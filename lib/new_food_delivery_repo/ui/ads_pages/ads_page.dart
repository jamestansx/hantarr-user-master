import 'package:hantarr/packageUrl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AdsPage extends StatefulWidget {
  @override
  _AdsPageState createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {
  PageController pageController;

  @override
  void initState() {
    pageController = PageController(
      initialPage: 0,
    );
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Container(
          width: mediaQ.width,
          height: mediaQ.height * .8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: PageView(
                  controller: pageController,
                  children: hantarrBloc.state.advertisements.map(
                    (e) {
                      return MaterialButton(
                        onPressed: () {
                          if (e.path.isNotEmpty) {
                            Navigator.popAndPushNamed(context, e.path);
                          }
                        },
                        padding: EdgeInsets.zero,
                        child: Container(
                          width: mediaQ.width,
                          padding: EdgeInsets.all(15.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  trailing: IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(
                                      Icons.cancel,
                                      color: themeBloc.state.primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    "${e.name}",
                                    style: themeBloc.state.textTheme.headline6
                                        .copyWith(
                                      inherit: true,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[850],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 25),
                                Container(
                                  width: mediaQ.width,
                                  height: mediaQ.height * .5,
                                  child: Image.network(
                                    "${e.imgUrl}",
                                  ),
                                ),
                                SizedBox(height: 25),
                                Text(
                                  "${e.desc}",
                                  style: themeBloc.state.textTheme.bodyText1
                                      .copyWith(
                                    inherit: true,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[850],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 15),
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: hantarrBloc.state.advertisements.length,
                  effect: ScrollingDotsEffect(
                    activeStrokeWidth: 2.6,
                    activeDotScale: .4,
                    radius: 8,
                    spacing: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
