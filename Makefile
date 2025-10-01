# ZMK Config Makefile
# Provides convenient commands for keymap alignment, testing, and building

PYTHON := python3
ALIGN_SCRIPT := align_keymap.py
CONFIG_DIR := config
TESTS_DIR := tests

# Keymap files
GLOVE80_KEYMAP := $(CONFIG_DIR)/glove80.keymap
CORNE_KEYMAP := $(CONFIG_DIR)/corne.keymap

# Layout files
GLOVE80_LAYOUT := glove80_layout.json
CORNE_LAYOUT := corne_layout.json

# Drawer yaml files
GLOVE80_DRAWER_YAML := glove80_keymap.yaml
CORNE_DRAWER_YAML := corne_keymap.yaml

# SVG output files
GLOVE80_SVG := glove80_keymap.svg
CORNE_SVG := corne_keymap.svg

# Test files
TEST_DIR := $(TESTS_DIR)
PYTEST_FILE := $(TESTS_DIR)/test_align_keymap.py

.PHONY: help align-glove80 align-corne align sync sync-glove80 sync-corne draw draw-glove80 draw-corne test test-verbose build build-glove80 build-corne clean

# Default target - show help
help:
	@echo "ZMK Config Makefile"
	@echo "==================="
	@echo ""
	@echo "Available targets:"
	@echo "  sync           - Complete workflow: align, draw, and build for both keyboards"
	@echo "  sync-glove80   - Complete workflow for Glove80 only (align + draw + build)"
	@echo "  sync-corne     - Complete workflow for Corne only (align + draw + build)"
	@echo "  align-glove80  - Align Glove80 keymap in place"
	@echo "  align-corne    - Align Corne keymap in place" 
	@echo "  align          - Align both keymaps"
	@echo "  draw-glove80   - Generate SVG diagram for Glove80"
	@echo "  draw-corne     - Generate SVG diagram for Corne"
	@echo "  draw           - Generate SVG diagrams for both keyboards"
	@echo "  test           - Run the test suite with pytest"
	@echo "  test-verbose   - Run tests with detailed output" 
	@echo "  build          - Build firmware for both keyboards"
	@echo "  build-glove80  - Build only Glove80 firmware"
	@echo "  build-corne    - Build only Corne firmware"
	@echo "  clean          - Clean up temporary files and UF2 outputs"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "Workflow Examples:"
	@echo "  make sync               # Complete workflow for both keyboards"
	@echo "  make sync-glove80       # Complete workflow for Glove80 only"
	@echo "  make sync-corne         # Complete workflow for Corne only"
	@echo ""
	@echo "Build Examples:"
	@echo "  make build              # Build both keyboards"
	@echo "  make build-glove80      # Build Glove80 only"
	@echo "  make build-corne        # Build Corne only"
	@echo ""
	@echo "Build Differences:"
	@echo "  Glove80: Uses Moergo's custom ZMK fork with Nix"
	@echo "  Corne: Uses standard ZMK with official Docker container"

# Align Glove80 keymap in place
align-glove80:
	@echo "🔧 Aligning Glove80 keymap..."
	@if [ ! -f "$(GLOVE80_KEYMAP)" ]; then \
		echo "❌ Error: $(GLOVE80_KEYMAP) not found"; \
		exit 1; \
	fi
	@if [ ! -f "$(GLOVE80_LAYOUT)" ]; then \
		echo "❌ Error: $(GLOVE80_LAYOUT) not found"; \
		exit 1; \
	fi
	$(PYTHON) $(ALIGN_SCRIPT) --keymap $(GLOVE80_KEYMAP) --layout $(GLOVE80_LAYOUT)
	@echo "✅ Glove80 keymap aligned successfully"

# Align Corne keymap in place
align-corne:
	@echo "🔧 Aligning Corne keymap..."
	@if [ ! -f "$(CORNE_KEYMAP)" ]; then \
		echo "❌ Error: $(CORNE_KEYMAP) not found"; \
		exit 1; \
	fi
	@if [ ! -f "$(CORNE_LAYOUT)" ]; then \
		echo "❌ Error: $(CORNE_LAYOUT) not found"; \
		exit 1; \
	fi
	$(PYTHON) $(ALIGN_SCRIPT) --keymap $(CORNE_KEYMAP) --layout $(CORNE_LAYOUT)
	@echo "✅ Corne keymap aligned successfully"

# Align both keymaps
align: align-glove80 align-corne
	@echo "🎉 All keymaps aligned successfully!"

# Run tests
test:
	@echo "🧪 Running test suite with pytest..."
	@if [ ! -f "$(PYTEST_FILE)" ]; then \
		echo "❌ Error: $(PYTEST_FILE) not found"; \
		exit 1; \
	fi
	@if command -v uv >/dev/null 2>&1; then \
		uv run pytest $(PYTEST_FILE) -v; \
	else \
		$(PYTHON) -m pytest $(PYTEST_FILE) -v; \
	fi
	@echo "✅ All tests passed!"

# Run tests with extra verbose output
test-verbose:
	@echo "🧪 Running test suite with verbose output..."
	@if command -v uv >/dev/null 2>&1; then \
		uv run pytest $(PYTEST_FILE) -vvv --tb=long; \
	else \
		$(PYTHON) -m pytest $(PYTEST_FILE) -vvv --tb=long; \
	fi

