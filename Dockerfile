FROM maven:3-amazoncorretto-8-debian as server-stopper-build

WORKDIR /var/tmp

RUN apt-get update \
    && apt-get install -y git

RUN git clone https://github.com/vincss/mcEmptyServerStopper.git

WORKDIR mcEmptyServerStopper

RUN mvn clean package


FROM node:lts-alpine

# Environment variables
ENV SERVER_PATH="/server"\
    DEPENDENCIES_PATH="/depencencies"

WORKDIR /

RUN apk update \
    && apk add git wget jq openjdk17 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir ${DEPENDENCIES_PATH}

ADD "https://github.com/vincss/mcsleepingserverstarter/releases/latest" skipcache

RUN git clone https://github.com/vincss/mcsleepingserverstarter.git ${DEPENDENCIES_PATH}

WORKDIR ${DEPENDENCIES_PATH}

RUN npm install

COPY --from=server-stopper-build /var/tmp/mcEmptyServerStopper/target/mcEmptyServerStopper-*.jar .

ENTRYPOINT exec sh papermc.sh
