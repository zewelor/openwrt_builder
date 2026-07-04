When adding new host:

- add in docker compose
- add in justfile
- add files in files with correct naming
    - remember to auto add ssh keys

OpenWrt version is configured in `.env` as `OPENWRT_VERSION` and updated by Renovate.
Renovate watches `ghcr.io/openwrt/imagebuilder:x86-64-*` as a proxy for Docker imagebuilder availability, then writes only the version number to `.env`.
The x86-64 imagebuilder is not used for router builds; `docker-compose.yml` still defines the real imagebuilder targets.
When bumping OpenWrt manually, update `.env` only.
`Build images` ignores README-only changes and workflow changes outside `.github/workflows/image.yml`; on relevant pushes it refreshes the current `OPENWRT_VERSION` release tag.
