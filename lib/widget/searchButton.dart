import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchButton extends StatefulWidget {
  final Function(List<dynamic>) onSearchResults; // Add callback function
  const SearchButton({Key? key, required this.onSearchResults})
      : super(key: key);

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
        _searchController.clear();
      }
    });
  }

  Future<void> _onSearch(String query) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (query.isEmpty) {
      widget.onSearchResults([]); // Reset search
      return;
    }

    try {
      final response = await supabase
          .from('budgets')
          .select()
          .eq('user_id', userId)
          .ilike('name', '%$query%')
          .order('created_at', ascending: false);

      widget.onSearchResults(response); // Send results back to parent
    } catch (error) {
      print('Search error: $error');
      widget.onSearchResults([]); // Reset on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizeTransition(
          sizeFactor: _animation,
          axis: Axis.horizontal,
          axisAlignment: 1.0,
          child: Container(
            width: 200,
            margin: const EdgeInsets.only(right: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Looking for?',
                hintStyle: const TextStyle(color: Colors.white70),
                isDense: true,
                filled: true,
                fillColor: Colors.white24,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.white, width: 1),
                ),
              ),
              onChanged: _onSearch, // Search as user types
            ),
          ),
        ),
        IconButton(
          onPressed: _toggleSearch,
          iconSize: 32,
          icon: AnimatedIcon(
            icon: AnimatedIcons.search_ellipsis,
            progress: _animation,
            color: Colors.white, // Make icon white
          ),
        ),
      ],
    );
  }
}
