import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../widgets/auth_page_layout.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final res = await AuthService.register(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;

      if (res['success'] == true) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouting.main,
          (route) => false,
        );
      } else {
        _showMessage(res['message']?.toString() ?? 'Pendaftaran gagal.');
      }
    } on TimeoutException {
      if (mounted) {
        _showMessage(
          'Server tidak merespons. Periksa server API lalu coba lagi.',
        );
      }
    } on http.ClientException {
      if (mounted) {
        _showMessage(
          'Tidak dapat terhubung ke server API. Pastikan server berjalan di port 8000.',
        );
      }
    } on FormatException {
      if (mounted) {
        _showMessage(
          'Respons server tidak valid. Periksa endpoint API pendaftaran.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      eyebrow: 'Mulai rencanakan menu',
      title: 'Buat akun.',
      description: 'Simpan inspirasi seafood dan susun rencana makanmu.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama lengkap',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Email tidak valid' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password (minimal 6 karakter)',
                prefixIcon: Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (v) =>
                  v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmPassCtrl,
              obscureText: _obscureConfirmation,
              decoration: InputDecoration(
                labelText: 'Ulangi password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () => _obscureConfirmation = !_obscureConfirmation,
                  ),
                  icon: Icon(
                    _obscureConfirmation
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) => value != _passCtrl.text
                  ? 'Konfirmasi password tidak sama'
                  : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Buat akun'),
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Sudah punya akun?'),
          TextButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRouting.login),
            child: const Text('Masuk'),
          ),
        ],
      ),
    );
  }
}
