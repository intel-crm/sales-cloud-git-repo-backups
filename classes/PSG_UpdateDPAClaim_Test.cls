/****************************************************************************************************
Apex Class Name : PSG_UpdateDPAClaim_Test
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_UpdateDPAClaim.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_UpdateDPAClaim_Test {
    @TestSetup
    public static void setupData(){
        List<User> lstUsers3 = PSG_Test_Utility.createSOSUser();
        if(!lstUsers3.isEmpty()){
            Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
            
            System.assert(!lstUsers3.isEmpty(),'Users Created');
            system.runAs(lstUsers3[0]){
                SBQQ.TriggerControl.disable();
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
                Account acc = PSG_Test_Utility.createAccount();
                acc.Core_PSG_Account__c=true;
                acc.Core_Direct_Pricing_Parent_Id__c=a2.id;
                acc.Core_Direct_Legal_Parent_Id__c=a1.Id;
                update acc;
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
                Test.startTest();
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 2);
                List<core_cpq_dpa_aln__c> lstdpa = PSG_Test_Utility.createDPARecord(lstquote[0],a1.Id);
                List<core_cpq_dpa_aln_line__c> lstDPALines=PSG_Test_Utility.createDPALines(lstdpa[0].Id,2);
                Test.stopTest(); 
            }   
        }
    }
    @isTest public static void testServiceCallout(){
        core_cpq_dpa_aln_line__c dpaLine=[SELECT Id,core_cpq_device_nm__c,core_cpq_device_nm__r.Name,core_cpq_device_nm__r.core_OPN__c,core_cpq_cis_no_nbr__r.Name from core_cpq_dpa_aln_line__c limit 1];
        Product2 p=new Product2();
        p.Id=dpaLine.core_cpq_device_nm__c;
        p.core_OPN__c='TESTOPN';
        update p;
        String strRequest = '{"Test":"Updated Claim Quantity"';
        String strRequest1 = '{'+
            '"DpaInterfaceAltera": {'+
            '"SAPDPANo": "0040553076",'+
            '"DPANo": "D004764",'+
            '"QuoteNo": "1-T4PP1Z761",'+
            '"ListOfDpaLineItemsInterfaceAltera": {'+
            '"DpaLineItemsInterfaceAltera": {'+
            '"LineNumber": 1,'+
            '"ProductName": "Test OEM product",'+
            '"ClaimedQty": "2.0000",'+
            '"ClaimedAmount": "2354.0000"'+
            '}'+
            '}'+
            '}'+
            '}';
        String strRequest2 = '{'+
            '"DpaInterfaceAltera": {'+
            '"SAPDPANo": "0040553076",'+
            '"DPANo": "'+dpaLine.core_cpq_cis_no_nbr__r.Name+'",'+
            '"QuoteNo": "1-T4PP1Z761",'+
            '"ListOfDpaLineItemsInterfaceAltera": {'+
            '"DpaLineItemsInterfaceAltera": {'+
            '"LineNumber": 1,'+
            '"ProductName": "'+dpaLine.core_cpq_device_nm__r.core_OPN__c+'",'+
            '"ClaimedQty": "2.0000",'+
            '"ClaimedAmount": "2354.0000"'+
            '}'+
            '}'+
            '}'+
            '}';
        System.assert(dpaLine!=null,'DPA Created');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(strRequest);
        req.requestURI = '/services/apexrest/v1/SyncDPAClaim'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PSG_UpdateDPAClaim.UpdateDPA();
        strRequest=strRequest+'}';
        req.requestBody = Blob.valueof(strRequest);
        PSG_UpdateDPAClaim.UpdateDPA();
        req.requestBody = Blob.valueof(strRequest1);
        PSG_UpdateDPAClaim.UpdateDPA();
        req.requestBody = Blob.valueof(strRequest2);
        PSG_UpdateDPAClaim.UpdateDPA();
        Test.stopTest();  
    }
    @isTest public static void testServiceCallout1(){
        String strRequest1 = '{'+
            '"DpaInterfaceAltera": {'+
            '"SAPDPANo": "0040553076",'+
            '"DPANo": "",'+
            '"QuoteNo": "1-T4PP1Z761",'+
            '"ListOfDpaLineItemsInterfaceAltera": {'+
            '"DpaLineItemsInterfaceAltera": {'+
            '"LineNumber": 1,'+
            '"ProductName": "Test OEM product",'+
            '"ClaimedQty": "2.0000",'+
            '"ClaimedAmount": "2354.0000"'+
            '}}}}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(strRequest1);
        req.requestURI = '/services/apexrest/v1/SyncDPAClaim'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PSG_UpdateDPAClaim.UpdateDPA();
        Test.stopTest();  
    }
    
    @isTest public static void testServiceCallout2(){
        String strRequest1 = '{'+
            '"DpaInterfaceAltera": {'+
            '"SAPDPANo": "0040553076",'+
            '"DPANo": "TJXVZ",'+
            '"QuoteNo": "1-T4PP1Z761",'+
            '"ListOfDpaLineItemsInterfaceAltera": {'+ 
            '"DpaLineItemsInterfaceAltera": [{'+
            '"LineNumber": 1,'+
            '"ProductName": "Test OEM product",'+
            '"ClaimedQty": "",'+
            '"ClaimedAmount": "2354.0000"'+
            '},{'+
            '"LineNumber": 2,'+
            '"ProductName": "Test OEM product",'+
            '"ClaimedQty": "2.0000",'+
            '"ClaimedAmount": "2354.0000"'+
            '}'+            
            ']}}}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(strRequest1);
        req.requestURI = '/services/apexrest/v1/SyncDPAClaim'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PSG_UpdateDPAClaim.UpdateDPA();
        Test.stopTest();  
    }
}