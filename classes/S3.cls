public with sharing class S3 {
    public static boolean saveFileOrFail(String callout, String bucket, String key, String content) {
        Blob base64Content = EncodingUtil.base64Decode(EncodingUtil.urlDecode(content, 'UTF-8'));

        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        req.setEndpoint('callout:' + 'https://ingestion-upload-production.s3.amazonaws.com/4090876643001/6283184435001/e3adb1a9-236c-4667-9657-e8f44fdf50d0/newvideoPostman');

        req.setHeader('Host', 'https://ingestion-upload-production.s3.amazonaws.com');
        req.setHeader('Access-Control-Allow-Origin', '*');
        req.setHeader('Content-Length', String.valueOf(content.length()));
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Connection', 'keep-alive');
        req.setBodyAsBlob(base64Content);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if(res.getStatusCode() != 200) {
            throw new S3UploadErrorException(String.ValueOF(res.getBody()));
        }

        return true;
    }
}