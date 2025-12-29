import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/Progress/progress_widgets/calories.dart';
import 'package:nuitro/Progress/progress_widgets/macros.dart';
import 'package:nuitro/Progress/progress_widgets/nutrients.dart';
import 'package:nuitro/models/progress_models.dart';
import 'package:nuitro/providers/progress_provider.dart';
import 'package:nuitro/screens/meal_diet/my_diets.dart';

class Progress extends StatefulWidget {
  const Progress({super.key});

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  final List<String> _tabs = ["Calories", "Macros", "Nutrients"];
  int _selectedIndex = 0;

  ProgressPeriod _selectedPeriod = ProgressPeriod.daily;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProgressProvider>();
      if (!provider.hasLoadedOnce) {
        provider.loadProgress(period: _selectedPeriod);
      }
    });
  }

  List<DropdownMenuItem<ProgressPeriod>> get _periodOptions {
    return ProgressPeriod.values
        .map(
          (period) => DropdownMenuItem<ProgressPeriod>(
            value: period,
            child: Text(period.displayLabel),
          ),
        )
        .toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<ProgressProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: provider.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Analytics Reports',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        TextButton(
                          onPressed: () {
                            debugPrint('[Progress] Get Diet Plan tapped');
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MyDietsPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(220, 250, 157, 1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              'Get Diet Plan',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 140,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: DropdownButton<ProgressPeriod>(
                        value: _selectedPeriod,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: _periodOptions,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedPeriod = value;
                          });
                          provider.setPeriod(value);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_tabs.length, (index) {
                        final isSelected = _selectedIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color.fromRGBO(220, 250, 157, 1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _tabs[index],
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    if (provider.isLoading && !provider.hasLoadedOnce)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      if (provider.errorMessage != null)
                        _ProgressWarningBanner(
                          message: provider.errorMessage!,
                          onRetry: provider.refresh,
                        ),
                      if (_selectedIndex == 0)
                        const Calories()
                      else if (_selectedIndex == 1)
                        const Macros()
                      else
                        const Nutrients(),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgressWarningBanner extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ProgressWarningBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Showing cached/placeholder data',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.manrope(fontSize: 13, color: Colors.orange.shade700),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => onRetry(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
