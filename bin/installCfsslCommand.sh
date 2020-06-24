#!/usr/bin/env bash
execCommand='cfssl'
jsonTools='cfssljson'
certinfoTools='cfssl-certinfo'


function installCfsslCommand () {
    if [ ! -f /usr/local/bin/$execCommand ];then
    	wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -O /usr/local/bin/${execCommand}
    fi

    if [ ! -f /usr/local/bin/$jsonTools ];then
    	wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -O /usr/local/bin/${jsonTools}
    fi

    if [ ! -f /usr/local/bin/$certinfoTools ];then
    	wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -O /usr/local/bin/${certinfoTools}
    fi
        chmod +x /usr/local/bin/cfssl*
}


function createSslPath () {

    [[ ! -d ssl ]] && mkdir ssl

}

function createJsonTemplate () {
    cd ssl/
    [[ ! -f ca-config.json ]] && cfssl print-defaults config > ca-config.json
    [[ ! -f ca-csr.json ]] && cfssl print-defaults csr > ca-csr.json

}

function main () {
    installCfsslCommand
    #createSslPath
    #createJsonTemplate
}
    main
