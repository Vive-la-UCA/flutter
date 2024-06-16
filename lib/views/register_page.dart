import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:vive_la_uca/controllers/register_controller.dart';
import 'package:vive_la_uca/views/home_page.dart';
import '../widgets/auth_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final RegisterController _controller = RegisterController();

  void _register() {
    if (_formKey.currentState!.validate()) {
      print(
          'Email: ${_controller.emailController.text}, Password: ${_controller.passwordController.text}'); // Debug
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
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
                    const Text(
                      'Registro',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    AuthField(controller: _controller.nameController, labelText: "Nombre", validator: _controller.validateName),
                    const SizedBox(height: 15,),
                    AuthField(controller: _controller.emailController, labelText: 'Correo electrónico', validator: _controller.validateEmail),
                     const SizedBox( height: 15,),
                    AuthField(controller: _controller.passwordController, labelText:  'Contraseña', validator: _controller.validatePassword, obscureText: true,),
                    const SizedBox( height: 15,),
                    AuthField(controller: _controller.repeatPasswordController, labelText: 'Contraseña', validator: _controller.validateRepeatPassword, obscureText: true,),
                    const SizedBox(height: 30),
                    
                    ElevatedButton(
                      onPressed: _register,
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
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
