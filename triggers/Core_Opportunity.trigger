/******************************************************************************************************************************************
Function    : Trigger for the object opportunity
*****************************************************************************************************************************************/
trigger Core_Opportunity on Opportunity(before insert, before update, after insert, after update, before delete) {
	map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
	
    //NP - WW44 Opportunity Trigger Switch
    //NK - WW44 Opportunity Bypass for Specific User
    if((!mapFunctionalityNameTriggerExecution.containsKey('BypassOpportunityTrigger') || (mapFunctionalityNameTriggerExecution.containsKey('BypassOpportunityTrigger') && !mapFunctionalityNameTriggerExecution.get('BypassOpportunityTrigger').Core_Active__c)) && !system.label.get('','Core_CRM_L3_Bypass_Users').contains(UserInfo.getUserEmail())){
        Boolean isRenewORAmend = false;    
        for(Opportunity opp : (Trigger.isDelete?Trigger.old:Trigger.New)){
            if((opp.name?.contains('Renewal') && opp.SBQQ__Renewal__c==true) || (opp.name?.contains('Amendment') && opp.SBQQ__AmendedContract__c != null))
                isRenewORAmend = true;
        }
        if(Core_OpportunityLineItemHandler.KPIJSONCheckInsert && !isRenewORAmend){
            new Core_OpportunityHelper().run();
        }  
    }
}