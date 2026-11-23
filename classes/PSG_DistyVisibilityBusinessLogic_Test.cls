/****************************************************************************************************
Apex Class Name : PSG_DistyVisibilityBusinessLogic_Test
Version         : 1.0 
Created Date    : 07/08/2021
Function        : Tst class for PSG_DistyVisibilityBusinessLogic
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sushmita                  07/08/2021                 Created
*****************************************************************************************************/
@isTest
public class PSG_DistyVisibilityBusinessLogic_Test {
    /*@testSetup
    public static void setupData(){
        List <User> lstUsers =  PSG_Test_Utility.createSOSUser();
        if(!lstUsers.isEmpty()){
            system.runAs(lstUsers[0]){
                System.assert(!lstUsers.isEmpty(), 'User created');
                Test.startTest();
                Account acc = PSG_Test_Utility.createAccount();
                Account acct = PSG_Test_Utility.createDistyAccount();
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                User distyUser = PSG_Test_Utility.createDistyTestUser(acct.Id);
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, con.Id, 1);
                Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
                acc.RecordTypeId = accRecordTypeId;
                acc.Core_Direct_Account_Type_Nm__c ='End Customer Parent';
                update acc;    
                List<core_cpq_dpa_aln__c> dpa_List = PSG_Test_Utility.createDPARecord(lstquote[0],acc.Id);
                List<core_cpq_disty_visibility__c> lstDV =  PSG_Test_Utility.createDistyVisibility(acct.Id, lstquote[0].Id,1);
                List<SBQQ__Quote__Share> lstQuoteShare = PSG_Test_Utility.createQuoteShare(acc.Id, lstquote[0].Id);
                Test.stopTest();
            }   
        }
    }
    
    @isTest static void testData1(){
        List<User> lstUsers = PSG_Test_Utility.createSOSUser();
        List<User> lstDistyUser = PSG_Test_Utility.createDistyUser(); 
        Account acct = PSG_Test_Utility.createDistyAccount();
        set<Id> accId = new set<id>();
        accId.add(acct.id);
        List<SBQQ__Quote__c> lstquotes    = [select id, SBQQ__Distributor__c from SBQQ__Quote__c limit 2];
        System.assert(!lstquotes.isEmpty(), 'Quotes retrieved');
        Test.startTest();
        List<core_cpq_disty_visibility__c> lstDV = [select id, core_cpq_distributor__c, core_cpq_quote__c,core_cpq_quote__r.core_cpq_quote_type_nm__c from core_cpq_disty_visibility__c limit 2];
        Map<Id,core_cpq_disty_visibility__c> oldMap = new Map<Id,core_cpq_disty_visibility__c>([select id, core_cpq_distributor__c, core_cpq_quote__c 
                                                                                                FROM core_cpq_disty_visibility__c limit 2 ]);
        List<SBQQ__Quote__Share> quoteSharedLst = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause 
                                                   FROM SBQQ__Quote__Share where ParentId = :lstquotes[0].Id AND UserOrGroupId =:lstDistyUser[0].Id];
        PSG_DistyVisibilityBusinessLogic.afterInsertOperations(lstDV,oldMap,true);
        PSG_DistyVisibilityBusinessLogic.afterDeleteOperations(lstDV,oldMap,true);
        PSG_DistyVisibilityBusinessLogic.manageQuoteShareWithDistyContacts(lstDV, accId, 'delete');
        if(!lstDV.isEmpty()){
            delete lstDV[0]; 
        }
        Test.stopTest();
    }*/
}