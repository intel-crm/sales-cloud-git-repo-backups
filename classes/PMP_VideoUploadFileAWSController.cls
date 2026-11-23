public with sharing class PMP_VideoUploadFileAWSController {
    public PMP_VideoUploadFileAWSController() {

    }
    //This method is used to post file to AWS
    @AuraEnabled
    public static boolean uploadFileToAWS(Id parentId,
                                        String strfileName, String fileType,
                                        String fileContent){
        System.debug('parentId=' + parentId);
        System.debug('strfileName=' + strfileName);
        System.debug('fileType=' + fileType);
        HttpRequest req = new HttpRequest();

        Blob base64Content = EncodingUtil.base64Decode(EncodingUtil.urlDecode(fileContent, 'UTF-8'));
        String attachmentBody =  fileContent;           
        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String dateString = Datetime.now().format('ddMMYYYYHHmmss');        
        String filename = dateString + '_' + parentId + '_' + strfileName;
        
        //AWS specific information
        String objectkey = '4090876643001/6283184435001/e3adb1a9-236c-4667-9657-e8f44fdf50d0/newvideoPostman'; //object key
        String key = 'ASIA25ESRNNE2A2YYKR7'; //AWS key
        String secret = 'WmcbMFr1jvHq4xfy9WI8zGSqE9jXAEpJUn3iYK8q'; //AWS Secret key
        String bucketname = 'ingestion-upload-production'; //AWS bucket name
        String host = 's3.amazonaws.com'; //'s3.amazonaws.com:443'
       
        String method = 'PUT';
        String endPoint = 'https://' + bucketname + '.' + host + '/'+ objectkey;

        req.setMethod(method);
        req.setEndpoint(endPoint);

        system.debug('Endpoint='+endPoint);
        //create header information
        req.setHeader('Host', bucketname + '.' + host);
        req.setHeader('Access-Control-Allow-Origin', '*');
        req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Content-type', fileType);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', formattedDateString); 
        req.setHeader('ACL', 'public-read');
        //store file as blob       
        req.setBodyAsBlob(base64Content);
        
        //prepare for signing information
        String stringToSign = 'PUT\n\n' +
        fileType + '\n' +
        formattedDateString + '\n' + '/' + bucketname + '/' + filename;

        String encodedStringToSign = EncodingUtil.urlEncode(stringToSign, 'UTF-8');
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String signedKey  = EncodingUtil.base64Encode(mac);

        //assign Authorization information
        String authHeader = 'AWS' + ' ' + key + ':' + signedKey;                    
        req.setHeader('Authorization',authHeader);

        //finally send information to AWS        
        Http http = new Http();
        HTTPResponse res = http.send(req);

        System.debug('*Resp:' + String.ValueOF(res.getBody()));
        System.debug('RESPONSE STRING: ' + res.toString());
        System.debug('RESPONSE STATUS: ' + res.getStatus());
        System.debug('STATUS_CODE: ' + res.getStatusCode());

        if(res.getStatusCode() == 200){
            insertAttachmentRecord (parentId,strfileName,endPoint);
            return true;
        }
        return false;
    }

    //This method inserts file information to Custom PMP_Company_Resource__c object
    public static void insertAttachmentRecord (Id parentId, String fileName, String fileURL){
        PMP_Company_Resource__c attachment = new PMP_Company_Resource__c();
        attachment.PMP_Company_Id__c = parentId;
       // attachment.Video_File_URL__c = fileURL;
       // attachment.Video_File_Name__c =  fileName;
        insert attachment;                                           
    }

    //This method retrieves Attachment record based on PMP_Company_Id__c
    @AuraEnabled
    public static List<PMP_Company_Resource__c> displayUploadedFiles(Id parentId){
        return [SELECT Id FROM PMP_Company_Resource__c
                WHERE PMP_Company_Id__c =:parentId];
    }
}