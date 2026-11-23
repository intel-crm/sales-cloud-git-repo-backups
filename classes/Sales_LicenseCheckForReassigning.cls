@isTest
public class Sales_LicenseCheckForReassigning {
	 //Input - License Type
    /*public class LicenseToolTypeInput {    
        @InvocableVariable
        public String License_Type_OnLicense;
    }
    //Output - Host License Type
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
                r.License_Type_OnHost = 'FIXED';				//Fixed license records will have Host License Type as as Fixed
            }else if((inp.License_Type_OnLicense == 'FLOAT') || (inp.License_Type_OnLicense == 'N-A')){
                r.License_Type_OnHost = 'FLOAT';				// Non fixed license records will have Host License Type as as Float
            }
            else if(inp.License_Type_OnLicense == 'NEUTRAL'){
                r.License_Type_OnHost = 'NEUTRAL';
            }
            output.add(r);
        }
        return output;
    }*/
}