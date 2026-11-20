@isTest
private class UCD_ACM_NonLatinAddressCheck_Test {

    @isTest
    static void testCheckNonLatinAddress() {
        // Prepare test data
        List<UCD_ACM_NonLatinAddressCheck.AddressRequestData> requestData = new List<UCD_ACM_NonLatinAddressCheck.AddressRequestData>();
        
        // Add a Latin address
        UCD_ACM_NonLatinAddressCheck.AddressRequestData latinAddress = new UCD_ACM_NonLatinAddressCheck.AddressRequestData();
        latinAddress.primaryAddress = '123 Main St, Anytown, USA';
        requestData.add(latinAddress);
        
        // Add a Non-Latin address
        UCD_ACM_NonLatinAddressCheck.AddressRequestData nonLatinAddress = new UCD_ACM_NonLatinAddressCheck.AddressRequestData();
        nonLatinAddress.primaryAddress = '123 главная улица, город, Россия'; // Example of a Cyrillic address
        requestData.add(nonLatinAddress);

        // Call the method
        Test.startTest();
        List<UCD_ACM_NonLatinAddressCheck.AddressOutputData> output = UCD_ACM_NonLatinAddressCheck.checkNonLatinAddress(requestData);
        Test.stopTest();

        // Validate the output
        System.assertEquals(2, output.size());
        System.assertEquals(false, output[0].isLatin); // Latin address
        System.assertEquals(true, output[1].isLatin); // Non-Latin address
    }
}