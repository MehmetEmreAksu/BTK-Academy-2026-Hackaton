/*
--------------------------------------------------------------------

Auth Gate - This will continuously listen for auth state changes

----------------------------------------------------------------------
unauthenticated -> show LoginScreen
authenticated -> show HomeScreen

*/


import 'package:btk_byte_benders/screens/login_screen.dart';
import 'package:btk_byte_benders/screens/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,
      // Build appropriate page based on auth state
      builder: (context, snapshot) {
        //loading...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        //check if user is authenticated
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session == null) {
          // User is not authenticated, show login screen
          return const LoginScreen();
        } else {
          // User is authenticated, show home screen
          return const UserScreen();
        }
        
      },
    );
  }
}