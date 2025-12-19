% =================================================================
% FILE: prolog_kb.pl
% Knowledge Base Logika Orde Pertama (FOL)
% TEMA: Bentrok Penjadwalan Ujian ETS
%   Deteksi bentrok penjadwalan ujian ETS berbasis:
%   - Konflik ruang (ruang & waktu sama)
%   - Validitas ketersediaan ruang
%   - Kehadiran pengawas
% =================================================================
% Predikat:
% jumlah_ruang/1, ketersediaan_ruang/3, mata_kuliah/3,
% jumlah_kelas/2, jadwal_penggunaan/3, pengawas/3,
% kelas_dijadwalkan/3, butuh_ruang/3,
% kelas_di_ruang/3, ditugaskan/3, kebutuhan_ruang/2 = 29 fakta
% =================================================================

% -----------------------------------------------------------------
%                      PENJELASAN PREDIKAT UTAMA
% -----------------------------------------------------------------
% jumlah_ruang(Gedung, Jumlah) :
%   Menyatakan jumlah total ruang yang tersedia di suatu gedung.
%
% ketersediaan_ruang(Ruang, Status) :
%   Status umum ruang (tersedia / terpakai).
%
% jadwal_penggunaan(Ruang, Waktu, Status) :
%   Menyatakan apakah ruang dipakai pada slot waktu tertentu.
%
% mata_kuliah(KodeMK, Tingkat, Tipe) :
%   Informasi mata kuliah untuk kepentingan pemodelan ujian.
%
% jumlah_kelas(Prodi, Tingkat, Jumlah) :
%   Digunakan untuk analisis kekurangan ruang.
%
% pengawas(Nama, Status) :
%   Status kehadiran pengawas ujian.
%
% kelas_dijadwalkan(Kelas, MK, Waktu) :
%   Jadwal ujian tiap kelas.
%
% butuh_ruang(Kelas) :
%   Menyatakan bahwa kelas tersebut memerlukan ruang fisik.
%
% kelas_di_ruang(Kelas, Ruang, Waktu) :
%   Penempatan kelas pada ruang dan waktu tertentu.
%
% ditugaskan(Pengawas, Kelas, Waktu) :
%   Relasi penugasan pengawas terhadap kelas ujian.
%
% kebutuhan_ruang(TipeMK, JenisRuang) :
%   Abstraksi kebutuhan ruang berdasarkan tipe mata kuliah.
% -----------------------------------------------------------------

% -----------------------------------------------------------------
%                               FACTS
% -----------------------------------------------------------------

% Kapasitas ruang di gedung
% Fakta ini menyatakan bahwa gedung_jtk memiliki 6 ruang ujian
% Fakta ini digunakan dalam kekurangan_ruang
jumlah_ruang(gedung_jtk, 6).

% Status ruang (umum, bukan spesifik waktu)
% Digunakan bersama jadwal_penggunaan untuk menentukan validitas ruang
ketersediaan_ruang(ruang_201, terpakai).
ketersediaan_ruang(ruang_301, tersedia).
ketersediaan_ruang(ruang_401, tersedia).

% Jadwal penggunaan ruang (slot waktu)
% Fakta ini menjadi dasar ruang_tidak_dapat_dipakai
jadwal_penggunaan(ruang_201, jam_9, terpakai).
jadwal_penggunaan(ruang_301, jam_9, tersedia).
jadwal_penggunaan(ruang_401, jam_14, tersedia).

% Informasi mata kuliah
% Digunakan sebagai konteks akademik, bukan langsung untuk konflik
mata_kuliah(mk_algoritma, tingkat_1, teori).
mata_kuliah(mk_jarkom, tingkat_2, teori).
mata_kuliah(mk_basisdata, tingkat_1, teori).

% Jumlah kelas per prodi dan tingkat
% Fakta ini memungkinkan deteksi kekurangan ruang secara logis
jumlah_kelas(tif, tingkat_1, 7).
jumlah_kelas(tko, tingkat_1, 2).

% Status kehadiran pengawas
% Digunakan untuk inferensi pengawas_tidak_bisa
pengawas(pengawas_andi, hadir).
pengawas(pengawas_budi, tidak_hadir).
pengawas(pengawas_citra, hadir).

% Jadwal ujian kelas (kelas, mk, waktu)
% Fakta ini menandai bahwa kelas memang memiliki ujian
kelas_dijadwalkan(kelasA, mk_algoritma, jam_9).
kelas_dijadwalkan(kelasB, mk_jarkom, jam_9).
kelas_dijadwalkan(kelasC, mk_basisdata, jam_14).

