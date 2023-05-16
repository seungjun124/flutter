import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MySQL Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _dataList = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://10.0.2.2/api/schoolSearch.php?search=${_searchController.text}'));
    if (response.statusCode == 200) {
      setState(() {
        _dataList = (json.decode(response.body) as List<dynamic>).cast<Map<String, dynamic>>();
      });
    } else {
      print('Failed to fetch data');
    }
  }

  Future<void> fetchDetails(String name) async {
    final response = await http.get(Uri.parse('http://10.0.2.2/api/schoolSELECT.php?name=$name'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;
      if (jsonData.isNotEmpty) {
        List<Map<String, dynamic>> itemList = [];
        for (var i = 0; i <= jsonData.length - 1; i++) {
          final item = jsonData[i];
          itemList.add(item);
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(jsonDataList: itemList),
          ),
        );
      } else {
        print('No data found');
      }
    } else {
      print('Failed to fetch details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('학사일정'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '학교 이름을 검색하세요.',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              fetchData();
            },
            child: Text('검색'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _dataList.length,
              itemBuilder: (context, index) {
                final data = _dataList[index];
                return ListTile(
                  title: Text(data['name']),
                  onTap: () {
                    fetchDetails(data['name'].toString());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  final List<Map<String, dynamic>> jsonDataList;
  final String? selectedMonth;

  const DetailsPage({required this.jsonDataList, this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredDataList = selectedMonth != null
        ? jsonDataList.where((data) => data['month'] == selectedMonth).toList()
        : jsonDataList;

    return Scaffold(
      appBar: AppBar(
        title: Text(filteredDataList.isNotEmpty ? '${filteredDataList[0]['year']}년 ${filteredDataList[0]['name']}' : 'No data found'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = (index + 1).toString().padLeft(2, '0'); // Format the month as "01", "02", etc.
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('$month월 일정'),
                  content: Column(
                    children: filteredDataList
                        .where((data) => data['month'] == month)
                        .map((data) => Text('${data['month']}월${data['day']}일: ${data['comment']}'))
                        .toList(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('닫기'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 132, 255),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  '$month월',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

