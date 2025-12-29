import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nuitro/providers/scan_workflow_provider.dart';

class Logs extends StatefulWidget {
  const Logs({Key? key}) : super(key: key);

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  final TextEditingController _searchController = TextEditingController();
  bool _controllerInitialized = false;
  bool _initialFetchTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_initialFetchTriggered) {
        _initialFetchTriggered = true;
        context.read<ScanWorkflowProvider>().loadLogs(forceRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final workflow = context.watch<ScanWorkflowProvider>();

    if (!_controllerInitialized) {
      _searchController.text = workflow.logsQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
      _controllerInitialized = true;
    }

    final results = workflow.logsResults;
    final isLoading = workflow.logsLoading;
    final selected = workflow.logsSelection;
    final totalCount = workflow.logsTotalCount;
    final heading = totalCount > 0 ? 'Logs - $totalCount' : 'Logs';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [Container(width:double.infinity, decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage("assets/images/Food.png"),
              fit: BoxFit.cover,
            ),
          ),),

            Padding(padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
              child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [Text(heading,style:TextStyle(fontSize: 24,fontWeight:FontWeight.w600,color: Colors.white,) ,),
                IconButton(
                  icon: const Icon(Icons.cancel_sharp, color: Colors.black,size: 40,),
                  onPressed: (){},

              ),],),
            ),

            Column(
            children: [
              SizedBox(height: 80,),
              /// Sticky Header
              // FoodDetailHeader(
              //   foodName: '',
              //   servingSize: "",
              //   imageUrl: "assets/images/Food.png",
              //   onBack: () => Navigator.pop(context),
              //   onFavorite: () => print("Favorite clicked"),
              // ),
          
              /// White Rounded Container
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        /// Search Bar
                        Container(alignment: Alignment.center,
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
                                  decoration:  InputDecoration(
                                    hintText: "Search food",hintStyle: GoogleFonts.zenKakuGothicAntique(
                                      fontWeight: FontWeight.w500,fontSize: 12

                                  ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10), // 👈 radius
                                      borderSide: BorderSide.none,             // removes visible border
                                    ),


                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 30,  // height padding
                                    horizontal: 10, // left/right padding
                                  ), ),
                                  onChanged: workflow.updateLogsQuery,
                                  onSubmitted: (_) => workflow.searchLogs(),

                                ),
                              ),
                              if (workflow.logsQuery.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    workflow.updateLogsQuery('');
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () => workflow.searchLogs(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (workflow.logsError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              workflow.logsError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        Expanded(
                          child: isLoading && results.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : results.isEmpty
                                  ? const Center(
                                      child: Text("No food logs found for today."),
                                    )
                                  : ListView.builder(
                                      itemCount: results.length,
                                      itemBuilder: (context, index) {
                                        final item = results[index];
                                        final name = item['name']?.toString() ?? 'Food item';
                                        final description = item['description']?.toString() ??
                                            item['summary']?.toString() ?? '';
                                        final timeLabel = item['captured_display']?.toString();
                                        final isSelected = workflow.logsSelection?['id'] == item['id'];
                                        return Card(
                                          color: isSelected
                                              ? const Color.fromRGBO(220, 250, 157, 0.7)
                                              : Colors.white,
                                          child: ListTile(
                                            onTap: () => workflow.selectLogsResult(item),
                                            title: Text(
                                              name,
                                              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                                            ),
                                            subtitle:
                                                description.isNotEmpty ? Text(description) : null,
                                            trailing: timeLabel != null && timeLabel.isNotEmpty
                                                ? Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        timeLabel,
                                                        style: GoogleFonts.manrope(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : null,
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
            ],
          ),]
        ),
      ),
    );
  }
}