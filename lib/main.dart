import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

final webViewKey = GlobalKey<_SoftXWebViewState>();

void main() => runApp(SoftXApp());

class SoftXApp extends StatefulWidget {
  @override
  _SoftXAppState createState() => _SoftXAppState();
}

class _SoftXAppState extends State<SoftXApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBar(
//              backgroundColor: Color.fromRGBO(13, 202, 120, 1),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: IconButton(
                color: Colors.blueGrey,
                onPressed: () {
                  webViewKey.currentState?.goToHome();
                },
                icon: Icon(Icons.home),
              ),
              leading: IconButton(
                  color: Colors.blueGrey,
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    webViewKey.currentState?.goOneStepBack();
                  }),
              actions: <Widget>[
                IconButton(
                  color: Colors.blueGrey,
                  icon: Icon(Icons.refresh),
                  onPressed: () {
//                    print('User pressed the button');
                    webViewKey.currentState?.reloadWebView();
                  },
                ),
              ],
            ),
          ),
          body: WillPopScope(
            onWillPop: popped,
            child: SoftXWebView(key: webViewKey),
          ),
        ),
      ),
    );
  }

  DateTime currentTime;

  Future<bool> popped() async {
    // get current time
    DateTime now = DateTime.now();

    // backbutton pressed time difference either zero or 3 seconds

    bool backbutton = currentTime == null ||
        now.difference(currentTime) > Duration(seconds: 2);
    if (backbutton) {
      currentTime = now;
      Fluttertoast.showToast(
          msg: 'Tap again to exit',
          backgroundColor: Colors.teal,
          textColor: Colors.white);
      return Future.value(false);
    } else {
      Fluttertoast.cancel();
      return Future.value(true);
    }
  }
}

class SoftXWebView extends StatefulWidget {
  SoftXWebView({Key key}) : super(key: key);

  @override
  _SoftXWebViewState createState() => _SoftXWebViewState();
}

class _SoftXWebViewState extends State<SoftXWebView> {
// Home Url
  final String selectedUrl = 'https://softx.app';

//  var screenSize = MediaQuery.of(context).size;

  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

//  Future<WebViewController> _webViewControllerFuture;
  WebViewController _webViewController;
  double webViewContainerHeight = 600;

  // variables to make stacked indexes for widgets
  num position = 1;

// keys will make sure each time we use loads it will generate a new screen
  final key = UniqueKey();

  // this function will make the loader disappear by pushing it behind the webview
  Future<void> doneLoading(String A) async {
    double height = double.parse(await _webViewController
        .evaluateJavascript('document.documentElement.scrollHeight;'));
    setState(() {
      position = 0;
      webViewContainerHeight = height;
    });
  }

  void startLoading(String A) {
    setState(() {
      position = 1;
    });
  }

  cannotLoad() {
    setState(() {
      position = 2;
    });
  }

  goToHome() {
    _webViewController?.loadUrl('$selectedUrl');
  }

  reloadWebView() {
    _webViewController?.reload();
  }

  goOneStepBack() {
    _webViewController?.goBack();
  }

  Future<Null> reloadOnRefresh() {
    goToHome();
    return null;
  }

  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await reloadOnRefresh();
      },
      key: refreshKey,
      child: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: <Widget>[
          Container(
            height: webViewContainerHeight,
            child: WebView(
              initialUrl: '$selectedUrl',
              javascriptMode: JavascriptMode.unrestricted,
              onPageStarted: startLoading,
              onPageFinished: doneLoading,
              onWebResourceError: cannotLoad(),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }
}
