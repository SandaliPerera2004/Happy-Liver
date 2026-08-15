import 'package:flutter/material.dart';
import 'package:happy_liver/screens/authentication/login_screen.dart';


class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends State<LanguageSelectionScreen> {

  String? selectedLanguage;

  void selectLanguage(String language) {
    setState(() {
      selectedLanguage = language;
    });
  }


  void continueNext() {

    if (selectedLanguage != null) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a language",
          ),
        ),
      );

    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(24),

          child: Column(

            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [


              const Text(

                "Choose Your Language",

                style: TextStyle(

                  fontSize: 28,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),


              const SizedBox(height: 15),




              const SizedBox(height: 40),



              languageOption("English"),


              languageOption("සිංහල"),


              languageOption("தமிழ்"),



              const SizedBox(height: 40),



              SizedBox(

                width: double.infinity,

                height: 55,


                child: ElevatedButton(

                  onPressed: continueNext,


                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.green[900],

                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(12),

                    ),

                  ),


                  child: const Text(

                    "Continue",

                    style: TextStyle(

                      fontSize: 18,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                ),

              ),
            ],

          ),

        ),

      ),

    );

  }



  Widget languageOption(String language) {


    bool isSelected =
        selectedLanguage == language;



    return GestureDetector(

      onTap: () {

        selectLanguage(language);

      },


      child: Container(

        width: double.infinity,

        margin:
        const EdgeInsets.only(bottom: 15),


        padding:
        const EdgeInsets.symmetric(

          horizontal: 20,

          vertical: 18,

        ),


        decoration: BoxDecoration(

          color: isSelected

              ? Colors.green.withValues(alpha: 0.1)

              : Colors.white,


          borderRadius:
          BorderRadius.circular(15),


          border: Border.all(

            width: 2,

            color: isSelected

                ? Colors.green

                : Colors.grey.shade300,

          ),

        ),



        child: Row(

          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,


          children: [



            Text(

              language,

              style: const TextStyle(

                fontSize: 20,

                fontWeight:
                FontWeight.w500,

              ),

            ),



            if (isSelected)

              const Icon(

                Icons.check_circle,

                color: Colors.green,

              ),


          ],

        ),

      ),

    );

  }

}