#!/bin/bash

#curl -s -O https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/i_dobleMe.sh

#EPG
 if [ ! -d /etc/epgimport/ ]; then
   echo "No tiene instalado epg import en su receptor, realice la instalacion y vuelva a intentarlo"
   sleep 5
 else
   curl -s -O http://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/dobleM_e2EPG.sources.tar
   tar xvf dobleM_e2EPG.sources.tar -C /etc/epgimport/
   rm -r dobleM_e2EPG.sources.tar
   echo "Ha finalizado la instalacion de EPG dobleM, espere unos segundos y volvera al menu"
   sleep 5
 fi

