import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/player_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../widgets/player_card.dart';
import '../../widgets/spora_logo.dart';
import 'package:badges/badges.dart' as badges;

class AgentSearchScreen extends StatefulWidget {
  const AgentSearchScreen({super.key});

  @override
  State<AgentSearchScreen> createState() => _AgentSearchScreenState();
}

class _AgentSearchScreenState extends State<AgentSearchScreen> {
  final _searchController = TextEditingController();
  String _selectedPosition = '';
  
  final List<String> _positions = [
    'Tous',
    'Gardien',
    'Défenseur',
    'Milieu',
    'Attaquant',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().loadRecommendedPlayers();
    });
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
                const SporaLogo(height: 28),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'AGENT',
                    style: TextStyle(
                      fontFamily: 'Poppins',
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
                        style: const TextStyle(color: Colors.white, fontSize: 9),
                      ),
                      badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.gold),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                        onPressed: () => context.push('/notifications'),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
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
                      color: Colors.white,
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
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.tune, color: AppColors.primary),
                          onPressed: () => _showFilterSheet(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onChanged: (value) {
                        // Implement search
                      },
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
                        final isSelected = position == _selectedPosition || (_selectedPosition.isEmpty && position == 'Tous');
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              position,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedPosition = position == 'Tous' ? '' : position;
                              });
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : AppColors.border,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Résultats',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: Consumer<PlayerProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final players = provider.recommendedPlayers;
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PlayerCard(
                        player: player,
                        onTap: () => context.push('/player/${player.id}'),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);
                  },
                );
              },
            ),
          ),
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
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() => _ageRange = const RangeValues(14, 40));
                      setState(() {});
                    },
                    child: const Text('Réinitialiser'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Age Range
              const Text('Âge', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_ageRange.start.round()} ans', style: const TextStyle(fontFamily: 'Poppins')),
                  Text('${_ageRange.end.round()} ans', style: const TextStyle(fontFamily: 'Poppins')),
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
              const Text('Nationalité', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCountryChip('France'),
                  _buildCountryChip('England'),
                  _buildCountryChip('Spain'),
                  _buildCountryChip('Germany'),
                  _buildCountryChip('Italy'),
                ],
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Appliquer les filtres', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCountryChip(String country) {
    return Chip(
      label: Text(country, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
  
  RangeValues _ageRange = const RangeValues(14, 40);
}
