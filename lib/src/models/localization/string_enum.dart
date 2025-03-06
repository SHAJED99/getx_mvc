// ignore_for_file: public_member_api_docs
part of 'app_translations.dart';

/// App text for different language
enum TextEnum {
  version(en: 'Version', bn: 'সংস্করণ'),

  // AuthenticationWrapperScreen
  provideEmailResetPassword(
    en: '''Provide your email to reset the password. An email to reset password will be sent to the given email.''',
    bn: '''পাসওয়ার্ড রিসেট করতে আপনার ইমেল প্রদান করুন। প্রদত্ত ইমেলে পাসওয়ার্ড রিসেট করার জন্য একটি ইমেল পাঠানো হবে।''',
  ),
  provideEmailPasswordLoginApp(
    en: '''Provide email and password to login into the app.''',
    bn: '''অ্যাপে লগইন করতে ইমেল এবং পাসওয়ার্ড প্রদান করুন।''',
  ),
  provideEmailPasswordSignupApp(
    en: '''Provide email and password to signup into the app.''',
    bn: '''অ্যাপে সাইন আপ করতে ইমেল এবং পাসওয়ার্ড প্রদান করুন।''',
  ),
  resetPassword(
    en: 'Reset password',
    bn: 'পাসওয়ার্ড রিসেট করুন',
  ),
  login(
    en: 'Login',
    bn: 'লগইন',
  ),
  signup(
    en: 'Signup',
    bn: 'সাইন আপ',
  ),
  email(
    en: 'Email',
    bn: 'ইমেল',
  ),
  enterYourEmail(
    en: 'Enter your email',
    bn: 'আপনার ইমেল লিখুন',
  ),
  password(
    en: 'Password',
    bn: 'পাসওয়ার্ড',
  ),
  enterYourPassword(
    en: 'Enter your password',
    bn: 'আপনার পাসওয়ার্ড লিখুন',
  ),
  reset(
    en: 'Reset',
    bn: 'রিসেট',
  ),
  forgotPassword(
    en: 'Forgot Password',
    bn: 'পাসওয়ার্ড ভুলে গেছেন',
  ),
  alreadyHaveAccount(
    en: 'Already have an account?',
    bn: 'ইতিমধ্যে একটি অ্যাকাউন্ট আছে?',
  ),

  // TODO: Add more entries as required
  ;

  const TextEnum({required String en, String? bn})
      : _en = en,
        _bn = bn ?? en;

  final String _en;
  final String _bn;

  String get tr => name.tr;
}
