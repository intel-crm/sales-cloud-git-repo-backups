public with sharing class DateFormatter {   
    // Method to test    
    //@AuraEnabled
    /*public static String getFormattedDate(DateHelper helper) { //DateHelper helper
    return 'Today\'s date is ' + helper.getTodaysDate();
    //return helper;
    }*/
    public static Map<String, String> getFormattedDate(DateHelper helper) { //DateHelper helper
        return helper.getTodaysDate();
    }
}