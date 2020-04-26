import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:telit/helpers/database_helper.dart';
import 'package:telit/helpers/utility.dart';
import 'package:telit/models/crime_model.dart';
import 'package:telit/models/police_contacts.dart';
import 'package:telit/widgets/pop_up.dart';
import 'package:url_launcher/url_launcher.dart';

//import 'package:share/share.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';


class AddEmergency extends StatefulWidget
{

  final Function updateList;
  final Crime crime;

  AddEmergency({this.updateList, this.crime});
  @override
  _AddEmergencyState createState() => _AddEmergencyState();
}

class _AddEmergencyState extends State<AddEmergency>
{


  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _location = "";
  String _url = "";
  File _image;
  String _phone;
  Uint8List _img;
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();


  String _selected;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy').add_jm();
  List<String> _locations = ["Abia", "Akwa Ibom", "Anambra", "Bauchi", "Bayelsa", "Benue", "Borno", "Cross River", "Delta",
    "Ebonyi", "Edo", "Ekiti", "Enugu", "Gombe", "Imo", "Jigawa", "Kaduna", "Kano", "Katsina", "Kebbi", "Kogi", "Kwara",
    "Lagos", "Nasarawa", "Niger", "Ogun", "Ondo", "Osun", "Oyo", "Plateau", "Rivers", "Sokoto", "Taraba", "Yobe", "Zamfara", "FCT"];



  int index = 0;



