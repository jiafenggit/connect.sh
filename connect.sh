#!/bin/sh

[ -z "$CONNJSON" ] && _BJSON=$HOME/Documents/ssh/json.sh || _BJSON=$CONNJSON
[ -z "$CONNCFG" ] && _C_CFG=$HOME/Documents/ssh/conn.profile || _C_CFG=$CONNCFG
if [ ! -f $_C_CFG ]; then
    echo "not fount profile file $_C_CFG"
    exit 0
fi

source $_BJSON

function connect() {
    name=$1
    config=`json < $_C_CFG | grep $name`
    row=`json < $_C_CFG | grep $name | wc -l`
    if [ $row -gt 7 ]; then
        echo "fount to many configs\n$config\n"
        exit 0
    fi

    connhost=`json < $_C_CFG | grep $name | grep "host" | grep -v grep | awk '{print \$3}'`
    if [ -z $connhost ]; then
        echo error:  没有那个IP
        exit 0
    fi
    connport=`json < $_C_CFG | grep $name | grep "port" | grep -v grep | awk '{print \$3}'`
    connuser=`json < $_C_CFG | grep $name | grep "user" | grep -v grep | awk '{print \$3}'`
    connpass=`json < $_C_CFG | grep $name | grep "pass" | grep -v grep | awk '{print \$3}'`
    connlang=`json < $_C_CFG | grep $name | grep "lang" | grep -v grep | awk '{print \$3}'`
    conntype=`json < $_C_CFG | grep $name | grep "conn" | grep -v grep | awk '{print \$3}'`
    conntssh=`json < $_C_CFG | grep $name | grep "ssht" | grep -v grep | awk '{print \$3}'`

    [ -z "$connport" ] && connport=22
    [ -z "$connuser" ] && connuser='root'
    [ -z "$connpass" ] && connpass='123456'
    [ -z "$connlang" ] && connlang='None'
    [ -z "$conntype" ] && conntype='ssh'
    [ -z "$conntssh" ] && conntssh='pass'

    if [ "$connlang" != "None" ]; then
        locallang=$LANG
        locallcall=$LC_ALL
        export LANG=$connlang
        export LC_ALL=$connlang
    fi

    if [ "$conntype" == "ssh" ]; then
        connstr="spawn ssh -p${connport} ${connuser}@${connhost}
                 expect {
                        \"*(yes/no)*\" { send \"yes\n\"; exp_continue }
                    -re \"assword:|assw\" { send \"${connpass}\n\" }
                 }"
        if [ "$conntssh" != "pass" ]; then
            connstr="spawn ssh -p${connport} ${connuser}@${connhost} -i${conntssh}
                     expect {
                            \"*(yes/no)*\" { send \"yes\n\" }
                        -re \">|]|$|#\" { send \"\n\" }
                     }"
        fi
        expect -c "
                set timeout 10000
                stty -echo
                ${connstr}

                if { \"${connlang}\" != \"None\" } {
                    expect {
                        -re \">|]|$|#\" { send \"export LANG=${connlang} && export LC_ALL=${connlang}\n\" }
                    }
                }
                interact 
                  "
    elif [ "$conntype" == "telnet" ]; then
        echo $connlang
        expect -c "
                set timeout 10000
                stty -echo
                spawn telnet ${connhost} ${connport}
                expect {
                        \"*(yes/no)*\" { send \"yes\n\"; exp_continue }
                        \"*ogin*\" { send \"${connuser}\n\"; exp_continue }
                    -re \"assword:|assw\" { send \"${connpass}\n\" }
                }

                if { \"${connlang}\" != \"None\" } {
                    expect {
                        -re \">|]|$|#\" { send \"export LANG=${connlang} && export LC_ALL=${connlang}\n\" }
                    }
                }
                interact 
                  "
    fi

    if [ "$connlang" != "None" ]; then
        locallang=$LANG
        locallcall=$LC_ALL
        export LANG=$locallang
        export LC_ALL=$locallcall
    fi
}

function showconn() {
    json < $_C_CFG | grep $1 | awk '{printf("%-25s\t%s\n", $1, $3)}'
}

case "$1" in 
    show)
        showconn $2
        ;;
    help)
        echo "$0 onename\n$0 show onename" >&2
        ;;
    *)
        connect $1
        ;;
esac

exit 0