# Build firmware for both keyboards
build:
	@echo "🏗️  Building firmware for both keyboards..."
	@if [ ! -f "build.sh" ]; then \
		echo "❌ Error: build.sh not found"; \
		exit 1; \
	fi
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "❌ Error: Docker not found. Please install Docker to build firmware."; \
		exit 1; \
	fi
	./build.sh both
	@echo "✅ Firmware build completed!"

# Build only Glove80 firmware
build-glove80:
	@echo "🏗️  Building Glove80 firmware..."
	@if [ ! -f "build.sh" ]; then \
		echo "❌ Error: build.sh not found"; \
		exit 1; \
	fi
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "❌ Error: Docker not found. Please install Docker to build firmware."; \
		exit 1; \
	fi
	./build.sh glove80
	@echo "✅ Glove80 firmware build completed!"

# Build only Corne firmware
build-corne:
	@echo "🏗️  Building Corne firmware..."
	@if [ ! -f "build.sh" ]; then \
		echo "❌ Error: build.sh not found"; \
		exit 1; \
	fi
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "❌ Error: Docker not found. Please install Docker to build firmware."; \
		exit 1; \
	fi
	./build.sh corne
	@echo "✅ Corne firmware build completed!"

# Create keymap-drawer drawings
draw:
	@echo "Generating keymap drawings..."
	keymap -c keymap_drawer.config.yaml parse -c 12 -z $(GLOVE80_KEYMAP) > $(GLOVE80_DRAWER_YAML)
	keymap -c keymap_drawer.config.yaml draw $(GLOVE80_DRAWER_YAML) > $(GLOVE80_SVG)
	@echo "Glove80 drawing yaml generated: $(GLOVE80_DRAWER_YAML)"
	@echo "Glove80 SVG generated: $(GLOVE80_SVG)"
	
	keymap -c keymap_drawer.config.yaml parse -c 6 -z $(CORNE_KEYMAP) > $(CORNE_DRAWER_YAML)
	keymap -c keymap_drawer.config.yaml draw $(CORNE_DRAWER_YAML) > $(CORNE_SVG)
	@echo "Corne drawing yaml generated: $(CORNE_DRAWER_YAML)"
	@echo "Corne SVG generated: $(CORNE_SVG)"
	@echo "✅ Keymap drawings generated successfully"

draw-glove80:
	@echo "Generating Glove80 keymap drawing..."
	keymap -c keymap_drawer.config.yaml parse -c 12 -z $(GLOVE80_KEYMAP) > $(GLOVE80_DRAWER_YAML)
	keymap -c keymap_drawer.config.yaml draw $(GLOVE80_DRAWER_YAML) > $(GLOVE80_SVG)
	@echo "Glove80 drawing yaml generated: $(GLOVE80_DRAWER_YAML)"
	@echo "Glove80 SVG generated: $(GLOVE80_SVG)"
	@echo "✅ Glove80 keymap drawing generated successfully"

draw-corne:
	@echo "Generating Corne keymap drawing..."
	keymap -c keymap_drawer.config.yaml parse -c 6 -z $(CORNE_KEYMAP) > $(CORNE_DRAWER_YAML)
	keymap -c keymap_drawer.config.yaml draw $(CORNE_DRAWER_YAML) > $(CORNE_SVG)
	@echo "Corne drawing yaml generated: $(CORNE_DRAWER_YAML)"
	@echo "Corne SVG generated: $(CORNE_SVG)"
	@echo "✅ Corne keymap drawing generated successfully"

# Clean up temporary files and build outputs
clean:
	@echo "🧹 Cleaning up temporary files..."
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name "*~" -delete 2>/dev/null || true
	@rm -f ./*.uf2 2>/dev/null || true
	@echo "✅ Cleanup completed!"

# Run all commands to sync
sync:
	@echo "🚀 Starting sync process..."
	@start_time=$$(date +%s); \
	if $(MAKE) align draw build; then \
		end_time=$$(date +%s); \
		elapsed=$$((end_time - start_time)); \
		minutes=$$((elapsed / 60)); \
		seconds=$$((elapsed % 60)); \
		echo "🎉 All tasks completed successfully!"; \
		echo "⏱️  Total time: $${minutes}m $${seconds}s"; \
	else \
		echo "❌ Sync failed - one or more tasks encountered an error"; \
		exit 1; \
	fi

sync-glove80:
	@echo "🚀 Starting Glove80 sync process..."
	@start_time=$$(date +%s); \
	if $(MAKE) align-glove80 draw-glove80 build-glove80; then \
		end_time=$$(date +%s); \
		elapsed=$$((end_time - start_time)); \
		minutes=$$((elapsed / 60)); \
		seconds=$$((elapsed % 60)); \
		echo "🎉 Glove80 tasks completed successfully!"; \
		echo "⏱️  Total time: $${minutes}m $${seconds}s"; \
	else \
		echo "❌ Glove80 sync failed - one or more tasks encountered an error"; \
		exit 1; \
	fi

sync-corne:
	@echo "🚀 Starting Corne sync process..."
	@start_time=$$(date +%s); \
	if $(MAKE) align-corne draw-corne build-corne; then \
		end_time=$$(date +%s); \
		elapsed=$$((end_time - start_time)); \
		minutes=$$((elapsed / 60)); \
		seconds=$$((elapsed % 60)); \
		echo "🎉 Corne tasks completed successfully!"; 	\
		echo "⏱️  Total time: $${minutes}m $${seconds}s"; \
	else \
		echo "❌ Corne sync failed - one or more tasks encountered an error"; \
		exit 1; \
	fi