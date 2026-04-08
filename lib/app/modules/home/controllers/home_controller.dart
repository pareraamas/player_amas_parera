import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:player_amas_parera/app/modules/home/dialog/dialog.dart';
import 'package:video_player/video_player.dart';

/// ============================================================================
/// HomeController - Controller utama untuk halaman video player
/// ============================================================================
///
/// ALUR UTAMA APLIKASI:
/// 1. App dibuka → onInit() → video di-load dari URL HLS
/// 2. Dialog info muncul → menjelaskan bahwa iklan tampil tiap 30 detik
/// 3. User tekan "Putar Video" → onDialogDismissed() → video mulai diputar
/// 4. Setiap 30 detik → iklan gambar muncul selama 7 detik (video di-pause)
/// 5. Setelah 7 detik → iklan hilang → video lanjut otomatis
///
/// ============================================================================
class HomeController extends GetxController {
  // ──────────────────────────────────────────────────────────────────────────
  // VIDEO PLAYER
  // ──────────────────────────────────────────────────────────────────────────

  /// Controller dari package video_player untuk mengontrol pemutaran video.
  /// Digunakan untuk play, pause, seek, dan mendapatkan info video.
  late VideoPlayerController videoController;

  // ──────────────────────────────────────────────────────────────────────────
  // STATE VARIABLES (Reactive / .obs)
  // Semua variable .obs akan otomatis memperbarui UI ketika nilainya berubah.
  // ──────────────────────────────────────────────────────────────────────────

  /// Apakah video sudah selesai di-load dan siap diputar?
  /// false = masih loading, true = video siap
  final isVideoInitialized = false.obs;

  /// Apakah video sedang diputar saat ini?
  /// Digunakan untuk menentukan icon play/pause di UI
  final isPlaying = false.obs;

  /// Apakah video sedang buffering (loading data dari internet)?
  /// Saat true, UI menampilkan loading indicator di atas video
  final isBuffering = false.obs;

  /// Apakah kontrol video (tombol play, slider, waktu) sedang ditampilkan?
  /// Kontrol otomatis hilang setelah 4 detik saat video diputar
  final showControls = true.obs;

  /// Posisi pemutaran video saat ini (contoh: 00:01:23)
  /// Diperbarui setiap 500ms oleh _positionTimer
  final currentPosition = Duration.zero.obs;

  /// Total durasi video (contoh: 00:10:00)
  final totalDuration = Duration.zero.obs;

  /// Volume video saat ini (0.0 = mute, 1.0 = max)
  /// Default 1.0 agar audio terdengar keras
  final volume = 1.0.obs;

  /// Apakah video sedang di-mute?
  final isMuted = false.obs;

  // ──────────────────────────────────────────────────────────────────────────
  // STATE IKLAN (AD)
  // ──────────────────────────────────────────────────────────────────────────

  /// Apakah iklan sedang ditampilkan di layar?
  /// true = overlay iklan muncul, video di-pause
  final showAd = false.obs;

  /// Hitungan mundur iklan (7 → 6 → 5 → ... → 0)
  /// Saat mencapai 0, iklan otomatis ditutup
  final adCountdown = 7.obs;

  /// Index gambar iklan yang sedang ditampilkan (0, 1, atau 2)
  /// Dipilih secara random dari daftar adAssets
  final currentAdIndex = 0.obs;

  // ──────────────────────────────────────────────────────────────────────────
  // STATE DIALOG
  // ──────────────────────────────────────────────────────────────────────────

  /// Apakah dialog info sudah ditutup oleh user?
  /// Video baru diputar setelah dialog ditutup (nilai = true)
  final dialogDismissed = false.obs;

  // ──────────────────────────────────────────────────────────────────────────
  // TIMER
  // Semua timer bersifat nullable (?) karena belum aktif saat awal
  // ──────────────────────────────────────────────────────────────────────────

  /// Timer yang berjalan setiap 30 detik untuk menampilkan iklan
  Timer? _adIntervalTimer;

  /// Timer yang menghitung mundur durasi iklan (7 detik → 0)
  Timer? _adCountdownTimer;

  /// Timer yang menyembunyikan kontrol video setelah 4 detik tidak disentuh
  Timer? _hideControlsTimer;

