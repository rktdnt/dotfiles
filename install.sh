#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Installer for Arch Linux (Hyprland + Quickshell + ThinkPad Controls)
# Repository: https://github.com/rktdnt/dotfiles
# ==============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.config/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Colors
C_RESET="\033[0m"
C_RED="\033[1;31m"
C_GREEN="\033[1;32m"
C_YELLOW="\033[1;33m"
C_BLUE="\033[1;34m"
C_CYAN="\033[1;36m"

info()    { echo -e "${C_BLUE}[INFO]${C_RESET} $*"; }
success() { echo -e "${C_GREEN}[OK]${C_RESET} $*"; }
warn()    { echo -e "${C_YELLOW}[WARN]${C_RESET} $*"; }
error()   { echo -e "${C_RED}[ERROR]${C_RESET} $*"; exit 1; }

echo -e "${C_CYAN}"
cat << "EOF"
  ____       _    __ _ _           
 |  _ \  ___| |_ / _(_) | ___  ___ 
 | | | |/ _ \ __| |_| | |/ _ \/ __|
 | |_| | (_) | |_|  _| | |  __/\__ \
 |____/ \___/ \__|_| |_|_|\___||___/
 Hyprland + Quickshell + ThinkPad Setup
EOF
echo -e "${C_RESET}"

# ------------------------------------------------------------------------------
# 1. Package Installation (Optional)
# ------------------------------------------------------------------------------
install_packages() {
    info "Memeriksa paket dependencies..."

    local PACMAN_PKGS=(
        hyprland
        hypridle
        hyprlock
        hyprsunset
        foot
        fuzzel
        cava
        matugen
        starship
        rsync
        cpupower
        thinkfan
        power-profiles-daemon
    )

    local AUR_PKGS=(
        quickshell
        wlogout
        ryzenadj
        ttf-ms-fonts
    )

    echo -ne "${C_YELLOW}Install dependencies via pacman/AUR? (y/N): ${C_RESET}"
    read -r resp
    if [[ "$resp" =~ ^[Yy]$ ]]; then
        info "Menginstall paket resmi via pacman..."
        sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

        local AUR_HELPER=""
        if command -v yay >/dev/null 2>&1; then
            AUR_HELPER="yay"
        elif command -v paru >/dev/null 2>&1; then
            AUR_HELPER="paru"
        fi

        if [ -n "$AUR_HELPER" ]; then
            info "Menginstall paket AUR menggunakan $AUR_HELPER..."
            "$AUR_HELPER" -S --needed --noconfirm "${AUR_PKGS[@]}"
        else
            warn "Tidak ditemukan yay/paru. Lewati paket AUR: ${AUR_PKGS[*]}"
        fi
        success "Paket dependencies selesai dipasang."
    else
        info "Instalasi paket dilewati."
    fi
}

# ------------------------------------------------------------------------------
# 2. Deploy User Configs (~/.config)
# ------------------------------------------------------------------------------
deploy_configs() {
    info "Menyiapkan penyalinan konfigurasi pengguna..."

    mkdir -p "${HOME}/.config"
    local TARGETS=(hypr quickshell illogical-impulse foot fuzzel matugen wlogout cava)
    local NEED_BACKUP=false

    for t in "${TARGETS[@]}"; do
        if [ -d "${HOME}/.config/${t}" ]; then
            NEED_BACKUP=true
            break
        fi
    done

    if [ "$NEED_BACKUP" = true ]; then
        info "Membuat backup konfigurasi lama di ${BACKUP_DIR}..."
        mkdir -p "${BACKUP_DIR}"
        for t in "${TARGETS[@]}"; do
            if [ -d "${HOME}/.config/${t}" ]; then
                cp -r "${HOME}/.config/${t}" "${BACKUP_DIR}/"
            fi
        done
        [ -f "${HOME}/.config/starship.toml" ] && cp "${HOME}/.config/starship.toml" "${BACKUP_DIR}/"
        success "Backup selesai."
    fi

    info "Menyalin file konfigurasi dari repo ke ~/.config/..."
    rsync -av --exclude=".git" "${DOTFILES_DIR}/.config/" "${HOME}/.config/"

    # Pastikan script thinkpad-control memiliki izin eksekusi
    if [ -f "${HOME}/.config/quickshell/ii/scripts/thinkpad-control.sh" ]; then
        chmod +x "${HOME}/.config/quickshell/ii/scripts/thinkpad-control.sh"
        success "thinkpad-control.sh sudah diberi izin eksekusi (+x)."
    fi

    success "Konfigurasi ~/.config berhasil diterapkan."
}

# ------------------------------------------------------------------------------
# 3. Setup ThinkPad System Controls (/etc)
# ------------------------------------------------------------------------------
setup_thinkpad_system() {
    echo -ne "${C_YELLOW}Terapkan konfigurasi sistem ThinkPad (/etc/thinkfan, modprobe, sudoers)? (y/N): ${C_RESET}"
    read -r resp
    if [[ "$resp" =~ ^[Yy]$ ]]; then
        info "Menerapkan konfigurasi hardware ThinkPad (memerlukan sudo)..."

        # 1. Thinkfan config
        if [ -f "${DOTFILES_DIR}/etc/thinkfan.yaml" ]; then
            sudo cp "${DOTFILES_DIR}/etc/thinkfan.yaml" /etc/thinkfan.yaml
            success "Disalin /etc/thinkfan.yaml"
        fi

        # 2. Modprobe configs
        if [ -d "${DOTFILES_DIR}/etc/modprobe.d" ]; then
            sudo mkdir -p /etc/modprobe.d
            sudo cp -r "${DOTFILES_DIR}/etc/modprobe.d/"* /etc/modprobe.d/
            success "Disalin opsi modprobe (thinkpad_acpi, psmouse)"
        fi

        # 3. Passwordless sudoers for thinkpad-control.sh
        info "Menyiapkan izin sudoers tanpa password untuk thinkpad-control.sh..."
        echo "%wheel ALL=(ALL) NOPASSWD: ${HOME}/.config/quickshell/ii/scripts/thinkpad-control.sh" | sudo tee /etc/sudoers.d/thinkpad-control >/dev/null
        sudo chmod 0440 /etc/sudoers.d/thinkpad-control
        success "Izin sudoers /etc/sudoers.d/thinkpad-control siap."

        # 4. Enable thinkfan service
        if command -v thinkfan >/dev/null 2>&1; then
            sudo systemctl enable --now thinkfan 2>/dev/null || true
            success "thinkfan.service diaktifkan."
        fi
    else
        info "Konfigurasi hardware sistem dilewati."
    fi
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    install_packages
    deploy_configs
    setup_thinkpad_system

    echo
    success "============================================================"
    success "Semua konfigurasi dotfiles berhasil dipasang!"
    success "Untuk memuat ulang Hyprland & Quickshell: Tekan Ctrl+Super+R"
    success "============================================================"
}

main "$@"
