import 'package:flutter/material.dart';
import 'package:forcegauge/models/tabata/report.dart';
import 'package:forcegauge/screens/tabata_tab/report_graph.dart';

class ReportScreen extends StatefulWidget {
  final WorkoutReport workoutReport;

  const ReportScreen(this.workoutReport);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Widget makeReportView(List<ReportValues> reports) {
    var table = Table(border: TableBorder.all(), // Allows to add a border decoration around your table
        children: [
          TableRow(children: [
            Text('Workout', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Min', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Max', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Average', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Graph', style: TextStyle(fontWeight: FontWeight.bold)),
            //TextButton(onPressed: onPressed, child: Text("+"));
          ]),
        ]);
    for (var report in reports) {
      var reportWidget = TableRow(children: [
        Text("Set: ${report.set}, Rep: ${report.rep}"),
        Text(report.getMin().toStringAsFixed(1)),
        Text(report.getMax().toStringAsFixed(1)),
        Text(report.getAverage().toStringAsFixed(1)),
        IconButton(
            icon: Icon(Icons.show_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  //builder: (context) => Container(),
                  builder: (context) => ReportGraph(report),
                ),
              );
            })
      ]);
      table.children.add(reportWidget);
    }
    return table;
  }

  @override
  Widget build(BuildContext context) {
    var reportScreen = makeReportView(widget.workoutReport.getAllReports());

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("", style: TextStyle(fontSize: 20.0)),
              Text("Report", style: TextStyle(fontSize: 60.0)),
              reportScreen,
            ],
          ),
        ),
      ),
    );
  }
}
