public class UCD_ACM_reltioAccountSearch {
    
    public static List<UCD_ACM_accountSearchResponseModel> getAccountByName(UCD_ACM_accountSearchModel accountSearchModel){
        String typeCode = 'configuration/entityTypes/BusinessOrganization';
        String BusinessNameTypeCd = 'SIMPLE';
        String unifiedGlobalCustomer = 'UNFD_GLBL_CUST';
        String unifiedCountryCustomer = 'UNFD_CTRY_CUST';
        String unifiedInterMeCustomer = 'UNFD_INTRMD_CUST';
        String access_Token = getAuthToken();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        system.debug('accountSearchModel--> '+accountSearchModel);
        if(accountSearchModel.BusinessPartyId != null){
            request.setEndpoint('https://apis-stage.intel.com/ucd/operate/v1/entities?filter=(equals(type,\''+typeCode+'\') AND equals(attributes.AggregateParent.BusinessPartyId,\''+accountSearchModel.BusinessPartyId+'\') AND equals(attributes.Addresses.Country,\''+accountSearchModel.Address.Country+'\') AND equals(attributes.CustomerAggregationTypeCd, \''+unifiedCountryCustomer+'\'))');
        }else if(accountSearchModel.CustomerAggregationType != null && accountSearchModel.CustomerAggregationType == 'UNFD_CTRY_CUST' && accountSearchModel.Name != null){
            request.setEndpoint('https://apis-stage.intel.com/ucd/operate/v1/entities?filter=(equals(type,\''+typeCode+'\') AND equals(attributes.Addresses.Country,\''+accountSearchModel.Address.Country+'\') AND contains(attributes.BusinessOrganizationName.BusinessOrganizationNm, \'*'+accountSearchModel.Name+'*\') AND equals(attributes.CustomerAggregationTypeCd, \''+accountSearchModel.CustomerAggregationType+'\'))');
        }else{
            request.setEndpoint('https://apis-stage.intel.com/ucd/operate/v1/entities?filter=(equals(type,\''+typeCode+'\') and equals(attributes.BusinessOrganizationName.BusinessNameTypeCd, \''+BusinessNameTypeCd+'\') AND contains(attributes.BusinessOrganizationName.BusinessOrganizationNm, \'*'+accountSearchModel.Name+'*\') AND  (equals(attributes.CustomerAggregationTypeCd, \''+unifiedGlobalCustomer+'\') OR  equals(attributes.CustomerAggregationTypeCd,\''+unifiedInterMeCustomer+'\')))');
        }
        
    	request.setMethod('GET');
        
        request.setHeader('Authorization', 'Bearer '+access_Token);
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200 && response.getBody() != null){
            List<UCD_ACM_accountSearchResponseModel> accountsResponse = UCD_ACM_accountSearchResponseModel.parse(response.getBody());
            if(accountsResponse.size() > 0){
                return accountsResponse;
            }
        }
        
        return null;
    }
    
    private static String getAuthToken(){
        authTokenResponse authToken = new authTokenResponse();
        
        String payload = 'client_secret=pA_3l5F181~5JycjupSwK2AnOf_eg_3T83&client_id=48d079f0-e1dc-483c-aa90-3721c45666bf&grant_type=client_credentials';
        Http http = new Http();
        HttpRequest tokenRequest = new HttpRequest();
        tokenRequest.setEndpoint('https://apis-stage.intel.com/v1/auth/token');
        tokenRequest.setMethod('POST');
        tokenRequest.setBody(payload);
        HttpResponse response = http.send(tokenRequest);
        if(response.getStatusCode() == 200){
            authToken = (authTokenResponse) JSON.deserialize(response.getBody(), authTokenResponse.class);
            return authToken.access_token;
        }
        return null;
        
    }
    
    public class authTokenResponse{
        public String access_token;
    }

}