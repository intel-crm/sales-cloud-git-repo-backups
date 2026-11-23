public class DocparserAPIHandler {
    @AuraEnabled
    public static void callDocparserAPI() {
        //String endpointUrl = 'https://app.docparser.com/v1/document/upload/';
        //String parserId = 'DP_PARSER_ID';
        //String endpointUrl = 'https://app.docparser.com/v1/document/upload/' + parserId + '?remote_id=' + file.Id;
        //PRM_Integration__mdt apiDetails = [Select Id, API_Key__c, EndPointURL__c, Password__c, Username__c from PRM_Integration__mdt where MasterLabel='DocParserAPI'];
        //string token = getToken(apiDetails) != null ? getToken(apiDetails).access_token : null;
        //System.debug('token-->'+token);
        
        
        StaticResource file = [SELECT Id,Name,Body FROM StaticResource WHERE Name = 'Salesforcereleasenotes' LIMIT 1];
        String apiKey = 'fec44cfd75fb64b2f8b748292e1dfa4fd3e557ad';
        String parserId = 'gcxngrtoscke';
        String targetURL = 'https://app.docparser.com/v1/document/upload/' + parserId + '?remote_id=' + file.Id;
        String boundary = 'Control the Content Included in Push Notifications';

        // header
        String header = '--' + boundary + '\nContent-Disposition: form-data; name="file"; filename="' + file.Name + '"\nContent-Type: multipart/form-data;'+'\nnon-svg='+True;
        String headerEncoded;
        do
        {
            header += ' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
        }
        while(headerEncoded.endsWith('='));

        // body
        String footer = '--' + boundary + '--';
        String bodyEncoded = EncodingUtil.base64Encode(file.Body);

        if (bodyEncoded.endsWith('==')) 
        {
            bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length()-2) + '0K';
        }
        else if(bodyEncoded.endsWith('=')) 
        {
            bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length()-1) + 'N';
            footer = '\n' + footer;           
        }
        else
        {
            footer = '\r\n' + footer;
        }
        //footer = '\r\n' + footer;
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        Blob bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
        System.debug('bodyBlob.size()' + bodyBlob.size());

        // send
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        req.setHeader('Authorization', 'Basic ' + apiKey);
        req.setMethod('POST');
        req.setEndpoint(targetURL);
        req.setBodyAsBlob(bodyBlob);
        req.setHeader('Content-Length', String.valueof(req.getBodyAsBlob().size()));
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('res' + res.getBody());
        
        
        
        //HttpResponse res = http.send(req);
        system.debug('res.getStatusCode()-->'+res.getStatusCode());

        if (res.getStatusCode() == 200) {
            String responseBody = res.getBody();
            System.debug('Docparser API Response: ' + responseBody);
            //String responseBody = res.getBody().replaceAll('&lt;','<').replaceAll('&gt;','>');
            //responseBody = responseBody.replace(responseBody.substringBefore('<res>'),'').replace(responseBody.substringAfter('</res>'),'');
            //system.debug('responseBody ===>'+responseBody);
            System.debug('Docparser API Response: ' + res.getBody());              
            
            createDocParserResponseRecord(responseBody); 
        } else {
            String errorMessage = 'Error calling Docparser API. Status Code: ' + res.getStatusCode() + ', Error Message: ' + res.getStatus();
            System.debug(errorMessage);
        }
    }
    public static void createDocParserResponseRecord(String msg){
        system.debug('msg-->'+msg);
        try{
            Id recId,syncObjRecId; 
            String strDetailsAndEx = '';
            if(msg != null){
                DocparserResponse__c dpr = new DocparserResponse__c();
                dpr.Response__c = msg;
                dpr.Status__c = 'Success';
                if(DocparserResponse__c.SObjectType.getDescribe().isCreateable()){ 
                    insert dpr;
                }
            }
        }
        catch(Exception e){
            system.debug('exception-->'+e);
        }
    }
    
    public static PRM_Token_Model getToken(PRM_Integration__mdt apiDetails) {
        PRM_Token_Model token = new PRM_Token_Model();
        try{
            HttpRequest httpReq = new  HttpRequest();
            httpReq.setEndpoint(apiDetails.API_Key__c);
            httpReq.setMethod( 'POST' );
            httpReq.setHeader('content-type', 'application/x-www-form-urlencoded');
            
            //string gType = EncodingUtil.urlEncode('client_credentials','UTF-8');
            String payLoad = 'grant_type=client_credentials&client_id=' + EncodingUtil.urlEncode(apiDetails.Username__c,'UTF-8') +'&client_secret=' + EncodingUtil.urlEncode(apiDetails.Password__c, 'UTF-8');
            system.debug('payload- '+payload);       
            httpReq.setBody(payLoad);
            system.debug('>>>>httpReq'+httpReq.getEndpoint());
            HttpResponse response;
            if(!Test.isRunningTest()){
                response = new Http().send(httpReq); 
            }else{
                response = new HttpResponse();
                response.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5Pbz","token_type": "Bearer","expires_in": "3599","ext_expires_in": "3599"}');
                response.setStatusCode(200);
            }
            
            if(response.getStatusCode() == 200 ) {
                system.debug('Response ===>'+EncodingUtil.urlDecode(response.getBody(), 'UTF-8'));
                token = PRM_Token_Model.parse(response.getBody());
                Cache.Org.put('local.PRMIPAPartition.APIGEEaccesstoken',token.access_token, Integer.valueOf(Label.APIGEETokenExpiryTime),Cache.Visibility.ALL, true);
            }
            
        }
        catch(Exception ex){
            //CustomException custEx = createException(ex);
            //createErrorRecord('API token issue', null, custEx, LOG_ENTRY_ERROR); 
        }
        return token;
    }
}