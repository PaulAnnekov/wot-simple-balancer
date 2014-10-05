library balancer.output;

import 'package:sprintf/sprintf.dart';

/**
 * Outputs results.
 */
class Output {
  /**
   * Output results.
   */
  static void output(Map<int, List> tankTeams) {
    tankTeams.forEach((clanId, tankTeam) {
      tankTeam.sort((first, second) =>
          (first['balance'] - second['balance']).toInt());
    });

    print('\nResults:');
    print('a/t - account id/tank id, w - balance weight.\n');

    print('Left column clan - ' + tankTeams.keys.first.toString() + '\t' +
              'right column clan - ' + tankTeams.keys.last.toString());
    for (var i = 0; i < tankTeams[tankTeams.keys.first].length; i++) {
      Map firstTank = tankTeams[tankTeams.keys.first][i];
      Map secondTank = tankTeams[tankTeams.keys.last][i];

      print(_formatTank(firstTank) + '\t' + _formatTank(secondTank));
    }
  }

  /**
   * Formats information about tank.
   */
  static String _formatTank(Map tank) {
    return sprintf("a/t: %d/%d (%s), w: %.2f", [
      tank['accountId'],
      tank['tankId'],
      tank['tankName'],
      tank['balance']
    ]);
  }
}
