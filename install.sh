#!/bin/bash
# Lucina Engine v2.9 - Universal Installer

set -e

echo "🌌 Instalando Lucina Engine v2.9..."

# 1. Crear directorios necesarios
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/wallpaper"
mkdir -p "$HOME/.config/systemd/user"

# 2. Copiar el ejecutable
cp bin/lucina "$HOME/.local/bin/lucina"
chmod +x "$HOME/.local/bin/lucina"

# 3. Configurar Alias (Detección de Shell)
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    if ! grep -q "alias lucina=" "$SHELL_RC"; then
        echo "alias lucina='$HOME/.local/bin/lucina'" >> "$SHELL_RC"
        echo "✅ Alias 'lucina' añadido a $SHELL_RC"
    fi
fi

# 4. Instalar Servicio de Systemd (Opcional pero recomendado)
if [ -f "systemd/lucina.service" ]; then
    cp systemd/lucina.service "$HOME/.config/systemd/user/lucina.service"
    systemctl --user daemon-reload
    echo "✅ Servicio Systemd instalado (usa 'systemctl --user enable lucina' para persistencia)"
fi

# 5. Verificación de Drivers de Video (Específico para Canaima/Arch)
echo "🔍 Verificando hardware de video..."
if lspci | grep -qi "intel"; then
    echo "💡 Detectada GPU Intel. Asegúrate de tener: sudo pacman -S intel-media-driver libva-utils"
elif lspci | grep -qi "nvidia"; then
    echo "🚀 Detectada GPU NVIDIA. Asegúrate de tener los drivers privativos instalados."
fi

echo "---"
echo "🎉 ¡Instalación completada!"
echo "Reinicia tu terminal o ejecuta 'source $SHELL_RC' para empezar."
echo "Usa el comando: lucina"
