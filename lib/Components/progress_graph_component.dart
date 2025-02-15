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
    _solveFuture = fetchSolvesByUserId();
    _solveFuture.then((solves) {
      setState(() {
        spotData = solves.asMap().entries.map((entry) {
          final index = entry.key;
          final solve = entry.value;
          return FlSpot(index.toDouble(), solve.solveTime);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Graph')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FutureBuilder<List<SolveModel>>(
                future: _solveFuture,
                builder: (context, snapshot2) {
                  if (snapshot2.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot2.hasError) {
                    return Center(
                      child: Text(
                        'Solve Error: ${snapshot2.error}',
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (!snapshot2.hasData || snapshot2.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No solve data available.',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Solve Times Over Time',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: 250,
                                  child: LineChart(
                                    LineChartData(

                                      borderData: FlBorderData(show: false),
                                      minY: spotData.isNotEmpty
                                          ? spotData.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 2
                                          : 0,
                                      maxY: spotData.isNotEmpty
                                          ? spotData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2
                                          : 10,
                                      gridData: FlGridData(
                                        show: true,
                                        drawHorizontalLine: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: 5,
                                        getDrawingHorizontalLine: (value) => const FlLine(
                                          color: Colors.grey,
                                          strokeWidth: 1,
                                          dashArray: [5, 5],
                                        ),
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: spotData,
                                          gradient: const LinearGradient(colors: [Colors.blue, Colors.blue]),
                                          barWidth: 3,
                                          isCurved: true,
                                          preventCurveOverShooting: true,
                                          isStrokeCapRound: true,
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
                                            reservedSize: 24,
                                            getTitlesWidget: (double value, TitleMeta meta) {
                                              if (value >= 0 && value < snapshot2.data!.length) {
                                                final date = snapshot2.data![value.toInt()].solveDate;
                                                return Text(
                                                  '${date.month}/${date.day}',
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                );
                                              }
                                              return const Text('');
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 24,
                                            interval: 5,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toStringAsFixed(0),
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder(
                          future: getSolveStats(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Center(child: Text('Error loading stats'));
                            } else if (!snapshot.hasData) {
                              return const Center(child: Text('No stats available'));
                            }

                            final stats = snapshot.data!;
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Solve Statistics',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    Table(
                                      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
                                      children: [
                                        _buildTableRow('Best Solve', '${stats.bestsolve.solveTime.toStringAsFixed(2)}s', true),
                                        _buildTableRow('Average Solve Time', '${stats.avrage.toStringAsFixed(2)}s', false),
                                        _buildTableRow('Average of 5 (Ao5)', '${stats.avrageof5.toStringAsFixed(2)}s', true),
                                        _buildTableRow('Average of 12 (Ao12)', '${stats.avrageof12.toStringAsFixed(2)}s', false),
                                        _buildTableRow('Last Solve', '${stats.lastSolve.solveTime.toStringAsFixed(2)}s', true),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value, bool isGrey) {
    return TableRow(
      children: [
        Container(color: isGrey ?  Theme.of(context).primaryColor : Theme.of(context).highlightColor, padding: const EdgeInsets.all(8.0), child: Text(label)),
        Container(color: isGrey ? Theme.of(context).primaryColor : Theme.of(context).highlightColor, padding: const EdgeInsets.all(8.0), child: Text(value)),
      ],
    );
  }
}
