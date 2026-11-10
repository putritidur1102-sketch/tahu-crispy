# Panduan membuat APK dari HP Android

## A. Buat repository GitHub
1. Buka https://github.com melalui Chrome dan daftar/login.
2. Tekan tombol + lalu New repository.
3. Nama repository: tahu-crispy-pos. Pilih Private, lalu Create repository.
4. Di repository, pilih Add file > Upload files. Unggah file `Tahu_Crispy_POS_Flutter_Starter.zip` dari paket ini, lalu tekan Commit changes.

## B. Buat workflow build
1. Di repository pilih Add file > Create new file.
2. Pada nama file, ketik tepat: `.github/workflows/build-apk.yml`
3. Salin isi file `build-apk.yml` yang ada di paket ini ke editor GitHub. Jika sulit membuka file tersebut, gunakan isi berikut:

```yaml
name: Build Tahu Crispy POS APK
on:
  workflow_dispatch:
permissions:
  contents: read
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Unpack app source
        run: |
          unzip -q Tahu_Crispy_POS_Flutter_Starter.zip -d app_source
          cp -a app_source/. .
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter create --platforms=android --project-name tahu_crispy_pos .
      - run: flutter pub get
      - run: flutter build apk --debug
      - uses: actions/upload-artifact@v4
        with:
          name: tahu-crispy-pos-apk
          path: build/app/outputs/flutter-apk/app-debug.apk
          if-no-files-found: error
          retention-days: 7
```
4. Tekan Commit changes.

## C. Jalankan build
1. Buka tab Actions di repository.
2. Pilih workflow `Build Tahu Crispy POS APK`.
3. Tekan Run workflow, lalu Run workflow lagi.
4. Tunggu sampai proses selesai dengan tanda centang hijau.
5. Buka run yang berhasil, gulir ke bagian Artifacts, lalu unduh `tahu-crispy-pos-apk`.
6. Buka ZIP hasil unduhan, ekstrak, lalu ketuk `app-debug.apk` untuk memasang.
7. Jika Android meminta izin memasang aplikasi dari sumber tersebut, aktifkan izin untuk Chrome atau aplikasi File yang digunakan. Matikan kembali setelah selesai bila diinginkan.

Jika gagal, buka run Actions, pilih langkah berwarna merah, lalu kirim tangkapan layar atau salin pesan errornya.

Catatan: Ini APK uji coba prototipe lokal. Data belum tersinkron otomatis antar-gerobak dan fitur laporan PDF/Excel, biaya operasional, tutup kas, foto setoran, serta insentif belum lengkap. Jangan gunakan sebagai sistem pencatatan resmi sebelum pengembangan dan pengujian lanjutan.
