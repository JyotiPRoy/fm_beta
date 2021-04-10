import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final headingStyle = TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Montserrat');
    final menuLabelStyle = TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Montserrat');
    return Material(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color.fromRGBO(116, 59, 157, 1), Color.fromRGBO(141, 91, 237, 1)],
          ),
        ),
        child: Stack(
          children: [
            // Avatar & Name
            Positioned(
              top: height * 0.053,
              left: width * 0.06,
              child: Row(
                children: [
                  ClipOval(
                    child: Container(
                      // TODO: REPLACE NUMBER IN PIXELS WITH STANDARD
                      height: 36,
                      width: 36,
                      color: Colors.white.withOpacity(0.3),
                      child: Center(child: Icon(Icons.person, color: Colors.white, size: 22,)),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.02,
                  ),
                  Text('Rachel Wills', style: headingStyle,)
                ],
              ),
            ),
            // Menu Options
            Positioned(
              top: height * 0.19,
              left: width * 0.06,
              child: Container(
                height: height * 0.28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ExpansionTile(
                    //   leading: Icon(Icons.link, color: Colors.white,),
                    //   title: Text('Quick Links', style: menuLabelStyle,),
                    // ),
                    Row(
                      children: [
                        Icon(Icons.link, color: Colors.white,),
                        SizedBox(
                          width: width * 0.015,
                        ),
                        Text('Quick Links', style: menuLabelStyle,),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.chartPie, color: Colors.white, size: 20,),
                        SizedBox(
                          width: width * 0.025,
                        ),
                        Text('Space Analyzer', style: menuLabelStyle,),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.tools, color: Colors.white, size: 20),
                        SizedBox(
                          width: width * 0.025,
                        ),
                        Text('Network Tools', style: menuLabelStyle,),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.cloud, color: Colors.white,),
                        SizedBox(
                          width: width * 0.015,
                        ),
                        Text('Cloud', style: menuLabelStyle,),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.share, color: Colors.white,),
                        SizedBox(
                          width: width * 0.015,
                        ),
                        Text('Sharing', style: menuLabelStyle,),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Settings
            Positioned(
              bottom: height * 0.05,
              left: width * 0.06,
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.white, size: 26,),
                  SizedBox(
                    width: width * 0.025,
                  ),
                  Text('Settings', style: menuLabelStyle,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
