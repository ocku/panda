# config
SITE_CONF_FILE				:= site.json
POSTS_PER_PAGE 				:= 15
# base
DATA_TMP_DIR 	 				:= .data
ROOT_OUT_DIR 	 				:= .dist
TEMPLATE_DIR 					:= templates
FILTER_DIR 	 					:= filters
STATIC_DIR						:= static
POST_SRC_DIR 	 				:= posts
# filters
INDEX_FILTER  				:= $(FILTER_DIR)/index.jq
PAGE_FILTER  					:= $(FILTER_DIR)/page.jq
POST_FILTER  					:= $(FILTER_DIR)/post.jq
# templates
DATA_TEMPLATE_FILE 		:= $(TEMPLATE_DIR)/data.tpl
POST_TEMPLATE_FILE 		:= $(TEMPLATE_DIR)/post.html
INDEX_TEMPLATE_FILE 	:= $(TEMPLATE_DIR)/index.html
# static files
STATIC_FILES 					:= $(shell find $(STATIC_DIR) -type f)
# posts
POST_OUT_DIR  				:= $(ROOT_OUT_DIR)/$(POST_SRC_DIR)
POST_TMP_DIR  				:= $(DATA_TMP_DIR)/$(POST_SRC_DIR)
POST_SRC_FILES  			:= $(wildcard $(POST_SRC_DIR)/*.md)
POST_OUT_FILES  			:= $(addprefix $(ROOT_OUT_DIR)/, $(POST_SRC_FILES:%.md=%.html))
POST_TMP_FILES  			:= $(addprefix $(DATA_TMP_DIR)/, $(POST_SRC_FILES:%.md=%.json))
# data
DATA_TMP_PART_FILE		:= $(DATA_TMP_DIR)/partial.json
DATA_TMP_FILE					:= $(DATA_TMP_DIR)/data.json
# indices
INDEX_PAGE_NUMBER			:= $(shell printf '%d\n' \
														"$$(( $(words $(POST_SRC_FILES)) / $(POSTS_PER_PAGE) ))")

INDEX_TMP_FILES				:= $(addprefix $(DATA_TMP_DIR)/, index.json \
														$(addsuffix .json, $(shell seq 1 $(INDEX_PAGE_NUMBER))))

INDEX_OUT_FILES				:= $(INDEX_TMP_FILES:$(DATA_TMP_DIR)/%.json=$(ROOT_OUT_DIR)/%.html)


panda : $(DATA_TMP_DIR) $(ROOT_OUT_DIR) $(POST_OUT_FILES) $(INDEX_OUT_FILES)

$(ROOT_OUT_DIR)/%.html : $(DATA_TMP_DIR)/%.json $(INDEX_TEMPLATE_FILE)
	pandoc -s --template $(INDEX_TEMPLATE_FILE) --metadata-file $< -o $@ </dev/null

$(INDEX_TMP_FILES) : $(DATA_TMP_FILE)
	jq -f $(PAGE_FILTER) \
		--argjson index "$(subst index,0,${@:$(DATA_TMP_DIR)/%.json=%})" \
		$< > $@

$(DATA_TMP_FILE) : $(DATA_TMP_PART_FILE) $(SITE_CONF_FILE)
	jq -s '.[0] * .[1]' $(SITE_CONF_FILE) $< > $@

$(DATA_TMP_PART_FILE): $(POST_TMP_FILES) 
	jq -f $(INDEX_FILTER) --argjson chunkSize $(POSTS_PER_PAGE) \
		-n $^ > $(DATA_TMP_PART_FILE)

$(POST_TMP_DIR)/%.json : $(POST_SRC_DIR)/%.md $(DATA_TEMPLATE_FILE) $(SITE_CONF_FILE)
	pandoc -s $< --template $(DATA_TEMPLATE_FILE) \
		--metadata-file $(SITE_CONF_FILE) \
		| jq  -f $(POST_FILTER) --arg path "$(@:$(DATA_TMP_DIR)/%.json=/%)" > $@

$(POST_OUT_DIR)/%.html : $(POST_SRC_DIR)/%.md $(POST_TEMPLATE_FILE) $(SITE_CONF_FILE)
	pandoc -s $< --template $(POST_TEMPLATE_FILE) \
		--metadata-file $(SITE_CONF_FILE) -o $@

$(DATA_TMP_DIR):
	mkdir -p $@
	mkdir -p $@/$(POST_SRC_DIR)

$(ROOT_OUT_DIR): $(STATIC_FILES)
	mkdir -p $@
	mkdir -p $@/$(POST_SRC_DIR)
	cp -r $(STATIC_DIR)/* $(ROOT_OUT_DIR)

.PHONY: clean
clean:
	rm -rf $(ROOT_OUT_DIR)
	rm -rf $(DATA_TMP_DIR)

.PHONY: post
URL=$(shell printf "$(title)" \
	| tr [A-Z] [a-z] \
	| tr -cd '[:alnum:] [:space:]' \
	| tr '[:space:]' '-')

post:
ifneq ($(wildcard $(POST_SRC_DIR)/$(URL).md),)
	@echo "[e] A post with url=$(URL)" already exists
	@exit 1
else
	printf -- "---\ntitle: %s\ndate: %s\nsort: %d\n---\n" \
			"$(title)" "$(shell date '+%F')" "$(shell date '+%s')" > "$(POST_SRC_DIR)/$(URL).md"
endif