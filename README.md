<h1 align="center">
  <img src="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/logo_dobleM.png">
</h1>
<h1 align="center">
  Grupo de telegram: <a href="https://tttttt.me/EPG_dobleM">EPG dobleM</a>
</h1>

Pásate por la pagína <a href="https://github.com/davidmuma/EPG_dobleM">EPG dobleM</a> para saber mas sobre la guía de programación y ver capturas de como queda.

Actualmente el script incluye todos los canales de Movistar+, canales deportivos alemanes y canales IPTV en abierto (Gracias LaQuay). 

Para que los canales IPTV funcionen correctamente será necesario tener instalado "ffmpeg" en el sistema. Solo disponen de EPG algunos(pocos) canales, espero solucionarlo en futuras versiones.

Los canales de Movistar+ vienen exactamente con el mismo orden que tienen oficialmente en su página. Todos los canales también están asignados a su correspondiente dial, renombrados a su nombre oficial en lugar de mantener el nombre con el que se emiten por satélite, y vienen con su correspondiente logo asignado. 

También se instala un grabber que descarga la EPG con cinco días de programación de prácticamente todos los canales, pudiendo elegir el tipo de imagen que aparecerá en el evento mostrado, poster o fanart.

El script configura tvheadend con los idiomas Spanish, English, German y French(ver página EPG_dobleM para mas información), modifica el cron para realizar la descarga de la EPG, configura el tipo y la ruta de los picons.

Solo debes descargar el script una vez, él se encargará siempre de bajar la última versión del instalador y de la lista de canales.

Descarga el script en el directorio que quieras (en Synology si no has entrado con sudo -i, pon sudo antes del wget)
```
wget https://github.com/davidmuma/Canales_dobleM/raw/master/dobleM.sh
```
y ejecútalo con (en Synology si no has entrado con sudo -i, pon sudo antes del sh)
```
sh dobleM.sh
```

El script es compatible con los siguientes sistemas:

- Synology/XPEnology
- LibreELEC/OpenELEC/CoreELEC
- Linux
