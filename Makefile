# ZMK Config Makefile
# Provides convenient commands for keymap alignment, testing, and building

PYTHON := python3
ALIGN_SCRIPT := align_keymap.py
CONFIG_DIR := config
TESTS_DIR := tests

CORNE_KEYMAP := $(CONFIG_DIR)/corne.keymap
CORNE_LAYOUT := corne_layout.json
CORNE_DRAWER_YAML := corne_keymap.yaml
CORNE_SVG := corne_keymap.svg

GLOVE80_KEYMAP := $(CONFIG_DIR)/glove80.keymap
GLOVE80_LAYOUT := glove80_layout.json
GLOVE80_DRAWER_YAML := glove80_keymap.yaml
GLOVE80_SVG := glove80_keymap.svg

TEST_DIR := $(TESTS_DIR)
PYTEST_FILE := $(TESTS_DIR)/test_align_keymap.py

.PHONY: help align-glove80 align-corne align sync sync-glove80 sync-corne draw draw-glove80 draw-corne test test-verbose build build-glove80 build-corne clean

# Default target - show help
help:
	@echo "ZMK Config Makefile"
	@echo "==================="
	@echo ""
	@echo "Workflows:"
	@echo "  sync           - align + draw + build (both keyboards)"
	@echo "  sync-glove80   - align + draw + build (Glove80)"
	@echo "  sync-corne     - align + draw + build (Corne)"
	@echo ""
	@echo "Individual Tasks:"
	@echo "  align          - Align both keymaps"
	@echo "  align-glove80  - Align Glove80 keymap"
	@echo "  align-corne    - Align Corne keymap"
	@echo "  draw           - Generate both SVGs from YAML"
	@echo "  draw-glove80   - Generate Glove80 SVG from YAML"
	@echo "  draw-corne     - Generate Corne SVG from YAML"
	@echo "  build          - Build both firmwares"
	@echo "  build-glove80  - Build Glove80 firmware"
	@echo "  build-corne    - Build Corne firmware"
	@echo "  test           - Run test suite"
	@echo "  test-verbose   - Run tests with verbose output"
	@echo "  clean          - Remove temp files and UF2s"

align-glove80:
	@$(PYTHON) $(ALIGN_SCRIPT) --keymap $(GLOVE80_KEYMAP) --layout $(GLOVE80_LAYOUT)
	@echo "✅ Glove80 keymap aligned"

align-corne:
	@$(PYTHON) $(ALIGN_SCRIPT) --keymap $(CORNE_KEYMAP) --layout $(CORNE_LAYOUT)
	@echo "✅ Corne keymap aligned"

align: align-glove80 align-corne

test:
	@uv run pytest $(PYTEST_FILE) -v

test-verbose:
	@uv run pytest $(PYTEST_FILE) -vvv --tb=long

build: build-glove80 build-corne

build-glove80:
	@./build.sh glove80
	@echo "✅ Glove80 firmware built"

build-corne:
	@./build.sh corne
	@echo "✅ Corne firmware built"

draw: draw-glove80 draw-corne

draw-glove80:
	@keymap -c keymap_drawer.config.yaml draw $(GLOVE80_DRAWER_YAML) > $(GLOVE80_SVG)
	@echo "✅ $(GLOVE80_SVG)"

draw-corne:
	@keymap -c keymap_drawer.config.yaml draw $(CORNE_DRAWER_YAML) > $(CORNE_SVG)
	@echo "✅ $(CORNE_SVG)"

clean:
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name "*~" -delete 2>/dev/null || true
	@rm -f ./*.uf2 2>/dev/null || true
	@echo "✅ Cleaned"

sync: align draw build
	@echo "✅ Sync complete"

sync-glove80: align-glove80 draw-glove80 build-glove80
	@echo "✅ Glove80 sync complete"

sync-corne: align-corne draw-corne build-corne
	@echo "✅ Corne sync complete"
