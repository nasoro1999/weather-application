import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController locationController = TextEditingController();
  String weatherResult = '';
  bool isLoading = false;

  Future<void> getWeather(String location) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/weather?location=$location'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          weatherResult = '''
            Weather in $location:
            Min Temperature: ${data['min_temperature']}°C
            Max Temperature: ${data['max_temperature']}°C
            Conditions: ${data['headline_text']}
            Day Precipitation Type: ${data['day_precipitation_type']}
            Night Precipitation Type: ${data['night_precipitation_type']}
          ''';
        });
      } else {
        setState(() {
          weatherResult = 'Error fetching weather data. Please check your location.';
        });
      }
    } catch (error) {
      setState(() {
        weatherResult = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> showNetworkErrorDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Network Error'),
          content: Text('Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Enter Location'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Check for internet connection before making the request
                if (isLoading) return;
                if (!isInternetConnected()) {
                  showNetworkErrorDialog();
                  return;
                }
                getWeather(locationController.text);
              },
              child: isLoading ? CircularProgressIndicator() : const Text('Get Weather'),
            ),
            const SizedBox(height: 16.0),
            Text(weatherResult),
          ],
        ),
      ),
    );
  }

  bool isInternetConnected() {
    // Replace this with your own logic to check internet connection
    // For simplicity, always assume there is an internet connection
    return true;
  }
}
