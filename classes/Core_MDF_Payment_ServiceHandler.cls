/******************************************************************************************************
* Class Name  : Core_MDF_Payment_ServiceHandler 
* Version     : 1.0 
* Created Date: 03-24-2020 
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - AD      03/22/2020          It is a service handler class                                   
*******************************************************************************************************/
public without sharing class Core_MDF_Payment_ServiceHandler {
    // Map of Payment Id and Payment record 
    public static Map<Id, Core_MDF_Payment__c> paymentIdToPaymentMap =  new Map<Id, Core_MDF_Payment__c>();
    //Map to hold payment Id and EFT Number
    public static final Map<Id,String> paymentToEFTNbrMap = new Map<Id,String>();
    //List of claims to be updated with EFT number
    public static List<PartnerFundClaim> claimsToUpdateEFTNbr = new List<PartnerFundClaim>();
    //paymentStatus
    public static final string paymentStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Paid');
    //Storing the Payment Run Record Types in the below list
    public static final List<String> paymentRecordTypes = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Payment_Record_Types',',');

    //Check if map is empty or not
    public static Boolean isNotEmpty(Map<Id,Core_MDF_Payment__c> eMap) {
        return (eMap!=null && eMap.size()>0);
    }
    
    //checks if EFT Number on payment is updated and payment status is paid
    public static Boolean isPaymentUpdated(Map<Id,Core_MDF_Payment__c> oldPaymentMap, Core_MDF_Payment__c paymentRecord) {

        Boolean isUpdated = false;
		System.debug('@@@RecType: '+paymentRecord.recordTypeId);
        if (isNotEmpty(oldPaymentMap) && oldPaymentMap.containsKey(paymentRecord.Id) && oldPaymentMap.get(paymentRecord.Id).Core_MDF_Payment_Status_Txt__c != paymentRecord.Core_MDF_Payment_Status_Txt__c && paymentRecord.Core_MDF_Payment_Status_Txt__c == paymentStatus 
			
            && (FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Payment_Admin_Manager') //Tejaswini
            || (paymentRecord.Core_MDF_Program_Txt__c == Label.Core_MDF_Retail_Program_Name && paymentRecord.Core_MDF_Budget_Type_Nm__c.contains(Label.Core_MDF_Retail_RSA_MD_Budget_Type))   //RMF: RSA MD
            || (paymentRecordTypes.contains(Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosById().get(paymentRecord.recordTypeId).getDeveloperName()))  // CCF MDF and DCF MDF
            || (paymentRecord.Core_MDF_Program_Txt__c == Label.Core_MDF_Co_GTM_program_name) //Co-GTM
            
            // Recordtype bypass logic for L3 users
            || (Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_PaymentBudgetTypeCheck').Core_Active__c 
                    && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c != null 
                    && Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users').Core_MDF_Value_Txt__c.contains(UserInfo.getUserName())))) {
          			
                    isUpdated = true;
        }
        else{
            isUpdated = false;
        }
        return isUpdated;
    }
    //checks if EFT Number on payment is updated and payment status is paid
    /* Any intermediate updates on payment, won't be reflect on claim=> because of multiple(2) DML updates.
       EFT Number will be synchronized from payment to claim only when payment status is 'paid'
    */
    public static boolean isEFTNbrUpdated(Core_MDF_Payment__c oldPmtRec, Core_MDF_Payment__c newPmtRec) {
        Boolean isUpdated = false;

        if(oldPmtRec.Core_MDF_EFT_Nbr__c != newPmtRec.Core_MDF_EFT_Nbr__c && newPmtRec.Core_MDF_Payment_Status_Txt__c == paymentStatus
            && oldPmtRec.Core_MDF_Payment_Status_Txt__c == newPmtRec.Core_MDF_Payment_Status_Txt__c) {
            isUpdated = true;
        }
        else{
            isUpdated = false;
        }
        return isUpdated;
    }
    /****************************************************************************************************** 
    Method Name:        populatePaymentMap
    return  :          void
    @parameters:        List of Incoming Payments and Old Payment Map
    Description:        This method is used to prepare payment Id to Payment map
    Added By:           Accenture - NB - 03/24/2020
    Modified By:                                     
    *******************************************************************************************************/   
    public static void populatePaymentMap(List<Core_MDF_Payment__c> paymentList, Map<Id,Core_MDF_Payment__c> oldPaymentMap) {
        for(Core_MDF_Payment__c paymentRecord :paymentList) {
            if(isEFTNbrUpdated(oldPaymentMap.get(paymentRecord.Id), paymentRecord)) {
                    paymentToEFTNbrMap.put(paymentRecord.Id,paymentRecord.Core_MDF_EFT_Nbr__c);
            }
            //if(isPaymentUpdated(oldPaymentMap,paymentRecord))
             if(isPaymentUpdated(oldPaymentMap,paymentRecord)) {               
                    // Map of Payment Id and Payment Record                  
                    paymentIdToPaymentMap.put(paymentRecord.Id, paymentRecord);
             }
         }
         populateEFTNbrOnClaims(paymentToEFTNbrMap);
    }
    /****************************************************************************************************** 
    Method Name:        updateClaimsToPaid
    @return  :          void
    @parameters:        List of Incoming Payments and Old Payment Map
    Description:        This method is used to update claims to be paid
    Added By:           Accenture - AD - 03/24/2020
    Modified By:        Pranav - Date: 14-Dec-2020      Changes: Invoke a batch to Update payment related Claims to Paid
    *******************************************************************************************************/   
    public static void updateClaimsToPaid(List<Core_MDF_Payment__c> paymentList, Map<Id,Core_MDF_Payment__c> oldPaymentMap) { 
        try {
            populatePaymentMap(paymentList,oldPaymentMap);
            if(paymentIdToPaymentMap!=null && paymentIdToPaymentMap.size() >0) {
                //Update payment related claims to Paid
                Database.executeBatch(new Core_MDF_Batch_UpdateClaimstoPaid(paymentIdToPaymentMap),200);
            }
        }
        catch(Exception e) { 
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

    /****************************************************************************************************** 
    Method Name:        populateEFTNbrOnClaims
    return  :           void
    @parameters:        Map of PaymentID and EFTNumber
    Description:        This method is used to prepare claim with EFT Number update
    Added By:           Accenture - NB - 12/12/2020
    Modified By:        Pranav - Date: 14-Dec-2020      Changes: Invoke a batch to Update payment related Claims to Paid
    *******************************************************************************************************/   
    public static void populateEFTNbrOnClaims(Map<Id,String> paymentToEFTMap) {
        try {
            for(PartnerFundClaim claim: [SELECT Id, Core_MDF_Payment_Id__c, Core_MDF_EFT_Number_txt__c FROM PartnerFundClaim where Core_MDF_Payment_Id__c in :paymentToEFTMap.keySet()]) {
                //claimsToUpdateEFTNbr
                if(paymentToEFTMap!=null && !paymentToEFTMap.isEmpty()) {
                    final PartnerFundClaim claimUpdate = new PartnerFundClaim();
                    claimUpdate.Id=claim.Id;
                    claimUpdate.Core_MDF_EFT_Number_txt__c = paymentToEFTMap.get(claim.Core_MDF_Payment_Id__c);
                    claimsToUpdateEFTNbr.add(claimUpdate);
                }
            }
            updateEFTNbrOnClaims(claimsToUpdateEFTNbr);
        }
        catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

    /****************************************************************************************************** 
    Method Name:        updateEFTNbrOnClaims
    return  :           void
    @parameters:        List of claims
    Description:        This method is used to update claims with EFT Number updated on associated payment record
    Added By:           Accenture - NB - 12/12/2020
    Modified By:        Pranav - Date: 14-Dec-2020      Changes: Invoke a batch to Update payment related Claims to Paid
    *******************************************************************************************************/   
    public static void updateEFTNbrOnClaims(List<PartnerFundClaim> claimsToUpdateEFTNbr) {
        try {
            if(claimsToUpdateEFTNbr != NULL && claimsToUpdateEFTNbr.size()>0) {
                Database.update(claimsToUpdateEFTNbr, false);
            }
        }
        catch(Exception e) { 
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
}