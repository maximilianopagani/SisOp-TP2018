#!/bin/bash
#Glog - Script log errores

verificarExistenciaOperador()
{
	OPERADORABUSCAR="$1"

	LINEFOUND=$(grep "^$OPERADORABUSCAR;" "$MAESTROSDIR/Operadores.txt")

	if [ "$LINEFOUND" != "" ]
	then
		#echo "Verificando existencia de operador $OPERADORABUSCAR en maestro de operadores... OK"
		return 1
	else	
		#echo "Verificando existencia de operador $OPERADORABUSCAR en maestro de operadores... ERROR, NO EXISTE"
		return 0
	fi			
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
		#echo "Verificando la vigencia del contrato del operador $OPERADORABUSCAR al mes $MESDEARRIBO... ERROR, CONTRATO VENCIDO"
		return 0
	else
		#echo "Verificando la vigencia del contrato del operador $OPERADORABUSCAR al mes $MESDEARRIBO... OK"
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
		#echo "Verificando existencia de alguna sucursal del operador $OPERADORABUSCAR con código postal $CPABUSCAR... OK"
		return 1
	else
		#echo "Verificando existencia de alguna sucursal del operador $OPERADORABUSCAR con código postal $CPABUSCAR... ERROR, NO EXISTE NINGUNA"
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
		#echo "Verificando cantidad de registros y suma de códigos postales con con el trailer... ERROR, NO COINCIDE"
		return 0
	else
		#echo "Verificando cantidad de registros y suma de códigos postales con con el trailer... OK"
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
		#echo "Verificando mes del arribo ($MES_ARRIBO) respecto al mes actual ($MES_ACTUAL)... OK"
		return 1
	else	
		#echo "Verificando mes del arribo ($MES_ARRIBO) respecto al mes actual ($MES_ACTUAL)... ERROR"
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
		#echo "Verificando si el nombre del archivo $file_name cumple con el formato estandar (Entregas_XX)... OK"
		return 1
	else
		#echo "Verificando si el nombre del archivo $file_name cumple con el formato estandar (Entregas_XX)... ERROR"
		return 0		
	fi
}

verificarSiNoFueProcesado()
{
	file_name="$1"
	
	if [ -e "$PROCESADOSDIR/$file_name" ]
	then
		#echo "Verificando si el archivo $file_name no fué procesado anteriormente... ERROR"
		return 0
	else
		#echo "Verificando si el archivo $file_name no fué procesado anteriormente... OK"
		return 1
	fi
}

#autocompletarString "STRING" "CARACTER" "IZQ/DER" "CANTIDAD TOTAL A ALCANZAR"
# EJ, completar con espacios a izquierda hasta los 50 caracteres: autocompletarString "mi_string" " " "IZQ" "50"

STRINGRESULT=""

