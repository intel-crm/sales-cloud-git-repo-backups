public class SWS_StringSplitUtility {
    
    @InvocableMethod(
        label='Split Semicolon String' 
        description='Splits a semicolon-separated string into a list of values'
        category='String Utilities'
    )
    public static List<SplitStringResult> splitSemicolonString(List<SplitStringRequest> requests ) {

        List<SplitStringResult> results = new List<SplitStringResult>();
        
        if (requests == null || requests.isEmpty())  {
            results.add(createEmptyResult());
            return results;
        }  
         for (SplitStringRequest request : requests) {
            results.add(processRequest(request));
        }
        return results;
        
    }
    
    /**
     * Processes a single request
     */
    private static SplitStringResult processRequest(SplitStringRequest request) {

        SplitStringResult result = new SplitStringResult();
        
        try {
            if (String.isBlank(request.inputString)) {
                return createEmptyResult();
            }
            List<String> splitValues = processInputString(request.inputString);
            return createSuccessResult(splitValues);
            
        } catch (Exception e) {
            return createErrorResult('Error splitting string: ' + e.getMessage());
        }
    }
    
    /**
     * Processes the input string and validates emails
     */
   private static List<String> processInputString(String inputString) {
    List<String> splitValues = new List<String>();
    
    String processedString = inputString.replaceAll(',(?=(?:[^"]*"[^"]*")*[^"]*$)(?![^<]*>)', ';');
    String[] rawSplit = processedString.split(';');
    
    for (String value : rawSplit) {
        String processedEmail = processEmailValue(value.trim());
        if (String.isNotBlank(processedEmail)) {
            splitValues.add(processedEmail);
        }
    }
    
    return splitValues;
   }
    
    /**
     * Processes a single email value
     */
    private static String processEmailValue(String trimmedValue) {
        String validatedEmail = SWS_EACUtility.validateEmail(trimmedValue);
        
        if (String.isBlank(validatedEmail)) {
            return null;
        }
        return extractEmailFromFormat(validatedEmail);
    }
    
    /**
     * Extracts email from RFC 2822 format or returns as-is for plain format
     */
    private static String extractEmailFromFormat(String email) {
        if (isRFC2822Format(email)) {
            return extractEmailFromBrackets(email);
        }
        return email;
    }
    
    /**
     * Checks if email is in RFC 2822 format
     */
    private static Boolean isRFC2822Format(String email) {
        return email.indexOf('<') > 0 && email.indexOf('>') > 0;
    }
    
    /**
     * Extracts email from angle brackets
     */
    private static String extractEmailFromBrackets(String email) {
        Integer startIndex = email.indexOf('<');
        Integer endIndex = email.indexOf('>');
        
        if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
            return email.substring(startIndex + 1, endIndex);
        }
        
        return null;
    }
    
    /**
     * Separates emails into Intel and non-Intel categories
     */
    private static Map<String, List<String>> categorizeEmails(List<String> emails) {
        List<String> intelEmails = new List<String>();
        List<String> nonIntelEmails = new List<String>();
        
        for (String email : emails) {
            if (String.isNotBlank(email) && email.toLowerCase().endsWith('@intel.com')) {
                intelEmails.add(email);
            } else if (String.isNotBlank(email)) {
                nonIntelEmails.add(email);
            }
        }
        
        Map<String, List<String>> categorizedEmails = new Map<String, List<String>>();
        categorizedEmails.put('intel', intelEmails);
        categorizedEmails.put('nonIntel', nonIntelEmails);
        return categorizedEmails;
    }
    
    /**
     * Creates an empty successful result
     */
    private static SplitStringResult createEmptyResult() {
        SplitStringResult result = new SplitStringResult();
        result.splitUserValues = new List<String>();
        result.splitContactValues = new List<String>();
        result.isSuccess = true;
        result.errorMessage = null;
        return result;
    }
    
    /**
     * Creates a successful result with values
     */
    private static SplitStringResult createSuccessResult(List<String> splitValues) {
        SplitStringResult result = new SplitStringResult();
        
        Map<String, List<String>> categorizedEmails = categorizeEmails(splitValues);
        result.splitUserValues = categorizedEmails.get('intel');
        result.splitContactValues = categorizedEmails.get('nonIntel');
        result.isSuccess = true;
        result.errorMessage = null;
        return result;
    }
    
    /**
     * Creates an error result
     */
    private static SplitStringResult createErrorResult(String errorMessage) {
        SplitStringResult result = new SplitStringResult();
        result.splitUserValues = new List<String>();
        result.splitContactValues = new List<String>();
        result.isSuccess = false;
        result.errorMessage = errorMessage;
        return result;
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
            label='Intel User Values' 
            description='List of Intel email addresses (@intel.com)'
        )
        public List<String> splitUserValues;
        
        @InvocableVariable(
            label='Contact Values' 
            description='List of non-Intel email addresses'
        )
        public List<String> splitContactValues;
        
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