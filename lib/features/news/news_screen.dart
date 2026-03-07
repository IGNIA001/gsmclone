import 'package:flutter/material.dart';

class TechNewsScreen extends StatefulWidget {
  const TechNewsScreen({super.key});

  @override
  State<TechNewsScreen> createState() => _TechNewsScreenState();
}

class _TechNewsScreenState extends State<TechNewsScreen> {
  String _selectedCategory = 'All';

  final _categories = ['All', 'Reviews', 'Launches', 'Comparison', 'Rumors'];

  static const _news = [
    _NewsItem(
      title: 'Samsung Galaxy S25 Ultra Review: Snapdragon 8 Elite Beast',
      summary:
      'Samsung\'s latest flagship brings Snapdragon 8 Elite, a redesigned titanium frame, and a 200MP main camera. We test it head-to-head against the iPhone 17 Pro Max.',
      tag: 'Reviews',
      timeAgo: '2 hours ago',
      imageUrl: 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s25-ultra.jpg',
    ),
    _NewsItem(
      title: 'iPhone 17 Pro Max vs Galaxy S25 Ultra — Ultimate 2025 Showdown',
      summary:
      'Apple\'s A19 Pro chip meets Qualcomm\'s Snapdragon 8 Elite. We compare cameras, performance, battery, and value in the definitive flagship battle of 2025.',
      tag: 'Comparison',
      timeAgo: '5 hours ago',
      imageUrl: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16-pro-max.jpg',
    ),
    _NewsItem(
      title: 'iPhone 17e — Action Button, USB-C, A16 Bionic at ₹59,900',
      summary:
      'Apple\'s most affordable 2025 iPhone replaces the SE lineup entirely. It gets a proper 48MP camera, Face ID, and Action Button — the biggest SE upgrade ever.',
      tag: 'Launches',
      timeAgo: '1 day ago',
      imageUrl: 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16.jpg',
    ),
    _NewsItem(
      title: 'Motorola Signature — Genuine Leather, Snapdragon 8 Elite, ₹89,999',
      summary:
      'Motorola\'s first true premium flagship in years. Genuine leather back, Snapdragon 8 Elite, 165Hz OLED, and 125W charging make this a serious contender.',
      tag: 'Launches',
      timeAgo: '1 day ago',
      imageUrl: 'https://fdn2.gsmarena.com/vv/bigpic/motorola-edge-50-ultra.jpg',
    ),
    _NewsItem(
      title: 'Google Pixel 9a: Tensor G4, Best Camera Under ₹55k',
      summary:
      'The Pixel 9a brings Google\'s computational photography to the mid-range. Tensor G4, 50MP Octa PD sensor, and 7 years of Android updates at ₹52,999.',
      tag: 'Launches',
      timeAgo: '2 days ago',
      imageUrl: 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-8a.jpg',
    ),
    _NewsItem(
      title: 'OnePlus 13T vs iQOO 13 — Battle of ₹60k Flagships',
      summary:
      'Both sport Snapdragon 8 Elite and 100W+ fast charging. We put them through a week of real-world tests to find out which delivers better value.',
      tag: 'Comparison',
      timeAgo: '3 days ago',
      imageUrl: 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-13.jpg',
    ),
    _NewsItem(
      title: 'Xiaomi 15 Ultra Review: Leica 1-inch Sensor Dominates',
      summary:
      'The Xiaomi 15 Ultra with its 1-inch Leica sensor and 5x periscope zoom challenges the S25 Ultra on camera grounds at a lower price point of ₹1,09,999.',
      tag: 'Reviews',
      timeAgo: '4 days ago',
      imageUrl: 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14-ultra.jpg',
    ),
    _NewsItem(
      title: 'Best Phones Under ₹20,000 in 2025 — Our Top Picks',
      summary:
      'Redmi Note 14 Pro, iQOO Z9 Turbo+, and Realme GT 7 are fighting for the budget crown. Here\'s which one to buy based on your priority.',
      tag: 'Comparison',
      timeAgo: '5 days ago',
      imageUrl: null,
    ),
    _NewsItem(
      title: 'Nothing Phone (3) — Glyph Matrix + Snapdragon 7s Gen 3',
      summary:
      'Nothing\'s third phone wraps LED strips across the entire back panel, enabling app notifications, music visualisers, and custom lighting effects.',
      tag: 'Rumors',
      timeAgo: '6 days ago',
      imageUrl: null,
    ),
    _NewsItem(
      title: 'Samsung Galaxy Z Fold 7 Hands-On: Thinner, Faster, Better',
      summary:
      'Samsung\'s foldable flagship gets a thinner hinge, Snapdragon 8 Elite, and an upgraded S Pen experience. Starting at ₹1,89,999 in India.',
      tag: 'Reviews',
      timeAgo: '1 week ago',
      imageUrl: null,
    ),
  ];

  List<_NewsItem> get _filtered => _selectedCategory == 'All'
      ? _news
      : _news.where((n) => n.tag == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tech News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => setState(() {}),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: theme.colorScheme.primaryContainer,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.newspaper_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text('No $_selectedCategory news yet.',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) {
          final n = filtered[i];
          return i == 0 && _selectedCategory == 'All'
              ? _FeaturedCard(news: n)
              : _NewsCard(news: n);
        },
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _NewsItem {
  final String title;
  final String summary;
  final String tag;
  final String timeAgo;
  final String? imageUrl;

  const _NewsItem({
    required this.title,
    required this.summary,
    required this.tag,
    required this.timeAgo,
    this.imageUrl,
  });
}

// ── Featured card ─────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final _NewsItem news;
  const _FeaturedCard({required this.news});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          news.imageUrl != null
              ? Image.network(news.imageUrl!,
              height: 200, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: theme.colorScheme.primaryContainer,
                  child: const Center(child: Icon(Icons.newspaper, size: 60))))
              : Container(height: 200, color: theme.colorScheme.primaryContainer,
              child: const Center(child: Icon(Icons.newspaper, size: 60))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _TagChip(tag: news.tag),
                  const Spacer(),
                  Text(news.timeAgo,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline)),
                ]),
                const SizedBox(height: 8),
                Text(news.title,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(news.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Regular news card ─────────────────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  final _NewsItem news;
  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _TagChip(tag: news.tag),
                    const SizedBox(width: 8),
                    Text(news.timeAgo,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline)),
                  ]),
                  const SizedBox(height: 6),
                  Text(news.title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(news.summary,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (news.imageUrl != null) ...[
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(news.imageUrl!,
                    width: 72, height: 72, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.phone_android, size: 40)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Tag chip ──────────────────────────────────────────────────────────────────
class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  static const _colors = {
    'Reviews': Colors.blue,
    'Launches': Colors.green,
    'Comparison': Colors.orange,
    'Rumors': Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[tag] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(tag,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}