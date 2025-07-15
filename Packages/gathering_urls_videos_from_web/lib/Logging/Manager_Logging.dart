part of gathering_urls_videos_from_web;

class ManagerLogging {
  static late Logger logger;

  ManagerLogging() {}

  static void createLoggerIfNotExistAndConfigure() {
    ManagerLogging.logger = Logger();
  }
}
