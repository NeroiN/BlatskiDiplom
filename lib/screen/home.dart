import 'package:flutter/material.dart';

class HomeScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final squareBlockSize =
        (screenWidth - 40) / 3; // Ширина квадратного блока (с учетом отступов)

    return Scaffold(
      appBar: AppBar(title: Text('Домашний экран')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Большой горизонтальный блок
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Большой горизонтальный блок',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Три квадратных блока в ряд
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Квадратный блок 1
                Container(
                  width: squareBlockSize,
                  height: squareBlockSize,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Квадрат 1',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                // Квадратный блок 2
                Container(
                  width: squareBlockSize,
                  height: squareBlockSize,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Квадрат 2',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                // Квадратный блок 3
                Container(
                  width: squareBlockSize,
                  height: squareBlockSize,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Квадрат 3',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
