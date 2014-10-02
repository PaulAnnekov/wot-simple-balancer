library balancer.api;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Api
{
  final String _applicationId;
  final String _host = "api.worldoftanks.ru";

  Api(this._applicationId);

  Future<dynamic> _request(String path, Map<String, String> query) {
    Completer completer = new Completer();

    Map<String, String> updatedQuery = new Map.from(query);
    updatedQuery["application_id"] = _applicationId;

    print(query);
    Uri url = new Uri.https(_host, 'wot/' + path + '/', updatedQuery);

    HttpClient client = new HttpClient();
    print(url);
    client.getUrl(url)
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse response) {
        response
          .transform(UTF8.decoder)
          .transform(JSON.decoder)
          .listen((contents) {
            print(JSON.encode(contents));
            completer.complete(contents);
          });
      });

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
