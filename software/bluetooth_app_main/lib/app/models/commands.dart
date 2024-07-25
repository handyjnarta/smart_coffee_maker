class Commands {
  // Properties
  late String numStep;
  late String volume;
  late String timePouring;
  late String timeInterval;

  // Constructor
  Commands({
    required this.numStep,
    required this.volume,
    required this.timePouring,
    required this.timeInterval,
  });

  // Convert a Commands object to a JSON map
  Map<String, dynamic> toJson() => {
        "numStep": numStep,
        "volume": volume,
        "timePouring": timePouring,
        "timeInterval": timeInterval,
      };

  // Create a Commands object from a JSON map
  static Commands fromJson(Map<String, dynamic> json) => Commands(
        numStep: json["numStep"],
        volume: json["volume"],
        timePouring: json["timePouring"],
        timeInterval: json["timeInterval"],
      );
}
