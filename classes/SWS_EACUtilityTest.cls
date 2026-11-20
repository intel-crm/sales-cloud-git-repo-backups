@isTest
public class SWS_EACUtilityTest {
    
    @isTest
    static void testValidateEmail_BlankInput() {
        // Test with null input
        String result = SWS_EACUtility.validateEmail(null);
        System.assertEquals(null, result, 'Null email should return null');
        
        // Test with empty string
        result = SWS_EACUtility.validateEmail('');
        System.assertEquals(null, result, 'Empty email should return null');
        
        // Test with whitespace only
        result = SWS_EACUtility.validateEmail('   ');
        System.assertEquals(null, result, 'Whitespace-only email should return null');
    }
    
    @isTest
    static void testValidateEmail_ValidPlainEmails() {
        // Test valid plain email formats
        String result = SWS_EACUtility.validateEmail('test@example.com');
        System.assertEquals('test@example.com', result, 'Valid plain email should be returned');
        
        result = SWS_EACUtility.validateEmail('user.name@domain.org');
        System.assertEquals('user.name@domain.org', result, 'Valid email with dot in username should be returned');
        
        result = SWS_EACUtility.validateEmail('user123@test-domain.co.uk');
        System.assertEquals('user123@test-domain.co.uk', result, 'Valid email with numbers and hyphens should be returned');
        
        result = SWS_EACUtility.validateEmail('a@b.c');
        System.assertEquals('a@b.c', result, 'Minimal valid email should be returned');
    }
    /*
    @isTest
    static void testValidateEmail_ValidRFC2822Emails() {
        // Test valid RFC 2822 format emails
        String result = SWS_EACUtility.validateEmail('John Doe <john@example.com>');
        System.assertEquals('John Doe <john@example.com>', result, 'Valid RFC 2822 email should be returned');
        
        result = SWS_EACUtility.validateEmail('Jane Smith <jane.smith@domain.org>');
        System.assertEquals('Jane Smith <jane.smith@domain.org>', result, 'Valid RFC 2822 email with dot should be returned');
        
        result = SWS_EACUtility.validateEmail('<test@example.com>');
        System.assertEquals('<test@example.com>', result, 'Valid RFC 2822 email without display name should be returned');
        
        result = SWS_EACUtility.validateEmail('  John Doe <john@example.com>  ');
        System.assertEquals('John Doe <john@example.com>', result, 'Valid RFC 2822 email with whitespace should be trimmed and returned');
    }*/
    
    @isTest
    static void testValidateEmail_InvalidPlainEmails() {
        // Test invalid plain email formats
        String result = SWS_EACUtility.validateEmail('invalid-email');
        System.assertEquals(null, result, 'Email without @ should return null');
        
        result = SWS_EACUtility.validateEmail('test@');
        System.assertEquals(null, result, 'Email without domain should return null');
        
        result = SWS_EACUtility.validateEmail('@domain.com');
        System.assertEquals(null, result, 'Email without username should return null');
        
        result = SWS_EACUtility.validateEmail('test@domain');
        System.assertEquals(null, result, 'Email without TLD should return null');
        
        result = SWS_EACUtility.validateEmail('test@@domain.com');
        System.assertEquals(null, result, 'Email with double @ should return null');
        
        result = SWS_EACUtility.validateEmail('test @domain.com');
        System.assertEquals(null, result, 'Email with space should return null');
        
        result = SWS_EACUtility.validateEmail('test@domain .com');
        System.assertEquals(null, result, 'Email with space in domain should return null');
    }
    
    @isTest
    static void testValidateEmail_InvalidRFC2822Emails() {
        // Test invalid RFC 2822 format emails
        String result = SWS_EACUtility.validateEmail('John Doe <invalid-email>');
        System.assertEquals(null, result, 'RFC 2822 with invalid email should return null');
        
        result = SWS_EACUtility.validateEmail('John Doe <test@>');
        System.assertEquals(null, result, 'RFC 2822 with incomplete email should return null');
        
        result = SWS_EACUtility.validateEmail('John Doe <@domain.com>');
        System.assertEquals(null, result, 'RFC 2822 with missing username should return null');
        
        result = SWS_EACUtility.validateEmail('John Doe <test@domain>');
        System.assertEquals(null, result, 'RFC 2822 with missing TLD should return null');
        
        result = SWS_EACUtility.validateEmail('John Doe <test@@domain.com>');
        System.assertEquals(null, result, 'RFC 2822 with double @ should return null');
        
        result = SWS_EACUtility.validateEmail('John Doe <test @domain.com>');
        System.assertEquals(null, result, 'RFC 2822 with space in email should return null');
    }
    
