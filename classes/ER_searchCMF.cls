public class ER_searchCMF {
    @AuraEnabled(cacheable=true)
    public static String getCMFDetails(String filteron,String filterValue) {
        String endpoint = 'https://edvp-tst.intel.com/server/customer/DirectCustomerInformation/views/DirectCustomerInformation?$start_index=0&$filter="CustomerApplicationSystemMapId"='+filterValue;
        System.debug('ANS'+endpoint);
        string username = 'sys_ERPMDenodo01'; 
        string password = '98765@ERPM$intel4321$';
        string method = 'GET';  
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(120000);
        req.setHeader('Authorization', authorizationHeader);
         res = h.send(req);
        System.debug('ANS'+res.getStatusCode());
        return null;
    }
}