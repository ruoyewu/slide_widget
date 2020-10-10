import 'package:flutter/material.dart';
import 'package:slide_widget/slide_widget.dart';
import 'package:slide_widget/slide_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title),),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return SlideWidget(
            child: Container(
              color: Colors.red,
              child: SizedBox(
                height: 100,
                child: ListTile(
                  title: Text('item $index'),
                ),
              ),
            ),
            leading: <SlideItem>[
              SlideItem(
                color: Colors.blue,
                size: Size(100, 100),
                child: Text('leading')
              ),
              SlideItem(
                color: Colors.green,
                size: Size(100, 100),
                child: Text('leading')
              )
            ],
            trailing: <SlideItem>[
              SlideItem(
                color: Colors.grey,
                size: Size(100, 100),
                child: Align(alignment: Alignment.centerLeft,child: Text('trailing')),
              ),
              SlideItem(
                color: Colors.cyan,
                size: Size(100, 100),
                child: GestureDetector(
                  onTap: () {
                    print('click icon');
                  },
                  child: Center(
                    child: Icon(Icons.ac_unit, size: 60,),
                  ),
                ),
              )
            ],
          );
      }),
    );
  }
}
