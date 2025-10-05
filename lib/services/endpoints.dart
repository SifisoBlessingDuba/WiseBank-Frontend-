class Endpoints {
  static const String baseUrl = 'http://localhost:8081';

  // Users
  static String userById(String userId) => '$baseUrl/user/read_user/$userId';

  // Accounts
  static String accountsByUser(String userId) => '$baseUrl/account/read_account/by-user/$userId';
  static const String allAccounts = '$baseUrl/account/all_accounts';
  static String accountByNumber(String accountNumber) => '$baseUrl/account/by-number/$accountNumber';

  // Beneficiaries (canonical per backend controller)
  static const String beneficiaryBase = '$baseUrl/beneficiary';
  static const String beneficiarySave = '$baseUrl/beneficiary/save';
  static const String beneficiaryUpdate = '$baseUrl/beneficiary/update';
  static String beneficiaryDelete(String id) => '$baseUrl/beneficiary/delete/$id';
  static String beneficiaryRead(String id) => '$baseUrl/beneficiary/read/$id';
  static const String beneficiaryAll = '$baseUrl/beneficiary/all';

  // Withdrawals
  static const String withdrawals = '$baseUrl/withdrawals';
}
