define run_compose_target
	docker compose pull $(1) ; docker compose run --rm $(1)
endef

BASE=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

# Include .env
ifneq (,$(wildcard ./.env))
	include .env
  export
endif

# all: clean ap_michal ap_basement summerhouse_rack x0
all: clean ap_michal ap_basement parents_router summerhouse_router x0

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

# build_new_builder:
# 	# apt-get install signify-openbsd
# 	cd openwrt-docker-builder ; BRANCH=19.07.3 TARGET=ramips-mt7621 GNUPGHOME=~/.gnupg/ ./docker-imagebuilder.sh

install_ap_basement:
	scp output/openwrt-${OPENWRT_VERSION}-ap-basement-ramips-mt7621-xiaomi_mi-router-4a-gigabit-squashfs-sysupgrade.bin ap-basement:/tmp/sysupgrade.bin && ssh ap-basement -t "sysupgrade -q /tmp/sysupgrade.bin"

install_ap_michal:
	scp output/openwrt-${OPENWRT_VERSION}-ap-michal-mediatek-mt7622-xiaomi_redmi-router-ax6s-squashfs-sysupgrade.bin ap-michal:/tmp/sysupgrade.bin && ssh ap-michal -t "sysupgrade -q /tmp/sysupgrade.bin"

clean:
	rm -rf ${BASE}output/*
