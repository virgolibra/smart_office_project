import 'dart:developer';
import 'dart:io';

// import 'package:camera/camera.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_casa0015_mobile_app/formatter.dart';
// import 'package:flutter_casa0015_mobile_app/page/add_receipt_page.dart';
import 'package:flutter_smart_office_project/page/add_image_page.dart';
import 'package:flutter_smart_office_project/page/smart_base_page.dart';
import 'package:provider/provider.dart';

import '../firebase_options.dart';
import '../authentication.dart';
import '../widgets.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Office', style: TextStyle(color: Color(0xffffffff)),),
        backgroundColor: Color(0xff242f35),
      ),
      body: ListView(
        children: <Widget>[
          Image.asset('assets/title1.png'),
          const SizedBox(height: 8),
          const IconAndDetail(Icons.account_balance_rounded, 'Login Page'),
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: const Color(0xffe5e5e5),
                borderRadius: BorderRadius.circular(18)),
            child: Consumer<ApplicationState>(
              builder: (context, appState, _) => Authentication(
                email: appState.email,
                loginState: appState.loginState,
                startLoginFlow: appState.startLoginFlow,
                endLoginFlow: appState.endLoginFlow,
                verifyEmail: appState.verifyEmail,
                signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
                cancelRegistration: appState.cancelRegistration,
                registerAccount: appState.registerAccount,
                signOut: appState.signOut,
              ),
            ),
          ),
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (appState.loginState == ApplicationLoginState.loggedIn) ...[
                  StartHome(
                    title: 'TestStartHome',
                    email: appState.email,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmartTableReportMessage {
  SmartTableReportMessage({
    required this.id,
    required this.name,
    required this.tableId,
    required this.timestamp,
    required this.imageId,
    required this.isImageUpload,
    required this.tagId,
    required this.checkInStatus,
    required this.iconIndex,

    // required this.price,
    // required this.item,
    // required this.category,
    // required this.iconIndex,
    // required this.lat,
    // required this.lon,
    // required this.timestamp,
    // required this.imageId,
    // required this.isReceiptUpload,
  });
  final String id;
  final String name;
  final String tableId;
  final int timestamp;
  final String imageId;
  final bool isImageUpload;
  final String tagId;
  final String checkInStatus;
  final int iconIndex;
  //
  // final String price;
  // final String item;
  // final String category;
  // final int iconIndex;
  // final double lat;
  // final double lon;
  // final int timestamp;
  // final bool isReceiptUpload;
  // final String imageId;
// final Timestamp timestamp;
}

enum Attending { yes, no, unknown }

class AddSmartTableItem extends StatefulWidget {
  const AddSmartTableItem({Key? key, required this.addItem}) : super(key: key);
  final FutureOr<void> Function(
       String checkInStatus, String imageId, bool isImageUpload) addItem;

  @override
  _AddSmartTableItemState createState() => _AddSmartTableItemState();
}

class _AddSmartTableItemState extends State<AddSmartTableItem> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_AddSpendingItemState');
  final _controller = TextEditingController();
  final _controller2 = TextEditingController();

  late ImageData imageData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageData = ImageData('/noPath', false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
                color: const Color(0xff496571),
                borderRadius: BorderRadius.circular(8)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  imageData.imageStatus == true
                      ? SizedBox(
                      height: 100,
                      width: 300,
                      child: Image.file(File(imageData.imagePath)))
                      : const Text("Click to add a photo", style: TextStyle(color: Color(0xffffffff)),),
                  const SizedBox(
                    height: 15,
                  ),

                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: 30,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            side: const BorderSide(
                                width: 3, color: const Color(0xffffffff)),


                          ),
                          onPressed: () async {
                            try {
                              WidgetsFlutterBinding.ensureInitialized();
                              // Obtain a list of the available cameras on the device.
                              final cameras = await availableCameras();
                              // Get a specific camera from the list of available cameras.
                              final firstCamera = cameras.first;

                              // imageData.receiptStatus = ReceiptStatus.notCaptured;

                              await Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) => AddImagePage(
                                    camera: firstCamera,
                                  ),
                                ),
                              )
                                  .then((value) {
                                print(value);
                                imageData = value;
                                print(imageData.imagePath);
                                print(imageData.imageStatus);

                                setState(() {});
                                // print(value[0].toString());
                                // print(value[1].toString());
                              });
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.camera_alt_rounded, size: 15,),
                              const SizedBox(width: 10),
                              imageData.imageStatus == true
                                  ? const Text(
                                'Re-capture',
                                style: TextStyle(fontSize: 12),
                              )
                                  : const Text(
                                'Add a Photo',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.30,
                        height: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: const Color(0xffffffff),
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                              textStyle: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await widget.addItem(
                                  'checkInStatus',
                                  imageData.imagePath.substring(
                                      imageData.imagePath.lastIndexOf('/')),
                                  imageData.imageStatus);

                              // String tableId, String tagId, String checkInStatus, String imageId, bool isImageUpload
                              _controller.clear();
                              _controller2.clear();

                              if (imageData.imageStatus) {
                                uploadImage();
                              }

                              imageData.imageStatus = false;
                              imageData.imagePath = '/noPath';
                              await showAddItemDoneDialog();
                              setState(() {});
                            }
                          },
                          child: Row(
                            children: const [
                              Icon(
                                Icons.add_circle_rounded,
                                size: 15,
                                color: Color(0xff242f35),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Upload',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff242f35),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<bool?> showAddItemDoneDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Congratulations!"),
          content: const Text("Card is recorded"),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "OK",
                style: TextStyle(color: Color(0xff6D42CE)),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            // TextButton(
            //   child: Text("delete"),
            //   onPressed: () {
            //     Navigator.of(context).pop(true);
            //   },
            // ),
          ],
        );
      },
    );
  }

  void uploadImage() {
    final storage = FirebaseStorage.instance;
    File file = File(imageData.imagePath);

    final imageName =
    imageData.imagePath.substring(imageData.imagePath.lastIndexOf('/'));

    // Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpeg");

// Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();

// Upload file and metadata to the path 'images/mountains.jpg'
    final uploadTask = storageRef
        .child(
        'images/spendingReport/${FirebaseAuth.instance.currentUser?.uid}/$imageName')
        .putFile(file, metadata);
    // Listen for state changes, errors, and completion of the upload.
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          print("Upload is $progress% complete.");
          break;
        case TaskState.paused:
          print("Upload is paused.");
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          break;
        case TaskState.error:
        // Handle unsuccessful uploads
          break;
        case TaskState.success:
        // Handle successful uploads on complete
        // ...
          break;
      }
    });
  }
}

