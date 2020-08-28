#!/bin/bash
cd `dirname $0`

img_mvn="maven:3.3.3-jdk-8"                 # docker image of maven
m2_cache=~/.m2                              # the local maven cache dir
proj_home=$PWD                              # the project root dir
img_output="epxing/epxing-eureka"      # output image tag
project="eureka-service"

# should use git clone https://name:pwd@xxx.git
git pull

echo "use docker maven"
docker run --rm \
   -v $m2_cache:/root/.m2 \
   -v $proj_home:/usr/src/mymaven \
   --net=host \
   -w /usr/src/mymaven $img_mvn mvn clean package -U -Dmaven.test.skip=true


# 兼容所有sh脚本
sudo mv $proj_home/target/$project-*.jar $proj_home/target/app.jar
docker build -t $img_output .

mkdir -p $PWD/logs
chmod 777 $PWD/logs


# 删除容器
docker rm -f $project &> /dev/null

version=`date "+%Y%m%d%H"`

# 启动镜像
docker run -d --restart=on-failure:5 --privileged=true \
    -p 8089:8089 \
    -w /home \
    -v $PWD/logs:/home/logs \
    --name $project $img_output \
    java  \
    -Djava.security.egd=file:/dev/./urandom \
    -Duser.timezone=Asia/Shanghai \
    -XX:+PrintGCDateStamps \
    -XX:+PrintGCTimeStamps \
    -XX:+PrintGCDetails \
    -XX:+HeapDumpOnOutOfMemoryError \
    -Xloggc:logs/gc_$version.log \
    -jar /home/app.jar


#打印日志
docker logs -f --tail 300  $project