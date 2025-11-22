# 📞 Asterisk PSTN Simulator (Rocky Linux 9 / Asterisk 20)

![Rocky Linux](https://img.shields.io/badge/Rocky_Linux-9.6-10B981?logo=rockylinux)
![Asterisk](https://img.shields.io/badge/Asterisk-20.15-orange?logo=asterisk)
![SIP](https://img.shields.io/badge/Protocol-chan__sip-blue)
![Status](https://img.shields.io/badge/Status-Production-success)

Este repositorio contiene la configuración de infraestructura para un servidor de simulación PSTN utilizado en entornos educativos y laboratorios de VoIP.

El sistema simula una **Red Telefónica Pública Conmutada** para interconectar múltiples PBX (sedes de alumnos) mediante troncales SIP, gestionando el enrutamiento de DIDs simulados.

---

## 📋 Índice

- [Especificaciones Técnicas](#️-especificaciones-técnicas)
- [Instalación Automatizada](#-instalación-automatizada)
- [Documentación Completa](#-documentación-completa)
- [Estructura del Repositorio](#-estructura-del-repositorio)
- [Soporte y Contacto](#-soporte-y-contacto)

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

## 📚 Documentación Completa

### 📖 Manual Técnico y de Uso

Para información detallada sobre cómo conectar tu PBX al simulador, configurar troncales, y realizar pruebas, consulta el **[Manual Técnico completo (Instrucciones.md)](./INSTRUCCIONES.md)**.

Este manual incluye:

- ✅ **Arquitectura del sistema** - Cómo funciona el loopback de pruebas
- ✅ **Guía de conexión paso a paso** - Configuración de `sip.conf` y `extensions.conf`
- ✅ **Plan de numeración (DIDs)** - Rangos asignados por sede y grupo
- ✅ **Credenciales de acceso** - Usuarios para troncales y softphones de prueba
- ✅ **Lógica técnica del dialplan** - Casos de llamadas salientes, entrantes y emergencias
- ✅ **Pruebas y validación** - Checklist y comandos de diagnóstico
- ✅ **Troubleshooting completo** - Solución a problemas comunes
- ✅ **Recursos adicionales** - Comandos útiles, softphones recomendados

**👉 [Ver Manual Técnico (INSTRUCCIONES.md)](./INSTRUCCIONES.md)**

---

## 🔧 Notas sobre Asterisk 20 y chan_sip

La versión 20 de Asterisk marca el controlador `chan_sip` como obsoleto (deprecated) y, por defecto, no lo carga.

Para garantizar la funcionalidad del simulador con equipos o configuraciones antiguas, el script `deploy.sh` realiza automáticamente la siguiente modificación en `/etc/asterisk/modules.conf`:

* **Acción:** Comenta la línea `noload => chan_sip.so` (añadiendo un `;` al inicio o eliminándola).
* **Resultado:** Permite que el módulo `chan_sip.so` se cargue al inicio, habilitando el soporte para troncales legacy.

> ⚠️ **Importante:** Si necesitas migrar a PJSIP en el futuro, consulta la [documentación oficialn](https://docs.asterisk.org/Asterisk_20_Documentation/).

---

## 📂 Estructura del Repositorio

    Asterisk-PSTN-Simulator/
    ├── README.md                    # Este archivo (Guía principal)
    ├── INSTRUCCIONES.md             # Manual técnico completo de uso
    ├── deploy.sh                    # Script de instalación automatizada
    ├── etc_asterisk/                # Configuraciones de Asterisk
    │   ├── extensions.conf          # Dialplan principal
    │   ├── sip.conf                 # Configuración de troncales SIP
    │   ├── modules.conf             # Módulos cargados/deshabilitados
    │   ├── rtp.conf                 # Configuración de puertos RTP
    │   └── ...                      # Otros archivos .conf
    └── etc_fail2ban/                # Configuración de seguridad
        └── jail.local               # Reglas de fail2ban


### Descripción de Carpetas

* **`/etc_asterisk`**: Contiene los archivos `.conf` vitales (`extensions.conf`, `sip.conf`, `modules.conf`, etc.).
* **`/etc_fail2ban`**: Configuración de seguridad (`jail.local`).
* **`deploy.sh`**: Script Bash que automatiza la instalación de repositorios, paquetes, permisos y configuraciones.

---

## 🔐 Seguridad

El sistema incluye las siguientes medidas de seguridad preconfiguradas:

### Firewalld

Puertos abiertos por defecto:

    # SIP Signaling
    firewall-cmd --permanent --add-port=5060/udp
    
    # RTP Media
    firewall-cmd --permanent --add-port=10000-20000/udp
    
    # SSH
    firewall-cmd --permanent --add-service=ssh

### Fail2Ban

Protección contra ataques de fuerza bruta en:
- Autenticación SIP
- Invitaciones SIP no autorizadas
- Intentos de acceso SSH

Configuración en: `/etc/fail2ban/jail.local`

---

## 🧪 Verificación Post-Instalación

Después de ejecutar `deploy.sh`, verifica que todo esté funcionando correctamente:

### 1. Estado de Asterisk

    systemctl status asterisk

### 2. Módulos Cargados

    asterisk -rx "module show like chan_sip"
    # Debe mostrar: chan_sip.so

### 3. Puertos en Escucha

    ss -ulnp | grep asterisk
    # Debe mostrar el puerto 5060/udp

### 4. Registros SIP

    asterisk -rx "sip show peers"
    # Mostrará los peers configurados

---

## 📞 Pruebas Rápidas

### Conectar un Softphone de Prueba

Usa las credenciales de ejemplo para probar la conectividad:

    Servidor: [IP_DEL_SIMULADOR]
    Usuario: test-user
    Password: test-password
    Puerto: 5060

### Realizar una Llamada de Prueba

Desde la CLI de Asterisk:

    asterisk -rvvv
    originate SIP/test-user extension 100@default

---

## 🤝 Soporte y Contacto

### Documentación Adicional

- 📖 [Manual Técnico Completo (Instrucciones.md)](./INSTRUCCIONES.md)
- 📚 [Asterisk 20 Documentation](https://docs.asterisk.org/Asterisk_20_Documentation/)
- 🔧 [chan_sip Configuration Guide](https://wiki.asterisk.org/wiki/display/AST/Configuring+chan_sip)

### Reportar Problemas

Si encuentras algún problema o bug:

1. Revisa primero la sección de [Troubleshooting en el Manual Técnico](./INSTRUCCIONES.md#7-troubleshooting)
2. Crea un [Issue en GitHub](../../issues) con detalles del error
3. Contacta al profesor vía email

### Contribuir

Las contribuciones son bienvenidas. Para contribuir:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/mejora`)
3. Commit tus cambios (`git commit -m 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/mejora`)
5. Abre un Pull Request

---

## 📝 Información del Proyecto

**Autor:** Docente Nicolás Sánchez R.  
**Proyecto:** Simulador PSTN para Educación en VoIP  
**Versión:** 1.0  
**Última actualización:** Noviembre 2025

---

## 📄 Licencia

Este proyecto está bajo licencia de uso educativo. Ver archivo [LICENSE](LICENSE) para más detalles.

[![License: Educational](https://img.shields.io/badge/License-Educational%20Use%20Only-yellow.svg)](LICENSE)

---

## ⭐ Agradecimientos

Agradecimientos especiales a:

- La comunidad de Asterisk por su excelente documentación
- Los estudiantes que han participado en las pruebas del simulador
- El equipo de Tucny por mantener los repositorios actualizados para Rocky Linux

---

**¿Necesitas ayuda para configurar tu PBX?** 👉 Consulta el **[Manual Técnico (INSTRUCCIONES.md)](./INSTRUCCIONES.md)**
