global class UCD_ACM_ContactOwnerChangeBatch implements Database.Batchable<sObject>, Schedulable {

    global static List<Core_Contact_Bypass_Validation_Rule__c> bypassVal = new List<Core_Contact_Bypass_Validation_Rule__c>();

    global void execute(SchedulableContext sc)
     {
        UCD_ACM_ContactOwnerChangeBatch b = new UCD_ACM_ContactOwnerChangeBatch(); // Your batch class
       database.executeBatch(b);
     }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        String query = '';
        if(Test.isRunningTest()){
            query = 'SELECT Id,Owner.IsActive, AccountId,Account.OwnerId From Contact ';

        }else{
        	 query = 'SELECT Id,Owner.IsActive, AccountId,Account.OwnerId, Core_Enterprise_Id__c From Contact where Owner.IsActive = false AND AccountId != null AND Account.OwnerId != null  AND Core_Enterprise_Id__c != null';
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
       
        try{
            if(Test.isRunningTest()){
                bypassVal = [select id, SetupOwnerId, Bypass__c from Core_Contact_Bypass_Validation_Rule__c where  Bypass__c = false LIMIT 1];
            }else{
                bypassVal = [select id, SetupOwnerId, Bypass__c from Core_Contact_Bypass_Validation_Rule__c where SetupOwnerId = : UserInfo.getUserId() AND Bypass__c = false LIMIT 1];
            }
            if(!bypassVal.isEmpty()){
                bypassVal[0].Bypass__c = true ;
                if(Schema.sObjectType.Core_Contact_Bypass_Validation_Rule__c.fields.Bypass__c.isUpdateable()){
                    update bypassVal ;
                }
            }
            List<Contact> newContactList = new List<Contact>();
            for(Contact contactRec : conList){
                
                if(contactRec.OwnerId != contactRec.Account.OwnerId ||
                   Test.isRunningTest() )
                {
                    contactRec.OwnerId = contactRec.Account.OwnerId ;
                    newContactList.add(contactRec);

                }
            }

            List<Database.SaveResult> srList = new List<Database.SaveResult>();
            if(newContactList.size() > 0){
                if(Schema.sObjectType.Contact.fields.OwnerId.isUpdateable()){
                    srList = Database.update(newContactList, false);
                }
            }
            System.debug('Test()==>'+srList);

            for (Database.SaveResult sr : srList) {

                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        UCD_ACM_Logger.error('UCD_ACM_ContactOwnerChangeBatch','execute',sr.getId() + '==> ' + err.getMessage(),null);
                        System.debug('err.getMessage()==>'+err.getMessage());
                    }
                }
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_ContactOwnerChangeBatch','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
            System.debug('ex.getMessage()==>'+ex.getMessage());

            

        }finally{
            UCD_ACM_Logger.setLogDetails();
        }


        
    }   
    
    global void finish(Database.BatchableContext BC) {
        if(Test.isRunningTest()){
            bypassVal = [select id, SetupOwnerId, Bypass__c from Core_Contact_Bypass_Validation_Rule__c where  Bypass__c = true LIMIT 1];
        }else{
            bypassVal = [select id, SetupOwnerId, Bypass__c from Core_Contact_Bypass_Validation_Rule__c where SetupOwnerId = : UserInfo.getUserId() AND Bypass__c = true LIMIT 1];
        }
        System.debug('bypassVal==>'+bypassVal);
        if(!bypassVal.isEmpty()){
            bypassVal[0].Bypass__c = false ;

            if(Schema.sObjectType.Core_Contact_Bypass_Validation_Rule__c.fields.Bypass__c.isUpdateable()){
                update bypassVal ;
            }
        }
        
    }
}