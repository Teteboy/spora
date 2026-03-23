import 'user_model.dart';

class PlayerModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final int age;
  final String nationality;
  final String city;
  final String primaryPosition;
  final String? secondaryPosition;
  final double height;
  final double weight;
  final String dominantFoot;
  final String currentClub;
  final String leagueDivision;
  final int yearsOfExperience;
  final List<String> previousClubs;
  final String? preferredStyle;
  final SubscriptionType subscription;
  final int profileViews;
  final int followers;
  final List<VideoModel> highlights;
  final PlayerStats stats;
  final bool isVerified;
  final double rating;

  const PlayerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.age,
    required this.nationality,
    required this.city,
    required this.primaryPosition,
    this.secondaryPosition,
    required this.height,
    required this.weight,
    required this.dominantFoot,
    required this.currentClub,
    required this.leagueDivision,
    required this.yearsOfExperience,
    this.previousClubs = const [],
    this.preferredStyle,
    this.subscription = SubscriptionType.free,
    this.profileViews = 0,
    this.followers = 0,
    this.highlights = const [],
    required this.stats,
    this.isVerified = false,
    this.rating = 0.0,
  });

  String get fullName => '$firstName $lastName';
  bool get isPremium => subscription == SubscriptionType.premium;
}

class PlayerStats {
  final int matchesPlayed;
  final int goals;
  final int assists;
  final int cleanSheets;
  final double passAccuracy;
  final double shotAccuracy;

  const PlayerStats({
    this.matchesPlayed = 0,
    this.goals = 0,
    this.assists = 0,
    this.cleanSheets = 0,
    this.passAccuracy = 0.0,
    this.shotAccuracy = 0.0,
  });
}

class VideoModel {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final String? videoUrl;
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final DateTime uploadDate;
  final String playerId;
  final String playerName;
  final String? playerAvatarUrl;
  final double playerRating;

  const VideoModel({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    this.videoUrl,
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    required this.uploadDate,
    required this.playerId,
    required this.playerName,
    this.playerAvatarUrl,
    this.playerRating = 0.0,
  });
}