% Kelas butuh ruang (semua ujian butuh ruang)
butuh_ruang(kelasA).
butuh_ruang(kelasB).
butuh_ruang(kelasC).

% Penempatan kelas ke ruang (kelas, ruang, waktu)
% kelasA dan kelasB sengaja ditempatkan di ruang & waktu sama
% untuk menghasilkan konflik nyata (bentrok_ruangan)
kelas_di_ruang(kelasA, ruang_201, jam_9).
kelas_di_ruang(kelasB, ruang_201, jam_9).   % sengaja dibuat konflik ruang yang nyata
kelas_di_ruang(kelasC, ruang_401, jam_14).

% Penugasan pengawas (pengawas, kelas, waktu)
% pengawas_budi tidak hadir → menghasilkan masalah spesifik kelasB
ditugaskan(pengawas_andi, kelasA, jam_9).
ditugaskan(pengawas_budi, kelasB, jam_9).   % budi tidak hadir → masalah spesifik ke kelasB
ditugaskan(pengawas_citra, kelasC, jam_14).

% Kebutuhan ruang berdasarkan tipe MK (contoh sederhana)
% Digunakan sebagai abstraksi tambahan (ekstensibilitas KB)
kebutuhan_ruang(teori, ruang_kelas).
kebutuhan_ruang(praktek, lab).


% -----------------------------------------------------------------
% RULES
% -----------------------------------------------------------------

% Rule 1 — Bentrok Ruangan yang benar-benar “ruang sama, waktu sama”
% Dua kelas bentrok jika:
% - Menggunakan ruang yang sama
% - Pada waktu yang sama
% - Dengan pembatas K1 @< K2 untuk menghindari duplikasi solusi
bentrok_ruangan(K1, K2) :-
    kelas_di_ruang(K1, R, W),
    kelas_di_ruang(K2, R, W),
    K1 @< K2.

% Rule 2 — Ruangan tidak dapat dipakai jika:
% - Pada waktu tertentu sudah terpakai
% - Dan status global ruang juga terpakai
ruang_tidak_dapat_dipakai(R, W) :-
    jadwal_penggunaan(R, W, terpakai),
    ketersediaan_ruang(R, terpakai).

% Rule 3 — Kekurangan ruang jika jumlah kelas prodi-tingkat melebihi jumlah ruang gedung
% Rule ini tidak bergantung pada waktu, murni logika kapasitas
kekurangan_ruang(Prodi, Tingkat) :-
    jumlah_kelas(Prodi, Tingkat, JK),
    jumlah_ruang(gedung_jtk, JR),
    JK > JR.

% Rule 4 — Potensi bentrok: kelas butuh ruang pada W, tapi ruang yang dipakai pada W ternyata tidak bisa dipakai
% (mengaitkan butuh_ruang + kelas_di_ruang + ruang_tidak_dapat_dipakai)
potensi_bentrok(K, R, W) :-
    butuh_ruang(K),
    kelas_di_ruang(K, R, W),
    ruang_tidak_dapat_dipakai(R, W).

% Rule 5 — Pengawas tidak bisa mengawasi kelas tertentu jika (ditugaskan ke kelas tsb) dan dia tidak hadir
pengawas_tidak_bisa(P, K) :-
    ditugaskan(P, K, _W),
    pengawas(P, tidak_hadir).

% Rule 6 — Kelas bermasalah 
% Sebuah kelas bermasalah jika:
% - Terlibat bentrok ruangan (posisi kiri atau kanan)
% - ATAU terkena potensi bentrok ruang
kelas_bermasalah(K) :-
    bentrok_ruangan(K, _).
kelas_bermasalah(K) :-
    bentrok_ruangan(_, K).
kelas_bermasalah(K) :-
    potensi_bentrok(K, _, _).

% Rule 7 — Jadwal bermasalah jika kelas bermasalah dan kelas itu memang dijadwalkan ujian
jadwal_bermasalah(K) :-
    kelas_bermasalah(K),
    kelas_dijadwalkan(K, _, _).

% Rule 8 — Perlu penjadwalan ulang jika jadwal bermasalah
perlu_penjadwalan_ulang(K) :-
    jadwal_bermasalah(K).

% Rule 9 — Perlu pengawas pengganti
% Kelas membutuhkan pengawas pengganti jika:
% Ada pengawas yang tidak bisa mengawasi kelas tersebut
butuh_pengawas_pengganti(K) :-
    pengawas_tidak_bisa(_, K).
