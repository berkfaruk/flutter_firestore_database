// ignore_for_file: must_be_immutable, unused_field, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreOperations extends StatelessWidget {
  FirestoreOperations({super.key});

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _userSubscribe = null;

  @override
  Widget build(BuildContext context) {
    //ID
    debugPrint(_firestore.collection('users').doc().id);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Firestore"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () => addDataWithAdd(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white),
                child: const Text("Add Data Add")),
            ElevatedButton(
                onPressed: () => addDataWithSet(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white),
                child: const Text("Add Data Set")),
            ElevatedButton(
                onPressed: () => updateData(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white),
                child: const Text("Update Data")),
            ElevatedButton(
                onPressed: () => deleteData(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text("Delete Data")),
            ElevatedButton(
                onPressed: () => readFromData(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white),
                child: const Text("Read Data One Time")),
            ElevatedButton(
                onPressed: () => readFromDataRealTime(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white),
                child: const Text("Read Data Real Time")),
            ElevatedButton(
                onPressed: () => stopStream(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white),
                child: const Text("Stop Stream")),
            ElevatedButton(
                onPressed: () => batchConcept(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white),
                child: const Text("Batch Concept")),
            ElevatedButton(
                onPressed: () => transactionConcept(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white),
                child: const Text("Transaction Concept")),
            ElevatedButton(
                onPressed: () => queryingData(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.white),
                child: const Text("Data Query")),
            ElevatedButton(
                onPressed: () => cameraGalleryImageUpload(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white),
                child: const Text("Camera Gallery Image Upload")),
          ],
        ),
      ),
    );
  }

  addDataWithAdd() async {
    Map<String, dynamic> _addedUser = <String, dynamic>{};
    _addedUser['name'] = 'ayse';
    _addedUser['age'] = 22;
    _addedUser['isStudent'] = true;
    _addedUser['address'] = {'city': 'ankara', 'district': 'fatih'};
    _addedUser['colors'] = FieldValue.arrayUnion(['blue', 'green']);
    _addedUser['createdAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('users').add(_addedUser);
  }

  addDataWithSet() async {
    var _newDocID = _firestore.collection('users').doc().id;

    await _firestore
        .doc('users/$_newDocID')
        .set({'name': 'emre', 'userID': _newDocID});

    await _firestore.doc('users/neL6Irk4iw86HqmALydn').set(
        {'school': 'Kırıkkale Üniversitesi', 'age': FieldValue.increment(1)},
        SetOptions(merge: true));
  }

  updateData() async {
    await _firestore
        .doc('users/neL6Irk4iw86HqmALydn')
        .update({'address.district': 'new ankara'});
  }

  deleteData() async {
    await _firestore.doc('users/neL6Irk4iw86HqmALydn').delete();

    /*
    await _firestore.doc('users/neL6Irk4iw86HqmALydn').update({
      'school':FieldValue.delete()
  });
  */
  }

  readFromData() async {
    var _usersDocuments = await _firestore.collection('users').get();
    debugPrint(_usersDocuments.size.toString());
    debugPrint(_usersDocuments.docs.length.toString());
    for (var element in _usersDocuments.docs) {
      debugPrint('Döküman ID ${element.id}');
      Map userMap = element.data();
      debugPrint(userMap['name']);
    }

    var _berkDoc = await _firestore.doc("users/vQ8SQfmIOEcAooyVUcFP").get();
    debugPrint(_berkDoc.data()!['address']['district'].toString());
  }

  readFromDataRealTime() async {
    //var _userStream = await _firestore.collection('users').snapshots();
    var _userDocStream =
        await _firestore.doc('users/vQ8SQfmIOEcAooyVUcFP').snapshots();
    _userSubscribe = _userDocStream.listen((event) {
      /*
      event.docChanges.forEach((element) {
        debugPrint(element.doc.data().toString());
      },);

      event.forEach((element) {
        debugPrint(element.data().toString());
      },);
      */

      debugPrint(event.data().toString());
    });
  }

  stopStream() async {
    await _userSubscribe!.cancel();
  }

  batchConcept() async {
    WriteBatch _batch = _firestore.batch();
    CollectionReference _counterColRef = _firestore.collection('counter');

    /*
    for(int i=0; i<100; i++) {
      var _newDoc = _counterColRef.doc();
      _batch.set(_newDoc, {'count':++i, 'id':_newDoc.id});
    }
    */

    /*
    var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.update(element.reference, {'createdAt':FieldValue.serverTimestamp()});
    },);
    */

    var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.delete(element.reference);
    });

    await _batch.commit();
  }

  transactionConcept() async {
    _firestore.runTransaction(
      (transaction) async {
        DocumentReference<Map<String, dynamic>> berkRef =
            _firestore.doc('users/vQ8SQfmIOEcAooyVUcFP');
        DocumentReference<Map<String, dynamic>> emreRef =
            _firestore.doc('users/cCnuFh1op0z3nGoUfdsy');

        var _berkSnapshot = await transaction.get(berkRef);
        var _berkMoney = _berkSnapshot.data()!['money'];
        if (_berkMoney > 100) {
          var _newBerkMoney = _berkSnapshot.data()!['money'] - 100;
          transaction.update(berkRef, {'money': _newBerkMoney});
          transaction.update(emreRef, {'money': FieldValue.increment(100)});
        }
      },
    );
  }

  queryingData() async {
    var _userRef = _firestore.collection('users').limit(5);
    var _result = await _userRef.where('colors', arrayContains: 'blue').get();

    /*
    for (var user in _result.docs) {
      debugPrint(user.data().toString());
    }
    */

    /*
    var _toSort = await _userRef.orderBy('age', descending: true).get();
    for (var user in _toSort.docs) {
      debugPrint(user.data().toString());
    }
    */

    var _stringSearch = await _userRef
        .orderBy('email')
        .startAt(['bfc']).endAt(['bfc' + '\uf8ff']).get();
    for (var user in _stringSearch.docs) {
      debugPrint(user.data().toString());
    }

  }

  cameraGalleryImageUpload() async {
    final ImagePicker _picker = ImagePicker();
    XFile? _file = await _picker.pickImage(source: ImageSource.gallery);
    var _profileRef = FirebaseStorage.instance.ref('users/profile_pictures/user_id');
    var _task = _profileRef.putFile(File(_file!.path));

    _task.whenComplete(() async{
      var _url = await _profileRef.getDownloadURL();
      _firestore.doc('users/GS795DXPlQhQ62hDgrcZ').set({
        'profile_pic':_url.toString()
      }, SetOptions(merge: true));
      debugPrint(_url);
    },);
  }
}
