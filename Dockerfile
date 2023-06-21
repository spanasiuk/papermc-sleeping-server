FROM maven:3-amazoncorretto-8-debian as server-stopper-build

WORKDIR /var/tmp

RUN apt-get update \
    && apt-get install -y git

RUN git clone https://github.com/vincss/mcEmptyServerStopper.git

WORKDIR mcEmptyServerStopper

RUN mvn clean package


FROM node:lts-alpine

# Environment variables
ENV MC_VERSION="latest" \
    PAPER_BUILD="latest"

RUN apk update \
    && apk add git wget jq openjdk17 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir server

ADD "https://github.com/vincss/mcsleepingserverstarter/releases/latest" skipcache

RUN git clone https://github.com/vincss/mcsleepingserverstarter.git server

WORKDIR server

RUN npm install

ADD papermc.sh .

ADD "https://papermc.io/api/v2/projects/paper" skipcache

RUN sh papermc.sh

COPY --from=server-stopper-build /var/tmp/mcEmptyServerStopper/target/mcEmptyServerStopper-*.jar ./plugins/

ENTRYPOINT exec npm start
