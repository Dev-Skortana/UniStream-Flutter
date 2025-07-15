part of gathering_data_videos_from_web;

class ManagerLogging {
  static late Logger logger;

  ManagerLogging() {}

  static void createLoggerIfNotExistAndConfigure() {
    ManagerLogging.logger = Logger(
        printer: PrettyPrinter(
            methodCount: 1,
            errorMethodCount: 8,
            lineLength: 120,
            colors: true,
            dateTimeFormat: DateTimeFormat.dateAndTime));
  }
}
