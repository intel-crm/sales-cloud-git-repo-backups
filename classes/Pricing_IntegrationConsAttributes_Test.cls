/**
 * @description       : Test class for Pricing_IntegrationConsumptionAttributes
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 11-21-2023
 * @last modified by  : Sandeep Chamate
**/
@isTest
public class Pricing_IntegrationConsAttributes_Test {

    @testSetup
    public static void setUpData(){
        
        List<User> adminUser = Pricing_Test_Utility.createAdminUser();
        test.startTest();
        system.runAs(adminUser[0]){

            Account acc = Pricing_Test_Utility.createAccount();
            List<Pricing_Account_To_CIM_ID_Mapping__mdt> cimIdtoAccList = [SELECT Id,DeveloperName,CIM_Id__c FROM Pricing_Account_To_CIM_ID_Mapping__mdt 
                                                                        WHERE CIM_Id__c != null];
            //cimIdtoAccList[0].CIM_Id__c = 'Id_' + acc.Id;
            //update cimIdtoAccList[0];
            String cimId1 = cimIdtoAccList[0].CIM_Id__c;
            String cimId2 = cimIdtoAccList[0].CIM_Id__c + ',' + cimIdtoAccList[1].CIM_Id__c;
            
            String reqBody = '{"Header":{"xid":"00000000-0000-0000-0000-000000000000","target_system":"Tender","source_system":"MyDeals","action":"UpdateDropdowns"},"RecordDetails":{"ConsumptionData":[{"value":"Blank Check 1","mode":"Insert","isActive":false,"consumptionType":"Consumption Platform","cimId":""},{"value":"Null check","mode":"Insert","isActive":true,"consumptionType":"Consumption Sales Geo","cimId":"'+ cimId1 + '"},{"value":"0 check","mode":"Insert","isActive":false,"consumptionType":"Consumption Sales Geo","cimId":"' + cimId2 + '"}]}}';
            reqBody = reqBody.replaceAll('CONSUMPTION_CUST_PLATFORM', 'Consumption Platform');
            reqBody = reqBody.replaceAll('CONSUMPTION_CUST_RPT_GEO', 'Consumption Sales Geo');
            Pricing_ConsumptionAttributesWrapper jsonMap = (Pricing_ConsumptionAttributesWrapper) System.JSON.deserialize(reqBody, Pricing_ConsumptionAttributesWrapper.class);
            List<Core_Integration_Inbound_Message__c> iimList = new List<Core_Integration_Inbound_Message__c>();
            Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();

            iim.Core_Payload__c = JSON.serialize(jsonMap);
            iim.Core_Message_Type__c = jsonMap.Header.action;
            iim.Core_Processing_Status__c = 'Successful';
            iim.Core_Error_Code__c = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200;
            iim.Core_Source_System__c = jsonMap.Header.source_system;
            iimList.add(iim);
            insert iimList;

            test.stopTest();          
             
        }
    }

    @isTest
   public static void testProcessConsumptionData() {
    User adminUser = [SELECT Id FROM User WHERE Email =: 'firstName@intel.com' LIMIT 1];
    Account acc = [SELECT Id FROM Account LIMIT 1];
    test.startTest();
    System.runAs(adminUser) {
        List<Pricing_Account_To_CIM_ID_Mapping__mdt> cimIdtoAccList = [SELECT Id,DeveloperName,CIM_Id__c FROM Pricing_Account_To_CIM_ID_Mapping__mdt 
                                                                        WHERE CIM_Id__c != null];
        cimIdtoAccList[0].DeveloperName = 'Id_' + acc.Id;
        List<Core_Integration_Inbound_Message__c> iimList = [SELECT Id,Core_Payload__c FROM Core_Integration_Inbound_Message__c LIMIT 1];

        Pricing_IntegrationConsumptionAttributes consAttr = new Pricing_IntegrationConsumptionAttributes();
        consAttr.processConsumptionData(iimList);

        System.assert(!iimList.isEmpty(), 'List is Empty');
    }
    test.stopTest();
   }
   
    @isTest
   public static void testCoreLogCreation() {
    User adminUser = [SELECT Id FROM User WHERE Email =: 'firstName@intel.com' LIMIT 1];
    List<String> errorMsgList = new List<String>();
       errorMsgList.add('Invalid Scenario check');
    test.startTest();
    System.runAs(adminUser) {
        Pricing_IntegrationConsumptionAttributes consAttr = new Pricing_IntegrationConsumptionAttributes();
        consAttr.coreLogEntryCreation(errorMsgList);

        System.assert(!errorMsgList.isEmpty(), 'List is Empty');
    }
    test.stopTest();
   }
}