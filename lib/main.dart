import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:icedoutcar/bluethooth_serial/select_bonded_device_page.dart';
import 'package:icedoutcar/theme/theme.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: MaterialTheme.lightMediumContrastScheme().toColorScheme(),
      ),
      home: IcedOutApp(),
    );
  }
}

class IcedOutApp extends StatefulWidget {
  const IcedOutApp({super.key});

  @override
  State<IcedOutApp> createState() => _IcedOutAppState();
}

class _IcedOutAppState extends State<IcedOutApp> {
  double pi = 3.14159265359;
  BluetoothDevice? connectedDevice;
  BluetoothConnection? connection;
  String serverName = '';
  bool isConnecting = false;
  bool get isConnected => (connection?.isConnected ?? false);
  bool isDisconnecting = false;

  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() {
    return Scaffold(
      appBar: AppBar(title: const Text('Iced Out App')),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double height = constraints.maxHeight;
            bool vertical = height > 500;
            return verticalView(height);
          },
        ),
      ),
    );
  }

  Column verticalView(double height) {
    return Column(
      children: [
        Divider(
          height: height * 0.01,
        ),
        Expanded(
          flex: 8,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: height * 0.1,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: height * 0.08, // Höhe der Buttons anpassen
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                if (isConnected) {
                                  sendMessage('light');
                                }
                              },
                              child: const Text('Lights'),
                            ),
                          ),
                        ),
                        const SizedBox(
                            width: 8), // Abstand zwischen den Buttons
                        Expanded(
                          child: SizedBox(
                            height: height * 0.08, // Höhe der Buttons anpassen
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                if (isConnected) {
                                  sendMessage('eis');
                                }
                              },
                              child: const Icon(Icons.ac_unit),
                            ),
                          ),
                        ),
                        const SizedBox(
                            width: 8), // Abstand zwischen den Buttons
                        Expanded(
                          child: SizedBox(
                            height: height * 0.08, // Höhe der Buttons anpassen
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                if (isConnected) {
                                  sendMessage('wip');
                                }
                              },
                              child: const Text('Wischer'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      height: 10), // Abstand zwischen den Buttonreihen
                  SizedBox(
                    height: height * 0.1,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (isConnected) {
                          sendMessage('autonomous');
                        }
                      },
                      onLongPress: () {
                        if (isConnected) {
                          sendMessage('direction:S');
                        }
                      },
                      child: const Text('Automatic'),
                    ),
                  ),
                  textDivider(
                    height: height * 0.05,
                    header: 'Controller',
                  ),
                  controllerView(
                    height: height * 0.3,
                  ),
                  textDivider(
                    height: height * 0.05,
                    header: 'Connection Status',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: height * 0.1,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (isConnected) {
                          disconnectFromDevice();
                        } else {
                          handleConnectRequest();
                        }
                      },
                      child: Text(
                        isConnected ? 'Disconnect' : 'Connect',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: height * 0.01,
        ),
      ],
    );
  }

  Widget textDivider({required double height, required String header}) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              height: height,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            header,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Divider(
              height: height,
            ),
          ),
        ],
      ),
    );
  }

  Widget controllerView({required double height}) {
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox.expand(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: () {
                        sendMessage('ind_left');
                      },
                      child: const Icon(Icons.arrow_back_ios),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: SizedBox.expand(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: () {
                        sendMessage('ind_right');
                      },
                      child: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(flex: 1, child: SizedBox()),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Dein Code hier für 'up-null'
                      sendMessage("direction:F");
                    },
                    onLongPress: () {
                      // Dein Code hier für 'direction:F'
                      sendMessage("direction:S");
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.arrow_upward),
                        SizedBox(height: 5),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 80), // Größe der Schaltfläche
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40), // Ovalform
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          const Expanded(flex: 1, child: SizedBox()),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Dein Code hier für 'up-left'
                      sendMessage("steering:-10");
                    },
                    onLongPress: () {
                      // Dein Code hier für 'stop'
                      print('stop');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.arrow_back),
                        SizedBox(height: 5),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 80), // Größe der Schaltfläche
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40), // Ovalform
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      sendMessage("direction:R");
                    },
                    onLongPress: () {
                      // Dein Code hier für 'direction:F'
                      sendMessage("direction:S");
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.arrow_downward),
                        SizedBox(height: 5),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 80), // Größe der Schaltfläche
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40), // Ovalform
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Dein Code hier für 'up-right'
                      sendMessage("steering:-100");
                    },
                    onLongPress: () {
                      // Dein Code hier für 'stop'
                      print('stop');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.arrow_forward),
                        SizedBox(height: 5),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 80), // Größe der Schaltfläche
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40), // Ovalform
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget controllerButton({
    required String startMessage,
    required String stopMessage,
    double degrees = 0,
  }) {
    return SizedBox.expand(
      child: Listener(
        onPointerDown: (details) {
          sendMessage(startMessage);
        },
        onPointerUp: (details) {
          sendMessage(stopMessage);
        },
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF69B4), // Hot pink
          ),
          onPressed: () {},
          child: Transform.rotate(
            angle: degrees * pi / 180,
            child: const Icon(Icons.arrow_upward),
          ),
        ),
      ),
    );
  }

  void connectToDevice() async {
    final BluetoothDevice? device = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const SelectBondedDevicePage(checkAvailability: false);
        },
      ),
    );

    if (device == null) {
      debugPrint('No device selected');
      return;
    } else {
      if (device == connectedDevice) {
        return;
      }
      connectedDevice = device;
      serverName = device.name ?? "Unknown";

      BluetoothConnection.toAddress(device.address).then((connection) {
        debugPrint('Connected to the device');
        this.connection = connection;
        isConnecting = false;
        isDisconnecting = false;
      }).catchError((error) {
        debugPrint('Cannot connect, exception occurred');
        debugPrint(error);
      });
    }
  }

  void sendMessage(String message) async {
    final text = message.trim();

    if (text.isNotEmpty) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode("$text\r\n")));
        await connection!.output.allSent;

        debugPrint('Sent: $text');
      } catch (e) {
        setState(() {});
      }
    }
  }

  void disconnectFromDevice() {
    if (isConnecting) {
      isConnecting = false;
      connection?.finish();
      connectedDevice = null;

      return;
    }
    isDisconnecting = true;
    connection?.finish();
    connectedDevice = null;
  }

  Widget connectionButton() {
    return ElevatedButton(
      onPressed: () {
        debugPrint('Connecting to Bluetooth');
      },
      child: const Icon(
        Icons.bluetooth_searching,
        color: Color(0xFFFF69B4),
      ),
    );
  }

  Future handleConnectRequest() async {
    await Permission.bluetoothScan.status.then((value) async {
      debugPrint("-------!${value.isGranted}!-------");
      if (value.isGranted) {
        debugPrint('Bluetooth permission granted');
        connectToDevice();
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return requestBluetoothDialog(context);
            });
      }
    });
  }

  AlertDialog requestBluetoothDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Bluetooth Permission'),
      content: const Text(
        'This app requires bluetooth permission to connect to the device, please allow location and nearby devices permission to continue.',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            await openAppSettings().then((value) async {
              Navigator.of(context).pop();
              await Permission.bluetoothScan.status.then((value) {
                if (value.isGranted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                    'Bluetooth permission granted, please try again.',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 24,
                    ),
                  )));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                    'Bluetooth permission is required to connect to the device.',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 24,
                    ),
                  )));
                }
              });
            });
          },
          child: const Text(
            'Open Settings',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }
}
