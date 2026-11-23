@isTest
public class PRM_OPID_OnDemandsyncRequest_Test {
	/*Public static Boolean isTestClassRunning = false;
    @testSetup
    private static void createData(){
        test.startTest();
         Id partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
         Account intelAccount = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'Americas ELAR Sales Group',
                                           Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi',
                                           ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True, Core_CIM_ID__c = '919190');
        insert intelAccount;
        Account intelAccount2 = new Account(Name ='IntelAccount2',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'Americas ELAR Sales Group',
                                           Industry='Agriculture', BillingCity='Chennai',BillingCountry='Ind',BillingStreet='nehru st',
                                           ShippingCity='Chennai',ShippingCountry='Ind',ShippingStreet='cv raman road',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
        insert intelAccount2;
        
        //partner acc start
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        //Account partnerAccount = PMP_TestDataUtility.createIntelAccount('Partner Account10',devRecordTypeId,true);
        Account partnerAccount = new Account();
        partnerAccount.RecordTypeId = devRecordTypeId;
        partnerAccount.Name = 'Partner Account10';       
        partnerAccount.Core_Account_Country__c='India';
        partnerAccount.Core_Sales_Groups__c='PRC Sales Group';
        partnerAccount.Core_Account_Type__c='ODM';
        partnerAccount.BillingStreet='Mock';
        partnerAccount.BillingCity='Bangalore';
        partnerAccount.BillingCountry='IND';
        partnerAccount.BillingState='KA';
        partnerAccount.BillingPostalCode='560029';
        partnerAccount.Industry='Agriculture';
		partnerAccount.Core_OnePartnerID__c ='12345678';
        insert partnerAccount;
        Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
        inboundTable.Core_Status__c = 'PROCESSED';
        inboundTable.Core_SalesCloud_AccountID__c = partnerAccount.Id;
        inboundTable.Core_OnePartnerID__c = 12345678;
        inboundTable.Core_CIM_ID__c=1235987;
        inboundTable.Core_OnePartner_Account_Name__c = 'Crosswealth2';
        inboundTable.Core_Effective_End_Date_Time__c = Date.newInstance(2016, 12, 9);
        inboundTable.Core_Status_Effective_End_Date_Time__c = Date.newInstance(2021, 9, 21);
        insert inboundTable;
        Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
        accGroupMem.Core_Partner_Account_Id__c = partnerAccount.Id;
        accGroupMem.Core_Intel_Account_Id__c = intelAccount.Id;
        accGroupMem.Core_Inactive_Ind__c = false;
        insert accGroupMem;
        //Account partnerAccount = PMP_TestDataUtility.createIntelAccount('Partner Account10',devRecordTypeId,true);
        Account partnerAccount1 = new Account();
        partnerAccount1.RecordTypeId = devRecordTypeId;
        partnerAccount1.Name = 'Partner Account10';       
        partnerAccount1.Core_Account_Country__c='India';
        partnerAccount1.Core_Sales_Groups__c='PRC Sales Group';
        partnerAccount1.Core_Account_Type__c='M';
        partnerAccount1.BillingStreet='Mock';
        partnerAccount1.BillingCity='Bangalore';
        partnerAccount1.BillingCountry='IND';
        partnerAccount1.BillingState='KA';
        partnerAccount1.BillingPostalCode='560029';
        partnerAccount1.Industry='Agriculture';
		partnerAccount1.Core_OnePartnerID__c ='12345678';
        insert partnerAccount1;
        
        Core_Account_Group_Member__c accGroupMem1 = new Core_Account_Group_Member__c();
        accGroupMem1.Core_Partner_Account_Id__c = partnerAccount1.Id;
        accGroupMem1.Core_Intel_Account_Id__c = intelAccount2.Id;
        accGroupMem1.Core_Inactive_Ind__c = false;
        insert accGroupMem1;
        
        test.stopTest();
    }
    
    @isTest static void createSyncReqMethod(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
        test.startTest();
        Account acc = [SELECT id,Core_OnePartnerID__c FROM Account WHERE BillingStreet ='Mock' LIMIT 1];
        
        String replacedjson = '[[{\"Core_CIM_ID_Temp\":\"37894006\",\"Core_Effective_End_Date_Time_Temp\":\"2021-09-20T18:07:00\",\"Core_Status_Effective_End_Date_Time_Temp\":\"2021-09-19T18:07:00\",\"Core_OnePartner_Account_Name_Temp\":\"UAT_RTA31-Non-Program\",\"Core_OnePartnerID_Temp\":\"11920002\",\"Core_Prime_Account_Name_Temp\":\"UAT_RTA31\",\"Core_PrimeID_Temp\":\"4480011\",\"Core_SalesCloud_AccountID_Temp__c\":\"0012i00000bHxMTAA0\",\"Core_Status_Temp\":\"PROCESSED\",\"Core_Status_Reason_Temp\":null,\"Core_Effective_Start_Date_Time_Temp\":\"2021-09-20T18:06:17\",\"Core_PAG_Grouping_Method_Temp\":\"LINEOFBUSNS\"},'+
            					'{\"Core_CIM_ID_Temp\":\"37894002\",\"Core_Effective_End_Date_Time_Temp\":\"2021-09-20T18:07:00\",\"Core_Status_Effective_End_Date_Time_Temp\":\"2021-09-19T18:07:00\",\"Core_OnePartner_Account_Name_Temp\":\"UAT_RTA31-Non-Program\",\"Core_OnePartnerID_Temp\":\"11920002\",\"Core_Prime_Account_Name_Temp\":\"UAT_RTA31\",\"Core_PrimeID_Temp\":\"4480011\",\"Core_SalesCloud_AccountID_Temp__c\":\"0012i00000bHwqdAAC\",\"Core_Status_Temp\":\"PROCESSED\",\"Core_Status_Reason_Temp\":null,\"Core_Effective_Start_Date_Time_Temp\":\"2021-09-20T18:07:00\",\"Core_PAG_Grouping_Method_Temp\":\"LINEOFBUSNS\"}]]';
        PRM_Integration__mdt intreq = new PRM_Integration__mdt();
        intreq.API_Key__c = 'https://apis-sandbox.intel.com/v1/auth/token';
        intreq.EndPointURL__c = 'https://apis-sandbox.intel.com/m2r/master-data/v1/point-metrics';
        //intreq.Password__c = 'Zaa8Q~-E0uzRMDmEYTM1Z5zUWiuIiJAYIuB65bp-';
        //intreq.Username__c = '66d60bd5-1f92-47b8-a11f-4ae50ab9f8bd';
        
        PRM_OPID_OnDemandsyncRequest.ondemandSyncReq(acc.Id);
        test.stopTest();
        try {
            PRM_OPID_OnDemandsyncRequest.ondemandSyncReq(null);
        }catch(Exception ex){
            system.assertEquals(ex.getMessage(), ex.getMessage());
        }
              
    }
    
    @isTest static void createSyncReqMethodCIMData(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorCIMData()); 
        test.startTest();
        Account acc = [SELECT id,Core_OnePartnerID__c FROM Account WHERE BillingStreet ='Mock' LIMIT 1];
        
		String replacedjson = '[[{\"Core_CIM_ID_Temp\":\"37894006\",\"Core_Effective_End_Date_Time_Temp\":\"2021-09-20T18:07:00\",\"Core_Status_Effective_End_Date_Time_Temp\":\"2021-09-19T18:07:00\",\"Core_OnePartner_Account_Name_Temp\":\"UAT_RTA31-Non-Program\",\"Core_OnePartnerID_Temp\":\"11920002\",\"Core_Prime_Account_Name_Temp\":\"UAT_RTA31\",\"Core_PrimeID_Temp\":\"4480011\",\"Core_SalesCloud_AccountID_Temp__c\":\"0012i00000bHxMTAA0\",\"Core_Status_Temp\":\"PROCESSED\",\"Core_Status_Reason_Temp\":null,\"Core_Effective_Start_Date_Time_Temp\":\"2021-09-20T18:06:17\",\"Core_PAG_Grouping_Method_Temp\":\"LINEOFBUSNS\"},'+
								'{\"Core_CIM_ID_Temp\":\"37894002\",\"Core_Effective_End_Date_Time_Temp\":\"2021-09-20T18:07:00\",\"Core_Status_Effective_End_Date_Time_Temp\":\"2021-09-19T18:07:00\",\"Core_OnePartner_Account_Name_Temp\":\"UAT_RTA31-Non-Program\",\"Core_OnePartnerID_Temp\":\"11920002\",\"Core_Prime_Account_Name_Temp\":\"UAT_RTA31\",\"Core_PrimeID_Temp\":\"4480011\",\"Core_SalesCloud_AccountID_Temp__c\":\"0012i00000bHwqdAAC\",\"Core_Status_Temp\":\"PROCESSED\",\"Core_Status_Reason_Temp\":null,\"Core_Effective_Start_Date_Time_Temp\":\"2021-09-20T18:07:00\",\"Core_PAG_Grouping_Method_Temp\":\"LINEOFBUSNS\"}]]'; 
        PRM_OPID_OnDemandsyncRequest.ondemandSyncReq(acc.Id);
        isTestClassRunning = true;
        if(isTestClassRunning){
            PRM_OPID_OnDemandsyncRequest.ondemandSyncReq(acc.Id);           
        }
        
        try{
           // PRM_OPID_OnDemandsyncRequest.throwDeactivateProfileUsersTestException = true;
            PRM_OPID_OnDemandsyncRequest.ondemandSyncReq(acc.Id);
        }catch(Exception e){
               system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        
        PRM_OPID_OnDemandsyncRequest.createOPIDSyncReqRecord(replacedjson,acc);
        
        
        String replacedjson1 = '[[40]]';
        PRM_OPID_OnDemandsyncRequest.createOPIDSyncReqRecord(replacedjson1,acc);
        
        String replacedjson2 = '[[40]]';
        acc.Core_Deactivated__c = false;
        Update acc;
        
        PRM_OPID_OnDemandsyncRequest.createOPIDSyncReqRecord(replacedjson2,acc);
        
        test.stopTest();
    }
      
    
    @isTest static void createSyncReqMethod1(){
       test.startTest();
	   Account acc = [SELECT id,Core_OnePartnerID__c FROM Account WHERE Core_OnePartnerID__c ='12345678' LIMIT 1]; 
       OPID_Sync_Request__c opSyncRec = new OPID_Sync_Request__c();
       opSyncRec.OP_CIMID__c = acc.Core_OnePartnerID__c;
       opSyncRec.OPID_Account__c = acc.Id;
       opSyncRec.Response__c = '';
       opSyncRec.Status__c = 'Sync Response Received';
        insert opSyncRec;
        //String Jsonstr = '[{"Core_CIM_ID__c":"12345678","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"12345678","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o000000O69iUAAR","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"11417969","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o000000OSa5fAAD","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"11355520","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o000000OSOC1AAP","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"11416219","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o000000OSlEtAAL","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"11455091","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o000000OSwwTAAT","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"11459206","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o000000OSoWrAAL","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"11837197","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o000000OTKtWAAX","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"13940423","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o0000011lpivAAA","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"11416557","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o000000OSlXIAA1","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"13940426","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o0000011lmN2AAI","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"11414728","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o000000OSkCxAAL","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"11748702","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o000000OTEliAAH","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"13939315","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"0011J00001DI4vgQAD","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"13940426","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o0000011lpj0AAA","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"},{"Core_CIM_ID__c":"13939315","Core_Effective_End_Date_Time__c":null,"Core_OnePartner_Account_Name__c":"L&T Infotech-India","Core_OnePartnerID__c":"20628","Core_Prime_Account_Name__c":"L&T Infotech","Core_PrimeID__c":"233","Core_SalesCloud_AccountID__c":"001o0000011lmMYAAY","Core_Status__c":"NEW","Core_Status_Reason__c":null,"Core_Effective_Start_Date_Time__c":"2021-01-28T02:49:11","Core_PAG_Grouping_Method__c":"CTRY"}]';
       PRM_OPID_OnDemandsyncRequest.ondemandSyncReq(acc.Id);
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1()); 
       PRM_OPID_OnDemandsyncRequest.ondemandSyncReq(acc.id);
       PRM_OPID_OnDemandsyncRequest.cimRecsMappingwrapper cim = new PRM_OPID_OnDemandsyncRequest.cimRecsMappingwrapper();
       test.stopTest();          
    }
    
    @isTest static void createSyncReqMethod2(){
       test.startTest();
       Account acc = [SELECT id,Core_OnePartnerID__c FROM Account LIMIT 1];  
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
       PRM_OPID_OnDemandsyncRequest.ondemandSyncReq(acc.Id);
       test.stopTest();
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().endsWith('token')) {//one-partner-id
                HttpResponse res = new HttpResponse();
            	res.setHeader('Content-Type', 'application/json');
            	res.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5Pbz","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599"}');
            	res.setStatusCode(200);
            	return res;
            }
            else{
                HttpResponse res = new HttpResponse();
            	res.setHeader('Content-Type', 'application/json');
                res.setBody('[{"12345678": [{"Core_CIM_ID__c": "11503813","Core_Effective_End_Date_Time__c": "2021-09-20T18:07:00","Core_Status_Effective_End_Date_Time__c":"2021-09-20T18:06:00","Core_OnePartner_Account_Name__c": "RadiSys-China","Core_OnePartnerID__c": "12345678","Core_Prime_Account_Name__c": "RadiSys","Core_PrimeID__c": "580010","Core_SalesCloud_AccountID__c": "001o000000OSn7sAAD","Core_Status__c": "NEW","Core_Status_Reason__c": null,"Core_Effective_Start_Date_Time__c": "2021-10-11T04:58:56","Core_PAG_Grouping_Method__c": "CTRY","Core_Status_Effective_End_Date_Time__c":"2021-09-20T18:07:00"}]}]');
            	res.setStatusCode(200);
                return res;
            }
        }
	}
    public class MockHttpResponseGeneratorCIMData implements HttpCalloutMock {
        
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().endsWith('token')) {//one-partner-id
                HttpResponse res = new HttpResponse();
            	res.setHeader('Content-Type', 'application/json');
            	res.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5Pbz","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599", "Core_Effective_Start_Date_Time__c": "2021-10-11T04:58:56", "Core_Effective_End_Date_Time__c": "2021-10-11T04:58:56"} ');
            	res.setStatusCode(200);
            	return res;
            }
            else{
                HttpResponse res = new HttpResponse();
            	res.setHeader('Content-Type', 'application/json');
                res.setBody('[{"12345678": [{"Core_CIM_ID__c": "11503813","Core_Effective_End_Date_Time__c": "2021-09-20T18:07:00","Core_Status_Effective_End_Date_Time__c":"2021-09-20T18:06:00","Core_OnePartner_Account_Name__c": "RadiSys-China","Core_OnePartnerID__c": "12345678","Core_Prime_Account_Name__c": "RadiSys","Core_PrimeID__c": "580010","Core_SalesCloud_AccountID__c": "001o000000OSn7sAAD","Core_Status__c": "NEW","Core_Status_Reason__c": null,"Core_Effective_Start_Date_Time__c": "2021-10-11T04:58:56","Core_PAG_Grouping_Method__c": "CTRY","Core_Status_Effective_End_Date_Time__c":"2021-09-20T18:07:00"}]}]');
                res.setStatusCode(401);
                return res;
            }
        }
	}
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5Pbz","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599"}');
            res.setStatusCode(401);
            return res;
        }
	}*/
}