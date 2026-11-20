/****************************************************************************************************************************************
* Class Name  : Core_MDF_CheckVatClaimCount 
* Version     : 1.0 
* Created Date: 10-Nov-2020
* Modification Log :
* Developer            Date                 Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Pranav       10-NOV-2020      This Class Checks If there exist Vat Claim Records Are there In a Payment Run. 
*****************************************************************************************************************************************/

public without sharing class Core_MDF_VatUtility {
    
    /****************************************************************************************************** 
     Method Name:        getCountOfVatClaimRecords
     @return  :          List of Boolean
     @parameters:        List of Payment Run Ids 
     Description:        This Function checks if there are any vat eligible claims picked during the payment Run
     Added By:           Pranav - Accenture - 11/11/2020 
     Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
    @InvocableMethod
    public static List<Boolean> getCountOfVatClaimRecords(List<Id> paymentRunId){
        //  Added List of Boolean as Invocable Method supports return type list of primitive data type only 
        List<Boolean> ifVatEligibleClaimExists = new List<Boolean>();
         // List of Vat Claims
        List<PartnerFundClaim> vatClaimList = new List<PartnerFundClaim>();
        
        // Querying Vat claims for given Payment Run
        vatClaimList = [Select Id, Core_MDF_Payment_Id__r.Core_MDF_Payment_Run_Id__c from PartnerFundClaim Where Core_MDF_Payment_Id__r.Core_MDF_Payment_Run_Id__c IN: paymentRunId AND Core_MDF_VAT_Eligibility_Ind__c = true];        
        // If Count of Claim is greater than zero; Add true in List of Boolean
        if(vatClaimList.size() > 0){ifVatEligibleClaimExists.add(true);}        
        else{
            // If Count of Claim is zero; Add false in List of Boolean
            ifVatEligibleClaimExists.add(false);
        }
        return ifVatEligibleClaimExists;
    }
    
    /****************************************************************************************************** 
     Method Name:        chkCountOfVatClaims
     @return  :          List of Boolean
     @parameters:        List of Payment Run Records 
     Description:        This Function checks if there are any vat eligible claims picked during the payment Run
     Added By:           Pranav - Accenture - 26/11/2020 
     Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
   /* public static List<Boolean> chkCountOfVatClaims(List<Core_MDF_Payment_Run__c> paymentRunRecsList){
        //  Added List of Boolean as Invocable Method supports return type list of primitive data type only 
        List<Boolean> vatEligibleClaimExistsBoolean = new List<Boolean>();
        // List To Hold aggregated Result of Count of Vat Eligible Claims
        AggregateResult countOfVatClaims ;
        // To store count of claims
        Integer vatClaimCount = 0;
        // Payment Run record
        Core_MDF_Payment_Run__c pRunRecord = paymentRunRecsList[0];
        
        // Query to get count of Vat Claim records for given budget type,start date,end date ,Geo
        countOfVatClaims = [Select count(Id) countOfVatClaim from PartnerFundClaim Where Core_MDF_VAT_Eligibility_Ind__c = true AND Core_MDF_Budget_Type_Options_Nm__c =: pRunRecord.Core_MDF_Budget_Type_nm__c AND Core_MDF_Ad_Run_Start_Date__c >=: pRunRecord.Core_MDF_Start_Dt__c AND Core_MDF_Ad_Run_End_Date__c <=: pRunRecord.Core_MDF_End_Dt__c AND Core_MDF_Region_Cd__c =: pRunRecord.Core_MDF_Geo_Txt__c AND ((Core_MDF_Status__c=:Label.Core_MDF_Status_Pending_Available_Fund AND Core_MDF_Type_Txt__c =:Label.Core_MDF_NegativeClaim) OR (Core_MDF_Status__c=:Label.Core_MDF_Status_Payment_Due ))];        
        
        // Assigning Count of Vat Claim to variable
        vatClaimCount = (Integer)countOfvatClaims.get('countOfVatClaim');
        
        if(vatClaimCount > 0){
            // If Count of Claim is greater than zero; Add true in List of Boolean
            vatEligibleClaimExistsBoolean.add(true);
        }        
        else{
            // If Count of Claim is zero; Add false in List of Boolean
            vatEligibleClaimExistsBoolean.add(false);
        }
        return vatEligibleClaimExistsBoolean;
    }*/
}