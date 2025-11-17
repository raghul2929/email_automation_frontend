class AppConstants {
  // App Info
  static const String appName = 'Email Automation';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String keyJwtToken = 'jwt_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  
  // Profession Options
  static const List<String> professions = [
    'Developer',
    'Designer',
    'Marketer',
    'Business Owner',
    'Sales Professional',
    'Content Creator',
    'Student',
    'Entrepreneur',
    'Consultant',
    'Other',
  ];
  
  // File Types
  static const List<String> allowedFileExtensions = ['xlsx', 'xls', 'csv'];
  
  // Validation
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
}
