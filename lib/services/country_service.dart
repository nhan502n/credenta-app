import 'dart:convert';
import 'package:http/http.dart' as http;

/// Minimal model for our picker
class CountryDial {
  final String name;     // e.g. "Belgium"
  final String cca2;     // e.g. "BE"
  final String dial;     // e.g. "+32"

  CountryDial({required this.name, required this.cca2, required this.dial});

  // Build from restcountries v3.1 fields: name.common, cca2, idd.root, idd.suffixes
  factory CountryDial.fromJson(Map<String, dynamic> j) {
    final name = (j['name']?['common'] ?? '').toString();
    final cca2 = (j['cca2'] ?? '').toString();
    final root = (j['idd']?['root'] ?? '').toString();            // like "+3"
    final suffixes = (j['idd']?['suffixes'] ?? []) as List?;      // like ["2"]
    // If multiple suffixes, we take the first for display; many countries only have one.
    final suffix = (suffixes != null && suffixes.isNotEmpty) ? suffixes.first.toString() : '';
    final dial = (root.isNotEmpty || suffix.isNotEmpty) ? (root + suffix) : '';
    return CountryDial(name: name, cca2: cca2, dial: dial);
  }
}

/// Simple in-memory cache
List<CountryDial>? _cache;

Future<List<CountryDial>> fetchCountryDials() async {
  if (_cache != null) return _cache!;
  final url = Uri.parse(
    // Only fetch what we need to keep it light
    'https://restcountries.com/v3.1/all?fields=name,cca2,idd'
  );
  final res = await http.get(url);
  if (res.statusCode != 200) {
    throw Exception('Failed to load country list (${res.statusCode})');
  }
  final data = json.decode(res.body) as List;
  final list = data
      .map((e) => CountryDial.fromJson(e as Map<String, dynamic>))
      .where((c) => c.name.isNotEmpty && c.dial.isNotEmpty)
      .toList();

  // Sort by localized name
  list.sort((a, b) => a.name.compareTo(b.name));
  _cache = list;
  return _cache!;
}

/// Convert “US” -> 🇺🇸 emoji flag (no external assets)
String flagEmoji(String iso2) {
  if (iso2.length != 2) return '🏳️';
  final base = 0x1F1E6; // Regional Indicator Symbol Letter A
  final chars = iso2.toUpperCase().codeUnits;
  return String.fromCharCodes(chars.map((c) => base + (c - 65)));
}

/// ===== Helper cho mở trang mượt =====

/// Trả về từ cache nếu có; nếu chưa có thì gọi fetchCountryDials()
Future<List<CountryDial>> fetchCountryDialsCached() async {
  if (_cache != null) return _cache!;
  return fetchCountryDials();
}

/// Gọi sớm (fire-and-forget) để warm cache, tránh lag khi push trang picker
void prefetchCountryDials() {
  if (_cache == null) {
    fetchCountryDials().then((d) => _cache = d).catchError((_) {});
  }
}
