public class PMP_FileUpload_SFToAWS3 {
    
   public static void uploadToAWS3(){

        //PMP_FileUpload_SFToAWS3.uploadToAWS3();

        List<ContentVersion> versions=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId ='0698A000001MMYI' AND IsLatest = true];

       

        for(ContentVersion attach:versions){

                String attachmentBody = EncodingUtil.base64Encode(attach.VersionData);

                String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');

                String key = 'AKIAQGF7GMWQSTNBBCXM'; //AWS key

                String secret = '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'; //AWS Secret key

                String bucketname = 'bucketforbrightcove'; //AWS bucket name

                String host = 's3.amazonaws.com';

                String method = 'DELETE';

                String filename = 'IntelVideo54.mp4';

                HttpRequest req = new HttpRequest();

                req.setMethod(method);

                req.setEndpoint('https://bucketforbrightcove.s3.amazonaws.com'+'/'+filename);

                req.setHeader('Host', bucketname + '.' + host);

                req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));

                req.setHeader('Content-Encoding', 'UTF-8');

                req.setHeader('Content-type', 'application/json');

                req.setHeader('Connection', 'keep-alive');

                req.setHeader('Date', formattedDateString);

                req.setHeader('ACL', 'public-read-write');

                req.setTimeout(30000);

               // Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);

                   // req.setBodyAsBlob(pdfBlob);

                String stringToSign = 'DELETE\n\n' + 'application/json' + '\n' + formattedDateString + '\n' + '/' + bucketname + '/' + filename;

                String encodedStringToSign = EncodingUtil.urlEncode(stringToSign, 'UTF-8');

                Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));

                String signedKey  = EncodingUtil.base64Encode(mac);

                String authHeader = 'AWS' + ' ' + key + ':' + signedKey ;

                req.setHeader('Authorization',authHeader);

                //String sessionToken = System.label.S3SessionToken;

                //req.setHeader('X-Amz-Security-Token', sessionToken);

                String decoded = EncodingUtil.urlDecode(encodedStringToSign , 'UTF-8');

                Http http = new Http();

                HTTPResponse res = http.send(req);

                System.debug('res--status---->'+res.getStatusCode());

                System.debug('res------>'+res.getBody());

        

        }  

    }
}