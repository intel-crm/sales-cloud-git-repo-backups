/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_OPID_Storefront_Mapping
* Description : API returnining publised storefront id
* Version     : 1.0 
* Created Date: Aug-2022
* Modification Log :  
* Created By  : DINESH MENGADE
********************************************************************************************************************************************************************************************************/

@RestResource(urlMapping='/v1.0/storefrontdetails')
global without sharing class PMP_OPID_Storefront_Mapping {

    static final string NO_STRFRNT_ERROR = 'No Storefront found for the user!';
    static final String INVALID_ID = 'Invalid Id!';
    /**
    * @description     
    * @param onePartnerId - one partner id from ConnectM System
    * @return PartnerResponse 
    **/
    @HttpPost
    global static PartnerResponse getPartnerDetails(String onePartnerId){
        Id companyId =null;                   
        String errorMessage ='Ok';
        
        
        try{                                    
            if( Schema.sObjectType.PMP_OPID_MPI_Rel__c.fields.PMP_One_Partner_ID__c.isAccessible() && onePartnerId!=null){
                for(PMP_OPID_MPI_Rel__c mpirel :[select Id,PMP_One_Partner_ID__c, PMP_Marketing_Profile_Id__c, Is_Active__c/*,PMP_Is_PagAccount_Ind__c, PMP_Storefront_Working_Copy__c,PMP_Storefront_Published_Copy__c*/ from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c =:onePartnerId and Is_Active__c =true and PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c= false and PMP_Marketing_Profile_Id__r.PMP_Partner_Benefit_Type__c!=null and PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c	='Published' ]){
                    companyId = mpirel.PMP_Marketing_Profile_Id__c;
                } 
                if(companyId==null){errorMessage =NO_STRFRNT_ERROR;}                                                                
            }else{errorMessage = INVALID_ID;}  
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
    
    /*Get the list of valid Pubslished storefronts*/
    global class StorefrontWrapper {
        public Boolean success;
        public List<Id> ids;
        public String message;
    } 
    
    @HttpGet
    global static StorefrontWrapper getStorefrontRecords(){
    	 StorefrontWrapper res = new StorefrontWrapper();
        
         try {
            List<PMP_Company__c> companyLst = [select id from PMP_Company__c where PMP_Company_Lifecycle_Status_Nm__c = 'Published' and PMP_Benefit_Update_Ind__c = false];
            
            res.ids = new List<Id>();
            for (PMP_Company__c cmp : companyLst) {
                res.ids.add(cmp.Id);
            }
            
            res.success = true;
            res.message = 'Fetched successfully';
            
        } catch (Exception e) {
            res.success = false;
            res.message = e.getMessage();
        }
        
        return res;
    }
       
}