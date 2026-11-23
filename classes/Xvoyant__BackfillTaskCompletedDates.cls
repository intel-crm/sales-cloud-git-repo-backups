/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class BackfillTaskCompletedDates implements Database.Batchable<SObject>, Database.Stateful {
    global Integer batchCount;
    global Integer count;
    global String Entity;
    global String Field;
    global String Query;
    global String Value;
    global BackfillTaskCompletedDates(String q, String e, String f, String v) {

    }
    global void execute(Database.BatchableContext BC, List<SObject> scope) {

    }
    global void finish(Database.BatchableContext BC) {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }
}
