// lib/shared/widgets/inputs/custom_inputs.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_themes.dart';
import '../../../core/constants/ui_config.dart';
import '../buttons/custom_buttons.dart';

/// Виджет для выбора времени (минуты:секунды)
class TimePicker extends StatefulWidget {
  final int initialMinutes;
  final int initialSeconds;
  final ValueChanged<Duration>? onChanged;
  final String? label;
  final int maxMinutes;
  final int maxSeconds;

  const TimePicker({
    super.key,
    this.initialMinutes = 0,
    this.initialSeconds = 0,
    this.onChanged,
    this.label,
    this.maxMinutes = 99,
    this.maxSeconds = 59,
  });

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialMinutes;
    _seconds = widget.initialSeconds;
    _minutesController = TextEditingController(text: _minutes.toString().padLeft(2, '0'));
    _secondsController = TextEditingController(text: _seconds.toString().padLeft(2, '0'));
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final duration = Duration(minutes: _minutes, seconds: _seconds);
    widget.onChanged?.call(duration);
  }

  void _onMinutesChanged(String value) {
    final minutes = int.tryParse(value) ?? 0;
    if (minutes >= 0 && minutes <= widget.maxMinutes) {
      setState(() {
        _minutes = minutes;
        _minutesController.text = minutes.toString().padLeft(2, '0');
      });
      _updateTime();
    }
  }

  void _onSecondsChanged(String value) {
    final seconds = int.tryParse(value) ?? 0;
    if (seconds >= 0 && seconds <= widget.maxSeconds) {
      setState(() {
        _seconds = seconds;
        _secondsController.text = seconds.toString().padLeft(2, '0');
      });
      _updateTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Лейбл (если есть)
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: customTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
        ],

        // Поля ввода времени
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Минуты
            Container(
              width: screenWidth * 0.2,
              height: screenHeight * 0.08,
              decoration: BoxDecoration(
                color: customTheme.cardColor,
                borderRadius: BorderRadius.circular(
                  screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
                ),
                border: Border.all(
                  color: customTheme.buttonPrimaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: TextField(
                controller: _minutesController,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: screenHeight * UIConfig.timerDisplayFontSizeFactor * 0.4,
                  fontWeight: FontWeight.bold,
                  color: customTheme.textPrimaryColor,
                  fontFamily: AppThemes.timerFontFamily,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: _onMinutesChanged,
              ),
            ),

            // Разделитель
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: Text(
                ':',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: screenHeight * UIConfig.timerDisplayFontSizeFactor * 0.4,
                  fontWeight: FontWeight.bold,
                  color: customTheme.textPrimaryColor,
                  fontFamily: AppThemes.timerFontFamily,
                ),
              ),
            ),

            // Секунды
            Container(
              width: screenWidth * 0.2,
              height: screenHeight * 0.08,
              decoration: BoxDecoration(
                color: customTheme.cardColor,
                borderRadius: BorderRadius.circular(
                  screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
                ),
                border: Border.all(
                  color: customTheme.buttonPrimaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: TextField(
                controller: _secondsController,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: screenHeight * UIConfig.timerDisplayFontSizeFactor * 0.4,
                  fontWeight: FontWeight.bold,
                  color: customTheme.textPrimaryColor,
                  fontFamily: AppThemes.timerFontFamily,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: _onSecondsChanged,
              ),
            ),
          ],
        ),

        // Подсказки
        SizedBox(height: screenHeight * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth * 0.2,
              child: Text(
                'мин',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: customTheme.textSecondaryColor,
                  fontSize: screenHeight * UIConfig.bodyFontSizeFactor * 0.8,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.06),
            SizedBox(
              width: screenWidth * 0.2,
              child: Text(
                'сек',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: customTheme.textSecondaryColor,
                  fontSize: screenHeight * UIConfig.bodyFontSizeFactor * 0.8,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Виджет ввода числового значения с кнопками +/-
class NumberInput extends StatefulWidget {
  final int initialValue;
  final int minValue;
  final int maxValue;
  final int step;
  final ValueChanged<int>? onChanged;
  final String? label;
  final String? suffix;

  const NumberInput({
    super.key,
    this.initialValue = 0,
    this.minValue = 0,
    this.maxValue = 100,
    this.step = 1,
    this.onChanged,
    this.label,
    this.suffix,
  });

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.clamp(widget.minValue, widget.maxValue);
  }

  void _increment() {
    if (_value + widget.step <= widget.maxValue) {
      setState(() {
        _value += widget.step;
      });
      widget.onChanged?.call(_value);
    }
  }

  void _decrement() {
    if (_value - widget.step >= widget.minValue) {
      setState(() {
        _value -= widget.step;
      });
      widget.onChanged?.call(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Лейбл (если есть)
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: customTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
        ],

        // Контейнер с кнопками и значением
        Container(
          height: screenHeight * 0.07,
          decoration: BoxDecoration(
            color: customTheme.cardColor,
            borderRadius: BorderRadius.circular(
              screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
            ),
            border: Border.all(
              color: customTheme.buttonPrimaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Кнопка уменьшения
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _value > widget.minValue ? _decrement : null,
                  borderRadius: BorderRadius.circular(
                    screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
                  ),
                  child: Container(
                    width: screenHeight * 0.07,
                    height: screenHeight * 0.07,
                    decoration: BoxDecoration(
                      color: _value > widget.minValue
                          ? customTheme.buttonPrimaryColor.withOpacity(0.1)
                          : customTheme.buttonDisabledColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
                      ),
                    ),
                    child: Icon(
                      Icons.remove,
                      color: _value > widget.minValue
                          ? customTheme.buttonPrimaryColor
                          : customTheme.buttonDisabledColor,
                      size: screenWidth * 0.05,
                    ),
                  ),
                ),
              ),

              // Значение
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _value.toString(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: screenHeight * UIConfig.titleFontSizeFactor,
                          fontWeight: FontWeight.bold,
                          color: customTheme.textPrimaryColor,
                        ),
                      ),
                      if (widget.suffix != null) ...[
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          widget.suffix!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: customTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Кнопка увеличения
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _value < widget.maxValue ? _increment : null,
                  borderRadius: BorderRadius.circular(
                    screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
                  ),
                  child: Container(
                    width: screenHeight * 0.07,
                    height: screenHeight * 0.07,
                    decoration: BoxDecoration(
                      color: _value < widget.maxValue
                          ? customTheme.buttonPrimaryColor.withOpacity(0.1)
                          : customTheme.buttonDisabledColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        screenWidth * UIConfig.containerBorderRadiusFactor * 0.7,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: _value < widget.maxValue
                          ? customTheme.buttonPrimaryColor
                          : customTheme.buttonDisabledColor,
                      size: screenWidth * 0.05,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Кастомный слайдер
class CustomSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double>? onChanged;
  final String? label;
  final String Function(double)? valueFormatter;

  const CustomSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions = 100,
    this.onChanged,
    this.label,
    this.valueFormatter,
  });

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value.clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Лейбл и значение
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.label != null)
              Text(
                widget.label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: customTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Text(
              widget.valueFormatter?.call(_currentValue) ?? _currentValue.toStringAsFixed(0),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: customTheme.buttonPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        SizedBox(height: screenHeight * 0.01),

        // Слайдер
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: customTheme.buttonPrimaryColor,
            inactiveTrackColor: customTheme.buttonPrimaryColor.withOpacity(0.3),
            thumbColor: customTheme.buttonPrimaryColor,
            overlayColor: customTheme.buttonPrimaryColor.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: _currentValue,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: (value) {
              setState(() {
                _currentValue = value;
              });
              widget.onChanged?.call(value);
            },
          ),
        ),
      ],
    );
  }
}