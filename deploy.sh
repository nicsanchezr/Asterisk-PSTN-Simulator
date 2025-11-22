#!/bin/bash
# Script de despliegue para Simulador PSTN (Asterisk 20 en Rocky Linux 9)

echo "--- [1/6] Preparando repositorios ---"
dnf update -y
dnf install epel-release wget vim nano 'dnf-command(config-manager)' -y

# Instalar Repositorio Tucny
cd /etc/yum.repos.d
wget https://ast.tucny.com/repo/tucny-asterisk-el9.repo
rpm --import https://ast.tucny.com/repo/RPM-GPG-KEY-tucnyastrepo

# ACTIVAR REPOSITORIOS ESPECÍFICOS (Asterisk 20 y Common)
echo "Activando repositorios asterisk-20 y asterisk-common..."
dnf config-manager --set-enabled asterisk-common
dnf config-manager --set-enabled asterisk-20

echo "--- [2/6] Instalando Paquetes Específicos ---"
# Lista exacta solicitada
dnf install asterisk-core asterisk-configs asterisk-odbc asterisk-sounds-core-en-alaw asterisk-sip asterisk-pjsip dahdi-linux libpri -y

echo "--- [3/6] Configurando Firewalld ---"
dnf install firewalld -y
systemctl enable --now firewalld
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-port=5060/udp
firewall-cmd --permanent --add-port=10000-20000/udp
firewall-cmd --reload

echo "--- [4/6] Instalando Fail2Ban ---"
dnf install fail2ban -y
systemctl enable --now fail2ban
# Restaurar configuración de Fail2Ban si existe en el backup
if [ -f "etc_fail2ban/jail.local" ]; then
    cp etc_fail2ban/jail.local /etc/fail2ban/
fi
systemctl restart fail2ban

echo "--- [5/6] Restaurando Configuraciones y Habilitando chan_sip ---"
# Restaurar archivos de configuración del backup
cp -r etc_asterisk/* /etc/asterisk/

# HABILITAR CHAN_SIP (Asterisk 20 lo trae deshabilitado por defecto)
# Buscamos la línea 'noload => chan_sip.so' y le ponemos un ; al principio
echo "Modificando modules.conf para habilitar chan_sip..."
sed -i 's/noload => chan_sip.so/;noload => chan_sip.so/g' /etc/asterisk/modules.conf

# Asegurar permisos
chown -R asterisk:asterisk /etc/asterisk/
chmod 750 /etc/asterisk/
mkdir -p /var/lib/asterisk/sounds/custom
chown -R asterisk:asterisk /var/lib/asterisk/

echo "--- [6/6] Iniciando Servicios ---"
systemctl enable --now asterisk
systemctl restart asterisk

echo "--- ¡Despliegue Completado! ---"
echo "Versión instalada:"
asterisk -rx "core show version"
echo "Estado de chan_sip (debe aparecer cargado):"
asterisk -rx "module show like chan_sip"
