/**************************************************************************************
Apex Class Name: Core_DelegateApproverOppShare_Test
Version     : 1.0 
Created Date: 24 AUG 2022
Function    : Test Class for the Core_DelegateApproverOppShare
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Megha Kumari             24/08/20222              Original Version               
*************************************************************************************/
@isTest
public class Core_DelegateApproverOppShare_Test {
    @testSetup
    static void setupTest() {
     List < Core_Trigger_Executions__c > lstTriggerExecution = new List < Core_Trigger_Executions__c > ();

        Core_Trigger_Executions__c opportunityTechnicalOwnerUpdate = new Core_Trigger_Executions__c();
        opportunityTechnicalOwnerUpdate.name = 'opportunityTechnicalOwnerUpdate';
        opportunityTechnicalOwnerUpdate.Core_Object__c = 'Opportunity';
        opportunityTechnicalOwnerUpdate.Core_Active__c = TRUE;
        opportunityTechnicalOwnerUpdate.Core_Trigger_Events__c = 'After insert';
        opportunityTechnicalOwnerUpdate.Core_Description__c = 'This is test description';
        opportunityTechnicalOwnerUpdate.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(opportunityTechnicalOwnerUpdate);

        Core_Trigger_Executions__c opportunityNameDuplicateCheck = new Core_Trigger_Executions__c();
        opportunityNameDuplicateCheck.name = 'opportunityNameDuplicateCheck';
        opportunityNameDuplicateCheck.Core_Object__c = 'Opportunity';
        opportunityNameDuplicateCheck.Core_Active__c = TRUE;
        opportunityNameDuplicateCheck.Core_Trigger_Events__c = 'After insert';
        opportunityNameDuplicateCheck.Core_Description__c = 'This is test description';
        opportunityNameDuplicateCheck.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(opportunityNameDuplicateCheck);

        Core_Trigger_Executions__c opportunityOppFactDelete = new Core_Trigger_Executions__c();
        opportunityOppFactDelete.name = 'opportunityOppFactDelete';
        opportunityOppFactDelete.Core_Object__c = 'Opportunity';
        opportunityOppFactDelete.Core_Active__c = TRUE;
        opportunityOppFactDelete.Core_Trigger_Events__c = 'After insert';
        opportunityOppFactDelete.Core_Description__c = 'This is test description';
        opportunityOppFactDelete.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(opportunityOppFactDelete);
        
        Core_Trigger_Executions__c OpportunityKPIJSON = new Core_Trigger_Executions__c();
        OpportunityKPIJSON.name = 'OpportunityKPIJSON';
        OpportunityKPIJSON.Core_Object__c = 'Opportunity';
        OpportunityKPIJSON.Core_Active__c = TRUE;
        OpportunityKPIJSON.Core_Trigger_Events__c = 'After insert,After Update';
        OpportunityKPIJSON.Core_Description__c = 'This is test description';
        OpportunityKPIJSON.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(OpportunityKPIJSON);
        
        Core_Trigger_Executions__c OpportunityDelegate = new Core_Trigger_Executions__c();
        OpportunityDelegate.name = 'delegateApproverRoleChange';
        OpportunityDelegate.Core_Object__c = 'Opportunity';
        OpportunityDelegate.Core_Active__c = TRUE;
        OpportunityDelegate.Core_Trigger_Events__c = 'After insert,After Update';
        OpportunityDelegate.Core_Description__c = 'This is test description';
        OpportunityDelegate.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(OpportunityDelegate);
        
        Core_Trigger_Executions__c UpdateTerritoryInfoOnOppty = new Core_Trigger_Executions__c();
        UpdateTerritoryInfoOnOppty.name = 'UpdateTerritoryInfoOnOppty';
        UpdateTerritoryInfoOnOppty.Core_Object__c = 'Core_OpportunityHandler';
        UpdateTerritoryInfoOnOppty.Core_Active__c = TRUE;
        UpdateTerritoryInfoOnOppty.Core_Trigger_Events__c = 'After insert,After Update';
        UpdateTerritoryInfoOnOppty.Core_Description__c = 'This is test description';
        UpdateTerritoryInfoOnOppty.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(UpdateTerritoryInfoOnOppty);
        
        Core_Trigger_Executions__c RestrictSolutionDetailLOV = new Core_Trigger_Executions__c();
        RestrictSolutionDetailLOV.name = 'RestrictSolutionDetailLOV';
        RestrictSolutionDetailLOV.Core_Object__c = 'Core_OpportunityHandler';
        RestrictSolutionDetailLOV.Core_Active__c = TRUE;
        RestrictSolutionDetailLOV.Core_Trigger_Events__c = 'After insert,After Update';
        RestrictSolutionDetailLOV.Core_Description__c = 'This is test description';
        RestrictSolutionDetailLOV.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(RestrictSolutionDetailLOV);
        
        Core_Trigger_Executions__c CombineSolutionDetailFields = new Core_Trigger_Executions__c();
        CombineSolutionDetailFields.name = 'CombineSolutionDetailFields';
        CombineSolutionDetailFields.Core_Object__c = 'Core_OpportunityHandler';
        CombineSolutionDetailFields.Core_Active__c = TRUE;
        CombineSolutionDetailFields.Core_Trigger_Events__c = 'After insert,After Update';
        CombineSolutionDetailFields.Core_Description__c = 'This is test description';
        CombineSolutionDetailFields.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(CombineSolutionDetailFields);
        
        Core_Trigger_Executions__c RestrictSolutionAreaInactiveLOV = new Core_Trigger_Executions__c();
        RestrictSolutionAreaInactiveLOV.name = 'RestrictSolutionAreaInactiveLOV';
        RestrictSolutionAreaInactiveLOV.Core_Object__c = 'Core_OpportunityHandler';
        RestrictSolutionAreaInactiveLOV.Core_Active__c = TRUE;
        RestrictSolutionAreaInactiveLOV.Core_Trigger_Events__c = 'After insert,After Update';
        RestrictSolutionAreaInactiveLOV.Core_Description__c = 'This is test description';
        RestrictSolutionAreaInactiveLOV.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(RestrictSolutionAreaInactiveLOV);
        
        Core_Trigger_Executions__c BlockExistingOppOnLeadConversion = new Core_Trigger_Executions__c();
        BlockExistingOppOnLeadConversion.name = 'BlockExistingOppOnLeadConversion';
        BlockExistingOppOnLeadConversion.Core_Object__c = 'Core_OpportunityHandler';
        BlockExistingOppOnLeadConversion.Core_Active__c = TRUE;
        BlockExistingOppOnLeadConversion.Core_Trigger_Events__c = 'After insert,After Update';
        BlockExistingOppOnLeadConversion.Core_Description__c = 'This is test description';
        BlockExistingOppOnLeadConversion.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(BlockExistingOppOnLeadConversion);
        
        Core_Trigger_Executions__c determineApprovers = new Core_Trigger_Executions__c();
        determineApprovers.name = 'determineApprovers';
        determineApprovers.Core_Object__c = 'Core_OpportunityHandler';
        determineApprovers.Core_Active__c = TRUE;
        determineApprovers.Core_Trigger_Events__c = 'After insert,After Update';
        determineApprovers.Core_Description__c = 'This is test description';
        determineApprovers.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(determineApprovers);
        
        Core_Trigger_Executions__c updateProductLineItems = new Core_Trigger_Executions__c();
        updateProductLineItems.name = 'updateProductLineItems';
        updateProductLineItems.Core_Object__c = 'Core_OpportunityHandler';
        updateProductLineItems.Core_Active__c = TRUE;
        updateProductLineItems.Core_Trigger_Events__c = 'After insert,After Update';
        updateProductLineItems.Core_Description__c = 'This is test description';
        updateProductLineItems.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(updateProductLineItems);
        
        Core_Trigger_Executions__c userGeoUpdate = new Core_Trigger_Executions__c();
        userGeoUpdate.name = 'userGeoUpdate';
        userGeoUpdate.Core_Object__c = 'Core_UserHandler';
        userGeoUpdate.Core_Active__c = TRUE;
        userGeoUpdate.Core_Trigger_Events__c = 'After insert,After Update';
        userGeoUpdate.Core_Description__c = 'This is test description';
        userGeoUpdate.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(userGeoUpdate);
        
        Core_Trigger_Executions__c assignLanguage = new Core_Trigger_Executions__c();
        assignLanguage.name = 'assignLanguage';
        assignLanguage.Core_Object__c = 'Core_UserHandler';
        assignLanguage.Core_Active__c = TRUE;
        assignLanguage.Core_Trigger_Events__c = 'After insert,After Update';
        assignLanguage.Core_Description__c = 'This is test description';
        assignLanguage.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(assignLanguage);
        
        Core_Trigger_Executions__c userFreezeUnfreeze = new Core_Trigger_Executions__c();
        userFreezeUnfreeze.name = 'userFreezeUnfreeze';
        userFreezeUnfreeze.Core_Object__c = 'Core_UserHandler';
        userFreezeUnfreeze.Core_Active__c = TRUE;
        userFreezeUnfreeze.Core_Trigger_Events__c = 'After insert,After Update';
        userFreezeUnfreeze.Core_Description__c = 'This is test description';
        userFreezeUnfreeze.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(userFreezeUnfreeze);
        
        Core_Trigger_Executions__c createFeed = new Core_Trigger_Executions__c();
        createFeed.name = 'createFeed';
        createFeed.Core_Object__c = 'Core_UserHandler';
        createFeed.Core_Active__c = TRUE;
        createFeed.Core_Trigger_Events__c = 'After insert,After Update';
        createFeed.Core_Description__c = 'This is test description';
        createFeed.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(createFeed);
        
        Core_Trigger_Executions__c userEmployeeTypeGroupAssignment = new Core_Trigger_Executions__c();
        userEmployeeTypeGroupAssignment.name = 'userEmployeeTypeGroupAssignment';
        userEmployeeTypeGroupAssignment.Core_Object__c = 'Core_UserHandler';
        userEmployeeTypeGroupAssignment.Core_Active__c = TRUE;
        userEmployeeTypeGroupAssignment.Core_Trigger_Events__c = 'After insert,After Update';
        userEmployeeTypeGroupAssignment.Core_Description__c = 'This is test description';
        userEmployeeTypeGroupAssignment.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(userEmployeeTypeGroupAssignment);
        
         
        Core_Trigger_Executions__c userProfileGroupAssignment = new Core_Trigger_Executions__c();
        userProfileGroupAssignment.name = 'userProfileGroupAssignment';
        userProfileGroupAssignment.Core_Object__c = 'Core_UserHandler';
        userProfileGroupAssignment.Core_Active__c = TRUE;
        userProfileGroupAssignment.Core_Trigger_Events__c = 'After insert,After Update';
        userProfileGroupAssignment.Core_Description__c = 'This is test description';
        userProfileGroupAssignment.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(userProfileGroupAssignment);
        
        Core_Trigger_Executions__c updateAGSInactiveOnUserDeactivation = new Core_Trigger_Executions__c();
        updateAGSInactiveOnUserDeactivation.name = 'updateAGSInactiveOnUserDeactivation';
        updateAGSInactiveOnUserDeactivation.Core_Object__c = 'Core_UserHandler';
        updateAGSInactiveOnUserDeactivation.Core_Active__c = TRUE;
        updateAGSInactiveOnUserDeactivation.Core_Trigger_Events__c = 'After insert,After Update';
        updateAGSInactiveOnUserDeactivation.Core_Description__c = 'This is test description';
        updateAGSInactiveOnUserDeactivation.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(updateAGSInactiveOnUserDeactivation);
        
        Core_Trigger_Executions__c opportunityStageUpdate = new Core_Trigger_Executions__c();
        opportunityStageUpdate.name = 'opportunityStageUpdate';
        opportunityStageUpdate.Core_Object__c = 'Core_OpportunityHandler';
        opportunityStageUpdate.Core_Active__c = TRUE;
        opportunityStageUpdate.Core_Trigger_Events__c = 'After insert,After Update';
        opportunityStageUpdate.Core_Description__c = 'This is test description';
        opportunityStageUpdate.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(opportunityStageUpdate);
        
        Core_Trigger_Executions__c updateActivityLineItems = new Core_Trigger_Executions__c();
        updateActivityLineItems.name = 'updateActivityLineItems';
        updateActivityLineItems.Core_Object__c = 'Core_OpportunityHandler';
        updateActivityLineItems.Core_Active__c = TRUE;
        updateActivityLineItems.Core_Trigger_Events__c = 'After insert,After Update';
        updateActivityLineItems.Core_Description__c = 'This is test description';
        updateActivityLineItems.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(updateActivityLineItems);
        
        Core_Trigger_Executions__c POPCheckOnUpdate = new Core_Trigger_Executions__c();
        POPCheckOnUpdate.name = 'POPCheckOnUpdate';
        POPCheckOnUpdate.Core_Object__c = 'POPCheckOnUpdate';
        POPCheckOnUpdate.Core_Active__c = TRUE;
        POPCheckOnUpdate.Core_Trigger_Events__c = 'After insert,After Update';
        POPCheckOnUpdate.Core_Description__c = 'This is test description';
        POPCheckOnUpdate.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(POPCheckOnUpdate);
        
        Core_Trigger_Executions__c Tech_CIMID_Validation = new Core_Trigger_Executions__c();
        Tech_CIMID_Validation.name = 'Tech_CIMID_Validation';
        Tech_CIMID_Validation.Core_Object__c = 'Core_OpportunityHandler';
        Tech_CIMID_Validation.Core_Active__c = TRUE;
        Tech_CIMID_Validation.Core_Trigger_Events__c = 'After insert,After Update';
        Tech_CIMID_Validation.Core_Description__c = 'This is test description';
        Tech_CIMID_Validation.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(Tech_CIMID_Validation);
         Core_Trigger_Executions__c TriggerExecutions = new Core_Trigger_Executions__c();
        TriggerExecutions.Name = 'goalAddCommissionableTxns';
        TriggerExecutions.Core_Object__c = 'Descriptive Feature';
        TriggerExecutions.Core_Trigger_Events__c = 'After insert After update';
        TriggerExecutions.Core_Active__c = false;
        TriggerExecutions.Core_Description__c = 'This is test description';
        TriggerExecutions.Core_Class_Name__c = 'Test Class';  
        lstTriggerExecution.add(TriggerExecutions);
        
        
        Core_Trigger_Executions__c TriggerExecutions1 = new Core_Trigger_Executions__c();
        TriggerExecutions1.Name = 'beforeGoalUpdateAcptDate';
        TriggerExecutions1.Core_Object__c = 'Core_Goal';
        TriggerExecutions1.Core_Trigger_Events__c = 'Before Insert Before Update';
        TriggerExecutions1.Core_Active__c = true;
        TriggerExecutions1.Core_Description__c = 'This is test description1';
        TriggerExecutions1.Core_Class_Name__c = 'Test Class1'; 
        lstTriggerExecution.add(TriggerExecutions1);
        
         Core_Trigger_Executions__c TriggerExecutions2 = new Core_Trigger_Executions__c();
        TriggerExecutions2.Name = 'UpdateKPIRevenueAndAchievedOnDWG';
        TriggerExecutions2.Core_Object__c = 'Descriptive Feature1';
        TriggerExecutions2.Core_Trigger_Events__c = 'Before Update';
        TriggerExecutions2.Core_Active__c = true;
        TriggerExecutions2.Core_Description__c = 'This is test description1';
        TriggerExecutions2.Core_Class_Name__c = 'Test Class1'; 
        lstTriggerExecution.add(TriggerExecutions2);
        
        Core_Trigger_Executions__c TriggerExecutions3 = new Core_Trigger_Executions__c();
        TriggerExecutions3.Name = 'beforeDWGUpdateStatusCheck';
        TriggerExecutions3.Core_Object__c = 'Core_Goal';
        TriggerExecutions3.Core_Trigger_Events__c = 'Before Update';
        TriggerExecutions3.Core_Active__c = true;
        TriggerExecutions3.Core_Description__c = 'This is test description1';
        TriggerExecutions3.Core_Class_Name__c = 'Test Class1'; 
        lstTriggerExecution.add(TriggerExecutions3);
        
        Core_Trigger_Executions__c TriggerExecutions4 = new Core_Trigger_Executions__c();
        TriggerExecutions4.Name = 'UpdateKPIRevenueOnDWG';
        TriggerExecutions4.Core_Object__c = 'Core_Goal';
        TriggerExecutions4.Core_Trigger_Events__c = 'Before Update';
        TriggerExecutions4.Core_Active__c = true;
        TriggerExecutions4.Core_Description__c = 'This is test description1';
        TriggerExecutions4.Core_Class_Name__c = 'Test Class1'; 
        lstTriggerExecution.add(TriggerExecutions4);
        
       /* if(sendNotifyMethod){
            lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='updateKPIFieldsonMatch',Core_Object__c='Core_GoalHandler',Core_Trigger_Events__c='before update, before insert',Core_Active__c=true,Core_Description__c='removesplcharacters',Core_Class_Name__c='Core_GoalHandler'));
            Core_KPI_FullRefresh_Check__c fullRefreshSetting = new Core_KPI_FullRefresh_Check__c();
            fullRefreshSetting.IsFullRefresh__c = false;
            insert fullRefreshSetting;
        }*/
                        
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='restrictInactivePicklist',Core_Object__c='Core_GoalHandler',Core_Trigger_Events__c='before update',Core_Active__c=true,Core_Description__c='Update for Goal',Core_Class_Name__c='Core_GoalHandler'));
        
        insert lstTriggerExecution;

    }
    @isTest
    public static void opportunityShare_test(){
        Test.startTest();
        String sLastName = 'User1';
        String sAlias = 'tuser1';
        String sEmail = 'test.user1@intel.com';
        String sUserName = 'test.user1@intel.com.crm.testclass';
        String sProfileName = 'Standard User';
        String userRole='00Eo0000000f9elEAA';
        
        String sLastName1 = 'User2';
        String sAlias1 = 'tuser2';
        String sEmail1 = 'test.user2@intel.com';
        String sUserName1 = 'test.user2@intel.com.crm.testclass';
        String sProfileName1 = 'Standard User';
        String userRole1='00Eo0000000f9evEAA';
        
        String sLastName2 = 'User3';
        String sAlias2 = 'tuser3';
        String sEmail2 = 'test.user3@intel.com';
        String sUserName2 = 'test.user3@intel.com.crm.testclass';
        String sProfileName2 = 'Standard User';
        String userRole2='00Eo0000000f9elEAA';
        
        Id profileId;
        List<Profile> lstProfiles = null;
        
        // Get the Id of the Standard Profile             
        lstProfiles = [SELECT Id FROM Profile WHERE Name = :sProfileName LIMIT 1];
        if (lstProfiles.size() == 0)
            profileId = null;
        else
            profileId = lstProfiles[0].Id;
        //List<User> userList= new List<User>();
        User testUser = new User(LastName = sLastName, Alias = sAlias, Email = sEmail, UserName = sUserName, ProfileId = profileId,UserRoleId=userRole,
                                 EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert testUser;
        User testUser2 = new User(LastName = sLastName2, Alias = sAlias2, Email = sEmail2, UserName = sUserName2, ProfileId = profileId,UserRoleId=userRole2,
                                  EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert testUser2;}
        Account acct = new Account(Name = 'Test Account 08-24-2022', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', /*Core_CIM_ID__c = '8675309',*/Core_Sales_Groups__c='Americas Brazil Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity oppForLoss = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                                 AccountId = acct.Id,Core_Approval_Status__c ='Submitted',
                                                 StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1),Core_Approver_1__c=testUser.Id,
                                                 Core_Approver_2__c=testUser.Id,Core_Approver_3__c=testUser.Id,Core_Approver_4__c=testUser.Id,Core_Approver_5__c=testUser.Id);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForLoss;
        }
        
        User testUser1 = new User(LastName = sLastName1, Alias = sAlias1, Email = sEmail1, UserName = sUserName1, ProfileId = profileId,UserRoleId=userRole1,
                                  EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        
        insert testUser1;
        
        Core_Goal__c goal1 = new Core_Goal__c();
         goal1.Name = 'testGoal';
        //goal1.Core_Goal_Name__c = 'testGoal';
        goal1.Core_Goal_BU_Focus_Area__c ='CCG Commercial Deal Revenue $';
        goal1.Core_Goal_Category__c = 'Assigned';
        goal1.Core_Goal_Status__c = 'Approved';
        goal1.Core_Goal_Criteria__c ='Drive Deal Wins focused on Application Acceleration.';
        goal1.Core_Goal_Claim_Date__c = System.Today();
        goal1.Core_Opportunity__c = oppForLoss.Id;
        goal1.Core_MatchOppKPI_Backend__c = 'KPI Achieved';
        //goal.OwnerId = lstUser.get(0).Id;
        goal1.Core_Goal_Approver__c=testUser.Id;
        goal1.Core_Goal_Owner__c=testUser2.Id;
         System.runAs(Core_Test_Utility.systemAdminUser) {
             insert goal1;}
        
        opportunityShare oppShare=new opportunityShare();
        oppShare.OpportunityId= oppForLoss.Id;
        oppShare.UserOrGroupId = testUser1.Id;
        oppShare.OpportunityAccessLevel= 'Edit';
        oppShare.RowCause = Schema.opportunityShare.RowCause.Manual;
        Database.SaveResult delegateResults=DataBase.insert(oppShare,false);
        //userId.put(testUser1.id,testUser1.id);
       
       List<Core_Delegate_Approver__c> deleList= new List< Core_Delegate_Approver__c>();
               Core_Delegate_Approver__c dele=new Core_Delegate_Approver__c(Core_User__c=testUser1.id,Core_Opportunity_ID__c=delegateResults.getId()+',',Core_Manager__c=testUser.id,Core_Deal_win_Goal_Share_Id__c='ahks,agdhs');
               Core_Delegate_Approver__c dele1=new Core_Delegate_Approver__c(Core_User__c=testUser1.id,Core_Opportunity_ID__c='afdv'+'dasvc',Core_Manager__c=testUser2.id,Core_Active__c=true,Core_Deal_win_Goal_Share_Id__c='ahks,agdhs');
               deleList.add(dele);
               deleList.add(dele1);
               System.runAs(Core_Test_Utility.systemAdminUser) {
                   insert deleList;
               }
        
        testUser.DelegatedApproverId=testUser1.Id;
        update testUser;
        goal1.Core_Goal_Status__c = 'Submitted';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update goal1;}
        testUser.DelegatedApproverId=null;
        update testUser;
        
                
        
        Test.stopTest(); 
    }   
    @isTest
    public static void postOpportunityShare_test(){
        Test.startTest();
        String sLastName = 'User1';
        String sAlias = 'tuser1';
        String sEmail = 'test.user1@intel.com';
        String sUserName = 'test.user1@intel.com.crm.testclass';
        String sProfileName = 'Standard User';
        String userRole='00Eo0000000f9evEAA';
        
        String sLastName1 = 'User2';
        String sAlias1 = 'tuser2';
        String sEmail1 = 'test.user2@intel.com';
        String sUserName1 = 'test.user2@intel.com.crm.testclass';
        String sProfileName1 = 'Standard User';
        String userRole1='00Eo0000000f9elEAA';
        
        String sLastName2 = 'User3';
        String sAlias2 = 'tuser3';
        String sEmail2 = 'test.user3@intel.com';
        String sUserName2 = 'test.user3@intel.com.crm.testclass';
        String sProfileName2 = 'Standard User';
        String userRole2='00Eo0000000f9elEAA';
        
        Id profileId;
        List<Profile> lstProfiles = null;
        
        // Get the Id of the Standard Profile             
        lstProfiles = [SELECT Id FROM Profile WHERE Name = :sProfileName LIMIT 1];
        if (lstProfiles.size() == 0)
            profileId = null;
        else
            profileId = lstProfiles[0].Id;
        //List<User> userList= new List<User>();
        User testUser = new User(LastName = sLastName, Alias = sAlias, Email = sEmail, UserName = sUserName, ProfileId = profileId,UserRoleId=userRole,
                                 EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert testUser;
        User testUser1 = new User(LastName = sLastName1, Alias = sAlias1, Email = sEmail1, UserName = sUserName1, ProfileId = profileId,UserRoleId=userRole1,
                                  EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US',DelegatedApproverId = testUser.Id);
        
        insert testUser1;
        
         User testUser2 = new User(LastName = sLastName2, Alias = sAlias2, Email = sEmail2, UserName = sUserName2, ProfileId = profileId,UserRoleId=userRole2,
                                  EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US',ManagerId= testUser1.id);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert testUser2;}
        
        //testUser1.DelegatedApproverId=testUser.Id;
        //update testUser1;
        Account acct = new Account(Name = 'Test Account 08-24-2022', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', /*Core_CIM_ID__c = '8675309',*/Core_Sales_Groups__c='Americas Brazil Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity oppForLoss = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                                 AccountId = acct.Id,
                                                 StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1),	OwnerId=testUser2.id,
                                                 Core_Approval_Status__c='Not Submitted');
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForLoss;
        }
        
        
        Map<Id,opportunity> opp=new Map<Id,opportunity>();
        opp.put(testUser.Id,oppForLoss);
        Map<id,id> userId= new Map<Id,Id>();
        userId.put(testUser.id,testUser1.id);
        Core_Delegate_Approver__c dele=new Core_Delegate_Approver__c(Core_User__c=testUser.id,Core_Opportunity_ID__c='avnsd,achjsm',Core_Manager__c=testUser1.id);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert dele;
        }
        oppForLoss.Core_Approval_Status__c='Submitted';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update oppForLoss;}
        
        //database.executebatch(new Core_postOpportunityShareBatch (opp,oppShareId),50);
        
        Test.stopTest(); 
    }
    
    @isTest
    public static void postDealShare_test(){
        Test.startTest();
        String sLastName = 'User1';
        String sAlias = 'tuser1';
        String sEmail = 'test.user1@intel.com';
        String sUserName = 'test.user1@intel.com.crm.testclass';
        String sProfileName = 'Standard User';
        String userRole='00Eo0000000f9evEAA';
        
        String sLastName1 = 'User2';
        String sAlias1 = 'tuser2';
        String sEmail1 = 'test.user2@intel.com';
        String sUserName1 = 'test.user2@intel.com.crm.testclass';
        String sProfileName1 = 'Standard User';
        String userRole1='00Eo0000000f9elEAA';
        
        
        String sLastName2 = 'User3';
        String sAlias2 = 'tuser3';
        String sEmail2 = 'test.user3@intel.com';
        String sUserName2 = 'test.user3@intel.com.crm.testclass';
        String sProfileName2 = 'Standard User';
        String userRole2='00Eo0000000f9elEAA';
        
        Id profileId;
        List<Profile> lstProfiles = null;
        
        // Get the Id of the Standard Profile             
        lstProfiles = [SELECT Id FROM Profile WHERE Name = :sProfileName LIMIT 1];
        if (lstProfiles.size() == 0)
            profileId = null;
        else
            profileId = lstProfiles[0].Id;
        //List<User> userList= new List<User>();
        User testUser = new User(LastName = sLastName, Alias = sAlias, Email = sEmail, UserName = sUserName, ProfileId = profileId,UserRoleId=userRole,
                                 EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert testUser;
        User testUser1 = new User(LastName = sLastName1, Alias = sAlias1, Email = sEmail1, UserName = sUserName1, ProfileId = profileId,UserRoleId=userRole1,
                                  EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US',DelegatedApproverId = testUser.Id);
        
        insert testUser1;
        
         User testUser2 = new User(LastName = sLastName2, Alias = sAlias2, Email = sEmail2, UserName = sUserName2, ProfileId = profileId,UserRoleId=userRole2,
                                  EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US',ManagerId= testUser1.id);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert testUser2;}
        
         Account acct = new Account(Name = 'Test Account 08-24-2022', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345', /*Core_CIM_ID__c = '8675309',*/ Core_Sales_Groups__c='Americas Brazil Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Opportunity oppForLoss = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                                                 AccountId = acct.Id,
                                                 StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1),
                                                 Core_Approval_Status__c='Not Submitted');
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert oppForLoss;
        }
         Core_Goal__c goal1 = new Core_Goal__c();
         goal1.Name = 'testGoal';
        //goal1.Core_Goal_Name__c = 'testGoal';
        goal1.Core_Goal_BU_Focus_Area__c ='CCG Commercial Deal Revenue $';
        goal1.Core_Goal_Category__c = 'Assigned';
        goal1.Core_Goal_Status__c = 'Approved';
        goal1.Core_Goal_Criteria__c ='Drive Deal Wins focused on Application Acceleration.';
        goal1.Core_Goal_Claim_Date__c = System.Today();
        goal1.Core_Opportunity__c = oppForLoss.Id;
        goal1.Core_MatchOppKPI_Backend__c = 'KPI Achieved';
        //goal.OwnerId = lstUser.get(0).Id;
        goal1.Core_Goal_Approver__c=testUser1.Id;
        goal1.Core_Goal_Owner__c=testUser2.Id;
         System.runAs(Core_Test_Utility.systemAdminUser) {
             insert goal1;}
        List<Core_Delegate_Approver__c> deleList= new List< Core_Delegate_Approver__c>();
               Core_Delegate_Approver__c dele1=new Core_Delegate_Approver__c(Core_User__c=testUser.id,Core_Opportunity_ID__c='afdv'+'dasvc',Core_Manager__c=testUser1.id,Core_Active__c=true,Core_Deal_win_Goal_Share_Id__c='ahks,agdhs');
               
               deleList.add(dele1);
               System.runAs(Core_Test_Utility.systemAdminUser) {
                   insert deleList;
               }
        
        
        goal1.Core_Goal_Status__c = 'Submitted';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update goal1;}
        Test.stopTest(); 
    }
  
}