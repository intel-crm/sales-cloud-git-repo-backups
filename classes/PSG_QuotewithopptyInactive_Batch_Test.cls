/***************************************************************************
Class Name    : PSG_QuotewithopptyInactive_Batch_Test
Version       : 1.0
Created Date  : 4 April 2023           
Modification Log :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------
* Ranjit                04/04/2023                           Test class for PSG_QuotewithopptyInactive_Batch.
*****************************************************************************************************************************************/

@isTest
public class PSG_QuotewithopptyInactive_Batch_Test {
    /*@testSetup
    public static void setUpData() {
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
        List < SBQQ__Quote__c > lstquote = PSG_Test_Utility.createQuote(accsToUpdate[0].id, con1.id, 3);
        List < SBQQ__QuoteLine__c > lstquoteLines = PSG_Test_Utility.createQuoteLines(lstquote[0].id, 1);
        List < price_prid__c > prid = PSG_Test_Utility.CreatePrid(accsToUpdate[0].id, null, null, p.Id);
        Opportunity opp = PSG_Test_Utility.createOpportunity(accsToUpdate[0].Id);
        Test.stopTest();
    }
    
     static testMethod void testBatchdwin() {
        List < User > lstUsers = PSG_Test_Utility.createAdminUser();
        Account acc2 = PSG_Test_Utility.createAccount();
        Contact con = PSG_Test_Utility.createContact(acc2.id);
        Account acc = [Select Id from Account LIMIT 1];
        system.runAS(lstUsers[0]) {
        
        SBQQ.TriggerControl.disable();
        List < SBQQ__Quote__c > lstquote = [Select Id from SBQQ__Quote__c];
        List < SBQQ__QuoteLine__c > lstquoteLines = [select id, SBQQ__Quote__r.core_cpq_quote_approved_date_dt__c, core_cpq_PRID__c, SBQQ__Quote__r.core_cpq_quote_type_nm__c, SBQQ__Quote__r.core_cpq_status_txt__c from SBQQ__QuoteLine__c];
        lstquote[0].core_cpq_quote_type_nm__c = 'Design Win';
        lstquote[0].SBQQ__Status__c = 'Approved';
        update lstquote;
        lstquote[0].core_cpq_quote_approved_date_dt__c = system.today().addyears(-3);
        update lstquote;
        
        List < price_PRID__C > prid = [Select Id from price_PRID__C];
        Test.startTest();
        lstquoteLines[0].core_cpq_PRID__c = prid[0].id;
        lstquoteLines[0].SBQQ__Quote__r.core_cpq_quote_type_nm__c = 'Design Win';
        lstquoteLines[0].SBQQ__Quote__r.core_cpq_status_txt__c = 'Approved';
        lstquoteLines[0].SBQQ__Quote__r.core_cpq_quote_approved_date_dt__c = system.today().addyears(-3);
        update lstquoteLines;
        
        lstquote[1].core_cpq_end_customer_nm__c = acc.Id;
        lstquote[1].core_cpq_quote_type_nm__c = 'Transfer Pricing';
        update lstquote[1];
        lstquote[1].SBQQ__Status__c = 'Approved';
        update lstquote;
        List < SBQQ__QuoteLine__c > tpquoteLines = PSG_Test_Utility.createQuoteLines(lstquote[1].id, 1);
        tpquoteLines[0].core_cpq_PRID__c = prid[0].id;
        update tpquoteLines;
        Test.stopTest();  
        }
        PSG_QuotewithopptyInactive_Batch batch = new PSG_QuotewithopptyInactive_Batch();
        Database.executeBatch(batch);
    }

    static testMethod void testBatchbudgetary() {
        SBQQ.TriggerControl.disable();
        Account acc = PSG_Test_Utility.createAccount();
        Contact con = PSG_Test_Utility.createContact(acc.Id);
        Account acc1 = [Select Id from Account LIMIT 1];
        Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
        rec.Bypass__c = true;
        insert rec;
        Opportunity opp = [select id from Opportunity limit 1];
        opp.StageName = 'Lost';
        opp.Core_Loss_Cancel_Reason__c = 'Lost-Price';
        opp.Core_Loss_Cancel_Details__c = 'test';
        opp.CloseDate = system.today();
        opp.Core_Opportunity_Team_Geo_APJ__c = true;
        update opp;
        List < SBQQ__Quote__c > DWquote3 = [Select Id,SBQQ__Distributor__c from SBQQ__Quote__c];
        DWquote3[0].core_cpq_quote_type_nm__c = 'Budgetary';
        DWquote3[0].SBQQ__Opportunity2__c = opp.id;
        DWquote3[0].core_cpq_end_customer_nm__c = acc1.Id;
        update DWquote3;
        DWquote3[0].SBQQ__Status__c = 'Approved';
        DWquote3[0].core_cpq_quote_approved_date_dt__c = system.today().addyears(-3);
        update DWquote3;
        Test.startTest();
        PSG_QuotewithopptyInactive_Batch batch = new PSG_QuotewithopptyInactive_Batch();
        Database.executeBatch(batch);
        PSG_QuotewithopptyInactive_Batch m = new PSG_QuotewithopptyInactive_Batch();
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('Update Job', sch, m);        
        Test.stopTest();
        Account a=new Account();
        /*
        Database.SaveResult[] srList = Database.insert(new List<Account>{a}, false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                String msg=PSG_QuotewithopptyInactive_Batch.getErrorAsString(sr.getErrors());
            }
        }
		
    }*/
}