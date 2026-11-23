@isTest
public class UCD_CIMConnectorTest {
    @isTest static  void testGetCallout() {
        UCD_AccountInfoWrapper sampleInput = new UCD_AccountInfoWrapper();
        sampleInput.accName = 'Dell';
        sampleInput.addressLine1 = 'Whitefield';
        sampleInput.addressLine2 = 'Address line 2';
        sampleInput.accPostalCode = '123123';
        sampleInput.accCity = 'Bangalore';
        sampleInput.accCountry = 'India';
        sampleInput.accStateProvince = 'Karnataka';
        system.assertEquals('Karnataka', sampleInput.accStateProvince);
        sampleInput.rcdLimit = '25';
        sampleInput.searchScore = '55';
        sampleInput.companyWebsite = 'www.dell.com';
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('CIMResponse1');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        list<UCD_CIMModel> result = UCD_CIMConnector.getCimResults(sampleInput);
    }
   
}