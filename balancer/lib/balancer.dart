library balancer;

import "dart:async";
import "dart:math";
import "dart:io";
import "package:logging/logging.dart";
import "package:balancer/api.dart";

class Balancer {
  final Logger _log = new Logger('balancer');
  Random _random = new Random();

  void run(List tankQueues) {
    _log.info('Balancer algorithm started.');

    _log.info(tankQueues);

    _log.info('Balancer algorithm finished.');
  }

  void balanceTanks()
  {

  }
}
