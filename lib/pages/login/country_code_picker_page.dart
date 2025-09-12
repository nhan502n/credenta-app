import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/country_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';

class CountryCodePickerPage extends StatefulWidget {
  final List<CountryDial>? prefetched;
  const CountryCodePickerPage({super.key, this.prefetched});

  @override
  State<CountryCodePickerPage> createState() => _CountryCodePickerPageState();
}

class _CountryCodePickerPageState extends State<CountryCodePickerPage> {
  // Data
  List<CountryDial> _all = [];
  List<CountryDial> _filtered = [];

  // Lazy render
  final _sc = ScrollController();
  static const int _batchSize = 20;
  int _limit = _batchSize;
  bool _loadingMore = false;

  // State
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _searchCtrl.addListener(_onSearchChanged);
    _sc.addListener(_onScroll);

    if (widget.prefetched != null) {
      _all = widget.prefetched!;
      _filtered = _all;
      _loading = false;
      _limit = _batchSize;
      setState(() {});
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _sc.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await fetchCountryDials();
      if (!mounted) return;
      setState(() {
        _all = data;
        _filtered = data;
        _loading = false;
        _limit = _batchSize;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load countries: $e';
        _loading = false;
      });
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), _applyFilter);
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all
              .where((c) =>
                  c.name.toLowerCase().contains(q) ||
                  c.dial.replaceAll('+', '').contains(q))
              .toList();
      _limit = _batchSize;
    });
  }

  void _onScroll() {
    if (_loadingMore || _filtered.isEmpty) return;

    const threshold = 200.0;
    if (_sc.position.pixels + threshold >= _sc.position.maxScrollExtent) {
      if (_limit >= _filtered.length) return;
      setState(() => _loadingMore = true);

      Future.microtask(() {
        if (!mounted) return;
        setState(() {
          _limit = (_limit + _batchSize).clamp(0, _filtered.length);
          _loadingMore = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          // ✅ tất cả (title + nút X + search + list) đều trong padding này
          padding: AppLayout.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Title + nút X bên phải
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Country Code',
                      style: TextStyle(
                        color: AppColors.title,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.brandOrange, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    splashRadius: 20,
                  ),
                ],
              ),
              AppLayout.gapMD,

              // Search
              TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: AppColors.placeholder),
                  filled: true,
                  fillColor: AppColors.inputFill50,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              AppLayout.gapSM,

              // List (ẩn scrollbar + overscroll glow)
              Expanded(
                child: ScrollConfiguration(
                  behavior: const _NoScrollbarBehavior(),
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandOrange),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_filtered.isEmpty) {
      return const Center(
        child: Text('No results', style: TextStyle(color: AppColors.placeholder)),
      );
    }

    final visibleCount = _limit.clamp(0, _filtered.length);
    final hasMore = visibleCount < _filtered.length;

    return ListView.builder(
      controller: _sc,
      padding: EdgeInsets.zero, // không cộng thêm padding
      itemExtent: 56,
      cacheExtent: 400,
      itemCount: visibleCount + (hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= visibleCount) {
          return const Center(
            child: SizedBox(
              height: 22, width: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandOrange),
            ),
          );
        }

        final c = _filtered[i];
        return Column(
  children: [
    ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Text(flagEmoji(c.cca2), style: const TextStyle(fontSize: 20)),
      // ⬇️ ép 1 dòng + ellipsis để không vượt itemExtent
      title: Text(
        c.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      trailing: Text(
        c.dial,
        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      ),
      onTap: () => Navigator.pop(context, c),
    ),
    const Divider(color: Colors.white12, height: 1, thickness: 1),
  ],
);
      },
    );
  }
}

/// Ẩn scrollbar & overscroll glow cho mọi platform
class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child; // không bọc Scrollbar
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child; // tắt hiệu ứng glow
  }
}
