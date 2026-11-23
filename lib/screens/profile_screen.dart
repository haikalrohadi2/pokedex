import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/poke_logo.dart';

// ====== GANTI DATA INI DENGAN DATA KAMU ======
const String kDeveloperName = 'Muhammad Haikal Rohadi';
const String kDeveloperId = '065124042 GAB A';
const String kDeveloperCourse = 'Ujian Tengah Praktikum Mobile Programming';
// =============================================
const String kAppVersion = '1.0.0';

/// Halaman Profile / About: informasi singkat aplikasi.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 12),
              const Center(child: PokeLogo(size: 96)),
              const SizedBox(height: 16),
              const Center(
                child: Text('PokeDex', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              ),
              const Center(
                child: Text(
                  'Ensiklopedia Pokémon',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),
              const _InfoCard(
                icon: Icons.info_outline,
                title: 'Tentang Aplikasi',
                body:
                    'PokeDex memungkinkan kamu menjelajahi Pokémon, mencari berdasarkan nama atau nomor, '
                    'melihat detail lengkap, dan menyimpan Pokémon favorit ke koleksi pribadi.',
              ),
              const _InfoCard(
                icon: Icons.cloud_outlined,
                title: 'Sumber Data',
                body: 'Data Pokémon berasal dari PokeAPI (https://pokeapi.co).',
              ),
              const _InfoCard(
                icon: Icons.tag,
                title: 'Versi',
                body: kAppVersion,
              ),
              const _InfoCard(
                icon: Icons.person_outline,
                title: 'Pengembang',
                body: '$kDeveloperName\n$kDeveloperId\n$kDeveloperCourse',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(40),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
