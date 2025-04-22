.PHONY: all validate clean generate-subcharts


BASE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
GENERATED_DIR := $(BASE_DIR)output

SUBCHART_YAML := config.yaml
SUBCHART_PAIRS := $(shell yq e -o=json '.subcharts[] | [.name, .workload] | @tsv' $(SUBCHART_YAML))
UMBRELLA_NAME := $(shell yq e '.umbrellaChartName' $(SUBCHART_YAML))

# Default target
all: template

# Create necessary directories
prepare:
	@mkdir -p $(GENERATED_DIR)
	@mkdir -p $(BASE_DIR)/output

# Generate manifests using helm template
generate: prepare
	cd $(BASE_DIR)templates/umbrella
	echo $(BASE_DIR)templates/umbrella
	@KUBECTL_SLICE_OPTS=$(KUBECTL_SLICE_OPTS)
	@echo "\nRunning helm template command to generate manifests..."
	echo $(realpath .)
	helm template -g $(realpath .)/templates/umbrella | kubectl slice -$(SLICE_OPTS)o $(GENERATED_DIR) $(DRY_RUN) --include-triple-dash --skip-non-k8s

# Validate YAML files using kubeconform
template: generate-subcharts
	helm template -g $(GENERATED_DIR)

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
#kubeconform -verbose -output json $$file || echo "failed to validate $$file"; \


generate-subcharts:
	@rm -rf $(GENERATED_DIR)/*
	@echo "Generating new Chart.yaml..."
	@cp -r $(BASE_DIR)/templates/umbrella/* output/
	@echo "Generating subcharts based on subcharts.yaml..."
	@for line in $(SUBCHART_PAIRS); do \
		name=$$(echo $$line | cut -f1); \
		workload=$$(echo $$line | cut -f2); \
		echo " - Creating subchart '$$name' with workload '$$workload'..."; \
		cp -r templates/subchart output/charts/$$name; \
		cd output/charts/$$name; \
		find . -type f -exec sed -i '' "s/component/$$name/g" {} +; \
		cd - > /dev/null; \
	done
	find  output -d 4
	$(MAKE) generate-dependencies




#cat $(GENERATED_DIR)/Chart.yaml | awk 'BEGIN { f=0 } { if (f==0) print; if ($$0 ~ /^dependencies:/) f=1 }' >> $$CHARTFILE; 
generate-dependencies:
	@echo "Regenerating dependencies section in Chart.yaml..."
	yq e '.subcharts[] | [{ "name": .name,  "version": "0.1.0", "repository": "file://./charts/"+.name }]' config.yaml >> $(GENERATED_DIR)/Chart.yaml

SED_I = $(shell if sed --version 2>/dev/null | grep -q GNU; then echo "-i"; else echo "-i ''"; fi)

rename-umbrella:
	@echo "Renaming umbrella chart from 'umbrella-chart' to '$(UMBRELLA_NAME)'..."
	@find output -type f \( -name "*.yaml" -o -name "*.tpl" -o -name "Makefile" \) -exec sed $(SED_I) "s/umbrella-chart/$(UMBRELLA_NAME)/g" {} +
	@sed $(SED_I) "s/^name: umbrella-chart/name: $(UMBRELLA_NAME)/" output/Chart.yaml

