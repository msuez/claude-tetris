---
name: weather
description: Consulta clima actual/pronostico de una ciudad via wttr.in (curl, sin API key). Usar cuando pidan clima, temperatura, pronostico o forecast.
---

# Weather

Da clima via `curl wttr.in`. No API key, no dependencias.

## Uso

Ciudad dada:
```bash
curl -s "wttr.in/<CIUDAD>?format=3"
```

Sin ciudad (detecta por IP):
```bash
curl -s "wttr.in?format=3"
```

Reporte completo (varios dias, formato ASCII):
```bash
curl -s "wttr.in/<CIUDAD>?lang=es&M"
```
Agrega `?M` para unidades metricas.

Solo JSON (parseo programatico):
```bash
curl -s "wttr.in/<CIUDAD>?format=j1"
```

## Reglas

- Ciudad con espacio: reemplazar espacio por `+` (ej `Buenos+Aires`).
- Sin conexion o timeout: avisar directo, no reintentar en loop.
- Reportar temperatura, condicion, viento — extra solo si piden.
