import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cn_pocket_hr/constants/smart_kit_pro_constant.dart';
import 'package:cn_pocket_hr/helpers/custom_blur_hash.dart';

class WrCard1 extends StatelessWidget {
  const WrCard1({
    Key? key,
    this.localimg,
    this.image,
    this.blurUrl,
    this.title,
    this.country,
    this.price,
    this.press,
  }) : super(key: key);

  final String? localimg, image, blurUrl, title, country;
  final int? price;
  final Function? press;

  @override
  Widget build(BuildContext context) {
    const double DefaultPadding = 20.0;
    const PrimaryColor = Color(0xFF0C9869);
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(
        left: 12,
      ),
      width: size.width * 0.5,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(DefaultPadding / 2),
              decoration: BoxDecoration(
                color: Color.fromRGBO(252, 253, 250, 1),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(66, 66, 66, 1).withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(1, 1), // changes position of shadow
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                    child: OctoImage(
                      image: CachedNetworkImageProvider(
                        image!,
                      ),
                      placeholderBuilder: OctoBlurHashFix.placeHolder(
                        blurUrl!,
                      ),
                      height: MediaQuery.of(context).size.height / 12,
                      width: MediaQuery.of(context).size.height / 12,
                      errorBuilder: OctoError.icon(color: Colors.black),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Spacer(),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: "$title\n".toUpperCase(),
                            style: Theme.of(context).textTheme.labelLarge),
                        TextSpan(
                          text: "$country".toUpperCase(),
                          style: TextStyle(
                            color: PrimaryColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
