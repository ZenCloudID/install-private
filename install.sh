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

# Fungsi untuk menampilkan pesan
msg() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

# Fungsi untuk menampilkan error dan exit
die() {
  msg "\n${RED}[ERROR] $1${NC}"
  exit 1
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

# Fungsi untuk menginstal tema Stellar
install_stellar_theme() {
    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]                INSTALASI STELLAR THEME                 [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "

    wget -O /var/www/stellar.zip "$RAW_URL/stellar.zip" || die "Gagal mendownload Stellar Theme"
    unzip -o /var/www/stellar.zip -d /var/www/
    rm -f /var/www/stellar.zip

    echo -e "${GREEN}[+]           STELLAR THEME BERHASIL DIINSTALL          [+]${NC}"
    echo -e "                                                       "
}

# Fungsi untuk menginstal tema Billing
install_billing_theme() {
    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]                INSTALASI BILLING THEME                 [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "

    wget -O /var/www/billing.zip "$RAW_URL/billing.zip" || die "Gagal mendownload Billing Theme"
    unzip -o /var/www/billing.zip -d /var/www/
    rm -f /var/www/billing.zip

    echo -e "${GREEN}[+]           BILLING THEME BERHASIL DIINSTALL          [+]${NC}"
    echo -e "                                                       "
}

# Fungsi untuk menginstal tema Enigma
install_enigma_theme() {
    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]                INSTALASI ENIGMA THEME                 [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "

    wget -O /var/www/enigma.zip "$RAW_URL/enigma.zip" || die "Gagal mendownload Enigma Theme"
    unzip -o /var/www/enigma.zip -d /var/www/
    rm -f /var/www/enigma.zip

    echo -e "${GREEN}[+]           ENIGMA THEME BERHASIL DIINSTALL          [+]${NC}"
    echo -e "                                                       "
}

# Fungsi untuk menginstal tema Nebula
install_nebula_theme() {
    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]                INSTALASI NEBULA THEME                 [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "

    wget -O /var/www/nebulaptero.zip "$RAW_URL/nebulaptero.zip" || die "Gagal mendownload Nebula Theme"
    unzip -o /var/www/nebulaptero.zip -d /var/www/
    rm -f /var/www/nebulaptero.zip

    echo -e "${GREEN}[+]           NEBULA THEME BERHASIL DIINSTALL          [+]${NC}"
    echo -e "                                                       "
}

# Fungsi untuk menginstal tema Elysium
install_elysium_theme() {
    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]             INSTALLASI ELYSIUM THEME           [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "

    wget -O /var/www/ElysiumTheme.zip "$RAW_URL/ElysiumTheme.zip" || die "Gagal mendownload Elysium Theme"
    unzip -o /var/www/ElysiumTheme.zip -d /var/www/
    rm -f /var/www/ElysiumTheme.zip

    echo -e "${GREEN}[+]          ELYSIUM THEME BERHASIL DIINSTALL       [+]${NC}"
    echo -e "                                                       "
}

# Fungsi untuk mengalokasikan node
install_node_allocation() {
    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]             INSTALLASI NODE ALLOCATION           [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "

    wget -O /var/www/alocation.sh "$RAW_URL/alocation.sh" || die "Gagal mendownload alocation.sh"
    chmod +x /var/www/alocation.sh
    bash /var/www/alocation.sh

    echo -e "${GREEN}[+]        NODE ALLOCATION BERHASIL DIINSTALL       [+]${NC}"
    echo -e "                                                       "
}

# Fungsi untuk membuat node baru
create_new_node() {
    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]             MEMBUAT NODE BARU                   [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "

    wget -O /var/www/createnode.sh "$RAW_URL/createnode.sh" || die "Gagal mendownload createnode.sh"
    chmod +x /var/www/createnode.sh
    bash /var/www/createnode.sh

    echo -e "${GREEN}[+]        NODE BARU BERHASIL DIBUAT                [+]${NC}"
    echo -e "                                                       "
}

# Fungsi untuk melindungi admin user
protect_admin_user() {
    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]             MELINDUNGI ADMIN USER                [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "

    wget -O /var/www/protectadminuser.sh "$RAW_URL/protectadminuser.sh" || die "Gagal mendownload protectadminuser.sh"
    chmod +x /var/www/protectadminuser.sh
    bash /var/www/protectadminuser.sh

    echo -e "${GREEN}[+]        ADMIN USER BERHASIL DILINDUNGI            [+]${NC}"
    echo -e "                                                       "
}

# Fungsi untuk memperbaiki panel Pterodactyl
repair_panel() {
    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]             MEMPERBAIKI PANEL PTERODACTYL        [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "

    wget -O /var/www/repair.sh "$RAW_URL/repair.sh" || die "Gagal mendownload repair.sh"
    chmod +x /var/www/repair.sh
    bash /var/www/repair.sh

    echo -e "${GREEN}[+]        PANEL PTERODACTYL BERHASIL DIPERBAIKI     [+]${NC}"
    echo -e "                                                       "
}

# ==============================================
# FUNGSI UTAMA
# ==============================================

main_menu() {
  while true; do
    clear
    echo -e "${BLUE}"
    figlet -f slant "PteroInstaller" | lolcat
    echo -e "${NC}"
    echo -e "${BLUE}=============================================${NC}" | lolcat
    echo -e " Versi Script : 2.0.0"
    echo -e " Dibuat oleh  : ZenCloudID" | lolcat  
    echo -e "${BLUE}=============================================${NC}" | lolcat
    echo -e " Pilihan:"
    echo -e " 1. Install Dependencies"
    echo -e " 2. Install Stellar Theme"
    echo -e " 3. Install Billing Theme"
    echo -e " 4. Install Enigma Theme"
    echo -e " 5. Install Nebula Theme"
    echo -e " 6. Install Elysium Theme"
    echo -e " 7. Install Node Allocation"
    echo -e " 8. Create New Node"
    echo -e " 9. Protect Admin User"
    echo -e " 10. Repair Pterodactyl Panel"
    echo -e " 11. Keluar"
    echo -e "${BLUE}=============================================${NC}" | lolcat
    echo -ne " Pilih menu [1-11]: "
    read -r choice

    case $choice in
      1) install_deps ;;
      2) install_stellar_theme ;;
      3) install_billing_theme ;;
      4) install_enigma_theme ;;
      5) install_nebula_theme ;;
      6) install_elysium_theme ;;
      7) install_node_allocation ;;
      8) create_new_node ;;
      9) protect_admin_user ;;
      10) repair_panel ;;
      11) 
        msg "${GREEN}[✓] Keluar dari installer...${NC}" | lolcat
        cleanup
        exit 0
        ;;
      *)
        msg "${RED}[!] Pilihan tidak valid!${NC}" | lolcat
        sleep 1
        ;;
    esac

    echo -ne "\nTekan enter untuk melanjutkan..."
    read -r
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

# Trap CTRL+C
trap ctrl_c INT
ctrl_c() {
  die "Instalasi dibatalkan oleh user"
}

# Main execution
main() {
  # Cek root
  if [ "$(id -u)" -ne 0 ]; then
    die "Script ini harus dijalankan sebagai root!"
  fi

  # Buat log file
  : > "$LOG_FILE"

  # Header
  msg "${BLUE}"
  figlet -f slant "PteroInstaller" | tee -a "$LOG_FILE" | lolcat
  msg "${NC}"
  msg "${BLUE}=== INSTALLER THEME PTERODACTYL ===${NC}" | lolcat
  msg " Tanggal : $(date)"
  msg " Logfile : $LOG_FILE"
  msg ""

  # Validasi
  check_internet

  # Jalankan menu utama
  main_menu

  # Cleanup
  cleanup
}

# Jalankan program utama
main
