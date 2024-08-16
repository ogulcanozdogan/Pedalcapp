import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String completePhoneNumber = '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 200,
              ),
              const SizedBox(height: 30),
              _buildTextField(
                controller: firstNameController,
                labelText: 'First Name',
                icon: Icons.person,
                filteringTextInputFormatter:
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: lastNameController,
                labelText: 'Last Name',
                icon: Icons.person_outline,
                filteringTextInputFormatter:
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: emailController,
                labelText: 'Email',
                icon: Icons.email,
                filteringTextInputFormatter:
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@.]')),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: passwordController,
                labelText: 'Password',
                icon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 15),
              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                initialCountryCode: 'US',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (phone) {
                  completePhoneNumber = phone.completeNumber;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (firstNameController.text.isEmpty ||
                      lastNameController.text.isEmpty ||
                      completePhoneNumber.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please fill in all the required fields.',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    final UserCredential userCredential = await FirebaseAuth
                        .instance
                        .createUserWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userCredential.user?.uid)
                        .set({
                      'firstName': firstNameController.text,
                      'lastName': lastNameController.text,
                      'email': emailController.text,
                      'phone': completePhoneNumber,
                    });

                    Navigator.pushReplacementNamed(context, '/selectApp');
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Registration failed: ${e.message}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
    TextInputFormatter? filteringTextInputFormatter,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      inputFormatters: filteringTextInputFormatter != null
          ? [filteringTextInputFormatter]
          : [],
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
