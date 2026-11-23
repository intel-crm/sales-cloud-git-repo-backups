/******************************************************************************************************************************************
Class Name  : Core_SM_redirectApprovalProcessExtension_Test 
Version     : 1.0 
Created Date: 3rd July, 2015
Function    : Test class for Extension controller of Core_SM_redirectApprovalProcess page contains logic for submitting the Milestone record for approval if the submitter is the Owner of the record.
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Ashwin Dash      7/3/2017      Original Version
*****************************************************************************************************************************************/
@isTest
public class Core_SM_redirectApprovalProcessExt_Test {

    public static List<Opportunity> opptyList = new List<Opportunity>();
    public static List<Core_Solution_Milestone__c> milestoneList= new List<Core_Solution_Milestone__c>();
    public static List<User> usrList = new List<User>();
    public static User sysUser = new User();
    
    static void setupData(){
        opptyList.clear();
        milestoneList.clear();
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;        
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        //usrList.add(Core_Test_Utility.systemAdminUser);
        Profile p = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr1 = [SELECT id, Name, isActive FROM User WHERE ProfileId = :p.Id AND isActive = true and ManagerId != '' LIMIT 1];
        usrList.add(usr1);
        System.runAs(usrList[0]){
            Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                           BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                           BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
            insert acct;
            opptyList.add(new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usrList[0].Id, Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Mobile', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));           
            insert opptyList;
            milestoneList.add(new Core_Solution_Milestone__c(Core_Milestone_Focus_Area__c = 'Deal CCG', Core_Opportunity__c = opptyList[0].id, Core_Milestone_Focus__c = 'New Form Factor Adoption', Core_Milestone__c='Deployment / Delivery', Core_Use_Case__c='NUCs', Core_Status__c='Pending', Core_Milestone_Date__c=System.Today(), Core_Milestone_Description__c='test', Core_As_Measured_By__c='test', Core_Results_Key_Learnings__c='test'));
            milestoneList.add(new Core_Solution_Milestone__c(Core_Milestone_Focus_Area__c = 'Deal CCG', Core_Opportunity__c = opptyList[0].id, Core_Milestone_Focus__c = 'New Form Factor Adoption', Core_Milestone__c='Deployment / Delivery', Core_Use_Case__c='NUCs', Core_Status__c='Pending', Core_Milestone_Date__c=System.Today(), Core_Milestone_Description__c='test', Core_As_Measured_By__c='test'));
            milestoneList.add(new Core_Solution_Milestone__c(Core_Milestone_Focus_Area__c = 'Deal CCG', Core_Opportunity__c = opptyList[0].id, Core_Milestone_Focus__c = 'New Form Factor Adoption', Core_Milestone__c='Deployment / Delivery', Core_Use_Case__c='NUCs', Core_Status__c='Pending', Core_Milestone_Date__c=System.Today(), Core_Milestone_Description__c='test', Core_As_Measured_By__c='test', Core_Results_Key_Learnings__c='test'));
            milestoneList.add(new Core_Solution_Milestone__c(Core_Milestone_Focus_Area__c = 'Deal CCG', Core_Opportunity__c = opptyList[0].id, Core_Milestone_Focus__c = 'New Form Factor Adoption', Core_Milestone__c='Deployment / Delivery', Core_Use_Case__c='NUCs', Core_Status__c='Pending', Core_Milestone_Date__c=System.Today(), Core_Milestone_Description__c='test', Core_As_Measured_By__c='test', Core_Results_Key_Learnings__c='test'));
            insert milestoneList;
        }  
        sysUser = Core_Test_Utility.systemAdminUser;
        System.runAs(sysUser){
            Account acct1 = new Account(Name = 'Test Account territory1', BillingStreet = '123 Fake St1',RecordTypeId = newAccountRecTypeId,
                                           BillingCity = 'Springfield1', BillingState = 'NY', BillingCountry = 'USA',
                                           BillingPostalCode = '122451', Core_CIM_ID__c = '8675308');
            insert acct1;
            opptyList.add(new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId, AccountId = acct1.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usrList[0].Id, Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Mobile', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));           
            upsert opptyList;
            milestoneList.add(new Core_Solution_Milestone__c(Core_Milestone_Focus_Area__c = 'Deal CCG', Core_Opportunity__c = opptyList[0].id, Core_Milestone_Focus__c = 'New Form Factor Adoption', Core_Milestone__c='Deployment / Delivery', Core_Use_Case__c='NUCs', Core_Status__c='Pending', Core_Milestone_Date__c=System.Today(), Core_Milestone_Description__c='test', Core_As_Measured_By__c='test', Core_Results_Key_Learnings__c='test'));
            upsert milestoneList;
        }  
    }
    
    //Positive Testing - submitting the record for approval
    static testMethod void checkSubmitterEqualOwner1(){
        setupData();
        PageReference pageRef = Page.Core_SM_redirectApprovalProcess;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', milestoneList[0].id);
        ApexPages.StandardController sc = new ApexPages.StandardController(milestoneList[0]);
        Core_SM_redirectApprovalProcessExtension controller = new Core_SM_redirectApprovalProcessExtension(sc);
        Test.startTest();
        controller.checkSubmitterEqualOwner();  
        System.runAs(usrList[0]){
            controller.checkSubmitterEqualOwner();  
        }
        Test.stopTest();
    }
    //Negative Testing - Checking error when Manager is not there on User while submitting the record
    static testMethod void checkSubmitterEqualOwner2(){
        setupData();
        PageReference pageRef = Page.Core_SM_redirectApprovalProcess;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', milestoneList[4].id);
        ApexPages.StandardController sc = new ApexPages.StandardController(milestoneList[4]);
        Core_SM_redirectApprovalProcessExtension controller = new Core_SM_redirectApprovalProcessExtension(sc);
        Test.startTest();
        controller.checkSubmitterEqualOwner();  
        System.runAs(sysUser){
            controller.checkSubmitterEqualOwner();  
        }   
        Test.stopTest();
    }
    //Catch Exception - after submitting unlocking the record and again submitting to test already submitted record
    static testMethod void checkSubmitterEqualOwner3(){
        setupData();
        PageReference pageRef = Page.Core_SM_redirectApprovalProcess;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', milestoneList[3].id);
        ApexPages.StandardController sc = new ApexPages.StandardController(milestoneList[3]);
        Core_SM_redirectApprovalProcessExtension controller = new Core_SM_redirectApprovalProcessExtension(sc);
        Test.startTest();
        controller.checkSubmitterEqualOwner();  
        System.runAs(usrList[0]){
            controller.checkSubmitterEqualOwner();  
        }   
        Approval.UnlockResult unlockedRersult = Approval.unlock(milestoneList[0]);
        System.runAs(usrList[0]){
            controller.checkSubmitterEqualOwner();  
        } 
        Test.stopTest();
    }
    //Negative Testing - Checking error when Core_Results_Key_Learnings__c is not there while submitting the record
    static testMethod void checkSubmitterEqualOwner4(){
        setupData();
        PageReference pageRef = Page.Core_SM_redirectApprovalProcess;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', milestoneList[1].id);
        ApexPages.StandardController sc = new ApexPages.StandardController(milestoneList[1]);
        Core_SM_redirectApprovalProcessExtension controller = new Core_SM_redirectApprovalProcessExtension(sc);
        Test.startTest();
        controller.checkSubmitterEqualOwner();  
        System.runAs(usrList[0]){
            controller.checkSubmitterEqualOwner();  
        }
        Test.stopTest();
    }
    //Negative Testing - Checking if record is already submitted and locked.
    static testMethod void checkSubmitterEqualOwner5(){
        setupData();
        PageReference pageRef = Page.Core_SM_redirectApprovalProcess;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', milestoneList[2].id);
        ApexPages.StandardController sc = new ApexPages.StandardController(milestoneList[2]);
        Core_SM_redirectApprovalProcessExtension controller = new Core_SM_redirectApprovalProcessExtension(sc);
        Test.startTest();
        controller.checkSubmitterEqualOwner();  
        System.runAs(usrList[0]){
            controller.checkSubmitterEqualOwner();  
            controller.checkSubmitterEqualOwner(); 
        }
        Test.stopTest();
    }
}