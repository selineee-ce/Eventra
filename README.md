# Eventra - As Your Personal Concert Hub

**Eventra** adalah platform ekosistem konser yang berfokus pada keadilan akses tiket dan pengambilan keputusan berbasis data bagi promotor. Project ini menggabungkan seluruh informasi konser dalam satu aplikasi sehingga pengguna tidak perlu lagi mengecek banyak platform berbeda.

## Tentang Project

Industri konser saat ini masih menghadapi beberapa permasalahan, seperti informasi event yang tersebar di berbagai platform, keterlambatan pengguna memperoleh informasi penjualan tiket, serta praktik *scalping* yang menyebabkan ketidakadilan akses tiket.

Eventra hadir sebagai solusi dengan menyediakan platform terpusat yang menghubungkan penggemar, artis, dan promotor dalam satu ekosistem digital. Selain mempermudah pengguna menemukan konser yang diminati, Eventra juga membantu promotor memahami minat pasar melalui fitur analytics berbasis aktivitas pengguna.

Project ini dikembangkan menggunakan metodologi **Agile Scrum** untuk mendukung kolaborasi tim yang aktif dan proses pengembangan yang fleksibel.

---

## Anggota Tim (Group 5)

* Edwin Winarto (2802445431)
* Joseline Fransiska Wijaya (2802455722)
* Kelly Aurelya Tiona (2802455325)
* Michelle Santoso (2802452582)
* Vincent Juvento (2802446011)

---

## Fitur Utama

### Untuk Pengguna

* **Platform Terpusat** – Mengintegrasikan informasi konser dalam satu aplikasi.
* **Reminder & Notifikasi Otomatis** – Pengingat jadwal konser dan penjualan tiket.
* **Personal Recommendation** – Rekomendasi konser berdasarkan preferensi pengguna.
* **Artist Profile & Subscription** – Mengikuti artis favorit dan mendapatkan update terbaru.
* **Wishlist Konser** – Menyimpan konser yang diminati untuk diakses kembali.
* **Ticket Purchasing** – Pembelian tiket secara digital melalui aplikasi.

### Untuk Promotor

* **Demand Analytics** – Analisis minat pengguna berdasarkan wishlist dan aktivitas pencarian.
* **Revenue Monitoring** – Pemantauan performa event dan penjualan tiket.
* **Event Management** – Pengelolaan event secara terpusat.

---

## Technology Stack
* **Frontend** memakai Flutter & Dart
* **Backend** dibuat dengan Node.js, Express.js & REST API
* **Database** dibuat dengan MySQL

### Development Tools
* Docker
* Docker Compose

---

## Installation & Running Guide

### Prerequisites

Pastikan perangkat telah terpasang:

* Flutter SDK
* Docker Desktop
* Git

### 1. Clone Repository

```bash
git clone [https://github.com/selineee-ce/Eventra.git]
cd eventra
```

### 2. Setup Backend & Database

Jalankan backend dan database menggunakan Docker Compose:
```bash
docker compose up --build
```

Service yang akan berjalan:

| Service        | Port |
| -------------- | ---- |
| Backend API    | 3000 |
| MySQL Database | 3306 |

Untuk menghentikan service:
```bash
docker compose down
```

### 3. Setup Frontend

Install dependency Flutter:
```bash
flutter pub get
```

Jalankan aplikasi:
```bash
flutter run
```

---

## Database Setup

Database MySQL akan dibuat otomatis melalui Docker Compose.
Jika diperlukan import database manual:

```bash
mysql -u root -p
CREATE DATABASE eventra;
```

Kemudian jalankan file SQL yang tersedia pada project.

---

## Documentation

Dokumentasi lengkap mengenai:

* Installation Guide
* Database Setup
* User Manual
* Promoter Manual
* Application Usage Guide

dapat dilihat pada file:

```text
Eventra_Guide.pdf
```

---

## Design Reference
Kamu bisa melihat prototipe desain kami di Figma melalui tautan berikut: [Eventra Figma Design](https://www.figma.com/design/LqRe0kuisKf15E9dTJnWEK/Eventra-New?node-id=0-1&t=BvLJRFvscRP9Zjp6-1)

---

## 📄 License

This project was developed for academic and educational purposes.
