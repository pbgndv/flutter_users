import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class User {
  final String name;
  final String email;

  const User({
    required this.name,
    required this.email,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Профиль пользователя',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthOrProfilePage(),
    );
  }
}

class AuthOrProfilePage extends StatefulWidget {
  const AuthOrProfilePage({super.key});

  @override
  State<AuthOrProfilePage> createState() => _AuthOrProfilePageState();
}

class _AuthOrProfilePageState extends State<AuthOrProfilePage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final email = prefs.getString('email');

    if (name != null && email != null) {
      setState(() {
        _user = User(name: name, email: email);
      });
    }
  }

  Future<void> _saveUser(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);

    setState(() {
      _user = User(name: name, email: email);
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('name');
    await prefs.remove('email');

    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _user == null
        ? AuthPage(onAuth: _saveUser)
        : ProfilePage(user: _user!, onLogout: _logout);
  }
}

class AuthPage extends StatefulWidget {
  final void Function(String, String) onAuth;

  const AuthPage({super.key, required this.onAuth});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  void _submit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty) {
      widget.onAuth(name, email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Имя'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Имя: ${user.name}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  'Email: ${user.email}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
