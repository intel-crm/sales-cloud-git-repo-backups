/***************************************************************************
Class Name    : PSG_Quote_Price_Prediction_Test
Version       : 1.0
Created Date  : 26/08/2024             
Modification Log :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------
* Ranjit                26/08/2024                           Test class for PSG_Quote_Price_Prediction_Controller.
*****************************************************************************************************************************************/
@IsTest
public class PSG_Quote_Price_Prediction_Test {
    
    @testSetup
    static void setUpData() {
        Account acc = PSG_Test_Utility.createAccount();
        Contact con1 = PSG_Test_Utility.createContact(acc.Id);
        con1.Email = 'FirstNameacc123@intel.com';
        update con1;
        List < Account > accs = [SELECT Id from Account where RecordType.Name = 'Intel Account' limit 10];
        List < Account > accsToUpdate = new List < Account > ();
        Id recordtypeId = [SELECT Id, name, developername from RecordType where sobjecttype = 'Account' and Developername = 'Core_Direct_Account' LIMIT 1].Id;
        Account a1 = PSG_Test_Utility.createDirectAccount();
        a1.RecordTypeId = recordtypeId;
        a1.Core_Direct_Account_Type_Nm__c = 'End Customer Parent';
        a1.Core_Is_Pricing_Parent_ChkBox__c = true;
        a1.Core_Direct_Account_Active_Ind__c = true;
        update a1;
        Account a2 = PSG_Test_Utility.createDirectAccount();
        a2.RecordTypeId = recordtypeId;
        a2.Core_Direct_Account_Type_Nm__c = 'End Customer Parent';
        a2.Core_Is_Pricing_Parent_ChkBox__c = true;
        a2.Core_Direct_Legal_Parent_Id__c = a1.Id;
        a2.Core_Direct_Account_Active_Ind__c = true;
        update a2;
        for (Integer i = 0; i < 1; i++) {
            accs[i].Core_PSG_Account__c = true;
            accs[i].Core_Direct_Pricing_Parent_Id__c = a2.id;
            accs[i].Core_Direct_Legal_Parent_Id__c = a1.Id;
            
            accsToUpdate.add(accs[i]);
        }
        update accsToUpdate;
        SBQQ.TriggerControl.disable();
        Product2 p = new Product2();
        p.core_OPN__c = 'INTELPROD';
        p.Name = 'Intel Prod 1';
        p.Core_Hierarchy_ID__c = '59';
        p.Core_Product_Type__c = Label.PSG_Product_Type_Identifier;
        p.Core_Code_Name__c = Label.PSG_Product_Type_Identifier;
        p.IsActive = true;
        p.Core_Product_org__c = 'Sales';
        insert p;
        Test.startTest();
        List < SBQQ__Quote__c > lstquote = PSG_Test_Utility.createQuote(accsToUpdate[0].id, con1.id, 1);
        List < SBQQ__QuoteLine__c > lstquoteLines = PSG_Test_Utility.createQuoteLines(lstquote[0].id, 1);
        Test.stopTest();
    }
    
    @istest
    static void testpricepredict(){
        List < User > lstUsers = PSG_Test_Utility.createAdminUser();
        Account acc2 = PSG_Test_Utility.createAccount();
        Contact con = PSG_Test_Utility.createContact(acc2.id);
        Account acc = [Select Id from Account LIMIT 1];
        system.runAS(lstUsers[0]) {
            
            SBQQ.TriggerControl.disable();
            List < SBQQ__Quote__c > lstquote = [Select Id from SBQQ__Quote__c];
            List < SBQQ__QuoteLine__c > lstquoteLines = [select id, SBQQ__Quote__r.core_cpq_quote_approved_date_dt__c, core_cpq_PRID__c, SBQQ__Quote__r.core_cpq_quote_type_nm__c, SBQQ__Quote__r.core_cpq_status_txt__c from SBQQ__QuoteLine__c];
            lstquote[0].core_cpq_quote_type_nm__c = 'Budgetary';
            lstquote[0].core_cpq_ready_for_submission__c=true;    
            lstquote[0].SBQQ__Status__c = 'In Review';
            update lstquote;
            Test.setMock(HttpCalloutMock.class, new PSG_Quote_Price_MockTest());
            Test.startTest();
            PSG_Quote_Price_Prediction_Controller.sendQuoteLinesToEndpoint(lstquote[0].id);
            lstquoteLines[0].core_cpq_disregarding_price_guidance__c='N/A';
            PSG_Quote_Price_Prediction_Controller.updateQuoteLines(lstquoteLines);  
            Test.stopTest();
            
            
        }
    }
    
}