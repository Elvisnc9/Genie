import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:genie/Constant/color.dart';
import 'package:genie/Presentation/Pages/Authentication/google_auth.dart';
import 'package:genie/Presentation/Pages/onboarding/onboarding_screen.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
 final AuthService _authService = AuthService();

  User? user;

  void _checkUser() {
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkUser();
  }
  @override
  Widget build(BuildContext context) {
    final texttheme = Theme.of(context).textTheme;
    return Scaffold(
      body:Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 2.h),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: (){
                  Navigator.pushNamed(context, '/Home');
                },
                child: Text(
                  'Skip',
                  style: texttheme.displayMedium ,
                ),
              ),
            ),

            Image.asset('assets/icons/Name.png', height: 25.h, width: 70.w ),

            TextSpann(),

            SizedBox(height: 10.h,),


            
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          child: Column(
            children: [
              SocialButton(title: 'Continue with Google', logo: 'assets/icons/google_logo.png',
               authenticate: () async {
                      await _authService.signInWithGoogle(context);
                      _checkUser();
                },),
                SocialButton(title: 'Continue with Facebook', logo: 'assets/icons/facebook_logo.png', authenticate: ()  {
                     
                  },),

              SocialButton(title: '  Continue with email', logo: 'assets/icons/email_logo.png',
               authenticate: (){}),
              
            ],
          ),


        ),
      ),

      SizedBox(height: 5.h,),


  Text.rich(
      TextSpan(
        text: 'By Continuing you agree to ',// Parent style
        
        children: <TextSpan>[
          TextSpan(
            text: 'Terms\n & Privacy Policy',
          
            style: TextStyle(
              fontFamily: 'poppins',
              fontWeight: FontWeight.bold,
              color: AppColors.dark // Different style (bold)         // Different color// Add a decoration
            ),
          ),
          
        ],
      ),
      textAlign: TextAlign.center,
      style: texttheme.displayMedium?.copyWith(fontSize: 18.sp),
      )


          
          ],
        ),
      ) ,
    );
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key, required this.title, required this.logo, required this.authenticate,
  
  });

  final String title;
  final String logo;
  final VoidCallback authenticate;

 

  @override
  Widget build(BuildContext context) {
    final texttheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ButtonWidget(push: authenticate, child:  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(logo, height: 3.5.h,),
              
          SizedBox(width: 0.1.h,),
              
          Text(
           title,
            style: texttheme.bodyMedium?.copyWith(color: AppColors.light),
          )
          
        ],
      )),
    );
  }
}

class TextSpann extends StatelessWidget {
  const TextSpann({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
              width: double.infinity, 
              child: Center(
    child: DefaultTextStyle(
      textAlign: TextAlign.center,
      style:  TextStyle( // This sets the base style for all texts
        fontSize: 18.sp,
        color: Colors.black, // Default color
        fontWeight: FontWeight.bold,
      
      ),
      child: AnimatedTextKit(
        animatedTexts: [
          // The text that gets typed/cleared
          TypewriterAnimatedText(
            'Experience reality like never before.',
            speed: const Duration(milliseconds: 150),
          ),
          TypewriterAnimatedText(
            'Place furniture in your actual home.',
            speed: const Duration(milliseconds: 150),
          ),
          TypewriterAnimatedText(
            'Design your space, effortlessly.',
            speed: const Duration(milliseconds: 150),
          ),
        ],
        totalRepeatCount: 40, // Repeats the sequence a few times
        pause: const Duration(milliseconds: 1000),
        displayFullTextOnTap: true,
        stopPauseOnTap: true,
      ),
    ),
              ),
            );
  }
}