import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/session_service.dart';
import 'pos_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final pinController = TextEditingController();
  String? error;

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  Future<void> _cashierLogin() async {
    final user = await SessionService().loginWithPin(pinController.text);
    if (!mounted) return;
    if (user == null) {
      setState(() => error = 'PIN tidak sesuai. Periksa kembali.');
      return;
    }
    _open(user);
  }

  void _open(AppUser user) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => PosHomeScreen(user: user),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.storefront, size: 64, color: Color(0xFF17452F)),
                  const SizedBox(height: 12),
                  Text('TAHU CRISPY POS', textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const Text('Silakan masuk ke akun Anda', textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  const Text('PIN KASIR (6 DIGIT)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    decoration: const InputDecoration(hintText: 'Masukkan PIN', counterText: ''),
                    onSubmitted: (_) => _cashierLogin(),
                  ),
                  if (error != null) Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(error!, style: const TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _cashierLogin,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                    child: const Text('MASUK SEBAGAI KASIR'),
                  ),
                  const SizedBox(height: 28),
                  const Divider(),
                  const Text('Akses demo pemilik/admin (khusus pengujian)',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () async {
                      final user = await SessionService().loginDemoOwner(admin: false);
                      if (mounted && user != null) _open(user);
                    },
                    child: const Text('Masuk Demo Pemilik'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final user = await SessionService().loginDemoOwner(admin: true);
                      if (mounted && user != null) _open(user);
                    },
                    child: const Text('Masuk Demo Admin'),
                  ),
                  const SizedBox(height: 12),
                  const Text('PIN demo: 111111 (Gerobak 1), 222222 (Gerobak 2), 333333 (Gerobak 3).',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
