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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollToEnd();
    });
  }

  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBarGraph(x: index, y: widget.monthlySummary[index]),
    );
  }

  double claculateMax() {
    double max = 500;
    widget.monthlySummary.sort();

    max = widget.monthlySummary.last * 1.05;
    if (max < 500) {
      return 500;
    }
    return max;
  }

  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // Moved inside the class and modified to use widget.startMonth
  Widget getBottomTitles(double value, TitleMeta meta) {
    const textStyle = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    // Calculate the actual month by adding startMonth and taking modulo 12
    int monthIndex = ((value.toInt() + widget.startMonth - 1) % 12);

    // Optional: Add debug print to see the values
    // print('Value: $value, StartMonth: ${widget.startMonth}, MonthIndex: $monthIndex');

    String text;
    switch (monthIndex) {
      case 0:
        text = 'J'; // January
        break;
      case 1:
        text = 'F'; // February
        break;
      case 2:
        text = 'M'; // March
        break;
      case 3:
        text = 'A'; // April
        break;
      case 4:
        text = 'M'; // May
        break;
      case 5:
        text = 'J'; // June
        break;
      case 6:
        text = 'J'; // July
        break;
      case 7:
        text = 'A'; // August
        break;
      case 8:
        text = 'S'; // September
        break;
      case 9:
        text = 'O'; // October
        break;
      case 10:
        text = 'N'; // November
        break;
      case 11:
        text = 'D'; // December
        break;
      default:
        text = '';
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: textStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeBarData();

    double barWidth = 20;
    double spaceBetweenBars = 15;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width: barWidth * barData.length +
              spaceBetweenBars * (barData.length - 1),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: claculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getBottomTitles,
                    reservedSize: 24,
                  ),
                ),
              ),
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
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: claculateMax(),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }
}
