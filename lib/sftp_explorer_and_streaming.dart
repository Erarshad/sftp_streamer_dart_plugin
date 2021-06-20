import 'dart:io';

import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sftp_explorer_and_streaming/image_streamer.dart';
import 'package:ssh/ssh.dart';
import 'package:sftp_explorer_and_streaming/video_dir.dart';
import 'package:sftp_explorer_and_streaming/web_spacer.dart';
import 'package:url_launcher/url_launcher.dart';

// class view extends StatefulWidget {
//   @override
//   _viewState createState() => _viewState();
// }

// class _viewState extends State<view> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "sftp explorer",
//       theme: ThemeData(primarySwatch: Colors.red),
//       home: files(
//         direx: "/",
//         path: "https://fremicro045.xirvik.com/downloads/",

//       ),
//     );
//   }
// }

class init_sftp_streamer extends StatefulWidget {
  final String direx;
  String path;
  final String host;
  final String port;
  final String username;
  final String password;
  final Map<String, String> network_headers;
  final TextStyle tile_style;
  init_sftp_streamer(
      {Key key,
      @required this.direx,
      @required this.path,
      @required this.host,
      @required this.port,
      @required this.password,
      @required this.username,
      this.network_headers,
      this.tile_style})
      : super(key: key);
  @override
  _init_sftp_streamerState createState() => _init_sftp_streamerState(
      direx: direx,
      path: path,
      host: host,
      network_headers: network_headers,
      password: password,
      port: port,
      username: username,
      tile_style: tile_style);
}

class _init_sftp_streamerState extends State<init_sftp_streamer> {
  final String direx;
  String path;
  final String host;
  final String port;
  final String username;
  final String password;
  final Map<String, String> network_headers;
  final TextStyle tile_style;

  _init_sftp_streamerState(
      {Key key,
      @required this.direx,
      @required this.path,
      @required this.host,
      @required this.port,
      @required this.username,
      @required this.password,
      this.network_headers,
      @required this.tile_style});
  bool get_connected = false;
  Future<List<dynamic>> directories;
  var client;

  Future<List<dynamic>> fetch_file() async {
    client = new SSHClient(
      host: host,
      port: int.parse(port),
      username: username,
      passwordOrKey: password,
    );
    try {
      String result = await client.connect();
      if (result == "session_connected") {
        result = await client.connectSFTP();
        if (result == "sftp_connected") {
          setState(() {
            directories = client.sftpLs(direx);
          });

          return directories;
        }
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
  }

  //--
  @override
  void initState() {
    super.initState();
    fetch_file();
  }

  void toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      fontSize: 16.0,
      backgroundColor: Colors.black,
    );
  }

  Icon handle_file_icon(String file_name) {
    if (file_name.toLowerCase().contains(".mp3")) {
      //mp3  or music file
      return Icon(
        Icons.music_note,
        size: 45.0,
      );
    } else if (file_name.toLowerCase().contains(".mp4") ||
        file_name.toLowerCase().contains(".mkv") ||
        file_name.toLowerCase().contains(".avi") ||
        file_name.toLowerCase().contains(".3gp")) {
      return Icon(
        Icons.movie,
        size: 45.0,
      );
    } else if (file_name.toLowerCase().contains(".jpg") ||
        file_name.toLowerCase().contains(".jpeg") ||
        file_name.toLowerCase().contains(".png")) {
      return Icon(
        Icons.image,
        size: 45.0,
      );
    } else if (file_name.toLowerCase().contains(".pdf") ||
        file_name.toLowerCase().contains(".doc") ||
        file_name.toLowerCase().contains(".docs") ||
        file_name.toLowerCase().contains(".xls") ||
        file_name.toLowerCase().contains(".xlsx") ||
        file_name.toLowerCase().contains(".ppt") ||
        file_name.toLowerCase().contains(".pptx")) {
      return Icon(
        Icons.book,
        size: 45.0,
      );
    } else {
      return Icon(
        Icons.file_copy,
        size: 45.0,
      );
    }
  }

