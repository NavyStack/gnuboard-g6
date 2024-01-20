# gnuboard-g6

K-CMS 그누보드(gnuboard) 6 도커이미지 (자동 빌드)

[![Nightly Build](https://github.com/NavyStack/gnuboard-g6/actions/workflows/docker-image-nightly.yml/badge.svg)](https://github.com/NavyStack/gnuboard-g6/actions/workflows/docker-image-nightly.yml)

- [NavyStack Github](https://github.com/NavyStack/)<br>
- [NavyStack 그누보드6 Dockerhub](https://hub.docker.com/r/navystack/gnuboard-g6)<br>
- [NavyStack 그누보드6 Github](https://github.com/NavyStack/gnuboard-g6)<br>
- [그누보드6 Github](https://github.com/gnuboard/g6.git)<br>

## K-CMS 그누보드 (gnuboard) 6

1. 정식 `semver` 태그가 부여되기 전까지는 매일 자동으로 빌드됩니다. (nightly)
2. 정식 `semver` 태그가 부여된 후에는, 해당 태그에 업데이트가 있을 때마다 자동으로 빌드됩니다.

> [!TIP]
> 그누보드가 새롭게 Python 기반으로 개발되었습니다. 개발자 여러분의 적극적인 참여를 부탁드립니다.

> [!NOTE]
> 정식 `semver` 태그가 부여되면, 폴더 경로가 변경될 수 있습니다.

> [!CAUTION]
> 코어 수정이 필요할 경우, 개별적인 수정을 하기보다는 Mainstream에 PR을 제출함으로써 전체 커뮤니티에 기여하고, 해당 변경사항이 반영되도록 하는 것이 바람직합니다.

> [!IMPORTANT]
> 본 레포의 `docker-compose.yml` 파일은 효율성을 위해 Traefik을 사용하는 것을 목적으로 설계되었습니다.<br><br>
> 결론도출근거
> 1. 웹서버인 uvicorn이 이미 존재함 따라서, Nginx를 앞단에 배치하는 것은 레이턴시만 높일 뿐임. <br>
> 2. Reverse-Proxy만을 목적으로 설계된 Traefik이 적합하다 판단.<br><br>
> 따라서 관련된 선행 작업이 있습니다.<br> [너무나 쉬운 트래픽 리버스 프록시](https://github.com/NavyStack/traefik)를 참고하셔서 진행하셔야 합니다.

## Traefik으로 사용하기
1. `git clone https://github.com/NavyStack/gnuboard-g6.git` <br>
2. `cd gnuboard-g6` <br>
3. `docker compose -f up -d`

## Nginx로 사용하기
1. `git clone https://github.com/NavyStack/gnuboard-g6.git` <br>
2. `cd gnuboard-g6` <br>
3. `docker compose -f docker-compose-nginx.yml up -d`

## PGsql을 DB로 사용하기
1. `git clone https://github.com/NavyStack/gnuboard-g6.git` <br>
2. `cd gnuboard-g6` <br>
3. `docker compose -f docker-compose-pgsql.yml up -d`

## 직접 빌드하고 싶으신가요?
1. `git clone https://github.com/NavyStack/gnuboard-g6.git` <br>
2. `cd gnuboard-g6` <br>
3. `docker buildx build -t navystack/gnuboard-g6 -f Dockerfile . --load` <br>

## 라이선스

SPDX-License-Identifier: MIT

모든 Docker 이미지와 마찬가지로, 여기에는 다른 라이선스(예: 기본 배포판의 Bash 등 및 포함된 기본 소프트웨어의 직간접적인 종속성)가 적용되는 다른 소프트웨어도 포함될 수 있습니다.

사전 빌드된 이미지 사용과 관련하여, 이 이미지를 사용할 때 이미지에 포함된 모든 소프트웨어에 대한 관련 라이선스를 준수하는지 확인하는 것은 이미지 사용자의 책임입니다.

기타 모든 상표는 각 소유주의 재산이며, 달리 명시된 경우를 제외하고 본문에서 언급한 모든 상표 소유자 또는 기타 업체와의 제휴관계, 홍보 또는 연관관계를 주장하지 않습니다.
