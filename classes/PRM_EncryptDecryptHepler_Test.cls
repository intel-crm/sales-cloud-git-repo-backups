@isTest
public class PRM_EncryptDecryptHepler_Test {
    
    @isTest
    private static void EncryptDecryptData() {
        string unionId='oFxRb1RG-KuOHQVH9vuAEaMLZAmI';  
        string encryptedValue=EncryptDecryptHelper.EncryptData(unionId);
        //system.debug('encryptedValue'+encryptedValue);
        string decryptValue=EncryptDecryptHelper.DecryptData(EncodingUtil.urlEncode(encryptedValue,'UTF-8'));
        System.assertEquals(unionId, decryptValue);
    }
    @isTest
    private static void EncryptDecryptDataException(){
        string decryptValue=EncryptDecryptHelper.DecryptData('Junk Value');
        System.assertEquals(decryptValue, '');
    }
}