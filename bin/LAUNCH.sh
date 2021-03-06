#!/bin/bash

GREEN="\\033[1;32m"
DEFAULT="\\033[0;39m"
RED="\\033[1;31m"
ROSE="\\033[1;35m"
BLUE="\\033[1;34m"
WHITE="\\033[0;02m"
YELLOW="\\033[1;33m"
CYAN="\\033[1;36m"

[ -z "$AIL_HOME" ] && echo "Needs the env var AIL_HOME. Run the script from the virtual environment." && exit 1;
[ -z "$AIL_REDIS" ] && echo "Needs the env var AIL_REDIS. Run the script from the virtual environment." && exit 1;
[ -z "$AIL_ARDB" ] && echo "Needs the env var AIL_ARDB. Run the script from the virtual environment." && exit 1;

export PATH=$AIL_HOME:$PATH
export PATH=$AIL_REDIS:$PATH
export PATH=$AIL_ARDB:$PATH

function helptext {
    echo -e $YELLOW"

              .o.            ooooo      ooooo
             .888.           \`888'      \`888'
            .8\"888.           888        888
           .8' \`888.          888        888
          .88ooo8888.         888        888
         .8'     \`888.        888        888       o
        o88o     o8888o   o  o888o   o  o888ooooood8

         Analysis Information Leak framework
    "$DEFAULT"
    This script launch:
    "$CYAN"
    - All the ZMQ queuing modules.
    - All the ZMQ processing modules.
    - All Redis in memory servers.
    - All Level-DB on disk servers.
    "$DEFAULT"
    (Inside screen Daemons)
    "$RED"
    But first of all you'll need to edit few path where you installed
    your redis & ardb servers.
    "$DEFAULT"
    Usage:
    -----
    "
}

function launching_redis {
    conf_dir="${AIL_HOME}/configs/"

    screen -dmS "Redis_AIL"
    sleep 0.1
    echo -e $GREEN"\t* Launching Redis servers"$DEFAULT
    screen -S "Redis_AIL" -X screen -t "6379" bash -c 'redis-server '$conf_dir'6379.conf ; read x'
    sleep 0.1
    screen -S "Redis_AIL" -X screen -t "6380" bash -c 'redis-server '$conf_dir'6380.conf ; read x'
    sleep 0.1
    screen -S "Redis_AIL" -X screen -t "6381" bash -c 'redis-server '$conf_dir'6381.conf ; read x'
}

function launching_ardb {
    conf_dir="${AIL_HOME}/configs/"

    screen -dmS "ARDB_AIL"
    sleep 0.1
    echo -e $GREEN"\t* Launching ARDB servers"$DEFAULT

    sleep 0.1
    screen -S "ARDB_AIL" -X screen -t "6382" bash -c 'ardb-server '$conf_dir'6382.conf ; read x'
}

function launching_logs {
    screen -dmS "Logging_AIL"
    sleep 0.1
    echo -e $GREEN"\t* Launching logging process"$DEFAULT
    screen -S "Logging_AIL" -X screen -t "LogQueue" bash -c 'log_subscriber -p 6380 -c Queuing -l ../logs/; read x'
    sleep 0.1
    screen -S "Logging_AIL" -X screen -t "LogScript" bash -c 'log_subscriber -p 6380 -c Script -l ../logs/; read x'
}

function launching_queues {
    screen -dmS "Queue_AIL"
    sleep 0.1

    echo -e $GREEN"\t* Launching all the queues"$DEFAULT
    screen -S "Queue_AIL" -X screen -t "Queues" bash -c 'python3 launch_queues.py; read x'
}

function launching_scripts {
    echo -e "\t* Checking configuration"
    bash -c "python3 Update-conf.py"
    exitStatus=$?
    if [ $exitStatus -ge 1 ]; then
        echo -e $RED"\t* Configuration not up-to-date"$DEFAULT
        exit
    fi
    echo -e $GREEN"\t* Configuration up-to-date"$DEFAULT

    screen -dmS "Script_AIL"
    sleep 0.1
    echo -e $GREEN"\t* Launching ZMQ scripts"$DEFAULT

    screen -S "Script_AIL" -X screen -t "ModuleInformation" bash -c './ModulesInformationV2.py -k 0 -c 1; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Mixer" bash -c './Mixer.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Global" bash -c './Global.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Duplicates" bash -c './Duplicates.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Lines" bash -c './Lines.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "DomClassifier" bash -c './DomClassifier.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Categ" bash -c './Categ.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Tokenize" bash -c './Tokenize.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "CreditCards" bash -c './CreditCards.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Onion" bash -c './Onion.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Mail" bash -c './Mail.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "ApiKey" bash -c './ApiKey.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Web" bash -c './Web.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Credential" bash -c './Credential.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Curve" bash -c './Curve.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "CurveManageTopSets" bash -c './CurveManageTopSets.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "RegexForTermsFrequency" bash -c './RegexForTermsFrequency.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "SetForTermsFrequency" bash -c './SetForTermsFrequency.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Indexer" bash -c './Indexer.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Keys" bash -c './Keys.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Base64" bash -c './Base64.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Bitcoin" bash -c './Bitcoin.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Phone" bash -c './Phone.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Release" bash -c './Release.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "Cve" bash -c './Cve.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "WebStats" bash -c './WebStats.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "ModuleStats" bash -c './ModuleStats.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "SQLInjectionDetection" bash -c './SQLInjectionDetection.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "alertHandler" bash -c './alertHandler.py; read x'
    sleep 0.1
    screen -S "Script_AIL" -X screen -t "SentimentAnalysis" bash -c './SentimentAnalysis.py; read x'

}

function shutting_down_redis {
    redis_dir=${AIL_HOME}/redis/src/
    bash -c $redis_dir'redis-cli -p 6379 SHUTDOWN'
    sleep 0.1
    bash -c $redis_dir'redis-cli -p 6380 SHUTDOWN'
    sleep 0.1
    bash -c $redis_dir'redis-cli -p 6381 SHUTDOWN'
}

function shutting_down_ardb {
    redis_dir=${AIL_HOME}/redis/src/
    bash -c $redis_dir'redis-cli -p 6382 SHUTDOWN'
}

function checking_redis {
    flag_redis=0
    redis_dir=${AIL_HOME}/redis/src/
    bash -c $redis_dir'redis-cli -p 6379 PING | grep "PONG" &> /dev/null'
    if [ ! $? == 0 ]; then
       echo -e $RED"\t6379 not ready"$DEFAULT
       flag_redis=1
    fi
    sleep 0.1
    bash -c $redis_dir'redis-cli -p 6380 PING | grep "PONG" &> /dev/null'
    if [ ! $? == 0 ]; then
       echo -e $RED"\t6380 not ready"$DEFAULT
       flag_redis=1
    fi
    sleep 0.1
    bash -c $redis_dir'redis-cli -p 6381 PING | grep "PONG" &> /dev/null'
    if [ ! $? == 0 ]; then
       echo -e $RED"\t6381 not ready"$DEFAULT
       flag_redis=1
    fi
    sleep 0.1

    return $flag_redis;
}

function checking_ardb {
    flag_ardb=0
    redis_dir=${AIL_HOME}/redis/src/
    sleep 0.2
    bash -c $redis_dir'redis-cli -p 6382 PING | grep "PONG" &> /dev/null'
    if [ ! $? == 0 ]; then
       echo -e $RED"\t6382 not ready"$DEFAULT
       flag_ardb=1
    fi

    return $flag_ardb;
}

#If no params, display the help
#[[ $@ ]] || { helptext; exit 1;}

helptext;

############### TESTS ###################
isredis=`screen -ls | egrep '[0-9]+.Redis_AIL' | cut -d. -f1`
isardb=`screen -ls | egrep '[0-9]+.ARDB_AIL' | cut -d. -f1`
islogged=`screen -ls | egrep '[0-9]+.Logging_AIL' | cut -d. -f1`
isqueued=`screen -ls | egrep '[0-9]+.Queue_AIL' | cut -d. -f1`
isscripted=`screen -ls | egrep '[0-9]+.Script_AIL' | cut -d. -f1`

options=("Redis" "Ardb" "Logs" "Queues" "Scripts" "Killall" "Shutdown" "Update-config")

menu() {
    echo "What do you want to Launch?:"
    for i in ${!options[@]}; do
        printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${options[i]}"
    done
    [[ "$msg" ]] && echo "$msg"; :
}

prompt="Check an option (again to uncheck, ENTER when done): "
while menu && read -rp "$prompt" numinput && [[ "$numinput" ]]; do
    for num in $numinput; do
        [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#options[@]} )) || {
            msg="Invalid option: $num"; break
        }
        ((num--)); msg="${options[num]} was ${choices[num]:+un}checked"
        [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
    done
done

for i in ${!options[@]}; do
    if [[ "${choices[i]}" ]]; then
        case ${options[i]} in
            Redis)
                if [[ ! $isredis ]]; then
                    launching_redis;
                else
                    echo -e $RED"\t* A screen is already launched"$DEFAULT
                fi
                ;;
            Ardb)
                if [[ ! $isardb ]]; then
                    launching_ardb;
                else
                    echo -e $RED"\t* A screen is already launched"$DEFAULT
                fi
                ;;
            Logs)
                if [[ ! $islogged ]]; then
                    launching_logs;
                else
                    echo -e $RED"\t* A screen is already launched"$DEFAULT
                fi
                ;;
            Queues)
                if [[ ! $isqueued ]]; then
                    launching_queues;
                else
                    echo -e $RED"\t* A screen is already launched"$DEFAULT
                fi
                ;;
            Scripts)
                if [[ ! $isscripted ]]; then
                  sleep 1
                    if checking_redis && checking_ardb; then
                        launching_scripts;
                    else
                        echo -e $YELLOW"\tScript not started, waiting 5 secondes"$DEFAULT
                        sleep 5
                        if checking_redis && checking_ardb; then
                            launching_scripts;
                        else
                            echo -e $RED"\tScript not started"$DEFAULT
                        fi;
                    fi;
                else
                    echo -e $RED"\t* A screen is already launched"$DEFAULT
                fi
                ;;
            Killall)
                if [[ $isredis || $isardb || $islogged || $isqueued || $isscripted ]]; then
                    echo -e $GREEN"Gracefully closing redis servers"$DEFAULT
                    shutting_down_redis;
                    sleep 0.2
                    echo -e $GREEN"Gracefully closing ardb servers"$DEFAULT
                    shutting_down_ardb;
                    echo -e $GREEN"Killing all"$DEFAULT
                    kill $isredis $isardb $islogged $isqueued $isscripted
                    sleep 0.2
                    echo -e $ROSE`screen -ls`$DEFAULT
                    echo -e $GREEN"\t* $isredis $isardb $islogged $isqueued $isscripted killed."$DEFAULT
                else
                    echo -e $RED"\t* No screen to kill"$DEFAULT
                fi
                ;;
            Shutdown)
                bash -c "./Shutdown.py"
                ;;
            Update-config)
                echo -e "\t* Checking configuration"
                bash -c "./Update-conf.py"
                exitStatus=$?
                if [ $exitStatus -ge 1 ]; then
                    echo -e $RED"\t* Configuration not up-to-date"$DEFAULT
                    exit
                else
                    echo -e $GREEN"\t* Configuration up-to-date"$DEFAULT
                fi
                ;;
        esac
    fi
done
