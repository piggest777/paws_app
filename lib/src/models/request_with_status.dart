import 'package:paws_app/src/models/request.dart';

class RequestWithStatusCounts {
  final Request request;
  final Map<String, int> boxStatusCounts;

  RequestWithStatusCounts(this.request, this.boxStatusCounts);
}
