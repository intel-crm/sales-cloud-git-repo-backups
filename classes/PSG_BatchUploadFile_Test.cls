/****************************************************************************************************
Apex Class Name : PSG_BatchUploadFile_Test
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_BatchUploadFile.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay                     08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_BatchUploadFile_Test {
    /*@testSetup
    public static void setUpData(){
        List<User> lstUsers3 = PSG_Test_Utility.createSOSUser();
        if(!lstUsers3.isEmpty()){
            system.runAs(lstUsers3[0]){                
                Account acc = PSG_Test_Utility.createAccount();
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 2);
                System.assert(lstquote[0].Id!=null,'Quote creation successfull');
                if(lstquote[0] != null){
                    pricebook2 pb = [Select id from pricebook2 limit 1];
                    lstquote[0].core_cpq_price_book_nm__c = pb.Id;
                    Test.startTest();
                    Update lstquote[0];
                    System.assert(lstquote[0].Id!=null,'Quote updation successfull');
                    List<SBQQ__QuoteLine__c> lstquoteLines= PSG_Test_Utility.createQuoteLines(lstquote[0].Id, 1);
                    Test.stopTest();
                }
            }   
        }
    }
    static testmethod void batchUploadFileTest(){
        Test.startTest();
        PSG_BatchUploadFile updateBatch = new PSG_BatchUploadFile(new List<String>{'OPN,FORWARDCOSTNAME,STARTDATE,ENDDATE,FORWARDCOST','EXNP1234,ABC,8/12/2021,8/12/2022,255'},true, false, 'Forward Cost',null,new List<String>(),new Map<String,String>(),'price_forward_cost__c',new Map<String,Set<String>>());
        updateBatch.firstLine='OPN,FORWARDCOSTNAME,STARTDATE,ENDDATE,FORWARDCOST';
        System.assert(updateBatch!=null,'PSG_BatchUploadFile successfull');
        Database.executeBatch(updateBatch,10);
        Test.stopTest();
    }
    */
}