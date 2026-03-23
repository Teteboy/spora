import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  int _currentStep = 0;

  // Step 1: General Info
  String firstName = '';
  String lastName = '';
  int? age;
  String position = '';
  String email = '';
  String password = '';
  String? profilePhotoPath;

  // Step 2: Football Info
  String primaryPosition = '';
  String? secondaryPosition;
  double? height;
  double? weight;
  String dominantFoot = '';
  String currentClub = '';
  String leagueDivision = '';
  int yearsOfExperience = 0;
  List<String> previousClubs = [];

  // Step 3: Highlights
  List<String> uploadedVideos = [];

  int get currentStep => _currentStep;

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  bool get canGoNext {
    switch (_currentStep) {
      case 0:
        return firstName.isNotEmpty && lastName.isNotEmpty && email.isNotEmpty && password.length >= 6;
      case 1:
        return primaryPosition.isNotEmpty && currentClub.isNotEmpty;
      default:
        return true;
    }
  }

  void updateStep1({
    String? firstName,
    String? lastName,
    int? age,
    String? position,
    String? email,
    String? password,
  }) {
    if (firstName != null) this.firstName = firstName;
    if (lastName != null) this.lastName = lastName;
    if (age != null) this.age = age;
    if (position != null) this.position = position;
    if (email != null) this.email = email;
    if (password != null) this.password = password;
    notifyListeners();
  }

  void updateStep2({
    String? primaryPosition,
    String? secondaryPosition,
    double? height,
    double? weight,
    String? dominantFoot,
    String? currentClub,
    String? leagueDivision,
    int? yearsOfExperience,
  }) {
    if (primaryPosition != null) this.primaryPosition = primaryPosition;
    if (secondaryPosition != null) this.secondaryPosition = secondaryPosition;
    if (height != null) this.height = height;
    if (weight != null) this.weight = weight;
    if (dominantFoot != null) this.dominantFoot = dominantFoot;
    if (currentClub != null) this.currentClub = currentClub;
    if (leagueDivision != null) this.leagueDivision = leagueDivision;
    if (yearsOfExperience != null) this.yearsOfExperience = yearsOfExperience;
    notifyListeners();
  }

  void addVideo(String path) {
    uploadedVideos.add(path);
    notifyListeners();
  }

  void reset() {
    _currentStep = 0;
    firstName = '';
    lastName = '';
    age = null;
    position = '';
    email = '';
    password = '';
    primaryPosition = '';
    secondaryPosition = null;
    height = null;
    weight = null;
    dominantFoot = '';
    currentClub = '';
    leagueDivision = '';
    yearsOfExperience = 0;
    previousClubs = [];
    uploadedVideos = [];
    notifyListeners();
  }
}
