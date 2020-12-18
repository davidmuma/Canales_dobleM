<h1 align="center">
  <img src="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/logo_dobleM.png">
</h1>
<h1 align="center">
  Grupo de telegram: <a href="https://tttttt.me/EPG_dobleM">EPG dobleM</a>
</h1>

# ULTIMA ACTUALIZACION
| **Satélite** | **IPTV** |
| -	| -	|
| 18/12/2020 | 24/10/2020 |

Pásate por la pagína <a href="https://github.com/davidmuma/EPG_dobleM">EPG dobleM</a> para saber mas sobre la guía de programación y ver capturas de como queda.

Actualmente el script incluye todos los canales satélite de Movistar+ y canales deportivos alemanes. Tambien es posible instalar una lista de canales IPTV libres y legales (gracias LaQuay). 

Para que los canales IPTV funcionen correctamente será necesario tener instalado "ffmpeg" en el sistema. Muchos de éstos canales IPTV no disponen de guía de programación.

Los canales de Movistar+ tienen todos su guía de programación y vienen exactamente con el mismo orden que tienen oficialmente en su página. Todos los canales también están asignados a su correspondiente dial, renombrados a su nombre oficial en lugar de mantener el nombre con el que se emiten por satélite, y vienen con su correspondiente logo asignado. 

También se instala un grabber que descarga la EPG con cinco días de programación, pudiendo elegir tanto el formato de la guía (Con etiquetas de colores, sin etiquetas de colores, con etiquetas de colores y título en una sola linea, sin etiquetas de colores, título en una sola linea y sin caracteres especiales), como el tipo de imagen que aparecerá en el evento mostrado (Imágenes tipo poster o imágenes tipo fanart).

El script configura tvheadend con los idiomas Spanish, English, German y French(ver página EPG_dobleM para mas información), modifica el cron para realizar la descarga de la EPG, configura el tipo y la ruta de los picons.

Al hacer la instalación de cualquiera de las dos listas de canales(Satélite o IPTV), el script respetará los canales creados por ti anteriormente.

Solo debes descargar el script una vez, él se encargará siempre de bajar la última versión del instalador y de la lista de canales.

Descarga el script en el directorio que quieras
```
wget https://github.com/davidmuma/Canales_dobleM/raw/master/dobleM.sh
```
y ejecútalo con
```
sh dobleM.sh
```

El script es compatible con los siguientes sistemas:

- Synology/XPEnology
- LibreELEC/OpenELEC/CoreELEC
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
