#!/bin/bash


    for l in `ls ca*.pem`
    do
        cp $l ${l%%.pem}.crt
    
    done
    
    for j in `ls server*.pem`
    do
        cp ${j} ${j%%.pem}.crt
    done
    
    
    for k in `ls peer*.pem`
    do
        cp $k ${k%%.pem}.crt
    done
    
    for h in `ls client*.pem`
    do
        cp $h ${h%%.pem}.crt
    done
