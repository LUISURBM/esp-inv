// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esp_sof/src/nivel_confianza.dart';
import 'package:intl/intl.dart' as intl;
import 'package:json_annotation/json_annotation.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:http/http.dart' as http;

class FormInfinitoWidgetsDemo extends StatefulWidget {
  const FormInfinitoWidgetsDemo({super.key});

  @override
  State<FormInfinitoWidgetsDemo> createState() =>
      _FormInfinitoWidgetsDemoState();
}

class _FormInfinitoWidgetsDemoState extends State<FormInfinitoWidgetsDemo> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  DateTime date = DateTime.now();
  double maxValue = 0;
  bool? brushedTeeth = false;
  bool enableFeature = false;
  List<NivelConfianza> userCollection = List<NivelConfianza>.empty();
  FormData formData = FormData();
  var txt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universo Infinito'),
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: Align(
            alignment: Alignment.topCenter,
            child: Card(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...[
                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'N',
                            labelText: 'Tamaño de muestra',
                          ),
                          onChanged: (value) {
                            setState(() {
                              formData.tamanio = double.tryParse(value) ?? 0;
                            });
                          },
                        ),
                        FormField<NivelConfianza>(builder: (state) {
                          return InputDecorator(
                              decoration: const InputDecoration(
                                filled: true,
                                hintText: 'Z',
                                labelText:
                                    'Parámetro estadístico que depende el nivel de confianza (NC)',
                              ),
                              child: StreamBuilder<List<NivelConfianza>>(
                                stream: _bids,
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<NivelConfianza>>
                                        snapshot) {
                                  List<Widget> children;
                                  if (snapshot.hasError) {
                                    children = <Widget>[
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 60,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Text('Error: ${snapshot.error}'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                            'Stack trace: ${snapshot.stackTrace}'),
                                      ),
                                    ];
                                  } else {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.none:
                                        children = const <Widget>[
                                          Icon(
                                            Icons.info,
                                            color: Colors.blue,
                                            size: 60,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 16),
                                            child: Text('Select a lot'),
                                          )
                                        ];
                                        break;
                                      case ConnectionState.waiting:
                                        children = const <Widget>[
                                          SizedBox(
                                            width: 60,
                                            height: 60,
                                            child: CircularProgressIndicator(),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 16),
                                            child: Text('Espere por favor...'),
                                          )
                                        ];
                                        break;
                                      case ConnectionState.active:
                                        children = <Widget>[
                                          const Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                            size: 60,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 16),
                                            child: Text('\$${snapshot.data}'),
                                          )
                                        ];
                                        break;
                                      case ConnectionState.done:
                                        formData.selected = snapshot.data?[0];
                                        children = <Widget>[
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: DropdownButtonFormField<
                                                      NivelConfianza>(
                                                    value: formData.selected,
                                                    icon: const Icon(
                                                        Icons.arrow_downward),
                                                    elevation: 16,
                                                    style: const TextStyle(
                                                        color:
                                                            Colors.deepPurple),
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                      formData.selected =
                                                          newValue;
                                                        formData.nc =
                                                            newValue?.z;
                                                      });
                                                    },
                                                    items: snapshot.data?.map<
                                                            DropdownMenuItem<
                                                                NivelConfianza>>(
                                                        (NivelConfianza value) {
                                                      return DropdownMenuItem<
                                                          NivelConfianza>(
                                                        value: value,
                                                        child: Text(
                                                            "${value.nivel}"),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.info,
                                                  color: Colors.blue,
                                                  size: 60,
                                                ),
                                              ])
                                        ];
                                        break;
                                    }
                                  }

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: children,
                                  );
                                },
                              ));
                        }),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'e',
                            labelText: 'Error de estimación maximo aceptado',
                          ),
                          onChanged: (value) {
                            setState(() {
                              formData.estimacionError =
                                  double.tryParse(value) ?? 0;
                            });
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'p',
                            labelText:
                                'Probabilidad de que ocurra el evento estudiado (éxito)',
                          ),
                          onChanged: (value) {
                            setState(() {
                              formData.probabilidadExito =
                                  double.tryParse(value) ?? 0;
                            });
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'q',
                            labelText:
                                '(1-p)Probabilidad de que ocurra no el evento estudiado (éxito)',
                          ),
                          onChanged: (value) {
                            setState(() {
                              formData.probabilidadError =
                                  double.tryParse(value) ?? 0;
                            });
                          },
                        ),
                        TextFormField(
                          controller: txt,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            hintText: 'Resultado',
                            labelText: 'Salida',
                          ),
                          maxLines: 3,
                          readOnly: true,
                        ),
                        TextButton(
                          child: const Text('Calcular'),
                          onPressed: () async {
                            // Use a JSON encoded string to send

                            var Z = formData.nc;
                            var e = formData.estimacionError! / 100;
                            var p = formData.probabilidadExito! / 100;
                            var q = formData.probabilidadError! / 100;

                            var numerador = (((Z as double) * (Z)) * p * q);
                            var divisor = (e * e);
                            var n = numerador / divisor;
                            formData.resultado = n;
                            txt.text = "$n";
                            _showDialog('Resultado $n');
                          },
                        ),
                      ].expand(
                        (widget) => [
                          widget,
                          const SizedBox(
                            height: 24,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final Stream<List<NivelConfianza>> _bids = (() {
    late final StreamController<List<NivelConfianza>> controller;
    controller = StreamController<List<NivelConfianza>>(
      onListen: () async {
        controller.add(await load());
        await controller.close();
      },
    );
    return controller.stream;
  })();

  Future<void> init() async {
    await connect();
  }

  Future<List<NivelConfianza>> connect() async {
    print('connect');
    mongo.Db db = await mongo.Db.create("mongodb+srv://" +
        Uri.encodeFull("lfurbinam") +
        ":" +
        Uri.encodeFull("rCybwv6FGhzPEUIt") +
        "@cluster0.ulzln.mongodb.net/?retryWrites=true&w=majority");
    await db.open();
    userCollection = await db
        .collection("ESP_INV.NIVEL_CONFIANZA")
        .find()
        .map((event) => NivelConfianza(
            id: mongo.ObjectId.parse(event['id'].toString()),
            nivel: double.parse(event['nivel'].toString()),
            z: double.parse(event['z'].toString())))
        .toList();
    print(userCollection);
    userCollection = await load();
    return userCollection;
  }

  void _showDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    connect().then((val) {
      setState(() {
        userCollection = val;
      });
      print("success");
    }).catchError((dynamic error, dynamic stackTrace) {
      print("outer: $error");
    });
    ;
  }
}

Future<List<NivelConfianza>> load() async {
  print('load');
  List<NivelConfianza> ak = List<NivelConfianza>.empty();
  var res = await http.post(
      Uri.parse(
          "https://data.mongodb-api.com/app/data-oiqru/endpoint/data/beta/action/find"),
      headers: {
        'Content-type': 'application/json',
        'Access-Control-Request-Headers': '*',
        'api-key':
            'WiojpWmpt6hJmvW9GjlLrO6FSFudW2U5xS2atiitM4Kaor7GbtBMisnhiw71EwGE'
      },
      body: jsonEncode({
        'collection': 'NIVEL_CONFIANZA',
        'database': 'ESP_INV',
        'dataSource': 'Cluster0'
      }));

  String v = res.body;
  print(v);
  final parsed = jsonDecode(v) as Map<String, dynamic>;

  print(parsed['documents']);
  ak = parsed['documents']
      .map<NivelConfianza>((dynamic json) =>
          NivelConfianza.fromJson(json as Map<String, dynamic>))
      .toList() as List<NivelConfianza>;
  print(ak);
  // print(v);
  return ak;
}

class _FormDatePicker extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _FormDatePicker({
    required this.date,
    required this.onChanged,
  });

  @override
  State<_FormDatePicker> createState() => _FormDatePickerState();
}

class _FormDatePickerState extends State<_FormDatePicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Date',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              intl.DateFormat.yMd().format(widget.date),
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
        TextButton(
          child: const Text('Edit'),
          onPressed: () async {
            var newDate = await showDatePicker(
              context: context,
              initialDate: widget.date,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );

            // Don't change the date if the date picker returns null.
            if (newDate == null) {
              return;
            }

            widget.onChanged(newDate);
          },
        )
      ],
    );
  }
}

@JsonSerializable()
class FormData {
  num? tamanio;
  num? nc;
  num? estimacionError;
  num? probabilidadExito;
  num? probabilidadError;
  num? resultado;
  NivelConfianza? selected;

  FormData(
      {this.tamanio,
      this.nc,
      this.estimacionError,
      this.probabilidadExito,
      this.probabilidadError,
      this.resultado,
      this.selected});
}
