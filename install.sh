#!/bin/bash
# Lucina Engine v3.2 - Universal Multi-Distro Installer
# Optimizaciones: Detección Automática de Dependencias | Systemd Auto-Enable

set -e

echo "🌌 Instalando Lucina Engine v3.2..."

# --- Detección de Distro y Gestor de Paquetes ---
if [ -f /etc/arch-release ]; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --needed --noconfirm"
    # Buscar AUR helpers
    if command -v yay &> /dev/null; then AUR_HELPER="yay";
    elif command -v paru &> /dev/null; then AUR_HELPER="paru";
    elif command -v pamac &> /dev/null; then AUR_HELPER="pamac"; fi
elif [ -f /etc/debian_version ] || [ -f /etc/pop-os/os-release ]; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt update && sudo apt install -y"
elif [ -f /etc/fedora-release ]; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
else
    echo "⚠️ Distro no reconocida oficialmente. Intentando usar detección genérica..."
    [ -x "$(command -v apt)" ] && PKG_MANAGER="apt"
    [ -x "$(command -v pacman)" ] && PKG_MANAGER="pacman"
fi

# --- Instalación de Dependencias ---
echo "📦 Verificando dependencias para $PKG_MANAGER..."
DEPS="mpv fzf ffmpeg"

case $PKG_MANAGER in
    "pacman")
        $INSTALL_CMD $DEPS
        if ! command -v mpvpaper &> /dev/null; then
            if [ -n "$AUR_HELPER" ]; then
                echo "🚀 Instalando mpvpaper vía $AUR_HELPER..."
                $AUR_HELPER -S --noconfirm mpvpaper-git
            else
                echo "❌ mpvpaper no encontrado. Por favor, instálalo manualmente desde AUR."
            fi
        fi
        ;;
    "apt")
        $INSTALL_CMD $DEPS
        if ! command -v mpvpaper &> /dev/null; then
            echo "💡 mpvpaper no suele estar en repos oficiales de Debian/Ubuntu."
            echo "Asegúrate de compilarlo desde: https://github.com/AntonySRE/mpvpaper"
        fi
        ;;
    "dnf")
        $INSTALL_CMD $DEPS
        ;;
esac

# --- Configuración de Directorios ---
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/wallpaper"
mkdir -p "$HOME/.config/systemd/user"

# --- Instalación de Binarios ---
cp bin/lucina "$HOME/.local/bin/lucina"
chmod +x "$HOME/.local/bin/lucina"

# --- Configuración de Shell (Alias) ---
SHELL_RC=""
[ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && SHELL_RC="$HOME/.bashrc"

if [ -n "$SHELL_RC" ]; then
    if ! grep -q "alias lucina=" "$SHELL_RC"; then
        echo "alias lucina='$HOME/.local/bin/lucina'" >> "$SHELL_RC"
        echo "✅ Alias 'lucina' añadido a $SHELL_RC"
    fi
fi

# --- Instalación y Activación del Servicio ---
if [ -f "systemd/lucina.service" ]; then
    cp systemd/lucina.service "$HOME/.config/systemd/user/lucina.service"
    systemctl --user daemon-reload
    systemctl --user enable --now lucina.service || echo "⚠️ El servicio se habilitó pero no pudo iniciar (puede faltar una sesión previa)."
    echo "✅ Servicio Systemd activado y habilitado por defecto."
fi

# --- Verificación de Hardware ---
echo "🔍 Optimizando para tu hardware..."
if lspci | grep -qi "intel"; then
    echo "💡 GPU Intel detectada. Recomendamos: intel-media-driver."
elif lspci | grep -qi "nvidia"; then
    echo "🚀 GPU NVIDIA detectada. Asegúrate de tener drivers privativos."
fi

echo "---"
echo "🎉 ¡Lucina Engine v3.2 instalado con éxito!"
echo "Usa el comando: lucina"
