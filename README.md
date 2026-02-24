# buildroot_overlay

This directory provides a simple Buildroot rootfs overlay used by the CCA realm demos.

Files here are copied into the target filesystem during Buildroot image generation.

## Layout

- `f_realm/etc/init.d/S99autorun`: startup hook executed at boot.
- `f_realm/root/rw_ivshmem*`: shared-memory helper and source.
- `f_realm/root/usecases/*`: example realm use cases and launcher scripts:
  - `rg_rf_ri`
  - `rg_ri_re`
  - `rnet_ra` (includes JSON configs and helper scripts)

## Usage

Point Buildroot to this overlay, for example via `BR2_ROOTFS_OVERLAY`, so these files are included in the generated root filesystem.
