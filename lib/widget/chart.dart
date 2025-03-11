// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartWidgets {
  static Widget buildLineChart(
      Map<DateTime, double> incomeData, Map<DateTime, double> expenseData) {
    final List<DateTime> dates =
        {...incomeData.keys, ...expenseData.keys}.toList()..sort();

    if (dates.isEmpty) return Container();

    // Calculate total income and expense
    final totalIncome = incomeData.values.fold<double>(0.0, (a, b) => a + b);
    final totalExpense = expenseData.values.fold<double>(0.0, (a, b) => a + b);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Financial Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _buildLegendItem(Colors.green, "Income"),
                    const SizedBox(width: 12),
                    _buildLegendItem(Colors.red, "Expense"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTotalCard("Total Income", totalIncome, Colors.green),
              _buildTotalCard("Total Expense", totalExpense, Colors.red),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: _buildTitlesData(dates),
                borderData: FlBorderData(show: false),
                lineBarsData:
                    _buildLineBarsData(dates, incomeData, expenseData),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    showOnTopOfTheChartBoxArea: true,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    tooltipRoundedRadius: 20,
                    tooltipPadding: const EdgeInsets.all(12),
                    tooltipMargin: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isIncome = spot.barIndex == 0;
                        return LineTooltipItem(
                          '${isIncome ? "Income" : "Expense"}\n₱${spot.y.toStringAsFixed(2)}',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchLineStart: (data, index) => 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTotalCard(String title, double amount, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "₱${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static LineChartBarData _buildLineChartBarData(List<DateTime> dates,
      Map<DateTime, double> data, Color color, int barIndex) {
    return LineChartBarData(
      spots: dates.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          data[entry.value]?.toDouble() ?? 0,
        );
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 6,
            color: Colors.white,
            strokeWidth: 3,
            strokeColor: color,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.15),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
      ),
    );
  }

  // Add the missing _buildLegendItem method
  static Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static FlTitlesData _buildTitlesData(List<DateTime> dates) {
    return FlTitlesData(
      show: true,
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1000,
          reservedSize: 45,
          getTitlesWidget: (value, meta) {
            return Text(
              '₱${value.toInt()}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= 0 && value.toInt() < dates.length) {
              final date = dates[value.toInt()];
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "${date.day}/${date.month}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
    );
  }

  static List<LineChartBarData> _buildLineBarsData(
    List<DateTime> dates,
    Map<DateTime, double> incomeData,
    Map<DateTime, double> expenseData,
  ) {
    return [
      _buildLineChartBarData(dates, incomeData, Colors.green, 0),
      _buildLineChartBarData(dates, expenseData, Colors.red, 1),
    ];
  }

  static Widget buildBarChart(
      Map<DateTime, double> incomeData, Map<DateTime, double> expenseData) {
    final List<DateTime> dates =
        {...incomeData.keys, ...expenseData.keys}.toList()..sort();

    if (dates.isEmpty) return Container();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _calculateMaxY(incomeData, expenseData),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBorder: BorderSide.none,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(12),
                    tooltipMargin: 8,
                    tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                    tooltipHorizontalOffset: 4,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isIncome = rodIndex == 0;
                      return BarTooltipItem(
                        '${isIncome ? "Income" : "Expense"}\n₱${rod.toY.toStringAsFixed(2)}',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₱${value.toInt()}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < dates.length) {
                          final date = dates[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "${date.day}/${date.month}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _createBarGroups(dates, incomeData, expenseData),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static double _calculateMaxY(
      Map<DateTime, double> incomeData, Map<DateTime, double> expenseData) {
    double maxIncome =
        incomeData.values.fold(0.0, (max, value) => value > max ? value : max);
    double maxExpense =
        expenseData.values.fold(0.0, (max, value) => value > max ? value : max);
    return (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2;
  }

  static List<BarChartGroupData> _createBarGroups(
    List<DateTime> dates,
    Map<DateTime, double> incomeData,
    Map<DateTime, double> expenseData,
  ) {
    return dates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: incomeData[date] ?? 0,
            color: Colors.green,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: expenseData[date] ?? 0,
            color: Colors.red,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }
}
