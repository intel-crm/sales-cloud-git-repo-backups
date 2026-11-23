/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_Close_Adjustment 
* Version     : 1.0 
* Created Date: 08-July-2019
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Areefa         08-July-2019                    This class holds the methods for closing Adjustment Claim Scenario     
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PFC_Close_Adjustment {
    
    /***************************************************************************************************** 
Method Name:        hasAccess
@return  :          Boolean
Description:        This method is used to check whether the logged in user has access to Close Claim.
Added By:           Intel - Areefa   - 08 July,2019
Modified By:        Date:       Changes: 
******************************************************************************************************/
    @AuraEnabled
    Public static Boolean hasAccess(){
        try {
            //Checking User permission from custom permission
            Boolean hasCustomPermission = FeatureManagement.checkPermission(Label.Core_MDF_FinanceMgr_FinanceUser_ClaimCaseRev_ClaimCaseMgr);
            return hasCustomPermission;}catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); throw e; } ///throw new AuraHandledException(''+e.getMessage()); 
    }
    
    /***************************************************************************************************** 
Method Name:        EligibilityToCloseWrapper
Description:        This wrapper return Claim close Eligibility 
Added By:           Intel - Areefa  - 08/07/2019
Modified By:        Date:       Changes: 
******************************************************************************************************/      
    public class EligibilityToCloseWrapper{
        @AuraEnabled
        public Boolean hasAccess = false;
        @AuraEnabled
        public Boolean adjustmentClaimType = false;       
        @AuraEnabled
        public Boolean restrictClaimWithoutOffset = false;
        @AuraEnabled
        public Boolean isPAF = false; 
        @AuraEnabled
        public Boolean claimCannotBeClose = false;      
        
    }
    
    
    /***************************************************************************************************** 
Method Name:        claimEligibleForClose
@return  :          Boolean
Description:        This method is used to check whether the Claim is Eligible for Close or not
Added By:           Intel - Areefa   - 10 July,2019
Modified By:        Date:       Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static eligibilityToCloseWrapper claimEligibleForClose(Id claimId){ 
        
        try{
            
            eligibilityToCloseWrapper eligibilityToClose = new eligibilityToCloseWrapper(); 
            
            //check User has access to Close claim
            boolean hasAccess = hasAccess();
            if(hasAccess){
                // set user access falg
                eligibilityToClose.hasAccess = true;
                
                //Query Claim Type and its Status
                PartnerFundClaim  claim = [Select Core_MDF_Type_Txt__c,Core_MDF_Status__c from PartnerFundClaim where Id = : claimId]; 
                
                // Claim Type : Adjustment
                if(Core_MDF_Claim_Utility.isType(claim, Label.Core_MDF_Claim_Adjustment_Type)){
                    eligibilityToClose.adjustmentClaimType = true;
                    //PAF
                    if(claim.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_Pending_Available_Fund){
                        
                        eligibilityToClose.isPAF = true;
                        // To get the Claim Offset details 
                        List<Core_MDF_Claim_Offset__c> offsetRecordList = [select id,Core_MDF_Adjustment_Claim_Nbr__c from Core_MDF_Claim_Offset__c where Core_MDF_Adjustment_Claim_Nbr__c= :claimId]; 
                        
                        // Partial offset
                        if(offsetRecordList != null && offsetRecordList.size() > 0 ){                               
                            eligibilityToClose.restrictClaimWithoutOffset = false;
                        }
                        //No offset
                        else{                            
                            eligibilityToClose.restrictClaimWithoutOffset = true;
                        }                        
                    }
                    else{
                        eligibilityToClose.claimCannotBeClose = true;
                    }                    
                }
                else{
                    // Positive Claims
                    eligibilityToClose.adjustmentClaimType = false;
                }
                
            }else{ 
                //user doesnot have access
                eligibilityToClose.hasAccess = false;
            }
            return eligibilityToClose;} catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e; } ///throw new AuraHandledException(''+e.getMessage());   
    }  
    
    /***************************************************************************************************** 
    Method Name:        closeClaims
    @return  :          boolean
    @parameters:        claimIdList
    Description:        This is a Method to be used to Close a list of claims, it will take care of validation , if claim doesnot have offset
    Added By:           Intel - Areefa  - 08/07/2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/       
    @AuraEnabled
    public static boolean closeClaims(List<Id> claimIdList)
    {
        system.debug('claimIdList-->' +claimIdList);
        Boolean success = true;
        try{
        List<PartnerFundClaim> claimToBeProcessClose = new List<PartnerFundClaim>();       
        
         //  Query all claims  
        Map<Id,PartnerFundClaim> claimMap = new Map<Id,PartnerFundClaim>([SELECT Id,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c 
                                      				FROM PartnerFundClaim
                                                    WHERE  Core_MDF_Status__c =: Label.Core_MDF_Status_Pending_Available_Fund                                  					
                                                    AND Id IN (SELECT Core_MDF_Adjustment_Claim_Nbr__c
                                               						FROM Core_MDF_Claim_Offset__c 
                                               						WHERE Core_MDF_Adjustment_Claim_Nbr__c IN :claimIdList)]); //WHERE Core_MDF_Status__c='Pending Available Fund'
        system.debug('claimMap values-->' +claimMap.values());
        if(!claimMap.isEmpty()){                       
            updateClaimCloseStatus(claimMap.values());
        }
        system.debug('success' +success);
        return success; 
        } 
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e; } ///throw new AuraHandledException(''+e.getMessage()); 
    }
    
    /***************************************************************************************************** 
        Method Name:        updateClaimCloseStatus
        @return  :          NA
        @parameters:        listOfClaimTobeProcess
        Description:        This is a Method to be used to chnage the status of claim to Close 
        Added By:           Intel - Areefa  - 11/07/2019
        Modified By:        Date:       Changes: 
    ******************************************************************************************************/  
    public static void updateClaimCloseStatus(List<PartnerFundClaim> listOfClaimTobeProcess)  
    {         
        try
        {   system.debug('listOfClaimTobeProcess-->' +listOfClaimTobeProcess);
            List<PartnerFundClaim> claimToBeClosed = new List<PartnerFundClaim>();
            for(PartnerFundClaim claim : listOfClaimTobeProcess)
            {   
                system.debug('Status-->' +claim.Core_MDF_Status__c);
                claim.Core_MDF_Claim_Previous_Status__c = claim.Core_MDF_Status__c ; 
                claim.Core_MDF_Status__c = Label.Core_MDF_Status_Close; // Status: Close                                                           
                claimToBeClosed.add(claim);
                system.debug('claimToBeClosed-->' +claimToBeClosed);
            }            
           Database.update(claimToBeClosed); 
         system.debug('After update' +claimToBeClosed);
      }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e; } ///throw new AuraHandledException(''+e.getMessage()); 
    }
    
}