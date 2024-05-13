import 'package:flutter/material.dart';
import 'package:vive_la_uca/views/home_page.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  @override
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
      print('Email: ${_controller.emailController.text}, Password: ${_controller.passwordController.text}');
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
                    const Text(
                      'Inicio de sesión',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                      ),
                      controller: _controller.emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                      validator: _controller.validateEmail,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _controller.passwordController,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                      ),
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      validator: _controller.validatePassword,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No tienes cuenta?',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: _toRegister,
                          child: const Text('Registrate aqui!',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              color: Colors.blue,
                            )
                          )
                        )
                      ],
                    )
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
