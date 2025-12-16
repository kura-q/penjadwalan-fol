% =================================================================
% Knowledge Base Logika Orde Pertama (FOL) prolog_kb.pl
% TEMA: Bentrok Penjadwalan Ujian ETS
% =================================================================
% Predikat utama:
% jumlah_ruang/2, ketersediaan_ruang/2, mata_kuliah/3,
% jumlah_kelas/3, jadwal_penggunaan/3, pengawas/2,
% kelas_dijadwalkan/3, butuh_ruang/1
% =================================================================

% -----------------------------------------------------------------
% FACTS (>= 15)
% -----------------------------------------------------------------

jumlah_ruang(gedung_jtk, 6).

ketersediaan_ruang(ruang_201, terpakai).
ketersediaan_ruang(ruang_301, tersedia).
ketersediaan_ruang(ruang_401, tersedia).

mata_kuliah(mk_algoritma, tingkat_1, teori).
mata_kuliah(mk_jarkom, tingkat_2, teori).
mata_kuliah(mk_basisdata, tingkat_1, teori).

jumlah_kelas(tif, tingkat_1, 7).
jumlah_kelas(tko, tingkat_1, 2).

jadwal_penggunaan(ruang_201, jam_9, terpakai).
jadwal_penggunaan(ruang_301, jam_9, tersedia).
jadwal_penggunaan(ruang_401, jam_14, tersedia).

pengawas(pengawas_andi, hadir).
pengawas(pengawas_budi, tidak_hadir).
pengawas(pengawas_citra, hadir).

kelas_dijadwalkan(kelasA, mk_algoritma, jam_9).
kelas_dijadwalkan(kelasB, mk_jarkom, jam_9).
kelas_dijadwalkan(kelasC, mk_basisdata, jam_14).

butuh_ruang(kelasA).
butuh_ruang(kelasB).
butuh_ruang(kelasC).


% -----------------------------------------------------------------
% RULES (>= 8)
% -----------------------------------------------------------------

% Rule 1 — Bentrok Ruangan
bentrok_ruangan(K1, K2) :-
    kelas_dijadwalkan(K1, _, W),
    kelas_dijadwalkan(K2, _, W),
    K1 \= K2.

% Rule 2 — Ruangan Tidak Dapat Digunakan
ruang_tidak_dapat_dipakai(R, W) :-
    jadwal_penggunaan(R, W, terpakai),
    ketersediaan_ruang(R, terpakai).

% Rule 3 — Kekurangan Ruang
kekurangan_ruang(Prodi, Tingkat) :-
    jumlah_kelas(Prodi, Tingkat, JK),
    jumlah_ruang(gedung_jtk, JR),
    JK > JR.

% Rule 4 — Potensi Bentrok Ruang
potensi_bentrok(K, R, W) :-
    kelas_dijadwalkan(K, _, W),
    ruang_tidak_dapat_dipakai(R, W).

% Rule 5 — Pengawas Tidak Bisa Mengawasi
pengawas_tidak_bisa(P, K) :-
    pengawas(P, tidak_hadir),
    kelas_dijadwalkan(K, _, _).

% Rule 6 — Kelas Bermasalah (rantai 1)
kelas_bermasalah(K) :-
    bentrok_ruangan(K, _).

% Rule 7 — Jadwal Bermasalah (rantai 2)
jadwal_bermasalah(K) :-
    kelas_bermasalah(K),
    butuh_ruang(K).

% Rule 8 — Perlu Penjadwalan Ulang (rantai 3)
perlu_penjadwalan_ulang(K) :-
    jadwal_bermasalah(K).
