import 'package:flutter/material.dart';

//Class for InputText that have a default style
class InputTextDialog extends StatefulWidget {
  final Function(String) validator;
  final Function(String) onSaved;
  final bool isSecure;
  final TextInputType inputType;
  final IconData icon;
  final String value;

  const InputTextDialog(
      {Key key,
      this.validator,
      this.isSecure = false,
      this.inputType,
      this.icon,
        this.value = '',
      this.onSaved})
      : super(key: key);

  @override
  _InputTextDialogState createState() => _InputTextDialogState();
}

class _InputTextDialogState extends State<InputTextDialog> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.inputType,
      obscureText: widget.isSecure,
      validator: widget.validator,
      onSaved: widget.onSaved,
      initialValue: widget.value != '' ? widget.value : '',
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black38),
        ),
      ),
    );
  }
}
