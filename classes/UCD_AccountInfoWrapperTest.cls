@isTest
public class UCD_AccountInfoWrapperTest {
    public static testMethod void wrappertest(){
        UCD_AccountInfoWrapper wp = new UCD_AccountInfoWrapper();
        wp.accName = 'Account name';
        wp.bizOrg = 'Distributor';
        wp.addressLine1 = 'Address Line 1';
        wp.addressLine2 = 'Address line 2';
        wp.accAddr = 'Account Address';
        wp.accPostalCode = '123123';
        wp.accCity = 'Bangalore';
        wp.accCountry = 'India';
        wp.accStateProvince = 'Karnataka';
        wp.rcdLimit = '25';
        wp.searchScore = '55';
        wp.companyWebsite = 'www.intel.com';
        wp.partnerRole = 'Sample Partner';
        wp.ownerId = 'Sample user';
        wp.companyName = 'Intel';
        wp.tname = 'Name';
        wp.taddressline1 = 'Address line 1';
        wp.taddressline2 = 'Address line 2';
        wp.tcity = 'Test city';
        system.debug('Test city' +wp.tcity);
        system.assertEquals(wp.tcity, 'Test city');
    }
}