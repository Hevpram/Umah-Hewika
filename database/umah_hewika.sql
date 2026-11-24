DROP DATABASE IF EXISTS umah_hewika;
CREATE DATABASE umah_hewika
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE umah_hewika;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================================
-- 1. Pengguna dan peran
-- =============================================================================

CREATE TABLE users (
  id_user       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  username      VARCHAR(50)  NOT NULL,
  email         VARCHAR(255) NOT NULL,
  password      VARCHAR(255) NOT NULL,
  nama_lengkap  VARCHAR(100) NOT NULL,
  no_hp         VARCHAR(20)  NOT NULL,
  `role`        ENUM('tamu','resepsionis','housekeeping','owner') NOT NULL,
  foto_profil   VARCHAR(255) NULL,
  is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_user),
  UNIQUE KEY uk_users_username (username),
  UNIQUE KEY uk_users_email (email),
  UNIQUE KEY uk_users_no_hp (no_hp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tamu (
  id_tamu         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_user         BIGINT UNSIGNED NOT NULL,
  nik             VARCHAR(20) NULL,
  alamat          TEXT NULL,
  tanggal_lahir   DATE NULL,
  jenis_kelamin   ENUM('L','P') NULL,
  is_blacklisted  BOOLEAN  NOT NULL DEFAULT FALSE,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_tamu),
  UNIQUE KEY uk_tamu_id_user (id_user),
  CONSTRAINT fk_tamu_user
    FOREIGN KEY (id_user) REFERENCES users (id_user)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE resepsionis (
  id_resepsionis     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_user            BIGINT UNSIGNED NOT NULL,
  kode_pegawai       VARCHAR(20) NOT NULL,
  tanggal_bergabung  DATE        NOT NULL,
  shift              ENUM('pagi','siang','malam') NOT NULL,
  created_at         DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_resepsionis),
  UNIQUE KEY uk_resepsionis_id_user (id_user),
  UNIQUE KEY uk_resepsionis_kode_pegawai (kode_pegawai),
  CONSTRAINT fk_resepsionis_user
    FOREIGN KEY (id_user) REFERENCES users (id_user)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE housekeeping (
  id_housekeeping    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_user            BIGINT UNSIGNED NOT NULL,
  kode_pegawai       VARCHAR(20) NOT NULL,
  tanggal_bergabung  DATE        NOT NULL,
  shift              ENUM('pagi','siang','malam') NOT NULL,
  created_at         DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_housekeeping),
  UNIQUE KEY uk_housekeeping_id_user (id_user),
  UNIQUE KEY uk_housekeeping_kode_pegawai (kode_pegawai),
  CONSTRAINT fk_housekeeping_user
    FOREIGN KEY (id_user) REFERENCES users (id_user)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE owner (
  id_owner    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_user     BIGINT UNSIGNED NOT NULL,
  nama_usaha  VARCHAR(100) NULL,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_owner),
  UNIQUE KEY uk_owner_id_user (id_user),
  CONSTRAINT fk_owner_user
    FOREIGN KEY (id_user) REFERENCES users (id_user)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE blacklist_tamu (
  id_blacklist        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_tamu             BIGINT UNSIGNED NOT NULL,
  id_pengaju          BIGINT UNSIGNED NOT NULL,
  id_pemutus          BIGINT UNSIGNED NULL,
  alasan              TEXT NOT NULL,
  status              ENUM('menunggu','disetujui','ditolak','dicabut') NOT NULL,
  tanggal_pengajuan   DATETIME NOT NULL,
  tanggal_keputusan   DATETIME NULL,
  catatan_keputusan   TEXT NULL,
  created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_blacklist),
  CONSTRAINT fk_blacklist_tamu
    FOREIGN KEY (id_tamu) REFERENCES tamu (id_tamu)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_blacklist_pengaju
    FOREIGN KEY (id_pengaju) REFERENCES resepsionis (id_resepsionis)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_blacklist_pemutus
    FOREIGN KEY (id_pemutus) REFERENCES owner (id_owner)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 2. Kamar dan fasilitas
-- =============================================================================

CREATE TABLE tipe_kamar (
  id_tipe_kamar  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama_tipe      VARCHAR(50) NOT NULL,
  deskripsi      TEXT NOT NULL,
  kapasitas      INT NOT NULL,
  harga_dasar    DECIMAL(10,0) NOT NULL,
  foto           VARCHAR(255) NULL,
  is_active      BOOLEAN  NOT NULL DEFAULT TRUE,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_tipe_kamar),
  UNIQUE KEY uk_tipe_kamar_nama (nama_tipe)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE kamar (
  id_kamar       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_tipe_kamar  BIGINT UNSIGNED NOT NULL,
  nomor_kamar    VARCHAR(10) NOT NULL,
  status         ENUM('tersedia','terisi','perlu_dibersihkan','rusak') NOT NULL,
  keterangan     VARCHAR(255) NULL,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_kamar),
  UNIQUE KEY uk_kamar_nomor (nomor_kamar),
  CONSTRAINT fk_kamar_tipe
    FOREIGN KEY (id_tipe_kamar) REFERENCES tipe_kamar (id_tipe_kamar)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE fasilitas (
  id_fasilitas    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama_fasilitas  VARCHAR(100) NOT NULL,
  ikon            VARCHAR(255) NULL,
  keterangan      TEXT NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_fasilitas),
  UNIQUE KEY uk_fasilitas_nama (nama_fasilitas)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE kamar_fasilitas (
  id_kamar      BIGINT UNSIGNED NOT NULL,
  id_fasilitas  BIGINT UNSIGNED NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_kamar, id_fasilitas),
  CONSTRAINT fk_kamar_fasilitas_kamar
    FOREIGN KEY (id_kamar) REFERENCES kamar (id_kamar)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_kamar_fasilitas_fasilitas
    FOREIGN KEY (id_fasilitas) REFERENCES fasilitas (id_fasilitas)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 3. Promo dan keanggotaan
-- =============================================================================

CREATE TABLE promo (
  id_promo             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  kode_promo           VARCHAR(20)  NOT NULL,
  nama_promo           VARCHAR(100) NOT NULL,
  persen_diskon        INT NOT NULL,
  keterangan_periode   VARCHAR(50) NULL,
  is_active            BOOLEAN  NOT NULL DEFAULT TRUE,
  created_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_promo),
  UNIQUE KEY uk_promo_kode (kode_promo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE jenis_member (
  id_jenis_member  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama_jenis       VARCHAR(30) NOT NULL,
  persen_diskon    INT NOT NULL,
  benefit          VARCHAR(255) NULL,
  biaya            DECIMAL(10,0) NOT NULL,
  kuota_voucher    INT NOT NULL,
  is_active        BOOLEAN  NOT NULL DEFAULT TRUE,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_jenis_member),
  UNIQUE KEY uk_jenis_member_nama (nama_jenis)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE kartu_member (
  id_kartu_member   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_tamu           BIGINT UNSIGNED NOT NULL,
  id_jenis_member   BIGINT UNSIGNED NOT NULL,
  nomor_kartu       VARCHAR(20) NOT NULL,
  tanggal_terbit    DATE NOT NULL,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_kartu_member),
  UNIQUE KEY uk_kartu_member_id_tamu (id_tamu),
  UNIQUE KEY uk_kartu_member_nomor (nomor_kartu),
  CONSTRAINT fk_kartu_member_tamu
    FOREIGN KEY (id_tamu) REFERENCES tamu (id_tamu)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_kartu_member_jenis
    FOREIGN KEY (id_jenis_member) REFERENCES jenis_member (id_jenis_member)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE langganan_member (
  id_langganan       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_kartu_member    BIGINT UNSIGNED NOT NULL,
  tanggal_mulai      DATE NOT NULL,
  tanggal_berakhir   DATE NOT NULL,
  biaya              DECIMAL(10,0) NOT NULL,
  status             ENUM('aktif','kedaluwarsa','dibatalkan') NOT NULL,
  created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_langganan),
  CONSTRAINT fk_langganan_kartu
    FOREIGN KEY (id_kartu_member) REFERENCES kartu_member (id_kartu_member)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE voucher_member (
  id_voucher_member    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_kartu_member      BIGINT UNSIGNED NOT NULL,
  id_promo             BIGINT UNSIGNED NOT NULL,
  kode_voucher         VARCHAR(20) NOT NULL,
  tanggal_berlaku      DATE NOT NULL,
  tanggal_kedaluwarsa  DATE NOT NULL,
  status               ENUM('tersedia','terpakai','kedaluwarsa') NOT NULL,
  created_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_voucher_member),
  UNIQUE KEY uk_voucher_member_kode (kode_voucher),
  CONSTRAINT fk_voucher_kartu
    FOREIGN KEY (id_kartu_member) REFERENCES kartu_member (id_kartu_member)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_voucher_promo
    FOREIGN KEY (id_promo) REFERENCES promo (id_promo)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 4. Reservasi dan pembayaran
-- =============================================================================

CREATE TABLE reservasi (
  id_reservasi       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_tamu            BIGINT UNSIGNED NOT NULL,
  kode_reservasi     VARCHAR(20) NOT NULL,
  tanggal_checkin    DATE NOT NULL,
  tanggal_checkout   DATE NOT NULL,
  jumlah_tamu        INT NOT NULL,
  jenis              ENUM('online','walk_in') NOT NULL,
  subtotal           DECIMAL(10,0) NOT NULL,
  total_diskon       DECIMAL(10,0) NOT NULL DEFAULT 0,
  total_harga        DECIMAL(10,0) NOT NULL,
  status             ENUM('menunggu_pembayaran','menunggu_verifikasi','dikonfirmasi','check_in','check_out','dibatalkan') NOT NULL,
  created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_reservasi),
  UNIQUE KEY uk_reservasi_kode (kode_reservasi),
  CONSTRAINT fk_reservasi_tamu
    FOREIGN KEY (id_tamu) REFERENCES tamu (id_tamu)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detail_reservasi (
  id_detail_reservasi  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_reservasi         BIGINT UNSIGNED NOT NULL,
  id_kamar             BIGINT UNSIGNED NULL,
  harga_per_malam      DECIMAL(10,0) NOT NULL,
  jumlah_malam         INT NOT NULL,
  subtotal             DECIMAL(10,0) NOT NULL,
  created_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_detail_reservasi),
  CONSTRAINT fk_detail_reservasi
    FOREIGN KEY (id_reservasi) REFERENCES reservasi (id_reservasi)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_detail_kamar
    FOREIGN KEY (id_kamar) REFERENCES kamar (id_kamar)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pembayaran (
  id_pembayaran       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_reservasi        BIGINT UNSIGNED NOT NULL,
  id_verifikator      BIGINT UNSIGNED NULL,
  metode              ENUM('transfer','qris','tunai') NOT NULL,
  jumlah              DECIMAL(10,0) NOT NULL,
  nama_pengirim       VARCHAR(100) NULL,
  bank_pengirim       VARCHAR(50) NULL,
  rekening_pengirim   VARCHAR(30) NULL,
  no_referensi        VARCHAR(50) NULL,
  bukti_transfer      VARCHAR(255) NULL,
  waktu_transfer      DATETIME NOT NULL,
  status_verifikasi   ENUM('menunggu','diterima','ditolak') NOT NULL,
  waktu_verifikasi    DATETIME NULL,
  catatan             TEXT NULL,
  created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_pembayaran),
  CONSTRAINT fk_pembayaran_reservasi
    FOREIGN KEY (id_reservasi) REFERENCES reservasi (id_reservasi)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pembayaran_verifikator
    FOREIGN KEY (id_verifikator) REFERENCES resepsionis (id_resepsionis)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE penggunaan_voucher (
  id_penggunaan_voucher  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_voucher_member      BIGINT UNSIGNED NOT NULL,
  id_reservasi           BIGINT UNSIGNED NOT NULL,
  nilai_potongan         DECIMAL(10,0) NOT NULL,
  tanggal_digunakan      DATETIME NOT NULL,
  created_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_penggunaan_voucher),
  UNIQUE KEY uk_penggunaan_voucher_member (id_voucher_member),
  CONSTRAINT fk_penggunaan_voucher
    FOREIGN KEY (id_voucher_member) REFERENCES voucher_member (id_voucher_member)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_penggunaan_reservasi
    FOREIGN KEY (id_reservasi) REFERENCES reservasi (id_reservasi)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 5. Operasional: barang tertinggal, kerusakan, kebersihan
-- =============================================================================

CREATE TABLE barang_tertinggal (
  id_barang         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_resepsionis    BIGINT UNSIGNED NOT NULL,
  id_kamar          BIGINT UNSIGNED NULL,
  id_reservasi      BIGINT UNSIGNED NULL,
  nama_barang       VARCHAR(100) NOT NULL,
  foto              VARCHAR(255) NULL,
  lokasi_ditemukan  VARCHAR(100) NOT NULL,
  no_wa_pemilik     VARCHAR(20) NULL,
  status            ENUM('belum_diambil','sudah_diambil') NOT NULL,
  catatan           TEXT NULL,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_barang),
  CONSTRAINT fk_barang_resepsionis
    FOREIGN KEY (id_resepsionis) REFERENCES resepsionis (id_resepsionis)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_barang_kamar
    FOREIGN KEY (id_kamar) REFERENCES kamar (id_kamar)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_barang_reservasi
    FOREIGN KEY (id_reservasi) REFERENCES reservasi (id_reservasi)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE laporan_kerusakan (
  id_laporan       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_kamar         BIGINT UNSIGNED NOT NULL,
  id_housekeeping  BIGINT UNSIGNED NOT NULL,
  kategori         VARCHAR(50) NOT NULL,
  deskripsi        TEXT NOT NULL,
  foto             VARCHAR(255) NULL,
  tingkat          ENUM('rendah','sedang','tinggi') NOT NULL,
  status           ENUM('dilaporkan','diproses','selesai') NOT NULL,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_laporan),
  CONSTRAINT fk_laporan_kamar
    FOREIGN KEY (id_kamar) REFERENCES kamar (id_kamar)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_laporan_housekeeping
    FOREIGN KEY (id_housekeeping) REFERENCES housekeeping (id_housekeeping)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE kebersihan (
  id_kebersihan       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_kamar            BIGINT UNSIGNED NOT NULL,
  id_housekeeping     BIGINT UNSIGNED NOT NULL,
  ganti_sprei         BOOLEAN  NOT NULL DEFAULT FALSE,
  bersih_kamar_mandi  BOOLEAN  NOT NULL DEFAULT FALSE,
  isi_perlengkapan    BOOLEAN  NOT NULL DEFAULT FALSE,
  vakum_pel           BOOLEAN  NOT NULL DEFAULT FALSE,
  lap_perabot         BOOLEAN  NOT NULL DEFAULT FALSE,
  cek_elektronik      BOOLEAN  NOT NULL DEFAULT FALSE,
  buang_sampah        BOOLEAN  NOT NULL DEFAULT FALSE,
  status              ENUM('dibersihkan','siap') NOT NULL,
  created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_kebersihan),
  CONSTRAINT fk_kebersihan_kamar
    FOREIGN KEY (id_kamar) REFERENCES kamar (id_kamar)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_kebersihan_housekeeping
    FOREIGN KEY (id_housekeeping) REFERENCES housekeeping (id_housekeeping)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- DATA DUMMY
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Pengguna (1 owner, 2 resepsionis, 2 housekeeping, 5 tamu)
-- -----------------------------------------------------------------------------
INSERT INTO users
  (id_user, username, email, password, nama_lengkap, no_hp, `role`, foto_profil, is_active, created_at, updated_at)
VALUES
  (1,  'kadekhevan',    'hevan@umahhewika.com',      'password123', 'Kadek Hevan Pramana Wijaya', '081234567890', 'owner',         NULL, TRUE,  '2024-01-02 08:00:00', '2024-01-02 08:00:00'),
  (2,  'madeayu',       'ayu@umahhewika.com',        'password123', 'Ni Made Ayu Pratiwi',        '081234567891', 'resepsionis',   NULL, TRUE,  '2024-01-08 08:00:00', '2024-01-08 08:00:00'),
  (3,  'ketutwirawan',  'ketut@umahhewika.com',      'password123', 'I Ketut Wirawan',            '081234567892', 'resepsionis',   NULL, TRUE,  '2024-06-15 08:00:00', '2024-06-15 08:00:00'),
  (4,  'luhsari',       'sari@umahhewika.com',       'password123', 'Ni Luh Putu Sari',           '081234567893', 'housekeeping',  NULL, TRUE,  '2024-02-01 08:00:00', '2024-02-01 08:00:00'),
  (5,  'wayangede',     'wayan@umahhewika.com',      'password123', 'I Wayan Gede Artawan',       '081234567894', 'housekeeping',  NULL, TRUE,  '2024-03-20 08:00:00', '2024-03-20 08:00:00'),
  (6,  'putuaditya',    'aditya@gmail.com',          'password123', 'I Putu Aditya Wirawan',      '081345678901', 'tamu',          NULL, TRUE,  '2026-01-10 10:15:00', '2026-01-10 10:15:00'),
  (7,  'komangdewi',    'dewi.lestari@gmail.com',    'password123', 'Ni Komang Dewi Lestari',     '081345678902', 'tamu',          NULL, TRUE,  '2026-02-20 14:30:00', '2026-02-20 14:30:00'),
  (8,  'ngurahbagus',   'bagus@yahoo.com',           'password123', 'I Gusti Ngurah Bagus Putra', '081345678903', 'tamu',          NULL, TRUE,  '2026-02-05 09:45:00', '2026-02-05 09:45:00'),
  (9,  'maderatih',     'ratih@gmail.com',           'password123', 'Ni Made Ratih Prameswari',   '081345678904', 'tamu',          NULL, TRUE,  '2026-08-20 16:00:00', '2026-09-04 11:00:00'),
  (10, 'kadekyoga',     'yoga@gmail.com',            'password123', 'I Kadek Yoga Pratama',       '081345678905', 'tamu',          NULL, TRUE,  '2026-11-01 11:20:00', '2026-11-01 11:20:00');

INSERT INTO tamu
  (id_tamu, id_user, nik, alamat, tanggal_lahir, jenis_kelamin, is_blacklisted, created_at, updated_at)
VALUES
  (1, 6, '5171011504980003', 'Jl. Diponegoro No. 45, Denpasar, Bali',            '1998-04-15', 'L', FALSE, '2026-01-10 10:15:00', '2026-01-10 10:15:00'),
  (2, 7, '5104015202000006', 'Br. Kawan, Blahbatuh, Gianyar, Bali',              '2000-02-12', 'P', FALSE, '2026-02-20 14:30:00', '2026-02-20 14:30:00'),
  (3, 8, '5103021001970002', 'Jl. Raya Kuta No. 88, Badung, Bali',               '1997-01-10', 'L', FALSE, '2026-02-05 09:45:00', '2026-02-05 09:45:00'),
  (4, 9, '5108055201990008', 'Jl. Monkey Forest, Ubud, Gianyar, Bali',           '1999-05-12', 'P', TRUE,  '2026-08-20 16:00:00', '2026-09-04 11:00:00'),
  (5, 10,'5102042005010001', 'Jl. Pahlawan No. 12, Tabanan, Bali',               '2001-05-20', 'L', FALSE, '2026-11-01 11:20:00', '2026-11-01 11:20:00');

INSERT INTO resepsionis
  (id_resepsionis, id_user, kode_pegawai, tanggal_bergabung, shift, created_at, updated_at)
VALUES
  (1, 2, 'RSP-001', '2024-01-08', 'pagi',  '2024-01-08 08:00:00', '2024-01-08 08:00:00'),
  (2, 3, 'RSP-002', '2024-06-15', 'malam', '2024-06-15 08:00:00', '2024-06-15 08:00:00');

INSERT INTO housekeeping
  (id_housekeeping, id_user, kode_pegawai, tanggal_bergabung, shift, created_at, updated_at)
VALUES
  (1, 4, 'HSK-001', '2024-02-01', 'pagi',  '2024-02-01 08:00:00', '2024-02-01 08:00:00'),
  (2, 5, 'HSK-002', '2024-03-20', 'siang', '2024-03-20 08:00:00', '2024-03-20 08:00:00');

INSERT INTO owner
  (id_owner, id_user, nama_usaha, created_at, updated_at)
VALUES
  (1, 1, 'Umah Hewika', '2024-01-02 08:00:00', '2024-01-02 08:00:00');

-- -----------------------------------------------------------------------------
-- Tipe kamar, kamar, dan fasilitas
-- -----------------------------------------------------------------------------
INSERT INTO tipe_kamar
  (id_tipe_kamar, nama_tipe, deskripsi, kapasitas, harga_dasar, foto, is_active, created_at, updated_at)
VALUES
  (1, 'Standard', 'Kamar nyaman untuk 2 tamu, dilengkapi WiFi, AC, TV, dan water heater.', 2,  350000, NULL, TRUE, '2024-01-02 08:30:00', '2024-01-02 08:30:00'),
  (2, 'Deluxe',   'Kamar lebih luas dengan balkon dan kulkas, cocok untuk pasangan.',       2,  550000, NULL, TRUE, '2024-01-02 08:30:00', '2024-01-02 08:30:00'),
  (3, 'VIP',      'Kamar premium kapasitas 3 tamu, dilengkapi bathtub dan balkon.',          3,  850000, NULL, TRUE, '2024-01-02 08:30:00', '2024-01-02 08:30:00'),
  (4, 'VVIP',     'Suite terluas untuk 4 tamu, lengkap dengan mini bar dan sarapan.',        4, 1500000, NULL, TRUE, '2024-01-02 08:30:00', '2024-01-02 08:30:00');

INSERT INTO kamar
  (id_kamar, id_tipe_kamar, nomor_kamar, status, keterangan, created_at, updated_at)
VALUES
  (1,  1, '101', 'tersedia',          NULL,                                              '2024-01-02 09:00:00', '2024-01-02 09:00:00'),
  (2,  1, '102', 'tersedia',          NULL,                                              '2024-01-02 09:00:00', '2024-01-02 09:00:00'),
  (3,  1, '103', 'perlu_dibersihkan', 'Baru check-out, menunggu housekeeping.',           '2024-01-02 09:00:00', '2026-11-24 12:00:00'),
  (4,  1, '104', 'tersedia',          NULL,                                              '2024-01-02 09:00:00', '2024-01-02 09:00:00'),
  (5,  2, '201', 'terisi',            'Tamu sedang menginap.',                            '2024-01-02 09:00:00', '2026-11-22 14:00:00'),
  (6,  2, '202', 'tersedia',          NULL,                                              '2024-01-02 09:00:00', '2024-01-02 09:00:00'),
  (7,  2, '203', 'tersedia',          NULL,                                              '2024-01-02 09:00:00', '2024-01-02 09:00:00'),
  (8,  2, '204', 'rusak',             'AC rusak, tidak bisa dipesan sampai diperbaiki.',  '2024-01-02 09:00:00', '2026-09-03 10:00:00'),
  (9,  3, '301', 'tersedia',          NULL,                                              '2024-01-02 09:00:00', '2024-01-02 09:00:00'),
  (10, 3, '302', 'tersedia',          NULL,                                              '2024-01-02 09:00:00', '2024-01-02 09:00:00'),
  (11, 3, '303', 'tersedia',          NULL,                                              '2024-01-02 09:00:00', '2024-01-02 09:00:00'),
  (12, 4, '401', 'tersedia',          NULL,                                              '2024-01-02 09:00:00', '2026-11-13 12:30:00'),
  (13, 4, '402', 'tersedia',          NULL,                                              '2024-01-02 09:00:00', '2024-01-02 09:00:00');

INSERT INTO fasilitas
  (id_fasilitas, nama_fasilitas, ikon, keterangan, created_at, updated_at)
VALUES
  (1, 'WiFi',          NULL, 'Akses internet nirkabel di dalam kamar.',             '2024-01-02 09:10:00', '2024-01-02 09:10:00'),
  (2, 'AC',            NULL, 'Pendingin ruangan.',                                  '2024-01-02 09:10:00', '2024-01-02 09:10:00'),
  (3, 'TV LED',        NULL, 'Televisi LED dengan kanal nasional dan internasional.', '2024-01-02 09:10:00', '2024-01-02 09:10:00'),
  (4, 'Water Heater',  NULL, 'Air panas di kamar mandi.',                           '2024-01-02 09:10:00', '2024-01-02 09:10:00'),
  (5, 'Kulkas',        NULL, 'Kulkas mini di dalam kamar.',                         '2024-01-02 09:10:00', '2024-01-02 09:10:00'),
  (6, 'Balkon',        NULL, 'Balkon pribadi.',                                     '2024-01-02 09:10:00', '2024-01-02 09:10:00'),
  (7, 'Bathtub',       NULL, 'Bak mandi di kamar mandi.',                           '2024-01-02 09:10:00', '2024-01-02 09:10:00'),
  (8, 'Mini Bar',      NULL, 'Mini bar dengan minuman pelengkap.',                  '2024-01-02 09:10:00', '2024-01-02 09:10:00'),
  (9, 'Sarapan',       NULL, 'Sarapan pagi termasuk dalam menginap.',               '2024-01-02 09:10:00', '2024-01-02 09:10:00');

INSERT INTO kamar_fasilitas (id_kamar, id_fasilitas, created_at, updated_at)
VALUES
  (1,1, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (1,2, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (1,3, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (1,4, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (2,1, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (2,2, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (2,3, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (2,4, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (3,1, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (3,2, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (3,3, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (3,4, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (4,1, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (4,2, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (4,3, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (4,4, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (5,1, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (5,2, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (5,3, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (5,4, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (5,5, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (5,6, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (6,1, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (6,2, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (6,3, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (6,4, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (6,5, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (6,6, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (7,1, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (7,2, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (7,3, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (7,4, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (7,5, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (7,6, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (8,1, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (8,2, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (8,3, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (8,4, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (8,5, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (8,6, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (9,1, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (9,2, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (9,3, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (9,4, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (9,5, '2024-01-02 09:20:00','2024-01-02 09:20:00'), (9,6, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (9,7, '2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (10,1,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (10,2,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (10,3,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (10,4,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (10,5,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (10,6,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (10,7,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (11,1,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (11,2,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (11,3,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (11,4,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (11,5,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (11,6,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (11,7,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (12,1,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (12,2,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (12,3,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (12,4,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (12,5,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (12,6,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (12,7,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (12,8,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (12,9,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (13,1,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (13,2,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (13,3,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (13,4,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (13,5,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (13,6,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (13,7,'2024-01-02 09:20:00','2024-01-02 09:20:00'), (13,8,'2024-01-02 09:20:00','2024-01-02 09:20:00'),
  (13,9,'2024-01-02 09:20:00','2024-01-02 09:20:00');

-- -----------------------------------------------------------------------------
-- Promo, jenis member, kartu, langganan, dan voucher
-- -----------------------------------------------------------------------------
INSERT INTO promo
  (id_promo, kode_promo, nama_promo, persen_diskon, keterangan_periode, is_active, created_at, updated_at)
VALUES
  (1, 'HEWIKA10',   'Diskon Menginap 10%',        10, 'Setiap hari',    TRUE,  '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  (2, 'LONGSTAY15', 'Diskon Menginap 3 Malam',    15, 'Min. 3 malam',   TRUE,  '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  (3, 'MEMBER20',   'Diskon Khusus Member',       20, 'Member aktif',   TRUE,  '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  (4, 'NYEPI2026',  'Promo Nyepi 2026',           25, 'Maret 2026',     FALSE, '2026-02-01 00:00:00', '2026-03-31 23:59:00');

INSERT INTO jenis_member
  (id_jenis_member, nama_jenis, persen_diskon, benefit, biaya, kuota_voucher, is_active, created_at, updated_at)
VALUES
  (1, 'Silver',   5,  'Potongan 5% setiap reservasi',                              150000, 2, TRUE, '2024-01-02 09:30:00', '2024-01-02 09:30:00'),
  (2, 'Gold',     10, 'Potongan 10% dan prioritas pemilihan kamar',                300000, 4, TRUE, '2024-01-02 09:30:00', '2024-01-02 09:30:00'),
  (3, 'Platinum', 15, 'Potongan 15%, late checkout, dan welcome drink',            500000, 6, TRUE, '2024-01-02 09:30:00', '2024-01-02 09:30:00');

INSERT INTO kartu_member
  (id_kartu_member, id_tamu, id_jenis_member, nomor_kartu, tanggal_terbit, created_at, updated_at)
VALUES
  (1, 1, 2, 'UH-GOLD-0001',   '2026-01-15', '2026-01-15 11:00:00', '2026-01-15 11:00:00'),
  (2, 2, 1, 'UH-SILVER-0001', '2026-03-01', '2026-03-01 13:00:00', '2026-03-01 13:00:00'),
  (3, 3, 3, 'UH-PLAT-0001',   '2026-02-10', '2026-02-10 10:00:00', '2026-02-10 10:00:00');

INSERT INTO langganan_member
  (id_langganan, id_kartu_member, tanggal_mulai, tanggal_berakhir, biaya, status, created_at, updated_at)
VALUES
  (1, 1, '2026-01-15', '2027-01-14', 300000, 'aktif',        '2026-01-15 11:00:00', '2026-01-15 11:00:00'),
  (2, 2, '2025-03-01', '2026-02-28', 150000, 'kedaluwarsa',  '2025-03-01 13:00:00', '2026-03-01 00:00:00'),
  (3, 2, '2026-03-01', '2027-02-28', 150000, 'aktif',        '2026-03-01 13:00:00', '2026-03-01 13:00:00'),
  (4, 3, '2026-02-10', '2027-02-09', 500000, 'aktif',        '2026-02-10 10:00:00', '2026-02-10 10:00:00');

INSERT INTO voucher_member
  (id_voucher_member, id_kartu_member, id_promo, kode_voucher, tanggal_berlaku, tanggal_kedaluwarsa, status, created_at, updated_at)
VALUES
  (1, 1, 1, 'VCH-HEWIKA10-001',   '2026-01-15', '2026-12-31', 'terpakai',    '2026-01-15 11:05:00', '2026-11-08 20:15:00'),
  (2, 1, 2, 'VCH-LONGSTAY15-001', '2026-01-15', '2026-12-31', 'tersedia',    '2026-01-15 11:05:00', '2026-01-15 11:05:00'),
  (3, 1, 3, 'VCH-MEMBER20-001',   '2026-01-15', '2026-06-30', 'kedaluwarsa', '2026-01-15 11:05:00', '2026-07-01 00:00:00'),
  (4, 2, 1, 'VCH-HEWIKA10-002',   '2026-03-01', '2026-12-31', 'tersedia',    '2026-03-01 13:05:00', '2026-03-01 13:05:00'),
  (5, 3, 1, 'VCH-HEWIKA10-003',   '2026-02-10', '2026-12-31', 'tersedia',    '2026-02-10 10:05:00', '2026-02-10 10:05:00'),
  (6, 3, 3, 'VCH-MEMBER20-002',   '2026-02-10', '2026-12-31', 'tersedia',    '2026-02-10 10:05:00', '2026-02-10 10:05:00');

-- -----------------------------------------------------------------------------
-- Reservasi, detail, pembayaran, dan pemakaian voucher
-- -----------------------------------------------------------------------------
INSERT INTO reservasi
  (id_reservasi, id_tamu, kode_reservasi, tanggal_checkin, tanggal_checkout, jumlah_tamu, jenis, subtotal, total_diskon, total_harga, status, created_at, updated_at)
VALUES
  (1, 1, 'RSV-20261110-0001', '2026-11-10', '2026-11-13', 2, 'online',  4500000, 450000, 4050000, 'check_out',            '2026-11-08 20:15:00', '2026-11-13 12:00:00'),
  (2, 2, 'RSV-20261122-0002', '2026-11-22', '2026-11-25', 2, 'online',  1650000,  82500, 1567500, 'check_in',             '2026-11-18 09:30:00', '2026-11-22 14:00:00'),
  (3, 3, 'RSV-20261201-0003', '2026-12-01', '2026-12-04', 3, 'online',  2550000, 382500, 2167500, 'dikonfirmasi',         '2026-11-20 16:45:00', '2026-11-21 10:00:00'),
  (4, 1, 'RSV-20261128-0004', '2026-11-28', '2026-11-30', 2, 'online',   700000,      0,  700000, 'menunggu_verifikasi',  '2026-11-24 08:20:00', '2026-11-24 08:40:00'),
  (5, 5, 'RSV-20261205-0005', '2026-12-05', '2026-12-07', 2, 'online',  1100000,      0, 1100000, 'menunggu_pembayaran',  '2026-11-23 19:10:00', '2026-11-23 19:10:00'),
  (6, 1, 'RSV-20261220-0006', '2026-12-20', '2026-12-22', 1, 'online',   700000,      0,  700000, 'dibatalkan',           '2026-11-15 11:00:00', '2026-11-16 09:00:00'),
  (7, 3, 'RSV-20261015-0007', '2026-10-15', '2026-10-17', 1, 'walk_in',  700000,      0,  700000, 'check_out',            '2026-10-15 13:20:00', '2026-10-17 11:00:00'),
  (8, 4, 'RSV-20260901-0008', '2026-09-01', '2026-09-03', 2, 'online',  1100000,      0, 1100000, 'check_out',            '2026-08-25 17:40:00', '2026-09-03 12:00:00');

INSERT INTO detail_reservasi
  (id_detail_reservasi, id_reservasi, id_kamar, harga_per_malam, jumlah_malam, subtotal, created_at, updated_at)
VALUES
  (1, 1, 12, 1500000, 3, 4500000, '2026-11-08 20:15:00', '2026-11-08 20:15:00'), 
  (2, 2,  5,  550000, 3, 1650000, '2026-11-18 09:30:00', '2026-11-18 09:30:00'), 
  (3, 3,  9,  850000, 3, 2550000, '2026-11-20 16:45:00', '2026-11-20 16:45:00'), 
  (4, 4,  1,  350000, 2,  700000, '2026-11-24 08:20:00', '2026-11-24 08:20:00'), 
  (5, 5,  6,  550000, 2, 1100000, '2026-11-23 19:10:00', '2026-11-23 19:10:00'), 
  (6, 6,  4,  350000, 2,  700000, '2026-11-15 11:00:00', '2026-11-15 11:00:00'), 
  (7, 7,  2,  350000, 2,  700000, '2026-10-15 13:20:00', '2026-10-15 13:20:00'), 
  (8, 8,  8,  550000, 2, 1100000, '2026-08-25 17:40:00', '2026-08-25 17:40:00'); 

INSERT INTO pembayaran
  (id_pembayaran, id_reservasi, id_verifikator, metode, jumlah, nama_pengirim, bank_pengirim, rekening_pengirim, no_referensi, bukti_transfer, waktu_transfer, status_verifikasi, waktu_verifikasi, catatan, created_at, updated_at)
VALUES
  (1, 1, 1, 'transfer', 4050000, 'I Putu Aditya Wirawan', 'BCA',    '1234567890', 'TF20261108UHW001', 'uploads/bukti/tf-rsv0001.jpg', '2026-11-08 20:30:00', 'diterima',  '2026-11-09 09:10:00', 'Pembayaran sesuai.',                         '2026-11-08 20:31:00', '2026-11-09 09:10:00'),
  (2, 2, 2, 'qris',     1567500, 'Ni Komang Dewi Lestari', NULL,     NULL,         'QR20261118UHW002', 'uploads/bukti/qr-rsv0002.jpg', '2026-11-18 09:45:00', 'diterima',  '2026-11-18 15:00:00', 'QRIS terverifikasi.',                        '2026-11-18 09:46:00', '2026-11-18 15:00:00'),
  (3, 3, 1, 'transfer', 2167500, 'I Gusti Ngurah Bagus Putra', 'Mandiri', '9876543210', 'TF20261120UHW003', 'uploads/bukti/tf-rsv0003.jpg', '2026-11-20 17:10:00', 'diterima',  '2026-11-21 10:00:00', 'Pembayaran sesuai, reservasi dikonfirmasi.', '2026-11-20 17:11:00', '2026-11-21 10:00:00'),
  (4, 4, NULL, 'transfer', 700000, 'I Putu Aditya Wirawan', 'BCA',  '1234567890', 'TF20261124UHW004', 'uploads/bukti/tf-rsv0004.jpg', '2026-11-24 08:35:00', 'menunggu',  NULL,                  'Menunggu pemeriksaan resepsionis.',          '2026-11-24 08:36:00', '2026-11-24 08:36:00'),
  (5, 7, 2, 'tunai',     700000, NULL, NULL, NULL, NULL, NULL, '2026-10-15 13:25:00', 'diterima', '2026-10-15 13:25:00', 'Pembayaran tunai di meja resepsionis.', '2026-10-15 13:25:00', '2026-10-15 13:25:00'),
  (6, 8, 1, 'transfer', 1100000, 'Ni Made Ratih Prameswari', 'BRI', '1122334455', 'TF20260825UHW008', 'uploads/bukti/tf-rsv0008.jpg', '2026-08-25 18:00:00', 'diterima',  '2026-08-26 09:00:00', 'Pembayaran sesuai.',                         '2026-08-25 18:01:00', '2026-08-26 09:00:00');

INSERT INTO penggunaan_voucher
  (id_penggunaan_voucher, id_voucher_member, id_reservasi, nilai_potongan, tanggal_digunakan, created_at, updated_at)
VALUES
  (1, 1, 1, 450000, '2026-11-08 20:15:00', '2026-11-08 20:15:00', '2026-11-08 20:15:00');

-- -----------------------------------------------------------------------------
-- Blacklist, barang tertinggal, laporan kerusakan, dan kebersihan
-- -----------------------------------------------------------------------------
INSERT INTO blacklist_tamu
  (id_blacklist, id_tamu, id_pengaju, id_pemutus, alasan, status, tanggal_pengajuan, tanggal_keputusan, catatan_keputusan, created_at, updated_at)
VALUES
  (1, 4, 1, 1,
   'Merusak AC kamar 204 dan merokok di dalam kamar meskipun sudah diperingatkan staf.',
   'disetujui',
   '2026-09-03 14:00:00',
   '2026-09-04 11:00:00',
   'Disetujui. Tamu tidak diperkenankan melakukan reservasi baru.',
   '2026-09-03 14:00:00',
   '2026-09-04 11:00:00');

INSERT INTO barang_tertinggal
  (id_barang, id_resepsionis, id_kamar, id_reservasi, nama_barang, foto, lokasi_ditemukan, no_wa_pemilik, status, catatan, created_at, updated_at)
VALUES
  (1, 1, 5,  2, 'Charger laptop USB-C',     NULL, 'Meja kerja kamar 201', '081345678902', 'belum_diambil', 'Ditemukan saat check-in hari kedua.',              '2026-11-23 10:15:00', '2026-11-23 10:15:00'),
  (2, 2, 12, 1, 'Kacamata hitam Ray-Ban',   NULL, 'Nakas kamar 401',      '081345678901', 'sudah_diambil', 'Sudah diambil pemilik saat melewati resepsionis.', '2026-11-13 12:20:00', '2026-11-13 16:45:00');

INSERT INTO laporan_kerusakan
  (id_laporan, id_kamar, id_housekeeping, kategori, deskripsi, foto, tingkat, status, created_at, updated_at)
VALUES
  (1, 8, 2, 'Elektronik',  'AC kamar 204 tidak dingin dan mengeluarkan bunyi keras setelah tamu check-out.', NULL, 'tinggi', 'diproses', '2026-09-03 10:30:00', '2026-09-03 15:00:00'),
  (2, 3, 1, 'Kamar Mandi', 'Keran wastafel kamar 103 menetes.',                                                NULL, 'rendah', 'selesai',  '2026-11-20 09:00:00', '2026-11-21 14:00:00');

INSERT INTO kebersihan
  (id_kebersihan, id_kamar, id_housekeeping, ganti_sprei, bersih_kamar_mandi, isi_perlengkapan, vakum_pel, lap_perabot, cek_elektronik, buang_sampah, status, created_at, updated_at)
VALUES
  (1,  3, 1, TRUE,  TRUE,  FALSE, TRUE,  TRUE,  FALSE, TRUE,  'dibersihkan', '2026-11-24 13:00:00', '2026-11-24 13:40:00'), -- 103 masih perlu dibersihkan
  (2, 12, 2, TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  'siap',        '2026-11-13 12:30:00', '2026-11-13 14:00:00'), -- 401 setelah check-out Aditya
  (3,  2, 1, TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  'siap',        '2026-10-17 11:15:00', '2026-10-17 12:30:00'); -- 102 setelah walk-in Bagus