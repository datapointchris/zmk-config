# ZMK Config Makefile
# Provides convenient commands for keymap alignment, testing, and building

PYTHON := python3
ALIGN_SCRIPT := align_keymap.py
CONFIG_DIR := config
TESTS_DIR := tests

# Keymap files
GLOVE80_KEYMAP := $(CONFIG_DIR)/glove80.keymap
CORNE42_KEYMAP := $(CONFIG_DIR)/corne.keymap

# Layout files
GLOVE80_LAYOUT := glove80_layout.json
CORNE42_LAYOUT := corne42_layout.json

# Test files
TEST_DIR := $(TESTS_DIR)
PYTEST_FILE := $(TESTS_DIR)/test_align_keymap.py

.PHONY: help align-glove80 align-corne42 align test test-verbose build build-glove80 build-corne42 clean

# Default target - show help
help:
	@echo "ZMK Config Makefile"
	@echo "==================="
	@echo ""
	@echo "Available targets:"
	@echo "  align-glove80  - Align Glove80 keymap in place"
	@echo "  align-corne42  - Align Corne42 keymap in place" 
	@echo "  align          - Align both keymaps"
	@echo "  test           - Run the test suite with pytest"
	@echo "  test-verbose   - Run tests with detailed output" 
	@echo "  build          - Build firmware for both keyboards"
	@echo "  build-glove80  - Build only Glove80 firmware"
	@echo "  build-corne42  - Build only Corne42 firmware"
	@echo "  clean          - Clean up temporary files and UF2 outputs"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "Build Examples:"
	@echo "  make build              # Build both keyboards"
	@echo "  make build-glove80      # Build Glove80 only"
	@echo "  make build-corne42      # Build Corne42 only"
	@echo ""
	@echo "Build Differences:"
	@echo "  Glove80: Uses Moergo's custom ZMK fork with Nix"
	@echo "  Corne42: Uses standard ZMK with official Docker container"

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

# Align Corne42 keymap in place
align-corne42:
	@echo "🔧 Aligning Corne42 keymap..."
	@if [ ! -f "$(CORNE42_KEYMAP)" ]; then \
		echo "❌ Error: $(CORNE42_KEYMAP) not found"; \
		exit 1; \
	fi
	@if [ ! -f "$(CORNE42_LAYOUT)" ]; then \
		echo "❌ Error: $(CORNE42_LAYOUT) not found"; \
		exit 1; \
	fi
	$(PYTHON) $(ALIGN_SCRIPT) --keymap $(CORNE42_KEYMAP) --layout $(CORNE42_LAYOUT)
	@echo "✅ Corne42 keymap aligned successfully"

# Align both keymaps
align: align-glove80 align-corne42
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

# Build only Corne42 firmware
build-corne42:
	@echo "🏗️  Building Corne42 firmware..."
	@if [ ! -f "build.sh" ]; then \
		echo "❌ Error: build.sh not found"; \
		exit 1; \
	fi
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "❌ Error: Docker not found. Please install Docker to build firmware."; \
		exit 1; \
	fi
	./build.sh corne42
	@echo "✅ Corne42 firmware build completed!"

# Clean up temporary files and build outputs
clean:
	@echo "🧹 Cleaning up temporary files..."
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name "*~" -delete 2>/dev/null || true
	@rm -f ./*.uf2 2>/dev/null || true
	@echo "✅ Cleanup completed!"

# Convenience targets
glove80: align-glove80
corne42: align-corne42
