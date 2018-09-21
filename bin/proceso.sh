#!/bin/bash
#Glog - Script log errores

####################################################
#	Principal
####################################################

echo "Programa Proceso"




#	Modo de uso: 
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
		echo "La operadora no tiene un contrato vigente"
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
