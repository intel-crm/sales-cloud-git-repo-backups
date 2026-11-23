public class Sales_LicenseCheckForReassigning {
    public class LicenseToolTypeInput {    
        @InvocableVariable
        public String License_Type_OnLicense;
    }
    public class Result {
        @InvocableVariable
        public String License_Type_OnHost;
    }
    @InvocableMethod(label='Host license type based on the license record')
    public static List<Result> determineHostLicType(List<LicenseToolTypeInput> licenseTypeInput) {
        List<Result> output = new List<Result>();
        for (LicenseToolTypeInput inp : licenseTypeInput) {
            Result r = new Result();          
            if(inp.License_Type_OnLicense == 'FIXED'){
                r.License_Type_OnHost = 'FIXED';				
            }else if((inp.License_Type_OnLicense == 'FLOAT') || (inp.License_Type_OnLicense == 'N-A')){
                r.License_Type_OnHost = 'FLOAT';				
            }
            else if(inp.License_Type_OnLicense == 'NEUTRAL'){
                r.License_Type_OnHost = 'NEUTRAL';
            }
            output.add(r);
        }
        return output;
    }
}