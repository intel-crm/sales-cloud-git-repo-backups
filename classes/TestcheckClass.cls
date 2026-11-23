global class TestcheckClass implements  Database.Batchable<sObject> {

 global Database.QueryLocator start(Database.BatchableContext bc) {
  /* string query=   'SELECT ID, Name,Bypass__c FROM Core_Validation_Bypass_for_Flow__c ';
  return Database.getQueryLocator(query);*/
 return null;
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope){

        // process each batch of records

       /* List<Core_Validation_Bypass_for_Flow__c> all = new List<Core_Validation_Bypass_for_Flow__c>();

        for (sObject aa : scope) {
            Core_Validation_Bypass_for_Flow__c label= (Core_Validation_Bypass_for_Flow__c)aa;  
            label.Bypass__c =true;
            all.add(label);    
            }
      update all;*/
        }

       

   
    global void finish(Database.BatchableContext bc){

    }
    }