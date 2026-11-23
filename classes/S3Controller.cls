public class S3Controller {
    //S3Controller.UploadDocToS3Server('0698A000001M6gk');
	@AuraEnabled
    public static void UploadDocToS3Server(string recordId)
    {
        System.debug('**recordId---->'+recordId);
        UploadDocument(recordId);
    }
    
    @future(callout=true)
    public static void UploadDocument(string recordId)
    {
        //S3 Key 
        String key = 'AKIAQGF7GMWQSTNBBCXM'; 
        //S3 Secret Key 
        String secret = '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';
        String bucket = 'mytestsalesforce'; 
        String host = 's3-us-east-1.amazonaws.com';
        String method = 'PUT';
        AWSService service=new AWSService();
		    service.UploadDocuments(recordId);
    }
}