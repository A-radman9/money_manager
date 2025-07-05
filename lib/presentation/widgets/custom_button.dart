import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50.0,
    this.padding,
    this.borderRadius,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !isLoading) ...[
          icon!,
          const SizedBox(width: 8.0),
        ],
        if (isLoading)
          const SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isOutlined
                  ? (textColor ?? theme.primaryColor)
                  : (textColor ?? Colors.white),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: backgroundColor ?? theme.primaryColor,
              width: 2.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12.0),
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24.0),
          ),
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12.0),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24.0),
          elevation: 2.0,
        ),
        child: buttonChild,
      ),
    );
  }
}

class FloatingActionButtonCustom extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FloatingActionButtonCustom({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? theme.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 4.0,
      child: Icon(icon),
    );
  }
}

class IconButtonCustom extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;

  const IconButtonCustom({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 24.0,
    this.tooltip,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget iconButton = IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: size,
        color: color ?? theme.iconTheme.color,
      ),
      tooltip: tooltip,
      padding: padding ?? const EdgeInsets.all(8.0),
    );

    if (backgroundColor != null) {
      iconButton = Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: iconButton,
      );
    }

    return iconButton;
  }
}

class SegmentedButton extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final void Function(String) onOptionSelected;
  final EdgeInsetsGeometry? margin;

  const SegmentedButton({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option == selectedOption;
          final isFirst = options.first == option;
          final isLast = options.last == option;
          
          return Expanded(
            child: InkWell(
              onTap: () => onOptionSelected(option),
              borderRadius: BorderRadius.horizontal(
                left: isFirst ? const Radius.circular(12.0) : Radius.zero,
                right: isLast ? const Radius.circular(12.0) : Radius.zero,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst ? const Radius.circular(12.0) : Radius.zero,
                    right: isLast ? const Radius.circular(12.0) : Radius.zero,
                  ),
                ),
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isSelected ? Colors.white : theme.textTheme.titleSmall?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
