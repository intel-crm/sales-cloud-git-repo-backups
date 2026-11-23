public class putFileInS3{
    public static void uploadToAWS3(){
        XmlStreamWriter x = new XmlStreamWriter();
    	x.writeStartDocument('utf-8', '1.0');
    	x.writeStartElement(null, 'SERVICE', null);
        x.writeAttribute(null, null, 'version', '1.0');
        x.writeStartElement(null, 'CLIENT', null);
        x.writeAttribute(null, null, 'email', 'aa.aa@aa.aa');
		x.writeStartElement(null, 'BASIC_FIELDS', null); 
        x.writeAttribute(null, null, 'id', '1');
        
        x.writeStartElement(null, 'ADDRESS_LINE_1', null);
        x.writeAttribute(null, null, 'id', '2');
        x.writeCharacters('INDIA');
        x.writeEndElement();
        
         x.writeEndElement();
         x.writeEndElement();
         x.writeEndElement();
         x.writeEndDocument();
        
        String xmlString = x.getXmlString();
        x.close();
        
        Blob xmlBlob = Blob.valueOf(xmlString);
        
        String attachmentBody = EncodingUtil.base64Encode(xmlBlob);
        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String key = 'ASIA25ESRNNE3ZAK3U5C'; //AWS key
        String secret = 'MxQ+SJ/M5tjwHQzT1hZBlB5cdvK3oZAbFlkQlytL'; //AWS Secret key
        String sessionToken = System.label.S3SessionToken;
        String bucketname = 'ingestion-upload-production'; //AWS bucket name
        String host = 's3.amazonaws.com';
        String contentType = 'application/json';
        String method = 'PUT';
        String filename = 'Test from SF';
        
         HttpRequest req = new HttpRequest();
         req.setMethod(method);
         req.setEndpoint('callout:ConnectoS3'+'/'+ filename);
         req.setHeader('Host', 'ingestion-upload-production.s3.amazonaws.com');
         req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
         req.setHeader('Content-Encoding', 'UTF-8');
         req.setHeader('Content-type', 'application/xml'); 
         req.setHeader('Connection', 'keep-alive');
         req.setHeader('Date', formattedDateString);
         req.setHeader('ACL', 'public-read-write');
        
        Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
        req.setBodyAsBlob(pdfBlob);
        
        String stringToSign = 'PUT\n\n' + 'application/xml' + '\n' + formattedDateString + '\n' + '/' + bucketname + '/' + filename;
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String signedKey  = EncodingUtil.base64Encode(mac);
        String authHeader = 'AWS' + ' ' + key + ':' + signedKey ;
        
        //req.setHeader('Authorization',authHeader);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.debug('res--status---->'+res.getStatusCode());
        System.debug('res------>'+res.getBody());
        
    } 
}