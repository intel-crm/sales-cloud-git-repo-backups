/**************************************************************************************
Apex Class Name:  Core_Account
Version     : 1.0 
Created Date: 03 OCT 2014
Function    : Trigger for the object Account
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/03/2014              Original Version
* Brian Matthews            12/3/2014               After-Delete.  Bulkified. 
* Dave Hood                 03/28/2017              Added code to prevent A&E User account ownership
*************************************************************************************/
trigger Core_Account on Account (before insert, before update, after delete,after update) {

    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        
        //Call the method to populate both Geo & Sub Geo fields using the Country State Reference object
        if(mapFunctionalityNameTriggerExecution.containsKey('accountObjectBeforeHandler') && 
           mapFunctionalityNameTriggerExecution.get('accountObjectBeforeHandler').Core_Active__c) 
            Core_AccountHandler.accountObjectBeforeHandler(Trigger.new,Trigger.newmap,Trigger.oldmap);
        
        //[Mar/07/2016 : Calling the method which would restrict the Users to change the Partner->Customer/Customer->Partner Account.]
        if(Trigger.isUpdate) {
            Core_IPS_Account_Trigger_Handler.restrictManageExternalAccount(Trigger.new,trigger.oldMap);
            
            // 3/28/17 DH: code added to prevent A&E User account ownership
            if(mapFunctionalityNameTriggerExecution.containsKey('accountPreventAEUserOwnership') && 
               mapFunctionalityNameTriggerExecution.get('accountPreventAEUserOwnership').Core_Active__c)  {
                   Core_AccountHandler.preventAEUserAccountOwnership(Trigger.new, Trigger.OldMap);
               }
            
            // 12/14/2016 Method to send out BoxB Account Outbound Message
            Core_AccountHandler.preventUncoveredAccountChange(Trigger.new, Trigger.OldMap);
            Core_ContactEntitlementValidation.validateAccountEnglishOnlyFields(Trigger.new, Trigger.OldMap);
            Core_Entitlement_Outbound_Integrations.generateBoxBAccountOutboundMessage(Trigger.new, Trigger.oldMap);
            
        }
    }
    
    if(trigger.isAfter && Trigger.isInsert){
        Core_IPS_Account_Trigger_Handler.assignEntitlementToIPSAccount(trigger.oldMap, trigger.new);
        
        //[Abhishek Arya : Mar/16/2016 : User Story# US36728 : ECB Marked Accounts Needs to Deactivate all IPS Contacts.]
        //Core_IPS_Account_Trigger_Handler.UpdateContactOnECBCheck(Trigger.new,null); //ECB flag logic validation-gangadhar
    }
    
    if (Trigger.isAfter && Trigger.isDelete) 
    {
        if(mapFunctionalityNameTriggerExecution.containsKey('accountObjectAfterDelete') && 
           mapFunctionalityNameTriggerExecution.get('accountObjectAfterDelete').Core_Active__c)
            Core_AccountHandler.accountObjectAfterDelete(Trigger.new, Trigger.newmap, Trigger.old, Trigger.oldmap);
        
        /*
        if(mapFunctionalityNameTriggerExecution.containsKey('deleteSalesoutShairing') && 
           mapFunctionalityNameTriggerExecution.get('deleteSalesoutShairing').Core_Active__c)
            Core_AccountHandler.deleteSalesoutShairing(trigger.new,trigger.old,trigger.newMap,trigger.oldMap,True); 
        */  
        
    }  
    
    if(Trigger.IsAfter && Trigger.IsUpdate)
    {
    
        /*
         if(mapFunctionalityNameTriggerExecution.containsKey('deleteSalesoutShairing') && 
           mapFunctionalityNameTriggerExecution.get('deleteSalesoutShairing').Core_Active__c)
             Core_AccountHandler.deleteSalesoutShairing(trigger.new,trigger.old,trigger.newMap,trigger.oldMap,False); 
        */
        Core_IPS_Account_Trigger_Handler.assignEntitlementToIPSAccount(trigger.oldMap, trigger.new);        
        Core_IPS_Account_Trigger_Handler.revokeAccess(Trigger.new,trigger.oldMap);
        Core_IPS_Account_Trigger_Handler.grantAccess(Trigger.new,trigger.oldMap);      
        
        //[Abhishek Arya : Mar/16/2016 : User Story# US36728 : ECB Marked Accounts Needs to Deactivate all IPS Contacts.]
        //Core_IPS_Account_Trigger_Handler.UpdateContactOnECBCheck(Trigger.new,Trigger.oldMap);//ECB flag logic validation-gangadhar
        
        //David S Wong: Jun 3 2016: US35541 ACCOUNTS: Automate Account Team Membership Audit
        Core_AccountHandler.accountTeamAuditCompletion(Trigger.new, Trigger.oldMap);
        
        // Zay Montalbo 2/10/2017 Change account english only name
        
        // Zay Montalbo 1/31/2017 CIM Update on Account generate ERPM OBM
        Core_Entitlement_Outbound_Integrations.generateOBMOnCIMUpdate(Trigger.new, Trigger.oldMap);
    }    
             
}