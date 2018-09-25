#!/bin/bash
INGRESO1=""
INGRESO=""
DIRECTORIO=""
OP=""
COMANDO=$0

#Constantes de instalacion
RUTAPAQUETE=$(pwd)'/paquete_sisop_grupo02.tar.gz'
RUTADATOS=$(pwd)'/sourcefiles'

RUTAARCHIVOSMAESTROSYTABLAS=${RUTADATOS}'/mae'	

RUTAACTUAL=$(pwd)
RUTAEJECUTABLES="${RUTAACTUAL}/sourcefiles/bin"
RUTAMAESTROS="${RUTAACTUAL}/sourcefiles/mae"
RUTAEJEMPLOS="${RUTAACTUAL}/sourcefiles/arribos"

	
chmod +x ./mover
chmod +x ./glog


DATASIZE=100
LOGSIZE=10000

#Variables globales
GRUPODIR=$(pwd)
CONFDIR="${GRUPODIR}/conf"
LOGDIR="${GRUPODIR}/conf/log"
ARCHIVOLOG="${GRUPODIR}/conf/log/instalacion.log"
ARCHIVOCONF="${CONFDIR}/tpconfig.txt"
BINDIR="${GRUPODIR}/bin"
MAESTROSDIR="${GRUPODIR}/maestros"
ARRIBOSDIR="${GRUPODIR}/arribos"
ACEPTADOSDIR="${GRUPODIR}/aceptados"
RECHAZADOSDIR="${GRUPODIR}/rechazados"
PROCESADOSDIR="${GRUPODIR}/procesados"
SALIDADIR="${GRUPODIR}/salida"

MENSAJECREACIONCONFDIR="Creacion del directorio de Configuracion (${CONFDIR}):"
MENSAJECREACIONLOGDIR="Creacion del directorio de LOGS (${LOGDIR}):"

#Primer parametro: directorio raiz a partir del cual se listaran los archivos y subdirectorios
mostarEstructuraDeArchivosYDirectorios(){
	find "$1" -mindepth 1 -printf '%P\n'	
	find "$1" -mindepth 1 | ./glog InsPro "$1"
}





#----------------------------  DEFINICION DE FUNCIONES  ----------------------------

#Crea los directorio de configuracion y de log.
#Esta funcion fue utilizada para modo test. 
#No hace falta usarla porque al descompromir el paquete ya se crean el dir /conf/log
CrearDirectoriosIniciales(){
	mkdir -p "${CONFDIR}"
	mkdir -p "${LOGDIR}"
	./glog instalacion "Ing FUNCION CrearDirectoriosIniciales"
	./glog instalacion "${MENSAJECREACIONCONFDIR}"
	./glog instalacion "${MENSAJECREACIONLOGDIR}"
}



MENSAJECOPYRIGHT="TP SO7508 Segundo Cuatrimestre 2018. Copyright © Grupo 02"
#Muestra mensaje de CopyRight
mostrarHeader(){
	clear
	echo ${MENSAJECOPYRIGHT}
	echo ''
}