class DisplaySmartTableItem extends StatefulWidget {
  const DisplaySmartTableItem({Key? key, required this.items}) : super(key: key);
  final List<SmartTableReportMessage> items; // new
  @override
  _DisplaySmartTableItemState createState() => _DisplaySmartTableItemState();
}

class _DisplaySmartTableItemState extends State<DisplaySmartTableItem> {
  double totolAmount = 0;
  @override
  void initState() {
    super.initState();

    // for (int i = 0; i < widget.items.length; i++) {
    //   totolAmount += double.parse(widget.items[i].price);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const SizedBox(height: 8),
        // ------MESSAGE display ----------------------------------

        // Container(
        //     color: Color(0xffE09E45),
        //     height: 50,
        //     child: Row(
        //       // mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Text(
        //           '   Total Amount: £${totolAmount.toString()}',
        //           style: TextStyle(
        //               color: Color(0xffF5E0C3),
        //               fontSize: 20,
        //               fontWeight: FontWeight.w700),
        //         ),
        //       ],
        //     )),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          // height: 600,

          child: ListView.builder(
            padding: const EdgeInsets.all(1),
            itemCount: widget.items.length,
            // shrinkWrap: false,
            // addAutomaticKeepAlives: false,
            // addSemanticIndexes: true,
            // semanticChildCount: 3,

    // final String id;
    // final String name;
    // final String tableId;
    // final int timestamp;
    // final String imageId;
    // final bool isImageUpload;
    // final String tagId;
    // final String checkInStatus;
            // final int iconIndex;
            itemBuilder: (BuildContext context, int index) {
              return ListElement(
                id: widget.items[index].id,
                tableId: widget.items[index].tableId,
                timestamp: widget.items[index].timestamp,
                imageId: widget.items[index].imageId,
                isImageUpload: widget.items[index].isImageUpload,
                tagId: widget.items[index].tagId,
                checkInStatus: widget.items[index].checkInStatus,
                iconIndex: widget.items[index].iconIndex,
                name: widget.items[index].name,
              );
            },

            // children: <Widget>[
            //   for (var message in widget.messages)
            //   // Paragraph('${message.name}: ${message.message}: ${message.type}'),
            //     ListElement(message.name, message.message),
            // ],
          ),
        ),

