/**
* @Name       		 : DDR_DMLOprationsCtrl
* @Description 		 : This class is used for Upsert operation only
* @author            : DINESH 
* @group             : 
* @last modified on  : 25-06-2023
* @last modified by  : 
**/
public without sharing class DDR_DMLOprationsCtrl {
    public static final String ORIGIN = 'DDR_DMLOprationsCtrl';
    public static final String SEVERITY = 'Critical';
    public static final String PROJECT = 'DDR';
    
    // Method to perform upsert operation on a list of sObjects
    public static void upsertData(List<SObject> sobjectList) {
        try {
            // Perform the upsert operation using Database.upsert and iterate over the UpsertResult records
            for (Database.UpsertResult recordResult : Database.upsert(sobjectList, false)) {
                if (!recordResult.isSuccess()) {
                    String errmsgs = '';
                    
                    // Iterate over the errors in the UpsertResult and concatenate the error messages
                    for (Database.Error errmsg : recordResult.getErrors()) {
                        errmsgs += errmsg.getMessage();
                    }
                    
                    // Log the error message using the logging method
                    Core_Log_Entry.logEntryWithDetails(ORIGIN + '.upsertData', PROJECT, 'Message', SEVERITY, errmsgs, '', null, null, null);
                }
            }
        } catch (Exception ex) {
            // Handle any exceptions that occur during the upsert operation and log the error message
            Core_Log_Entry.logEntryWithDetails(ORIGIN + '.upsertData', PROJECT, 'Message', SEVERITY, ex.getMessage(), '', null, null, null);
        }
    }
}