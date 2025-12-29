import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/models/api_reponse.dart';
import 'package:nuitro/providers/scan_workflow_provider.dart';
import 'package:nuitro/home/Notifications/manual_log_search_result.dart';
import 'package:nuitro/home/Notifications/manual_log_card.dart';

class ManualLog extends StatefulWidget {
  const ManualLog({Key? key}) : super(key: key);

  @override
  State<ManualLog> createState() => _ManualLogState();
}

class _ManualLogState extends State<ManualLog> {
  final TextEditingController _controller = TextEditingController();
  bool _controllerInitialized = false;
  Timer? _debounce;
  bool _programmaticEdit = false;

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openManualLogCard(BuildContext context) async {
    final workflow = context.read<ScanWorkflowProvider>();
    final query = workflow.manualQuery.trim();
    if (query.isEmpty) {
      _showSnack(context, 'Enter food details before logging manually');
      return;
    }

    final response = await workflow.predictManualFood();
    if (!mounted) {
      return;
    }

    if (!response.status) {
      _showSnack(context, response.message);
      return;
    }

    if (workflow.manualResults.isEmpty) {
      _showSnack(context, 'No nutrition info found for "$query"');
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ManualLogCard(),
      ),
    );
  }

  Future<ApiResponse> _handleSearch(BuildContext context,
      {bool suppressErrors = false}) async {
    final workflow = context.read<ScanWorkflowProvider>();
    final response = await workflow.searchManualFoods();
    if (!mounted) {
      return response;
    }
    if (!response.status && !suppressErrors) {
      _showSnack(context, response.message);
    } else if (response.status && workflow.manualResults.isEmpty &&
        !_controller.text.trim().isEmpty && !suppressErrors) {
      _showSnack(context, 'No matches found for "${workflow.manualQuery}"');
    }
    return response;
  }

  Future<void> _openResults(BuildContext context) async {
    final workflow = context.read<ScanWorkflowProvider>();
    final query = workflow.manualQuery.trim();
    if (query.isEmpty) {
      _showSnack(context, 'Enter food details to search');
      return;
    }

    final response = await workflow.predictManualFood();
    if (!mounted) {
      return;
    }
    if (!response.status) {
      _showSnack(context, response.message);
      return;
    }

    final results = workflow.manualResults
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);

    if (results.isEmpty) {
      _showSnack(context, 'No nutrition info found for "$query"');
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManualLogSearchResult(
          initialResults: results,
          initialQuery: query,
        ),
      ),
    );
  }

  void _setControllerText(String value) {
    if (_controller.text == value) {
      return;
    }
    _programmaticEdit = true;
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _programmaticEdit = false;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controllerInitialized) {
      final workflow = context.read<ScanWorkflowProvider>();
      _controller.text = workflow.manualQuery;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      _controllerInitialized = true;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workflow = context.watch<ScanWorkflowProvider>();
    final results = workflow.manualResults;

    if (!_programmaticEdit && _controller.text != workflow.manualQuery) {
      _setControllerText(workflow.manualQuery);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Manual Log",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(35, 34, 32, 1),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  Text(
                    "Log Manually or Deep Search",
                    style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Search e.g : Seafood with 1000 calories",
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (workflow.manualSelection != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Chip(
                        backgroundColor: const Color.fromRGBO(220, 250, 157, 1),
                        label: Text(
                          workflow.manualSelection?['name']?.toString() ?? 'Selected',
                          style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                        ),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => workflow.clearManualSelection(),
                      ),
                    ),
                  if (workflow.manualError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        workflow.manualError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (workflow.manualLoading && results.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (!workflow.manualLoading && results.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'Suggestions',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ...results.map((result) {
                    final isSelected = identical(workflow.manualSelection, result);
                    final name = result['name']?.toString() ?? 'Food item';
                    final description = result['description']?.toString() ??
                        result['nutrition_summary']?.toString() ?? '';
                    return Card(
                      color: isSelected
                          ? const Color.fromRGBO(220, 250, 157, 0.7)
                          : Colors.white,
                      child: ListTile(
                        onTap: () async {
                          workflow.selectManualResult(result);
                          _setControllerText(workflow.manualQuery);
                          FocusScope.of(context).unfocus();
                        },
                        title: Text(name,
                            style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                        subtitle: description.isNotEmpty ? Text(description) : null,
                        trailing: Icon(
                          isSelected ? Icons.check_circle : Icons.add_circle_outline,
                          color: isSelected ? Colors.green : Colors.black54,
                        ),
                      ),
                    );
                  }),
                  if (workflow.manualLoading && results.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (workflow.manualLoading) {
                        return;
                      }
                      FocusScope.of(context).unfocus();
                      await _openManualLogCard(context);
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(220, 250, 157, 1),
                        shape: BoxShape.circle,
                      ),
                      child: workflow.manualLoading
                          ? const Padding(
                              padding: EdgeInsets.all(14.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Icon(Icons.add, color: Colors.black, size: 30),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _controller,
                            onChanged: (value) {
                              if (_programmaticEdit) {
                                return;
                              }
                              workflow.updateManualQuery(value);
                              if (_debounce?.isActive ?? false) {
                                _debounce?.cancel();
                              }
                              if (value.trim().length >= 2) {
                                _debounce = Timer(const Duration(milliseconds: 350), () {
                                  if (mounted) {
                                    _handleSearch(context, suppressErrors: true);
                                  }
                                });
                              }
                            },
                            onSubmitted: (_) async {
                              await workflow.predictManualFood();
                              if (!mounted) return;
                              await _openResults(context);
                            },
                            decoration: InputDecoration(
                              hintText: "Search food",
                              border: InputBorder.none,
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.search, color: Colors.black87, size: 24),
                                    onPressed: () async {
                                      await workflow.predictManualFood();
                                      if (!mounted) return;
                                      await _openResults(context);
                                    },
                                  ),
                                  // IconButton(
                                  //   icon: const Icon(Icons.add_circle_outline, color: Colors.black87, size: 26),
                                  //   onPressed: () => _openResults(context),
                                  // ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
