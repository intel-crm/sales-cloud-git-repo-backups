public class SWS_StringSplitUtility {
    
    @InvocableMethod(
        label='Split Semicolon String' 
        description='Splits a semicolon-separated string into a list of values'
        category='String Utilities'
    )
    public static List<SplitStringResult> splitSemicolonString(List<SplitStringRequest> requests) {
        List<SplitStringResult> results = new List<SplitStringResult>();   
        SWS_Core_CRM_Labels__c swsLabel = SWS_Core_CRM_Labels__c.getValues('Excluded_Domains');
        string labelValue = swsLabel != null ? swsLabel.SWS_Value__c : '';
        system.debug('Input String ' +requests);
        Set<String> excludedDomains = new Set<String>();
      if (String.isNotBlank(labelValue)) {
        List<String> stringList = labelValue.split(';');        
        for (String str : stringList) {
            if (String.isNotBlank(str)) {
                excludedDomains.add(str.trim());
            }
        }
    }
        if (requests != null && !requests.isEmpty()) {
        for (SplitStringRequest request : requests) {
            SplitStringResult result = new SplitStringResult();            
            try {
                if (String.isNotBlank(request.inputString)) {
                    // Split the string by semicolon and trim whitespace
                    List<String> splitValues = new List<String>();
                    String[] rawSplit = request.inputString.split(';');
                    system.debug('Input Split ' +rawSplit);
                    
                    for (String value : rawSplit) {                       
                        String trimmedValue = value.trim();
                         String filteredEmail = SWS_EmailDomainFilter.filterEmailByDomain(trimmedValue, excludedDomains);
                        if (String.isNotBlank(filteredEmail) && (filteredEmail.indexOf('<') >0) && (filteredEmail.indexOf('>') >0) ) { 
                               // Find the position of '<' and '>'
        						Integer startIndex = filteredEmail.indexOf('<');
        						Integer endIndex = filteredEmail.indexOf('>');        
        						// Check if both brackets exist and are in correct order
        						if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
                					splitValues.add( filteredEmail.substring(startIndex + 1, endIndex));
        						}                            
                        }
                       else if (String.isNotBlank(filteredEmail)) 
                                {
                                    splitValues.add( filteredEmail);
                                }
                        
                    }                    
                    result.splitValues = splitValues;
                    result.isSuccess = true;
                    result.errorMessage = null;
                }
                else
                {
                     result.splitValues = new List<String>();
                    result.isSuccess = true;
                    result.errorMessage = null;
                    
                }
            } catch (Exception e) {
                result.splitValues = new List<String>();
                result.isSuccess = false;
                result.errorMessage = 'Error splitting string: ' + e.getMessage();
            }            
            results.add(result);
        }
        }
        else
        {
            SplitStringResult result = new SplitStringResult();
            result.splitValues = new List<String>();
            result.isSuccess = true;
            result.errorMessage = null;
            results.add(result);               
        }       
        system.debug('EMAIL Result ' +results);
        return results;        
    }
    
    // Input wrapper class
    public class SplitStringRequest {
        @InvocableVariable(
            label='Input String' 
            description='Semicolon-separated string to split' 
            required=false
        )
        public String inputString;
    }
    
    // Output wrapper class
    public class SplitStringResult {
        @InvocableVariable(
            label='Split Values' 
            description='List of split string values'
        )
        public List<String> splitValues;
        
        @InvocableVariable(
            label='Success' 
            description='Indicates if the operation was successful'
        )
        public Boolean isSuccess;
        
        @InvocableVariable(
            label='Error Message' 
            description='Error message if operation failed'
        )
        public String errorMessage;
    }
}