/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class LogsCleaner implements Database.Batchable<SObject>, Database.Stateful, System.Schedulable {
    global LogsCleaner(Integer daysOlderFromToday, Integer batchSize) {

    }
    global void execute(System.SchedulableContext sc) {

    }
    global void execute(Database.BatchableContext BC, List<rtsync__Log__c> scope) {

    }
    global void finish(Database.BatchableContext BC) {

    }
    global static void scheduleDeleteLogsOlderThanDays(Integer daysOlderFromToday) {

    }
    global static void scheduleDeleteLogsOlderThanDays(Integer daysOlderFromToday, Integer batchSize) {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }
}
