/****************************************************************************************************************************************
* Class Name  : Core_MDF_ClaimReviewCaseProcess
* Version     : 1.0   
* Created Date: 03-26-2019
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture K Alka         03/26/2019                    Created Core_MDF_ClaimReviewCaseProcess for Common Utility Methods      
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ClaimReviewCaseProcess {
    /****************************************************************************************************************************************
    Method Name:                                             processClaimReviewCases
    @return  :                                               Void
    @parameters:                                             newClaimList and oldClaimMap
    Description:                                             Update claim review cases when there is change in Claim information
                                                             for which Claim records are passed as parameter or create new Claim review case 
                                                             if Claim is flagged for audit
    Modified By:                  Date:                      Changes: 
    Accenture  K Alka             03/26/2019                 Created.
    *****************************************************************************************************************************************/ 
    public static void processClaimReviewCases(List<PartnerFundClaim> newClaimList, Map<Id,PartnerFundClaim> oldClaimMap){ 
        
        //variable declarations
        List<PartnerFundClaim> pfcListForNewCases = new List<PartnerFundClaim>();
        List<PartnerFundClaim> pfcListToBeUpdated = new List<PartnerFundClaim>();
        Map<Id,PartnerFundRequest> pfrIdMap;
        List<Id> caseOwnerIdList = new List<Id>();
        
        // Added to fetch all the co-marketing record types
        List<Id> claimRecordTypeID  = new List<Id>();   
        List<String> recTypeDeveloperName = Label.Core_MDF_CCP_ClaimRecordType_API_Name.split(',');
        for(String str: recTypeDeveloperName){
            claimRecordTypeID.add(Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get(str).getRecordTypeId());
        }
        System.debug('claimRecordTypeID: '+claimRecordTypeID);             
        
        try{
            for(PartnerFundClaim pfc : newClaimList){ 
                
                // Checking claim record type matches with co-marketing record type
                if(claimRecordTypeID.contains(pfc.RecordTypeId)){
                    if(oldClaimMap != null && oldClaimMap.size() > 0   
                        && oldClaimMap.get(pfc.ID).Core_MDF_FlaggedForAudit__c != pfc.Core_MDF_FlaggedForAudit__c 
                        && pfc.Core_MDF_FlaggedForAudit__c == true){
                            pfcListForNewCases.add(pfc);
                    }
                    
                    // checking whether the below fields are updated or not
                    // added a line to check whether Core_MDF_Total_Claim_Offsets__c is updated or not
                    // JV-Accenture: Added a condition to check whether Requested Amount is changed to update the same on the resp. Case field
                    // SN-Accenture: Added conditions to check whether Claim Number and Invoice Number is changed to update the same on the respective Case field
                    if(oldClaimMap != null && oldClaimMap.size() > 0
                        && pfc.Core_MDF_FlaggedForAudit__c == true
                        && ((oldClaimMap.get(pfc.ID).Core_MDF_Status__c != pfc.Core_MDF_Status__c
                        && pfc.Core_MDF_Status__c == 'Cancelled')
                        || oldClaimMap.get(pfc.ID).Amount != pfc.Amount
                        || oldClaimMap.get(pfc.ID).Core_MDF_Exchange_rate__c != pfc.Core_MDF_Exchange_rate__c
                        || oldClaimMap.get(pfc.ID).Core_MDF_Currency__c != pfc.Core_MDF_Currency__c
                        || oldClaimMap.get(pfc.ID).Core_MDF_Taxes_Local__c != pfc.Core_MDF_Taxes_Local__c
                        || oldClaimMap.get(pfc.ID).Core_MDF_Invoice_Date__c != pfc.Core_MDF_Invoice_Date__c
                        || oldClaimMap.get(pfc.ID).Core_MDF_OtherCostsnotReimbursable_Local__c != pfc.Core_MDF_OtherCostsnotReimbursable_Local__c
                        || oldClaimMap.get(pfc.ID).Core_MDF_Total_Invoice_Amount_Local__c != pfc.Core_MDF_Total_Invoice_Amount_Local__c
                        || oldClaimMap.get(pfc.ID).OwnerId != pfc.OwnerId
                        || oldClaimMap.get(pfc.ID).Core_MDF_Requested_Reimbursement_Amt__c != pfc.Core_MDF_Requested_Reimbursement_Amt__c  
                        || oldClaimMap.get(pfc.ID).Core_MDF_Invoice_Number__c != pfc.Core_MDF_Invoice_Number__c
                        || oldClaimMap.get(pfc.ID).Core_MDF_Claim_Ref_Number__c != pfc.Core_MDF_Claim_Ref_Number__c
                        //|| oldClaimMap.get(pfc.ID).Core_MDF_Total_Claim_Offsets__c != pfc.Core_MDF_Total_Claim_Offsets__c
                           )){
                            pfcListToBeUpdated.add(pfc);
                            
                            // checking whether the owner id is changed or not
                            if(oldClaimMap.get(pfc.ID).OwnerId != pfc.OwnerId){
                                System.debug('oldClaimMap.get(pfc.ID).OwnerId***'+oldClaimMap.get(pfc.ID).OwnerId);
                                System.debug('pfc.OwnerId***'+pfc.OwnerId);
                                caseOwnerIdList.add(pfc.OwnerId);   
                            }
                    }
                }
            }
            System.debug('pfcListForNewCases***'+pfcListForNewCases);
            
            
            
            // calling the method for case creation
            if(pfcListForNewCases.size()>0){
                //ID jobID = System.enqueueJob(new Core_MDF_ClaimReviewCaseProcessHelper(pfcListForNewCases,'CreateCases'));
                //InsertAudHoldClaimsForCaseRetry(pfcListForNewCases);//Added by Ealisha
                
                Id batchInstanceId = Database.executeBatch(new Core_MDF_ClaimReviewCaseProcessHelper(pfcListForNewCases,'CreateCases'),50);
                InsertAudHoldClaimsForCaseRetry(pfcListForNewCases);//Added by Ealisha
           }
            
            // calling the method for case updation
            System.debug('pfcListToBeUpdated***'+pfcListToBeUpdated);
            if(pfcListToBeUpdated.size()>0){
                //ID jobID = System.enqueueJob(new Core_MDF_ClaimReviewCaseProcessHelper(pfcListToBeUpdated,'UpdateCases',caseOwnerIdList));
                //InsertAudHoldClaimsForCaseRetry(pfcListToBeUpdated);//Added by Ealisha
                Id batchInstanceId = Database.executeBatch(new Core_MDF_ClaimReviewCaseProcessHelper(pfcListToBeUpdated,'UpdateCases',caseOwnerIdList),50);
                InsertAudHoldClaimsForCaseRetry(pfcListToBeUpdated);//Added by Ealisha
            }
        }catch(exception ex){
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(ex.getMessage(),'Core_MDF_ClaimReviewCaseProcess.processClaimReviewCases');
        }    
    }
    
    //Added by Ealisha-Retry Case creation-US518106
    public static void InsertAudHoldClaimsForCaseRetry(List<PartnerFundClaim> pfcListForNewCases){           
                List<Core_MDF_Audit_Hold_Claim__c> claimsForCaseGen = new List<Core_MDF_Audit_Hold_Claim__c>();
                // Modifications by JV- Accenture:
                Map<String,Core_MDF_Audit_Hold_Claim__c> existingClaimIdToAHCMap = new Map<String,Core_MDF_Audit_Hold_Claim__c>();
                List<String> claimIds = new List<String>();
        try{        
        for(PartnerFundClaim claim : pfcListForNewCases){ claimIds.add(claim.id);}
                for(Core_MDF_Audit_Hold_Claim__c existingAHC : [SELECT Id,Core_MDF_Claim_Id__c,
                                                                Name,Core_MDF_Status__c,Core_MDF_Retry_Indicator__c
                                                                FROM Core_MDF_Audit_Hold_Claim__c 
                                                                WHERE Core_MDF_Claim_Id__c IN:claimIds])
                {
                     existingClaimIdToAHCMap.put(existingAHC.Core_MDF_Claim_Id__c,existingAHC);                                                  
                }
                // checking review case on claim is null
                for(PartnerFundClaim pfc: pfcListForNewCases){
                    // Modified by JV- Accenture : modified the upsert logic incase the AHC already exists
                    Core_MDF_Audit_Hold_Claim__c ahc;
                    if(existingClaimIdToAHCMap != null && existingClaimIdToAHCMap.size() > 0){
                       ahc = existingClaimIdToAHCMap.containsKey(pfc.Id) ? existingClaimIdToAHCMap.get(pfc.Id) : new Core_MDF_Audit_Hold_Claim__c();    
                    }else{
                      ahc = new Core_MDF_Audit_Hold_Claim__c();  
                      ahc.Core_MDF_Claim_Id__c=pfc.Id;
                      ahc.Name=pfc.Title;
                      ahc.Core_MDF_Status__c='Pending';
                      ahc.Core_MDF_Retry_Indicator__c = 0;
                    }                   
                    claimsForCaseGen.add(ahc);                                    
                }
                if(claimsForCaseGen != null && claimsForCaseGen.size() > 0){
                    Database.upsertResult[] ahcLst = Database.upsert(claimsForCaseGen, false);

                }
        }
        catch(exception ex){
            throw ex;
            //Core_MDF_CCP_UtilityClass.logErrorinLogObject(ex.getMessage(),'Core_MDF_ClaimReviewCaseProcess.InsertAudHoldClaimsForCaseRetry');
        }
    }
}