#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

KEYBOARD="${1:-both}"
BRANCH="${2:-main}"

show_help() {
    echo -e "${BLUE}ZMK Firmware Build Script${NC}"
    echo -e "${BLUE}=========================${NC}"
    echo ""
    echo "Usage: $0 [KEYBOARD] [BRANCH]"
    echo ""
    echo "KEYBOARD options:"
    echo "  glove80   - Build only Glove80 firmware"
    echo "  corne42   - Build only Corne42 firmware"  
    echo "  both      - Build both keyboards (default)"
    echo ""
    echo "BRANCH options (Glove80 only):"
    echo "  main      - Use main branch (default)"
    echo "  beta      - Use beta branch"
    echo "  <tag>     - Use specific tag"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build both keyboards"
    echo "  $0 glove80           # Build Glove80 with main branch"
    echo "  $0 glove80 beta      # Build Glove80 with beta branch"
    echo "  $0 corne42           # Build Corne42"
    echo "  $0 both              # Build both keyboards"
    echo ""
    echo -e "${YELLOW}Note: Corne42 uses standard ZMK, Glove80 uses Moergo's custom ZMK fork${NC}"
}

build_glove80() {
    echo -e "${BLUE}🏗️  Building Glove80 firmware...${NC}"
    echo -e "${YELLOW}Using Moergo's custom ZMK fork with Nix build system${NC}"
    
    IMAGE=glove80-zmk-config-docker
    
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: Docker not found. Please install Docker to build firmware.${NC}"
        exit 1
    fi

    if [ ! -f "Dockerfile" ]; then
        echo -e "${RED}❌ Error: Dockerfile not found${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Building Docker image...${NC}"
    docker build -t "$IMAGE" .
    
    echo -e "${YELLOW}Running build with branch: $BRANCH${NC}"
    docker run --rm -v "$PWD:/config" -e UID="$(id -u)" -e GID="$(id -g)" -e BRANCH="$BRANCH" "$IMAGE"
    
    if [ -f "glove80.uf2" ]; then
        echo -e "${GREEN}✅ Glove80 firmware built successfully: glove80.uf2${NC}"
        ls -lh glove80.uf2
    else
        echo -e "${RED}❌ Glove80 build failed - no output file found${NC}"
        exit 1
    fi
}

build_corne42() {
    echo -e "${BLUE}🏗️  Building Corne42 firmware...${NC}"
    echo -e "${YELLOW}Using standard ZMK with official Docker container${NC}"
    
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: Docker not found. Please install Docker to build firmware.${NC}"
        exit 1
    fi

    # Check if zmk-config Docker volume exists, create if it doesn't
    if ! docker volume ls | grep -q zmk-config; then
        echo -e "${YELLOW}Creating zmk-config Docker volume...${NC}"
        docker volume create zmk-config
    fi

    # Check if ZMK source exists
    ZMK_PATH="/Users/chris/code/zmk"
    if [ ! -d "$ZMK_PATH" ]; then
        echo -e "${YELLOW}ZMK source not found at $ZMK_PATH, cloning...${NC}"
        mkdir -p "$(dirname "$ZMK_PATH")"
        git clone https://github.com/zmkfirmware/zmk.git "$ZMK_PATH"
    fi

    echo -e "${YELLOW}Building with official ZMK Docker container...${NC}"
    
    # Use the official ZMK Docker image with proper volume mounting
    docker run --rm \
      -v zmk-config:/workspaces/zmk-config \
      -v "$ZMK_PATH:/workspaces/zmk" \
      -w /workspaces/zmk \
      zmkfirmware/zmk-build-arm:3.5-branch \
      /bin/bash -c "
        # Copy current config to the volume (SAFE - no rm commands)
        cp -r $PWD/config/* /workspaces/zmk-config/ 2>/dev/null || true
        
        # Initialize the workspace if not already done
        if [ ! -f .west/config ]; then
          west init -l app/
          west update
        fi
        
        # Change to app directory as required by ZMK documentation
        cd app
        
        echo 'Building Corne42 left half...'
        west build -d build/left -p -b nice_nano_v2 -- \
          -DSHIELD=corne_left \
          -DZMK_CONFIG=/workspaces/zmk-config
        cp build/left/zephyr/zmk.uf2 /workspaces/zmk-config/corne42_left.uf2
        
        echo 'Building Corne42 right half...'
        west build -d build/right -p -b nice_nano_v2 -- \
          -DSHIELD=corne_right \
          -DZMK_CONFIG=/workspaces/zmk-config
        cp build/right/zephyr/zmk.uf2 /workspaces/zmk-config/corne42_right.uf2
        
        echo 'Corne42 firmware built successfully!'
      "

    # Copy the built files back to the host (SAFE)
    docker run --rm -v zmk-config:/workspaces/zmk-config -v "$PWD:/host" alpine:latest \
      sh -c "cp /workspaces/zmk-config/corne42_*.uf2 /host/ 2>/dev/null || true"

    # Verify files were created
    if [ -f "corne42_left.uf2" ] && [ -f "corne42_right.uf2" ]; then
        echo -e "${GREEN}✅ Corne42 firmware built successfully:${NC}"
        ls -lh corne42_*.uf2
    else
        echo -e "${RED}❌ Corne42 build failed - no output files found${NC}"
        exit 1
    fi
}

# Main script logic
case "$KEYBOARD" in
    "glove80")
        build_glove80
        ;;
    "corne42")
        build_corne42
        ;;
    "both")
        echo -e "${BLUE}🏗️  Building firmware for both keyboards...${NC}"
        echo ""
        build_glove80
        echo ""
        build_corne42
        echo ""
        echo -e "${GREEN}🎉 All firmware built successfully!${NC}"
        echo "Output files:"
        ls -lh ./*.uf2 2>/dev/null || echo "No .uf2 files found"
        ;;
    "--help"|"-h"|"help")
        show_help
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Error: Unknown keyboard '$KEYBOARD'${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac