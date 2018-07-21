# NLP with PyTorch 고급반 실습용 도커 이미지

* OS: Ubuntu 16.04
* Preinstalled libraries: PyTorch (CPU), TorchText, KoNLPy, Mecab-Ko, MUSE, Champollion, FastText, NLTK, SRILM
* Sample code in `/root`
* External library source code in `/opt`
* Dockerfile available at https://github.com/juneoh/fastcampus-pytorchnlp-advanced

## Docker Quickstart

`sudo` 권한이 필요할 수 있습니다.

### 이미지 불러오기

```
docker load -i 이미지파일
```

예: `docker load -i pytorchnlp-advanced.v0.2.3.img.tar`

### 새 컨테이너 띄우기

```
docker run 옵션 이미지명
```

예: `docker run -d -P --name nlp pytorchnlp-advanced:v0.2.3`

* `-d` 데몬 모드
* `-P` 컨테이너 포트와 호스트 포트 연결
* `--name` 컨테이너명 지정

### 실행 중인 컨테이너 셸에 접속하기

```
docker exec -it 컨테이너명 명령어
```

예: `docker exec -it nlp bash`

### 컨테이너 중지하기

```
docker stop 컨테이너명
```

예: `docker stop nlp`

### 컨테이너 재실행하기

```
docker start 컨테이너명
```

예: `docker start nlp`

### 컨테이너에 파일 복사하기

```
docker cp 파일명 컨테이너명:위치
```

예: `docker cp data.txt nlp:/root/`
