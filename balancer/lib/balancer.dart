library balancer;

import "dart:math";
import "package:logging/logging.dart";

/**
 * Creates two balanced teams from queues.
 */
class Balancer {
  /**
   * Logger.
   */
  final Logger _log = new Logger('balancer');

  /**
   * Random.
   */
  Random _random = new Random();

  /**
   * Number of members in each team.
   */
  static const TEAM_MAX = 15;

  /**
   * Starts balancing [tankQueues] and returns result with one list for each
   * team.
   */
  Map<int, List> run(List tankQueues) {
    _log.info('Balancer algorithm started.');

    if (tankQueues[0]['tanks'].length < TEAM_MAX ||
        tankQueues[1]['tanks'].length < TEAM_MAX) {
      _log.info('One of queues have less than 15 tanks. Restart app, please.');

      return null;
    }

    Map<int, List> results = _balanceTanks(tankQueues);

    _log.info('Balancing completed.');

    return results;
  }

  /**
   * Creates 2 balanced teams from [tankQueues].
   */
  Map<int, List> _balanceTanks(List tankQueues)
  {
    Map queueA = tankQueues[0];
    Map queueB = tankQueues[1];
    List<Map> tanksA = _calculateBalances(new List.from(queueA['tanks'].values));
    List<Map> tanksB = _calculateBalances(new List.from(queueB['tanks'].values));

    List resultFirst = [], resultSecond = [];

    int tryNumber = 0;
    while (resultFirst.length < TEAM_MAX) {
      tryNumber++;

      int tankIndex = _random.nextInt(tanksA.length);
      var tankA = tanksA[tankIndex];

      int opponentIndex = _closestBalance(tanksB, tankA['balance']);
      var tankB = tanksB[opponentIndex];

      if (_matchCheck(tankA, tankB, tryNumber)) {
        tryNumber = 0;

        resultFirst.add(tankA);
        resultSecond.add(tankB);

        tanksA.removeAt(tankIndex);
        tanksB.removeAt(opponentIndex);
      }
      else {
        _log.fine("Match was not found from $tryNumber try.");
      }
    }

    return {
      queueA['clanId']: resultFirst,
      queueB['clanId']: resultSecond
    };
  }

  /**
   * Checks if [tankA] is good opponent for [tankB] tanking into account
   * [tryNumber].
   */
  bool _matchCheck(Map tankA, Map tankB, int tryNumber) {
    double difference = (tankA['balance']-tankB['balance']).abs();

    return 100 / tankA['balance'] * difference <= tryNumber * 10;
  }

  /**
   * Finds tank index in [tanks] with balance value closest to [balance].
   */
  int _closestBalance(List<Map> tanks, double balance)
  {
    var previousIndex = null;
    var nextIndex = null;

    for (var i = 0; i < tanks.length; i++) {
      Map tank = tanks[i];
      if (tank['balance'] >= balance) {
        nextIndex = i;
        break;
      }

      // TODO: yep, we can get this value using calculation after loop. But I'm too lazy.
      previousIndex = i;
    }

    if (nextIndex == null) {
      return previousIndex;
    } else if (previousIndex == null) {
      return nextIndex;
    } else {
      var previous = tanks[previousIndex]['balance'];
      var next = tanks[nextIndex]['balance'];

      return ((previous-balance).abs() > (next-balance).abs()) ? nextIndex :
        previousIndex;
    }
  }

  /**
   * Calculates balances of tanks in [tankQueue]. Adds `balance` parameter to
   * each tank.
   */
  List<Map> _calculateBalances(List tankQueue)
  {
    List<Map> balances=[];
    tankQueue.forEach((params) {
      params['balance'] = _getWeight(params);
      balances.add(params);
    });

    balances.sort((first, second) => (first['balance']-second['balance']).toInt());

    return balances;
  }

  /**
   * Gets balance weight of [tank].
   */
  double _getWeight(Map tank)
  {
    return tank['gun_damage_min'] + tank['gun_damage_max'] +
      tank['max_health'] * (tank['mark_of_mastery'] / 16 + 1);
  }
}
