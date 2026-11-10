import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/app_user.dart';
import '../models/sale.dart';
import '../services/local_database.dart';
import '../services/session_service.dart';
import 'login_screen.dart';

class PosHomeScreen extends StatefulWidget {
  const PosHomeScreen({super.key, required this.user});
  final AppUser user;
  @override
  State<PosHomeScreen> createState() => _PosHomeScreenState();
}

class _PosHomeScreenState extends State<PosHomeScreen> {
  int _tab = 0;
  int _qty = 1;
  String _payment = 'Tunai';
  int get _unitPrice => cartId == 'Gerobak 1' ? 5000 : cartId == 'Gerobak 2' ? 6000 : 7000;
  bool _saving = false;
  Map<String, int> _summary = {'revenue': 0, 'count': 0, 'cash': 0, 'qris': 0};
  List<Map<String, Object?>> _sales = [];
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  bool get isCashier => widget.user.role == UserRole.cashier;
  String? get cartId => widget.user.cartId;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final summary = await LocalDatabase.instance.dailySummary(cartId: cartId);
    final sales = await LocalDatabase.instance.getSales(cartId: cartId);
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _sales = sales;
    });
  }

  Future<void> _saveSale() async {
    if (_saving || cartId == null) return;
    setState(() => _saving = true);
    try {
      final sale = Sale(
        id: const Uuid().v4(),
        cartId: cartId!,
        quantity: _qty,
        unitPrice: _unitPrice,
        paymentMethod: _payment,
        createdAt: DateTime.now(),
      );
      await LocalDatabase.instance.insertSale(sale.toMap());
      setState(() => _qty = 1);
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi tersimpan di perangkat.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    await SessionService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final title = isCashier ? cartId! : widget.user.name;
    return Scaffold(
      appBar: AppBar(
        title: Text('TAHU CRISPY POS · $title'),
        actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.logout))],
      ),
      body: isCashier ? _cashierBody() : _ownerBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (v) => setState(() => _tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Ringkasan'),
          NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'Kasir'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );
  }

  Widget _cashierBody() {
    if (_tab == 2) return _history();
    if (_tab == 0) return _summaryView();
    return _cashierView();
  }

  Widget _summaryView() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text('Ringkasan Hari Ini', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      _metric('Omzet', _currency.format(_summary['revenue'])),
      _metric('Jumlah transaksi', '${_summary['count']}'),
      _metric('Tunai', _currency.format(_summary['cash'])),
      _metric('QRIS', _currency.format(_summary['qris'])),
      const SizedBox(height: 12),
      const Text('Data tersimpan lokal pada perangkat ini.'),
    ],
  );

  Widget _cashierView() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text('Penjualan ${cartId!}', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 16),
      Card(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.fastfood, size: 42),
          const SizedBox(height: 8),
          const Text('TAHU CRISPY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 12),
          Text(_currency.format(_unitPrice), style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Harga contoh untuk prototype. Harga produksi harus diatur pemilik.'),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Harga: '),
            DropdownButton<int>(
              value: _unitPrice,
              items: [5000, 6000, 7000, 8000].map((v) => DropdownMenuItem(value: v, child: Text(_currency.format(v)))).toList(),
              onChanged: (v) => setState(() => _unitPrice = v ?? _unitPrice),
            ),
          ]),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Jumlah porsi', style: TextStyle(fontSize: 16)),
            Row(children: [
              IconButton.filledTonal(onPressed: () => setState(() => _qty = (_qty - 1).clamp(1, 999)), icon: const Icon(Icons.remove)),
              Text('$_qty', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton.filled(onPressed: () => setState(() => _qty++), icon: const Icon(Icons.add)),
            ]),
          ]),
          const Divider(),
          Text('Total: ${_currency.format(_qty * _unitPrice)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Tunai', label: Text('Tunai'), icon: Icon(Icons.payments)),
              ButtonSegment(value: 'QRIS', label: Text('QRIS'), icon: Icon(Icons.qr_code)),
            ],
            selected: {_payment},
            onSelectionChanged: (v) => setState(() => _payment = v.first),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 56,
            child: FilledButton.icon(
              onPressed: _saving ? null : _saveSale,
              icon: const Icon(Icons.check_circle),
              label: Text(_saving ? 'Menyimpan...' : 'SIMPAN TRANSAKSI'),
            )),
        ]),
      )),
    ],
  );

  Widget _history() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text('Riwayat ${cartId ?? 'Semua Gerobak'}', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      if (_sales.isEmpty) const Text('Belum ada transaksi.'),
      ..._sales.map((s) => Card(child: ListTile(
        title: Text(_currency.format(s['total'] as int)),
        subtitle: Text('${s['quantity']} porsi · ${s['payment_method']} · ${s['created_at']}'),
        trailing: const Icon(Icons.receipt_long),
      ))),
    ],
  );

  Widget _ownerBody() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text('Dashboard ${widget.user.role.name.toUpperCase()}', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      const Text('Akun demo pemilik/admin. Dashboard lintas perangkat membutuhkan integrasi Firebase.'),
      _metric('Omzet pada perangkat ini', _currency.format(_summary['revenue'])),
      _metric('Transaksi lokal', '${_summary['count']}'),
      const SizedBox(height: 12),
      const Text('Gerobak yang direncanakan: Gerobak 1, Gerobak 2, Gerobak 3.'),
      const Text('Harga, laporan gabungan, tutup kas, pengeluaran, payroll, PDF/Excel, dan sinkronisasi cloud adalah modul tahap integrasi berikutnya.'),
    ],
  );

  Widget _metric(String label, String value) => Card(
    child: ListTile(title: Text(label), trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
  );
}
