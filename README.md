# ZMK Firmware for Dao keyboard

This is a repository for a ZMK Firmware for both Dao42 and Dao44 keyboards.

* [main](https://github.com/yumagulovrn/dao-zmk-config/tree/main) branch is for Dao42
* [dao44](https://github.com/yumagulovrn/dao-zmk-config/tree/dao44) branch is, obviously, for Dao44

## Default keymap

### Dao42

Visual representation of the default keymap in keyboard-layout-editor: [KLE](http://www.keyboard-layout-editor.com/#/gists/67a81f6b83c65abcda5e7f32989a1688)

This layout is heavily inspired by [this](https://github.com/aroum/Watchman-layouts)

### Dao44

Visual representation of the default keymap in keyboard-layout-editor: [KLE](http://www.keyboard-layout-editor.com/#/gists/c6ba0634e5b92366be9f324775394e66)

This layout is heavily inspired by [this](https://github.com/KGOH/Jian-Info)

Because of current ZMK limitations, Dao44 keymap is in the branch [dao44](https://github.com/yumagulovrn/dao-zmk-config/tree/dao44)

## Building locally with Nix

Works on Linux and macOS (x86_64/aarch64) with flakes enabled:

```sh
nix build                    # dao_left + dao_right -> result/zmk_{left,right}.uf2
nix build .#firmware-studio  # same, with ZMK Studio enabled on the left (central) half
nix build .#settings-reset   # settings_reset for nice_nano_v2
nix run .#flash              # interactive flasher (Linux only: needs lsblk/udisks)
```

Dependencies come from `config/west.yml`, which pins every project to a commit so the
fixed-output `zephyrDepsHash` in `flake.nix` stays valid. To bump them, run `nix run .#update`
(it follows the branch named in the `# <branch>` comment next to each revision). The first
build fetches Zephyr with full git history and takes ~10 minutes.

Why ZMK is pinned to `v0.3-branch`: the Dao board in `ergonautkb-zmk-module` uses Zephyr's
legacy hardware model (HWMv1), and ZMK `main` moved to Zephyr 4.1, which fails in Kconfig for
`dao_left`/`dao_right`. Move to `main` only once the board gains a `board.yml` (HWMv2).

The flake also patches nanopb (ZMK Studio builds) to use `importlib.resources`, since the
nanopb in ZMK v0.3 imports `pkg_resources`, removed from current setuptools.

## FAQ

- [FAQ](#faq)
  - [How to change the keymap?](#how-to-change-the-keymap)
  - [How to flash the keyboard?](#how-to-flash-the-keyboard)
  - [How to pair halves?](#how-to-pair-halves)
  - [Problems](#problems)
    - [I'm getting File Transfer Error after copying firmware to the keyboard](#im-getting-file-transfer-error-after-copying-firmware-to-the-keyboard)

### How to change the keymap?

1. Fork the repository https://github.com/yumagulovrn/dao-zmk-config
2. Make changes to the [dao.keymap](../config/boards/arm/dao/dao.keymap) file in your repository OR use wonderful https://nickcoutsos.github.io/keymap-editor/
3. Commit changes to your repository
4. Go to `Actions` tab in your repository
5. Wait for the GitHub Action to complete
6. Grab `firmware.zip` file - it contains firmware for both of your halves

### How to flash the keyboard?

1. Obtain `firmware.zip`
2. Unzip `firmware.zip` - you should have `dao_left.uf2` and `dao_right.uf2` files
3. Turn off the power for selected halve (move slider to position `OFF`)
4. Connect selected halve to the PC via USB-C cable
5. Press `RESET` button **twice** to enter DFU mode - you should see new USB device in your file manager
6. Copy the corresponding firmware to the root directory of the new USB device
7. Disconnect selected halve from the PC
8. Repeat steps 3-7 for the other halve

### How to pair halves?

1. Turn off the power for both halves (move slider to position `OFF`)
2. Turn on the power for both halves (move slider to position `ON`)
3. Press `RESET` button **once** on both halves **simultaneously**

### Problems

#### I'm getting File Transfer Error after copying firmware to the keyboard

It's OK. Proof: https://zmk.dev/docs/troubleshooting#file-transfer-error
