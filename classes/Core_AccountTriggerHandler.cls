public without sharing class Core_AccountTriggerHandler extends TriggerHandler {
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    static boolean isAccountNumberInsertCalled = false;
    static boolean isAccountNumberUpdateCalled = false;
    static boolean runonce=true;
    Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
    
    
    public override void beforeInsert(){

        //Call the Account Dup Check method to update the Record Type field mapping from UCD_ACM_AccountHandler
        if(mapFunctionalityNameTriggerExecution.containsKey('accountDupCheck') &&
            mapFunctionalityNameTriggerExecution.get('accountDupCheck').Core_Active__c){
                Core_AccountTriggerHandlerController.accountRecordTypeDupFieldUpdate(Trigger.new);
        }

        //Call the method to populate both Geo & Sub Geo fields using the Country State Reference object
        if(mapFunctionalityNameTriggerExecution.containsKey('accountObjectBeforeHandler') &&
            mapFunctionalityNameTriggerExecution.get('accountObjectBeforeHandler').Core_Active__c &&
            !Test.isRunningTest()) {
                Core_AccountTriggerHandlerController.accountObjectBeforeHandler((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.NewMap,(Map<Id,Account>)Trigger.OldMap);
        }

        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_MultipleVCForSameProg') && 
            mapFunctionalityNameTriggerExecution.get('Core_MDF_MultipleVCForSameProg').Core_Active__c ) {
                Core_AccountTriggerHandlerController.preventMultipleVCForSameProg(Trigger.new);
        }

        //US901870: KIIT Reduce Account validation rule - analysis
        if(mapFunctionalityNameTriggerExecution.containsKey('ValidateTierValues') &&
            mapFunctionalityNameTriggerExecution.get('ValidateTierValues').Core_Active__c ){
                Core_AccountTriggerHandlerController.validateTierValues(Trigger.New);
        }

        if( mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_IgnoreUpdateAccountFields') && 
            mapFunctionalityNameTriggerExecution.get('UCD_ACM_IgnoreUpdateAccountFields').Core_Active__c ){
                Core_AccountTriggerHandlerController.updateAccountAddress(Trigger.New);
        }

        /*
         * description : If Business Party Id is already present in salesforce then change the recordType
         *               to RejectedAccount otherwise it is EndCustomer.
         * params : Trigger.New
         * return : NA
         * author and date :ankit1x.sharma@intel.com, 23/11/2021
        */
       /* if( mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_UpdateRecordType') && 
            mapFunctionalityNameTriggerExecution.get('UCD_ACM_UpdateRecordType').Core_Active__c ){
                Core_AccountTriggerHandlerController.updateAccountRecordType((List<Account>)Trigger.New, (Map<Id,Account>)Trigger.OldMap);
        }*/

        /*
         * description : Update UCD Hierarchy fields before create or update
         * author and date :Chethan.s.kunder@intel.com, 26/11/2021
        */
        if( mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_UpdateHierarchy') && 
            mapFunctionalityNameTriggerExecution.get('UCD_ACM_UpdateHierarchy').Core_Active__c){
                Core_AccountTriggerHandlerController.updateHierarchyFields(Trigger.New);
        }
    }
    public override void beforeUpdate(){
        
        //Call the Account Dup Check method to update the Record Type field mapping from UCD_ACM_AccountHandler
        if(mapFunctionalityNameTriggerExecution.containsKey('accountDupCheck') &&
            mapFunctionalityNameTriggerExecution.get('accountDupCheck').Core_Active__c){
                Core_AccountTriggerHandlerController.accountRecordTypeDupFieldUpdate(Trigger.new);
        }

        //Call the method to populate both Geo & Sub Geo fields using the Country State Reference object
        if(mapFunctionalityNameTriggerExecution.containsKey('accountObjectBeforeHandler') &&
            mapFunctionalityNameTriggerExecution.get('accountObjectBeforeHandler').Core_Active__c && 
            !Test.isRunningTest()) {
                Core_AccountTriggerHandlerController.accountObjectBeforeHandler((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.NewMap,(Map<Id,Account>)Trigger.OldMap);
        }

        //US901870: KIIT Reduce Account validation rule - analysis
        if(mapFunctionalityNameTriggerExecution.containsKey('ValidateTierValues') &&
            mapFunctionalityNameTriggerExecution.get('ValidateTierValues').Core_Active__c ){
                Core_AccountTriggerHandlerController.validateTierValues(trigger.New);
        }

        //[Mar/07/2016 : Calling the method which would restrict the Users to change the Partner->Customer/Customer->Partner Account.]
        if(!Test.isRunningTest()){
            Core_IPS_Account_Trigger_Handler.restrictManageExternalAccount((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
        }

        // 3/28/17 DH: code added to prevent A&E User account ownership
        if(mapFunctionalityNameTriggerExecution.containsKey('accountPreventAEUserOwnership') &&
            mapFunctionalityNameTriggerExecution.get('accountPreventAEUserOwnership').Core_Active__c && 
            !Test.isRunningTest())  {
                Core_AccountTriggerHandlerController.preventAEUserAccountOwnership((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
        }
        
        if( mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_IgnoreUpdateAccountFields') && 
            mapFunctionalityNameTriggerExecution.get('UCD_ACM_IgnoreUpdateAccountFields').Core_Active__c ){
                Core_AccountTriggerHandlerController.restrictUpdatingSFFields(Trigger.New, Trigger.Old);
        }

        // 12/14/2016 Method to send out BoxB Account Outbound Message
        if(!Test.isRunningTest()){
            Core_AccountTriggerHandlerController.preventUncoveredAccountChange((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
            Core_ContactEntitlementValidation.validateAccountEnglishOnlyFields((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
            Core_Entitlement_Outbound_Integrations.generateBoxBAccountOutboundMessage((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
        }

        //Set IPA integration status to pending - IPA integration
        //Added by Anand TB - US607581
        if(mapFunctionalityNameTriggerExecution.containsKey('Account_Update_IPA_Integration_Trigger') &&
            mapFunctionalityNameTriggerExecution.get('Account_Update_IPA_Integration_Trigger').Core_Active__c && 
            !Test.isRunningTest()) {
            //system.enqueueJob(new PRM_SalesCloudAccountIntStatus_Handler((List<Account>)triggerNew, (Map<Id,Account>)triggerOldMap, (Set<Id>)triggerNewMap.keySet()));
                PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPendingOnUpdate( (List<Account>)trigger.New, (Map<Id,Account>)trigger.OldMap, (Set<Id>)trigger.NewMap.keySet());
        }

        if(mapFunctionalityNameTriggerExecution.containsKey('preventUncoveredAccountChange') && 
            mapFunctionalityNameTriggerExecution.get('preventUncoveredAccountChange').Core_Active__c)  {
                Core_AccountTriggerHandlerController.preventUncoveredAccountChangeOnOppStatus((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
        }

        //To validate the co-marketing Account's Parent Fund Account changes
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ValidatePFAChange') && 
            mapFunctionalityNameTriggerExecution.get('Core_MDF_ValidatePFAChange').Core_Active__c &&
            !Test.isRunningTest()) {
                Core_AccountTriggerHandlerController.validateMDFParentFundAccChanges((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
        }

        /*
         * description : If Business Party Id is already present in salesforce then change the recordType
         *               to RejectedAccount otherwise it is EndCustomer.
         * params : Trigger.New
         * return : NA
         * author and date :ankit1x.sharma@intel.com, 23/11/2021
        */
        if( mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_UpdateRecordType') && 
            mapFunctionalityNameTriggerExecution.get('UCD_ACM_UpdateRecordType').Core_Active__c ){
                Core_AccountTriggerHandlerController.updateAccountRecordType((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
        }

        /*
         * description : Update UCD Hierarchy fields before create or update
         * author and date :Chethan.s.kunder@intel.com, 26/11/2021
        */
        if( mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_UpdateHierarchy') && 
            mapFunctionalityNameTriggerExecution.get('UCD_ACM_UpdateHierarchy').Core_Active__c ){
                Core_AccountTriggerHandlerController.updateHierarchyFields((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap, false);
        }
        /*List<Account> newAccounts = Trigger.new;
        Map<id, Account> oldMap = (Map<id, Account>) Trigger.oldMap;
        List<Account> updatedAccounts = new List<Account>();
        List<PRM_SendNotificationMessages.MessageWrapper> messageWrappers = new List<PRM_SendNotificationMessages.MessageWrapper>();
        if(!Test.isRunningTest()){
        for (Account newAccount : newAccounts) {
            Account oldAccount = oldMap.get(newAccount.Id);

            if (
                newAccount.OwnerId != oldAccount.OwnerId &&
                newAccount.RecordType.DeveloperName == Label.PRM_Intel_Account &&
                newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c) {
                    PRM_SendNotificationMessages.MessageWrapper messageWrapper = new PRM_SendNotificationMessages.MessageWrapper();
                    messageWrapper.accountId = newAccount.ID;
                            messageWrapper.msgCd = Label.PRM_Msgcd_NewManager;
                            messageWrappers.add(messageWrapper);

            }
        }
        if (!updatedAccounts.isEmpty()) {
            PRM_SendNotificationMessages.sendNotifications(messageWrappers);
        }
     }*/
      


    }
    public override void beforeDelete(){}
    public override void afterInsert(){
     
        if (!Test.isRunningTest() && isAccountNumberInsertCalled == false) {
      List<Account> accountNewList = Trigger.new;
      List<Account> accList = new List<Account>();
      for (Account acc : accountNewList) {
        if ( String.isNotBlank(acc.AccountNumber) && acc.RecordTypeId == accountRecordType) {
          accList.add(acc);
        }
      }
        System.debug('accList'+accList);
        if(accList!= null && !accList.isEmpty()) {
          PRM_AccountNumberGenerator.updateAccountNumberCS(accList, null);
          isAccountNumberInsertCalled = true;
    }
  }

        List<Account> accountToBeSharedList = new List<Account>();
        //To create Group on Co-Marketing Accounts for Node Based Sharing
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_createGroupForAccountNode') &&
            mapFunctionalityNameTriggerExecution.get('Core_MDF_createGroupForAccountNode').Core_Active__c)
        {
            accountToBeSharedList = Core_AccountTriggerHandlerController.createGroupForComarketingAccount(trigger.New);
        }

         //To call Batch process for Account and Budget Sharing
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ShareAccountsWithGroups') &&
            mapFunctionalityNameTriggerExecution.get('Core_MDF_ShareAccountsWithGroups').Core_Active__c &&
            !Test.isRunningTest())
        {
            Core_AccountTriggerHandlerController.sharingWithNewAcctGrps(accountToBeSharedList);
        }

        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_Account_node_share') && 
           mapFunctionalityNameTriggerExecution.get('Core_MDF_Account_node_share').Core_Active__c &&
           !Test.isRunningTest()) {
                if(!Core_MDF_Utility.byPassFeature('Bypass_External_Group_Creation')){
                    Core_AccountTriggerHandlerController.createNodeSharingGroup((Map<Id,Account>)Trigger.NewMap);
                }    
        }

        if(mapFunctionalityNameTriggerExecution.containsKey('UpdatePrimaryDirectAccount') &&
            mapFunctionalityNameTriggerExecution.get('UpdatePrimaryDirectAccount').Core_Active__c &&
            !Test.isRunningTest())  
        {
            Core_DirectAccount_Handler.UpdatePrimaryAcc(trigger.New);
        }

        //[Abhishek Arya : Mar/16/2016 : User Story# US36728 : ECB Marked Accounts Needs to Deactivate all IPS Contacts.]
        if(!Test.isRunningTest()){
            //Core_IPS_Account_Trigger_Handler.UpdateContactOnECBCheck(trigger.New,null);
        }
		if(mapFunctionalityNameTriggerExecution.containsKey('PRM_CreateTrackerMilestones') &&
            mapFunctionalityNameTriggerExecution.get('PRM_CreateTrackerMilestones').Core_Active__c){
                Core_IPS_Account_Trigger_Handler.createTrackerMilestonesForBadgeTierUpdate((List<Account>)Trigger.New,null);
        }
    }
    public override void afterUpdate(){

        if(runonce){
            runonce=false;
        }
        

        if(mapFunctionalityNameTriggerExecution.containsKey('UpdatePrimaryDirectAccount') &&
            mapFunctionalityNameTriggerExecution.get('UpdatePrimaryDirectAccount').Core_Active__c && 
            !Test.isRunningTest())  
        {
            Core_DirectAccount_Handler.UpdatePrimaryAccAsBlank((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
                   
            Core_DirectAccount_Handler.UpdatePrimaryAccOnIntelRec((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
        }

        if(!Test.isRunningTest()){
            Core_IPS_Account_Trigger_Handler.assignEntitlementToIPSAccount((Map<Id,Account>)Trigger.OldMap, (List<Account>)Trigger.New);
            Core_IPS_Account_Trigger_Handler.revokeAccess((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
            Core_IPS_Account_Trigger_Handler.grantAccess((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
        }
        
        // added by Javid - Agate as part of TWC729 - 1886
        if(mapFunctionalityNameTriggerExecution.containsKey('CIMIDStampCheck') &&
           mapFunctionalityNameTriggerExecution.get('CIMIDStampCheck').Core_Active__c && Core_IPS_Account_Trigger_Handler.isFirstRunCheck &&
           !Test.isRunningTest())  
        {
            Core_IPS_Account_Trigger_Handler.isFirstRunCheck = false ;
            Core_IPS_Account_Trigger_Handler.CIMIdStamped((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
        }

        if(!Test.isRunningTest()){
            //TWC729-3627
            Core_AccountTriggerHandlerController.accountRecordTypeAfterUpdate((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap, (Map<Id,Account>)Trigger.NewMap);
            //[Abhishek Arya : Mar/16/2016 : User Story# US36728 : ECB Marked Accounts Needs to Deactivate all IPS Contacts.]
            //Core_IPS_Account_Trigger_Handler.UpdateContactOnECBCheck((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
            
            //David S Wong: Jun 3 2016: US35541 ACCOUNTS: Automate Account Team Membership Audit
            Core_AccountTriggerHandlerController.accountTeamAuditCompletion((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
            
            // Zay Montalbo 2/10/2017 Change account english only name
            
            // Zay Montalbo 1/31/2017 CIM Update on Account generate ERPM OBM
            Core_Entitlement_Outbound_Integrations.generateOBMOnCIMUpdate((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
        }

         //To validate the co-marketing Account's Parent Fund Account changes
         if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ValidatePFAChangeOnAftrUpdt') && 
         mapFunctionalityNameTriggerExecution.get('Core_MDF_ValidatePFAChangeOnAftrUpdt').Core_Active__c) 
        {
            Core_AccountTriggerHandlerController.validateAccountHierarchy((List<Account>)Trigger.new, (Map<Id,Account>)Trigger.oldMap);
        } 

        // Uday 5/5/2019 US351963 - Populate all the MP fields from Account to its Company Information object.
        if(mapFunctionalityNameTriggerExecution.containsKey('Update_MP_Partners') &&
            mapFunctionalityNameTriggerExecution.get('Update_MP_Partners').Core_Active__c && 
            !Test.isRunningTest())
        {
            // Commented the below - As part of OPID Restructure - Sathish
            // Core_AccountHandler.updatePartnerInfo(trigger.New,trigger.NewMap,trigger.OldMap);
            //Added by Kirshna Ch - US854868 -KTBE : Changes in Biz org, Specialty
            PMP_AccountHandler.updatePartnerInfo((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.NewMap,(Map<Id,Account>)Trigger.OldMap);
        }

        /********************* Raushan US369121 - Update Membership flag when partner type is being changed.***************/
        if(mapFunctionalityNameTriggerExecution.containsKey('accountPartnerTypeAfterUpate') &&
            mapFunctionalityNameTriggerExecution.get('accountPartnerTypeAfterUpate').Core_Active__c &&
            !Test.isRunningTest())
        {
            Core_AccountTriggerHandlerController.membershipFlagUpdate((List<Account>)Trigger.Old,(List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap, (Map<Id,Account>)Trigger.NewMap);
        }

        //Rahul Added for US759847
        if(mapFunctionalityNameTriggerExecution.containsKey('Roll_up_account') &&
            mapFunctionalityNameTriggerExecution.get('Roll_up_account').Core_Active__c &&
            !Test.isRunningTest()) 
        {
            Core_AccountTriggerHandlerController.invokeRollUpScenario((List<Account>)trigger.New,(Map<Id,Account>)Trigger.OldMap);
                   
        }
        
     if (!Test.isRunningTest() && isAccountNumberUpdateCalled == false) {
      List<Account> accountNewListupdate = Trigger.new;
      Map<Id, Account> oldMap = (Map<Id, Account>)Trigger.oldMap;
      List<Account> accListupdate = new List<Account>();
      for (Account acc : accountNewListupdate) {
        if (oldMap !=null && oldMap.get(acc.Id).AccountNumber!=acc.AccountNumber &&
            String.isNotBlank(acc.AccountNumber) && acc.RecordTypeId == accountRecordType) {
            accListupdate.add(acc);
            system.debug('accAccountNumber'+acc.AccountNumber);
        }
      }
        System.debug('accListupdate'+accListupdate);
        if(accListupdate!= null && !accListupdate.isEmpty()) {
          PRM_AccountNumberGenerator.updateAccountNumberCS(accListupdate, oldMap);
          isAccountNumberUpdateCalled = true;
    }
  }

        

        /*
        * description : If any changes in account and if recordtype is Intel Account publish platform Event.
        * params : Trigger.new (List<Account>, Trigger.old (List<Account>,Trigger.isUpdate)
        * return : NA
        * author and date : Harshal Gosavi, 4th August 2021
        */
        if(mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_ExecutePlatformEvent') && 
            mapFunctionalityNameTriggerExecution.get('UCD_ACM_ExecutePlatformEvent').Core_Active__c)
        {
            Core_AccountTriggerHandlerController.triggerPlatformEventOnUpdate((List<Account>)Trigger.New, (Map<Id,Account>)Trigger.oldMap);
        }

        /*
        * description : Update UCD Hierarchy fields after update
        * author and date :Chethan.s.kunder@intel.com, 1 Dec 2021
        */
        if( mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_UpdateHierarchy') && 
            mapFunctionalityNameTriggerExecution.get('UCD_ACM_UpdateHierarchy').Core_Active__c &&
            !Test.isRunningTest())
        {
            Core_AccountTriggerHandlerController.updateHierarchyFields((List<Account>)Trigger.New, (Map<Id,Account>)Trigger.OldMap, true);
        }

         /*
        * description : Update Account Parent if parent is missing
        * author and date :harshalx.sunil.gosavi@intel.com, 1 Apr 2022
        */
        if(mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_UpdateParentOnAccount') && 
            mapFunctionalityNameTriggerExecution.get('UCD_ACM_UpdateParentOnAccount').Core_Active__c &&
            !Test.isRunningTest())
        {
            Core_AccountTriggerHandlerController.updateParentOnAccount((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
        }

        if(mapFunctionalityNameTriggerExecution.containsKey('PRM_CreateTrackerMilestones') &&
            mapFunctionalityNameTriggerExecution.get('PRM_CreateTrackerMilestones').Core_Active__c){
                Core_IPS_Account_Trigger_Handler.createTrackerMilestonesForBadgeTierUpdate((List<Account>)Trigger.New,(Map<Id,Account>)Trigger.OldMap);
        }

    }
    public override void afterDelete(){
        if(mapFunctionalityNameTriggerExecution.containsKey('accountObjectAfterDelete') &&
            mapFunctionalityNameTriggerExecution.get('accountObjectAfterDelete').Core_Active__c &&
            !Test.isRunningTest()) 
        {
            Core_AccountTriggerHandlerController.accountObjectAfterDelete((List<Account>)Trigger.New, (Map<Id,Account>)Trigger.NewMap, (List<Account>)Trigger.Old, (Map<Id,Account>)Trigger.OldMap);
        }
    }
    public override void afterUndelete(){}

}