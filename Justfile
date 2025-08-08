# Clean the output directory
clean:
    rm -rf ./output/*

# Recipes for each service
summerhouse_router:
    docker compose pull summerhouse_router ; docker compose run --rm summerhouse_router

x0:
    docker compose pull x0 ; docker compose run --rm x0

ap_basement:
    docker compose pull ap_basement ; docker compose run --rm ap_basement

ap_michal:
    docker compose pull ap_michal ; docker compose run --rm ap_michal

parents_router:
    docker compose pull parents_router ; docker compose run --rm parents_router

portosanto_router:
    docker compose pull portosanto_router ; docker compose run --rm portosanto_router
