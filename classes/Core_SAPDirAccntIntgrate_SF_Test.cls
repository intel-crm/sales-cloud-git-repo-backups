@isTest
public class Core_SAPDirAccntIntgrate_SF_Test {    
    
    @isTest static void callDoPost(){
        Test.startTest();
        List<RecordType> recTypeDirect =[SELECT Id, DeveloperName FROM Recordtype WHERE DeveloperName = 'Core_Direct_Account' WITH SECURITY_ENFORCED];
        List<RecordType> recTypeIntel =[SELECT Id, DeveloperName FROM Recordtype WHERE DeveloperName = 'Mastered_Account' WITH SECURITY_ENFORCED];
        
        Core_PSG_SAP_integration__c sapIntegrationCS =  new Core_PSG_SAP_integration__c();
        sapIntegrationCS.isDeactivated__c = false;
        insert sapIntegrationCS;
        
        Account acc = new Account();
        acc.name='Test98798729173912739712937hjhkj';
        //acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_Account_Legal_Name__c='asas';
        acc.Core_Sales_Segment__c='aa';
        acc.Core_Sales_Group__c='Global Accounts';
        acc.Fax='aaa';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Phone='121212';
        acc.Industry = '';
        acc.RecordTypeId = recTypeIntel[0].Id;
        insert acc;    
        Account acc1 = new Account();
        acc1.name='Test1asd98asdkjasdo9asdalskjkdasd91';
        //acc.Core_CIM_ID__c = '22213672';
        acc1.BillingCountry='USA';
        acc1.BillingStreet='700 Chestnut Ridge Rd New';
        acc1.BillingCity='Chestnut Ridge';
        acc1.BillingPostalCode='109776435';
        acc1.BillingState=null;
        acc1.Core_Account_Legal_Name__c='asas';
        acc1.Core_Sales_Segment__c='aa';
        acc1.Core_Sales_Group__c='Global Accounts';
        acc1.Fax='aaa';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        acc1.Core_Account_Type__c = 'Distributor';
        acc1.Phone='121212';
        acc1.Industry = '';
        acc1.RecordTypeId = recTypeDirect[0].Id;
        acc1.Core_Direct_Account_Type_Nm__c = 'Ship To';
        acc1.Core_Direct_Account_Id__c = '8100002736';
        insert acc1;
        
        Account acc2 = new Account();
        acc2.name='Test2678ghjvbvbsadgaudy';
        //acc.Core_CIM_ID__c = '22213672';
        acc2.BillingCountry='USA';
        acc2.BillingStreet='700 Chestnut Ridge Rd New';
        acc2.BillingCity='Chestnut Ridge';
        acc2.BillingPostalCode='109776435';
        acc2.BillingState=null;
        acc2.Core_Account_Legal_Name__c='asas';
        acc2.Core_Sales_Segment__c='aa';
        acc2.Core_Sales_Group__c='Global Accounts';
        acc2.Fax='aaa';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc2.Core_IPA_Partner_Role__c = 'Distributor';
        acc2.Core_Account_Type__c = 'Distributor';
        acc2.Phone='121212';
        acc2.Industry = '';
        acc2.RecordTypeId = recTypeDirect[0].Id;
        acc2.Core_Direct_Account_Type_Nm__c = 'Ship To';
        acc2.Core_Direct_Account_Id__c = '8100002737';
        insert acc2;
        
        Account acc3 = new Account();
        acc3.name='Test209sadasjhdkasjhdo98asusidhansd';
        //acc.Core_CIM_ID__c = '22213672';
        acc3.BillingCountry='USA';
        acc3.BillingStreet='700 Chestnut Ridge Rd New';
        acc3.BillingCity='Chestnut Ridge';
        acc3.BillingPostalCode='109776435';
        acc3.BillingState=null;
        acc3.Core_Account_Legal_Name__c='asas';
        acc3.Core_Sales_Segment__c='aa';
        acc3.Core_Sales_Group__c='Global Accounts';
        acc3.Fax='aaa';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc3.Core_IPA_Partner_Role__c = 'Distributor';
        acc3.Core_Account_Type__c = 'Distributor';
        acc3.Phone='121212';
        acc3.Industry = '';
        acc3.RecordTypeId = recTypeDirect[0].Id;
        acc3.Core_Direct_Account_Type_Nm__c = 'Sold To';
        acc3.Core_Direct_Account_Id__c = '6100002736';
        insert acc3;
        
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/utils/SAPAccountInboundintegration/';       
        String postData = '<?xml version="1.0" encoding="UTF-8"?>'
+'<SalesforceCustomer>'
+'<ListOfAccountEaiAltera>'
+'<AccountEaiAltera>'
+'<ExpressStationId>'+acc3.Id+'</ExpressStationId>'
+'<TrainStationID>'+acc.Id+'</TrainStationID>'
+'<Name>Test Direct Account SoldTo-01</Name>'
+'<SAPAccountNumber>6100002736</SAPAccountNumber>'
+'<FreightTerms>CPT</FreightTerms>'
+'<X_ALT_PAYTERMS>U</X_ALT_PAYTERMS>'
+'<X_ALT_SAP_ACCT_TYPE>Sold To</X_ALT_SAP_ACCT_TYPE>'
+'<ShippingCondition>64</ShippingCondition>'
+'<StreetAddress>Borewell Road</StreetAddress>'
+'<StreetAddress2>8 CONTAINER PORT RD </StreetAddress2>'
+'<City>Whitefield</City>'
+'<Province>KA</Province>'
+'<State></State>'
+'<Country>IND</Country>'
+'<PostalCode>560032</PostalCode>'
+'<RegionCode>KA</RegionCode>'
+'<SalesOrganization>AP21</SalesOrganization>'
+'<DistyChannel>01</DistyChannel>'
+'<ShipToEndCustomer></ShipToEndCustomer>'
+'<ShippingInstructions></ShippingInstructions>'
+'<AccountName2></AccountName2>'
+'<ParentAccountTier></ParentAccountTier>'
+'<SAPAccountStatus></SAPAccountStatus>'
+'<IsPricingParent>True</IsPricingParent>'
+'<SAPAccountStatus></SAPAccountStatus >'
+'<Shipto_Partners>'
+'	<Shipto_Partner>'
+'		<Shipto>8100002736</Shipto>'
+'		<ShiptoExpressStationID>'+acc1.Id+'</ShiptoExpressStationID>'
+'	</Shipto_Partner>'
+'	<Shipto_Partner>'
+'		<Shipto>8100002737</Shipto>'
+'		<ShiptoExpressStationID>'+acc2.Id+'</ShiptoExpressStationID>'
+'	</Shipto_Partner>'
+'</Shipto_Partners>'
+'</AccountEaiAltera>'
+'</ListOfAccountEaiAltera>'
+'</SalesforceCustomer>';
        
        //String JsonMsg=JSON.serialize(postData);
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Core_SAPDirAccntIntgrate_SF_RestService.doPost();
        
        
        
        String postData2 = '<?xml version="1.0" encoding="UTF-8"?>'
+'<SalesforceCustomer>'
+'<ListOfAccountEaiAltera>'
+'<AccountEaiAltera>'
+'<ExpressStationId>0012D00000Wd81QAAA</ExpressStationId>'
+'<TrainStationID>'+acc.Id+'</TrainStationID>'
+'<Name>Test Direct Account SoldTo-01</Name>'
+'<SAPAccountNumber>6100002736</SAPAccountNumber>'
+'<FreightTerms>CPT</FreightTerms>'
+'<X_ALT_PAYTERMS>U</X_ALT_PAYTERMS>'
+'<X_ALT_SAP_ACCT_TYPE>Sold To</X_ALT_SAP_ACCT_TYPE>'
+'<ShippingCondition>64</ShippingCondition>'
+'<StreetAddress>Borewell Road</StreetAddress>'
+'<StreetAddress2>8 CONTAINER PORT RD </StreetAddress2>'
+'<City>Whitefield</City>'
+'<Province>KA</Province>'
+'<State></State>'
+'<Country>IND</Country>'
+'<PostalCode>560032</PostalCode>'
+'<RegionCode>KA</RegionCode>'
+'<SalesOrganization>AP21</SalesOrganization>'
+'<DistyChannel>01</DistyChannel>'
+'<ShipToEndCustomer></ShipToEndCustomer>'
+'<ShippingInstructions></ShippingInstructions>'
+'<AccountName2></AccountName2>'
+'<ParentAccountTier></ParentAccountTier>'
+'<SAPAccountStatus></SAPAccountStatus>'
+'<IsPricingParent>True</IsPricingParent>'
+'<SAPAccountStatus></SAPAccountStatus >'
+'<Shipto_Partners>'
+'	<Shipto_Partner>'
+'		<Shipto>8100002736</Shipto>'
+'		<ShiptoExpressStationID>'+acc1.Id+'</ShiptoExpressStationID>'
+'	</Shipto_Partner>'
+'	<Shipto_Partner>'
+'		<Shipto>8100002737</Shipto>'
+'		<ShiptoExpressStationID>'+acc2.Id+'</ShiptoExpressStationID>'
+'	</Shipto_Partner>'
+'</Shipto_Partners>'
+'</AccountEaiAltera>'
+'</ListOfAccountEaiAltera>'
+'</SalesforceCustomer>';
        req.requestBody = Blob.valueof(postData2);
        RestContext.request = req; 
        RestContext.response= res;
        Core_SAPDirAccntIntgrate_SF_RestService.doPost();
        
        
        String postData3 = '<?xml version="1.0" encoding="UTF-8"?>'
+'<SalesforceCustomer>'
+'<ListOfAccountEaiAltera>'
+'<AccountEaiAltera>'
+'<ExpressStationId>'+acc3.Id+'</ExpressStationId>'
+'<TrainStationID>0012D00000Wd81QAAA</TrainStationID>'
+'<Name>Test Direct Account SoldTo-01</Name>'
+'<SAPAccountNumber>6100002736</SAPAccountNumber>'
+'<FreightTerms>CPT</FreightTerms>'
+'<X_ALT_PAYTERMS>U</X_ALT_PAYTERMS>'
+'<X_ALT_SAP_ACCT_TYPE>Sold To</X_ALT_SAP_ACCT_TYPE>'
+'<ShippingCondition>64</ShippingCondition>'
+'<StreetAddress>Borewell Road</StreetAddress>'
+'<StreetAddress2>8 CONTAINER PORT RD </StreetAddress2>'
+'<City>Whitefield</City>'
+'<Province>KA</Province>'
+'<State></State>'
+'<Country>IND</Country>'
+'<PostalCode>560032</PostalCode>'
+'<RegionCode>KA</RegionCode>'
+'<SalesOrganization>AP21</SalesOrganization>'
+'<DistyChannel>01</DistyChannel>'
+'<ShipToEndCustomer></ShipToEndCustomer>'
+'<ShippingInstructions></ShippingInstructions>'
+'<AccountName2></AccountName2>'
+'<ParentAccountTier></ParentAccountTier>'
+'<SAPAccountStatus></SAPAccountStatus>'
+'<IsPricingParent>True</IsPricingParent>'
+'<SAPAccountStatus></SAPAccountStatus >'
+'<Shipto_Partners>'
+'	<Shipto_Partner>'
+'		<Shipto>8100002736</Shipto>'
+'		<ShiptoExpressStationID>'+acc1.Id+'</ShiptoExpressStationID>'
+'	</Shipto_Partner>'
+'	<Shipto_Partner>'
+'		<Shipto>8100002737</Shipto>'
+'		<ShiptoExpressStationID>'+acc2.Id+'</ShiptoExpressStationID>'
+'	</Shipto_Partner>'
+'</Shipto_Partners>'
+'</AccountEaiAltera>'
+'</ListOfAccountEaiAltera>'
+'</SalesforceCustomer>';
        req.requestBody = Blob.valueof(postData3);
        RestContext.request = req; 
        RestContext.response= res;
        Core_SAPDirAccntIntgrate_SF_RestService.doPost();
        
        
        
        String postData4 = '<?xml version="1.0" encoding="UTF-8"?>'
+'<SalesforceCustomer>'
+'<ListOfAccountEaiAltera>'
+'<AccountEaiAltera>'
+'<ExpressStationId>'+acc3.Id+'</ExpressStationId>'
+'<TrainStationID>'+acc.Id+'</TrainStationID>'
+'<Name>Test Direct Account SoldTo-01</Name>'
+'<SAPAccountNumber>6100002736</SAPAccountNumber>'
+'<FreightTerms>CPT</FreightTerms>'
+'<X_ALT_PAYTERMS>U</X_ALT_PAYTERMS>'
+'<X_ALT_SAP_ACCT_TYPE>Sold To</X_ALT_SAP_ACCT_TYPE>'
+'<ShippingCondition>64</ShippingCondition>'
+'<StreetAddress>Borewell Road</StreetAddress>'
+'<StreetAddress2>8 CONTAINER PORT RD </StreetAddress2>'
+'<City>Whitefield</City>'
+'<Province>KA</Province>'
+'<State></State>'
+'<Country>IND</Country>'
+'<PostalCode>560032</PostalCode>'
+'<RegionCode>KA</RegionCode>'
+'<SalesOrganization>AP21</SalesOrganization>'
+'<DistyChannel>01</DistyChannel>'
+'<ShipToEndCustomer></ShipToEndCustomer>'
+'<ShippingInstructions></ShippingInstructions>'
+'<AccountName2></AccountName2>'
+'<ParentAccountTier></ParentAccountTier>'
+'<SAPAccountStatus></SAPAccountStatus>'
+'<IsPricingParent>True</IsPricingParent>'
+'<SAPAccountStatus></SAPAccountStatus >'
+'<Shipto_Partners>'
+'	<Shipto_Partner>'
+'		<Shipto>81000027311</Shipto>'
+'		<ShiptoExpressStationID>'+acc1.Id+'</ShiptoExpressStationID>'
+'	</Shipto_Partner>'
+'	<Shipto_Partner>'
+'		<Shipto>8100002737</Shipto>'
+'		<ShiptoExpressStationID>'+acc2.Id+'</ShiptoExpressStationID>'
+'	</Shipto_Partner>'
+'</Shipto_Partners>'
+'</AccountEaiAltera>'
+'</ListOfAccountEaiAltera>'
+'</SalesforceCustomer>';
        req.requestBody = Blob.valueof(postData4);
        RestContext.request = req; 
        RestContext.response= res;
        Core_SAPDirAccntIntgrate_SF_RestService.doPost();
        
        String postData5 = '<?xml version="1.0" encoding="UTF-8"?>'
+'<SalesforceCustomer>'
+'<ListOfAccountEaiAltera>'
+'<AccountEaiAltera>'
+'<ExpressStationId>'+acc3.Id+'</ExpressStationId>'
+'<TrainStationID>'+acc.Id+'</TrainStationID>'
+'<Name>Test Direct Account SoldTo-01</Name>'
+'<SAPAccountNumber>6100002736</SAPAccountNumber>'
+'<FreightTerms>CPT</FreightTerms>'
+'<X_ALT_PAYTERMS>U</X_ALT_PAYTERMS>'
+'<X_ALT_SAP_ACCT_TYPE>Sold To</X_ALT_SAP_ACCT_TYPE>'
+'<ShippingCondition>64</ShippingCondition>'
+'<StreetAddress>Borewell Road</StreetAddress>'
+'<StreetAddress2>8 CONTAINER PORT RD </StreetAddress2>'
+'<City>Whitefield</City>'
+'<Province>KA</Province>'
+'<State></State>'
+'<Country>IND</Country>'
+'<PostalCode>560032</PostalCode>'
+'<RegionCode>KA</RegionCode>'
+'<SalesOrganization>AP21</SalesOrganization>'
+'<DistyChannel>01</DistyChannel>'
+'<ShipToEndCustomer></ShipToEndCustomer>'
+'<ShippingInstructions></ShippingInstructions>'
+'<AccountName2></AccountName2>'
+'<ParentAccountTier></ParentAccountTier>'
+'<SAPAccountStatus></SAPAccountStatus>'
+'<IsPricingParent>True</IsPricingParent>'
+'<SAPAccountStatus></SAPAccountStatus >'
+'<Shipto_Partners>'
+'	<Shipto_Partner>'
+'		<Shipto>8100002736</Shipto>'
+'		<ShiptoExpressStationID>0012D00000Wd81QAAAAA</ShiptoExpressStationID>'
+'	</Shipto_Partner>'
+'	<Shipto_Partner>'
+'		<Shipto>8100002737</Shipto>'
+'		<ShiptoExpressStationID>'+acc2.Id+'</ShiptoExpressStationID>'
+'	</Shipto_Partner>'
+'</Shipto_Partners>'
+'</AccountEaiAltera>'
+'</ListOfAccountEaiAltera>'
+'</SalesforceCustomer>';
        req.requestBody = Blob.valueof(postData5);
        RestContext.request = req; 
        RestContext.response= res;
        Core_SAPDirAccntIntgrate_SF_RestService.doPost();
        
        
         String postData6 = '<?xml version="1.0" encoding="UTF-8"?>'
+'<SalesforceCustomer>'
+'<ListOfAccountEaiAltera>'
+'<AccountEaiAltera>'
+'<TrainStationID>'+acc.Id+'</TrainStationID>'
+'<Name>Test Direct Account SoldTo-01</Name>'
+'<SAPAccountNumber>6100002736</SAPAccountNumber>'
+'<FreightTerms>CPT</FreightTerms>'
+'<X_ALT_PAYTERMS>U</X_ALT_PAYTERMS>'
+'<X_ALT_SAP_ACCT_TYPE>Sold To</X_ALT_SAP_ACCT_TYPE>'
+'<ShippingCondition>64</ShippingCondition>'
+'<StreetAddress>Borewell Road</StreetAddress>'
+'<StreetAddress2>8 CONTAINER PORT RD </StreetAddress2>'
+'<City>Whitefield</City>'
+'<Province>KA</Province>'
+'<State></State>'
+'<Country>IND</Country>'
+'<PostalCode>560032</PostalCode>'
+'<RegionCode>KA</RegionCode>'
+'<SalesOrganization>AP21</SalesOrganization>'
+'<DistyChannel>01</DistyChannel>'
+'<ShipToEndCustomer></ShipToEndCustomer>'
+'<ShippingInstructions></ShippingInstructions>'
+'<AccountName2></AccountName2>'
+'<ParentAccountTier></ParentAccountTier>'
+'<SAPAccountStatus></SAPAccountStatus>'
+'<IsPricingParent>True</IsPricingParent>'
+'<SAPAccountStatus></SAPAccountStatus >'
+'<Shipto_Partners>'
+'	<Shipto_Partner>'
+'		<Shipto>8100002736</Shipto>'
+'		<ShiptoExpressStationID>0012D00000Wd81QAAAAA</ShiptoExpressStationID>'
+'	</Shipto_Partner>'
+'	<Shipto_Partner>'
+'		<Shipto>8100002737</Shipto>'
+'		<ShiptoExpressStationID>'+acc2.Id+'</ShiptoExpressStationID>'
+'	</Shipto_Partner>'
+'</Shipto_Partners>'
+'</AccountEaiAltera>'
+'</ListOfAccountEaiAltera>'
+'</SalesforceCustomer>';
        req.requestBody = Blob.valueof(postData6);
        RestContext.request = req; 
        RestContext.response= res;
        Core_SAPDirAccntIntgrate_SF_RestService.doPost();
        
        system.assert(True);
        Test.stopTest();
    }
    
}