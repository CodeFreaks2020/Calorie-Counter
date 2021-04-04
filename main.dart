import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:splashscreen/splashscreen.dart';


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Splash2(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class Splash2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 6,
      backgroundColor: Colors.black,
      navigateAfterSeconds: new SecondScreen(),
      title: new Text('Calorie Counter',textScaleFactor: 2,
      style: TextStyle(
        color: Colors.white,
      ),
      ),
      image: new Image.network('https://png.pngtree.com/png-clipart/20190517/original/pngtree-vegetables-and-fruits-forming-of-lettering-calories.-png-image_3741505.jpg'),
      loadingText: Text("Loading"),
      photoSize: 100.0,
      loaderColor: Colors.blue,
    );
  }


}


class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File _imageFile;
  List _classifiedResult;

  @override
  void initState() {
    super.initState();
    loadImageModel();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: Text("Calorie Counter"),
      ),
      backgroundColor: Colors.blueGrey[900],
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
              border: Border.all(color: Colors.transparent),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(2, 2),
                  spreadRadius: 2,
                  blurRadius: 1,
                ),
              ],
            ),
            child: (_imageFile != null)?
            Image.file(_imageFile) :
            Image.network('https://i.imgur.com/sUFH1Aq.png')
          ),
          Row(

            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text("Select the Image : ",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w200,

                ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey,
                    onPrimary: Colors.white,
                    //shadowColor: Colors.red,
                    elevation: 10,
                  ),
                  onPressed: (){
                    selectImage();
                  },
                  child: Icon(Icons.photo_album)
              ),

              SizedBox(
                width: 20,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey,
                    onPrimary: Colors.white,
                    //shadowColor: Colors.red,
                    elevation: 10,
                  ),
                  onPressed: (){
                    getImage();
                  },
                  child: Icon(Icons.camera_enhance_sharp)
              ),


            ],
          ),
          SizedBox(
           height: 30,
          ),
          Container(
            child: Text("Predicted result:",
            style: TextStyle(
              fontSize: 25,
              color: Colors.lightBlue,
              fontWeight: FontWeight.w500,
            ),),
          ),
          SizedBox(
            height: 20,
          ),

          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
              _classifiedResult != null
                  ? _classifiedResult.map((result) {
                      return Text(
                       "${result['label']}".substring(2).toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      );
                    }).toList()
                  : [],
            ),
          ),

        ],
      ),
    );
  }

  Future loadImageModel() async {
    Tflite.close();
    String result;
    result = await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",

      // model: "assets/catdog_model.tflite",
      // labels: "assets/cat_dog_labels.txt",
    );
    print(result);
  }

  Future selectImage() async {
    final picker = ImagePicker();
    var image = await picker.getImage(source: ImageSource.gallery, maxHeight: 300);
    classifyImage(image);
  }

  Future getImage() async {
    File _image;
    final picker = ImagePicker();
    var image1 = await picker.getImage(source: ImageSource.camera);
    setState(() {
      _image = File(image1.path);
    });
    classifyImage(_image);

  }

  Future classifyImage(image) async {
    _classifiedResult = null;
    // Run tensorflowlite image classification model on the image
    print("classification start $image");
    final List result = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    print("classification done");
    print(result);
    setState(() {
      if (image != null) {
        _imageFile = File(image.path);
        _classifiedResult = result;
      } else {
        print('No image selected.');
      }
    });
  }

}
