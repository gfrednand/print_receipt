library print_receipt;

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class PrintReceipt {
  // static Future showCustomAlertBox({
  //   @required BuildContext context,
  //   @required Widget willDisplayWidget,
  // }) {
  //   assert(context != null, "context is null!!");
  //   assert(willDisplayWidget != null, "willDisplayWidget is null!!");
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(15)),
  //           ),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: <Widget>[
  //               willDisplayWidget,
  //               MaterialButton(
  //                 color: Colors.white30,
  //                 child: Text('close alert'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               )
  //             ],
  //           ),
  //           elevation: 10,
  //         );
  //       });
  // }
  static const int STATE_OFF = 10;
  static const int STATE_TURNING_ON = 11;
  static const int STATE_ON = 12;
  static const int STATE_TURNING_OFF = 13;
  static const int STATE_BLE_TURNING_ON = 14;
  static const int STATE_BLE_ON = 15;
  static const int STATE_BLE_TURNING_OFF = 16;
  static const int ERROR = -1;
  static const int CONNECTED = 1;
  static const int DISCONNECTED = 0;

  static const String namespace = 'print_receipt';
  static const MethodChannel _channel =
      const MethodChannel('$namespace/methods');

  static const EventChannel _readChannel =
      const EventChannel('$namespace/read');

  static const EventChannel _stateChannel =
      const EventChannel('$namespace/state');

  final StreamController<MethodCall> _methodStreamController =
      new StreamController.broadcast();
  //Stream<MethodCall> get _methodStream => _methodStreamController.stream;

  PrintReceipt._() {
    _channel.setMethodCallHandler((MethodCall call) {
      _methodStreamController.add(call);
    });
  }

  static PrintReceipt _instance = new PrintReceipt._();

  static PrintReceipt get instance => _instance;

  Stream<int> onStateChanged() =>
      _stateChannel.receiveBroadcastStream().map((buffer) => buffer);

  Stream<String> onRead() =>
      _readChannel.receiveBroadcastStream().map((buffer) => buffer.toString());

  Future<bool> get isAvailable async =>
      await _channel.invokeMethod('isAvailable');

  Future<bool> get isOn async => await _channel.invokeMethod('isOn');

  Future<bool> get isConnected async =>
      await _channel.invokeMethod('isConnected');

  Future<bool> get openSettings async =>
      await _channel.invokeMethod('openSettings');

  Future<List<BluetoothDevice>> getBondedDevices() async {
    final List list = await _channel.invokeMethod('getBondedDevices');
    return list.map((map) => BluetoothDevice.fromMap(map)).toList();
  }

  Future<dynamic> connect(BluetoothDevice device) =>
      _channel.invokeMethod('connect', device.toMap());

  Future<dynamic> disconnect() => _channel.invokeMethod('disconnect');

  Future<dynamic> write(String message) =>
      _channel.invokeMethod('write', {'message': message});

  Future<dynamic> writeBytes(Uint8List message) =>
      _channel.invokeMethod('writeBytes', {'message': message});

  Future<dynamic> printCustom(String message, int size, int align) =>
      _channel.invokeMethod(
          'printCustom', {'message': message, 'size': size, 'align': align});

  Future<dynamic> printNewLine() => _channel.invokeMethod('printNewLine');

  Future<dynamic> paperCut() => _channel.invokeMethod('paperCut');

  Future<dynamic> printImage(String pathImage) =>
      _channel.invokeMethod('printImage', {'pathImage': pathImage});

  Future<dynamic> printQRcode(
          String textToQR, int width, int height, int align) =>
      _channel.invokeMethod('printQRcode', {
        'textToQR': textToQR,
        'width': width,
        'height': height,
        'align': align
      });

  Future<dynamic> printLeftRight(String string1, String string2, int size) =>
      _channel.invokeMethod('printLeftRight',
          {'string1': string1, 'string2': string2, 'size': size});
}

class BluetoothDevice {
  final String name;
  final String address;
  final int type = 0;
  bool connected = false;

  BluetoothDevice(this.name, this.address);

  BluetoothDevice.fromMap(Map map)
      : name = map['name'],
        address = map['address'];

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'address': this.address,
        'type': this.type,
        'connected': this.connected,
      };

  operator ==(Object other) {
    return other is BluetoothDevice && other.address == this.address;
  }

  @override
  int get hashCode => address.hashCode;
}
