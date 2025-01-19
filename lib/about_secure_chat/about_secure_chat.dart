import 'package:flutter/material.dart';

class AboutSecureChat extends StatefulWidget {
  const AboutSecureChat({super.key});

  @override
  State<AboutSecureChat> createState() => _AboutSecureChatState();
}

class _AboutSecureChatState extends State<AboutSecureChat> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Row(
          children: [
            Image.asset(
              'images/image.png',  // Replace with your actual image path
              width: 30,  // Adjust the size as needed
              height: 30,
            ),
            const SizedBox(width: 10,),
            const Text(
              'About Secure Chat',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0), // Optional padding
          child: IconButton(
            icon: Container(
              decoration: const BoxDecoration( // Background color of the custom shape
                shape: BoxShape.circle, // Change this to other shapes like BoxShape.rectangle if needed
              ),
              child: const Icon(
                Icons.arrow_downward_outlined, // You can change the icon here
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Define the functionality when the icon is pressed
            },
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: width,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: width*.07,top: height*.02),
                child: const Text(
                    'What is Secure Chat?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: width*.1,top: height*.01,right: width*.05),
                child: const Text(
                  'Secure Chat is a reliable platform for chatting with your loved ones without getting the fear of being watched over. Chat securely with Secure Chat!',
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: width*.07,top: height*.02),
                child: const Text(
                  'What is Secure Chat made for?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: width*.1,top: height*.01,right: width*.05),
                child: const Text(
                  'Secure Chat is made for an Internship project by Muhammad Salman Abid.',
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: width*.07,top: height*.02),
                child: const Text(
                  'Want to know something else?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: width*.1,top: height*.01,right: width*.05),
                child: const Text(
                  'Contact us via: abid.salman2952@gmail.com Phone No: +92 (330) 9533315',
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: width*.07,top: height*.02),
                child: const Text(
                  'Is Secure Chat really secure?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: width*.1,top: height*.01,right: width*.05),
                child: const Text(
                  'Yes, your messages are secure on Secure Chat.',
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
