import 'package:flutter/material.dart';
import 'package:flutter_application_2/util/emoticon_face.dart';
import 'package:flutter_application_2/util/exercise_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Home'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  // greeting row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Hey
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, Yagami',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '15 Sept 2025',
                            style: TextStyle(color: Colors.blue[200]),
                          ),
                        ],
                      ),

                      // notification
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.notifications, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  //searchbar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.white),
                        SizedBox(width: 5),
                        Text('Search', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),

                  //howdo you feel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'How do you feel?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Icon(Icons.more_horiz, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 25),

                  //differentface
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //bad
                      Column(
                        children: [
                          EmoticonFace(emoticonFace: '😵‍💫'),
                          SizedBox(height: 8),
                          Text('Bad', style: TextStyle(color: Colors.white)),
                        ],
                      ),

                      //fine
                      Column(
                        children: [
                          EmoticonFace(emoticonFace: '🙂'),
                          SizedBox(height: 8),
                          Text('Fine', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      //well
                      Column(
                        children: [
                          EmoticonFace(emoticonFace: '😐'),
                          SizedBox(height: 8),
                          Text('Well', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      //excellent
                      Column(
                        children: [
                          EmoticonFace(emoticonFace: '🤩'),
                          SizedBox(height: 8),
                          Text(
                            'Excellent',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(25),
                color: Colors.grey[100],
                child: Center(
                  child: Column(
                    children: [
                      // Exercise Heading
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Exercises',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Icon(Icons.more_horiz),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Listview of exercise
                      Expanded(
                        child: ListView(
                          children: [
                            ExerciseTile(
                              icon: Icons.favorite,
                              exerciseName: 'Speaking Skill',
                              numberOfEsxercise: 12,
                              color: Colors.orange,
                            ),
                            ExerciseTile(
                              icon: Icons.book,
                              exerciseName: 'Reading Skill',
                              numberOfEsxercise: 20,
                              color: Colors.blue,
                            ),
                            ExerciseTile(
                              icon: Icons.edit,
                              exerciseName: 'Writing Skill',
                              numberOfEsxercise: 15,
                              color: Colors.pink,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
