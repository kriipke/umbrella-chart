.PHONY: all validate clean generate-subcharts


BASE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
GENERATED_DIR := $(BASE_DIR)tests/generated

SUBCHART_YAML := subcharts.yaml
SUBCHARTS := $(shell yq e '.subcharts[]' $(SUBCHART_YAML))

# Default target
all: template

# Create necessary directories
prepare:
	@mkdir -p $(GENERATED_DIR)
	@mkdir -p $(BASE_DIR)/tests/generated.last
	@rm -rf $(BASE_DIR)/tests/generated.last/*

# Generate manifests using helm template
generate: prepare
	@cd $(BASE_DIR)
	@KUBECTL_SLICE_OPTS=$(KUBECTL_SLICE_OPTS)
	@echo "\nRunning helm template command to generate manifests..."
	@helm template -g . | kubectl slice -$(SLICE_OPTS)o $(GENERATED_DIR) $(DRY_RUN) --include-triple-dash --skip-non-k8s

# Validate YAML files using kubeconform
template: 
	@$(MAKE) KUBECTL_SLICE_OPTS="q" STDOUT="--stdout" --no-print-directory generate
	@cat $(GENERATED_DIR)/*
	@$(MAKE) --no-print-directory clean

# Validate YAML files using kubeconform
test: generate
	@echo "\nRunning kubeconform to validate manifests..."
	@YAML_FILES=$$(find $(GENERATED_DIR) -type f -name '*.yaml'); \
	if [ -z "$$YAML_FILES" ]; then \
		echo "No YAML files found to validate."; \
	else \
			echo "Validating $(GENERATED_DIR)..."; \
			kubeconform -verbose -summary -output json $(GENERATED_DIR); \
	fi
	@echo "\nTests Complete!"
	@$(MAKE) --no-print-directory clean
#kubeconform -verbose -output json $$file || echo "failed to validate $$file"; \

# Clean up and move files
clean:
	@rm -rf $(BASE_DIR)/tests/generated.last/* || true
	@mv $(GENERATED_DIR)/* $(BASE_DIR)/tests/generated.last/ || true
