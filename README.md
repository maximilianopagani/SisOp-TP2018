# SisOp-TP2018
Guía de instalacion desde medio externo:
1. Conecte el dispositivo de almacenamiento externo al equipo.
2. Explore el dispositivo y encuentre el instalable con el nombre grupo02.tar.gz
3. Seleccione y archivo e indique la opcion copiar.
    a) Click derecho y en el menu desplegado seleccione la opcion copiar.
    b) Seleccionado el archivo presione CTRL + C.
4. Explore sus medios de instalación hasta encontrar el directorio donde quiere instalar el sistema.
5. Cree una carpeta con el nombre grupo02
6. Pegue el instalable dentro de esta carpeta creada.
7. Abra una terminal.
8. Posiciónese sobre el directorio creado: grupo02
   Descomprima y desempaque el instalable ejecutando desde la terminal el siguiente comando:
             tar -xzvf grupo02.tar.gz
9. Para ejecutar el script de instalación debe contar con permisos de ejecución sobre el mismo. Para
   obtener permisos de ejecución, ingrese el siguiente comando:
             chmod +x instalacion.sh
10. Ejecute el script de instalación mediante el siguiente comando:
             $./instalacion.sh
 11. El sistema solicitará que de algunos parámetros de configuración previo a la instalación. Dichos
     parámetros tienen un valor predeterminado, indicado por pantalla. En caso de que no desee modificar
     alguno, sólo presione la tecla Enter cuando el sistema le solicite definirlo:
     estas consultas son directoiros a crear al momento de la instalacion.
     Si no indica ningun directorio, por defecto se usarán los indicados por pantalla.
12. El sistema solicitará confirmación de la instalación. Ingrese la opción Si para continuar o la opción
    No para no instalar o cancelar para salir de la aplicacion.
    Si elige la opción No, no se instalra y se le volvera a solicitar los nombres de los directorios
    Si selecciona cancel no se instalar la aplicacion y termniara su proceso
13. si desea volver a instlaar el sistema copie el archvio grupo02.tar.gz al directorio grupo02
    este archivo quedara guardado en el directorio sourcefiles de ldirectoiro grupo02
              $ mv sourcefiles/grupo02.tar.gz grupo02
    luego, repita los pasos a partir del paso 8

El comando dispones de las siguientes opciones:
sin opciones:$./instalacion.sh instala l aaplcacion
con opciones:$./instalacion -h ayuda
              $./instalacion /r reparacion del sistema
              
              
