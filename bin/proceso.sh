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

	echo "Verificando existencia de operador $OPERADORABUSCAR en maestro de operadores..."
	#glog

	LINEFOUND=$(grep "^$OPERADORABUSCAR;" "$MAESTROSDIR/Operadores.txt")

	if [ "$LINEFOUND" != "" ]
	then
		echo "Operador $OPERADORABUSCAR encontrado."
		#glog
		return 1
	fi		

	echo "Operador $OPERADORABUSCAR no existe."
	#glog
	return 0	
}

verificarVigenciaContrato()
{
	OPERADORABUSCAR="$1"
	MESDEARRIBO="$2"

	echo "Verificando la vigencia del contrato del operador $OPERADORABUSCAR al mes $MESDEARRIBO..."
	#glog

	FECHAARRIBO=$MESDEARRIBO/$(date +%d)/$(date +%Y)
	FECHAFIN=$(grep "^${OPERADORABUSCAR}" "$MAESTROSDIR/Operadores.txt" | sed 's|.*;\([^/]*\)/\([^/]*\)/\([^/]*\)$|\2/\1/\3|')

	SEGUNDOSARRIBO=$(date -d $FECHAARRIBO +%s)
	SEGUNDOSFIN=$(date -d $FECHAFIN +%s)

	if [ ${SEGUNDOSARRIBO} -ge ${SEGUNDOSFIN} ]
	then
		echo "La operadora no tiene un contrato vigente."
		#glog
		return 0
	else
		echo "Contrato vigente verificado."
		#glog
		return 1
	fi	
}

verificarCPSucursalOperador()
{
	OPERADORABUSCAR="$1"
	CPABUSCAR="$2"

	echo "Verificando existencia de alguna sucursal del operador $OPERADORABUSCAR con código postal $CPABUSCAR..."
	#glog

	LINEFOUND=$(grep ".*;${CPABUSCAR};${OPERADORABUSCAR};[^;]*$" "$MAESTROSDIR/Sucursales.txt")

	if [ "$LINEFOUND" != "" ]
	then
		echo "Sucursal de $OPERADORABUSCAR con código postal $CPABUSCAR encontrada."
		#glog
		return 1
	fi	

	echo "Sucursal de $OPERADORABUSCAR con código postal $CPABUSCAR no existe."
	#glog
	return 0	
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

		for FILE in $ARRIBOSDIR/*
		do
			#nota: FILE es el absolute path. Ej: /home/..../arribos/Entreas_02.txt
			#si queremos que solo queden como Entregas_02.txt, hay que poner cd $ARRIBOSDIR antes

			echo "============================ Procesando archivo $FILE... ============================"
			#glog

			ARCHIVOACEPTADO=1

			#verificar nombre
			#verificar no vacio
			#verificar extension .txt
			#verificar si ya se procesó otro con mismo nombre en PROCESADOSDIR
			#chequear suma codigo postal y cantidad de registros
				#si ok continuar, sino mover **archivo completo** a rechazados
			if [ "$ARCHIVOACEPTADO" == "0" ]
			then	
				echo "Archivo $FILE rechazado."
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

						verificarExistenciaOperador "$OPERADOR"
						if [ "$?" == "0" ]
						then
							REGISTROACEPTADO=0
						fi

						verificarVigenciaContrato "$OPERADOR" "07" #MES_ARRIBO
						if [ "$?" == "0" ]
						then
							REGISTROACEPTADO=0
						fi

						verificarCPSucursalOperador "$OPERADOR" "$CODIGOPOSTAL"
						if [ "$?" == "0" ]
						then
							REGISTROACEPTADO=0
						fi
					fi

					if [ "$REGISTROACEPTADO" == "0" ]
					then
						echo "Registro rechazado."
						#glog
						#hacer append del registro a Entregas_Rechazadas
					else
						#procesar registro actual, formatear como lo pedido y append a Entregas_OPERADOR con todos los campos pedidos
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
