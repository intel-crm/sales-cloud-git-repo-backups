public class SWS_EACUtility {
    
    /**
     * Validates email format
     * @param email - The email address to check
     * @return String - Returns the email if it's valid, otherwise returns null
     */
    public static String validateEmail(String email) {
        if (String.isBlank(email)) {
            return null;
        }
        
        try {
            return processEmailValidation(email);
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
     * Batch method to validate multiple emails
     * @param emails - List of email addresses to check
     * @return List<String> - Returns list of valid emails (nulls are excluded from result)
     */
    public static List<String> validateEmails(List<String> emails) {
        List<String> validEmails = new List<String>();
        
        if (emails == null || emails.isEmpty()) {
            return validEmails;
        }
        
        for (String email : emails) {
            String validEmail = validateEmail(email);
            if (validEmail != null) {
                validEmails.add(validEmail);
            }
        }
        
        return validEmails;
    }
    
    /**
     * Processes the email validation logic
     */
    private static String processEmailValidation(String email) {
        if (!isValidEmail(email)) {
            return null;
        }
        
        return email;
    }
    
    /**
     * Validates email format (handles both plain and RFC 2822 formats)
     */
    private static Boolean isValidEmail(String email) {
        if (String.isBlank(email)) {
            return false;
        }
        
        String trimmedEmail = email.trim();
        
        if (isRFC2822Format(trimmedEmail)) {
            return validateRFC2822Email(trimmedEmail);
        }
        
        return isValidPlainEmail(trimmedEmail);
    }
    
    /**
     * Checks if email is in RFC 2822 format
     */
    private static Boolean isRFC2822Format(String email) {
        return email.contains('<') && email.contains('>');
    }
    
    /**
     * Validates RFC 2822 format email
     */
    private static Boolean validateRFC2822Email(String email) {
        Integer startIndex = email.indexOf('<');
        Integer endIndex = email.indexOf('>');
        
        if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
            return false;
        }
        
        String extractedEmail = email.substring(startIndex + 1, endIndex).trim();
        return isValidPlainEmail(extractedEmail);
    }
    
    /**
     * Validates plain email format
     */
    private static Boolean isValidPlainEmail(String email) {
        if (String.isBlank(email)) {
            return false;
        }
        
        String emailRegex = '^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        
        return emailPattern.matcher(email).matches();
    }
    
    /**
     * Extracts domain from email (handles both plain and RFC 2822 formats)
     */
    public static String extractDomain(String email) {
        if (String.isBlank(email)) {
            return '';
        }
        
        String actualEmail = getActualEmailAddress(email.trim());
        
        if (!actualEmail.contains('@')) {
            return '';
        }
        
        Integer atIndex = actualEmail.lastIndexOf('@');
        
        if (atIndex >= 0 && atIndex < actualEmail.length() - 1) {
            return actualEmail.substring(atIndex + 1);
        }
        
        return '';
    }
    
    /**
     * Extracts the actual email address from RFC 2822 format or returns as-is for plain format
     */
    private static String getActualEmailAddress(String email) {
        if (!isRFC2822Format(email)) {
            return email;
        }
        
        Integer startIndex = email.indexOf('<');
        Integer endIndex = email.indexOf('>');
        
        if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
            return email;
        }
        
        return email;
    }
}