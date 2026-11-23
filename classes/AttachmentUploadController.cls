public with sharing class AttachmentUploadController {
    public static final String CALLOUT = 'aws_s3_storage';
    public static final String BUCKET = 'https://ingestion-upload-production.s3.amazonaws.com';
    
    @AuraEnabled
    public static void uploadFileOrFail(Id parentId, String filename, String fileContent) {
        /*if (filename == null) {
            throw new RuntimeException('Filename is empty');
        }*/

        String uploadFilename = filename.toLowerCase().trim().replaceAll('[^a-z0-9.\\\\s]+', '').replaceAll('[\\\\s]+', '-');
        String key = '/my-directory/' + uploadFilename;
        system.debug('*****key****'+key);
        system.debug('*****fileContent****'+fileContent);
        system.debug('*****uploadFilename****'+uploadFilename);

        S3.saveFileOrFail(CALLOUT, BUCKET, key, fileContent);
	//AttachmentRepository.insertRecord(parentId, key);
    }
}