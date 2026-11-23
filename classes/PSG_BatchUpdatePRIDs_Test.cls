/****************************************************************************************************
Apex Class Name : PSG_BatchUpdatePRIDs_Test
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_BatchUpdatePRIDs.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Lata             08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_BatchUpdatePRIDs_Test {
    @testSetup
    public static void setupData(){
     	SBQQ.TriggerControl.disable();
        List<User> adminUserlst = PSG_Test_Utility.createAdminUser();
        System.runAs(adminUserlst[0]){
            System.assert(!adminUserlst.isEmpty(), 'User Created');
            Test.startTest();
            Account acc = PSG_Test_Utility.createAccount();
            Contact con = PSG_Test_Utility.createContact(acc.Id);
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, con.Id, 1);
            List<SBQQ__QuoteLine__c> lstquoteLine=PSG_Test_Utility.createQuoteLines(lstquote[0].Id,1);
            List<Product2> lstProd=PSG_Test_Utility.createProduct(1);
            List <price_prid__c> lstPRIDS =  PSG_Test_Utility.createPrid(acc.Id, lstquote[0].Id,lstquoteLine[0].Id, lstProd[0].Id);
            List <PRID_POS_Stage__c> pridPosList = PSG_Test_Utility.createPridPos(lstPRIDS[0]);
            List <price_prid__c> lstPRIDS1 =  [select name from price_prid__c where id=:lstPRIDS[0].Id];    
            String pridName = lstPRIDS1[0].Name;
            pridPosList[0].Price_PRID__c = pridName;
            update pridPosList;
            Test.stopTest();
        }
    }
    public static testMethod void pridScheduleTest1(){ 
       	SBQQ.TriggerControl.disable();
        List<User> lstUsers3 = PSG_Test_Utility.createAdminUser();
        system.runAs(lstUsers3[0]){
            System.assert(!lstUsers3.isEmpty(), 'User Created');
            Test.startTest();
            PSG_BatchUpdatePRIDs pridBatch = new PSG_BatchUpdatePRIDs();
            database.executeBatch(pridBatch);
            Test.stopTest();
        }  
    }
     static testMethod void pridScheduleTest(){ 
        SBQQ.TriggerControl.disable();
        List<User> lstUsers3 = PSG_Test_Utility.createAdminUser(); 
        System.assert(!lstUsers3.isEmpty(),'User inserted');
        system.runAs(lstUsers3[0]){
            Test.startTest();
            PSG_BatchUpdatePRIDs pridBatch = new PSG_BatchUpdatePRIDs();
            database.executeBatch(pridBatch);
            PSG_BatchUpdatePRIDs m = new PSG_BatchUpdatePRIDs();
            String sch = '20 30 8 10 2 ?';
            String jobID = system.schedule('Update Job', sch, m);
            Test.stopTest();
        }  
    }
}