import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The app's icon set. The design system uses Lucide icons at 18px with a
/// 1.5px stroke; widgets should reference icons only through this class so the
/// set can be swapped in one place.
abstract class AppIcons {
  // Destinations
  static const IconData home = LucideIcons.house;
  static const IconData queue = LucideIcons.users;
  static const IconData patients = LucideIcons.folderHeart;
  static const IconData clinic = LucideIcons.stethoscope;
  static const IconData hospital = LucideIcons.hospital;
  static const IconData notifications = LucideIcons.bell;
  static const IconData consultations = LucideIcons.fileText;
  static const IconData labResults = LucideIcons.flaskConical;
  static const IconData more = LucideIcons.menu;

  // Actions and status
  static const IconData search = LucideIcons.search;
  static const IconData logout = LucideIcons.logOut;
  static const IconData alert = LucideIcons.triangleAlert;
  static const IconData error = LucideIcons.circleAlert;
  static const IconData calendarDays = LucideIcons.calendarDays;
  static const IconData chevronLeft = LucideIcons.chevronLeft;
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData chevronDown = LucideIcons.chevronDown;
  static const IconData chevronUp = LucideIcons.chevronUp;
  static const IconData filter = LucideIcons.listFilter;
  static const IconData rowMenu = LucideIcons.ellipsisVertical;
  static const IconData check = LucideIcons.check;
  static const IconData checkCheck = LucideIcons.checkCheck;
  static const IconData circleCheck = LucideIcons.circleCheck;
  static const IconData eye = LucideIcons.eye;
  static const IconData edit = LucideIcons.pencil;
  static const IconData info = LucideIcons.info;
  static const IconData close = LucideIcons.x;
  static const IconData clock = LucideIcons.clock;
  static const IconData sparkles = LucideIcons.sparkles;
  static const IconData userCheck = LucideIcons.userCheck;
  static const IconData userCog = LucideIcons.userCog;
  static const IconData nurse = LucideIcons.heartPulse;

  // Quick actions and attention items
  static const IconData addWalkIn = LucideIcons.userRoundPlus;
  static const IconData registerPatient = LucideIcons.userPlus;
  static const IconData bookAppointment = LucideIcons.calendarPlus;
  static const IconData takePayment = LucideIcons.creditCard;
  static const IconData conflict = LucideIcons.circleX;
  static const IconData payments = LucideIcons.circleDollarSign;

  // Arrows and indicators
  static const IconData arrowRight = LucideIcons.arrowRight;
  static const IconData arrowLeft = LucideIcons.arrowLeft;
  static const IconData arrowUpRight = LucideIcons.arrowUpRight;
  static const IconData lock = LucideIcons.lock;
  static const IconData file = LucideIcons.file;
  static const IconData fileText = LucideIcons.fileText;
  static const IconData calendar = LucideIcons.calendar;
  static const IconData broadcast = LucideIcons.radio;
}
