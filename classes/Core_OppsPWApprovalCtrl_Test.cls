/****************************************************************************************************
Apex Class Name : Core_OppsPWApprovalCtrl_Test
Version         : 1.0 
Created Date    : 23 Feb,2023
Function        : Test class for Core_OppsPWApprovalCtrl
Modifications:

*****************************************************************************************************/
@isTest
public class Core_OppsPWApprovalCtrl_Test {
    static List<Account> accountList;
    static Opportunity opp1;
    
    @testSetup
    static void setupTest() {
        User sysUser = [select id from User where Profile.name='System Administrator' and isActive=true limit 1];
        system.runAs(sysUser)
        {
            Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
            triggerExecList.Bypass__c = true;
            insert triggerExecList;
            accountList = Core_Test_Utility.createAccount(1);
            accountList[0].Name = 'Dell';
            accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
            accountList[0].core_2023_Sales_Group__c = 'Americas US Sales Group';
            accountList[0].Core_Sales_Group_Preview__c = 'Americas US Sales Group';
            accountList[0].Industry = 'Agriculture';
            accountList[0].Core_Sub_Industry__c = 'Forestry';
            //accountList[0].Core_Approved_Account__c =TRUE;
            accountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            //accountList[0].Core_CIM_ID__c  = '123';
            insert accountList;
            
            // Set the field values with test data
        Opportunity__c salesGroupCtrl = new Opportunity__c();
        salesGroupCtrl.Name = 'salesGroupCtrl';
        salesGroupCtrl.Core_Start_Date__c = system.today();
        salesGroupCtrl.Core_End_Date__c = system.today();
        salesGroupCtrl.Core_Field_API_name__c = 'Core_Sales_Group_Preview__c';
        
        // Insert the custom setting record
        insert salesGroupCtrl;
        
        }
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(1);
        TestDDRlst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert TestDDRlst;
        
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(2);
        Id oppDesignID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        opp1 = listOpportunity[1];    
        opp1.AccountId = accountList[0].Id;
        opp1.Core_Commissionable__c='Yes';
        opp1.RecordTypeId = oppDesignID;
        opp1.StageName = 'Qualify';     
        opp1.Core_Opportunity_Type__c='Design: Original';
        opp1.Core_Solution_Area__c = 'CCG Commercial Deal $';
        opp1.Core_Lead_Conversion_Flag__c = false;
        opp1.Core_Intel_Platform__c ='ALDER LAKE D';
        opp1.Core_First_Customer_Ship_Date__c = date.newInstance(2022, 08, 07);
        opp1.Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.id;
        System.runAs(Core_Test_Utility.systemAdminUser){
            insert opp1;
        }
        Opportunity opp2 = new Opportunity(Name = 'PCC', RecordTypeId = oppDesignID,
                                           AccountId = accountList[0].Id, OwnerId= UserInfo.getUserId(), Core_Design_Registration_Id__c =TestDDRlst[0].id,
                                           Core_Opportunity_Type__c='Design: Original', Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity',
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_First_Customer_Ship_Date__c = System.Date.today().addYears(1));
        System.runAs(Core_Test_Utility.systemAdminUser){
            insert opp2;
        }
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=opp1.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;
        
        List<Core_CRM_Labels__c> CRMLabels = new List<Core_CRM_Labels__c>();        

        CRMLabels.add(new Core_CRM_Labels__c(
            name = 'Core_OpportunityPartnerProgram',
            value__c = 'Partner-Led Opportunity'
        ));
        CRMLabels.add(new Core_CRM_Labels__c(
            name = 'CRM_Opportunity_Design_RecordType',
            value__c = 'Core_Design_Opportunity'
        ));
         CRMLabels.add(new Core_CRM_Labels__c(
            name = 'Core_PW_ApprovalSubmissionRestrict',
            value__c = 'true'
        ));
        
        CRMLabels.add(new Core_CRM_Labels__c(
            name = 'AccountSalesGroupError',
            value__c = 'The 2H 2024 Submission Window has closed and you cannot submit this Opportunity for approval.'
        ));
        
        
        
        insert CRMLabels;
        
         Profile p = [select Id from Profile where Name = 'IT Admin'];
        
        User fseowner = new User(Alias = 'fseOwner', Email='fseOwner@apttus.com',
                               EmailEncodingKey='UTF-8', LastName='TTest', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = p.Id,
                               TimeZoneSidKey='America/Los_Angeles', UserName='FSE@mail.com', Department='OSC', Core_User_Geo__c = 'PRC');
        insert fseowner;
        List<OpportunityTeamMember> oppTMList = new List<OpportunityTeamMember>();
        /*OpportunityTeamMember teamMember1 = new OpportunityTeamMember(OpportunityId=opp2.Id, UserId=sysUser.Id, Core_Production_Win_Member_Role__c='Sales Account Manager');
        
        oppTMList.add(teamMember1);
        insert oppTMList;*/
    }
    
