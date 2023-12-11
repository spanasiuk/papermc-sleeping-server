#!/bin/bash

SERVER_PATH=/server
DEPENDENCIES_PATH=/depencencies

# Enter server directory
cd ${SERVER_PATH}

echo "Fetching paper.jar with following params: MC_VERSION: [${MC_VERSION}], PAPER_BUILD: [${PAPER_BUILD}], AUTO_UPDATE: [${AUTO_UPDATE}], SERVER_PATH: [${SERVER_PATH}], DEPENDENCIES_PATH: [${DEPENDENCIES_PATH}]"

if [ "${AUTO_UPDATE}" = true ] && [ ! -e paper.jar ]; then
  # Get version information and build download URL and jar name
  URL=https://papermc.io/api/v2/projects/paper
  if [ ${MC_VERSION} = latest ]
  then
    # Get the latest MC version
    MC_VERSION=$(wget -qO - $URL | jq -r '.versions[-1]') # "-r" is needed because the output has quotes otherwise
  fi
  URL=${URL}/versions/${MC_VERSION}
  if [ ${PAPER_BUILD} = latest ]
  then
    # Get the latest build
    PAPER_BUILD=$(wget -qO - $URL | jq '.builds[-1]')
  fi
  JAR_NAME=paper-${MC_VERSION}-${PAPER_BUILD}.jar
  URL=${URL}/builds/${PAPER_BUILD}/downloads/${JAR_NAME}

  # Remove old server jar(s)
  rm -f paper.jar
  # Download new server jar
  wget ${URL} -O paper.jar
fi

# If this is the first run, accept the EULA
if [ ! -e eula.txt ]
then
  echo "eula.txt doesn't exist, creating a new one"
  # Run the server once to generate eula.txt
  java -jar paper.jar
  # Edit eula.txt to accept the EULA
  sed -i 's/false/true/g' eula.txt
fi

cp ${DEPENDENCIES_PATH}/mcEmptyServerStopper-*.jar ./plugins/

if [ ! -e sleepingSettings.yml ]; then
  echo "sleepingSettings.yml doesn't exist, copying the default one"
  cp -n ${DEPENDENCIES_PATH}/sleepingSettings.yml ./
  echo "minecraftWorkingDirectory: \"${SERVER_PATH}\"" >> sleepingSettings.yml
fi

cd ${DEPENDENCIES_PATH}

rm sleepingSettings.yml
ln -s ${SERVER_PATH}/sleepingSettings.yml ./

npm start