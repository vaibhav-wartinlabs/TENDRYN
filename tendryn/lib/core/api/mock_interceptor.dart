import 'package:dio/dio.dart';

/// In-process fake backend, enabled by `USE_MOCK_API` (default on).
/// Demo login: any valid email with password `password123`.
class MockInterceptor extends Interceptor {
  static const _tokens = {'access_token': 'mock-access', 'refresh_token': 'mock-refresh'};
  static const _user = {
    'id': 'u1',
    'name': 'Lerato Mokoena',
    'email': 'lerato@example.com',
    'role': 'member',
    'job_title': 'Receptionist',
    'clinic_name': 'Ubuntu Family Clinic',
  };

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    switch ('${options.method} ${options.path}') {
      case 'POST /auth/login':
        final body = options.data as Map<String, dynamic>;
        if (body['password'] != 'password123') return _fail(options, handler, 401, 'Invalid email or password.');
        return _ok(options, handler, {..._tokens, 'user': {..._user, 'email': body['email']}});
      case 'POST /auth/refresh':
        return _ok(options, handler, _tokens);
      case 'POST /auth/logout':
        return _ok(options, handler, <String, dynamic>{});
      case 'GET /auth/me':
        return _ok(options, handler, _user);
      case 'GET /dashboard/summary':
        return _ok(options, handler, _dashboard());
      case 'GET /queue':
        return _ok(options, handler, _queue());
      case 'POST /leave-requests':
        final body = options.data as Map<String, dynamic>;
        if (body['start_date'] == null || body['end_date'] == null) {
          return _fail(options, handler, 422, 'Start and end dates are required.');
        }
        return _ok(options, handler, {
          'id': 'LV-${DateTime.now().millisecondsSinceEpoch}',
          'status': 'pending',
          'start_date': body['start_date'],
          'end_date': body['end_date'],
          'reason': body['reason'],
        });
      default:
        return _extra(options, handler);
    }
  }

  /// Minimal mocks for the newer screens so they render offline (USE_MOCK_API=true).
  /// For real data, run with USE_MOCK_API=false against the backend.
  void _extra(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method;
    final path = options.path;
    bool get(String p) => method == 'GET' && (path == p || path.endsWith(p));
    bool post(String p) => method == 'POST' && (path == p || path.endsWith(p));

    if (get('/patients/stats')) {
      return _ok(options, handler, {'total': 0, 'recently_seen': 0, 'in_queue': 0, 'recently_added': 0});
    }
    if (get('/patients/search')) return _ok(options, handler, <dynamic>[]);
    if (get('/billing/summary')) {
      return _ok(options, handler,
          {'to_collect': 0.0, 'to_collect_count': 0, 'paid_today': 0.0, 'paid_today_count': 0, 'cash_up_status': 'Not started'});
    }
    if (get('/invoices')) return _ok(options, handler, <dynamic>[]);
    if (get('/appointments')) return _ok(options, handler, <dynamic>[]);
    if (get('/consultations')) return _ok(options, handler, {'items': <dynamic>[], 'total': 0});
    if (get('/lab/referrals')) return _ok(options, handler, {'referrals': <dynamic>[], 'total_count': 0});
    if (get('/lab/results')) return _ok(options, handler, {'results': <dynamic>[], 'total_count': 0});
    if (get('/vitals')) return _ok(options, handler, <dynamic>[]);
    if (post('/patients')) {
      final body = options.data as Map<String, dynamic>? ?? {};
      return _ok(options, handler, {
        'patient': {
          'id': 'mock-${DateTime.now().millisecondsSinceEpoch}',
          'first_name': body['first_name'] ?? 'New',
          'last_name': body['last_name'] ?? 'Patient',
          'file_number': null,
        },
        'possible_duplicates': <dynamic>[],
      });
    }
    return _fail(options, handler, 404, 'No mock for $method $path');
  }

  void _ok(RequestOptions o, RequestInterceptorHandler h, Object data) =>
      h.resolve(Response<dynamic>(requestOptions: o, statusCode: 200, data: data));

  void _fail(RequestOptions o, RequestInterceptorHandler h, int status, String message) => h.reject(
        DioException(
          requestOptions: o,
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(requestOptions: o, statusCode: status, data: {'message': message}),
        ),
        true,
      );

  Map<String, dynamic> _queue() {
    final dashboard = _dashboard();
    return {
      'patients_waiting': dashboard['patients_waiting'],
      'seen_today': dashboard['seen_today'],
      'average_wait_minutes': dashboard['average_wait_minutes'],
      'entries': dashboard['queue'],
    };
  }

  Map<String, dynamic> _dashboard() => {
        'patients_waiting': 12,
        'seen_today': 38,
        'average_wait_minutes': 18,
        'takings_today': 8450.0,
        'queue': [
          {'number': 'Q014', 'patient': 'Thabo Nkosi', 'arrival': '09:10', 'waiting_minutes': 24, 'reason': 'General consultation', 'priority': 'routine', 'status': 'waiting', 'practitioner': null},
          {'number': 'Q015', 'patient': 'Naledi Molefe', 'arrival': '09:18', 'waiting_minutes': 16, 'reason': 'Follow-up', 'priority': 'urgent', 'status': 'waitingForDoctor', 'practitioner': 'Dr Thandi Maseko'},
          {'number': 'Q016', 'patient': 'Sipho Dlamini', 'arrival': '09:22', 'waiting_minutes': 12, 'reason': 'General consultation', 'priority': 'routine', 'status': 'withNurse', 'practitioner': 'Nurse Z. Mthembu'},
          {'number': 'Q017', 'patient': 'Amahle Khumalo', 'arrival': '09:27', 'waiting_minutes': 7, 'reason': 'Prescription follow-up', 'priority': 'routine', 'status': 'waiting', 'practitioner': null},
          {'number': 'Q018', 'patient': 'Kabelo Mokoena', 'arrival': '09:31', 'waiting_minutes': 3, 'reason': 'General consultation', 'priority': 'emergency', 'status': 'waiting', 'practitioner': null},
        ],
        'appointments': {
          'booked': 24,
          'remaining': 3,
          'no_shows': 2,
          'items': [
            {'time': '14:00', 'patient': 'Lindiwe Ndlovu', 'practitioner': 'Dr Thandi Maseko', 'visit_type': 'Follow-up', 'status': 'checkedIn'},
            {'time': '14:30', 'patient': 'Peter Jacobs', 'practitioner': 'Dr Thandi Maseko', 'visit_type': 'Consultation', 'status': 'upcoming'},
            {'time': '15:00', 'patient': 'Nomsa Dube', 'practitioner': 'Dr Sipho Khumalo', 'visit_type': 'Follow-up', 'status': 'upcoming'},
          ],
        },
        'attention': [
          {'kind': 'appointmentConflicts', 'title': '2 appointment conflicts', 'description': 'Double bookings need to be resolved.'},
          {'kind': 'outstandingPayments', 'title': '3 outstanding payments', 'description': 'Patients have balances requiring front desk follow-up.'},
        ],
      };

}