  /// Timer yang memperbarui posisi pemutaran video setiap 500ms
  /// Digunakan agar slider/progress bar bergerak halus
  Timer? _positionTimer;

  // ──────────────────────────────────────────────────────────────────────────
  // DATA IKLAN
  // ──────────────────────────────────────────────────────────────────────────

  /// Daftar path gambar iklan yang tersedia di folder assets/ads/
  /// Salah satu akan dipilih secara random setiap kali iklan muncul
  final List<String> adAssets = [
    'assets/ads/ad_1.png',
    'assets/ads/ad_2.png',
    'assets/ads/ad_3.png',
  ];

  /// Generator angka random untuk memilih iklan secara acak
  final random = Random();

  // ══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Dipanggil otomatis saat controller pertama kali dibuat.
  /// Di sini kita memulai proses loading video dari internet.
  @override
  void onInit() {
    super.onInit();
    _initVideoPlayer(); // Langkah 1: Load video
  }

  /// Dipanggil otomatis setelah widget sudah ter-render di layar.
  /// Di sini kita menampilkan dialog info karena butuh context yang sudah siap.
  ///
  /// Alur:
  /// 1. onInit() → load video (belum ada UI)
  /// 2. onReady() → UI sudah siap → tampilkan dialog info
  /// 3. User tekan "Putar Video" → onDialogDismissed() → video mulai
  @override
  void onReady() {
    super.onReady();
    showInfoDialogInfo(); // Langkah 2: Tampilkan dialog info
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INISIALISASI VIDEO
  // ══════════════════════════════════════════════════════════════════════════

  /// Menginisialisasi video player dengan URL HLS (streaming).
  ///
  /// Proses:
  /// 1. Buat VideoPlayerController dengan URL video
  /// 2. Panggil initialize() untuk mulai download metadata video
  /// 3. Jika berhasil → set isVideoInitialized = true, ambil durasi total
  /// 4. Pasang listener untuk memantau perubahan state video
  /// 5. Jika gagal → cetak error ke console
  void _initVideoPlayer() {
    // Buat controller dengan URL HLS (format streaming adaptif)
    videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'),
    );

    // Mulai inisialisasi (download metadata, siapkan decoder)
    videoController
        .initialize()
        .then((_) {
          // Sukses! Video siap diputar
          isVideoInitialized.value = true;
          totalDuration.value = videoController.value.duration;

          // Set volume ke maximum agar audio terdengar keras
          videoController.setVolume(1.0);

          // Pasang listener yang akan dipanggil setiap kali state video berubah
          videoController.addListener(_videoListener);
        })
        .catchError((error) {
          // Gagal inisialisasi (contoh: tidak ada internet, URL salah)
          debugPrint('Video init error: $error');
        });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VIDEO LISTENER
  // ══════════════════════════════════════════════════════════════════════════

  /// Listener yang dipanggil setiap kali state video player berubah.
  /// Fungsi ini menyinkronkan state internal video_player ke variable .obs
  /// agar UI (Obx widget) otomatis diperbarui.
  void _videoListener() {
    isPlaying.value = videoController.value.isPlaying; // Sedang play?
    isBuffering.value = videoController.value.isBuffering; // Sedang buffer?
    currentPosition.value = videoController.value.position; // Posisi saat ini
    totalDuration.value = videoController.value.duration; // Total durasi
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DIALOG HANDLER
  // ══════════════════════════════════════════════════════════════════════════

  /// Menampilkan dialog info menggunakan Get.dialog().
  /// Dialog ini memberitahu user bahwa iklan muncul setiap 30 detik.
  /// Video baru diputar setelah user menekan tombol "Putar Video".
  ///
  /// Menggunakan Get.dialog() agar tidak perlu BuildContext dari View,
  /// sehingga View tetap bisa stateless (GetView).

  /// Dipanggil saat user menekan tombol "Putar Video" di dialog info.
  ///
  /// Alur:
  /// 1. Set dialogDismissed = true (menandai dialog sudah ditutup)
  /// 2. Panggil playVideo() untuk mulai memutar video
  void onDialogDismissed() {
    dialogDismissed.value = true; // Dialog sudah ditutup
    playVideo(); // Mulai putar video!
  }

  // ══════════════════════════════════════════════════════════════════════════
  // KONTROL PEMUTARAN VIDEO
  // ══════════════════════════════════════════════════════════════════════════

  /// Mulai memutar video dan mengaktifkan semua timer pendukung.
  ///
  /// Yang terjadi saat video diputar:
  /// 1. Video mulai play
  /// 2. Timer iklan 30 detik dimulai
  /// 3. Timer posisi (update slider) dimulai
  /// 4. Timer auto-hide kontrol dimulai (4 detik)
  void playVideo() {
    videoController.play(); // Putar video
    isPlaying.value = true; // Update state
    _startAdTimer(); // Mulai hitung 30 detik untuk iklan
    _startPositionTracker(); // Mulai track posisi video
    _scheduleHideControls(); // Jadwalkan sembunyikan kontrol
  }

  /// Jeda video dan hentikan timer yang tidak diperlukan saat pause.
  ///
  /// Timer iklan dan posisi dihentikan karena:
  /// - Iklan seharusnya hanya muncul saat video sedang diputar
  /// - Tidak perlu update posisi saat video di-pause
  void pauseVideo() {
    videoController.pause(); // Pause video
    isPlaying.value = false; // Update state
    _adIntervalTimer?.cancel(); // Hentikan timer iklan
    _positionTimer?.cancel(); // Hentikan tracker posisi
  }

  /// Toggle antara play dan pause.
  /// Dipanggil saat user menekan tombol play/pause di tengah video.
  void togglePlayPause() {
    if (isPlaying.value) {
      pauseVideo(); // Sedang play → pause
    } else {
      playVideo(); // Sedang pause → play
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // POSITION TRACKER
  // ══════════════════════════════════════════════════════════════════════════

  /// Memulai timer yang memperbarui posisi video setiap 500ms (0.5 detik).
  ///
  /// Kenapa 500ms? Agar slider bergerak cukup halus tanpa membebani performa.
  /// Timer lama di-cancel dulu untuk menghindari duplikasi.
  void _startPositionTracker() {
    _positionTimer?.cancel(); // Cancel timer lama jika ada
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (videoController.value.isInitialized) {
        // Update posisi saat ini ke variable reactive
        currentPosition.value = videoController.value.position;
      }
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SISTEM IKLAN
  // ══════════════════════════════════════════════════════════════════════════

  /// Memulai timer interval iklan setiap 30 detik.
  ///
  /// Setiap 30 detik, timer ini mengecek:
  /// - Apakah video sedang diputar? (isPlaying)
  /// - Apakah tidak ada iklan yang sedang tampil? (!showAd)
  /// Jika keduanya true → tampilkan iklan
  void _startAdTimer() {
    _adIntervalTimer?.cancel(); // Cancel timer lama jika ada
    _adIntervalTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (isPlaying.value && !showAd.value) {
        _showAdOverlay(); // Tampilkan iklan!
      }
    });
  }

  /// Menampilkan overlay iklan di atas video.
  ///
  /// Proses:
  /// 1. Pilih gambar iklan secara random dari adAssets
  /// 2. Set showAd = true (UI menampilkan overlay iklan)
  /// 3. Set countdown = 7 (mulai dari 7 detik)
  /// 4. Pause video (video berhenti selama iklan tampil)
  /// 5. Mulai timer countdown yang mengurangi 1 detik setiap detik
  /// 6. Saat countdown = 0 → panggil _dismissAd()
  void _showAdOverlay() {
    // Pilih iklan random (0, 1, atau 2)
    currentAdIndex.value = random.nextInt(adAssets.length);

    // Tampilkan overlay iklan di UI
    showAd.value = true;

    // Set countdown ke 7 detik
    adCountdown.value = 7;

    // Pause video selama iklan tampil
    videoController.pause();

    // Mulai countdown: 7 → 6 → 5 → 4 → 3 → 2 → 1 → 0
    _adCountdownTimer?.cancel(); // Cancel countdown lama jika ada
    _adCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      adCountdown.value--; // Kurangi 1 setiap detik

      // Jika countdown habis (0), tutup iklan
      if (adCountdown.value <= 0) {
        timer.cancel(); // Hentikan timer countdown
        _dismissAd(); // Tutup iklan dan lanjutkan video
      }
    });
  }

  /// Menutup iklan dan melanjutkan pemutaran video.
  ///
  /// Dipanggil otomatis setelah countdown iklan selesai (7 detik).
  void _dismissAd() {
    showAd.value = false; // Sembunyikan overlay iklan
    videoController.play(); // Lanjutkan pemutaran video
    isPlaying.value = true; // Update state ke playing
  }

  // ══════════════════════════════════════════════════════════════════════════
  // KONTROL UI (SHOW/HIDE CONTROLS)
  // ══════════════════════════════════════════════════════════════════════════

  /// Dipanggil saat user mengetuk area video.
  /// Toggle tampilkan/sembunyikan kontrol (tombol play, slider, waktu).
  ///
  /// Jika kontrol muncul → jadwalkan auto-hide setelah 4 detik
  void onTapVideo() {
    showControls.value = !showControls.value; // Toggle visibility

    if (showControls.value) {
      _scheduleHideControls(); // Jika muncul, jadwalkan auto-hide
    }
  }

  /// Menjadwalkan kontrol video untuk disembunyikan setelah 4 detik.
  ///
  /// Kontrol hanya disembunyikan jika video masih diputar.
  /// Jika video di-pause, kontrol tetap tampil agar user bisa menekan play.
  void _scheduleHideControls() {
    _hideControlsTimer?.cancel(); // Cancel jadwal lama jika ada
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (isPlaying.value) {
        showControls.value = false; // Sembunyikan kontrol
      }
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEEK (GESER POSISI VIDEO)
  // ══════════════════════════════════════════════════════════════════════════

  /// Menggeser posisi pemutaran video ke waktu tertentu.
  /// Dipanggil saat user menggeser slider di kontrol video.
  void seekTo(Duration position) {
    videoController.seekTo(position);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // KONTROL VOLUME
  // ══════════════════════════════════════════════════════════════════════════

  /// Mengatur volume video ke nilai tertentu (0.0 - 1.0).
  /// Dipanggil saat user menggeser slider volume.
  void setVolume(double value) {
    volume.value = value;
    videoController.setVolume(value);
    isMuted.value = value == 0.0;
  }

  /// Toggle mute/unmute.
  /// Jika sedang mute → kembalikan ke volume sebelumnya (atau 1.0)
  /// Jika sedang unmute → set volume ke 0.0 (mute)
  void toggleMute() {
    if (isMuted.value) {
      // Unmute: kembalikan ke volume 1.0
      isMuted.value = false;
      volume.value = 1.0;
      videoController.setVolume(1.0);
    } else {
      // Mute: simpan volume lama, set ke 0
      isMuted.value = true;
      volume.value = 0.0;
      videoController.setVolume(0.0);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UTILITAS FORMAT WAKTU
  // ══════════════════════════════════════════════════════════════════════════

  /// Mengubah Duration menjadi string format waktu yang mudah dibaca.
  ///
  /// Contoh:
  /// - Duration(seconds: 65)  → "01:05"
  /// - Duration(hours: 1, minutes: 2, seconds: 3) → "01:02:03"
  ///
  /// Jika durasi kurang dari 1 jam → format MM:SS
  /// Jika durasi 1 jam atau lebih → format HH:MM:SS
  String formatDuration(Duration d) {
    final hours = d.inHours; // Ambil jam
    final minutes = d.inMinutes.remainder(60); // Ambil menit (sisa bagi 60)
    final seconds = d.inSeconds.remainder(60); // Ambil detik (sisa bagi 60)

    if (hours > 0) {
      // Format: HH:MM:SS (contoh: 01:23:45)
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    // Format: MM:SS (contoh: 05:30)
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEANUP (BERSIHKAN RESOURCE)
  // ══════════════════════════════════════════════════════════════════════════

  /// Dipanggil otomatis saat controller dihancurkan (halaman ditutup).
  ///
  /// PENTING: Semua timer dan listener HARUS di-cancel/remove di sini
  /// untuk menghindari memory leak (kebocoran memori).
  @override
  void onClose() {
    _adIntervalTimer?.cancel(); // Hentikan timer interval iklan
    _adCountdownTimer?.cancel(); // Hentikan timer countdown iklan
    _hideControlsTimer?.cancel(); // Hentikan timer auto-hide kontrol
    _positionTimer?.cancel(); // Hentikan timer posisi video

    // Hapus listener dari video player
    videoController.removeListener(_videoListener);

    // Hancurkan video player dan bebaskan resource
    videoController.dispose();

    super.onClose();
  }
}
