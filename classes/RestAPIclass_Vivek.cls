@RestResource(urlMapping='/fetchClaimDtls/')
global class RestAPIclass_Vivek {
	/*@HttPPost
    global static string sendResponse(string message){
        return 'This is an API response '+message;
    }*/
    
    @HttPPost
    global static string fetchClaimStatus(string claimNo){
        partnerFundClaim pfc;
        string status = '';
        
        if(string.isNotEmpty(claimNo)){
            string claimToQuery = string.escapeSingleQuotes(claimNo);
            pfc = [select id,Core_MDF_Status__c from PartnerFundClaim where Core_MDF_Claim_Ref_Number__c=:claimToQuery];            
        }
        
        if(pfc!=null && pfc.Core_MDF_Status__c!=null){
            status = pfc.Core_MDF_Status__c;
        }
        
        return status;
    }            
    
}