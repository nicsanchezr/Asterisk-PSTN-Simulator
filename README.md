# 📞 Asterisk PSTN Simulator (Rocky Linux 9 / Asterisk 20)

Este repositorio contiene la configuración de infraestructura para un servidor de simulación PSTN utilizado en entornos educativos y laboratorios de VoIP.

El sistema simula una **Red Telefónica Pública Conmutada** para interconectar múltiples PBX (sedes de alumnos) mediante troncales SIP, gestionando el enrutamiento de DIDs simulados.

---

## ⚙️ Especificaciones Técnicas

* **Sistema Operativo:** Rocky Linux 9.6 (Compatible con BlueOnyx)
* **Motor de Telefonía:** Asterisk 20.15 (Repositorio Tucny)
* **Drivers:**
    * `PJSIP` (Estándar actual)
    * `chan_sip` (Legacy - Habilitado explícitamente para compatibilidad)
* **Seguridad:**
    * `Firewalld` (Puertos SIP/RTP/SSH)
    * `Fail2Ban` (Protección contra fuerza bruta)

---

## 📦 Paquetes Requeridos

El script de despliegue se encarga de instalar automáticamente las siguientes dependencias y paquetes de Asterisk:

    asterisk-core
    asterisk-configs
    asterisk-odbc
    asterisk-sounds-core-en-alaw
    asterisk-sip
    asterisk-pjsip
    dahdi-linux
    libpri

---

## 🚀 Instalación Automatizada

Para desplegar este simulador en un servidor **Rocky Linux 9 limpio**:

### 1. Clonar el Repositorio

    git clone https://github.com/nicsanchezr/Asterisk-PSTN-Simulator.git
    cd Asterisk-PSTN-Simulator

### 2. Ejecutar Script de Despliegue
Da permisos de ejecución y lanza el instalador automatizado:

    chmod +x deploy.sh
    ./deploy.sh

### 3. Post-Instalación (Manual)
Por seguridad, las contraseñas de los troncales han sido sanitizadas en el archivo de respaldo. Debes editar el archivo de configuración SIP para establecer las credenciales reales:

    vim /etc/asterisk/sip.conf
    # Buscar 'secret=CHANGE_ME_PASSWORD' y actualizar con las claves reales

Luego, recarga la configuración SIP para aplicar los cambios:

    asterisk -rx "sip reload"

---

## 🔧 Notas sobre Asterisk 20 y chan_sip

La versión 20 de Asterisk marca el controlador `chan_sip` como obsoleto (deprecated) y, por defecto, no lo carga.

Para garantizar la funcionalidad del simulador con equipos o configuraciones antiguas, el script `deploy.sh` realiza automáticamente la siguiente modificación en `/etc/asterisk/modules.conf`:

* **Acción:** Comenta la línea `noload => chan_sip.so` (añadiendo un `;` al inicio o eliminándola).
* **Resultado:** Permite que el módulo `chan_sip.so` se cargue al inicio, habilitando el soporte para troncales legacy.

---

## 📂 Estructura del Repositorio

* **`/etc_asterisk`**: Contiene los archivos `.conf` vitales (`extensions.conf`, `sip.conf`, `modules.conf`, etc.).
* **`/etc_fail2ban`**: Configuración de seguridad (`jail.local`).
* **`deploy.sh`**: Script Bash que automatiza la instalación de repositorios, paquetes, permisos y configuraciones.

---

**Autor:** Profesor Nicolás Sánchez R.
**Proyecto:** Simulador PSTN 
