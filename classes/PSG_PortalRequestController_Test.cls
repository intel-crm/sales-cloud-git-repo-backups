/*********************************************************************************************************************
Class Name    : PSG_PortalRequestController_Test
Version       : 1.0
Created Date  : 20 Dec 2022

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Ranjit Kumar      12-20-2022                  Test Class for PSG_PortalRequestController
* *********************************************************************************************************************/


@isTest
public class PSG_PortalRequestController_Test {
    /*static testMethod void testAfterInsertUpdateOperations(){
        User thisUser = [ select Id from User where profile.Name='System Administrator' and isactive=true limit 1];
           system.runAs(thisUser){
            Account acc = PSG_Test_Utility.createAccount();
            List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
            List<Account> accsToUpdate=new List<Account>();
            Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
             update accsToUpdate;
             Opportunity opp = PSG_Test_Utility.createOpportunity(accsToUpdate[0].Id);
            SBQQ.TriggerControl.disable();
            SBQQ__Quote__c quote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].Id,opp.id);
            quote.core_cpq_end_customer_nm__c=accsToUpdate[0].Id;
            insert quote;
            SBQQ.TriggerControl.disable();
            core_cpq_dpa_aln__c aln = new core_cpq_dpa_aln__c();  
            aln.RecordTypeId = Schema.SObjectType.core_cpq_dpa_aln__c.getRecordTypeInfosByDeveloperName().get('PSG_DPA').getRecordTypeId();
            aln.core_cpq_active_quote__c = quote.Id;
            aln.core_cpq_record_type_identifier__c = 'DPA';
            aln.core_cpq_status_txt__c = 'New';
            aln.core_cpq_change_flag__c = 'N';
            aln.core_cpq_dpa_approved_date__c = '1/28/2022';
            aln.core_cpq_dpa_approved_date__c = '1/28/2022';
            aln.core_cpq_comments_txt__c = 'test';     
            aln.core_cpq_ship_end_date_dt__c=system.today();
            insert aln;
        
            List<SBQQ__QuoteLine__c> lstquoteLines = PSG_Test_Utility.createQuoteLines(quote.id, 1);
            List<core_cpq_dpa_aln_line__c> lstdpaalnLines = PSG_Test_Utility.createDPALinesWithoutInsert(aln.id, 1);
            lstdpaalnLines[0].core_cpq_quote_item_line_no__c=lstquoteLines[0].Id;   
            insert lstdpaalnLines; 
           
            core_cpq_portalrequest__c pr = new core_cpq_portalrequest__c();
           pr.core_cpq_Status__c= '';
            pr.core_cpq_request_type__c = 'Field Update';
            pr.core_cpq_bot_Object_Name__c = 'core_cpq_dpa_aln_line__c';
            pr.core_cpq_bot_field_name__c= 'core_cpq_requested_qty_nbr__c';
            pr.core_cpq_Field_Type__c = 'Double';
            pr.core_cpq_value__c = '45';
            pr.core_cpq_record_Id__c = lstdpaalnLines[0].Id;
            insert pr;
             
            Test.startTest();
            SBQQ.TriggerControl.disable();  
            pr.core_cpq_Status__c= 'Approved';
            update pr;
           Test.stopTest();
             
           }
    }
    
    static testMethod void testGetFieldValue(){
        Object value = PSG_PortalRequestController.getFieldValue('Currency', '50.00');
        System.assertEquals(value, 50.00);
        Object value1 = PSG_PortalRequestController.getFieldValue('Date', '5/5/2026');
        System.assertEquals(value1, Date.parse('5/5/2026'));
        Object value2 = PSG_PortalRequestController.getFieldValue('Boolean', 'True');
        System.assertEquals(value2, True);
        Object value3 = PSG_PortalRequestController.getFieldValue('Percent', '6');
        System.assertEquals(value3, 6);
        Object value4 = PSG_PortalRequestController.getFieldValue('', '');
        System.assertEquals(value4, null);
    }
    
      @isTest
    static void testGetPRList() {
        User thisUser = [ select Id from User where profile.Name='System Administrator' and isactive=true limit 1];
        core_cpq_portalrequest__c testPR = new core_cpq_portalrequest__c(core_cpq_approver__c=thisUser.Id,core_cpq_Status__c='Pending');
        insert testPR;
        system.runAs(thisUser){
        List<core_cpq_portalrequest__c> prList = PSG_PortalRequestController.GetPRList();
        System.assertEquals(1, prList.size());
        System.assertEquals(testPR.Id, prList[0].Id);
        }

       
    }*/
}