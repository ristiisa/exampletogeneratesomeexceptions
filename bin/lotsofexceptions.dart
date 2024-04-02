import 'dart:async';
import 'dart:developer';
import 'dart:math' show Random;

class NonCriticalException implements Exception {
  final String message;
  NonCriticalException(this.message);

  @override
  String toString() => "NonCriticalException: $message";
}

Stream<int> generate(int count) async* {
  for(var i = 0; i < count; i++) yield i;
}

Future occasionallyFails(int n) async {
  await for(var i in generate(n)) {
    try {
      if(i % 2 == 0) {
        throw NonCriticalException("oops");
      } else if(i % 9 == 0) {
        var r = Random().nextInt(10);
        int.parse(n.toString(), radix: r);
      } else {
        print("Operation successful: $i");
      }
    } on NonCriticalException catch(e, s) {
      log("nothing to worry about", error: e, stackTrace: s, name: "ok");
    } catch(e, s) {
      log("something went wrong", error: e, stackTrace: s, name: "\x1B[31mpanic\x1B[0m");
    }
  }
}

void main(List<String> arguments) async {
  Timer.periodic(Duration(milliseconds: 10), (_) async => await occasionallyFails(1));
  Timer.periodic(Duration(milliseconds: 50), (_) async => await occasionallyFails(5));
  Timer.periodic(Duration(milliseconds: 1000), (_) async => await occasionallyFails(10));
}
