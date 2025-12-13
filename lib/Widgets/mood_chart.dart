// lib/widgets/mood_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/mood_entry.dart'; // Додано

class MoodChart extends StatelessWidget {
  final List<MoodEntry> entries; // Змінено тип

  const MoodChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    int good = entries.where((e) => e.mood == "Добрий").length; // Оновлено
    int normal = entries.where((e) => e.mood == "Нормальний").length; // Оновлено
    int bad = entries.where((e) => e.mood == "Поганий").length; // Оновлено

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Статистика настрою", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                        switch (v.toInt()) {
                          case 0:
                            return const Text("Добрий");
                          case 1:
                            return const Text("Нормальний");
                          case 2:
                            return const Text("Поганий");
                        }
                        return const Text("");
                      }),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: good.toDouble(), color: Colors.green)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: normal.toDouble(), color: Colors.orange)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: bad.toDouble(), color: Colors.red)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}