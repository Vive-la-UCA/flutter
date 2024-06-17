import 'package:flutter/material.dart';
import 'package:vive_la_uca/views/home_page.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_field.dart';
import '../widgets/form_button.dart';
import '../widgets/register_question.dart';
import '../widgets/simple_text.dart';

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
    Navigator.pushNamed(context, '/register');
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    }
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
            colors: [Color.fromARGB(255, 21, 38, 80), Color.fromARGB(255, 21, 38, 100)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
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
                    const SimpleText(text:  'Inicio de sesión'),
                    const SizedBox(height: 15),
                    AuthField(controller: _controller.emailController, labelText: 'Correo electrónico', validator: _controller.validateEmail),
                    const SizedBox(height: 15),
                    AuthField(controller: _controller.passwordController, labelText: 'Contraseña', validator: _controller.validatePassword),
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
