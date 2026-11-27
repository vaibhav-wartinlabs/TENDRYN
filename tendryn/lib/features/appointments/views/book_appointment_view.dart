import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/appointments/controllers/appointments_controller.dart';
import 'package:tendryn/features/appointments/controllers/book_appointment_controller.dart';
import 'package:tendryn/features/appointments/views/appointments_view.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/features/dashboard/views/dashboard_view.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/features/queue/models/walk_in_patient.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/dashboard_service.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/desktop/desktop_scaffold.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';

const _subtitle = 'Schedule a receptionist-managed visit.';

/// Full page for Mobile and Tablet; desktop renders the underlying page with the
/// right-hand slide drawer [BookAppointmentDrawer] over it.
/// In Mobile and Tablet, the bottom navigation bar is omitted.
class BookAppointmentView extends GetView<BookAppointmentController> {
  const BookAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (ResponsiveHelper.screenType(context)) {
      LayoutType.desktop => _buildDesktop(context),
      LayoutType.tablet => _Tablet(controller: controller),
      LayoutType.mobile => _Mobile(controller: controller),
    };
  }

  // ---------------------------------------------------------------------------
  // Desktop Layout (Background page on left + darkened overlay + Drawer on right)
  // ---------------------------------------------------------------------------
  Widget _buildDesktop(BuildContext context) {
    final isFromAppointments = controller.returnRoute == AppRoutes.appointments;

    if (isFromAppointments) {
      if (!Get.isRegistered<AppointmentsController>()) {
        Get.put(AppointmentsController());
      }
    } else {
      if (!Get.isRegistered<DashboardController>()) {
        if (Get.isRegistered<DashboardService>() && Get.isRegistered<AuthController>()) {
          final dash = Get.put(DashboardController(
            service: Get.find<DashboardService>(),
            auth: Get.find<AuthController>(),
          ));
          dash.load();
        }
      } else {
        final dash = Get.find<DashboardController>();
        if (dash.summary.value == null) {
          dash.load();
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Underlying desktop scaffold with side navigation, top bar, and content
          Positioned.fill(
            child: DesktopScaffold(
              route: isFromAppointments ? AppRoutes.appointments : AppRoutes.dashboard,
              child: isFromAppointments ? const AppointmentsView() : const DashboardView(),
            ),
          ),
          // Darkened semi-transparent overlay
          Positioned.fill(
            child: GestureDetector(
              key: const Key('book_appointment_overlay'),
              onTap: controller.cancel,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ),
          // Right-side drawer
          const Align(
            alignment: Alignment.centerRight,
            child: BookAppointmentDrawer(),
          ),
          // Conflict dialog overlay
          Obx(() {
            if (!controller.showConflict.value) return const SizedBox.shrink();
            return _AppointmentConflictOverlay(controller: controller);
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tablet Layout
// ---------------------------------------------------------------------------

class _Tablet extends StatelessWidget {
  const _Tablet({required this.controller});

  final BookAppointmentController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.backgroundApp,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const TabletHeader(),
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.pageMarginDesktop,
                    Dimensions.spaceMd,
                    Dimensions.pageMarginDesktop,
                    Dimensions.spaceMd,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundSurface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.borderDefault),
                    ),
                  ),
                  child: Row(
                    children: [
                      _BackButton(onTap: controller.cancel),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Book Appointment',
                              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _subtitle,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.pageMarginDesktop,
                      vertical: Dimensions.spaceLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Patient section (full width)
                        _FindPatientSection(controller: controller),
                        const SizedBox(height: 16),

                        // Practitioner section (full width card)
                        _PractitionerSection(controller: controller),
                        const SizedBox(height: 16),

                        // 2-Column section: Left = Date & Calendar, Right = Slots, Visit Type, Notes
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column: Date & Calendar
                            Expanded(
                              child: _DateCalendarCard(controller: controller, isTablet: true),
                            ),
                            const SizedBox(width: 16),
                            // Right column: Available slots, Visit type, Scheduling notes
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundSurface,
                                  borderRadius: BorderRadius.circular(Dimensions.radius),
                                  border: Border.all(color: AppColors.borderDefault),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _AvailableSlotsSection(controller: controller),
                                    const SizedBox(height: 24),
                                    _VisitTypeSection(controller: controller),
                                    const SizedBox(height: 24),
                                    _SchedulingNotesSection(controller: controller),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _BottomActionBar(controller: controller),
        ),
        // Conflict dialog overlay
        Obx(() {
          if (!controller.showConflict.value) return const SizedBox.shrink();
          return _AppointmentConflictOverlay(controller: controller);
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile Layout
// ---------------------------------------------------------------------------

class _Mobile extends StatelessWidget {
  const _Mobile({required this.controller});

  final BookAppointmentController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.backgroundApp,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.pageMarginMobile,
                    12,
                    Dimensions.pageMarginMobile,
                    12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundSurface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.borderDefault),
                    ),
                  ),
                  child: Row(
                    children: [
                      _BackButton(onTap: controller.cancel),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Book Appointment',
                              style: AppTextStyles.h2Mobile.copyWith(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _subtitle,
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.pageMarginMobile,
                      Dimensions.spaceLg,
                      Dimensions.pageMarginMobile,
                      Dimensions.spaceLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Find patient search and card
                        _FindPatientSection(controller: controller),
                        const SizedBox(height: 16),

                        // Practitioner dropdown
                        _PractitionerSection(controller: controller),
                        const SizedBox(height: 16),

                        // Date section with expandable calendar
                        _DateCalendarCard(controller: controller, isTablet: false),
                        const SizedBox(height: 16),

                        // Available slots
                        _AvailableSlotsSection(controller: controller),
                        const SizedBox(height: Dimensions.pageSectionGap),

                        // Visit Type
                        _VisitTypeSection(controller: controller),
                        const SizedBox(height: Dimensions.pageSectionGap),

                        // Scheduling notes
                        _SchedulingNotesSection(controller: controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _BottomActionBar(controller: controller),
        ),
        // Conflict dialog overlay
        Obx(() {
          if (!controller.showConflict.value) return const SizedBox.shrink();
          return _AppointmentConflictOverlay(controller: controller);
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop Drawer (Side Sheet matching Figma prototype 1:1)
// ---------------------------------------------------------------------------

class BookAppointmentDrawer extends StatelessWidget {
  const BookAppointmentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookAppointmentController>();
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.white,
        child: Container(
          width: Dimensions.drawerWidth,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x240F1F1D),
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Book Appointment',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            _subtitle,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkResponse(
                      onTap: controller.cancel,
                      radius: 16,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(AppIcons.close, size: 18, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

              // Body (Scrollable form)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FindPatientSection(controller: controller),
                      const SizedBox(height: 16),
                      _PractitionerSection(controller: controller),
                      const SizedBox(height: 16),
                      _DateCalendarCard(controller: controller, isTablet: false),
                      const SizedBox(height: 16),
                      _AvailableSlotsSection(controller: controller),
                      const SizedBox(height: 16),
                      _VisitTypeSection(controller: controller),
                      const SizedBox(height: 16),
                      _SchedulingNotesSection(controller: controller),
                      const SizedBox(height: Dimensions.pageSectionGap),
                    ],
                  ),
                ),
              ),

              // Bottom Actions (Sticky footer)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.borderDefault,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _DrawerCancelButton(onTap: controller.cancel),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DrawerBookButton(onTap: controller.bookAppointment),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerCancelButton extends StatefulWidget {
  const _DrawerCancelButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_DrawerCancelButton> createState() => _DrawerCancelButtonState();
}

class _DrawerCancelButtonState extends State<_DrawerCancelButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: Dimensions.buttonMinHeight,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.brandTint : Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(
              color: _isHovered ? AppColors.brandPrimary : AppColors.borderDefault,
              width: _isHovered ? 1.4 : 1,
            ),
          ),
          child: const Center(
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.brandPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerBookButton extends StatefulWidget {
  const _DrawerBookButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_DrawerBookButton> createState() => _DrawerBookButtonState();
}

class _DrawerBookButtonState extends State<_DrawerBookButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: Dimensions.buttonMinHeight,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.brandHover : AppColors.brandPrimary,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.brandPrimary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: const Center(
            child: Text(
              'Book Appointment',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper to open the desktop drawer.
void showBookAppointmentDrawer(
  BuildContext context, {
  String returnRoute = AppRoutes.dashboard,
  WalkInPatient? initialPatient,
  PatientQuickViewModel? initialQuickPatient,
  DateTime? initialDate,
  String? initialSlot,
  String? initialPractitioner,
}) {
  if (Get.isRegistered<BookAppointmentController>()) {
    Get.delete<BookAppointmentController>();
  }

  Get.put(BookAppointmentController(
    returnRoute: returnRoute,
    initialPatient: initialPatient,
    initialQuickPatient: initialQuickPatient,
    initialDate: initialDate,
    initialSlot: initialSlot,
    initialPractitioner: initialPractitioner,
  ));

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, _, _) {
      final controller = Get.find<BookAppointmentController>();
      return Stack(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: BookAppointmentDrawer(),
          ),
          Obx(() {
            if (!controller.showConflict.value) return const SizedBox.shrink();
            return _AppointmentConflictOverlay(controller: controller);
          }),
        ],
      );
    },
    transitionBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ).then((_) {
    if (Get.isRegistered<BookAppointmentController>()) {
      Get.delete<BookAppointmentController>();
    }
  });
}

// ---------------------------------------------------------------------------
// Section Components
// ---------------------------------------------------------------------------

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: Dimensions.touchTarget / 2,
      child: SizedBox.square(
        dimension: Dimensions.touchTarget,
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              border: Border.all(color: AppColors.borderDefault),
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
            child: const Icon(AppIcons.chevronLeft, size: 20, color: AppColors.brandPrimary),
          ),
        ),
      ),
    );
  }
}

class _FindPatientSection extends StatefulWidget {
  const _FindPatientSection({required this.controller});

  final BookAppointmentController controller;

  @override
  State<_FindPatientSection> createState() => _FindPatientSectionState();
}

class _FindPatientSectionState extends State<_FindPatientSection> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted && _isFocused != _focusNode.hasFocus) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isActive = _isFocused || _isHovered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Find patient',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),

        // Search Input Box (Highlights green on hover, touch, and focus)
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.text,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(
                color: isActive ? AppColors.brandPrimary : AppColors.borderDefault,
                width: isActive ? 1.5 : 1.2,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.brandPrimary.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.search,
                  size: 18,
                  color: isActive ? AppColors.brandPrimary : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller.searchText,
                    focusNode: _focusNode,
                    onChanged: controller.search,
                    cursorColor: AppColors.brandPrimary,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search patient by name',
                      hintStyle: TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Obx(() {
                  if (controller.searchQuery.value.isNotEmpty || controller.selectedPatient.value != null) {
                    return InkResponse(
                      onTap: controller.clearSearch,
                      radius: 16,
                      child: const Icon(AppIcons.close, size: 16, color: AppColors.textSecondary),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Reactive content:
        // 1. If patient is selected -> show selected patient card
        // 2. If searching -> show matching patients only (or 'No match' if none)
        // 3. If empty -> show 'No match? Register New Patient'
        Obx(() {
          final selected = controller.selectedPatient.value;
          final query = controller.searchQuery.value.trim();

          // State 1: Patient selected
          if (selected != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SelectedPatientCard(
                  patient: selected,
                  onChange: controller.clearSearch,
                ),
              ],
            );
          }

          // State 2: Searching with query
          if (query.isNotEmpty) {
            final matches = controller.filteredPatients;
            if (matches.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Row(
                      children: [
                        const Icon(AppIcons.alert, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No patient found for "$query"',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RegisterPatientPrompt(onTap: controller.onRegisterNewPatient),
                ],
              );
            }

            // Show matching patients with hover highlight
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final p in matches.take(4))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PatientSearchResultTile(
                      patient: p,
                      onTap: () => controller.selectPatient(p),
                    ),
                  ),
                _RegisterPatientPrompt(onTap: controller.onRegisterNewPatient),
              ],
            );
          }

          // State 3: Empty query & no patient selected
          return _RegisterPatientPrompt(onTap: controller.onRegisterNewPatient);
        }),
      ],
    );
  }
}

