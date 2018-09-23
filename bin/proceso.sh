#!/bin/bash
#Glog - Script log errores

#	Funciones - Modo de uso:
#	(debe poder leerse MAESTROSDIR)
#
#	verificarExistenciaOperador "CODIGO_OPERADOR"
#	ejemplo: verificarExistenciaOperador "OCA"
#	devuelve 1 si la verificacion fue con éxito, 0 en caso contrario
#
#	verificarVigenciaContrato "CODIGO_OPERADOR" "MES_ARRIBO"
# 	ejemplo: verificarVigenciaContrato "OCA" "02"
#	devuelve 1 si la verificacion fue con éxito, 0 en caso contrario
#
#	verificarCPSucursalOperador "CODIGO_OPERADOR" "CODIGO_POSTAL"
#	verificarCpSucursalOperador "OCA" "1214"
#	devuelve 1 si la verificacion fue con éxito, 0 en caso contrario

verificarExistenciaOperador()
{
	OPERADORABUSCAR="$1"

	LINEFOUND=$(grep "^$OPERADORABUSCAR;" "$MAESTROSDIR/Operadores.txt")

	if [ "$LINEFOUND" != "" ]
	then
		echo "Verificando existencia de operador $OPERADORABUSCAR en maestro de operadores... OK"
		#glog
		return 1
	fi		

	echo "Verificando existencia de operador $OPERADORABUSCAR en maestro de operadores... ERROR, NO EXISTE"
	#glog
	return 0	
}

verificarVigenciaContrato()
{
	OPERADORABUSCAR="$1"
	MESDEARRIBO="$2"

	FECHAARRIBO=$MESDEARRIBO/$(date +%d)/$(date +%Y)
	FECHAFIN=$(grep "^${OPERADORABUSCAR}" "$MAESTROSDIR/Operadores.txt" | sed 's|.*;\([^/]*\)/\([^/]*\)/\([^/]*\)$|\2/\1/\3|')

	SEGUNDOSARRIBO=$(date -d $FECHAARRIBO +%s)
	SEGUNDOSFIN=$(date -d $FECHAFIN +%s)

	if [ ${SEGUNDOSARRIBO} -ge ${SEGUNDOSFIN} ]
	then
		echo "Verificando la vigencia del contrato del operador $OPERADORABUSCAR al mes $MESDEARRIBO... ERROR, CONTRATO VENCIDO"
		#glog
		return 0
	else
		echo "Verificando la vigencia del contrato del operador $OPERADORABUSCAR al mes $MESDEARRIBO... OK"
		#glog
		return 1
	fi	
}

verificarCPSucursalOperador()
{
	OPERADORABUSCAR="$1"
	CPABUSCAR="$2"

	LINEFOUND=$(grep ".*;${CPABUSCAR};${OPERADORABUSCAR};[^;]*$" "$MAESTROSDIR/Sucursales.txt")

	if [ "$LINEFOUND" != "" ]
	then
		echo "Verificando existencia de alguna sucursal del operador $OPERADORABUSCAR con código postal $CPABUSCAR... OK"
		#glog
		return 1
	else
		echo "Verificando existencia de alguna sucursal del operador $OPERADORABUSCAR con código postal $CPABUSCAR... ERROR, NO EXISTE NINGUNA"
		#glog
		return 0
	fi		
}

verificarTrailer()
{
	file=$1
	CONTADOR=0
	SUM_COD_POSTAL=0

	IFS_BACKUP=$IFS 
	IFS=$'\n'

	for registro in $( cat $file )
	do
		COD_POSTAL=`echo $registro | cut -d ";" -f6`
		OPERADOR=`echo $registro | cut -d ";" -f1`

		if [ "$OPERADOR" != "" ] #Si no estoy en la ultima linea
		then
			CONTADOR=$((CONTADOR+1))
			SUM_COD_POSTAL=$((SUM_COD_POSTAL+COD_POSTAL))	
		else
			TRAILER=`echo $registro | cut -d ";" -f6`
			Q_REGISTROS=`echo $registro | cut -d ";" -f5`
		fi
	done

	IFS=$IFS_BACKUP

	if [ "$SUM_COD_POSTAL" != "$TRAILER" ] || [ "$CONTADOR" != "$Q_REGISTROS" ]
	then
		echo "Verificando cantidad de registros y suma de códigos postales con con el trailer... ERROR, NO COINCIDE"
		#glog
		return 0
	else
		echo "Verificando cantidad de registros y suma de códigos postales con con el trailer... OK"
		#glog
		return 1
	fi
}

