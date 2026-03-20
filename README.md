# Lucina Engine v2.8 🌌

Engine ligero para fondos animados en Wayland, optimizado para GPUs NVIDIA (arquitectura Ampere/RTX 3060+) mediante NVDEC/CUDA.

## 🚀 Características
- **Adaptive Session:** Detección automática de sesión Wayland (`wayland-0`/`wayland-1`).
- **Hardware Acceleration:** Decodificación nativa por hardware para un consumo mínimo de CPU.
- **Minimalista:** Escrito en Bash para mayor portabilidad y rapidez.
- **Persistencia:** Integración nativa con Systemd para restaurar el fondo al iniciar sesión.

## 📋 Requisitos
Asegúrate de tener instalados los siguientes paquetes:
- `mpvpaper` (disponible en AUR o compílelo desde su fuente)
- `mpv` (con soporte para `--hwdec=nvdec`)
- `fzf` (para la selección interactiva de fondos)
- `grep`, `awk`, `find` (utilidades estándar de Linux)

## 🛠️ Instalación
```bash
git clone https://github.com/tu-usuario/lucina-engine.git
cd lucina-engine
chmod +x install.sh
./install.sh
```

## 📖 Uso
### Seleccionar un nuevo fondo:
Simplemente ejecuta `lucina` en tu terminal. Se abrirá un menú interactivo con `fzf` listando los videos en tu carpeta de fondos (por defecto `~/wallpaper`).

```bash
lucina
```

### Restaurar sesión:
El motor restaura automáticamente el último fondo usado al iniciar la sesión gráfica gracias al servicio de Systemd incluido.

## 📂 Configuración
Por defecto, Lucina busca videos `.mp4` en `~/wallpaper`. Puedes cambiar esta ruta editando la variable `BASE_DIR` en el script o configurando las variables de entorno XDG correspondientes.

---
Licencia MIT | 2026 Lucina Engine Contributors
