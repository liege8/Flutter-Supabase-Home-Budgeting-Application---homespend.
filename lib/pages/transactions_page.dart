// ignore_for_file: deprecated_member_use

import 'package:araneta_HBA_it14/theme/colors.dart';
import 'package:araneta_HBA_it14/data/transaction_categories.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'dart:math';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  bool _showAllTransactions = false;
  static const int _initialDisplayCount =
      5; // Number of transactions to show initially
  // Update filter variables
  int selectedFilter = 1; // Default to "All"
  final List<String> filterOptions = ['Income', 'All', 'Expense'];

  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> transactions = [];
  bool _isLoading = false;
  String selectedType = 'expense';
  String? selectedCategoryId;
  final currencyFormat = NumberFormat.currency(locale: "en_PH", symbol: "₱");

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final data = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        transactions = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      _showErrorMessage('Error loading transactions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTransactions() async {
    await _loadTransactions();
  }

  void _showAddTransactionDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String dialogSelectedType = selectedType;
    String? dialogSelectedCategoryId;
    DateTime selectedDate = DateTime.now(); // Add this line

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: white,
          title: Text('Add Transaction'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add Date Selection
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Transaction Date'),
                    subtitle: Text(
                      DateFormat('MMM d, y').format(selectedDate),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.calendar_today),
                      color: secondary1, // Green accent
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: secondary1, // Green accent
                                colorScheme:
                                    ColorScheme.light(primary: secondary1),
                                dialogBackgroundColor: Colors.white,
                                buttonTheme: ButtonThemeData(
                                  textTheme: ButtonTextTheme.primary,
                                ),
                                textSelectionTheme: TextSelectionThemeData(
                                  cursorColor: secondary1,
                                  selectionHandleColor: secondary1,
                                ),
                                datePickerTheme: DatePickerThemeData(
                                  // Customize the calendar style here
                                  backgroundColor: Colors.white,
                                  headerBackgroundColor: secondary1,
                                  headerForegroundColor: Colors.white,
                                  dayStyle: TextStyle(color: Colors.black),
                                  dayOverlayColor: MaterialStateProperty.all(
                                      secondary1.withOpacity(0.5)),
                                  todayForegroundColor:
                                      MaterialStateProperty.all(
                                    secondary1,
                                  ), // Today's text color
                                  todayBackgroundColor:
                                      MaterialStateProperty.all(
                                          secondary1.withOpacity(
                                              0.1)), // Today's background color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ),
                  Divider(),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'expense',
                        label: Text('Expense'),
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: secondary1,
                        ),
                      ),
                      ButtonSegment(
                        value: 'income',
                        label: Text('Income'),
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: secondary1,
                        ),
                      ),
                    ],
                    selected: {dialogSelectedType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setDialogState(() {
                        dialogSelectedType = newSelection.first;
                        dialogSelectedCategoryId = null;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: secondary1.withOpacity(
                          0.1), // Background color for unselected segments
                      selectedBackgroundColor:
                          secondary1, // Background color for the selected segment
                      foregroundColor:
                          secondary1, // Text and icon color for unselected segments
                      selectedForegroundColor: Colors
                          .white, // Text and icon color for the selected segment
                      iconColor: white,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Category Selection
                  Container(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            TransactionCategories.getByType(dialogSelectedType)
                                .map((category) {
                          final isSelected =
                              category.id == dialogSelectedCategoryId;
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                dialogSelectedCategoryId = category.id;
                              });
                            },
                            child: Container(
                              width: 70,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primary.withOpacity(0.1)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? primary : Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    category.icon,
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    category.name,
                                    style: TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₱',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: secondary1),
              ),
            ),
            // Update the onPressed of FilledButton
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: secondary1,
                foregroundColor: white,
              ),
              onPressed: () async {
                if (amountController.text.isEmpty) {
                  _showErrorMessage('Please enter an amount');
                  return;
                }
                if (dialogSelectedCategoryId == null) {
                  _showErrorMessage('Please select a category');
                  return;
                }

                try {
                  final amount = double.parse(amountController.text);
                  final description = descriptionController.text.trim();
                  final userId = _supabase.auth.currentUser?.id;

                  if (userId == null) throw Exception('User not authenticated');

                  await _supabase.from('transactions').insert({
                    'user_id': userId,
                    'amount':
                        dialogSelectedType == 'expense' ? -amount : amount,
                    'description': description,
                    'type': dialogSelectedType,
                    'category_id': dialogSelectedCategoryId,
                    'created_at':
                        selectedDate.toIso8601String(), // Update this line
                  });

                  Navigator.pop(context);
                  _loadTransactions();
                  _showSuccessMessage('Transaction added successfully');
                } catch (e) {
                  _showErrorMessage('Error adding transaction: $e');
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTransactionDialog(Map<String, dynamic> transaction) {
    final TextEditingController amountController = TextEditingController(
      text: transaction['amount'].abs().toString(),
    );
    final TextEditingController descriptionController = TextEditingController(
      text: transaction['description'],
    );
    String editType = transaction['type'];
    String? editCategoryId = transaction['category_id'];
    DateTime selectedDate =
        DateTime.parse(transaction['created_at']); // Add this line

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // Change to StatefulBuilder
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add Date Selection
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Transaction Date'),
                  subtitle: Text(
                    DateFormat('MMM d, y').format(selectedDate),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ),
                Divider(),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'expense',
                      label: Text('Expense'),
                      icon: Icon(Icons.remove_circle_outline),
                    ),
                    ButtonSegment(
                      value: 'income',
                      label: Text('Income'),
                      icon: Icon(Icons.add_circle_outline),
                    ),
                  ],
                  selected: {editType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setDialogState(() {
                      editType = newSelection.first;
                      // Reset category when type changes
                      editCategoryId = null;
                    });
                  },
                ),
                SizedBox(height: 16),
                // Add category selection in edit dialog
                Container(
                  height: 200,
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TransactionCategories.getByType(editType)
                          .map((category) {
                        final isSelected = category.id == editCategoryId;
                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              editCategoryId = category.id;
                            });
                          },
                          child: Container(
                            width: 70,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primary.withOpacity(0.1)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? primary : Colors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  category.icon,
                                  style: TextStyle(fontSize: 24),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  category.name,
                                  style: TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₱',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: secondary1, width: 2.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: secondary1, width: 2.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            // Update the onPressed of FilledButton
            FilledButton(
              onPressed: () async {
                if (amountController.text.isEmpty) {
                  _showErrorMessage('Please enter an amount');
                  return;
                }
                if (editCategoryId == null) {
                  _showErrorMessage('Please select a category');
                  return;
                }

                try {
                  final amount = double.parse(amountController.text);
                  final description = descriptionController.text.trim();

                  await _supabase.from('transactions').update({
                    'amount': editType == 'expense' ? -amount : amount,
                    'description': description,
                    'type': editType,
                    'category_id': editCategoryId,
                    'created_at':
                        selectedDate.toIso8601String(), // Add this line
                    'updated_at': DateTime.now().toIso8601String(),
                  }).eq('id', transaction['id']);

                  Navigator.pop(context);
                  _loadTransactions();
                  _showSuccessMessage('Transaction updated successfully');
                } catch (e) {
                  _showErrorMessage('Error updating transaction: $e');
                }
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTransaction(int transactionId) async {
    try {
      await _supabase.from('transactions').delete().eq('id', transactionId);
      _loadTransactions();
      _showSuccessMessage('Transaction deleted successfully');
    } catch (e) {
      _showErrorMessage('Error deleting transaction: $e');
    }
  }

  // Add method to filter transactions
  List<Map<String, dynamic>> get filteredTransactions {
    switch (selectedFilter) {
      case 0: // Income
        return transactions.where((t) => (t['amount'] as num) > 0).toList();
      case 2: // Expense
        return transactions.where((t) => (t['amount'] as num) < 0).toList();
      default: // All (1)
        return transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.05),
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

  Widget _getBody() {
    return Column(
      children: [
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
            padding:
                const EdgeInsets.only(top: 50, right: 20, left: 20, bottom: 20),
            child: Column(
              children: [
                _buildAppBar(),
                SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildFilterOption("Income", 0),
                      _buildFilterOption("All", 1),
                      _buildFilterOption("Expense", 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Total Amount Card
        Container(
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      color: black.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    currencyFormat.format(
                      filteredTransactions.fold<double>(
                        0,
                        (sum, transaction) =>
                            sum + (transaction['amount'] as num),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: _showAddTransactionDialog,
                icon: Icon(Icons.add, size: 20),
                label: Text('Add Transaction'),
                style: FilledButton.styleFrom(
                  backgroundColor: secondary1,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Income and Expense Summary Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              // Income Card
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade300,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_upward, color: white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Income',
                            style: TextStyle(
                              color: white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        currencyFormat.format(
                          transactions
                              .where((t) => (t['amount'] as num) > 0)
                              .fold<double>(
                                0,
                                (sum, t) => sum + (t['amount'] as num),
                              ),
                        ),
                        style: TextStyle(
                          color: white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 15),
              // Expense Card
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade400,
                        Colors.red.shade300,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_downward, color: white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Expense',
                            style: TextStyle(
                              color: white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        currencyFormat.format(
                          transactions
                              .where((t) => (t['amount'] as num) < 0)
                              .fold<double>(
                                0,
                                (sum, t) => sum + (t['amount'] as num).abs(),
                              ),
                        ),
                        style: TextStyle(
                          color: white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Transactions List
        Expanded(
          child: filteredTransactions.isEmpty
              ? Center(
                  child: Text(
                    'No transactions found',
                    style: TextStyle(color: grey),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _showAllTransactions
                            ? filteredTransactions.length
                            : min(_initialDisplayCount,
                                filteredTransactions.length),
                        padding: EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          final amount = transaction['amount'] as num;
                          final isExpense = amount < 0;
                          final category = TransactionCategories.getById(
                              transaction['category_id'] ?? 'others');

                          return Card(
                            elevation: 2,
                            color: white,
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    isExpense ? Colors.red : Colors.green,
                                child: Text(
                                  category?.icon ?? '📝',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              title: Text(
                                transaction['description'] ?? 'No description',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(category?.name ?? 'Others'),
                                  Text(
                                    DateFormat('MMM d, y').format(
                                      DateTime.parse(transaction['created_at']),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currencyFormat.format(amount.abs()),
                                    style: TextStyle(
                                      color:
                                          isExpense ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  PopupMenuButton(
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: ListTile(
                                          leading: Icon(Icons.edit),
                                          title: Text('Edit'),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onTap: () {
                                          Future.delayed(
                                            Duration(seconds: 0),
                                            () => _showEditTransactionDialog(
                                                transaction),
                                          );
                                        },
                                      ),
                                      PopupMenuItem(
                                        child: ListTile(
                                          leading: Icon(Icons.delete,
                                              color: Colors.red),
                                          title: Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onTap: () {
                                          _deleteTransaction(transaction['id']);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (filteredTransactions.length > _initialDisplayCount)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          bottom: 40.0,
                        ),
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _showAllTransactions = !_showAllTransactions;
                            });
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: secondary1,
                            foregroundColor: white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _showAllTransactions ? 'Show Less' : 'Show More',
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Transactions",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: white,
          ),
        ),
        IconButton(
          onPressed: _fetchTransactions,
          icon: const Icon(
            AntDesign.reload1,
            color: white,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOption(String title, int index) {
    bool isActive = selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? secondary1 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            filterOptions[index],
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

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
