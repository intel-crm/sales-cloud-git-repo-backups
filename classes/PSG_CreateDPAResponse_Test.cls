/****************************************************************************************************
Apex Class Name : PSG_CreateDPAResponse_Test
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_CreateDPAResponse.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_CreateDPAResponse_Test {
    /*
    @testSetup
    public static void setUpData(){
        List<User> lstUsers3 = PSG_Test_Utility.createSOSUser();
        if(!lstUsers3.isEmpty()){
            system.runAs(lstUsers3[0]){ 
                Account acc1 = PSG_Test_Utility.createDirectAccount();
                Account acc = PSG_Test_Utility.createAccount();
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
                Test.startTest();
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 2);
                System.assert(!lstquote.isEmpty(), 'Quotes Inserted');
                List<core_cpq_dpa_aln__c> lstdpa = PSG_Test_Utility.createDPARecord(lstquote[0],acc1.Id);
                List<core_cpq_dpa_aln__c> lstdpa1 = PSG_Test_Utility.createDPARecord(lstquote[0],acc1.Id);
                lstdpa[0].core_cpq_disty_submitted_user__c=UserInfo.getUserId();
                lstdpa1[0].core_cpq_disty_submitted_user__c=UserInfo.getUserId();
                lstdpa.add(lstdpa1[0]);
                update lstdpa;
                Test.stopTest();
            }   
        }
    }
    @isTest public static void testServiceCallout1(){
        List<core_cpq_dpa_aln__c> dpaList = [select id,Name  from core_cpq_dpa_aln__c];
        System.assert(!dpaList.isEmpty(), 'DPA Inserted');
        JSONGenerator jsGen=JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeFieldName('ListOfDpaInterfaceAltera');
        jsGen.writeStartObject();
        jsGen.writeFieldName('DpaInterfaceAltera');
        jsGen.writeStartObject();
        jsGen.writeStringField('SAPDPANo','0041986801');
        jsGen.writeStringField('SAPDPAStatus','AWRD:Approved - Awarded');
        jsGen.writeStringField('DPANo',dpaList[0].Name);
        jsGen.writeStringField('SyncComments','No changes possible in document');
        jsGen.writeStringField('Type','DPA');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.close();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(jsGen.getAsString());
        req.requestURI = '/services/apexrest/v1/CreateDPAResponse'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PSG_CreateDPAResponse.UpdateDPA();
        Test.stopTest();  
    }
    @isTest 
    public static void testServiceCallout2(){
        JSONGenerator jsGen=JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeFieldName('ListOfDpaInterfaceAltera');
        jsGen.writeStartObject();
        jsGen.writeFieldName('DpaInterfaceAltera');
        jsGen.writeStartObject();
        jsGen.writeStringField('SAPDPANo','0041986801');
        jsGen.writeStringField('SAPDPAStatus','AWRD:Approved - Awarded');
        jsGen.writeStringField('DPANo','1-D9SCFJ');
        jsGen.writeStringField('SyncComments','No changes possible in document');
        jsGen.writeStringField('Type','DPA');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.close();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        System.assert(req != null, 'DPA Inserted');
        req.requestBody = Blob.valueof(jsGen.getAsString());
        req.requestURI = '/services/apexrest/v1/CreateDPAResponse'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PSG_CreateDPAResponse.UpdateDPA();
        Test.stopTest();  
    }
    @isTest 
    public static void testServiceCallout3(){
        List<core_cpq_dpa_aln__c> dpaList = [select id,Name  from core_cpq_dpa_aln__c];
        System.assert(!dpaList.isEmpty(), 'DPA Inserted');
        JSONGenerator jsGen=JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeFieldName('ListOfDpaInterfaceAltera');
        jsGen.writeStartObject();
        jsGen.writeFieldName('DpaInterfaceAltera');
        jsGen.writeStartObject();
        jsGen.writeStringField('SAPDPANo','');
        jsGen.writeStringField('SAPDPAStatus','FAIL-ALN 1-9B1B2H already in SAP');
        jsGen.writeStringField('DPANo',dpaList[0].Name);
        jsGen.writeStringField('SyncComments','No changes possible in document');
        jsGen.writeStringField('Type','DPA');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.close();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(jsGen.getAsString());
        req.requestURI = '/services/apexrest/v1/CreateDPAResponse'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PSG_CreateDPAResponse.UpdateDPA();
        Test.stopTest();  
    }
    @isTest 
    public static void testServiceCallout4(){
        List<core_cpq_dpa_aln__c> dpaList = [select id,Name,core_cpq_change_flag__c  from core_cpq_dpa_aln__c];
        System.assert(!dpaList.isEmpty(), 'DPA Inserted');
        dpaList[1].core_cpq_dpa_aln_no_nbr__c=dpaList[1].Name;
        dpaList[1].core_cpq_status_txt__c='Hold';
        dpaList[1].core_cpq_change_flag__c='R';
        dpaList[1].core_cpq_record_type_identifier__c='ALN';
        dpaList[1].RecordTypeId=[Select Id from RecordType where sObjectType='core_cpq_dpa_aln__c' and developername='PSG_ALN' Limit 1].Id;
        update dpaList[1];
        dpaList[0].core_cpq_change_flag__c='R';
        dpaList[0].core_cpq_replace_aln_txt__c=dpaList[1].core_cpq_dpa_aln_no_nbr__c;
        update dpaList[0];
        JSONGenerator jsGen=JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeFieldName('ListOfDpaInterfaceAltera');
        jsGen.writeStartObject();
        jsGen.writeFieldName('DpaInterfaceAltera');
        jsGen.writeStartObject();
        jsGen.writeStringField('SAPDPANo','5428565');
        jsGen.writeStringField('SAPDPAStatus','SUCC-Success');
        jsGen.writeStringField('DPANo',dpaList[0].Name);
        jsGen.writeStringField('SyncComments','');
        jsGen.writeStringField('Type','ALN');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.close();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(jsGen.getAsString());
        req.requestURI = '/services/apexrest/v1/CreateDPAResponse'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PSG_CreateDPAResponse.UpdateDPA();
        Test.stopTest();  
    }
     
    @isTest 
    public static void testServiceCallout5(){
        List<core_cpq_dpa_aln__c> dpaList = [select id,Name,core_cpq_change_flag__c  from core_cpq_dpa_aln__c];
        System.assert(!dpaList.isEmpty(), 'DPA Inserted');
        dpaList[1].core_cpq_dpa_aln_no_nbr__c=dpaList[1].Name;
        dpaList[1].core_cpq_status_txt__c='Hold';
        dpaList[1].core_cpq_change_flag__c='R';
        dpaList[1].core_cpq_record_type_identifier__c='ALN';
        dpaList[1].RecordTypeId=[Select Id from RecordType where sObjectType='core_cpq_dpa_aln__c' and developername='PSG_ALN' Limit 1].Id;
        update dpaList[1];
        dpaList[0].core_cpq_change_flag__c='';
        dpaList[0].core_cpq_replace_aln_txt__c=dpaList[1].core_cpq_dpa_aln_no_nbr__c;
        update dpaList;
        JSONGenerator jsGen=JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeFieldName('ListOfDpaInterfaceAltera');
        jsGen.writeStartObject();
        jsGen.writeFieldName('DpaInterfaceAltera');
        jsGen.writeStartObject();
        jsGen.writeStringField('SAPDPANo','5428565');
        jsGen.writeStringField('SAPDPAStatus','SUCC-Success');
        jsGen.writeStringField('DPANo',dpaList[0].Name);
        jsGen.writeStringField('SyncComments','');
        jsGen.writeStringField('Type','ALN');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.close();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(jsGen.getAsString());
        req.requestURI = '/services/apexrest/v1/CreateDPAResponse'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PSG_CreateDPAResponse.UpdateDPA();
        JSONGenerator jsGen1=JSON.createGenerator(true);
        jsGen1.writeStartObject();
        jsGen1.writeFieldName('ListOfDpaInterfaceAltera');
        jsGen1.writeStartObject();
        jsGen1.writeFieldName('DpaInterfaceAltera');
        jsGen1.writeStartObject();
        jsGen1.writeStringField('SAPDPANo','5428565');
        jsGen1.writeStringField('SAPDPAStatus','SUCC-Success');
        jsGen1.writeStringField('DPANo',dpaList[1].Name);
        jsGen1.writeStringField('SyncComments','');
        jsGen1.writeStringField('Type','ALN');
        jsGen1.writeEndObject();
        jsGen1.writeEndObject();
        jsGen1.writeEndObject();
        jsGen1.close();
        req.requestBody = Blob.valueof(jsGen1.getAsString());
        req.requestURI = '/services/apexrest/v1/CreateDPAResponse'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        PSG_CreateDPAResponse.UpdateDPA();
        req.requestBody = Blob.valueof('/"{');
        PSG_CreateDPAResponse.UpdateDPA();
        Test.stopTest();  
    }
    */
}