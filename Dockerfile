FROM golang:1.20 as build
WORKDIR /app
COPY go.mod go.sum ./
ENV GOPROXY=https://goproxy.cn
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

FROM alpine:3.12
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
# 如果update失败,在/etc/docker/daemon.json添加一行: "dns": ["8.8.8.8"]
RUN apk update
RUN apk add --no-cache ca-certificates
RUN apk add --no-cache curl
RUN curl -fsSL https://raw.staticdn.net/pressly/goose/master/install.sh | sh
WORKDIR /app
COPY --from=build /app/main /app/main
COPY --from=build /app/db /app/db
EXPOSE 8000
CMD ["/app/main"]