    static testMethod void validatechecks1(){
        try{
            Opportunity opp = [select id,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c from opportunity where name like '%Test%' limit 1];
            OpportunityLineItem oli = [select id, core_status__c, Core_Write_In_Product_Flag__c from OpportunityLineItem where opportunityid = :opp.id];
            account acc = [select id,Core_Business_Party_Id__c , Core_Export_Compliance_Block__c,Core_Export_Compliance_Block_Reason__c from account where Name = 'Dell'];
            acc.Core_Business_Party_Id__c  = '123';
            update acc;
            opp.StageName = 'Lost';
            opp.Core_Loss_Cancel_Details__c = 'test';
            opp.Core_Loss_Cancel_Reason__c = 'Cancelled - Authority';
            update opp;
            system.assertEquals(opp<>null,true);
            Core_OppsPWApprovalCtrl.checklistForApproval(opp.id,'comments',true);
            Core_OppsPWApprovalCtrl.submitApproval(opp.id,'comments');
        }catch(Exception ex){
            System.assertNotEquals(null, ex);
            System.assert(false, 'Exception occurred in test: ' + ex.getMessage());
        }
    }
    
    static testMethod void submitTest(){
        try{
            Opportunity opp = [select id,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c from opportunity where name like '%Test%' limit 1];
            OpportunityLineItem oli = [select id, core_status__c, Core_Write_In_Product_Flag__c from OpportunityLineItem where opportunityid = :opp.id];
            account acc = [select id,Core_Business_Party_Id__c , Core_Export_Compliance_Block__c,Core_Export_Compliance_Block_Reason__c from account where Name = 'Dell'];
            acc.Core_Business_Party_Id__c  = '123';
            oli.Core_At_Risk__c = false;
            update oli;
            Test.startTest();
            system.assertEquals(opp<>null,true);
            Core_OppsPWApprovalCtrl.submitApproval(opp.id,'comments');
        }catch(Exception ex){
            System.assertNotEquals(null, ex);
        }
        Test.stopTest();
        
    }
    static testMethod void checkDesignOpp(){
        User sysUser = [select id,name from User where Profile.name='System Administrator' and isActive=true limit 1];
        system.assertEquals(sysUser<>null,true);
        system.runAs(sysUser)
        {
            Opportunity opp = [select id,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c from opportunity where Core_Opportunity_Type__c='Design: Original' limit 1];
            opp.Core_Manufacturing_Geo__c = '';
            opp.Core_Production_End_Date__c = null;
            opp.Core_Volume__c = null;
            update opp;
            OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId=opp.Id, UserId=sysUser.Id, Core_Production_Win_Member_Role__c = 'Viewer (0%)');
            insert otm;
            Test.startTest();
            Core_OppsPWApprovalCtrl.checklistForApproval(opp.id,'comments',true);
            Test.stopTest();
        }              
    }
    static testMethod void checkPCCDesignOpp(){
        User sysUser = [select id,name from User where Profile.name='System Administrator' and isActive=true limit 1];
        system.assertEquals(sysUser<>null,true);
        system.runAs(sysUser)
        {
            Opportunity opp = [select id,accountid from opportunity where Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity' limit 1];            
            Test.startTest();
            Core_OppsPWApprovalCtrl.checklistForApproval(opp.id,'comments',true);
            try{
                Core_OppsPWApprovalCtrl.submitApproval(null,'comments');
            }catch(Exception ex){
                System.assertNotEquals(null, ex);
                return;
            }
            Test.stopTest();
        }  
    }
    static testMethod void checkFSEUser(){
        User sysUser = [select id,name from User where Profile.name='System Administrator' and isActive=true limit 1];
        system.assertEquals(sysUser<>null,true);
        
        Opportunity opp = [select id,accountid from opportunity where Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity' limit 1]; 
        system.runAs(sysUser)
        {
            Test.startTest();
            OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId=opp.Id, UserId=sysUser.Id, Core_Production_Win_Member_Role__c='Sales Account Manager');
            insert otm;
            Core_OppsPWApprovalCtrl.checklistForApproval(opp.id,'comments',true);
            try{
                Core_OppsPWApprovalCtrl.submitApproval(null,'comments');
            }catch(Exception ex){
                System.assertNotEquals(null, ex);
                return;
            }
            Test.stopTest();
        }  
    }
   /* static testMethod void testErrorHandling(){
        Map<String, List<String>> errMsgMap = new Map<String, List<String>>();
        Boolean isPCCDesignHigh = true;
        Boolean userCheckforPCCDesSub = true;
        Boolean userCheckFSE = false;
        user sysAdmUser = Core_Test_Utility.systemAdminUser;
        List<User> users = new List<User>();
        Profile p = [select Id from Profile where Name = 'IT Admin'];
        users.add(new User(UserName='test.user1.testOppApproverByManager@intel.com.crm', LastName='User 1', Email='test.user1@intel.com',
        Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ManagerId = sysAdmUser.id,
        ProfileId=p.Id, LanguageLocaleKey='en_US'));
        insert users;

        OpportunityTeamMember teamMember1 = new OpportunityTeamMember(OpportunityId = opp1.Id, UserId = users[0].Id,    TeamMemberRole = 'Sales Account Manager');
         insert teamMember1;
         OpportunityTeamMember otm = [select id, UserId from OpportunityTeamMember where Core_Production_Win_Member_Role__c='Sales Account Manager'];
        Opportunity opp = [select id,accountid from opportunity where Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity' limit 1];
        Test.startTest();
        Core_OppsPWApprovalCtrl.checklistForApproval(opp.id,'comments',true);
        Test.stopTest();

    }*/
    static testMethod void checkPW_QuantitySalesPriceValidation(){
        Opportunity opp = [select id,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c from opportunity where name like '%Test%' limit 1];
        OpportunityLineItem oli = [select id, core_status__c, Core_Write_In_Product_Flag__c,Core_PW_Quantity__c from OpportunityLineItem where opportunityid = :opp.id];
        opp.Core_Manufacturing_Geo__c = '';
        opp.Core_Production_End_Date__c = null;
        opp.Core_Volume__c = null;
        opp.Core_Approval_Status__c = 'Approved';
        opp.StageName='Design Win';
        update opp;
        //Update Opportunity LineItem PW quantity and sales price to null.
        User sysUser = [select id from User where Profile.name='System Administrator' and isActive=true limit 1];
        system.assertEquals(sysUser<>null,true);       
        system.runAs(sysUser)
        {
            oli.core_status__c='Win Approved';
            Update oli;
            oli.Core_PW_Quantity__c =2;
            oli.Core_PW_Sales_Price__c=null;
            Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
            triggerExecList.Bypass__c = true;
            triggerExecList.SetupOwnerId=sysUser.Id;
            insert triggerExecList;
            Update oli;
            Test.startTest();
            Core_OppsPWApprovalCtrl.checklistForApproval(opp.id,'comments',true);
            opp.StageName='Lost';
            update opp;
            Core_OppsPWApprovalCtrl.checklistForApproval(opp.id,'test',true);
            oli.Core_PW_Sales_Price__c=0;
            update oli;
            Core_OppsPWApprovalCtrl.checklistForApproval(opp.id,'test',true);
            try{
                Core_OppsPWApprovalCtrl.checklistForApproval(null,null,true);
                Core_OppsPWApprovalCtrl.submitApproval(null,'comments');
            }
            catch(exception e){
                System.assertNotEquals(null, e);
            }
            
            Test.stopTest();
        }
    }
}