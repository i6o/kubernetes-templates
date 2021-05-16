helpFunction()
{
   echo ""
   echo "Usage: $0 -r role"
   echo -e "\t-r Which role MASTER or BACKUP"
   exit 1 # Exit script after printing help
}

while getopts "r:" opt
do
   case "$opt" in
      r ) parameterRole="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterRole" ]
then
   echo "Required parameter is empty!";
   helpFunction
fi

sudo apt update
sudo apt -y upgrade
sudo apt -y install haproxy keepalived

# Append custom k8s hosts to /etc/hosts
grep -qFf ./hosts /etc/hosts
if [ $? -eq 1 ]
then
   cat ./hosts | sudo tee -a /etc/hosts > /dev/null
fi

# Read environment-variables
source ./env-variables

# MASTER | BACKUP
export STATE=$parameterRole
export INTERFACE=`ip r | grep default | cut -d " " -f5 -`
# from 100 to lower...
if ["$parameterRole" = "MASTER" ]
then
  export PRIORITY=100
else
  export PRIORITY=99
fi


sudo tee /etc/keepalived/check_apiserver.sh <<EOF
#!/bin/sh

errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

curl --silent --max-time 2 --insecure https://localhost:${APISERVER_DEST_PORT}/ -o /dev/null || errorExit "Error GET https://localhost:${APISERVER_DEST_PORT}/"
if ip addr | grep -q ${APISERVER_VIP}; then
    curl --silent --max-time 2 --insecure https://${APISERVER_VIP}:${APISERVER_DEST_PORT}/ -o /dev/null || errorExit "Error GET https://${APISERVER_VIP}:${APISERVER_DEST_PORT}/"
fi
EOF

sudo chmod a+x /etc/keepalived/check_apiserver.sh

sudo tee /etc/keepalived/keepalived.conf <<EOF
! /etc/keepalived/keepalived.conf
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL
}
vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3
  weight -2
  fall 10
  rise 2
}

vrrp_instance VI_1 {
    state ${STATE}
    interface ${INTERFACE}
    virtual_router_id ${ROUTER_ID}
    priority ${PRIORITY}
    authentication {
        auth_type PASS
        auth_pass ${AUTH_PASS}
    }
    virtual_ipaddress {
        ${APISERVER_VIP}
    }
    track_script {
        check_apiserver
    }
}
EOF


sudo tee /etc/haproxy/haproxy.cfg <<EOF
# /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 1
    timeout http-request    10s
    timeout queue           20s
    timeout connect         5s
    timeout client          20s
    timeout server          20s
    timeout http-keep-alive 10s
    timeout check           10s

#---------------------------------------------------------------------
# apiserver frontend which proxys to the masters
#---------------------------------------------------------------------
frontend apiserver
    bind *:${APISERVER_DEST_PORT}
    mode tcp
    option tcplog
    default_backend apiserver

#---------------------------------------------------------------------
# round robin balancing for apiserver
#---------------------------------------------------------------------
backend apiserver
    option httpchk GET /healthz
    http-check expect status 200
    mode tcp
    option ssl-hello-chk
    balance     roundrobin
        server ${HOST1_ID} ${HOST1_ADDRESS}:${APISERVER_DEST_PORT} check
        server ${HOST2_ID} ${HOST2_ADDRESS}:${APISERVER_DEST_PORT} check
        server ${HOST3_ID} ${HOST3_ADDRESS}:${APISERVER_DEST_PORT} check

EOF

sudo systemctl enable haproxy --now
sudo systemctl enable keepalived --now

sudo systemctl restart haproxy
sudo systemctl restart keepalived

