import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constant.dart';
import '../models/user_model.dart';
import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../theme/seafood_theme.dart';

class ProfileAboutPage extends StatefulWidget {
  const ProfileAboutPage({super.key});

  @override
  State<ProfileAboutPage> createState() => _ProfileAboutPageState();
}

class _ProfileAboutPageState extends State<ProfileAboutPage> {
  UserModel? _user;
  String _profileName = '';
  String _className = '';
  String _attendanceNumber = '';
  bool _isLoading = true;

  String _profileKey(String field, [UserModel? user]) {
    final account = (user ?? _user)?.email.toLowerCase() ?? 'local';
    return 'profile_${account}_$field';
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await AuthService.getUserProfile();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _user = user;
      _profileName =
          prefs.getString(_profileKey('name', user)) ?? user?.name ?? '';
      _className = prefs.getString(_profileKey('class', user)) ?? '';
      _attendanceNumber =
          prefs.getString(_profileKey('attendance', user)) ?? '';
      _isLoading = false;
    });
  }

  Future<void> _editProfile() async {
    final draft = await showDialog<_ProfileDraft>(
      context: context,
      builder: (_) => _EditProfileDialog(
        name: _profileName.isNotEmpty ? _profileName : _user?.name ?? '',
        className: _className,
        attendanceNumber: _attendanceNumber,
      ),
    );

    if (draft != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey('name'), draft.name);
      await prefs.setString(_profileKey('class'), draft.className);
      await prefs.setString(_profileKey('attendance'), draft.attendanceNumber);
      if (mounted) {
        setState(() {
          _profileName = draft.name;
          _className = draft.className;
          _attendanceNumber = draft.attendanceNumber;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil disimpan di perangkat.'),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouting.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _profileName.isNotEmpty ? _profileName : 'Lengkapi profilmu';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang profil',
            onPressed: _isLoading ? null : _loadProfile,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [SeafoodColors.green, SeafoodColors.lime],
                      ),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white,
                          foregroundColor: SeafoodColors.deepGreen,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PROFIL PENGGUNA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                _user?.email ?? 'Email akun tidak tersedia',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Informasi profil',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _editProfile,
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Edit'),
                              ),
                            ],
                          ),
                          const Divider(height: 18),
                          _ProfileDetail(
                            icon: Icons.person_outline,
                            label: 'Nama lengkap',
                            value: _profileName.isEmpty
                                ? 'Belum diisi'
                                : _profileName,
                          ),
                          _ProfileDetail(
                            icon: Icons.school_outlined,
                            label: 'Kelas',
                            value: _className.isEmpty
                                ? 'Belum diisi'
                                : _className,
                          ),
                          _ProfileDetail(
                            icon: Icons.badge_outlined,
                            label: 'Nomor absen',
                            value: _attendanceNumber.isEmpty
                                ? 'Belum diisi'
                                : _attendanceNumber,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.public,
                        color: SeafoodColors.green,
                      ),
                      title: const Text('Sumber Public API'),
                      subtitle: const Text(ApiConstant.publicApiUrl),
                      isThreeLine: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar dari akun'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SeafoodColors.deepGreen,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileDraft {
  const _ProfileDraft({
    required this.name,
    required this.className,
    required this.attendanceNumber,
  });

  final String name;
  final String className;
  final String attendanceNumber;
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({
    required this.name,
    required this.className,
    required this.attendanceNumber,
  });

  final String name;
  final String className;
  final String attendanceNumber;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _classController;
  late final TextEditingController _attendanceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _classController = TextEditingController(text: widget.className);
    _attendanceController = TextEditingController(
      text: widget.attendanceNumber,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _attendanceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _ProfileDraft(
        name: _nameController.text.trim(),
        className: _classController.text.trim(),
        attendanceNumber: _attendanceController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit profil'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _classController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Kelas',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _attendanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nomor absen',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: SeafoodColors.green),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
