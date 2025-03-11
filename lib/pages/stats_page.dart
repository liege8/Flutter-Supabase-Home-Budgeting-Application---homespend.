// ignore_for_file: deprecated_member_use

import 'package:araneta_HBA_it14/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:araneta_HBA_it14/widget/chart.dart';
import 'package:araneta_HBA_it14/json/create_budget_json.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // Keep only one instance of these variables
  int activeFilter = 0;
  bool _showAllCategories = false;
  Map<String, double> _categorySpending = {};

  // Instance variables
  final SupabaseClient _supabase = Supabase.instance.client;

  // Data tracking variables
  Map<DateTime, double> _incomeData = {};
  Map<DateTime, double> _expenseData = {};
  Map<String, double> _frequencyCounts = {
    "Daily": 0,
    "Weekly": 0,
    "Monthly": 0,
    "Yearly": 0,
  };
  Map<String, double> _spendingData = {
    "Daily": 0,
    "Weekly": 0,
    "Monthly": 0,
    "Yearly": 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBudgetData();
  }

  // Data fetching method
  // Add this variable to store category spending data
  // Map<String, double> _categorySpending = {};

  // Update the setState in _fetchBudgetData
  Future<void> _fetchBudgetData() async {
    try {
      setState(() => _isLoading = true);

      final budgetResponse =
          await _supabase.from('budgets').select('amount, category, frequency');
      final transactionResponse = await _supabase
          .from('transactions')
          .select('amount, created_at, type')
          .order('created_at');

      if (budgetResponse.isEmpty) {
        print("No budget data found!");
        setState(() => _isLoading = false);
        return;
      }

      // Process data
      final processedData =
          _processFinancialData(budgetResponse, transactionResponse);

      setState(() {
        _spendingData = processedData['spendingData'];
        _frequencyCounts = processedData['frequencyCounts'];
        _incomeData = processedData['incomeData'];
        _expenseData = processedData['expenseData'];
        _categorySpending =
            processedData['categorySpending']; // Store category spending
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => _isLoading = false);
    }
  }

  // Update _buildSpendingCategories to use stored data
  Widget _buildSpendingCategories() {
    final List<Map<String, dynamic>> budgetCategories =
        List<Map<String, dynamic>>.from(categories);

    // Use stored category spending data
    final Map<String, double> categorySpending = _isLoading
        ? Map.fromIterable(
            budgetCategories,
            key: (item) => item['name'],
            value: (_) => 1000.0,
          )
        : _categorySpending; // Use the class variable directly instead of reprocessing

    // Show only first 4 categories if not showing all
    final displayedCategories = _showAllCategories
        ? budgetCategories
        : budgetCategories.take(4).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Spending Categories",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: displayedCategories.length,
            itemBuilder: (context, index) {
              final category = displayedCategories[index]['name'];
              final icon = budgetCategories[index]['icon'];
              final amount = categorySpending[category] ?? 0;
              final total =
                  categorySpending.values.fold<double>(0, (a, b) => a + (b));
              final percentage =
                  total > 0 ? (amount / total * 100).toStringAsFixed(0) : '0';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getCategoryColor(category).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          icon,
                          width: 35,
                          height: 35,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₱${amount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$percentage%",
                          style: TextStyle(
                            fontSize: 12,
                            color: _getCategoryColor(category),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          if (budgetCategories.length > 4) ...[
            const SizedBox(height: 15),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAllCategories = !_showAllCategories;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _showAllCategories ? "Show Less" : "Show All",
                      style: TextStyle(
                        color: secondary1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      _showAllCategories
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: secondary1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Data processing method
  Map<String, dynamic> _processFinancialData(
      List<dynamic> budgetResponse, List<dynamic> transactionResponse) {
    // Initialize maps
    Map<String, double> categorySpending = {};
    Map<String, double> frequencyAmounts = {
      "Daily": 0,
      "Weekly": 0,
      "Monthly": 0,
      "Yearly": 0,
    };
    Map<DateTime, double> tempIncomeData = {};
    Map<DateTime, double> tempExpenseData = {};

    // Process budget data
    for (var row in budgetResponse) {
      String? category = row['category'];
      String? frequency = row['frequency'];
      double amount = (row['amount'] ?? 0).toDouble();

      if (category != null) {
        categorySpending[category] = (categorySpending[category] ?? 0) + amount;
      }

      if (frequency != null && frequencyAmounts.containsKey(frequency)) {
        frequencyAmounts[frequency] =
            (frequencyAmounts[frequency] ?? 0) + amount;
      }
    }

    // Process transaction data
    for (var transaction in transactionResponse) {
      final date = DateTime.parse(transaction['created_at']).toLocal();
      final amount = transaction['amount'] as double;
      final dateKey = DateTime(date.year, date.month, date.day);

      if (amount > 0) {
        tempIncomeData[dateKey] = (tempIncomeData[dateKey] ?? 0) + amount;
      } else {
        tempExpenseData[dateKey] =
            (tempExpenseData[dateKey] ?? 0) + amount.abs();
      }
    }

    // Calculate percentages for pie chart
    Map<String, double> percentageFrequencyCounts = Map.from(frequencyAmounts);
    double total = percentageFrequencyCounts.values.fold(0, (a, b) => a + b);
    if (total > 0) {
      percentageFrequencyCounts
          .updateAll((key, value) => (value / total) * 100);
    }

    return {
      'categorySpending': categorySpending,
      'frequencyCounts': percentageFrequencyCounts,
      'spendingData': frequencyAmounts,
      'incomeData': tempIncomeData,
      'expenseData': tempExpenseData,
    };
  }

  // UI building methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.05),
      body: Skeletonizer(
        enabled: _isLoading,
        effect: ShimmerEffect(
          baseColor: Colors.grey[300]!,
          highlightColor: secondary1,
        ),
        ignoreContainers: true,
        child: _getBody(),
      ),
    );
  }

  // Add this method
  Widget _getBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with filter options
          Container(
            decoration: BoxDecoration(
              color: secondary1,
              boxShadow: [
                BoxShadow(
                  color: secondary1,
                  spreadRadius: 10,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 30, right: 10, left: 10, bottom: 10),
              child: Column(
                children: [
                  _buildAppBar(),
                  // Filter options
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildFilterOption("Budgets", 0),
                        _buildFilterOption("Transactions", 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Conditional rendering based on filter
          if (activeFilter == 0) ...[
            _buildPieChart(),
            const SizedBox(height: 20),
            _buildSpendingCategories(),
          ] else ...[
            ChartWidgets.buildLineChart(_incomeData, _expenseData),
            ChartWidgets.buildBarChart(_incomeData, _expenseData),
          ],
        ],
      ),
    );
  }

  // Add this method for filter options
  Widget _buildFilterOption(String title, int index) {
    bool isActive = activeFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            activeFilter = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? secondary1 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? white : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Update _buildPieChart to handle empty state
  Widget _buildPieChart() {
    double totalBudget =
        _spendingData.values.fold(0, (sum, value) => sum + value);

    // Add dummy data for skeleton state
    final dummyData = _isLoading
        ? {
            "Daily": 25.0,
            "Weekly": 25.0,
            "Monthly": 25.0,
            "Yearly": 25.0,
          }
        : _frequencyCounts;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      height: 330,
      width: 470,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "My Budget Summary",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: dummyData.entries.map((entry) {
                            return PieChartSectionData(
                              color: _getColor(entry.key),
                              value: entry.value,
                              title: "${entry.value.toStringAsFixed(0)}%",
                              radius: 40,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              showTitle: entry.value > 5,
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 3,
                          centerSpaceRadius: 80,
                          startDegreeOffset: 270,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Total Budget",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "₱${totalBudget.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Legend Section
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _frequencyCounts.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getColor(entry.key),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "₱${_spendingData[entry.key]?.toStringAsFixed(2) ?? '0.00'}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Existing color methods
  Color _getColor(String frequency) {
    switch (frequency) {
      case "Daily":
        return Colors.blueAccent;
      case "Weekly":
        return Colors.greenAccent;
      case "Monthly":
        return Colors.orangeAccent;
      case "Yearly":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor(String category) {
    Map<String, Color> categoryColors = {
      "Auto/Transpo": Colors.blueAccent,
      "Cash": Colors.green,
      "Bills": Colors.yellow,
      "Bank": Colors.orange,
      "Charity": Colors.purple,
      "Food Supply": Colors.redAccent,
      "Gift": Colors.indigo,
      "Travel": Colors.cyan,
      "Online\n Subscription": Colors.tealAccent,
      "Healthcare": Colors.pink,
      "School": Colors.brown,
      "Clothing": Colors.deepOrange,
      "Others": Colors.blueGrey,
    };

    return categoryColors[category] ?? Colors.grey;
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: secondary1,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.01),
            spreadRadius: 10,
            blurRadius: 3,
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 30, right: 10, left: 10, bottom: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Statistics",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: white,
              ),
            ),
            IconButton(
              onPressed: _fetchBudgetData,
              icon: const Icon(
                AntDesign.reload1,
                color: white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
