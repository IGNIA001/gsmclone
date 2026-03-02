import 'package:dio/dio.dart';
import 'package:xml/xml.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

class SyncManager {
  final AppDatabase db;
  final Dio _dio;

  SyncManager(this.db)
      : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      // Mimic a browser so GSMArena doesn't block the request
      'User-Agent':
      'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36',
    },
  ));

  // ── Public entry point called by WorkManager ────────────────────────────

  Future<void> syncEverything() async {
    try {
      await _syncFromRss();
    } catch (e) {
      print('[SyncManager] syncEverything failed: $e');
      rethrow;
    }
  }

  // ── RSS feed → new device names ─────────────────────────────────────────

  /// GSMArena publishes a public RSS feed of newly reviewed / announced phones.
  /// We parse the feed, extract device names, then try to fetch each device's
  /// specs page to pull a real price & image.
  Future<void> _syncFromRss() async {
    const rssFeed = 'https://www.gsmarena.com/rss-reader.php3';

    final response = await _dio.get<String>(rssFeed);
    if (response.statusCode != 200 || response.data == null) return;

    final document = XmlDocument.parse(response.data!);
    final items = document.findAllElements('item');

    for (final item in items.take(20)) {
      try {
        final title = item.findElements('title').firstOrNull?.innerText ?? '';
        final link  = item.findElements('link').firstOrNull?.innerText ?? '';

        // Only process phone review / specs pages
        if (link.isEmpty || !link.contains('gsmarena.com')) continue;
        if (!_looksLikePhone(title)) continue;

        // Parse brand + model from title like "Samsung Galaxy S25 Ultra review"
        final parsed = _parseTitle(title);
        if (parsed == null) continue;

        final (brand, model) = parsed;

        // Check if we already have this device
        final existing = await (db.select(db.devices)
          ..where((t) => t.name.equals(model)))
            .getSingleOrNull();
        if (existing != null) continue;

        // Fetch the device specs page to get image + price
        final details = await _scrapeDevicePage(link);

        await db.upsertDevice(DevicesCompanion.insert(
          brand: brand,
          name: model,
          cpuScore: const Value(0),   // scores require deeper parsing; 0 for now
          gpuScore: const Value(0),
          cameraScore: const Value(0),
          softwareScore: const Value(0),
          price: Value(details.price),
          imageUrl: Value(details.imageUrl),
        ));

        print('[SyncManager] Added: $brand $model');
      } catch (e) {
        // Don't let one bad item break the whole sync
        print('[SyncManager] Skipped item: $e');
      }
    }
  }

  // ── Scrape a single GSMArena device page ────────────────────────────────

  Future<_DeviceDetails> _scrapeDevicePage(String url) async {
    try {
      final response = await _dio.get<String>(url);
      final html = response.data ?? '';

      // ── Image ──
      // GSMArena big images follow the pattern:
      // <div class="specs-photo-main"><a href="..."><img src="https://fdn2.gsmarena.com/vv/bigpic/...
      final imgRegex = RegExp(
          r'specs-photo-main.*?<img\s+src="(https://fdn2\.gsmarena\.com/vv/bigpic/[^"]+)"',
          dotAll: true);
      final imgMatch = imgRegex.firstMatch(html);
      final imageUrl = imgMatch?.group(1);

      // ── Price (India) ──
      // GSMArena shows price in a <td data-spec="price"> cell
      // Typical value: "₹79,990" or "About 800 EUR / 80,000 INR"
      double price = 0;
      final priceRegex = RegExp(r'₹\s*([\d,]+)');
      final priceMatch = priceRegex.firstMatch(html);
      if (priceMatch != null) {
        final raw = priceMatch.group(1)!.replaceAll(',', '');
        price = double.tryParse(raw) ?? 0;
      }

      return _DeviceDetails(imageUrl: imageUrl, price: price);
    } catch (_) {
      return const _DeviceDetails(imageUrl: null, price: 0);
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  bool _looksLikePhone(String title) {
    final lower = title.toLowerCase();
    // Skip accessories, tablets, smart watches etc.
    final skip = ['tablet', 'watch', 'band', 'buds', 'earphone',
      'charger', 'laptop', 'pc ', 'weekly'];
    for (final s in skip) {
      if (lower.contains(s)) return false;
    }
    return true;
  }

  /// Tries to extract (brand, model) from a title such as:
  ///   "Samsung Galaxy S25 Ultra review"
  ///   "OnePlus 13R announced"
  ///   "Apple iPhone 16e - full specs"
  (String, String)? _parseTitle(String title) {
    // Strip suffixes
    final clean = title
        .replaceAll(RegExp(r'\s*[-–]\s*.*'), '')       // "- full specs"
        .replaceAll(RegExp(r'\s+(review|announced|specs|official|hands[- ]on|first look|preview|vs\.?.*)',
        caseSensitive: false), '')
        .trim();

    if (clean.isEmpty) return null;

    // Known brands (expand as needed)
    const brands = [
      'Samsung', 'Apple', 'Xiaomi', 'Redmi', 'OnePlus', 'Realme', 'Oppo',
      'Vivo', 'iQOO', 'Google', 'Motorola', 'Nokia', 'Sony', 'Nothing',
      'Asus', 'Poco', 'Honor', 'Huawei', 'Infinix', 'Tecno', 'Lava',
    ];

    for (final brand in brands) {
      if (clean.toLowerCase().startsWith(brand.toLowerCase())) {
        final model = clean.substring(brand.length).trim();
        if (model.isNotEmpty) return (brand, model);
      }
    }

    // Fallback: first word = brand, rest = model
    final parts = clean.split(' ');
    if (parts.length >= 2) {
      return (parts.first, parts.skip(1).join(' '));
    }

    return null;
  }
}

// ── Value object ────────────────────────────────────────────────────────────

class _DeviceDetails {
  final String? imageUrl;
  final double price;

  const _DeviceDetails({required this.imageUrl, required this.price});
}