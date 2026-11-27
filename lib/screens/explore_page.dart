import 'package:flutter/material.dart';

import '../models/meal_model.dart';
import '../routes/app_routing.dart';
import '../services/public_api_service.dart';
import '../theme/seafood_theme.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _recipesKey = GlobalKey();
  late Future<List<MealModel>> _mealsFuture;
  String _query = '';
  String _selectedArea = 'Semua';

  @override
  void initState() {
    super.initState();
    _mealsFuture = PublicApiService.fetchSeafoodMeals();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _reloadMeals() {
    setState(() {
      _mealsFuture = PublicApiService.fetchSeafoodMeals();
    });
  }

  void _scrollToRecipes() {
    final recipesContext = _recipesKey.currentContext;
    if (recipesContext == null) return;
    Scrollable.ensureVisible(
      recipesContext,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
      alignment: 0.06,
    );
  }

  Widget _enter(Widget child, {int delay = 0, Key? key}) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }

  List<MealModel> _filterMeals(List<MealModel> meals) {
    final query = _query.trim().toLowerCase();
    return meals.where((meal) {
      final matchesArea =
          _selectedArea == 'Semua' || meal.strArea == _selectedArea;
      final searchableText =
          '${meal.strMeal} ${meal.strArea} ${meal.strCategory} '
                  '${meal.ingredients.join(' ')}'
              .toLowerCase();
      return matchesArea && (query.isEmpty || searchableText.contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      body: SafeArea(
        child: FutureBuilder<List<MealModel>>(
          future: _mealsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _ExploreLoading();
            }
            if (snapshot.hasError) {
              return _ExploreError(
                error: snapshot.error,
                onRetry: _reloadMeals,
              );
            }

            final meals = snapshot.data ?? [];
            if (meals.isEmpty) {
              return const _ExploreEmpty();
            }

            final areas =
                meals
                    .map((meal) => meal.strArea)
                    .where((area) => area.trim().isNotEmpty)
                    .toSet()
                    .toList()
                  ..sort();
            final visibleMeals = _filterMeals(meals);

            return ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildHero(meals.first),
                const SizedBox(height: 24),
                _buildSearchField(),
                const SizedBox(height: 25),
                _buildSectionHeading(
                  'Inspirasi hari ini',
                  'Pilihan spesial untukmu',
                ),
                const SizedBox(height: 14),
                _buildFeaturedMeals(meals.take(3).toList()),
                const SizedBox(height: 26),
                _buildSectionHeading('Jelajahi rasa', 'Pilih asal hidangan'),
                const SizedBox(height: 12),
                _buildAreaFilters(areas),
                const SizedBox(height: 25),
                _buildRecipeHeading(visibleMeals.length),
                const SizedBox(height: 13),
                _buildRecipeList(visibleMeals),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return _enter(
      Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: SeafoodColors.deepGreen,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: SeafoodColors.deepGreen.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.set_meal_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SEAFOOD PLANNER',
                style: TextStyle(
                  color: SeafoodColors.deepGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Rasa segar, setiap hari',
                style: TextStyle(color: SeafoodColors.muted, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE9EEE8)),
            ),
            child: const Icon(
              Icons.waves_rounded,
              color: SeafoodColors.green,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(MealModel meal) {
    return _enter(
      LayoutBuilder(
        builder: (context, constraints) {
          final imageSize = (constraints.maxWidth * 0.42).clamp(116.0, 164.0);
          return Container(
            height: 222,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF176B47), Color(0xFF0C4836)],
              ),
              borderRadius: BorderRadius.circular(27),
              boxShadow: [
                BoxShadow(
                  color: SeafoodColors.deepGreen.withValues(alpha: 0.16),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -28,
                  top: -54,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 32,
                  child: Container(
                    width: imageSize,
                    height: imageSize,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: _FoodImage(url: meal.strMealThumb, iconSize: 48),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(19, 20, 0, 17),
                  child: SizedBox(
                    width: constraints.maxWidth * 0.53,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'SEGAR DARI LAUT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Menu lezat,\nlebih istimewa.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            height: 1.12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          child: InkWell(
                            onTap: _scrollToRecipes,
                            borderRadius: BorderRadius.circular(15),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Lihat resep',
                                    style: TextStyle(
                                      color: SeafoodColors.deepGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 15,
                                    color: SeafoodColors.deepGreen,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return _enter(
      TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari resep seafood favoritmu',
          hintStyle: const TextStyle(color: Color(0xFF9AA59E), fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, size: 21),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close_rounded, size: 19),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFFE9EEE8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFFE9EEE8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: SeafoodColors.green,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: SeafoodColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: SeafoodColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedMeals(List<MealModel> meals) {
    return SizedBox(
      height: 179,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: meals.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final meal = meals[index];
          return _enter(
            SizedBox(
              width: 142,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => _openMeal(meal),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SizedBox(
                            width: double.infinity,
                            height: 104,
                            child: _FoodImage(url: meal.strMealThumb),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          meal.strMeal,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SeafoodColors.ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          meal.strArea,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SeafoodColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            delay: index * 45,
            key: ValueKey('featured-${meal.idMeal}'),
          );
        },
      ),
    );
  }

  Widget _buildAreaFilters(List<String> areas) {
    final filters = ['Semua', ...areas];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final area = filters[index];
          final isSelected = _selectedArea == area;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isSelected ? SeafoodColors.deepGreen : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? SeafoodColors.deepGreen
                    : const Color(0xFFE8EDE7),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: SeafoodColors.deepGreen.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedArea = area),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: TextStyle(
                        color: isSelected ? Colors.white : SeafoodColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      child: Text(area),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeHeading(int count) {
    return Container(
      key: _recipesKey,
      child: Row(
        children: [
          Expanded(
            child: _buildSectionHeading(
              'Menu seafood',
              'Temukan menu yang pas untukmu',
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Container(
              key: ValueKey(count),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F4EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count resep',
                style: const TextStyle(
                  color: SeafoodColors.deepGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(List<MealModel> meals) {
    if (meals.isEmpty) {
      return _enter(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 34,
                color: SeafoodColors.muted,
              ),
              SizedBox(height: 9),
              Text(
                'Resep belum ditemukan',
                style: TextStyle(
                  color: SeafoodColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Coba kata kunci atau asal hidangan lain.',
                textAlign: TextAlign.center,
                style: TextStyle(color: SeafoodColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey('$_query-$_selectedArea'),
        children: [
          for (var index = 0; index < meals.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: _enter(
                _buildRecipeCard(meals[index]),
                delay: index.clamp(0, 5) * 35,
                key: ValueKey('recipe-${meals[index].idMeal}'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(MealModel meal) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _openMeal(meal),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: _FoodImage(url: meal.strMealThumb),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.strMeal,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SeafoodColors.ink,
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.public_rounded,
                          size: 13,
                          color: SeafoodColors.green,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            meal.strArea,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: SeafoodColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F6F0),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        meal.strCategory,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SeafoodColors.deepGreen,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF9BA79F),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMeal(MealModel meal) {
    Navigator.pushNamed(context, AppRouting.exploreDetail, arguments: meal);
  }
}

class _FoodImage extends StatelessWidget {
  const _FoodImage({required this.url, this.iconSize = 34});

  final String url;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        final isLoaded = wasSynchronouslyLoaded || frame != null;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          child: isLoaded
              ? SizedBox.expand(key: const ValueKey('loaded'), child: child)
              : const ColoredBox(
                  key: ValueKey('loading'),
                  color: Color(0xFFEAF2EA),
                  child: Center(
                    child: Icon(
                      Icons.set_meal_rounded,
                      color: SeafoodColors.green,
                      size: 30,
                    ),
                  ),
                ),
        );
      },
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: const Color(0xFFEAF2EA),
        child: Center(
          child: Icon(
            Icons.set_meal_rounded,
            color: SeafoodColors.green,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}

class _ExploreLoading extends StatelessWidget {
  const _ExploreLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3EA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.set_meal_rounded,
              color: SeafoodColors.green,
              size: 28,
            ),
          ),
          const SizedBox(height: 15),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: SeafoodColors.green,
            ),
          ),
          const SizedBox(height: 11),
          const Text(
            'Menyiapkan inspirasi menu...',
            style: TextStyle(color: SeafoodColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ExploreError extends StatelessWidget {
  const _ExploreError({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 42,
              color: SeafoodColors.muted,
            ),
            const SizedBox(height: 13),
            const Text(
              'Menu belum bisa dimuat',
              style: TextStyle(
                color: SeafoodColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: SeafoodColors.muted, fontSize: 11),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreEmpty extends StatelessWidget {
  const _ExploreEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.ramen_dining_rounded,
              size: 42,
              color: SeafoodColors.muted,
            ),
            SizedBox(height: 12),
            Text(
              'Belum ada menu ditemukan',
              style: TextStyle(
                color: SeafoodColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
