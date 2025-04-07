import 'package:flutter/material.dart';
import 'package:surveylance/App%20colors/colors.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appcolor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
        ),
        title: Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monitoring of IEC Activities, View events & File complaints with Surveylance!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: appcolor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Surveylance is your go-to app for maintaining sanitation and keeping your neighbourhood clean. '
              'Need regular door-to-door garbage collection? Want to get an area cleaned up or dispose of recyclables? '
              'With Surveylance, you can quickly raise a complaint or send a special request to get the help you need.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            _buildSectionTitle('• How It Works'),
            _buildSectionText(
              'Once you sign in as a citizen, you have options to either make a special request to get your recyclables '
              'collected or file a complaint about local sanitation. When you submit a request, it goes directly to a team '
              'leader, who reviews and approves it before assigning it to one of the IEC Team members. '
              'You\'ll get real-time updates on your request - from when it’s started, to when it’s completed, and finally accepted.',
            ),
            SizedBox(height: 5),
            _buildSectionTitle('• Convenient Recyclable Collection'),
            _buildSectionText(
              'Whether it’s old electronics, used clothing, newspapers, metal scraps, or even furniture, Surveylance helps '
              'you get recyclables collected with ease. Just choose the items you’d like to dispose of and set a date and time '
              'when you\'re available, making the process quick and hassle-free.',
            ),
            SizedBox(height: 5),

            _buildSectionTitle('• Join Community Events'),
            _buildSectionText(
              'Stay connected with what’s happening in your area! The ‘events’ feature in Surveylance lets you discover and '
              'join community activities focused on cleanliness and sanitation in your neighbourhood. These events aim not only '
              'to encourage active participation in cleanup drives and local initiatives but also to raise awareness on hygiene and '
              'waste management. By attending these events, users can engage in IEC (Information, Education, and Communication) activities, '
              'helping to spread valuable information about responsible waste disposal and sanitation practices. '
              'Surveylance keeps you informed and involved, making it easy to contribute to a cleaner, healthier community.',
            ),
            SizedBox(height: 5),

            _buildSectionTitle('• For IEC Team Members'),
            _buildSectionText(
              'Sanitation workers can log in with their assigned IDs to see all their tasks in one place. Each task provides fields '
              'for taking real-time photos and adding comments as needed. From complaints to special requests, everything is organised '
              'in a simple layout, making it easy to stay on top of tasks and track updates.',
            ),
            SizedBox(height: 5),

            _buildSectionTitle('• A Simple Solution for a Cleaner Community'),
            _buildSectionText(
              'With Surveylance, both citizens and sanitation teams can work together to create cleaner, healthier neighbourhoods. '
              'This app bridges the gap, making it easier for people to report issues and for workers to complete tasks efficiently and report. '
              'Join Surveylance and be part of the solution for a cleaner tomorrow!\n\n',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: appcolor,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Text(text, style: TextStyle(fontSize: 15)),
    );
  }
}
