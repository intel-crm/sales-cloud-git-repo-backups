public class EncryptDecryptHelper {
    static String  privateKey =System.Label.EncryptDecryptPrivateKey;//'XT6fmxXfhNVp3tBuhkNIQIsPgI/ziVS7LSzv5f7oFbk=';
    static String vectorKey=System.Label.EncryptDecryptVectorKey;//'y/B?E(G+KbPeShVm';
    
    public static String EncryptData(String inputData){   
        try{
            return string.isEmpty(inputData) ? '' : EncodingUtil.base64Encode(Crypto.encrypt('AES256',EncodingUtil.base64Decode(privateKey),Blob.valueOf(vectorKey), Blob.valueOf(inputData)));
        }catch(exception ex){ 
            System.debug('ex '+ ex.getMessage());
            return '';
        }
    }
    
    public static String DecryptData(String encryptedData){  
        try{
            return string.isEmpty(encryptedData) ? '' 
                : Crypto.decrypt('AES256', EncodingUtil.base64Decode(privateKey),Blob.valueOf(vectorKey), EncodingUtil.base64Decode(EncodingUtil.urlDecode(encryptedData,'UTF-8').replaceAll('\\s','+'))).toString(); 
        }
        catch(exception ex){
            System.debug('ex '+ ex.getMessage());
            return '';
        }
    }
}