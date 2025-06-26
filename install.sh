#!/bin/bash

# ==============================================
# KONFIGURASI UTAMA
# ==============================================
REPO_OWNER="ZenCloudID"
REPO_NAME="install-private"
REPO_URL="https://github.com/$REPO_OWNER/$REPO_NAME"
RAW_URL="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/main"
TEMP_DIR="/tmp/ptero_installer_$(date +%s)"
THEME_DIR="/var/www/pterodactyl"
LOG_FILE="/var/log/ptero_installer.log"
TOKEN="ZenCloud2025Terbaru"  # Ganti dengan token Anda

# ==============================================
# FUNGSI UTILITY
# ==============================================

cleanup_on_exit() {
    echo -e "${RED}\n[!] Membersihkan file installer...${NC}"
    sleep 1
    # Hapus file instalasi dan log
    rm -f "$0" "$LOG_FILE" 2>/dev/null
    echo -e "${GREEN}[✓] File installer berhasil dihapus${NC}"
    exit 0
}

# Fungsi untuk menampilkan pesan
msg() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Fungsi untuk menampilkan error dan exit
die() {
    msg "\n${RED}[ERROR] $1${NC}"
    cleanup_on_exit
}

# Fungsi untuk memvalidasi koneksi internet
check_internet() {
    if ! ping -c 1 github.com &> /dev/null; then
        die "Tidak ada koneksi internet. Silakan cek koneksi Anda."
    fi
}

# Fungsi untuk cleanup
cleanup() {
    rm -rf "$TEMP_DIR"
}

# Fungsi install dependencies
install_deps() {
    msg "${BLUE}[+] Memeriksa dependensi sistem...${NC}"
    
    # Daftar dependensi
    DEPS=(git curl wget unzip php nodejs yarn)

    # Cek package manager
    if command -v apt &> /dev/null; then
        PKG_MGR="apt"
        sudo apt update | tee -a "$LOG_FILE"
    elif command -v yum &> /dev/null; then
        PKG_MGR="yum"
    else
        die "Package manager tidak dikenali (tidak support apt/yum)"
    fi

    # Install dependencies
    for dep in "${DEPS[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            msg "${YELLOW}[-] Menginstall $dep...${NC}"
            sudo "$PKG_MGR" install -y "$dep" | tee -a "$LOG_FILE" || 
                die "Gagal menginstall $dep"
        fi
    done

    # Install lolcat jika belum ada
    if ! command -v lolcat &> /dev/null; then
        if command -v gem &> /dev/null; then
            sudo gem install lolcat | tee -a "$LOG_FILE"
        elif command -v pip &> /dev/null; then
            pip install lolcat | tee -a "$LOG_FILE"
        else
            msg "${YELLOW}[!] Lolcat tidak terinstall, tampilan akan kurang colorful${NC}"
        fi
    fi
}

# ==============================================
# FUNGSI INSTALASI
# ==============================================

# Fungsi untuk menginstal tema Stellar
install_stellar_theme() {
    echo -e "${GREEN}[+] Memulai instalasi Stellar Theme...${NC}" | lolcat
    
    wget -q --show-progress "$RAW_URL/stellar.zip" -O "$TEMP_DIR/stellar.zip" || die "Gagal mendownload Stellar Theme"
    unzip -o "$TEMP_DIR/stellar.zip" -d "$THEME_DIR" || die "Gagal mengekstrak Stellar Theme"
    
    echo -e "${GREEN}[✓] Stellar Theme berhasil diinstall${NC}" | lolcat
}

# Fungsi untuk menginstal tema Billing
install_billing_theme() {
    echo -e "${GREEN}[+] Memulai instalasi Billing Theme...${NC}" | lolcat
    
    wget -q --show-progress "$RAW_URL/billing.zip" -O "$TEMP_DIR/billing.zip" || die "Gagal mendownload Billing Theme"
    unzip -o "$TEMP_DIR/billing.zip" -d "$THEME_DIR" || die "Gagal mengekstrak Billing Theme"
    
    echo -e "${GREEN}[✓] Billing Theme berhasil diinstall${NC}" | lolcat
}