  @override
  void initState(){
    super.initState();
    if(widget.crime != null)
    {
      _title = widget.crime.title;
      _location = widget.crime.location;
      _date = widget.crime.date;
      _img = Utility.imageFromBase64String(widget.crime.picture);


    }
    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose(){
    _dateController.dispose();
    super.dispose();
  }

  getPhone() async{
    PoliceContacts con =  await DatabaseHelper.instance.getPhone2(_location);
    _phone = con.phone;


  }
  _handleDatePicker() async{
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if(date != null && date != _date)
    {
      setState(() {
        _date = date;
      });
    }
    _dateController.text = _dateFormatter.format(date);
  }
  _submit(){
    if(_formKey.currentState.validate())
    {
      _formKey.currentState.save();

//      insert task into sqflite database
      Crime crime = Crime(title: _title, date: _date, location: _location, picture: _url);

      if(widget.crime == null){
        crime.status = 0;
        DatabaseHelper.instance.insertCrime(crime);
      }
      else{
        crime.id = widget.crime.id;
        crime.status = widget.crime.status;
        DatabaseHelper.instance.updateCrime(crime);
      }
//      update task in database

      widget.updateList();
      Navigator.pop(context);
    }
  }
  _delete(){
    DatabaseHelper.instance.deleteCrime(widget.crime.id);
    widget.updateList();
    Navigator.pop(context);
  }

  _handleImageFromGallery() async{

    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(imageFile != null)
    {
      String imgString = Utility.base64String(imageFile.readAsBytesSync());


    }
   String url = await DatabaseHelper.instance.uploadImage(_image);
   setState(() {
     _url = url;

   });

  }

  _pickImageFromGallery()
  {
    ImagePicker.pickImage(source: ImageSource.gallery).then((imgFile)
    {
      setState(() => _image = imgFile);
      String imgString = Utility.base64String(imgFile.readAsBytesSync());
      setState(() {
        _url = imgString;

      });
    });
  }


  _displayChatImage()
  {
    return GestureDetector(
      onTap: _pickImageFromGallery,
      child: Center(
        child: CircleAvatar(
            radius: 80.0,
            backgroundColor: Colors.grey[300],
            backgroundImage: _image != null ? FileImage(_image) : null,
            child: _image == null ?
            const Icon(
              Icons.add_a_photo,
              size: 50.0,
            ): null

        ),
      ),
    );
  }


  _displayImage(){
    return GestureDetector(

      child: new ListTile(
        leading: Image.memory(_img,
          fit: BoxFit.cover,
          width: 230.0,
          height: 80.0,
        ),
        onTap: ()async{
          await showDialog(
            context: context,
            builder: (_)=>ImageDialog(_img),
          );
        },
        onLongPress: (){},

      ),

    );
  }

  dialPhone() async
  {
    PoliceContacts con =  await DatabaseHelper.instance.getPhone2(_location);
    String phone = con.phone;

    String number = "tel:"+phone;
    launch(number);
    if (await canLaunch(number)) {
      await launch(number);
    } else {
      throw 'Could not place a call to $number';
    }

  }

  _sendSmS1()async{
    PoliceContacts con =  await DatabaseHelper.instance.getPhone2(_location);
    String phone = con.phone;

    String number = "sms:"+phone;
    launch(number);
    if (await canLaunch(number)) {
      await launch(number);
    } else {
      throw 'Could not write sms to $number';
    }
  }



  void _sendSMS2() async
  {

    String message;
    final DateFormat dateFormatter = DateFormat('MMMM dd, yyyy').add_jm();
    String date = dateFormatter.format(_date);
    PoliceContacts con =  await DatabaseHelper.instance.getPhone2(_location);
    String phone = con.phone;
    message = "This incident: $_title, happend on $date and I'm reporting from $_location";
    List<String> recipients = [phone];
   if(phone != null && phone.trim().isNotEmpty){
     String _result = await sendSMS(message: message, recipients: recipients)
         .catchError((onError) {
       print(onError);
     });

   }

  }

  callAmbulance() async{
    String phone = "112";
    String number = "tel:"+phone;
    launch(number);
    if (await canLaunch(number)) {
      await launch(number);
    } else {
      throw 'Could not place a call to $number';
    }
  }
  callFireService() async{
    String phone = "112";
    String number = "tel:"+phone;
    launch(number);
    if (await canLaunch(number)) {
      await launch(number);
    } else {
      throw 'Could not place a call to $number';
    }
  }

  Future<void> _shareImage() async {
    try {
      if(_image != null)
      {
        final ByteData bytes = await rootBundle.load(_image.readAsStringSync());
        _img = bytes.buffer.asUint8List();
      }
      else{
        _img = _img;
      }


      await Share.file(
          'TeLit', 'esys.png', _img, 'image/png',
          text: 'image share from TeLit');
    } catch (e) {
      print('error: $e');
    }
  }

  void choiceAction(PopUp pop)
  {
    setState(()
    {
      _selected = pop.option;

      if(_selected == 'Call Police')
      {
          dialPhone();


      }
      else if(_selected == 'Call Ambulance')
      {
          callAmbulance();
      }
      else if(_selected == 'Call Fire Service')
      {
          callFireService();
      }
      else if(_selected == 'Send Emergency Report To Police')
      {

          _sendSMS2();

      }
      else if(_selected == 'Share Image')
      {
        _shareImage();
      }
      else if(_selected == 'About')
      {

      }

    });
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(

      appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(33.0),
            child: Text(widget.crime == null ? 'Add Emergency' : 'Update Emergency', style: TextStyle(
                color: Colors.white70,
                fontSize: 20.0,
                fontWeight: FontWeight.bold
            ),
            ),

          ),
        actions: <Widget>[

          new PopupMenuButton(
             itemBuilder: (BuildContext context){
               return PopUp.pop.map((PopUp pop){
                 return new PopupMenuItem(
                   value: pop,

                   child: new ListTile(
                     title: pop.title,
                     leading: pop.icon,
                   ),

                 );

               }).toList();
             },
            onSelected: choiceAction,
          )

//          IconButton(
//            icon: Icon(Icons.more_vert, color: Colors.white70),
//            onPressed: ()=>_scaffoldKey.currentState.openDrawer(),
//          )
        ],
        ),


      body: GestureDetector(
        onTap: ()=>FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
//                GestureDetector(
//                  onTap: ()=>Navigator.pop(context),
//                  child: Icon(Icons.arrow_back_ios,
//                    size: 30.0,
//                    color: Theme.of(context).primaryColor,
//                  ),
//                ),
                SizedBox(height: 20.0),
//                Text(widget.crime == null ? 'Add Emergency' : 'Update Emergency', style: TextStyle(
//                    color: Colors.black,
//                    fontSize: 40.0,
//                    fontWeight: FontWeight.bold
//                ),
//                ),
                _img == null ? _displayChatImage() :_displayImage(),
                SizedBox(height: 5.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),

                        child: TextFormField(
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )
                          ),
                          validator: (input)=>input.trim().isEmpty ? "Please enter a title" : null,
                          onSaved: (input)=>_title = input.trim(),
                          initialValue: _title,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          style: TextStyle(fontSize: 18.0),
                          onTap: _handleDatePicker,
                          decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )
                          ),

                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),

                        child: DropdownButtonFormField(
                          isDense: true,
                          icon: Icon(Icons.arrow_drop_down_circle),
                          iconSize: 22.0,
                          iconEnabledColor: Theme.of(context).primaryColor,
                          items: _locations.map((String location){
                            return DropdownMenuItem(
                              value: location,
                              child: Text(
                                location, style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0
                              ),
                              ),

                            );
                          }).toList(),
                          style: TextStyle(fontSize: 14.0),
                          decoration: InputDecoration(
                              labelText: 'Location',
                              labelStyle: TextStyle(fontSize: 14.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )
                          ),
                          validator: (input)=>_location == null
                              ? "Please enter a location"
                              : null,
                          onChanged: (value)
                          {
                            setState(() {
                              _location = value;


                            });
                            getPhone();
                          },
                          value: _location.isNotEmpty ? _location : null,
                        ),

                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: FlatButton(
                          child: Text( widget.crime == null ? 'Add' : 'Update', style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold
                          ),
                          ),
                          onPressed:_submit,
                        ),
                      ),
                      widget.crime != null ? Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        child: FlatButton(
                          child: Text('Delete', style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold
                          ),
                          ),
                          onPressed:_delete,
                        ),
                      )
                          : SizedBox.shrink(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImageDialog extends StatelessWidget
{

  final Uint8List _img;

  ImageDialog(this._img);
  @override
  Widget build(BuildContext context)
  {
    return Dialog(
        child: Container(

          child: ListTile(
            leading: Image.memory(_img,
             fit: BoxFit.cover,
            ),

          ),
          ),

    );
  }
}

