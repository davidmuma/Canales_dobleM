## <b>Instalar guía en Alexelec </B>
#### 1> Descargar el archivo <i>"tv_grab_EPG_dobleM"</i> en en la siguiente ruta:
| Con imágenes tipo poster | ![alt text](https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Varios/poster.jpg)  |
| -	| - |
```
wget -P /storage/.config/tvheadend/bin/ https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/P/tv_grab_EPG_dobleM
```
| Con imágenes tipo fanart | ![alt text](https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Varios/fanart.jpg)  |
| -	| - |
```
wget -P /storage/.config/tvheadend/bin/ https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/F/tv_grab_EPG_dobleM
```
#### 2> Dar permisos de ejecución al grabber:
```
chmod 755 /storage/.config/tvheadend/bin/tv_grab_EPG_dobleM
```
### <b>Configuración de Tvheadend </B>

#### 3> Reiniciar Tvheadend y habilitar el grabber:
<i>[ Configuración ] - [ Canal / EPG ] - [ Módulos para Obtención de Guía ]</i>

Seleccionar ( Interno: XMLTV: EPG_dobleM-SAT ), marcar ( Habilitado: ) y clicar ( Guardar )

![alt text](https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Varios/tvheadend1.jpg)

#### 4> Programar la descarga de la guía:

<i>[ Configuración ] - [ Canal / EPG ] - [ Obtener Guía ]</i>
  
( Internal Grabber Settings - Cronología multi-línea: ), escribir la programación y clicar ( Guardar )
```
# Todos los días a las 8:04, 14:04 y 20:04
4 8 * * *
4 14 * * *
4 20 * * *
```
![alt text](https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Varios/tvheadend2.jpg)

#### 5> Forzar una descarga de la guía de programación:

En la misma pestaña anterior clicar ( Volver a ejecutar los capturadores de EPG internos )

![alt text](https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Varios/tvheadend3.jpg)

#### 6> Configurar el formato de la guía:

<i>[ Configuración ] - [ General ] - [ Base ]</i>

( EPG_Settings - Idioma(s) por defecto ), añadir el idioma y clicar ( Guardar )

Spanish: Guía con etiquetas de colores | [ejemplo](https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Varios/kodicolor.jpg)

English: Guía sin etiquetas de colores | [ejemplo](https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Varios/kodisincolor.jpg)

![alt text](https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Varios/tvheadend4.jpg)
