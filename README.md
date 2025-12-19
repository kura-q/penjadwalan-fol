# 🤖 Sistem Inferensi Penjadwalan Ujian ETS  
**Tugas Besar Logika Orde Pertama (FOL) dan Prolog**

Disusun oleh:
- Annisa Reida Kamilaini (241524032)
- Shofiana Winocita (241524061)

Sistem ini dirancang untuk menganalisis dan mendeteksi **masalah penjadwalan ujian ETS**, khususnya terkait **konflik ruangan, validitas ruang, dan ketersediaan pengawas**.

---

## Tujuan Sistem

Sistem ini bertujuan untuk:

- Mengidentifikasi **bentrok ruangan** (ruang & waktu sama)
- Memvalidasi **ketersediaan ruang ujian**
- Mendeteksi **kelas bermasalah** secara logis dan tidak berlebihan
- Menentukan apakah suatu kelas **perlu dijadwalkan ulang**
- Mengidentifikasi kebutuhan **pengawas pengganti**
- Menunjukkan bagaimana **inferensi logis bertingkat** bekerja secara transparan

---

## Pendekatan yang Digunakan

- **Paradigma**: Logika Orde Pertama (FOL)
- **Mesin Inferensi**: SWI-Prolog
- **Frontend**: Streamlit (Python)
- **Teknik Penalaran**:
  - Unifikasi
  - Modus Ponens
  - Rantai inferensi bertingkat
  - Resolusi (konseptual)

---

## Knowledge Base (Prolog)

Knowledge Base memuat:
- Predikat
- Facts
- Rules

---

## Antarmuka Aplikasi

Aplikasi Streamlit menyediakan:

- Tombol inferensi siap pakai
- Tampilan hasil inferensi yang jelas:
  - VALID / TIDAK VALID
  - Binding variabel (jika ada)
- Query kustom untuk eksplorasi bebas
- Tampilan Knowledge Base secara langsung

---

## Cara Menjalankan

### Prasyarat
Pastikan telah terpasang:
- pyswip                    0.3.3
- streamlit                 1.51.0

### Run
```bash
streamlit run app_inferensi_kebijakan.py