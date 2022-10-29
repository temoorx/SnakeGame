import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/blank_pixel.dart';
import 'package:snake_game/highscore_tile.dart';
import 'package:snake_game/snake_pixel.dart';

import 'food_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // game settings
  bool gameHasStarted = false;
  final _nameController = TextEditingController();

  //grid dimensions
  int rowSize = 10;
  int totalGrids = 100;

// user score
  int currentScore = 0;

  // snake position
  List<int> snakePos = [0, 1, 2];

  // snake direction is intially right
  var currentDirection = snake_Direction.RIGHT;
  // food position

  int foodPos = 55;
//high scores list
  List<String> highscores_DocIds = [];
  late final Future? letgetDocids;

  @override
  void initState() {
    letgetDocids = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('highscores')
        .orderBy("scores", descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscores_DocIds.add(element.reference.id);
            }));
  }

  // start the game
  void StartGame() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        // snake movement
        MoveSnake();
//check if the game is over
        if (gameOver()) {
          timer.cancel();
          //show the gamover alert!
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Game Over!"),
                  content: Column(
                    children: [
                      Text("Your Score is " + currentScore.toString()),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(hintText: 'Enter name'),
                      ),
                    ],
                  ),
                  actions: [
                    MaterialButton(
                        child: Text('Submit'),
                        color: Colors.pink,
                        onPressed: (() {
                          Navigator.pop(context);
                          submitScore();
                          newGame();
                        }))
                  ],
                );
              });
        }
      });
    });
  }

  //submit scores
  void submitScore() {
    //get access to the collection
    var database = FirebaseFirestore.instance;

    //add data to firebase
    database.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

//new game
  Future newGame() async {
    highscores_DocIds = [];
    await getDocId();
    setState(() {
      snakePos = [0, 1, 2];
      foodPos = 55;
      currentDirection = snake_Direction.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore++;
    // it will make sure to randomize the food position
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalGrids);
    }
  }

  void MoveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          if (snakePos.last % rowSize == 9) {
            // add a head
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            // add a head
            snakePos.add(snakePos.last + 1);
          }
        }

        break;
      case snake_Direction.LEFT:
        {
          if (snakePos.last % rowSize == 0) {
            // add a head
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            // add a head
            snakePos.add(snakePos.last - 1);
          }
        }
        break;
      case snake_Direction.UP:
        {
          // add a head
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalGrids);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;
      case snake_Direction.DOWN:
        {
          // add a head
          if (snakePos.last + rowSize > totalGrids) {
            snakePos.add(snakePos.last + rowSize - totalGrids);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;
      default:
    }
    // snake is eating food
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      // remove the tail
      snakePos.removeAt(0);
    }
  }

//game over
  bool gameOver() {
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);
    if (bodySnake.contains(snakePos.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
              currentDirection != snake_Direction.UP) {
            currentDirection = snake_Direction.DOWN;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
              currentDirection != snake_Direction.DOWN) {
            currentDirection = snake_Direction.UP;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
              currentDirection != snake_Direction.RIGHT) {
            currentDirection = snake_Direction.LEFT;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
              currentDirection != snake_Direction.LEFT) {
            currentDirection = snake_Direction.RIGHT;
          }
        },
        child: SizedBox(
          width: screenWidth > 428 ? 428 : screenWidth,
          child: Column(
            children: [
              // for the high scores
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Current Score'),
                      Text(
                        currentScore.toString(),
                        style: TextStyle(fontSize: 36),
                      ),
                    ],
                  ),
                  //highscores
                  Expanded(
                    child: gameHasStarted
                        ? Text('High Scores..')
                        : FutureBuilder(
                            future: letgetDocids,
                            builder: (context, snapshot) {
                              return ListView.builder(
                                  itemCount: highscores_DocIds.length,
                                  itemBuilder: ((context, index) {
                                    return HighScoreTile(
                                        documentId: highscores_DocIds[index]);
                                  }));
                            }),
                  )
                ],
                // game grid
              )),
              Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.delta.dy > 0 &&
                          currentDirection != snake_Direction.UP) {
                        currentDirection = snake_Direction.DOWN;
                      } else if (details.delta.dy < 0 &&
                          currentDirection != snake_Direction.DOWN) {
                        currentDirection = snake_Direction.UP;
                      }
                    },
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx > 0 &&
                          currentDirection != snake_Direction.LEFT) {
                        currentDirection = snake_Direction.RIGHT;
                      } else if (details.delta.dx < 0 &&
                          currentDirection != snake_Direction.RIGHT) {
                        currentDirection = snake_Direction.LEFT;
                      }
                    },
                    child: GridView.builder(
                        itemCount: totalGrids,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: rowSize),
                        itemBuilder: (context, index) {
                          if (snakePos.contains(index)) {
                            return SnakePixel();
                          } else if (foodPos == index) {
                            return FoodPixel();
                          } else {
                            return BlankPixel();
                          }
                        }),
                  )),
              Expanded(
                  child: Container(
                child: Center(
                    child: MaterialButton(
                  onPressed: gameHasStarted ? () {} : StartGame,
                  color: gameHasStarted ? Colors.grey : Colors.pink,
                  child: Text("PLAY"),
                )),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
