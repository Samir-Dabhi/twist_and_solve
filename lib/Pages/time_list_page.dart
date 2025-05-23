import 'package:flutter/material.dart';
import 'package:twist_and_solve/Components/ErrorPage.dart';
import '../Service/solve_service.dart';
import 'package:intl/intl.dart';

class TimeList extends StatefulWidget {
  @override
  State<TimeList> createState() => _TimeListState();
}

class _TimeListState extends State<TimeList> {
  Future<List<SolveModel>?> getPreferences() async {
    return await fetchSolvesByUserId();
  }

  Future<void> _confirmDelete(int index, int solveId) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Record",style: TextStyle(color: Color(0xFF00ADB5)),),
        content: const Text("Are you sure you want to delete this solve record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black26),
            ),
          ),
          TextButton(
            onPressed: () {
              removeSolveFromApi(solveId);
              setState(() {}); // Refresh list after deletion
              Navigator.of(context).pop();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSolveDetailsPopup(BuildContext context, SolveModel solve) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Center(
              child: Text("Solve Details", style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF00ADB5)))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: const Text("Scramble", style: TextStyle(fontWeight: FontWeight.bold))),
              Center(
                child: Text(solve.scramble ?? "N/A",
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              _buildDetailRow("Solve Time", "${solve.solveTime.toStringAsFixed(2)} sec"),
              _buildDetailRow("Solve Date", DateFormat('yyyy-MM-dd').format(solve.solveDate)),
              _buildDetailRow("Method", solve.method ?? "N/A"),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close",style: TextStyle(color: Colors.black54),),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Solve Records"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FutureBuilder<List<SolveModel>?>(
            future: getPreferences(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                if(snapshot.error.toString().contains("No solves found for user ID")){
                  return const ErrorComponent(ErrorText: 'No Solve Record Found !!!',);
                }
                else{
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('No records found.', style: TextStyle(fontSize: 18)));
              }

              final timeList = snapshot.data!;
              return GridView.builder(
                itemCount: timeList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 60,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showSolveDetailsPopup(context, timeList[index]),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: Text(
                          (('${timeList[index].solveTime}00').substring(0, 5)),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(index, timeList[index].solveId),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