        // const SizedBox(height: 8),
      ],
    );
  }
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _listenerCountSub = FirebaseFirestore.instance
        .collection('attendees')
        .where('attending', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _attendees = snapshot.docs.length;
      notifyListeners();
    });

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
        _email = user.email;
        _spendingReportSubscription = FirebaseFirestore.instance
            .collection('SmartTableReport')
            // .doc(user.uid)
            // .collection(user.uid)
        // .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
        .limit(30)
            .snapshots()
            .listen((snapshot) {
          _smartTableReportMessages = [];
          for (final document in snapshot.docs) {
            _smartTableReportMessages.add(
              SmartTableReportMessage(


                // final String id;
                // final String name;
                // final String tableId;
                // final int timestamp;
                // final String imageId;
                // final bool isImageUpload;
                // final String tagId;
                // final String checkInStatus;

                id: document.id,
                name: document.data()['name'] as String,
                tableId: document.data()['tableId'] as String,
                timestamp: document.data()['timestamp'] as int,
                imageId: document.data()['imageId'] as String,
                isImageUpload: document.data()['isImageUpload'] as bool,
                tagId: document.data()['tagId'] as String,
                checkInStatus: document.data()['checkInStatus'] as String,
                iconIndex: document.data()['iconIndex'] as int,
              ),
            );
          }
          notifyListeners();
        });

        _attendingSubscription = FirebaseFirestore.instance
            .collection('attendees')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.data() != null) {
            if (snapshot.data()!['attending'] as bool) {
              _attending = Attending.yes;
            } else {
              _attending = Attending.no;
            }
          } else {
            _attending = Attending.unknown;
          }
          notifyListeners();
        });
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        _smartTableReportMessages = [];
        _spendingReportSubscription?.cancel();
        _attendingSubscription?.cancel(); // new
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  // ApplicationLoginState _loginState = ApplicationLoginState.loggedIn;
  ApplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  StreamSubscription<QuerySnapshot>? _spendingReportSubscription;
  List<SmartTableReportMessage> _smartTableReportMessages = [];
  List<SmartTableReportMessage> get smartTableReportMessages =>
      _smartTableReportMessages;

  int _attendees = 0;
  int get attendees => _attendees;

  Attending _attending = Attending.unknown;
  StreamSubscription<DocumentSnapshot>? _attendingSubscription;
  Attending get attending => _attending;
  set attending(Attending attending) {
    final userDoc = FirebaseFirestore.instance
        .collection('attendees')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    if (attending == Attending.yes) {
      userDoc.set(<String, dynamic>{'attending': true});
      print('$_attendees people going');
    } else {
      userDoc.set(<String, dynamic>{'attending': false});
      print('$_attendees people going');
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _listenerCountSub;

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  void endLoginFlow() {
    _loginState = ApplicationLoginState.loggedOut;
    notifyListeners();
  }

  Future<void> verifyEmail(
      String email,
      void Function(FirebaseAuthException e) errorCallback,
      ) async {
    try {
      var methods =
      await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  Future<void> signInWithEmailAndPassword(
      String email,
      String password,
      void Function(FirebaseAuthException e) errorCallback,
      ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> registerAccount(
      String email,
      String displayName,
      String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<DocumentReference> addMessageToSmartTableReport(
      String tableId,
      String imageId,
      bool isImageUpload,
      String tagId,
      String checkInStatus,
      int iconIndex,
      ) {
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Must be logged in');
    }


    return FirebaseFirestore.instance
        // .collection('SmartTableReport')
        // .doc(FirebaseAuth.instance.currentUser!.uid)
        // .collection(FirebaseAuth.instance.currentUser!.uid)
        // .add(<String, dynamic>{
        .collection('SmartTableReport')
        // .doc(FirebaseAuth.instance.currentUser!.uid)
        // .collection(FirebaseAuth.instance.currentUser!.uid)
        .add(<String, dynamic>{

      'tableId': tableId,
      'tagId': tagId,
      'checkInStatus': checkInStatus,
      'iconIndex': iconIndex,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'imageId': imageId,
      'isImageUpload': isImageUpload,
    });
  }
  //
  // Future<DocumentReference> deleteMessageToSpendingReport(
  //     String item,
  //     int timestamp) {
  //   if (_loginState != ApplicationLoginState.loggedIn) {
  //     throw Exception('Must be logged in');
  //   }
  //
  //
  //
  //
  //   FirebaseFirestore.instance
  //       .collection('SpendingReport')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .collection(FirebaseAuth.instance.currentUser!.uid)
  //   .doc(d)
  //   .where('timestamp', isEqualTo: timestamp).
  //
  //
  //   return FirebaseFirestore.instance
  //       .collection('SpendingReport')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .collection(FirebaseAuth.instance.currentUser!.uid)
  //   .where(Firebase.firestore.FieldPath.documentId(), '==', 'fK3ddutEpD2qQqRMXNW5')
  //
  //       .add(<String, dynamic>{
  //     'item': item,
  //     'price': price,
  //     'category': category,
  //     'iconIndex': iconIndex,
  //     'lat': lat,
  //     'lon': lon,
  //     'timestamp': DateTime.now().millisecondsSinceEpoch,
  //     'name': FirebaseAuth.instance.currentUser!.displayName,
  //     'userId': FirebaseAuth.instance.currentUser!.uid,
  //     'imageId': imageId,
  //     'isReceiptUpload': isReceiptUpload,
  //   });
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    _listenerCountSub?.cancel();

    super.dispose();
  }
}

class YesNoSelection extends StatelessWidget {
  const YesNoSelection({required this.state, required this.onSelection});
  final Attending state;
  final void Function(Attending selection) onSelection;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case Attending.yes:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0),
                onPressed: () => onSelection(Attending.yes),
                child: const Text('YES'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => onSelection(Attending.no),
                child: const Text('NO'),
              ),
            ],
          ),
        );
      case Attending.no:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              TextButton(
                onPressed: () => onSelection(Attending.yes),
                child: const Text('YES'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0),
                onPressed: () => onSelection(Attending.no),
                child: const Text('NO'),
              ),
            ],
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              StyledButton(
                onPressed: () => onSelection(Attending.yes),
                child: const Text('YES'),
              ),
              const SizedBox(width: 8),
              StyledButton(
                onPressed: () => onSelection(Attending.no),
                child: const Text('NO'),
              ),
            ],
          ),
        );
    }
  }
}

class StartHome extends StatefulWidget {
  const StartHome({
    Key? key,
    required this.title,
    required this.email,
  }) : super(key: key);
  final String title;
  final String? email;

  @override
  _StartHomeState createState() => _StartHomeState();
}

class _StartHomeState extends State<StartHome> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            width: 200,
            height: 100,
            child: StyledIconButton4(
              label: const Text(
                'Main Page',
                style: TextStyle(fontSize: 22),
              ),
              icon: const Icon(Icons.account_balance_rounded),
              onPressed: () async {
                if (widget.email != null) {

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          SmartBasePage(email: widget.email!),
                    ),
                  );
                }
              },

              // onPressed: () async {
              //   try {
              //     await Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (context) => const MessageTestPage(),
              //       ),
              //     );
              //   } catch (e) {
              //     print(e);
              //   }
              // },
            ),
          ),
        ),
        const Text('Click to enter main page'),

      ],
    );
  }
}
