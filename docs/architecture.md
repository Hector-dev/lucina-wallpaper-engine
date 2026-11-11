# Lucina Engine — Teardown de arquitectura

> Skill usage marker: used the project-teardown skill

Documento vivo. La Parte Uno es el panorama global; la Parte Dos se rellena ronda a ronda, una sola pregunta central por vez.

---

## Parte Uno: Panorama global

### Juicio en una frase

No es un "wallpaper engine" en el sentido comercial (una app con UI que pinta fondos): es **un orquestador de proceso y hardware** — un script de bash que decide *cómo* debe arrancar `mpv` para que un video se renderice como fondo de pantalla en Wayland, con el menor consumo posible y sobreviviendo a reinicios.

### Qué es realmente este proyecto

Tres capas, y solo una es "código propio" en sentido estricto:

1. **Orquestación (bash, 468 líneas)** — el producto real. Detecta sesión Wayland, elige códec de hardware, arma las banderas de `mpv`, aplica un perfil de rendimiento, guarda estado y gestiona el ciclo de vida del proceso.
2. **Renderizado (mpvpaper + mpv)** — dependencia externa. Lucina no dibuja nada; le entrega a `mpvpaper` un monitor y una lista de banderas para que `mpv` pinte en la capa de fondo de Wayland.
3. **Superposición visual (Lua, 105 líneas)** — un script que `mpv` carga y que dibuja reloj y visualizador como subtítulos ASS encima del video.

No hay servidor, no hay base de datos, no hay daemon propio. El "estado" son archivos de texto en `XDG_STATE_HOME` y un unit de systemd de usuario.

### Dolor de negocio que resuelve

El problema no es "poner un video de fondo". Es que **poner un video de fondo en Linux es caro y frágil**:

- Un video 1080p decodificado por CPU satura un portátil modesto (el historial de commits lo dice literal: "Celeron N2805", "28% GPU", "reduce CPU usage by 85%").
- `mpvpaper` necesita saber *dónde* dibujar (monitor Wayland), lo que cambia entre compositores (Hyprland, Sway, otros) y entre sesiones (`wayland-0`, `wayland-1`…).
- La aceleración por hardware no es universal: NVIDIA quiere `nvdec`, Intel/AMD quieren `vaapi`, y ciertos formatos (imágenes, GIF) fallan si se les fuerza HWDEC.
- Un proceso que se lanza desde una terminal muere al cerrarla; nadie quiere relanzar su fondo cada login.

Lucina convierte esas cuatro fragilidades en decisiones automáticas y persistidas.

### Un flujo central: "elegir fondo" de punta a punta

```
lucina (menú fzf)
  └─> start_engine(ruta, perfil)
        ├─ mata mpvpaper previo (SIGTERM, luego SIGKILL)
        ├─ detecta MONITOR (mpvpaper -d) y RESOLUTION (hyprctl | swaymsg | sysfs)
        ├─ guarda STATE_FILE + PROFILE_FILE          ← persistencia
        ├─ resuelve HW_FLAG según extensión y códec   ← decisión de hardware
        ├─ arma LOOP_FLAGS (sin audio, sin caché, socket IPC)
        ├─ inyecta lucina_widgets.lua si existe        ← capa visual
        ├─ start_cava() si el visualizador está activo ← puente de audio
        └─ exec mpvpaper -p|-f -o "<flags>" <monitor> <archivo>
              └─ si falla → exec mpvpaper con --hwdec=no y perfil low  ← degradación
```

El arranque normal es interactivo (`-f`, en background). El arranque por systemd es `--restore --no-fork`, en primer plano, para que el servicio sea el dueño del proceso y pueda reiniciarlo.

### El mecanismo que más conviene entender primero

**La cadena de degradación**: `nvdec` → `vaapi` → `auto` → `software`, más el fallback de `exec` cuando `mpvpaper` falla al arrancar.

Ahí está concentrada la tesis del proyecto. Todo lo demás (menú, widgets, instalador) es periferia; esto es lo que hace que un video no rompa una sesión gráfica y lo que justifica los perfiles `performance`/`mid`/`low`/`very_low`. Sin esa cadena, Lucina sería un alias de `mpvpaper`.

### Panorama en una imagen

| Decisión | Elección | Lo que evita |
|---|---|---|
| Renderizador | `mpvpaper` (mpv) en vez de dibujar | Reimplementar un compositor de video |
| Persistencia de sesión | `systemd --user` + archivos planos | Daemon propio, PID huérfano |
| Widgets | Overlay ASS dentro de mpv | Toolkit gráfico (GTK/Qt/eww) y otro proceso |
| Visualizador de audio | CAVA → FIFO → archivo en RAM | IPC por socket a 20 FPS |
| Rendimiento | 4 perfiles de banderas | Un único ajuste "que funcione en todo" |
| Estado | `XDG_STATE_HOME` | Base de datos para 2 strings |

### Confirmado vs. inferido vs. desconocido

- **Confirmado por código**: todo lo anterior; el fallback usa `exec` (no reintento en el mismo proceso) y los formatos estáticos fuerzan `--hwdec=no`.
- **Inferido**: los perfiles están calibrados empíricamente para un Celeron N2805 (los mensajes de commit lo sugieren); `very_low` es un perfil de "último recurso" más que un modo de uso diario.
- **Desconocido / pendiente**: `assets/Modelfile` define un modelo `qwen2.5-coder:1.5b` para generar comandos bash, pero **ningún script lo referencia** — parece una idea abandonada. `yay-bin/` está vendorizado dentro del repo (árbol de compilación de `yay`), sin relación con el producto.

### Por dónde seguir

El orden que más rendimiento de comprensión da:

1. **Degradación de hardware** — es la tesis del proyecto.
2. **Modelo de proceso y systemd** — por qué `exec`, por qué `--no-fork`, por qué `tail -f /dev/null`.
3. **Widgets sin toolkit** — el truco de dibujar ASS dentro de mpv.
4. **Puente CAVA** — el diseño de "archivo atómico" en lugar de IPC.
5. **Distribución multi-distro** — qué se puede y qué no se puede prometer en `install.sh`.

---

## Parte Dos: Teardowns por tema

> Secciones reservadas. Cada ronda añade contenido a una sola sección; no se abren documentos nuevos.

### T1. Aceleración por hardware y degradación elegante

*Pregunta central pendiente:* ¿por qué un fallback de hardware es el corazón del proyecto y no un detalle de configuración?

### T2. Modelo de proceso: `exec`, `--no-fork` y systemd

*Pregunta central pendiente:* ¿por qué el mismo binario debe comportarse distinto según lo lance una terminal o systemd?

### T3. Widgets sin toolkit: overlay ASS dentro de mpv

*Pregunta central pendiente:* ¿qué se gana dibujando reloj y visualizador como subtítulos en vez de usar una capa de UI?

### T4. Puente CAVA: archivo atómico contra IPC

*Pregunta central pendiente:* ¿por qué 20 FPS de archivo en RAM es mejor que un socket?

### T5. Distribución universal: qué promete `install.sh`

*Pregunta central pendiente:* ¿dónde está la frontera real entre "soporte multi-distro" y "detección de distro"?
