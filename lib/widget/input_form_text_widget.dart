import 'package:flutter/material.dart';
import 'package:meeting_app/utils/colors_utils.dart';
import 'package:meeting_app/utils/styles_utils.dart';

//Class for InputForns that have a default style
class InputTextForm extends StatefulWidget {
  final String label;
  final Function(String) validator;
  final bool isSecure;
  final TextInputType inputType;
  final IconData icon;
  final String value;

  const InputTextForm(
      {Key key,
      @required this.label,
      this.validator,
      this.value = '',
      this.isSecure = false,
      this.inputType,
      this.icon})
      : super(key: key);

  @override
  _InputTextFormState createState() => _InputTextFormState();
}

class _InputTextFormState extends State<InputTextForm> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.value,
      cursorColor: ColorProvider.primaryColor,
      style: Styles.textColorWhite,
      keyboardType: widget.inputType,
      obscureText: widget.isSecure,
      validator: widget.validator,
      decoration: InputDecoration(
        //text styles
        labelText: widget.label,
        labelStyle: Styles.textColorWhite,
        alignLabelWithHint: true,
        //borders
        enabledBorder: Styles.enabledInput,
        focusedBorder: Styles.focusedInput,
        errorBorder: Styles.errorInput,
        border: Styles.focusedInput,

        //icon
        suffixIcon: Icon(
          widget.icon,
          color: ColorProvider.white,
        ),
      ),
    );
  }
}
