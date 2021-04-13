# <b>Instalación en enigma2 </B>

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

![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/blob/master/Varios/E2_I1.jpg)

- Elige la EPG dobleM que mas te guste y luego pulsa el boton Verde (Guardar)

![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/blob/master/Varios/E2_I2.jpg)

- Volveremos a la pantalla principal de EPG-Import, déjala como en la captura y si quieres forzar la primera decarga pulsa el boton Amarillo (Manual)

![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/blob/master/Varios/E2_I1.jpg)
#

# Modificación del skin para caracteres especiales y estrellas

1. Nos descargamos paquete de tipos de letra que admiten los caracteres especiales:

https://raw.githubusercontent.com/davidmuma/Canales_dobleM/blob/master/Varios/fonts.zip)

2. Descomprimimos el archivo y copiamos los ficheros en el directorio fonts de nuestra imagen

![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/blob/master/Varios/E2_S1.jpg)

3. Ahora editamos el archivo skin.xml de nuestro skin

![alt text](https://raw.githubusercontent.com/davidmuma/Canales_dobleM/blob/master/Varios/E2_S2.jpg)

4. Y en el mismo buscamos: (las rutas y los nombres son distintos en cada skin)

<font filename="/usr/share/fonts/OpenSans-Regular.ttf" name="Regular" scale="95"/>   

y sustituimos el nombre del tipo de letra por el que hayamos escogido:

<font filename="/usr/share/fonts/NanumGothic.ttf" name="Regular" scale="95"/> 

5. Guardamos cambios y reiniciamos el receptor






