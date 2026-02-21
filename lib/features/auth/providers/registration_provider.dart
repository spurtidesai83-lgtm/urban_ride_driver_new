import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationState {
  final String? selectedCity;
  final String? selectedLanguage;
  final String? phoneOrEmail;
  final String? emailAddress;
  final bool isEmailValid;
  final bool isDropdownOpen;
  final int selectedVehicleIndex;

  RegistrationState({
    this.selectedCity = 'Pune',
    this.selectedLanguage = 'en',
    this.phoneOrEmail,
    this.emailAddress = '',
    this.isEmailValid = false,
    this.isDropdownOpen = false,
    this.selectedVehicleIndex = 0,
  });

  RegistrationState copyWith({
    Object? selectedCity = _sentinel,
    Object? selectedLanguage = _sentinel,
    Object? phoneOrEmail = _sentinel,
    Object? emailAddress = _sentinel,
    bool? isEmailValid,
    bool? isDropdownOpen,
    int? selectedVehicleIndex,
  }) {
    return RegistrationState(
      selectedCity: selectedCity == _sentinel ? this.selectedCity : (selectedCity as String?),
      selectedLanguage: selectedLanguage == _sentinel ? this.selectedLanguage : (selectedLanguage as String?),
      phoneOrEmail: phoneOrEmail == _sentinel ? this.phoneOrEmail : (phoneOrEmail as String?),
      emailAddress: emailAddress == _sentinel ? this.emailAddress : (emailAddress as String?),
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isDropdownOpen: isDropdownOpen ?? this.isDropdownOpen,
      selectedVehicleIndex: selectedVehicleIndex ?? this.selectedVehicleIndex,
    );
  }

  static const _sentinel = Object();
}

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  RegistrationNotifier() : super(RegistrationState());

  void setCity(String city) {
    state = state.copyWith(selectedCity: city);
  }

  void setLanguage(String languageCode) {
    state = state.copyWith(selectedLanguage: languageCode, isDropdownOpen: false);
  }

  void toggleDropdown() {
    state = state.copyWith(isDropdownOpen: !state.isDropdownOpen);
  }

  void setPhoneOrEmail(String val) {
    state = state.copyWith(phoneOrEmail: val);
  }

  void setEmailAddress(String email) {
    final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
    state = state.copyWith(emailAddress: email, isEmailValid: isValid);
  }

  void setVehicleIndex(int index) {
    state = state.copyWith(selectedVehicleIndex: index);
  }

  void reset() {
    state = RegistrationState();
  }
}

final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  return RegistrationNotifier();
});