autoCompletarString()
{
	STRING="$1"
	CARACTER="$2"
	SENTIDO="$3"
	TOTAL="$4"

	if [ "$SENTIDO" == "IZQ" ]
	then
		while [ ${#STRING} -lt $TOTAL ]
		do
			STRING="$CARACTER""${STRING}"
		done
	else
		if [ "$SENTIDO" == "DER" ]
		then
			while [ ${#STRING} -lt $TOTAL ]
			do
				STRING="${STRING}""$CARACTER"
			done
		fi
	fi

	STRINGRESULT="${STRING}"
}

removerEspaciosADerecha()
{
	STRING="$1"
	STRINGRESULT=$(sed 's|\(^.*[^ ]\)[ ]*$|\1|' <<<"$STRING")
}


######################################################################################################
#                                        PROCESO                                                     #
######################################################################################################

main()
{
	if [ "$TP_SISOP_INIT" != "YES" ] #Variable que vendría de más arriba
	then
		#echo "============ [ERROR] No se puede ejecutar el proceso debido a que el sistema no se encuentra inicializado ============"
		./glog "procesoSisOp" "============ [ERROR] No se puede ejecutar el proceso ya que el sistema no se encuentra inicializado ============" "ERROR"
		return 0
	fi

	#echo "======================== INICIANDO PROCESO. DIRECTORIO A BUSCAR NOVEDADES: $ARRIBOSDIR ========================"
	./glog "procesoSisOp" "======================== INICIANDO PROCESO. DIRECTORIO A BUSCAR NOVEDADES: $ARRIBOSDIR ========================"

	TP_SISOP_CICLO=0

	while true
	do
		TP_SISOP_CICLO=$((TP_SISOP_CICLO+1))
		
		#echo "======================== SE INICIA CICLO DE PROCESAMIENTO NRO $TP_SISOP_CICLO ========================"
		./glog "procesoSisOp" "======================== SE INICIA CICLO DE PROCESAMIENTO NRO $TP_SISOP_CICLO ========================"

		#################### Procesamiento de ARRIBOS ####################

		if [ -z "$(ls -A $ARRIBOSDIR)" ] # Si el directorio está vacío
		then
			#echo "===================      NO HAY NOVEDADES PARA PROCESAR      ==================="
			./glog "procesoSisOp" "=======================      NO HAY NOVEDADES PARA PROCESAR      ======================="
		else
			#echo "=======================      VERIFICANDO ARCHIVOS ARRIBADOS      ======================="
			./glog "procesoSisOp" "=======================      VERIFICANDO ARCHIVOS ARRIBADOS      ======================="

			for FILEARRIBO in "$ARRIBOSDIR"/*
			do
				ARCHIVOACEPTADO=1
				MOTIVORECHAZO=""

				# $FILEARRIBO : /home/.../arribos/Entregas_01.txt
				FILENAME=$(echo "$FILEARRIBO" | rev | cut -d '/' -f1 | rev) # Entregas_01.txt
				MESARRIBO=$(echo "$FILENAME" | cut -d '.' -f1 | cut -d '_' -f2) # 01

				#echo "====================== Verificando archivo arribado $FILENAME... ======================"

				########### Verificación de archivo no vacío ###########
				if [ "$ARCHIVOACEPTADO" == "1" ]
				then
					if [ ! -s "$FILEARRIBO" ]
					then
						#echo "Verificando si el archivo $FILENAME es no vacio... ERROR"
						ARCHIVOACEPTADO=0
						MOTIVORECHAZO="El archivo está vacio"
					fi
				fi
			
				############ Verificación de extensión .txt ############
				if [ "$ARCHIVOACEPTADO" == "1" ]
				then
					FILE_EXTENSION=$(echo "$FILEARRIBO" | cut -d '.' -f2)
					if [ "${FILE_EXTENSION}" != "txt" ]
					then
						#echo "Verificando extension .txt de $FILENAME... ERROR"
						ARCHIVOACEPTADO=0
						MOTIVORECHAZO="El archivo no posee extension .txt"
					fi	
				fi

				######### Verificación del nombre del archivo ##########
				if [ "$ARCHIVOACEPTADO" == "1" ]
				then
					verificarNombreArchivo "$FILENAME"
					if [ "$?" == "0" ]
					then
						ARCHIVOACEPTADO=0
						MOTIVORECHAZO="El archivo posee un nombre distinto al estandar esperado (Entregas_XX)"
					fi
				fi

				########### Verificación del mes del arribo ############
				if [ "$ARCHIVOACEPTADO" == "1" ]
				then
					verificarMesArchivo "$MESARRIBO"
					if [ "$?" == "0" ]
					then
						ARCHIVOACEPTADO=0
						MOTIVORECHAZO="El archivo es de un mes posterior al actual"
					fi
				fi

				############ Verificación si ya se procesó #############
				if [ "$ARCHIVOACEPTADO" == "1" ]
				then
					verificarSiNoFueProcesado "$FILENAME"
					if [ "$?" == "0" ]
					then
						ARCHIVOACEPTADO=0
						MOTIVORECHAZO="El archivo ya fué procesado anteriormente"
					fi
				fi

				if [ "$ARCHIVOACEPTADO" == "0" ]
				then	
					#echo "Archivo $FILENAME RECHAZADO. Motivo: $MOTIVORECHAZO"
					./glog "procesoSisOp" "=== $FILENAME === Archivo RECHAZADO. Motivo: $MOTIVORECHAZO"
					mv -u "$FILEARRIBO" "$RECHAZADOSDIR"
					#./mover "$FILEARRIBO" "$RECHAZADOSDIR"
				else
					#echo "Verificación de archivo $FILENAME OK. Se mueve al directorio de aceptados"
					./glog "procesoSisOp" "=== $FILENAME === Verificación de archivo OK. Se mueve al directorio de aceptados"
					mv -u "$FILEARRIBO" "$ACEPTADOSDIR"
					#./mover "$FILEARRIBO" "$ACEPTADOSDIR"						
				fi
			done
		fi

		sleep 5 # Hago un sleep corto por si demora en mover los archivos

		################### Procesamiento de ACEPTADOS ###################

		if [ "$(ls -A $ACEPTADOSDIR)" ] # Si el directorio no está vacío
		then
			#echo "=======================      PROCESANDO ARCHIVOS ACEPTADOS      ======================="
			./glog "procesoSisOp" "=======================      PROCESANDO ARCHIVOS ACEPTADOS      ========================"

			for FILEACEPTADO in "$ACEPTADOSDIR"/*
			do
				# $FILEACEPTADO: /home/.../aceptados/Entregas_01.txt
				FILENAME=$(echo "$FILEACEPTADO" | rev | cut -d '/' -f1 | rev) # Entregas_01.txt
				MESARRIBO=$(echo "$FILENAME" | cut -d '.' -f1 | cut -d '_' -f2) # 01
					
				######### Verificación del trailer del arribo ##########
				verificarTrailer "$FILEACEPTADO"
				if [ "$?" == "0" ]
				then
					#echo "=== $FILENAME === Archivo RECHAZADO. Motivo: El trailer del archivo no coincide con los datos de los registros"
					./glog "procesoSisOp" "=== $FILENAME === Archivo RECHAZADO. Motivo: El trailer del archivo no coincide con los datos de los registros"
					mv -u "$FILEACEPTADO" "$RECHAZADOSDIR"
					#./mover "$FILEACEPTADO" "$RECHAZADOSDIR"	
				else
					# Trailer OK, procedemos a grabar en log y procesar los registros
					#echo "=== $FILENAME === Verificación del trailer OK. Se procede a analizar los registros"
					./glog "procesoSisOp" "=== $FILENAME === Verificación del trailer OK. Se procede a analizar los registros"

					while read REGISTRO
					do
						REGISTROACEPTADO=1
						MOTIVORECHAZO=""

						OPERADOR=$(cut -d';' -f1 <<<$REGISTRO)
						CODIGOPOSTAL=$(cut -d';' -f6 <<<$REGISTRO)

						if [ "$OPERADOR" != "" ] #Si no estoy en la ultima linea
						then

							#echo "=========== Procesando registro $REGISTRO... ==========="

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

							######### Procesamos los registros exitosos ############
							if [ "$REGISTROACEPTADO" == "0" ]
							then
								#echo "Registro RECHAZADO. Operador: $OPERADOR - Código Postal: $CODIGOPOSTAL - Nro Pieza: $NROPIEZA - Motivo: $MOTIVORECHAZO"
								echo "$REGISTRO;$MOTIVORECHAZO;$FILENAME">>"$RECHAZADOSDIR/Entregas_Rechazadas"
								./glog "procesoSisOp" "Registro RECHAZADO. Operador: $OPERADOR - Código Postal: $CODIGOPOSTAL - Nro Pieza: $NROPIEZA - Motivo: $MOTIVORECHAZO"
							else
								NROPIEZA=$(cut -d';' -f2 <<<$REGISTRO)
								NOMBREYAPELLIDO=$(cut -d';' -f3 <<<$REGISTRO)
								TIPODOC=$(cut -d';' -f4 <<<$REGISTRO)
								DOCUMENTO=$(cut -d';' -f5 <<<$REGISTRO)
								LINEASUCURSAL=$(grep ".*;${CODIGOPOSTAL};${OPERADOR};[^;]*$" "$MAESTROSDIR/Sucursales.txt")
								CODIGOSUCURSAL=$(cut -d';' -f1 <<<$LINEASUCURSAL)
								NOMBRESUCURSAL=$(cut -d';' -f2 <<<$LINEASUCURSAL)
								DIRECCIONSUCURSAL=$(cut -d';' -f3 <<<$LINEASUCURSAL)
								PRECIOSUCURSAL=$(cut -d';' -f8 <<<$LINEASUCURSAL)
							
								autoCompletarString "$NROPIEZA" "0" "IZQ" "20"
								NROPIEZA="$STRINGRESULT"
							
								removerEspaciosADerecha "$NOMBREYAPELLIDO"
								autoCompletarString "$STRINGRESULT" " " "IZQ" "50"
								NOMBREYAPELLIDO="$STRINGRESULT"

								removerEspaciosADerecha "$TIPODOC"
								TIPODOC="$STRINGRESULT"

								autoCompletarString "$DOCUMENTO" "0" "IZQ" "11"
								DOCUMENTO="$STRINGRESULT"

								removerEspaciosADerecha "$NOMBRESUCURSAL"
								autoCompletarString "$STRINGRESULT" " " "IZQ" "25"
								NOMBRESUCURSAL="$STRINGRESULT"

								removerEspaciosADerecha "$DIRECCIONSUCURSAL"
								autoCompletarString "$STRINGRESULT" " " "IZQ" "25"
								DIRECCIONSUCURSAL="$STRINGRESULT"

								autoCompletarString "$PRECIOSUCURSAL" "0" "IZQ" "6"
								PRECIOSUCURSAL="$STRINGRESULT"

								#echo "Registro ACEPTADO. Operador: $OPERADOR - Código Postal: $CODIGOPOSTAL - Nro Pieza: $NROPIEZA"
								echo "$NROPIEZA""$NOMBREYAPELLIDO""$TIPODOC""$DOCUMENTO""$CODIGOPOSTAL""$CODIGOSUCURSAL""$NOMBRESUCURSAL""$DIRECCIONSUCURSAL""$PRECIOSUCURSAL""$FILENAME">>"$SALIDADIR/Entregas_$OPERADOR"
								./glog "procesoSisOp" "Registro ACEPTADO. Operador: $OPERADOR - Código Postal: $CODIGOPOSTAL - Nro Pieza: $NROPIEZA"					
							fi
						fi

					done <$FILEACEPTADO
				
					mv -u "$FILEACEPTADO" "$PROCESADOSDIR"
					#./mover "$FILEACEPTADO" "$PROCESADOSDIR"
				fi
			done
		fi
		sleep 60
	done
	return 1
}

chmod +x ./mover
chmod +x ./glog

main

######################################################################################################
#                                             FIN PROCESO                                            #
######################################################################################################
