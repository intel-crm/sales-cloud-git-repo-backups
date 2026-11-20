/******************************************************************************************************
* Class Name  : Core_MDF_InactivateAccount 
* Version     : 1.0 
* Created Date: 03-26-2019
* Modification Log :
* Developer           Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - VS     03-26-2019          Controller class to check if the account is eligible for inactivation
*******************************************************************************************************/

public without sharing class Core_MDF_InactivateAccount {
    
    /****************************************************************************************************** 
Class Name:         AccountInactivationWrapper
@parameters:        N/A
Description:        Wrapper which will hold return values of all the validation check to inactivate account
Added By: VS        Accenture - 03-26-2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    public class AccountInactivationWrapper{    
        @AuraEnabled
        public Boolean isTopVirtualNode=false;
        @AuraEnabled
        public Boolean isDeactivated=false;
        @AuraEnabled
        public Boolean isAutoTransferAccount=false;
        @AuraEnabled
        public Boolean hasAllocation=false;
        @AuraEnabled
        public Boolean hasActiveClaims=false;
        @AuraEnabled
        public Boolean hasBankmappings=false;
        @AuraEnabled
        public Boolean hasActivities=false;
        @AuraEnabled
        public Integer claimCount=0;
        @AuraEnabled
        public Integer activityCount=0;
        @AuraEnabled
        public Boolean hasOpenEscalationRecords=false;
        @AuraEnabled
        public Boolean hasCampaigns=false;
        @AuraEnabled
        public Integer campaignCount=0;
      
    }
    /****************************************************************************************************** 
Method Name:        isAccountEligibileForInactivation
@return  :          Wrapper which will hold the values of all the variables.
@parameters:        Account Id
Description:        This method will call other methods to check for different validations
Added By: VD        Accenture - 01/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public  static AccountInactivationWrapper isAccountEligibileForInactivation ( Id accId ){
        //Creating Wrapper class instance
        AccountInactivationWrapper acctWrap  = new AccountInactivationWrapper();
        AccountInactivationWrapper claimAcctWrap = new AccountInactivationWrapper();
        AccountInactivationWrapper activitiesAcctWrap = new AccountInactivationWrapper();
        AccountInactivationWrapper campAcctWrap = new AccountInactivationWrapper();
        
        try{
            //Created Account instance to update account fields.
            Account accVar =  [SELECT Core_MDF_Active_Ind__c, Core_MDF_Parent_Fund_Account__r.RecordType.Developername FROM Account WHERE Core_MDF_Parent_Fund_Account__c!= null AND id =: accId LIMIT 1];
            
            if(accVar!=NULL){
                //Checking for different validations on Account
                acctWrap.isTopVirtualNode = isTopVirtualNode(accVar);
                if(!acctWrap.isTopVirtualNode){
                    acctWrap.isDeactivated = isDeactivatedAccount(accVar);
                    if(!acctWrap.isDeactivated){
                        acctWrap.isAutoTransferAccount = isAutoTransAcct(accVar);
                        acctWrap.hasAllocation = isAllocationAvailable(accVar);
                        acctWrap.hasBankmappings = hasAccntBankMappings(accVar);
                        
                        activitiesAcctWrap = isActivitiesAssociated(accVar);
                        acctWrap.hasActivities = activitiesAcctWrap.hasActivities;
                        acctWrap.activityCount = activitiesAcctWrap.activityCount;
                        
                        claimAcctWrap = isClaimsAssociated(accVar);
                        acctWrap.hasActiveClaims = claimAcctWrap.hasActiveClaims;
                        acctWrap.claimCount = claimAcctWrap.claimCount;                        
                        //For open Escalations
                        acctWrap.hasOpenEscalationRecords = hasOpenEscalations(accVar);

                        campAcctWrap = isCampaignsAssociated(accVar);
                        acctWrap.hasCampaigns = campAcctWrap.hasCampaigns;
                        acctWrap.campaignCount = campAcctWrap.campaignCount;  
                    }
                } 
            }
            //When account is valid for Inactivation, Account Active field will be updated
            if((!acctWrap.isTopVirtualNode) && (!acctWrap.isDeactivated) && (!acctWrap.isAutoTransferAccount) && (!acctWrap.hasAllocation) && (!acctWrap.hasActiveClaims) && (!acctWrap.hasActivities) && (!acctWrap.hasBankmappings) && (!acctWrap.hasOpenEscalationRecords) && (!acctWrap.hasCampaigns)){
                accVar.Core_MDF_Active_Ind__c = false;
                Database.update (accVar);
            }
            return acctWrap;  
        }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);
            return null;}
    }
    /****************************************************************************************************** 
Method Name:        isUserEligibiletoInactivate
@return  :          wrapper which will hold the values of all the validation checks.
@parameters:        N/A
Description:        This method is used to check if user has permission to deactivate account.
Added By: VD        Accenture - 01/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/  
    @AuraEnabled
    Public static Boolean isUserEligibiletoInactivate(){
        try {
            //Checking User permission from custom permission
            Boolean hasCustomPermission = FeatureManagement.checkPermission(Label.Core_MDF_Account_Inactivation_Deletion_Access);
            return hasCustomPermission;
        } 
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);
            return null;}
    } 
    /****************************************************************************************************** 
Method Name:        isTopVirtualNode
@return  :          wrapper which will hold the values of all the validation checks.
@parameters:        Account record
Description:        This method is used to check for top virtual account
Added By: VD        Accenture -  01/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    Public static Boolean isTopVirtualNode (Account accVar){
        try{
            //Check if account is top virtual account
            if(accVar.Core_MDF_Parent_Fund_Account__r.RecordType.Developername.equals(Label.Core_MDF_MasterAccount)){
                return TRUE;                    
            }
            return FALSE;
        }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);
            return null;}
    }
    /****************************************************************************************************** 
Method Name:        isDeactivatedAccount
@return  :          wrapper which will hold the values of all the validation checks.
@parameters:        Account record
Description:        This method is used to check if account is already deactivated.
Added By: VD        Accenture -  01/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/   
    @AuraEnabled
    Public static Boolean isDeactivatedAccount (Account acctVar){
        try{
            //Check if account is already deactivated.
            if (!acctVar.Core_MDF_Active_Ind__c){
                return TRUE;
            }
            return FALSE;
        }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);
            return null;}
    }
    /****************************************************************************************************** 
Method Name:        isAutoTransAcct 
@return  :          wrapper which will hold the values of all the validation checks.
@parameters:        Account record
Description:        This method is used to check if account is used as an auto transfer account
Added By: VD        Accenture - 01/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static Boolean isAutoTransAcct(Account accntVar){
        try{
            //Check if account is used as Auto Transfer account
            List<Account> autoTransAcctList = [SELECT Id FROM Account WHERE Core_MDF_Auto_Transfer_Account__c =: accntVar.Id AND Core_MDF_Auto_Transfer_Account__r.Core_MDF_Active_Ind__c = TRUE LIMIT 1];
            if( autoTransAcctList != NUll && autoTransAcctList.size()>0 ){
                return TRUE;
            }
            return FALSE;
        }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);
            return null;}
    }
    /****************************************************************************************************** 
Method Name:        isAllocationAvailable
@return  :          wrapper which will hold the values of all the validation checks.
@parameters:        Account record
Description:        This method is used to check allocations on the account.
Added By: VD        Accenture -  01/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/           
    @AuraEnabled 
    Public static Boolean isAllocationAvailable (Account acntVar){
        try{
            //List to Check if the account has any allocations
            List<PartnerFundAllocation> pfaList = [SELECT Id,Budget.Core_MDF_Program_Nm__c,Core_MDF_Budget_Type__c,Core_MDF_Available_Allocation_Amount__c,Core_MDF_Available_Activity_Alloc_Amt__c FROM PartnerFundAllocation WHERE channelpartnerid =:acntVar.Id];             
            list<String> progBudLst=new List<String>();
            Map<String,Boolean> isActivityAvailAmountBased = new Map<String,Boolean>();
            Boolean result=false;
            if ( pfaList !=Null &&  pfaList.size()>0 ){
                for(PartnerFundAllocation alloc:pfaList){
                    String prgBudTypeKey = alloc.Budget.Core_MDF_Program_Nm__c+':'+alloc.Core_MDF_Budget_Type__c;
                    if(prgBudTypeKey!=Null){
                        progBudLst.add(prgBudTypeKey);
                    }  
                }
            }
            if (progBudLst !=Null && progBudLst.size()>0){
                isActivityAvailAmountBased = Core_MDF_PMBServiceHandler.isActAvailAmtValidationReq(progBudLst);
            }
            if (pfaList !=Null && pfaList.size()>0){ 
                for(PartnerFundAllocation pfa:pfaList){
                    String uniqueKey = pfa.Budget.Core_MDF_Program_Nm__c+':'+pfa.Core_MDF_Budget_Type__c;
                    if((isActivityAvailAmountBased.containsKey(uniqueKey) && isActivityAvailAmountBased.get(uniqueKey) && pfa.Core_MDF_Available_Activity_Alloc_Amt__c > 0) ||
                       ((!isActivityAvailAmountBased.containsKey(uniqueKey)||(isActivityAvailAmountBased.containsKey(uniqueKey)&& !isActivityAvailAmountBased.get(uniqueKey))) && 
                        pfa.Core_MDF_Available_Allocation_Amount__c > 0)){
                           result=true;
                            break;
                        } 
                    else{
                        result=false;
                    }
                } 
            }
            return result;           
        }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);
        return null;}
    }
    /****************************************************************************************************** 
Method Name:        isClaimsAssociated
@return  :          wrapper which will hold the values of all the validation checks.
@parameters:        Account record
Description:        This method is used to check claims associated with this account which doesn't have end status.
Added By: VD        Accenture -  01/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    Public static AccountInactivationWrapper isClaimsAssociated (Account accontVar){
        try{
            AccountInactivationWrapper claimWrapper = new AccountInactivationWrapper ();
            
            //Fetch claim status from custom label
            Set<String> claimStatusSet = new Set<String>();
            String claimStatusList = System.label.Core_MDF_Claim_Status_For_Account_Inactive;
            if(!String.IsBlank(claimStatusList)){
                for(String claimStatus : claimStatusList.split(';')){
                    claimStatusSet.add(claimStatus);
                }
            }
            //List to store the claims which are in submitted, hold, pending available funds, payment due and pending payment status and bypassing negative claims
            List<PartnerFundClaim> claimList = [SELECT Id FROM PartnerFundClaim WHERE Core_MDF_Status__c  IN: claimStatusSet  AND ChannelPartner.Id =: accontVar.Id AND Core_MDF_Type_Txt__c!=:Label.Core_MDF_Claim_Adjustment_Type];       
            if (claimList != Null && claimList.size()>0){
                claimWrapper.hasActiveClaims = TRUE;
                claimWrapper.claimCount = claimList.size();
            }
            return claimWrapper;
        }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);
        return null;}  
    } 
    /****************************************************************************************************** 
Method Name:        isActivitiesAssociated
@return  :          wrapper which will hold the values of all the validation checks.
@parameters:        Account record
Description:        This method is used to check Activities associated with this account whose status are in Planned/In-Progress
Added By: VD        Accenture - 01/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    Public static AccountInactivationWrapper isActivitiesAssociated(Account acountVar){
        try{
            AccountInactivationWrapper activitiesWrap = new AccountInactivationWrapper();
            
            //Fetch partnerfundrequest status from custom label
            Set<String> pfrStatusSet = new Set<String>();
            String pfrStatusList = System.label.Core_MDF_Activity_Status_Check_for_Inactive_Account;
            if(!String.IsBlank(pfrStatusList)){
                for(String pfrStatus : pfrStatusList.split(';')){
                    pfrStatusSet.add(pfrStatus);
                }
            }
            //List to store activities which are in Planned, In-Progress or Pending Review status
            List<PartnerFundRequest> pfrList = [SELECT Id FROM PartnerFundRequest WHERE Core_MDF_Fund_Request_Status__c IN:pfrStatusSet AND ChannelPartnerId =:acountVar.Id];
            if (pfrList != Null && pfrList.size()>0 ){
                activitiesWrap.hasActivities = TRUE;
                activitiesWrap.activityCount = pfrList.size();
            }
            return activitiesWrap;
        }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);
        return null;} 
    }    
    /****************************************************************************************************** 
Method Name:        hasAccntBankMappings
@return  :          wrapper which will hold the values of all the validation checks.
@parameters:        Account record
Description:        This method is used to check account bank mapping record
Added By: VD        Accenture - 01/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    Public static Boolean hasAccntBankMappings(Account accountVar){
        Boolean hasBankMappingRecord = FALSE;
        try{
            //Fetch bank status from custom label
            Set<String> bankStatusSet = new Set<String>();
            String bankStatusList = System.label.Core_MDF_Claim_Bank_StatusList;
            if(!String.IsBlank(bankStatusList)){
                for(String bankStatus : bankStatusList.split(';')){
                    bankStatusSet.add(bankStatus);
                }
            }
            //List to store account bank mappings for the account 
            List<Core_MDF_Account_Bank_Mapping__c> accbankmapList = [SELECT Id FROM Core_MDF_Account_Bank_Mapping__c WHERE core_MDF_Bank__r.core_MDF_Bank_Status__c =:bankStatusSet AND Core_MDF_Account__c =:accountVar.Id AND Core_MDF_Active_ind__c=TRUE];
            if ( accbankmapList != Null && accbankmapList.size()>0 ){
                hasBankMappingRecord = TRUE;
            }
            return hasBankMappingRecord;
        }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);
        return null;}
    }
    
    /****************************************************************************************************** 
Method Name:        hasOpenEscalations
@return  :          boolean
@parameters:        Account record
Description:        This method is used to check open escalations
Added By: AD        Accenture - 01/31/2020
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    Public static Boolean hasOpenEscalations(Account accountVar) {
        Boolean hasOpenEscalationRecord = FALSE;
        try {
            Map < Id, Core_MDF_Escalation__c > mapOfOpenEsclations = new Map < Id, Core_MDF_Escalation__c > ([
                Select Id from Core_MDF_Escalation__c
                where ((RecordType.DeveloperName =: Label.Core_MDF_LateClaim_RecordType and Core_MDF_Co_Marketing_Activity_id__c != null and Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId =: accountVar.Id) OR
                       (RecordType.DeveloperName =: Label.Core_MDF_ClaimCaseReviewResult_RecordType  and Core_MDF_Case_ID_Number_id__c != null and Core_MDF_Case_ID_Number_id__r.AccountId =: accountVar.Id)) AND Core_MDF_Claim_Number_id__c = NULL AND Core_MDF_Escalation_Status_nm__c != : Label.Core_MDF_Exception_Cancelled_Status AND Core_MDF_Escalation_Status_nm__c != : Label.Core_MDF_Exception_Denied_Status
            ]);
            if(mapOfOpenEsclations!=null && mapOfOpenEsclations.size()>0){
                //open escalation
                return hasOpenEscalationRecord = TRUE;
            }
            return hasOpenEscalationRecord;
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return null;
        }
    }
        /****************************************************************************************************** 
Method Name:        isCampaignsAssociated
@return  :          wrapper which will hold the values of all the validation checks.
@parameters:        Account record
Description:        This method is used to check Campaign associated with this account whose status are in Planned/In-Progress
Added By: VD        Accenture - 01/04/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
@AuraEnabled
Public static AccountInactivationWrapper isCampaignsAssociated(Account acountVar){
    try{
        AccountInactivationWrapper campaignsWrap = new AccountInactivationWrapper();
        
        //Fetch campaign status from custom label
        Set<String> campStatusSet = new Set<String>();
        String campStatusList = System.label.Core_MDF_Campaign_Status_Check_for_Inactive_Account;
        if(!String.IsBlank(campStatusList)){
            for(String campStatus : campStatusList.split(';')){
                campStatusSet.add(campStatus);
            }
        }
        //List to store campaigns which are not in Completed,Cancelled status
        List<Campaign> cmpList = [SELECT Id FROM Campaign WHERE Status NOT  IN:campStatusSet AND Core_MDF_Account__c =:acountVar.Id];
        if (cmpList != Null && cmpList.size()>0 ){
            campaignsWrap.hasCampaigns = TRUE;
            campaignsWrap.campaignCount = cmpList.size();
        }
        return campaignsWrap;
    }
    catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);
     return null;} 
}  
}