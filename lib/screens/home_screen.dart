import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/poke_logo.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/state_views.dart';

/// Halaman Home / Explore: pencarian, filter tipe, dan grid Pokémon.
///
/// Cara kerja pemuatan data:
/// 1. Satu request ringan mengambil daftar nama + ID semua Pokémon.
/// 2. Grid hanya menampilkan 24 item pertama, lalu menambah 24 lagi saat
///    pengguna menggulir ke bawah.
/// 3. Detail (tipe) tiap Pokémon baru diambil ketika kartunya dibuat.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _pageSize = 24;

  final PokemonService _service = PokemonService.instance;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<PokemonRef> _all = [];
  Set<int>? _typeIds; // ID Pokémon dari tipe yang dipilih (null = semua)
  String? _selectedType;
  String _query = '';
  int _visibleCount = _pageSize;

  bool _loading = true; // memuat daftar utama
  bool _typeLoading = false; // memuat data filter tipe
  String? _error;

  bool get _busy => _loading || _typeLoading;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreIfNeeded);
    _loadIndex();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _messageOf(Object e) =>
      e is ApiException ? e.message : 'Terjadi kesalahan yang tidak diketahui.';

  Future<void> _loadIndex() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.getIndex();
      if (!mounted) return;
      setState(() {
        _all = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _messageOf(e);
        _loading = false;
      });
    }
  }

  Future<void> _selectType(String? type) async {
    final newType = type == _selectedType ? null : type;

    if (newType == null) {
      setState(() {
        _selectedType = null;
        _typeIds = null;
        _visibleCount = _pageSize;
      });
      return;
    }

    setState(() {
      _selectedType = newType;
      _typeLoading = true;
      _visibleCount = _pageSize;
    });
    try {
      final ids = await _service.getIdsByType(newType);
      if (!mounted || _selectedType != newType) return;
      setState(() {
        _typeIds = ids;
        _typeLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _selectedType = null;
        _typeIds = null;
        _typeLoading = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_messageOf(e))));
    }
  }

  List<PokemonRef> get _filtered {
    final q = _query.trim().toLowerCase().replaceAll('#', '').replaceAll(' ', '-');
    return _all.where((p) {
      if (_typeIds != null && !_typeIds!.contains(p.id)) return false;
      if (q.isEmpty) return true;
      return p.name.contains(q) || p.id.toString().contains(q);
    }).toList();
  }

  void _loadMoreIfNeeded() {
    if (!mounted || !_scrollController.hasClients || _busy || _error != null) return;
    final total = _filtered.length;
    if (_visibleCount >= total) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 600) {
      setState(() => _visibleCount = math.min(_visibleCount + _pageSize, total));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final visible = filtered.take(_visibleCount).toList();
    final hasMore = visible.length < filtered.length;

    // Di layar sangat besar, 24 kartu bisa belum memenuhi layar (tidak ada scroll).
    // Cek setelah frame selesai dan tambah kartu jika perlu.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMoreIfNeeded());

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(filtered.length)),
              if (_busy)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: LoadingView(message: 'Memuat Pokémon...'),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(message: _error!, onRetry: _loadIndex),
                )
              else if (filtered.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyView(
                    icon: Icons.search_off,
                    title: 'Pokémon tidak ditemukan',
                    message: 'Coba kata kunci atau tipe yang lain.',
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 210,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.74,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => PokemonCard(
                        key: ValueKey(visible[index].id),
                        pokemon: visible[index],
                      ),
                      childCount: visible.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: hasMore
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Semua Pokémon sudah ditampilkan',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PokeLogo(size: 40),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PokeDex',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    _busy ? 'Memuat...' : '$count Pokémon',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {
              _query = value;
              _visibleCount = _pageSize;
            }),
            decoration: InputDecoration(
              hintText: 'Cari nama atau nomor Pokémon',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _query = '';
                          _visibleCount = _pageSize;
                        });
                      },
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _typeChip(null),
                for (final t in kPokemonTypes) _typeChip(t),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String? type) {
    final selected = _selectedType == type;
    final color = type == null ? AppColors.primary : TypeColors.of(type);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(type == null ? 'Semua' : prettyName(type)),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => _selectType(type),
        selectedColor: Color.lerp(color, Colors.black, 0.15),
        backgroundColor: AppColors.surface,
        side: BorderSide(color: selected ? color : AppColors.surfaceLight),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
