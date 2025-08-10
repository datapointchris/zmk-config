#!/bin/bash

# ZMK Glove80 Build Script
# This script builds the ZMK firmware for both left and right sides of the Glove80
# using your custom keymap configuration

set -e  # Exit on any error

echo "🚀 Building ZMK firmware for Glove80..."
echo "Using custom keymap: config/glove80.keymap"
echo ""

# Docker image to use
DOCKER_IMAGE="zmkfirmware/zmk-build-arm:stable"

# Function to build a side
build_side() {
    local side=$1
    local board=$2
    
    echo "🔨 Building $side side ($board)..."
    
    # Clean previous build
    rm -rf build/$side
    
    # Run the build
    docker run --rm -it --name "zmk-config-$side" \
        -v "${PWD}":/app \
        -w /app \
        $DOCKER_IMAGE \
        bash -c "west zephyr-export && west build -d build/$side -s zmk/app -b $board -- -DZMK_CONFIG=/app/config"
    
    if [ -f "build/$side/zephyr/zmk.uf2" ]; then
        echo "✅ $side side build completed successfully!"
        ls -lh build/$side/zephyr/zmk.uf2
    else
        echo "❌ $side side build failed!"
        exit 1
    fi
    echo ""
}

# Build both sides
echo "Building both sides..."
echo ""

build_side "left" "glove80_lh"
build_side "right" "glove80_rh"

echo "🎉 All builds completed successfully!"
echo ""
echo "📁 Firmware files:"
echo "   Left:  build/left/zephyr/zmk.uf2"
echo "   Right: build/right/zephyr/zmk.uf2"
echo ""
echo "📋 To flash:"
echo "   1. Put each half into bootloader mode (double-tap reset)"
echo "   2. Copy the corresponding .uf2 file to the USB drive that appears"
