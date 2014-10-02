import "package:balancer/balancer.dart";
import "package:balancer/data_preparer.dart";
import "package:balancer/api.dart";
import "package:balancer/api_cache.dart";
import "package:logging/logging.dart";

String applicationId="a40ea2cd93662d60037a60c32ccd6763";

main()
{
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  //Api api = new Api(applicationId);
  ApiCache api = new ApiCache();
  DataPreparer dataPreparer = new DataPreparer(api);
  dataPreparer.prepare((tankQueues) {
    Balancer balancer = new Balancer();
    balancer.run(tankQueues);
  });
}