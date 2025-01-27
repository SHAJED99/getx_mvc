import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//! ------------------------------------------------------------------ Dimension
/// Designed screen size
const Size defaultBaseScreenSize = Size(360, 690);

/// Default spacing
double get defaultPadding => 24.sp;

/// Button Height.
/// Also can be accessed using `Theme.of(context).buttonTheme.height`
double get defaultButtonHeight => defaultPadding * 2;

/// The maximum with the widget takes.
const double defaultMaxBoxWidth = 400;

//* Border
/// Border width 1.sp
double get defaultBorderWidth1 => 1.sp;

/// Border width 1.sp
double get defaultBorderWidth2 => 2.sp;

//! ------------------------------------------------------- Animation & Duration
/// Animation curve
const Curve defaultCurve = Curves.easeInOut;

/// Splash screen waiting time
const Duration defaultSplashScreenShow = Duration(seconds: 3);

/// Animation duration
const Duration defaultDuration = Duration(milliseconds: 500);

/// OTP resend waiting time
const Duration defaultOtpWaiting = Duration(seconds: 120);

//! ----------------------------------------------------------------- Validation
/// Phone number length
const int defaultPhoneNumberLength = 11;

/// Name minium length
const int defaultNameMinLength = 8;

/// Password minium length
const int defaultPasswordMinLength = 6;

/// Address minium length
const int defaultAddressLength = 10;

/// Email validation pattern
const String defaultEmailValidationPattern =
    r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$';

/// OTP length
const int defaultOtpValidationLength = 5;
