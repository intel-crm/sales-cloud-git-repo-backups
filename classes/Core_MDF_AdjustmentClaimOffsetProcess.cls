/****************************************************************************************************************************************
* Class Name  : Core_MDF_AdjustmentClaimOffsetProcess 
* Version     : 1.0   
* Created Date: 06/03/2018 
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - AD     06/03/2018                    Class contains all the methods supporting the Adjustment Claim offset process
*****************************************************************************************************************************************/
public without sharing class Core_MDF_AdjustmentClaimOffsetProcess {

// Program Set 
public static Set<String> programSet = new Set<String>();
public static Set<String> paymentType = new Set<String>();
// Geo Set
public static Set<String> geoSet=new Set<String>();
// Subgeo Set
public static Set<String> subgeoSet = new Set<String>();
public static Set<String> budgetTypeSet;// = new Set<String>(); 
public static Set<Id> setOfSelAccounts=new Set<Id>();
public static Set<Date> payStartDt = new Set<Date>();
public static Set<Date> payEndDt = new Set<Date>();
public static Set<String> mdfPaymentRunRecordTypes=new Set<String>();
//OOC (Out of Cycle) - specific claims selected on the payment run
public static Set<Id> selectedClaimIds = new Set<Id>();
//Map of channel program meta data
public static Map<String,String> mapOfProgramMetadata = new Map<String,String>();
public static String surePay = Label.Core_MDF_nonTranslate_Sure_Pay;
public static string REVIEW_COMPLETED = Core_MDF_CCP_ConstantClass.REVIEW_COMPLETED ;
private static String CoGTMProgram = Core_MDF_CustomLabelConfig.getTextValues('Co_GTM');
/****************************************************************************************************** 
Method Name:        performClaimAdjustmentProcess
@return  :          N/A
@parameters:        List of payment run records
Description:        This method is used to perform claim offseting and send PD claims to payment process/update remaining claims
Added By:           Accenture - AD - 06/03/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static List<PartnerFundClaim> performClaimAdjustmentProcess(List<Core_MDF_Payment_Run__c> paymentRunRecordsTobeProcessed){
        //List of payment run records
        List<PartnerFundClaim> paymentDueClaimsToBeProcessed;
            paymentDueClaimsToBeProcessed = groupClaimsforPayment(paymentRunRecordsTobeProcessed);
        return paymentDueClaimsToBeProcessed;
    }   
    
/****************************************************************************************************** 
Method Name:        groupClaimsforPayment
@return  :          Map of uniqueKey as key List of claims as value
@parameters:        List of payment run records
Description:        This method is used to query all claims (including adjustments) based on status PAF/PD, Geo/country,program and create map for same
Added By:           Accenture - HP - 11/06/2020
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static List<PartnerFundClaim> groupClaimsforPayment(List<Core_MDF_Payment_Run__c> paymentRunRecordsTobeProcessed){
        //Unique Key - company account node+program
        String uniqueKey = '';
        
        //List of retail or IPA claims
        List<PartnerFundClaim> retailOrIpaClaimsToBeProcessed = new List<PartnerFundClaim>();
        List<PartnerFundClaim> cogtmClaimsToBeProcessed = new List<PartnerFundClaim>();
        //List of CMP Payment claims
        List<PartnerFundClaim> cmpPaymentClaimsToBeProcessed= new List<PartnerFundClaim>();
        //custom label for type of claims for offset processs  - Claim,Escalation Claim
        List<String> validClaimTypeForOffsetProcess = Label.Core_MDF_TypeOfClaimForOffsetProcess.split(',');
        //Production Test Account Ids to Be Excluded 
        List<String> testAccountIdstobeExcluded = Label.Core_MDF_TestAccountIdsToBeExcluded.split(',');
        //create sets for query filter
        generateQueryFilters(paymentRunRecordsTobeProcessed);
        //List of payment run records
        List<PartnerFundClaim> paymentDueClaimsToBeProcessed = new List<PartnerFundClaim>();
        //List of claims to be processed 
        List<PartnerFundClaim> claimsTobeProcessed = new List<PartnerFundClaim>();
        //For RMF Program, Claims To Be queried
        if(programSet.contains(Label.Core_MDF_Retail_Program_Name) || programSet.contains(Label.Core_MDF_IPA_Program_Name)){
        
          retailOrIpaClaimsToBeProcessed = query_Retail_IPA_CMDF_Claims();
          //Adding retail, IPA claims to final list 
           if(retailOrIpaClaimsToBeProcessed !=null && retailOrIpaClaimsToBeProcessed.size()>0){
            paymentDueClaimsToBeProcessed.addAll(retailOrIpaClaimsToBeProcessed);
           }
        } else if(programSet.contains(CoGTMProgram)){
          cogtmClaimsToBeProcessed = Core_MDF_PaymentUtility.queryPaymentDueClaimsForPayment(paymentRunRecordsTobeProcessed);
          if(cogtmClaimsToBeProcessed !=null && cogtmClaimsToBeProcessed.size() > 0){
              paymentDueClaimsToBeProcessed.addAll(cogtmClaimsToBeProcessed);
          }
      }
        else{ //For Comarketing Programs - MDF & CMP
            //Account selection is mandatory for standard MDF payment runs, optional for OOC payment runs (selectedClaimIds populated)
            if(mdfPaymentRunRecordTypes!=null && mdfPaymentRunRecordTypes.size()>0 && (setOfSelAccounts.size()>0 || !selectedClaimIds.isEmpty())){
                 String paymentDueStatus = Label.Core_MDF_Status_Payment_Due;
                 String mdfClaimsQuery = 'SELECT Id,CreatedDate,Core_MDF_Country_Location_nm__c,Core_MDF_Requested_Reimbursement_Amt__c,ChannelPartnerId,ChannelPartner.Core_MDF_Group_Id__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Program__c,Amount,Core_MDF_Status__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,'
                 + 'Core_MDF_Bank__c,Core_MDF_Bank__r.Core_MDF_Supplier_Number__c,Core_MDF_Payment_Id__c,Core_MDF_Bank__r.Core_MDF_Payment_Method_Code__c,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Ad_Run_End_Date__c,Core_MDF_RMF_Last_POP_Submission_Dt__c,Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_RMF_Claim_Approval_Dt__c,'
                 + 'Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c,Core_MDF_Bank__r.Core_MDF_Supplier_Name__c,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c ,Request.ChannelPartner.Core_MDF_Channel_Program__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,'
                 + 'ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Type_Txt__c,Core_MDF_C_Type_Ind__c,'
                 + 'Core_MDF_AccountCompany__c,Core_MDF_VAT_Eligibility_Ind__c,Request.Core_MDF_Activity_Number__c,Core_MDF_Quarter_Year_Txt__c,ChannelPartner.Name,Core_MDF_Claim_Ref_Number__c,Title,Core_MDF_Activity_Types__c,Budget.Title,Request.Title,'
                 + 'Request.Core_MDF_Intel_Activity_Owner_Id__c,Request.Core_MDF_Intel_Activity_Owner_Id__r.Name,Request.Core_MDF_Member_Owner_txt__c,Request.Core_MDF_Priorities__c,Request.Core_MDF_ProductType__c,Request.Core_MDF_TargetAudience__c,Request.Campaign.Name FROM PartnerFundClaim '
                 + 'WHERE Core_MDF_Program__c IN:programSet'
                 + ' AND Core_MDF_Budget_Type_Options_Nm__c IN: budgetTypeSet'
                 + ' AND (Core_MDF_Status__c=:paymentDueStatus'
                 + ' AND Core_MDF_Type_Txt__c  IN:validClaimTypeForOffsetProcess)'
                 + ' AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c'
                 + ' NOT IN: testAccountIdstobeExcluded'
                 + ' AND Core_MDF_Recovery_Hold_Ind__c = FALSE AND (Core_MDF_Processing_Preference_nm__c !=: surePay OR (Core_MDF_Processing_Preference_nm__c =: surePay AND (Core_MDF_VAT_Eligibility_Ind__c = TRUE OR (Core_MDF_Claim_Review_Case__c = NULL OR (Core_MDF_Claim_Review_Case__c != NULL AND Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c =: REVIEW_COMPLETED)))))';
                 //Account filter is mandatory for standard MDF payment runs, optional for OOC
                 if(!setOfSelAccounts.isEmpty()){
                     mdfClaimsQuery += ' AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN:setOfSelAccounts';
                 }
                 //OOC payment run - run for specific claims
                 if(!selectedClaimIds.isEmpty()){
                     mdfClaimsQuery += ' AND Id IN :selectedClaimIds';
                 }
                 mdfClaimsQuery += ' ORDER BY Core_MDF_Status__c DESC';
                 claimsTobeProcessed = Database.query(mdfClaimsQuery);
                
                paymentDueClaimsToBeProcessed.addAll(claimsTobeProcessed);
            }
            else{
                //CMP Payments
                cmpPaymentClaimsToBeProcessed =queryCMPaymentClaims();
                //Adding cmp claims to final list 
                if(cmpPaymentClaimsToBeProcessed !=null && cmpPaymentClaimsToBeProcessed.size()>0){
                    paymentDueClaimsToBeProcessed.addAll(cmpPaymentClaimsToBeProcessed);
                }
            }
       }
        return paymentDueClaimsToBeProcessed;
    }
        
    public static List<PartnerFundClaim> queryCMPaymentClaims(){
        //List of claims to be processed 
        List<PartnerFundClaim> claimsTobeProcessed = new List<PartnerFundClaim>();
        //custom label for type of claims for offset processs  - Claim,Escalation Claim
        List<String> validClaimTypeForOffsetProcess = Label.Core_MDF_TypeOfClaimForOffsetProcess.split(',');
        //Production Test Account Ids to Be Excluded 
        List<String> testAccountIdstobeExcluded = Label.Core_MDF_TestAccountIdsToBeExcluded.split(',');
        //Map of unique key and list of adjustment claims
        Map<String,List<PartnerFundClaim>> accountToListOfAdjustmentClaims = new Map<String,List<PartnerFundClaim>>();
        //Map of unique key and list of claims
        Map<String,List<PartnerFundClaim>> accountToListOfClaims = new Map<String,List<PartnerFundClaim>>();
        //Unique Key - company account node+program
        String uniqueKey = '';
        List<PartnerFundClaim> paymentDueClaimsToBeProcessed = new List<PartnerFundClaim>();
        if(setOfSelAccounts.size()==0 && mdfPaymentRunRecordTypes.size() == 0){ //Added Budget Type field in where condition as part of CMP Payments US- US1017409
            String paymentDueStatus = Label.Core_MDF_Status_Payment_Due;
            String cmpQuery = 'SELECT Id,ChannelPartnerId,ChannelPartner.Core_MDF_Group_Id__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Program__c,Amount,Core_MDF_Status__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,'
             + 'Core_MDF_Bank__c,Core_MDF_Bank__r.Core_MDF_Supplier_Number__c,Core_MDF_Payment_Id__c,Core_MDF_Bank__r.Core_MDF_Payment_Method_Code__c,'
             + 'Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c,Core_MDF_Bank__r.Core_MDF_Supplier_Name__c,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c ,Request.ChannelPartner.Core_MDF_Channel_Program__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,'
             + 'ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Type_Txt__c,Core_MDF_C_Type_Ind__c,Core_MDF_AccountCompany__c,Core_MDF_VAT_Eligibility_Ind__c,Request.Core_MDF_Activity_Number__c FROM PartnerFundClaim '
             + 'WHERE Core_MDF_Program__c IN:programSet'
             + ' AND Core_MDF_Budget_Type_Options_Nm__c IN: budgetTypeSet'
             + ' AND Core_MDF_Region_Cd__c IN:geoSet';
            //OOC payment run - run for specific claims
            if(!selectedClaimIds.isEmpty()){
                cmpQuery += ' AND Id IN :selectedClaimIds';
            }
            cmpQuery += ' AND ((Core_MDF_Status__c=:paymentDueStatus'
             + ' AND Core_MDF_Type_Txt__c  IN:validClaimTypeForOffsetProcess))'
             + ' AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c'
             + ' NOT IN: testAccountIdstobeExcluded AND Core_MDF_Recovery_Hold_Ind__c = FALSE AND (Core_MDF_Processing_Preference_nm__c !=: surePay OR (Core_MDF_Processing_Preference_nm__c =: surePay AND (Core_MDF_VAT_Eligibility_Ind__c = TRUE OR (Core_MDF_Claim_Review_Case__c = NULL OR (Core_MDF_Claim_Review_Case__c != NULL AND Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c =: REVIEW_COMPLETED)))))'
             + ' ORDER BY Core_MDF_Status__c DESC';
            claimsTobeProcessed = Database.query(cmpQuery);
        }
       /* if(claimsTobeProcessed!=Null && claimsTobeProcessed.size()>0){//
        for(PartnerFundClaim claimRecord : claimsTobeProcessed){
            //Ex: IDxxxxx_CCF_OEM CMP - Added Budget type field in unique key as part of CMP Payments US -US1017409
            uniqueKey = claimRecord.Core_MDF_Budget_Type_Options_Nm__c!= null ? claimRecord.ChannelPartnerId+'_'+mapOfProgramMetadata.get(claimRecord.Core_MDF_Program__c)+'_'+claimRecord.Core_MDF_Budget_Type_Options_Nm__c
                                                                      : claimRecord.ChannelPartnerId+'_'+mapOfProgramMetadata.get(claimRecord.Core_MDF_Program__c);
         
            //List of all negative claims except retail,there by bypassing offsetprocess for retail
            if(!claimRecord.Core_MDF_C_Type_Ind__c && 
            claimRecord.Core_MDF_Status__c == Label.Core_MDF_Status_Pending_Available_Fund && 
            claimRecord.Core_MDF_Type_Txt__c == Label.Core_MDF_NegativeClaim && 
            claimRecord.Core_MDF_Budget_Type_Options_Nm__c!= Label.Core_MDF_RetailMDF_BudgetType){
                if(accountToListOfAdjustmentClaims.containsKey(uniqueKey)){ accountToListOfAdjustmentClaims.get(uniqueKey).add(claimRecord);
                }else{
                    accountToListOfAdjustmentClaims.put(uniqueKey, new List<PartnerFundClaim>{claimRecord});
                }
            
            }
            //List of all positive claims except retail, there by bypassing offsetprocess for retail
            else if(claimRecord.Core_MDF_Status__c == Label.Core_MDF_Status_Payment_Due && 
                validClaimTypeForOffsetProcess.contains(claimRecord.Core_MDF_Type_Txt__c) && 
                claimRecord.Core_MDF_Budget_Type_Options_Nm__c!=Label.Core_MDF_RetailMDF_BudgetType){
                if(accountToListOfClaims.containsKey(uniqueKey)){
                  accountToListOfClaims.get(uniqueKey).add(claimRecord);
                }else{
                    accountToListOfClaims.put(uniqueKey, new List<PartnerFundClaim>{claimRecord});
                }
            
            }            
         }
        }
        if(accountToListOfClaims!=null && accountToListOfClaims.size()>0){ // 
            //payment due claims after offset process and pass same to payment process
            paymentDueClaimsToBeProcessed = performOffsetProcess(accountToListOfAdjustmentClaims,accountToListOfClaims);
        }*/
        return claimsTobeProcessed;
        
    }
  
