# Lucina Engine v3.2 🌌

**Lucina Engine** is a high-performance, universal wallpaper engine for Wayland. It transforms your desktop with dynamic videos and static images, featuring intelligent hardware acceleration and seamless persistence.

---

## 🚀 Key Features

- **Universal Distro Support:** Native installers for **Arch Linux**, **Debian/Ubuntu/Pop!_OS**, and **Fedora**.
- **Adaptive Rendering:** Supports both high-fidelity video formats (`.mp4`, `.mkv`) and static images (`.png`, `.jpg`, `.webp`, `.gif`).
- **Intelligent Fallback:** Automatically detects GPU capabilities. If hardware acceleration (`nvdec`, `vaapi`) fails, it gracefully falls back to software rendering to ensure your wallpaper stays active.
- **Hardware Optimized:** Pre-configured performance profiles (`performance`, `mid`, `low`, `very_low`) to balance visual quality and CPU/GPU usage.
- **Session Persistence:** Built-in **Systemd user service** that automatically restores your last used wallpaper upon login.
- **Dynamic Wayland Detection:** Seamlessly detects active Wayland sessions (`wayland-0`, `wayland-1`, etc.) and monitor resolutions.

---

## 📋 Requirements

Lucina Engine automatically attempts to install these dependencies, but you can also install them manually:

- `mpvpaper` (Core rendering engine)
- `mpv` (Backend with HWDEC support)
- `fzf` (Interactive selection menu)
- `ffmpeg` (Video processing utilities)

---

## 🛠️ Installation

```bash
git clone https://github.com/Hector-dev/lucina-wallpaper-engine.git
cd lucina-wallpaper-engine
chmod +x install.sh
./install.sh
```

---

## 📖 Usage

### Launch the Interactive Menu
Simply type `lucina` in your terminal to select a wallpaper, change performance profiles, or optimize your videos:
```bash
lucina
```

### Automatic Restoration
The engine includes a background daemon. Once you pick a wallpaper, it will survive terminal reloads and system reboots. To check the service status:
```bash
systemctl --user status lucina.service
```

---

## 📂 Configuration
By default, Lucina looks for files in `~/wallpaper`. You can customize this by setting the `LUCINA_WALLPAPER_DIR` environment variable in your `.zshrc` or `.bashrc`.

---
**MIT License | 2026 Lucina Engine Contributors**
