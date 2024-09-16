import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';

class SensorTrackingScreen extends StatefulWidget {
  @override
  _SensorTrackingScreenState createState() => _SensorTrackingScreenState();
}

class _SensorTrackingScreenState extends State<SensorTrackingScreen> {
  // Data lists for graphs
  List<_SensorData> gyroData = [];
  List<_SensorData> accelData = [];

  int sampleIndex = 0;
  double threshold = 2.0; // Threshold for triggering alert

  // Subscriptions for sensor events
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    startSensorListeners();
  }

  @override
  void dispose() {
    _gyroscopeSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void startSensorListeners() {
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        if (gyroData.length > 50) {
          gyroData.removeAt(0);
        }
        gyroData.add(
            _SensorData(sampleIndex.toDouble(), event.x, event.y, event.z));
        sampleIndex++;
        checkForAlert(event.x, event.y);
      });
    });

    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        if (accelData.length > 50) {
          accelData.removeAt(0);
        }
        accelData.add(
            _SensorData(sampleIndex.toDouble(), event.x, event.y, event.z));
        checkForAlert(event.x, event.y);
      });
    });
  }

  // Check if values exceed the threshold
  void checkForAlert(double x, double y) {
    if ((x.abs() > threshold && y.abs() > threshold)) {
      showAlert();
    }
  }

  void showAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "ALERT !",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF33CCCC)),
          ),
          content: Text(
            "High movement detected on multiple axes!",
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Color(0xFF585858)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF33CCCC)),
              ),
            ),
          ],
        );
      },
    );
  }

  // Graph widget for gyroscope and accelerometer data
  Widget buildGraph(String title, List<_SensorData> data, String dataType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2)
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(
                  interval: 1,
                  title: AxisTitle(text: 'Samples'),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(
                      text: dataType,
                      textStyle: TextStyle(fontSize: 8),
                      alignment: ChartAlignment.near),
                ),
                series: <LineSeries<_SensorData, double>>[
                  LineSeries<_SensorData, double>(
                    dataSource: data,
                    xValueMapper: (_SensorData data, _) => data.index,
                    yValueMapper: (_SensorData data, _) => data.x,
                    color: Colors.red,
                    name: 'X Axis',
                  ),
                  LineSeries<_SensorData, double>(
                    dataSource: data,
                    xValueMapper: (_SensorData data, _) => data.index,
                    yValueMapper: (_SensorData data, _) => data.y,
                    color: Colors.green,
                    name: 'Y Axis',
                  ),
                  LineSeries<_SensorData, double>(
                    dataSource: data,
                    xValueMapper: (_SensorData data, _) => data.index,
                    yValueMapper: (_SensorData data, _) => data.z,
                    color: Colors.blue,
                    name: 'Z Axis',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Sensor Tracking'),
      ),
      body: Column(
        children: [
          buildGraph('Gyroscope', gyroData, 'Gyroscope Sensor Data (rad/s)'),
          buildGraph(
              'Accelerometer', accelData, 'Accelerometer Sensor Data (rad/s)'),
        ],
      ),
    );
  }
}

class _SensorData {
  _SensorData(this.index, this.x, this.y, this.z);

  final double index;
  final double x;
  final double y;
  final double z;
}
