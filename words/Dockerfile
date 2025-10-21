# 使用官方Maven镜像作为构建环境
FROM maven:3.9.0-eclipse-temurin-8 AS builder

# 设置工作目录
WORKDIR /app

# 复制pom.xml文件
COPY pom.xml .

# 下载依赖（利用Docker缓存层）
RUN mvn dependency:go-offline -B

# 复制源代码
COPY src ./src

# 编译和打包
RUN mvn clean package -DskipTests

# 使用更小的JRE镜像
FROM openjdk:8-jre-alpine

# 设置工作目录
WORKDIR /app

# 从构建阶段复制JAR文件和依赖
COPY --from=builder /app/target/words.jar .
COPY --from=builder /app/target/dependency ./dependency

# 暴露端口8080
EXPOSE 8080

# 运行程序
CMD ["java", "-Xmx8m", "-Xms8m", "-jar", "words.jar"]
