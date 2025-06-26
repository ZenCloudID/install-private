#!/bin/bash

# Periksa apakah skrip dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "Harap jalankan skrip ini sebagai root."
    exit 1
fi

# 1. Tanyakan User ID yang tidak boleh dihapus
echo -n "Masukkan User ID yang tidak boleh dihapus (contoh: 1): "
read PROTECTED_USER_ID

if [[ ! "$PROTECTED_USER_ID" =~ ^[0-9]+$ ]]; then
    echo "User ID harus berupa angka. Keluar."
    exit 1
fi

# 2. Ganti fungsi delete di Pterodactyl
CONTROLLER_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/UserController.php"

if [ -f "$CONTROLLER_PATH" ]; then
    echo "Mengganti fungsi delete di UserController.php..."

    sed -i "/public function delete(Request \$request, User \$user): RedirectResponse {/,/^}/c\\
    public function delete(Request \$request, User \$user): RedirectResponse {\\
        if (\$user->id === $PROTECTED_USER_ID) {\\
            throw new DisplayException('Dilarang Menghapus Admin Panel Utama');\\
        }\\
        if (\$request->user()->id === \$user->id) {\\
            throw new DisplayException('Anda tidak dapat menghapus akun Anda sendiri.');\\
        }\\
        \$this->deletionService->handle(\$user);\\
        return redirect()->route('admin.users');\\
    }" "$CONTROLLER_PATH"

    echo "Fungsi delete berhasil diperbarui."
else
    echo "File UserController.php tidak ditemukan di $CONTROLLER_PATH."
    exit 1
fi

# 3. Instal Node.js 18 jika belum ada
NODE_VERSION=$(node -v 2>/dev/null | grep -oP '[0-9]+' | head -1)
if [ -z "$NODE_VERSION" ] || [ "$NODE_VERSION" -lt 18 ]; then
    echo "Node.js 18 tidak ditemukan. Menginstal Node.js 18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
else
    echo "Node.js versi $NODE_VERSION sudah terinstal."
fi

# 4. Instal Yarn jika belum ada
if ! command -v yarn &>/dev/null; then
    echo "Yarn tidak ditemukan. Menginstal Yarn..."
    npm install -g yarn
else
    echo "Yarn sudah terinstal."
fi

# 5. Jalankan Yarn dan build frontend dengan opsi OpenSSL legacy
cd /var/www/pterodactyl || { echo "Direktori Pterodactyl tidak ditemukan."; exit 1; }
echo "Menjalankan Yarn..."
yarn

echo "Membangun aset frontend..."
export NODE_OPTIONS=--openssl-legacy-provider
yarn build:production

# 6. Bersihkan cache Laravel secara manual
echo "Membersihkan cache Laravel..."
rm -rf bootstrap/cache/*
rm -rf storage/framework/cache/*
rm -rf storage/framework/sessions/*
rm -rf storage/framework/views/*

# 7. Selesai
echo "Proses selesai. Admin dengan User ID $PROTECTED_USER_ID tidak dapat dihapus."