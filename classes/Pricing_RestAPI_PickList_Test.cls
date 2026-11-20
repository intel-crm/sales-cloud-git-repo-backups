/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_PickList_Test 
* Version     : 1.0 
* Created Date: 06 Oct 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         06/10/2020              Test class for Rest API to send Piklist field values as response to the calling system
*****************************************************************************************************************************************/
@isTest
public class Pricing_RestAPI_PickList_Test {
    
    @testSetup
    private static void createData(){
        Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        Pricing_Test_Utility.createPriceBook();
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();          
        System.runAs(lstUsers2[0])
        {
            test.startTest();
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Rest_API_PickList_Test');
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            //Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            test.stopTest();
            
            List<Pricing_Picklist_FieldNames_Mapping__mdt> fldMappingMdt = [SELECT MasterLabel,Pricing_FieldAPI_Nm__c,Pricing_ObjectAPI_Pkl__c,Pricing_RecordTypeAPI_Pkl__c
                                                                            FROM Pricing_Picklist_FieldNames_Mapping__mdt 
                                                                            WHERE Pricing_RecordTypeAPI_Pkl__c!=null AND Pricing_IsActive_Ind__c=True];
            
            
            String fldKey = 'TelstFld';
            List<Pricing_Picklist_Metadata__c> pdConfigs = new List<Pricing_Picklist_Metadata__c>();
            for(Integer i=0;i<50;i++){
                Pricing_Picklist_Metadata__c pdConfig = new Pricing_Picklist_Metadata__c();
                pdConfig.Pricing_Field_Label_Txt__c = fldMappingMdt[0].MasterLabel;
                pdConfig.Pricing_Field_API_Nm__c = fldMappingMdt[0].Pricing_FieldAPI_Nm__c;
                pdConfig.Pricing_Picklist_Item_Label_Txt__c = fldKey+i;
                pdConfig.Pricing_Picklist_Item_Value_Txt__c = fldKey+i;
                pdConfig.Pricing_Object_API_Nm__c = fldMappingMdt[0].Pricing_ObjectAPI_Pkl__c;
                //pdConfig.RecordTypeId = fldMappingMdt[0].Pricing_RecordTypeAPI_Pkl__c;
                pdConfig.RecordTypeId = Schema.SObjectType.Pricing_Picklist_Metadata__c.getRecordTypeInfosByName().get(fldMappingMdt[0].Pricing_RecordTypeAPI_Pkl__c).getRecordTypeId();
                pdConfig.Pricing_IsActive_Ind__c = True;
                pdConfigs.add(pdConfig);
            }
            insert pdConfigs;
        }
    }
    
    @isTest
    private static void testGetValuesWithRecordType(){
        User usr = [SELECT id FROM User WHERE email='Rest_API_PickList_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            List<Pricing_Picklist_FieldNames_Mapping__mdt> fldMappingMdt = [SELECT MasterLabel FROM Pricing_Picklist_FieldNames_Mapping__mdt 
                                                                            WHERE Pricing_RecordTypeAPI_Pkl__c!=null AND Pricing_IsActive_Ind__c=True];
            RestRequest request = new RestRequest();
            request.requestUri = '/v1.0/quoterequest/picklistutility/'+fldMappingMdt[0].MasterLabel;
            request.httpMethod = 'GET';
            RestContext.request = request;
            
            Pricing_RestAPI_Response resp = Pricing_RestAPI_PickList.doGet();
            system.assert(resp.successContent!=null);
            test.stopTest();
        }
    }
    @isTest 
    private static void testGetValuesWithOutRecordType(){
        User usr = [SELECT id FROM User WHERE email='Rest_API_PickList_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = new RestRequest();
            request.requestUri = '/v1.0/quoterequest/picklistutility/PerformanceMetricsUsed';
            request.httpMethod = 'GET';
            RestContext.request = request;
            
            Pricing_RestAPI_Response resp = Pricing_RestAPI_PickList.doGet();
            system.assert(resp.successContent!=null);
            test.stopTest();
        }
    }
    @isTest 
    private static void testGetValuesWithRecordType_NoDataException(){
        User usr = [SELECT id FROM User WHERE email='Rest_API_PickList_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            List<Pricing_Picklist_FieldNames_Mapping__mdt> fldMappingMdt = [SELECT MasterLabel FROM Pricing_Picklist_FieldNames_Mapping__mdt 
                                                                            WHERE Pricing_RecordTypeAPI_Pkl__c!=null AND Pricing_IsActive_Ind__c=True];
            RestRequest request = new RestRequest();
            request.requestUri = '/v1.0/quoterequest/picklistutility/'+fldMappingMdt[1].MasterLabel;
            request.httpMethod = 'GET';
            RestContext.request = request;
            
            Pricing_RestAPI_Response resp = Pricing_RestAPI_PickList.doGet();
            system.assert(resp.errorContent!=null);
            test.stopTest();
        }
    }
    
    @isTest 
    private static void testWrongFieldNameInput(){
        User usr = [SELECT id FROM User WHERE email='Rest_API_PickList_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = new RestRequest();
            request.requestUri = '/v1.0/quoterequest/picklistutility/Application12';
            request.httpMethod = 'GET';
            RestContext.request = request;
            
            Pricing_RestAPI_Response resp = Pricing_RestAPI_PickList.doGet();
            system.assert(resp.errorContent!=null);
            test.stopTest();
        }
    }
    @isTest 
    private static void testgetAllFieldNames(){
        User usr = [SELECT id FROM User WHERE email='Rest_API_PickList_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = new RestRequest();
            request.requestUri = '/v1.0/quoterequest/picklistutility/';
            request.httpMethod = 'GET';
            RestContext.request = request;
            
            Pricing_RestAPI_Response resp = Pricing_RestAPI_PickList.doGet();
            system.assert(resp.successContent!=null);
            test.stopTest();
        }
    }
    @isTest 
    private static void testgetEndCustomer(){
        User usr = [SELECT id FROM User WHERE email='Rest_API_PickList_Test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = new RestRequest();
            request.requestUri = '/v1.0/quoterequest/picklistutility/EndCustomer';
            request.httpMethod = 'GET';
            RestContext.request = request;
            
            Pricing_RestAPI_Response resp = Pricing_RestAPI_PickList.doGet();
            system.assert(resp.successContent==null);
            test.stopTest();
        }
    }
    @isTest 
    private static void testgetConsumptionValues(){
        User usr = [SELECT id,AccountId FROM User WHERE email='Rest_API_PickList_Test@noemail.com'];
        Pricing_ConsumptionAccountMapping__c Consumption = new Pricing_ConsumptionAccountMapping__c(Name = 'Test Consumption',Pricing_Account_Nm__c = usr.AccountId,Pricing_Consumption_Type_Nm__c = 'Consumption Platform',Pricing_Active_ind__c = true);
        insert Consumption;
        system.runAs(usr){
            test.startTest();
            RestRequest request = new RestRequest();
            request.requestUri = '/v2.0/quoterequest/picklistutility/ConsumptionPlatform';
            request.httpMethod = 'GET';
            RestContext.request = request;
            List<Pricing_RestAPI_PicklistHandler.PickListEntry> pickListValues = Pricing_RestAPI_PicklistHandler.getConsumptionValues('Consumption Platform',usr);
            system.assertEquals(1,pickListValues.size());
            
            test.stopTest();
        }
    }
    
    
}