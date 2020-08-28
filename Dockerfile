# 建议生产使用，ref: http://blog.tenxcloud.com/?p=1894
FROM fabric8/java-jboss-openjdk8-jdk

#设置环境变量
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

#使用root用户
USER root

#拷贝资源
COPY target/app.jar /home/