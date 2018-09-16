#INICIALIZAR AMBIENTE DESDE $GRUPO/bin/initVars.sh  EL ARCHIVO DE CONFIGURACION /conf/tpconfig.txt

initVars() 
{	
	SCRIPTPATH="$( cd "$(dirname "$0")" ; cd .. ; pwd -P )" # A modificar cuando tengamos los scripts del principio

	echo

	if [ "$TP_SISOP_INIT" = "YES" ] #Variable que vendría de más arriba

	then
		echo "Error: sistema ya inicializado."
		echo
		return 0
	fi

	if [ ! -f "$SCRIPTPATH/conf/tpconfig.txt" ] 

	then
		echo "Error: no existe el archivo de configuracion tpconfig.txt."
		echo
		return 0
	else
		if [ ! -r "$SCRIPTPATH/conf/tpconfig.txt" ]
		
		then
			chmod +r "$SCRIPTPATH/conf/tpconfig.txt"
			
			if [ ! -r "$SCRIPTPATH/conf/tpconfig.txt" ]
		
			then
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
		export $VARIABLE=$DIRECCION
		echo "Cargando: $VARIABLE - RUTA: $DIRECCION"

	done <$SCRIPTPATH/conf/tpconfig.txt

	IFS=$IFS_BACKUP
	
	export TP_SISOP_INIT=YES

	echo
	echo "Sistema inicializado."
	echo

	return 1;
}

initVars
