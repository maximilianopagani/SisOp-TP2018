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

fileExists=""
checkIfFileExists()
{
	FILE=$1
	if [ -f "$FILE" ]
	then
		fileExists="YES"
	else
		fileExists="NO"
	fi
}

fileExecutable=""
checkIfFileIsExecutable()
{
	FILE=$1
	if [[ -x "$FILE" ]]
	then
		fileExecutable="YES"
	else
		fileExecutable="NO"
	fi
}

init() 
{	
	SCRIPTPATH="$( cd "$(dirname "$0")" ; cd .. ; pwd -P )" # A modificar cuando tengamos los scripts del principio
	
	INIT_SUCCESS=TRUE
	VARCOUNT=0
	FAILURE_REASON=""

	if [ "$TP_SISOP_INIT" == "YES" ] #Variable que vendría de más arriba
	then
		INIT_SUCCESS=FALSE
		FAILURE_REASON="Error: sistema ya inicializado."
		echo "Error: sistema ya inicializado."
		return 0
	fi

	# Verifico existencia con permiso de lectura del archivo de configuración

	if [ ! -f "$SCRIPTPATH/conf/tpconfig.txt" ] 
	then
		INIT_SUCCESS=FALSE
		FAILURE_REASON="Error: no existe el archivo de configuracion tpconfig.txt."
		echo "Error: no existe el archivo de configuracion tpconfig.txt."
		echo
		return 0
	else
		if [ ! -r "$SCRIPTPATH/conf/tpconfig.txt" ]		
		then
			chmod +r "$SCRIPTPATH/conf/tpconfig.txt"
			
			if [ ! -r "$SCRIPTPATH/conf/tpconfig.txt" ]
			then
				INIT_SUCCESS=FALSE
				FAILURE_REASON="Error: el archivo de configuracion tpconfig.txt no tiene permiso de lectura."
				echo "Error: el archivo de configuracion tpconfig.txt no tiene permiso de lectura."
				echo
				return 0
			fi
		fi	
	fi

	echo "Inicializando sistema..."

	while read REGISTRO
	do	
		VARIABLE=$(cut -d'-' -f1 <<<$REGISTRO)
		VALOR=$(cut -d'-' -f2 <<<$REGISTRO)

		#ARCHIVOLOG="${GRUPODIR}/conf/log/instalacion.log"
		#ARCHIVOCONF="${CONFDIR}/tpconfig.txt"

		if [ ! -d "$VALOR" ]	
		then
			INIT_SUCCESS=FALSE
			FAILURE_REASON="Error al cargar $VARIABLE. El directorio no existe ($VALOR)"
			echo "Error al cargar $VARIABLE. El directorio no existe ($VALOR)"
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
			esac

			echo "Cargando: $VARIABLE - Valor: $VALOR"
		fi	

	done <"$SCRIPTPATH/conf/tpconfig.txt"

	if [ "$VARCOUNT" != "10" ]
	then
		INIT_SUCCESS=FALSE
		FAILURE_REASON="Error: el archivo de configuracion está incompleto o mal configurado"
	fi

	# Verifico existencia con permiso de lectura de los archivos maestros

	if [ ! -f "$MAESTROSDIR/Sucursales.txt" ]
	then
		INIT_SUCCESS=FALSE
		FAILURE_REASON="Error: no existe el archivo de maestros Sucursales.txt."
		echo "Error: no existe el archivo de maestros Sucursales.txt."
	else
		if [ ! -r "$MAESTROSDIR/Sucursales.txt" ]		
		then
			chmod +r "$MAESTROSDIR/Sucursales.txt"
			
			if [ ! -r "$MAESTROSDIR/Sucursales.txt" ]		
			then
				INIT_SUCCESS=FALSE
				FAILURE_REASON="Error: el archivo de maestros Sucursales.txt no tiene permiso de lectura y no fué posible modificarlo"
				echo "Error: el archivo de maestros Sucursales.txt no tiene permiso de lectura y no fué posible modificarlo"
			fi
		fi	
	fi

	if [ ! -f "$MAESTROSDIR/Operadores.txt" ]
	then
		INIT_SUCCESS=FALSE
		FAILURE_REASON="Error: no existe el archivo de maestros Operadores.txt"
		echo "Error: no existe el archivo de maestros Operadores.txt"
	else
		if [ ! -r "$MAESTROSDIR/Operadores.txt" ]	
		then
			chmod +r "$MAESTROSDIR/Operadores.txt"
			
			if [ ! -r "$MAESTROSDIR/Operadores.txt" ]		
			then
				INIT_SUCCESS=FALSE
				FAILURE_REASON="Error: el archivo de maestros Operadores.txt no tiene permiso de lectura y no fué posible modificarlo"
				echo "Error: el archivo de maestros Operadores.txt no tiene permiso de lectura y no fué posible modificarlo"
			fi
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
	checkIfFileExists "$BINDIR/procesoSisOp.sh"
	checkIfFileExists "$BINDIR/instalacion.sh"
	if [ "$fileExists" == "NO" ]
	then
		INIT_SUCCESS=FALSE
		FAILURE_REASON="No se pueden encontrar uno o más ejecutables de $DIRBIN"
	else
		chmod +x "$BINDIR/mover"
		chmod +x "$BINDIR/glog"
		chmod +x "$BINDIR/start"
		chmod +x "$BINDIR/stop"
		chmod +x "$BINDIR/procesoSisOp.sh"
		chmod +x "$BINDIR/instalacion.sh"

		fileExecutable="YES"
		checkIfFileIsExecutable "$BINDIR/mover"
		checkIfFileIsExecutable "$BINDIR/glog"
		checkIfFileIsExecutable "$BINDIR/start"
		checkIfFileIsExecutable "$BINDIR/stop"
		checkIfFileIsExecutable "$BINDIR/procesoSisOp.sh"
		checkIfFileIsExecutable "$BINDIR/instalacion.sh"
		if [ "$fileExecutable" == "NO" ]
		then
			INIT_SUCCESS=FALSE
			FAILURE_REASON="Uno o más ejecutables de $DIRBIN no tienen permiso de ejecución y no es posible modificarlo"
		fi
	fi

	###########################################################################

	if [ "$INIT_SUCCESS" = "TRUE" ]
	then	
		TP_SISOP_INIT=YES

		export TP_SISOP_INIT
		export GRUPODIR
		export CONFDIR
		export LOGDIR
		export LOGSIZE
		export BINDIR
		export MAESTROSDIR
		export ARRIBOSDIR
		export ACEPTADOSDIR
		export RECHAZADOSDIR
		export PROCESADOSDIR
		export SALIDADIR

		echo "Sistema inicializado con éxito. Se procede con la invocación del comando start para iniciar el proceso en segundo plano"
		"$BINDIR"./start
		
		return 1
	else

		unset TP_SISOP_INIT
		unset GRUPODIR
		unset CONFDIR
		unset LOGDIR
		unset LOGSIZE
		unset BINDIR
		unset MAESTROSDIR
		unset ARRIBOSDIR
		unset ACEPTADOSDIR
		unset RECHAZADOSDIR
		unset PROCESADOSDIR
		unset SALIDADIR

		echo "Error al inicializar el sistema. Motivo: $FAILURE_REASON"
		return 0
	fi
}

chmod +x ./glog

init
