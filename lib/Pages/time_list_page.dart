import 'package:flutter/material.dart';
import '../Service/solve_service.dart';

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
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this solve record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel",style: TextStyle(
              color: Colors.black26
            ),),
          ),
          TextButton(
            onPressed: () {
              removeSolveFromApi(solveId);
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
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
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No records found.', style: TextStyle(fontSize: 18)));
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
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(
                        ((timeList[index].solveTime.toString()+'00').substring(0,5)),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(index, timeList[index].solveId),
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