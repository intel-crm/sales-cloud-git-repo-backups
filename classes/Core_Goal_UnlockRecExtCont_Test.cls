/****************************************************************************************************
Apex Class Name : Core_Goal_UnlockRecExtCont_Test
Version         : 1.0 
Created Date    : 12/11/2017
Function        : Test class for Core_Goal_UnlockRecExtController
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ashwin Dash                12/11/2017              Original Version
*****************************************************************************************************/
@isTest
public class Core_Goal_UnlockRecExtCont_Test{
    public static List<Opportunity> opptyList = new List<Opportunity>();
    public static List<Core_Goal__c> goalList = new List<Core_Goal__c>();
    
    static void setupData(){
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
        Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA', Core_Sales_Groups__c = 'CCG Sales Group',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
        insert acct;
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;  
        opptyList.add(new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usr.Id, Core_Sales_Group__c='Global Accounts',Core_Commissionable__c ='Yes', Core_Opportunity_Type__c='Design: Original', Core_Product_Segment__c='Embedded - Drones', Core_Product_Application__c = 'Drone', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Board', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8)));
        opptyList.add(new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,
            AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usr.Id, Core_Sales_Group__c='Regional Sales',Core_Solution_Area__c='IOTG All Deal $', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Embedded - Drones', Core_Product_Application__c = 'Drone', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Board', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8)));    
        opptyList.add(new Opportunity(Name = 'Test Opportunity3', RecordTypeId = newOppRecTypeId,
            AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usr.Id, Core_Sales_Group__c='Regional Sales',Core_Solution_Area__c='IOTG All Deal $', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Embedded - Drones', Core_Product_Application__c = 'Drone', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Board', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8)));    
        insert opptyList;
        
              
        System.runAs(Core_Test_Utility.systemAdminUser){            
            goalList.add(new Core_Goal__c(Core_Goal_Name__c = 'Test Goal Win1', Core_Goal_Category__c = 'Assigned', Core_Goal_BU_Focus_Area__c = 'DCG Compute Deal $', Core_Goal_Criteria__c = 'Drive Data Center compute technology with priority workloads and solutions into end user markets.'));
            goalList.add(new Core_Goal__c(Core_Goal_Name__c = 'Test Goal Win2', Core_Goal_Category__c = 'Assigned', Core_Goal_BU_Focus_Area__c = 'DCG Compute Deal $', Core_Goal_Criteria__c = 'Drive Data Center compute technology with priority workloads and solutions into end user markets.', Core_Goal_Status__c= 'Accepted'));
            goalList.add(new Core_Goal__c(Core_Goal_Name__c = 'Test Goal Win3', Core_Goal_Category__c = 'Assigned', Core_Goal_BU_Focus_Area__c = 'DCG Compute Deal $', Core_Goal_Criteria__c = 'Drive Data Center compute technology with priority workloads and solutions into end user markets.', Core_Goal_Status__c= 'Accepted'));
            goalList.add(new Core_Goal__c(Core_Goal_Name__c = 'Test Goal Win4', Core_Goal_Category__c = 'Assigned', Core_Goal_BU_Focus_Area__c = 'DCG Compute Deal $', Core_Goal_Criteria__c = 'Drive Data Center compute technology with priority workloads and solutions into end user markets.', Core_Goal_Status__c= 'Accepted',Core_Goal_Owner__c = UserInfo.getUserId()));
            insert goalList;    
     
            //update opptyList;
            
        }
        
    }
    
    static testMethod void unlockGoal_Test1(){
        
        setupData();        
        PageReference pageRef = Page.Core_Goal_UnlockRecord;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(goalList[0]);
        ApexPages.currentPage().getParameters().put('id', goalList[0].Id);
        Core_Goal_UnlockRecExtController cont = new Core_Goal_UnlockRecExtController(sc);
        cont.onLoad();
        cont.unlockGoal();
    }
    
    static testMethod void unlockGoal_Test2(){
        setupData();        
        goalList[1].Core_Goal_Status__c = 'Approved';
        update goalList[1];
        PageReference pageRef = Page.Core_Goal_UnlockRecord;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(goalList[1]);
        ApexPages.currentPage().getParameters().put('id', goalList[1].Id);
        Core_Goal_UnlockRecExtController cont = new Core_Goal_UnlockRecExtController(sc);
        Test.startTest();  
        cont.onLoad();      
        cont.unlockGoal();
        Test.stopTest();
    }
    
    static testMethod void unlockGoal_Test3(){
        setupData();        
        goalList[2].Core_Goal_Status__c = 'Approved';
        goalList[2].Core_Goal_Approver__c = UserInfo.getUserId();
        update goalList[2];
        PageReference pageRef = Page.Core_Goal_UnlockRecord;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(goalList[2]);
        ApexPages.currentPage().getParameters().put('id', goalList[2].Id);
        Core_Goal_UnlockRecExtController cont = new Core_Goal_UnlockRecExtController(sc);
        Test.startTest();
        cont.onLoad();      
        cont.unlockGoal();
        cont.backToGoal();
        Test.stopTest();
    }
    
    static testMethod void unlockGoal_Test4(){
        setupData();        
        PageReference pageRef = Page.Core_Goal_UnlockRecord;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(goalList[0]);
        Core_Goal_UnlockRecExtController cont = new Core_Goal_UnlockRecExtController(sc);
        
    }
    
}