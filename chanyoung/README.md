## 2장 테스트 환경을 도커 컨테이너로 구성하기

```sh
# 컨테이너 간 통신할 네트워크 생성
$ docker network create kube-network

# 이미지 빌드
$ docker build -t kube-study:latest .

# 컨테이너 실행
$ docker run --network kube-network --name server-1 -p 20000:20000 -d kube-study
$ docker run --network kube-network --name server-2 -p 20000:20000 -d kube-study

# 네트워크 통신 잘 작동하는지 확인
$ docker exec -it server-1 /bin/bash
$ ping server-2 -c 5

# 실행 중인 도커 컨테이너 목록 확인
$ docker container ls

# 실행 중인 도커 컨테이너에 접속
$ docker exec -it server-1 /bin/bash
```
