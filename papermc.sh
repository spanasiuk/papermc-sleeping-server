#!/bin/bash

# Enter server directory
cd server

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
wget ${URL} -O ${JAR_NAME}

# If this is the first run, accept the EULA
if [ ! -e eula.txt ]
then
  # Run the server once to generate eula.txt
  java -jar ${JAR_NAME}
  # Edit eula.txt to accept the EULA
  sed -i 's/false/true/g' eula.txt
fi

mv ${JAR_NAME} paper.jar