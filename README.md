<h1 align="center">
  <img src="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/logo_dobleM.png">
</h1>
<h1 align="center">
  Grupo de telegram: <a href="https://tttttt.me/EPG_dobleM">EPG dobleM</a>
</h1>

| | Última actualización | Versión |
| -	| - | - |
| Satélite | 03/02/2021 | [ 2.0 ](https://github.com/davidmuma/Canales_dobleM/blob/master/Varios/changelog.md) | 
| TDTChannels | 12/02/2021 | [ 2.0 ](https://github.com/LaQuay/TDTChannels/blob/master/info_television.md) | 
| Pluto.TV | 12/02/2021 | [ 2.2 ](https://github.com/davidmuma/Canales_dobleM/blob/master/Varios/changelogpluto.md) | 
| Pluto.TV VOD | 12/02/2021 | [ 1.1 ](https://github.com/davidmuma/Canales_dobleM/blob/master/Varios/changelogpluto.md) | 

Pásate por la pagína <a href="https://github.com/davidmuma/EPG_dobleM">EPG dobleM</a> para saber mas sobre la guía de programación y ver capturas de como queda.

Actualmente el script incluye las siguientes listas de canales:

- Satélite: Todos los canales de Movistar+ en HD y SD + canales deportivos alemanes.
- IPTV / TDTChannels: Más de 500 canales libres españoles y extranjeros (gracias LaQuay)
- IPTV / Pluto.TV: Más de 600 canales libres y en varios idiomas
- IPTV / Pluto.TV VOD: Más de 200 péliculas libres y en español


Para que los canales IPTV funcionen correctamente será necesario tener instalado "ffmpeg" en el sistema. Muchos de éstos canales IPTV no disponen de guía de programación.

Los canales de Movistar+ tienen todos su guía de programación y vienen exactamente con el mismo orden que tienen oficialmente en su página. Todos los canales también están asignados a su correspondiente dial, renombrados a su nombre oficial en lugar de mantener el nombre con el que se emiten por satélite, y vienen con su correspondiente logo asignado. 

También se instala un grabber que descarga la EPG con siete días de programación, pudiendo elegir tanto el formato de la guía (Con etiquetas de colores, sin etiquetas de colores, con etiquetas de colores y título en una sola linea, sin etiquetas de colores, título en una sola linea y sin caracteres especiales), como el tipo de imagen que aparecerá en el evento mostrado (Imágenes tipo poster o imágenes tipo fanart) y también da la posibilidad de elegir tipo de picons.

El script configura tvheadend con los idiomas Spanish, English, German y French(ver página EPG_dobleM para mas información), modifica el cron para realizar la descarga de la EPG, configura el tipo y la ruta de los picons. (Gracias Jungle-Team por los picons)

Al hacer la instalación de cualquiera de las listas de canales(Satélite o IPTV), el script respetará los canales creados por ti anteriormente.

Solo debes descargar el script una vez, él se encargará siempre de bajar la última versión del instalador y de la lista de canales.

Ejecuta el script con el siguiente comando:
```
wget -q https://github.com/davidmuma/Canales_dobleM/raw/master/dobleM.sh ; sh dobleM.sh
```

El script es compatible con los siguientes sistemas:

- Synology/XPEnology
- Qnap
- LibreELEC/OpenELEC
- CoreELEC
- AlexELEC
- Linux
- Docker

Notas:

En Synology si no has entrado con sudo -i, pon sudo antes del wget y del sh

En Docker ejecuta el script en el sistema anfitrión, no en el contenedor

<a href="https://www.paypal.me/EPGdobleM"><img src="https://image.flaticon.com/icons/png/128/3039/3039775.png" style="height: auto !important;width: auto !important;" ></a>  
Si te gusta mi trabajo, apóyame con una pequeña donación.

## CAPTURAS
![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/I1.jpg)
![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/I2.jpg)
