#!/bin/bash

# Script untuk mengunduh dan menjalankan installer Pterodactyl premium ZenCloud

echo "Mengunduh install.sh dari GitHub..."
wget -O install.sh https://raw.githubusercontent.com/ZenCloudID/install-private/main/install.sh

chmod u+x install.sh

echo "Loading..."
sleep 2

echo "Menjalankan Installer Premium ZenCloud..."
./install.sh
