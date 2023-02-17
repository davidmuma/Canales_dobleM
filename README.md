<p align="center">
  <a href="https://github.com/davidmuma/EPG_dobleM"> <img src="https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Images/logo_dobleM.png" width="30%" height="30%"> </a>
  <a href="https://github.com/davidmuma/Canales_dobleM"> <img src="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/logo_dobleM.png" width="30%" height="30%"> </a>
  <a href="https://github.com/davidmuma/Docker_dobleM"> <img src="https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/logo_dobleM.png" width="30%" height="30%"> </a>
</p>

<h2 align="center">
  Grupo de telegram: <a href="https://t.me/EPG_dobleM">dobleM</a>
</h2>

<h2 align="center">
  
  | Lista | Última actualización | Versión |
  | :-:	| :-: | :-: |
  | Satélite Astra | 17/02/23 | [ 5.5 ](https://github.com/davidmuma/Canales_dobleM/blob/master/Varios/changelog.md) |
  
</h2>

Los canales de Movistar+ tienen asignado su correspondiente dial y están en el mismo orden en el que aparecen en su página web.
Todos están renombrados con su nombre oficial en lugar de mantener el nombre con el que se emiten por satélite y vienen con su correspondiente guía de programación y  picon. 
***
El script permite seleccionar la lista a instalar en función de nuestra instalación de antena parabólica:
- Todo (Astra individual + comunitaria + canales SD)
- Astra individual + canales SD
- Astra comunitaria + canales SD
- Astra individual
- Astra comunitaria

Y configura distintos formatos de guía de programación y picon, pudiendo elegir:
- el formato de la guía:

  | Con etiquetas de colores [(ampliar)](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/kodicolor.jpg) | Sin etiquetas de colores [(ampliar)](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/kodisincolor.jpg) |
  | :-:	| :-: |
  | <a href="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/kodicolor.jpg"><img src="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/kodicolorp.jpg"></a> | <a href="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/kodisincolor.jpg"><img src="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/kodisincolorp.jpg"></a> |
 
 - el tipo de imagen que aparecerá en el evento mostrado:

   | Poster | Fanart |
   | :-:	| :-: |
   | ![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/poster.jpg) | ![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/fanart.jpg) |

- y el tipo de picon:

  ![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/picon.png)

El propio script configura tvheadend con las opciones indicadas, modifica el cron para realizar la descarga de la EPG y configura el tipo y la ruta de los picons.

Al hacer la instalación de la lista de canales satélite, el script respetará los canales creados por ti anteriormente.

Solo debes descargar el script una vez, él se encargará siempre de bajar la última versión del instalador y de la lista de canales.

En putty (o el programa que estés usando) ejecuta el script con el siguiente comando:
```
curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/dobleM.sh ; sh dobleM.sh
```
Si te falla el primero prueba con este otro comando:
```
wget -O dobleM.sh --no-check-certificate "https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/dobleM.sh" ; sh dobleM.sh
```
Una vez descargado puedes volver a ejecutarlo las veces que quieras con el comando:
```
sh dobleM.sh
```
***
El script solo es compatible con tvheadend 4.3 y para los siguientes sistemas:

- Synology/XPEnology (DSM 6)
- Qnap
- LibreELEC/OpenELEC
- CoreELEC
- AlexELEC
- Linux
- ~~Docker~~ - [Nuevo script especial para Docker](https://github.com/davidmuma/Docker_dobleM/blob/main/README.md)
- Enigma2 - [Instalación y configuración](https://github.com/davidmuma/Canales_dobleM/blob/master/Varios/INSenigma2.md)

-NOTA: En Synology si no has entrado con sudo -i, pon sudo antes del curl
***
Agradecimientos:

Manuelin por crear los cimientos

Jungle-Team por los picons

LaQuay y HelmerLuzo por los enlaces IPTV
***
<a href="https://www.paypal.me/EPGdobleM"><img src="http://www.webgrabplus.com/sites/default/files/styles/thumbnail/public/badges/donation.png" style="height: auto !important;width: auto !important;" ></a> Si te gusta mi trabajo puedes invitarme a un café :smile:
***
## CAPTURAS
![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/I1.jpg)
![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/I2.jpg)
