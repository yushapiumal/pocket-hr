import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localstorage/localstorage.dart';
import 'package:octo_image/octo_image.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:cn_pocket_hr/Constant/Slideanimation.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/controller/controller.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/GlassBox.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/HRStrings.dart';
import 'package:cn_pocket_hr/helper/customBlurHash.dart';
import 'package:cn_pocket_hr/model/SliderModel.dart';

class TabletHome extends StatefulWidget {
  const TabletHome({Key? key}) : super(key: key);

  @override
  State<TabletHome> createState() => _TabletHomeState();
}

class _TabletHomeState extends State<TabletHome> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  AnimationController? _animationController;
  PageController? _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final String morningBg =
      "https://www.farmersalmanac.com/wp-content/uploads/2020/11/Earliest-Sunrise-June-A191879830.jpg";
  final String afternoonBg =
      "https://www.farmersalmanac.com/wp-content/uploads/2020/11/Earliest-Sunrise-June-A191879830.jpg";
  final String eveningBg =
      "https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/sunset-quotes-21-1586531574.jpg";
  final String nightBg = "https://wallpaperaccess.com/full/2113857.jpg";

  late String bgImg;
  String? _dateTime;
  late Timer _timer;
  late String checking = "CHECK-IN";
  final DateTime now = DateTime.now();

  final LocalStorage storage = LocalStorage('pocketHR');
  final APIService apiService = APIService();
  final HRController controller = HRController();

  var latitude;
  var longitude;
  var address;
  late StreamSubscription<Position> streamSubscription;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    getLocation();
    _controller = PageController(initialPage: 0);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => getTime());
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  }

  @override
  void dispose() {
    _timer.cancel();
    streamSubscription.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  void getTime() {
    final languageCode = Localizations.localeOf(context).languageCode;
    String formattedDateTime = "";

    String suffix = 'th';
    final int digit = now.day % 10;
    if ((digit > 0 && digit < 4) && (now.day < 11 || now.day > 13)) {
      suffix = <String>['st', 'nd', 'rd'][digit - 1];
    }

    if (languageCode == 'si' || languageCode == 'ta') {
      formattedDateTime = DateFormat("dd MMM yyyy - kk:mm:ss", languageCode).format(DateTime.now()).toString();
    } else {
      formattedDateTime = DateFormat("d'$suffix' MMM yyyy - kk:mm:ss", languageCode).format(DateTime.now()).toString();
    }

    setState(() {
      _dateTime = formattedDateTime;
    });
  }

  Future<void> checkinCheckout(String type) async {
    final DateTime getCurrentTimestamp = DateTime.now();
    final String date = controller.formatISOTime(getCurrentTimestamp);

    final lat = (latitude != null) ? latitude.toString() : null;
    final lng = (longitude != null) ? longitude.toString() : null;
    final addr = (address != null) ? address.toString() : null;

    await apiService.checkInCheckout(
      date,
      type,
      latitude: lat,
      longitude: lng,
      address: addr,
    );
  }

  void changeBTN() {
    if (storage.getItem('checking')) {
      checking = "CHECK-OUT";
    } else {
      checking = "CHECK-IN";
    }
  }

  String setBgImage() {
    final hours = DateTime.now().hour;
    if (hours < 12) {
      bgImg = morningBg;
    } else if (hours < 14) {
      bgImg = afternoonBg;
    } else if (hours < 18) {
      bgImg = eveningBg;
    } else {
      bgImg = nightBg;
    }
    return bgImg;
  }

  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    streamSubscription = Geolocator.getPositionStream().listen((Position position) {
      latitude = position.latitude;
      longitude = position.longitude;
      getAddressFromLatLang(position);
    });
  }

  Future<void> getAddressFromLatLang(Position position) async {
    final placemark = await placemarkFromCoordinates(position.latitude, position.longitude);
    final place = placemark[0];
    address = '${place.street}, ${place.locality}';
  }

  Widget slider() {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width;

    // Tablet responsive: keep same design but constrain the glass card width.
    final contentMaxWidth = (maxWidth * 0.92).clamp(720.0, 1100.0);

    return SizedBox(
      height: size.height / 1.9,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: 1,
            onPageChanged: (int index) => setState(() => currentIndex = index),
            itemBuilder: (_, i) {
              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  child: OctoImage(
                    image: CachedNetworkImageProvider(setBgImage()),
                    placeholderBuilder: OctoBlurHashFix.placeHolder(sliderList[i].blurUrl!),
                    width: size.width,
                    height: size.height,
                    errorBuilder: OctoError.icon(color: HRColors.black),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.05),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: SizedBox(
                  height: size.height / 5.2,
                  child: SlideAnimation(
                    position: 4,
                    itemCount: 8,
                    slideDirection: SlideDirection.fromTop,
                    animationController: _animationController,
                    child: GlassBox(
                      redius: 40.0,
                      width: contentMaxWidth,
                      height: size.height / 5.2,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 20.0),
                                        child: Text(
                                          _dateTime ?? "loading...",
                                          style: const TextStyle(
                                            color: HRColors.black,
                                            fontSize: 25,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: SingleChildScrollView(
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 20.0, top: 1.0),
                                            child: Text(
                                              address ?? "loading...",
                                              style: const TextStyle(color: HRColors.black, fontSize: 15),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => checkinCheckout('checkin'),
                                        child: Container(
                                          height: 50,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [HRColors.blueColor, HRColors.blueColor],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              bottomLeft: Radius.circular(20),
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(left: 20.0),
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                'CHECK-IN',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: HRColors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Icon(Icons.input, color: HRColors.white),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => checkinCheckout('checkout'),
                                        child: Container(
                                          height: 50,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [HRColors.orangeColor, HRColors.orangeColor],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(20),
                                              bottomRight: Radius.circular(20),
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(left: 5.0, right: 20.0),
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                'CHECK-OUT',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: HRColors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Icon(Icons.output, color: HRColors.white),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget data() {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            snap: false,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text("", style: TextStyle(color: HRColors.white, fontSize: 0)),
              background: Stack(children: [slider()]),
            ),
            actions: <Widget>[
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, HRNotifications.routeName),
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  alignment: Alignment.center,
                  child: GlassBox(
                    redius: 40.0,
                    width: 50,
                    height: 50,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset("assets/svg/notifications_icon.svg"),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            expandedHeight: MediaQuery.of(context).size.height / 2,
            backgroundColor: Colors.transparent.withOpacity(0.02),
            shadowColor: Colors.transparent,
            leading: GestureDetector(
              onTap: () => _scaffoldKey.currentState!.openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(5.0),
                alignment: Alignment.center,
                child: GlassBox(
                  redius: 40.0,
                  width: 50,
                  height: 50,
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset("assets/svg/drawer_icon.svg"),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SlideAnimation(
                  position: 4,
                  itemCount: 8,
                  slideDirection: SlideDirection.fromBottom,
                  animationController: _animationController,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsetsDirectional.only(top: 10, start: 10, end: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      HRStrings.rosterText,
                                      style: const TextStyle(
                                        color: HRColors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                              roster(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        backgroundColor: Colors.white,
        drawerScrimColor: Colors.transparent,
        drawer: Drawer(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Material(
            color: Colors.transparent,
            child: DesignConfig.drawerContent(_scaffoldKey, context),
          ),
        ),
        body: SizedBox(width: double.infinity, child: data()),
      ),
    );
  }

  Widget roster() {
    final CalendarController c = CalendarController();
    const Color surface = Color.fromARGB(255, 248, 250, 252);

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              color: surface,
              child: SfCalendar(
                view: CalendarView.month,
                controller: c,
                viewNavigationMode: ViewNavigationMode.none,
                dataSource: MeetingDataSource(_getDataSource()),
                headerStyle: const CalendarHeaderStyle(backgroundColor: surface, textAlign: TextAlign.center),
                monthViewSettings: MonthViewSettings(
                  showTrailingAndLeadingDates: false,
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                  dayFormat: 'EEE',
                  agendaViewHeight: MediaQuery.of(context).size.height / 580,
                  showAgenda: true,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.40)),
          ],
        ),
      ),
    );
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].from;

  @override
  DateTime getEndTime(int index) => appointments![index].to;

  @override
  String getSubject(int index) => appointments![index].eventName;

  @override
  Color getColor(int index) => appointments![index].background;

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
