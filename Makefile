# ZMK Config Makefile
# Provides convenient commands for keymap alignment, testing, and building

PYTHON := python3
ALIGN_SCRIPT := align_keymap.py
CONFIG_DIR := config
TESTS_DIR := tests

# Keymap files
GLOVE80_KEYMAP := $(CONFIG_DIR)/glove80.keymap
CORNE42_KEYMAP := $(CONFIG_DIR)/corne42.keymap

# Layout files
GLOVE80_LAYOUT := glove80_layout.json
CORNE42_LAYOUT := corne42_layout.json

# Test files
TEST_SCRIPT := $(TESTS_DIR)/test_align_keymap.py

.PHONY: help align-glove80 align-corne42 align test build clean

# Default target - show help
help:
	@echo "ZMK Config Makefile"
	@echo "==================="
	@echo ""
	@echo "Available targets:"
	@echo "  align-glove80  - Align Glove80 keymap in place"
	@echo "  align-corne42  - Align Corne42 keymap in place" 
	@echo "  align          - Align both keymaps"
	@echo "  test           - Run the test suite"
	@echo "  build          - Build firmware using Docker"
	@echo "  clean          - Clean up temporary files"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make align-glove80"
	@echo "  make align"
	@echo "  make test"
	@echo "  make build"

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
	@echo "🧪 Running test suite..."
	@if [ ! -f "$(TEST_SCRIPT)" ]; then \
		echo "❌ Error: $(TEST_SCRIPT) not found"; \
		exit 1; \
	fi
	$(PYTHON) $(TEST_SCRIPT)
	@echo "✅ All tests passed!"

# Build firmware using Docker
build:
	@echo "🏗️  Building firmware..."
	@if [ ! -f "build.sh" ]; then \
		echo "❌ Error: build.sh not found"; \
		exit 1; \
	fi
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "❌ Error: Docker not found. Please install Docker to build firmware."; \
		exit 1; \
	fi
	./build.sh
	@echo "✅ Firmware build completed!"

# Clean up temporary files
clean:
	@echo "🧹 Cleaning up temporary files..."
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name "*~" -delete 2>/dev/null || true
	@echo "✅ Cleanup completed!"

# Convenience targets
glove80: align-glove80
corne42: align-corne42
