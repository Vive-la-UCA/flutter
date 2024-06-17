import 'package:flutter/material.dart';
import 'package:vive_la_uca/controllers/register_controller.dart';
import '../widgets/auth_field.dart';
import '../widgets/form_button.dart';
import '../widgets/simple_text.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final RegisterController _controller = RegisterController();

  void _register() {
    if (_formKey.currentState!.validate()) {
      _controller.register(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
            constraints: BoxConstraints(minHeight: size.height),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Image(
                      image: AssetImage('lib/assets/images/logo.png'),
                      height: 200,
                    ),
                    const SimpleText(text: 'Registro'),
                    const SizedBox(height: 15),
                    AuthField(
                        controller: _controller.nameController,
                        labelText: "Nombre completo",
                        validator: _controller.validateName),
                    const SizedBox(
                      height: 15,
                    ),
                    AuthField(
                        controller: _controller.emailController,
                        labelText: 'Correo electrónico',
                        validator: _controller.validateEmail),
                    const SizedBox(
                      height: 15,
                    ),
                    AuthField(
                      controller: _controller.passwordController,
                      labelText: 'Contraseña',
                      validator: _controller.validatePassword,
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    AuthField(
                      controller: _controller.repeatPasswordController,
                      labelText: 'Repite la contraseña',
                      validator: _controller.validateRepeatPassword,
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),
                    FormButton(text: 'Registrarse', onPressed: _register),
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
