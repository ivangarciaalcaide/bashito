#!/bin/bash

# COMMON_FUNCTIONS v1.0.0

# Comprueba el puerto 445 y hace un ping a la máquina.
#   Dependiendo del resultado, determina si detrás hay:
#   - un Windows encendido (responde el puerto 445),
#   - un GNU/Linux encendido (no responde el 445 pero sí el ping)
#   - nada, la maquina está apagada (no responde a ninguno).
#
# Variables de entrada:
#
#   $MAQUINA --> Donde espera encontrar el FQDN o la IP.
#
# Valores devueltos:
#
#   0       --> Apagada
#   1       --> Windows
#   2       --> GNU/Linux
#   [Otro]  --> Mensaje de error
#
# Ejemplos de llamada:
#
#   RESULTADO=$(check_os 192.168.1.1)
#   RESULTADO=$(check_os www.google.es)
#
function check_os() {
    local MAQUINA=$1
    local RESULTADO=0

    if [ -z $MAQUINA ]; then
            local RESULTADO="No se ha recibido el parámetro MAQUINA, está vacio."
    else
        # Netcat -z sólo escanea un puerto y devuelve:
        #    0: si lo encuentra abierto.
        #    1: si falla.
        # El puerto 445 en Windows está abierto por defecto para
        #    comunicaciones con Exchange Server. A no ser que se cape
        #    a drede en el firewall, estará abierto.
        nc -z -w 1 $MAQUINA 445 &> /dev/null
        if [[ $? -eq 0 ]]; then
                local RESULTADO=1
            else
                # La ejecución de 'ping' devuelve:
                #    0: Si recibe pong (la máquina is alive).
                #    1: Si existe la máquina pero no contesta.
                #    2: Si el host no existe.
                ping -c 1 -W 1 $MAQUINA &> /dev/null
                if [[ $? -eq 0 ]]; then
                    local RESULTADO=2
                fi
        fi
    fi        
    
    echo $RESULTADO
}


# Comprueba si una máquina Windows está encendida o apagada.
#
# Variables de entrada:
#   $MAQUINA --> Donde espera encontrar el FQDN o la IP.
#
# Valores devueltos:
#   0       --> Apagada
#   1       --> Encendida
#   [Otro]  --> Mensaje de error
#
# Ejemplos de llamada:
#
#   RESULTADO=$(is_on_windows 192.168.1.1)
#   RESULTADO=$(is_on_windows www.google.es)
#
function is_on_windows() {
    local MAQUINA=$1
    local RESULTADO=0

    if [ -z $MAQUINA ]; then
        local RESULTADO="No se ha recibido el parámetro MAQUINA, está vacio."
    else
        # Netcat -z sólo escanea un puerto y devuelve:
        #    0: si lo encuentra abierto.
        #    1: si falla.
        # El puerto 445 en Windows está abierto por defecto para
        #    comunicaciones con Exchange Server. A no ser que se cape
        #    a drede en el firewall, estará abierto.
        nc -z -w 1 $MAQUINA 445 &> /dev/null
        if [[ $? -eq 0 ]]; then
            local RESULTADO=1
        fi
    fi        
    
    echo $RESULTADO   
}

# Comprueba si una máquina Linux está encendida o apagada.
#
# Variables de entrada:
#   $MAQUINA --> Donde espera encontrar el FQDN o la IP.
#
# Valores devueltos:
#   0       --> Apagada
#   1       --> Encendida
#   [Otro]  --> Mensaje de error
#
# Ejemplos de llamada:
#
#   RESULTADO=$(is_on_linux 192.168.1.1)
#   RESULTADO=$(is_on_linux www.google.es)
#
function is_on_linux() {
    local MAQUINA=$1
    local RESULTADO=0

    if [ -z $MAQUINA ]; then
        local RESULTADO="No se ha recibido el parámetro MAQUINA, está vacio."
    else
        # Netcat -z sólo escanea un puerto y devuelve:
        #    0: si lo encuentra abierto.
        #    1: si falla.
        # El puerto 22 en Windows está cerrado por defecto y en linux se 
        #    usa para ssh.
        nc -z -w 1 $MAQUINA 22 &> /dev/null
        if [[ $? -eq 0 ]]; then
            local RESULTADO=1
        fi
    fi        
    
    echo $RESULTADO   
}

