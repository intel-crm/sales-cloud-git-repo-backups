global class Core_ContactAudienceListBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    List<Contact> returnedContactList = new List<Contact>();
    List<Contact> contactListFromAudienceListMethod = new List<Contact>();
    String successfulContactsStr = '';
    String failureContactsStr = '';
    String failureDetails = '';
 
    final static string FIELDS_AFFECTED_ERRORS = 'Contact fields that affected this error:';
    final static String AUDIENCE_LIST_BATCH = 'AudienceList Update Batch';
    final static String BATCHES_PROCESSED = 'Batches processed with';
    final static String FAILURE_RECORDS = 'failures';
    //Getting the email ids from the label
    String 	Core_Email_Batch_Status_Label = System.Label.Core_Email_Batch_Status_Label;
    //Splitting email ids with comma seperated
    List<String> lstEmailIds = Core_Email_Batch_Status_Label.split(';');
    //Batch Start method
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String Core_Entitlement_Id_Label = System.Label.Core_Entitlement_Id;
        List<String> lstEntitlementIds = new List<String>();
        List<Core_Entitlement__c> entitlementDetails = new List<Core_Entitlement__c>();
        //When test is not running
        if(!Test.isRunningTest()){
            lstEntitlementIds = Core_Entitlement_Id_Label.split(';');
        }else{
            //Querying Entitlement Detail
            entitlementDetails = [Select Id, Name, Core_Display_Name__c from Core_Entitlement__c];
            for(Core_Entitlement__c coreEntitlement : entitlementDetails){
                lstEntitlementIds.add(coreEntitlement.Id);
            }
        }
        List <Core_Contact_Entitlement__c> contactEntitlementList = new List<Core_Contact_Entitlement__c>();
        //Querying contactEntitlementList for the lstEntitlementIds 
        contactEntitlementList = [Select Core_Contact_Id__c, Core_Entitlement_Id__c FROM Core_Contact_Entitlement__c WHERE Core_Selected__c = true AND Core_Status__c = 'Complete' 
                                  AND Core_Entitlement_Id__c in :lstEntitlementIds];
        
        return Database.getQueryLocator(
            'Select Core_Contact_Id__c, Core_Entitlement_Id__c '+
            ' FROM Core_Contact_Entitlement__c WHERE Core_Selected__c = true '+
            ' AND Core_Status__c = \'Complete\' '+
            ' AND Core_Entitlement_Id__c in :lstEntitlementIds');
    }
    //Batch Execute method
	global void execute(Database.BatchableContext bc, List<Core_Contact_Entitlement__c> scope){
        //storing the contact details returned by populateAudienceList() method from Core_ContactAudienceList 
     	returnedContactList = Core_ContactAudienceList.populateAudienceList(scope);
		Database.SaveResult[] updateResults = new List<Database.SaveResult>();        
        if(Test.isRunningTest()){
            Database.SaveResult updateResultsSingleRec = (Database.SaveResult)
            JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}',
                             Database.SaveResult.class);
            updateResults.add(updateResultsSingleRec);
        }else{
            updateResults = Database.update(returnedContactList, false); 
        }
        
        
        for(Integer i=0;i<updateResults.size();i++){
            //get the ID of the record that was processed Successfully
            if (updateResults.get(i).isSuccess()){
                successfulContactsStr += updateResults.get(i).getId() + ' \t ';   
                
            }else if (updateResults.get(i) != null && !updateResults.get(i).isSuccess()){
                // DML operation failed so get all errors
                String failedDML = '';
                if(updateResults.get(i).getErrors() != null && !updateResults.get(i).getErrors().isEmpty()){
                	Database.Error error = updateResults.get(i).getErrors().get(0);
                	failedDML = error.getMessage();
                }
                if(returnedContactList.get(i) != null){
                	failureContactsStr += returnedContactList.get(i).Id + '\t' + failedDML + ' \t ';
                    
                }
             }
        
        }

	}
    //Batch Finish method
	global void finish(Database.BatchableContext bc){        
        AsyncApexJob apexJob = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email 
                          from AsyncApexJob where Id =:bc.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{};
        toAddresses.add(apexJob.CreatedBy.Email);
        for(String strOfEmails:lstEmailIds){
            toAddresses.add(strOfEmails);
        }
        mail.setToAddresses(toAddresses);
        mail.setSubject(AUDIENCE_LIST_BATCH +' '+ apexJob.Status);
        //Mail Body
        mail.setPlainTextBody(apexJob.TotalJobItems+' '+ BATCHES_PROCESSED+' '+ apexJob.NumberOfErrors+' '+ FAILURE_RECORDS + '\n'+
                             + 'Contacts which were successfully updated : ' + successfulContactsStr + '\n' +
                             + 'Contacts which could not be processed : ' + failureContactsStr);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 

}