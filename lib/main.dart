import 'package:flutter/material.dart';

import 'Book.dart';
import 'Books.dart';
import 'ImageWidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Challenge'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<Book> books = Books().bookList;

  int index = 0;
  late AnimationController _controller;
  late Animation<double> curve;
  late Animation<Color?> _colorAnimationRed;
  late Animation<Color?> _colorAnimationGreen;
  late Animation<double?> _size;
  bool left = false;
  bool right = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 500),
      // Animation duration
    );

    curve = CurvedAnimation(parent: _controller, curve: Curves.easeInExpo);

    _colorAnimationRed =
        ColorTween(begin: Colors.transparent, end: Colors.red).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.10,
          curve: Curves.easeInExpo,
        ),
      ),
    );

    _colorAnimationGreen =
        ColorTween(begin: Colors.transparent, end: Colors.green).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.10,
          curve: Curves.easeInExpo,
        ),
      ),
    );

    _size = Tween<double>(
      begin: 450.0,
      end: 550.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.70,
          1.0,
          curve: Curves.ease,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double x = 0.0;
    // than having to individually change instances of widgets.
    return SafeArea(
      child: Scaffold(
        body: Stack(children: [
          Positioned(
              left: 50,
              child: right
                  ? AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 0,
                            bottom: 220,
                          ),
                          child: Container(
                            width: _size.value,
                            height: _size.value,
                            decoration: BoxDecoration(
                              color: _colorAnimationRed.value,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    )
                  : Container()),
          Positioned(
              right: 50,
              child: left
                  ? AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 0,
                            bottom: 220,
                          ),
                          child: Container(
                            width: _size.value,
                            height: _size.value,
                            decoration: BoxDecoration(
                              color: _colorAnimationGreen.value,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    )
                  : Container()),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 30,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.menu,
                    color: Colors.grey,
                  ),
                  Icon(Icons.album_rounded),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            bottom: 220,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Stack(children: [
                ImageWidget(books[3].img),
                ImageWidget(books[2].img),
                ImageWidget(books[1].img),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      debugPrint("is completed ${_controller.isCompleted}");
                      AnimationStatus status = _controller.status;
                      _controller.addListener(() {
                        if (_controller.isCompleted) {
                          _controller.reset();
                          setState(() {
                            Book first = books.first;
                            books.removeAt(0);
                            books.add(first);
                          });
                        }
                      });
                    },
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      debugPrint("drag ${details.delta.dx}");
                      if (details.delta.dx.isNegative) {
                        setState(() {
                          left = true;
                          right = false;
                        });
                      } else {
                        setState(() {
                          left = false;
                          right = true;
                        });
                      }
                      _controller.forward();
                    },
                    child: AnimatedBuilder(
                      animation: curve,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: left
                              ? Offset(curve.value * -360.0, 0.0)
                              : Offset(curve.value * 360.0, 0.0),
                          child: child,
                        );
                      },
                      child: ImageWidget(books.first.img),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        books[index].name,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        books[index].author,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(books[0].category,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
