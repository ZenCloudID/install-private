#!/bin/bash

# ==============================================
# KONFIGURASI
# ==============================================
REPO_OWNER="xjunznaire"
REPO_NAME="Auto-Installer-Theme-Pterodactyl"
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

# Fungsi untuk menginstal dependensi untuk Nebula dan Elysium
install_depend() {
    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]           INSTALL NODE.JS & BLUEPRINT           [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "

    # Install dependensi dasar
    sudo apt-get install -y ca-certificates curl gnupg
    sudo mkdir -p /etc/apt/keyrings

    # Menambahkan kunci repositori Node.js
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

    # Menambahkan sumber paket Node.js versi 20.x
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

    # Memperbarui daftar paket dan menginstal Node.js
    sudo apt-get update
    sudo apt-get install -y nodejs
    npm i -g yarn

    # Navigasi ke direktori Pterodactyl
    cd /var/www/pterodactyl

    # Menginstal dependensi dengan Yarn
    yarn
    yarn add cross-env

    # Install dependensi tambahan
    sudo apt install -y zip unzip git curl wget

    # Mengunduh Blueprint Framework versi terbaru
    wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip

    # Memindahkan dan mengekstrak file release
    mv release.zip /var/www/pterodactyl/release.zip
    cd /var/www/pterodactyl
    unzip release.zip

    # Konfigurasi permission dan eksekusi blueprint.sh
    WEBUSER="www-data"
    USERSHELL="/bin/bash"
    PERMISSIONS="www-data:www-data"

    sed -i -E -e "s|WEBUSER=\"www-data\" #;|WEBUSER=\"$WEBUSER\" #;|g" \
               -e "s|USERSHELL=\"/bin/bash\" #;|USERSHELL=\"$USERSHELL\" #;|g" \
               -e "s|OWNERSHIP=\"www-data:www-data\" #;|OWNERSHIP=\"$PERMISSIONS\" #;|g" blueprint.sh

    chmod +x blueprint.sh
    bash blueprint.sh

    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]        INSTALLASI NODE.JS & BLUEPRINT SELESAI   [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "

    sleep 2
}

# Fungsi untuk menginstal tema Nebula
install_nebula_theme() {
    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]                INSTALASI NEBULA THEME                 [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "

    local BLUEPRINT_FILE="/var/www/pterodactyl/blueprint.sh"
    
    if [ ! -f "$BLUEPRINT_FILE" ]; then
        echo "𝗗𝗘𝗣𝗘𝗡𝗗 𝗣𝗟𝗨𝗚𝗜𝗡𝗦 𝗕𝗘𝗟𝗨𝗠 𝗗𝗜𝗜𝗡𝗦𝗧𝗔𝗟. 𝗦𝗜𝗟𝗔𝗛𝗞𝗔𝗡 𝗜𝗡𝗦𝗧𝗔𝗟𝗟 𝗗𝗘𝗡𝗚𝗔𝗡 𝗢𝗣𝗦𝗜 𝗡𝗢 𝟭𝟭"
        exit 1
    fi

    # URL Repositori (gunakan HTTPS tanpa autentikasi)
    local REPO_URL="https://github.com/xjunznaire/Auto-Installer-Theme-Pterodactyl.git"
    local TEMP_DIR="Autoinstaller-Theme-Pterodactyl"

    echo -e "${BLUE}🔄 Mengkloning repositori...${NC}"
    git clone --depth=1 "$REPO_URL"

    if [ ! -d "$TEMP_DIR" ]; then
        echo -e "${RED}❌ Gagal mengkloning repositori.${NC}"
        exit 1
    fi

    echo -e "${BLUE}📦 Memindahkan dan mengekstrak file...${NC}"
    mv "$TEMP_DIR/nebulaptero.zip" /var/www/
    unzip -o /var/www/nebulaptero.zip -d /var/www/

    echo -e "${BLUE}⚙️ Menginstal blueprint...${NC}"
    cd /var/www/pterodactyl && blueprint -install nebula

    echo -e "${BLUE}🧹 Membersihkan file sementara...${NC}"
    rm -rf "$TEMP_DIR" "/var/www/nebulaptero.zip" "/var/www/pterodactyl/nebula.blueprint"

    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]           NEBULA THEME BERHASIL DIINSTALL          [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "
    
    sleep 2
}

# Fungsi untuk menginstal tema Elysium
install_elysium_theme() {
    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]             INSTALLASI ELYSIUM THEME           [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "

    # Menginstal Tema Elysium
    REPO_URL="https://github.com/xjunznaire/Auto-Installer-Theme-Pterodactyl.git"
    TEMP_DIR="Autoinstaller-Theme-Pterodactyl"

    git clone "$REPO_URL" "$TEMP_DIR" || { echo "Gagal mengkloning repositori."; exit 1; }

    # Menyimpan dan mengekstrak file ZIP
    sudo mv "$TEMP_DIR/ElysiumTheme.zip" /var/www/
    unzip -o /var/www/ElysiumTheme.zip -d /var/www/
    rm -rf "$TEMP_DIR" /var/www/ElysiumTheme.zip

    # Install Node.js dan Yarn
    install_depend

    # Navigasi ke direktori Pterodactyl
    cd /var/www/pterodactyl
    yarn
    yarn build:production
    php artisan migrate
    php artisan view:clear

    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]          ELYSIUM THEME BERHASIL DIINSTALL       [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
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
    echo -e " Dibuat oleh  : xjunznaire" | lolcat  
    echo -e "${BLUE}=============================================${NC}" | lolcat
    echo -e " Pilihan:"
    echo -e " 1. Install Dependencies"
    echo -e " 2. Install Nebula Theme"
    echo -e " 3. Install Elysium Theme"
    echo -e " 4. Keluar"
    echo -e "${BLUE}=============================================${NC}" | lolcat
    echo -ne " Pilih menu [1-4]: "
    read -r choice

    case $choice in
      1) install_depend ;;
      2) install_nebula_theme ;;
      3) install_elysium_theme ;;
      4) 
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
  install_deps

  # Jalankan menu utama
  main_menu

  # Cleanup
  cleanup
}

# Jalankan program utama
main
