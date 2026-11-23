public with sharing class PRM_W9_Utility {
    
    // Encrypts a string using AES/CBC/PKCS5Padding
    public static String encrypt(String textToEncrypt, String key) {
        try {
            // Ensure the key is 16 bytes long (128 bits)
            if (key.length() > 16) {
                key = key.substring(0, 16);
            } else if (key.length() < 16) {
                key = key + String.valueOf(' ').repeat(16 - key.length());
            }
            Blob keyBlob = Blob.valueOf(key);

            // Use the same key for IV
            Blob ivBlob = keyBlob;

            // Convert the text to encrypt into a Blob
            Blob dataBlob = Blob.valueOf(textToEncrypt);

            // Encrypt using AES with CBC mode and PKCS5 padding
            Blob encryptedBlob = Crypto.encrypt('AES128', keyBlob, ivBlob, dataBlob);
            string encryptedstr = EncodingUtil.base64Encode(encryptedBlob);
            system.debug('Encrypted String = ' + encryptedstr);
            // Convert the encrypted Blob to Base64 string
            return encryptedstr;
            
        } catch (Exception e) {
            System.debug('Error occurred at Encryption method: ' + e.getMessage());
            return null;
        }
    }

    public static String decrypt(String encryptedText, String key) {
        try {
                // Ensure the key is 16 bytes long (128 bits)
                if (key.length() > 16) {
                    key = key.substring(0, 16);
                } else if (key.length() < 16) {
                    key = key + String.valueOf(' ').repeat(16 - key.length());
                }
                Blob keyBlob = Blob.valueOf(key);
    
                // Use the same key for IV
                Blob ivBlob = keyBlob;
    
                // Convert the encrypted Base64 string back to a Blob
                Blob encryptedBlob = EncodingUtil.base64Decode(encryptedText);
    
                // Decrypt using AES128 with CBC mode and PKCS5 padding
                Blob decryptedBlob = Crypto.decrypt('AES128', keyBlob, ivBlob, encryptedBlob);
                string decryptedstr = decryptedBlob.toString();
                system.debug('Encrypted String = ' + decryptedstr);
                // Convert the decrypted Blob back to a String
                return decryptedstr;
        	} catch (Exception e) {
                System.debug('Error occurred at Decryption method: ' + e.getMessage());
                return null;
        	}
    }
}