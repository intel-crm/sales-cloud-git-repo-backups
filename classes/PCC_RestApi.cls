@RestResource(urlMapping='/api/v1.0/ddr/*')
global with sharing class PCC_RestApi {
    
    @HttpGet
    global static List<Account> getAccount() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //String AccNumber = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<Account> result = [SELECT Id, Name, Phone, Website FROM Account limit 5 ];
        return result;
    }
}