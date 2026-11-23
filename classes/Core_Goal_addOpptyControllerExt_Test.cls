/****************************************************************************************************
Apex Class Name : Core_Goal_addOpptyControllerExt_Test
Version         : 1.0 
Created Date    : 10/22/17
Function        : Test class for the Controller class for adding and removing Opportunities from Deal Win Goal
Modifications:
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Ashwin Dash                10/22/17                Original Version
*****************************************************************************************************/
@isTest
public class Core_Goal_addOpptyControllerExt_Test{
    
    public static List<Opportunity> opptyList = new List<Opportunity>();
    public static List<Core_Goal__c> goalList = new List<Core_Goal__c>();
    public static User sysAdmin = new User();
    public static User usr = new User();
    
    static void setupData(){       
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
        Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Core_Sales_Groups__c = 'CCG Sales Group',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
        insert acct;
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];
        sysAdmin = Core_Test_Utility.systemAdminUser;
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;  
        opptyList.add(new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
            AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usr.Id, Core_Sales_Group__c='Global Accounts',Core_Commissionable__c ='Yes', Core_Opportunity_Type__c='Design: Original', Core_Product_Segment__c='Drones', Core_Product_Application__c ='Drone - other', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Broadwell', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8)));
        opptyList.add(new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,
            AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usr.Id, Core_Sales_Group__c='Regional Sales',Core_Solution_Area__c='DCG - CoSP 5G', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Drones', Core_Product_Application__c ='Drone - other', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Broadwell', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8)));           
        insert opptyList;        
              
        System.runAs(sysAdmin){            
                        
        }
        System.runAs(usr){
            goalList.add(new Core_Goal__c(Core_Goal_Name__c = 'Test Goal Win',Core_Goal_Category__c = 'Assigned',Core_Goal_BU_Focus_Area__c ='DCG OPA Deal #',Core_Goal_Criteria__c ='Deliver next gen Intel® Omni-Path Fabric Deal Wins.'));
            insert goalList;
        }
        DWG_Opportunity__c dwg=new DWG_Opportunity__c();
        /*dwg.Core_DWG_Opportunity__c=opptyList[0].Id;
        dwg.Core_DWG_Deal_Win_Goal__c= goalList[0].Id;
        insert dwg;*/
    }
    static testMethod void TestMethod1(){
        setupData();
        test.startTest();
        PageReference pageRef = Page.Core_Goal_AddOppty;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', goalList[0].Id);
        Core_Goal_addOpptyControllerExt g = new Core_Goal_addOpptyControllerExt();
        test.stopTest();    
    }   
    
    /*static testMethod void TestMethod1(){
        setupData();
        test.startTest();
        PageReference pageRef = Page.Core_Goal_AddOppty;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', goalList[0].Id);
        Core_Goal_addOpptyControllerExt g = new Core_Goal_addOpptyControllerExt();
        g.getItems();
        g.getOperators();
        g.last();
        g.first();
        g.next();
        g.previous();
        g.toggleSort();
        g.queriedOppty[0].selected =true; 
        g.getSelected();        
        g.addOpptytoGoal();
        g.addOpptytoGoal();
        g.queriedOppty[0].selected =false;
        g.getSelected();
        goalList[0].Core_Goal_Opportunity_Identified__c = true;
        update goalList[0];
        g.addOpptytoGoal();
        g.clearTable();
        g.changeQuery();
        g.selOwnerFilter = 'My Opportunity Teams';
        g.changeQuery();
        g.selOwnerFilter = 'My Opportunities';
        g.changeQuery();
        pageReference p3 = g.cancelAdd();
        g.populateOpptyList();
        test.stopTest();    
    }   
    
    static testMethod void SearchMethodTest1(){
        setupData();
        test.startTest();
        PageReference pageRef = Page.Core_Goal_AddOppty;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', goalList[0].Id);
        Core_Goal_addOpptyControllerExt g = new Core_Goal_addOpptyControllerExt();
        g.searchMethod();
        g.selOpptyName = 'Test Opportunity1';
        g.selOpptyNameOp = 'equals';
        g.selOpptyOwner = sysAdmin.Name;
        g.selOpptyOwnerOp = 'equals';       
        g.selTechOwner = usr.Name;
        g.selTechOwnerOp = 'equals';
        Account acc = [SELECT id, Name FROM Account WHERE id=:opptyList[0].AccountId LIMIT 1];
        g.selAccName = acc.Name;
        g.selAccNameOp = 'equals';
        g.searchMethod();
        g.selOpptyNameOp = 'contains';
        g.selOpptyOwnerOp = 'contains';
        g.selTechOwnerOp = 'contains';
        g.selAccNameOp = 'contains';
        g.searchMethod();       
        test.stopTest();
    }
    
    static testMethod void updateOpptyTest1(){
        setupData();
        test.startTest();
        PageReference pageRef = Page.Core_Goal_AddOppty;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', goalList[0].Id);
        Core_Goal_addOpptyControllerExt g = new Core_Goal_addOpptyControllerExt();
        //opptyList[1].Core_Opp_Deal_Win_Goal__c = goalList[0].Id;
        //update opptyList[1];
        g.populateOpptyList();
        for(Core_Goal_addOpptyControllerExt.NewopptyWrapper opw : g.NewremoveOpptylist){
            if(!opw.Newselected){
                opw.Newselected = true;
            }
        }
        g.updateOppty();
        test.stopTest();
    }
    */
}