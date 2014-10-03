library balancer.data_preparer;

import "dart:async";
import "dart:math";
import "dart:mirrors";
import "dart:io";
import "package:logging/logging.dart";
import "package:balancer/api.dart";

class DataPreparer {
  final Logger _log = new Logger('balancer');
  Api _api;
  Random _random = new Random();
  List _tanksQueues=[];

  DataPreparer(this._api);

  void prepare(Function onDone) {
    _log.info('Data preparation started.');

    Future done = _getClans()
      .then(_getClansMembers)
      .then(_getAccountTanks)
      .then(_getTanksInfo)
      .then((List responses) {
        _done(responses);

        onDone(_tanksQueues);
      });
  }

  Future _getClans() {
    return  _api.getClans();
  }

  Future _getClansMembers(data) {
    _log.info('Clans received.');
    var clan1 = data['data'][_random.nextInt(data['count'])]['clan_id'];
    var clan2 = data['data'][_random.nextInt(data['count'])]['clan_id'];

    _log.info('Two clans chosen: ' + clan1.toString() + ' and ' +
    clan2.toString());

    this._tanksQueues = [
        {
            'clanId': clan1
        },
        {
            'clanId': clan2
        },
    ];

    return _api.getClanMembers([clan1,clan2]);
  }

  Future _getAccountTanks(data) {
    _log.info('Getting accounts tanks.');

    var accountIds=[];
    data['data'][data['data'].keys.first]['members']
    .forEach((accountId,member) {
      accountIds.add(accountId);
    });

    Future clanMembers1 = _api.getAccountTanks(accountIds);

    accountIds=[];
    data['data'][data['data'].keys.last]['members']
    .forEach((accountId,member) {
      accountIds.add(accountId);
    });

    Future clanMembers2 = _api.getAccountTanks(accountIds);

    return Future.wait([clanMembers1,clanMembers2]);
  }

  Future _getTanksInfo(List data) {
    _log.info('Gettings tanks info.');

    List<Future> wait = new List();

    int current=0;
    data.forEach((Map data) {
      List tanksId=[];
      _tanksQueues[current]['tanks']={};

      data['data'].forEach((accountId, List tanks) {
        Map tank = tanks[_random.nextInt(tanks.length)];
        tanksId.add(tank['tank_id']);
        _tanksQueues[current]['tanks'][tank['tank_id']] = {
            'accountId': accountId,
            'mark_of_mastery': tank['mark_of_mastery']
        };
      });

      wait.add(_api.getTanksInfo(tanksId));
      current++;
    });

    return Future.wait(wait);
  }

  void _done(List responses) {
    int current = 0;
    responses.forEach((Map response) {
      response['data'].forEach((tankId, Map info) {
        tankId = int.parse(tankId);
        _tanksQueues[current]['tanks'][tankId].addAll({
            'gun_damage_min': info['gun_damage_min'],
            'gun_damage_max': info['gun_damage_max'],
            'max_health': info['max_health'],
        });
      });
      current++;
    });

    _log.info('Data is prepared.');
  }
}
