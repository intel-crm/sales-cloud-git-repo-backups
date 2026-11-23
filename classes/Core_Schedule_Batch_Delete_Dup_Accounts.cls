global class Core_Schedule_Batch_Delete_Dup_Accounts implements Schedulable {
    Map<String,Core_ACM_Control_Execution__c> mapAcmClassCheckToEol = Core_ACM_Control_Execution__c.getAll();
    global void execute(SchedulableContext sc) {
        if(mapAcmClassCheckToEol.containsKey('Delete_Dup_Accounts') && mapAcmClassCheckToEol.get('Delete_Dup_Accounts').IsActive__c) {
            Database.executeBatch(new Core_Batch_Delete_Dup_Accounts());
        }
    }
}