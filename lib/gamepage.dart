import 'dart:async';
import 'dart:math';

import 'HomePage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balloon Poppers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score = 0;
  int balloonsPopped = 0;
  int balloonsMissed = 0;
  int gameTimeInSeconds = 120;

  List<Balloon> balloons = [];

  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    gameTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (gameTimeInSeconds > 0) {
        setState(() {
          gameTimeInSeconds--;
        });
        generateBalloon();
      } else {
        endGame();
      }
    });
  }

  void generateBalloon() {
    Random random = Random();
    double randomX =
        random.nextDouble() * (MediaQuery.of(context).size.width - 50);
    balloons.add(Balloon(
      key: UniqueKey(),
      xPosition: randomX,
      onTap: () {
        setState(() {
          score += 2;
          balloonsPopped++;
        });
      },
      onMissed: () {
        setState(() {
          score -= 1;
          balloonsMissed++;
        });
      },
    ));
  }

  void endGame() {
    gameTimer?.cancel();
    // Display final score on the screen
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Column(
            children: [
              Text('Balloons Popped: $balloonsPopped'),
              Text('Balloons Missed: $balloonsMissed'),
              Text('Your Final Score: $score'),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => HomePage(),
                    ),
                  );
                },
                child: Text('Home Page'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  restartGame();
                },
                child: Text('Play Again'),
              ),
            ],
          ),
        );
      },
    );
  }

  void restartGame() {
    setState(() {
      score = 0;
      balloonsPopped = 0;
      balloonsMissed = 0;
      gameTimeInSeconds = 120; // Reset to the initial time
      balloons.clear();
    });
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BALLOON POPPERS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/mXD4mv.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Game background or other elements can be added here

            // Balloons
            ...balloons,

            // UI Elements
            Positioned(
              top: 20,
              left: 10,
              child: Text(
                'Balloons Popped: $balloonsPopped',
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
            ),
            Positioned(
              top: 20,
              right: 10,
              child: Text(
                'Balloons Missed: $balloonsMissed',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
            Positioned(
              top: 20,
              left: MediaQuery.of(context).size.width / 2 - 50,
              child: Text(
                'Time: ${gameTimeInSeconds ~/ 60}:${(gameTimeInSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Positioned(
              top: 50,
              left: MediaQuery.of(context).size.width / 2 - 50,
              child: Text(
                'Score: $score',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width / 2 - 50,
              child: ElevatedButton(
                onPressed: () {
                  // Restart game logic
                  setState(() {
                    score = 0;
                    balloonsPopped = 0;
                    balloonsMissed = 0;
                    gameTimeInSeconds = 120;
                    balloons.clear();
                    startGame();
                  });
                },
                child: Text('Play Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Balloon extends StatefulWidget {
  final double xPosition;
  final VoidCallback onTap;
  final VoidCallback onMissed;

  const Balloon({
    Key? key,
    required this.xPosition,
    required this.onTap,
    required this.onMissed,
  }) : super(key: key);

  @override
  _BalloonState createState() => _BalloonState();
}

class _BalloonState extends State<Balloon> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  bool isPopped = false;

  List<String> balloonImages = [
    'assets/balloon1.png',
    'assets/balloon2.png',
    'assets/balloon3.png',
    'assets/balloon4.png',
    'assets/balloon5.png'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 10), // Increase the duration for slower speed
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, -1),
    ).animate(_controller);
    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !isPopped) {
        // Increase missed count when the balloon reaches the top without getting popped
        widget.onMissed();
        _controller.dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return isPopped
            ? Container() // Return an empty container when popped
            : Positioned(
                top: MediaQuery.of(context).size.height * _animation.value.dy,
                left: widget.xPosition,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isPopped = true;
                    });
                    // Increase popped count when the balloon is popped
                    widget.onTap();
                  },
                  child: Image.asset(
                    balloonImages[
                        widget.xPosition.toInt() % balloonImages.length],
                    width: 80,
                    height: 100,
                  ),
                ),
              );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}