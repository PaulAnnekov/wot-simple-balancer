library balancer.api;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';

class Api
{
  final String _applicationId;
  final String _host = "api.worldoftanks.ru";
  final Logger _log = new Logger('balancer.api');

  Api(this._applicationId);

  void _request_api(String path, Map<String, String> query, Completer completer) {
    _log.fine(query);

    Map<String, String> updatedQuery = new Map.from(query);
    updatedQuery["application_id"] = _applicationId;

    Uri url = new Uri.https(_host, 'wot/' + path + '/', updatedQuery);
    _log.config(url);

    HttpClient client = new HttpClient();
    client.getUrl(url)
    .then((HttpClientRequest request) => request.close())
    .then((HttpClientResponse response) {
      response
      .transform(UTF8.decoder)
      .transform(JSON.decoder)
      .listen((contents) {
        _log.fine(JSON.encode(contents));

        if (contents['status']=='ok')
          completer.complete(contents);
        else
        {
          _log.warning('Error: ' + contents['error']['message'] + ' (' +
            contents['error']['code'].toString() + '). Trying to repeat.');

          _request_api(path, query, completer);
        }
      });
    });
  }

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
      'map_id': 'globalmap',
      'order_by': 'provinces_count'
    });
  }

  /**
   * Gets members of clan with id [clanId].
   */
  Future getClanMembers(List<int> clanIds) {
    return _request('clan/info',{
        'clan_id': clanIds.join(','),
    });
  }

  /**
   * Gets information about users' tanks.
   */
  Future getAccountTanks(List accountIds) {
    return _request('account/tanks',{
        'account_id': accountIds.getRange(0,accountIds.length<100?accountIds.length:100).join(','),
    });
  }

  /**
   * Gets information about tanks.
   */
  Future getTanksInfo(List tankIds) {
    return _request('encyclopedia/tankinfo',{
        'tank_id': tankIds.join(','),
    });
  }
}
