/****************************************************************************************************************************************
* Class Name  : PMP_BrightCoveVideoUploadAWS3 
* Version     : 1.0 
* Created Date: 06/04/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 06/04/2022                This class is used to upload the video file to AWS3 
*****************************************************************************************************************************************/
public class PMP_BrightCoveVideoUploadAWS3 {

/*************************************************************************************************************
* Method Name : uploadVideoToAWS3
* Description : this method is used to upload video in AWS3
* Version     : 1.0 
* Created Date: 06/04/2022
* Modification Log :
**************************************************************************************************************/
    //IPA2.0 Offering changes
    /*public static String uploadVideoToAWS3(String fileName,String object_type,String contentDocumentId, Map<String,String> videoIdMap){
        //3.Video upload to AWS3
        ContentVersion attach=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId AND IsLatest = true limit 1];        
        String attachmentBody = EncodingUtil.base64Encode(attach.VersionData);
        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String key = 'ASIA25ESRNNEY4KM7Z6K'; //AWS key
        String secret = 'tg8wI4oT6s/nzsyc5/QjBYlt4T8gtvxEXA6baNyG'; //AWS Secret key
        String bucketname = 'ingestion-upload-production'; //AWS bucket name
        
        String method = 'PUT';
        String sessionToken = 'IQoJb3JpZ2luX2VjEBEaCXVzLWVhc3QtMSJGMEQCIFOX4QPib1bZEiXuXUEqvvGSi0SXIa44wMpcUEPEnpuJAiAtonET4cbZz8n8cBx4W59/vxp8BH7AN25gIku0uUS3wCrhAwiq//////////8BEAAaDDc0OTc3OTExODkyMSIMGONiU2ATX3vp745BKrUD0YLbtQ4oqA3z8s6wKINCjpb1h3uoxu9ZNF9GloihDn9mU2pzx/CBNb5edzf1qchelWY5GZaCBlvNAzVrNu/MHaHDehgyKf1y7LhVCoVoFHT9XdlUQCc5CmZiIp732nRPPoQ1thITAhbOnRl8kPPNUhBTdrIhHb6d2zVI3i+1F+HCn4u0Gn66YTnYfPHs7JDAp/mt5XnDMv0GvZMREeWMGdoKVjXMcoIVMwrcfUz317bAlmuEgjc21N9v9384mzLPY7fkDRKxcJlBNuen5dbK/HnPd/+C75ZYBYzy4nXDHTuvdEbI6i/IRm1YC4Zr45qX2Y8a6ykwRvW+Ce+pK2izJy9q7vAMPL2I6G7gr1RZzVGMyTfXtMo0fMEJf/lBupFnlx4pO7PFrgJVFPaaP1WuHd4X4TT+LRF3PrJ3L80pnHOPszl6waq2zsBCfsjweH7kh1KeAtHxyIiv+2IBPPvPIlZuk2e0UtLWBFQLewrD5fr4jAJr8Z64ucfnfqIkKLxeqPkD+Eq/N324/B37tCd5kG08c3I9YB73bT0ke+7eVYhX45XCOm8npRMB9XHXtc8lvsLAzbUw2f62kgY6mgF0kD13IVO0dGsKnBYZfa6IdjOKE6tHdi3Dd3iYvnHpUyP9t4VBXLgqOsYi7XIytzTg5qJHvb1eaQppvSlAzI5qxHZJAbU6ex52G+l0D0EUrzT3mEJgH1zk4kSe5T6BDtuERVfMvz6edlDugp7bPT/qQpDL7zf6EgAFQsYSLovS2Ffl4yzdOlz2SDDifpFcP/akXEHJwBGsJ5W8';
        
        Blob fileBlob = attach.VersionData;
        Blob paylodHashing = Crypto.generateDigest('SHA-256', fileBlob);
        String hashedPaylod = EncodingUtil.convertToHex(paylodHashing);
        
        String region = 'us-east-1';			
        String service = 's3';					          
        String host = bucketname+'.'+service+'.amazonaws.com';
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint('https://ingestion-upload-production.s3.amazonaws.com/6298977448001/6303060396001/50c82bde-0bd6-40f9-bcaf-45e18d7075c7/Sample_Video_Upload.mp4');
        request.setHeader('host', host);
        request.setHeader('X-Amz-Security-Token', sessionToken);
        request.setHeader('X-Amz-Content-Sha256', hashedPaylod);
        request.setHeader('X-Amz-Date','20220406T173121Z');
        
        String headr = 'AWS4-HMAC-SHA256' +' Credential='+ 'ASIA25ESRNNEY4KM7Z6K/20220406/us-east-1/s3/aws4_request' +',SignedHeaders='+  'host;x-amz-content-sha256;x-amz-date;x-amz-security-token' +',Signature='+ '1fe7503ac2d15ec03cde176a6a392d2df695c63b5c4cbb8118cb2cfb240c8026';
        request.setHeader('Authorization', headr);
        request.setHeader('Content-type', 'video/mp4');
        
        Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
        request.setBodyAsBlob(pdfBlob);
        request.setTimeout(30000);
        
        Http http = new Http();
        HTTPResponse response = new HTTPResponse();
        try{
            response = http.send(request);
            if(response.getStatusCode() != 200) 
            {       
                if (object_type == 'Offering_Resource_Type')
                {
                    PMP_BrightCoveAPIVideoCallouts.performDMLWhenFailedInCreateVideoOffering(videoIdMap,'Failed at uploadVideoToAWS3 - Couldnot upload video to AWS3','uploadVideoToAWS3'); 
                }   
            }
            return String.valueOf(response.getStatusCode());
        }catch(Exception e){
            String error= e.getMessage().substring(0,e.getMessage().length()>250 ? 250 : e.getMessage().length() - 1);
            PMP_BrightCoveAPIVideoCallouts.performDMLWhenFailedInCreateVideoOffering(videoIdMap,error,'uploadVideoToAWS3'); 
            PMP_Utility.logError(e,'PMP_BrightCoveVideoUploadAWS3 - uploadVideoToAWS3');    
            return null;
        }
    }
*/
}