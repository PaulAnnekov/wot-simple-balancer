library balancer.api;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';

/**
 * Makes requests to WOT api.
 */
class Api
{
  /**
   * Application ID for API requests.
   */
  final String _applicationId;

  /**
   * API host.
   */
  final String _host = "api.worldoftanks.ru";

  /**
   * Logger.
   */
  final Logger _log = new Logger('balancer.api');

  /**
   * Total time of all requests.
   */
  int totalTime = 0;

  /**
   * Current number of failed requests.
   */
  int failedRequests = 0;

  /**
   * Maximum number of fails after which they won't be repeated.
   */
  int maxFails = 10;

  Api(this._applicationId);

  /**
   * Handles request exception and retries/completes it.
   */
  void handleException(path, query, Completer completer, exception) {
    if (maxFails == null || failedRequests < maxFails)
      _log.warning('Error during API request: $exception. Trying to repeat.');
    else {
      completer.completeError(new Exception('Error during API request: '
          '$exception. Stopping repetition. It was the last chance.'));

      return;
    }

    failedRequests++;
    _request_api(path, query, completer);
  }

  /**
   * Makes api request [path] with parameters [query] and calls [completer] when
   * request is completed successfully. Will try to repeat request infinitely.
   */
  void _request_api(String path, Map<String, String> query, Completer completer) {
    _log.config('Request to $path.');

    Map<String, String> updatedQuery = new Map.from(query);
    updatedQuery["application_id"] = _applicationId;

    Uri url = new Uri.https(_host, 'wot/' + path + '/', updatedQuery);
    _log.fine(url);

    // Measure request time.
    Stopwatch stopwatch = new Stopwatch()..start();

    HttpClient client = new HttpClient();
    client.getUrl(url)
    .then((HttpClientRequest request) => request.close())
    .then((HttpClientResponse response) {
      response
        .transform(UTF8.decoder)
        .transform(JSON.decoder)
        .listen((contents) {
          stopwatch.stop();
          totalTime += stopwatch.elapsedMilliseconds;

          _log.fine(JSON.encode(contents));

          if (contents['status']=='ok')
            completer.complete(contents['data']);
          else
          {
            var message = 'error in result: ' + contents['error']['message'] +
                ' (' + contents['error']['code'].toString() + ')';
            handleException(path, query, completer, new Exception(message));
          }
        });
    })
    .catchError((Exception exception) {
      handleException(path, query, completer, exception);
    });
  }

  /**
   * Wrapper for making API request that returns Future.
   */
  Future<dynamic> _request(String path, Map<String, String> query) {
    Completer completer = new Completer();

    _request_api(path, query, completer);

    return completer.future;
  }

  /**
   * Gets 2 random clans from top 10 clans (globalwar/top) with maximum number
   * of owned provinces on global map (globalmap).
   */
  Future getClans() {
    return _request('globalwar/top',{
      'fields': 'clan_id,name,members_count',
      'map_id': 'globalmap',
      'order_by': 'provinces_count'
    });
  }

  /**
   * Gets members of clan with id [clanId].
   */
  Future getClanMembers(List<int> clanIds) {
    return _request('clan/info',{
      'fields': 'clan_id,members.account_id',
      'clan_id': clanIds.join(','),
    });
  }

  /**
   * Gets information about users' tanks.
   */
  Future getAccountTanks(List accountIds) {
    return _request('account/tanks',{
      'fields': 'tank_id,mark_of_mastery',
      'account_id': accountIds.getRange(0,accountIds.length<100?accountIds.length:100).join(','),
    });
  }

  /**
   * Gets information about tanks.
   */
  Future getTanksInfo(List tankIds) {
    return _request('encyclopedia/tankinfo',{
      'fields': 'gun_damage_min,gun_damage_max,max_health,name_i18n',
      'tank_id': tankIds.join(','),
    });
  }

  /**
   * Gets information about tanks.
   */
  Future getTanksList() {
    return _request('encyclopedia/tanks',{
      'fields': 'tank_id,level,name_i18n'
    });
  }
}
