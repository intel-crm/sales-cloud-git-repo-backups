public class SPM_SecurityMappingBatch implements Database.Batchable<sObject>,Database.Stateful{

public Map<String,List<SPM_Security_Mapping__c>> securityMapTemp = new Map<String,List<SPM_Security_Mapping__c>>();
public Map<String,List<SPM_Security_Mapping__c>> regionalLeadMap = new Map<String,List<SPM_Security_Mapping__c>>();
public Set<string> uniqueManagerSet = new Set<string>();

public Database.QueryLocator start(Database.BatchableContext BC){
    String query='select Id,TA__c, Account_Owner__c,Account_Owner__r.Core_WWID__c, Customer_Category__c,Region__c,Role__c,Manager__c from SPM_Security_Mapping__c where Account_Owner__r.IsActive  = true and Manager__r.IsActive = true';
	return Database.getQueryLocator(query);
}

public void execute(Database.BatchableContext BC, List<SPM_Security_Mapping__c> scope){
    system.debug('INSIDE SECURITY MAPPING BATCH:'+scope.size());
    for(SPM_Security_Mapping__c tempSecurity : scope)
    {
        if(!securityMapTemp.containsKey(tempSecurity.Account_Owner__r.Core_WWID__c)){
             securityMapTemp.put(tempSecurity.Account_Owner__r.Core_WWID__c, new List<SPM_Security_Mapping__c>());
        }
        else{
            securityMapTemp.get(tempSecurity.Account_Owner__r.Core_WWID__c).add(tempSecurity);
        }
         if(tempSecurity.Role__c == 'Regional Lead'){
          	if(!regionalLeadMap.containsKey(tempSecurity.Region__c)) {
            		regionalLeadMap.put(tempSecurity.Region__c, new List<SPM_Security_Mapping__c>{tempSecurity});
              }
              else if(!uniqueManagerSet.contains(tempSecurity.Region__c+'_'+tempSecurity.Manager__c)) {
              		regionalLeadMap.get(tempSecurity.Region__c).add(tempSecurity);
                    uniqueManagerSet.add(tempSecurity.Region__c+'_'+tempSecurity.Manager__c);
                    } 
           	}  
                        
	}
}

public void finish(Database.BatchableContext BC){
    system.debug('INSIDE SECURITY MAPPING BATCH SECURITY:'+securityMapTemp);
    system.debug('INSIDE SECURITY MAPPING BATCH REGIONALLEAD:'+regionalLeadMap);
    system.debug('FINISH INSIDE SECURITY MAPPING BATCH SECURITY:'+securityMapTemp.size());
      system.debug('FINISH INSIDE SECURITY MAPPING BATCH REGIONALLEAD:'+regionalLeadMap.size());
	SPM_ShareAccountdetails batchForUncovered = new SPM_ShareAccountdetails(false,'Where Account_Owner_WWID__c != null and SPM_Customer_ID__c != null and CRM_CST_Is_Active_Planning_Period__c = true' ,50,securityMapTemp,regionalLeadMap);
	Database.executeBatch(batchForUncovered,50);

    
    }
}