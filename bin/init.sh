#INICIALIZAR AMBIENTE DESDE $GRUPODIR/bin/init.sh  - EL ARCHIVO DE CONFIGURACION $GRUPODIR/conf/tpconfig.txt

GRUPODIR=""
CONFDIR=""
LOGDIR=""
BINDIR=""
MAESTROSDIR=""
ARRIBOSDIR=""
ACEPTADOSDIR=""
RECHAZADOSDIR=""
PROCESADOSDIR=""
SALIDADIR=""

fileExists="YES"
checkIfFileExists()
{
	FILE=$1
	if [ ! -f "$FILE" ]
	then
		fileExists="NO"
	fi
}

fileExecutable="YES"
checkIfFileIsExecutable()
{
	FILE=$1
	if [ ! -x "$FILE" ]
	then
		fileExecutable="NO"
	fi
}

fileReadable="YES"
checkIfFileIsReadable()
{
	FILE=$1
	if [ ! -r "$FILE" ]
	then
		fileReadable="NO"
	fi
}

unsetVars()
{
	unset TP_SISOP_INIT
	unset GRUPODIR
	unset CONFDIR
	unset LOGDIR
	unset BINDIR
	unset MAESTROSDIR
	unset ARRIBOSDIR
	unset ACEPTADOSDIR
	unset RECHAZADOSDIR
	unset PROCESADOSDIR
	unset SALIDADIR
}

inicializacionAbortadaMsj()
{
	echo "====================== INICIALIZACION CANCELADA ======================"
	./glog "init" "====================== INICIALIZACION CANCELADA ======================"
}

