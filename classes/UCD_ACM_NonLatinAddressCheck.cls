public without sharing class UCD_ACM_NonLatinAddressCheck {
    public class AddressRequestData {
        @InvocableVariable
        public String primaryAddress;
    }

    public class AddressOutputData {
        @InvocableVariable
        public Boolean isLatin;
    }

    @InvocableMethod(label='Check NonLatinAddress' description='Check the NonLatinAddress')
    public static List<AddressOutputData> checkNonLatinAddress(List<AddressRequestData> Addresses) { 
        List<AddressOutputData> outputAddresses = new List<AddressOutputData>();     
        try{
            for (AddressRequestData address : Addresses) {
                String check=address.primaryAddress;
                Pattern nonASCIIPattern = Pattern.compile('[^\\x00-\\x7F]');
                Matcher matcher = nonASCIIPattern.matcher(check); 
                AddressOutputData outputData=new AddressOutputData();          
                outputData.isLatin = matcher.find(); 
                outputAddresses.add(outputData);
            }
           return outputAddresses;
    }
    catch(Exception ex) {
        UCD_ACM_Logger.error('UCD_ACM_NonLatinAddressCheck','checkNonLatinAddress','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        return outputAddresses;
    } finally {
        UCD_ACM_Logger.setLogDetails();   
    }
    }
}