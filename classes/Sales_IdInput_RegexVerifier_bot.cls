/*********************************************************************************************************************
Version       : 1.0
Created Date  : 27 June 2021

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        27-July-2021             Sales_IdInput_RegexVerifier_bot - For Chatbot to verify Regex for user Input (HOST ID/ NIC ID/ GUARD ID/ COMPANION SERVER ID)
* ---------------------------------------------------------------------------------------------------------*/
public class Sales_IdInput_RegexVerifier_bot {
    public class IdRegexInput {
        @InvocableVariable
        public String Id_To_Verify;			// HOST ID/ NIC ID/ GUARD ID/ COMPANION SERVER ID as Input        
        @InvocableVariable
        public String InputType;			//Input Type - 'HostId' for HOST ID/ 'NicId' for NIC ID/ 'GuardId' for GUARD ID/ 'CompanionId' for COMPANION SERVER ID
    }
    
    public class IdRegexOutput {
        @InvocableVariable
        public Boolean Success_Or_Failure;		//True is Success & False is Failure       
    }
    
    @InvocableMethod(label='Verify Id Regex')
    public static List<IdRegexOutput> generateLicenseFile(List<IdRegexInput> inputData) {       
        List<IdRegexOutput> outputData = new List<IdRegexOutput>();
        Boolean result;
        for(IdRegexInput input : inputData) {
            IdRegexOutput output = new IdRegexOutput();
            
            if(input.InputType == 'HostId'){
                Pattern HostIdPattern = Pattern.compile('[A-Fa-f0-9]{8}');
                result = HostIdPattern.matcher( input.Id_To_Verify ).matches();
            }
            else if(input.InputType == 'NicId'){
                Pattern NicIdPattern = Pattern.compile('[A-Fa-f0-9]{12}');
                result = NicIdPattern.matcher( input.Id_To_Verify ).matches();
            }
            else if(input.InputType == 'GuardId'){
                Pattern GuardIdPattern = Pattern.compile('[T|S]{1}[0-9]{9}');
                result = GuardIdPattern.matcher( input.Id_To_Verify ).matches();
            }
            else if(input.InputType == 'CompanionId'){
                Pattern CompanionIdPattern = Pattern.compile('[A-Fa-f0-9]{12}|[T|S]{1}[0-9]{9}');
                result = CompanionIdPattern.matcher( input.Id_To_Verify ).matches();
            }
            
            output.Success_Or_Failure = result;
            outputData.add(output); 
        }
        return outputData;
    }   
    
}