## 2장 테스트 환경을 도커 컨테이너로 구성하기

```sh
# 컨테이너 간 통신할 네트워크 생성
$ docker network create kube-network

# 이미지 빌드
$ docker build -t kube-study:latest .

# 컨테이너 실행
$ docker run --network kube-network --name server-1 -p 20000:20000 -d kube-study
$ docker run --network kube-network --name server-2 -p 20000:20000 -d kube-study

# 네트워크 통신의 경우, server-1 컨테이너에 들어가서 아래 명령어를 입력해보면 된다.
$ ping server-2

```
