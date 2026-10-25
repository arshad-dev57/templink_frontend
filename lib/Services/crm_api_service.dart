// lib/Services/crm_api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/config/api_config.dart';

class CrmApiService {
  static String get _baseUrl => '${ApiConfig.baseUrl}/api/crm';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ==================== 1. DASHBOARD ====================
  static Future<CrmDashboardData?> getDashboardAnalytics() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse('$_baseUrl/dashboard'), headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          return CrmDashboardData.fromJson(data['data']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching CRM dashboard: $e');
    }
    return null;
  }

  // ==================== 2. LEADS ====================
  static Future<Map<String, dynamic>> getLeads({
    String search = '',
    String status = '',
    String priority = '',
    String leadSource = '',
    String assignedTo = '',
    int page = 1,
    int limit = 15,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search.isNotEmpty) params['search'] = search;
      if (status.isNotEmpty) params['status'] = status;
      if (priority.isNotEmpty) params['priority'] = priority;
      if (leadSource.isNotEmpty) params['leadSource'] = leadSource;
      if (assignedTo.isNotEmpty) params['assignedTo'] = assignedTo;

      final uri = Uri.parse('$_baseUrl/leads').replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List<dynamic>?)
                ?.map((l) => CrmLead.fromJson(l as Map<String, dynamic>))
                .toList() ??
            [];
        return {
          'leads': list,
          'pagination': data['pagination'] ?? {},
        };
      }
    } catch (e) {
      debugPrint('Error getting leads: $e');
    }
    return {'leads': <CrmLead>[], 'pagination': {}};
  }

  static Future<bool> createLead(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('$_baseUrl/leads'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final body = jsonDecode(res.body);
      // Accept both 200 and 201 — some backends return 200 for successful creation
      return (res.statusCode == 200 || res.statusCode == 201) && body['success'] == true;
    } catch (e) {
      debugPrint('Error creating lead: $e');
      return false;
    }
  }

  static Future<bool> updateLead(String id, Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.put(
        Uri.parse('$_baseUrl/leads/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final body = jsonDecode(res.body);
      return res.statusCode == 200 && body['success'] == true;
    } catch (e) {
      debugPrint('Error updating lead: $e');
      return false;
    }
  }

  static Future<bool> deleteLead(String id) async {
    try {
      final headers = await _getHeaders();
      final res = await http.delete(Uri.parse('$_baseUrl/leads/$id'), headers: headers);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> convertLead(String id, Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('$_baseUrl/leads/$id/convert'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final body = jsonDecode(res.body);
      return res.statusCode == 200 && body['success'] == true;
    } catch (e) {
      debugPrint('Error converting lead: $e');
      return false;
    }
  }

  // ==================== 3. CONTACTS ====================
  static Future<Map<String, dynamic>> getContacts({
    String search = '',
    String lifecycleStage = '',
    String status = '',
    String companyId = '',
    int page = 1,
    int limit = 15,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search.isNotEmpty) params['search'] = search;
      if (lifecycleStage.isNotEmpty) params['lifecycleStage'] = lifecycleStage;
      if (status.isNotEmpty) params['status'] = status;
      if (companyId.isNotEmpty) params['companyId'] = companyId;

      final uri = Uri.parse('$_baseUrl/contacts').replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List<dynamic>?)
                ?.map((c) => CrmContact.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [];
        return {'contacts': list, 'pagination': data['pagination'] ?? {}};
      }
    } catch (e) {
      debugPrint('Error getting contacts: $e');
    }
    return {'contacts': <CrmContact>[], 'pagination': {}};
  }

  static Future<bool> createContact(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('$_baseUrl/contacts'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final body = jsonDecode(res.body);
      return res.statusCode == 201 && body['success'] == true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateContact(String id, Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.put(
        Uri.parse('$_baseUrl/contacts/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteContact(String id) async {
    try {
      final headers = await _getHeaders();
      final res = await http.delete(Uri.parse('$_baseUrl/contacts/$id'), headers: headers);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== 4. COMPANIES ====================
  static Future<Map<String, dynamic>> getCompanies({
    String search = '',
    String industry = '',
    String type = '',
    String status = '',
    int page = 1,
    int limit = 15,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search.isNotEmpty) params['search'] = search;
      if (industry.isNotEmpty) params['industry'] = industry;
      if (type.isNotEmpty) params['type'] = type;
      if (status.isNotEmpty) params['status'] = status;

      final uri = Uri.parse('$_baseUrl/companies').replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List<dynamic>?)
                ?.map((c) => CrmCompany.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [];
        return {'companies': list, 'pagination': data['pagination'] ?? {}};
      }
    } catch (e) {
      debugPrint('Error getting companies: $e');
    }
    return {'companies': <CrmCompany>[], 'pagination': {}};
  }

  static Future<bool> createCompany(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('$_baseUrl/companies'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final body = jsonDecode(res.body);
      return res.statusCode == 201 && body['success'] == true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateCompany(String id, Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.put(
        Uri.parse('$_baseUrl/companies/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteCompany(String id) async {
    try {
      final headers = await _getHeaders();
      final res = await http.delete(Uri.parse('$_baseUrl/companies/$id'), headers: headers);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== 5. DEALS ====================
  static Future<Map<String, dynamic>> getDeals({
    String search = '',
    String stage = '',
    String assignedTo = '',
    String companyId = '',
    int page = 1,
    int limit = 15,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search.isNotEmpty) params['search'] = search;
      if (stage.isNotEmpty) params['stage'] = stage;
      if (assignedTo.isNotEmpty) params['assignedTo'] = assignedTo;
      if (companyId.isNotEmpty) params['companyId'] = companyId;

      final uri = Uri.parse('$_baseUrl/deals').replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List<dynamic>?)
                ?.map((d) => CrmDeal.fromJson(d as Map<String, dynamic>))
                .toList() ??
            [];
        return {'deals': list, 'pagination': data['pagination'] ?? {}};
      }
    } catch (e) {
      debugPrint('Error getting deals: $e');
    }
    return {'deals': <CrmDeal>[], 'pagination': {}};
  }

  static Future<bool> createDeal(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('$_baseUrl/deals'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final body = jsonDecode(res.body);
      return res.statusCode == 201 && body['success'] == true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateDealStage(String id, String stage, {String wonReason = '', String lostReason = ''}) async {
    try {
      final headers = await _getHeaders();
      final res = await http.patch(
        Uri.parse('$_baseUrl/deals/$id/stage'),
        headers: headers,
        body: jsonEncode({
          'stage': stage,
          if (wonReason.isNotEmpty) 'wonReason': wonReason,
          if (lostReason.isNotEmpty) 'lostReason': lostReason,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateDeal(String id, Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.put(
        Uri.parse('$_baseUrl/deals/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteDeal(String id) async {
    try {
      final headers = await _getHeaders();
      final res = await http.delete(Uri.parse('$_baseUrl/deals/$id'), headers: headers);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== 6. SALES PIPELINE ====================
  static Future<List<CrmPipelineColumn>> getSalesPipeline() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse('$_baseUrl/pipeline'), headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List<dynamic>)
              .map((c) => CrmPipelineColumn.fromJson(c as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error getting pipeline: $e');
    }
    return [];
  }

  // ==================== 7. TASKS & ACTIVITIES ====================
  static Future<Map<String, dynamic>> getActivities({
    String activityType = '',
    String status = '',
    String priority = '',
    String assignedTo = '',
    bool? overdue,
    bool? upcoming,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (activityType.isNotEmpty) params['activityType'] = activityType;
      if (status.isNotEmpty) params['status'] = status;
      if (priority.isNotEmpty) params['priority'] = priority;
      if (assignedTo.isNotEmpty) params['assignedTo'] = assignedTo;
      if (overdue == true) params['overdue'] = 'true';
      if (upcoming == true) params['upcoming'] = 'true';

      final uri = Uri.parse('$_baseUrl/activities').replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List<dynamic>?)
                ?.map((a) => CrmActivity.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [];
        return {'activities': list, 'pagination': data['pagination'] ?? {}};
      }
    } catch (e) {
      debugPrint('Error getting activities: $e');
    }
    return {'activities': <CrmActivity>[], 'pagination': {}};
  }

  static Future<bool> createActivity(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('$_baseUrl/activities'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final body = jsonDecode(res.body);
      return res.statusCode == 201 && body['success'] == true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateActivityStatus(String id, String status, {String outcomeNotes = ''}) async {
    try {
      final headers = await _getHeaders();
      final res = await http.patch(
        Uri.parse('$_baseUrl/activities/$id/status'),
        headers: headers,
        body: jsonEncode({
          'status': status,
          if (outcomeNotes.isNotEmpty) 'outcomeNotes': outcomeNotes,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteActivity(String id) async {
    try {
      final headers = await _getHeaders();
      final res = await http.delete(Uri.parse('$_baseUrl/activities/$id'), headers: headers);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== 8. CALENDAR ====================
  static Future<List<CrmActivity>> getCalendarEvents({DateTime? start, DateTime? end}) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{};
      if (start != null) params['startDate'] = start.toIso8601String();
      if (end != null) params['endDate'] = end.toIso8601String();

      final uri = Uri.parse('$_baseUrl/calendar').replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['data'] as List<dynamic>?)
                ?.map((e) => CrmActivity.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }
    } catch (e) {
      debugPrint('Error getting calendar events: $e');
    }
    return [];
  }

  // ==================== 9. MEETINGS & CALLS ====================
  static Future<Map<String, dynamic>> getMeetingsAndCalls({String type = '', int page = 1}) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{'page': page.toString()};
      if (type.isNotEmpty) params['type'] = type;

      final uri = Uri.parse('$_baseUrl/meetings-calls').replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List<dynamic>?)
                ?.map((e) => CrmActivity.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        return {'items': list, 'pagination': data['pagination'] ?? {}};
      }
    } catch (e) {
      debugPrint('Error getting meetings/calls: $e');
    }
    return {'items': <CrmActivity>[], 'pagination': {}};
  }

  // ==================== 10. NOTES ====================
  static Future<List<CrmNote>> getNotes({String relatedToType = '', String relatedToId = '', String search = ''}) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{};
      if (relatedToType.isNotEmpty) params['relatedToType'] = relatedToType;
      if (relatedToId.isNotEmpty) params['relatedToId'] = relatedToId;
      if (search.isNotEmpty) params['search'] = search;

      final uri = Uri.parse('$_baseUrl/notes').replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['data'] as List<dynamic>?)
                ?.map((n) => CrmNote.fromJson(n as Map<String, dynamic>))
                .toList() ??
            [];
      }
    } catch (e) {
      debugPrint('Error getting notes: $e');
    }
    return [];
  }

  static Future<bool> createNote(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('$_baseUrl/notes'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final body = jsonDecode(res.body);
      return res.statusCode == 201 && body['success'] == true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteNote(String id) async {
    try {
      final headers = await _getHeaders();
      final res = await http.delete(Uri.parse('$_baseUrl/notes/$id'), headers: headers);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== 11. EMAILS ====================
  static Future<List<CrmEmailRecord>> getEmails({String relatedToType = '', String relatedToId = ''}) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{};
      if (relatedToType.isNotEmpty) params['relatedToType'] = relatedToType;
      if (relatedToId.isNotEmpty) params['relatedToId'] = relatedToId;

      final uri = Uri.parse('$_baseUrl/emails').replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['data'] as List<dynamic>?)
                ?.map((e) => CrmEmailRecord.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }
    } catch (e) {
      debugPrint('Error getting emails: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> sendEmail(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('$_baseUrl/emails/send'),
        headers: headers,
        body: jsonEncode(payload),
      );
      final body = jsonDecode(res.body);
      return {
        'success': res.statusCode == 201 && body['success'] == true,
        'message': body['message'] ?? (res.statusCode == 201 ? 'Email sent successfully' : 'Failed to send email'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== 12. CUSTOMER SUPPORT / CASES ====================
  static Future<Map<String, dynamic>> getCases({
    String search = '',
    String status = '',
    String priority = '',
    int page = 1,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{'page': page.toString()};
      if (search.isNotEmpty) params['search'] = search;
      if (status.isNotEmpty) params['status'] = status;
      if (priority.isNotEmpty) params['priority'] = priority;

      final uri = Uri.parse('$_baseUrl/cases').replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List<dynamic>?)
                ?.map((c) => CrmCase.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [];
        return {'cases': list, 'pagination': data['pagination'] ?? {}};
      }
    } catch (e) {
      debugPrint('Error getting cases: $e');
    }
    return {'cases': <CrmCase>[], 'pagination': {}};
  }

  static Future<bool> createCase(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('$_baseUrl/cases'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateCase(String id, Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.put(
        Uri.parse('$_baseUrl/cases/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== 13. PRODUCTS & SERVICES ====================
  static Future<Map<String, dynamic>> getProducts({
    String search = '',
    String category = '',
    String type = '',
    int page = 1,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{'page': page.toString()};
      if (search.isNotEmpty) params['search'] = search;
      if (category.isNotEmpty) params['category'] = category;
      if (type.isNotEmpty) params['type'] = type;

      final uri = Uri.parse('$_baseUrl/products').replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List<dynamic>?)
                ?.map((p) => CrmProduct.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [];
        return {'products': list, 'pagination': data['pagination'] ?? {}};
      }
    } catch (e) {
      debugPrint('Error getting products: $e');
    }
    return {'products': <CrmProduct>[], 'pagination': {}};
  }

  static Future<bool> createProduct(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('$_baseUrl/products'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateProduct(String id, Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.put(
        Uri.parse('$_baseUrl/products/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteProduct(String id) async {
    try {
      final headers = await _getHeaders();
      final res = await http.delete(Uri.parse('$_baseUrl/products/$id'), headers: headers);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== 14. QUOTATIONS ====================
  static Future<Map<String, dynamic>> getQuotations({String search = '', String status = '', int page = 1}) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{'page': page.toString()};
      if (search.isNotEmpty) params['search'] = search;
      if (status.isNotEmpty) params['status'] = status;

      final uri = Uri.parse('$_baseUrl/quotations').replace(queryParameters: params);
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List<dynamic>?)
                ?.map((q) => CrmQuotation.fromJson(q as Map<String, dynamic>))
                .toList() ??
            [];
        return {'quotations': list, 'pagination': data['pagination'] ?? {}};
      }
    } catch (e) {
      debugPrint('Error getting quotations: $e');
    }
    return {'quotations': <CrmQuotation>[], 'pagination': {}};
  }

  static Future<bool> createQuotation(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('$_baseUrl/quotations'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateQuotationStatus(String id, String status) async {
    try {
      final headers = await _getHeaders();
      final res = await http.patch(
        Uri.parse('$_baseUrl/quotations/$id/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== 15. REPORTS & ANALYTICS ====================
  static Future<Map<String, dynamic>> getReportsAndAnalytics() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse('$_baseUrl/reports'), headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
      }
    } catch (e) {
      debugPrint('Error getting CRM reports: $e');
    }
    return {};
  }

  // ==================== 16. SETTINGS & TEAM MEMBERS ====================
  static Future<Map<String, dynamic>> getSettings() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse('$_baseUrl/settings'), headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
    } catch (e) {
      debugPrint('Error getting settings: $e');
    }
    return {};
  }

  static Future<bool> updateSettings(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.put(
        Uri.parse('$_baseUrl/settings'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<CrmTeamMember>> getTeamMembers() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse('$_baseUrl/team-members'), headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['data'] as List<dynamic>?)
                ?.map((m) => CrmTeamMember.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [];
      }
    } catch (e) {
      debugPrint('Error getting team members: $e');
    }
    return [];
  }
}
