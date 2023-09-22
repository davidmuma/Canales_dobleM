### [<<<Volver](https://github.com/davidmuma/EPG_dobleM) - <b>Instalar guía en Coreelec </B>
#### 1> Descargar el archivo <i>"tv_grab_EPG_dobleM"</i> en en la siguiente ruta:
| Con imágenes tipo poster | ![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/poster.jpg)  |
| -	| - |
```
wget -P /storage/.kodi/addons/service.tvheadend43/bin/ https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/P/tv_grab_EPG_dobleM
```
| Con imágenes tipo fanart | ![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/fanart.jpg)  |
| -	| - |
```
wget -P /storage/.kodi/addons/service.tvheadend43/bin/ https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/F/tv_grab_EPG_dobleM
```
#### 2> Dar permisos de ejecución al grabber:
```
chmod 755 /storage/.kodi/addons/service.tvheadend43/bin/tv_grab_EPG_dobleM
```
### <b>Configuración de Tvheadend </B>

#### 3> Reiniciar Tvheadend y habilitar el grabber:
<i>[ Configuración ] - [ Canal / EPG ] - [ Módulos para Obtención de Guía ]</i>

Seleccionar ( Interno: XMLTV: EPG_dobleM-SAT ), marcar ( Habilitado: ) y clicar ( Guardar )

![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/tvheadend1.jpg)

#### 4> Programar la descarga de la guía:

<i>[ Configuración ] - [ Canal / EPG ] - [ Obtener Guía ]</i>
  
( Internal Grabber Settings - Cronología multi-línea: ), escribir la programación y clicar ( Guardar )
```
# A diario a las 5:00 | 9:00 | 13:00 |17:00 | 21:00
0 5 * * *
0 9 * * *
0 13 * * *
0 17 * * *
0 21 * * *
```
![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/tvheadend2.jpg)

#### 5> Forzar una descarga de la guía de programación:

En la misma pestaña anterior clicar ( Volver a ejecutar los capturadores de EPG internos )

![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/tvheadend3.jpg)

#### 6> Configurar el formato de la guía:

<i>[ Configuración ] - [ General ] - [ Base ]</i>

( EPG_Settings - Idioma(s) por defecto ), añadir el idioma y clicar ( Guardar )

Spanish: Guía con etiquetas de colores | [ejemplo](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/kodicolor.jpg)

English: Guía sin etiquetas de colores | [ejemplo](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/kodisincolor.jpg)

![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/EPG/tvheadend4.jpg)
