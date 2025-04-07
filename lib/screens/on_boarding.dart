import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:surveylance/App%20colors/colors.dart';
import 'package:surveylance/Authentication/login.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final controller = PageController();
  bool islastpage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget boardPage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 150, color: appcolor),
      SizedBox(height: 40),
      Card(
        elevation: 3,
        shadowColor: gridcolor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.all(20),
        color: taskcolor,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 20),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: controller,
          onPageChanged: (index) {
            setState(() => islastpage = index == 2);
          },
          children: [
            boardPage(
              icon: Icons.assignment_add,
              title: 'Complaint',
              subtitle:
                  'File a complaint about local sanitation or garbage collection in your neighbourhood.',
            ),
            boardPage(
              icon: Icons.live_help,
              title: 'Request',
              subtitle:
                  'Make a special request to collect your recyclables  like old electronics, used clothing etc.  ',
            ),
            boardPage(
              icon: Icons.event_available_rounded,
              title: 'Event',
              subtitle:
                  'join community activities focused on cleanliness and sanitation in your neighbourhood. ',
            ),
          ],
        ),
      ),
      bottomSheet:
          islastpage
              ? TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  minimumSize: Size.fromHeight(10),
                  backgroundColor: appcolor,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
              : Container(
                color: gridcolor,
                padding: EdgeInsetsDirectional.symmetric(horizontal: 20),
                height: 55,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => controller.jumpToPage(2),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: appcolor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Center(
                      child: SmoothPageIndicator(
                        controller: controller,
                        count: 3,
                        effect: WormEffect(
                          activeDotColor: appcolor,
                          dotColor: Colors.black12,
                          spacing: 15,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          () => controller.nextPage(
                            duration: Duration(microseconds: 500),
                            curve: Curves.easeInOut,
                          ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: appcolor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
