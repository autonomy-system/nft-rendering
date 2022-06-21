import 'package:flutter/material.dart';
import 'package:nft_rendering/nft_rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo NFT Display'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _inputPreviewUrl = "";
  String _mimeType = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 170,
            child: InputProperty(callbackAction: _callbackFromInputProperty),
          ),
          _inputPreviewUrl.isNotEmpty && _mimeType.isNotEmpty
              ? Expanded(
                  child: Center(
                    child: NFTRenderingCombineWidget(
                      mimeType: _mimeType,
                      previewURL: _inputPreviewUrl,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  void _callbackFromInputProperty(String mimeType, String previewUrl) {
    setState(() {
      _inputPreviewUrl = previewUrl;
      _mimeType = mimeType;
    });
  }
}

class InputProperty extends StatefulWidget {
  const InputProperty({Key? key, required this.callbackAction})
      : super(key: key);

  final Function callbackAction;
  @override
  State<StatefulWidget> createState() {
    return _StateInputProperty();
  }
}

class _StateInputProperty extends State<InputProperty> {
  String _dropdownValue = typesOfNFTRenderingWidget.keys.toList().first;
  final TextEditingController textEdittingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _inputPreviewUrl(),
        _dropdownListMimeType(),
        _renderButton(),
      ],
    );
  }

  Widget _dropdownListMimeType() {
    if (typesOfNFTRenderingWidget.isNotEmpty) {
      List<String> listValue = typesOfNFTRenderingWidget.keys.toList();
      return Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: DropdownButton<String>(
          isExpanded: true,
          value: _dropdownValue,
          icon: const Icon(
            Icons.arrow_downward,
            size: 18,
            color: Colors.blueAccent,
          ),
          elevation: 16,
          style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
          underline: Container(
            height: 2,
            color: Colors.blueAccent,
          ),
          onChanged: (String? newValue) {
            setState(() {
              _dropdownValue = newValue!;
            });
          },
          items: listValue.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      );
    }
    return const SizedBox();
  }

  Widget _inputPreviewUrl() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: TextFormField(
        controller: textEdittingController,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          border: UnderlineInputBorder(),
          labelText: "Enter your url",
        ),
        onChanged: (value) {},
      ),
    );
  }

  Widget _renderButton() {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(100, 50),
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.all(0),
      ),
      onPressed: () {
        String url = textEdittingController.text;
        if (url.isNotEmpty) {
          widget.callbackAction(_dropdownValue, url);
        }
      },
      child: const Text(
        "Render NFT",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    textEdittingController.dispose();
    super.dispose();
  }
}
