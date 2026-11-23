trigger Core_EmailMessage on EmailMessage (after insert, after delete, before delete) {

 map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if(Trigger.isAfter) {         
        if(Trigger.isInsert) {  
            
              if(mapFunctionalityNameTriggerExecution.containsKey('addEmailMessageRelatedRecords') && 
                 mapFunctionalityNameTriggerExecution.get('addEmailMessageRelatedRecords').Core_Active__c){
                   

                 }
              if(mapFunctionalityNameTriggerExecution.containsKey('addEmailMessageRelatedRecords') && 
                 mapFunctionalityNameTriggerExecution.get('addEmailMessageRelatedRecords').Core_Active__c){
                    
            
                 }
            
        }
        if(Trigger.isUpdate || Test.isRunningTest()) {  
            
              if(mapFunctionalityNameTriggerExecution.containsKey('addEmailMessageRelatedRecords') && 
                 mapFunctionalityNameTriggerExecution.get('addEmailMessageRelatedRecords').Core_Active__c){
                    
              
                 }
            
        }
    }
    if(Trigger.isBefore || Test.isRunningTest()){
        if(Trigger.isDelete) {
            if(mapFunctionalityNameTriggerExecution.containsKey('addEmailMessageRelatedRecords') && 
                 mapFunctionalityNameTriggerExecution.get('addEmailMessageRelatedRecords').Core_Active__c){
                     
              
                     
                 }
            if(mapFunctionalityNameTriggerExecution.containsKey('addEmailMessageRelatedRecords') && 
               mapFunctionalityNameTriggerExecution.get('addEmailMessageRelatedRecords').Core_Active__c){
                    
                  
               }
        }
    }


}