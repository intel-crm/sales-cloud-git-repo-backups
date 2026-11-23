public without sharing class Core_AccountTriggerHandler extends TriggerHandler {
  Map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
  Map<String, Set<String>> accountTriggerExecution = getAccountTriggerExecution();
  public static  List<Core_AccountTriggerExecution__mdt> triggerExecutionData = null;
  static boolean isAccountNumberInsertCalled = false;
  static boolean isAccountNumberUpdateCalled = false;
  Type triggerExecutionClassType;

  
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
  
      if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_AccountOnBeforeInsert') && 
         mapFunctionalityNameTriggerExecution.get('Core_MDF_AccountOnBeforeInsert').Core_Active__c) 
      {
          Core_MDF_AccountServiceHandler.processCCPTriggerUpdates((List<Account>)Trigger.New, (Map<Id, Account>) Trigger.newMap, (Map<Id, Account>) Trigger.oldMap, 'before insert');
      }
    
  
    //US901870: KIIT Reduce Account validation rule - analysis
    if (mapFunctionalityNameTriggerExecution.containsKey('ValidateTierValues') &&
        mapFunctionalityNameTriggerExecution.get('ValidateTierValues').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.validateTierValues(Trigger.New);
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
       }
  
    //Set IPA integration status to pending - IPA integration
    //Added by Anand TB - US607581
    if (mapFunctionalityNameTriggerExecution.containsKey('Account_Update_IPA_Integration_Trigger') &&
        mapFunctionalityNameTriggerExecution.get('Account_Update_IPA_Integration_Trigger').Core_Active__c &&
        !Test.isRunningTest()
      
    ) {
        PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPendingOnUpdate((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap,(Set<Id>) Trigger.NewMap.keySet());
    }
  
    if (mapFunctionalityNameTriggerExecution.containsKey('preventUncoveredAccountChange') && mapFunctionalityNameTriggerExecution.get('preventUncoveredAccountChange').Core_Active__c
    ) {
        Core_AccountTriggerHandlerController.preventUncoveredAccountChangeOnOppStatus((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }
  
      if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_AccountOnBeforeUpdate') && 
               mapFunctionalityNameTriggerExecution.get('Core_MDF_AccountOnBeforeUpdate').Core_Active__c) 
            {
                Core_MDF_AccountServiceHandler.processCCPTriggerUpdates((List<Account>)Trigger.New, (Map<Id, Account>) Trigger.newMap, (Map<Id, Account>) Trigger.oldMap, 'before update');
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
    if (!Test.isRunningTest()){
      UCD_ACM_AccountMerge.beforeDeleteAccountMerge(Trigger.old);
    }
   // ACM_BU_DeleteDuplicateChnlMembership.getChildChnlMembership(Trigger.old);
  }
  
  public override void afterInsert() {
    String contractName = 'IAfterInsertAccountTrigger';
    UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
  

      if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_AccountOnAfterInsert') && 
         mapFunctionalityNameTriggerExecution.get('Core_MDF_AccountOnAfterInsert').Core_Active__c) 
      {
          Core_MDF_AccountServiceHandler.processCCPTriggerUpdates((List<Account>)Trigger.New, (Map<Id, Account>) Trigger.newMap, (Map<Id, Account>) Trigger.oldMap, 'after insert');
      }
    

  
    if (mapFunctionalityNameTriggerExecution.containsKey('UpdatePrimaryDirectAccount') &&
        mapFunctionalityNameTriggerExecution.get('UpdatePrimaryDirectAccount').Core_Active__c &&
      !Test.isRunningTest()
    ) {
      Core_DirectAccount_Handler.UpdatePrimaryAcc(Trigger.New);
    }
  
    //[Abhishek Arya : Mar/16/2016 : User Story# US36728 : ECB Marked Accounts Needs to Deactivate all IPS Contacts.]
    /*if (!Test.isRunningTest()) {//IPS logic code commented-gangadhar-begin //US-0050009 Hercules_IPS_ECBFlagIssueFix
      Core_IPS_Account_Trigger_Handler.UpdateContactOnECBCheck(Trigger.New,null);
    }*/
  

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
  
    /*if (!Test.isRunningTest()) {//IPS logic code commented-gangadhar //US-0050009 Hercules_IPS_ECBFlagIssueFix
      //TWC729-3627
      //[Abhishek Arya : Mar/16/2016 : User Story# US36728 : ECB Marked Accounts Needs to Deactivate all IPS Contacts.]
      Core_IPS_Account_Trigger_Handler.UpdateContactOnECBCheck((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }*/
    //David S Wong: Jun 3 2016: US35541 ACCOUNTS: Automate Account Team Membership Audit
    Core_AccountTriggerHandlerController.accountTeamAuditCompletion((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
  
    // Zay Montalbo 2/10/2017 Change account english only name
    if (!Test.isRunningTest()) {
      // Zay Montalbo 1/31/2017 CIM Update on Account generate ERPM OBM
      Core_Entitlement_Outbound_Integrations.generateOBMOnCIMUpdate((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    }
      if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_AccountOnAfterUpdate') && 
         mapFunctionalityNameTriggerExecution.get('Core_MDF_AccountOnAfterUpdate').Core_Active__c) 
      {
          Core_MDF_AccountServiceHandler.processCCPTriggerUpdates((List<Account>)Trigger.New, (Map<Id, Account>) Trigger.newMap, (Map<Id, Account>) Trigger.oldMap, 'after update');
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
    /*if (mapFunctionalityNameTriggerExecution.containsKey('accountPartnerTypeAfterUpate') &&
        mapFunctionalityNameTriggerExecution.get('accountPartnerTypeAfterUpate').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.membershipFlagUpdate((List<Account>) Trigger.Old,(List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap,(Map<Id, Account>) Trigger.NewMap);
    }*/
  
    //Rahul Added for US759847
    if (mapFunctionalityNameTriggerExecution.containsKey('Roll_up_account') &&
        mapFunctionalityNameTriggerExecution.get('Roll_up_account').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.invokeRollUpScenario((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
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
    // if (mapFunctionalityNameTriggerExecution.containsKey('accountDetailsUpdateOnPsgMethod') &&
    //     mapFunctionalityNameTriggerExecution.get('accountDetailsUpdateOnPsgMethod').Core_Active__c
    // ) {
    //   Core_AccountTriggerHandlerController.sendAccountDetailsToPsgMethods((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.OldMap);
    // }
  

   
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
   
      system.debug('newacc'+(List<Account>) Trigger.New);
      list<account> accListNew=(List<Account>) Trigger.New;
      for (Account acc : accListNew) {
           system.debug('(Account) Trigger.oldMap.get(acc.Id)'+(Account) Trigger.oldMap.get(acc.Id));
           Account oldAcc = (Account) Trigger.oldMap.get(acc.Id);
          system.debug('oldAcc.ParentId'+oldAcc.ParentId);
           system.debug('acc.ParentId'+acc.ParentId);
      }
      //update deal flag when parent account is changed
  /*    Map<Id, Account> parentAccountMap = new Map<Id, Account>();
	list<account> accListNew=(List<Account>) Trigger.New;
for (Account acc : accListNew) {
    Account oldAcc = (Account) Trigger.oldMap.get(acc.Id);

    if (acc.ParentId != oldAcc.ParentId && acc.recordtype.name=='Intel Account') {

        if (oldAcc.ParentId != null) {
            parentAccountMap.put(
                oldAcc.ParentId,
                new Account(
                    Id = oldAcc.ParentId,
                    PRM_Impartner_Deal_Sync__c = false
                )
            );
            system.debug(oldAcc.ParentId+'oldAcc.ParentId');
        }

        if (acc.ParentId != null) {
            parentAccountMap.put(
                acc.ParentId,
                new Account(
                    Id = acc.ParentId,
                    PRM_Impartner_Deal_Sync__c = true
                )
            );
              system.debug(acc.ParentId+'acc.ParentId');
        }
    }
}

if (!parentAccountMap.isEmpty()) {
    system.debug(parentAccountMap.values()+'acctstoupdate');
    update parentAccountMap?.values();
}*/

  }
  
  public override void afterDelete() {
    if (mapFunctionalityNameTriggerExecution.containsKey('accountObjectAfterDelete') &&
      mapFunctionalityNameTriggerExecution.get('accountObjectAfterDelete').Core_Active__c
    ) {
      Core_AccountTriggerHandlerController.accountObjectAfterDelete((List<Account>) Trigger.New,(Map<Id, Account>) Trigger.NewMap,(List<Account>) Trigger.Old,(Map<Id, Account>) Trigger.OldMap);
    }
    //ACM_BU_DeleteDuplicateChnlMembership.delteDupChnlMembership(Trigger.old);
    if (!Test.isRunningTest()){
      UCD_ACM_AccountMerge.afterDeleteAccountMerge(Trigger.old);
    }
  }
  public override void afterUndelete() {
  }
  
  private Map<String, Set<String>> getAccountTriggerExecution() {
    Map<String, Set<String>> accountTriggerExecution = new Map<String, Set<String>>();
  
    if(triggerExecutionData == null){
      triggerExecutionData = new List<Core_AccountTriggerExecution__mdt>([
        SELECT Interface_Name__c, Apex_Class_Name__c,Execution_Order__c
        FROM Core_AccountTriggerExecution__mdt
        WHERE IsActive__c = TRUE
        ORDER BY Execution_Order__c ASC
      ]);
    }
    for (Core_AccountTriggerExecution__mdt data : triggerExecutionData) {
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