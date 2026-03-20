#!/bin/bash
set -e

echo "🌌 Preparando instalación de Lucina Engine v2.8..."

# Validación de dependencias críticas
for cmd in mpvpaper mpv fzf; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ Error: '$cmd' no está instalado. Por favor, instálalo antes de continuar."
        exit 1
    fi
done

echo "🚀 Instalando archivos..."
mkdir -p ~/.local/bin ~/.config/systemd/user ~/wallpaper

cp bin/lucina ~/.local/bin/lucina
chmod +x ~/.local/bin/lucina

cp systemd/lucina.service ~/.config/systemd/user/lucina.service

echo "⚙️ Configurando servicio de Systemd..."
systemctl --user daemon-reload
systemctl --user enable lucina.service

echo "✅ ¡Instalación completada con éxito!"
echo "👉 Puedes iniciar el motor ejecutando: lucina"
