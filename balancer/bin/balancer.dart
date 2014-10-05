import "dart:io";

import "package:balancer/balancer.dart";
import "package:balancer/data_preparer.dart";
import "package:balancer/api.dart";
import "package:logging/logging.dart";
import "package:balancer/output.dart";
import "package:intl/intl.dart";
import "package:args/args.dart";

main(List<String> arguments)
{
  Stopwatch stopwatch = new Stopwatch()..start();

  Map params = init(arguments);
  Logger log = new Logger('balancer');

  Api api = new Api(params['applicationId']);
  if (params['repeat'])
    api.maxFails=null;

  DataPreparer dataPreparer = new DataPreparer(api);
  dataPreparer.prepare((tankQueues) {
    if (tankQueues == null)
      exit(1);

    Balancer balancer = new Balancer();
    Map<int, List> results = balancer.run(tankQueues);
    if (results != null)
      Output.output(results);

    stopwatch.stop();
    print('\n');
    log.info('Total execution time (seconds): ' +
        (stopwatch.elapsedMilliseconds / 1000).toString());
    log.info('Data preparation time: ' +
        (dataPreparer.totalTime / 1000).toString());
    log.info('API requests total time (could be run in parallel): ' +
        (api.totalTime / 1000).toString());
  });
}

Map init(List<String> arguments) {
  var parser = new ArgParser();
  parser.addOption('app-id', abbr: 'a', help: 'Defines application ID (required).');
  parser.addFlag('verbose', abbr: 'v', defaultsTo: false, negatable: false,
      help: 'Displays API requests info and some additional data.');
  parser.addFlag('help', abbr: 'h', defaultsTo: false, negatable: false,
      help: 'Displays this usage guide.');
  parser.addFlag('repeat', abbr: 'r', defaultsTo: false, negatable: false,
        help: 'Repeat API requests infinitely if error occured. Otherwise they will be repeated only 10 times.');

  var results = parser.parse(arguments);

  if (results['help']) {
    print('S&S (Simple and stupid) balancer for WOT. Parameters:');
    print(parser.getUsage());
    exit(0);
  }

  if (results['app-id'] == null)
  {
    print('Please, provide "--app-id/-a" argument.');
    exit(1);
  }

  if (results['verbose']) {
    Logger.root.level = Level.ALL;
  } else {
    Logger.root.level = Level.CONFIG;
  }

  Logger.root.onRecord.listen((LogRecord rec) {
    String time = new DateFormat('HH:mm:ss.S').format(rec.time);
    print('${rec.level.name}: $time: ${rec.message}');
  });

  return {
    'applicationId': results['app-id'],
    'repeat': results['repeat']
  };
}