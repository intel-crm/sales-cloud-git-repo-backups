public class PMP_Company_Info_TriggerHandler extends TriggerHandler {
	
    Map<Id,PMP_Company__c> oldMap = (Map<Id,PMP_Company__c>) Trigger.oldMap;
    Map<Id,PMP_Company__c> newMap = (Map<Id,PMP_Company__c>) Trigger.newMap;
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();    
    
    public override void afterInsert() {
        //Draco
        for(PMP_Company__c newCompany : (List<PMP_Company__c>) trigger.new){
        	
                PMP_Company_Info_Sharing.shareCompanyInfoRecords(Trigger.Old, Trigger.New);
                
        }
        
        //Tanzanite code added on 22nd Aug
        if(mapFunctionalityNameTriggerExecution.containsKey('Company_Info_Handler') && 
           mapFunctionalityNameTriggerExecution.get('Company_Info_Handler').Core_Active__c){        
        	PMP_SearchCompanyTranslationAction.insertTranslation(Trigger.isInsert, trigger.new);
        }
    }
    
    public override void afterUpdate() {
        //Draco
        for(PMP_Company__c newCompany : (List<PMP_Company__c>) trigger.new){
            if(newCompany.PMP_Account_Id__c!=oldMap.get(newCompany.Id).PMP_Account_Id__c || newCompany.OwnerId != oldMap.get(newCompany.Id).OwnerId){
                        
                        PMP_Company_Info_Sharing.shareCompanyInfoRecords(Trigger.Old, Trigger.New);
                    }
        }
        //PMP_Company_Info_Sharing.shareCompanyInfoRecords(Trigger.Old, Trigger.New);
        
        //Tanzanite code added on 22nd Aug
        if(mapFunctionalityNameTriggerExecution.containsKey('Company_Info_Handler') && 
           mapFunctionalityNameTriggerExecution.get('Company_Info_Handler').Core_Active__c){        
               if(PMP_SearchTierTriggerUtility.runOnce()){           
                   PMP_SearchCompanyLeadGenAction.updatePublishedCopy(Trigger.isUpdate, trigger.new, trigger.old, newMap, oldMap);
                   PMP_SearchPartnerTriggerHelper.syncPublishedPartnerCopy(trigger.new, oldMap);
               }
           }        
    }
       
}