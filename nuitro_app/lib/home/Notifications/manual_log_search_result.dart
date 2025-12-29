import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/api_reponse.dart';
import '../../providers/scan_workflow_provider.dart';
import 'food_detail_header.dart';

class ManualLogSearchResult extends StatefulWidget {
  final List<Map<String, dynamic>> initialResults;
  final String initialQuery;

  const ManualLogSearchResult({
    Key? key,
    required this.initialResults,
    required this.initialQuery,
  }) : super(key: key);

  @override
  State<ManualLogSearchResult> createState() => _ManualLogSearchResultState();
}

class _ManualLogSearchResultState extends State<ManualLogSearchResult> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _statusMessage = "";
  Timer? _debounce;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _searchText = widget.initialQuery;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(BuildContext context, String query,
      {bool silent = false}) async {
    final workflow = context.read<ScanWorkflowProvider>();
    setState(() {
      _searchText = query;
    });
    workflow.updateManualQuery(query);
    if (query.trim().isEmpty) {
      setState(() {
        _statusMessage = '';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      if (!silent) {
        _statusMessage = 'Searching...';
      }
    });

    final ApiResponse response = await workflow.searchManualFoods();
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      if (!response.status) {
        _statusMessage = response.message;
      } else if (workflow.manualResults.isEmpty) {
        _statusMessage = 'No matches found for "$query"';
      } else {
        _statusMessage = '';
      }
    });
  }

  void _onQueryChanged(BuildContext context, String value) {
    setState(() {
      _searchText = value;
      _statusMessage = '';
    });
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    if (value.trim().length < 2) {
      setState(() {
        _statusMessage = '';
        _isLoading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        _performSearch(context, value, silent: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final workflow = context.watch<ScanWorkflowProvider>();
    final results = workflow.manualResults.isNotEmpty
        ? workflow.manualResults
        : widget.initialResults;
    final selection = workflow.manualSelection ??
        (results.isNotEmpty ? results.first : null);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// Sticky Header
            FoodDetailHeader(
              foodName: results.isNotEmpty
                  ? (selection?['name']?.toString() ?? widget.initialQuery)
                  : widget.initialQuery,
              servingSize: results.isNotEmpty
                  ? (selection?['serving_size']?.toString() ?? "")
                  : "",
              imageUrl: results.isNotEmpty
                  ? (selection?['image_url']?.toString() ?? "assets/images/Food.png")
                  : "assets/images/Food.png",
              onBack: () => Navigator.pop(context),
              onFavorite: () => print("Favorite clicked"),
            ),

            /// White Rounded Container
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      /// Search Bar
                      Container(
                        alignment: Alignment.center,
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: "Search",
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  _onQueryChanged(context, value);
                                },
                              ),
                            ),
                            if (_searchText.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchText = '';
                                    _statusMessage = '';
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Food List
                      Expanded(
                        child: results.isEmpty
                            ? Center(
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : Text(
                                        _statusMessage.isNotEmpty
                                            ? _statusMessage
                                            : 'No nutrition info found. Try refining your search.',
                                        style: GoogleFonts.manrope(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                              )
                            : ListView.builder(
                                itemCount: results.length,
                                itemBuilder: (context, index) {
                                  final food = results[index];
                                  final isSelected = identical(selection, food);
                                  final nutrition = food['nutrition_data'] as Map<String, dynamic>?;
                                  final calories = nutrition?['energy'] ?? nutrition?['calories'];
                                  final protein = nutrition?['protein'];
                                  final carbs = nutrition?['carbs'];
                                  final fat = nutrition?['fat'];
                                  final imageUrl = food['image_url']?.toString();
                                  return Container(
                                    height: 95,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color.fromRGBO(220, 250, 157, 0.9)
                                          : const Color.fromRGBO(220, 250, 157, 0.5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      onTap: () => context
                                          .read<ScanWorkflowProvider>()
                                          .selectManualResult(food),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: imageUrl != null
                                            ? Image.network(
                                                imageUrl,
                                                width: 53,
                                                height: 53,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Image.asset(
                                                  "assets/images/Food.png",
                                                  width: 53,
                                                  height: 53,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Image.asset(
                                                "assets/images/Food.png",
                                                width: 53,
                                                height: 53,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      title: Text(
                                        food['name']?.toString() ?? 'Food item',
                                        style: GoogleFonts.manrope(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        _buildSubtitle(calories, protein, carbs, fat),
                                        style: GoogleFonts.manrope(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  final query = _searchController.text.trim();
                                  await _performSearch(context, query);
                                },
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Search'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle(dynamic calories, dynamic protein, dynamic carbs, dynamic fat) {
    final values = <String>[];
    if (calories != null) {
      values.add('${_formatNumber(calories)} kcal');
    }
    if (protein != null) {
      values.add('Protein: ${_formatNumber(protein)}g');
    }
    if (carbs != null) {
      values.add('Carbs: ${_formatNumber(carbs)}g');
    }
    if (fat != null) {
      values.add('Fat: ${_formatNumber(fat)}g');
    }
    if (values.isEmpty) {
      return 'No nutrition details available';
    }
    return values.join(' | ');
  }

  String _formatNumber(dynamic value) {
    if (value is num) {
      return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
    }
    if (value is String) {
      return value;
    }
    return '0';
  }
}
