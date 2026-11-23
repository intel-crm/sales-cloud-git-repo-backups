/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AdminUtils implements System.Callable {
    global AdminUtils() {

    }
    global static void addSettingsDefaults() {

    }
    global static void addVisionAdmin(Id userId) {

    }
    global static void addVisionAdmins(Set<Id> userIds) {

    }
    global static void backfillTaskCompletedDates() {

    }
    global static void backfillTaskCompletedDates(Integer batchCount) {

    }
    global static void backfillTaskCounts() {

    }
    global static void backfillTaskCounts(Integer batchCount) {

    }
    global Object call(String actionName, Map<String,Object> args) {
        return null;
    }
    global static void clearExternalLinks() {

    }
    global static void clearRASRConfig() {

    }
    global static Integer clearVisionErrors(Boolean deleteAll) {
        return null;
    }
    global static void convertCustomReports() {

    }
    global static void convertSettingsToCoachRollup(Boolean runAsBatch) {

    }
    global static void convertStageSettings() {

    }
    global static void convertToGroupSettings() {

    }
    global static void convertToRASR() {

    }
    global static void convertVerifiersCompletedToVerifierStatus(Boolean runAsBatch) {

    }
    global static List<String> getAccessList() {
        return null;
    }
    global static String getPackageNamespace() {
        return null;
    }
    global static Boolean hasAdminAccess() {
        return null;
    }
    global static void logAppError(String msg, Integer line, String stack) {

    }
    global static void populateFactorMultipliers() {

    }
    global static void populateFactorMultipliers(Integer variance, Integer numBuckets) {

    }
    global static void populateXUser() {

    }
    global static void removeVisionAdmin(Id userId) {

    }
    global static void removeVisionAdmins(Set<Id> userIds) {

    }
    global static void rescheduleXvoyantJobs() {

    }
    global static void rescheduleXvoyantJobs(String jobType) {

    }
    global static void runDailyJob() {

    }
    global static void runWeeklyJob() {

    }
    global static void sendCustomCoachingReport(Date analysisDate) {

    }
    global static void sendCustomCoachingReportAll(Date analysisDate) {

    }
    global static Integer sendVisionErrors() {
        return null;
    }
global class MalformedCallException extends Exception {
}
global class PermissionException extends Exception {
}
}
