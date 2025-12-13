// lib/core/app_strings.dart
abstract class AppStrings {
  static const String appTitle = 'Міні-щоденник настрою';
  static const String login = 'Вхід у щоденник';
  static const String register = 'Реєстрація';
  static const String emailHint = 'Email';
  static const String passwordHint = 'Пароль';
  static const String nameHint = "Ім'я";
  static const String surnameHint = 'Прізвище';
  static const String loginButton = 'Увійти';
  static const String registerButton = 'Зареєструватися';
  static const String noAccount = 'Немає акаунта? Зареєструйтесь';
  static const String hasAccount = 'Вже маєте акаунт? Увійдіть';
  static const String errorFillFields = 'Заповніть усі поля';
  static const String errorUserExists = 'Такий користувач вже існує';
  static const String successRegister = 'Реєстрація успішна! Тепер увійдіть.';
  static const String errorWrongCredentials = 'Неправильний email або пароль';

  // AddEntryPage
  static const String addEntryTitle = 'Додати запис';
  static const String moodLabel = 'Настрій';
  static const String noteHint = 'Нотатка';
  static const String saveButton = 'Зберегти';

  const AppStrings._();
}