import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/player_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../widgets/spora_logo.dart';
import '../home/home_screen.dart' show PlayerListTile;
import 'package:badges/badges.dart' as badges;
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bordered icon tile used in the top bar (Figma header pattern, 44 px).
Widget _headerTile(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: AppDimens.minTouch,
      height: AppDimens.minTouch,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 26, color: AppColors.textPrimary),
    ),
  );
}

class RecruiterSearchScreen extends StatefulWidget {
  const RecruiterSearchScreen({super.key});

  @override
  State<RecruiterSearchScreen> createState() => _RecruiterSearchScreenState();
}

class _RecruiterSearchScreenState extends State<RecruiterSearchScreen> {
  final _searchController = TextEditingController();
  String _selectedPosition = '';
  String? _selectedCountry;
  RangeValues _ageRange = const RangeValues(14, 40);

  final List<String> _positions = [
    'Tous',
    'Gardien',
    'Défenseur',
    'Milieu',
    'Attaquant',
  ];

  /// Country chip label → nationality stored on PlayerModel (mock data).
  static const Map<String, String> _nationalityByCountry = {
    'France': 'Française',
    'England': 'Anglaise',
    'Spain': 'Espagnole',
    'Germany': 'Allemande',
    'Italy': 'Italienne',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSearch());
  }

  void _runSearch() {
    final query = _searchController.text.trim();
    context.read<PlayerProvider>().searchPlayers(
          query: query.isEmpty ? null : query,
          position: _selectedPosition.isEmpty ? null : _selectedPosition,
          minAge: _ageRange.start.round(),
          maxAge: _ageRange.end.round(),
          nationality: _selectedCountry == null
              ? null
              : _nationalityByCountry[_selectedCountry],
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.backgroundLight,
            floating: true,
            pinned: false,
            elevation: 0,
            title: Row(
              children: [
                const SporaLogo(height: 24, flat: true),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'CLUB',
                    style: TextStyle(
                      fontFamily: 'TikTok Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Consumer<MessagingProvider>(
                builder: (context, msg, _) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: badges.Badge(
                      showBadge: msg.unreadNotifications > 0,
                      badgeContent: Text(
                        '${msg.unreadNotifications}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 9),
                      ),
                      badgeStyle:
                          const badges.BadgeStyle(badgeColor: AppColors.danger),
                      child: _headerTile(LucideIcons.bell,
                          () => context.push('/notifications')),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher par nom, club...',
                        prefixIcon: const Icon(LucideIcons.search,
                            color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: const Icon(LucideIcons.slidersHorizontal,
                              color: AppColors.primary),
                          onPressed: () => _showFilterSheet(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                      onChanged: (_) => _runSearch(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Position Filters
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _positions.length,
                      itemBuilder: (context, index) {
                        final position = _positions[index];
                        final isSelected = position == _selectedPosition ||
                            (_selectedPosition.isEmpty && position == 'Tous');
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _PillChip(
                            label: position,
                            selected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedPosition =
                                    position == 'Tous' ? '' : position;
                              });
                              _runSearch();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Résultats',
                    style: TextStyle(
                      fontFamily: 'TikTok Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Consumer<PlayerProvider>(
            builder: (context, provider, _) {
              if (provider.isSearching || provider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final players = provider.searchResults;

              if (players.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text('Aucun résultat.', style: AppTextStyles.body()),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMD),
                sliver: SliverList.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) =>
                      PlayerListTile(player: players[index])
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (index * 50).ms),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtres avancés',
                    style: TextStyle(
                      fontFamily: 'TikTok Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _ageRange = const RangeValues(14, 40);
                        _selectedCountry = null;
                      });
                      setState(() {});
                    },
                    child: const Text('Réinitialiser'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Age Range
              const Text('Âge',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontFamily: 'TikTok Sans')),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_ageRange.start.round()} ans',
                      style: const TextStyle(fontFamily: 'TikTok Sans')),
                  Text('${_ageRange.end.round()} ans',
                      style: const TextStyle(fontFamily: 'TikTok Sans')),
                ],
              ),
              RangeSlider(
                values: _ageRange,
                min: 14,
                max: 40,
                divisions: 26,
                labels: RangeLabels(
                  _ageRange.start.round().toString(),
                  _ageRange.end.round().toString(),
                ),
                onChanged: (values) {
                  setModalState(() => _ageRange = values);
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),

              // Nationality
              const Text('Nationalité',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontFamily: 'TikTok Sans')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCountryChip('France', setModalState),
                  _buildCountryChip('England', setModalState),
                  _buildCountryChip('Spain', setModalState),
                  _buildCountryChip('Germany', setModalState),
                  _buildCountryChip('Italy', setModalState),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _runSearch();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Appliquer les filtres',
                      style: TextStyle(
                          fontFamily: 'TikTok Sans', fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryChip(String country, StateSetter setModalState) {
    final selected = _selectedCountry == country;
    return _PillChip(
      label: country,
      selected: selected,
      onTap: () =>
          setModalState(() => _selectedCountry = selected ? null : country),
    );
  }
}

/// Flat pill filter chip (home_screen `_FilterChip` pattern).
class _PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PillChip({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.lg, vertical: AppDimens.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption(
                  color:
                      selected ? AppColors.textLight : AppColors.textSecondary)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
