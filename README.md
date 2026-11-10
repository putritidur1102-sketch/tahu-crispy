# Tahu Crispy POS — Starter Flutter Android

## Isi prototype
- Login PIN 6 digit demo untuk kasir Gerobak 1, 2, dan 3.
- Tombol akses demo pemilik dan admin.
- Kasir satu produk dengan pilihan pembayaran Tunai/QRIS.
- Penyimpanan transaksi lokal SQLite.
- Ringkasan dan riwayat transaksi per gerobak.

## Menjalankan
1. Install Flutter SDK dan Android Studio.
2. Ekstrak folder proyek.
3. Buka terminal di folder `tahu_crispy_pos`.
4. Jalankan:
   ```bash
   flutter pub get
   flutter run
   ```
6. Untuk membuat APK debug:
   ```bash
   flutter build apk --debug
   ```
   File APK biasanya berada di `build/app/outputs/flutter-apk/app-debug.apk`.

## PIN demo
- 111111 = Kasir Gerobak 1
- 222222 = Kasir Gerobak 2
- 333333 = Kasir Gerobak 3

Tombol Pemilik dan Admin pada layar login adalah akses demo tanpa autentikasi.

## PENTING — sebelum produksi
Ini starter/prototype, bukan aplikasi siap operasional. PIN demo dan akses pemilik/admin belum aman untuk produksi. Sebelum dipakai dengan uang sungguhan:
- Implementasikan Firebase Authentication untuk 2 akun berbeda: Owner dan Admin.
- Implementasikan verifikasi PIN kasir di backend (Cloud Functions) dengan hash + salt, rate limit, lockout, dan reset PIN oleh owner/admin. Jangan simpan PIN plaintext di Firestore.
- Terapkan Firebase Security Rules berbasis role dan cartId; kasir hanya boleh membaca/menulis data gerobaknya.
- Tambahkan sinkronisasi antrean SQLite ke Firestore dengan id transaksi idempotent, status pending/synced, retry, dan konflik yang ditangani.
- Harga harus berasal dari konfigurasi server dan tidak dapat diubah kasir. Dropdown harga di prototype hanya untuk uji UI.
- Tambahkan pengeluaran, tutup kas, bukti foto, approval, payroll, ekspor PDF/Excel, dan audit log.
- Uji offline, perangkat berganda, duplikasi transaksi, pergantian hari, serta backup/restore.

## Akun yang direncanakan
- 1 Owner
- 1 Admin
- Kasir Gerobak 1, Gerobak 2, Gerobak 3, dan seterusnya.

Owner/Admin sebaiknya login email + password dan verifikasi tambahan. Kasir memakai PIN 6 digit yang diverifikasi server, bukan PIN hardcoded seperti mode demo.
