public without sharing class Core_AccountTriggerHandler extends TriggerHandler {
  Map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
  Map<String, Set<String>> accountTriggerExecution = getAccountTriggerExecution();
  static boolean isAccountNumberInsertCalled = false;
  static boolean isAccountNumberUpdateCalled = false;
  Type triggerExecutionClassType;
  Id accountRecordType = Schema.getGlobalDescribe()
    .get('Account')
    .getDescribe()
    .getRecordTypeInfosByDeveloperName()
    .get(System.Label.PRM_Intel_Account)
    .getRecordTypeId();
  static boolean runonce = true;
  
  public override void beforeInsert() {
    String contractName = 'IBeforeInsertAccountTrigger';
    UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
  
    //Call the Account Dup Check method to update the Record Type field mapping from UCD_ACM_AccountHandler
    if (mapFunctionalityNameTriggerExecution.containsKey('accountDupCheck') && 
        mapFunctionalityNameTriggerExecution.get('accountDupCheck').Core_Active__c) {
          Core_AccountTriggerHandlerController.accountRecordTypeDupFieldUpdate( Trigger.new);
    }
  
    //Call the method to populate both Geo & Sub Geo fields using the Country State Reference object
    if ( mapFunctionalityNameTriggerExecution.containsKey( 'accountObjectBeforeHandler') && 
          mapFunctionalityNameTriggerExecution.get('accountObjectBeforeHandler').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.accountObjectBeforeHandler( (List<Account>) Trigger.New, (Map<Id, Account>) Trigger.NewMap,(Map<Id, Account>) Trigger.OldMap);
    }
  
    if ( mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_MultipleVCForSameProg') &&
        mapFunctionalityNameTriggerExecution.get('Core_MDF_MultipleVCForSameProg').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.preventMultipleVCForSameProg(Trigger.new);
    }
  
    //US901870: KIIT Reduce Account validation rule - analysis
    if (mapFunctionalityNameTriggerExecution.containsKey('ValidateTierValues') &&
        mapFunctionalityNameTriggerExecution.get('ValidateTierValues').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.validateTierValues(Trigger.New);
    }
  
    //This method is called during node account creation to update the host region on node accounts from its parent fund account(parent can be either virtual corp account or another node account)
    if (mapFunctionalityNameTriggerExecution.containskey('Core_MDF_UpdateHostRegionOnNodeAcc') &&
        mapFunctionalityNameTriggerExecution.get('Core_MDF_UpdateHostRegionOnNodeAcc').Core_Active__c
    ) {
      //Core_AccountHandler.updateHostRegionOnNodeAccounts((List<Account>)Trigger.New);
      Core_AccountTriggerHandlerController.processCCPTriggerUpdates((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.newMap,(Map<Id, Account>) Trigger.oldMap,'before insert');
    }
  
  
    if(!accountTriggerExecution.isEmpty() && accountTriggerExecution.containsKey(contractName)) {
        Set<String> triggerExecutionClassNames = accountTriggerExecution.get(
            contractName
        );
        for (String className : triggerExecutionClassNames) {
            if (className != null) {
                triggerExecutionClassType = Type.forName(className);
                if (triggerExecutionClassType == null) {
                    continue;
                } else {
                    UCD_ACM_ServiceContracts.IBeforeInsertAccountTrigger beforeInsertTriggerExecution = (UCD_ACM_ServiceContracts.IBeforeInsertAccountTrigger) triggerExecutionClassType.newInstance();
                    beforeInsertTriggerExecution.execute((List<Account>) Trigger.New);
                }
            }
        }
    }
  }
  public override void beforeUpdate() {
    String contractName = 'IBeforeUpdateAccountTrigger';
    system.debug('Inside acc trigger handler before update');
    
    //Call the Account Dup Check method to update the Record Type field mapping from UCD_ACM_AccountHandler
    if ( mapFunctionalityNameTriggerExecution.containsKey('accountDupCheck') &&
        mapFunctionalityNameTriggerExecution.get('accountDupCheck').Core_Active__c
    ) {
        Core_AccountTriggerHandlerController.accountRecordTypeDupFieldUpdate(Trigger.new);
    }
  
    //Call the method to populate both Geo & Sub Geo fields using the Country State Reference object
    if ( mapFunctionalityNameTriggerExecution.containsKey('accountObjectBeforeHandler' ) &&
        mapFunctionalityNameTriggerExecution.get('accountObjectBeforeHandler').Core_Active__c
    ) {
        Core_AccountTriggerHandlerController.accountObjectBeforeHandler((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.NewMap,(Map<Id, Account>) Trigger.OldMap);
    }
  
    //US901870: KIIT Reduce Account validation rule - analysis
    if ( mapFunctionalityNameTriggerExecution.containsKey('ValidateTierValues') &&
        mapFunctionalityNameTriggerExecution.get('ValidateTierValues').Core_Active__c
    ) {
        Core_AccountTriggerHandlerController.validateTierValues(Trigger.New);
    }
  
    //[Mar/07/2016 : Calling the method which would restrict the Users to change the Partner->Customer/Customer->Partner Account.]
    if (!Test.isRunningTest()) {
        Core_IPS_Account_Trigger_Handler.restrictManageExternalAccount((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }
  
    // 3/28/17 DH: code added to prevent A&E User account ownership
    if (mapFunctionalityNameTriggerExecution.containsKey('accountPreventAEUserOwnership') &&
        mapFunctionalityNameTriggerExecution.get('accountPreventAEUserOwnership').Core_Active__c
    ) {
        Core_AccountTriggerHandlerController.preventAEUserAccountOwnership((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }
  
    // 12/14/2016 Method to send out BoxB Account Outbound Message
    Core_AccountTriggerHandlerController.preventUncoveredAccountChange((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
  
    if (!Test.isRunningTest()) {
        Core_ContactEntitlementValidation.validateAccountEnglishOnlyFields((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
        Core_Entitlement_Outbound_Integrations.generateBoxBAccountOutboundMessage((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }
  
    //Set IPA integration status to pending - IPA integration
    //Added by Anand TB - US607581
    if (mapFunctionalityNameTriggerExecution.containsKey('Account_Update_IPA_Integration_Trigger') &&
        mapFunctionalityNameTriggerExecution.get('Account_Update_IPA_Integration_Trigger').Core_Active__c &&
      !Test.isRunningTest()
    ) {
      //system.enqueueJob(new PRM_SalesCloudAccountIntStatus_Handler((List<Account>)triggerNew, (Map<Id,Account>)triggerOldMap, (Set<Id>)triggerNewMap.keySet()));
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPendingOnUpdate((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap,(Set<Id>) Trigger.NewMap.keySet());
    }
  
    if (mapFunctionalityNameTriggerExecution.containsKey('preventUncoveredAccountChange') && mapFunctionalityNameTriggerExecution.get('preventUncoveredAccountChange').Core_Active__c
    ) {
        Core_AccountTriggerHandlerController.preventUncoveredAccountChangeOnOppStatus((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }
  
    //To validate the co-marketing Account's Parent Fund Account changes
    if (mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ValidatePFAChange') && 
      mapFunctionalityNameTriggerExecution.get('Core_MDF_ValidatePFAChange').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.validateMDFParentFundAccChanges((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }
  
    if ( mapFunctionalityNameTriggerExecution.containskey('Core_MDF_IPA_Account_Region_Check') &&
        mapFunctionalityNameTriggerExecution.get('Core_MDF_IPA_Account_Region_Check').Core_Active__c
    ) {
      //Core_AccountHandler.restrictHostRegionUpdateOnNodeAccounts((Map<Id,Account>)Trigger.NewMap, (Map<Id,Account>)Trigger.OldMap);
        Core_AccountTriggerHandlerController.processCCPTriggerUpdates((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.newMap,(Map<Id, Account>) Trigger.oldMap,'before update');
    }
  

    if(!accountTriggerExecution.isEmpty() && accountTriggerExecution.containsKey(contractName)) {
      Set<String> triggerExecutionClassNames = accountTriggerExecution.get(
        contractName
      );
      for (String className : triggerExecutionClassNames) {
        if (className != null) {
          triggerExecutionClassType = Type.forName(className);
  
          if (triggerExecutionClassType == null) {
            continue;
          } else {
            UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger beforeUpdateTriggerExecution = (UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger) triggerExecutionClassType.newInstance();
            beforeUpdateTriggerExecution.execute(
              (Map<Id, Account>) Trigger.OldMap,
              (Map<Id, Account>) Trigger.NewMap
            );
          }
        }
      }
    }
  }
  
  public override void beforeDelete() {
  }
  
  public override void afterInsert() {
    String contractName = 'IAfterInsertAccountTrigger';
    UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
  
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
    if ( mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_createGroupForAccountNode') &&
       mapFunctionalityNameTriggerExecution.get('Core_MDF_createGroupForAccountNode').Core_Active__c
    ) {
      accountToBeSharedList = Core_AccountTriggerHandlerController.createGroupForComarketingAccount(Trigger.New);
    }
  
    //To call Batch process for Account and Budget Sharing
    if (mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ShareAccountsWithGroups') &&
        mapFunctionalityNameTriggerExecution.get('Core_MDF_ShareAccountsWithGroups').Core_Active__c
    ) {
        Core_AccountTriggerHandlerController.sharingWithNewAcctGrps(accountToBeSharedList);
    }
  
    if (mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_Account_node_share') &&
        mapFunctionalityNameTriggerExecution.get('Core_MDF_Account_node_share').Core_Active__c
    ) {
      if (!Core_MDF_Utility.byPassFeature('Bypass_External_Group_Creation')) {
          Core_AccountTriggerHandlerController.createNodeSharingGroup((Map<Id, Account>) Trigger.NewMap);
      }
    }
  
    if (mapFunctionalityNameTriggerExecution.containsKey('UpdatePrimaryDirectAccount') &&
        mapFunctionalityNameTriggerExecution.get('UpdatePrimaryDirectAccount').Core_Active__c &&
      !Test.isRunningTest()
    ) {
      Core_DirectAccount_Handler.UpdatePrimaryAcc(Trigger.New);
    }
  
    //[Abhishek Arya : Mar/16/2016 : User Story# US36728 : ECB Marked Accounts Needs to Deactivate all IPS Contacts.]
    if (!Test.isRunningTest()) {
      Core_IPS_Account_Trigger_Handler.UpdateContactOnECBCheck(Trigger.New,null);
    }
  
    /*
      * description : for publishing Account
      * params : Trigger.New
      * return : NA
      * author and date :ankit1x.sharma@intel.com, 10/11/2022
      */
    if (mapFunctionalityNameTriggerExecution.containsKey('UCD_ACM_PublishAccount') &&
        mapFunctionalityNameTriggerExecution.get('UCD_ACM_PublishAccount').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.publishAccount(Trigger.new);
    }
    if (mapFunctionalityNameTriggerExecution.containsKey('PRM_CreateTrackerMilestones') &&
      mapFunctionalityNameTriggerExecution.get('PRM_CreateTrackerMilestones').Core_Active__c &&
      !Test.isRunningTest()
    ) {
      Core_IPS_Account_Trigger_Handler.createTrackerMilestonesForBadgeTierUpdate((List<Account>) Trigger.New,null);
    }
  
    if(!accountTriggerExecution.isEmpty() && accountTriggerExecution.containsKey(contractName)) {
      set<String>  triggerExecutionClassNames = accountTriggerExecution.get(contractName);
      for (String className : triggerExecutionClassNames) {
        if (className != null) {
          triggerExecutionClassType = Type.forName(className);
  
          if (triggerExecutionClassType == null) {
            continue;
          } else {
            UCD_ACM_ServiceContracts.IAfterInsertAccountTrigger afterInsertTriggerExecution = (UCD_ACM_ServiceContracts.IAfterInsertAccountTrigger) triggerExecutionClassType.newInstance();
            afterInsertTriggerExecution.execute(
              unitwork,
              (Map<Id, Account>) Trigger.OldMap,
              (Map<Id, Account>) Trigger.NewMap
            );
          }
        }
      }
      unitwork.commitWork();
    }
  }
  public override void afterUpdate() {	
    String contractName = 'IAfterUpdateAccountTrigger';
    UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
    if (runonce) {
      runonce = false;
    }
  
    if (mapFunctionalityNameTriggerExecution.containsKey('UpdatePrimaryDirectAccount') &&
        mapFunctionalityNameTriggerExecution.get('UpdatePrimaryDirectAccount').Core_Active__c &&
      !Test.isRunningTest()
    ) {
      Core_DirectAccount_Handler.UpdatePrimaryAccAsBlank((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
  
      Core_DirectAccount_Handler.UpdatePrimaryAccOnIntelRec((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }
  
    if (!Test.isRunningTest()) {
      Core_IPS_Account_Trigger_Handler.assignEntitlementToIPSAccount((Map<Id, Account>) Trigger.OldMap,(List<Account>) Trigger.New);
      Core_IPS_Account_Trigger_Handler.revokeAccess((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
      Core_IPS_Account_Trigger_Handler.grantAccess((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }
  
    // added by Javid - Agate as part of TWC729 - 1886
    if (mapFunctionalityNameTriggerExecution.containsKey('CIMIDStampCheck') &&
        mapFunctionalityNameTriggerExecution.get('CIMIDStampCheck').Core_Active__c &&
        Core_IPS_Account_Trigger_Handler.isFirstRunCheck &&
      !Test.isRunningTest()
    ) {
      Core_IPS_Account_Trigger_Handler.isFirstRunCheck = false;
      Core_IPS_Account_Trigger_Handler.CIMIdStamped((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }
  
    Core_AccountTriggerHandlerController.accountRecordTypeAfterUpdate((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap,(Map<Id, Account>) Trigger.NewMap);
  
    if (!Test.isRunningTest()) {
      //TWC729-3627
      //[Abhishek Arya : Mar/16/2016 : User Story# US36728 : ECB Marked Accounts Needs to Deactivate all IPS Contacts.]
      Core_IPS_Account_Trigger_Handler.UpdateContactOnECBCheck((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }
    //David S Wong: Jun 3 2016: US35541 ACCOUNTS: Automate Account Team Membership Audit
    Core_AccountTriggerHandlerController.accountTeamAuditCompletion((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
  
    // Zay Montalbo 2/10/2017 Change account english only name
    if (!Test.isRunningTest()) {
      // Zay Montalbo 1/31/2017 CIM Update on Account generate ERPM OBM
      Core_Entitlement_Outbound_Integrations.generateOBMOnCIMUpdate((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }
  
    //To validate the co-marketing Account's Parent Fund Account changes
    if (mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ValidatePFAChangeOnAftrUpdt') &&
        mapFunctionalityNameTriggerExecution.get('Core_MDF_ValidatePFAChangeOnAftrUpdt').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.validateAccountHierarchy((List<Account>) Trigger.new,(Map<Id, Account>) Trigger.oldMap);
    }
  
    // Uday 5/5/2019 US351963 - Populate all the MP fields from Account to its Company Information object.
    if (mapFunctionalityNameTriggerExecution.containsKey('Update_MP_Partners') &&
        mapFunctionalityNameTriggerExecution.get('Update_MP_Partners').Core_Active__c &&
      !Test.isRunningTest()
    ) {
      // Commented the below - As part of OPID Restructure - Sathish
      // Core_AccountHandler.updatePartnerInfo(trigger.New,trigger.NewMap,trigger.OldMap);
      //Added by Kirshna Ch - US854868 -KTBE : Changes in Biz org, Specialty
      PMP_AccountHandler.updatePartnerInfo((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.NewMap,(Map<Id, Account>) Trigger.OldMap);
    }
  
    /********************* Raushan US369121 - Update Membership flag when partner type is being changed.***************/
    if (mapFunctionalityNameTriggerExecution.containsKey('accountPartnerTypeAfterUpate') &&
        mapFunctionalityNameTriggerExecution.get('accountPartnerTypeAfterUpate').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.membershipFlagUpdate((List<Account>) Trigger.Old,(List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap,(Map<Id, Account>) Trigger.NewMap);
    }
  
    //Rahul Added for US759847
    if (mapFunctionalityNameTriggerExecution.containsKey('Roll_up_account') &&
        mapFunctionalityNameTriggerExecution.get('Roll_up_account').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.invokeRollUpScenario((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
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
      
  
    if (mapFunctionalityNameTriggerExecution.containsKey('PRM_CreateTrackerMilestones') &&
        mapFunctionalityNameTriggerExecution.get('PRM_CreateTrackerMilestones').Core_Active__c &&
      !Test.isRunningTest()
    ) {
      Core_IPS_Account_Trigger_Handler.createTrackerMilestonesForBadgeTierUpdate((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap
      );
    }
    /*Description: on Update Account Name call psg method which will update same in license record
  author and date:dnyanadax.argulwar@intel.com ,23Nov    
  */
    if (mapFunctionalityNameTriggerExecution.containsKey('accountDetailsUpdateOnPsgMethod') &&
        mapFunctionalityNameTriggerExecution.get('accountDetailsUpdateOnPsgMethod').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.sendAccountDetailsToPsgMethods((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }
  
    // This method will be called when a host region is changed on the virtual corp  and the same should be stamped on its child accounts
    if (mapFunctionalityNameTriggerExecution.containskey('Core_MDF_UpdateHostRegionAfterVCUpdate') && 
        mapFunctionalityNameTriggerExecution.get('Core_MDF_UpdateHostRegionAfterVCUpdate').Core_Active__c
    ) {
      //Core_AccountHandler.updateHostRegionAfterVirtualCorpUpdate((List<Account>)Trigger.New, (Map<Id,Account>)Trigger.OldMap);
      Core_AccountTriggerHandlerController.processCCPTriggerUpdates((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.newMap,(Map<Id, Account>) Trigger.oldMap,'after update');
    }
        
   
   if(!accountTriggerExecution.isEmpty() && accountTriggerExecution.containsKey(contractName)) {
      Set<String> triggerExecutionClassNames = accountTriggerExecution.get(
        contractName
      );
      for (String className : triggerExecutionClassNames) {
        if (className != null) {
          triggerExecutionClassType = Type.forName(className);
  
          if (triggerExecutionClassType == null) {
            String message =
              'Could not load class - ' +
              className +
              '. Class not found';
            continue;
          } else {
            UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger afterUpdateTriggerExecution = (UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger) triggerExecutionClassType.newInstance();
            afterUpdateTriggerExecution.execute(
              unitwork,
              (Map<Id, Account>) Trigger.OldMap,
              (Map<Id, Account>) Trigger.NewMap
            );
          }
        }
      }
      unitwork.commitWork();
    }
  }
  
  public override void afterDelete() {
    if (mapFunctionalityNameTriggerExecution.containsKey('accountObjectAfterDelete') &&
      mapFunctionalityNameTriggerExecution.get('accountObjectAfterDelete').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.accountObjectAfterDelete((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.NewMap,(List<Account>) Trigger.Old,(Map<Id, Account>) Trigger.OldMap);
    }
  }
  public override void afterUndelete() {
  }
  
  private Map<String, Set<String>> getAccountTriggerExecution() {
    Map<String, Set<String>> accountTriggerExecution = new Map<String, Set<String>>();
  
    for (Core_AccountTriggerExecution__mdt data : [
      SELECT Interface_Name__c, Apex_Class_Name__c
      FROM Core_AccountTriggerExecution__mdt
      WHERE IsActive__c = TRUE
      ORDER BY Execution_Order__c ASC
    ]) {
      if (accountTriggerExecution.get(data.Interface_Name__c) == null) {
        Set<String> classNames = new Set<String>();
        classNames.add(data.Apex_Class_Name__c);
  
        accountTriggerExecution.put(data.Interface_Name__c, classNames);
      } else {
        Set<String> classNames = accountTriggerExecution.get(
          data.Interface_Name__c
        );
        classNames.add(data.Apex_Class_Name__c);
      }
    }
  
    return accountTriggerExecution;
  }
  }