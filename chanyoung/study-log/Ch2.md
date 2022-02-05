## 2장 테스트 환경 구성하기

**코드형 인프라(IaC, Infrastructure as Code)**

### 테스트 환경을 자동으로 구성하는 도구

*(책에서는  Virtual Box로 VM을 생성하고, 베이그런트로 프로비저닝을 진행한다.)*

- 프로비저닝이란 사용자의 요구에 맞게 시스템 자원을 할당, 배치, 배포해 두었다가 필요할 때 시스템을 사용할 수 있는 상태로 만드는 것 → 코드형 인프라

굳이 베이그런트로 하지 않고, 책에 나온 설정들을 도커 파일에 담아서 컨테이너 형태로 구동시켜보자.

### 베이그런트로 테스트 환경 구축하기 → 도커로 테스트 환경 구축

“가상 머신의 이름, CPU 수, 메모리 크기, 소속된 그룹을 명시”

- 도커에서는 CPU, 메모리, Block I/O 등을 제한할 수 있다.

### 🚨  베이그런트 파일에서 VM의 네트워크를 설정하는 부분이 있다.

```bash
...
	cfg.vm.network "private_network", ip: "192.168.1.10"
	cfg.vm.network "forwarded_port", guest: 22. host:60010, auto_correct: true, id: "ssh"
...
```

- 첫번째 줄에 대한 설명으로 “호스트 전용 네트워크를 private_network로 설정해 eth1 인터페이스를 호스트 전형으로 구성하고 IP는 192.168.1.10으로 지정한다”고 설명되어 있다.
    - 호스트 전용 네트워크는 호스트 내부에 192.168.1.0대의 사설망을 구성합니다. 가상 머신은 NAT(Network Address Translation) 인터페이스인 eth0를 통해서 인터넷에 접속합니다.
- *무언가 제대로 이해하지 못하고 있다.*

### 🔍  이해를 위한 정리

- 호스트 전용 네트워크란?
    - [참고 블로그](https://cjwoov.tistory.com/11)
    - VirtualBox 네트워크 설정에서 나오는 용어이다. 설정에는 NAT, **NAT 네트워크**, 어댑터에 브릿지, 내부 네트워크, 호스트 전용 어댑터, 일반 드라이버가 존재한다.
    - 이 중 **NAT 네트워크**를 살펴보면, 아래 그림과 같다. 즉, 가상 NAT 라우터의 내부 IP가 192.168.1.1이 되겠고, 게스트의 내부 IP가 192.168.1.10이 되는 것이다.
        
        ![image](https://user-images.githubusercontent.com/39409255/152646700-1aa7d506-9e90-44e9-b94d-feeb664fe791.png)
        
    - 추가로 호스트 전용 어댑터의 경우 아래 사진과 같이 게스트가 가상 호스트 네트워크 인터페이스를 통해 인터넷에 접근할 수 없다.
        
        ![image](https://user-images.githubusercontent.com/39409255/152646703-c5674cc4-c44d-4778-bd48-cb2745afb676.png)
        

- Network Interface란?
    - 흔히 우리가 `ifconfig` 명령어로 네트워크 인터페이스를 살핀다. 이때 네트워크 인터페이스는 아래 그림과 같이 TCP/IP 네트워크 계층을 의미한다.
        
        ![image](https://user-images.githubusercontent.com/39409255/152646707-8e88fc24-2429-4bcb-89c6-f93826e36f14.png)
        
    - 지원하는 인터페이스 유형에는 아래의 것들이 있고, 자세한 ifconfig 내 항목은 [이 블로그](https://seamless.tistory.com/12)를 참고하면 좋다.
        - 표준 이더넷 버전 2(en)
        - IEEE 802.3(et)
        - 루프백(lo)
        - ...

### Docker Network 짤막하게 설명

- [이 블로그](https://bluese05.tistory.com/15)를 참고하였고, 나중에 다 자세히 읽어보면 좋을 듯 하다.
- 컨테이너 간 통신을 하기 위해 아래 명령어로 네트워크를 생성하고, 컨테이너를 실행시켰을 때, 컨테이너 정보를 살펴보면, IPAddress 값이 존재하지 않았다.
    
    ```bash
    $ docker network create kube-network
    $ docker run --network kube-network --name server-1 -p 20000:20000 -d kube-study
    
    $ docker inspect -f "{{ .NetworkSettings.IPAddress }}" CONTAINER_ID
    
    >>> ""
    ```
    
    - 생성한 네트워크를 설정하지 않고 만들 경우에는 IPAddress 값이 존재한다.
- 그 이유는 Docker의 Network 환경은 Linux namespace 라는 기술을 이용해 구현되었으며, Container들은 각각의 독립된 환경을 제공 받게 된다. Container들은 기본적으로 한개의 ethernet interface 와 private IP를 자동으로 할당 받는다.
- *자세한 것은... 블로그를 더 읽어보자...*

### 다시 도커로 테스트 환경 구축하기 이어서

베이그런트에서 “호스트 전용 네트워크 설정, IP 지정, SSH 통신, 디렉터리 동기화”

→ 결론적으로 도커의 경우 컨테이너끼리 통신만 잘하면 되므로 아래와 같이 진행한다.

- `docker network ls`
    
    ![image](https://user-images.githubusercontent.com/39409255/152646710-ca6e81e6-53d3-4356-97be-7bf8fe8dc463.png)
    
    - 현재 생성되어 있는 Docker 네트워크 목록을 조회
- 다양한 종류의 드라이버 지원
    - `bridge` 네트워크는 하나의 호스트 컴퓨터 내에서 여러 컨테이너들이 서로 소통할 수 있도록 해줍니다.
    - `host` 네트워크는 컨터이너를 호스트 컴퓨터와 동일한 네트워크에서 컨테이너를 돌리기 위해서 사용됩니다.
    - `overlay` 네트워크는 여러 호스트에 분산되어 돌아가는 컨테이너들 간에 네트워킹을 위해서 사용됩니다.

### 도커 파일 작성

- 컨테이너를 VM처럼 쓰기 위한 가르침 ([참고 링크](https://www.popit.kr/%EA%B0%9C%EB%B0%9C%EC%9E%90%EA%B0%80-%EC%B2%98%EC%9D%8C-docker-%EC%A0%91%ED%95%A0%EB%95%8C-%EC%98%A4%EB%8A%94-%EB%A9%98%EB%B6%95-%EB%AA%87%EA%B0%80%EC%A7%80/))
    - Docker 컨테이너는 단지 명령만 실행하고 그 결과만 보여주는 기능을 수행한다.
    - `/bin/bash -c "while true; do echo "still alive"; sleep 100; done"`
        - 위 명령어가 계속 실행되는 컨테이너에 `docker attach`를 통해 컨테이너에 접속하여 100초마다 still alive를 출력하는 것을 볼수도 있고,
        - `docker exec` 를 통해 추가적인 명령어를 실행할 수 있다.
        - 추가로 `CMD tail -f /dev/null`

가상 머신 총 4대를 구성한다. 그리고 가상 머신 간에 네트워크 통신이 원활하게 작동하는지 확인