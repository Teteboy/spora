import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/spora_logo.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedPosition;
  String? _selectedFoot;
  String? _selectedNationality;
  RangeValues _ageRange = const RangeValues(16, 35);
  bool _premiumOnly = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().searchPlayers();
    });
  }

  void _search() {
    context.read<PlayerProvider>().searchPlayers(
      query: _searchCtrl.text,
      position: _selectedPosition,
      minAge: _ageRange.start.toInt(),
      maxAge: _ageRange.end.toInt(),
      nationality: _selectedNationality,
      foot: _selectedFoot,
      premiumOnly: _premiumOnly,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: const SporaLogo(height: 32),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _showFilters = !_showFilters),
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              size: 18,
              color: AppColors.primary,
            ),
            label: Text(
              'Filtres',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => _search(),
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un joueur, poste, club...',
                      hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textHint),
                      prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                if (_showFilters) ...[
                  const SizedBox(height: 12),
                  _buildFilters(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Results
          Expanded(
            child: Consumer<PlayerProvider>(
              builder: (context, provider, _) {
                if (provider.isSearching) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (provider.searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 60, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        const Text('Aucun joueur trouvé', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        const Text('Modifiez vos critères de recherche', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textHint)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
                  itemCount: provider.searchResults.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final player = provider.searchResults[i];
                    return GestureDetector(
                      onTap: () => context.push('/player/${player.id}', extra: player),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundImage: NetworkImage(player.avatarUrl ?? 'https://i.pravatar.cc/80?u=${player.id}'),
                                ),
                                if (player.isPremium)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(colors: AppColors.goldGradient),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.star, color: Colors.white, size: 10),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(player.fullName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${player.primaryPosition.split(' ').first} • ${player.age} ans • ${player.nationality}',
                                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.sports_soccer, size: 12, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(player.currentClub, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: AppColors.gold, size: 14),
                                    const SizedBox(width: 2),
                                    Text(player.rating.toStringAsFixed(1), style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('${player.profileViews} vues', style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: i * 50)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtres', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FilterDropdown(
                  hint: 'Poste',
                  value: _selectedPosition,
                  items: AppConstants.positions.map((p) => p.split(' ').first).toList(),
                  onChanged: (v) { setState(() => _selectedPosition = v); _search(); },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterDropdown(
                  hint: 'Pied',
                  value: _selectedFoot,
                  items: AppConstants.feet,
                  onChanged: (v) { setState(() => _selectedFoot = v); _search(); },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Âge: ${_ageRange.start.toInt()} - ${_ageRange.end.toInt()} ans',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
          ),
          RangeSlider(
            values: _ageRange,
            min: 14,
            max: 45,
            divisions: 31,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (v) { setState(() => _ageRange = v); _search(); },
          ),
          Row(
            children: [
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: _premiumOnly,
                  onChanged: (v) { setState(() => _premiumOnly = v); _search(); },
                  activeColor: AppColors.gold,
                ),
              ),
              const Text('Premium uniquement', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const _FilterDropdown({required this.hint, this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textHint)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
