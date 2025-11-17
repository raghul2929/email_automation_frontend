class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    
    return null;
  }
  
  static String? validateProfession(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a profession';
    }
    return null;
  }
  
  static String? validateCampaignName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campaign name is required';
    }
    return null;
  }
  
  static String? validateSubject(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email subject is required';
    }
    return null;
  }
  
  static String? validateBody(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email body is required';
    }
    return null;
  }
}