# Fungsi untuk menginstal tema Enigma
install_enigma_theme() {
    echo -e "${GREEN}[+] Memulai instalasi Enigma Theme...${NC}" | lolcat
    
    wget -q --show-progress "$RAW_URL/enigma.zip" -O "$TEMP_DIR/enigma.zip" || die "Gagal mendownload Enigma Theme"
    unzip -o "$TEMP_DIR/enigma.zip" -d "$THEME_DIR" || die "Gagal mengekstrak Enigma Theme"
    
    echo -e "${GREEN}[✓] Enigma Theme berhasil diinstall${NC}" | lolcat
}

# Fungsi untuk menginstal tema Nebula
install_nebula_theme() {
    echo -e "${GREEN}[+] Memulai instalasi Nebula Theme...${NC}" | lolcat
    
    wget -q --show-progress "$RAW_URL/nebulaptero.zip" -O "$TEMP_DIR/nebulaptero.zip" || die "Gagal mendownload Nebula Theme"
    unzip -o "$TEMP_DIR/nebulaptero.zip" -d "$THEME_DIR" || die "Gagal mengekstrak Nebula Theme"
    
    echo -e "${GREEN}[✓] Nebula Theme berhasil diinstall${NC}" | lolcat
}

# Fungsi untuk menginstal tema Elysium
install_elysium_theme() {
    echo -e "${GREEN}[+] Memulai instalasi Elysium Theme...${NC}" | lolcat
    
    wget -q --show-progress "$RAW_URL/ElysiumTheme.zip" -O "$TEMP_DIR/ElysiumTheme.zip" || die "Gagal mendownload Elysium Theme"
    unzip -o "$TEMP_DIR/ElysiumTheme.zip" -d "$THEME_DIR" || die "Gagal mengekstrak Elysium Theme"
    
    echo -e "${GREEN}[✓] Elysium Theme berhasil diinstall${NC}" | lolcat
}

