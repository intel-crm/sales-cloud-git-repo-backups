@isTest
public class UCD_BizOrgRequestController_test {

    @isTest static void UCD_BizOrgRequestController_testmethod()
    {   UCD_BizOrgRequestModel.AddressesWrap address = new UCD_BizOrgRequestModel.AddressesWrap();
        address.CountryCode = 'TestCountryCode';
        address.CountryName = 'TestCountry';
        address.TypeCode = 'TestTypeCode';
        
      UCD_BizOrgRequestModel.CustomerProcessEngagmentWrap customerPro = new UCD_BizOrgRequestModel.CustomerProcessEngagmentWrap();
        customerPro.ProcessCode = 'TestProcessCode';
        
 
        
        UCD_BizOrgRequestModel Model1 = new UCD_BizOrgRequestModel();
         Model1.Addresses = new List<UCD_BizOrgRequestModel.AddressesWrap> {address};
         Model1.CustomerAggregationTypeCode = 'TestCustomerAggregationTypeCode';
         Model1.CustomerProcessEngagment = new List<UCD_BizOrgRequestModel.CustomerProcessEngagmentWrap> {customerPro};
         Model1.Name = 'test';
   
       UCD_BizOrgRequestController.UCD_BizOrgRequestController(Model1);
        
    }
    
     @isTest static void UCD_BizOrgRequestController_testmethod1()
    {   UCD_BizOrgRequestModel.AddressesWrap address = new UCD_BizOrgRequestModel.AddressesWrap();
        address.CountryCode = 'TestCountryCode';
        address.CountryName = 'TestCountry';
        address.TypeCode = 'TestTypeCode';
        
      UCD_BizOrgRequestModel.CustomerProcessEngagmentWrap customerPro = new UCD_BizOrgRequestModel.CustomerProcessEngagmentWrap();
        customerPro.ProcessCode = 'TestProcessCode';
        
 
        
        UCD_BizOrgRequestModel Model1 = new UCD_BizOrgRequestModel();
         Model1.Addresses = new List<UCD_BizOrgRequestModel.AddressesWrap> {address};
         Model1.CustomerAggregationTypeCode = 'TestCustomerAggregationTypeCode';
         Model1.CustomerProcessEngagment = new List<UCD_BizOrgRequestModel.CustomerProcessEngagmentWrap> {customerPro};
         Model1.Name = '';
   
       UCD_BizOrgRequestController.UCD_BizOrgRequestController(Model1);
        
    }
}