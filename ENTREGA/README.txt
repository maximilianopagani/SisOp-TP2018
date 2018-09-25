# SisOp-TP2018

Requisitos:

1. Sistema operativo basado en distribución Linux.

2. Conocimiento y manejo básico de shell script mediante una terminal.

3. Comandos pkill, pidof, mv, cut, sed, grep.

4. Usuario con permiso de escritura en el directorio de instalación elegido.


Guía de descompresión e instalación desde medio externo:

1. Conecte el dispositivo de almacenamiento externo al equipo.

2. Explore el dispositivo y encuentre el instalable con el nombre grupo02.tar.gz

3. Seleccione y archivo e indique la opción copiar. a) Click derecho y en el menú desplegado seleccione la opción copiar. b) Seleccionado el archivo presione CTRL + C.

4. Explore sus medios de instalación hasta encontrar el directorio donde quiere instalar el sistema.

5. Cree una carpeta con el nombre grupo02

6. Pegue el instalable dentro de esta carpeta creada.

7. Abra una terminal.

8. Posiciónese sobre el directorio creado: grupo02 Descomprima y desempaque el instalable ejecutando desde la terminal el siguiente comando: "$ tar -xzvf grupo02.tar.gz"

9. Para ejecutar el script de instalación debe contar con permisos de ejecución sobre el mismo. Para obtener permisos de ejecución, ingrese el siguiente comando: "$ chmod +x instalacion.sh"

10. Ejecute el script de instalación mediante el siguiente comando: "$ ./instalacion.sh"

11. El sistema solicitará que de algunos parámetros de configuración previo a la instalación. Dichos parámetros tienen un valor predeterminado, indicado por pantalla. En caso de que no desee modificar alguno, sólo presione la tecla Enter cuando el sistema le solicite definirlo: estas consultas son directorios a crear al momento de la instalación. Si no indica ningún directorio, por defecto se usarán los indicados por pantalla.

12. El sistema solicitará confirmación de la instalación. Ingrese la opción Si para continuar o la opción No para no instalar o cancelar para salir de la aplicación. Si elige la opción No, no se instalará y se le volverá a solicitar los nombres de los directorios. Si selecciona cancel no se instalar la aplicación y terminará su proceso.

13. Si desea volver a instalar el sistema copie el archivo grupo02.tar.gz al directorio grupo02 este archivo quedara guardado en el directorio “sourcefiles” del directorio grupo02 con el comando “$ mv sourcefiles/grupo02.tar.gz grupo02”, luego, repita los pasos a partir del paso 8.
El comando dispone de las siguientes opciones: sin opciones: "$ ./instalacion.sh" instala la aplicación. Con opciones: “$ ./instalacion –h” ayuda, “$ ./instalacion /r” reparación del sistema


Guía de ejecución del sistema:

1. Abra una terminal y navegue hasta el directorio de ejecutables que eligió durante la instalación. Ej: /home/usuario/programa/grupo02/bin. Haga de éste el directorio corriente del shell con $ cd “RUTA” (Ej: “$ cd /home/usuario/programa/grupo02/bin"). Alternativamente navegue con el explorador de archivos hasta la ubicación y haga clic derecho -> abrir terminal.

2. Una vez con nuestro shell en el directorio de ejecutables, para poder iniciar el sistema y comenzar a procesar archivos, antes que nada hay que inicializar el sistema. Esto se hace ejecutando el archivo init.sh ubicado en el directorio de ejecutables mediante el comando "$ . ./init.sh" Es importante el primer “.” y el espacio antes de "./init.sh", ya que esto hará que el script se ejecute en el mismo ambiente, sin crear un shell hijo, permitiendo compartir recursos entre cualquier comando del sistema lanzado en esa terminal. Siempre antes de ejecutar el proceso principal deberá haber inicializado el sistema antes, de lo contrario el sistema le impedirá ejecutarlo.

3. De resultar algún error durante la inicialización se le informará por pantalla, y deberá proceder a su criterio, siendo la opción mas recomendada reparar la instalación, y como último recurso reinstalar el paquete.

4. Al finalizar con éxito la inicialización, se ejecutará automáticamente el proceso que procesará los archivos de novedades cada cierto tiempo (1 minuto). El número de proccess_id le será informado en pantalla y se registrará en el log. NO CIERRE LA TERMINAL. Si lo hace cerrará todo el programa. Puede minimizarla o desconectarse, si estuviese remotamente. El proceso continuará corriendo indefinidamente hasta que sea detenido.

5. Para detener el proceso, sitúese en la misma terminal anterior en la cual estaba operando, y en el directorio corriente correspondiente al directorio de ejecutables. Aplique el comando "$ ./stop" para detener el proceso. Un mensaje en pantalla le indicará si tuvo éxito o no el comando.

6. En el caso de querer reanudar con el procesamiento, puede “encender” nuevamente proceso.sh mediante el uso del comando "$ ./start" (nuevamente, como en el punto 5, situado en la misma terminal y en el mismo directorio)

7. En el caso de querer apagar por completo el sistema, use como en los pasos anteriores el comando "$ ./stop" y luego cierre la terminal (si es que únicamente la usó para correr este sistema y no tiene corriendo otros procesos), lo que borrará todas las variables y recursos utilizados por el sistema.

8. Si más adelante desea ejecutar nuevamente el sistema, deberá proceder desde el paso 1 nuevamente.
              
