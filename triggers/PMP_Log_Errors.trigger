trigger PMP_Log_Errors on PMP_Error_Logging__e (after Insert) {
    
    System.debug('Executed!!!');
    
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('Events -->'+Trigger.new);
        List<Core_Log_Entry__c> listofrecords = new List<Core_Log_Entry__c>();
        for(PMP_Error_Logging__e error : Trigger.new){
            Core_Log_Entry__c entry = new Core_Log_Entry__c();
            entry.Core_Origin__c = error.Execution_Context__c;
            entry.Core_Details__c = error.PMP_Information_Message__c;
            entry.Core_Severity__c ='normal';
            entry.Core_When__c = System.now();
            entry.Core_Message__c = error.PMP_Transaction_Error__c?'Transaction Failed':'Transaction Processed';
            entry.Core_Project__c = 'MP';
            listofrecords.add(entry);
        }
        insert listofrecords;
        System.debug(' listofrecords -->'+listofrecords[0].Id);
            
    }
}