## <b>Instalar guía en Synology </B>
#### 1> Descargar el archivo <i>"tv_grab_EPG_dobleM"</i> en en la siguiente ruta:
<i>Con imágenes tipo poster</i> 
```
sudo wget -P /usr/local/bin/ https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/P/tv_grab_EPG_dobleM
```
<i>Con imágenes tipo fanart</i>
```
sudo wget -P /usr/local/bin/ https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/F/tv_grab_EPG_dobleM
```
#### 2> Dar permisos de ejecución al grabber:
```
sudo chmod 755 /usr/local/bin/tv_grab_EPG_dobleM
```
### <b>Configuración de tvheadend </B>
#### 3> Reiniciar tvheadend y habilitar el grabber:
<i>Configuración - Canal/EPG - Módulos para Obtención de Guía - Interno: XMLTV: tv_grab_EPG_dobleM</i>
![alt text](https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Images/Tvheadend1.jpg)
#### 4> Programar la descarga de la guía:
<i>Configuración - Canal/EPG - Obtener Guía - Internal Grabber Settings - Cronología multi-línea</i>
![alt text](https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Images/Tvheadend2.jpg)
```
# Todos los días a las 8:04, 14:04 y 20:04
4 8 * * *
4 14 * * *
4 20 * * *
```
#### 5> Forzar una descarga de la guía de programación:
<i>Pulsar el botón "Volver a ejecutar los capturadores de EPG internos"</i>

#### 6> Configurar el formato de la guía:
<i>Configuración - General - EPG_Settings - Idioma(s) por defecto</i>
![alt text](https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Images/Tvheadend4.jpg)
```
Spanish - Guía con etiquetas de colores
English- Guía sin etiquetas de colores
```