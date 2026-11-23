public class Sales_BotLicenseProcess {

    public class SalesLicenseOutput {
        @InvocableVariable(required=true)
        public String status;
    }

    public class SalesLicenseInput {
        @InvocableVariable(required=true)
        public String activationCode;
    }
    
    @InvocableMethod(label='Activate License')
    public static List<SalesLicenseOutput> ActivateLicense(List<SalesLicenseInput> salesLicInputs) {
        Set<String> activateCodes = new Set<String>(); 
        
        // Get the order numbers from the input
        for (SalesLicenseInput salesLicInput : salesLicInputs) {
            activateCodes.add(salesLicInput.activationCode);
        }
        
        
        List<SalesLicenseOutput> salesLicOutputs = new List<SalesLicenseOutput>();
        SalesLicenseOutput licoutput = new SalesLicenseOutput();
        licoutput.status = 'Success';
        salesLicOutputs.add(licoutput);
    
    	return salesLicOutputs;    
  }
    
}