import 'package:shared_preferences/shared_preferences.dart';
import 'package:uzme/core/models/recent_account.dart';

/// Manages the list of recent accounts for quick re-login.
class RecentAccountsService {
  static const String _key = 'recent_accounts';
  static const int _maxAccounts = 5;

  List<RecentAccount> _accounts = [];

  List<RecentAccount> get accounts => List.unmodifiable(_accounts);

  /// Load recent accounts from SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _accounts = RecentAccount.decodeList(prefs.getString(_key));
  }

  /// Find a stored account by email, or null if missing.
  RecentAccount? findByEmail(String email) {
    for (final account in _accounts) {
      if (account.email == email) return account;
    }
    return null;
  }

  /// Add or update an account in the recent list.
  ///
  /// If the email already exists, it updates the entry, preserves the
  /// `biometricEnabled` flag, and moves it to the top.
  /// Keeps at most [_maxAccounts] entries.
  Future<void> addAccount(RecentAccount account) async {
    final existing = findByEmail(account.email);
    final merged = existing == null
        ? account
        : account.copyWith(biometricEnabled: existing.biometricEnabled);
    _accounts.removeWhere((a) => a.email == merged.email);
    _accounts.insert(0, merged);
    if (_accounts.length > _maxAccounts) {
      _accounts = _accounts.sublist(0, _maxAccounts);
    }
    await _save();
  }

  /// Remove an account from the recent list.
  Future<void> removeAccount(String email) async {
    _accounts.removeWhere((a) => a.email == email);
    await _save();
  }

  /// Toggle the biometric opt-in flag for [email].
  Future<void> setBiometricEnabled(String email, bool enabled) async {
    final index = _accounts.indexWhere((a) => a.email == email);
    if (index == -1) return;
    _accounts[index] = _accounts[index].copyWith(biometricEnabled: enabled);
    await _save();
  }

  /// Clear all recent accounts.
  Future<void> clear() async {
    _accounts = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, RecentAccount.encodeList(_accounts));
  }
}
