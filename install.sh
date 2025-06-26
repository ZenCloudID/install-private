#!/bin/bash

# ==============================================
# KONFIGURASI
# ==============================================
REPO_URL="https://github.com/ZenCloudID/install-private.git"
TEMP_DIR="/tmp/zencloud_installer"
THEME_DIR="/var/www/pterodactyl"
TOKEN="ZenCloud2025Terbaru"

# Warna
BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# ==============================================
# FUNGSI UTILITY
# ==============================================

# Cek dan install dependensi
install_deps() {
  echo -e "\n${BLUE}[+] Memeriksa dependensi...${NC}"
  
  # Cek dan install lolcat
  if ! command -v lolcat &>/dev/null; then
    echo -e "${YELLOW}[!] Lolcat tidak ditemukan, menginstall...${NC}"
    
    # Coba via apt
    if command -v apt &>/dev/null; then
      sudo apt update && sudo apt install -y lolcat || {
        echo -e "${YELLOW}[!] Fallback ke pip...${NC}"
        python3 -m pip install --user lolcat || {
          echo -e "${RED}[X] Gagal install lolcat${NC}"
          alias lolcat="cat"
        }
      }
    else
      python3 -m pip install --user lolcat || {
        echo -e "${RED}[X] Gagal install lolcat${NC}"
        alias lolcat="cat"
      }
    fi
  fi

  # Cek dependensi penting
  for dep in wget unzip git curl; do
    if ! command -v $dep &>/dev/null; then
      echo -e "${YELLOW}[!] Menginstall $dep...${NC}"
      sudo apt install -y $dep || echo -e "${RED}[X] Gagal install $dep${NC}"
    fi
  done
}

# Download resources
download_resources() {
  echo -e "\n${BLUE}[+] Mendownload resources...${NC}"
  
  # Hapus folder temp jika ada
  rm -rf $TEMP_DIR
  
  # Coba clone repo
  if git clone $REPO_URL $TEMP_DIR 2>/dev/null; then
    echo -e "${GREEN}[✓] Berhasil clone repository${NC}"
  else
    echo -e "${YELLOW}[!] Gagal clone, mencoba download manual...${NC}"
    
    # Buat folder temp
    mkdir -p $TEMP_DIR
    
    # Download file satu per satu
    files=(
      "stellar.zip"
      "billing.zip"
      "enigma.zip"
      "nebulaptero.zip"
      "ElysiumTheme.zip"
      "repair.sh"
    )
    
    for file in "${files[@]}"; do
      echo -e "${BLUE}[-] Mengunduh $file...${NC}"
      wget -q "https://github.com/ZenCloudID/install-private/raw/main/$file" -O "$TEMP_DIR/$file" || \
      echo -e "${RED}[X] Gagal download $file${NC}"
    done
  fi
}

# ==============================================
# FUNGSI UTAMA
# ==============================================

# Install tema
install_theme() {
  themes=(
    ["1"]="stellar.zip"
    ["2"]="billing.zip" 
    ["3"]="enigma.zip"
    ["4"]="nebulaptero.zip"
    ["5"]="ElysiumTheme.zip"
  )
  
  while true; do
    clear
    echo -e "${BLUE}"
    figlet -f small "Pilih Tema" | lolcat
    echo -e "${NC}"
    
    echo -e "${BLUE}===========================${NC}" | lolcat
    echo -e "1. Stellar" | lolcat
    echo -e "2. Billing" | lolcat
    echo -e "3. Enigma" | lolcat
    echo -e "4. Nebula" | lolcat
    echo -e "5. Elysium" | lolcat
    echo -e "6. Kembali" | lolcat
    echo -e "${BLUE}===========================${NC}" | lolcat
    echo -e "Pilihan [1-6]: \c"
    read -r choice

    [[ "$choice" == "6" ]] && return
    
    if [[ -n "${themes[$choice]}" ]]; then
      theme_file="${themes[$choice]}"
      
      echo -e "\n${GREEN}[+] Menginstall ${theme_file%.*}...${NC}" | lolcat
      
      # Ekstrak tema
      if unzip -o "$TEMP_DIR/$theme_file" -d "$THEME_DIR" 2>/dev/null; then
        echo -e "${GREEN}[✓] Berhasil install tema${NC}"
        
        # Jalankan post-install
        case $choice in
          4) # Nebula
            cd $THEME_DIR && yarn install && yarn build:production
            ;;
          5) # Elysium
            cd $THEME_DIR && php artisan migrate && yarn build:production
            ;;
        esac
        
        echo -e "${GREEN}[✓] Tema siap digunakan!${NC}"
      else
        echo -e "${RED}[X] Gagal ekstrak tema${NC}"
      fi
      
      sleep 2
    else
      echo -e "${RED}[!] Pilihan tidak valid${NC}" | lolcat
      sleep 1
    fi
  done
}

# ==============================================
# EKSEKUSI PROGRAM
# ==============================================

# Main flow
{
  install_deps
  download_resources
  
  # Verifikasi token
  echo -e "\n${BLUE}"
  figlet -f slant "Verifikasi" | lolcat
  echo -e "${NC}"
  
  echo -e "Masukkan token: \c"
  read -r input_token
  
  if [[ "$input_token" != "$TOKEN" ]]; then
    echo -e "${RED}[X] Token tidak valid!${NC}" | lolcat
    exit 1
  fi

  # Menu utama
  while true; do
    clear
    echo -e "${BLUE}"
    figlet -f slant "Menu Utama" | lolcat
    echo -e "${NC}"
    
    echo -e "${BLUE}===========================${NC}" | lolcat
    echo -e "1. Install Tema" | lolcat
    echo -e "2. Reparasi Panel" | lolcat
    echo -e "3. Keluar" | lolcat
    echo -e "${BLUE}===========================${NC}" | lolcat
    echo -e "Pilihan [1-3]: \c"
    read -r main_choice
    
    case $main_choice in
      1) install_theme ;;
      2) 
        echo -e "\n${GREEN}[+] Menjalankan reparasi...${NC}" | lolcat
        bash "$TEMP_DIR/repair.sh"
        ;;
      3) 
        echo -e "${GREEN}[✓] Sampai jumpa!${NC}" | lolcat
        rm -rf $TEMP_DIR
        exit 0
        ;;
      *)
        echo -e "${RED}[!] Pilihan tidak valid${NC}" | lolcat
        sleep 1
        ;;
    esac
  done
}