class _PatientSearchResultTile extends StatefulWidget {
  const _PatientSearchResultTile({
    required this.patient,
    required this.onTap,
  });

  final WalkInPatient patient;
  final VoidCallback onTap;

  @override
  State<_PatientSearchResultTile> createState() => _PatientSearchResultTileState();
}

class _PatientSearchResultTileState extends State<_PatientSearchResultTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.brandTint : Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(
              color: _isHovered ? AppColors.brandPrimary : AppColors.borderDefault,
              width: _isHovered ? 1.3 : 1.0,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _isHovered ? Colors.white : AppColors.brandTint,
                child: Text(
                  widget.patient.initials,
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 100),
                      style: TextStyle(
                        color: _isHovered ? AppColors.brandPrimary : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      child: Text(widget.patient.name),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.patient.phoneDetails,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isHovered ? AppColors.brandPrimary : AppColors.brandTint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Select',
                  style: TextStyle(
                    color: _isHovered ? Colors.white : AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterPatientPrompt extends StatefulWidget {
  const _RegisterPatientPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_RegisterPatientPrompt> createState() => _RegisterPatientPromptState();
}

class _RegisterPatientPromptState extends State<_RegisterPatientPrompt> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'No match? ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: Text(
              'Register New Patient',
              style: TextStyle(
                color: _isHovered ? AppColors.brandHover : AppColors.brandPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                decoration: _isHovered ? TextDecoration.underline : TextDecoration.none,
                decorationColor: AppColors.brandHover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedPatientCard extends StatefulWidget {
  const _SelectedPatientCard({
    required this.patient,
    this.onChange,
  });

  final WalkInPatient patient;
  final VoidCallback? onChange;

  @override
  State<_SelectedPatientCard> createState() => _SelectedPatientCardState();
}

class _SelectedPatientCardState extends State<_SelectedPatientCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onChange != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onChange,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.brandTint,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(
              color: _isHovered ? AppColors.brandPrimary : AppColors.brandTint,
              width: _isHovered ? 1.5 : 1.2,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.brandPrimary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // White circular avatar with teal initials
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  widget.patient.initials,
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Patient details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patient.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.patient.phoneDetails,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Teal circle checkmark
              const Icon(
                AppIcons.circleCheck,
                size: 20,
                color: AppColors.brandPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PractitionerSection extends StatelessWidget {
  const _PractitionerSection({required this.controller});

  final BookAppointmentController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Practitioner',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        _PractitionerCard(controller: controller),
      ],
    );
  }
}

class _PractitionerCard extends StatefulWidget {
  const _PractitionerCard({required this.controller});

  final BookAppointmentController controller;

  @override
  State<_PractitionerCard> createState() => _PractitionerCardState();
}

class _PractitionerCardState extends State<_PractitionerCard> {
  bool _isHeaderHovered = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Obx(() {
      final isExpanded = controller.isPractitionerExpanded.value;
      final selected = controller.selectedPractitioner.value;
      final isAssigned = selected != 'Select Practitioner';
      final isHeaderActive = isExpanded || _isHeaderHovered;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Trigger Box (Visible green effect on hover and open)
          MouseRegion(
            onEnter: (_) => setState(() => _isHeaderHovered = true),
            onExit: (_) => setState(() => _isHeaderHovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: controller.togglePractitioner,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isHeaderActive
                      ? AppColors.brandTint.withValues(alpha: 0.5)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  border: Border.all(
                    color: isHeaderActive ? AppColors.brandPrimary : AppColors.borderDefault,
                    width: isHeaderActive ? 1.5 : 1.2,
                  ),
                  boxShadow: _isHeaderHovered
                      ? [
                          BoxShadow(
                            color: AppColors.brandPrimary.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selected,
                        style: TextStyle(
                          color: isHeaderActive
                              ? AppColors.brandPrimary
                              : (isAssigned ? AppColors.textPrimary : AppColors.textSecondary),
                          fontSize: 14,
                          fontWeight: (isAssigned || isHeaderActive) ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? AppIcons.chevronUp : AppIcons.chevronDown,
                      size: 18,
                      color: isHeaderActive ? AppColors.brandPrimary : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Separate Dropdown Menu Box below header
          if (isExpanded) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                border: Border.all(color: AppColors.borderDefault),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C0E6C61),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (final p in BookAppointmentController.practitioners)
                    _PractitionerOptionTile(
                      name: p,
                      isSelected: p == selected,
                      onTap: () => controller.selectPractitioner(p),
                    ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _PractitionerOptionTile extends StatefulWidget {
  const _PractitionerOptionTile({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_PractitionerOptionTile> createState() => _PractitionerOptionTileState();
}

class _PractitionerOptionTileState extends State<_PractitionerOptionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final isHighlighted = isSelected || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.brandTint
                : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isHighlighted
                  ? AppColors.brandPrimary.withValues(alpha: isSelected ? 0.4 : 0.25)
                  : AppColors.brandPrimary.withValues(alpha: 0.0),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 100),
                  style: TextStyle(
                    color: isHighlighted
                        ? AppColors.brandPrimary
                        : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(widget.name),
                ),
              ),
              if (isSelected)
                const Icon(
                  AppIcons.circleCheck,
                  size: 18,
                  color: AppColors.brandPrimary,
                )
              else if (_isHovered)
                const Icon(
                  AppIcons.check,
                  size: 18,
                  color: AppColors.brandPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateCalendarCard extends StatefulWidget {
  const _DateCalendarCard({required this.controller, required this.isTablet});

  final BookAppointmentController controller;
  final bool isTablet;

  @override
  State<_DateCalendarCard> createState() => _DateCalendarCardState();
}

class _DateCalendarCardState extends State<_DateCalendarCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),

        // Header Trigger Box (Highlights green when hovered or open)
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.toggleDate,
            child: Obx(() {
              final isExpanded = controller.isDateExpanded.value;
              final isActive = isExpanded || _isHovered;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.brandTint.withValues(alpha: 0.45)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  border: Border.all(
                    color: isActive ? AppColors.brandPrimary : AppColors.borderDefault,
                    width: isActive ? 1.5 : 1.2,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: AppColors.brandPrimary.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.formattedFullDate,
                        style: TextStyle(
                          color: isActive ? AppColors.brandPrimary : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? AppIcons.chevronUp : AppIcons.chevronDown,
                      size: 18,
                      color: isActive ? AppColors.brandPrimary : AppColors.textSecondary,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        // Calendar Card below
        Obx(() {
          if (!controller.isDateExpanded.value && !widget.isTablet) {
            return const SizedBox.shrink();
          }
          return Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Column(
              children: [
                // Month Nav row: < September 2026 >
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkResponse(
                      onTap: controller.previousMonth,
                      radius: 16,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(AppIcons.chevronLeft, size: 14, color: AppColors.textSecondary),
                      ),
                    ),
                    Text(
                      controller.formattedCalendarMonth,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                    InkResponse(
                      onTap: controller.nextMonth,
                      radius: 16,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(AppIcons.chevronRight, size: 14, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Weekday headers: Mo Tu We Th Fr Sa Su
                const Row(
                  children: [
                    _WeekdayHeader('Mo'),
                    _WeekdayHeader('Tu'),
                    _WeekdayHeader('We'),
                    _WeekdayHeader('Th'),
                    _WeekdayHeader('Fr'),
                    _WeekdayHeader('Sa'),
                    _WeekdayHeader('Su'),
                  ],
                ),
                const SizedBox(height: 8),

                // Dynamic Month Calendar Grid
                _MonthCalendarGrid(controller: controller),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _MonthCalendarGrid extends StatelessWidget {
  const _MonthCalendarGrid({required this.controller});

  final BookAppointmentController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedDate = controller.selectedDate.value;
      final currentMonth = controller.calendarMonth.value;
      final year = currentMonth.year;
      final month = currentMonth.month;

      // Total days in current month
      final daysInMonth = DateTime(year, month + 1, 0).day;
      // Weekday of 1st day (1 = Monday, 7 = Sunday)
      final firstWeekday = DateTime(year, month, 1).weekday;

      // Build rows of 7
      final rows = <List<int?>>[];
      var currentRow = <int?>[];

      // Leading empty spaces
      for (var i = 1; i < firstWeekday; i++) {
        currentRow.add(null);
      }

      // Fill days
      for (var d = 1; d <= daysInMonth; d++) {
        currentRow.add(d);
        if (currentRow.length == 7) {
          rows.add(currentRow);
          currentRow = <int?>[];
        }
      }

      // Trailing empty spaces
      if (currentRow.isNotEmpty) {
        while (currentRow.length < 7) {
          currentRow.add(null);
        }
        rows.add(currentRow);
      }

      return Column(
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) const SizedBox(height: 6),
            Row(
              children: [
                for (final day in rows[r])
                  Expanded(
                    child: day == null
                        ? const SizedBox(height: 32)
                        : _buildDayCell(
                            day: day,
                            isSelected: selectedDate.year == year &&
                                selectedDate.month == month &&
                                selectedDate.day == day,
                            onTap: () => controller.selectDate(DateTime(year, month, day)),
                          ),
                  ),
              ],
            ),
          ],
        ],
      );
    });
  }

  Widget _buildDayCell({
    required int day,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return _CalendarDayCell(
      day: day,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class _CalendarDayCell extends StatefulWidget {
  const _CalendarDayCell({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_CalendarDayCell> createState() => _CalendarDayCellState();
}

class _CalendarDayCellState extends State<_CalendarDayCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final isHovered = _isHovered && !isSelected;

    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.brandPrimary
                  : (isHovered ? AppColors.brandTint : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${widget.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : (isHovered ? FontWeight.w600 : FontWeight.w500),
                color: isSelected
                    ? Colors.white
                    : (isHovered ? AppColors.brandPrimary : AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailableSlotsSection extends StatelessWidget {
  const _AvailableSlotsSection({required this.controller});

  final BookAppointmentController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: Available slots ... Tuesday, 29 Sept
        Row(
          children: [
            const Text(
              'Available slots',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Obx(() => Text(
                    controller.formattedSlotHeaderDate,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Slot chips grid (Exactly 4 per row matching Figma)
        Obx(() {
          final selected = controller.selectedSlot.value;
          return LayoutBuilder(
            builder: (context, constraints) {
              const crossAxisCount = 4;
              const spacing = 8.0;
              final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: 10,
                children: [
                  for (final slot in BookAppointmentController.allSlots)
                    SizedBox(
                      width: itemWidth,
                      child: _SlotChip(
                        slot: slot,
                        isSelected: slot == selected,
                        isUnavailable: BookAppointmentController.unavailableSlots.contains(slot),
                        onTap: () => controller.selectSlot(slot),
                      ),
                    ),
                ],
              );
            },
          );
        }),
      ],
    );
  }
}

class _SlotChip extends StatefulWidget {
  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.isUnavailable,
    required this.onTap,
  });

  final String slot;
  final bool isSelected;
  final bool isUnavailable;
  final VoidCallback onTap;

  @override
  State<_SlotChip> createState() => _SlotChipState();
}

class _SlotChipState extends State<_SlotChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isUnavailable) {
      return Container(
        height: 34,
        alignment: Alignment.center,
        child: Text(
          widget.slot,
          style: const TextStyle(
            color: AppColors.textDisabled,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    if (widget.isSelected) {
      return Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.brandPrimary,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandPrimary.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          widget.slot,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final isHighlight = _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isHighlight ? AppColors.brandTint : Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: AppColors.brandPrimary,
              width: isHighlight ? 1.5 : 1.2,
            ),
            boxShadow: isHighlight
                ? [
                    BoxShadow(
                      color: AppColors.brandPrimary.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.slot,
            style: TextStyle(
              color: AppColors.brandPrimary,
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _VisitTypeSection extends StatelessWidget {
  const _VisitTypeSection({required this.controller});

  final BookAppointmentController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Visit Type',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),

        // Segmented selector with hover effects
        Container(
          height: Dimensions.buttonMinHeight,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.backgroundApp,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          ),
          child: Obx(() {
            final current = controller.selectedVisitType.value;
            return Row(
              children: [
                for (final type in BookAppointmentController.visitTypes)
                  Expanded(
                    child: _VisitTypeOption(
                      type: type,
                      isSelected: type == current,
                      onTap: () => controller.selectVisitType(type),
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _VisitTypeOption extends StatefulWidget {
  const _VisitTypeOption({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final String type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_VisitTypeOption> createState() => _VisitTypeOptionState();
}

class _VisitTypeOptionState extends State<_VisitTypeOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final isHovered = _isHovered && !isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : (isHovered ? AppColors.brandTint : AppColors.backgroundApp),
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: AppColors.brandTint, width: 1)
                : (isHovered
                    ? Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3), width: 1)
                    : Border.all(color: AppColors.backgroundApp, width: 1)),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x0C0E6C61),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x000E6C61),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 100),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: (isSelected || isHovered)
                  ? AppColors.brandPrimary
                  : AppColors.textSecondary,
            ),
            child: Text(widget.type),
          ),
        ),
      ),
    );
  }
}

class _SchedulingNotesSection extends StatefulWidget {
  const _SchedulingNotesSection({required this.controller});

  final BookAppointmentController controller;

  @override
  State<_SchedulingNotesSection> createState() => _SchedulingNotesSectionState();
}

class _SchedulingNotesSectionState extends State<_SchedulingNotesSection> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted && _isFocused != _focusNode.hasFocus) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _isFocused || _isHovered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Scheduling Notes (optional)',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),

        // Interactive Note Box matching other text fields directly without extra outer padding
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.text,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.brandPrimary.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller.notesController,
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              minLines: 1,
              maxLines: 5,
              maxLength: 500,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                height: 1.35,
              ),
              cursorColor: AppColors.brandPrimary,
              cursorHeight: 18.0,
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
                hintText: 'Add scheduling notes or special instructions...',
                hintStyle: const TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  borderSide: BorderSide(
                    color: isActive ? AppColors.brandPrimary : AppColors.borderDefault,
                    width: isActive ? 1.5 : 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  borderSide: BorderSide(
                    color: isActive ? AppColors.brandPrimary : AppColors.borderDefault,
                    width: isActive ? 1.5 : 1.2,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(
                    color: AppColors.brandPrimary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.controller});

  final BookAppointmentController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(
          top: BorderSide(
            color: AppColors.borderDefault,
            width: Dimensions.strokeDivider,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: 'Cancel',
                onPressed: controller.cancel,
                expand: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton.primary(
                label: 'Book Appointment',
                onPressed: controller.bookAppointment,
                expand: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Appointment Conflict Dialog
// ---------------------------------------------------------------------------

/// Full-screen overlay with centred modal — matches Figma screenshots exactly.
/// Works across Mobile, Tablet, and Desktop (overlaid on top of whatever layout).
class _AppointmentConflictOverlay extends StatelessWidget {
  const _AppointmentConflictOverlay({required this.controller});

  final BookAppointmentController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Positioned.fill(
      child: GestureDetector(
        onTap: controller.dismissConflict,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.black.withValues(alpha: 0.40),
          alignment: Alignment.center,
          child: GestureDetector(
            // Prevent taps inside dialog from closing
            onTap: () {},
            child: isMobile
                ? _ConflictDialogCard(
                    controller: controller,
                    maxWidth: width - 32,
                  )
                : _ConflictDialogCard(
                    controller: controller,
                    maxWidth: 440,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ConflictDialogCard extends StatelessWidget {
  const _ConflictDialogCard({
    required this.controller,
    required this.maxWidth,
  });

  final BookAppointmentController controller;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final practitioner = controller.conflictPractitioner.value;
      final slot = controller.conflictSlot.value;

      return Material(
        color: Colors.transparent,
        child: Container(
          width: maxWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x280F1F1D),
                blurRadius: 40,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Appointment conflict',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'The selected time overlaps an existing appointment.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkResponse(
                      onTap: controller.dismissConflict,
                      radius: 18,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(AppIcons.close, size: 18, color: AppColors.textDisabled),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimensions.sectionContentGap),

              // ── Orange warning banner ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.feedbackWarningTint,
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    border: Border.all(color: AppColors.feedbackWarningTint, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          AppIcons.alert,
                          size: 16,
                          color: AppColors.feedbackWarning,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$practitioner already has an appointment at $slot.',
                          style: const TextStyle(
                            color: AppColors.feedbackWarning,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Disclaimer text ─────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '"Book Anyway" is a lower-emphasis action for authorised staff only. No existing appointment will be cancelled.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.pageSectionGap),

              // ── Divider ─────────────────────────────────────────────────────
              const Divider(height: 1, color: AppColors.borderDefault),

              // ── Action buttons ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: _ConflictSecondaryButton(
                        label: 'Book Anyway',
                        onTap: controller.bookAnyway,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ConflictPrimaryButton(
                        label: 'Choose Another Time',
                        onTap: controller.chooseAnotherTime,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ConflictSecondaryButton extends StatefulWidget {
  const _ConflictSecondaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_ConflictSecondaryButton> createState() => _ConflictSecondaryButtonState();
}

class _ConflictSecondaryButtonState extends State<_ConflictSecondaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: Dimensions.buttonMinHeight,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.brandTint : Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(
              color: _isHovered ? AppColors.brandPrimary : AppColors.borderDefault,
              width: _isHovered ? 1.5 : 1.2,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _isHovered ? AppColors.brandHover : AppColors.brandPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConflictPrimaryButton extends StatefulWidget {
  const _ConflictPrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_ConflictPrimaryButton> createState() => _ConflictPrimaryButtonState();
}

class _ConflictPrimaryButtonState extends State<_ConflictPrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: Dimensions.buttonMinHeight,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.brandHover : AppColors.brandPrimary,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.brandPrimary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
