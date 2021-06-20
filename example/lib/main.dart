import 'package:flutter/material.dart';
import 'package:sftp_explorer_and_streaming/sftp_explorer_and_streaming.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "sftp_streamer",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ts(),
    );
  }
}

class ts extends StatefulWidget {
  @override
  _tsState createState() => _tsState();
}

class _tsState extends State<ts> {
  Map<String, String> headers = {
    "any_auth": "jgngsydnlopsns..." // put your headers
  };
  // in case of no header please pass empty map
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: init_sftp_streamer(
            direx: "/",
            path:
                "https://xyx.com/downloads/", // it should open directory of your files
            host: "xyx.com", //host name
            port: "54022", // sftp port
            password: "123456m", // sftp username

            username: "adminz", // sftp password
            network_headers: headers // network headers
            ));
  }
}
