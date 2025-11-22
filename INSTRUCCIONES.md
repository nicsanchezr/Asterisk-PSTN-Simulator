# 📚 Manual Técnico y de Uso: Simulador PSTN (ITSP)

![Asterisk](https://img.shields.io/badge/Asterisk-20.15-orange?logo=asterisk)
![SIP](https://img.shields.io/badge/Protocol-chan__sip-blue)
![License](https://img.shields.io/badge/License-Educational-green)
![Status](https://img.shields.io/badge/Status-Active-success)

Este repositorio contiene la configuración e infraestructura de un servidor **Asterisk 20.15** diseñado para simular una **Red Telefónica Pública Conmutada (PSTN)**. Actúa como un ITSP (*Internet Telephony Service Provider*) educativo, permitiendo la interconexión de múltiples PBX mediante troncales SIP (chan_sip) y la simulación de llamadas hacia/desde la red pública.

> ⚠️ **Nota Importante:** Este sistema utiliza **chan_sip** (SIP tradicional), no PJSIP. Asegúrese de que su servidor Asterisk tenga cargado el módulo `chan_sip.so`.

---

## 📋 Tabla de Contenidos

- [Arquitectura de Simulación](#1-arquitectura-de-simulación-loopback)
- [Guía de Conexión](#2-guía-de-conexión)
- [Plan de Numeración](#3-plan-de-numeración-dids)
- [Credenciales de Acceso](#4-credenciales-de-acceso)
- [Lógica Técnica](#5-lógica-técnica-extensionsconf)
- [Pruebas y Validación](#6-pruebas-y-validación)
- [Troubleshooting](#7-troubleshooting)
- [Recursos Adicionales](#8-recursos-adicionales)

---

## 1. Arquitectura de Simulación (Loopback)

El sistema está diseñado para que cada grupo pueda probar sus configuraciones de forma autónoma utilizando un **Softphone de Pruebas** que actúa como "El Mundo Exterior".

### 🔄 El Ciclo de Pruebas

1. **Prueba Saliente (PBX → Mundo):**
   * Alumno llama a un celular (`912345678`) desde su PBX.
   * El simulador recibe la llamada y la envía al **Softphone del grupo**.
   * *Resultado:* El Softphone suena, simulando ser el destino.

2. **Prueba Entrante (Mundo → PBX):**
   * Alumno marca su propio DID (`225881000`) desde el Softphone.
   * El simulador envía la llamada al **Troncal de la PBX**.
   * *Resultado:* La PBX recibe una llamada entrante.

### 📊 Diagrama de Flujo

    ┌─────────────┐         ┌──────────────┐         ┌─────────────┐
    │   PBX del   │────────▶│   Simulador  │────────▶│  Softphone  │
    │    Grupo    │         │     PSTN     │         │  de Pruebas │
    └─────────────┘◀────────└──────────────┘◀────────└─────────────┘
         ▲                                                   │
         └───────────────────────────────────────────────────┘
                    (Loopback para pruebas)

---

## 2. Guía de Conexión

### A. Parámetros Globales

| Parámetro | Valor |
|-----------|-------|
| **IP del Servidor** | `[IP_DEL_SERVIDOR]` |
| **Puerto** | `5060` (UDP) |
| **Códecs** | `alaw`, `ulaw` |
| **DTMF** | `rfc2833` |
| **Protocolo** | SIP (chan_sip) |
| **Versión Asterisk** | 20.15 |

### B. Configuración del Troncal (sip.conf)

Ejemplo de configuración para conectar su servidor Asterisk al simulador usando **chan_sip**:

    ; === CONFIGURACIÓN GENERAL (en sección [general]) ===
    ; Agregar al final de la sección [general] de sip.conf
    
    register => [USUARIO_TRONCAL]:[PASSWORD_TRONCAL]@[IP_DEL_SERVIDOR]:[PUERTO]/[USUARIO_TRONCAL]
    
    ; === TRONCAL HACIA PSTN SIMULADA ===
    
    [pstn-trunk]
    type=peer
    host=[IP_DEL_SERVIDOR]
    port=5060
    username=[USUARIO_TRONCAL]
    secret=[PASSWORD_TRONCAL]
    fromuser=[USUARIO_TRONCAL]
    fromdomain=[IP_DEL_SERVIDOR]
    context=from-pstn
    disallow=all
    allow=alaw
    allow=ulaw
    dtmfmode=rfc2833
    canreinvite=no
    insecure=port,invite
    qualify=yes
    nat=no

### C. Dialplan Básico Recomendado

Para enviar llamadas salientes hacia el simulador:

    [outbound-routes]
    ; Llamadas a móviles (9XXXXXXXX)
    exten => _9XXXXXXXX,1,NoOp(Llamada saliente a móvil: ${EXTEN})
     same => n,Dial(SIP/${EXTEN}@pstn-trunk)
     same => n,Hangup()
    
    ; Llamadas a fijos (2XXXXXXXX)
    exten => _2XXXXXXXX,1,NoOp(Llamada saliente a fijo: ${EXTEN})
     same => n,Dial(SIP/${EXTEN}@pstn-trunk)
     same => n,Hangup()
    
    ; Llamadas de emergencia (13X)
    exten => _13X,1,NoOp(Llamada de emergencia: ${EXTEN})
     same => n,Dial(SIP/${EXTEN}@pstn-trunk)
     same => n,Hangup()

---

## 3. Plan de Numeración (DIDs)

Cada grupo tiene asignado un rango de números. Su PBX debe estar preparada para recibir llamadas a cualquiera de estos DIDs.

### 📍 Sede: Antonio Varas

| Grupo | Rango DID Asignado         | Total DIDs |
|-------|----------------------------|------------|
| 1     | 225881000 - 225881999      | 1000       |
| 2     | 225882000 - 225882999      | 1000       |
| 3     | 225883000 - 225883999      | 1000       |
| 4     | 225884000 - 225884999      | 1000       |
| 5     | 225885000 - 225885999      | 1000       |
| 6     | 225886000 - 225886999      | 1000       |

> **📝 Nota:** El patrón se repite para las demás sedes. Ver archivos CSV adjuntos en la documentación del curso.

### Ejemplo de Configuración para Recibir DIDs

    [from-pstn]
    ; Recibir llamadas al rango de DIDs del grupo
    exten => _225881XXX,1,NoOp(Llamada entrante al DID: ${EXTEN})
     same => n,Goto(internal-routing,${EXTEN:5},1)  ; Últimos 3 dígitos
     same => n,Hangup()

---

## 4. Credenciales de Acceso

Utilice estas credenciales para configurar su Troncal (en su servidor) y su Softphone (en su PC/Celular).

### 📍 Sede: Antonio Varas

| Grupo | Usuario Troncal (PBX) | Password      | Usuario Softphone (Pruebas) | Password      |
|-------|-----------------------|---------------|-----------------------------|---------------|
| 1     | avaras1               | avaras.2024   | grupo1-varas                | avaras.2024   |
| 2     | avaras2               | avaras.2024   | grupo2-varas                | avaras.2024   |
| 3     | avaras3               | avaras.2024   | grupo3-varas                | avaras.2024   |
| 4     | avaras4               | avaras.2024   | grupo4-varas                | avaras.2024   |
| 5     | avaras5               | avaras.2024   | grupo5-varas                | avaras.2024   |
| 6     | avaras6               | avaras.2024   | grupo6-varas                | avaras.2024   |

> ⚠️ **Seguridad:** Estas credenciales son exclusivas para el entorno educativo. En producción, utilice contraseñas robustas y únicas.

---

## 5. Lógica Técnica (extensions.conf)

El servidor clasifica el tráfico entrante y lo redirige para cerrar el bucle de pruebas.

### Caso A: Llamada Saliente (Simulación Fija/Móvil)

Cuando la PBX envía una llamada a la PSTN:

    ; Patrón para detectar llamadas a Fijos (2XXXXXXXX) o Móviles (9XXXXXXXX)
    exten => _[29]XXXXXXXX,1,NoOp(Llamada PSTN simulada de ${CALLERID(num)} para ${EXTEN})
     same => n,GotoIf($["${EXTEN:0:1}" = "2"]?set-local:set-celular)
    
    ; Etiquetado y envío al Softphone del grupo
     same => n(set-local),Set(CALL_TYPE=LOCAL)
     same => n,Dial(SIP/grupo1-varas)
    
     same => n(set-celular),Set(CALL_TYPE=CELULAR)
     same => n,Dial(SIP/grupo1-varas)

### Caso B: Llamada de Emergencia

Cuando la PBX marca 131, 132 o 133:

    exten => _13X,1,NoOp(Llamada Emergencia simulada)
     same => n,Set(CALL_TYPE=EMERGENCIA)
     same => n,Dial(SIP/grupo1-varas)

### Caso C: Llamada Entrante (Simulación DID)

Cuando el Softphone marca el DID propio del grupo:

    ; El alumno marca su propio DID desde el softphone
    exten => _225881XXX,1,NoOp(Llamada entrante para Grupo 1)
     same => n,Dial(SIP/avaras1/${EXTEN}) ; Se envía al Troncal de la PBX

---

## 6. Pruebas y Validación

### ✅ Checklist de Configuración

- [ ] Troncal configurado en `sip.conf`
- [ ] Registro exitoso con el simulador (`sip show registry`)
- [ ] Softphone configurado con credenciales del grupo
- [ ] Dialplan configurado para llamadas salientes
- [ ] Context `from-pstn` configurado para llamadas entrantes
- [ ] Códecs `alaw` y `ulaw` habilitados
- [ ] Módulo `chan_sip.so` cargado en Asterisk

### 🧪 Pruebas Recomendadas

#### 1. Verificar Registro del Troncal

    asterisk -rx "sip show registry"

**Resultado esperado:**
    
    Host                            Username       Refresh State
    [IP_DEL_SERVIDOR]:5060          [USUARIO]          105 Registered

#### 2. Prueba de Llamada Saliente a Móvil

1. Desde un softphone interno, marcar: `912345678`
2. Debe sonar el Softphone de pruebas del grupo
3. Verificar audio bidireccional

#### 3. Prueba de Llamada Entrante desde DID

1. Desde el Softphone de pruebas, marcar: `225881XXX`
2. Debe sonar en la extensión correspondiente de la PBX
3. Verificar audio bidireccional

#### 4. Prueba de Llamada de Emergencia

1. Desde un softphone interno, marcar: `131`, `132` o `133`
2. Debe sonar el Softphone de pruebas del grupo
3. Verificar identificación de tipo de llamada

---

## 7. Troubleshooting

### ❌ Problemas Comunes

#### El troncal no registra

**Síntomas:**
- `sip show registry` muestra "Unregistered" o "Request Sent"

**Solución:**

    ; Verificar conectividad
    ping [IP_DEL_SERVIDOR]
    
    ; Verificar logs de Asterisk
    asterisk -rx "sip set debug on"
    
    ; Revisar credenciales en sip.conf
    ; Verificar que username/secret sean correctos
    
    ; Verificar estado del peer
    asterisk -rx "sip show peer pstn-trunk"

#### No hay audio en las llamadas

**Síntomas:**
- La llamada se establece pero no hay audio

**Solución:**

    ; Verificar que canreinvite=no esté configurado
    ; Revisar que los códecs coincidan (alaw/ulaw)
    asterisk -rx "core show channels"
    
    ; Verificar NAT/Firewall
    ; Puertos UDP 5060 y 10000-20000 deben estar abiertos
    
    ; Revisar configuración RTP en rtp.conf
    cat /etc/asterisk/rtp.conf

#### Llamadas entrantes no llegan

**Síntomas:**
- El Softphone puede llamar hacia afuera, pero no recibe llamadas

**Solución:**

    ; Verificar que el context from-pstn exista
    asterisk -rx "dialplan show from-pstn"
    
    ; Verificar patrón de DIDs en extensions.conf
    ; Asegurar que coincida con el rango asignado

#### Error "No Route to Host"

**Síntomas:**
- Error al intentar llamar

**Solución:**

    ; Verificar rutas de red
    traceroute [IP_DEL_SERVIDOR]
    
    ; Verificar firewall local
    sudo iptables -L -n
    
    ; Verificar peer en chan_sip
    asterisk -rx "sip show peer pstn-trunk"
    
    ; Verificar que chan_sip esté cargado
    asterisk -rx "module show like chan_sip"

---

## 8. Recursos Adicionales

### 📚 Documentación Oficial

- [Asterisk 20 Documentation](https://docs.asterisk.org/Asterisk_20_Documentation/)
- [chan_sip Configuration](https://wiki.asterisk.org/wiki/display/AST/Configuring+chan_sip)
- [Asterisk 20.15 Release Notes](https://downloads.asterisk.org/pub/telephony/asterisk/releases/ChangeLog-20.15.0.md)
- [Dialplan Applications](https://wiki.asterisk.org/wiki/display/AST/Dialplan+Applications)

### 🔧 Comandos Útiles de Asterisk

    # Ver estado de registros SIP
    asterisk -rx "sip show registry"
    
    # Ver peers configurados
    asterisk -rx "sip show peers"
    
    # Ver detalles de un peer específico
    asterisk -rx "sip show peer pstn-trunk"
    
    # Ver canales activos
    asterisk -rx "core show channels"
    
    # Ver dialplan
    asterisk -rx "dialplan show"
    
    # Recargar configuración SIP
    asterisk -rx "sip reload"
    
    # Activar debug de SIP
    asterisk -rx "sip set debug on"
    
    # Ver logs en tiempo real
    asterisk -rx "core set verbose 5"
    tail -f /var/log/asterisk/full
    
    # Verificar módulo chan_sip cargado
    asterisk -rx "module show like chan_sip"

### 🎓 Softphones Recomendados

| Plataforma | Aplicación | Notas |
|------------|------------|-------|
| Windows | [MicroSIP](https://www.microsip.org/) | Ligero y fácil de usar |
| Windows/Mac/Linux | [Linphone](https://www.linphone.org/) | Open source, multiplataforma |
| Android | [Linphone](https://play.google.com/store/apps/details?id=org.linphone) | Versión móvil |
| iOS | [Linphone](https://apps.apple.com/app/linphone/id360065638) | Versión móvil |
| Web | [JsSIP](https://tryit.jssip.net/) | Sin instalación |

### 📁 Archivos de Configuración de Ejemplo

Puedes encontrar ejemplos completos de configuración en la carpeta `/ejemplos`:

- `sip.conf.example` - Configuración completa del troncal con chan_sip
- `extensions.conf.example` - Dialplan con todos los casos
- `rtp.conf.example` - Configuración de puertos RTP

### 📋 Requisitos del Sistema

- **Asterisk:** Versión 20.15
- **Módulos requeridos:** `chan_sip.so`
- **Sistema Operativo:** Linux (Ubuntu 20.04+, Debian 11+, CentOS 8+)
- **Puertos:** UDP 5060 (SIP), UDP 10000-20000 (RTP)

---

## 📝 Información del Documento

**Autor:** Docente Nicolás Sánchez R.  
**Versión:** 2.1 (Formato GitHub)  
**Última actualización:** Noviembre 2025  
**Repositorio:** [github.com/nicsanchezr/Asterisk-PSTN-Simulator/](https://github.com/nicsanchezr/Asterisk-PSTN-Simulator/)

---

## 📄 Licencia

Este material es de uso educativo exclusivo para estudiantes del curso de Telefonía IP.

[![License: Educational](https://img.shields.io/badge/License-Educational%20Use%20Only-yellow.svg)](LICENSE)

---

## 🤝 Contribuciones

Si encuentras errores o deseas sugerir mejoras:

1. Crea un [Issue](../../issues)
2. Envía un Pull Request
3. Contacta al profesor vía email

---

## ⭐ Agradecimientos

Agradecimientos especiales a todos los estudiantes que han participado en las pruebas y validación de este simulador.

---

**¿Necesitas ayuda?** Consulta la sección de [Troubleshooting](#7-troubleshooting) o contacta al profesor.
