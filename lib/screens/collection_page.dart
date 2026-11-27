import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../constants/api_constant.dart';
import '../models/restaurant_model.dart';
import '../models/seafood_list_model.dart';
import '../services/crud_service.dart';
import '../theme/seafood_theme.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RestaurantModel> _restaurants = [];
  List<SeafoodListModel> _seafoodLists = [];
  int? _selectedFilterRestaurantId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final restos = await CrudService.getRestaurants();
      final lists = await CrudService.getSeafoodLists(
        restaurantId: _selectedFilterRestaurantId,
      );
      if (!mounted) return;
      setState(() {
        _restaurants = restos;
        _seafoodLists = lists;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ==================== DIALOG TABEL 1 (RESTAURANTS) ====================
  void _showRestaurantForm({RestaurantModel? item}) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Tambah Tempat' : 'Edit Tempat'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Nama Tempat (Contoh: Masak Sendiri, Resto, Kafe)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              if (item == null) {
                await CrudService.addRestaurant(nameCtrl.text.trim());
              } else {
                await CrudService.updateRestaurant(
                  item.id,
                  nameCtrl.text.trim(),
                );
              }
              if (!ctx.mounted) return;
              if (!mounted) return;
              Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ==================== DIALOG TABEL 2 (SEAFOOD LISTS) ====================
  void _showSeafoodForm({SeafoodListModel? item}) {
    if (_restaurants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan kategori Tempat terlebih dahulu!'),
        ),
      );
      return;
    }

    int selectedRestoId = item?.restaurantId ?? _restaurants.first.id;
    final titleCtrl = TextEditingController(text: item?.title ?? '');
    final ingredientCtrl = TextEditingController(
      text: item?.mainIngredient ?? '',
    );
    final notesCtrl = TextEditingController(text: item?.notes ?? '');
    final imageUrlCtrl = TextEditingController(text: item?.imageUrl ?? '');
    XFile? pickedImage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            item == null ? 'Tambah Menu Seafood' : 'Edit Menu Seafood',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedRestoId,
                  decoration: const InputDecoration(
                    labelText: 'Kategori Tempat',
                    border: OutlineInputBorder(),
                  ),
                  items: _restaurants
                      .map(
                        (r) =>
                            DropdownMenuItem(value: r.id, child: Text(r.name)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedRestoId = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Menu',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ingredientCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Bahan Utama (misal: Salmon, Udang)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Catatan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL Foto (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                      maxWidth: 1600,
                      maxHeight: 1600,
                    );
                    if (file != null) {
                      setDialogState(() => pickedImage = file);
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: Text(
                    pickedImage == null
                        ? 'Pilih Foto dari Galeri'
                        : 'Foto dipilih: ${pickedImage!.name}',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty ||
                    ingredientCtrl.text.trim().isEmpty) {
                  return;
                }
                final success = await CrudService.saveSeafoodList(
                  id: item?.id,
                  restaurantId: selectedRestoId,
                  title: titleCtrl.text.trim(),
                  mainIngredient: ingredientCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                  imageUrl: imageUrlCtrl.text.trim(),
                  imageFile: pickedImage,
                );
                if (!ctx.mounted) return;
                if (!success) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menyimpan menu atau foto'),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                _loadData();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSeafoodDetails(SeafoodListModel item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: _SeafoodImage(
                  imageUrl: item.imageUrl,
                  width: double.infinity,
                  height: 220,
                  iconSize: 64,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Tempat: ${item.restaurant?.name ?? "-"}'),
              const SizedBox(height: 4),
              Text('Bahan utama: ${item.mainIngredient}'),
              if (item.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Catatan',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(item.notes),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayFormatted = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My seafood plan'),
            Text(
              todayFormatted,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: SeafoodColors.muted,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daftar Menu Seafood'),
            Tab(text: 'Kategori Tempat'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // ==================== TAB 1: SEAFOOD LISTS ====================
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: DropdownButtonFormField<int?>(
                        initialValue: _selectedFilterRestaurantId,
                        decoration: const InputDecoration(
                          labelText: 'Filter Berdasarkan Tempat',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Semua Tempat'),
                          ),
                          ..._restaurants.map(
                            (r) => DropdownMenuItem<int?>(
                              value: r.id,
                              child: Text(r.name),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedFilterRestaurantId = val);
                          _loadData();
                        },
                      ),
                    ),
                    Expanded(
                      child: _seafoodLists.isEmpty
                          ? const Center(
                              child: Text('Belum ada rencana menu seafood'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: _seafoodLists.length,
                              itemBuilder: (context, index) {
                                final item = _seafoodLists[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    onTap: () => _showSeafoodDetails(item),
                                    leading: _SeafoodImage(
                                      imageUrl: item.imageUrl,
                                      width: 55,
                                      height: 55,
                                      iconSize: 32,
                                    ),
                                    title: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tempat: ${item.restaurant?.name ?? "-"} | Bahan: ${item.mainIngredient}',
                                        ),
                                        if (item.notes.isNotEmpty)
                                          Text(
                                            'Catatan: ${item.notes}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: SeafoodColors.deepGreen,
                                          ),
                                          onPressed: () =>
                                              _showSeafoodForm(item: item),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            await CrudService.deleteSeafoodList(
                                              item.id,
                                            );
                                            _loadData();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),

                // ==================== TAB 2: RESTAURANTS ====================
                _restaurants.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada tempat. Tambahkan Masak Sendiri, Resto, atau Kafe.',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _restaurants.length,
                        itemBuilder: (context, index) {
                          final resto = _restaurants[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.storefront,
                                color: SeafoodColors.green,
                              ),
                              title: Text(resto.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: SeafoodColors.deepGreen,
                                    ),
                                    onPressed: () =>
                                        _showRestaurantForm(item: resto),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await CrudService.deleteRestaurant(
                                        resto.id,
                                      );
                                      if (_selectedFilterRestaurantId ==
                                          resto.id) {
                                        _selectedFilterRestaurantId = null;
                                      }
                                      _loadData();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showSeafoodForm();
          } else {
            _showRestaurantForm();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SeafoodImage extends StatelessWidget {
  const _SeafoodImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.iconSize,
  });

  final String? imageUrl;
  final double width;
  final double height;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final url = ApiConstant.resolveImageUrl(imageUrl);
    final placeholder = ColoredBox(
      color: SeafoodColors.paleMint,
      child: Center(
        child: Icon(Icons.set_meal, size: iconSize, color: SeafoodColors.green),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                loadingBuilder: (context, child, loadingProgress) =>
                    loadingProgress == null ? child : placeholder,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Gagal memuat foto menu dari $url: $error');
                  return placeholder;
                },
              ),
      ),
    );
  }
}
