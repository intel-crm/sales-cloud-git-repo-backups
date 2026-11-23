@RestResource(urlMapping='/v1.0/partnerDetails/partner')
global class PMP_MarketplacePartnerDetailAPI extends PMP_PartnerDetailsWrapper{    
    @HttpPost
    global static PartnerResponse getPartnerDetails(String accountId){
        Id companyId =null;                   
        STring errorMessage ='Ok';
        
        try{            
            String onePartnerId;                                    
            // if Account id is provided
            for(Core_Account_Group_Member__c cagmRecord : [select Core_Partner_Account_Id__c from Core_Account_Group_Member__c where Core_Inactive_Ind__c = false and Core_Intel_Account_Id__c =:accountId order by LastModifiedDate desc limit 1]){
                onePartnerId = cagmRecord.Core_Partner_Account_Id__c;
            }
            
            if(onePartnerId!=null){
                for(PMP_OPID_MPI_Rel__c mpirel :[select Id,PMP_One_Partner_ID__c, PMP_Marketing_Profile_Id__c, Is_Active__c,PMP_Is_PagAccount_Ind__c, PMP_Storefront_Working_Copy__c,PMP_Storefront_Published_Copy__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c =:onePartnerId and Is_Active__c =true and PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c= false and PMP_Marketing_Profile_Id__r.PMP_Partner_Benefit_Type__c!=null and PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c	='Published' ]){
                    companyId = mpirel.PMP_Marketing_Profile_Id__c;
                }           
            }
            
            if(companyId==null){errorMessage ='No Storefront found for the user!';}                                                                
            
        }catch(Exception ex){errorMessage =  ex.getMessage();}
        
        PartnerResponse response = new PartnerResponse();
        response.errorMessage = errorMessage;
        response.storefrontId = companyId;       
        
        return response;
    }
    
    global class PartnerResponse{
        global String storefrontId{get;set;}
        global String errorMessage{get;set;}
    }
    
}