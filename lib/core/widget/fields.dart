import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:incidents_managment/core/constant/colors.dart';

// ============= CUSTOM TEXT FORM FIELD =============
class CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;

  final String? text;
  final String? labelText;
  final String? hintText;
  final String? initialValue;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final bool useValidator;

  final IconData? iconData;
  final Widget? prefixWidget;
  final Widget? suffixWidget;

  final bool enableTogglePassword;
  final bool isPhoneField;
  final bool isNumberField;
  final bool useThousandsSeparator;
  final bool allowDecimals;
  final int decimalPlaces;
  final VoidCallback? onSelectCountry;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.validator,
    this.text,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.useValidator = true,
    this.iconData,
    this.prefixWidget,
    this.suffixWidget,
    this.enableTogglePassword = false,
    this.isPhoneField = false,
    this.isNumberField = false,
    this.useThousandsSeparator = false,
    this.allowDecimals = false,
    this.decimalPlaces = 2,
    this.onSelectCountry,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();

  // ============= FACTORY CONSTRUCTORS =============
  static CustomTextFormField password({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? labelText,
    String? hintText,
    String? labelAboveField,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onFieldSubmitted,
    TextInputAction? textInputAction,
    bool enabled = true,
  }) => CustomTextFormField(
    key: key,
    controller: controller,
    focusNode: focusNode,
    labelText: labelText,
    hintText: hintText,
    text: labelAboveField,
    iconData: Icons.lock_outline,
    obscureText: true,
    enableTogglePassword: true,
    validator: validator,
    onChanged: onChanged,
    onFieldSubmitted: onFieldSubmitted,
    textInputAction: textInputAction ?? TextInputAction.done,
    enabled: enabled,
  );

  static CustomTextFormField phone({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? labelText,
    String? hintText,
    String? labelAboveField,
    required VoidCallback onSelectCountry,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    TextInputAction? textInputAction,
    bool enabled = true,
  }) => CustomTextFormField(
    key: key,
    controller: controller,
    focusNode: focusNode,
    labelText: labelText,
    hintText: hintText,
    text: labelAboveField,
    isPhoneField: true,
    onSelectCountry: onSelectCountry,
    keyboardType: TextInputType.phone,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: validator,
    onChanged: onChanged,
    textInputAction: textInputAction ?? TextInputAction.next,
    enabled: enabled,
  );

  static CustomTextFormField number({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? labelText,
    String? hintText,
    String? labelAboveField,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    TextInputAction? textInputAction,
    bool enabled = true,
    bool useThousandsSeparator = true,
    bool allowDecimals = false,
    int decimalPlaces = 2,
  }) => CustomTextFormField(
    key: key,
    controller: controller,
    focusNode: focusNode,
    labelText: labelText,
    hintText: hintText,
    text: labelAboveField,
    isNumberField: true,
    useThousandsSeparator: useThousandsSeparator,
    allowDecimals: allowDecimals,
    decimalPlaces: decimalPlaces,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    validator: validator,
    onChanged: onChanged,
    textInputAction: textInputAction ?? TextInputAction.done,
    enabled: enabled,
  );

  static CustomTextFormField currency({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? labelText,
    String? hintText,
    String? labelAboveField,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    TextInputAction? textInputAction,
    bool enabled = true,
    int decimalPlaces = 2,
  }) => CustomTextFormField(
    key: key,
    controller: controller,
    focusNode: focusNode,
    labelText: labelText,
    hintText: hintText,
    text: labelAboveField,
    isNumberField: true,
    useThousandsSeparator: true,
    allowDecimals: true,
    decimalPlaces: decimalPlaces,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    validator: validator,
    onChanged: onChanged,
    textInputAction: textInputAction ?? TextInputAction.done,
    enabled: enabled,
  );
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMultiline = widget.maxLines != null && widget.maxLines! > 1;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      initialValue: widget.initialValue,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      obscureText: _isObscured,
      maxLines: _isObscured ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: _getKeyboardType(),
      textInputAction: widget.textInputAction,
      inputFormatters: _getInputFormatters(),
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
      cursorColor: appColor,
      decoration: InputDecoration(
        fillColor: fieldColor,
        filled: true,
        labelText: widget.labelText,
        labelStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          color: appColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        counterText: widget.maxLength != null ? null : '',
        counterStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        errorStyle: const TextStyle(fontSize: 12, height: 0.8),
        prefixIcon: _buildPrefixWidget(),
        suffixIcon: _buildSuffixWidget(),
        contentPadding: EdgeInsets.symmetric(
          vertical: isMultiline ? 16 : 16,
          horizontal: widget.iconData != null || widget.prefixWidget != null
              ? 8
              : 16,
        ),
      ),
      validator: widget.useValidator ? _getValidator() : null,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onEditingComplete: widget.onEditingComplete,
    );
  }

  TextInputType _getKeyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType!;
    if (widget.isPhoneField) return TextInputType.phone;
    if (widget.isNumberField) {
      return TextInputType.numberWithOptions(decimal: widget.allowDecimals);
    }
    return TextInputType.text;
  }

  List<TextInputFormatter>? _getInputFormatters() {
    if (widget.inputFormatters != null) return widget.inputFormatters;

    final List<TextInputFormatter> formatters = [];

    if (widget.isPhoneField) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }

    if (widget.isNumberField) {
      if (widget.allowDecimals) {
        formatters.add(
          FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d{0,' + widget.decimalPlaces.toString() + r'}'),
          ),
        );
      } else {
        formatters.add(FilteringTextInputFormatter.digitsOnly);
      }
    }

    return formatters.isEmpty ? null : formatters;
  }

  Widget? _buildPrefixWidget() {
    if (widget.prefixWidget != null) return widget.prefixWidget;

    if (widget.iconData != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Icon(widget.iconData, color: appColor, size: 22),
      );
    }

    return null;
  }

  Widget? _buildSuffixWidget() {
    if (widget.suffixWidget != null) return widget.suffixWidget;

    if (widget.enableTogglePassword && widget.obscureText) {
      return IconButton(
        icon: Icon(
          _isObscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: Colors.grey.shade600,
          size: 22,
        ),
        onPressed: widget.enabled
            ? () => setState(() => _isObscured = !_isObscured)
            : null,
        splashRadius: 20,
      );
    }

    return null;
  }

  FormFieldValidator<String>? _getValidator() {
    return widget.validator ??
        (value) {
          if (value == null || value.trim().isEmpty) {
            return "هذا الحقل مطلوب";
          }
          return null;
        };
  }
}

