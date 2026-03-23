import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../data/mock_data.dart';

class PlayerProvider extends ChangeNotifier {
  List<PlayerModel> _trendingPlayers = [];
  List<PlayerModel> _searchResults = [];
  List<PlayerModel> _recommendedPlayers = [];
  List<VideoModel> _latestHighlights = [];
  final List<PlayerModel> _savedPlayers = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';

  List<PlayerModel> get trendingPlayers => _trendingPlayers;
  List<PlayerModel> get searchResults => _searchResults;
  List<PlayerModel> get recommendedPlayers => _recommendedPlayers;
  List<VideoModel> get latestHighlights => _latestHighlights;
  List<PlayerModel> get savedPlayers => _savedPlayers;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  Future<void> loadHomeData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));
    _trendingPlayers = MockData.trendingPlayers;
    _recommendedPlayers = MockData.trendingPlayers;
    _latestHighlights = MockData.latestHighlights;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRecommendedPlayers() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _recommendedPlayers = MockData.trendingPlayers;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchPlayers({
    String? query,
    String? position,
    int? minAge,
    int? maxAge,
    String? nationality,
    String? foot,
    bool? premiumOnly,
  }) async {
    _isSearching = true;
    _searchQuery = query ?? '';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _searchResults = MockData.trendingPlayers.where((player) {
      bool matches = true;
      if (query != null && query.isNotEmpty) {
        matches = matches &&
            (player.fullName.toLowerCase().contains(query.toLowerCase()) ||
                player.primaryPosition
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                player.currentClub.toLowerCase().contains(query.toLowerCase()));
      }
      if (position != null && position.isNotEmpty) {
        matches = matches && player.primaryPosition.contains(position);
      }
      if (minAge != null) matches = matches && player.age >= minAge;
      if (maxAge != null) matches = matches && player.age <= maxAge;
      if (nationality != null && nationality.isNotEmpty) {
        matches = matches && player.nationality == nationality;
      }
      if (foot != null && foot.isNotEmpty) {
        matches = matches && player.dominantFoot == foot;
      }
      if (premiumOnly == true) matches = matches && player.isPremium;
      return matches;
    }).toList();

    _isSearching = false;
    notifyListeners();
  }

  void toggleSavePlayer(PlayerModel player) {
    if (_savedPlayers.any((p) => p.id == player.id)) {
      _savedPlayers.removeWhere((p) => p.id == player.id);
    } else {
      _savedPlayers.add(player);
    }
    notifyListeners();
  }

  bool isPlayerSaved(String playerId) {
    return _savedPlayers.any((p) => p.id == playerId);
  }
}
