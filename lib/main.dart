import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🟢 Fullscreen mode untuk iPhone
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // 🔒 Kunci orientasi ke landscape
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } catch (e) {
    print('Error setting system UI: $e');
  }

  runApp(const ZTimeApp());
}

class ZTimeApp extends StatelessWidget {
  const ZTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZClock',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.orbitronTextTheme(),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.orbitronTextTheme(),
      ),
      home: const ClockScreen(),
    );
  }
}

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late DateTime _currentTime;
  late Timer _timer;
  bool _isDarkMode = true;
  bool _showClock = true;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable().catchError((_) {});
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  String _getHour12Format(DateTime dt) {
    int hour = dt.hour % 12;
    if (hour == 0) hour = 12;
    return hour.toString().padLeft(2, '0');
  }

  String _getMinute(DateTime dt) => dt.minute.toString().padLeft(2, '0');
  String get _amPm => _currentTime.hour >= 12 ? "PM" : "AM";

  String get _monthName {
    const months = [
      "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
      "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER",
    ];
    return months[_currentTime.month - 1];
  }

  String get _day => _currentTime.day.toString().padLeft(2, '0');
  String get _year => _currentTime.year.toString();

  Widget _buildAnimatedDigit(String digit, double fontSize, Color color) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        final rotate = Tween(begin: 1.0, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            final angle = rotate.value * 3.1416 / 2;
            return Transform(
              transform: Matrix4.rotationX(angle),
              alignment: Alignment.center,
              child: child,
            );
          },
        );
      },
      child: Text(
        digit,
        key: ValueKey(digit),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: color,
          shadows: [
            Shadow(
              blurRadius: 20,
              color: color.withOpacity(0.5),
              offset: const Offset(0, 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePair(String value, double fontSize, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedDigit(value[0], fontSize, color),
        _buildAnimatedDigit(value[1], fontSize, color),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String hour = _getHour12Format(_currentTime);
    final String minute = _getMinute(_currentTime);
    final Color mainColor =
        _isDarkMode ? Colors.white : Colors.black.withOpacity(0.9);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    double scale = 1.0;
    double clockScale = 1.2;

    if (screenWidth < 400 || screenHeight < 700) {
      scale = 0.75;
      clockScale = 1.0;
    } else if (screenWidth < 450) {
      scale = 0.85;
      clockScale = 1.1;
    } else if (screenWidth < 500) {
      scale = 0.95;
      clockScale = 1.15;
    }

    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
      body: GestureDetector(
        onDoubleTap: () => setState(() => _showClock = !_showClock),
        onLongPress: () => setState(() => _isDarkMode = !_isDarkMode),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double baseSize =
                (constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth * 0.5
                        : constraints.maxHeight * 0.5) *
                    clockScale;

            final double dateBaseSize =
                (constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth * 0.5
                        : constraints.maxHeight * 0.5) *
                    scale;

            return Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: _showClock
                    ? FittedBox(
                        fit: BoxFit.scaleDown,
                        key: const ValueKey("clock"),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment:
                              CrossAxisAlignment.center, // ✅ center vertikal
                          children: [
                            _buildTimePair(hour, baseSize, mainColor),
                            AnimatedOpacity(
                              opacity:
                                  _currentTime.second % 2 == 0 ? 1.0 : 0.2,
                              duration:
                                  const Duration(milliseconds: 500),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12 * scale,
                                ),
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                    fontSize: baseSize * 1.1,
                                    fontWeight: FontWeight.w900,
                                    color: mainColor.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ),
                            _buildTimePair(minute, baseSize, mainColor),
                            Padding(
                              padding: EdgeInsets.only(
                                left: baseSize * 0.1,
                                top: baseSize * 0.05, // ✅ naikkan sedikit
                              ),
                              child: Text(
                                _amPm,
                                style: TextStyle(
                                  fontSize: baseSize * 0.25,
                                  fontWeight: FontWeight.w600,
                                  color: mainColor.withOpacity(0.85),
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        key: const ValueKey("date"),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _day,
                            style: TextStyle(
                              fontSize: dateBaseSize * 1.2,
                              fontWeight: FontWeight.w900,
                              color: mainColor,
                              height: 0.9,
                              shadows: [
                                Shadow(
                                  blurRadius: 25,
                                  color: mainColor.withOpacity(0.5),
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10 * scale),
                          Text(
                            _monthName,
                            style: TextStyle(
                              fontSize: dateBaseSize * 0.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 10 * scale,
                              color: mainColor.withOpacity(0.9),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 15 * scale),
                            width: dateBaseSize * 0.8,
                            height: 2,
                            color: mainColor.withOpacity(0.5),
                          ),
                          Text(
                            _year,
                            style: TextStyle(
                              fontSize: dateBaseSize * 0.5,
                              fontWeight: FontWeight.w600,
                              color: mainColor.withOpacity(0.8),
                              letterSpacing: 8 * scale,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
