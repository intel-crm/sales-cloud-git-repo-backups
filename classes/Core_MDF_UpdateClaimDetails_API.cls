@RestResource(urlMapping='/UpdateClaimDetails/')
global class Core_MDF_UpdateClaimDetails_API {
	/*@HttPPost
    global static string sendResponse(string message){
        return 'This is an API response '+message;
    }*/
    
    @HttPPost
    global static string UpdateClaimStatus(string claimNo){
        partnerFundClaim pfc;
        string response = '';
        
        if(string.isNotEmpty(claimNo)){
            string claimToQuery = string.escapeSingleQuotes(claimNo);
            pfc = [select id,Core_MDF_Status__c from PartnerFundClaim where Core_MDF_Claim_Ref_Number__c=:claimToQuery];            
        }
        
        if(pfc!=null && pfc.Core_MDF_Status__c!=null && pfc.Core_MDF_Status__c == 'Payment Due'){
            //status = pfc.Core_MDF_Status__c;
            pfc.Core_MDF_Status__c = 'Cancelled';
            update pfc;
            response = claimNo + ' has been cancelled.';
        }
        else{
            response = 'This claim cannot be cancelled now';
        }
              
        
        return response;
    }            
    
}