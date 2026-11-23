/****************************************************************************************************************************************
* Class Name  : Core_MDF_Vat_Utility 
* Version     : 1.0 
* Created Date: 18-11-2020
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         18/11/2020                    This class hold the Utility methods for the Vat File Approval  
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Vat_Utility {
    
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getVatFileNames(String recordId) {
        try{
            Set<Id> fileId = new Set<Id>();
            Set<String> fileNames = new Set<String>();
            List<ContentDocument> contentFiles = new List<ContentDocument>();
            for(ContentDocumentLink link : [Select id, ContentDocumentId, ContentDocument.Title, ContentDocument.CreatedDate, ContentDocument.CreatedBy.Name
                                            from ContentDocumentLink where LinkedEntityId = :recordId])
            {
                fileId.add(link.ContentDocumentId); 
            }
            for(ContentDocument doc: [Select id, Title, CreatedDate, CreatedBy.Name 
                                      from ContentDocument where Id IN :fileId])
            {
                contentFiles.add(doc); 
            }
            return contentFiles; } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);AuraHandledException ex = new AuraHandledException(e.getMessage());ex.setMessage(e.getMessage());throw ex;}
    }
    
    
    /***************************************************************************************************** 
Method Name:        isEligible
@return  :          VatEligibleWrapper
@parameters:        recordId
Description:        This is a Method to check whether the eligible for selecting the approved file
Added By:           Intel - SM - 18/11/2020 
******************************************************************************************************/   
    @AuraEnabled
    public static VatEligibleWrapper isEligible(String recordId)
    {
        VatEligibleWrapper eligibleWrap = new VatEligibleWrapper();
        try{
            
            Core_MDF_Claim_VAT_Info__c vatRec = [Select Id, Core_MDF_Status_Txt__c from Core_MDF_Claim_VAT_Info__c where Id = :recordId Limit 1];
            Boolean hasCustomPermission = (FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Payment_Admin') || 
                                           FeatureManagement.checkPermission('Core_MDF_CCP_Internal_IPA_Payment_Admin') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Co_GTM_Payment_Adm')) ? true : false;
            List<String> eligibleStatus = Label.Core_MDF_status_for_vat_file_approval.split(',');
            if(eligibleStatus.contains(vatRec.Core_MDF_Status_Txt__c))
            {
                eligibleWrap.vatEligibleforUpdate = true;
                if(hasCustomPermission)
                {
                    eligibleWrap.userEligibletoUpdate=true;          
                }
            }
            return eligibleWrap;  }      catch(exception e){Core_MDF_CCP_UtilityClass.logError(e);AuraHandledException ex = new AuraHandledException(e.getMessage());ex.setMessage(e.getMessage());throw ex;}
    }
    
    
    /***************************************************************************************************** 
Class Name:        VatEligibleWrapper
Description:        This is a Wrapper class to hold the eligibility fields for vat
Added By:           Intel - SM - 18/11/2020 
******************************************************************************************************/   
    
    public class VatEligibleWrapper{
        @AuraEnabled
        public Boolean vatEligibleforUpdate = false;
        @AuraEnabled
        public Boolean userEligibletoUpdate = false;
    }
    
    /***************************************************************************************************** 
Method Name:        caseReviewResultupdatesonVAT
@return  :          void
@parameters:        claimList and action
Description:        This is a Method to check whether the eligible for selecting the approved file
Added By:           Intel - SM - 05/01/2021 
******************************************************************************************************/       
    public static void caseReviewResultupdatesonVAT(List<PartnerFundClaim> claimList, string action)
    {
        try{
            
            Map<Id, PartnerFundClaim> claimMap = new Map<Id, PartnerFundClaim>();
            Map<Id, Core_MDF_Claim_VAT_Info__c> claimVatMap = new Map<Id, Core_MDF_Claim_VAT_Info__c>();
            List<PartnerFundClaim> claimsToBeUpdated = new List<PartnerFundClaim>();
            Map<Id,PartnerFundClaim> clmIdToClmsToBeUpdatedMap = new Map<Id,PartnerFundClaim>();
            List<PartnerFundClaim> claimsToBeReleased = new List<PartnerFundClaim>();
            List<Core_MDF_Claim_VAT_Info__c> vatsToBeUpdated = new List<Core_MDF_Claim_VAT_Info__c>();
            List<Id> vatIdsToBeRejected = new List<Id>();
            for(PartnerFundClaim claim : claimList)
            {
                claimMap.put(claim.Id, claim);
            }
            //to get all the vat records for the given claims
            for(Core_MDF_Claim_VAT_Info__c vat : [Select Core_MDF_Claim_Id__c, Core_MDF_Status_Txt__c, Id from Core_MDF_Claim_VAT_Info__c
                                                  where Core_MDF_Claim_Id__c in :claimMap.keySet()])
            {
                claimVatMap.put(vat.Core_MDF_Claim_Id__c, vat);
            }
            //to loop through the incoming claim list and take action
            for(PartnerFundClaim claim : claimList)
            {
                switch on action{
                    when 'Denied'{
                        //to deny vat and claim when action is to Deny
                        if(claimVatMap != null && claimVatMap.containsKey(claim.Id))
                        {                            
                            Core_MDF_Claim_VAT_Info__c vat = claimVatMap.get(claim.Id);
                            vatIdsToBeRejected.add(vat.Id);
                            vat.Core_MDF_Status_Txt__c = Label.Core_MDF_Claim_Denied_status;
                            claim.Core_MDF_Status__c = Label.Core_MDF_Claim_Denied_status;
                            claim.Core_MDF_VAT_Hold_Ind__c = false;                                                      
                            //claimsToBeUpdated.add(claim);
                            clmIdToClmsToBeUpdatedMap.put(claim.Id,claim);
                            vatsToBeUpdated.add(vat);
                        }                        
                        //to deny claim when no vat
                        else
                        {
                            claim.Core_MDF_Status__c = Label.Core_MDF_Claim_Denied_status;
                            //claimsToBeUpdated.add(claim);
                            clmIdToClmsToBeUpdatedMap.put(claim.Id,claim);
                        }
                        // when claim is denied, set bank document hold indicator to false
                        if(claim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c && claim.Core_MDF_Bank_Doc_Hold_Ind__c){
                            
                            if(clmIdToClmsToBeUpdatedMap.containsKey(claim.Id)){
                                clmIdToClmsToBeUpdatedMap.get(claim.Id).Core_MDF_Bank_Doc_Hold_Ind__c = false;
                            }else{
                                claim.Core_MDF_Bank_Doc_Hold_Ind__c = false; clmIdToClmsToBeUpdatedMap.put(claim.Id,claim);
                            }
                        }
                        
                    }
                    when 'Compliant'{                        
                        // If Bank Document Hold Eligibility is true and Flagged for Bank Doc Hold is false, release claims from Audit hold
                        // Update Bank Doc Hold Indicator to true
                        if(claim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c && !claim.Core_MDF_FlaggedForBankDocHold_Ind__c){
                            claim.Core_MDF_Bank_Doc_Hold_Ind__c = true;
                            claim.Core_MDF_Status__c = Label.Core_MDF_Hold_Status;
                            claim.Core_MDF_Audit_Hold__c = false;
                            clmIdToClmsToBeUpdatedMap.put(claim.Id,claim);
                        }
                        //to release claim when vat is existing
                        //// If Bank Document Hold Eligibility and Flagged for Bank Doc Hold are true, release claims from Audit hold
                        if(claimVatMap != null && claimVatMap.containsKey(claim.Id) && !clmIdToClmsToBeUpdatedMap.containsKey(claim.Id))
                        {
                            
                            claimsToBeReleased.add(claim);
                        }
                        //to release claim from audit hold and put claim on vat hold when vat amount is > 0 and bank doc hold is true
                        else if(claim.Core_MDF_VAT_Amt__c>0 && claim.Core_MDF_VAT_Eligibility_Ind__c)
                        {
                            if(clmIdToClmsToBeUpdatedMap.containsKey(claim.Id)){
                                clmIdToClmsToBeUpdatedMap.get(claim.Id).Core_MDF_Status__c = Label.Core_MDF_Hold_Status;
                                clmIdToClmsToBeUpdatedMap.get(claim.Id).Core_MDF_VAT_Hold_Ind__c = true;
                                clmIdToClmsToBeUpdatedMap.get(claim.Id).Core_MDF_Audit_Hold__c = false;
                            }else{
                                claim.Core_MDF_Status__c = Label.Core_MDF_Hold_Status;claim.Core_MDF_VAT_Hold_Ind__c = true;claim.Core_MDF_Audit_Hold__c = false;
                                //claimsToBeUpdated.add(claim);
                                clmIdToClmsToBeUpdatedMap.put(claim.Id,claim);
                            }
                           
                        }                       
                        //to release claim from audit hold when bank vat % and claim vat amount is 0
                        else if(!clmIdToClmsToBeUpdatedMap.containsKey(claim.Id)){
                            claimsToBeReleased.add(claim);
                                                     
                        }
                    }
                }   
            }
            
            if(claimsToBeReleased != null && claimsToBeReleased.size()>0)
            {
                Core_MDF_Claim_Utility.releaseHold(claimsToBeReleased,new List<string>{Label.Core_MDF_Audit_Hold});
            }
            /*if(claimsToBeUpdated != null && claimsToBeUpdated.size()>0)
{
Database.update(claimsToBeUpdated);
}*/
            
            if(clmIdToClmsToBeUpdatedMap.size() > 0){
                Database.update(clmIdToClmsToBeUpdatedMap.values());
            }
            //to remove vat from approval queue when action is to deny
            if(vatIdsToBeRejected != null && vatIdsToBeRejected.size()>0)
            {
                Core_MDF_VAT_ApprovalQueueRemoval.removeRecordsFromApprovalQueue(vatIdsToBeRejected);
            }
            if(vatsToBeUpdated != null && vatsToBeUpdated.size()>0)
            {
                Database.update(vatsToBeUpdated);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
    }
    
    public class CaseReviewResultParams
    {
        @InvocableVariable(label = 'Claims' required = true)
        public List<PartnerFundClaim> inputClaims;
        @InvocableVariable(label = 'Action' required = true)
        public String action;
    }
    
    @InvocableMethod
    public static void invokeCaseReviewResultupdatesonVAT(List<CaseReviewResultParams> reviewParams)
    {
        Map<string,List<PartnerFundClaim>> mapOfClaimsandAction = new Map<string,List<PartnerFundClaim>>();
        //bulkified in case when the bulk claims are getting from the time based workflow for case denial
        if(reviewParams!= null && reviewParams.size()>0)
        {
            for(CaseReviewResultParams param : reviewParams)
            {
                //to group claims based on the action
                if(mapOfClaimsandAction.containsKey(param.action)){
                        mapOfClaimsandAction.get(param.action).addAll(param.inputClaims);
                    }
                    else{
                        mapOfClaimsandAction.put(param.action, param.inputClaims);
                    }
                }
            }
            if(mapOfClaimsandAction != NULL && mapOfClaimsandAction.size()>0)
            {
                //to call the actual method based on the action
                for(string key : mapOfClaimsandAction.keySet())
                {
                    if(mapOfClaimsandAction.get(key).size()>0)
                    {
                       caseReviewResultupdatesonVAT(mapOfClaimsandAction.get(key),key); 
                    }
                }
                
            }   
     }

    @AuraEnabled
    public static void updateApprovedVatFile(Id vatId, Id fileId, String fileName) {
        update new Core_MDF_Claim_VAT_Info__c(
            Id = vatId,
            Core_MDF_Approved_File_Id__c = fileId,
            Core_MDF_Approved_File_Name_Txt__c = fileName
        );
    }

}