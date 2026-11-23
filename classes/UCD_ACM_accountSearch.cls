@RestResource(urlMapping = '/ReltioAccountSearch/*')
global class UCD_ACM_accountSearch {
	@HttpPost
    global static UCD_ACM_accountSearchModel.AccountSearchResponse seachAccount(){
        UCD_ACM_accountSearchModel requestModel = UCD_ACM_accountSearchModel.parseRequestBody(RestContext.request.requestBody.toString());
        List<UCD_ACM_accountSearchResponseModel> accountsResponse = UCD_ACM_reltioAccountSearch.getAccountByName(requestModel);
        UCD_ACM_accountSearchModel.AccountSearchResponse response = mapResponse(accountsResponse);
        return response;
    } 
    
    private static UCD_ACM_accountSearchModel.AccountSearchResponse mapResponse(List<UCD_ACM_accountSearchResponseModel> accountsResponse){
        
        UCD_ACM_accountSearchModel.AccountSearchResponse response = new UCD_ACM_accountSearchModel.AccountSearchResponse();
        
        if(accountsResponse != null){
            response.Status = 'Suceess';
            List<UCD_ACM_accountSearchModel.ResponseData> accountsData = new List<UCD_ACM_accountSearchModel.ResponseData>();
            For(UCD_ACM_accountSearchResponseModel accountResponse : accountsResponse){
                UCD_ACM_accountSearchModel.ResponseData accountData = new UCD_ACM_accountSearchModel.ResponseData();
                UCD_ACM_accountSearchModel.ParentAccount parentAcc = new UCD_ACM_accountSearchModel.ParentAccount();
                // Account Info
                accountData.Name = accountResponse.Attributes.BusinessOrganizationName[0].value.BusinessOrganizationNm[0].value;
                accountData.BusinessPartyId = accountResponse.Attributes.BusinessPartyId != null?accountResponse.Attributes.BusinessPartyId[0].value:null;
                accountData.CustomerProcessEngagement = accountResponse.Attributes.CustomerProcessEngagement != null?accountResponse.Attributes.CustomerProcessEngagement[0].label:null;
                accountData.CustomerAggregationType = accountResponse.Attributes.CustomerAggregationTypeCd != null?accountResponse.Attributes.CustomerAggregationTypeCd[0].value:null;
                //Parent Info
                parentAcc.Name = accountResponse.Attributes.AggregateParent != null ? accountResponse.Attributes.AggregateParent[0].label:null;
                parentAcc.BusinessPartyId = accountResponse.Attributes.AggregateParent != null?accountResponse.Attributes.AggregateParent[0].value.BusinessPartyId[0].value:null;
            	parentAcc.CustomerAggregationType = accountResponse.Attributes.AggregateParent != null?accountResponse.Attributes.AggregateParent[0].value.CustomerAggregationTypeCd[0].value:null;
                
                accountData.ParentAccount = parentAcc;
                accountsData.add(accountData);
            }
            response.Data = accountsData;
            return response;
        }else{
            response.Message = 'No Data Found';
            return response;
        }
        
        
    }
}