// ============= CUSTOM DROPDOWN FORM FIELD =============
class CustomDropdownFormField<T> extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final IconData? iconData;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool useValidator;
  final bool readOnly;

  const CustomDropdownFormField({
    super.key,
    this.labelText,
    required this.items,
    this.hintText,
    this.iconData,
    this.value,
    this.onChanged,
    this.validator,
    this.useValidator = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: readOnly ? null : onChanged,
      validator: useValidator
          ? validator ?? (val) => val == null ? "هذا الحقل مطلوب" : null
          : null,
      decoration: InputDecoration(
        fillColor: fieldColor,
        filled: true,
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          color: appColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        prefixIcon: iconData != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(iconData, color: appColor, size: 22),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: iconData != null ? 8 : 16,
        ),
        errorStyle: const TextStyle(fontSize: 12, height: 0.8),
      ),
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
      dropdownColor: Colors.white,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.grey.shade600,
        size: 28,
      ),
      iconSize: 28,
      isExpanded: true,
      menuMaxHeight: 400,
      borderRadius: BorderRadius.circular(12),
      elevation: 8,
      hint: hintText != null
          ? Text(
              hintText!,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            )
          : null,
      selectedItemBuilder: value != null
          ? (BuildContext context) {
              return items.map<Widget>((DropdownMenuItem<T> item) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    item.child is Text ? (item.child as Text).data ?? '' : '',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList();
            }
          : null,
    );
  }
}

// ============= TEXT CONTROLLER EXTENSIONS =============
extension TextEditingControllerExtension on TextEditingController {
  int? get numericValue {
    final cleaned = text.replaceAll(',', '');
    return int.tryParse(cleaned);
  }

  double? get decimalValue {
    final cleaned = text.replaceAll(',', '');
    return double.tryParse(cleaned);
  }

  set numericValue(int? value) {
    if (value == null) {
      text = '';
    } else {
      text = NumberFormat('#,###').format(value);
    }
  }

  void setDecimalValue(double? value, {int decimalPlaces = 2}) {
    if (value == null) {
      text = '';
    } else {
      text = NumberFormat('#,##0.${'0' * decimalPlaces}').format(value);
    }
  }
}

// ============= CUSTOM BUTTON =============
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final Color textColor;
  final Color borderColor;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56,
    this.borderRadius = 12,
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.borderColor = appColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? appColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? appColor).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
