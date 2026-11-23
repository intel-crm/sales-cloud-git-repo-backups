public class SWS_EmailDomainFilter {
    
    /**
     * Filters out emails with specific domains
     * @param email - The email address to check
     * @param excludedDomains - Set of domains to exclude (case-insensitive)
     * @return String - Returns the email if it passes the filter, otherwise returns null
     */
    public static String filterEmailByDomain(String email, Set<String> excludedDomains) {
        // Return null if email is blank or null
        if (String.isBlank(email)) {
            return null;
        }
        
        // Return null if excludedDomains is null or empty (no filtering needed, return original email)
        if (excludedDomains == null || excludedDomains.isEmpty()) {
            return email;
        }
        
        try {
            // Validate email format
            if (!isValidEmail(email)) {
                return null; // Invalid email format
            }
            
            // Extract domain from email
            String domain = extractDomain(email);
            
            if (String.isBlank(domain)) {
                return null; // No domain found
            }
            
            // Check if domain is in excluded list (case-insensitive)
            for (String excludedDomain : excludedDomains) {
                if (String.isNotBlank(excludedDomain) && 
                    domain.equalsIgnoreCase(excludedDomain.trim())) {
                    return null; // Domain is excluded
                }
            }
            
            // Email passes the filter
            return email;
            
        } catch (Exception e) {
            System.debug('Error filtering email: ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * Overloaded method that accepts comma or semicolon separated string of domains
     * @param email - The email address to check
     * @param excludedDomainsString - Comma or semicolon separated string of domains to exclude
     * @return String - Returns the email if it passes the filter, otherwise returns null
     */
    public static String filterEmailByDomain(String email, String excludedDomainsString) {
        if (String.isBlank(excludedDomainsString)) {
            return email;
        }
        
        Set<String> excludedDomains = new Set<String>();
        
        // Split by both comma and semicolon
        String[] domains = excludedDomainsString.split('[;,]');
        
        for (String domain : domains) {
            String trimmedDomain = domain.trim();
            if (String.isNotBlank(trimmedDomain)) {
                excludedDomains.add(trimmedDomain);
            }
        }
        
        return filterEmailByDomain(email, excludedDomains);
    }
    
    /**
     * Batch method to filter multiple emails
     * @param emails - List of email addresses to check
     * @param excludedDomains - Set of domains to exclude
     * @return List<String> - Returns list of emails that pass the filter (nulls are excluded from result)
     */
    public static List<String> filterEmailsByDomain(List<String> emails, Set<String> excludedDomains) {
        List<String> filteredEmails = new List<String>();
        
        if (emails == null || emails.isEmpty()) {
            return filteredEmails;
        }
        
        for (String email : emails) {
            String filteredEmail = filterEmailByDomain(email, excludedDomains);
            if (filteredEmail != null) {
                filteredEmails.add(filteredEmail);
            }
        }
        
        return filteredEmails;
    }
    
    /**
     * Batch method with string input for domains
     * @param emails - List of email addresses to check
     * @param excludedDomainsString - Comma or semicolon separated string of domains to exclude
     * @return List<String> - Returns list of emails that pass the filter
     */
    public static List<String> filterEmailsByDomain(List<String> emails, String excludedDomainsString) {
        if (String.isBlank(excludedDomainsString)) {
            return emails != null ? emails : new List<String>();
        }
        
        Set<String> excludedDomains = new Set<String>();
        String[] domains = excludedDomainsString.split('[;,]');
        
        for (String domain : domains) {
            String trimmedDomain = domain.trim();
            if (String.isNotBlank(trimmedDomain)) {
                excludedDomains.add(trimmedDomain);
            }
        }
        
        return filterEmailsByDomain(emails, excludedDomains);
    }
    
    // Helper method to validate email format
    private static Boolean isValidEmail(String email) {
        if (String.isBlank(email)) {
            return false;
        }
        
        // Basic email validation regex
        String emailRegex = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        return emailPattern.matcher(email.trim()).matches();
    }
    
    // Helper method to extract domain from email
    private static String extractDomain(String email) {
        if (String.isBlank(email) || !email.contains('@')) {
            return '';
        }

        
        String trimmedEmail = email.trim();
        Integer atIndex = trimmedEmail.lastIndexOf('@');
        
        if (atIndex >= 0 && atIndex < trimmedEmail.length() - 1) {
            return trimmedEmail.substring(atIndex + 1);
        }
        
        return '';
    }
}