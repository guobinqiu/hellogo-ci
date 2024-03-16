pipeline {
    agent any

    tools {
        go 'go_1.20.6'
    }
    
    environment {
        GOPROXY = 'https://goproxy.cn,direct'
    }

    stages {
        stage('Static Analysis') {
            steps {
                //withSonarQubeEnv是SonarQube Scanner for Jenkins插件提供的一个函数
                withSonarQubeEnv('sonarqube_server') {
                    sh '/opt/sonar-scanner/bin/sonar-scanner'
                }
            }
        }

        stage('Build') {
            steps {
                //withCredentials是Credentials Binding Plugin插件提供的一个函数, 凭证类型:Username with password
                withCredentials([
                    usernamePassword(credentialsId: '75d62f1f-d4a5-4033-b0b9-eb05ffb862be', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')
                ]) {
                    sh """
                    docker build -t qiuguobin/hellogo -f Dockerfile .
                    docker tag qiuguobin/hellogo qiuguobin/hellojava-${GIT_COMMIT}
                    echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin
                    docker push qiuguobin/hellogo
                    docker push qiuguobin/hellogo-${GIT_COMMIT}
                    """
                }
            }
        }

        stage('Trigger CD') {
            steps{
                dir('../hellogo-cd') {
                    // checkout([$class: 'GitSCM',
                    //     branches: [[name: '*/master']], 
                    //     doGenerateSubmoduleConfigurations: false, 
                    //     extensions: [], 
                    //     submoduleCfg: [],
                    //     userRemoteConfigs: [[credentialsId: 'd04c26e0-50f5-4b05-adeb-fdc09e6f77de', url: 'https://github.com/guobinqiu/hellogo-cd.git']]
                    // ])
                    git branch: 'main', credentialsId: 'd04c26e0-50f5-4b05-adeb-fdc09e6f77de', url: 'https://github.com/guobinqiu/hellogo-cd.git'

                    //latest_version记录每次应用提交后数据迁移到的位置

                    //这里有坑
                    //双引号sh块内的变量会被jenkins当作groovy变量
                    //单引号sh块内的变量会被jenkins当作shell变量

                    //这里定义latest_version为shell变量
                    //当latest_version在双引号sh块内时, ${latest_version}读取的是groovy变量; \${latest_version}读取的才是shell变量
                    //当latest_version在单引号sh块内时, ${latest_version}读取的是shell变量; 由于${GIT_COMMIT}是groovy变量, 这里只能使用双引号sh块配合\转义来读取shell变量
                    // withCredentials([usernamePassword(credentialsId: 'd04c26e0-50f5-4b05-adeb-fdc09e6f77de', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                    //     sh """
                    //     #成对保留每一次变更, 回滚时使应用变更和数据变更能够保持同步
                    //     mkdir -p revisions/${GIT_COMMIT}

                    //     #设置应用版本
                    //     (cd kube && kustomize edit set image qiuguobin/hellogo=qiuguobin/hellogo:${GIT_COMMIT})
                    //     kustomize build kube > revisions/${GIT_COMMIT}/deploy.yaml
                        
                    //     #设置数据版本
                    //     latest_version=`ls ../hellogo-ci/db/migrations/ | cut -d '_' -f1 | sort -rn | head -n 1`
                    //     echo \${latest_version}
                    //     sed "s/我是要被替换的/\${latest_version}/g" job/rollback.yaml > revisions/${GIT_COMMIT}/rollback.yaml
                        
                    //     #提交变更
                    //     git config user.name "Guobin"
                    //     git config user.email "qracle@126.com"
                    //     git add .
                    //     git commit -m "deploy"
                    //     git push https://${GIT_USER}:${GIT_PASS}@github.com/guobinqiu/hellogo-cd.git
                    //     """
                    // }

                    //这里定义latest_version为groovy变量, 是jenkins推荐做法
                    //双引号sh块内的变量会被jenkins当作groovy变量
                    //当latest_version在双引号sh块内时, 通过${latest_version}读取groovy变量值
                    withCredentials([usernamePassword(credentialsId: 'd04c26e0-50f5-4b05-adeb-fdc09e6f77de', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                        script {
                            //一定要trim
                            latest_version = sh(script: "ls ../hellogo-ci/db/migrations/ | cut -d '_' -f1 | sort -rn | head -n 1", returnStdout: true).trim()
                            echo "${latest_version}"

                            sh """
                            #成对保留每一次变更, 回滚时使应用变更和数据变更能够保持同步
                            mkdir -p revisions/${GIT_COMMIT}

                            #设置应用版本
                            (cd kube && kustomize edit set image qiuguobin/hellogo=qiuguobin/hellogo:${GIT_COMMIT})
                            kustomize build kube > revisions/${GIT_COMMIT}/deploy.yaml
                            
                            #设置数据版本
                            sed "s/我是要被替换的/${latest_version}/g" job/rollback.yaml > revisions/${GIT_COMMIT}/rollback.yaml
                            
                            #提交变更
                            git config user.name "Guobin"
                            git config user.email "qracle@126.com"
                            git add .
                            git commit -m "deploy"
                            git push https://${GIT_USER}:${GIT_PASS}@github.com/guobinqiu/hellogo-cd.git
                            """
                        }
                    }
                }
            }
        }
    }
}
