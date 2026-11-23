@RestResource(urlMapping='/PartnerFundClaims/*')
global with sharing class testExternalApiService {
    
    @HttpGet
    global static list<PartnerFundClaim> getAccountById() {
        // Retrieve the ID from the request URL
        RestRequest req = RestContext.request;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        // Query the Account object
        list<PartnerFundClaim> PartnerFundClaims = [SELECT Id from PartnerFundClaim LIMIT 10];
        System.debug('testAmeyjhc '+PartnerFundClaims);
        // Return the queried Account record
        return PartnerFundClaims;
    }
}