import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_map_location_picker/generated/l10n.dart'
    as location_picker;
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/bloc/theme_bloc.dart';
import 'package:flutter/services.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/module/translation_module.dart';
import 'package:hantarr/root_page_repo/ui/error_page.dart';
import 'package:hantarr/rootpage.dart';
import 'package:hantarr/route_setting/generated_route.dart';
import 'package:hantarr/route_setting/route_settings.dart';
import 'package:location/location.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2pTransaction_module.dart';
import 'utilities/overrider_http_cert.dart';

// ignore: unused_element
final _kShouldTestAsyncErrorOnInit = true;
// Toggle this for testing Crashlytics in your app locally.
// ignore: unused_element
final _kTestingCrashlytics = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  HttpOverrides.global = new MyHttpOverrides();
  Bloc.observer = SimpleBlocObserver();
  String languageString = await rootBundle.loadString('assets/lang.json');
  Map translations = jsonDecode(languageString);

  runZonedGuarded(() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(
        Phoenix(
          child: Translation(
            translations: translations,
            lang: "en",
            child: MyApp(),
          ),
        ),
      );
    });
  }, (error, stackTrace) {
    print('runZonedGuarded: Caught error in my root zone.');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics;
  Future onSelectNotification(String payload) async {
    print(payload);
    BotToast.showText(text: payload);
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    print(message);
    if (message.containsKey('data')) {
      // Handle data message
      // ignore: unused_local_variable
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      // ignore: unused_local_variable
      final dynamic notification = message['notification'];
    }

    // Or do other work.
    return null;
  }

  void eventlogger(var data) {
    print(data);
    if (data['event'] != null) {
      // FirebaseAnalytics().logEvent(name: data['event'], parameters: {});
      FirebaseInAppMessaging.instance.triggerEvent(data['event']);
    }
  }

  @override
  void initState() {
    analytics = FirebaseAnalytics.instance;
    themeBloc = ThemeBloc(ThemeBloc(ThemeData()).lightTheme);
    hantarrBloc = HantarrBloc(HantarrState.initial());
    setApp();
    setLanguage();
    getLocationPermission();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    hantarrBloc.state.flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
    hantarrBloc.state.flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: onSelectNotification);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      '1',
      'Task Notification',
      'Notification related to task',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    hantarrBloc.state.notificationDetails = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    hantarrBloc.add(Refresh());
    super.initState();
    hantarrBloc.state.fcm.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        try {
          print("onMessage: $message");
          var data = message.data;
          eventlogger(data);
          await hantarrBloc.state.flutterLocalNotificationsPlugin.show(
            DateTime.now().millisecond,
            message.notification.title,
            message.notification.body,
            hantarrBloc.state.notificationDetails,
          );
          await NewFoodDelivery().getPendingDelivery();
          await P2pTransaction().getPendingP2Ps();
        } catch (e) {
          print(e.toString());
        }
      }
    });

    // hantarrBloc.state.fcm.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     try {
    //       print("onMessage: $message");
    //       var data = message['data'];
    //       eventlogger(data);
    //       await hantarrBloc.state.flutterLocalNotificationsPlugin.show(
    //         DateTime.now().millisecond,
    //         Platform.isIOS
    //             ? message['aps']['alert']['title']
    //             : message['notification']['title'],
    //         Platform.isIOS
    //             ? message['aps']['alert']['body']
    //             : message['notification']['body'],
    //         hantarrBloc.state.notificationDetails,
    //       );
    //       // await Delivery().getPendingOrder();
    //       await NewFoodDelivery().getPendingDelivery();
    //       await P2pTransaction().getPendingP2Ps();
    //     } catch (e) {
    //       print(e.toString());
    //     }
    //   },
    //   onBackgroundMessage: myBackgroundMessageHandler,
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //     // await Delivery().getPendingOrder();
    //     await NewFoodDelivery().getPendingDelivery();
    //     await P2pTransaction().getPendingP2Ps();
    //     Map<String, dynamic> data = message['data'];
    //     eventlogger(data);
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");
    //     // await Delivery().getPendingOrder();
    //     await NewFoodDelivery().getPendingDelivery();
    //     await P2pTransaction().getPendingP2Ps();
    //     Map<String, dynamic> data = message['data'];
    //     eventlogger(data);
    //   },
    // );
  }

  setApp() async {
    hantarrBloc.state.app = await Firebase.initializeApp(
      name: 'hantarrUser${DateTime.now().millisecondsSinceEpoch}',
      options: Platform.isIOS || Platform.isMacOS
          ? FirebaseOptions(
              appId: '1:254489337322:ios:e33619263a945780e72693',
              apiKey: 'AIzaSyC8CLZq3p9O9UW9SrR4YRLU_6AloW8gRf0',
              projectId: 'str8-4b828',
              messagingSenderId: '254489337322',
              databaseURL: 'https://str8-4b828.firebaseio.com/',
            )
          : FirebaseOptions(
              appId: '1:254489337322:android:b5155972d51d4b9ce72693',
              apiKey: 'AIzaSyC8CLZq3p9O9UW9SrR4YRLU_6AloW8gRf0',
              messagingSenderId: '254489337322',
              projectId: 'str8-4b828',
              databaseURL: 'https://str8-4b828.firebaseio.com/',
            ),
    );
  }

  setLanguage() async {
    String value = await hantarrBloc.state.storage.read(
      key: "language",
    );
    if (value != null) {
      hantarrBloc.state.translation.lang = value;
      hantarrBloc.add(Refresh());
    }
  }

  getLocationPermission() async {
    var location = new Location();
    // LocationData currentLocation;
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      _permissionGranted = await Location().requestPermission();
    }
  }

  // for new development
  bool switchNew = true;
  @override
  Widget build(BuildContext context) {
    Translation translation =
        context.dependOnInheritedWidgetOfExactType<Translation>();
    hantarrBloc.state.translation = translation;
    return MultiBlocProvider(
      providers: [
        BlocProvider<HantarrBloc>(
          create: (BuildContext context) => hantarrBloc,
        ),
        BlocProvider<ThemeBloc>(
          create: (BuildContext context) => themeBloc,
        ),
      ],
      child: !switchNew
          ? MaterialApp(
              title: 'Hantarr',
              builder: BotToastInit(), //1. call BotToastInit
              navigatorObservers: [
                BotToastNavigatorObserver(),
              ],
              theme: ThemeData(
                primarySwatch: Colors.orange,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              home: Rootpage(),
            )
          : MaterialApp(
              title: 'Hantarr Delivery',
              builder: BotToastInit(), //1. call BotToastInit
              navigatorObservers: [
                BotToastNavigatorObserver(),
                NavigationHistoryObserver(),
                FirebaseAnalyticsObserver(analytics: analytics)
              ],
              theme: themeBloc.state,
              // routes: routes,
              onGenerateRoute: generateRoute,
              initialRoute: initialRoute,
              onUnknownRoute: (settings) => MaterialPageRoute(
                builder: (context) => ErrorPage(
                    // name: settings.name,
                    ),
              ),
              localizationsDelegates: const [
                location_picker.S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const <Locale>[
                Locale('en', ''),
                Locale('ar', ''),
                Locale('pt', ''),
                Locale('tr', ''),
                Locale('es', ''),
                Locale('it', ''),
                Locale('ru', ''),
              ],
            ),
    );
    // return BlocProvider(
    //   create: (_) => hantarrBloc,
    //   child: !switchNew
    //       ? MaterialApp(
    //           title: 'Hantarr', builder: BotToastInit(), //1. call BotToastInit
    //           navigatorObservers: [
    //             BotToastNavigatorObserver(),
    //             NavigationHistoryObserver(),
    //           ],
    //           theme: ThemeData(
    //             primarySwatch: Colors.orange,
    //             visualDensity: VisualDensity.adaptivePlatformDensity,
    //           ),
    //           routes: routes,
    //           initialRoute: initialRoute,
    //         )
    //       : MaterialApp(
    //           title: 'Hantarr Delivery',
    //           builder: BotToastInit(), //1. call BotToastInit
    //           navigatorObservers: [
    //             BotToastNavigatorObserver(),
    //             NavigationHistoryObserver(),
    //           ],
    //           theme: themeBloc.state,
    //           routes: routes,
    //           initialRoute: initialRoute,
    //         ),
    // );
  }
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- ${bloc.runtimeType}');
  }
}
