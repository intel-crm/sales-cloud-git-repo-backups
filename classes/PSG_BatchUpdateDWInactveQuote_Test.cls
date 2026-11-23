/****************************************************************************************************
Apex Class Name : PSG_BatchUpdateDWInactveQuote_Test
Version         : 1.0 
Created Date    : 4/26/2021
Function        : Test class for PSG_BatchUpdateDWInactveQuote
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijaykanth                 4/26/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_BatchUpdateDWInactveQuote_Test {    
    /*@testSetup
    public static void setUpData(){
         SBQQ.TriggerControl.disable();
        List<User> lstUsers3 = PSG_Test_Utility.createSOSUser();
        if(!lstUsers3.isEmpty()){
            system.runAs(lstUsers3[0]){
                Account a1=PSG_Test_Utility.createDirectAccount();
                a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
                a1.Core_Is_Pricing_Parent_ChkBox__c=true;
                a1.Core_Direct_Account_Active_Ind__c=true;
                update a1;
                Account acc=PSG_Test_Utility.createAccount();
                acc.Core_PSG_Account__c=true;
                acc.Core_Direct_Pricing_Parent_Id__c=a1.id;
                acc.Core_Direct_Legal_Parent_Id__c=a1.Id;
                update acc;
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 2);
                System.assert(lstquote[0].Id!=null,'Quote creation successfull');
                if(lstquote[0] != null){
                    pricebook2 pb = [Select id from pricebook2 limit 1];
                    lstquote[0].core_cpq_price_book_nm__c = pb.Id;
                    lstquote[0].core_cpq_quote_type_nm__c = 'Design Win';
                    lstquote[0].core_cpq_active_cb__c = true;
                    lstquote[0].core_cpq_status_txt__c='Approved';
                    lstquote[0].SBQQ__Status__c='Approved';
                    lstquote[0].core_cpq_end_customer_nm__c=acc.Id;
                    lstquote[1].core_cpq_end_customer_nm__c=acc.Id;
                    Update lstquote;
                    Test.startTest();
                    System.assert(lstquote[0].Id!=null,'Quote updation successfull');
                    List<SBQQ__QuoteLine__c> lstquoteLines= PSG_Test_Utility.createQuoteLines(lstquote[1].Id, 1);
                    lstquoteLines[0].core_cpq_parent_quote__c = lstquote[0].Id;
                    update lstquoteLines[0];
                    lstquote[0].core_cpq_active_cb__c = false; 
                    Update lstquote[0];
                    Test.stopTest();
                }              
            }   
        }
    }
    static testmethod void batchUpdateQuoteLinesTest(){
         SBQQ.TriggerControl.disable();
        List<User> lstUsers3 = PSG_Test_Utility.createSOSUser();
        system.runAs(lstUsers3[0]){
            System.assert(!lstUsers3.isEmpty(),'user created successfull');
            Test.startTest();
            PSG_BatchUpdateDWInactveQuote updateBatch = new PSG_BatchUpdateDWInactveQuote();
            Database.executeBatch(updateBatch,1);
            Test.stopTest();
        }
    }*/
}