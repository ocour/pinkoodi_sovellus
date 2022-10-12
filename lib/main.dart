import 'dart:async';

import 'package:flutter/material.dart';
import 'package:crypt/crypt.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const Root(),
      '/home': (context) => const HomePage(),
      '/register': (context) => const RegisterPIN(),
      '/login': (context) => const Login(),
    },
  ));
}

class Root extends StatefulWidget {
  const Root({Key? key}) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  @override
  void initState() {
    super.initState();

    final SecureStorage _secureStorage = SecureStorage();
    _secureStorage.readSecureData('pinkoodi').then((value) {
      if (value == null) {
        Navigator.pushReplacementNamed(context, '/register');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(140.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

// Kotisivu jonne pääse vasta kun pinkoodi on syötetty oikein.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SecureStorage _secureStorage = SecureStorage();
  String tietoa = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kotisivu'),
        backgroundColor: Colors.grey,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Tervetuloa'),
                    Text(
                      tietoa,
                      style: TextStyle(
                          fontSize: 20,
                          color: tietoa == 'pinkoodi poistettu.'
                              ? Colors.green
                              : Colors.red),
                    ),
                  ],
                )),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              child: ElevatedButton(
                child: const Text('Poista pinkoodi'),
                onPressed: () async {
                  await _secureStorage.readSecureData('pinkoodi').then((value) {
                    if (value != null) {
                      _secureStorage.deleteSecureData('pinkoodi');
                      setState(() {
                        tietoa = 'pinkoodi poistettu.';
                      });
                    } else {
                      setState(() {
                        tietoa = 'Pinkoodia ei löytynyt.';
                      });
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// PINKOODIN REKISTERI SIVU
class RegisterPIN extends StatefulWidget {
  const RegisterPIN({Key? key}) : super(key: key);

  @override
  _RegisterPINState createState() => _RegisterPINState();
}

class _RegisterPINState extends State<RegisterPIN> {
  final SecureStorage _secureStorage = SecureStorage();
  TextEditingController controller = TextEditingController();
  late String _input;

  static const rivi1Numerot = ['1', '2', '3'];
  static const rivi2Numerot = ['4', '5', '6'];
  static const rivi3Numerot = ['7', '8', '9'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Luo Pinkoodi',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black54,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.bottomCenter,
                child: PinCodeTextField(
                  readOnly: true,
                  appContext: context,
                  keyboardType: TextInputType.number,
                  controller: controller,
                  obscureText: true,
                  blinkWhenObscuring: true,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  autoDisposeControllers: false,
                  showCursor: false,
                  textStyle: const TextStyle(color: Colors.black54),
                  pinTheme: PinTheme(
                    selectedColor: Colors.grey,
                    activeColor: Colors.black26,
                    inactiveColor: Colors.black26,
                    shape: PinCodeFieldShape.box,
                    borderWidth: 1,
                  ),
                  length: 4,
                  onChanged: (pin) {
                    _input = pin;
                  },
                  onCompleted: (pin) async {
                    // Tähän koodi joka luo syötetyn pinkoodin.

                    final String _pinkoodi = Crypt.sha256(_input).toString();     // hash pinkoodi

                    await _secureStorage.writeSecureData('pinkoodi', _pinkoodi);  // tallentaa hash pinkoodin

                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                //color: Colors.black12,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Mappaa ekan rivin painikkeet.
                        ...rivi1Numerot
                            .map((numero) => MyButton(
                                color: Colors.white,
                                textColor: Colors.black54,
                                buttonText: numero,
                                controller: controller))
                            .toList(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Mappaa tokan rivin painikkeet.
                        ...rivi2Numerot
                            .map((numero) => MyButton(
                                color: Colors.white,
                                textColor: Colors.black54,
                                buttonText: numero,
                                controller: controller))
                            .toList(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Mappaa kolmannen rivin painikkeet.
                        ...rivi3Numerot
                            .map((numero) => MyButton(
                                color: Colors.white,
                                textColor: Colors.black54,
                                buttonText: numero,
                                controller: controller))
                            .toList(),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Viimeisen rivin painikeet.
                          MyButton(
                              color: Colors.white,
                              buttonText: '0',
                              textColor: Colors.black54,
                              controller: controller),
                          MyDeleteButton(
                              textColor: Colors.black54,
                              controller: controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// LOGIN SIVU
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final SecureStorage _secureStorage = SecureStorage();
  final StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();
  TextEditingController controller = TextEditingController();
  late String _input;

  static const rivi1Numerot = ['1', '2', '3'];
  static const rivi2Numerot = ['4', '5', '6'];
  static const rivi3Numerot = ['7', '8', '9'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Syötä Pinkoodi',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black54,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.bottomCenter,
                child: PinCodeTextField(
                  readOnly: true,
                  appContext: context,
                  keyboardType: TextInputType.number,
                  errorAnimationController: errorController,
                  controller: controller,
                  obscureText: true,
                  blinkWhenObscuring: true,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  autoDisposeControllers: false,
                  showCursor: false,
                  textStyle: const TextStyle(color: Colors.black54),
                  pinTheme: PinTheme(
                    selectedColor: Colors.grey,
                    activeColor: Colors.black26,
                    inactiveColor: Colors.black26,
                    shape: PinCodeFieldShape.box,
                    borderWidth: 1,
                  ),
                  length: 4,
                  onChanged: (pin) {
                    _input = pin;
                  },
                  onCompleted: (pin) {
                    // Tähän koodi joka katsoo onko syötetty pinkoodi oikea.
                    _secureStorage.readSecureData('pinkoodi').then((value) {

                      // parsee ja ottaa tyypin, kierrokset ja saltin
                      final _h = Crypt(value);

                      // jos oikee niin kotisivulle, muuten tyhjentää pinkoodi fieldin ja antaa error/väärä_pin animaation.
                      if (_h.match(_input)) {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        errorController.add(ErrorAnimationType.shake);
                        controller.clear();
                      }
                    });
                  },
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                //color: Colors.black12,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // eka rivi
                        ...rivi1Numerot
                            .map((numero) => MyButton(
                                color: Colors.white,
                                textColor: Colors.black54,
                                buttonText: numero,
                                controller: controller))
                            .toList(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // toka rivi
                        ...rivi2Numerot
                            .map((numero) => MyButton(
                                color: Colors.white,
                                textColor: Colors.black54,
                                buttonText: numero,
                                controller: controller))
                            .toList(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // kolmas rivi
                        ...rivi3Numerot
                            .map((numero) => MyButton(
                                color: Colors.white,
                                textColor: Colors.black54,
                                buttonText: numero,
                                controller: controller))
                            .toList(),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // vika rivi
                          MyButton(
                              color: Colors.white,
                              buttonText: '0',
                              textColor: Colors.black54,
                              controller: controller),
                          MyDeleteButton(
                              textColor: Colors.black54,
                              controller: controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// numero buttonit
class MyButton extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String buttonText;
  final TextEditingController controller;

  const MyButton(
      {Key? key,
      required this.color,
      required this.textColor,
      required this.buttonText,
      required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () {
          controller.text += buttonText;
        },
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 8,
          fixedSize: const Size(110, 60),
          primary: color,
          onPrimary: textColor,
        ),
      ),
    );
  }
}

// delete button
class MyDeleteButton extends StatelessWidget {
  final Color textColor;
  final TextEditingController controller;

  const MyDeleteButton(
      {Key? key, required this.textColor, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: TextButton(
        onPressed: () {
          if (controller.text.isNotEmpty) {
            controller.text =
                controller.text.substring(0, controller.text.length - 1);
          }
        },
        child: const Icon(
          Icons.backspace_outlined,
          size: 20,
        ),
        style: TextButton.styleFrom(
          fixedSize: const Size(110, 60),
          primary: textColor,
        ),
      ),
    );
  }
}

// että voi tallentaa dataa enkryptattuna omalle laitteelle.
class SecureStorage {
  final _storage = const FlutterSecureStorage();

  Future writeSecureData(String key, String value) async {
    var writeData = await _storage.write(key: key, value: value);
    return writeData;
  }

  Future readSecureData(String key) async {
    var readData = await _storage.read(key: key);
    return readData;
  }

  Future deleteSecureData(String key) async {
    var deleteData = await _storage.delete(key: key);
    return deleteData;
  }
}
