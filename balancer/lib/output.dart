library balancer.output;

import 'package:sprintf/sprintf.dart';

class Output {
  static void output(List<List> tankTeams) {
    tankTeams.forEach((tankTeam) {
      tankTeam.sort((first, second) => (first['balance']-second['balance']).toInt());
    });

    print('\nResults:');
    print('a/t - account id/tank id, w - balance weight.\n');

    for (var i = 0; i < tankTeams.first.length; i++) {
      Map firstTank = tankTeams[0][i];
      Map secondTank = tankTeams[1][i];

      print(_formatTank(firstTank) + '\t' + _formatTank(secondTank));
    }
  }

  static String _formatTank(Map tank) {
    return sprintf("a/t: %d/%d (%s)", [//, w: %.2f
      tank['accountId'],
      tank['tankId'],
      tank['tankName'],
      tank['balance']
    ]);
  }
}