/****************************************************************************************************** 
Method Name:        queryRetailClaims
@return  :          list of payment due claims
@parameters:        
Description:        This method is used to query all retail positive claims and adjustment claims for payment process
Added By:           Accenture - AD - 06/10/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/ 
    public static List<PartnerFundClaim> query_Retail_IPA_CMDF_Claims(){
    //List of payment due claims to be processed
        List<PartnerFundClaim> paymentDueClaimsTobeProcessed = new List<PartnerFundClaim>();
        //Production Test Account Ids to Be Excluded 
        List<String> testAccountIdstobeExcluded = Label.Core_MDF_TestAccountIdsToBeExcluded.split(',');
        List<String> validClaimTypeForOffsetProcess = Label.Core_MDF_TypeOfClaimForOffsetProcess.split(',');
    //Payment Due label
        String paymentDueLabel = Label.Core_MDF_Status_Payment_Due;
        //Pending Available Fund Label
      String pafLabel = Label.Core_MDF_Status_Pending_Available_Fund ;
        //Adjustment Label
    String adjusTypeLabel = Label.Core_MDF_NegativeClaim ;
    Set<Id> accountIdSet = new Set<Id>();
    String ipaProgramName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name');
    Set<String> applicableSuperClaimStatus = new Set<String>{'','Payment Due','Queued for Payment'};

    //Existing Retail Payment Due Claims
    String paymentDueClaimsQuery = 'Select Id, Core_MDF_AccountCompany__c,Core_MDF_Bank__r.Core_MDF_Currency_cd__c,Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c,Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c,Core_MDF_Sub_Region_Cd__c,Core_MDF_Bank__r.Core_MDF_Payment_Method_Code__c,Core_MDF_Bank__c,Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_Bank__r.Core_MDF_VAT_pct__c, Core_MDF_Bank__r.Core_MDF_Bank_Beneficiary_Name__c,Core_MDF_Bank__r.Core_MDF_Supplier_Name__c,Core_MDF_Bank__r.Core_MDF_Supplier_City_txt__c,Core_MDF_Bank__r.Core_MDF_Supplier_Region_txt__c,Core_MDF_Bank__r.Core_MDF_Supplier_Postal_Code_cd__c,Core_MDF_Type_Txt__c,Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c,ChannelPartner.Name,ChannelPartner.Core_MDF_Group_Id__c,Title,Core_MDF_Program__c,Core_MDF_Status__c,Status,Core_MDF_Country_Location_nm__c,Request.Core_MDF_Activity_Number__c,Core_MDF_Activity_Types__c,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Ad_Run_End_Date__c,CreatedDate,Request.ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Requested_Reimbursement_Amt__c,Core_MDF_Audit_Adjustment_Amount__c,Amount,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, ChannelPartner.Core_MDF_Channel_Program__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Region_Cd__c,ChannelPartnerId,Core_MDF_Payment_Id__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_RMF_Claim_Approval_Dt__c,Core_MDF_RMF_Last_POP_Submission_Dt__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Bank__r.Core_MDF_Tax_codes_cd__c,Core_MDF_Claim_Ref_Number__c,Request.Core_MDF_Product_Category_txt__c,Core_MDF_Quarter_Year_txt__c,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_VAT_Amt__c,Core_MDF_C_Type_Ind__c, Core_MDF_Total_Claim_Recovery_Amount__c, Request.Core_MDF_BU_Split__c,Request.Core_MDF_BU1_Split_Percent_nbr__c,Request.Core_MDF_BU2_Split_Percent_nbr__c,Request.Core_MDF_BU3_Split_Percent_nbr__c,Request.Core_MDF_BU4_Split_Percent_nbr__c,Request.Core_MDF_BU5_Split_Percent_nbr__c,Request.Core_MDF_BU6_Split_Percent_nbr__c,Request.Core_MDF_BU7_Split_Percent_nbr__c,Request.Core_MDF_BU8_Split_Percent_nbr__c,Request.Core_MDF_BU9_Split_Percent_nbr__c,Request.Core_MDF_BU10_Split_Percent_nbr__c,Core_MDF_Payment_Type_nm__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id,Core_MDF_Applicable_VAT_Percentage_nm__c, Core_MDF_Claim_Id__c FROM PartnerFundClaim WHERE Core_MDF_Region_Cd__c IN: geoSet AND Core_MDF_Program__c IN: programSet AND((Core_MDF_Status__c=:pafLabel AND Core_MDF_Type_Txt__c =:adjusTypeLabel AND Core_MDF_C_Type_Ind__c = true AND Core_MDF_Program__c !=: ipaProgramName) OR (Core_MDF_Status__c=:paymentDueLabel AND Core_MDF_Type_Txt__c  IN:validClaimTypeForOffsetProcess)) AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c NOT IN: testAccountIdstobeExcluded AND Core_MDF_Recovery_Hold_Ind__c = false AND (Core_MDF_Processing_Preference_nm__c !=: surePay OR (Core_MDF_Processing_Preference_nm__c =: surePay AND (Core_MDF_VAT_Eligibility_Ind__c = TRUE OR (Core_MDF_Claim_Review_Case__c = NULL OR (Core_MDF_Claim_Review_Case__c != NULL AND Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c =: REVIEW_COMPLETED)))))';
    if(programSet.contains(Label.Core_MDF_Retail_Program_Name)){
        paymentDueClaimsQuery+= ' AND Core_MDF_Budget_Type_Options_Nm__c IN: budgetTypeSet';
    }
    if(subgeoSet != Null && subgeoSet.size()>0){ paymentDueClaimsQuery += ' AND Core_MDF_Sub_Region_Cd__c IN : subgeoSet';                         
    } 
    if(payStartDt != NULL && payStartDt.size()>0){
        paymentDueClaimsQuery+= ' AND Core_MDF_Ad_Run_Start_Date__c >=:payStartDt';
    }
    if(payEndDt != NULL && payEndDt.size()>0){
        paymentDueClaimsQuery+= ' AND Core_MDF_Ad_Run_End_Date__c <=:payEndDt';
    }

    if(programSet.contains(ipaProgramName)){//For IPA
        paymentDueClaimsQuery += ' AND Core_MDF_Payment_Type_nm__c IN : paymentType AND Core_MDF_Has_Sub_Claims_Ind__c = false AND Core_MDF_Super_Claim_Status_nm__c IN : applicableSuperClaimStatus';
    }
    //OOC payment run - run for specific claims
    if(!selectedClaimIds.isEmpty()){
        paymentDueClaimsQuery += ' AND Id IN :selectedClaimIds';
    }
    paymentDueClaimsTobeProcessed = Database.query(String.escapeSingleQuotes(paymentDueClaimsQuery));
    return paymentDueClaimsTobeProcessed;
}
/****************************************************************************************************** 
Method Name:        performOffsetProcess
@return  :          List of payment due claims
@parameters:        Map od adjustment claims and map of other claims(whose status is PAF/PD)
Description:        This method is used to offset claims and update accordingly and return PD claims for payment process
Added By:           Accenture - AD - 06/03/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/     
   /* public static List<PartnerFundClaim> performOffsetProcess(Map<String,List<PartnerFundClaim>> accountToAdjustmentClaims,Map<String,List<PartnerFundClaim>> accountToClaims){
        //List of Claim Offset to be created
        Set<Core_MDF_Claim_Offset__c> newClaimOffsetRecToBeCreated = new Set<Core_MDF_Claim_Offset__c>();
        //All Adjustment claims tobe updated
        Map<Id,PartnerFundClaim> adjustmentClaimsToBeUpdatedMap = new Map<Id,PartnerFundClaim>();
        //All remainig claims to be updated
        Map<Id,PartnerFundClaim> claimsToBeUpdatedMap = new Map<Id,PartnerFundClaim>();
        //Map of channel program meta data
        Map<String,String> mapOfProgramMetadata = new Map<String,String>();
        //Set of payment due claims
        Set<PartnerFundClaim> paymentDueClaimsToBeProcessed = new Set<PartnerFundClaim>();
        // final list of payment due claims for payment process
        List<PartnerFundClaim> listOfPaymentDueClaimsToBeProcessed;
        //Unique Key - company account node+program
        String uniqueKey = '';
        //Claim offset amount
        Decimal claimOffsetAmount;
        
        
        //Existing channel program meta data
        List<Core_MDF_ChannelProgram__mdt> existingProgramMetadata = [SELECT Label,Core_MDF_Program_Name__c FROM Core_MDF_ChannelProgram__mdt LIMIT 1000];
        for(Core_MDF_ChannelProgram__mdt cp : existingProgramMetadata){
            mapOfProgramMetadata.put(cp.Label,cp.Core_MDF_Program_Name__c);
        }
        
        if(accountToAdjustmentClaims!=null && accountToAdjustmentClaims.size()>0){
            
            for(String uKey : accountToAdjustmentClaims.keySet()){
                //Getting list of adjustment claims from map by unique key
                List<PartnerFundClaim> adjustmentClaimList = accountToAdjustmentClaims.get(uKey);
                for(PartnerFundClaim adjustmentClaim : adjustmentClaimList){
                    //getting list of other claims from map
                    List<PartnerFundClaim> listOfClaims = accountToClaims.ContainsKey(uKey) ? accountToClaims.get(uKey) : null;
                    if(listOfClaims!=null && listOfClaims.size()>0){
                        for(PartnerFundClaim claimRecord : listOfClaims){
                            if (Math.abs(adjustmentClaim.Amount)>0 && claimRecord.Amount>0){
                                if((Math.abs(adjustmentClaim.Amount)) < claimRecord.Amount){
                                    claimOffsetAmount = Math.abs(adjustmentClaim.Amount);
                                    claimRecord.Amount = claimRecord.Amount - (Math.abs(adjustmentClaim.Amount));
                                    adjustmentClaim.Amount =0.0;
                                    adjustmentClaim.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
                                    //claim to be updated
                                    claimsToBeUpdatedMap.put(claimRecord.id,claimRecord);
                                    //New claim offset entry
                                    newClaimOffsetRecToBeCreated.add(createClaimOffsetEntry(claimRecord.Id,adjustmentClaim.Id,claimOffsetAmount));
                                    break;
                                }else if((Math.abs(adjustmentClaim.Amount)) == claimRecord.Amount){
                                    claimOffsetAmount = Math.abs(adjustmentClaim.Amount);
                                    claimRecord.Amount = 0.0;
                                    adjustmentClaim.Amount =0.0;
                                    adjustmentClaim.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
                                    claimRecord.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
                                    //claim to be updated
                                    claimsToBeUpdatedMap.put(claimRecord.id,claimRecord);
                                    //New claim offset entry
                                    newClaimOffsetRecToBeCreated.add(createClaimOffsetEntry(claimRecord.Id,adjustmentClaim.Id,claimOffsetAmount));break;
                                }else{
                                    claimOffsetAmount = claimRecord.Amount;
                                    adjustmentClaim.Amount = -((Math.abs(adjustmentClaim.Amount)) - claimRecord.Amount);
                                    claimRecord.Amount =0.0;
                                    adjustmentClaim.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
                                    claimRecord.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
                                    //claim to be updated
                                    claimsToBeUpdatedMap.put(claimRecord.id,claimRecord);
                                    //New claim offset entry
                                    newClaimOffsetRecToBeCreated.add(createClaimOffsetEntry(claimRecord.Id,adjustmentClaim.Id,claimOffsetAmount));                           
                                }
                            }
                        }
                        adjustmentClaimsToBeUpdatedMap.put(adjustmentClaim.Id,adjustmentClaim);
                    }
                }
            }
            //conver set to list and update/insert list of claims
            if(claimsToBeUpdatedMap!=null && adjustmentClaimsToBeUpdatedMap!=null 
                && newClaimOffsetRecToBeCreated!=null){
                database.update(claimsToBeUpdatedMap.values());
                database.update(adjustmentClaimsToBeUpdatedMap.values());           
                database.insert(new List<Core_MDF_Claim_Offset__c>(newClaimOffsetRecToBeCreated));      
            }
        }
        for(String uKey : accountToClaims.keySet()){
            //Getting list of other claims from map by unique key
            List<PartnerFundClaim> claimList = accountToClaims.get(uKey);
            for(PartnerFundClaim pfcRecord : claimList){
                //Checking PD claims
                if(Label.Core_MDF_Status_Payment_Due == pfcRecord.Core_MDF_Status__c){
                    paymentDueClaimsToBeProcessed.add(pfcRecord);
                }
            }
        }
        if(paymentDueClaimsToBeProcessed!=null){
            listOfPaymentDueClaimsToBeProcessed= new List<PartnerFundClaim>(paymentDueClaimsToBeProcessed);
        }
        //Send payment due claims to payment process
        return listOfPaymentDueClaimsToBeProcessed;
    }*/
    /****************************************************************************************************** 
Method Name:        createClaimOffsetEntry
@return  :          new claim offset record
@parameters:        offset claim Id, adjustment claim Id, offset amount
Description:        This method is used to create offset entry
Added By:           Accenture - AD - 06/03/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/      
    public static Core_MDF_Claim_Offset__c createClaimOffsetEntry(Id offsetClaimId,Id adjustmentClaimId,Decimal offsetAmount){
        //create new claim offest record
        Core_MDF_Claim_Offset__c newClaimOffset = new Core_MDF_Claim_Offset__c();
        newClaimOffset.Core_MDF_Offset_Claim_Nbr__c = offsetClaimId;
        newClaimOffset.Core_MDF_Adjustment_Claim_Nbr__c = adjustmentClaimId;
        newClaimOffset.Core_MDF_Offset_Amount_Amt__c = offsetAmount;
        return newClaimOffset;
    }
    /****************************************************************************************************** 
Method Name:        generateQueryFilters
@return  :          N/A
@parameters:        list of payment run records
Description:        This method is used to assign geo/countries, program, map of program meta data
Added By:           Accenture - AD - 06/03/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/     
public static void generateQueryFilters(List<Core_MDF_Payment_Run__c> paymentRunRecordsTobeProcessed){
    
    //Existing channel program meta data
    List<Core_MDF_ChannelProgram__mdt> existingProgramMetadata = [SELECT Label,Core_MDF_Program_Name__c FROM Core_MDF_ChannelProgram__mdt LIMIT 1000];
    for(Core_MDF_ChannelProgram__mdt cp : existingProgramMetadata){
        mapOfProgramMetadata.put(cp.Label,cp.Core_MDF_Program_Name__c);
    }
    
    for(Core_MDF_Payment_Run__c prun : paymentRunRecordsTobeProcessed){
        if(prun.Core_MDF_Geo_Txt__c!=null){
            //geoSet= new Set<String>();
            geoSet.add(prun.Core_MDF_Geo_Txt__c);}
            if(prun.Core_MDF_Program_Id__r.Name!=null){
            programSet.add(prun.Core_MDF_Program_Id__r.Name);
            }
            
        if(String.isNotBlank(prun.Core_MDF_Payment_Types_txt__c)){
            paymentType.addAll(prun.Core_MDF_Payment_Types_txt__c.split(';'));
        }
        //For RMF Program OR IPA Program
            if(prun.Core_MDF_Start_Dt__c!= null){
                payStartDt.add(prun.Core_MDF_Start_Dt__c);
            }
            if(prun.Core_MDF_End_Dt__c!= null){
                payEndDt.add(prun.Core_MDF_End_Dt__c);
            }
            if(prun.Core_MDF_Subgeo_Txt__c!=null){ subgeoSet.add(prun.Core_MDF_Subgeo_Txt__c);
            }
            /*if(prun.Core_MDF_Budget_Type_Txt__c!=null){
                budgetTypeSet.add(prun.Core_MDF_Budget_Type_Txt__c);
            }*/
            //Budget type is not available for CCFB & SPCF programs
            if(prun.Core_MDF_Budget_Type_nm__c!=null){ //Budget type field of Multi select picklist
                budgetTypeSet = new Set<String>();
                List<String> budtypes =prun.Core_MDF_Budget_Type_nm__c.split(';');
                budgetTypeSet.addAll(budtypes);  
            }
            List<String> mdfRecTypes = Core_MDF_Configuration__c.getValues('Payment_Run_RecordTypes_MDF').Core_MDF_Value__c.split(',');

            Boolean isMDFPayment = !mdfRecTypes.isEmpty() && mdfRecTypes.contains(prun.RecordType.DeveloperName);
            if(isMDFPayment){
                mdfPaymentRunRecordTypes.add(prun.RecordType.DeveloperName);
            }
            //Accounts are optional for OOC payment runs, so record type is tracked independently of account population
	        if(isMDFPayment && prun.Core_MDF_Payment_run_for_Accounts__c !=null){
	            List<Id> selectedAccounts = prun.Core_MDF_Payment_run_for_Accounts__c.split('[,;]');
	            setOfSelAccounts.addAll(selectedAccounts);
            }
            //OOC - collect the specific claims selected on the payment run
            if(String.isNotBlank(prun.Core_MDF_Payment_Run_for_Claims_Id__c)){
                List<Id> selectedClaimIdsList = prun.Core_MDF_Payment_Run_for_Claims_Id__c.split(';');
                selectedClaimIds.addAll(selectedClaimIdsList);
            }
    }
}
}