// ======================================================================
// File: vndb_api_query.dart
// Description: Defines the [VndbApiQuery] class for constructing API
//              queries to vndb.org.
//
// Author: dennis828
// Date: 2024-11-18
// ======================================================================

import 'dart:convert';

import 'package:boabox/services/logger_service/logger_service.dart';

/// Represents a query to the VNDB API.
///
/// The [VndbApiQuery] class allows you to build and serialize queries
/// for fetching game properties from vndb.org. It includes various parameters
/// to filter, sort, and paginate the results.
/// 
/// **Default Query:**
/// ```
/// {
///   "filters": [],
///   "fields": "",
///   "sort": "id",
///   "reverse": false,
///   "results": 10,
///   "page": 1,
///   "user": null,
///   "count": false,
///   "compact_filters": false,
///   "normalized_filters": false
/// } 
/// ```
class VndbApiQuery {
  /// List of filters to apply to the query.
  final List<dynamic> filters;

  /// List of fields to retrieve from the API.
  final List<String> fields;

  /// The field by which to sort the results.
  final String sort;

  /// Whether to reverse the sort order.
  bool reverse;

  /// Number of results to return per page.
  int results;

  /// The page number to retrieve.
  int page;

  /// The username for authenticated requests, if any.
  final String? user;

  /// Whether to include a count of total results.
  final bool count;

  /// Whether to use compact filter formatting.
  final bool compactFilters;

  /// Whether to use normalized filter formatting.
  final bool normalizedFilters;


  /// Creates a new instance of [VndbApiQuery].
  ///
  /// All parameters are optional and have default values.
  /// 
  /// - [filters]: Filters to apply to the query.
  /// - [fields]: Fields to retrieve from the API.
  /// - [sort]: Field to sort by. Defaults to `"id"`.
  /// - [reverse]: Whether to reverse the sort order. Defaults to `false`.
  /// - [results]: Number of results per page. Defaults to `10`.
  /// - [page]: Page number to retrieve. Defaults to `1`.
  /// - [user]: Username for authenticated requests.
  /// - [count]: Whether to include a count of total results. Defaults to `false`.
  /// - [compactFilters]: Whether to use compact filter formatting. Defaults to `false`.
  /// - [normalizedFilters]: Whether to use normalized filter formatting. Defaults to `false`.
  VndbApiQuery({
    List<dynamic>? filters,
    List<String>? fields,
    this.sort = "id",
    this.reverse = false,
    this.results = 10,
    this.page = 1,
    this.user,
    this.count = false,
    this.compactFilters = false,
    this.normalizedFilters = false
  }) :
      filters = filters ?? [],
      fields = fields ?? []
  {
   logger.t('VndbApiQuery instance created with parameters: '
    'filters=$filters, fields=$fields, sort=$sort, reverse=$reverse, '
    'results=$results, page=$page, user=$user, count=$count, '
    'compactFilters=$compactFilters, normalizedFilters=$normalizedFilters'); 
  }

  /// Converts the [VndbApiQuery] instance to a JSON map.
  ///
  /// This map can be used to send the query to the VNDB API.
  Map<String, dynamic> toJson() {
    return {
      "filters": filters,
      "fields": _reformatVndbFields(fields),
      "sort": sort,
      "reverse": reverse,
      "results": results,
      "page": page,
      "user": user,
      "count": count,
      "compact_filters": compactFilters,
      "normalized_filters": normalizedFilters
    };
  }

  /// Encodes the [VndbApiQuery] instance to a JSON string.
  ///
  /// This string can be sent in the body of an HTTP request to the VNDB API.
  String package() {
    return json.encode(toJson());
  }

  /// Reformats the list of fields into a comma-separated string.
  ///
  /// This is required by the VNDB API for specifying multiple fields.
  /// Logs the reformatting process at trace level.
  static String _reformatVndbFields(List<String> fields) {
    return fields.join(", ");
  }
}
