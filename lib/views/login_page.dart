import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vive_la_uca/services/token_service.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_field.dart';
import '../widgets/form_button.dart';
import '../widgets/register_question.dart';
import '../widgets/simple_text.dart';
import 'package:vive_la_uca/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final LoginController _controller = LoginController();

  void _toRegister() {
    GoRouter.of(context).replace('/register');
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      // Navigator.of(context)
      //     .pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));

      final email = _controller.emailController.text;
      final password = _controller.passwordController.text;

      try {
        // final authService = AuthService(
        //     baseUrl: 'https://vivelauca.uca.edu.sv/admin-back/api/auth');

        final authService = AuthService(
            baseUrl: 'https://vivelauca.uca.edu.sv/admin-back/api/auth');
        final result = await authService.login(email, password);

        if (result.containsKey('token')) {
          await TokenStorage.saveToken(result['token']);
          GoRouter.of(context).replace('/home');
        } else {
          _showErrorDialog('Failed to login: ${result['message']}');
        }
      } catch (e) {
        _showErrorDialog('Check credentials and try again.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 21, 38, 80),
              Color.fromARGB(255, 21, 38, 100)
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Image(
                      image: AssetImage('lib/assets/images/logo.png'),
                      height: 300,
                    ),
                    const SimpleText(text: 'Inicio de sesión'),
                    const SizedBox(height: 15),
                    AuthField(
                        controller: _controller.emailController,
                        labelText: 'Correo electrónico',
                        validator: _controller.validateEmail),
                    const SizedBox(height: 15),
                    AuthField(
                        controller: _controller.passwordController,
                        labelText: 'Contraseña',
                        validator: _controller.validatePassword,
                        obscureText: true),
                    const SizedBox(height: 30),
                    FormButton(text: 'Iniciar sesión', onPressed: _login),
                    const SizedBox(height: 10),
                    RegisterQuestion(onRegisterPressed: _toRegister),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
