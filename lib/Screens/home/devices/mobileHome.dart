import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localstorage/localstorage.dart'; 
import 'package:octo_image/octo_image.dart';
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
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({Key? key}) : super(key: key);

  @override
  _MobileHomeState createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  AnimationController? _animationController;
  PageController? _controller;
  CarouselController buttonCarouselController = CarouselController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String morningBg =
      "https://www.farmersalmanac.com/wp-content/uploads/2020/11/Earliest-Sunrise-June-A191879830.jpg";

  String afternoonBg =
        "https://www.farmersalmanac.com/wp-content/uploads/2020/11/Earliest-Sunrise-June-A191879830.jpg";

  String eveningBg =
      "https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/sunset-quotes-21-1586531574.jpg";

  String nightBg = "https://wallpaperaccess.com/full/2113857.jpg";

  late String bgImg;
  String? _dateTime;
  late Timer _timer;
  late String checking = "CHECK-IN";
  final DateTime now = DateTime.now();
  LocalStorage storage = LocalStorage('pocketHR');
  APIService apiService = APIService();
  HRController controller = HRController();
  bool _pressingCheckIn = false;
  bool _pressingCheckOut = false;
  // Top toast overlay
  void showTopToast(String message, {Color? background, Duration duration = const Duration(seconds: 3), VoidCallback? onTap}) {
    final overlay = Overlay.of(context);

    final animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    final animation = CurvedAnimation(parent: animController, curve: Curves.easeOut);

    late OverlayEntry entry;
    entry = OverlayEntry(builder: (ctx) {
      return Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 12,
        right: 12,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(animation),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                try { animController.reverse(); } catch (_) {}
                try { entry.remove(); } catch (_) {}
                try { animController.dispose(); } catch (_) {}
                if (onTap != null) onTap();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: background ?? const Color(0xFF323232),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(message, style: const TextStyle(color: Colors.white), maxLines: 3, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });

    overlay.insert(entry);
    animController.forward();

    Future.delayed(duration, () async {
      try { await animController.reverse(); } catch (_) {}
      try { entry.remove(); } catch (_) {}
      try { animController.dispose(); } catch (_) {}
    });
  }
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    getLocation();
    // changeBTN();
    _controller = PageController(initialPage: 0);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _timer = new Timer.periodic(Duration(seconds: 1), (Timer t) => getTime());
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1400));
  }

  @override
  void dispose() {
    _timer.cancel();
    streamSubscription.cancel();
    _animationController!.dispose();
    super.dispose();
  }

  getTime() {
    String languageCode = Localizations.localeOf(context).languageCode;
    String formattedDateTime = "";
    String suffix = 'th';
    final int digit = now.day % 10;
    if ((digit > 0 && digit < 4) && (now.day < 11 || now.day > 13)) {
      suffix = <String>['st', 'nd', 'rd'][digit - 1];
    }

    if (languageCode == 'si' || languageCode == 'ta') {
      formattedDateTime = DateFormat("dd MMM yyyy - kk:mm:ss", languageCode)
          .format(DateTime.now())
          .toString();
    } else {
      formattedDateTime =
          DateFormat("d'$suffix' MMM yyyy - kk:mm:ss", languageCode)
              .format(DateTime.now())
              .toString();
    }

    setState(() {
      _dateTime = formattedDateTime;
    });
  }

  checkinCheckout(type) async {

    DateTime getCurrentTimestamp = DateTime.now();
    String date = controller.formatISOTime(getCurrentTimestamp);
    final lat = (latitude != null) ? latitude.toString() : null;
    final lng = (longitude != null) ? longitude.toString() : null;
    final addr = (address != null) ? address.toString() : null;

    final res = await apiService.checkInCheckout(
      date,
      type,
      latitude: lat,
      longitude: lng,
      address: addr,
    );

    String msg = '';
    Color bg = Colors.black;
    if (res is Map && res.containsKey('message')) {
      msg = res['message']?.toString() ?? '';
      bg = (type == 'checkout') ? HRColors.orangeColor : Colors.green;
    } else if (res == null) {
      msg = 'Failed to perform action';
      bg = Colors.red;
    } else {
      msg = 'Success';
      bg = (type == 'checkout') ? HRColors.orangeColor : Colors.green;
    }

    if (mounted) showTopToast(msg, background: bg);
  }

  changeBTN() {
    if (storage.getItem('checking')) {
      checking = "CHECK-OUT";
    } else {
      checking = "CHECK-IN";
    }
  }

  setBgImage() {
    var hours = DateTime.now().hour;
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

  var latitude;
  var longitude;
  var address;
  late StreamSubscription<Position> streamSubscription;

  getLocation() async {
    bool serviceEnabled;

    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      latitude = position.latitude;
      longitude = position.longitude;
      getAddressFromLatLang(position);
    });
  }

  Future<void> getAddressFromLatLang(Position position) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemark[0];

    address = '${place.street}, ${place.locality}';
  }

  Widget slider() {
    return Container(
      height: MediaQuery.of(context).size.height / 1.9,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: 1,
            onPageChanged: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (_, i) {
              return GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40))),
                    child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40)),
                        child: OctoImage(
                          image: CachedNetworkImageProvider(setBgImage()),
                          placeholderBuilder: OctoBlurHashFix.placeHolder(
                            sliderList[i].blurUrl!,
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          errorBuilder: OctoError.icon(color: HRColors.black),
                          fit: BoxFit.cover,
                        )),
                  ),
                  onTap: () {});
            },
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5.2,
            margin: EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: MediaQuery.of(context).size.height * .318),
            child: SlideAnimation(
              position: 4,
              itemCount: 8,
              slideDirection: SlideDirection.fromTop,
              animationController: _animationController,
              child: Container(
                child: GlassBox(
                  redius: 40.0,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 5.2,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: EdgeInsets.only(top: 15.0),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      _dateTime ?? "loading...",
                                      style: TextStyle(
                                          color: HRColors.black,
                                          fontSize: 25,
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: SingleChildScrollView(
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 20.0, top: 1.0),
                                        child: Text(
                                          address ?? "loading...",
                                          style: TextStyle(
                                              color: HRColors.black,
                                              fontSize: 15),
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
                            padding: EdgeInsets.only(top: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTapDown: (_) => setState(() => _pressingCheckIn = true),
                                  onTapUp: (_) {
                                    setState(() => _pressingCheckIn = false);
                                    checkinCheckout('checkin');
                                  },
                                  onTapCancel: () => setState(() => _pressingCheckIn = false),
                                  child: AnimatedScale(
                                    scale: _pressingCheckIn ? 0.96 : 1.0,
                                    duration: const Duration(milliseconds: 120),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 160),
                                      curve: Curves.easeOut,
                                      height: 50,
                                      width: MediaQuery.of(context).size.width / 2.5,
                                      margin: const EdgeInsets.only(left: 20.0),
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [HRColors.blueColor, HRColors.blueColor], begin: Alignment.centerLeft, end: Alignment.centerRight),
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                                        boxShadow: _pressingCheckIn ? [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))] : [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,6))],
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text('CHECK-IN', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20)),
                                          SizedBox(width: 6),
                                          Icon(Icons.input, color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTapDown: (_) => setState(() => _pressingCheckOut = true),
                                  onTapUp: (_) {
                                    setState(() => _pressingCheckOut = false);
                                    checkinCheckout('checkout');
                                  },
                                  onTapCancel: () => setState(() => _pressingCheckOut = false),
                                  child: AnimatedScale(
                                    scale: _pressingCheckOut ? 0.96 : 1.0,
                                    duration: const Duration(milliseconds: 120),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 160),
                                      curve: Curves.easeOut,
                                      height: 50,
                                      width: MediaQuery.of(context).size.width / 2.5,
                                      margin: const EdgeInsets.only(left: 5.0),
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [HRColors.orangeColor, HRColors.orangeColor], begin: Alignment.centerLeft, end: Alignment.centerRight),
                                        borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                                        boxShadow: _pressingCheckOut ? [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))] : [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,6))],
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text('CHECK-OUT', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20)),
                                          SizedBox(width: 6),
                                          Icon(Icons.output, color: Colors.white),
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
          )
        ],
      ),
    );
  }

  Widget data() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          snap: false,
          pinned: true,
          floating: false,
          flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "",
                style:
                    TextStyle(color: HRColors.white, fontSize: 0), //TextStyle
              ), //Text
              background: Stack(children: [
                slider(),
              ])),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, HRNotifications.routeName);
              },
              child: Container(
                padding: EdgeInsets.all(5.0),
                alignment: Alignment.center,
                child: GlassBox(
                  redius: 40.0,
                  width: 50,
                  height: 50,
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child:
                          SvgPicture.asset("assets/svg/notifications_icon.svg"),
                    ),
                  ),
                ),
              ),
            ), //IconButton//IconButton
          ], //FlexibleSpaceBar
          expandedHeight: MediaQuery.of(context).size.height / 2,
          backgroundColor: Colors.transparent.withOpacity(0.02),
          shadowColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            child: Container(
              padding: EdgeInsets.all(5.0),
              alignment: Alignment.center,
              child: GlassBox(
                redius: 40.0,
                width: 50,
                height: 50,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: SvgPicture.asset("assets/svg/drawer_icon.svg"),
                  ),
                ),
              ),
            ),
          ), //IconButton
        ),
        //SliverAppBar
        SliverList(
          delegate: SliverChildListDelegate(
            [
              SlideAnimation(
                position: 4,
                itemCount: 8,
                slideDirection: SlideDirection.fromBottom,
                animationController: _animationController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                          top: 10, start: 10, end: 10),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  HRStrings.rosterText,
                                  style: TextStyle(
                                      color: HRColors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                              Spacer(), // Defaults to a flex of one.
                            ]),
                            roster()
                          ]),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ], //<Widget>[]
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
        child: DesignConfig.drawerContent(_scaffoldKey, context),
      ),
        body: Container(
          width: double.infinity,
          child: data(),
        ),
      ),
    );
  }

  Future<void> navigationPage() async {
    Navigator.pop(context);
  }

  Widget roster() {
    final CalendarController _controller = CalendarController();

    const Color _surface = Color.fromARGB(255, 248, 250, 252);

    return GestureDetector(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              color: _surface,
              child: SfCalendar(
                view: CalendarView.month,
                controller: _controller,
                viewNavigationMode: ViewNavigationMode.none,
                dataSource: MeetingDataSource(_getDataSource()),
                headerStyle: const CalendarHeaderStyle(backgroundColor: _surface, textAlign: TextAlign.center),
                monthViewSettings: MonthViewSettings(
                  showTrailingAndLeadingDates: false,
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment,
                  dayFormat: 'EEE',
                  agendaViewHeight: MediaQuery.of(context).size.height / 580,
                  showAgenda: true,
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.40))
          ],
        ),
      ),
    );
  }



  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    // final DateTime today = DateTime.now();
    // final DateTime startTime =
    //     DateTime(today.year, today.month, today.day + 1, 9, 0, 0);
    // final DateTime endTime = startTime.add(const Duration(hours: 2));
    // meetings.add(
    //     Meeting('AAA', startTime, endTime, const Color(0xFF0F8644), false));
    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
