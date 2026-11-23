/****************************************************************************************************
Apex Class Name : PSG_Integration_DPA_Test
Version         : 1.0 
Created Date    : 01/06/2021
Function        : Class is used to submit DPA/ALN record to SAP.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari                  01/06/2021                 Created
*****************************************************************************************************/
@isTest
public class PSG_Integration_DPA_Test {
    /*
    Public static List<User> admUserList = PSG_Test_Utility.createAdminUser();
    @TestSetup
    private static void createTestData(){
        
        System.runAs(admUserList[0]){
            SBQQ.TriggerControl.disable();
            Account acc3 = PSG_Test_Utility.createAccount();
            Account acc = PSG_Test_Utility.createDirectAccount();
            Account acc4 = PSG_Test_Utility.createAccount();
			//Account directAcct = PSG_Test_Utility.createDirectAccount();
            acc4.Core_Direct_Pricing_Parent_Id__c=acc.id;
            acc4.Core_Direct_Legal_Parent_Id__c=acc.id;
            update acc4;
            Account acc2 = PSG_Test_Utility.createAccount();
            Contact con = PSG_Test_Utility.createContact(acc2.Id);
            Account accAln = PSG_Test_Utility.createAccount();
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc4.Id, con.Id, 1);
            lstquote[0].Pricing_Quote_Program_Nm__c = 'Tender';
            lstquote[0].core_cpq_sap_ecp_nm__c = acc.id;
            update lstquote[0];
            List<SBQQ__QuoteLine__c> lstquotelines=PSG_Test_Utility.createQuoteLines(lstquote[0].Id, 1);
            lstquotelines[0].core_cpq_dollar_change_flag_cb__c=false;
            lstquotelines[0].core_cpq_quote_line_type_txt__c='Step';
            lstquotelines[0].core_cpq_active_Pricing__c=false;
            update lstquotelines[0];
            Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
            List<core_cpq_dpa_aln__c> lstdpa = PSG_Test_Utility.createDPARecord(lstquote[0],acc.Id);
            List<core_cpq_dpa_aln__c> lstdpa1 = PSG_Test_Utility.createDPARecord(lstquote[0],acc.Id);
            lstdpa[0].core_cpq_record_type_identifier__c='DPA';
            lstdpa[0].core_cpq_quote_distributor__c=acc3.Id;
            lstdpa1[0].core_cpq_change_flag__c='H';
            lstdpa.add(lstdpa1[0]);
            update lstdpa;
            List<core_cpq_dpa_aln__c> lstaln = PSG_Test_Utility.createDPARecord(lstquote[0],acc.Id);
            lstaln[0].core_cpq_record_type_identifier__c='ALN';
            lstaln[0].core_cpq_quote_distributor__c=acc3.Id;
            lstaln[0].core_cpq_change_flag__c='H';
            update lstaln;
            Test.stopTest();
            acc2.RecordTypeId = accRecordTypeId;
            acc2.Core_Direct_Account_Type_Nm__c ='Sold To';
            acc2.ParentId = acc3.Id;
            acc2.Core_Nielsen_ID__c = 'D';
            update acc2;  
            accAln.RecordTypeId = accRecordTypeId;
            accAln.Core_Direct_Account_Type_Nm__c ='Sold To';
            accAln.ParentId = acc3.Id;
            accAln.Core_Nielsen_ID__c = 'L';
            update accAln;
            /*directAcct.RecordTypeId = accRecordTypeId;
            directAcct.Core_Direct_Account_Type_Nm__c ='Sold To';
            directAcct.ParentId = acc3.Id;
            directAcct.Core_Nielsen_ID__c = 'D';
            update directAcct; 
            lstdpa[0].core_cpq_ship_start_date_dt__c=System.today();
            lstdpa[0].core_cpq_ship_end_date_dt__c=Date.newInstance(2030, 07, 15);
            lstdpa[0].core_cpq_duration_nbr__c=20;
            lstdpa[0].core_cpq_sap_end_customer_nm__c=acc.Id;
            lstdpa[0].core_cpq_sap_distributor_nm__c=acc2.Id;
            lstdpa[0].core_cpq_record_type_identifier__c='DPA';
            update lstdpa[0];
            lstaln[0].core_cpq_ship_start_date_dt__c=System.today();
            lstaln[0].core_cpq_ship_end_date_dt__c=Date.newInstance(2030, 07, 15);
            lstaln[0].core_cpq_duration_nbr__c=20;
            lstaln[0].core_cpq_sap_end_customer_nm__c=acc.Id;
            lstaln[0].core_cpq_sap_distributor_nm__c=accAln.Id;
            lstaln[0].core_cpq_record_type_identifier__c='ALN';
            update lstaln[0];
            
        }
    }
    
    @isTest
    private static void sendRequestToSAPTestDPA(){
        SBQQ.TriggerControl.disable();
        List<core_cpq_dpa_aln__c> lstdpa=[Select Id from core_cpq_dpa_aln__c];
        List<core_cpq_dpa_aln__c> lstaln=[Select Id from core_cpq_dpa_aln__c where core_cpq_record_type_identifier__c='ALN'];
        List<SBQQ__QuoteLine__c> lstquotelines=[Select Id from SBQQ__QuoteLine__c];
        List<core_cpq_dpa_aln_line__c> lstdpaLines=new List<core_cpq_dpa_aln_line__c>();
        List<core_cpq_dpa_aln_line__c> lstalnLines=new List<core_cpq_dpa_aln_line__c>();
 
        if(lstdpa[0] != null){
            lstdpaLines= PSG_Test_Utility.createDPALines(lstdpa[0].Id, 1);
            for(core_cpq_dpa_aln_line__c dpaLine:lstdpaLines){
                dpaLine.core_cpq_approved_qty_nbr__c=20;
                dpaLine.core_cpq_quote_item_line_no__c=lstquotelines[0].Id;
                dpaLine.core_cpq_disty_margin_pct__c=03;
            }
            update lstdpaLines;
            Test.startTest();
        }
                
        System.runAs(admUserList[0]){
            SBQQ.TriggerControl.disable();
            Test.setMock(HttpCalloutMock.class, new PSG_Integration_DPA_MockTest());            
            PSG_Integration_DPA.LightningResponse lr=PSG_Integration_DPA.sendRequestToSAP(lstdpa[0].Id,'submit');
            PSG_Integration_DPA.LightningResponse lr1=PSG_Integration_DPA.sendRequestToSAP(lstaln[0].Id,'submit');
            System.assert(!admUserList.isEMpty(),'');            
            PSG_Integration_DPA.changeBeforeSendToSap(lstdpa[0].Id,'hold');
            PSG_Integration_DPA.LightningResponse lr2=PSG_Integration_DPA.sendRequestToSAP(lstdpa[0].Id,'modify');
            PSG_Integration_DPA.LightningResponse lraln=PSG_Integration_DPA.sendRequestToSAP(lstaln[0].Id,'modify');
            Test.stopTest();
            PSG_Integration_DPA.modifyLineBeforeSendToSap(lstdpa[0].Id,'modify');
            lstdpa[0].core_cpq_ship_start_date_dt__c=date.newinstance(2018,02,02);
            lstdpa[0].core_cpq_change_flag__c = 'N';
            //update lstdpa[0];
            
            //PSG_Integration_DPA.LightningResponse lr3=PSG_Integration_DPA.sendRequestToSAP(lstdpa[0].Id,'submit');            
        }
    }
    
    @isTest
    private static void testHoldMethod(){
        List<core_cpq_dpa_aln__c> lstdpa=[Select Id from core_cpq_dpa_aln__c where core_cpq_change_flag__c='H'];
        SBQQ__QuoteLine__c ql=[Select Id from SBQQ__QuoteLine__c LIMIT 1];
        System.assert(!lstdpa.isEmpty(), '');
        Test.setMock(HttpCalloutMock.class, new PSG_Integration_DPA_MockTest());
        Test.startTest();
        PSG_Integration_DPA.LightningResponse lr=PSG_Integration_DPA.sendRequestToSAP(lstdpa[0].Id,'submit');
        PSG_QuoteBusinessLogic.sendAVPPRIDEmailAlert(new Set<Id>{ql.Id},'APJ');
        Test.stopTest();
    }
    
    @isTest
    private static void testSendRequestToSAPALN(){
        SBQQ.TriggerControl.disable();
        List<core_cpq_dpa_aln__c> lstdpa=[Select Id from core_cpq_dpa_aln__c];
        List<core_cpq_dpa_aln__c> lstaln=[Select Id,Name,core_cpq_siebel_cis_no_txt__c from core_cpq_dpa_aln__c where core_cpq_record_type_identifier__c='ALN'];
        List<SBQQ__QuoteLine__c> lstquotelines=[Select Id from SBQQ__QuoteLine__c];
        List<core_cpq_dpa_aln_line__c> lstalnLines=new List<core_cpq_dpa_aln_line__c>();
        //Changes 
        if(lstaln[0] != null){
            lstalnLines= PSG_Test_Utility.createDPALines(lstaln[0].Id, 1);
            for(core_cpq_dpa_aln_line__c dpaLine:lstalnLines){
                dpaLine.core_cpq_approved_qty_nbr__c=20;
                dpaLine.core_cpq_quote_item_line_no__c=lstquotelines[0].Id;
                dpaLine.core_cpq_disty_margin_pct__c=03;
            }
            update lstalnLines;
            Test.startTest();
        }
        System.runAs(admUserList[0]){
            SBQQ.TriggerControl.disable();
            System.assert(!admUserList.isEMpty(),''); 
            Test.setMock(HttpCalloutMock.class, new PSG_Integration_DPA_MockTest());            
            PSG_Integration_DPA.LightningResponse lr1=PSG_Integration_DPA.sendRequestToSAP(lstaln[0].Id,'submit');
            PSG_Integration_DPA.LightningResponse lraln=PSG_Integration_DPA.sendRequestToSAP(lstaln[0].Id,'modify');
            PSG_Integration_DPA.LightningResponse lr3 = PSG_Integration_DPA.getALNOpenQty(new List<String>{lstaln[0].core_cpq_siebel_cis_no_txt__c!=null?lstaln[0].core_cpq_siebel_cis_no_txt__c:lstaln[0].Name});
            Test.stopTest();
        }
    }*/
}