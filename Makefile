SHELL := /bin/bash

.PHONY: validate enforce_tags schema yaml_syntax enforce_teams

schema:
				@for file in `find /rules/ -type f \( -name "*.yaml" -or -name "*.yml" \)` ; do \
                echo "Testing schema for rule $$file" ; \
                elastalert-test-rule --schema-only $$file ; \
        done ;

yaml_syntax:
				@for file in `find /rules/ -type f \( -name "*.yaml" -or -name "*.yml" \)` ; do \
                echo "Testing Yaml syntax for rule $$file" ; \
                cat $$file | yq . >/dev/null 2>/dev/null ; \
        done ; 
				@echo ""

enforce_tags:
				@for file in `find /rules/ -type f \( -name "*.yaml" -or -name "*.yml" \)` ; do \
                echo "Testing rule $$file for TAGS" ; \
                cat $$file | yq .opsgenie_tags -e >/dev/null 2>/dev/null ; \
                if [ $$? -ne 1 ]; then \
                        echo "ERROR: You should not specify any tag for opsgenie in your rules - those are set in the common config" && exit 1 ; \
                fi \
        done
				@echo ""

enforce_teams:
				@for file in `find /rules/ -type f \( -name "*.yaml" -or -name "*.yml" \)` ; do \
                echo "Testing rule $$file for TEAM" ; \
                cat $$file | yq .opsgenie_teams -e >/dev/null 2>/dev/null ; \
                if [ $$? -ne 0 ]; then \
                        echo "ERROR: You MUST specify a team for opsgenie in your rule" && exit 1 ; \
                fi \
        done
				@echo ""

validate:  schema yaml_syntax enforce_tags enforce_teams
        @echo "All Validations passed"
