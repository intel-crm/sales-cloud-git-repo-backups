trigger Sales_FreeLicenseRequestTrigger on PSG_Free_License_Request__c (after insert, after update) {
    //Added by Ayan for demo
    for(PSG_Free_License_Request__c rqst : Trigger.New){
        
        //Sales_CreateLicenseProvider.createLicNew(rqst);
    }
    
}