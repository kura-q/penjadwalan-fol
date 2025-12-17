% =================================================================
% FILE: prolog_kb.pl
% Knowledge Base Logika Orde Pertama (FOL)
% TEMA: Bentrok Penjadwalan Ujian ETS 
% =================================================================
% Predikat:
% jumlah_ruang/2, ketersediaan_ruang/2, mata_kuliah/3,
% jumlah_kelas/3, jadwal_penggunaan/3, pengawas/2,
% kelas_dijadwalkan/3, butuh_ruang/1,
% kelas_di_ruang/3, ditugaskan/3, kebutuhan_ruang/2
% =================================================================

% -----------------------------------------------------------------
% FACTS
% -----------------------------------------------------------------

% Kapasitas ruang di gedung
jumlah_ruang(gedung_jtk, 6).

% Status ruang (umum)
ketersediaan_ruang(ruang_201, terpakai).
ketersediaan_ruang(ruang_301, tersedia).
ketersediaan_ruang(ruang_401, tersedia).

% Jadwal penggunaan ruang (slot waktu)
jadwal_penggunaan(ruang_201, jam_9, terpakai).
jadwal_penggunaan(ruang_301, jam_9, tersedia).
jadwal_penggunaan(ruang_401, jam_14, tersedia).

% Mata kuliah
mata_kuliah(mk_algoritma, tingkat_1, teori).
mata_kuliah(mk_jarkom, tingkat_2, teori).
mata_kuliah(mk_basisdata, tingkat_1, teori).

% Jumlah kelas per prodi-tingkat
jumlah_kelas(tif, tingkat_1, 7).
jumlah_kelas(tko, tingkat_1, 2).

% Pengawas dan kehadiran
pengawas(pengawas_andi, hadir).
pengawas(pengawas_budi, tidak_hadir).
pengawas(pengawas_citra, hadir).

% Kelas dijadwalkan (kelas, mk, waktu)
kelas_dijadwalkan(kelasA, mk_algoritma, jam_9).
kelas_dijadwalkan(kelasB, mk_jarkom, jam_9).
kelas_dijadwalkan(kelasC, mk_basisdata, jam_14).

% Kelas butuh ruang (semua ujian butuh ruang)
butuh_ruang(kelasA).
butuh_ruang(kelasB).
butuh_ruang(kelasC).

% Penempatan kelas ke ruang (kelas, ruang, waktu)
kelas_di_ruang(kelasA, ruang_201, jam_9).
kelas_di_ruang(kelasB, ruang_201, jam_9).   % sengaja dibuat konflik ruang yang nyata
kelas_di_ruang(kelasC, ruang_401, jam_14).

% Penugasan pengawas (pengawas, kelas, waktu)
ditugaskan(pengawas_andi, kelasA, jam_9).
ditugaskan(pengawas_budi, kelasB, jam_9).   % budi tidak hadir → masalah spesifik ke kelasB
ditugaskan(pengawas_citra, kelasC, jam_14).

% Kebutuhan ruang berdasarkan tipe MK (contoh sederhana)
kebutuhan_ruang(teori, ruang_kelas).
kebutuhan_ruang(praktek, lab).


% -----------------------------------------------------------------
% RULES
% -----------------------------------------------------------------

% Rule 1 — Bentrok Ruangan yang benar-benar “ruang sama, waktu sama”
bentrok_ruangan(K1, K2) :-
    kelas_di_ruang(K1, R, W),
    kelas_di_ruang(K2, R, W),
    K1 @< K2.

% Rule 2 — Ruangan tidak dapat dipakai jika pada waktu itu terpakai + statusnya terpakai
ruang_tidak_dapat_dipakai(R, W) :-
    jadwal_penggunaan(R, W, terpakai),
    ketersediaan_ruang(R, terpakai).

% Rule 3 — Kekurangan ruang jika jumlah kelas prodi-tingkat melebihi jumlah ruang gedung
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
% Ini memperbaiki “budi otomatis tidak bisa untuk semua kelas”.
pengawas_tidak_bisa(P, K) :-
    ditugaskan(P, K, _W),
    pengawas(P, tidak_hadir).

% Rule 6 — Kelas bermasalah jika bentrok ruangan ATAU terkena potensi bentrok (ruang tidak bisa dipakai)
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

% Rule 9 — Perlu pengawas pengganti jika pengawas tidak bisa mengawasi kelas tersebut
butuh_pengawas_pengganti(K) :-
    pengawas_tidak_bisa(_, K).
