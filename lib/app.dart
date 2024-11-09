import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_2/features/auth/data/firebase_auth_repo.dart';
import 'package:social_media_2/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_2/features/auth/presentation/cubits/auth_states.dart';
import 'package:social_media_2/features/auth/presentation/pages/auth_page.dart';
import 'package:social_media_2/features/home/presentation/pages/home_page.dart';
import 'package:social_media_2/features/profile/data/firebase_profile_repo.dart';
import 'package:social_media_2/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_2/themes/light_mode.dart';

/*

App -- Root Level

--------------------------------------------------------------------------------

Repositories : For the database
  -- FIrebase

Bloc Providers : for State management
  -- Auth
  -- Profile
  -- Post
  -- Search
  -- Theme

Check Auth State : 
  -- Unauthenticated -> Auth Page (login/register)
  -- Authenticated -> Home Page

*/

class MyApp extends StatelessWidget {
  // auth repo
  final authRepo = FirebaseAuthRepo();

  // profile repo
  final profileRepo = FirebaseProfileRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // provide cubits to app
    return MultiBlocProvider(
      providers: [
        // auth cubit
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
        ),

        // profile cubit
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(profileRepo: profileRepo),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, authState) {
            // print(authState); // test

            // Unauthenticated -> Auth Page (login/register)
            if (authState is Unauthenticated) {
              return const AuthPage();
            }

            // Authenticated -> Home Page
            if (authState is Authenticated) {
              return const HomePage();
            }

            // loading . . .
            else {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },

          // listen for login errors..
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                  showCloseIcon: true,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
