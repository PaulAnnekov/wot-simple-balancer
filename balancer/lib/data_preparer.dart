library balancer.data_preparer;

import "dart:async";
import "dart:math";
import "package:logging/logging.dart";
import "package:balancer/api.dart";

class DataPreparer {
  final Logger _log = new Logger('balancer');
  Api _api;
  Random _random = new Random();
  List<Map> _tanksQueues=[];
  Map _tanks;
  static const MIN_LEVEL=4;
  static const MAX_LEVEL=6;

  /**
   * Preparation time.
   */
  int totalTime = 0;

  /**
   * Allowed minimum of accounts in clans.
   */
  static const MIN_ACCOUNTS=50;

  /**
   * Number of top clans we choose for random selection.
   */
  static const CLANS_TOP_COUNT=10;

  DataPreparer(this._api);

  void prepare(Function onDone) {
    _log.info('Data preparation started.');
    Stopwatch stopwatch = new Stopwatch()..start();

    Future done = _getTanks()
      .then((Map response) {
        _tanks = response['data'];
      })
      .then(_getClans)
      .then(_getClansMembers)
      .then(_getAccountTanks)
      .then(_getTanksInfo)
      .then((List responses) {
        _done(responses);

        stopwatch.stop();
        totalTime = stopwatch.elapsedMilliseconds;

        onDone(_tanksQueues);
      });
  }

  Future _getTanks() {
    return _api.getTanksList();
  }

  Future _getClans(data) {
    return _api.getClans();
  }

  Future _getClansMembers(response) {
    _log.info('Clans received.');

    List<Map> clans = new List.from(response['data'].getRange(0,CLANS_TOP_COUNT));
    List<int> clanIds = [];

    while (this._tanksQueues.length != 2) {
      Map clan = clans[_random.nextInt(clans.length)];

      if (!clanIds.contains(clan['clan_id']) &&
          clan['members_count'] >= MIN_ACCOUNTS) {
        clanIds.add(clan['clan_id']);
        this._tanksQueues.add({'clanId': clan['clan_id']});
      }
    }

    _log.info('Two clans chosen: ' + clanIds.first.toString() + ' and ' +
        clanIds.last.toString());

    return _api.getClanMembers(clanIds);
  }

  Future _getAccountTanks(Map response) {
    _log.info('Getting accounts tanks.');

    List wait = [];

    response['data'].forEach((String clanId, Map clanInfo) {
      List accountIds = [];
      clanInfo['members'].forEach((String accountId, Map info) {
        accountIds.add(accountId);
      });

      wait.add(_api.getAccountTanks(accountIds));
    });

    return Future.wait(wait);
  }

  Future _getTanksInfo(List<Map> responses) {
    _log.info('Gettings tanks info.');

    List<Future> wait = new List();

    int current=0;
    responses.forEach((Map response) {
      List tanksId=[];
      _tanksQueues[current]['tanks']={};

      response['data'].forEach((String accountId, List<Map> tanks) {
        List<Map> filtered = _filterTanks(tanks);
        if (filtered.isEmpty) {
          _log.fine("User $accountId has no tanks of needed level.");
          return;
        }

        Map tank = filtered[_random.nextInt(filtered.length)];
        tanksId.add(tank['tank_id']);
        _tanksQueues[current]['tanks'][tank['tank_id']] = {
            'accountId': int.parse(accountId),
            'tankId': tank['tank_id'],
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
          'tankName': info['name_i18n'],
        });
      });

      current++;
    });

    _log.info('Data is prepared.');
  }

  /**
   * Filters [tanks] list removing tanks with inappropriate level.
   */
  List<Map> _filterTanks(List<Map> tanks) {
    List<Map> filtered = [];

    tanks.forEach((Map tankInfo) {
      int level = _tanks[tankInfo['tank_id'].toString()]['level'];
      if (level >= MIN_LEVEL && level <= MAX_LEVEL) {
        filtered.add(tankInfo);
      }
    });

    return filtered;
  }
}
