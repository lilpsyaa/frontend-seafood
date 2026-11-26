import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../widgets/auth_page_layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final res = await AuthService.login(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;

      if (res['success'] == true) {
        Navigator.pushReplacementNamed(context, AppRouting.main);
      } else {
        _showMessage(res['message']?.toString() ?? 'Login gagal.');
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
        _showMessage('Respons server tidak valid. Periksa endpoint API login.');
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
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      eyebrow: 'Selamat datang kembali',
      title: 'Masuk.',
      description: 'Masuk dan lanjutkan rencana menu seafood favoritmu.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                labelText: 'Password',
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Masuk ke akun'),
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Belum punya akun?'),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRouting.register),
            child: const Text('Daftar'),
          ),
        ],
      ),
    );
  }
}