# Fungsi untuk menginstal tema Nookure
install_nookure_theme() {
    echo -e "${GREEN}[+] Memulai instalasi Nookure Theme...${NC}" | lolcat
    
    cd "$THEME_DIR" || die "Gagal pindah ke direktori Pterodactyl"
    php artisan down
    curl -L https://github.com/Nookure/NookTheme/releases/latest/download/panel.tar.gz | tar -xzv
    chmod -R 755 storage/* bootstrap/cache
    composer install --no-dev --optimize-autoloader
    php artisan view:clear
    php artisan config:clear
    php artisan migrate --seed --force
    chown -R www-data:www-data /var/www/pterodactyl/*
    php artisan queue:restart
    php artisan up
    
    echo -e "${GREEN}[✓] Nookure Theme berhasil diinstall${NC}" | lolcat
}

# Fungsi untuk menguninstall tema
uninstall_theme() {
    echo -e "${RED}[!] Apakah Anda yakin ingin menguninstall tema dan addon di panelmu? (y/n)${NC}"
    read -r confirm
    if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
        echo -e "${GREEN}[+] Memulai proses uninstall tema...${NC}" | lolcat
        
        php artisan down
        curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
        tar -xzvf panel.tar.gz -C "$THEME_DIR"
        chmod -R 755 storage/* bootstrap/cache
        composer install --no-dev --optimize-autoloader
        php artisan view:clear
        php artisan config:clear
        php artisan migrate --seed --force
        chown -R www-data:www-data /var/www/pterodactyl/*
        php artisan queue:restart
        php artisan up
        
        echo -e "${GREEN}[✓] Tema berhasil diuninstall${NC}" | lolcat
    else
        echo -e "${YELLOW}[!] Proses uninstall dibatalkan.${NC}" | lolcat
    fi
}

# Fungsi untuk membuat pengguna administrator secara otomatis
create_admin_user_auto() {
    echo -e "${GREEN}[+] Membuat pengguna administrator secara otomatis...${NC}" | lolcat
    
    cd "$THEME_DIR" || die "Gagal pindah ke direktori Pterodactyl"
    php artisan p:user:make --admin --email "new@admin.com" --username "administrator" --password "Administrator@2025"
    
    echo -e "${GREEN}[✓] Pengguna administrator berhasil dibuat${NC}" | lolcat
}

# Fungsi untuk membuat pengguna administrator secara manual
create_admin_user_manual() {
    echo -e "${GREEN}[+] Membuat pengguna administrator secara manual...${NC}" | lolcat
    
    cd "$THEME_DIR" || die "Gagal pindah ke direktori Pterodactyl"
    php artisan p:user:make
    
    echo -e "${GREEN}[✓] Pengguna administrator berhasil dibuat${NC}" | lolcat
}

# Fungsi untuk memeriksa pengguna administrator
check_admin_user() {
    echo -e "${GREEN}[+] Memeriksa pengguna administrator...${NC}" | lolcat
    
    # Menampilkan daftar pengguna
    php artisan p:user:list
    
    echo -e "${GREEN}[✓] Daftar pengguna administrator ditampilkan di atas${NC}" | lolcat
}

# ==============================================
# MENU UTAMA
# ==============================================

main_menu() {
    while true; do
        clear
        echo -e "${BLUE}"
        figlet -f slant "ZenCloud Ptero" | lolcat
        echo -e "${NC}"
        echo -e "${BLUE}=============================================${NC}" | lolcat
        echo -e " ${CYAN}Pterodactyl Panel Installer${NC}"
        echo -e "${BLUE}=============================================${NC}" | lolcat
        echo -e " 1. Install Dependencies"
        echo -e " 2. Install Stellar Theme"
        echo -e " 3. Install Billing Theme"
        echo -e " 4. Install Enigma Theme"
        echo -e " 5. Install Nebula Theme"
        echo -e " 6. Install Elysium Theme"
        echo -e " 7. Install Nookure Theme"
        echo -e " 8. Uninstall Theme"
        echo -e " 9. Create Administrator User (Auto)"
        echo -e "10. Create Administrator User (Manual)"
        echo -e "11. Check User Administrator"
        echo -e "${BLUE}---------------------------------------------${NC}"
        echo -e "12. Node Allocation"
        echo -e "13. Create New Node"
        echo -e "14. Protect Admin User"
        echo -e "15. Repair Panel"
        echo -e "${BLUE}---------------------------------------------${NC}"
        echo -e "16. Exit & Cleanup"
        echo -e "${BLUE}=============================================${NC}" | lolcat
        
        echo -ne " Pilih menu [1-16]: "
        read -r choice

        case $choice in
            1) install_deps ;;
            2) install_stellar_theme ;;
            3) install_billing_theme ;;
            4) install_enigma_theme ;;
            5) install_nebula_theme ;;
            6) install_elysium_theme ;;
            7) install_nookure_theme ;;
            8) uninstall_theme ;;
            9) create_admin_user_auto ;;
            10) create_admin_user_manual ;;
            11) check_admin_user ;;
            12) install_node_allocation ;;
            13) create_new_node ;;
            14) protect_admin_user ;;
            15) repair_panel ;;
            16) 
                echo -e "${YELLOW}[!] Membersihkan sistem...${NC}" | lolcat
                cleanup_on_exit
                ;;
            *)
                echo -e "${RED}[!] Pilihan tidak valid!${NC}" | lolcat
                sleep 1
                ;;
        esac

        if [ "$choice" != "16" ]; then
            echo -ne "\nTekan Enter untuk melanjutkan..."
            read -r
        fi
    done
}

# ==============================================
# INISIALISASI
# ==============================================

# Warna terminal
BLUE='\033[1;34m'
RED='\033[1;31m' 
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# Trap CTRL+C dan exit untuk cleanup
trap ctrl_c INT
trap cleanup_on_exit EXIT

ctrl_c() {
    die "Instalasi dibatalkan oleh user"
}

# Main execution
main() {
    # Cek root
    if [ "$(id -u)" -ne 0 ]; then
        die "Script ini harus dijalankan sebagai root!"
    fi

    # Buat folder temp
    mkdir -p "$TEMP_DIR"

    # Header
    echo -e "${BLUE}"
    figlet -f slant "ZenCloud Ptero" | lolcat
    echo -e "${NC}"
    echo -e "${BLUE}=== Pterodactyl Panel Installer ===${NC}" | lolcat
    echo -e " Versi   : 3.0"
    echo -e " Tanggal : $(date)"
    echo -e "${BLUE}=================================${NC}"

    # Validasi
    check_internet

    # Jalankan menu utama
    main_menu
}

# Jalankan program utama
main
