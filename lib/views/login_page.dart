import 'package:flutter/material.dart';
import 'package:vive_la_uca/views/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
   
    final username = _usernameController.text;
    final password = _passwordController.text;
    print('Username: $username, Password: $password');
     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

       appBar: AppBar(
        title: const Text('Login'),
        
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
           ElevatedButton(
              onPressed: _login,
              child: Text('Iniciar Sesion'),
            ),
          ],
        ),
      ),
      
    );
  }
}