@isTest
public class SWS_EmailDomainFilterTest {
    
    @isTest
    static void testFilterEmailByDomain_ValidEmailNotExcluded() {
        // Test data
        String email = 'test@example.com';
        Set<String> excludedDomains = new Set<String>{'gmail.com', 'yahoo.com'};
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(email, result, 'Valid email not in excluded domains should be returned');
    }
    
    @isTest
    static void testFilterEmailByDomain_ValidEmailExcluded() {
        // Test data
        String email = 'test@gmail.com';
        Set<String> excludedDomains = new Set<String>{'gmail.com', 'yahoo.com'};
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, result, 'Email with excluded domain should return null');
    }
    
    @isTest
    static void testFilterEmailByDomain_CaseInsensitive() {
        // Test data
        String email = 'test@GMAIL.COM';
        Set<String> excludedDomains = new Set<String>{'gmail.com', 'yahoo.com'};
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, result, 'Case insensitive domain matching should work');
    }
    
    @isTest
    static void testFilterEmailByDomain_ExcludedDomainsWithSpaces() {
        // Test data
        String email = 'test@gmail.com';
        Set<String> excludedDomains = new Set<String>{' gmail.com ', 'yahoo.com'};
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, result, 'Excluded domains with spaces should be trimmed and matched');
    }
    
    @isTest
    static void testFilterEmailByDomain_NullEmail() {
        // Test data
        String email = null;
        Set<String> excludedDomains = new Set<String>{'gmail.com'};
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, result, 'Null email should return null');
    }
    
    @isTest
    static void testFilterEmailByDomain_BlankEmail() {
        // Test data
        String email = '   ';
        Set<String> excludedDomains = new Set<String>{'gmail.com'};
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, result, 'Blank email should return null');
    }
    
    @isTest
    static void testFilterEmailByDomain_NullExcludedDomains() {
        // Test data
        String email = 'test@gmail.com';
        Set<String> excludedDomains = null;
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(email, result, 'Null excluded domains should return original email');
    }
    
    @isTest
    static void testFilterEmailByDomain_EmptyExcludedDomains() {
        // Test data
        String email = 'test@gmail.com';
        Set<String> excludedDomains = new Set<String>();
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(email, result, 'Empty excluded domains should return original email');
    }
    
    @isTest
    static void testFilterEmailByDomain_InvalidEmailFormat() {
        // Test data
        String email = 'invalid-email';
        Set<String> excludedDomains = new Set<String>{'gmail.com'};
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, result, 'Invalid email format should return null');
    }
    
    @isTest
    static void testFilterEmailByDomain_EmailWithoutDomain() {
        // Test data
        String email = 'test@';
        Set<String> excludedDomains = new Set<String>{'gmail.com'};
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, result, 'Email without domain should return null');
    }
    
    @isTest
    static void testFilterEmailByDomain_StringOverload_CommaSeparated() {
        // Test data
        String email = 'test@gmail.com';
        String excludedDomainsString = 'gmail.com,yahoo.com,hotmail.com';
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomainsString);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, result, 'String overload with comma separated domains should work');
    }
    
    @isTest
    static void testFilterEmailByDomain_StringOverload_SemicolonSeparated() {
        // Test data
        String email = 'test@example.com';
        String excludedDomainsString = 'gmail.com;yahoo.com;hotmail.com';
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomainsString);
        Test.stopTest();
        
        // Assert
        System.assertEquals(email, result, 'String overload with semicolon separated domains should work');
    }
    
    @isTest
    static void testFilterEmailByDomain_StringOverload_MixedSeparators() {
        // Test data
        String email = 'test@yahoo.com';
        String excludedDomainsString = 'gmail.com;yahoo.com,hotmail.com';
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomainsString);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, result, 'String overload with mixed separators should work');
    }
    
    @isTest
    static void testFilterEmailByDomain_StringOverload_BlankString() {
        // Test data
        String email = 'test@gmail.com';
        String excludedDomainsString = '';
        
        // Test
        Test.startTest();
        String result = SWS_EmailDomainFilter.filterEmailByDomain(email, excludedDomainsString);
        Test.stopTest();
        
        // Assert
        System.assertEquals(email, result, 'Blank excluded domains string should return original email');
    }
    
    @isTest
    static void testFilterEmailsByDomain_MultipleEmails() {
        // Test data
        List<String> emails = new List<String>{
            'test1@gmail.com',
            'test2@example.com',
            'test3@yahoo.com',
            'test4@company.com'
        };
        Set<String> excludedDomains = new Set<String>{'gmail.com', 'yahoo.com'};
        
        // Test
        Test.startTest();
        List<String> result = SWS_EmailDomainFilter.filterEmailsByDomain(emails, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(2, result.size(), 'Should return 2 emails that are not excluded');
        System.assert(result.contains('test2@example.com'), 'Should contain example.com email');
        System.assert(result.contains('test4@company.com'), 'Should contain company.com email');
    }
    
    @isTest
    static void testFilterEmailsByDomain_NullEmailList() {
        // Test data
        List<String> emails = null;
        Set<String> excludedDomains = new Set<String>{'gmail.com'};
        
        // Test
        Test.startTest();
        List<String> result = SWS_EmailDomainFilter.filterEmailsByDomain(emails, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, result.size(), 'Null email list should return empty list');
    }
    
    @isTest
    static void testFilterEmailsByDomain_EmptyEmailList() {
        // Test data
        List<String> emails = new List<String>();
        Set<String> excludedDomains = new Set<String>{'gmail.com'};
        
        // Test
        Test.startTest();
        List<String> result = SWS_EmailDomainFilter.filterEmailsByDomain(emails, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, result.size(), 'Empty email list should return empty list');
    }
    
    @isTest
    static void testFilterEmailsByDomain_WithInvalidEmails() {
        // Test data
        List<String> emails = new List<String>{
            'valid@example.com',
            'invalid-email',
            null,
            '   ',
            'another@test.com'
        };
        Set<String> excludedDomains = new Set<String>{'gmail.com'};
        
        // Test
        Test.startTest();
        List<String> result = SWS_EmailDomainFilter.filterEmailsByDomain(emails, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(2, result.size(), 'Should return only valid emails');
        System.assert(result.contains('valid@example.com'), 'Should contain valid email');
        System.assert(result.contains('another@test.com'), 'Should contain another valid email');
    }
    
    @isTest
    static void testFilterEmailsByDomain_StringOverload() {
        // Test data
        List<String> emails = new List<String>{
            'test1@gmail.com',
            'test2@example.com',
            'test3@yahoo.com'
        };
        String excludedDomainsString = 'gmail.com,yahoo.com';
        
        // Test
        Test.startTest();
        List<String> result = SWS_EmailDomainFilter.filterEmailsByDomain(emails, excludedDomainsString);
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, result.size(), 'Should return 1 email that is not excluded');
        System.assertEquals('test2@example.com', result[0], 'Should return the example.com email');
    }
    
    @isTest
    static void testFilterEmailsByDomain_StringOverload_BlankString() {
        // Test data
        List<String> emails = new List<String>{'test@gmail.com', 'test@yahoo.com'};
        String excludedDomainsString = '';
        
        // Test
        Test.startTest();
        List<String> result = SWS_EmailDomainFilter.filterEmailsByDomain(emails, excludedDomainsString);
        Test.stopTest();
        
        // Assert
        System.assertEquals(2, result.size(), 'Blank excluded domains should return all emails');
    }
    
    @isTest
    static void testComplexEmailFormats() {
        // Test data with various valid email formats
        List<String> emails = new List<String>{
            'user.name@example.com',
            'user+tag@example.com',
            'user_name@example-domain.com',
            'user123@sub.example.com'
        };
        Set<String> excludedDomains = new Set<String>{'example.com'};
        
        // Test
        Test.startTest();
        List<String> result = SWS_EmailDomainFilter.filterEmailsByDomain(emails, excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(2, result.size(), 'Should handle complex email formats correctly');
        System.assert(result.contains('user_name@example-domain.com'), 'Should contain hyphenated domain');
        System.assert(result.contains('user123@sub.example.com'), 'Should contain subdomain');
    }
    
    @isTest
    static void testEdgeCases() {
        // Test various edge cases
        Set<String> excludedDomains = new Set<String>{'', '   ', null, 'valid.com'};
        
        Test.startTest();
        String result1 = SWS_EmailDomainFilter.filterEmailByDomain('test@valid.com', excludedDomains);
        String result2 = SWS_EmailDomainFilter.filterEmailByDomain('test@other.com', excludedDomains);
        Test.stopTest();
        
        // Assert
        System.assertEquals(null, result1, 'Should exclude valid.com domain');
        System.assertEquals('test@other.com', result2, 'Should allow other.com domain');
    }
}