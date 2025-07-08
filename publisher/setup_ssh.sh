#!/bin/bash

echo "[*] Esperando que Stratum0 esté disponible..."
until ping -c1 stratum0 &>/dev/null; do sleep 1; done

echo "[*] Generando claves SSH..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""
fi

echo "[*] Aceptando clave host de Stratum0..."
#ssh-keyscan -H stratum0 >> ~/.ssh/known_hosts
ssh-keygen -R stratum0 2>/dev/null
ssh-keyscan -H stratum0 >> ~/.ssh/known_hosts

echo "[*] Enviando clave pública a Stratum0..."
for i in {1..10}; do
    sshpass -p stratum ssh-copy-id -o StrictHostKeyChecking=no stratum@stratum0 && break
    echo "Esperando acceso SSH... intento $i"
    sleep 2
done

echo "[*] Acceso configurado. Probando SSH:"
ssh stratum@stratum0 hostname

echo "[*] Esperando indefinidamente para mantener el contenedor activo..."
tail -f /dev/null
