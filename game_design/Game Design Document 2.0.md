# GAME DESIGN DOCUMENT

## Monster Bug

| Field              | Detail                                                          |
| ------------------ | --------------------------------------------------------------- |
| **Versi**          | 2.0 (Draft Produksi Mobile Portrait)                            |
| **Genre**          | Deck-building Card Battler / Puzzle Tactical                    |
| **Platform**       | **Android Only** (Single-player Offline)                        |
| **Orientasi**      | **Portrait (Vertikal)**                                         |
| **Target Session** | 20–40 menit per run                                             |
| **Art Style**      | Pixel Art (UI/Kartu) & Semi-3D (Monster), Dark Fantasy          |
| **Engine**         | **Defold 1.14.0** (Lua, 2D native, ekspor Android)              |

---

## Daftar Isi

1. [Ringkasan Eksekutif](#1-ringkasan-eksekutif)
2. [Visi & Pilar Desain](#2-visi--pilar-desain)
3. [Target Platform & Teknis](#3-target-platform--teknis)
4. [Core Loop](#4-core-loop)
5. [Sistem Utama](#5-sistem-utama)
6. [Struktur Turn](#6-struktur-turn)
7. [Kartu](#7-kartu)
8. [Monster](#8-monster)
9. [UI Layout & Visual Table](#9-ui-layout--visual-table)
10. [Progresi & Meta](#10-progresi--meta)
11. [Art Direction](#11-art-direction)
12. [Audio](#12-audio)
13. [Scope MVP & Roadmap](#13-scope-mvp--roadmap)
14. [Risiko & Mitigasi](#14-risiko--mitigasi)
15. [Metrik Keberhasilan](#15-metrik-keberhasilan-playtest)
16. [Lampiran](#16-lampiran)

---

## 1. Ringkasan Eksekutif

**Monster Bug** adalah game kartu single-player di mana pemain berperan sebagai pemburu serangga raksasa. Mekanik inti berputar pada tiga ide besar:

1. **Deck adalah Nyawa.** Tidak ada HP bar terpisah. Jumlah total kartu di deck = nyawa pemain. Serangan monster membakar kartu dari deck.
2. **Monster adalah Puzzle.** Monster tidak punya HP angka. Setiap monster memiliki slot tubuh alami (cangkang, kaki, perut, leher) yang harus "ditutup" dengan kartu senjata bertipe cocok.
3. **Setiap Kartu adalah Pilihan Sulit.** Kartu yang menambah HP (Meat) juga mengotori deck. Kartu sampah (Larva) mengurangi nyawa saat dihancurkan. Pemain terus menimbang antara bertahan dan efisiensi.

> **Catatan Desain (Sistem Multibahasa pada Kartu):** 
> Untuk menghemat performa dan mempermudah *art direction*, elemen visual kartu **di-*bake* (dibakar) menjadi aset gambar statis (PNG)**. Elemen tersebut meliputi: **Art (Ilustrasi), Name (Nama Kartu), Category (Kategori/Tipe), dan Action Needed (Biaya Aksi)**. 
> Satu-satunya elemen yang dirender secara *runtime* (menggunakan `gui.new_text`) adalah **Deskripsi Fungsi/Efek Kartu**. Teks efek ini akan berubah secara instan mengikuti bahasa yang dipilih pemain (Indonesia/Inggris).

> **Hook utama:** "Kamu tidak mengurangi HP monster. Kamu membongkar anatominya."

---

## 2. Visi & Pilar Desain

### 2.1 Visi

Menciptakan deck-builder yang **terasa seperti puzzle biologi gelap** — bukan pertarungan angka. Setiap monster adalah teka-teki anatomi yang harus dipecahkan dengan senjata yang tepat, dioptimalkan untuk sesi bermain satu tangan (one-handed play) di Smartphone Android.

### 2.2 Pilar Desain

| Pilar                         | Penjelasan                                               | Implikasi Desain                                              |
| ----------------------------- | -------------------------------------------------------- | ------------------------------------------------------------- |
| **Anatomi = Mekanik**         | Slot monster adalah bagian tubuh nyata, bukan UI abstrak | Setiap monster punya siluet unik yang mengisyaratkan strategi |
| **Deck = Nyawa = Beban**      | Setiap kartu berharga ganda                              | Setiap reward dan keputusan punya opportunity cost            |
| **Keputusan Sulit Tiap Turn** | Tidak ada pilihan "benar" yang jelas                     | Setiap turn minimal 2 pilihan valid dengan trade-off          |
| **Deterministik & Terbaca**   | Pola monster terlihat, deck bisa dikelola                | Cocok offline, tanpa RNG tersembunyi yang tidak adil          |
| **Mobile Portrait UX**        | Jempol adalah input utama                                | UI ditempatkan di zona jangkauan jempol bawah                 |
| **Hybrid Localization**       | Nama aset statis (EN), teks efek dinamis (ID/EN)         | Aset gambar kartu statis, render teks efek di atasnya         |

### 2.3 Anti-Pilar (yang dihindari)

- ❌ Damage race "attack vs HP" biasa
- ❌ RNG draw yang menentukan menang/kalah
- ❌ UI bertema "kotak-kotak kaku" (harus terasa seperti meja board game fisik)
- ❌ Me-render teks Nama Kartu/Kategori/Biaya menggunakan *font engine* (harus berupa gambar statis).
- ❌ Layout Landscape / PC / Steam (Fokus eksklusif pada Mobile Portrait)

---

## 3. Target Platform & Teknis

### 3.1 Spesifikasi Platform

| Aspek                     | Spesifikasi (Android)                                  |
| ------------------------- | ------------------------------------------------------ |
| **Target Distribusi**     | Google Play Store (Min. SDK 24 / Android 7.0)          |
| **Orientasi Layar**       | **Portrait (Vertikal)**                                |
| **Resolusi**              | 1080×1920 base, scale ke 720×1280 & 1440×2560          |
| **Native Art Resolution** | 480×800 (pixel scale ×2.5) untuk UI. 1080p untuk Monster.|
| **Input**                 | Touchscreen (Tap, Drag & Drop, Swipe)                  |
| **Offline**               | 100% offline                                           |
| **Save**                  | Local save file (JSON via `sys.save`), auto-save       |
| **Bahasa UI & Efek**      | Indonesia, Inggris (Dinamis)                           |
| **Bahasa Nama Aset**      | **Inggris (Statis / Gambar PNG)**                      |

### 3.2 Engine: Defold 1.14.0

| Aspek            | Detail                                                                    |
| ---------------- | ------------------------------------------------------------------------- |
| **Bahasa Skrip** | Lua 5.1 (defold-flavored)                                                 |
| **UI System**    | GUI nodes (`gui.new_text`, `gui.new_box_node`, `gui.new_texture`)         |
| **Aset Monster** | Menggunakan *Sprite component* resolusi tinggi.                           |
| **Aset Kartu**   | Menggunakan Atlas (`.atlas`) untuk *full card image* statis.              |
| **Z-Order**      | Monster di lapisan belakang. UI (Nama, Tombol, Target, Hand) di depan.    |
| **Save**         | `sys.save(sys.get_save_file("monster_bug", "save"), save)`                |
| **Build Target** | Android (`.apk` / `.aab`)                                                 |

### 3.3 Batasan Teknis (Mobile Portrait)

- **Input Abstraksi:** Gunakan *Action* di `.input_binding` untuk mendeteksi sentuhan dan *drag*.
- **Interaksi Kartu:** Kartu hanya dimainkan lewat drag-and-drop: drag senjata ke slot yang cocok, atau drag kartu Support ke area mana pun. Tap slot tidak memainkan kartu. Double-tap kartu membuka preview detail tanpa memainkannya.
- **Safe Area:** UI harus menghindari *notch* atau *punch-hole camera* di bagian atas layar. Gunakan *safe area inset*.
- **Memori & Baterai:** Hindari alokasi tabel Lua per-frame di dalam `update()`. Gunakan sistem *object pooling* untuk kartu di *hand*.

### 3.4 Arsitektur Teknis (Defold)

**Struktur Collection:**

```
main.collection
├── game_controller.go        (script: game_controller.script)
├── ui.collection             (di-load sekali)
│   ├── table.gui             (UI meja utama - Portrait)
│   ├── hand.gui              (hand area, render gambar kartu + teks efek)
│   ├── modal.gui             (reward, pause, settings)
│   └── main_menu.gui         (menu awal & pilih bahasa)
├── encounter.collection      (di-load per encounter)
│   ├── monster.go            (script: monster.script + sprite monster semi-3D)
│   ├── slot_panel.go         (script: slot_panel.script)
│   └── threat_panel.go       (script: threat_panel.script)
└── audio.go                  (sound components + mixer)
```

---

## 4. Core Loop

### 4.1 Encounter Loop (1 Pertarungan)

```
1. Monster muncul di bagian atas layar (semi-3D, menghadap ke bawah)
2. Pemain draw 5 kartu dari deck (Nyawa)
3. Pemain mainkan senjata ke slot monster (Drag & Drop ke UI Target 2x2)
4. Semua slot tertutup?
   ├─ YA → Monster MATI, ambil reward
   └─ TIDAK → Monster menyerang (bakar kartu)
5. Discard sisa hand, draw lagi
6. Ulangi sampai kill atau deck habis
```

---

## 5. Sistem Utama

### 5.1 Sistem Deck = Nyawa
- Nyawa = jumlah total kartu di `draw pile + hand + discard`.
- Kartu dibakar = hilang permanen.
- Deck habis = GAME OVER.

### 5.2 Sistem Slot Monster (Anatomi = Puzzle)
- Monster punya 3–5 slot wajib (Shield, Legs, Abdomen, dll).
- Slot tertutup = permanen selama encounter.
- Semua slot tertutup = monster mati.

### 5.3 Sistem Senjata & Aksi
- **5 Tipe Aksi:** Blunt (Pukul), Slash (Potong), Pierce (Tusuk), Web (Jaring), Fire (Api).
- **3 Aksi per turn.** Sisa aksi tidak carry over.
- Kartu support memberikan tambahan aksi atau pertahanan.

### 5.4 Siklus Threat & Anti-Softlock
- Threat monster berputar: T1 → T2 → ... → T1.
- `destroy_weapon` tanpa senjata membakar 1 kartu.
- Jika 2 turn berturut-turut tidak ada slot yang tertutup, 1 kartu dibakar langsung (menembus Shield) sampai pemain membuat progress. Mekanisme ini mencegah stalemate tanpa akhir.

---

## 6. Struktur Turn

### Fase Turn
1. **[1] FASE DRAW:** Draw 5 kartu. Cek pasif (misal: Meat +1 Nyawa).
2. **[2] FASE MAIN:** Drag & drop senjata ke slot target di UI. Cek kill.
3. **[3] FASE SERANGAN:** Jika monster belum mati, ia menyerang (bakar kartu, sisip Larva, dll).
4. **[Fase Reward]:** Setelah kill, pilih 1 dari 3 reward (Meat, Upgrade, Buang Sampah).

---

## 7. Kartu

### 7.1 Kategori Kartu
- **Weapons**: Blunt, Slash, Pierce, Web, Fire.
- **Support**: Shield, Buff, Potion.
- **Passive**: Meat.
- **Junk & Curse**: Larva, Twig, Dry Leaf, Poison.
- **Reward pool**: semua kartu non-junk dan non-Meat dapat muncul sebagai reward. Meat diperoleh dari pilihan reward Meat; junk diperoleh dari efek monster.

### 7.2 Pembagian Elemen Kartu (Statis vs Dinamis)

Setiap kartu di dalam game terdiri dari dua lapisan:

1. **Lapisan Statis (Gambar PNG):** Terdiri dari Bingkai, Art Senjata, Nama Kartu (English), Kategori (e.g., *Blunt*), dan Angka Biaya Aksi. Semua ini menyatu dalam satu file gambar (misal `card_stone_hammer.png`).
2. **Lapisan Dinamis (Teks Runtime):** Terdiri dari Deskripsi Efek. Di Defold, teks ini dirender menggunakan `gui.new_text` di area kosong yang disediakan pada gambar kartu.

**Tabel Data Kartu (Deskripsi Efek akan di-translate):**

| Nama Kartu (STATIS) | Kategori (STATIS) | Biaya (STATIS) | Efek (DINAMIS - ID) |
| :--- | :--- | :--- | :--- |
| Stone Hammer | Blunt | 1 | Tutup 1 slot Blunt. +1 jika target Shield. |
| Wooden Mallet | Blunt | 1 | Tutup 1 slot Blunt. |
| War Hammer | Blunt | 2 | Tutup 2 slot Blunt. |
| Spiked Club | Blunt | 1 | Tutup 1 slot Blunt. +1 jika target Leg. |
| Giant Sledge | Blunt | 3 | Tutup semua Shield. Jika tidak ada Shield, tutup 1 slot apa pun. |
| Gauntlet | Blunt | 0 | Tutup 1 slot. Discard setelahnya. |
| Machete | Slash | 1 | Tutup 1 slot Slash. +1 jika target Leg. |
| Heavy Axe | Slash | 2 | Tutup 1 slot Slash. |
| Bone Sickle | Slash | 1 | Tutup 1 slot Slash. +1 jika target Wing. |
| Serrated Sword | Slash | 2 | Tutup 2 slot Slash. |
| Chainsaw | Slash | 3 | Tutup 2 slot Leg. |
| Folding Knife | Slash | 0 | Tutup 1 slot. Discard setelahnya. |
| Bone Dagger | Pierce | 1 | Tutup 1 slot Pierce. +1 jika target Abdomen. |
| Sharp Spear | Pierce | 1 | Tutup 1 slot Pierce. |
| Poison Dagger | Pierce | 1 | Tutup 1 slot Pierce. Cegah regen. |
| Demon Trident | Pierce | 2 | Tutup 2 slot Pierce. |
| Piercing Arrow | Pierce | 2 | Tutup 1 slot Pierce. Abaikan Shield. |
| Stinger Needle | Pierce | 0 | Tutup 1 slot. Discard setelahnya. |
| Fiber Web | Web | 1 | Tutup 1 slot Wing. Cegah serangan. |
| Steel Web | Web | 2 | Tutup 1 slot Wing. Tahan 2 turn. |
| Glue Trap | Web | 1 | Tutup 1 slot Leg. Cegah serangan Leg. |
| Spider Web | Web | 1 | Tutup 1 slot. Sisipkan Larva. |
| Torch | Fire | 2 | Bakar 1 Larva. Tutup 1 slot Wing. |
| Fire Arrow | Fire | 1 | Bakar 1 slot Wing. |
| Molotov Cocktail | Fire | 2 | Buang 2 kartu sampah. Jika tidak ada sampah, tidak ada efek. |
| Wooden Shield | Support | 1 | Cegah 2 bakaran. |
| Focus | Support | 0 | +1 Aksi turn ini. |
| Alert | Support | 1 | Lihat 3 deck teratas. |
| Red Potion | Support | 0 | +1 Nyawa. |
| Green Potion | Support | 0 | +2 Aksi turn ini. |
| Smoke Bomb | Support | 1 | Cegah serangan monster 1 turn. |
| Meat | Passive | - | Tidak bisa dimainkan. +1 Nyawa. |
| Larva | Junk | - | Aksi: Exile (Nyawa -1). Menetas setelah 2 turn. |
| Twig | Junk | - | Tidak bisa dimainkan. |
| Dry Leaf | Junk | - | Tidak bisa dimainkan. |
| Poison | Curse | - | Nyawa -1 saat di-draw. |

---

## 8. Monster

### 8.1 Prinsip Desain Monster

1.  **Monster sebagai Entitas Fisik (Bukan Kartu).** Monster adalah entitas visual masif yang mendominasi bagian atas meja permainan.
2.  **Posisi & Skala.** Monster ditempatkan di **bagian atas layar**. Menghadap ke bawah (ke arah pemain).
3.  **Lapisan Z-Order.** Monster berada di lapisan belakang. Nama Monster dan Tombol End Turn berada di lapisan paling depan agar tidak tertutup.
4.  **Gaya Visual Semi-3D.** Menggunakan pencahayaan, gradasi warna, dan bayangan. *Pixel art* hanya untuk UI.
5.  **Ekspresi Jahat.** Wajah monster mengintimidasi, dengan mata menyala dan rahang tajam.

### 8.2 Daftar Monster (Nama Statis English)

| Nama Monster (STATIS) | Tier | Slot (Anatomi) | Serangan (DINAMIS - ID) |
| --- | --- | --- | --- |
| **Stag Beetle** | 2 | Mandibles, Shell, Legs, Head | Bakar 1, Potong 1 |
| **Praying Mantis** | 2 | Scythe Arms, Neck, Wings, Abdomen | Potong 1, Tusuk 1 |
| **Bullet Ant** | 2 | Abdomen, Head, Legs, Thorax | Racun (Bakar 1/turn) |
| **Atlas Moth** | 3 | Wings, Body, Antennae, Head, Legs | Bakar 3, Sisip 1 Larva |
| **Black Widow** | 3 | Abdomen, Head, Legs, Thorax, Fangs | Racun (Bakar 2/turn) |
| **Emperor Scorpion** | Boss | Shell, Tail, Legs, Claws, Stinger | Bakar 3, Sengat (Tusuk 3) |

*(Daftar lengkap 30 monster dapat dilihat di `monsters.md`)*

---

## 9. UI Layout & Visual Table

Visual meja bermain mengadopsi gaya **Tabletop / Board Game fisik** yang dioptimalkan untuk layar **Portrait (Vertikal)**.

### 9.1 Layout Meja (Portrait 1080×1920)

```
┌────────────────────────────────────────────────────────────────────────┐
│ ┌─────────────────┐                                    [ END TURN ]    │
│ │ STAG BEETLE     │                                                    │
│ │ SERANGGA · T1   │                                                    │
│ └─────────────────┘                                                    │
│                                                                        │
│                           [MONSTER]                                    │
│                        (Semi-3D, Besar)                                │
│                      Menghadap ke Bawah                                │
│                                                                        │
│  ┌───────────────────────────┐  ┌───────────────────────────────────┐  │
│  │ 🛡️ SHIELD      ✓ CLOSED   │  │ 🦵 LEG LEFT      ○ OPEN           │  │
│  └───────────────────────────┘  └───────────────────────────────────┘  │
│  ┌───────────────────────────┐  ┌───────────────────────────────────┐  │
│  │ 🦵 LEG RIGHT   ○ OPEN     │  │ 🫃 ABDOMEN       ○ OPEN           │  │
│  └───────────────────────────┘  └───────────────────────────────────┘  │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ ⚠ CURRENT THREAT        │ NEXT THREATS                           │  │
│  │                         │ ▶ T2: Bakar 3                          │  │
│  │ BAKAR 3                 │ ▶ T3+: Sisip Larva                     │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                        │
│  ┌──────┐┌──────┐┌──────┐┌──────┐┌──────┐┌──────┐┌──────┐            │
│  │ Palu ││Jaring││Belati││Parang││ Obor ││Perisai││Larva│ (Hand)     │
│  └──────┘└──────┘└──────┘└──────┘└──────┘└──────┘└──────┘            │
│                                                                        │
│ ┌────────────────────────────┐ ┌─────────────────────────────────────┐ │
│ │ DECK (NYAWA)               │ │ NYAWA TOTAL                         │ │
│ │ [Tumpukan] 14/18           │ │ [██████████████████░░░] 14 / 18     │ │
│ └────────────────────────────┘ └─────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 10. Progresi & Meta
- **8 encounter** per run (save lama 6 encounter tetap dapat diselesaikan).
- **1 boss** di akhir run.
- **Run selesai dalam 20–40 menit.**
- **Deck Awal Hero (10 kartu):** 2 Stone Hammer, 2 Bone Dagger, 2 Machete, 1 Fiber Web, 1 Torch, 1 Wooden Shield, 1 Focus.

---

## 11. Art Direction

### 11.1 Gaya Visual
-   **UI & Kartu Pemain:** Pixel art 16-bit/32-bit dengan palet terbatas.
-   **Monster:** **Semi-3D Render**. Menggunakan gradasi warna, pencahayaan kompleks, dan bayangan (*drop shadow*). Native resolution setara HD (1080p).

### 11.2 Aset: Raster vs Teks Dinamis

| Elemen Visual | Tipe Aset | Keterangan |
| --- | --- | --- |
| **Visual Monster** | Raster (PNG HD) | Ilustrasi semi-3D monster. Nama ditulis di UI (Dynamic Text). |
| **Card Body (Lengkap)** | Raster (PNG) | Bingkai + Art + **Name (EN)** + **Category (EN)** + **Action Cost**. Semua statis. |
| **Card Effect Text** | **Dynamic Text Node** | Dirender di atas gambar kartu. Teks di-translate (ID/EN). |

### 11.3 Kartu (Render Runtime)

| Properti | Nilai |
| --- | --- |
| Ukuran render | 300×480 px (Hand) |
| Ukuran native | 75×120 unit |
| Latar Belakang (Image) | Aset statis `card_xxx.png` yang memuat Bingkai, Art, Nama, Tipe, Biaya. |
| Teks Efek (Runtime) | Ditempatkan di kotak area kosong (misal: Y: 350-450) pada gambar kartu. |

---

## 12. Audio
- **BGM:** Ambient gelap, drone + perkusi rendah.
- **SFX:** Suara kartu, dengung serangga, retakan cangkang, api menyala.

---

## 13. Scope MVP & Roadmap
| Fitur | Status |
| --- | --- |
| Sistem Deck = Nyawa | Wajib |
| Monster Semi-3D (Layout Portrait) | Wajib |
| UI Tabletop (2x2 Grid, Threat Timeline, Hand Overlap) | Wajib |
| 36 Kartu Statis (Senjata + Utility) | Wajib |
| 6 Monster (MVP) | Wajib |
| **Sistem Multibahasa (Efek & UI ID/EN)** | **Wajib** |
| **Dynamic Text Rendering** | **Wajib** |
| **Build Android (APK / AAB)** | **Wajib** |

---

## 14. Risiko & Mitigasi
| Risiko | Dampak | Mitigasi |
| --- | --- | --- |
| Monster terlalu menutupi UI | Informasi terhalang | Gunakan Z-Order; UI Nama & Tombol di lapisan depan. |
| Kartu Hand overlap terlalu rapat | Sulit di-drag di HP | Beri *hitbox* yang tepat saat kartu di-tap/di-drag. |
| Teks efek terpotong akibat bahasa | UI berantakan | Gunakan fitur *text wrap* (word wrap) di GUI Defold. |
| Layar HP terlalu kecil (Portrait) | Target Slot 2x2 sesak | Gunakan layout *full-width* dan kurangi padding. |

---

## 15. Metrik Keberhasilan
1. Pemain mengerti aturan dalam 5 menit.
2. Setiap turn ada 2 pilihan valid.
3. Tidak ada frame drop di bawah 60 FPS pada perangkat mid-end.
4. Teks efek berubah instan saat bahasa diganti.
5. Pemain bisa memainkan game dengan satu tangan.

---

## 16. Lampiran

### 16.1 Referensi Inspirasi
| Game | Inspirasi |
| --- | --- |
| **Slay the Spire** | Struktur run & deck-building |
| **Inscryption** | Atmosfer gelap & kartu fisik |
| **Hollow Knight** | Art direction serangga gelap |

### 16.2 Glosarium
| Istilah | Arti |
| --- | --- |
| **Deck** | Tumpukan kartu = nyawa pemain |
| **Slot** | Bagian tubuh monster yang harus ditutup |
| **Burn** | Kartu keluar permanen dari run |
| **Encounter** | Satu pertarungan melawan 1 monster |
| **Top-Down** | Sudut pandang kamera dari atas ke bawah |
| **Semi-3D** | Gaya visual monster dengan pencahayaan dan volume |
| **Dynamic Text** | Teks yang dirender oleh engine (bisa di-translate) |
| **Static Image** | Aset PNG yang tidak bisa diubah (Nama, Kategori, Biaya) |

---

> **Akhir Dokumen — Versi 2.0**
>
> Dokumen ini adalah *living document*. Engine acuan: **Defold 1.14.0**. Target Platform: **Android Only**. Layout: **Portrait (Vertikal)**. Nama Aset & Visual: **English (Statis)**. Efek: **Dinamis (ID/EN)**.