init() 
{	
	SCRIPTPATH="$( cd "$(dirname "$0")" ; cd .. ; pwd -P )" # A modificar cuando tengamos los scripts del principio
	LOGDIR="$SCRIPTPATH/conf/log"
	export LOGDIR
	chmod +x ./glog

	echo "====================== INICIALIZANDO SISTEMA ======================"
	./glog "init" "====================== INICIALIZANDO SISTEMA ======================"

	if [ "$TP_SISOP_INIT" == "YES" ] #Variable que vendría de más arriba
	then
		echo "Verificando que el sistema no se encuentre ya inicializado... ERROR"
		./glog "init" "Verificando que el sistema no se encuentre ya inicializado... ERROR" "ERROR"
		inicializacionAbortadaMsj
		return 0
	else
		echo "Verificando que el sistema no se encuentre ya inicializado... OK"
		./glog "init" "Verificando que el sistema no se encuentre ya inicializado... OK"
	fi

	###########################################################################
	#      VERIFICAR QUE EXISTA TPCONFIG.TXT Y TENGA PERMISO DE LECTURA       #
	###########################################################################

	fileExists="YES"
	checkIfFileExists "$SCRIPTPATH/conf/tpconfig.txt"
	if [ "$fileExists" == "NO" ]
	then
		echo "Verificando existencia del archivo de configuración en $SCRIPTPATH/conf... ERROR"
		./glog "init" "Verificando existencia del archivo de configuracion en $SCRIPTPATH/conf... ERROR" "ERROR"
		inicializacionAbortadaMsj
		return 0
	else
		echo "Verificando existencia del archivo de configuración en $SCRIPTPATH/conf... OK"
		./glog "init" "Verificando existencia del archivo de configuracion en $SCRIPTPATH/conf... OK"

		echo "Seteando permiso de lectura al archivo de configuración... OK"
		./glog "init" "Seteando permiso de lectura al archivo de configuración... OK"

		chmod +r "$SCRIPTPATH/conf/tpconfig.txt"

		fileReadable="YES"
		checkIfFileIsReadable "$SCRIPTPATH/conf/tpconfig.txt"
		if [ "$fileReadable" == "NO" ]
		then
			echo "Verificando que el archivo de configuración tenga permisos de lectura... ERROR"
			./glog "init" "Verificando que el archivo de configuración tenga permisos de lectura... ERROR" "ERROR"
			inicializacionAbortadaMsj
			return 0
		else
			echo "Verificando que el archivo de configuración tenga permisos de lectura... OK"
			./glog "init" "Verificando que el archivo de configuración tenga permisos de lectura... OK"
		fi
	fi

	###########################################################################
	#               LEO VARIABLES DEL ARCHIVO DE CONFIGURACION                #
	###########################################################################
	
	VARCOUNT=0

	while read REGISTRO
	do	
		VARIABLE=$(cut -d'-' -f1 <<<$REGISTRO)
		VALOR=$(cut -d'-' -f2 <<<$REGISTRO)

		NOMBRECORRECTO="SI"

		#ARCHIVOLOG="${GRUPODIR}/conf/log/instalacion.log"
		#ARCHIVOCONF="${CONFDIR}/tpconfig.txt"

		if [ ! -d "$VALOR" ]	
		then
			echo "Cargando variable $VARIABLE y ruta $VALOR... ERROR - RUTA INEXISTENTE"
			./glog "init" "Cargando variable $VARIABLE y ruta $VALOR... ERROR - RUTA INEXISTENTE" "ERROR"
			ALLDIREXISTS="NO"
 		else
			case $VARIABLE in
				"GRUPODIR")
				GRUPODIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;
				"CONFDIR")
				CONFDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;
				"LOGDIR")
				LOGDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"BINDIR")
				BINDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"MAESTROSDIR")
				MAESTROSDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"ARRIBOSDIR")
				ARRIBOSDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"ACEPTADOSDIR")
				ACEPTADOSDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"RECHAZADOSDIR")
				RECHAZADOSDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"PROCESADOSDIR")
				PROCESADOSDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"SALIDADIR")
				SALIDADIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;
				*)
				NOMBRECORRECTO="NO"
				;;		
			esac
			
			if [ "$NOMBRECORRECTO" == "NO" ]
			then
				echo "Cargando variable $VARIABLE y ruta $VALOR... ERROR - NOMBRE INCORRECTO"
				./glog "init" "Cargando variable $VARIABLE y ruta $VALOR... ERROR - NOMBRE INCORRECTO" "ERROR"
			else
				echo "Cargando variable $VARIABLE y ruta $VALOR... OK"
				./glog "init" "Cargando variable $VARIABLE y ruta $VALOR... OK"
			fi
		fi	

	done <"$SCRIPTPATH/conf/tpconfig.txt"

	###########################################################################
	#      VERIFICAR LA EXISTENCIA DE TODOS LAS RUTAS DE LAS VARIABLES        #
	###########################################################################

	if [ "$ALLDIREXISTS" == "NO" ]
	then
		echo "Se han encontrado una o más rutas inexistentes para los directorios... ERROR"
		./glog "init" "Se han encontrado una o más rutas inexistentes para los directorios... ERROR" "ERROR"
		inicializacionAbortadaMsj
		unsetVars
		return 0
	fi

	###########################################################################
	#     VERIFICAR LA CANTIDAD DE VARIABLES DE NOMBRES ESPERADOS LEIDAS      #
	###########################################################################

	if [ "$VARCOUNT" != "10" ]
	then
		echo "Verificando cantidad esperada (10) y nombres de variables esperadas... ERROR"
		./glog "init" "Verificando cantidad esperada (10) y nombres de variables esperadas... ERROR" "ERROR"
		inicializacionAbortadaMsj
		unsetVars
		return 0
	else
		echo "Verificando cantidad esperada (10) y nombres de variables esperadas... OK"
		./glog "init" "Verificando cantidad esperada (10) y nombres de variables esperadas... OK"
	fi

	###########################################################################
	#       VERIFICAR EXISTAN LOS MAESTROS Y TENGAN PERMISO DE LECTURA        #
	###########################################################################

	fileExists="YES"
	checkIfFileExists "$MAESTROSDIR/Sucursales.txt"
	checkIfFileExists "$MAESTROSDIR/Operadores.txt"
	if [ "$fileExists" == "NO" ]
	then
		echo "Verificando existencia de los archivos maestros en $MAESTROSDIR... ERROR"
		./glog "init" "Verificando existencia de los archivos maestros en $MAESTROSDIR... ERROR" "ERROR"
		inicializacionAbortadaMsj
		unsetVars
		return 0
	else
		echo "Verificando existencia de los archivos maestros en $MAESTROSDIR... OK"
		./glog "init" "Verificando existencia de los archivos maestros en $MAESTROSDIR... OK"

		echo "Seteando permisos de lectura a los archivos maestros... OK"
		./glog "init" "Seteando permisos de lectura a los archivos maestros... OK"

		chmod +r "$MAESTROSDIR/Operadores.txt"
		chmod +r "$MAESTROSDIR/Sucursales.txt"

		fileReadable="YES"
		checkIfFileIsReadable "$MAESTROSDIR/Operadores.txt"
		checkIfFileIsReadable "$MAESTROSDIR/Sucursales.txt"
		if [ "$fileReadable" == "NO" ]
		then
			echo "Verificando que los archivos maestros tengan permiso de lectura... ERROR"
			./glog "init" "Verificando que los archivos maestros tengan permiso de lectura... ERROR" "ERROR"
			inicializacionAbortadaMsj
			unsetVars
			return 0
		else
			echo "Verificando que los archivos maestros tengan permiso de lectura... OK"
			./glog "init" "Verificando que los archivos maestros tengan permiso de lectura... OK"
		fi
	fi

	###########################################################################
	# VERIFICAR EXISTAN LOS EJECUTABLES DE /BIN Y TENGAN PERMISO DE EJECUCION #
	###########################################################################

	fileExists="YES"
	checkIfFileExists "$BINDIR/mover"
	checkIfFileExists "$BINDIR/glog"
	checkIfFileExists "$BINDIR/start"
	checkIfFileExists "$BINDIR/stop"
	checkIfFileExists "$BINDIR/proceso.sh"
	checkIfFileExists "$BINDIR/instalacion.sh"
	if [ "$fileExists" == "NO" ]
	then
		echo "Verificando existencia de los archivos ejecutables en $BINDIR... ERROR"
		./glog "init" "Verificando existencia de los archivos ejecutables en $BINDIR... ERROR" "ERROR"
		inicializacionAbortadaMsj
		unsetVars
		return 0
	else
		echo "Verificando existencia de los archivos ejecutables en $BINDIR... OK"
		./glog "init" "Verificando existencia de los archivos ejecutables en $BINDIR... OK"

		echo "Seteando permisos de ejecución a los archivos ejecutables... OK"
		./glog "init" "Seteando permisos de ejecución a los archivos ejecutables... OK"

		chmod +x "$BINDIR/mover"
		chmod +x "$BINDIR/glog"
		chmod +x "$BINDIR/start"
		chmod +x "$BINDIR/stop"
		chmod +x "$BINDIR/proceso.sh"
		chmod +x "$BINDIR/instalacion.sh"

		fileExecutable="YES"
		checkIfFileIsExecutable "$BINDIR/mover"
		checkIfFileIsExecutable "$BINDIR/glog"
		checkIfFileIsExecutable "$BINDIR/start"
		checkIfFileIsExecutable "$BINDIR/stop"
		checkIfFileIsExecutable "$BINDIR/proceso.sh"
		checkIfFileIsExecutable "$BINDIR/instalacion.sh"
		if [ "$fileExecutable" == "NO" ]
		then
			echo "Verificando que los archivos ejecutables tengan permiso de ejecución... ERROR"
			./glog "init" "Verificando que los archivos ejecutables tengan permiso de ejecución... ERROR" "ERROR"
			inicializacionAbortadaMsj
			unsetVars
			return 0
		else
			echo "Verificando que los archivos ejecutables tengan permiso de ejecución... OK"
			./glog "init" "Verificando que los archivos ejecutables tengan permiso de ejecución... OK"		
		fi
	fi

	###########################################################################
	#         VERIFICACIONES CORRECTAS - TERMINAR LA INICIALIZACION           #
	###########################################################################

	TP_SISOP_INIT=YES

	export TP_SISOP_INIT
	export GRUPODIR
	export CONFDIR
	export LOGDIR
	export BINDIR
	export MAESTROSDIR
	export ARRIBOSDIR
	export ACEPTADOSDIR
	export RECHAZADOSDIR
	export PROCESADOSDIR
	export SALIDADIR

	echo "Sistema inicializado con éxito. Se procede con la invocación del comando start para iniciar el proceso en segundo plano"
	./glog "init" "Sistema inicializado con éxito. Se procede con la invocación del comando start para iniciar el proceso en segundo plano"		
	echo "====================== INICIALIZACION COMPLETADA CON EXITO ======================"
	./glog "init" "====================== INICIALIZACION COMPLETADA CON EXITO ======================"
	"$BINDIR"/start
}

init
