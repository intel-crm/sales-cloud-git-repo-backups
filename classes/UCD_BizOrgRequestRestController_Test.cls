@IsTest
public class UCD_BizOrgRequestRestController_Test {
	@isTest
    static void testPostMethod1(){
        UCD_BizOrgRequestRestModel.AddressesWrap address = new UCD_BizOrgRequestRestModel.AddressesWrap();
        address.CountryCode = 'TestCountryCode';
        address.CountryName = 'TestCountry';
        address.TypeCode = 'TestTypeCode';
        
        UCD_BizOrgRequestRestModel.ElectronicAddressesWrap elecAddress = new UCD_BizOrgRequestRestModel.ElectronicAddressesWrap();
        elecAddress.TypeCode = 'TestTypeCode';
        elecAddress.Value = 'TestValue';
        
        UCD_BizOrgRequestRestModel.CustomerProcessEngagmentWrap customerPro = new UCD_BizOrgRequestRestModel.CustomerProcessEngagmentWrap();
        customerPro.ProcessCode = 'TestProcessCode';
        
        UCD_BizOrgRequestRestModel restModel = new UCD_BizOrgRequestRestModel();
        restModel.Name = 'Test';
        restModel.CustomerAggregationTypeCode = 'TestCustomerAggregationTypeCode';
        restModel.ContactEmailId = 'Test@test.com';
        restModel.TaxId = 'TestTaxId';
        restModel.Addresses = new List<UCD_BizOrgRequestRestModel.AddressesWrap> {address};
        restModel.ElectronicAddresses = new List<UCD_BizOrgRequestRestModel.ElectronicAddressesWrap> {elecAddress};
        restModel.CustomerProcessEngagment = new List<UCD_BizOrgRequestRestModel.CustomerProcessEngagmentWrap> {customerPro};
            
        String jsonReq = JSON.serialize(restModel);
        
        RestRequest request = new RestRequest();
        request.requestUri =System.Url.getSalesforceBaseUrl()+'/services/apexrest/BusinessOrganizationRequest';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(jsonReq);
		
        RestContext.request = request;
		UCD_BizOrgRequestRestModel.ResponseWrap response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
    }
    @isTest
    static void testPostMethod2(){
        UCD_BizOrgRequestRestModel.AddressesWrap address = new UCD_BizOrgRequestRestModel.AddressesWrap();
        address.CountryCode = 'TestCountryCode';
        address.CountryName = 'TestCountry';
        address.TypeCode = 'TestTypeCode';
        
        UCD_BizOrgRequestRestModel.ElectronicAddressesWrap elecAddress = new UCD_BizOrgRequestRestModel.ElectronicAddressesWrap();
        elecAddress.TypeCode = 'TestTypeCode';
        elecAddress.Value = 'TestValue';
        
        UCD_BizOrgRequestRestModel.CustomerProcessEngagmentWrap customerPro = new UCD_BizOrgRequestRestModel.CustomerProcessEngagmentWrap();
        customerPro.ProcessCode = 'TestProcessCode';
        
        UCD_BizOrgRequestRestModel restModel = new UCD_BizOrgRequestRestModel();
        restModel.Name = null;
        restModel.CustomerAggregationTypeCode = 'TestCustomerAggregationTypeCode';
        restModel.ContactEmailId = 'Test@test.com';
        restModel.TaxId = 'TestTaxId';
        restModel.Addresses = new List<UCD_BizOrgRequestRestModel.AddressesWrap> {address};
        restModel.ElectronicAddresses = new List<UCD_BizOrgRequestRestModel.ElectronicAddressesWrap> {elecAddress};
        restModel.CustomerProcessEngagment = new List<UCD_BizOrgRequestRestModel.CustomerProcessEngagmentWrap> {customerPro};
            
        String jsonReq = JSON.serialize(restModel);
        
        RestRequest request = new RestRequest();
        request.requestUri =System.Url.getSalesforceBaseUrl()+'/services/apexrest/BusinessOrganizationRequest';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(jsonReq);
		
        RestContext.request = request;
		UCD_BizOrgRequestRestModel.ResponseWrap response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
    }
    
    @isTest
    static void testPostMethod3(){
        
        UCD_BizOrgRequestRestModel.ElectronicAddressesWrap elecAddress = new UCD_BizOrgRequestRestModel.ElectronicAddressesWrap();
        elecAddress.TypeCode = 'TestTypeCode';
        elecAddress.Value = 'TestValue';
        
        UCD_BizOrgRequestRestModel.CustomerProcessEngagmentWrap customerPro = new UCD_BizOrgRequestRestModel.CustomerProcessEngagmentWrap();
        customerPro.ProcessCode = 'TestProcessCode';
        
        UCD_BizOrgRequestRestModel restModel = new UCD_BizOrgRequestRestModel();
        restModel.Name = null;
        restModel.CustomerAggregationTypeCode = 'TestCustomerAggregationTypeCode';
        restModel.ContactEmailId = 'Test@test.com';
        restModel.TaxId = 'TestTaxId';
        restModel.ElectronicAddresses = new List<UCD_BizOrgRequestRestModel.ElectronicAddressesWrap> {elecAddress};
        restModel.CustomerProcessEngagment = new List<UCD_BizOrgRequestRestModel.CustomerProcessEngagmentWrap> {customerPro};
            
        String jsonReq = JSON.serialize(restModel);
        
        RestRequest request = new RestRequest();
        request.requestUri =System.Url.getSalesforceBaseUrl()+'/services/apexrest/BusinessOrganizationRequest';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(jsonReq);
		
        RestContext.request = request;
		UCD_BizOrgRequestRestModel.ResponseWrap response = UCD_BizOrgRequestRestController.CreatBusinessOrganizationRequest();
    }
}