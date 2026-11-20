@isTest
public class Core_MindsComplianceControllerTest {
    public static List<Opportunity> opptyList = new List<Opportunity>();
    static void testData(){
         Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;        
        Profile p = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :p.Id AND isActive = true LIMIT 1];
        System.runAs(usr){
            Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St', 
                                           BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA', Core_Sales_Groups__c='CCG Sales Group',
                                           BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
            insert acct;
            
            opptyList.add(new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                 AccountId = acct.Id,StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usr.Id, Core_Sales_Group__c='Global Accounts', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Apollo Lake D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'));
            opptyList.add(new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,
                 AccountId = acct.Id,StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usr.Id, Core_Sales_Group__c='Regional Sales', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Apollo Lake D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'));
            opptyList.add(new Opportunity(Name = 'Test Opportunity3', RecordTypeId = newOppRecTypeId,
                 AccountId = acct.Id,StageName = 'Define', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = usr.Id, Core_Sales_Group__c='Regional Sales', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='Apollo Lake D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'));
            insert opptyList;
        }
    }
    static testMethod void mindsComplianceTest(){
        testData();
        ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[0]);
        Core_MindsComplianceController cmc=new Core_MindsComplianceController(sc);
        cmc.Header='test';
        cmc.Guardrail='google';
        cmc.nonIntel='test1';
        cmc.Url='google.com';
        cmc.nonIntelUrl='google.com';
    }
     static testMethod void mindsComplianceTest1(){
        testData();
        ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[0]);
        Core_MindsComplianceController cmc=new Core_MindsComplianceController(sc);
     }
}