# Recoge y procesa los argumentos para grupo y perfil y devuelve un array $MAQUINAS.
#
# El script principal debe asignar un valor correcto a la variable '$DIR_DATA' que contenga
#	una cadena con la ruta al directorio donde se encuentren los ficheros de datos.
#	Asimismo, el script principal ha de recoger los valores de los argumentos -g y -p (--group
# 	y --profile) y ponerlos en las variables GRUPO y PERFIL siendo estas arrays. El
#	código que recoge estas variables debe ser parecido a este:
#
#		[...]
#
#		-g|--group)
#			if [[ -n $2 && $2 == -* ]]; then
#				printf "\nArgumento GRUPO sin valor.\n\n"
#				exit 1
#			else
#				GRUPO=($2)
#			fi
#			shift 2
#			;;
#
#		[...]
#
#		-p|--profile)
#			if [[ -n $2 && $2 == -* ]]; then
#				printf "\nArgumento PERFIL sin valor.\n\n"
#				exit 1
#			else
#				PERFIL=($2)
#			fi
#			shift 2
#			;;
#
#		[...]
#
function getMaquinas() {
	# GRUPO puede ser all o algún grupo que exista (que haya un fichero
	#	cuyo nombre empiece por lo indicado).
	#
	#	('test -z' --> True, si la cadena está vacía).
	if [[ -z $GRUPO ]]; then
		printf "\nERROR: No se ha indicado ningún grupo.\n"
		exit 1
	fi

	# Lo mismo para perfil.
	if [[ -z $PERFIL ]]; then
		printf "\nERROR: No se ha indicado ningún perfil.\n"
		exit 1
	fi

	# Si se seleccionan todos los grupos, se recoge el nombre de todos
	#	los ficheros de datos y los pone en el array GRUPOS.
	if [[ $GRUPO == "all" ]]; then
		# Con los paréntesis se dice que se quiere una variable de tipo 
		#	array, y lo carga con cada elemento que encuentra al ejecutar
		#	el 'ls' del directorio de datos. Puede haber elementos 
		#	repetidos en caso de que un grupo tenga más de una 
		#	configuración (ya que se traduce en varios ficheros que 
		#	comienzan por el nombre del grupo)
		GRUPO=($(ls $DIR_DATA /dev/null))
		GRUPO=(${GRUPO[@]%%.*})
	fi

	# Por si hay grupos o perfiles repetidos, los quitamos
	eval GRUPO=($(printf "%q\n" "${GRUPO[@]}" | sort -u))
	eval PERFIL=($(printf "%q\n" "${PERFIL[@]}" | sort -u))

		# Para cada grupo de máquinas recogido...
	for g in ${GRUPO[@]}; do
		# Se guardan los ficheros de datos referentes a un grupo.
		FICHEROS=($(ls $DIR_DATA/$g.*.info 2> /dev/null))
		# Si se han encontrado ficheros para este grupo, se muestra menasaje
		#	y se continua, si no, se dice que no hay ficehros para ese grupo
		#	y se pasa al siguiente.
		if [[ -n $FICHEROS ]]; then
			echo ""
			printf "Recogiendo máquinas del grupo: $g." | boxes -d simple
			# Por cada fichero para ese grupo, es decir, para cada configuración
			#	posible para ese grupo...
			for f in ${FICHEROS[@]}; do
				if [[ -z "${f##*.win*.info}" ]]; then
					SO=WINDOWS
				else
					SO=GNU/LINUX
				fi
				printf "\nEncontrado fichero '$(basename $f)' para sistema $SO.\n\n"

				# Para cada perfil indicado...
				for p in ${PERFIL[@]}; do
					MSG="Máquinas encontradas"

					# Si se quieren todos los perfiles, awk saca todos los
					#	nombres de máquina que haya en el fichero. Pero si se ha
					#	indicado algún perfil concreto, solo saca los FQDN de las
					#	máquinas que coincidan.
					#	'-v perf=$p' recoge el valor de $p y lo pone en una variable
					#	que se llame 'perf' y que pueda usar awk.
					#	'$6 ~ perf' dice que si el campo 6 (el ID de la máquina) comienza
					#		por lo que contenga la variable 'perf', saca el campo 1 (FQDN).
					if [[ ${p,,} == "all" ]]; then
						AUX=($(awk '$1 != "#" { print $1 }' $f))
						MSG+=" de uno o varios perfiles: "
					else
						AUX=($(awk -v perf=$p '$6 ~ perf { print $1 }' $f))
						MSG+=" del perfil $p: "
					fi
					MAQUINAS+=(${AUX[*]})
					if [[ ${#AUX[@]} -eq 0 ]]; then
						MSG+=NINGUNA
					fi
					MSG+=$(printf "%s, " "${AUX[@]%%.*}")
					echo "${MSG%,*}." | fold -s -w $(tput cols)
				done
			done
		else
			printf "\nEl grupo %s no existe o no se puedo leer.\n" $g
			exit 1
		fi

		# Se quitan las máquinas repetidas
		eval MAQUINAS=($(printf "%q\n" "${MAQUINAS[@]}" | sort -u))
	done

}
