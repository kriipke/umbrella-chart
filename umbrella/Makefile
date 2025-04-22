.PHONY: all validate clean generate-subcharts


BASE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
GENERATED_DIR := $(BASE_DIR)tests/generated

SUBCHART_YAML := ../subcharts.yaml
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



generate-subcharts:
	@echo "Using subcharts from $(SUBCHART_YAML): $(SUBCHARTS)"

	@echo "Removing obsolete subcharts from ./charts/..."
	@for dir in charts/*; do \
		name=$$(basename $$dir); \
		if [ -d "$$dir" ] && ! echo "$(SUBCHARTS)" | grep -wq "$$name"; then \
			echo "  - Removing unused subchart $$name"; \
			rm -rf "$$dir"; \
		fi; \
	done

	@echo "Removing existing subcharts to regenerate clean copies..."
	@for name in $(SUBCHARTS); do \
		if [ -d "charts/$$name" ]; then \
			echo "  - Removing existing charts/$$name"; \
			rm -rf "charts/$$name"; \
		fi; \
	done

	@echo "Cleaning subchart dependencies in Chart.yaml..."
	@awk '\
		BEGIN { skip = 0 } \
		/^dependencies:/ { print; next } \
		/^- name:/ { skip = 1; next } \
		/^  / { if (!skip) print; next } \
		{ print }' Chart.yaml > Chart.yaml.tmp && mv Chart.yaml.tmp Chart.yaml

	@echo "Generating fresh subcharts from component..."
	@for name in $(SUBCHARTS); do \
		echo "  - Creating charts/$$name"; \
		cp -r ../subchart charts/$$name; \
		cd charts/$$name; \
		find . -type f -exec sed -i '' "s/component/$$name/g" {} +; \
		cd - > /dev/null; \
		echo "  - name: $$name" >> .chart.tmp; \
		echo "    version: \"0.1.0\"" >> .chart.tmp; \
		echo "    repository: \"file://./charts/$$name\"" >> .chart.tmp; \
	done

	@if [ -f .chart.tmp ]; then \
		echo "Re-inserting dependencies into Chart.yaml..."; \
		echo "dependencies:" > deps.tmp; \
		cat .chart.tmp >> deps.tmp; \
		awk '!/^dependencies:/' Chart.yaml >> deps.tmp; \
		mv deps.tmp Chart.yaml; \
		rm .chart.tmp; \
	fi

