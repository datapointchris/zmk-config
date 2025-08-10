#!/bin/bash

# ZMK Glove80 Right Side Build Script

set -e

echo "🔨 Building ZMK firmware for Glove80 RIGHT side..."
echo "Using custom keymap: config/glove80.keymap"
echo ""

# Clean previous build
rm -rf build/right

# Build right side
docker run --rm -it --name zmk-config-right \
    -v "${PWD}":/app \
    -w /app \
    zmkfirmware/zmk-build-arm:stable \
    bash -c "west zephyr-export && west build -d build/right -s zmk/app -b glove80_rh -- -DZMK_CONFIG=/app/config"

if [ -f "build/right/zephyr/zmk.uf2" ]; then
    echo "✅ Right side build completed successfully!"
    ls -lh build/right/zephyr/zmk.uf2
    echo ""
    echo "📋 To flash the right side:"
    echo "   1. Put the RIGHT half into bootloader mode (double-tap reset)"
    echo "   2. Copy build/right/zephyr/zmk.uf2 to the USB drive"
else
    echo "❌ Right side build failed!"
    exit 1
fi
