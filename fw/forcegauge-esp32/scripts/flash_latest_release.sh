#!/bin/bash

# One liner download latest release
#curl -s https://api.github.com/repos/szbeni/forcegauge/releases/latest | grep "forcegauge-esp32.ino.bin" | cut -d : -f 2,3 | tr -d \" | wget -qi -

curl -s https://api.github.com/repos/szbeni/forcegauge/releases/latest > ./tmp
NAMEURL=`cat ./tmp | grep "forcegauge-esp32.ino.bin" | cut -d : -f 2,3 | tr -d \"`
VERSION=`cat ./tmp |  grep tag_name | cut -d : -f 2,3 | tr -d \" | tr -d ,  | tr -d " "`
FILENAME=`echo $NAMEURL | awk -F',' '{print $1}'`
URL=`echo $NAMEURL | awk -F',' '{print $2}'`
rm tmp
# echo $FILENAME
# echo $URL
# echo $VERSION
wget -qO $FILENAME $URL
echo "Latest release: $VERSION"

if [ $# -eq 1 ]
  then
    UPDATE_URL="http://$1/update"
    echo -e "Uploading $FILENAME $VERSION to $1:\n"
    curl -F 'update=@./$FILENAME' $UPDATE_URL
fi

