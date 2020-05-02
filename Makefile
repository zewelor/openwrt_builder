define run_compose_target
	docker-compose pull $(1) ; docker-compose run --rm $(1)
endef

x1:
	$(call run_compose_target,x1)

summerhouse_rack:
	$(call run_compose_target,summerhouse_rack)
