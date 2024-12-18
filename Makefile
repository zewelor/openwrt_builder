define run_compose_target
	docker compose pull $(1) ; docker compose run --rm $(1)
endef

BASE=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

SERVICES := $(shell docker compose config --services)

# Include .env
ifneq (,$(wildcard ./.env))
	include .env
  export
endif

# all: clean ap_michal ap_basement summerhouse_rack x0
all: clean $(SERVICES)

ap_michal:
	$(call run_compose_target,$@)

ap_basement:
	$(call run_compose_target,$@)

summerhouse_router:
	$(call run_compose_target,$@)

# travel_router:
# 	$(call run_compose_target,$@)

x0:
	$(call run_compose_target,$@)

parents_router:
	$(call run_compose_target,$@)

portosanto_router:
	$(call run_compose_target,$@)

# build_new_builder:
# 	# apt-get install signify-openbsd
# 	cd openwrt-docker-builder ; BRANCH=19.07.3 TARGET=ramips-mt7621 GNUPGHOME=~/.gnupg/ ./docker-imagebuilder.sh

clean:
	rm -rf ${BASE}output/*
