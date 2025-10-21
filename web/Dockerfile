# 使用官方Go镜像作为构建环境
FROM golang:1.21-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制Go源文件
COPY dispatcher.go .

# 编译Go程序（使用CGO_ENABLED=0减少依赖）
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o dispatcher dispatcher.go

# 使用scratch镜像作为运行环境（最小化）
FROM scratch

# 从alpine镜像复制ca-certificates
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# 设置工作目录
WORKDIR /app

# 从构建阶段复制编译好的二进制文件
COPY --from=builder /app/dispatcher .

# 复制静态文件目录
COPY static ./static

# 暴露端口80
EXPOSE 80

# 运行程序
CMD ["./dispatcher"]
