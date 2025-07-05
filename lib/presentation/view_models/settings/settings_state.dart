import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {
  final Locale locale;

  const SettingsInitial({this.locale = const Locale('en')});

  @override
  List<Object> get props => [locale];
}

class SettingsLoaded extends SettingsState {
  final Locale locale;

  const SettingsLoaded({required this.locale});

  @override
  List<Object> get props => [locale];
}

class SettingsLanguageChanged extends SettingsState {
  final Locale locale;

  const SettingsLanguageChanged({required this.locale});

  @override
  List<Object> get props => [locale];
}
