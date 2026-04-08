import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:player_amas_parera/app/modules/home/controllers/home_controller.dart';

void showInfoDialogInfo() {
  final controller = Get.find<HomeController>();
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16162A)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF).withValues(alpha: 0.2),
                    const Color(0xFF3F37C9).withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF6C63FF),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Informasi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Video ini akan menampilkan iklan gambar setiap 30 detik selama 7 detik. Video akan otomatis dijeda saat iklan tampil dan dilanjutkan setelah iklan selesai.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // Indikator interval iklan
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Color(0xFF6C63FF),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Iklan muncul setiap 30 detik',
                    style: TextStyle(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Tombol untuk menutup dialog dan mulai putar video
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Tutup dialog
                  controller.onDialogDismissed(); // Mulai putar video
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Putar Video',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false, // User harus tekan tombol, tidak bisa tap luar
    barrierColor: Colors.black.withValues(alpha: 0.85),
  );
}
