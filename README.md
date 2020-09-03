# Tvheadend_Movistar-Spain
Script que instala en el Tvheadend todos los canales de Movistar+, los cuales vienen exactamente con el mismo orden que tienen oficialmente en el iPlus.
Todos los canales también están asignados a su correspondiente dial, renombrados a su nombre oficial en lugar de mantener el nombre con el que se emiten por satélite, y vienen con su correspondiente logo asignado (logos originales, transparentes y con una resolución bastante alta).

También cabe destacar que se incluye un grabber que descarga la EPG de todos los canales, esta EPG se descarga en cuestión de segundos sin necesidad de estar horas generándola con alguna herramienta externa y además incluye 30 días de programación.
Si se decide instalar dicho grabber, todos los canales de la lista también se mapearan con su correspondiente EPG.


Descarga del script: https://github.com/manuelrn/Tvheadend_Movistar-Spain/raw/master/Tvheadend_Movistar-Spain.sh

El script es compatible con los sistemas operativos:
  * Synology/XPEnology
  * LibreELEC/OpenELEC
  * Linux

## Parámetros del script
  * -b / -B: Realiza un backup de su configuración actual (lista de canales, logos y mapeo de la EPG de cada canal).
  * -g / -G: Instala el grabber y mapea todos los canales con su correspondiente EPG.
