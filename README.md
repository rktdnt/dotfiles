# Dotfiles (ThinkPad X395 - Arch Linux)

Personal dotfiles for Arch Linux based on [**end-4/dots-hyprland**](https://github.com/end-4/dots-hyprland) (*illogical-impulse*), customized with hardware integrations tailored for **Lenovo ThinkPad X395** (fan curves, 3-tier power profiles, battery conservation, and trackpad fixes).

> 💡 **Looking for what was changed from upstream?** See [**`ADAPTATIONS.md`**](ADAPTATIONS.md) for a complete breakdown of new and modified files.

---

## Features

* **Upstream Base:** Built on [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) (Quickshell / Material You).
* **Window Manager:** [Hyprland](https://hyprland.org/) with smooth animations, custom keybinds, and tuned window rules.
* **Shell & Widgets:** [Quickshell](https://quickshell.outfoxxed.me/) with Material You Android-style quick settings panel:
  * **Fan Control Toggle:** Real-time RPM readout with single-click cycling: `Auto (thinkfan)` ↔ `Full Speed (Level 7)` ↔ `Quiet (Level 1)`.
  * **Power Profile Toggle:** Unlocks 3 tiers on AMD Picasso: `Balanced` ↔ `Performance (25W TDP + max boost)` ↔ `Power Saver (8W TDP + boost off + 1.7GHz cap)`.
  * **Battery Limit Toggle:** Quick toggle between `80% Limit` (battery conservation) and `100% Full`.
* **Trackpad Tuning:** Fixed right-click behavior (`clickfinger_behavior = false` for bottom-right corner click + 2-finger tap) and tuned adaptive acceleration.
* **App Themes:** Foot, Fuzzel, Matugen (Material You color generation), Wlogout, Cava, Starship prompt.

---

## Installation

Clone this repository and run the installer:

```bash
git clone https://github.com/rktdnt/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The script will:
1. Ask to install dependencies via `pacman` and `yay`/`paru`.
2. Back up existing configs to `~/.config/dotfiles_backup_<timestamp>/`.
3. Deploy all configuration files into `~/.config/`.
4. Optionally configure ThinkPad hardware files (`/etc/thinkfan.yaml`, `/etc/modprobe.d/`, and passwordless sudo for `thinkpad-control.sh`).

---

## Manual Hardware Setup (ThinkPad Only)

If you prefer to configure the ThinkPad system files manually:

```bash
# 1. Install thinkfan and modprobe options
sudo cp ~/dotfiles/etc/thinkfan.yaml /etc/thinkfan.yaml
sudo cp ~/dotfiles/etc/modprobe.d/* /etc/modprobe.d/

# 2. Grant passwordless execution to thinkpad-control.sh for Quickshell
echo "%wheel ALL=(ALL) NOPASSWD: $HOME/.config/quickshell/ii/scripts/thinkpad-control.sh" | sudo tee /etc/sudoers.d/thinkpad-control
sudo chmod 0440 /etc/sudoers.d/thinkpad-control

# 3. Enable thinkfan service
sudo systemctl enable --now thinkfan
```

---

## Reloading After Changes

* Press **`Ctrl + Super + R`** to reload both Hyprland and Quickshell.
