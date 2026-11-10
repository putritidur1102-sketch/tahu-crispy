import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

class SessionService {
  static const _roleKey = 'demo_role';
  static const _cartKey = 'demo_cart';
  static const _nameKey = 'demo_name';

  // MODE DEMO: PIN contoh hanya untuk uji tampilan.
  // Jangan gunakan PIN hardcoded ini pada aplikasi produksi.
  static const demoPins = {
    '111111': ('Kasir Gerobak 1', 'Gerobak 1'),
    '222222': ('Kasir Gerobak 2', 'Gerobak 2'),
    '333333': ('Kasir Gerobak 3', 'Gerobak 3'),
  };

  Future<AppUser?> loginWithPin(String pin) async {
    final entry = demoPins[pin];
    if (entry == null) return null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, 'cashier');
    await prefs.setString(_cartKey, entry.$2);
    await prefs.setString(_nameKey, entry.$1);
    return AppUser(id: entry.$2.toLowerCase().replaceAll(' ', '_'),
      name: entry.$1, role: UserRole.cashier, cartId: entry.$2);
  }

  Future<AppUser?> loginDemoOwner({required bool admin}) async {
    final prefs = await SharedPreferences.getInstance();
    final role = admin ? UserRole.admin : UserRole.owner;
    final name = admin ? 'Admin Demo' : 'Pemilik Demo';
    await prefs.setString(_roleKey, role.name);
    await prefs.setString(_nameKey, name);
    await prefs.remove(_cartKey);
    return AppUser(id: role.name, name: name, role: role);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
    await prefs.remove(_cartKey);
    await prefs.remove(_nameKey);
  }
}
