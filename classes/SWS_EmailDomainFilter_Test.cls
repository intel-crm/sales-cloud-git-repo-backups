@isTest
public class SWS_EmailDomainFilter_Test {
  @isTest
    static void testFilterEmailByDomain_ValidEmail_NotExcluded() {
        // Test valid email with domain not in excluded list
        Set<String> excludedDomains = new Set<String>{'spam.com', 'blocked.org'};
        String email = 'test@gmail.com';
        
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        
        System.assertEquals(email, result, 'Valid email should pass filter');
    }
    
    @isTest
    static void testFilterEmailByDomain_ValidEmail_Excluded() {
        // Test valid email with domain in excluded list
        Set<String> excludedDomains = new Set<String>{'spam.com', 'blocked.org'};
        String email = 'test@spam.com';
        
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        
        System.assertEquals(null, result, 'Email with excluded domain should return null');
    }
    
    @isTest
    static void testFilterEmailByDomain_CaseInsensitive() {
        // Test case insensitive domain matching
        Set<String> excludedDomains = new Set<String>{'SPAM.COM', 'blocked.org'};
        String email = 'test@spam.com';
        
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        
        System.assertEquals(null, result, 'Case insensitive matching should work');
        
        // Test reverse case
        excludedDomains = new Set<String>{'spam.com'};
        email = 'test@SPAM.COM';
        
        result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        
        System.assertEquals(null, result, 'Case insensitive matching should work both ways');
    }
    
    @isTest
    static void testFilterEmailByDomain_NullEmail() {
        // Test null email
        Set<String> excludedDomains = new Set<String>{'spam.com'};
        
        String result = SWS_EmailDomainFilter.filterEmailByDomain(null, excludedDomains);
        
        System.assertEquals(null, result, 'Null email should return null');
    }
    
    @isTest
    static void testFilterEmailByDomain_BlankEmail() {
        // Test blank email
        Set<String> excludedDomains = new Set<String>{'spam.com'};
        
        String result = SWS_EmailDomainFilter.filterEmailByDomain('', excludedDomains);
        System.assertEquals(null, result, 'Empty email should return null');
        
        result = SWS_EmailDomainFilter.filterEmailByDomain('   ', excludedDomains);
        System.assertEquals(null, result, 'Whitespace email should return null');
    }
    
    @isTest
    static void testFilterEmailByDomain_NullExcludedDomains() {
        // Test null excluded domains
        String email = 'test@gmail.com';
        
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, (Set<String>)null);
        
        System.assertEquals(email, result, 'Null excluded domains should return original email');
    }
    
    @isTest
    static void testFilterEmailByDomain_EmptyExcludedDomains() {
        // Test empty excluded domains
        String email = 'test@gmail.com';
        Set<String> excludedDomains = new Set<String>();
        
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        
        System.assertEquals(email, result, 'Empty excluded domains should return original email');
    }

}