import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeList extends StatefulWidget {

  @override
  State<TimeList> createState() => _TimeListState();
}

class _TimeListState extends State<TimeList> {
  Future<List<String>?> getPreferences() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('TimeList');
  }
  void removeTimeFromPreference(int index) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list;
    if(prefs.getStringList('TimeList')==null){
      prefs.setStringList("TimeList", List.empty());
    }
    list = prefs.getStringList('TimeList');
    list?.removeAt(index);
    print(list?.remove(index));
    prefs.setStringList('TimeList', list!);
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<List<String>?>(
            future: getPreferences(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No records found.'));
              } else {
                final timeList = snapshot.data!;
                return GridView.builder(
                  itemCount: timeList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    mainAxisExtent: 50,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: const BorderRadius.all(Radius.circular(7)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Record text
                          Text(timeList[index]),
                          // Delete Button
                          IconButton(
                            onPressed: () {
                              // timeList.removeAt(index); // This modification is local
                              removeTimeFromPreference(index);
                              setState(() {});
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

}
