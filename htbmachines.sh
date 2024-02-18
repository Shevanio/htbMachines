#!/bin/bash
# Author: Shevanio

# Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
    echo -e "\n\n${redColour}[!] Saliendo...\n${endcolour}"
    tput cnorm && exit 1
}

# Ctrl+C 
trap ctrl_c INT

#Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
    echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios.${endColour}"
    echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por nombre de máquina.${endColour}"
    echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por dirección IP.${endColour}"
    echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por la dificultad de una máquina.${endColour}"
    echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por el Sistema Operativo.${endColour}"
    echo -e "\t${purpleColour}c)${endColour}${grayColour} Buscar por el nivel de certificación.${endColour}"
    echo -e "\t${purpleColour}s)${endColour}${grayColour} Buscar por alguna skill.${endColour}"
    echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener link de la resolución de la máquina en Youtube.${endColour}"
    echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda.${endColour}"
    exit 1
}

function updateFiles(){
    tput civis # Ocultar el cursor
    if [ ! -f bundle.js ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
        curl -s $main_url > bundle.js
        js-beautify bundle.js | sponge bundle.js
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados.${endColour}"
    else
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando si hay actualizaciones pendientes...${endColour}"
        curl -s $main_url > bundle_temp.js
        js-beautify bundle_temp.js | sponge bundle_temp.js
        md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
        md5_original_value=$(md5sum bundle.js | awk '{print $1}')
        
        if [ "$md5_temp_value" == "$md5_original_value" ]; then
            echo -e "\n${yellowColour}[+]${endColour}${grayColour} No se han detectado actualizaciones.${endColour}"
            rm bundle_temp.js
        else
            echo -e "\n${yellowColour}[+]${endColour}${grayColour} Se han detectado actualizaciones disponibles.${endColour}"
            sleep 1

            rm bundle.js && mv bundle_temp.js bundle.js
            echo -e "\n${yellowColour}[+]${endColour}${grayColour} Los archivos han sido actualizados.${endColour}"
        fi
    fi
    tput cnorm # Mostrar el cursor
}

function searchMachine(){
    machineName="$1"

    machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

    if [ "$machineName_checker" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la máquina${endColour}${purpleColour} $machineName${endColour}${grayColour}:${endColour}\n"
        cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
    else
        echo -e "\n${redColour}[!] La máquina proporcionada no existe.${endColour}\n"
    fi

    #cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
}

function searchIP(){
    ipAddress="$1"

    machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $2}' | tr -d '"' | tr -d ',')"
    
    if [ "$machineName" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} La máquina correspondiente para la IP ${endColour}${blueColour}$ipAddress${endColour}${grayColour} es ${endColour}${purpleColour}$machineName${endColour}${grayColour}.${endColour}\n"
    else
        echo -e "\n${redColour}[!] La IP proporcionada no existe.${endColour}\n"
    fi
}

function getYoutubeLink(){
    machineName="$1"

    youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk '{print $2}')"
    
    if [ "$youtubeLink" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Enlace de la máquina ${purpleColour}$machineName${endColour} resuelta: ${endColour}${blueColour}$youtubeLink${endColour}\n"
    else
        echo -e "\n${redColour}[!] La máquina proporcionada no existe.${endColour}\n"
    fi
}

function getDifficultymachines(){
    difficulty="$1"

    machinesDifficulty="$(cat bundle.js | grep -i "dificultad: \"$difficulty\"" -B5 | grep "name: " | awk '{print $2}' | tr -d '"' | tr -d ',' | column)"
    
    if [ "$machinesDifficulty" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas con dificultad ${blueColour}$difficulty${endColour} son: \n${endColour}${purpleColour}$machinesDifficulty${endColour}\n"

    else
        echo -e "\n${redColour}[!] La dificultad indicada no existe.${endColour}\n"
    fi
}

function getOSMachines(){
    os="$1"

    osMachines="$(cat bundle.js | grep -i "so: \"$os\"" -B 5 | grep "name: " | awk '{print $2}' | tr -d '"' | tr -d ',' |column)"
    
    if [ "$osMachines" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas con Sistema Operativo ${blueColour}$os${endColour}${grayColour} son: \n${endColour}${purpleColour}$osMachines${endColour}\n"
    else
        echo -e "\n${redColour}[!] El sistema operativo indicado no existe.${endColour}\n"
    fi
}


function getOSDifficultyMachines(){
    difficulty="$1"
    os="$2"

    osDifMachines="$(cat bundle.js | grep -i "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk '{print $2}' | tr -d '"' | tr -d ',' | column)"
    
    if [ "$osDifMachines" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas con Sistema Operativo ${endColour}${blueColour}$os${endColour}${grayColour} y con dificultad ${endColour}${blueColour}$difficulty${endColour}${grayColour} son: \n${endColour}${purpleColour}$osDifMachines${endColour}\n"
    else
        echo -e "\n${redColour}[!] No se encuentran máquinas con el sistema operativo y nivel de dificultad deseados.${endColour}\n"
    fi
}

function getCertMachines(){
    cert="$1"

    certMachines="$(cat bundle.js | grep -i "like: \"$cert\"" -B 8|grep name: | awk '{print $2}' | tr -d "\"" | tr -d "," | column)"
    
    if [ "$certMachines" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas con certificación ${endColour}${blueColour}$cert${endColour}${grayColour} son: \n${endColour}${purpleColour}$certMachines${endColour}\n"
    else
        echo -e "\n${redColour}[!] No se encuentran máquinas con los certificados deseados.${endColour}\n"
    fi
}

function getSkillMachines(){
    skill="$1"

    skillMachines="$(cat bundle.js | grep "skills: " -B 6| grep -i "$skill" -B 6 | grep "name: " | awk '{print $2}' | tr -d '"' | tr -d ',' | column)"
    
    if [ "$skillMachines" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas con la técnica ${endColour}${blueColour}$skill${endColour}${grayColour} son: \n${endColour}${purpleColour}$skillMachines${endColour}\n"
    else
        echo -e "\n${redColour}[!] No se encuentran máquinas con las habilidades deseadas.${endColour}\n"
    fi
}


# Indicadores
declare -i parameter_counter=0

# Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0


while getopts "m:ui:y:d:o:c:s:h" arg; do
    case $arg in
        m) machineName="$OPTARG"; let parameter_counter+=1;;
        u) let parameter_counter+=2;;
        i) ipAddress="$OPTARG"; let parameter_counter+=3;;
        y) machineName="$OPTARG"; let parameter_counter+=4;;
        d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
        o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
        c) cert="$OPTARG"; let parameter_counter+=7;;
        s) skill="$OPTARG"; let parameter_counter+=8;;
        h) helpPanel; let parameter_counter+=99;;
    esac
done

if [ $parameter_counter -eq 1 ]; then
    searchMachine "$machineName"
elif [ $parameter_counter -eq 2 ]; then
    updateFiles
elif [ $parameter_counter -eq 3 ]; then
    searchIP "$ipAddress"
elif [ $parameter_counter -eq 4 ]; then
    getYoutubeLink "$machineName"
elif [ $parameter_counter -eq 5 ]; then
    getDifficultymachines "$difficulty"
elif [ $parameter_counter -eq 6 ]; then
    getOSMachines "$os"
elif [ $parameter_counter -eq 7 ]; then
    getCertMachines "$cert"
elif [ $parameter_counter -eq 8 ]; then
    getSkillMachines "$skill"
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
    getOSDifficultyMachines $difficulty $os
elif [ $parameter_counter -eq 99 ]; then
  helpPanel
else
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Utiliza ${endColour}${purpleColour}-h${endColour}${grayColour} para el panel de ayuda.${endColour}"
fi