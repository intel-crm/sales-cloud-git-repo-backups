/****************************************************************************************************************************************
* Class Name  : Core_MDF_Claim_Utility 
* Test Class  : Core_MDF_Claim_Utility_Test
* Version     : 1.0   
* Created Date: 11-13-2018
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         11/13/2018                    Created Core_MDF_Claim_Utility for Common Utility Methods      
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Claim_Utility {
    //To hold all record type meta data
    public static Map<String,Core_MDF_ObjRecType_Budget_FieldSetMap__mdt> mapOfRecTypeMetadata; //TWC3117-18333
    public static Map<String,Core_MDF_CCP_GenericUtility.countryGeoSubGeoWrapper> wrapperMapOfCountryRegion = new Map<String,Core_MDF_CCP_GenericUtility.countryGeoSubGeoWrapper>();
    public static Map<Id,PartnerFundRequest> pfrInstance;
    public static Map<String, List<String>> channelProgramToCountriesMap = new Map<String, List<String>>();
    public static Set<Id> setOfBankIds;
    public static Map<Id,PartnerFundRequest> pfrMap;
    private static string isclaimAdjustmentType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Adjustment_Type');
    //Assign all record type meta data
    static{
        mapOfRecTypeMetadata = fetchRecordTypeMetaData();
        wrapperMapOfCountryRegion = Core_MDF_CCP_GenericUtility.getCountryGeoMap(); 
    }
    
    /***************************************************************************************************** 
Method Name:        releaseHold 
@return  :          void 
@parameters:        
Description:        This method is used to release the claims that are on hold
Added By:           Intel - SM - 11/13/2018
Modified By:        Date:       Changes:  
******************************************************************************************************/
    public static void releaseHold(List<PartnerFundClaim> inputClaims, List<String> releaseReason)
    {
        //To get the fields of the list of claims passed as input
        processReleaseHold(inputClaims,releaseReason);
        Database.update(inputClaims);        
    }      
    
    /***************************************************************************************************** 
Method Name:        processReleaseHold
@return  :          void
@parameters:        
Description:        This method is used to release the claims that are on hold
Added By:           Intel - SM - 11/13/2018assign
Modified By:        Date:       Changes: 
******************************************************************************************************
*  VS               4/4/2019       Added condition to check Payment Hold reason
******************************************************************************************************/
    public static void processReleaseHold(List<PartnerFundClaim> claims, List<String> releaseReason)
    {
        //To Store the Updated claim
        List<PartnerFundClaim> claimListToUpdate = new List<PartnerFundClaim>();

        //Roshan - Super Claim PIC
        List<PartnerFundClaim> superClaimsReleasedFromHold = new List<PartnerFundClaim>();
        
        //To Uncheck the Hold Reason
        //ATHR - Deeply Nested if 16209
        if (claims == null || claims.isEmpty()) return;
        //if(claims != NULL && claims.size() > 0)
        //{
            for(PartnerFundClaim claim : claims)
            {
                for(String reason : releaseReason)
                {
                    if(reason == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ESD_Hold'))
                    { 
                        claim.Core_MDF_ESD_Hold__c = false; 
                    }
                    if(reason == Label.Core_MDF_Audit_Hold)
                    {
                        claim.Core_MDF_Audit_Hold__c = false;
                    }
                    if(reason == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Payment_Hold'))
                    {
                        claim.Core_MDF_Payment_Hold_ind__c = false;                        
                    }
                    if(reason == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Criteria_Hold'))
                    {
                        claim.Core_MDF_Criteria_Hold_Ind__c = false;                        
                    }
                    if(reason == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Intel_Manual_Hold'))
                    {
                        claim.Core_MDF_Intel_Manual_Hold_Ind__c = false;                        
                    }
                    if(reason == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Member_Manual_Hold'))
                    {
                        claim.Core_MDF_Member_Manual_Hold_Ind__c = false;                        
                    }          
                    if(reason == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_VAT_Hold')) // if VAT status is approved
                    {
                        
                        claim.Core_MDF_VAT_Hold_Ind__c = false;                        
                    }
                    if(reason == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bank_Document_Hold')){
                        claim.Core_MDF_Bank_Doc_Hold_Ind__c = false;
                    }
                    // Cheking if reason is Document Hold, then uncheck the doc hold checkbox
                    if(reason == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Document_Hold')){
                        claim.Core_MDF_Document_Hold_Ind__c = false;
                    }
                }
                //if(!claim.Core_MDF_Audit_Hold__c && !claim.Core_MDF_ESD_Hold__c && !claim.Core_MDF_Payment_Hold_ind__c 
                if(!claim.Core_MDF_ESD_Hold__c && !claim.Core_MDF_Payment_Hold_ind__c
                   && !claim.Core_MDF_Intel_Manual_Hold_Ind__c && !claim.Core_MDF_Member_Manual_Hold_Ind__c && !claim.Core_MDF_VAT_Hold_Ind__c
                   && !claim.Core_MDF_Criteria_Hold_Ind__c && !claim.Core_MDF_Bank_Doc_Hold_Ind__c && !claim.Core_MDF_Document_Hold_Ind__c && claim.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold')){                       
                       String tempPrevStatus = claim.Core_MDF_Claim_Previous_Status__c;

                       //Roshan - Super Claim PIC
                        if (claim.Core_MDF_Has_Sub_Claims_Ind__c) {
                            if (tempPrevStatus == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Available_Fund')) {
                                claim.Core_MDF_Status__c = tempPrevStatus;
                            } else {
                                superClaimsReleasedFromHold.add(claim);
                            }
                        } else {
                            if(tempPrevStatus!=null && (tempPrevStatus == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Available_Fund') || tempPrevStatus == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted'))){
                                
                                claim.Core_MDF_Status__c = tempPrevStatus;    
                            }else{
                                
                                claim.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted');
                            }
                        }
                }
            }
        //}   
        
        //Roshan - Super Claim PIC
        if (!superClaimsReleasedFromHold.isEmpty()) {
            updateSuperClaimStatusFromSubClaims(superClaimsReleasedFromHold);
        }
    } 

    //Roshan - Super Claim PIC
    public static void updateSuperClaimStatusFromSubClaims(List<PartnerFundClaim> superClaims) {

        Set<Id> superClaimIds = new Set<Id>();
        for (PartnerFundClaim superClaim : superClaims) {
            superClaimIds.add(superClaim.Id);
        }

        Map<Id, Set<String>> superToSubStatuses = new Map<Id, Set<String>>();
        for (PartnerFundClaim subClaim : [SELECT Core_MDF_Claim_Id__c, Core_MDF_Status__c FROM PartnerFundClaim WHERE Core_MDF_Claim_Id__c IN :superClaimIds AND Core_MDF_Status__c != 'Cancelled']) {
            if (!superToSubStatuses.containsKey(subClaim.Core_MDF_Claim_Id__c)) {
                superToSubStatuses.put(subClaim.Core_MDF_Claim_Id__c, new Set<String>());
            }
            superToSubStatuses.get(subClaim.Core_MDF_Claim_Id__c).add(subClaim.Core_MDF_Status__c);
        }

        for (PartnerFundClaim superClaim : superClaims) {
            String finalStatus;
            if (superToSubStatuses.get(superClaim.Id).size() == 1) {
                for (String status : superToSubStatuses.get(superClaim.Id)) {
                    finalStatus = status;
                    break;
                }
            }
            else if (superToSubStatuses.get(superClaim.Id).contains('Paid') || superToSubStatuses.get(superClaim.Id).contains('Pending Payment')) {
                finalStatus = 'Queued for Payment';
            }
            else if (superToSubStatuses.get(superClaim.Id).contains('Hold')) {
                finalStatus = 'Hold';
            }
            else if (superToSubStatuses.get(superClaim.Id).contains('Pending Available Funds')) {
                finalStatus = 'Pending Available Funds';
            }
            else {
                finalStatus = 'Payment Due';
            }
            superClaim.Core_MDF_Status__c = finalStatus;
        }
    }

    
    /***************************************************************************************************** 
Method Name:        invokeReleaseHold
@return  :          void
@parameters:        
Description:        This is an Invocable Method for the Release Hold method
Added By:           Intel - SM - 11/20/2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    
    @InvocableMethod
    public static void invokeReleaseHold(List<ReleaseHoldParams> releaseParams)
    {
        releaseHold(releaseParams[0].inputClaims,releaseParams[0].releaseReason);
    }
    
    /***************************************************************************************************** 
ClassName:        ReleaseHoldParams
@parameters:        
Description:        This is a wrapper class to be used to send parameters to the Invocable Method
Added By:           Intel - SM - 11/20/2018
******************************************************************************************************/    
    public class ReleaseHoldParams
    {
        @InvocableVariable(label = 'Claims' required = true)
        public List<PartnerFundClaim> inputClaims;
        @InvocableVariable(label = 'Release Reason' required = true)
        public List<String> releaseReason;
    }
    
    /***************************************************************************************************** 
Method Name:        updateClaimStatus
@return  :          void
@parameters:        newClaimList and oldClaimMap
Description:        This method is used to set the claim previous and standard Status on the basic of custom status 
Added By:           Accenture - JV
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static void updateClaimStatus(List<PartnerFundClaim> newClaimList, Map<Id,PartnerFundClaim> oldClaimMap){ 
        List<String> legacyPaidclmStsLst = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_PostPaid_Legacy_Claim_Statuses');
        for(PartnerFundClaim pfc : newClaimList){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(pfc, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Adjustment_Type')))
            {
                continue;
            }
            if(oldClaimMap!=null && oldClaimMap.size() > 0  && oldClaimMap.get(pfc.ID).Core_MDF_Status__c != pfc.Core_MDF_Status__c){
                
                // To set the claim previous status field before changing claim current status
                pfc.Core_MDF_Claim_Previous_Status__c = oldClaimMap.get(pfc.ID).Core_MDF_Status__c;
                
                if (pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Available_Fund') 
                    || pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted')
                    || pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold')
                    || pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PIC_Pending')
                    || pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_PendingDocs')
                    || pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ResubReqd')) {
                        pfc.Status = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted');
                    }
                else if(pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Payment_Due') || pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Payment')){
                    if (!pfc.Core_MDF_Has_Sub_Claims_Ind__c) {  //Roshan - Super Claim PIC
                        pfc.Status = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Approved');
                    }
                }
                else if(pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Denied') || pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Cancelled') || pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Adjusted')
                        || pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ResubWinClosed')){
                            pfc.Status = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Rejected');
                        }
                //else if(pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Paid')){
                else if(legacyPaidclmStsLst.contains(pfc.Core_MDF_Status__c)||pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Paid')){   
                    if (!pfc.Core_MDF_Has_Sub_Claims_Ind__c) {  //Roshan - Super Claim PIC
                        pfc.Status = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Paid');
                    }
                }
                //Roshan
                if(pfc.Core_MDF_Status__c == 'Pending Review') {
                    if(pfc.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM || pfc.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM) {  //Swati - added ipa check
                        pfc.Core_MDF_Approval_Stage_nm__c = pfc.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM ? 'Technical Approver' : 'Account Manager';
                        pfc.Core_MDF_Approval_Step_Counter_nbr__c = 1;
                        pfc.Core_MDF_Comments_Appvr_Only_txt__c  = '';
                    }
                }
            }
            }
        }

    /***************************************************************************************************** 
Class Name:         ClaimWrapperClass 
Description:        Wrapper to check duplicate claims
@Added By:          Accenture - AH - 11-11-2018
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public class ClaimWrapperClass {
        public String activityNumber;
        public Date adRunStartDate;
        public Date adRunEndDate;
        public String countryLocation;
        public String mediaVehicle;
        public String accountCompany;
        public string invoiceNumber;
        //IPA
        public string activityType;
        public decimal amount; 
        public string currencyType;
        public string program;
        
        public ClaimWrapperClass(String activityNumber, Date adRunStartDate, Date adRunEndDate, String countryLocation, 
                                 String mediaVehicle, String accountCompany, String invoiceNumber,String activityType,decimal amount,string currencyType,string program){
                                     this.activityNumber = activityNumber;
                                     this.adRunStartDate = adRunStartDate;
                                     this.adRunEndDate = adRunEndDate;
                                     this.countryLocation = countryLocation;
                                     this.mediaVehicle = mediaVehicle;
                                     this.accountCompany = accountCompany;
                                     this.invoiceNumber = invoiceNumber;
                                     this.activityType = activityType;
                                     this.amount = amount;
                                     this.currencyType = currencyType;
                                     this.program = program;
                                 }
        
        public Boolean equals(Object obj) {
            if (obj instanceof ClaimWrapperClass){
                ClaimWrapperClass p = (ClaimWrapperClass)obj;
                return ((activityNumber==p.activityNumber) && 
                        (adRunStartDate==p.adRunStartDate) && 
                        (adRunEndDate==p.adRunEndDate) && 
                        (countryLocation==p.countryLocation) &&
                        (mediaVehicle==p.mediaVehicle) && 
                        (accountCompany==p.accountCompany) && 
                        (invoiceNumber==p.invoiceNumber) &&
                        ((p.program== Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name'))?((activityType==p.activityType) && (amount == p.amount) && (currencyType==p.currencyType)) :true));
            }
            return false;
        }
        
        public Integer hashCode() {
            Integer hashCode = 0;
            hashCode = activityNumber!=null ? (hashCode + System.hashCode(activityNumber)):hashCode;
            hashCode = adRunStartDate!=null ? (hashCode + System.hashCode(adRunStartDate)):hashCode;
            hashCode = adRunEndDate!=null ? (hashCode + System.hashCode(adRunEndDate)):hashCode;
            hashCode = countryLocation!=null ? (hashCode + System.hashCode(countryLocation)):hashCode;
            hashCode = mediaVehicle!=null ? (hashCode + System.hashCode(mediaVehicle.toLowerCase())):hashCode;
            hashCode = accountCompany!=null ? (hashCode + System.hashCode(accountCompany)):hashCode;
            hashCode = invoiceNumber!=null ? (hashCode + System.hashCode(invoiceNumber.toLowerCase())):hashCode;
            
            //IPA
            hashCode = (activityType!=null && program==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')) ? (hashCode + System.hashCode(activityType.toLowerCase())):hashCode;
            hashCode = (amount!=null && program==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')) ? (hashCode + System.hashCode(amount)):hashCode;
            hashCode = (currencyType!=null && program==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')) ? (hashCode + System.hashCode(currencyType.toLowerCase())):hashCode;
            return hashCode;
        }
    }
    
    
    /***************************************************************************************************** 
Method Name:        duplicateClaimCheckOnInsert
@return  :          List of Duplicate Claims from Database
@parameters:        claimList - This will contain all the pfc records to be inserted/updated.
Description:        Whenever a record is inserted of Partner Fund Claim, this method checks whether the current record is duplicate or not
@Added By:          Accenture - AH - 11-11-2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static List<PartnerFundClaim> duplicateClaimCheckOnInsert(List<PartnerFundClaim> claimList) {    
        
        List<PartnerFundClaim> partnerFundClaimList = new List<PartnerFundClaim>();
        
        // This set is required to store Requests
        Set<Id> requestIdSet = new Set<id>();
        if(claimList != Null && claimList.size()>0)
        {
            for(PartnerFundClaim newClaim : claimList){
                //check if adjustment then break
                if(!Core_MDF_Claim_Utility.isType(newClaim, isclaimAdjustmentType))
                {
                    requestIdSet.add(newClaim.RequestId);
                }
            }
        }
        
        if(requestIdSet != NULL && requestIdSet.size() > 0){
            partnerFundClaimList = duplicateProcess(requestIdSet,claimList);
        }
        return partnerFundClaimList;
    }  
    
    /***************************************************************************************************** 
Method Name:        duplicateClaimCheckOnUpdate
@return  :          List of Duplicate Claims from Database
@parameters:        claimList - This will contain all the pfc records to be inserted/updated.
Description:        this method checks if any of the duplicate field over claim is changed
@Added By:          Accenture - AH - 11-11-2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static Void duplicateClaimCheckOnUpdate(List<PartnerFundClaim> claimList,Map<Id,PartnerFundClaim> oldClaimMap) {    
        
        // This set is required to store Requests
        Set<Id> requestIdSet = new Set<id>();
        
        //To hold IPA record type Id
        Id IPARecTypeId = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType')).getRecordTypeId();    
   
        
        //check for Start Date or End Date or Media Vehicle or Invoice Number is changed 
        for(PartnerFundClaim newClaim : claimList){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(newClaim, isclaimAdjustmentType)){continue;}
            if(newClaim.Core_MDF_Ad_Run_Start_Date__c != oldClaimMap.get(newClaim.ID).Core_MDF_Ad_Run_Start_Date__c
               || newClaim.Core_MDF_Ad_Run_End_Date__c != oldClaimMap.get(newClaim.ID).Core_MDF_Ad_Run_End_Date__c
               || (newClaim.Core_MDF_Media_Vehicle__c!=null && oldClaimMap.get(newClaim.ID).Core_MDF_Media_Vehicle__c!=null && newClaim.Core_MDF_Media_Vehicle__c.toLowerCase() != oldClaimMap.get(newClaim.ID).Core_MDF_Media_Vehicle__c.toLowerCase())
               || (newClaim.Core_MDF_Invoice_Number__c!=null && oldClaimMap.get(newClaim.ID).Core_MDF_Invoice_Number__c!=null && newClaim.Core_MDF_Invoice_Number__c.toLowerCase() != oldClaimMap.get(newClaim.ID).Core_MDF_Invoice_Number__c.toLowerCase())
               || (newClaim.Core_MDF_Country_Location_nm__c !=null && oldClaimMap.get(newClaim.ID).Core_MDF_Country_Location_nm__c!=null && newClaim.Core_MDF_Country_Location_nm__c.toLowerCase() != oldClaimMap.get(newClaim.ID).Core_MDF_Country_Location_nm__c.toLowerCase())
               || newClaim.Core_MDF_Total_Invoice_Amount_Local__c != oldClaimMap.get(newClaim.ID).Core_MDF_Total_Invoice_Amount_Local__c
               //IPA
               || (newClaim.Core_MDF_Activity_Types__c!=null && oldClaimMap.get(newClaim.ID).Core_MDF_Activity_Types__c!=null && newClaim.Core_MDF_Activity_Types__c.toLowerCase() != oldClaimMap.get(newClaim.ID).Core_MDF_Activity_Types__c.toLowerCase())
               || (newClaim.Core_MDF_AccountCompany__c!=null && oldClaimMap.get(newClaim.ID).Core_MDF_AccountCompany__c!=null && newClaim.Core_MDF_AccountCompany__c.toLowerCase() != oldClaimMap.get(newClaim.ID).Core_MDF_AccountCompany__c.toLowerCase())
               || (newClaim.Core_MDF_Currency__c!=null && oldClaimMap.get(newClaim.ID).Core_MDF_Currency__c!=null && newClaim.Core_MDF_Currency__c.toLowerCase() != oldClaimMap.get(newClaim.ID).Core_MDF_Currency__c.toLowerCase())
              ){requestIdSet.add(newClaim.RequestId);}
        }
        
        if(requestIdSet != NULL && requestIdSet.size() > 0){duplicateProcess(requestIdSet,claimList);}
    }      
    
    /***************************************************************************************************** 
Method Name:        duplicateProcess
@return  :          List of Duplicate Claims from Database
@parameters:        requestIdSet and claimList 
Description:        Whenever a record is updated of Partner Fund Claim, this method checks whether the current record is duplicate or not
@Added By:          Accenture - AH - 11-11-2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static List<PartnerFundClaim> duplicateProcess(Set<Id> requestIdSet,List<PartnerFundClaim> claimList){
        
        // Sets for all the fields against which duplicate needs to be checked
        Set<String> newActivityNumber = new Set<String>();
        Set<Date> newAdRunStartDate = new Set<Date>();
        Set<Date> newAdRunEndDate = new Set<Date>();
        Set<String> newCountryLocation = new Set<String>();
        Set<String> newMediaVehicle = new Set<String>();
        Set<String> newAccountCompany = new Set<String>();
        Set<String> newInvoiceNumber = new Set<String>();
        Set<String> newClamIds = new Set<String>();
        //IPA
        Set<String> newActyType = new Set<String>();
        Set<Decimal> newAmount = new Set<Decimal>();
        Set<String> newCurrencyType = new Set<String>();
        //To hold IPA record type Id
        Id IPARecTypeId = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType')).getRecordTypeId(); 
        
        // Set for Claim Wrapper : New Claims Wrapper and Existing PFC Claims Wrapper
        Set<ClaimWrapperClass> dbWrapperSet = new Set<ClaimWrapperClass>();
        Set<ClaimWrapperClass> newWrapperSet = new Set<ClaimWrapperClass>();
        
        //This List contains the dbDuplicate Claims
        List<PartnerFundClaim> duplicateClaimList = new List<PartnerFundClaim>();
        
        //This Map stores dbClaimWrapper and Corresponding db Claim : will be used to capture db duplicate claims        
        Map<ClaimWrapperClass,List<PartnerFundClaim>> mapClaimWrapper = new Map<ClaimWrapperClass,List<PartnerFundClaim>>();
        
        
        // This is to get the Request fields , as the Formula fields over Claim are not available during before Insert         
        /*Map<Id,PartnerFundRequest> pfrMap= new Map<Id,PartnerFundRequest>([Select Core_MDF_Activity_Number__c,Core_MDF_Activity_SubType_nm__c,
ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name
from PartnerFundRequest where Id IN: requestIdSet]);*/
        pfrMap = new Map<Id,PartnerFundRequest>([Select Core_MDF_Activity_Number__c,Core_MDF_Activity_SubType_nm__c,
                                                 ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name
                                                 from PartnerFundRequest where Id IN: requestIdSet]);
      
        // To find the duplicate claims withing the List of claims to be inserted
        for(PartnerFundClaim newClaim : claimList){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(newClaim, isclaimAdjustmentType)){   continue; }
            //IPA adding ActivityType, Amount & its currencyType 
            ClaimWrapperClass iKey = new ClaimWrapperClass(pfrMap.get(newClaim.RequestId).Core_MDF_Activity_Number__c , 
                                                           newClaim.Core_MDF_Ad_Run_Start_Date__c , newClaim.Core_MDF_Ad_Run_End_Date__c , 
                                                           newClaim.Core_MDF_Country_Location_nm__c, newClaim.Core_MDF_Media_Vehicle__c , 
                                                           pfrMap.get(newClaim.RequestId).ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name , 
                                                           newClaim.Core_MDF_Invoice_Number__c,
                                                           newclaim.Core_MDF_Activity_Types__c,
                                                           newclaim.Core_MDF_Total_Invoice_Amount_Local__c,newclaim.Core_MDF_Currency__c,newclaim.Core_MDF_Program__c);

            if(newWrapperSet.contains(iKey)){
                newClaim.Core_MDF_Duplicate_Claim__c = true;
            } else {
                newActivityNumber.add((pfrMap.get(newClaim.RequestId).Core_MDF_Activity_Number__c)!=null ?
                                      pfrMap.get(newClaim.RequestId).Core_MDF_Activity_Number__c.trim() : '');
                newAdRunStartDate.add(newClaim.Core_MDF_Ad_Run_Start_Date__c);
                newAdRunEndDate.add(newClaim.Core_MDF_Ad_Run_End_Date__c);
                newCountryLocation.add(newClaim.Core_MDF_Country_Location_nm__c !=null ?
                                       newClaim.Core_MDF_Country_Location_nm__c : '');
                newMediaVehicle.add((newClaim.Core_MDF_Media_Vehicle__c)!=null ?
                                    newClaim.Core_MDF_Media_Vehicle__c.trim() : '');
                newAccountCompany.add((pfrMap.get(newClaim.RequestId).ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r)!=null 
                                      ? pfrMap.get(newClaim.RequestId).ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name.trim() : '');
                newInvoiceNumber.add((newClaim.Core_MDF_Invoice_Number__c)!=null ?
                                     newClaim.Core_MDF_Invoice_Number__c.trim() : '');
                newActyType.add((newClaim.Core_MDF_Activity_Types__c)!=null ?
                                newClaim.Core_MDF_Activity_Types__c.trim() : '');  
                newAmount.add(newClaim.Core_MDF_Total_Invoice_Amount_Local__c);
                newCurrencyType.add((newClaim.Core_MDF_Currency__c)!=null ?
                                    newClaim.Core_MDF_Currency__c.trim() : '');
                newWrapperSet.add(iKey);
            }
            
            newClamIds.add(newClaim.Id);
        }
        // To find duplicate claims against Claims in db
        for(PartnerFundClaim dbClaim : [select Id,Title,Request.Core_MDF_Activity_Number__c, Core_MDF_Ad_Run_Start_Date__c, 
                                        Core_MDF_Ad_Run_End_Date__c,Core_MDF_Country_Location_nm__c,Core_MDF_Media_Vehicle__c,
                                        Core_MDF_AccountCompany__c,Core_MDF_Invoice_Number__c,Core_MDF_Activity_Types__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Currency__c,Core_MDF_Program__c
                                        from PartnerFundClaim where ((Request.Core_MDF_Activity_Number__c IN: newActivityNumber AND Core_MDF_Ad_Run_Start_Date__c IN: newAdRunStartDate  AND Core_MDF_Ad_Run_End_Date__c IN: newAdRunEndDate AND Core_MDF_Country_Location_nm__c IN: newCountryLocation AND Core_MDF_Media_Vehicle__c IN: newMediaVehicle AND Core_MDF_AccountCompany__c IN: newAccountCompany AND Core_MDF_Invoice_Number__c IN: newInvoiceNumber) AND (Id NOT IN:newClamIds)) order by CreatedDate desc]){                                            
                                            ClaimWrapperClass dbWrapperInstance = new ClaimWrapperClass(dbClaim.Request.Core_MDF_Activity_Number__c,dbClaim.Core_MDF_Ad_Run_Start_Date__c,dbClaim.Core_MDF_Ad_Run_End_Date__c,dbClaim.Core_MDF_Country_Location_nm__c,dbClaim.Core_MDF_Media_Vehicle__c,dbClaim.Core_MDF_AccountCompany__c,dbClaim.Core_MDF_Invoice_Number__c,dbClaim.Core_MDF_Activity_Types__c,dbClaim.Core_MDF_Total_Invoice_Amount_Local__c,dbclaim.Core_MDF_Currency__c,dbclaim.Core_MDF_Program__c);
                                            
                                            
                                            dbWrapperSet.add(dbWrapperInstance);
                                            if(mapClaimWrapper.containsKey(dbWrapperInstance)){mapClaimWrapper.get(dbWrapperInstance).add(dbClaim);
                                                                                              }
                                            else{
                                                mapClaimWrapper.put(dbWrapperInstance, new List<PartnerFundClaim>{dbClaim});
                                            }
                                        }
                for(PartnerFundClaim newClaim : claimList){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(newClaim, isclaimAdjustmentType)){continue;}
            ClaimWrapperClass iKey = new ClaimWrapperClass(pfrMap.get(newClaim.RequestId).Core_MDF_Activity_Number__c , 
                                                           newClaim.Core_MDF_Ad_Run_Start_Date__c , 
                                                           newClaim.Core_MDF_Ad_Run_End_Date__c , 
                                                           newClaim.Core_MDF_Country_Location_nm__c , 
                                                           newClaim.Core_MDF_Media_Vehicle__c , 
                                                           pfrMap.get(newClaim.RequestId).ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name , 
                                                           newClaim.Core_MDF_Invoice_Number__c,                                                          
                                                           newClaim.Core_MDF_Activity_Types__c,
                                                           newclaim.Core_MDF_Total_Invoice_Amount_Local__c,
                                                           newclaim.Core_MDF_Currency__c, newclaim.Core_MDF_Program__c);
            
            if(dbWrapperSet.contains(iKey)){
                newClaim.Core_MDF_Duplicate_Claim__c = true;
                // Currently we need to get the duplicate claim list against single record , therefore list would meet our requirement
                // Incase we need List of Duplicate Claims against Multiple Claims to be Inserted, then we would need one more map here to save the claim to be inserted and duplicate claims list from DB 
                duplicateClaimList = mapClaimWrapper.get(iKey);
            }
            // added null check on Id for handling bulk claim scenario
            if(duplicateClaimList.size()==0 && newClaim.Core_MDF_Duplicate_Claim__c==true && newClaim.Id != null){ 
                newClaim.Core_MDF_Duplicate_Claim__c = false;
            }
        }
        return duplicateClaimList;
        
    }
    
    /***************************************************************************************************** 
Method Name:        calculateClaimAmtFieldsOnInsert
@return  :          void
@parameters:        newclaimList
Description:        Method internally calls calculateClaimFields for new claims to be inserted
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void calculateClaimAmtFieldsOnInsert(List<PartnerFundClaim> newclaimList) {
        // calculate claim fields during insert
        calculateClaimFieldsForInsert(newclaimList);
    }
    
    /***************************************************************************************************** 
Method Name:        calculateClaimAmtFieldsOnUpdate 
@return  :          void
@parameters:        inputClaimList and oldClaimList
Description:        Method to determine which all claims got updated and calculation is required
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void calculateClaimAmtFieldsOnUpdate(Map<Id,PartnerFundClaim> newclaimMap,Map<Id,PartnerFundClaim> oldClaimMap) {
        // Perform necessary checks here
        List<PartnerFundClaim> claimListToUpdateStatusToSubmitted = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimListAmountToBeProcessed = new List<PartnerFundClaim>();
        List<String> claimPICStatuses = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimPICStatus').split(';');
        List<String> postPaymentClaimStatus = new List<String>{'Pending Payment', 'Paid'};
        //Set<Id> vatClaimsToBeCancelled = new Set<Id>();
        for(PartnerFundClaim newClaim: newclaimMap.values()){  
            Boolean isAmountChanged = false;

            // Roshan - TWC3117-11893 Bulk claims going into Submitted status when edited after PIC is Passed
            Boolean shouldProcessTaxChange  = !(oldClaimMap.get(newClaim.Id).Core_MDF_Taxes_Local__c == null && newClaim.Core_MDF_Taxes_Local__c == 0);

            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(newClaim, isclaimAdjustmentType)){continue;}
            // if amt chnage 
            if(newClaim.Id == oldClaimMap.get(newClaim.Id).Id 
               &&((newClaim.Core_MDF_Total_Invoice_Amount_Local__c!=null && newClaim.Core_MDF_Total_Invoice_Amount_Local__c != oldClaimMap.get(newClaim.Id).Core_MDF_Total_Invoice_Amount_Local__c)
                  || (newClaim.Core_MDF_OtherCostsnotReimbursable_Local__c!=null && newClaim.Core_MDF_OtherCostsnotReimbursable_Local__c != oldClaimMap.get(newClaim.Id).Core_MDF_OtherCostsnotReimbursable_Local__c)
                  || (shouldProcessTaxChange && newClaim.Core_MDF_Taxes_Local__c != oldClaimMap.get(newClaim.Id).Core_MDF_Taxes_Local__c)  // Roshan - Added new Boolean field
                  //|| (newClaim.Core_MDF_Audit_Adjustment_Amount__c!=null && newClaim.Core_MDF_Audit_Adjustment_Amount__c != oldClaimMap.get(newClaim.Id).Core_MDF_Audit_Adjustment_Amount__c)
                  || (newClaim.Core_MDF_Currency__c!=null && newClaim.Core_MDF_Currency__c != oldClaimMap.get(newClaim.Id).Core_MDF_Currency__c ) 
                  && !postPaymentClaimStatus.contains(newClaim.Core_MDF_Status__c))){ isAmountChanged = true;   claimListAmountToBeProcessed.add(newClaim);  }
            if((isAmountChanged) && !claimPICStatuses.contains(newClaim.Core_MDF_Status__c) && newClaim.Core_MDF_Status__c != Core_MDF_CCP_ConstantClass.PENDING_CLARIFICATION) {claimListToUpdateStatusToSubmitted.add(newClaim);}
        }
        
        if(claimListAmountToBeProcessed != NULL && claimListAmountToBeProcessed.size()>0)
        {
            calculateClaimFieldsForUpdate(newclaimMap,oldClaimMap,claimListAmountToBeProcessed); 
            //Prevent claim update if claim amount exceeds the remaining Activity Budget Amount
            checkClaimAmtAgainstActivityBudgetAmt(claimListAmountToBeProcessed);
            Core_MDF_PFC_Budget_CAP_Validations.checkClaimAmtAgainstCampaignCAPtAmt(claimListAmountToBeProcessed);
        }
        if(claimListToUpdateStatusToSubmitted != NULL && claimListToUpdateStatusToSubmitted.size()>0)  
        {   
            updateStatusToSubmitted(newclaimMap,claimListToUpdateStatusToSubmitted);  
        }
    }
    
    /***************************************************************************************************** 
Method Name:        calculateClaimFieldsForInsert
@return  :          void
@parameters:        inputClaimList and claimListToBeProcessed
Description:        Method to Calculate the Claims fields like Amount based on the exchange rates,
taxes, reimbursement amount etc
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void calculateClaimFieldsForInsert(List<PartnerFundClaim> claimListToBeProcessed) {
        
        List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> inputList = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
        for(PartnerFundClaim claimObj : claimListToBeProcessed){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(claimObj, isclaimAdjustmentType)){continue;}
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount input = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            /*claimObj.Core_MDF_Reimbursable_TransactionAmt_Loc__c = claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c!=null 
&& claimObj.Core_MDF_Taxes_Local__c!=null ?  claimObj.Core_MDF_Total_Invoice_Amount_Local__c - (claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c + claimObj.Core_MDF_Taxes_Local__c) : claimObj.Core_MDF_Total_Invoice_Amount_Local__c;
*/
            //Areefa testing start
            claimObj.Core_MDF_Reimbursable_TransactionAmt_Loc__c = claimObj.Core_MDF_Total_Invoice_Amount_Local__c - 
                ((claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c!=null? claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c: 0) + 
                 ( claimObj.Core_MDF_Taxes_Local__c!=null?claimObj.Core_MDF_Taxes_Local__c:0)); 
            //Areefa Testing End
            
            //claimObj.Core_MDF_Reimbursable_TransactionAmt_Loc__c = claimObj.Core_MDF_Total_Invoice_Amount_Local__c - (claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c + claimObj.Core_MDF_Taxes_Local__c);
            //Passing the Reimbursable_TransactionAmt_Loc to the multicurrency method to get the USD equivalent
            input.inputCurrency = claimObj.Core_MDF_Currency__c;
            input.inputAmount = claimObj.Core_MDF_Reimbursable_TransactionAmt_Loc__c;
            input.inputDate = claimObj.CreatedDate == NULL ? System.today() : claimObj.CreatedDate.Date();
            inputList.add(input);
        }
        if(inputList != null && inputList.size() > 0){
            Map<string,Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> usdAmount = Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(inputList);

            for(PartnerFundClaim claimObj : claimListToBeProcessed){
                //check if adjustment then break
                if(Core_MDF_Claim_Utility.isType(claimObj, isclaimAdjustmentType)){continue;}
 
                String reimbursementPercent = claimObj.Core_MDF_Reimbursement_Percent__c.removeEnd('%');
                Date inputDate = claimObj.CreatedDate == NULL ? System.today() : claimObj.CreatedDate.Date();
                String key = string.valueof(claimObj.Core_MDF_Reimbursable_TransactionAmt_Loc__c) + '\t' +
                    claimObj.Core_MDF_Currency__c + '\t' + string.valueof(inputDate);
               
                if(usdAmount.containsKey(key) && usdAmount.get(key).conversionRate != Null)
                {
                    claimObj.Core_MDF_Exchange_rate__c = usdAmount.get(key).conversionRate;
                    claimObj.Core_MDF_Reimbursable_Transaction_Amount__c = usdAmount.get(key).convertedAmount;
                    claimObj.Core_MDF_Requested_Reimbursement_Amt__c =  claimObj.Core_MDF_Reimbursable_Transaction_Amount__c != NULL ? ((double.valueOf(reimbursementPercent)/100)*claimObj.Core_MDF_Reimbursable_Transaction_Amount__c).setScale(2,System.RoundingMode.HALF_UP) : 0;
                    claimObj.Core_MDF_Audit_Adjustment_Amount__c = claimObj.Core_MDF_Audit_Adjustment_Amount__c != NULL ? (claimObj.Core_MDF_Audit_Adjustment_Amount__c).setScale(2,System.RoundingMode.HALF_UP) : 0;
                    claimObj.Amount = (claimObj.Core_MDF_Requested_Reimbursement_Amt__c - claimObj.Core_MDF_Audit_Adjustment_Amount__c).setScale(2,System.RoundingMode.HALF_UP);
                }
                else{claimObj.Amount = null;}
                
            }
        }
    }
    
    /***************************************************************************************************** 
Method Name:        calculateClaimFieldsforUpdate
@return  :          void
@parameters:        inputClaimList and claimListToBeProcessed
Description:        Method to Calculate the Claims fields like Amount based on the exchange rates,
taxes, reimbursement amount etc
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void calculateClaimFieldsforUpdate(Map<Id,PartnerFundClaim> inputClaimMap, Map<Id,PartnerFundClaim> oldClaimMap, List<PartnerFundClaim> claimListToBeProcessed) {
        //hold parameter needed for multicurrancy function
        List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> inputList = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
        //List of claims to be processed with new exchange rate
        List<PartnerFundClaim> claimListToBeProcessedWithNewExcRate = new List<PartnerFundClaim>();
        //To hold return value of exchange rate function
        Map<string,Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> usdAmount;
        for(PartnerFundClaim claimObj : claimListToBeProcessed){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(claimObj, isclaimAdjustmentType)){continue;}
            if(claimObj == inputClaimMap.get(claimObj.Id)){                
                //check if currency change - call exchange rate function
                if(inputClaimMap.get(claimObj.Id).Core_MDF_Currency__c != oldClaimMap.get(claimObj.Id).Core_MDF_Currency__c ){
                    Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount input = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();                                       
                    //total invoice amoiunt - (other cost not reimburble + tax)
                    //Old code:Decimal reimTransactionAmtLocal = claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c != null && claimObj.Core_MDF_Taxes_Local__c != null? claimObj.Core_MDF_Total_Invoice_Amount_Local__c - (claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c + claimObj.Core_MDF_Taxes_Local__c):claimObj.Core_MDF_Total_Invoice_Amount_Local__c;
                    //Areefa Start
                    Decimal reimTransactionAmtLocal = claimObj.Core_MDF_Total_Invoice_Amount_Local__c - 
                        ((claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c != null?claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c:0) + 
                         (claimObj.Core_MDF_Taxes_Local__c != null ? claimObj.Core_MDF_Taxes_Local__c :0));
                    
                    //Areefa End               
                    
                    inputClaimMap.get(claimObj.Id).Core_MDF_Reimbursable_TransactionAmt_Loc__c = reimTransactionAmtLocal;
                    input.inputCurrency = claimObj.Core_MDF_Currency__c;
                    input.inputAmount = inputClaimMap.get(claimObj.Id).Core_MDF_Reimbursable_TransactionAmt_Loc__c;
                    input.inputDate = claimObj.CreatedDate == NULL ? System.today() : claimObj.CreatedDate.Date();
                    inputList.add(input);
                    claimListToBeProcessedWithNewExcRate.add(claimObj);
                }
            }
        }
        if(inputList != null && inputList.size() > 0){usdAmount = Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(inputList);
                                                     }
        //Calculate amount fields with or without currency change
        calculateAmountWithExistingExcRate(claimListToBeProcessed,inputClaimMap,claimListToBeProcessedWithNewExcRate,usdAmount);
    }
    
    /***************************************************************************************************** 
Method Name:        calculateAmountWithExistingExcRate
@return  :          void
@parameters:        claimListToBeProcessed,newClaimMap,oldClaimMap,list of claims with new exchange rate,exchange rate and amount map
Description:        Method to Calculate amount fields with or without currency change
@Added By:          Accenture - AD 
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    public static void calculateAmountWithExistingExcRate(List<PartnerFundClaim> claimListToBeProcessed,Map<Id,PartnerFundClaim> inputClaimMap,List<PartnerFundClaim> claimListToBeProcessedWithNewExcRate,Map<string,Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> usdAmount){
        
        for(PartnerFundClaim claimObj : claimListToBeProcessed){            
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(claimObj, isclaimAdjustmentType)){continue;}
            String reimbursementPercent = claimObj.Core_MDF_Reimbursement_Percent__c.removeEnd('%');
            if(claimObj == inputClaimMap.get(claimObj.Id) && claimListToBeProcessedWithNewExcRate.contains(claimObj)){               
                Date inputDate = claimObj.CreatedDate == NULL ? System.today() : claimObj.CreatedDate.Date();
                String key = string.valueof(claimObj.Core_MDF_Reimbursable_TransactionAmt_Loc__c) + '\t' + claimObj.Core_MDF_Currency__c + '\t' + string.valueof(inputDate);
                if(usdAmount.containsKey(key) && usdAmount.get(key).conversionRate != Null)
                {
                    inputClaimMap.get(claimObj.Id).Core_MDF_Exchange_rate__c = usdAmount.get(key).conversionRate;
                    inputClaimMap.get(claimObj.Id).Core_MDF_Reimbursable_Transaction_Amount__c = usdAmount.get(key).convertedAmount;
                    inputClaimMap.get(claimObj.Id).Core_MDF_Requested_Reimbursement_Amt__c = claimObj.Core_MDF_Reimbursable_Transaction_Amount__c != NULL ? ((double.valueOf(reimbursementPercent)/100)*claimObj.Core_MDF_Reimbursable_Transaction_Amount__c).setScale(2,System.RoundingMode.HALF_UP) : 0;
                    inputClaimMap.get(claimObj.Id).Core_MDF_Audit_Adjustment_Amount__c = claimObj.Core_MDF_Audit_Adjustment_Amount__c != NULL ? (claimObj.Core_MDF_Audit_Adjustment_Amount__c).setScale(2,System.RoundingMode.HALF_UP) : 0;
                    inputClaimMap.get(claimObj.Id).Amount = (inputClaimMap.get(claimObj.Id).Core_MDF_Requested_Reimbursement_Amt__c - inputClaimMap.get(claimObj.Id).Core_MDF_Audit_Adjustment_Amount__c).setScale(2,System.RoundingMode.HALF_UP);                    
                }
                else{inputClaimMap.get(claimObj.Id).Amount = null;}
            }else{
                //calculate fields with existing exchange rate
                Decimal reimTransactionAmtLocal = claimObj.Core_MDF_Total_Invoice_Amount_Local__c-((claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c != null ? claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c : 0)+ (claimObj.Core_MDF_Taxes_Local__c != null ? claimObj.Core_MDF_Taxes_Local__c : 0));
                inputClaimMap.get(claimObj.Id).Core_MDF_Reimbursable_TransactionAmt_Loc__c = reimTransactionAmtLocal;
                inputClaimMap.get(claimObj.Id).Core_MDF_Reimbursable_Transaction_Amount__c = (reimTransactionAmtLocal *inputClaimMap.get(claimObj.Id).Core_MDF_Exchange_rate__c).setScale(2);            
                inputClaimMap.get(claimObj.Id).Core_MDF_Requested_Reimbursement_Amt__c = claimObj.Core_MDF_Reimbursable_Transaction_Amount__c != NULL ? ((double.valueOf(reimbursementPercent)/100)*claimObj.Core_MDF_Reimbursable_Transaction_Amount__c).setScale(2,System.RoundingMode.HALF_UP) : 0;
                inputClaimMap.get(claimObj.Id).Core_MDF_Audit_Adjustment_Amount__c = claimObj.Core_MDF_Audit_Adjustment_Amount__c != NULL ? (claimObj.Core_MDF_Audit_Adjustment_Amount__c).setScale(2,System.RoundingMode.HALF_UP) : 0;
                inputClaimMap.get(claimObj.Id).Amount = (inputClaimMap.get(claimObj.Id).Core_MDF_Requested_Reimbursement_Amt__c - inputClaimMap.get(claimObj.Id).Core_MDF_Audit_Adjustment_Amount__c).setScale(2,System.RoundingMode.HALF_UP);
            }
        }
    }
    /***************************************************************************************************** 
Method Name:        updateStatusToSubmitted
@return  :          void
@parameters:        inputClaimList and claimListToBeProcessed
Description:        Method to update claim status to submitted
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void updateStatusToSubmitted(Map<Id,PartnerFundClaim> inputClaimMap, List<PartnerFundClaim> claimListToBeProcessed) {
        
        for(PartnerFundClaim claimObj : claimListToBeProcessed){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(claimObj, isclaimAdjustmentType)){continue;}
            if(claimObj == inputClaimMap.get(claimObj.Id) &&
                claimObj.Core_MDF_Status__c!= Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold') && claimObj.Core_MDF_Status__c!= Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Denied')){
                    if(claimObj.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM || (claimObj.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && claimObj.Core_MDF_OutcomeBased_Ind__c)){  
                    inputClaimMap.get(claimObj.Id).Core_MDF_Status__c = 'Draft';
                }
                else{       
                    inputClaimMap.get(claimObj.Id).Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted');
                }
            }
        }
    }
    
    /*************************************************************************************************************************
* @description : Method to assign the Record Type to Claim based on the Record Type assigned to its respective Activity
* @param claimList 
******************************************************************************************************************************/
    public static void assignClaimRecordType(List<PartnerFundClaim> claimList){
        
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        
        List<string> validbudgetTypes = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_OPAL_BudgetTypes'); 
        List<string> oEMProgram = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_OEM_Program_Name');         
        // flag saying whether the PIC functionality is ON or OFF
        Boolean isPICRequired = (mapFunctionalityNameTriggerExecution.containsKey('checkAndSendClaimsForPIC') && mapFunctionalityNameTriggerExecution.get('checkAndSendClaimsForPIC').Core_Active__c) ? true : false;
        //Set of request Ids
        Set<ID> requestIDs = new Set<ID>();
        setOfBankIds = new Set<Id>();
        for(PartnerFundClaim pfc: claimList){
            requestIDs.add(pfc.RequestId);
            if(pfc.Core_MDF_Bank__c!=null){
                setOfBankIds.add(pfc.Core_MDF_Bank__c);
            }  
            assignClaimType(pfc);            
            
        }
        //existing PFRs specific to request IDs
        //Map<Id,PartnerFundRequest> 
        pfrInstance = new Map<ID,PartnerFundRequest>([SELECT ID,RecordType.DeveloperName,Core_MDF_Brand_nm__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Activity_SubType_nm__c, channelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountry,channelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c 
                                                      ,Core_MDF_Proposal_Based_Ind__c,Campaign.Core_MDF_CampOutcomeOpt_In_Ind__c, Core_MDF_Is_Outcome_Based_Ind__c FROM PartnerFundRequest WHERE ID IN:requestIDs]);  //Roshan
        
        
        //Record Type Info Map
        Map<String,Schema.RecordTypeInfo> claimRecordTypeMap = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName(); 
        for(PartnerFundClaim claimObj : claimList){
            String claimRecTypeDevName;
            if(mapOfRecTypeMetadata !=null && (mapOfRecTypeMetadata.containsKey((pfrInstance.get(claimObj.RequestId)).RecordType.DeveloperName) || mapOfRecTypeMetadata.containsKey((pfrInstance.get(claimObj.RequestId)).RecordType.DeveloperName +'_Proposal_Based')) ){
             
                if(pfrInstance.get(claimObj.RequestId).Core_MDF_Proposal_Based_Ind__c){
                    claimRecTypeDevName = mapOfRecTypeMetadata.get((pfrInstance.get(claimObj.RequestId)).RecordType.DeveloperName+'_Proposal_Based').Core_MDF_Claim_RecordType_txt__c; 
                }
                else{
                    claimRecTypeDevName = mapOfRecTypeMetadata.get((pfrInstance.get(claimObj.RequestId)).RecordType.DeveloperName).Core_MDF_Claim_RecordType_txt__c;
                }
                claimObj.RecordtypeId =  claimRecordTypeMap.get(claimRecTypeDevName).getRecordTypeId();
               
            }
            //check if adjustment then break
            if(!Core_MDF_Claim_Utility.isType(claimObj, isclaimAdjustmentType))
            {
                // Setting status field at time of claim creation
                if(claimObj.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM || (claimObj.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && ((pfrInstance.get(claimObj.RequestId)).Campaign.Core_MDF_CampOutcomeOpt_In_Ind__c ==TRUE || (pfrInstance.get(claimObj.RequestId)).Core_MDF_Is_Outcome_Based_Ind__c == TRUE))) {  //Roshan
                    claimObj.Core_MDF_Status__c = (claimObj.Core_MDF_Status__c == 'Pending Review' && claimObj.Core_MDF_Claim_Id__c == null) ? claimObj.Core_MDF_Status__c : 'Draft';
                    claimObj.Core_MDF_Approval_Step_Counter_nbr__c = (claimObj.Core_MDF_Status__c == 'Pending Review' && claimObj.Core_MDF_Claim_Id__c == null) ? 1 : 0;
                } else {
                    claimObj.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted');
                }
                claimObj.Core_MDF_Claim_Previous_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted');
                claimObj.Status = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted');
                
            }
            
            // setting the Eval In progress flag to True if PIC Functionality is Set          
            if(isPICRequired && claimObj.Core_MDF_Claim_Id__c == null){
                claimObj.Core_MDF_Claim_EvalInProgress_Ind__c = true;
            }
            //Areefa 11/11/2021 : defualt selection of Activity Subtype
            if(!Core_MDF_Utility.byPassFeature('Bypass_StampingOfActySubType_Check')){            
                if(oEMProgram.contains(claimObj.Core_MDF_Program__c) && validbudgetTypes.contains(claimObj.Core_MDF_Budget_Type_Options_Nm__c) && pfrInstance.get(claimObj.RequestId).Core_MDF_Activity_SubType_nm__c!=null && claimObj.Core_MDF_Activity_SubType_nm__c==null ){
                    claimObj.Core_MDF_Activity_SubType_nm__c = pfrInstance.get(claimObj.RequestId).Core_MDF_Activity_SubType_nm__c;
                }
            }
            //Multiselect Brand picklist field changes- WW27/June'2022
            if(pfrInstance.get(claimObj.RequestId).Core_MDF_Brand_nm__c!=null){
                claimObj.Core_MDF_Brand_nm__c = pfrInstance.get(claimObj.RequestId).Core_MDF_Brand_nm__c;
            }
        }
    }   
    
    
    /***************************************************************************************************** 
Method Name:        updateEvalInProgressFlag
@return  :          void
@parameters:        claimList and oldClaimMap
Description:        Method to Check if the editable fields on the Claims are updated 
And accordingly change the Core_MDF_Claim_EvalInProgress_Ind__c flag to True
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void updateEvalInProgressFlag(List<PartnerFundClaim> claimList, Map<Id,PartnerFundClaim> oldClaimMap){
        List<String> claimPICStatuses = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimPICStatus').split(';');
        for(partnerFundClaim newClaim: claimList){
            ///check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(newClaim, isclaimAdjustmentType)){continue;}
            //check if claim is in submitted and is set for reprocessing OR check if claim is legacy and is edited
            if((newClaim.Core_MDF_Status__c == label.Core_MDF_Status_Submitted && newClaim.Core_MDF_Reprocess_Claim__c==true) || (Core_MDF_PIC_Utility.isLegacy(newClaim) && !newClaim.Core_MDF_PIC_Review_Completed__c && isClaimEdited(newClaim,oldClaimMap) && !claimPICStatuses.contains(newClaim.Core_MDF_Status__c))){
                newClaim.Core_MDF_Claim_EvalInProgress_Ind__c = true;
            }
        }
    }
    
    /***************************************************************************************************** 
Method Name:        sendclaimsforPIC
@return  :          void
@parameters:        claimList and oldClaimMap
Description:        Method to Send the Claims for PIC Processing if the corresponding Core_MDF_Claim_EvalInProgress_Ind__c flag is true
and expected editable fields are updated
@Added By:          Intel - SM
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void sendclaimsforPIC(List<PartnerFundClaim> claimList, Map<Id,PartnerFundClaim> oldClaimMap){
        
        List<PartnerFundClaim> claimListToBeSentToPIC = new List<PartnerFundClaim>();
        List<String> claimPICStatuses = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimPICStatus').split(';');
        for(PartnerFundClaim newClaim : claimList){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(newClaim, isclaimAdjustmentType))
            {
                continue;
            }
            //check if claim is in submitted and is set for reprocessing OR check if claim is legacy and is edited
            if((newClaim.Core_MDF_Status__c == label.Core_MDF_Status_Submitted && newClaim.Core_MDF_Reprocess_Claim__c==true && newClaim.Core_MDF_Claim_Id__c == null) || (Core_MDF_PIC_Utility.isLegacy(newClaim) && !newClaim.Core_MDF_PIC_Review_Completed__c && newClaim.Core_MDF_Claim_EvalInProgress_Ind__c && isClaimEdited(newClaim,oldClaimMap) && !claimPICStatuses.contains(newClaim.Core_MDF_Status__c))){
                claimListToBeSentToPIC.add(newClaim);
            }
        }
        if(claimListToBeSentToPIC != NULL && claimListToBeSentToPIC.size() > 0){
            ID jobID = System.enqueueJob(new Core_MDF_BatchtoPICClaim(claimListToBeSentToPIC));
        }
    }
    
    
    /***************************************************************************************************** 
Method Name:        isClaimEdited
@return  :          Boolean
@parameters:        NewClaim and oldClaimMap
Description:        Method to check if any of the ediatble fields on the claim is getting changed
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static Boolean isClaimEdited(PartnerFundClaim newClaim, Map<Id,PartnerFundClaim> oldClaimMap){
        
        if(newClaim.Core_MDF_Ad_Run_Start_Date__c != oldClaimMap.get(newClaim.ID).Core_MDF_Ad_Run_Start_Date__c
           || newClaim.Core_MDF_Ad_Run_End_Date__c != oldClaimMap.get(newClaim.ID).Core_MDF_Ad_Run_End_Date__c
           || newClaim.Core_MDF_Media_Vehicle__c != oldClaimMap.get(newClaim.ID).Core_MDF_Media_Vehicle__c
           || newClaim.Core_MDF_Bank__c != oldClaimMap.get(newClaim.ID).Core_MDF_Bank__c
           || newClaim.Core_MDF_Invoice_Number__c != oldClaimMap.get(newClaim.ID).Core_MDF_Invoice_Number__c
           || newClaim.Core_MDF_Invoice_Date__c != oldClaimMap.get(newClaim.ID).Core_MDF_Invoice_Date__c
           || newClaim.Core_MDF_Total_Invoice_Amount_Local__c != oldClaimMap.get(newClaim.ID).Core_MDF_Total_Invoice_Amount_Local__c
           || newClaim.Core_MDF_OtherCostsnotReimbursable_Local__c != oldClaimMap.get(newClaim.ID).Core_MDF_OtherCostsnotReimbursable_Local__c
           || newClaim.Core_MDF_Taxes_Local__c != oldClaimMap.get(newClaim.ID).Core_MDF_Taxes_Local__c
           || (newClaim.Core_MDF_Audit_Adjustment_Amount__c != oldClaimMap.get(newClaim.ID).Core_MDF_Audit_Adjustment_Amount__c && newClaim.Core_MDF_Status__c!=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Denied'))
           || newClaim.Core_MDF_Currency__c != oldClaimMap.get(newClaim.ID).Core_MDF_Currency__c
           || newClaim.Core_MDF_PIC_Review_Completed__c != oldClaimMap.get(newClaim.ID).Core_MDF_PIC_Review_Completed__c
           || (newClaim.Core_MDF_Reprocess_Claim__c != oldClaimMap.get(newClaim.ID).Core_MDF_Reprocess_Claim__c && newClaim.Core_MDF_Reprocess_Claim__c && newClaim.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted'))){ 
               
               return true;    
           }
        else{
            return false;
        }
    }
    /***************************************************************************************************** 
Method Name:        fetchRecordTypeMetaData
@return  :          Map of string and metadata object
@parameters:        N/A
Description:        Method to query all metadata records and create a map
@Added By:          Accenture - AD 
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    public static Map<String,Core_MDF_ObjRecType_Budget_FieldSetMap__mdt> fetchRecordTypeMetaData(){ //TWC3117-18333
        Map<String,Core_MDF_ObjRecType_Budget_FieldSetMap__mdt> mapOfRecordTypes = new Map<String,Core_MDF_ObjRecType_Budget_FieldSetMap__mdt>();
        for(Core_MDF_ObjRecType_Budget_FieldSetMap__mdt recTypeMetaData:[Select Id,Core_MDF_Region_cd__c,Core_MDF_Channel_Program_txt__c ,Core_MDF_Activity_RecordType_txt__c,Core_MDF_Allocation_RecordType_txt__c,
                                                                       Core_MDF_Claim_RecordType_txt__c,Core_MDF_Enable_Fund_Reservation_chk__c,Core_MDF_isProposalBased__c 
                                                                       from Core_MDF_ObjRecType_Budget_FieldSetMap__mdt LIMIT 1000]
           ){
                if(recTypeMetaData.Core_MDF_isProposalBased__c)
               {
                   mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Activity_RecordType_txt__c+'_Proposal_Based',recTypeMetaData);  
               }
               else
                {
                   mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Activity_RecordType_txt__c,recTypeMetaData);
                }
            
           }
        return mapOfRecordTypes;
    }
    
    /***************************************************************************************************** 
Method Name:        getRecordTypeSet
@return  :          Set of record type Id
@parameters:        Map of record type info
Description:        Method to query all metadata records and create a map
@Added By:          Accenture - AD 
Modified By:        Date:       Changes: 
Roshan              28/02/25    Added a conditon in IF to check only for RecordTypes which are existing in PFC object
******************************************************************************************************/
    public static Set<Id> getRecordTypeSet(Map<String,Schema.RecordTypeInfo> claimRecordTypeMap){
        // To hold CoMarketing Record Types for Claims
        Set<Id> recordTypeSet = new Set<Id>();
        for(Core_MDF_ObjRecType_Budget_FieldSetMap__mdt recordTypeMetaData : mapOfRecTypeMetadata.values()){ //TWC3117-18333
            if(recordTypeMetaData.Core_MDF_Claim_RecordType_txt__c!=null && claimRecordTypeMap.containsKey(recordTypeMetaData.Core_MDF_Claim_RecordType_txt__c) && recordTypeMetaData.Core_MDF_Enable_Fund_Reservation_chk__c == TRUE){
                recordTypeSet.add(claimRecordTypeMap.get(recordTypeMetaData.Core_MDF_Claim_RecordType_txt__c).getRecordTypeId());   
            }
        }
        return recordTypeSet;
    } 
    
    /***************************************************************************************************** 
Method Name:        isType
@return  :          Boolean value to indicate whether the given claim belongs to a given type 
@parameters:        Claim and type to be checked for
Description:        Method to check whether the given claim belongs to a given type
@Added By:          Intel - SM 
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    
    @AuraEnabled
    public static Boolean isType(PartnerFundClaim claim, String types)
    {
        //List of types to be checked - from a label of different types to be checked
        
        List<String> claimType = types.split(';');
        if(claim.Core_MDF_Type_Txt__c != NULL && claimType.contains(claim.Core_MDF_Type_Txt__c))
        {
            return true;
        }
        else
        {
            return false;
        }
        
    } 
    
    /***************************************************************************************************** 
Method Name:        assignClaimType
@return  :          void 
@parameters:        Claim 
Description:        Method to assign Claim Type to a claim
@Added By:          Intel - SM 
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    
    public static void assignClaimType(PartnerFundClaim claim)
    {
        claim.Core_MDF_Type_Txt__c = claim.Core_MDF_Type_Txt__c == null ? claim.Core_MDF_Type_Txt__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Type') : claim.Core_MDF_Type_Txt__c;
    } 
    
    
    
    /****************************************************************************************************** 
Method Name:        isInternalAuditUser
@return  :          Boolean
@parameters:        String userId,String permissionName
Description:        This method is used to check the permission set over logged in user
Added By:           Accenture - AD - 11/26/2018
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static Boolean isInternalAuditUser(String custPermissionName){
        Boolean isAuditUser = false;
        try {
            Boolean hasCustomPermission = FeatureManagement.checkPermission(custPermissionName);
            if(hasCustomPermission){isAuditUser=true;}
            return isAuditUser;
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    /****************************************************************************************************** 
Method Name:        updateClaimIdOnEscalation
@return  :          N/A
@parameters:        List of claims to be processed
Description:        This method is used to update claim id over escalation
Added By:           Accenture - AD - 06/25/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/    
    public static void updateClaimIdOnEscalation(List<PartnerFundClaim> claimsToBeProcessed){
       
        //Map of escalations to be updated
        Map<Id,Core_MDF_Escalation__c> escalationsToBeUpdatedMap = new Map<Id,Core_MDF_Escalation__c>();
        for(PartnerFundClaim pfcRecord : claimsToBeProcessed){
            if(pfcRecord.Core_MDF_Escalation_Id__c !=null && pfcRecord.Core_MDF_Claim_Id__c == null){
                //New escalation instance
                Core_MDF_Escalation__c escalationRecord = new Core_MDF_Escalation__c(id=pfcRecord.Core_MDF_Escalation_Id__c);
                //null check for escalation record
                if(escalationRecord!=null){
                    //Assign claim id on escalation record
                    escalationRecord.Core_MDF_Claim_Number_id__c = pfcRecord.Id;
                    //Add updated escalation
                    escalationsToBeUpdatedMap.put(escalationRecord.Id,escalationRecord);
                }
            }   
        }
       
        if(escalationsToBeUpdatedMap!=null && escalationsToBeUpdatedMap.size()>0){
            //Update escalations
            Database.update(escalationsToBeUpdatedMap.values());
        }
    }
    /****************************************************************************************************** 
Method Name:        populateOwnerLangLocalonclaimcreate
@return  :          N/A
@parameters:        List of claims
Description:        This method is used to update language local key on claim when owner is changed
Added By:           Accenture - AS - 07/22/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static void populateOwnerLangLocalOnClaim(List<PartnerFundClaim> newClaimList, Map<Id,PartnerFundClaim> oldClaimMap){
        //Map of claim owner Id and Claim Id
        Map<Id,Id> ownerIdToClaimIDMap = new Map<Id,Id>();
        for(PartnerFundClaim pfc : newClaimList){
            //check for New and Owner updated claim
            if((oldClaimMap == null && pfc.Core_MDF_Owner_LanguageLocaleKey_Cd__c == null) || (oldClaimMap != null && (pfc.OwnerId != oldClaimMap.get(pfc.Id).OwnerId)) ){
                ownerIdToClaimIDMap.put(pfc.OwnerId,pfc.Id);   
            }
        }
        if(ownerIdToClaimIDMap!=null && ownerIdToClaimIDMap.size()>0){
            //Map of existing user
            Map<Id,User> userLocalMap = new Map<Id,User>([Select id,LanguageLocaleKey from User where Id IN:ownerIdToClaimIDMap.Keyset()]);
            for(PartnerFundClaim newpfc : newClaimList){
                if(ownerIdToClaimIDMap.values().contains(newpfc.Id)){
                    //to store owner's language locale key
                    newpfc.Core_MDF_Owner_LanguageLocaleKey_Cd__c = userLocalMap.containsKey(newpfc.OwnerId) ? userLocalMap.get(newpfc.OwnerId).LanguageLocaleKey : Core_MDF_CustomLabelConfig.getTextValues('Core_English_Language_Locale_Key');
                    
                }                
            }
        }
    }
    
    /****************************************************************************************************** 
Method Name:        updateRegionFieldOverClaimOnInsert
@return  :          NA
@parameters:        List of claims to be updated with Geo values
Description:        This method will update Region field on claim as per country selected on claim creation.
Added By:           Accenture - VD - 11-Oct-2019
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static void updateRegionFieldOverClaimOnInsert(List<PartnerFundClaim> newclaimList) {
        // update Region field according to country on claim record
        //ATHR - Deeply Nested if 16209
        if(newclaimList == NULL || newclaimList.isEmpty()) return;
        //if(newclaimList != NULL && newclaimList.size() > 0){
            for(PartnerFundClaim pfc : newclaimList){
                //ATHR - Deeply Nested if 16209
                if (wrapperMapOfCountryRegion == null || wrapperMapOfCountryRegion.isEmpty() || wrapperMapOfCountryRegion.get(pfc.Core_MDF_Country_Location_nm__c) == null || !wrapperMapOfCountryRegion.containskey(pfc.Core_MDF_Country_Location_nm__c)) continue;
                //if(wrapperMapOfCountryRegion!=Null && wrapperMapOfCountryRegion.size()>0 && wrapperMapOfCountryRegion.containskey(pfc.Core_MDF_Country_Location_nm__c)){
                    pfc.Core_MDF_Region_Cd__c = wrapperMapOfCountryRegion.get(pfc.Core_MDF_Country_Location_nm__c).geo;
                    //Getting Region field from metadata to check it's value
                    if(mapOfRecTypeMetadata !=null && mapOfRecTypeMetadata.containsKey((pfrInstance.get(pfc.RequestId)).RecordType.DeveloperName)){
                        String metadataRegion = mapOfRecTypeMetadata.get((pfrInstance.get(pfc.RequestId)).RecordType.DeveloperName).Core_MDF_Region_cd__c;
                        //Checking if claim is of retail program
                        if(metadataRegion!='' && metadataRegion!=NULL && metadataRegion.contains(pfc.Core_MDF_Region_Cd__c)){
                            //updating subgeo field
                            pfc.Core_MDF_Sub_Region_Cd__c = wrapperMapOfCountryRegion.get(pfc.Core_MDF_Country_Location_nm__c).subGeo;
                        }
                    }
                //}
            }
        //}
    }
    
    
    /****************************************************************************************************** 
Method Name:        updateRegionFieldOverClaimOnUpdate
@return  :          NA
@parameters:        New claim map and old claim map
Description:        This method will update Region field on claim if claim country is updated
Added By:           Accenture - VD - 14-Oct-2019
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static void updateRegionFieldOverClaimOnUpdate(Map<Id,PartnerFundClaim> newClaimMap,Map<Id,PartnerFundClaim> oldClaimMap){
        //Map of Program and Region
        Map<String,String> mapOfProgramTypeAndRegion = new Map<String,String>();
        for(Core_MDF_ObjRecType_Budget_FieldSetMap__mdt mapOfRecType : mapOfRecTypeMetadata.values()){ //TWC3117-18333
            mapOfProgramTypeAndRegion.put(mapOfRecType.Core_MDF_Channel_Program_txt__c,mapOfRecType.Core_MDF_Region_cd__c);
        }
        for(PartnerFundClaim claim : newClaimMap.values()){
            if(claim.Id == oldClaimMap.get(claim.Id).Id 
               && claim.Core_MDF_Country_location_nm__c != oldClaimMap.get(claim.Id).Core_MDF_Country_location_nm__c 
               && wrapperMapOfCountryRegion!=Null && wrapperMapOfCountryRegion.size()>0 && wrapperMapOfCountryRegion.containskey(claim.Core_MDF_Country_Location_nm__c)){
                   //Updating Region field
                   claim.Core_MDF_Region_Cd__c = wrapperMapOfCountryRegion.get(claim.Core_MDF_Country_Location_nm__c).geo;
                   //Checking if it is retail program
                   if(mapOfProgramTypeAndRegion !=null && mapOfProgramTypeAndRegion.containsKey(claim.Core_MDF_Program__c)
                      && mapOfProgramTypeAndRegion.get(claim.Core_MDF_Program__c)!=NULL && mapOfProgramTypeAndRegion.get(claim.Core_MDF_Program__c).contains(claim.Core_MDF_Region_Cd__c)){
                          //Updating Sub Region field
                          claim.Core_MDF_Sub_Region_Cd__c = wrapperMapOfCountryRegion.get(claim.Core_MDF_Country_Location_nm__c).subGeo;
                      }
               }
        }
    }
    
    /****************************************************************************************************** 
Method Name:        validateABM
@return  :          NA
@parameters:        List of claims to be processed
Description:        This method will check for active ABM
Added By:           Accenture - AD - 10-Feb-2020
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static void validateABM(List<PartnerFundClaim> claimsToBeProcessed){
       
        //Bank Id Set
        Set<Id> bankIdSet = new Set<Id>();
        //Request Id Set 
        Set<Id> requestIdSet = new Set<Id>();
        //unique  key  and active flag map
        Map<String,Boolean> accountBankMappingMap = new Map<String,Boolean>();
        //PFR to channel partner ID
        Map<Id,Id> pfrToChannelPartnerMap = new Map<Id,Id>();
        //to get budgettypes for which bank has to be hidden from custom setting
        Core_MDF_Configuration__c mc = Core_MDF_Configuration__c.getValues('BUDGET_TYPE_CLAIM_BANK_HIDE');
        List<String> creditMemoPaymentTypes = Label.Core_MDF_PaymentTypes_to_hideBank.split(',');
        List<String> budgetTypesToHideBank = (mc != null) ? mc.Core_MDF_Value__c.split(',') : null;
        for(PartnerFundClaim pfcRecord : claimsToBeProcessed){
            requestIdSet.add(pfcRecord.requestId);
            bankIdSet.add(pfcRecord.Core_MDF_Bank__c);
        }
        //Query exisitng PFR and creating pfr to channel partner map    
        for(PartnerFundRequest pfrRecord : [Select Id,ChannelPartnerId from PartnerFundRequest where Id IN:requestIdSet]){
            pfrToChannelPartnerMap.put(pfrRecord.Id,pfrRecord.ChannelPartnerId);
        }
        //Query exisitng account bank mapping based on account and bank   
        for(Core_MDF_Account_Bank_Mapping__c abmRecord : [SELECT Id,Core_MDF_Active_ind__c,Core_MDF_Bank__c,Core_MDF_Account__c from Core_MDF_Account_Bank_Mapping__c where Core_MDF_Bank__c IN:bankIdSet 
                                                          and Core_MDF_Account__c IN:pfrToChannelPartnerMap.values()]){
                                                              accountBankMappingMap.put(abmRecord.Core_MDF_Bank__c+'-'+abmRecord.Core_MDF_Account__c,abmRecord.Core_MDF_Active_ind__c);
                                                          }
        for(PartnerFundClaim pfcRecord : claimsToBeProcessed){
            //Areefa
            
            if(pfcRecord!=null && pfcRecord.Core_MDF_Type_Txt__c != isclaimAdjustmentType
               
               && pfcRecord.Core_MDF_Budget_Type_Options_Nm__c != Label.Core_MDF_Retail_RSA_MD_Budget_Type
               && (!creditMemoPaymentTypes.contains(pfcRecord.Core_MDF_Paid_By_Payment_Type_nm__c))
               && (budgetTypesToHideBank != null && !budgetTypesToHideBank.contains(pfcRecord.Core_MDF_Budget_Type_Options_Nm__c))
              && (pfcRecord.RecordType.developername == Label.Core_MDF_IPA_AccountBased_RecType_DevName && pfcRecord.Core_MDF_OutcomeBased_Ind__c && (pfcRecord.Request.Core_MDF_Activity_Level_nm__c == null || pfcRecord.Core_MDF_Claim_Id__c != null))){
                   //Unique Key [bank Id - ChannelPartnerId]
                   
                   String uniqueKey = String.valueOf(pfcRecord.Core_MDF_Bank__c+'-'+
                                                     (pfrToChannelPartnerMap.containsKey(pfcRecord.requestId) ? pfrToChannelPartnerMap.get(pfcRecord.requestId) : ''));
                   
                   if(!accountBankMappingMap.containsKey(uniqueKey) || (accountBankMappingMap.containsKey(uniqueKey) && !accountBankMappingMap.get(uniqueKey))){
                       //Showing bank related error
                       pfcRecord.addError(Label.Core_MDF_Claim_Stage_Bank_Error);
                   }
               }
        }
    }
    
    /****************************************************************************************************** 
Method Name:        checkClaimAmtAgainstActivityBudgetAmt
@return  :          NA
@parameters:        List of input claims
Description:        This method is used to check the Claim Amount Against the Activity Budget Amount
Added By:           Intel - SM  - 13-Feb-2020
Modified By:        Date:       Changes: 
Intel   -    Areefa     -    1 July,2021
Intel   -    Areefa     -    8 Sept,2021
*******************************************************************************************************/
    
    public static void checkClaimAmtAgainstActivityBudgetAmt(List<PartnerFundClaim> inputClaims)
    {
        Set<String> programsForActBudgetAmtCheck = new Set<String>();
        
        //Exclude the budget type validation for CCF 1.0 and DCF 1.0 program 
        List<string> excludeBudgetTypes = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_BudgetTypeToExclude');
       
        //To check if the Activity Budget Amount Check is Required for a given Program
        for(Core_MDF_ChannelProgram__mdt program : [Select Label from Core_MDF_ChannelProgram__mdt
                                                    where Core_MDF_Act_Budget_Amt_Chk_Reqd__c= true])
        {
            programsForActBudgetAmtCheck.add(program.Label);
        }
        List<PartnerFundClaim> listOfClaimsToBeProcessed = new List<PartnerFundClaim>();
        
        for(PartnerFundClaim pfc : inputClaims)
        {
            // excludeBudgetTypes added to Exculde validation for CCF1.0 and DCF1.0 Program
            if(programsForActBudgetAmtCheck.contains(pfc.Core_MDF_Program__c) && pfc.Core_MDF_Type_Txt__c.equals(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Type')) 
               && !(excludeBudgetTypes.contains(string.valueof(pfc.Core_MDF_Budget_Type_Options_Nm__c))))
            {
                listOfClaimsToBeProcessed.add(pfc); 
            }
        }
        //ATHR - Deeply Nested if 16209
        if((listOfClaimsToBeProcessed == null || listOfClaimsToBeProcessed.isEmpty()) && !Test.isRunningTest()) {
            return;
        }
        //if(listOfClaimsToBeProcessed!= null && listOfClaimsToBeProcessed.size() > 0 ||test.isRunningTest())
        //{ 
            //Label.Core_MDF_InactiveStatusForClaim = 'Cancelled;Denied;Adjusted'
            List<String> claimStatusToBeExcluded = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_InactiveStatusForClaim');
            //Map to store the Activity as key and list of its new claims to be inserted
            Map<Id, List<PartnerFundClaim>> mapNewClaimwithAct = new Map<Id,List<PartnerFundClaim>>();
            for(PartnerFundClaim pfc : listOfClaimsToBeProcessed)
            {
                if(mapNewClaimwithAct.containsKey(pfc.RequestId)){
                    mapNewClaimwithAct.get(pfc.RequestId).add(pfc);
                }
                else{
                    mapNewClaimwithAct.put(pfc.RequestId, new List<PartnerFundClaim>{pfc});
                }
            }
            //Map to store the Activity as key and its Available Budget Amount.
            Map<Id,Decimal> mapofActwithAvailableBudget = new Map<Id,Decimal>();
            
            for(PartnerFundRequest pfr : [Select Id, RequestedAmount,Core_MDF_Activity_Reimbursement_Amt_nbr__c,Core_MDF_Program__c from PartnerFundRequest where Id IN : mapNewClaimwithAct.keySet()])
            { mapofActwithAvailableBudget.put(pfr.Id, pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c); }
            
            //Aggregate result to the Sum of Claims Amount on an Activity
            
            List<AggregateResult> sumofClaimsAmount = [SELECT RequestID, SUM(Amount) claimedAmt, MAX(Request.RequestedAmount) requestedAmount,
                                                       MAX(Request.Core_MDF_Activity_Reimbursement_Amt_nbr__c) activiyReimAmount,MAX(Request.Core_MDF_Program__c) Program 
                                                       from PartnerFundClaim WHERE RequestId IN :mapNewClaimwithAct.keySet() AND Core_MDF_Status__c <> :claimStatusToBeExcluded AND Core_MDF_Type_Txt__c = :Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Type') AND Id Not IN :inputClaims
                                                       GROUP BY RequestId];
            //To Obtain the Available Amount by decducting the sum of the claims Amount from the Activity Budget Amount
            if(sumofClaimsAmount!= null && sumofClaimsAmount.size() > 0){ 
                for(AggregateResult agg:sumofClaimsAmount){ 
                    Decimal requestedAmount =(Decimal)agg.get('requestedAmount'); 
                    Decimal activiyReimAmount =(Decimal)agg.get('activiyReimAmount'); 
                    Decimal claimedAmt=(decimal)agg.get('claimedAmt'); 
                    mapofActwithAvailableBudget.put((id)agg.get('RequestID'), activiyReimAmount - claimedAmt);                                     
                } 
            }
            //Loop thro the Incoming Claims List to check 
            //their Amount lies within the corresponding Activity's Budget Amount
            for(Id reqId : mapNewClaimwithAct.keySet())
            { 
                //get the list of claims for a given activity from the list of incoming claims 
                List<PartnerFundClaim> claimLst = mapNewClaimwithAct.get(reqId);
                for(PartnerFundClaim pfc : claimLst)
                {
                    //defaulting excess requested amount to zero
                    pfc.Core_MDF_Excess_Requested_Amount__c=0;
                    //Get the corresponding Actvity's Available Budget Amount
                    Decimal availableAmount = mapofActwithAvailableBudget.get(pfc.RequestId);
                   
                    //check if requested amount is exceeding
                    //ATHR - Deeply Nested if 16209
                    /*if(pfc.Amount > availableAmount)
                    {
                        
                            // check if all amount available on activity is not consumed
                            if(availableAmount > 0){                            
                                pfc.Core_MDF_Excess_Requested_Amount__c = pfc.Amount - availableAmount;
                                pfc.Amount = availableAmount;
                                mapofActwithAvailableBudget.put(pfc.RequestId, 0); 
                            }
                            
                            else{
                                //if all amount available on activity is consumed
                                pfc.addError(Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt, true);
                            }

                    }*/
                    if(pfc.Amount > availableAmount && availableAmount > 0){                            
                        pfc.Core_MDF_Excess_Requested_Amount__c = pfc.Amount - availableAmount;
                        pfc.Amount = availableAmount;
                        mapofActwithAvailableBudget.put(pfc.RequestId, 0); 
                    }
                    else if(pfc.Amount > availableAmount && availableAmount <= 0)
                    {
                        pfc.addError(Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt, true);
                    }
                    else
                    {
                        //If claim amount is lesser than or equal to the activity's available amount,
                        //process it by deducting claim amount from the available amount
                        mapofActwithAvailableBudget.put(pfc.RequestId, (availableAmount != null ? availableAmount : 0) - (pfc.Amount !=null ? pfc.Amount : 0));
                    }
                    
                }
                
            }
        //}
        
    }
    
    /*********************************************************************************************************************** 
Method Name:        populateQuarterYearFieldOnClaimInsert
@return  :          void
@parameters:        List of input claims
Description:        This method is used to update Core_MDF_AdrunStartDate_QuarterNo_Year__c field for claim's start date
Added By:           Accenture - Pranav  - 18-Sep-2020
Modified By:        Date:       Changes: 
************************************************************************************************************************/
    
    public static void populateQuarterYearFieldOnClaimInsert(List<PartnerFundClaim> claimList)
    {
        // Variables to store Latest and Oldest Claim's AdrunStart date
        Date oldestAdRunStartDate; 
        Date latestAdRunStartDate;
        if(claimList != NULL && !claimList.isEmpty()){
            
            // Assigning oldestAdRunStartDate and latestAdRunStartDate with very first claim's Ad run Start date 
            oldestAdRunStartDate = claimList[0].Core_MDF_Ad_Run_Start_Date__c;
            latestAdRunStartDate = claimList[0].Core_MDF_Ad_Run_Start_Date__c;
            
            // Fetching Oldest and latest Adrun start Date from list of claims
            for(PartnerFundClaim claim : claimList){
                if(claim.Core_MDF_Ad_Run_Start_Date__c < oldestAdRunStartDate){ oldestAdRunStartDate = claim.Core_MDF_Ad_Run_Start_Date__c;
                                                                              }
                if(claim.Core_MDF_Ad_Run_Start_Date__c > latestAdRunStartDate){ latestAdRunStartDate = claim.Core_MDF_Ad_Run_Start_Date__c;
                                                                              }
            }
            
            // get all the Custom fiscal Quarter and respective years between Oldest and latest Ad run Start date
            List<Period> periodList = [SELECT FiscalYearSettings.Name, Number, StartDate, EndDate FROM Period where FiscalYearSettings.YearType = 'Custom' And Type = 'Quarter' And StartDate <=: latestAdRunStartDate and endDate >=: oldestAdRunStartDate];      
            
            // Iterate over new list of claims
            for (PartnerFundClaim pfc : claimList)
            {
                // for Each Period
                for(Period period: periodList){
                    // Check if claim start date is within the quarter
                    if((pfc.Core_MDF_Ad_Run_Start_Date__c >= period.StartDate) &&
                       ( pfc.Core_MDF_Ad_Run_Start_Date__c <= period.EndDate ))
                    {
                        pfc.Core_MDF_Quarter_Year_txt__c = 'Q' + period.Number + '-' + period.FiscalYearSettings.Name;
                        break;
                    }                   
                }   
            }
        }
    }
    
    /*********************************************************************************************************************** 
Method Name:        updateQuarterYearFieldOnClaimUpdate
@return  :          void
@parameters:        List of input claims , Map of claims to be updated
Description:        This method is used to update Core_MDF_AdrunStartDate_QuarterNo_Year__c field when claim's start date
is updated
Added By:           Accenture - Pranav  - 18-Sep-2020
Modified By:        Date:       Changes: 
************************************************************************************************************************/
    
    public static void updateQuarterYearFieldOnClaimUpdate(List<PartnerFundClaim> claimList , Map<Id,PartnerFundClaim> oldClaimMap)
    {
        // Variables to store Latest and Oldest Claim's AdrunStart date
        Date oldestAdRunStartDate; 
        Date latestAdRunStartDate;
        //ATHR - Deeply Nested if 16209
        if(claimList == NULL || claimList.isEmpty()){
            return;
        }
        //if(claimList != NULL && !claimList.isEmpty()){
            
            // Assigning oldestAdRunStartDate and latestAdRunStartDate with very first claim's Ad run Start date 
            oldestAdRunStartDate = claimList[0].Core_MDF_Ad_Run_Start_Date__c;
            latestAdRunStartDate = claimList[0].Core_MDF_Ad_Run_Start_Date__c;
            
            // Fetching Oldest and latest Adrun start Date from list of claims
            for(PartnerFundClaim claim : claimList){
                if(claim.Core_MDF_Ad_Run_Start_Date__c < oldestAdRunStartDate){ oldestAdRunStartDate = claim.Core_MDF_Ad_Run_Start_Date__c;
                                                                              }
                if(claim.Core_MDF_Ad_Run_Start_Date__c > latestAdRunStartDate){ latestAdRunStartDate = claim.Core_MDF_Ad_Run_Start_Date__c;
                                                                              }
            }
            
            // get all the Custom fiscal Quarter and respective years between Oldest and latest Ad run Start date
            List<Period> periodList = [SELECT FiscalYearSettings.Name, Number, StartDate, EndDate FROM Period where FiscalYearSettings.YearType = 'Custom' And Type = 'Quarter' And StartDate <=: latestAdRunStartDate and endDate >=: oldestAdRunStartDate];      
            for (PartnerFundClaim pfc : claimList)
            {
                // Check if claim's start date field is updated then only update the quarter field
                //ATHR - Deeply Nested if 16209
                if(oldClaimMap == null || pfc.Core_MDF_Ad_Run_Start_Date__c == oldClaimMap.get(pfc.Id).Core_MDF_Ad_Run_Start_Date__c){
                    continue;
                }
                //if(oldClaimMap != NULL && pfc.Core_MDF_Ad_Run_Start_Date__c != oldClaimMap.get(pfc.Id).Core_MDF_Ad_Run_Start_Date__c )
                //{
                    for(Period period: periodList){
                        // Check if claim start date is within the quarter
                        if((pfc.Core_MDF_Ad_Run_Start_Date__c >= period.StartDate) && ( pfc.Core_MDF_Ad_Run_Start_Date__c <= period.EndDate ))
                        {
                            pfc.Core_MDF_Quarter_Year_Txt__c = 'Q' + period.Number + '-' + period.FiscalYearSettings.Name; break;
                        }                   
                    }   
                //}
            }
        //}
    }
    
    /*********************************************************************************************************************** 
Method Name:        isClaimEligibleForBankDocHold
@return  :          void
@parameters:        List of input claims 
Description:        This method is used to update Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c field on the basis of
Claim's ultimate Account Country and Claim's program                        
Added By:           Accenture - Pranav  - -5-Feb-2021
Modified By:        Date:       Changes: 
************************************************************************************************************************/
    
    public static void isClaimEligibleForBankDocHold(List<PartnerFundClaim> claimList){
        
        Map<String, List<String>> channelProgramToCountriesMap = new Map<String, List<String>>();
        //Set of bank Ids
        Set<ID> setOfBankIds = new Set<ID>();
        //BankMap to get bankcountry
        Map<Id,Core_MDF_Bank__c> bankMap = new Map<Id,Core_MDF_Bank__c>();
        
        // List of Budget Types for Which Bank Document Hold Indicator wont be set
        List<String> ignoreBankDocHoldBudgetTypeList = new List<String>();
        Core_MDF_Configuration__c budgetTypes = Core_MDF_Configuration__c.getValues('BUDGET_TYPE_SKIP_BANK_DOC_HOLD');
        if(budgetTypes != null){
            ignoreBankDocHoldBudgetTypeList = budgetTypes.Core_MDF_Value__c.split(';');
        }
        
        for(PartnerFundClaim pfc: claimList){
            if(pfc.Core_MDF_Bank__c!=null){
                setOfBankIds.add(pfc.Core_MDF_Bank__c);
            }
        }
        if(Core_MDF_PFC_HoldCheck.bankIdTobankInstance!=null && !Core_MDF_PFC_HoldCheck.bankIdTobankInstance.isEmpty()){
            bankMap = Core_MDF_PFC_HoldCheck.bankIdTobankInstance;        
        }else if(setOfBankIds != Null && setOfBankIds.size()>0){
            bankMap = new Map<ID,Core_MDF_Bank__c>([SELECT ID,Core_MDF_Bank_Status__c,Core_MDF_Bank_Location__c,Core_MDF_ESD_Hold_Indicator__c,Core_MDF_Hold_Payments_from_AP_file_ind__c FROM Core_MDF_Bank__c WHERE ID IN:setOfBankIds]);
        } 
        //ATHR - Deeply Nested if 16209
        if(bankMap==null || bankMap.isEmpty()){
            return;
        }
        //if(bankMap!=null && !bankMap.isEmpty()){
            // Querying Channel Program Metadata and Creating map of Channel Program and the countries for which Claims need to go to bank doc hold
            for(Core_MDF_ChannelProgram__mdt cp : [Select Core_MDF_Technical_Program_Name__c,Core_MDF_BankDocHold_Countries_Required__c FROM Core_MDF_ChannelProgram__mdt WHERE Core_MDF_BankDocHold_Countries_Required__c != null]){
                
                List<String> listOfCountries = new List<String>();
                listOfCountries = cp.Core_MDF_BankDocHold_Countries_Required__c.split(';');
                channelProgramToCountriesMap.put(cp.Core_MDF_Technical_Program_Name__c, listOfCountries);
            }
            
            // Seting Bank Doc hold Eligiblity indicator for the eligible claims after checking program and ultimate account's country
            for(PartnerFundClaim pfc : claimList){
                
                // Skip the logic - For Adjustments Or Budget Type = null Or any budget type for which Bank doc hold needs to be skipped
                if(Core_MDF_Claim_Utility.isType(pfc, isclaimAdjustmentType ) || pfc.Core_MDF_Budget_Type_Options_Nm__c == null ||
                   (pfc.Core_MDF_Budget_Type_Options_Nm__c != null && ignoreBankDocHoldBudgetTypeList.contains(pfc.Core_MDF_Budget_Type_Options_Nm__c))){continue;}
                //ATHR - Deeply Nested if 16209
                if(pfrInstance == null || pfrInstance.isEmpty() || pfrInstance.get(pfc.requestId) == null || !pfrInstance.containsKey(pfc.requestId)){
                    continue;
                }
                //if(pfrInstance != null && pfrInstance.size()>0 && pfrInstance.containsKey(pfc.requestId)){
                    
                    if(pfc.Core_MDF_Bank__c!=null && bankMap.containsKey(pfc.Core_MDF_Bank__c) && bankMap.get(pfc.Core_MDF_Bank__c).Core_MDF_Bank_Location__c !=null){
                        //Getting bank country
                        String bankCountry = bankMap.get(pfc.Core_MDF_Bank__c).Core_MDF_Bank_Location__c.toUpperCase();
                        
                        // Get Ultimate Account's Channel Program
                        String channelProgram = pfrInstance.get(pfc.requestId).channelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
                        
                        if(channelProgramToCountriesMap != null && channelProgramToCountriesMap.size()>0 && bankCountry != null && channelProgram != null && channelProgramToCountriesMap.containsKey(channelProgram))
                        {
                            //   if(channelProgramToCountriesMap.get(channelProgram).contains(accCountry)){
                            if(channelProgramToCountriesMap.get(channelProgram).contains(bankCountry)){pfc.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = true;}          
                        }
                    }
                //}
            }
        //}
    }
    /*********************************************************************************************************************** 
Method Name:        isClaimEligibleForBankDocOnBankChange
@return  :          void
@parameters:        newClaimMap, oldClaimMap 
Description:        This method is used to update Core_MDF_Bank_Doc_Hold_Ind__c field on the basis of Bank change.                                                
Added By:           Accenture 
Modified By:        Date:       Changes: 
************************************************************************************************************************/
    public static void isClaimEligibleForBankDocOnBankChange(Map<Id,PartnerFundClaim> newclaimMap,Map<Id,PartnerFundClaim> oldClaimMap){ 
        //Set of bank Ids
        Set<ID> bankIDs = new Set<ID>();
        //Map<String, List<String>> channelProgramToCountriesMap = new Map<String, List<String>>();
        List<PartnerFundClaim> listOfClaims = new List<PartnerFundClaim>();
        //BankMap to get bankcountry
        Map<Id,Core_MDF_Bank__c> bankMap = new Map<Id,Core_MDF_Bank__c>();
        
        // List of Budget Types for Which Bank Document Hold Indicator wont be set
        List<String> ignoreBankDocHoldBudgetTypeList = new List<String>();
        Core_MDF_Configuration__c budgetTypes = Core_MDF_Configuration__c.getValues('BUDGET_TYPE_SKIP_BANK_DOC_HOLD');
        if(budgetTypes != null){
            ignoreBankDocHoldBudgetTypeList = budgetTypes.Core_MDF_Value__c.split(';');
        }
        
        for(PartnerFundClaim pfc: newclaimMap.values()){
            if(pfc.Core_MDF_Bank__c!=null){
                bankIDs.add(pfc.Core_MDF_Bank__c);
            }
        }
        if(Core_MDF_PFC_HoldCheck.bankIdTobankInstance!=null && !Core_MDF_PFC_HoldCheck.bankIdTobankInstance.isEmpty()){
            bankMap = Core_MDF_PFC_HoldCheck.bankIdTobankInstance;        
        }else if(bankIDs != Null && bankIDs.size()>0){
            bankMap = new Map<ID,Core_MDF_Bank__c>([SELECT ID,Core_MDF_Bank_Status__c,Core_MDF_Bank_Location__c,Core_MDF_ESD_Hold_Indicator__c,Core_MDF_Hold_Payments_from_AP_file_ind__c FROM Core_MDF_Bank__c WHERE ID IN:bankIDs]);
        }
        //ATHR - Deeply Nested if 16209
        if(bankMap==null || bankMap.isEmpty()){
            return;
        }
        //if(bankMap!=null && !bankMap.isEmpty()){
            // Querying Channel Program Metadata and Creating map of Channel Program and the countries for which Claims need to go to bank doc hold
            for(Core_MDF_ChannelProgram__mdt cp : [Select Core_MDF_Technical_Program_Name__c,Core_MDF_BankDocHold_Countries_Required__c FROM Core_MDF_ChannelProgram__mdt WHERE Core_MDF_BankDocHold_Countries_Required__c != null]){
                
                List<String> listOfCountries = new List<String>();
                listOfCountries = cp.Core_MDF_BankDocHold_Countries_Required__c.split(';');
                channelProgramToCountriesMap.put(cp.Core_MDF_Technical_Program_Name__c, listOfCountries);
            }
            for(PartnerFundClaim pfc: newclaimMap.values()){
                if(Core_MDF_Claim_Utility.isType(pfc, isclaimAdjustmentType ) || pfc.Core_MDF_Budget_Type_Options_Nm__c == null ||
                   (pfc.Core_MDF_Budget_Type_Options_Nm__c != null && ignoreBankDocHoldBudgetTypeList.contains(pfc.Core_MDF_Budget_Type_Options_Nm__c))){continue;}
                //ATHR - Deeply Nested if 16209
                if(pfc.Core_MDF_Bank__c == null || bankMap.get(pfc.Core_MDF_Bank__c) == null || !bankMap.containsKey(pfc.Core_MDF_Bank__c) || bankMap.get(pfc.Core_MDF_Bank__c).Core_MDF_Bank_Location__c == null){
                    continue;
                }
                //if(pfc.Core_MDF_Bank__c!=null && bankMap.containsKey(pfc.Core_MDF_Bank__c) && bankMap.get(pfc.Core_MDF_Bank__c).Core_MDF_Bank_Location__c !=null){
                    //Getting bank country
                    String bankCountry = bankMap.get(pfc.Core_MDF_Bank__c).Core_MDF_Bank_Location__c.toUpperCase();
                    
                    // Get Ultimate Account's Channel Program
                    String channelProgram = pfc.Core_MDF_Program__c;
                    //ATHR - Deeply Nested if 16209
                    if(channelProgramToCountriesMap == null || channelProgramToCountriesMap.isEmpty() || channelProgramToCountriesMap.get(channelProgram) == null || !channelProgramToCountriesMap.containsKey(channelProgram) || bankCountry == null || channelProgram == null){
                        continue;
                    }
                    //if(channelProgramToCountriesMap != null && channelProgramToCountriesMap.size()>0 && bankCountry != null && channelProgram != null && channelProgramToCountriesMap.containsKey(channelProgram))
                    //{

                        //   if(channelProgramToCountriesMap.get(channelProgram).contains(accCountry)){
                        if(channelProgramToCountriesMap.get(channelProgram).contains(bankCountry)){   
                            //ATHR - Deeply Nested if 16209
                            //if(!pfc.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c){pfc.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = true; } 
                            pfc.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = true; //19451 Prod Defect fix
                            
                        }else{
                            //if(pfc.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c){pfc.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = false;}
                            pfc.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = false; //19451 Prod Defect fix
                            if(pfc.Core_MDF_Bank_Doc_Hold_Ind__c && pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold')){listOfClaims.add(pfc);}
                            
                        }          
                    //}
                //} 
            }
            if(listOfClaims != Null && listOfClaims.size()>0){processReleaseHold(listOfClaims,new List<string>{Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bank_Document_Hold')});}
        //}
    }
    
    
    /*********************************************************************************************************************** 
Method Name:        isClaimEligibleForBankDocOnAmtChange
@return  :          void
@parameters:        newClaimMap, oldClaimMap 
Description:        This method is used to update Core_MDF_Bank_Doc_Hold_Ind__c field on the basis of Amount change.                                                
Added By:           Accenture - HP  - -12-Feb-2021
Modified By:        Date:       Changes: 
************************************************************************************************************************/
    public static void isClaimEligibleForBankDocOnAmtChange(Map<Id,PartnerFundClaim> newclaimMap,Map<Id,PartnerFundClaim> oldClaimMap){ 
        
        
        for(PartnerFundClaim newClaim: newclaimMap.values()){
            if(Core_MDF_Claim_Utility.isType(newClaim, isclaimAdjustmentType)){continue;}
            if(newClaim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c && !newClaim.Core_MDF_Bank_Doc_Hold_Ind__c){
                
                if(((newClaim.Core_MDF_Total_Invoice_Amount_Local__c!=null && newClaim.Core_MDF_Total_Invoice_Amount_Local__c != oldClaimMap.get(newClaim.Id).Core_MDF_Total_Invoice_Amount_Local__c) 
                    ||(newClaim.Core_MDF_Audit_Adjustment_Amount__c!=null && newClaim.Core_MDF_Audit_Adjustment_Amount__c != oldClaimMap.get(newClaim.Id).Core_MDF_Audit_Adjustment_Amount__c)
                    ||(newClaim.Core_MDF_Currency__c != oldClaimMap.get(newClaim.Id).Core_MDF_Currency__c)
                    ||((newClaim.Core_MDF_Bank__c!=null && newClaim.Core_MDF_Bank__c != oldClaimMap.get(newClaim.Id).Core_MDF_Bank__c) 
                       && (channelProgramToCountriesMap.size()>0 && channelProgramToCountriesMap.containsKey(newClaim.Core_MDF_Program__c) && !channelProgramToCountriesMap.get(newClaim.Core_MDF_Program__c).contains(oldClaimMap.get(newClaim.Id).Core_MDF_Bank__r.Core_MDF_Bank_Location__c))))
                   && newClaim.Core_MDF_Status__c!='Denied' && newClaim.Core_MDF_Status__c!='Cancelled' && newclaim.Core_MDF_PIC_Review_Completed__c){ 
                       
                       newClaim.Core_MDF_Bank_Doc_Hold_Ind__c = true;
                       newClaim.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold');                       
                   }
            }
        }
    }
    
    /***************************************************************************************************** 
Method Name:        updatePaymentAdminReminderDate
@return  :          void
@parameters:        newClaimList and oldClaimMap
Description:        This method is used to update the PaymentAdminReminderDate for bank doc hold on claims by adding number of business days to it
and also it will update Core_MDF_FlaggedForBankDocHold_Ind__c to true when it bank document hold is true
Added By:           Accenture - TS Date : 9-FEB-2021
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static void updatePaymentAdminReminderDate(List<PartnerFundClaim> newClaimList, Map<Id,PartnerFundClaim> oldClaimMap){ 
        List<PartnerFundClaim> claimsToBeProcessed = new List<PartnerFundClaim>();
        Set<String> setOfAllowedProg = new Set<String>();
        Integer numOfDays =3; 
        //Retrieve allowed programs eligible for russian payments
        List<String> programs = Core_MDF_Configuration__c.getValues('ALLOWED_PRG_FOR_RUS_NOTIF').Core_MDF_Value__c.split(',');
        if(programs!=null && programs.size()>0){
            setOfAllowedProg.addAll(programs);
        }
        for(PartnerFundClaim pfc : newClaimList){
            //check if Bank Document Hold is set to true
            if(setOfAllowedProg.contains(pfc.Core_MDF_Program__c) && pfc.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold') && (pfc.Core_MDF_Bank_Doc_Hold_Ind__c &&((oldClaimMap==null) || (!oldClaimMap.get(pfc.id).Core_MDF_Bank_Doc_Hold_Ind__c) || (oldClaimMap.get(pfc.id).Core_MDF_Bank_Doc_Hold_Ind__c && oldClaimMap.get(pfc.id).Core_MDF_Audit_Hold__c && !pfc.Core_MDF_Audit_Hold__c)))){
                //Getting number of days to be added for current datefrom Configuration custom setting
                numOfDays = Integer.valueOf(Core_MDF_Configuration__c.getValues('ADD_BUS_DAYS_ON_REMINDER_DATE_CLAIM').Core_MDF_Value__c);
                pfc.Core_MDF_Payment_Admin_Reminder_Date_Dtm__c = Core_MDF_PFC_VAT_ServiceHandler.addBusinessDays(system.today(),numOfDays);
                // Updating below field to true
                pfc.Core_MDF_FlaggedForBankDocHold_Ind__c = true;
            }
        }
        
    }
    /*********************************************************************************************************************** 
Method Name:        getListOfUsersWithsObjTypeAccess
@return  :          Map<id,String> listOfUsersWithsObjReadAccess
@parameters:        userIds, sObjectType 
Description:        This is a generic method used to return listOfUsers along with specific sObjectType access                                              
Added By:           Accenture - TT -4-AUG-2021
Modified By:        Date:       Changes: 
************************************************************************************************************************/
    public static Map<Id,String> getListOfUsersWithsObjTypeAccess(List<Id> userIds,String sObjType){
        Map<Id,String> listOfUsersWithsObjReadAccess = new Map<Id,String>();
         //Jahnavi K -- Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
        for(PermissionSetAssignment permSetAssign :[Select PermissionSet.name,Assignee.Id From PermissionSetAssignment where Assignee.Id IN: userIds AND PermissionSetId IN (SELECT ParentId FROM ObjectPermissions where PermissionsRead = true AND SobjectType =: sObjType) AND (Assignee.isActive=true or Assignee.Partner_License_Reclaimed__c = true)]){
            listOfUsersWithsObjReadAccess.put(permSetAssign.Assignee.Id,permSetAssign.PermissionSet.name); 
        }
        return listOfUsersWithsObjReadAccess;
    }
    
    /*********************************************************************************************************************** 
Method Name:        updateClaimFieldsFromActivity
@return  :          void
@parameters:        List<PartnerFundClaim> claimList
Description:        This is a generic method used to copy Claim ActivitySubType field data with activity                                            
Added By:           Intel   -   Areefa  - 12 Nov,2021
Modified By:        Date:       Changes: 
************************************************************************************************************************/
    public static void updateClaimFieldsFromActivity(List<PartnerFundClaim> claimList,Map<Id,PartnerFundClaim> newclaimMap,Map<Id,PartnerFundClaim> oldClaimMap){ 
        
    
        // This set is required to store Requests
        Set<Id> requestIdWithActySubTypeReq = new Set<id>();
        List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
        List<string> validbudgetTypes = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_OPAL_BudgetTypes'); 
        List<string> oEMProgram = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_OEM_Program_Name'); 
        boolean pfrSelectReq =false;
        for(PartnerFundClaim newClaim: newclaimMap.values()){
            if(newClaim.Core_MDF_Activity_SubType_nm__c==null && oEMProgram.contains(newClaim.Core_MDF_Program__c) && validbudgetTypes.contains(newClaim.Core_MDF_Budget_Type_Options_Nm__c)){  // check prgm and budget type here only
                pfc.add(newClaim);
                requestIdWithActySubTypeReq.add(newClaim.RequestId);                
                if(pfrMap!= null && !pfrMap.containsKey(newClaim.RequestId)){
                    pfrSelectReq=true;
                }
            }
        }
        

        if(requestIdWithActySubTypeReq!=null && (pfrMap== null || pfrMap.isEmpty() || pfrSelectReq )){ 
           
            pfrMap = new Map<Id,PartnerFundRequest>([Select Core_MDF_Activity_Number__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_Budget_Type_nm__c from PartnerFundRequest 
                                                     where Id IN: requestIdWithActySubTypeReq]); 
           
        }      
        
        for(PartnerFundClaim newClaim : pfc){
            if(pfrMap.get(newClaim.RequestId).Core_MDF_Activity_SubType_nm__c!=null){
                newClaim.Core_MDF_Activity_SubType_nm__c = pfrMap.get(newClaim.RequestId).Core_MDF_Activity_SubType_nm__c;
            }   
        }
    } 
    /*********************************************************************************************************************** 
Method Name:        updateQueuedHoldEmailSent
@return  :          void
@parameters:        List<PartnerFundClaim> claimList
Description:        This is a generic method used to update the queued email sent flag to true                                            
Added By:           Accenture   -   21/march/2022
Modified By:        Date:       Changes: 
************************************************************************************************************************/   
    public static void updateQueuedHoldEmailSent(List<PartnerFundClaim> newClaimList){
        String queuedForHoldStatuses = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_QueuedForHold');
        Set<String> queuedForHoldStatusSet = new Set<String>(queuedForHoldStatuses.split(';'));
        for(PartnerFundClaim pfcRecord : newClaimList){
        if(!pfcRecord.Core_MDF_Queued_Email_Sent_Ind__c && queuedForHoldStatusSet.contains(pfcRecord.Core_MDF_Status__c) && (pfcRecord.Core_MDF_Intel_Manual_Hold_Ind__c || pfcRecord.Core_MDF_Member_Manual_Hold_Ind__c || pfcRecord.Core_MDF_ESD_Hold__c || pfcRecord.Core_MDF_Payment_Hold_ind__c || pfcRecord.Core_MDF_Criteria_Hold_Ind__c)){
            pfcRecord.Core_MDF_Queued_Email_Sent_Ind__c= true;
        }
        }
    }
/*********************************************************************************************************************** 
Method Name:        bypassCDBCalloutValidationCheck
@return  :          boolean
@parameters:        
Description:        This method used to check bypass validation logic for AI CDB Callout
Added By:           Accenture   -   04/Nov/2025
Modified By:        Date:       Changes: 
************************************************************************************************************************/ 

public static Boolean bypassCDBCalloutValidationCheck(String mainTriggerSwitch, String bypassTriggerSwitch)
{
    Trigger_Execution__mdt  mainSwitch = Trigger_Execution__mdt.getInstance(mainTriggerSwitch);
    // If main switch is not active bypass for everyone
    if ( mainSwitch != null && ! mainSwitch.Active__c) {
        return true;
    }
    
    if ( mainSwitch == null ||  mainSwitch.Active__c) {
        Core_Trigger_Executions__c bypassSwitch = Core_Trigger_Executions__c.getValues(bypassTriggerSwitch);
        // If bypass switch is false or null, we should make CDB call
        if (bypassSwitch == null || !bypassSwitch.Core_Active__c) {
            return false;
        }
        else if (bypassSwitch.Core_Active__c) {
            String validationBypassUsers = Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users')?.Core_MDF_Value_Txt__c;
            
            // If no users configured for bypass, don't bypass
            if (String.isBlank(validationBypassUsers)) {
                return false; // Don't bypass
            }
            
            List<String> validationBypassUsersList = validationBypassUsers.split(';');
            
            // If user is in the bypass list, we bypass by returing true
            // If user is NOT in the bypass list, we don't bypass - return false
            return validationBypassUsersList.contains(UserInfo.getUserName());
        }
    }
    
    // Default case - don't bypass
    return false;
}
/*********************************************************************************************************************** 
Method Name:        isClaimEligibleForAICDBCallout
@return  :          boolean
@parameters:        
Description:        This method used to check on claim's eligibility for the AI CDB Callout
Added By:           Accenture -VB  18/Nov/2025
Modified By:        Date:       Changes: 
************************************************************************************************************************/ 
public static Boolean isClaimEligibleForAICDBCallout(PartnerFundClaim claim) {
    List<String> aiPICEnabledPgms = Label.Core_MDF_AI_POP_Validation_EnabledPrograms.split(';');
    Boolean isClaimEligibleForCDBCallout = false;
    if(!claim.Core_MDF_OutcomeBased_Ind__c && aiPICEnabledPgms.contains(claim.Core_MDF_Program__c)  && claim.Core_MDF_Budget_Type_Nm__c !=  Label.Core_MDF_Retail_RSAMD_UnTranslated && claim.CreatedDate > Date.valueOf(Label.Core_MDF_DateToEnableAIPIC) && 
    claim.Core_MDF_Status__c == label.Core_MDF_Claim_Status_PIC_Pending) {
        isClaimEligibleForCDBCallout = true;
    } else {
        isClaimEligibleForCDBCallout = false;
    }
    return isClaimEligibleForCDBCallout;
}
}