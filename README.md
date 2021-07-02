<h1 align="center">
  <img src="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/logo_dobleM.png">
</h1>
<h1 align="center">
  Grupo de telegram: <a href="https://tttttt.me/EPG_dobleM">EPG dobleM</a>
</h1>

| Lista | Última actualización | Versión | Descripción |
| -	| - | - | - |
| Satélite | 02/07/2021 | [ 3.0 ](https://github.com/davidmuma/Canales_dobleM/blob/master/Varios/changelog.md) | Parrilla Movistar+ en HD y SD + deportivos alemanes |
| TDTChannels | 21/05/2021 | [ 2.2 ](https://github.com/LaQuay/TDTChannels/blob/master/info_television.md) | Más de 500 canales libres españoles y extranjeros |
| Pluto.TV | 21/05/2021 | [ 2.7 ](https://github.com/davidmuma/Canales_dobleM/blob/master/Varios/changelogpluto.md) | Más de 600 canales libres y en varios idiomas |
| Pluto.TV VOD | 21/05/2021 | [ 2.1 ](https://github.com/davidmuma/Canales_dobleM/blob/master/Varios/changelogpluto.md) | Más de 200 péliculas libres y en español |

Pásate por la pagína <a href="https://github.com/davidmuma/EPG_dobleM">EPG dobleM</a> para saber mas sobre la guía de programación y ver capturas.


En algunos sistemas es necesario tener instalado "ffmpeg" para que los canales IPTV funcionen correctamente, con el script se pueden instalar las dos opciones, con o sin ffmpeg, usa la que mejor te funcione. Algunos de éstos canales IPTV no disponen de guía de programación.

Los canales satélite de Movistar+ tienen todos su guía de programación y vienen exactamente con el mismo orden que tienen oficialmente en su página. Todos los canales tienen asignado su correspondiente dial, renombrados a su nombre oficial en lugar de mantener el nombre con el que se emiten por satélite, y vienen con su correspondiente logo/picon. 

También se instala un grabber que descarga la EPG con siete días de programación, pudiendo elegir tanto el formato de la guía (Con etiquetas de colores, sin etiquetas de colores, con etiquetas de colores y título en una sola linea, sin etiquetas de colores, título en una sola linea y sin caracteres especiales), como el tipo de imagen que aparecerá en el evento mostrado (Imágenes tipo poster o imágenes tipo fanart) y también da la posibilidad de elegir tipo de picons.

El script configura tvheadend con los idiomas Spanish, English, German y French (ver página <a href="https://github.com/davidmuma/EPG_dobleM">EPG dobleM</a> para mas información), modifica el cron para realizar la descarga de la EPG, configura el tipo y la ruta de los picons.

Al hacer la instalación de cualquiera de las listas de canales(Satélite o IPTV), el script respetará los canales creados por ti anteriormente.

Solo debes descargar el script una vez, él se encargará siempre de bajar la última versión del instalador y de la lista de canales.

En putty (o el programa que estés usando) ejecuta el script con el siguiente comando:
```
curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/dobleM.sh ; sh dobleM.sh
```
Si te falla el primero prueba con este otro comando:
```
wget -O dobleM.sh https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/dobleM.sh ; sh dobleM.sh
```
Una vez descargado puedes volver a ejecutarlo las veces que quieras con el comando:
```
sh dobleM.sh
```

El script solo es compatible con tvheadend 4.3 y en los siguientes sistemas:

- Synology/XPEnology
- Qnap
- LibreELEC/OpenELEC
- CoreELEC
- AlexELEC
- Linux
- Docker
- Enigma2 - [Instalación EPG](https://github.com/davidmuma/Canales_dobleM/blob/master/Varios/INSenigma2.md)

#
Notas:

En Synology si no has entrado con sudo -i, pon sudo antes del curl

En Docker ejecuta el script en el sistema anfitrión, no en el contenedor

#
Agradecimientos:

Jungle-Team por los picons

LaQuay y HelmerLuzo por los enlaces IPTV

#
<a href="https://www.paypal.me/EPGdobleM"><img src="https://image.flaticon.com/icons/png/128/3039/3039775.png" style="height: auto !important;width: auto !important;" ></a>  
Si te gusta mi trabajo, apóyame con una pequeña donación.

## CAPTURAS
![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/I1.jpg)
![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/I2.jpg)
## Tipos de picon
![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/picon.png)
