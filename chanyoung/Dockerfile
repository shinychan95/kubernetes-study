ARG CENTOS_TAG=centos7
FROM docker.io/centos:${CENTOS_TAG}
LABEL maintainer="shinychan95@gmail.com"

# TODO: 이후 사용될 포트 및 마운트 경로를 지정해야 한다.

RUN yum -y install epel-release vim-enhanced

CMD tail -f /dev/null