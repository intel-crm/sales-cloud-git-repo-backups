/*
* Class for Einstein Bot to Determine Host Type based on License Type / Fetch Host License Type from Input Host Object
* Developer --> Shivam Vishwakarma
* Created Date --> 14.6.2021
* User Stories were this class was required : 
*       1. US1029878 : chatbot - add new host/view the list of existing computers to assign  
*/
public class Sales_DetermineHostLicType_Bot {
    public class LicenseToolTypeInput {    
        @InvocableVariable
        public String License_Type_OnLicense;
        @InvocableVariable
        public Sales_Host__c hostobj;
    }
    public class Result {
        @InvocableVariable
        public String License_Type_OnHost;
    }
    @InvocableMethod(label='Determine Host Licence Type')
    public static List<Result> determineHostLicType(List<LicenseToolTypeInput> licenseTypeInput) {
        List<Result> output = new List<Result>();
        for (LicenseToolTypeInput inp : licenseTypeInput) {
            Result r = new Result(); 
            if(inp.License_Type_OnLicense != null)
            {
                if(inp.License_Type_OnLicense == 'FIXED'){
                    r.License_Type_OnHost = 'FIXED';                
                }else if( inp.License_Type_OnLicense == 'FLOAT' || inp.License_Type_OnLicense == 'N-A' ){
                    r.License_Type_OnHost = 'FLOAT';                
                }
                else if(inp.License_Type_OnLicense == 'NEUTRAL'){
                     r.License_Type_OnHost = 'NEUTRAL';  
                }
            }
            else if(inp.hostobj != null)
            {
                r.License_Type_OnHost =inp.hostobj.Sales_License_Type__c;
            }
            output.add(r);
        }
        return output;
    }
}