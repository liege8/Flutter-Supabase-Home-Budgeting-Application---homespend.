// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:araneta_HBA_it14/pages/create_budget_page.dart';
import 'package:araneta_HBA_it14/pages/edit_budget_page.dart';
import 'package:araneta_HBA_it14/widget/searchButton.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:intl/intl.dart';
import 'package:araneta_HBA_it14/theme/colors.dart';
import 'package:araneta_HBA_it14/json/day_month.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// Add fullName to your state variables at the top of the class
class _HomePageState extends State<HomePage> {
  int activeTimeFilter =
      0; // 0 = All, 1 = Daily, 2 = Weekly, 3 = Monthly, 4 = Yearly
  int activeDay = int.parse(days.last['day']!);
  List<dynamic> allBudgets = []; // Store all fetched budgets
  List<dynamic> filteredBudgets = []; // Store filtered budgets to display
  bool isLoading = true;
  double totalBudget = 0;
  final currencyFormat = NumberFormat.currency(locale: "en_PH", symbol: "₱");
  final supabase = Supabase.instance.client;
  String fullName = ""; // Add this line
  bool showAllBudgets = false;
  static const int initialBudgetCount = 3; // Show only 3 items initially

  @override
  void initState() {
    super.initState();
    fetchUserProfile(); // Add this line
    fetchBudgets();
  }