  void check_format(String path, String file_name) {
    if (file_name.toLowerCase().contains(".mp3") ||
        (file_name.toLowerCase().contains(".mp4") ||
            file_name.toLowerCase().contains(".mkv") ||
            file_name.toLowerCase().contains(".avi") ||
            file_name.toLowerCase().contains(".3gp"))) {
      //mp3  or music file
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => media_stream(
                    selected_file: path,
                    file_name: file_name,
                    headers: network_headers,
                  )));
    } else if (file_name.toLowerCase().contains(".jpg") ||
        file_name.toLowerCase().contains(".jpeg") ||
        file_name.toLowerCase().contains(".png")) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => img(
                    path: path,
                    headers: network_headers,
                  )));
    } else if (file_name.toLowerCase().contains(".pdf") ||
        file_name.toLowerCase().contains(".doc") ||
        file_name.toLowerCase().contains(".docs") ||
        file_name.toLowerCase().contains(".xls") ||
        file_name.toLowerCase().contains(".xlsx") ||
        file_name.toLowerCase().contains(".ppt") ||
        file_name.toLowerCase().contains(".pptx")) {
      launchInBrowser(path);
    } else {
      toastMessage("file doesnot supported to open, You can download file");
    }
  }

  Future<void> launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: network_headers,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  String selected_file = "";

  void rename(String dir, String selected_file, String new_name) async {
    // for rename folder/nameof file
    try {
      await client.sftpRename(
          oldPath: dir + selected_file, newPath: dir + new_name);
    } catch (e) {
      print(e);
    }
  }

  //----------------------------------------------------
  void create_folder(String direcx, String name) async {
    try {
      // '/' is path
      await client.sftpMkdir(direcx + name);
    } catch (e) {
      print(e);
    }
  }

  //--------
  void removefolder(String directory, String selected_file) async {
    try {
      // / is path
      await client.sftpRmdir(directory + selected_file);
    } catch (e) {
      print(e);
    }
  }

  TextEditingController text_controller = TextEditingController();

  Text title_handler_alert_box(int widget_id) {
    if (widget_id == 1) {
      return Text("Rename");
    } else if (widget_id == 2) {
      return Text("Create Folder");
    } else if (widget_id == 3) {
      return Text("Delete");
    }
  }

  Widget content_handler_alert_box(int widget_id) {
    if (widget_id == 1) {
      return TextField(
        controller: text_controller,
        decoration: InputDecoration(hintText: "Enter new name"),
      );
    } else if (widget_id == 2) {
      return TextField(
        controller: text_controller,
        decoration: InputDecoration(hintText: "Enter folder name"),
      );
    } else if (widget_id == 3) {
      return Text("Are you sure to delete this");
    }
  }

  Text handle_confirmation_button(int widget_id) {
    if (widget_id == 1) {
      return Text("Change");
    } else if (widget_id == 2) {
      return Text("Create");
    } else if (widget_id == 3) {
      return Text("Yes");
    }
  }

  //---------------------------------------------------------------------------
  Future<void> promptwith_input(BuildContext context, int widget_id,
      String directory, String selected) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: title_handler_alert_box(widget_id),
            content: content_handler_alert_box(widget_id),
            actions: [
              FlatButton(
                  onPressed: () {
                    if (widget_id == 1) {
                      if (text_controller.text.length > 0) {
                        rename(directory, selected,
                            text_controller.text.toString());
                        // refresh
                        setState(() {
                          directories = fetch_file();
                        });
                        Navigator.of(context).pop();
                      } else {
                        print("please enter text");
                      }
                    } else if (widget_id == 2) {
                      if (text_controller.text.length > 0) {
                        create_folder(direx, text_controller.text.toString());
                        setState(() {
                          directories = fetch_file();
                        });
                        Navigator.of(context).pop();
                      } else {
                        print("directory name is empty");
                      }
                    } else if (widget_id == 3) {
                      removefolder(direx, selected);
                      setState(() {
                        directories = fetch_file();
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: handle_confirmation_button(widget_id)),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"))
            ],
          );
        });
  }
  //--------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(direx),
          actions: [
            IconButton(
                icon: Icon(Icons.create_new_folder),
                onPressed: () {
                  // toadd new folder
                  promptwith_input(context, 2, direx, "");
                })
          ],
        ),
        body: FutureBuilder<List<dynamic>>(
            future: directories,
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                //------------
                return Center(child: new CircularProgressIndicator());
              } else {
                return ListView.builder(
                    // where snapshot data means here is torrent=snapshot.data

                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          child: ListTile(
                            trailing:
                                snapshot.data[index]['isDirectory'] == false
                                    ? IconButton(
                                        icon: Icon(Icons.download_rounded),
                                        onPressed: () {
                                          String temp = path +
                                              snapshot.data[index]['filename']
                                                  .toString();
                                          temp = remove_space.remove(temp);
                                          // handle url launcher
                                          launchInBrowser(temp);
                                        })
                                    : new Container(
                                        height: 0.0,
                                        width: 0.0,
                                      ),
                            leading: snapshot.data[index]['isDirectory']
                                ? Icon(
                                    Icons.folder,
                                    size: 45.0,
                                  )
                                : handle_file_icon(
                                    snapshot.data[index]['filename']),
                            title: Text(
                              snapshot.data[index]['filename'],
                              style: tile_style,
                            ),
                            subtitle: Text(
                              "Last Access: " +
                                  snapshot.data[index]['lastAccess'] +
                                  " " +
                                  "\nPermissions: " +
                                  snapshot.data[index]['permissions'] +
                                  "\nSize: " +
                                  filesize(snapshot.data[index]['fileSize'])
                                      .toString(),
                              style: tile_style,
                            ),
                            onTap: () {
                              //--------------------------------------
                              if (snapshot.data[index]['isDirectory'] == true) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            init_sftp_streamer(
                                              direx: direx +
                                                  snapshot.data[index]
                                                      ['filename'] +
                                                  "/",
                                              path: path +
                                                  snapshot.data[index]
                                                          ['filename']
                                                      .toString() +
                                                  "/",
                                              host: host,
                                              network_headers: network_headers,
                                              password: password,
                                              port: port,
                                              username: username,
                                              tile_style: tile_style,
                                            )));
                              } else {
                                // here we will not override the real path
                                String temp = path +
                                    snapshot.data[index]['filename'].toString();
                                temp = remove_space.remove(temp);
                                print(temp);
                                // we need to stream media when i  get the music or video
                                check_format(
                                    temp, snapshot.data[index]['filename']);
                              }
                            },
                          ),
                          secondaryActions: <Widget>[
                            IconSlideAction(
                                caption: 'Rename',
                                color: Colors.blue,
                                icon: Icons.edit,
                                onTap: () {
                                  promptwith_input(context, 1, direx,
                                      snapshot.data[index]['filename']);
                                }),
                            IconSlideAction(
                                caption: 'Delete',
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () {
                                  promptwith_input(context, 3, direx,
                                      snapshot.data[index]['filename']);
                                }),
                          ]);
                    });
              }
            }));
  }
}
