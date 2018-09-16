#INICIALIZAR AMBIENTE DESDE $GRUPO/bin/initVars.sh  EL ARCHIVO DE CONFIGURACION /conf/tpconfig.txt

initVars() 
{	
	SCRIPTPATH="$( cd "$(dirname "$0")" ; cd .. ; pwd -P )" # A modificar cuando tengamos los scripts del principio
	
	INIT_SUCCESS=TRUE

	echo

	if [ "$TP_SISOP_INIT" = "YES" ] #Variable que vendría de más arriba
	then
		INIT_SUCCESS=FALSE
		echo "Error: sistema ya inicializado."
		echo
		return 0
	fi

	# Verifico existencia con permiso de lectura del archivo de configuración

	if [ ! -f "$SCRIPTPATH/conf/tpconfig.txt" ] 
	then
		INIT_SUCCESS=FALSE
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
				echo "Error: el archivo de configuracion tpconfig.txt no tiene permiso de lectura."
				echo
				return 0
			fi
		fi	
	fi

	echo "Inicializando sistema..."
	echo
	
	IFS_BACKUP=$IFS 
	IFS="="

	while read VARIABLE DIRECCION

	do	
		if [ ! -d "$DIRECCION" ]		
		then
			INIT_SUCCESS=FALSE
			echo "Error al cargar $VARIABLE. El directorio no existe ($DIRECCION)"
 
		else
			export $VARIABLE=$DIRECCION
			echo "Cargando: $VARIABLE - RUTA: $DIRECCION"
		fi

	done <$SCRIPTPATH/conf/tpconfig.txt
	
	echo
	
	IFS=$IFS_BACKUP

	# Verifico existencia con permiso de lectura de los archivos maestros

	if [ ! -f "$MAESTROSDIR/sucursales.txt" ]
	then
		INIT_SUCCESS=FALSE
		echo "Error: no existe el archivo de maestros sucursales.txt."
		echo
	else
		if [ ! -r "$MAESTROSDIR/sucursales.txt" ]		
		then
			chmod +r "$MAESTROSDIR/sucursales.txt"
			
			if [ ! -r "$MAESTROSDIR/sucursales.txt" ]		
			then
				INIT_SUCCESS=FALSE
				echo "Error: el archivo de maestros sucursales.txt no tiene permiso de lectura."
				echo
			fi
		fi	
	fi

	if [ ! -f "$MAESTROSDIR/operadores.txt" ]
	then
		INIT_SUCCESS=FALSE
		echo "Error: no existe el archivo de maestros operadores.txt."
		echo
	else
		if [ ! -r "$MAESTROSDIR/operadores.txt" ]	
		then
			chmod +r "$MAESTROSDIR/operadores.txt"
			
			if [ ! -r "$MAESTROSDIR/operadores.txt" ]		
			then
				INIT_SUCCESS=FALSE
				echo "Error: el archivo de maestros operadores.txt no tiene permiso de lectura."
				echo
			fi
		fi	
	fi

	# VERIFICAR QUE TODOS LOS EJECUTABLES DE /BIN TENGAN PERMISO DE EJECUCION
	#########################################################################

	if [ "$INIT_SUCCESS" = "TRUE" ]
	then	
		export TP_SISOP_INIT=YES
		echo "Sistema inicializado con éxito."
	else
		echo "Error al inicializar el sistema."
	fi

	echo

	return 1;
}

initVars
