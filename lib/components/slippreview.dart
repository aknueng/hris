import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFPreview extends StatefulWidget {
  const PDFPreview({super.key});

  @override
  State<PDFPreview> createState() => _PDFPreviewState();
}

class _PDFPreviewState extends State<PDFPreview> {
  String? _password;
  final GlobalKey<FormFieldState> _formKey = GlobalKey<FormFieldState>();
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _passwordDialogFocusNode = FocusNode();
  bool _hasPasswordDialog = false;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final argument = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{'url': ''}) as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DCI E-SLIP'),
        toolbarHeight: 56,
      ),
      body: SfPdfViewer.network(
        argument['url'],
        canShowPasswordDialog: false,
        password: _password,
        onDocumentLoaded: (details) {
          if (_hasPasswordDialog) {
            Navigator.pop(context);
            _hasPasswordDialog = false;
            _passwordDialogFocusNode.unfocus();
            _textFieldController.clear();
          }
        },
        onDocumentLoadFailed: (details) {
          if (details.description.contains('password')) {
            if (details.description.contains('password') &&
                _hasPasswordDialog) {
              _errorText = "รหัสไม่ถูกต้อง (Invalid password) !!";
              _formKey.currentState?.validate();
              _textFieldController.clear();
              _passwordDialogFocusNode.requestFocus();
            } else {
              _errorText = '';

              /// Creating custom password dialog.
              _showCustomPasswordDialog();
              _passwordDialogFocusNode.requestFocus();
              _hasPasswordDialog = true;
            }
          }
        },
      ),
    );
  }

  /// Show the customized password dialog
  Future<void> _showCustomPasswordDialog() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          final Orientation orientation = kIsWeb
              ? Orientation.portrait
              : MediaQuery.of(context).orientation;
          return AlertDialog(
            scrollable: true,
            insetPadding: EdgeInsets.zero,
            contentPadding: orientation == Orientation.portrait
                ? const EdgeInsets.all(24)
                : const EdgeInsets.only(top: 0, right: 24, left: 24, bottom: 0),
            buttonPadding: orientation == Orientation.portrait
                ? const EdgeInsets.all(8)
                : const EdgeInsets.all(4),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'กรอกรหัสดูสลิป (DCI E-SLIP)',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.87),
                  ),
                ),
                SizedBox(
                  height: 36,
                  width: 36,
                  child: RawMaterialButton(
                    onPressed: () {
                      _closePasswordDialog();
                    },
                    child: Icon(
                      Icons.clear,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
            content: SingleChildScrollView(
                child: SizedBox(
                    width: 326,
                    child: Column(children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                          child: Text(
                            'กรุณากรอกรหัสเพื่อดูสลิปเงินเดือน \n(Please enter a password)',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                      Form(
                        child: TextFormField(
                          key: _formKey,
                          controller: _textFieldController,
                          focusNode: _passwordDialogFocusNode,
                          obscureText: true,
                          decoration: const InputDecoration(
                              hintText: 'รหัสดูสลิป',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue))),
                          obscuringCharacter: '#',
                          onFieldSubmitted: (value) {
                            _handlePasswordValidation(value);
                          },
                          validator: (value) {
                            if (_errorText.isNotEmpty) {
                              return _errorText;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _formKey.currentState?.validate();
                            _errorText = '';
                          },
                        ),
                      )
                    ]))),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _handlePasswordValidation(_textFieldController.text);
                },
                child: Text(
                  'ยืนยัน',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: TextButton(
                  onPressed: () {
                    _closePasswordDialog();
                  },
                  child: Text(
                    'ยกเลิก',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  ///Close the password dialog
  void _closePasswordDialog() {
    //Navigator.pop(context, 'Cancel');
    Navigator.pushNamed(context, '/slip');
    _hasPasswordDialog = false;
    _passwordDialogFocusNode.unfocus();
    _textFieldController.clear();
  }

  /// Validates the password entered in text field.
  void _handlePasswordValidation(String value) {
    setState(() {
      _password = value;
      _passwordDialogFocusNode.requestFocus();
    });
  }
}
