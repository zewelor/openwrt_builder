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

## Removing the firewall from non-router images (APs)

Removing `firewall` from an AP image is **not** as simple as adding `-firewall`:

- The firewall in current OpenWrt (25.x) is **`firewall4`** (+ `nftables-json`), not the legacy `firewall` (fw3) package. `-firewall -nftables` are no-ops — they match nothing in the image.
- `firewall4` is part of the **target default packages** (see the "Packages:" line in the build output).
- `firewall4` is hard-required by the chain `luci` → `luci-light` → `luci-app-firewall` → `uci-firewall` (a `PROVIDES` of `firewall4`). Adding `-luci-app-firewall -firewall4` therefore **breaks the build** with an apk dependency conflict.

Verified on 25.12.5 / ramips-mt7621 (build log: `firewall4`, `nftables-json`, `luci-app-firewall`, `kmod-nft-offload` all still installed after `-firewall -nftables`).

To actually remove it you would have to replace `luci`/`luci-ssl` with a hand-picked set of luci modules that excludes `luci-app-firewall`. Not done — APs keep luci and firewall4, which is only disabled via `DISABLED_SERVICES="firewall ..."`.
