# Tendryn architecture (GetX)

One Flutter codebase for Android phone, Android tablet and Windows. State, DI and navigation are all GetX.
Logic is shared; only layout and navigation chrome adapt to width.

```
View (GetView) -> Controller (Rx state) -> Service (GetxService) -> ApiClient (Dio) -> Backend
                        \-> AuthController / SessionService (core/authentication)
```

## Folders
| Folder | Responsibility |
|---|---|
| `core/api` | `ApiClient`, `ApiEndpoints`, `ApiResponse`, `ApiException` (typed errors), `ApiInterceptor` (bearer token, 401 refresh+retry), `MockInterceptor` |
| `core/authentication` | `AuthController` (reactive `AuthState`, login/logout/restore, permissions), `SessionService` (token persistence + refresh, in `auth_service.dart`), `AuthGuard` (route middleware) |
| `core/storage` | `StorageService` interface; `SecureStorageService` (tokens); `PreferencesService` (settings) |
| `core/responsive` | `ResponsiveBreakpoints` (600 / 1200), `ResponsiveHelper`, `ResponsiveLayout` |
| `core/utils`, `core/constants`, `core/theme` | validators, formatters, `LoadableMixin`, logger; `AppConfig` (dart-define), keys, dimensions; themes |
| `models` | Shared plain models (`User`, `AuthTokens`) |
| `services` | `GetxService`s: `ApiService`, `AuthService` (login API), `StorageManager`, `ConnectivityService`, `AppService`, `DashboardService` |
| `routes` | `AppRoutes` (paths), `RouteNames` (titles), `AppPages` (GetPage + Binding + guard), `InitialBinding` (global DI), `AppNavigation` |
| `features/<f>` | `bindings/` DI, `controllers/` state+logic, `views/` screen, `widgets/` mobile/tablet/desktop parts, `models/` feature models |
| `widgets/common` | `AppShell`, `StatusView`, `StatCard`, `AppTextField`, nav destinations |
| `widgets/mobile` `tablet` `desktop` | Side-nav (desktop, Ctrl+1..5 shortcuts) and bottom-nav (tablet, mobile) scaffolds with per-platform headers |

Name notes: `core/authentication/auth_service.dart` holds `SessionService` and `services/auth_service.dart` holds `AuthService`
(both file names come from the spec; the class names avoid the clash). `services/storage_service.dart` holds `StorageManager`.

## Design system (Figma "Tendryn DS / 01")
- Tokens: `core/theme/app_colors.dart` (full palette), `app_typography.dart` (type styles, `tabular()` for numbers), `core/constants/dimensions.dart` (spacing, radius, strokes, sizes), `app_icons.dart` (Lucide, 18px / 1.5px stroke).
- Decoration: `core/theme/app_theme.dart` defines button, input, card and navigation-rail themes once. Read neutrals from `Theme.of(context)`; use `AppColors` only for fixed triage / sync / safety colors.
- Widgets (`widgets/common`): `AppButton`, `AppTextField`, `AppSearchField`, `AppCard` (flat/soft), `SyncChip`, `TriageTag`, `AllergyBanner`, `OfflineBanner`, `AppNavItem`, `AppIconButton`, `AppUserBadge`, `PageHeading`.
  Navigation: `widgets/desktop/side_navigation.dart`, `widgets/mobile/bottom_navigation.dart`; tablet uses the themed `NavigationRail`.
- Rules from the file: buttons 48px high, mobile tap targets >= 48x48, labels may grow 40% (no fixed narrow widths), sync/triage always colour + text, allergy banner pinned on patient-facing clinical views, tabular figures for vitals/ZAR/time/ICD-10.

## Dashboard (Figma "Receptionist dashboard")
`DashboardView` -> `ResponsiveLayout` -> `DashboardDesktop` / `DashboardTablet` / `DashboardMobile` (thin arrangements) -> shared sections in `features/dashboard/widgets` (`queue_widgets`, `appointment_widgets`, `quick_actions_section`, `attention_section`, `dashboard_kpis`, `dashboard_page_header`), all reading the one `DashboardController`.
Desktop = tables, tablet = two-column cards + bottom bar, mobile = compact cards + bottom bar. Shared building blocks live in `widgets/common` (`KpiCard`, `SectionCard`, `AppDataTable`, `StatusBadge`, `StatusPill`, `BrandLogo`). Actions whose screens don't exist yet call `AppNotice.unavailable`.

## Rules in practice
- Controllers are created only by Bindings (`Get.lazyPut`); views extend `GetView<T>`.
- All three dashboard layouts share one `DashboardController`.
- Inside `Obx`, read an Rx value directly (`.value`, or `list.toList()`); passing an `RxList` object through without reading it throws GetX's "improper use" error.
- Startup: `InitialBinding` registers permanent services -> `SplashController` runs `AppService.initialize()` + `AuthController.restoreSession()` -> dashboard or login.
- 401 handling: interceptor refreshes once and retries; if refresh fails `AuthController.handleSessionExpired()` clears tokens and `Get.offAllNamed(login)`.
- Main navigation (Dashboard, Queue, Patients, Appointments, Billing) is defined once in `widgets/common/nav_destination.dart`; Queue, Patients, Appointments and Billing are page shells (`PageHeading`) until their screens are built.

## Run
```
flutter run -d windows --dart-define=API_BASE_URL=https://your.api --dart-define=USE_MOCK_API=false
```
`USE_MOCK_API` defaults to true: sign in with any valid email and password `password123`.

## Packages (Windows support checked)
`get`, `dio`, `shared_preferences`, `flutter_secure_storage` (needs the Visual Studio ATL component on Windows), `connectivity_plus` (Windows supported).
Re-check Windows support before adding anything else; Android-only features go behind an interface in `services/`.
