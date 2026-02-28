import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:ui_demo/features/auth/presentation/pages/auth_page.dart';
import 'package:ui_demo/first_screen.dart';
// import 'package:ui_demo/home_page.dart';
import 'package:ui_demo/main.dart';
// import 'package:ui_demo/home_page.dart';s

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: Supabase.instance.client.auth.onAuthStateChange,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         // check if there is a valid session currently
//         final session = snapshot.hasData ? snapshot.data!.session : null;
//         if (session != null) {
//           return HomePage();
//         } else {
//           return FirstScreen();
//         }
//       },
//     );
//   }
// }

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = supabase.auth.currentSession;
        // print(supabase.auth.currentUser);
        // print(session!.user.);
        return session != null ? const CommunityPage() : const FirstScreen();
      },
    );
  }
}

