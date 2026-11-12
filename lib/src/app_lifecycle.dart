import 'package:flutter/widgets.dart'
    show AppLifecycleState, WidgetsBinding, WidgetsBindingObserver;

/// `WidgetsBinding` yang sedang aktif, atau `null` bila belum ada.
///
/// SDK TIDAK BOLEH memanggil `WidgetsFlutterBinding.ensureInitialized()`
/// sendiri: SDK juga dipakai di test Dart murni dan di isolate background
/// (mis. handler FCM) yang tidak punya binding. Membuat binding di sana
/// mengubah perilaku aplikasi tanpa sepengetahuannya.
///
/// Di Flutter 2.x getter `instance` bertipe nullable dan mengembalikan `null`
/// bila belum di-inisialisasi. Sejak Flutter 3.0 getter-nya non-nullable dan
/// MELEMPAR bila belum di-inisialisasi (`FlutterError` dari assert di mode
/// debug, error null-check di mode release). Fungsi ini menyamakan keduanya:
/// return type nullable + try/catch.
WidgetsBinding? maybeWidgetsBinding() {
  try {
    return WidgetsBinding.instance;
  } catch (_) {
    return null;
  }
}

/// Memanggil [onResumed] setiap kali aplikasi kembali ke foreground
/// ([AppLifecycleState.resumed]), dengan debounce.
///
/// Debounce mencegah rentetan resume (mis. dialog izin sistem, app switcher,
/// atau aplikasi yang juga memanggil `handleAppResumed()` dari observer-nya
/// sendiri) memborbardir endpoint sync.
class AppResumeSync with WidgetsBindingObserver {
  AppResumeSync({
    required this.onResumed,
    this.debounce = defaultDebounce,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const defaultDebounce = Duration(seconds: 2);

  /// Dikerjakan saat resume. Mengembalikan `false` bila tidak ada yang
  /// dikerjakan (mis. user belum login), supaya resume tersebut tidak
  /// membuka jendela debounce.
  final bool Function() onResumed;
  final Duration debounce;
  final DateTime Function() _now;

  WidgetsBinding? _binding;
  DateTime? _lastRun;

  bool get isAttached => _binding != null;

  /// Daftarkan observer ke binding yang SUDAH ada. Idempoten.
  ///
  /// Mengembalikan `false` bila belum ada binding; tidak ada yang didaftarkan
  /// dan pemanggil boleh mencoba lagi nanti.
  bool attach() {
    if (_binding != null) return true;
    var binding = maybeWidgetsBinding();
    if (binding == null) return false;
    binding.addObserver(this);
    _binding = binding;
    return true;
  }

  /// Lepas observer dan reset debounce. Aman dipanggil berulang kali.
  void detach() {
    _binding?.removeObserver(this);
    _binding = null;
    _lastRun = null;
  }

  /// Jalankan [onResumed] kecuali masih dalam jendela debounce dari run
  /// sebelumnya. Mengembalikan `true` bila [onResumed] benar-benar bekerja.
  bool trigger() {
    var now = _now();
    var last = _lastRun;
    if (last != null && now.difference(last) < debounce) return false;
    if (!onResumed()) return false;
    _lastRun = now;
    return true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) trigger();
  }
}
