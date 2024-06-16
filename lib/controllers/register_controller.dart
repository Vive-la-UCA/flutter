import 'package:flutter/material.dart';

class RegisterController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String? validateEmail(String? value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(value!) || value == null) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese un nombre de usuario';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su número de teléfono';
    } else if (!RegExp(r'^\+?\d{8,8}$').hasMatch(value)) {
      return 'Por favor ingrese un número de teléfono válido';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    if (value != repeatPasswordController.text) {
      return 'Las contraseñas deben ser iguales';
    }
    return null;
  }

  String? validateRepeatPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor repita su contraseña';
    } else if (passwordController.text != value) {
      return 'Las contraseñas deben ser iguales';
    }
    return null;
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    phoneController.dispose();
  }
}