    @isTest
    static void testValidateEmail_MalformedRFC2822() {
        // Test malformed RFC 2822 formats
        String result = SWS_EACUtility.validateEmail('John Doe <test@domain.com');
        System.assertEquals(null, result, 'RFC 2822 without closing bracket should return null');
        
        result = SWS_EACUtility.validateEmail('John Doe test@domain.com>');
        System.assertEquals(null, result, 'RFC 2822 without opening bracket should return null');
        
        result = SWS_EACUtility.validateEmail('John Doe >test@domain.com<');
        System.assertEquals(null, result, 'RFC 2822 with reversed brackets should return null');
        
        result = SWS_EACUtility.validateEmail('John Doe <>');
        System.assertEquals(null, result, 'RFC 2822 with empty brackets should return null');
        
        result = SWS_EACUtility.validateEmail('<>');
        System.assertEquals(null, result, 'Empty RFC 2822 brackets should return null');
    }
    
    @isTest
    static void testValidateEmails_NullAndEmptyInput() {
        // Test with null input
        List<String> result = SWS_EACUtility.validateEmails(null);
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Result should be empty for null input');
        
        // Test with empty list
        List<String> emptyList = new List<String>();
        result = SWS_EACUtility.validateEmails(emptyList);
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Result should be empty for empty input');
    }
    
    @isTest
    static void testValidateEmails_MixedValidAndInvalid() {
        List<String> emails = new List<String>{
            'valid@example.com',
            'invalid-email',
            'John Doe <john@domain.org>',
            null,
            '',
            'another@test.com',
            'bad@',
            'Jane <jane@company.co.uk>'
        };
        
        List<String> result = SWS_EACUtility.validateEmails(emails);
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(4, result.size(), 'Should return 4 valid emails');
        
        // Verify the valid emails are included
        System.assert(result.contains('valid@example.com'), 'Should contain valid@example.com');
        System.assert(result.contains('John Doe <john@domain.org>'), 'Should contain RFC 2822 email');
        System.assert(result.contains('another@test.com'), 'Should contain another@test.com');
        System.assert(result.contains('Jane <jane@company.co.uk>'), 'Should contain Jane RFC 2822 email');
        
        // Verify invalid emails are not included
        System.assert(!result.contains('invalid-email'), 'Should not contain invalid email');
        System.assert(!result.contains(null), 'Should not contain null');
        System.assert(!result.contains(''), 'Should not contain empty string');
        System.assert(!result.contains('bad@'), 'Should not contain incomplete email');
    }
    
    @isTest
    static void testValidateEmails_AllValid() {
        List<String> emails = new List<String>{
            'test1@example.com',
            'test2@domain.org',
            'John <john@company.com>',
            'Jane Smith <jane@test.co.uk>'
        };
        
        List<String> result = SWS_EACUtility.validateEmails(emails);
        
        System.assertEquals(4, result.size(), 'All valid emails should be returned');
        System.assertEquals(emails, result, 'Result should match input for all valid emails');
    }
    
    @isTest
    static void testValidateEmails_AllInvalid() {
        List<String> emails = new List<String>{
            'invalid-email',
            'bad@',
            '@domain.com',
            null,
            '',
            '   '
        };
        
        List<String> result = SWS_EACUtility.validateEmails(emails);
        
        System.assertEquals(0, result.size(), 'No valid emails should be returned');
    }
    
    @isTest
    static void testExtractDomain_BlankInput() {
        // Test with null input
        String result = SWS_EACUtility.extractDomain(null);
        System.assertEquals('', result, 'Null email should return empty string');
        
        // Test with empty string
        result = SWS_EACUtility.extractDomain('');
        System.assertEquals('', result, 'Empty email should return empty string');
        
        // Test with whitespace only
        result = SWS_EACUtility.extractDomain('   ');
        System.assertEquals('', result, 'Whitespace-only email should return empty string');
    }
    
