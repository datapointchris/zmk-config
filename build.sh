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
    echo "  corne     - Build only Corne firmware"  
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
    echo "  $0 corne             # Build Corne"
    echo "  $0 both              # Build both keyboards"
    echo ""
    echo -e "${YELLOW}Note: Corne uses standard ZMK, Glove80 uses Moergo's custom ZMK fork${NC}"
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

build_corne() {
    echo -e "${BLUE}🏗️  Building Corne firmware...${NC}"
    echo -e "${YELLOW}Using standard ZMK with official Docker container${NC}"
    
    # Check timestamps before build
    left_old_ts=""
    right_old_ts=""
    if [ -f "corne_left.uf2" ]; then
        left_old_ts=$(stat -f "%m" corne_left.uf2)
    fi
    if [ -f "corne_right.uf2" ]; then
        right_old_ts=$(stat -f "%m" corne_right.uf2)
    fi
    
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: Docker not found. Please install Docker to build firmware.${NC}"
        exit 1
    fi

    # Get absolute path to current directory for bind mounting
    ZMK_CONFIG_PATH="$(pwd)"
    
    # Check if ZMK source exists
    ZMK_PATH="/Users/chris/code/zmk"
    if [ ! -d "$ZMK_PATH" ]; then
        echo -e "${YELLOW}ZMK source not found at $ZMK_PATH, cloning...${NC}"
        mkdir -p "$(dirname "$ZMK_PATH")"
        git clone https://github.com/zmkfirmware/zmk.git "$ZMK_PATH"
    fi

    # Create/recreate the zmk-config volume as a bind mount (following official docs)
    echo -e "${YELLOW}Setting up zmk-config volume as bind mount...${NC}"
    docker volume ls | grep -q zmk-config && docker volume rm zmk-config >/dev/null 2>&1 || true
    docker volume create --driver local \
      -o o=bind \
      -o type=none \
      -o device="$ZMK_CONFIG_PATH" \
      zmk-config

    echo -e "${YELLOW}Building with official ZMK Docker container...${NC}"
    
    # Use the official ZMK Docker image with proper bind-mounted volume
    docker run --rm \
      -v zmk-config:/workspaces/zmk-config \
      -v "$ZMK_PATH:/workspaces/zmk" \
      -w /workspaces/zmk \
      zmkfirmware/zmk-build-arm:3.5-branch \
      /bin/bash -c "
        # Initialize the workspace if not already done
        if [ ! -f .west/config ]; then
          west init -l app/
          west update
        fi
        
        # Change to app directory as required by ZMK documentation
        cd app
        
        echo 'Building Corne left half...'
        west build -d build/left -p -b nice_nano_v2 -- \
          -DSHIELD='corne_left nice_view_adapter nice_view' \
          -DZMK_CONFIG=/workspaces/zmk-config/config
        cp build/left/zephyr/zmk.uf2 /workspaces/zmk-config/corne_left.uf2
        
        echo 'Building Corne right half...'
        west build -d build/right -p -b nice_nano_v2 -- \
          -DSHIELD='corne_right nice_view_adapter nice_view' \
          -DZMK_CONFIG=/workspaces/zmk-config/config
        cp build/right/zephyr/zmk.uf2 /workspaces/zmk-config/corne_right.uf2
        
        echo 'Corne firmware built successfully!'
      "

    # Verify files were created and timestamps changed
    if [ -f "corne_left.uf2" ] && [ -f "corne_right.uf2" ]; then
        left_new_ts=$(stat -f "%m" corne_left.uf2)
        right_new_ts=$(stat -f "%m" corne_right.uf2)
        left_human=$(stat -f "%Sm" corne_left.uf2)
        right_human=$(stat -f "%Sm" corne_right.uf2)
        if [ "$left_new_ts" = "$left_old_ts" ] || [ "$right_new_ts" = "$right_old_ts" ]; then
            echo -e "${RED}❌ Corne build failed or did not update UF2 files. Timestamp unchanged.${NC}"
            echo -e "Left: $left_human | Right: $right_human"
            exit 1
        fi
        echo -e "${GREEN}✅ Corne firmware built successfully:${NC}"
        echo "Left UF2: $left_human"
        echo "Right UF2: $right_human"
        ls -lh corne_*.uf2
    else
        echo -e "${RED}❌ Corne build failed - no output files found${NC}"
        exit 1
    fi
}

# Main script logic
case "$KEYBOARD" in
    "glove80")
        build_glove80
        ;;
    "corne")
        build_corne
        ;;
    "both")
        echo -e "${BLUE}🏗️  Building firmware for both keyboards...${NC}"
        echo ""
        build_glove80
        echo ""
        build_corne
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