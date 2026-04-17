import 'package:cn_pocket_hr/helpers/hr_constant.dart';



class IntroductionModel {
  String? imageUrl;
  String? title;
  String? blurUrl;
  String? localimg;

  IntroductionModel({this.imageUrl, this.title, this.blurUrl, this.localimg});
}

List<IntroductionModel> introductionList = [
  IntroductionModel(
    title:
        'Plan your trips safely by browsing places through a safety parameter.',
    imageUrl:
        'https://cdn.pixabay.com/photo/2020/01/12/09/33/colombo-4759588_960_720.jpg',
    blurUrl: 'L9BpR]~DjW-:AzN{RlSP049}WBNH',
  ),
  IntroductionModel(
      title:
          'Connect with a community of registered travellers  and know their experiences.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2020/01/10/17/10/srilanka-4755729_960_720.jpg',
      blurUrl: 'L9BpR]~DjW-:AzN{RlSP049}WBNH',
      localimg: 'assets/travelapp/image/intro_image_b.jpg'),
  IntroductionModel(
      title: 'Have a safety at\nWorldTour',
      imageUrl:
          'https://cdn.pixabay.com/photo/2021/01/05/01/11/night-5889363_960_720.jpg',
      blurUrl: 'L671A#EK0#}TtSsSNbNa0K-V^O12',
      localimg: 'assets/travelapp/image/intro_image_c.jpg'),
];
