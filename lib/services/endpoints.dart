import 'globals.dart';

class Endpoints {
  static final String baseUrl = apiBaseUrl;

  // Users
  static String userById(String userId) => '$baseUrl/user/read_user/$userId';

  // Accounts
  static String accountsByUser(String userId) => '$baseUrl/account/read_account/by-user/$userId';
  static final String allAccounts = '$baseUrl/account/all_accounts';
  static String accountByNumber(String accountNumber) => '$baseUrl/account/by-number/$accountNumber';

  // Beneficiaries (canonical per backend controller)
  static final String beneficiaryBase = '$baseUrl/beneficiary';
  static final String beneficiarySave = '$baseUrl/beneficiary/save';
  static final String beneficiaryUpdate = '$baseUrl/beneficiary/update';
  static String beneficiaryDelete(String id) => '$baseUrl/beneficiary/delete/$id';
  static String beneficiaryRead(String id) => '$baseUrl/beneficiary/read/$id';
  static final String beneficiaryAll = '$baseUrl/beneficiary/all';

  // Withdrawals
  static final String withdrawals = '$baseUrl/withdrawals';
}
