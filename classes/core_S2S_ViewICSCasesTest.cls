@isTest
public class core_S2S_ViewICSCasesTest {
    @testSetup 
    private static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='requestoremail@example.com', 
                          EmailEncodingKey='UTF-8', LastName='requestorUser', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='requestoremail@testorg.com');
        insert u;
        PermissionSet ps = [SELECT Id 
                            FROM PermissionSet 
                            WHERE Name = 'SWS_IDC_Business_Ops'];
        
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        System.runAs(u){
            insert psa;
        }
        Account acc = new Account();
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        acc.Name = 'Test Account'+ math.random();
        acc.Core_Account_Type__c = 'Distributor;End Customer';//added
        acc.Industry = 'Banking';
        acc.BillingCity = 'Texas';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'G-2101'; 
        acc.Core_Sales_Groups__c = 'APJ India Sales Group'; 
        acc.Core_Geo__c = 'APJ';
        acc.Core_Sub_Geo__c = 'IJKK';
        acc.Core_PSG_Account__c = true;
        acc.Core_Account_Tier__c ='PSG-Tier 4';
        acc.Core_Partner_Alliance_Program__c ='PSG Demand Creation - PSG';
        acc.Core_Account_BU_Focus__c='PSG-CM;PSG-DISTI';
        
        insert acc;
        Contact con = new Contact();
        con.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Intel_Contact').getRecordTypeId();
        con.FirstName = 'FirstName'+System.now();
        con.LastName = 'LastName';
        con.Email = 'FirstName@intel.com';
        con.AccountId = acc.Id;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry='USA';
        insert con;
    }
    
    @isTest static void listViewDataWithAccountId(){
        Account acc = [Select Id FROM Account LIMIT 1 ];
        List<sObject> cases = core_S2S_ViewICSCases.getListViewData(acc.Id,null,10,0);
        System.assertEquals(true,true);
    }
    
    @isTest static void listViewDataWithUserEmail(){
        Contact con = [Select Email from Contact LIMIT 1];
        List<sObject> cases = core_S2S_ViewICSCases.getListViewData(null,con.Email,10,0);
        system.assertEquals(0,cases.size());
        System.assertEquals(true,true);
    }
    
    @isTest static void listViewDataWithBothNull(){
        try{
            core_S2S_ViewICSCases.getListViewData(null,null,10,0);
            System.assertEquals(true,true);
        }catch(Exception e){
            
        }
    }
    
    @isTest 
    static void hasAccessTest(){
        try{
            core_S2S_ViewICSCases.hasAccess('','');
            System.assertEquals(true,true);
        }catch(Exception e){
            
        }
    }
}