    @isTest
    static void testExtractDomain_PlainEmails() {
        // Test valid plain emails
        String result = SWS_EACUtility.extractDomain('test@example.com');
        System.assertEquals('example.com', result, 'Should extract domain from plain email');
        
        result = SWS_EACUtility.extractDomain('user@domain.org');
        System.assertEquals('domain.org', result, 'Should extract .org domain');
        
        result = SWS_EACUtility.extractDomain('name@company.co.uk');
        System.assertEquals('company.co.uk', result, 'Should extract multi-level domain');
        
        result = SWS_EACUtility.extractDomain('a@b.c');
        System.assertEquals('b.c', result, 'Should extract minimal domain');
        
        result = SWS_EACUtility.extractDomain('  test@example.com  ');
        System.assertEquals('example.com', result, 'Should handle whitespace and extract domain');
    }
    /*
    @isTest
    static void testExtractDomain_RFC2822Emails() {
        // Test RFC 2822 format emails
        String result = SWS_EACUtility.extractDomain('John Doe <john@example.com>');
        System.assertEquals('example.com', result, 'Should extract domain from RFC 2822 email');
        
        result = SWS_EACUtility.extractDomain('Jane Smith <jane@domain.org>');
        System.assertEquals('domain.org', result, 'Should extract domain from RFC 2822 with display name');
        
        result = SWS_EACUtility.extractDomain('<test@company.co.uk>');
        System.assertEquals('company.co.uk', result, 'Should extract domain from RFC 2822 without display name');
        
        result = SWS_EACUtility.extractDomain('  John <john@test.com>  ');
        System.assertEquals('test.com', result, 'Should handle whitespace in RFC 2822 and extract domain');
    }*/
    
    @isTest
    static void testExtractDomain_InvalidEmails() {
        // Test emails without @ symbol
        String result = SWS_EACUtility.extractDomain('invalid-email');
        System.assertEquals('', result, 'Email without @ should return empty string');
        
        result = SWS_EACUtility.extractDomain('nodomain');
        System.assertEquals('', result, 'String without @ should return empty string');
        
        // Test emails with @ at the end
        result = SWS_EACUtility.extractDomain('test@');
        System.assertEquals('', result, 'Email ending with @ should return empty string');
        
        // Test emails with @ at the beginning
        result = SWS_EACUtility.extractDomain('@domain.com');
        System.assertEquals('domain.com', result, 'Email starting with @ should return domain part');
    }
    
    @isTest
    static void testExtractDomain_MultipleAtSymbols() {
        // Test emails with multiple @ symbols (should use last one)
        String result = SWS_EACUtility.extractDomain('test@user@domain.com');
        System.assertEquals('domain.com', result, 'Should use last @ symbol for domain extraction');
        
        result = SWS_EACUtility.extractDomain('a@b@c@example.org');
        System.assertEquals('example.org', result, 'Should use last @ symbol with multiple @ symbols');
    }
    /*
    @isTest
    static void testExtractDomain_MalformedRFC2822() {
        // Test malformed RFC 2822 formats - these should still try to extract domain
        String result = SWS_EACUtility.extractDomain('John Doe <test@domain.com');
        System.assertEquals('domain.com', result, 'Should extract domain even from malformed RFC 2822');
        
        result = SWS_EACUtility.extractDomain('John Doe test@domain.com>');
        System.assertEquals('domain.com', result, 'Should extract domain from malformed RFC 2822');
        
        result = SWS_EACUtility.extractDomain('John Doe >test@domain.com<');
        System.assertEquals('domain.com', result, 'Should extract domain from reversed brackets');
    } */
    
    @isTest
    static void testValidateEmail_ExceptionHandling() {
        // This test ensures the exception handling in validateEmail works
        // We'll test with a very long string that might cause issues
        String veryLongEmail = 'a'.repeat(1000) + '@' + 'b'.repeat(1000) + '.com';
        
        String result = SWS_EACUtility.validateEmail(veryLongEmail);
        // The result depends on whether the regex can handle it, but it shouldn't throw an exception
        System.assert(result == null || result == veryLongEmail, 'Should handle long emails without exception');
    }
   
    @isTest
    static void testIsRFC2822Format_EdgeCases() {
        // Test edge cases for RFC 2822 detection through public methods
        String result = SWS_EACUtility.validateEmail('<');
        System.assertEquals(null, result, 'Single < should be invalid');
        
        result = SWS_EACUtility.validateEmail('>');
        System.assertEquals(null, result, 'Single > should be invalid');
        
        result = SWS_EACUtility.validateEmail('><');
        System.assertEquals(null, result, 'Reversed brackets should be invalid');
        
        result = SWS_EACUtility.validateEmail('test<>@domain.com');
        System.assertEquals(null, result, 'Brackets in wrong position should be invalid');
    }
 /*
    @isTest
    static void testGetActualEmailAddress_EdgeCases() {
        // Test the getActualEmailAddress method through extractDomain
        String result = SWS_EACUtility.extractDomain('Name <>');
        System.assertEquals('', result, 'Empty brackets should return empty domain');
        
        result = SWS_EACUtility.extractDomain('Name <@domain.com>');
        System.assertEquals('domain.com', result, 'Should extract domain even with missing username');
        
        result = SWS_EACUtility.extractDomain('Name <user@>');
        System.assertEquals('', result, 'Should return empty for missing domain');
    }*/
}