verificarMesArchivo()
{
	MES_ARRIBO="$1"
	MES_ACTUAL=$(date +%m)
	
	diferencia=`expr ${MES_ACTUAL} - ${MES_ARRIBO}`
	
	if [ $diferencia -ge 0 ]
	then
		echo "Verificando mes del arribo ($MES_ARRIBO) respecto al mes actual ($MES_ACTUAL)... OK"
		return 1
	else	
		echo "Verificando mes del arribo ($MES_ARRIBO) respecto al mes actual ($MES_ACTUAL)... ERROR"
		return 0
	fi
}

verificarNombreArchivo()
{
	file_name="$1"
	M="F"

	name=$(echo $file_name | cut -d '.' -f1)
	nombre=$(echo $name | cut -d '_' -f1)
	mes=$(echo $name | cut -d '_' -f2)
	
	case $mes in
	01)
	M="V"
	;;
	02)
	M="V"
	;;
	03)
	M="V"
	;;	
	04)
	M="V"
	;;	
	05)
	M="V"
	;;	
	06)
	M="V"
	;;	
	07)
	M="V"
	;;	
	08)
	M="V"
	;;	
	09)
	M="V"
	;;	
	10)
	M="V"
	;;	
	11)
	M="V"
	;;	
	12)
	M="V"
	;;
	*)
	M="F"
	;;	
	esac

	if [ ${#file_name} == 15 ] && [ "${M}" == "V" ] && [ "${nombre}" == "Entregas" ]
	then
		echo "Verificando si el nombre del archivo $file_name cumple con el formato estandar (Entregas_XX)... OK"
		#glog
		return 1
	else
		echo "Verificando si el nombre del archivo $file_name cumple con el formato estandar (Entregas_XX)... ERROR"
		#glog
		return 0		
	fi
}

verificarSiNoFueProcesado()
{
	file_name="$1"
	
	if [ -e "$PROCESADOSDIR/$file_name" ]
	then
		echo "Verificando si el archivo $file_name no fué procesado anteriormente... ERROR"
		#glog
		return 0
	else
		echo "Verificando si el archivo $file_name no fué procesado anteriormente... OK"
		#glog
		return 1
	fi
}

#autocompletarString "STRING" "CARACTER" "IZQ/DER" "CANTIDAD TOTAL A ALCANZAR"
# EJ, completar con espacios a izquierda hasta los 50 caracteres: autocompletarString "mi_string" " " "IZQ" "50"

STRINGRESULT=""

autocompletarString()
{
	STRING="$1"
	CARACTER="$2"
	SENTIDO="$3"
	TOTAL="$4"

	while [ ${#STRING} != $TOTAL ]
	do
		if [ "$SENTIDO" == "IZQ" ]
		then
			STRING="$CARACTER$STRING"
		else
			if [ "$SENTIDO" == "DER" ]
			then
				STRING="$STRING$CARACTER"
			fi
		fi
	done

	STRINGRESULT=$STRING
}


######################################################################################################
#                                        PROCESO                                                     #
######################################################################################################

main()
{
	if [ "$TP_SISOP_INIT" != "YES" ] #Variable que vendría de más arriba
	then
		echo "Error: el sistema no se ha inicializado y no se podrá correr el proceso."
		#glog
		return 0
	fi

	TP_SISOP_CICLO=0

	while true
	do
		TP_SISOP_CICLO=$((TP_SISOP_CICLO+1))
		
		echo "====================================================="
		echo "Iniciado ciclo de procesamiento nro $TP_SISOP_CICLO"
		#glog
		echo "====================================================="

		for FILE in $ARRIBOSDIR/*
		do
			echo "============================ Procesando archivo $FILE... ============================"
			#glog

			ARCHIVOACEPTADO=1
			MOTIVORECHAZO=""

			# $FILE : /home/...../Entregas_01.txt
			FILENAME=$(echo "$FILE" | rev | cut -d '/' -f1 | rev) # Entregas_01.txt
			MESARRIBO=$(echo "$FILENAME" | cut -d '.' -f1 | cut -d '_' -f2) # 01

			########### Verificación de archivo no vacío ###########
			if [ "$ARCHIVOACEPTADO" == "1" ]
			then
				if [ ! -s "$FILE" ]
				then
					echo "Verificando si el archivo $FILENAME es no vacio... ERROR"
					#glog
					ARCHIVOACEPTADO=0
				else
					echo "Verificando si el archivo $FILENAME es no vacio... OK"
				fi
			fi
			########################################################
			
			############ Verificación de extensión .txt ############
			if [ "$ARCHIVOACEPTADO" == "1" ]
			then
				FILE_EXTENSION=$(echo "$FILE" | cut -d '.' -f2)
				if [ "${FILE_EXTENSION}" != "txt" ]
				then
					echo "Verificando extension .txt de $FILENAME... ERROR"
					#glog
					ARCHIVOACEPTADO=0
				else
					echo "Verificando extension .txt de $FILENAME... OK"
					#glog
				fi	
			fi
			########################################################

			######### Verificación del nombre del archivo ##########
			if [ "$ARCHIVOACEPTADO" == "1" ]
			then
				verificarNombreArchivo "$FILENAME"
				if [ "$?" == "0" ]
				then
					ARCHIVOACEPTADO=0
				fi
			fi
			########################################################

			########### Verificación del mes del arribo ############
			if [ "$ARCHIVOACEPTADO" == "1" ]
			then
				verificarMesArchivo "$MESARRIBO"
				if [ "$?" == "0" ]
				then
					ARCHIVOACEPTADO=0
				fi
			fi
			########################################################

			######### Verificación del trailer del arribo ##########
			if [ "$ARCHIVOACEPTADO" == "1" ]
			then
				verificarTrailer "$FILE"
				if [ "$?" == "0" ]
				then
					ARCHIVOACEPTADO=0
				fi
			fi
			########################################################

			############ Verificación si ya se procesó #############
			if [ "$ARCHIVOACEPTADO" == "1" ]
			then
				verificarSiNoFueProcesado "$FILENAME"
				if [ "$?" == "0" ]
				then
					ARCHIVOACEPTADO=0
				fi
			fi
			########################################################

			if [ "$ARCHIVOACEPTADO" == "0" ]
			then	
				echo "Archivo $FILENAME RECHAZADO."
				#glog
				# Mover el archivo completo a rechazados	
			else
				while read REGISTRO
				do
					REGISTROACEPTADO=1

					OPERADOR=$(cut -d';' -f1 <<<$REGISTRO)
					CODIGOPOSTAL=$(cut -d';' -f6 <<<$REGISTRO)

					if [ "$OPERADOR" != "" ] #Si no estoy en la ultima linea
					then

						echo "=========== Procesando registro $REGISTRO... ==========="
						#glog

						######### Verificación existencia de operador ##########
						if [ "$REGISTROACEPTADO" == "1" ]
						then				
							verificarExistenciaOperador "$OPERADOR"
							if [ "$?" == "0" ]
							then
								REGISTROACEPTADO=0
								MOTIVORECHAZO="No existe ese operador en el maestro de operadores"
							fi	
						fi
						########################################################

						########### Verificación vigencia contrato #############
						if [ "$REGISTROACEPTADO" == "1" ]
						then
							verificarVigenciaContrato "$OPERADOR" "$MESARRIBO"
							if [ "$?" == "0" ]
							then
								REGISTROACEPTADO=0
								MOTIVORECHAZO="Falla en la verificación de vigencia del contrato con ese operador"
							fi
						fi
						########################################################

						########## Verificación existencia sucursal ############
						if [ "$REGISTROACEPTADO" == "1" ]
						then
							verificarCPSucursalOperador "$OPERADOR" "$CODIGOPOSTAL"
							if [ "$?" == "0" ]
							then
								REGISTROACEPTADO=0
								MOTIVORECHAZO="No existe una sucursal con ese CP en el maestro de sucursales"
							fi
						fi
						########################################################

						if [ "$REGISTROACEPTADO" == "0" ]
						then
							echo "Registro RECHAZADO."
							echo "$REGISTRO;$MOTIVORECHAZO;$FILENAME">>"$RECHAZADOSDIR/Entregas_Rechazadas"
							#glog debe tener Operador, codigo postal, numero de pieza, y motivo de rechazo
						else
							echo "Registro aceptado, se procede a procesarlo."
							#procesar registro actual, formatear como lo pedido y append a Entregas_OPERADOR con todos los campos pedidos
						fi
					fi

				done <$FILE

				#Mover el archivo a procesados
			fi
		done

		echo "====================================================="
		echo "Finalizado ciclo de procesamiento nro $TP_SISOP_CICLO"
		#glog
		echo "====================================================="

		sleep 60
	done
	
	return 1
}

main
