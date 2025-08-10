#!/bin/bash

# ZMK Glove80 Left Side Build Script

set -e

echo "🔨 Building ZMK firmware for Glove80 LEFT side..."
echo "Using custom keymap: config/glove80.keymap"
echo ""

# Clean previous build
rm -rf build/left

# Build left side
docker run --rm -it --name zmk-config-left \
    -v "${PWD}":/app \
    -w /app \
    zmkfirmware/zmk-build-arm:stable \
    bash -c "west zephyr-export && west build -d build/left -s zmk/app -b glove80_lh -- -DZMK_CONFIG=/app/config"

if [ -f "build/left/zephyr/zmk.uf2" ]; then
    echo "✅ Left side build completed successfully!"
    ls -lh build/left/zephyr/zmk.uf2
    echo ""
    echo "📋 To flash the left side:"
    echo "   1. Put the LEFT half into bootloader mode (double-tap reset)"
    echo "   2. Copy build/left/zephyr/zmk.uf2 to the USB drive"
else
    echo "❌ Left side build failed!"
    exit 1
fi
