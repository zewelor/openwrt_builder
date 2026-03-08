When adding new host:

- add in docker compose
- add in justfile
- add files in files with correct naming
    - remember to auto add ssh keys

OpenWrt version is configured in `.env` as `OPENWRT_VERSION`.
When bumping OpenWrt, update `.env` only.
