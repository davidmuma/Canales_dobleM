# <b>Instalación en enigma2 </B> - [Capturas](https://github.com/davidmuma/EPG_dobleM/blob/master/Varios/capturasE.md)

- El script se encarga de instalar los sources dobleM para EPG-Import

Ejecuta el script con el siguiente comando:
```
curl -sO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/dobleM.sh ; sh dobleM.sh
```
Si te falla el primero prueba con este otro comando:
```
wget -O dobleM.sh https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/dobleM.sh ; sh dobleM.sh
```

- Una vez instalado, ves al plugin EPG-Import y pulsa el boton Azul (Fuentes)

![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/E2_I1.jpg)

- Elige la EPG dobleM que mas te guste y luego pulsa el boton Verde (Guardar)

![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/E2_I2.jpg)

- Volveremos a la pantalla principal de EPG-Import, si quieres forzar la primera decarga pulsa el boton Amarillo (Manual)

Déjala como en la captura y luego pulsa el boton Verde (Guardar)

![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/E2_I1.jpg)
#

# Modificación del skin para caracteres especiales y estrellas

- Nos descargamos el paquete de tipos de letra que admiten los caracteres especiales:

[fonts.zip](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/fonts.zip)

- Descomprimimos el archivo y copiamos los ficheros en el directorio fonts de nuestro receptor

(las rutas y los nombres pueden cambiar)

![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/E2_S1.jpg)

- Ahora vamos al directorio de nuestro skin y editamos el archivo skin.xml

(las rutas y los nombres pueden cambiar en cada skin)

![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Varios/E2_S2.jpg)

- En el mismo buscamos:

(las rutas y los nombres pueden cambiar en cada skin)

<font filename="/usr/share/fonts/OpenSans-Regular.ttf" name="Regular" scale="95"/>   

y sustituimos el nombre del tipo de letra por el nombre de uno de los archivos que hemos descargado en el paquete fonts.zip:

<font filename="/usr/share/fonts/NanumGothic.ttf" name="Regular" scale="95"/> 

Los tipos de letra disponibles son:
- NanumGothic.ttf
- RocknRollOne.ttf
- Rounded.ttf
- SawarabiGothic.ttf
- Titre.ttf

- Guardamos cambios y reiniciamos el receptor
