// ignore_for_file: deprecated_member_use

import 'package:araneta_HBA_it14/json/create_budget_json.dart';
import 'package:araneta_HBA_it14/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class CreateBudgetPage extends StatefulWidget {
  const CreateBudgetPage({Key? key}) : super(key: key);

  @override
  _CreateBudgetPageState createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends State<CreateBudgetPage> {
  int activeCategory = 0;
  final TextEditingController _budgetName = TextEditingController();
  final TextEditingController _budgetPrice = TextEditingController(text: "₱");
  final TextEditingController _budgetNote = TextEditingController();
  bool _isLoading = false;
  final currencyFormat = NumberFormat.currency(locale: "en_PH", symbol: "₱");
  String selectedFrequency = 'none';

  // Reference to Supabase client
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _setupPriceController();
  }

  void _setupPriceController() {
    _budgetPrice.addListener(() {
      final text = _budgetPrice.text;
      final selection = _budgetPrice.selection;

      if (text.isEmpty || selection.baseOffset == 0) {
        // Always ensure the peso sign is present at the beginning
        _budgetPrice.text = "₱";
        _budgetPrice.selection = TextSelection.fromPosition(
          TextPosition(offset: _budgetPrice.text.length),
        );
      } else if (text.length == 1 && text != "₱") {
        // If user deletes the peso sign, put it back
        _budgetPrice.text = "₱$text";
        _budgetPrice.selection = TextSelection.fromPosition(
          TextPosition(offset: _budgetPrice.text.length),
        );
      } else if (!text.startsWith("₱")) {
        // Ensure it always starts with ₱
        _budgetPrice.text = "₱$text";
        _budgetPrice.selection = TextSelection.fromPosition(
          TextPosition(offset: _budgetPrice.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _budgetName.dispose();
    _budgetPrice.dispose();
    _budgetNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
            context, false); // Return false when back button is pressed
        return false;
      },
      child: Scaffold(
        backgroundColor: grey.withOpacity(0.08),
        appBar: AppBar(
          backgroundColor: secondary1,
          elevation: 0.5,
          title: Text(
            "Create budget",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: white),
            onPressed: () {
              Navigator.pop(
                  context, false); // Return false when close button is pressed
            },
          ),
        ),
        body: getBody(),
      ),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySection(),
          SizedBox(height: 30),
          _buildFormSection(),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Text(
            "Choose Category",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: black.withOpacity(0.5),
            ),
          ),
        ),
        SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(categories.length, (index) {
              return _buildCategoryItem(index);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          activeCategory = index;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        width: 140,
        height: 180,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 2,
            color: activeCategory == index
                ? primary.withOpacity(0.8)
                : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            if (activeCategory == index)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: primary,
                    size: 20,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeCategory == index
                          ? primary.withOpacity(0.1)
                          : grey.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Image.asset(
                        categories[index]['icon'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    categories[index]['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: activeCategory == index ? primary : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField(
            label: "Budget Name",
            hint: "Enter Budget Name",
            controller: _budgetName,
            isBold: true,
          ),
          SizedBox(height: 20),
          _buildFormField(
            label: "Note (optional)",
            hint: "Enter note or description",
            controller: _budgetNote,
            maxLines: 3,
            isBold: false,
          ),
          SizedBox(height: 20),
          Text(
            "Budget Amount",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Color(0xff67727d),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: TextField(
              controller: _budgetPrice,
              keyboardType: TextInputType.number,
              cursorColor: black,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: black,
              ),
              decoration: InputDecoration(
                hintText: "Enter Amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Budget Frequency",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Color(0xff67727d)),
          ),
          DropdownButtonFormField<String>(
            value: selectedFrequency,
            items: ['none', 'Daily', 'Weekly', 'Monthly', 'Yearly']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(fontSize: 16)),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedFrequency = newValue!;
              });
            },
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
          SizedBox(height: 40),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isBold = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Color(0xff67727d),
          ),
        ),
        TextField(
          controller: controller,
          cursorColor: black,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 17,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary1,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _isLoading ? null : _submitBudget,
        child: _isLoading
            ? Container(
                height: 2,
                child: LinearProgressIndicator(
                  backgroundColor: white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(white),
                ),
              )
            : Text(
                "Submit Budget",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: white,
                ),
              ),
      ),
    );
  }

  Future<void> _submitBudget() async {
    // Validate inputs
    final name = _budgetName.text.trim();
    final note = _budgetNote.text.trim();

    // Handle currency amount extraction
    String priceText = _budgetPrice.text;
    if (priceText.startsWith("₱")) {
      priceText = priceText.substring(1); // Remove peso sign
    }
    priceText = priceText.replaceAll(",", "").trim(); // Remove commas

    if (name.isEmpty) {
      _showErrorMessage('Budget name is required');
      return;
    }

    double amount = 0;
    try {
      amount = double.parse(priceText);
    } catch (e) {
      _showErrorMessage('Please enter a valid amount');
      return;
    }

    if (amount <= 0) {
      _showErrorMessage('Amount must be greater than zero');
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      await _saveBudgetToSupabase(name, amount, note);

      // Fetch updated budgets
      await fetchBudgets();

      // Show success message
      _showSuccessMessage('Budget added successfully!');

      // Wait for the snackbar to be visible
      await Future.delayed(Duration(milliseconds: 500));

      // Reset form
      _resetForm();

      // Navigate back with true result to indicate success and refresh
      if (mounted) {
        Navigator.pop(context, true);
        await fetchBudgets();
      }
    } catch (error) {
      _showErrorMessage('Error: ${error.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchBudgets() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch budgets data from Supabase
      final data = await _supabase
          .from('budgets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // This is just for logging, since this method is called within CreateBudgetPage
      // and you likely don't have budgets or totalBudget variables in this class
      print('Fetched ${data.length} budgets');

      // Calculate total for logging purposes
      double total = 0;
      for (var budget in data) {
        total += (budget['amount'] as num).toDouble();
      }
      print('Total budget amount: $total');
    } catch (error) {
      print('Error fetching budgets: ${error.toString()}');
    }
  }

  Future<void> _saveBudgetToSupabase(
      String name, double amount, String note) async {
    // Get current user ID to associate budget with user
    final userId = _supabase.auth.currentUser?.id;

    // Check if user is authenticated
    if (userId == null) {
      throw Exception('You must be logged in to create a budget');
    }

    // Get selected category
    final category = categories[activeCategory]['name'];
    final iconPath = categories[activeCategory]['icon'];

    // Create budget data
    final budgetData = {
      'user_id': userId,
      'name': name,
      'amount': amount,
      'category': category,
      'icon_path': iconPath,
      'note': note,
      'frequency': selectedFrequency,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      // Use the correct insert method based on your Supabase version
      await _supabase.from('budgets').insert(budgetData);
      print('Budget saved successfully');
    } catch (e) {
      print('Supabase error: $e');
      throw Exception('Failed to save budget: $e');
    }
  }

  void _resetForm() {
    _budgetName.clear();
    _budgetPrice.text = "₱";
    _budgetNote.clear();
    setState(() {
      activeCategory = 0;
    });
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ));
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ));
    }
  }
}
