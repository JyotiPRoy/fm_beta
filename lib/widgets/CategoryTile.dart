import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryTile extends StatelessWidget {
  final String title;
  final String assetPath;
  final String contents;

  CategoryTile({
    this.title,
    this.assetPath,
    this.contents
  });

  @override
  Widget build(BuildContext context) {
    final globalHeight = MediaQuery.of(context).size.height;
    final globalWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints){
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        bool isScaledDown = constraints.maxWidth/MediaQuery.of(context).size.width < 0.4;

        return Container(
          height: globalHeight * 0.17,
          width: globalWidth * 0.4,
          decoration: BoxDecoration(
            color: Color.fromRGBO(235, 238, 243, 1),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: height * (height < 700 ? 0.026 : 0.02), horizontal: width * 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: height * 0.58,
                    width: width * 0.48,
                    child: SvgPicture.asset(assetPath)
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isScaledDown ? 12 : 15, fontFamily: 'Montserrat'),),
                SizedBox(
                  height: height * 0.01,
                ),
                Text(contents, style: TextStyle(fontSize: isScaledDown ? 10 : 13, fontFamily: 'Montserrat'),),
              ],
            ),
          ),
        );
      },
    );
  }
}
