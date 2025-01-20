import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:twist_and_solve/Service/solve_service.dart';

class ProgressGraph extends StatefulWidget {
  const ProgressGraph({super.key});

  @override
  State<ProgressGraph> createState() => _ProgressGraphState();
}

class _ProgressGraphState extends State<ProgressGraph> {
  late Future<List<SolveModel>> _solveFuture;
  List<FlSpot> spotData = [];
  @override
  void initState() {
    super.initState();
    setState(() {
      _solveFuture = fetchSolvesByUserId(); // Fetch solves for this userId
      _solveFuture.then((solves) {
        setState(() {
          // Map solve data to spots
          spotData = solves.asMap().entries.map((entry) {
            final index = entry.key;
            final solve = entry.value;
            return FlSpot(index.toDouble(), solve.solveTime);
          }).toList();

        });
      });
    });
    // _solveFuture = fetchSolvesByUserId(_userId);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Graph'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<SolveModel>>(
          future: _solveFuture,
          builder: (context, snapshot2) {
            if (snapshot2.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            else if (snapshot2.hasError) {
              return Center(
                child: Text(
                  'solve Error: ${snapshot2.error}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            }
            else if (!snapshot2.hasData || snapshot2.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No solve data available.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            }
            else {
              return Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Solve Times Over Time',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width, // Adjust based on screen width
                            child: LineChart(
                              LineChartData(
                                minY: spotData.isNotEmpty
                                    ? spotData.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 5
                                    : 0,
                                maxY: spotData.isNotEmpty
                                    ? spotData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 5
                                    : 10,
                                gridData: const FlGridData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spotData,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.blue,
                                        Colors.purple,
                                      ],
                                    ),
                                    barWidth: 2,
                                    isCurved: true,
                                    preventCurveOverShooting: true,
                                    isStrokeCapRound: true,
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.blueAccent,
                                          Colors.purpleAccent,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        if (value >= 0 && value < snapshot2.data!.length) {
                                          final date = snapshot2.data![value.toInt()].solveDate;
                                          return Text(
                                            '${date.month}/${date.day}',
                                            style: const TextStyle(fontSize: 12),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                    axisNameWidget: const Text(
                                      'Solve Date',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      interval: 5,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toStringAsFixed(0),
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        )
      ),
    );
  }
}

