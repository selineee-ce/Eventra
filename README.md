# Eventra - As Your Personal Concert Hub

**Eventra** adalah platform ekosistem konser yang berfokus pada keadilan akses tiket dan pengambilan keputusan berbasis data bagi promotor. Project ini menggabungkan seluruh informasi konser dalam satu aplikasi sehingga pengguna tidak perlu lagi mengecek banyak platform berbeda. 


## Tentang Project

Aplikasi ini dikembangkan untuk mengatasi masalah tersebarnya informasi konser di berbagai platform dan ketidakadilan akses tiket akibat praktik *scalping*. Kami menggunakan model pengembangan **Scrum** untuk memastikan fleksibilitas tinggi dan kolaborasi yang aktif selama proses pembuatan produk. 

### Anggota Tim (Group 5):
- Edwin Winarto(2802445431) 
- Joseline Fransiska Wijaya (2802455722) 
- Kelly Aurelya Tiona (2802455325) 
- Michelle Santoso (2802452582) 
- Vincent Juvento (2802446011) 

## Fitur Utama
1. Platform Terpusat: Mengintegrasikan semua informasi konser agar lebih mudah diakses. 
2. Reminder & Notifikasi Otomatis: Pengingat jadwal konser (H-7, H-3, H-1) dan notifikasi penjualan tiket agar pengguna tidak kehabisan tiket. 
3. Personal Recommendation: Rekomendasi konser berdasarkan minat, riwayat pencarian, dan artis yang di-*subscribe*. 
4. Profil Artis & Subscribe: Halaman khusus untuk setiap artis dengan jadwal konser mendatang yang bisa diikuti oleh pengguna.  
5. Penjualan Tiket Aman: Fitur jual-beli tiket langsung di dalam aplikasi dengan proses transaksi yang terpercaya. 
6. Wishlist Konser: Memungkinkan pengguna menyimpan konser pilihan dan menerima pembaruan terkait event tersebut. 

## Instruksi Instalasi & Running
### Prasyarat

* Instal [Flutter SDK](https://docs.flutter.dev/get-started/install) versi terbaru.
* Instal [Docker Desktop](https://www.docker.com/products/docker-desktop/) untuk menjalankan backend dan MySQL lewat Compose.

### Langkah-langkah:

1. Clone Repository:
```bash
git clone https://github.com/username/eventra.git
cd eventra

```

2. Setup Backend + Database:
Jalankan backend Node.js dan MySQL sekaligus dengan Docker Compose.
```bash
docker compose up --build
```

API akan tersedia di `http://localhost:3000`, sedangkan MySQL berjalan di `localhost:3306`.

Jika kamu ingin mematikan stack-nya:
```bash
docker compose down
```

3. Setup Frontend:
Kembali ke folder utama, ambil dependensi Flutter, lalu jalankan aplikasi.
```bash
flutter pub get
flutter run
```

## Design Reference
Kamu bisa melihat prototipe desain kami di Figma melalui tautan berikut: 
[Eventra Figma Design](https://www.figma.com/design/LqRe0kuisKf15E9dTJnWEK/Eventra-New?node-id=0-1&t=BvLJRFvscRP9Zjp6-1)
