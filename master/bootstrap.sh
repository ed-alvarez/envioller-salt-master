#!/bin/bash

#
# This script bootstrap a new salt-master instance based on Ubuntu 20.04
#

function usage() {
    echo "Usage: $0 [production|staging]"
    exit 1;
}

function add_salt_to_etc_host() {
    if [ -n "$(grep salt /etc/hosts)" ]; then
        echo "salt entry already exists in /etc/hosts"
    else
        echo "Adding salt entry to /etc/hosts";
        sudo -- sh -c -e "echo '127.0.0.1 salt' >> /etc/hosts";

        if [ -n "$(grep salt /etc/hosts)" ]; then
            echo "salt entry was added succesfully";
        else
            echo "Failed to add salt entry to /etc/hosts";
            exit 1
        fi
    fi
}

if [ $# -ne 1 ]; then
    usage;
fi

environment=$1

if [ "$environment" != "production" ] && [ "$environment" != "staging" ]; then
    usage;
fi

metadata=$(curl -s http://169.254.169.254/latest/meta-data/iam/info)
if [ ! -n "$(echo $metadata | grep instance-profile/salt-master)" ]; then
    echo "ERROR: this instance needs the IAM role 'salt-master' attached"
    exit 1
fi

add_salt_to_etc_host

sudo apt install unzip

if [ ! -x /usr/local/bin/aws ]; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

wget -O - https://repo.saltstack.com/py3/ubuntu/20.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -

echo "deb http://repo.saltstack.com/py3/ubuntu/20.04/amd64/latest focal main" | sudo tee /etc/apt/sources.list.d/saltstack.list

sudo apt-get -y update
sudo apt-get -y install salt-minion
sudo apt-get -y install salt-master
sudo apt-get -y install jq

sudo apt -y install python3-pip
sudo pip3 install cherrypy
sudo apt-get -y install salt-api

if [ "$environment" == "production" ]; then
    minion_id="salt-master.eng.envio.systems"
    elif [ "$environment" == "staging" ]; then
    minion_id="salt-master-${environment}.eng.envio.systems"
fi

echo "$minion_id" | sudo tee /etc/salt/minion_id
sudo systemctl restart salt-minion

sudo salt-key -y -a $minion_id
sudo salt-key -L

# clone repository ------------------------------------------------------------

if [ ! -f ~/.ssh/id_rsa ]; then
    echo "creating ssh key ..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -C $minion_id -q -N ""
else
    echo "ssh key already exists"
fi

if [ ! -d ~/envio-devops-salt/srv ]; then
    cat ~/.ssh/id_rsa.pub
    read -n 1 -s -r -p "please register this ssh key as a deployment key in 'envio-devops-salt' repository and press any key to continue..."
    echo ""

    cd ~
    git clone git@github.com:enviosystems/envio-devops-salt.git

    if [ $? -ne 0 ]; then
        echo "I couldn't clone git repository"
        exit 1
    fi
else
    echo "~/envio-devops-salt already exists"
fi

# configure folders -----------------------------------------------------------

sudo rm -r /srv
sudo ln -s ~/envio-devops-salt/srv /srv

if [ ! -d ~/envio-devops-salt/master/master.d ]; then
    echo "ERROR: cannot copy master.d configuration"
    exit 1
else
    sudo cp -r ~/envio-devops-salt/master/master.d/*.conf /etc/salt/master.d
fi

# configuring API -------------------------------------------------------------

sudo mkdir -p  /etc/pki/tls/certs
sudo chmod 700 /etc/pki/tls/certs

if [ "$environment" == "production" ]; then
    minion_id_internal="salt-master-internal.eng.envio.systems"
    elif [ "$environment" == "staging" ]; then
    minion_id_internal="salt-master-${environment}-internal.eng.envio.systems"
fi

sudo openssl req -nodes -new -x509 \
-subj "/C=DE/ST=Berlin/L=Berlin/O=Enviosystems Security/OU=IT Department/CN=${minion_id_internal}" \
-addext "subjectAltName = DNS:${minion_id_internal}" \
-keyout /etc/pki/tls/certs/salt-api.key \
-out /etc/pki/tls/certs/salt-api.crt

sudo service salt-api restart

# configuring encryption ------------------------------------------------------

sudo mkdir -p   /etc/salt/gpgkeys
sudo chmod 0700 /etc/salt/gpgkeys

sudo echo 'homedir /etc/salt/gpgkeys' > ~/.gnupg

if [ ! -f ~/envio-devops-salt/master/gpg/pubkey.gpg ]; then
    echo "ERROR: cannot find '~/envio-devops-salt/master/gpg/pubkey.gpg'"
    exit 1
else
    sudo gpg --homedir /etc/salt/gpgkeys --import ~/envio-devops-salt/master/gpg/pubkey.gpg
    aws ssm get-parameter --with-decryption --name "salt.gpg.key" | jq -r ".Parameter.Value" | sudo gpg --homedir /etc/salt/gpgkeys --import -
fi

echo ""
echo "IMPORTANT: you need to change trust level of gpg keys as explained at https://docs.saltproject.io/en/latest/ref/renderers/all/salt.renderers.gpg.html"
echo "           gpg --homedir /etc/salt/gpgkeys --edit-key 11F58D6689402D78AE1815B705A27C50A0FAF17F"
echo "           Type trust to be able to set the trust level for the key and then select 5 (I trust ultimately). Then quit the shell by typing save."
echo "           Double check typing gpg --homedir /etc/salt/gpgkeys --list-keys"
echo "IMPORTANT: you need to set master role running: "\'"sudo salt ${minion_id} grains.set roles salt-master"\'
echo ""
