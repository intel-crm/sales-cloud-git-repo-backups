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
* Sarah Manuel              25/08/2020              Added code to onboard IPA accounts and Create group for Co-marketing Accounts
* Anjali Haryani            14/09/2020              Commented IPS code in after insert as that was not being invoked anytime
*************************************************************************************/
trigger Core_Account on Account (before insert, before update, after delete,after update,after insert) {

    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        
        //Call the method to populate both Geo & Sub Geo fields using the Country State Reference object
        if(mapFunctionalityNameTriggerExecution.containsKey('accountObjectBeforeHandler') && 
           mapFunctionalityNameTriggerExecution.get('accountObjectBeforeHandler').Core_Active__c) 
            Core_AccountHandler.accountObjectBeforeHandler(Trigger.new,Trigger.newmap,Trigger.oldmap);
        System.debug('Trigger.new after accountObjectBeforeHandler:::'+Trigger.new[0].IsPartner);
        
        
         System.debug('Trigger.new before owner change :::'+Trigger.new[0].Ownerid);
         //Trigger.new[0].Ownerid = Label.Core_MDF_Dummy_Account_Owner_Id;
         System.debug('Trigger.new after owner change :::'+Trigger.new[0].Ownerid);
               
        if(Trigger.isBefore && Trigger.isInsert){
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_AccountOnBeforeInsert') && 
               mapFunctionalityNameTriggerExecution.get('Core_MDF_AccountOnBeforeInsert').Core_Active__c) 
            {
                Core_MDF_AccountServiceHandler.processCCPTriggerUpdates((List<Account>)Trigger.New, (Map<Id, Account>) Trigger.newMap, (Map<Id, Account>) Trigger.oldMap, 'before insert');
            }
            
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_MultipleVCForSameProg') && 
               mapFunctionalityNameTriggerExecution.get('Core_MDF_MultipleVCForSameProg').Core_Active__c) 
            {
            	//Core_AccountHandler.preventMultipleVCForSameProg(Trigger.new);
            }
            //This method is called to restrict manual virtual Corp Account creation from Account
            //Core_AccountHandler.preventManualVCInsertion(Trigger.new);
            
            //This method is called during node account creation to update the host region on node accounts from its parent fund account(parent can be either virtual corp account or another node account)
            if(mapFunctionalityNameTriggerExecution.containskey('Core_MDF_UpdateHostRegionOnNodeAcc') &&
               mapFunctionalityNameTriggerExecution.get('Core_MDF_UpdateHostRegionOnNodeAcc').Core_Active__c) {
                   //Core_AccountHandler.updateHostRegionOnNodeAccounts((List<Account>)Trigger.New);
                   //Core_AccountHandler.processCCPTriggerUpdates((List<Account>)Trigger.New, (Map<Id, Account>) Trigger.newMap, (Map<Id, Account>) Trigger.oldMap, 'before insert');
               }
            
        }       	
          
        //[Mar/07/2016 : Calling the method which would restrict the Users to change the Partner->Customer/Customer->Partner Account.]
        if(Trigger.isUpdate) {
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_AccountOnBeforeUpdate') && 
               mapFunctionalityNameTriggerExecution.get('Core_MDF_AccountOnBeforeUpdate').Core_Active__c) 
            {
                Core_MDF_AccountServiceHandler.processCCPTriggerUpdates((List<Account>)Trigger.New, (Map<Id, Account>) Trigger.newMap, (Map<Id, Account>) Trigger.oldMap, 'before update');
            }
            if(mapFunctionalityNameTriggerExecution.containskey('Core_MDF_IPA_Account_Region_Check') &&
               mapFunctionalityNameTriggerExecution.get('Core_MDF_IPA_Account_Region_Check').Core_Active__c) {
                   //Core_AccountHandler.restrictHostRegionUpdateOnNodeAccounts((Map<Id,Account>)Trigger.NewMap, (Map<Id,Account>)Trigger.OldMap);
                   //Core_AccountHandler.processCCPTriggerUpdates((List<Account>)Trigger.New, (Map<Id, Account>) Trigger.newMap, (Map<Id, Account>) Trigger.oldMap, 'before update');
               }

           
            //To check if the IPA MDF Account Onboarding automation is enabled, and call the method to validate the account.
           /*if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_EnableIPAMDFAccountOnboarding') && 
           mapFunctionalityNameTriggerExecution.get('Core_MDF_EnableIPAMDFAccountOnboarding').Core_Active__c) 
           {
                Core_AccountHandler.validateAccountForMDF((List<Account>) Trigger.new,(Map<Id,Account>) Trigger.oldMap);   
           }*/
           
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
            //To validate the co-marketing Account's Parent Fund Account changes
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ValidatePFAChange') && 
               mapFunctionalityNameTriggerExecution.get('Core_MDF_ValidatePFAChange').Core_Active__c) 
            {
                //Core_AccountHandler.validateMDFParentFundAccChanges(Trigger.new, Trigger.OldMap);
            }
        }
    }

    if(trigger.isAfter && Trigger.isInsert){
         System.debug('Trigger.new before Core_MDF_createGroupForAccountNode:::'+Trigger.new[0].IsPartner);
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_AccountOnAfterInsert') && 
           mapFunctionalityNameTriggerExecution.get('Core_MDF_AccountOnAfterInsert').Core_Active__c) 
        {
            Core_MDF_AccountServiceHandler.processCCPTriggerUpdates((List<Account>)Trigger.New, (Map<Id, Account>) Trigger.newMap, (Map<Id, Account>) Trigger.oldMap, 'after insert');
        } 
        //List<Account> accountToBeSharedList = new List<Account>();
        //To create Group on Co-Marketing Accounts for Node Based Sharing
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_createGroupForAccountNode') && 
           mapFunctionalityNameTriggerExecution.get('Core_MDF_createGroupForAccountNode').Core_Active__c) 
        {
            //accountToBeSharedList = Core_AccountHandler.createGroupForComarketingAccount(Trigger.new); 
        } 
        //To call Batch process for Account and Budget Sharing
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ShareAccountsWithGroups') && 
           mapFunctionalityNameTriggerExecution.get('Core_MDF_ShareAccountsWithGroups').Core_Active__c){
               //Core_AccountHandler.sharingWithNewAcctGrps(accountToBeSharedList);
           } 
        
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_Account_node_share') && 
           mapFunctionalityNameTriggerExecution.get('Core_MDF_Account_node_share').Core_Active__c) {
               if(!Core_MDF_Utility.byPassFeature('Bypass_External_Group_Creation')){
                   system.debug('createNodeSharingGroup' + Trigger.new);
        		//Core_AccountHandler.createNodeSharingGroup(Trigger.newmap);
               }
           }
        // Commenting below mentioned two methods as these was never being called, since after insert was never getting fired as event was not part of this trigger.
        // With CCP Requirement, we have added afterInsert in Trigger context hence need to comment assignEntitlementToIPSAccount and UpdateContactOnECBCheck
        // As discussed with Sumukh and Sriranjani, commenting assignEntitlementToIPSAccount and UpdateContactOnECBCheck on 14th September 2020
        //Core_IPS_Account_Trigger_Handler.assignEntitlementToIPSAccount(trigger.oldMap, trigger.new);
        
        //[Abhishek Arya : Mar/16/2016 : User Story# US36728 : ECB Marked Accounts Needs to Deactivate all IPS Contacts.]
        //Core_IPS_Account_Trigger_Handler.UpdateContactOnECBCheck(Trigger.new,null);                      
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
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_AccountOnAfterUpdate') && 
           mapFunctionalityNameTriggerExecution.get('Core_MDF_AccountOnAfterUpdate').Core_Active__c) 
        {
            Core_MDF_AccountServiceHandler.processCCPTriggerUpdates((List<Account>)Trigger.New, (Map<Id, Account>) Trigger.newMap, (Map<Id, Account>) Trigger.oldMap, 'after update');
        } 
    
        /*
         if(mapFunctionalityNameTriggerExecution.containsKey('deleteSalesoutShairing') && 
           mapFunctionalityNameTriggerExecution.get('deleteSalesoutShairing').Core_Active__c)
             Core_AccountHandler.deleteSalesoutShairing(trigger.new,trigger.old,trigger.newMap,trigger.oldMap,False); 
        */
        
        // This method will be called when a host region is changed on the virtual corp  and the same should be stamped on its child accounts
        if(mapFunctionalityNameTriggerExecution.containskey('Core_MDF_UpdateHostRegionAfterVCUpdate') &&
           mapFunctionalityNameTriggerExecution.get('Core_MDF_UpdateHostRegionAfterVCUpdate').Core_Active__c) {
               //Core_AccountHandler.updateHostRegionAfterVirtualCorpUpdate((List<Account>)Trigger.New, (Map<Id,Account>)Trigger.OldMap);
               //Core_AccountHandler.processCCPTriggerUpdates((List<Account>)Trigger.New, (Map<Id, Account>) Trigger.newMap, (Map<Id, Account>) Trigger.oldMap, 'after update');
           }
        


        Core_IPS_Account_Trigger_Handler.assignEntitlementToIPSAccount(trigger.oldMap, trigger.new);        
        Core_IPS_Account_Trigger_Handler.revokeAccess(Trigger.new,trigger.oldMap);
        Core_IPS_Account_Trigger_Handler.grantAccess(Trigger.new,trigger.oldMap);      
        
        //[Abhishek Arya : Mar/16/2016 : User Story# US36728 : ECB Marked Accounts Needs to Deactivate all IPS Contacts.]
        Core_IPS_Account_Trigger_Handler.UpdateContactOnECBCheck(Trigger.new,Trigger.oldMap);  
        
        //David S Wong: Jun 3 2016: US35541 ACCOUNTS: Automate Account Team Membership Audit
        Core_AccountHandler.accountTeamAuditCompletion(Trigger.new, Trigger.oldMap);
        
        // Zay Montalbo 2/10/2017 Change account english only name
        
        // Zay Montalbo 1/31/2017 CIM Update on Account generate ERPM OBM
        Core_Entitlement_Outbound_Integrations.generateOBMOnCIMUpdate(Trigger.new, Trigger.oldMap);
        
        //To validate the co-marketing Account's Parent Fund Account changes
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ValidatePFAChangeOnAftrUpdt') && 
           mapFunctionalityNameTriggerExecution.get('Core_MDF_ValidatePFAChangeOnAftrUpdt').Core_Active__c) 
        {
            //Core_AccountHandler.validateAccountHierarchy(Trigger.new, Trigger.oldMap);
        }
    }    
    
}