  // Add this new method to fetch user profile
  Future<void> fetchUserProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final userData = await supabase
          .from('users')
          .select('full_name')
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          fullName = userData['full_name'] ?? "User";
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<void> fetchBudgets() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        _showErrorMessage('You are not logged in.');
        setState(() {
          isLoading = false;
        });
        return;
      }

      // The response is now directly the data array
      final data = await supabase
          .from('budgets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        allBudgets = data; // Store all budgets
        applyFilters(); // Apply active filter
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching budgets: ${error.toString()}');
      setState(() {
        isLoading = false;
      });
      _showErrorMessage('Error fetching budgets: ${error.toString()}');
    }
  }

  // New method to apply filters based on the selected time period
  void applyFilters() {
    List<dynamic> filtered = [];

    // Apply time filter
    switch (activeTimeFilter) {
      case 0: // All
        filtered = List.from(allBudgets);
        break;
      case 1: // Daily
        filtered = filterDailyBudgets();
        break;
      case 2: // Weekly
        filtered = filterWeeklyBudgets();
        break;
      case 3: // Monthly
        filtered = filterMonthlyBudgets();
        break;
      case 4: // Yearly
        filtered = filterYearlyBudgets();
        break;
      default:
        filtered = List.from(allBudgets);
    }

    // Calculate total budget for filtered list
    double total = 0;
    for (var budget in filtered) {
      total += (budget['amount'] as num).toDouble();
    }

    setState(() {
      filteredBudgets = filtered;
      totalBudget = total;
    });
  }

  List<dynamic> filterDailyBudgets() {
    return allBudgets.where((budget) {
      // Only show budgets with frequency set to 'Daily'
      return budget['frequency'] == 'Daily';
    }).toList();
  }

  List<dynamic> filterWeeklyBudgets() {
    return allBudgets.where((budget) {
      // Only show budgets with frequency set to 'Weekly'
      return budget['frequency'] == 'Weekly';
    }).toList();
  }

  List<dynamic> filterMonthlyBudgets() {
    return allBudgets.where((budget) {
      // Only show budgets with frequency set to 'Monthly'
      return budget['frequency'] == 'Monthly';
    }).toList();
  }

  List<dynamic> filterYearlyBudgets() {
    return allBudgets.where((budget) {
      // Only show budgets with frequency set to 'Yearly'
      return budget['frequency'] == 'Yearly';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.05),
      body: getBody(),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: fetchBudgets,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Skeletonizer(
          enabled: isLoading,
          effect: ShimmerEffect(
            baseColor: Colors.grey[300]!,
            highlightColor: secondary1,
          ),
          ignoreContainers: true,
          child: Column(
            children: [
              // Header with time period filter
              Container(
                decoration: BoxDecoration(
                  color: secondary1,
                  boxShadow: [
                    BoxShadow(
                      color: grey.withOpacity(0.01),
                      spreadRadius: 10,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 60, right: 20, left: 20, bottom: 25),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/homespend - white (32x32).png',
                                    width: 32,
                                    height: 32,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "homespend.",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: white,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Welcome ${fullName.split(' ')[0]}!",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // In the build method where SearchButton is used
                          SearchButton(
                            onSearchResults: (results) {
                              setState(() {
                                if (results.isEmpty) {
                                  // If no search results or search cleared, show all budgets
                                  applyFilters();
                                } else {
                                  // Show search results
                                  filteredBudgets = results;
                                  // Update total budget for search results
                                  totalBudget = results.fold(
                                      0.0,
                                      (sum, budget) =>
                                          sum +
                                          (budget['amount'] as num).toDouble());
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Time period filter remains the same
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildTimeFilterOption("All", 0),
                            _buildTimeFilterOption("Daily", 1),
                            _buildTimeFilterOption("Weekly", 2),
                            _buildTimeFilterOption("Monthly", 3),
                            _buildTimeFilterOption("Yearly", 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Total Budget Summary Card
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: secondary1,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: secondary1.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Budget",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isLoading
                                  ? "Loading..."
                                  : currencyFormat.format(totalBudget),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            padding: const EdgeInsets.all(15),
                            constraints:
                                const BoxConstraints(), // Removes default padding
                            icon: Icon(
                              AntDesign.wallet,
                              size: 30,
                              color: white,
                            ),
                            onPressed: () async {
                              await fetchBudgets(); // Refresh the budgets
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Refreshed successfully'),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: secondary1,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Time Period Budget Summary Cards
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPeriodBudgetCard("Daily", filterDailyBudgets()),
                    const SizedBox(width: 10),
                    _buildPeriodBudgetCard("Weekly", filterWeeklyBudgets()),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Row(
                  children: [
                    _buildPeriodBudgetCard("Monthly", filterMonthlyBudgets()),
                    const SizedBox(width: 10),
                    _buildPeriodBudgetCard("Yearly", filterYearlyBudgets()),
                  ],
                ),
              ),

              // Budget List Section Title
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Budgets",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: black.withOpacity(0.5),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        // Navigate to create budget page
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateBudgetPage()),
                        );
                        if (result == true) {
                          fetchBudgets(); // Refresh budgets if a new one was created
                        }
                      },
                      child: Text(
                        "Add New",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: secondary1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Budget List or Loading/Empty State
              isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: CircularProgressIndicator(color: secondary1),
                      ),
                    )
                  : filteredBudgets.isEmpty
                      ? _emptyBudgetMessage()
                      : _buildBudgetList(MediaQuery.of(context).size,
                          filteredBudgets, _editBudget, _deleteBudget),

              const SizedBox(height: 60), // Space at the bottom
            ],
          ),
        ),
      ),
    );
  }

  // Update this method to call applyFilters when filter selection changes
  Widget _buildTimeFilterOption(String label, int index) {
    bool isActive = activeTimeFilter == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            activeTimeFilter = index;
            applyFilters();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? secondary1 : white, // Changed background color
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: white, width: 2),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? white
                    : black.withOpacity(0.7), // Updated text color for contrast
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyBudgetMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(
              AntDesign.wallet,
              size: 60,
              color: grey,
            ),
            const SizedBox(height: 10),
            Text(
              activeTimeFilter == 0
                  ? "No budgets found"
                  : "No ${_getFilterName(activeTimeFilter)} budgets found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: black.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Start by adding your first budget",
              style: TextStyle(
                fontSize: 14,
                color: black.withOpacity(0.3),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get the name of the filter
  String _getFilterName(int filter) {
    switch (filter) {
      case 1:
        return "daily";
      case 2:
        return "weekly";
      case 3:
        return "monthly";
      case 4:
        return "yearly";
      default:
        return "";
    }
  }

  Widget _buildBudgetList(Size size, List<dynamic> budgets,
      Function _editBudget, Function _deleteBudget) {
    final currencyFormat = NumberFormat.currency(locale: "en_PH", symbol: "₱");
    final displayedBudgets =
        showAllBudgets ? budgets : budgets.take(initialBudgetCount).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Column(
            children: List.generate(displayedBudgets.length, (index) {
              final budget = displayedBudgets[index];
              final iconPath =
                  budget['icon_path'] ?? 'assets/images/budget.png';
              final budgetId = budget['id'] is int
                  ? budget['id']
                  : int.tryParse(budget['id'].toString()) ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 3,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withOpacity(0.15),
                          ),
                          child: Center(
                            child: Image.asset(
                              iconPath,
                              width: 30,
                              height: 30,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(AntDesign.wallet,
                                    color: Colors.black.withOpacity(0.5));
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        SizedBox(
                          width: (size.width - 140) * 0.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                budget['name'] ?? 'Unnamed Budget',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                budget['category'] ?? 'Uncategorized',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black.withOpacity(0.6),
                                    fontWeight: FontWeight.w400),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (budget['note'] != null &&
                                  budget['note'].toString().isNotEmpty)
                                Text(
                                  'Note: ${budget['note']}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.5)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (budget['frequency'] != null)
                                Text(
                                  'Time Period: ${budget['frequency']}',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.blueGrey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(budget['amount'] ?? 0),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _editBudget(budget),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: Icon(Icons.edit_outlined,
                                    size: 18, color: Colors.blueGrey),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _deleteBudget(budgetId),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.delete_outline,
                                    size: 18, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
          // Add this new section for the Show All button
          if (budgets.length > initialBudgetCount)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showAllBudgets = !showAllBudgets;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showAllBudgets ? "Show Less" : "View All Budgets",
                      style: TextStyle(
                        color: secondary1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      showAllBudgets
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: secondary1,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _editBudget(Map<String, dynamic> budget) async {
    // Navigate to edit budget page with the budget data
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBudgetPage(budget: budget),
      ),
    );

    if (result == true) {
      fetchBudgets(); // Refresh budgets if edited
      _showSuccessMessage('Budget updated successfully');
    }
  }

  Future<void> _deleteBudget(int budgetId) async {
    // Check if budgetId is valid
    if (budgetId == 0) {
      _showErrorMessage('Invalid budget ID');
      return;
    }
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Delete the budget from Supabase
      await supabase.from('budgets').delete().eq('id', budgetId);

      // Refresh budgets
      await fetchBudgets();
      _showSuccessMessage('Budget deleted successfully');
    } catch (error) {
      _showErrorMessage('Error deleting budget: ${error.toString()}');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ));
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

// Add this method at the bottom of your class
  Widget _buildPeriodBudgetCard(String period, List<dynamic> budgets) {
    print(
        'Building card for $period with ${budgets.length} budgets'); // Add this debug line
    double total = budgets.fold(
        0.0, (sum, budget) => sum + (budget['amount'] as num).toDouble());

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: white,
          border: Border.all(color: secondary1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: secondary1.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                period,
                style: TextStyle(
                  color: secondary1,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              currencyFormat.format(total),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "${budgets.length} budgets",
              style: TextStyle(
                fontSize: 12,
                color: black.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
