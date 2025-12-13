// lib/pages/auth_page.dart
import 'package:flutter/material.dart';
import 'package:mini_mood_diary/core/app_strings.dart';
import 'package:mini_mood_diary/services/firebase_service.dart';
import 'mood_diary_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();

  int _tabIndex = 0; 
  String _errorMessage = '';
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_tabIndex == 0) {
        // === ВХІД ===
        final error = await FirebaseService.instance.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;

        if (error != null) {
          setState(() => _errorMessage = error);
        } else {
          final user = FirebaseService.instance.auth.currentUser!;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MoodDiaryPage(
                name: _nameController.text.isNotEmpty ? _nameController.text : 'Користувач',
                surname: _surnameController.text.isNotEmpty ? _surnameController.text : '',
                email: user.email ?? '',
              ),
            ),
          );
        }
      } else {
        // === РЕЄСТРАЦІЯ ===
        final error = await FirebaseService.instance.register(
          _nameController.text.trim(),
          _surnameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;

        if (error != null) {
          setState(() => _errorMessage = error);
        } else {
          setState(() {
            _errorMessage = AppStrings.successRegister;
            _tabIndex = 0; // Повертаємо на логін
          });
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Невідома помилка');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _tabIndex == 0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Заголовок
                      Text(
                        isLogin ? AppStrings.login : AppStrings.register,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 20),

                      // Поля для реєстрації
                      if (!isLogin) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: AppStrings.nameHint,
                          ),
                          validator: (v) => v?.trim().isEmpty ?? true ? 'Введіть ім\'я' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _surnameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: AppStrings.surnameHint,
                          ),
                          validator: (v) => v?.trim().isEmpty ?? true ? 'Введіть прізвище' : null,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppStrings.emailHint,
                        ),
                        validator: (v) {
                          if (v?.trim().isEmpty ?? true) return 'Введіть email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                            return 'Невірний формат email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Пароль
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppStrings.passwordHint,
                        ),
                        validator: (v) => (v?.length ?? 0) < 6 ? 'Пароль ≥ 6 символів' : null,
                      ),
                      const SizedBox(height: 20),

                      // Кнопка
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(isLogin ? AppStrings.loginButton : AppStrings.registerButton),
                      ),
                      const SizedBox(height: 10),

                      // Перемикач
                      TextButton(
                        onPressed: () => setState(() {
                          _tabIndex = isLogin ? 1 : 0;
                          _errorMessage = '';
                        }),
                        child: Text(
                          isLogin ? AppStrings.noAccount : AppStrings.hasAccount,
                          style: const TextStyle(color: Colors.deepPurple),
                        ),
                      ),

                      // Повідомлення про помилку / успіх
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: _errorMessage.contains('успішна') ? Colors.green : Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }
}