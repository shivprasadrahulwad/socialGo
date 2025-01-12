import 'package:flutter/material.dart';
import 'package:social/constants/global_variables.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _pronounsController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
              SizedBox(height: 10,),
              const Center(
                child: Text(
                  'Edit picture or avator',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: GlobalVariables.blueTextColor),
                ),
              ),
              TextFormField(
                controller: _nameController, // Bind the controller
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameController, // Bind the controller
                decoration: const InputDecoration(labelText: 'Username'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController, // Bind the controller
                decoration: const InputDecoration(labelText: 'Bio'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bio';
                  }

                  if (value.length > 25) {
                    return 'Bio should be less than 25 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pronounsController, // Bind the controller
                decoration: const InputDecoration(labelText: 'Pronoun'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Pronoun';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 120),

              const Text('PROFILE INFORMATION',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold,color: Colors.grey),),
              TextFormField(
                    controller: _emailController, // Bind the controller
                    decoration: const InputDecoration(labelText: 'Email address'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Email ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _numberController, // Bind the controller
                    decoration: const InputDecoration(labelText: 'Phone number'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }

                      if (value.length < 6) {
                        return 'Phone number should be 10 digit long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
            ],
          ),
        ));
  }
}
