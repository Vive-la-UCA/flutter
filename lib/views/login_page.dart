import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Si el login cumple los requisitos pasa a hacer el siguiente codigo
      final email = _emailController.text;
      final password = _passwordController.text;
      print('Email: $email, Password: $password'); //valores para debug
      // aqui se agrega la logica del backend para verificar las credenciales
    }
  }

  String? _validateEmail(String? value) {
    // Verificar si el correo es un correo
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(value!) || value == null) {
      return 'Ingrese un correo electrónico válido';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
         
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                style: const TextStyle(
                  fontWeight:FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: Colors.white, // Color del texto ingresado
                ),
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors
                        .white, // Color de la etiqueta cuando está en posición flotante
                  ),
                  //fillColor: Color.fromARGB(255, 186, 184, 184), // Color de fondo del campo
                  //filled: true, // Debe ser true para que el color fillColor se aplique
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
                validator: _validateEmail,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                style: const TextStyle(
                    fontFamily: 'Montserrat', 
                    color: Colors.white
                    ),
                decoration:  const InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors
                        .white, // Color de la etiqueta cuando está en posición flotante
                  ),
                  //fillColor: Color.fromARGB(255, 186, 184, 184), // Color de fondo del campo
                  //filled: true, // Debe ser true para que el color fillColor se aplique
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
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese su contraseña';
                  }
                  return null;
                },





              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
