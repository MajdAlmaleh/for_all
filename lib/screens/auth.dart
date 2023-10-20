// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:for_all/main.dart';
import 'package:for_all/providers/user_provider.dart';
import 'package:for_all/widgets/my_image_picker.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  var _enterdEmail = '';
  var _enterdPassword = '';
  var _enterdUserName = '';
  // ignore: avoid_init_to_null
  var _selectedImage = null;
  // ignore: avoid_init_to_null
  var _enterdBio = null;
  var _isSignUp = false;
  var _isAuthing = false;
  RegExp regExp = RegExp(r'^[a-zA-Z0-9]+$');
  final _form = GlobalKey<FormState>();

  void _submit() async {
    if (_selectedImage == null && _isSignUp) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('please select an image')));
      return;
    }

    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }
    setState(() {
      _isAuthing = true;
    });
    _form.currentState!.save();
    try {
      if (_isSignUp) {
        await ref.read(authProvider.notifier).signUp(
            email: _enterdEmail,
            password: _enterdPassword,
            username: _enterdUserName,
            bio: _enterdBio,
            userImage: _selectedImage);
      } else {
        await ref
            .read(authProvider.notifier)
            .signIn(email: _enterdEmail, password: _enterdPassword);
      }
    } catch (e) {
      setState(() {
        _isAuthing = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider);
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSignUp)
                    MyImagePicker(
                      onPickImage: (pickedImage) {
                        _selectedImage = pickedImage;
                      },
                    ),
                  Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          onSaved: (newValue) {
                            _enterdEmail = newValue!;
                          },
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid Email';
                            }
                            return null;
                          },
                          decoration:
                              const InputDecoration(labelText: 'Email Address'),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                        ),
                        TextFormField(
                          onSaved: (newValue) {
                            _enterdPassword = newValue!;
                          },
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                value.length < 6) {
                              return 'Password must be 6 characters at least';
                            }
                            return null;
                          },
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),
                        if (_isSignUp)
                          TextFormField(
                            onSaved: (newValue) {
                              _enterdUserName = newValue!;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.length < 4) {
                                return 'Username must be 4 characters at least';
                              }
                              if (!regExp.hasMatch(value)) {
                                return 'Must only include alphbetics and numbers';
                              }
                              return null;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Username'),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                          ),
                        if (_isSignUp)
                          TextFormField(
                            onSaved: (newValue) {
                              _enterdBio = newValue;
                            },
                            validator: (value) {
                              return null;
                            },
                            decoration: const InputDecoration(labelText: 'Bio'),
                            autocorrect: false,
                          ),
                        if (_isAuthing) const CircularProgressIndicator(),
                        if (!_isAuthing)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: _isSignUp
                                ? const Text('Sign Up')
                                : const Text('Sign In'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!_isAuthing)
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isSignUp
                        ? const Text(
                            'Already have an account?',
                          )
                        : const Text(
                            'Don\'t have an account?',
                          ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                        });
                      },
                      child: _isSignUp
                          ? const Text('Sign in')
                          : const Text('Sign up'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
