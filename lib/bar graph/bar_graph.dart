// ignore_for_file: prefer_const_constructors

import 'package:expense_tracker/bar%20graph/individual_bar_graph.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;

  const MyBarGraph(
      {super.key, required this.monthlySummary, required this.startMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  List<IndividualBarGraph> barData = [];

  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBarGraph(x: index, y: widget.monthlySummary[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeBarData();

    double barWidth = 20;
    double spaceBetweenBars = 15;

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 100,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
                sideTitles: SideTitles(
              showTitles: false,
              getTitlesWidget: getBottomTitles,
              reservedSize: 24,
            ))),
        barGroups: barData
            .map(
              (data) => BarChartGroupData(
                x: data.x,
                barRods: [
                  BarChartRodData(
                    toY: data.y,
                    width: barWidth,
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade800,
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

Widget getBottomTitles(double value, TitleMeta meta) {
  const textStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  String text;
  switch (value.toInt() % 12) {
    case 0:
      text = 'J';
      break;
    case 1:
      text = 'F';
      break;
    case 2:
      text = 'M';
      break;
    case 3:
      text = 'A';
      break;
    case 4:
      text = 'M';
      break;
    case 5:
      text = 'J';
      break;
    case 6:
      text = 'J';
      break;
    case 7:
      text = 'A';
      break;
    case 8:
      text = 'S';
      break;
    case 9:
      text = 'O';
      break;
    case 10:
      text = 'N';
      break;
    case 11:
      text = 'D';
      break;

    default:
      text = '';
      break;
  }
  return SideTitleWidget(
      child: Text(
        text,
        style: textStyle,
      ),
      axisSide: meta.axisSide);
}