VARBOOL="F"
#funcion que verifica que los nombres de dir no sean repetidos ni nombres reservados
#nombres reservados: BIN,CONF,maestros,arribos,aceptados,rechazados,procesados,salida
#en cualquier conbinacion de mayusculas y mimnusculas.
#No se permite qu eun directorio lleve el nombre porpuesto para otro directorio
#por ejemplo 
#el dir SALIDA: no puede llamarse rechazados, aceptados etc
VerificarNoRepetido(){
	
	if [ "${INGRESO}" == "conf" ] || [ "${INGRESO}" == "log"  ];
	then
		echo "El nombre que ha ingresado ${INGRESO} es un nombre reservado."
		VARBOOL="F"
		return
	fi
	#DIRECTORIO = BIN
	if [ "${DIRECTORIO}" == "BIN" ]
		then
		    if [ "${INGRESO}" == "bin" ]
			then 
				VARBOOL="V"
				return
			fi
	            if [ "${INGRESO}" == "maestros" ] || [ "${INGRESO}" == "arribos" ] || [ "${INGRESO}" == "aceptados" ] || [ "${INGRESO}" == "rechazados" ] || [ "${INGRESO}" == "procesados" ] || [ "${INGRESO}" == "salida" ]
			then
				echo "El nombre que ha ingresado ${INGRESO} es un nombre reservado para otro directorio."
				VARBOOL="F"
				return
			fi
		fi
	#DIRECTORIO = MAE
	if [ "${DIRECTORIO}" == "MAE" ]
		then
		    if [ "${INGRESO}" == "maestros" ]
			then 
				VARBOOL="V"
				return
			fi
	            if [ "${INGRESO}" == "bin" ] || [ "${INGRESO}" == "arribos" ] || [ "${INGRESO}" == "aceptados"  ]  || [ "${INGRESO}" == "rechazados" ] || [ "${INGRESO}" == "procesados" ]  || [ "${INGRESO}" == "salida" ]
			then
				echo "El nombre que ha ingresado ${INGRESO} es un nombre reservado para otro directorio."
				VARBOOL="F"
				return
			fi
		     if [ "${GRUPODIR}/${INGRESO}" == "$BINDIR" ]
			then
				VALBOOL="F"
				echo "El nombre que ha ingresado ya lo ha ingresado para otro directorio."
				return	
		        fi					

		fi
	#DIRECTORIO = EXT
	if [ "${DIRECTORIO}" == "EXT" ]
		then
		    if [ "${INGRESO}" == "arribos" ]
			then 
				VARBOOL="V"
				return
			fi
	            if [ "${INGRESO}" == "maestros" ] ||  [ "${INGRESO}" == "bin" ] || [ "${INGRESO}" == "aceptados" ] || [ "${INGRESO}" == "rechazados" ] || [ "${INGRESO}" == "procesados" ] || [ "${INGRESO}" == "salida" ]
			then
				echo "El nombre que ha ingresado es un nombre reservado para otro directorio."
				VARBOOL="F"
				return
			fi
		     if [ "${GRUPODIR}/${INGRESO}" == "$BINDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$MAESTROSDIR" ]
			then
				VALBOOL="F"
				echo "El nombre que ha ingresado ya lo ha ingresado para otro directorio."
				return	
		        fi
		fi
	#DIRECTORIO = ACEP
	if [ "${DIRECTORIO}" == "ACEP" ]
		then
		    if [ "${INGRESO}" == "aceptados" ]
			then 
				VARBOOL="V"
				return
			fi
	            if [ "${INGRESO}" == "maestros"  ] || [ "${INGRESO}" == "arribos"  ] || [ "${INGRESO}" == "bin" ] || [  "${INGRESO}" == "rechazados" ] || [ "${INGRESO}" == "procesados" ] || [ "${INGRESO}" == "salida" ]
			then
				echo "El nombre que ha ingresado ${INGRESO} es un nombre reservado para otro directorio."
				VARBOOL="F"
				return
			fi
		    if [ "${GRUPODIR}/${INGRESO}" == "$BINDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$MAESTROSDIR" ] || [ "${GRUPO}/${INGRESO}" == "$ARRIBOSDIR" ]
			then
				VALBOOL="F"
				echo "El nombre que ha ingresado ya lo ha ingresado para otro directorio."
				return	
		        fi
		fi
	#DIRECTORIO = RECH
	if [ "${DIRECTORIO}" == "RECH" ]
		then
		    if [ "${INGRESO}" == "rechazados" ]
			then 
				VARBOOL="V"
				return
			fi
	            if [ "${INGRESO}" == "maestros" ] || [  "${INGRESO}" == "arribos" ] || [ "${INGRESO}" == "aceptados" ] || [ "${INGRESO}" == "bin" ] || [  "${INGRESO}" == "procesados" ] || [ "${INGRESO}" == "salida" ]
			then
				echo "El nombre que ha ingresado ${INGRESO} es un nombre reservado para otro directorio."
				VARBOOL="F"
				return
			fi
		        if [ "${GRUPODIR}/${INGRESO}" == "$BINDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$MAESTROSDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$ARRIBOSDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$ACEPTADOSDIR" ]
			then
				VALBOOL="F"
				echo "El nombre que ha ingresado ya lo ha ingresado para otro directorio."
				return	
		        fi
		fi
	#DIERCTORIO = PROC
	if [ "${DIRECTORIO}" == "PROC" ]
		then
		    if [ "${INGRESO}" == "procesados" ]
			then 
				VARBOOL="V"
				return
			fi
	            if [ "${INGRESO}" == "maestros" ] || [ "${INGRESO}" == "arribos"  ] || [ "${INGRESO}" == "aceptados" ] || [ "${INGRESO}" == "rechazados" ] || [ "${INGRESO}" == "bin" ] ||  [ "${INGRESO}" == "salida" ]
			then
				echo "El nombre que ha ingresado ${INGRESO} es un nombre reservado para otro directorio."
				VARBOOL="F"
				return
			fi
			if [ "${GRUPODIR}/${INGRESO}" == "$BINDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$MAESTROSDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$ARRIBOSDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$ACEPTADOSDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$RECHAZADOSDIR" ]
			then
				VALBOOL="F"
				echo "El nombre que ha ingresado ya lo ha ingresado para otro directorio."
				return	
		        fi
		fi
	#DIRECTORIO = SAL
	if [ "${DIRECTORIO}" == "SAL" ]
		then
		    if [ "${INGRESO}" == "salida" ]
			then 
				VARBOOL="V"
				return
			fi
	            if [ "${INGRESO}" == "maestros" ] || [ "${INGRESO}" == "salida" ] || [ "${INGRESO}" == "aceptados" ] || [ "${INGRESO}" == "rechazados" ] || [ "${INGRESO}" == "procesados" ] || [ "${INGRESO}" == "bin" ]
			then
				echo "El nombre que ha ingresado ${INGRESO} es un nombre reservado para otro directorio."
				VARBOOL="F"
				return
			fi
			if [ "${GRUPODIR}/${INGRESO}" == "$BINDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$MAESTROSDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$ARRIBOSDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$ACEPTADOSDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$RECHAZADOSDIR" ] || [ "${GRUPODIR}/${INGRESO}" == "$PROCESADOSDIR" ]
			then
				VALBOOL="F"
				echo "El nombre que ha ingresado ya lo ha ingresado para otro directorio."
				return	
		        fi
		fi
	 
	VARBOOL="V"
}

 
MENSAJECONSULTABINDIR="Defina el directorio de instalación de los ejecutables (${BINDIR}):"
MENSAJECONSULTABINDIRLOG="Consulta al usuario el directorio de instalación de los ejecutables, por defecto: ${BINDIR})."
consultarRutaEjecutables(){	
	DIRECTORIO="BIN"	
	VARBOOL="F"
	while [ "${VARBOOL}" == "F" ]
	do
		echo "${MENSAJECONSULTABINDIR}"
		./glog instalacion "${MENSAJECONSULTABINDIRLOG}"
		read INGRESO1
		INGRESO=${INGRESO1,,}
		if [ ${#INGRESO} -gt 0 ];
		then
			
			VerificarNoRepetido		
			if [ "${VARBOOL}" == "V" ];
				then
				BINDIR="${GRUPODIR}/${INGRESO1}"
				fi
		else
			VARBOOL="V"
		fi
	done
	echo "Directorio de Archivos Ejecutables: ${BINDIR}"	
}

MENSAJECONSULTAMAEDIR="Defina el directorio de instalación de los maestros (${MAESTROSDIR}):"
MENSAJECONSULTAMAEDIRLOG="Consulta al usuario el directorio de instalación de los maestros, por defecto: ${MAESTROSDIR})."
consultarRutaMaestros(){	
	DIRECTORIO="MAE"	
	VARBOOL="F"
	while [ "${VARBOOL}" == "F" ]
	do
		echo "${MENSAJECONSULTAMAEDIR}"
		./glog instalacion "${MENSAJECONSULTAMAEDIRLOG}"
		read INGRESO1
		INGRESO=${INGRESO1,,}
		if [ ${#INGRESO} -gt 0 ];
		then
			VerificarNoRepetido		
			if [ "${VARBOOL}" == "V" ];
				then
				MAESTROSDIR="${GRUPODIR}/${INGRESO1}"
				fi
		else
			VARBOOL="V"
		fi
	done
	echo "Directorio de Maestros: ${MAESTROSDIR}"	
}


MENSAJECONSULTAEXTDIR="Defina el directorio de instalación de los arribos (${ARRIBOSDIR}):"
MENSAJECONSULTAEXTDIRLOG="Consulta al usuario el directorio de instalación de los arribos, por defecto: ${ARRIBOSDIR})."
consultarRutaExternos(){	
	DIRECTORIO="EXT"	
	VARBOOL="F"
	while [ "${VARBOOL}" == "F" ]
	do
		echo "${MENSAJECONSULTAEXTDIR}"
		./glog instalacion "${MENSAJECONSULTAEXTDIRLOG}"
		read INGRESO1
		INGRESO=${INGRESO1,,}
		if [ ${#INGRESO} -gt 0 ];
		then
			VerificarNoRepetido		
			if [ "${VARBOOL}" == "V" ];
				then
				ARRIBOSDIR="${GRUPODIR}/${INGRESO1}"
				fi
		else
			VARBOOL="V"
		fi
	done
	echo "Directorio de Externos: ${ARRIBOSDIR}"	
}


MENSAJECONSULTAACEPDIR="Defina el directorio de instalación de los aceptados (${ACEPTADOSDIR}):"
MENSAJECONSULTAACEPDIRLOG="Consulta al usuario el directorio de instalación de los aceptados, por defecto: ${ACEPTADOSDIR})."
consularRutaAceptados(){	
	DIRECTORIO="ACEP"	
	VARBOOL="F"
	while [ "${VARBOOL}" == "F" ]
	do
		echo "${MENSAJECONSULTAACEPDIR}"
		./glog instalacion "${MENSAJECONSULTAACEPDIRLOG}"
		read INGRESO1
		INGRESO=${INGRESO1,,}
		if [ ${#INGRESO} -gt 0 ];
		then
			VerificarNoRepetido		
			if [ "${VARBOOL}" == "V" ];
				then
				ACEPTADOSDIR="${GRUPODIR}/${INGRESO1}"
				fi
		else
			VARBOOL="V"
		fi
	done
	echo "Directorio de Externos: ${ACEPTADOSDIR}"	
}


MENSAJECONSULTARECHDIR="Defina el directorio de instalación de los rechazados (${RECHAZADOSDIR}):"
MENSAJECONSULTARECHDIRLOG="Consulta al usuario el directorio de instalación de los rechazados, por defecto: ${RECHAZADOSDIR})."
consultarRutaRechazados(){
	DIRECTORIO="RECH"	
	VARBOOL="F"
	while [ "${VARBOOL}" == "F" ]
	do
		echo "${MENSAJECONSULTARECHDIR}"
		./glog instalacion "${MENSAJECONSULTARECHDIRLOG}"
		read INGRESO1
		INGRESO=${INGRESO1,,}
		if [ ${#INGRESO} -gt 0 ];
		then
			VerificarNoRepetido		
			if [ "${VARBOOL}" == "V" ];
				then
				RECHAZADOSDIR="${GRUPODIR}/${INGRESO1}"
				fi
		else
			VARBOOL="V"
		fi
	done
	echo "Directorio de Externos: ${RECHAZADOSDIR}"	
}

MENSAJECONSULTAPROCDIR="Defina el directorio de instalación de los procesados (${PROCESADOSDIR}):"
MENSAJECONSULTAPROCDIRLOG="Consulta al usuario el directorio de instalación de los procesados, por defecto: ${PROCESADOSDIR})."
consultarRutaProcesados(){
	DIRECTORIO="PROC"	
	VARBOOL="F"
	while [ "${VARBOOL}" == "F" ]
	do
		echo "${MENSAJECONSULTAPROCDIR}"
		./glog instalacion "${MENSAJECONSULTAPROCDIRLOG}"
		read INGRESO1
		INGRESO=${INGRESO1,,}
		if [ ${#INGRESO} -gt 0 ];
		then
			VerificarNoRepetido		
			if [ "${VARBOOL}" == "V" ];
				then
				PROCESADOSDIR="${GRUPODIR}/${INGRESO1}"
				fi
		else
			VARBOOL="V"
		fi
	done
	echo "Directorio de Externos: ${PROCESADOSDIR}"	
}



MENSAJECONSULTASALDIR="Defina el directorio de instalación de los Salida (${SALIDADIR}):"
MENSAJECONSULTASALDIRLOG="Consulta al usuario el directorio de instalación de los salida, por defecto: ${SALIDADIR})."
consutarRutaSalida(){	
	DIRECTORIO="SAL"
	VARBOOL="F"
	while [ "${VARBOOL}" == "F" ]
	do
		echo "${MENSAJECONSULTASALDIR}"
		./glog instalacion "${MENSAJECONSULTASALDIRLOG}"
		read INGRESO1
		INGRESO=${INGRESO1,,}
		if [ ${#INGRESO} -gt 0 ];
		then
			VerificarNoRepetido		
			if [ "${VARBOOL}" == "V" ];
				then
				SALIDADIR="${GRUPODIR}/${INGRESO1}"
				fi
		else
			VARBOOL="V"
		fi
	done
	echo "Directorio de Externos: ${SALIDADIR}"	
}

#Funcion que consulta al usuario el nombre de los diretorios a utilizar por la aplicacion
ConsultasAlUsuario(){
	echo "DEFINICION  DE DIRECTORIOS:"
	echo "A continuacion se le consultara los nombres de los directorios usados por el sistema."
	echo "Se le propondra un nombre por defecto entre parentesis, si lo acepta solo presione ENTER."
	echo ""
	#BINDIR="${GRUPODIR}/bin"	
	consultarRutaEjecutables
	MENSAJECONSULTABINDIR="Defina el directorio de instalación de los ejecutables (${BINDIR}):"
	MENSAJECONSULTABINDIRLOG="Consulta al usuario el directorio de instalación de los ejecutables, por defecto: ${BINDIR})."
	echo ''
	#MAESTROSDIR="${GRUPODIR}/maestros"
	consultarRutaMaestros
	MENSAJECONSULTAMAEDIR="Defina el directorio de instalación de los maestros (${MAESTROSDIR}):"
	MENSAJECONSULTAMAEDIRLOG="Consulta al usuario el directorio de instalación de los maestros, por defecto: ${MAESTROSDIR})."
	echo ''
	#ARRIBOSDIR="${GRUPODIR}/arribos"
	consultarRutaExternos
	MENSAJECONSULTAEXTDIR="Defina el directorio de instalación de los externos (${ARRIBOSDIR}):"
	MENSAJECONSULTAEXTDIRLOG="Consulta al usuario el directorio de instalación de los externos, por defecto: ${ARRIBOSDIR})."
	echo ''
	#ACEPTADOSDIR="${GRUPO}/aceptados"
	consularRutaAceptados
	MENSAJECONSULTAACEPDIR="Defina el directorio de instalación de los aceptados (${ACEPTADOSDIR}):"
	MENSAJECONSULTAACEPDIRLOG="Consulta al usuario el directorio de instalación de los aceptados, por defecto: ${ACEPTADOSDIR})."
	echo ''
	#RECHAZADOSDIR="${GRUPO}/rechazados"
	consultarRutaRechazados
	MENSAJECONSULTARECHDIR="Defina el directorio de instalación de los rechazados (${RECHAZADOSDIR}):"
	MENSAJECONSULTARECHDIRLOG="Consulta al usuario el directorio de instalación de los rechazados, por defecto: ${RECHAZADOSDIR})."
	echo ''
	#PROCESADOSDIR="${GRUPO}/procesados"
	consultarRutaProcesados
	MENSAJECONSULTAPROCDIR="Defina el directorio de instalación de los procesados (${PROCESADOSDIR}):"
	MENSAJECONSULTAPROCDIRLOG="Consulta al usuario el directorio de instalación de los procesados, por defecto: ${PROCESADOSDIR})."
	echo ''
	#SALIDADIR="${GRUPO}/salida"
	consutarRutaSalida
MENSAJECONSULTASALDIR="Defina el directorio de instalación de los Salida (${SALIDADIR}):"
MENSAJECONSULTASALDIRLOG="Consulta al usuario el directorio de instalación de los salida, por defecto: ${SALIDADIR})."
	echo ''
}


#Presenta al usuario los directorios definidos
mostrarEstructuraDeArchivos(){
mostrarHeader
echo "Directorio padre: ${GRUPODIR}"
echo "Deirectorio de configuraicon: ${CONFDIR}"
echo "Libreria de ejecutables: ${BINDIR}"
echo "repositorio de maestros: ${MAESTROSDIR}"
echo "Directorio para el arrilo de archivos eternos: ${ARRIBOSDIR}"
echo "Directorio para los archivos aceptados: ${ACEPTADOSDIR}"
echo "Directorio para los archivos rechazados: ${RECHAZADOSDIR}"
echo "Directorio para los archivos procesados: ${PROCESADOSDIR}"
echo "Directorio para los archivos de Salida: ${SALIDADIR}"
}



MENSAJECONSULTAINICIOINSTALACION="Inicia la instalación? (Si – No – Cancel)"
MENSAJECONSULTAINICIOINSTALACIONLOG="Consulta si Inicia la instalación"
#Iteracion de consulta
#OPCION NO. vuleve a preguntar con las opciones cargadas anteriormente
#OPCION CANCEL. Cancela la instalacion
#OPCION SI. instala la aplicacion
ConsultasDirectorios(){
	OP=""
	while [[ "${OP}" != "si"  &&  "${OP}" != "cancel" ]]
	    do		
		ConsultasAlUsuario
		mostrarEstructuraDeArchivos
		echo "${MENSAJECONSULTAINICIOINSTALACION}"
		./glog instalacion "${MENSAJEINSTALACIONCOMPLETARLOG}"
		read OPCION
		OP=${OPCION,,}
			while [[ ${OP} != "si"  &&  ${OP} != "no"  && ${OP} != "cancel" ]]
				do
					echo "ingreso una opcion incorrecta."
					echo "${MENSAJECONSULTAINICIOINSTALACION}"
					read OPCION
					OP=${OPCION,,}
				done
		done

}


MENSAJECREADONDIRECTORIOS="Creando Estructuras de directorio....."
#Creacion de Directorios
crearDirectoriosNoExistentes(){
	echo "${MENSAJECREADONDIRECTORIOS}"
	./glog instalacion "${MENSAJECREADONDIRECTORIOS}" 
	mkdir -p "${BINDIR}"
	mkdir -p "${MAESTROSDIR}"
	mkdir -p "${ARRIBOSDIR}"
	mkdir -p "${ACEPTADOSDIR}"
	mkdir -p "${RECHAZADOSDIR}"
	mkdir -p "${PROCESADOSDIR}"
	mkdir -p "${SALIDADIR}"	
}


#Mueve todos los archivos de un directorio($1), sin incluir sus subdirectorios, a otro directorio ($2)
moverArchivosDeDirectorio(){
	for arch in $(find $1 -maxdepth 1 -type f -printf '%P\n')
	do
		./mover "$1/$arch" "$2"	
	done
}


MENSAJEINSTALACIONENCURSO="Creando Estructuras de directorio....."
#Instalacion de la aplicacion
instalar(){
	mostrarHeader
	echo "${MENSAJEINSTALACIONENCURSO}"
	./glog instalacion "${MENSAJEINSTALACIONENCURSO}\n"
	echo ''

	mostrarEstructuraDeArchivos
	crearDirectoriosNoExistentes	
	moverArchivosDeDirectorio "${RUTAEJECUTABLES}" "${BINDIR}"
	moverArchivosDeDirectorio "${RUTAMAESTROS}" "${MAESTROSDIR}"
        moverArchivosDeDirectorio "${RUTAEJEMPLOS}" "${ARRIBOSDIR}"

	chmod +x "${BINDIR}/init.sh"
	chmod +x "${BINDIR}/proceso.sh"
	chmod +x "${BINDIR}/start"
	chmod +x "${BINDIR}/stop"

	actualizarConfiguracion
}

actualizarConfiguracion(){
	> "${ARCHIVOCONF}"		
	echo "GRUPODIR-$GRUPODIR-${USER}-$(date +%Y-%m-%d_%H:%M:%S)" >> "${ARCHIVOCONF}"
	echo "CONFDIR-$CONFDIR-${USER}-$(date +%Y-%m-%d_%H:%M:%S)" >> "${ARCHIVOCONF}"
	echo "LOGDIR-$LOGDIR-${USER}-$(date +%Y-%m-%d_%H:%M:%S)" >> "${ARCHIVOCONF}"
	echo "BINDIR-$BINDIR-${USER}-$(date +%Y-%m-%d_%H:%M:%S)" >> "${ARCHIVOCONF}"
	echo "MAESTROSDIR-$MAESTROSDIR-${USER}-$(date +%Y-%m-%d_%H:%M:%S)" >> "${ARCHIVOCONF}"
	echo "ARRIBOSDIR-$ARRIBOSDIR-${USER}-$(date +%Y-%m-%d_%H:%M:%S)" >> "${ARCHIVOCONF}"
	echo "ACEPTADOSDIR-$ACEPTADOSDIR-${USER}-$(date +%Y-%m-%d_%H:%M:%S)" >> "${ARCHIVOCONF}"
	echo "RECHAZADOSDIR-$RECHAZADOSDIR-${USER}-$(date +%Y-%m-%d_%H:%M:%S)" >> "${ARCHIVOCONF}"
	echo "PROCESADOSDIR-$PROCESADOSDIR-${USER}-$(date +%Y-%m-%d_%H:%M:%S)" >> "${ARCHIVOCONF}"
	echo "SALIDADIR-$SALIDADIR-${USER}-$(date +%Y-%m-%d_%H:%M:%S)" >> "${ARCHIVOCONF}"
}


#Utilizado por la funcion Verificar Instalacion
#Si el archivo de configuracion no tiene todos los directorios se considera corrupto.
leerArchivoConf(){
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
	SAVEIFS=$IFS
	IFS=$'\n'
	for registro  in `cat $ARCHIVOCONF`; do
		variable=`echo $registro | cut -d "-" -f1`
		valor=`echo $registro | cut -d "-" -f2`	
		export $variable=$valor	
	done;
	IFS=$SAVEIFS
	if [ ${#GRUPODIR} -eq 0 ] || [ ${#CONFDIR} -eq 0 ] || [ ${#LOGDIR} -eq 0 ] || [ ${#BINDIR} -eq 0 ] || [ ${#MAESTROSDIR} -eq 0 ] || [ ${#ARRIBOSDIR} -eq 0 ] || [ ${#ACEPTADOSDIR} -eq 0 ] || [ ${#RECHAZADOSDIR} -eq 0 ] || [ ${#PROCESADOSDIR} -eq 0 ] || [ ${#SALIDADIR} -eq 0 ]
		then
		echo "El archivo de configuracion estacorrupto o ha sido modificado"
		exit 1
		fi
}

#compara un directorio completo ($1), con otro($2) posiblemente inexistento o incompleto.
chequearFaltantes(){
	if [ ! -d "$2" ]; then
		#si no existe el otro dir, listo todo el primero
		echo "$1/"		
		mostarEstructuraDeArchivosYDirectorios "$1"
	else
		diff -r "$1" "$2"
		diff -r "$1" "$2" | ./glog instalacion "$1"
	fi
	echo ''
}


MENSAJEINSTALACIONCOMPLETA="Estado de la instalación: COMPLETA"
MENSAJEINSTALACIONCOMPLETALOG="Estado de la instalación: COMPLETA"
MENSAJEINSTALACIONINCOMPLETA="Estado de la instalación: INCOMPLETA"
MENSAJEINSTALACIONINCOMPLETALOG="Estado de la instalación: INCOMPLETA"
MENSAJEINSTALACIONFALTANTES="Componentes faltantes: "
MENSAJEINSTALACIONCOMPLETAR="Desea completar la instalación? (${GREEN}Si${NC} – ${RED}No${NC})"
MENSAJEINSTALACIONCOMPLETARLOG="Consulta si Desea completar la instalación?"
verificarInstalacionCompleta(){	
	leerArchivoConf
	mostrarEstructuraDeArchivos

 	declare local temp="$(chequearFaltantes "$RUTAEJECUTABLES" "$BINDIR")"
	if [ ${#temp} -gt 0 ]; then		
		echo -e "${MENSAJEINSTALACIONINCOMPLETA}"
		./glog instalacion "${MENSAJEINSTALACIONINCOMPLETALOG}"
		echo ''
		echo "${MENSAJEINSTALACIONFALTANTES}"
		./glog instalacion "${MENSAJEINSTALACIONFALTANTES}"
		echo 'Entrando'
		echo "${RUTAEJECUTABLES}"
		echo "${BINDIR}"
		chequearFaltantes "$RUTAEJECUTABLES" "$BINDIR"
		chequearFaltantes "$RUTAARCHIVOSMAESTROSYTABLAS" "$MAEDIR"	
		echo ''
		mostrarMSJreparacion			
		#confirmarCompletarInstalacion
	else
		temp="$(chequearFaltantes "$RUTAMAESTROS" "$MAESTROSDIR")"
		if [ ${#temp} -gt 0 ]; then
			echo -e "${MENSAJEINSTALACIONINCOMPLETA}"
			./glog instalacion "${MENSAJEINSTALACIONINCOMPLETALOG}"
			echo ''
			./glog instalacion "${MENSAJEINSTALACIONFALTANTES}"
			echo ''
			chequearFaltantes "$RUTAMAESTROS" "$MAESTROSDIR"	
			echo ''
			mostrarMSJreparacion
			#confirmarCompletarInstalacion
		else
			if  [ -d "${CONFDIR}" ] && [  -d "${LOGDIR}" ] && [ -d "${BINDIR}" ] && [  -d "${MAESTROSDIR}" ] && [ -d "${ACEPTADOSDIR}" ]  && [  -d "${RECHAZADOSDIR}" ] && [  -d "${PROCESADOSDIR}" ] && [  -d "${SALIDADIR}" ] 
				then
				echo -e "${MENSAJEINSTALACIONCOMPLETA}"
				./glog instalacion "${MENSAJEINSTALACIONCOMPLETALOG}"
				echo ''
				echo "${MENSAJEINSTALACIONCANCELADA}"
				./glog instalacion "${MENSAJEINSTALACIONCANCELADA}"
				echo ''
				#finalizarInstalacion
			else
				
				echo "Faltan directorios"				
				echo -e "${MENSAJEINSTALACIONINCOMPLETA}"
				./glog instalacion "${MENSAJEINSTALACIONINCOMPLETALOG}"
				echo ''
				mostrarMSJreparacion
			fi
		fi	
	fi
	actualizarConfiguracion
}


repararSistema(){
	echo "Reparar Sistema"
	if [ -f ${ARCHIVOCONF} ]
	   then
	   leerArchivoConf
	   mostrarEstructuraDeArchivos
	   #Crear los directorios que faltan
	   if [  ! -d "${LOGDIR}" ]
		then
	 	    mkdir "${LOGDIR}"
		fi 	
	   if [  ! -d "${ARRIBOSDIR}" ]
		then
	 	    mkdir "${ARRIBOSDIR}"
		fi
	   if [  ! -d "${ACEPTADOSDIR}" ]
		then
	 	    mkdir "${ACEPTADOSDIR}"
		fi 
           if [  ! -d "${RECHAZADOSDIR}" ]
		then
	 	    mkdir "${RECHAZADOSDIR}"
		fi 
           if [  ! -d "${SALIDADIR}" ]
		then
	 	    mkdir "${SALIDADIR}"
		fi 
           if [  ! -d "${PROCESADOSDIR}" ]
		then
	 	    mkdir "${PROCESADOSDIR}"
		fi 
	   rm -r "${BINDIR}"
	   rm -r "${MAESTROSDIR}"
	   mkdir "${BINDIR}"
	   mkdir "${MAESTROSDIR}"
	   moverArchivosDeDirectorio "${RUTAEJECUTABLES}" "${BINDIR}"
	   moverArchivosDeDirectorio "${RUTAMAESTROS}" "${MAESTROSDIR}"
	   actualizarConfiguracion
	else
	   echo "No existe el archivo de configuracion, no se puede reparar el sistema"
	fi
}


MENSAJEREPARACION="Usted puede si desea reparar el sistema utilizando el siguiente comando:"
MENSAJECOMANDOREPARACION="./instalacion.sh -r"

mostrarMSJreparacion(){
	echo "${MENSAJEREPARACION}"
	echo "${MENSAJECOMANDOREPARACION}"
	echo ""
}

showhelp(){
#./glog instalacion "Muestra de Ayuda - FUNC Showhelp"
clear
echo "Uso:    ./instalacion.sh"
echo "        ./instalacion.sh [OPTION]"
echo ""
echo "[OPTION]"
echo "	-h,--help:   muetra la presente ayuda."
echo "	-r,-repare:  repara el sistema."
echo "Sin opciones:  instala la aplicacion si aun no esta en el sistema,"
echo "               o verifica si esta bien instalada."
echo ""
}



#######################################################################################################
#				PROGRAMA PRINCIPAL				   
#######################################################################################################



#Verificar si se recibieron parametros.

if [ $# -eq 1 ]
	then
		case "$1" in
			-h|--help)
				showhelp
				;;
			-r|--repare)
				repararSistema
				;;
			*)
				echo "Argumento invalido..."
				showhelp
				;;
		esac
	else
		if [ $# -gt 1 ]
			then
			echo "Cantidad de Argumentos invalidos..."
			showhelp
		fi	
fi

if [ $# -eq 0 ]
then

	#No usar esta funcion cuando se descomprime el paquete.
	#CrearDirectoriosIniciales
	mostrarHeader
	echo 'Inicio de Ejecución de la Instalacion'
	./glog instalacion 'Inicio de Ejecución de la Instalacion'
	echo ''
	echo "Directorio predefinido de Configuración: ${CONFDIR}"
	./glog instalacion "Directorio predefinido de Configuración: ${CONFDIR}"
	echo ''
	echo "Directorio predefinido para los Log: ${ARCHIVOLOG}"
	./glog instalacion "Directorio predefinido para los Log: ${ARCHIVOLOG}"
	echo ''

	if [ -f ${ARCHIVOCONF} ]
	   then
	   	verificarInstalacionCompleta
   	else
		ConsultasDirectorios
		if [ ${OP} == "si" ]
			then
				instalar
			else
	 			echo "Cancelar instalacion"
				./glog instalacion "Cancelar Instalacion"
		fi
	fi
fi
