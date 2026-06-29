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

## Page Documentations

### User Pages

#### Authentication
- **Login Page** - Halaman masuk pengguna untuk mengakses akun Eventra.

  ![Login Page](screenshots/loginPage.png)

- **Register Page** - Halaman pendaftaran akun baru bagi pengguna.

  ![Register Page](screenshots/registerPage.png)

#### Home & Exploration
- **Home Page** - Tampilan utama aplikasi yang menampilkan daftar event, banner unggulan, serta fitur pencarian dan rekomendasi.

  ![Home Page](screenshots/homePage.png)

- **Home Page (Additional View)** - Tampilan lain dari halaman beranda yang menampilkan konten event dan kategori tambahan.

  ![Home Page Additional View](screenshots/homePage1.png)

- **Trending Page** - Halaman yang menampilkan event-event populer atau sedang tren.

  ![Trending Page](screenshots/trendingPage.png)

- **Search Page** - Halaman pencarian event dengan filter dan fitur pencarian lanjutan.

  ![Search Page](screenshots/searchPage.png)

- **Notification Page** - Halaman notifikasi yang menampilkan update event dan reminder tiket.

  ![Notification Page](screenshots/notificationPage.png)

#### Event & Artist Details
- **Artist Profile Page** - Halaman profil artis yang menampilkan informasi artis dan event terkait.

  ![Artist Profile Page](screenshots/artistProfile.png)

- **Event Detail Page** - Halaman detail event yang menampilkan informasi lengkap konser dan jadwal.

  ![Event Detail Page](screenshots/eventDetail.png)

- **Ticket Page** - Halaman detail tiket yang berisi informasi pembelian dan akses tiket.

  ![Ticket Page](screenshots/ticketPage.png)

#### Purchase & Payment
- **Checkout Page** - Halaman checkout untuk memproses pemesanan tiket.

  ![Checkout Page](screenshots/checkoutPage.png)

- **Payment Page** - Halaman pembayaran sebelum tiket dikonfirmasi.

  ![Payment Page](screenshots/paymentPage.png)

- **Payment Status Page** - Halaman status pembayaran setelah transaksi diproses.

  ![Payment Status Page](screenshots/paymentStatus.png)

#### User Profile
- **Profile Page** - Halaman profil pengguna yang menampilkan informasi akun dan pengaturan.

  ![Profile Page](screenshots/profilePage.png)

### Promotor Pages

- **Promotor Login Page** - Halaman login khusus untuk promotor mengakses dashboard dan fitur manajemen event.

  ![Promotor Login Page](screenshots/promotorLogin.png)

- **Promotor Home Page** - Dashboard utama promotor yang menampilkan ringkasan event dan performa penjualan tiket.

  ![Promotor Home Page](screenshots/promotorHomePage.png)

- **Promotor Event Page** - Halaman manajemen event untuk promotor mengelola acara dan tiket.

  ![Promotor Event Page](screenshots/promotorEventPage.png)

- **Create Event Page** - Halaman pembuatan event baru dengan form detail event dan konfigurasi tiket.

  ![Create Event Page](screenshots/createEventPage.png)

- **Promotor Profile Page** - Halaman profil promotor dengan informasi perusahaan dan pengaturan akun.

  ![Promotor Profile Page](screenshots/promotorProfile.png)

- **Analytics Page** - Halaman analytics yang menampilkan data demand, trend event, dan insights pengguna untuk pengambilan keputusan promotor.

  ![Analytics Page](screenshots/analyticsPage.png)

## 📄 License

This project was developed for academic and educational purposes.
