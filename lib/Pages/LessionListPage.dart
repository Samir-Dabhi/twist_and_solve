
import 'package:twist_and_solve/Components/Timer.dart';
import 'package:twist_and_solve/Pages/HomePage.dart';
import 'package:twist_and_solve/Pages/LessionListPage.dart';
import 'package:twist_and_solve/Pages/TimeListPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Lessionlistpage extends StatefulWidget {
  const Lessionlistpage({super.key});
  @override
  State<Lessionlistpage> createState() => _LessionlistpageState();
}

class _LessionlistpageState extends State<Lessionlistpage> {
  Future<List<String>?> getPreferences() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('LessionList');
  }
  Future<List<String>?> setPreferences() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('LessionList');
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
                return const Center(child: Text('No Lessons found.'));
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
                              timeList.removeAt(index); // This modification is local
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
