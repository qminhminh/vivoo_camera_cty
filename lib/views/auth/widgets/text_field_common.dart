// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:vivoo_camera_cty/common/app_style.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';

class TextFieldCommon extends StatelessWidget {
  const TextFieldCommon({
    Key? key,
    this.prefixIcon,
    this.keyboardType,
    this.onEditingComplete,
    this.controller,
    this.hintText,
    this.focusNode,
    this.initialValue,
  }) : super(key: key);
  final String? hintText;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final void Function()? onEditingComplete;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      textInputAction: TextInputAction.next,
      onEditingComplete: onEditingComplete,
      keyboardType: keyboardType,
      initialValue: initialValue,
      controller: controller,
      validator: (value) {
        if (value!.isEmpty) {
          return "Please enter a valid value";
        } else {
          return null;
        }
      },
      style: appStyle(16, kDark, FontWeight.normal),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        isDense: false,

        hintStyle: appStyle(14, kGray, FontWeight.normal),
        // contentPadding: EdgeInsets.only(left: 24),
        errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: kDark, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: kGray, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: kGray, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: kDark, width: 0.5),
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
      ),
    );
  }
}
