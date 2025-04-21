.PHONY: all validate clean

BASE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
GENERATED_DIR := $(BASE_DIR)tests/generated

# Default target
all: validate

# Create necessary directories
prepare:
	@mkdir -p $(GENERATED_DIR)
	@mkdir -p $(BASE_DIR)/tests/generated.last

# Generate manifests using helm template
generate: prepare
	@cd $(BASE_DIR)
	@echo "\nRunning helm template command to generate manifests..."
	@helm template -g . | kubectl slice -o $(GENERATED_DIR)

# Validate YAML files using kubeconform
validate: generate
	@echo "\nRunning kubeconform to validate manifests..."
	@YAML_FILES=$$(find $(GENERATED_DIR) -type f -name '*.yaml'); \
	if [ -z "$$YAML_FILES" ]; then \
		echo "No YAML files found to validate."; \
	else \
		for file in $$YAML_FILES; do \
			echo "Validating $$file..."; \
			/home/linuxbrew/.linuxbrew/bin/kubeconform "$$file"; \
		done; \
	fi
	@echo "\nTests Complete!"
	@$(MAKE) --no-print-directory clean

# Clean up and move files
clean:
	@rm -rf $(BASE_DIR)/tests/generated.last/* || true
	@mv $(GENERATED_DIR)/* $(BASE_DIR)/tests/generated.last/ || true
