# Clean the output directory
clean:
    rm -rf ./output/*

# Private recipe: common build logic for any service
[private]
build service:
    docker compose pull {{service}}
    docker compose run --rm {{service}}

# Aliases for each router (backward-compatible interface)
ap_michal: (build "ap_michal")
ap_basement: (build "ap_basement")
parents_router: (build "parents_router")
summerhouse_router: (build "summerhouse_router")
x0: (build "x0")
portosanto_router: (build "portosanto_router")
