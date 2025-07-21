class Constants {
  static const List<String> topics = [
    'Technology',
    'Business',
    'Programming',
    'Entertainment',
  ];

  static const List<String> securityModes = [
    securityNone,
    securityPassword,
    securityApproval,
  ];

  static const String securityNone = 'None';
  static const String securityPassword = 'Password';
  static const String securityApproval = 'Approval by Admin';

  static const noConnectionErrorMessage = 'Not connected to a network!';
}
