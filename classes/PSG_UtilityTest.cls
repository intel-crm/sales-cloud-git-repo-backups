/****************************************************************************************************
Apex Class Name : PSG_UtilityTest
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_Utility.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema             08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_UtilityTest{
    @isTest static void createQuoteHistoryTest(){
        Account ac = PSG_Test_Utility.createAccount();
        Contact con = PSG_Test_Utility.createContact(ac.Id);
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = PSG_Test_Utility.createQuote(ac.Id, con.Id, 1);
        quoteList[0].core_cpq_ready_for_submission__c=true;
        update quoteList[0];
        List<User> distyUser = PSG_Test_Utility.createDistyUser();
        System.assert(distyUser[0].email!=null,'Disty user is created');
        PSG_Utility.syncQuoteStatus(quoteList[0].Id,'New');
        PSG_Utility.getLoginUserType(distyUser[0].Id);
        PSG_Utility.getRecordTypeId('SBQQ__Quote__c','PSG_Quote_Inactive_Quotes');
        System.runAs(distyUser[0]){ 
            psg_utility.getUserInformation();
        }
        List<User> u = PSG_Test_Utility.createSOSUser();
        System.assert(u[0].email!=null,'SOSuser is created');
        PSG_Utility.syncQuoteStatus(quoteList[0].Id,'In Progress');
        PSG_Utility.getLoginUserType(u[0].Id);
        PSG_Utility.getRecordTypeId('SBQQ__Quote__c','PSG_Quote_Inactive_Quotes');
        PSG_Utility.syncQuoteStatus(quoteList[0].Id,'In Review');
        PSG_Utility.getRecordTypeId('SBQQ__Quote__c','PSG_Quote_Inactive_Quotes');
        Test.stopTest();
        List<User> u2 = PSG_Test_Utility.createBMUser();
        PSG_Utility.getUserPemissionSets(u2[0].Id);
        System.assert(u2[0].email!=null,'BM user is created');
        PSG_Utility.syncQuoteStatus(quoteList[0].Id,'In Review');
        PSG_Utility.getLoginUserType(u2[0].Id);
        PSG_Utility.createPSGLogEntry('PSG_ProductBusinessLogic','changeProductOnRelatedObjects','Error while Copying Forward cost records.','Error','Product','Low','',null,'','');
        PSG_Utility.createCoreLogEntry('PSG_ProductBusinessLogic','changeProductOnRelatedObjects','Error while Copying Forward cost records.','Error','Product','Low','');
        Id recordId=PSG_Utility.getRecordTypeId('SBQQ__Quote__c','PSG_Quote_Inactive_Quotes');
        try {
            Contact c = new Contact(FirstName = 'Unit', LastName = 'Test',AccountId = UserInfo.getUserId());
            insert c;
        }Catch(Exception e){
            PSG_Utility.logError(e);            
        }
    }
}