
import 'package:flutter/material.dart';

class PopUp{
  final Text title;
  final Icon icon;
  final String option;
   const PopUp({this.title, this.icon, this.option});

   static const List<PopUp> pop = <PopUp>[
      PopUp(title: Text('Call Police'), icon: const Icon(Icons.call), option: 'Call Police'),
      PopUp(title: Text('Call Ambulance'), icon: const Icon(Icons.local_hospital), option: 'Call Ambulance'),
      PopUp(title: Text('Call Fire Service'), icon: const Icon(Icons.local_laundry_service), option: 'Call Fire Service' ),
      PopUp(title: Text('Send Emergency Report To Police'), icon: const Icon(Icons.send), option: 'Send Emergency Report To Police'),
      PopUp(title: Text('Share Image'), icon: const Icon(Icons.share), option: 'Share Image'),
      PopUp(title: Text('About'), icon: const Icon(Icons.markunread), option: 'About'),
  ];

}