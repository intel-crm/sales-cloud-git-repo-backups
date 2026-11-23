@IsTest
private class PRM_W9_UtilityTest {
    @IsTest
    static void testEncryptionDecryption() {
        // Test data
        String originalText = '123456789';
        String encryptionKey = 'mysecretkey12345'; // Must be 16 bytes for AES-128
        
        // Encrypt the data
        String encryptedText = PRM_W9_Utility.encrypt(originalText, encryptionKey);
        
        // Verify encryption produces non-null, different result from original
        System.assertNotEquals(null, encryptedText);
        System.assertNotEquals(originalText, encryptedText);
        
        // Decrypt the data
        String decryptedText = PRM_W9_Utility.decrypt(encryptedText, encryptionKey);
        
        // Verify decryption recovers the original text
        System.assertEquals(originalText, decryptedText);
    }
    
    // @IsTest
    // static void testInvalidDecryption() {
    //     // Test invalid input formats
    //     String result = PRM_W9_Utility.decrypt('InvalidFormat', 'mysecretkey12345');
    //     System.assertEquals(null, result);
        
    //     // Test with wrong key
    //     String encryptedText = PRM_W9_Utility.encrypt('Secret', 'SixteenByteKeyABC');
    //     String decryptedWithWrongKey = PRM_W9_Utility.decrypt(encryptedText, 'DifferentSixteenB');
    //     System.assertNotEquals('Secret', decryptedWithWrongKey);
    // }
}