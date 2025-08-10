# ZMK Glove80 Makefile
# Simple commands to build your custom ZMK firmware

.PHONY: build build-left build-right clean help

# Docker image
DOCKER_IMAGE := zmkfirmware/zmk-build-arm:stable

help: ## Show this help message
	@echo "ZMK Glove80 Build Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build firmware for both left and right sides
	@echo "🧹 Cleaning previous build artifacts..."
	@rm -rf build/
	@echo "✅ Build directory cleaned"
	@echo "🚀 Building both sides..."
	@./build.sh

build-left: ## Build firmware for left side only
	@echo "🔨 Building left side..."
	@./build-left.sh

build-right: ## Build firmware for right side only  
	@echo "🔨 Building right side..."
	@./build-right.sh

clean: ## Clean all build artifacts
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf build/
	@echo "✅ Build directory cleaned"

update: ## Update ZMK dependencies
	@echo "🔄 Updating ZMK dependencies..."
	@docker run --rm -it \
		-v "${PWD}":/app \
		-w /app \
		$(DOCKER_IMAGE) \
		west update
	@echo "✅ Dependencies updated"

test: ## Test build without creating artifacts (quick syntax check)
	@echo "🧪 Testing keymap syntax..."
	@docker run --rm \
		-v "${PWD}":/app \
		-w /app \
		$(DOCKER_IMAGE) \
		bash -c "west zephyr-export && west build -d /tmp/test -s zmk/app -b glove80_lh -- -DZMK_CONFIG=/app/config"
	@echo "✅ Keymap syntax is valid"
