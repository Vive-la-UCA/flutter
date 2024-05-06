

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:vive_la_uca/views/home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({ Key? key }) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

   final _formKey = GlobalKey<FormState>();
   final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  void _toRegister() {
    Navigator.pushNamed(context, '/register');
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      print('Email: $email, Password: $password'); // Debug
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

   String? _validateEmail(String? value) {
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
                    TextFormField(
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                      ),
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                      
                    ),
                    const SizedBox(height: 15,),
                    TextFormField(
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                      ),
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
  controller: _phoneController, // Asegúrate de definir `_phoneController`
  style: const TextStyle(
    fontFamily: 'Montserrat',
    color: Colors.white,
  ),
  keyboardType: TextInputType.phone, // Usa el teclado de teléfono
  inputFormatters: [
                  LengthLimitingTextInputFormatter(8), // Limitar a 8 caracteres
                  FilteringTextInputFormatter.digitsOnly, // Solo números
                ],
  decoration: const InputDecoration(
    labelText: 'Número de teléfono',
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
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su número de teléfono';
    } else if (!RegExp(r'^\+?\d{8,8}$').hasMatch(value)) {
      return 'Por favor ingrese un número de teléfono válido';
    }
    return null;
  },
),

const SizedBox(height: 15,),

                    TextFormField(
                      controller: _passwordController,
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
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor ingrese su contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _login,
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