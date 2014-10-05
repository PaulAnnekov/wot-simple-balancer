library balancer.api_cache;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:balancer/api.dart';

@deprecated
class ApiCache implements Api
{
  int _accountTanksRequest = 0;
  int _tanksInfoRequest = 0;

  Future _getFile(String name) {
    Completer completer = new Completer();

    Uri clientScript = Platform.script.resolve("../cache/" + name);

    new File(clientScript.toFilePath()).readAsString().then((String contents) {
      completer.complete(JSON.decode(contents));
    });

    return completer.future;
  }

  Future getClans() {
    return this._getFile('clans.json');
  }

  Future getClanMembers(List<int> clanIds) {
    return this._getFile('clans_info.json');
  }

  Future getAccountTanks(List accountIds) {
    _accountTanksRequest++;
    return this._getFile('accounts_tanks' + _accountTanksRequest.toString() + '.json');
  }

  Future getTanksInfo(List tankIds) {
    _tanksInfoRequest++;
    return this._getFile('tanks_info' + _tanksInfoRequest.toString() + '.json');
  }
}
