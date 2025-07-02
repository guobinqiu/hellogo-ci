# hellogo-ci

[hellogo-cd](https://github.com/guobinqiu/hellogo-cd)

## Design Principles

- GitOps: ci和cd分离, cd端使用ArgoCD
- Rollback: 应用和数据联动
  - 回滚应用的同时数据跟着回滚到匹配状态(简单讲,在CI阶段进行备份,在CD阶段回滚备份)
  - 每次发布都备份一个全量数据库, 回滚的时候把当时的全量数据库再执行一遍
