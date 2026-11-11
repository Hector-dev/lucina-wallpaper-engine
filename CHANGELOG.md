# Changelog

## v3.3 — Supervisor Edition

Cambios medidos en una sesión real (i5-12400, Intel UHD 730, Wayland/Hyprland).

### Añadido

- **Supervisor del motor**: si `mpvpaper` muere, se relanza con backoff (1 s, 2 s, 4 s…)
  en lugar de quedarse en software para siempre. Reintenta `vaapi` tras una corrida estable.
- **Backend de imagen estática** con `swaybg`/`wbg`: **14,7 MB RSS y 0,00 % CPU** frente a
  ~260 MB y 1,6 % usando `mpv` para pintar un PNG.
- **CLI**: `lucina set <archivo> [perfil]`, `lucina status`, `lucina bench [segundos]`.
- **Detección de tier** (potato/low/balanced/max) que elige perfil por defecto; se puede
  forzar con `LUCINA_TIER`.
- **`lucina bench`** por socket IPC: RSS (Anon/File/swap), hilos, CPU real, hwdec, fps
  efectivo y frames dropeados.

### Cambiado

- `mpvpaper -d` se ejecuta **una vez** por arranque (−79 ms y un pico de RAM menos).
- Perfiles sin `--loop-file` duplicado (ya vive en las banderas comunes).
- Los `pkill` masivos se sustituyen por terminación del PID propio (o huérfano reconocido
  por su socket IPC).
- Lock de instancia validado contra `/proc/<pid>/cmdline` (los PID de `/tmp` se reutilizan).

### Corregido

- **fuga de memoria de la GPU**: se cargaba el stack EGL de NVIDIA (libcuda,
  libnvidia-egl*) aunque la GPU fuese Intel, porque glvnd sondea todos los ICD.
  Forzar el proveedor de Mesa ahorra **−97 MB de RSS** sin tocar `vaapi`.
- Widgets Lua: el timer redibujaba 25 veces por segundo incluso para un reloj que cambia
  1 vez por segundo; ahora sólo redibuja si el ASS cambió y baja a 4 fps sin visualizador.

### Notas

- `--profile=fast` (perfil `mid`) ahorra ~1 punto de CPU frente a `performance`
  incluso con escalado 1:1: medido 4,6 % vs 5,6 %. Se mantiene en `mid`/`low`/`very_low`.
- El coste real de los widgets es componer el OSD, no redibujarlo: con reloj activo el
  motor pasa de 4,7 % a ~5,5 % de un núcleo.
