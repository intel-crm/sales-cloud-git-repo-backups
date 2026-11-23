/****************************************************************************************************** 
Class Name:         Core_MDF_BankUtility
@parameters:        N/A
Description:        Utility Class for Bank & ABM to fetch Various metadata Records
Added By:           NZ   02-10-2020
Modified By:        Date:           Changes:

*******************************************************************************************************/
public without sharing class Core_MDF_BankUtility {
    /*************************************************
     * abc**************************************************** 
    Method Name	:       bankClaimMappingWrapper
    Added By	:       Accenture - NZ - 02/10/2020
    Modified By	:       Date:       Changes: 
    ******************************************************************************************************/
    public class BankClaimMappingWrapper
    {   
     	public Map<Id,Set<String>> bankIdProgramStrSetMap;
        public Set<String> bankIdAccountIdStringSet;
    }    
    /***************************************************************************************************** 
    Method Name	:       validateClaimAssociationWithABM
    @return  	:     	bankClaimMappingWrapper
    @parameters	:       Set<Id> eligibleBankSet - Set of Bank
						Set<String> eligibleBankProgramSet - Set of Program
						Set<Id> accountIdSet - Set of Account
    Description	:       Validate if Claim are assocaited with Bank or ABM and store info in Wrapper
    Added By	:       Accenture - NZ - 02/10/2020
    Modified By	:       Date:       Changes: 
    ******************************************************************************************************/
    public static Set<String> validateClaimAssociationWithABM(Set<Id> eligibleAccountIdSet, Set<Id> eligibleBankIdSet, Set<String> eligibleBankProgramSet){ 
        
        //Map key-- API name Value --> Label name of Program
        Map<String,String> programMap = new Map<String,String>();

        //Fetching the Program Mapping Metadata
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt programMapping : [SELECT Id, Core_MDF_Channel_Program_txt__c, Core_MDF_Channel_Program_Name_txt__c
                                                                        FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt]){
            programMap.put(programMapping.Core_MDF_Channel_Program_Name_txt__c, programMapping.Core_MDF_Channel_Program_txt__c);
        }

        //This will store a combination of Bank Id, Account Id and Program
        Set<String> bankIdAccountIdProgramStrSet = new Set<String>();
        
        //List to Store claim status on which bank sud not be de-actiated -- Submitted;Pending Available Fund;Payment Due;Hold
        List<String> claimStatusStrList = Label.Core_MDF_Claim_Status_for_Inactive_Bank.split(';');
        
        String claimBankAssociateQueryStr = '';     	
        String adjustmentClaimTypeStr = Label.Core_MDF_Claim_Adjustment_Type;
        //Build Query to fetch Claim
        /* claimBankAssociateQueryStr = 	'SELECT Id,Core_MDF_Status__c, Core_MDF_Bank__c, Core_MDF_Program__c,ChannelPartnerId ' +
                                    	'FROM PartnerFundClaim ' +
                                    	'WHERE Core_MDF_Bank__c IN : eligibleBankIdSet AND ' +
                                    	'Core_MDF_Status__c IN : claimStatusStrList AND ' + 
                                        'ChannelPartnerId IN :eligibleAccountIdSet AND ' +
                                        'Core_MDF_Type_Txt__c != :adjustmentClaimTypeStr AND ' +
                                   		'Core_MDF_Program__c IN : eligibleBankProgramSet '; */
        
        for(PartnerFundClaim pfc : [SELECT Id,Core_MDF_Status__c, Core_MDF_Bank__c, Core_MDF_Program__c,ChannelPartnerId 
                                    FROM PartnerFundClaim
                                    WHERE Core_MDF_Bank__c IN : eligibleBankIdSet AND
                                        Core_MDF_Status__c IN : claimStatusStrList AND
                                        ChannelPartnerId IN :eligibleAccountIdSet AND
                                        Core_MDF_Type_Txt__c != :adjustmentClaimTypeStr AND
                                        Core_MDF_Program__c IN : eligibleBankProgramSet]){
            String bankIdAccountIdProgramStr = (String)pfc.Core_MDF_Bank__c + pfc.ChannelPartnerId + pfc.Core_MDF_Program__c;          
            bankIdAccountIdProgramStrSet.add(bankIdAccountIdProgramStr);
        }
        
        return bankIdAccountIdProgramStrSet;    
    }
    /***************************************************************************************************** 
    Method Name:        fetchEscalationsForAccounts
    @return  :          void
    @parameters:        accountIdSet - Set of Account Id
    Description:        Check if any Escalations exist for Banks related to ABM in the oldABMMap
    Added By:           Accenture - SB - 21/02/2020
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static Set<Id> fetchEscalationsForAccounts(Set<Id> accountIdSet){
        Set<Id> accountIdWithEscalationSet = new Set<Id>();
        for(Core_MDF_Escalation__c escalationRecord: [SELECT Id, Core_MDF_Co_Marketing_Activity_id__c, RecordType.DeveloperName,
                                                                Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId, Core_MDF_Case_ID_Number_id__r.AccountId
                                                        FROM Core_MDF_Escalation__c
                                                        WHERE ((RecordType.DeveloperName =: Label.Core_MDF_LateClaim_RecordType AND //Core_MDF_Late_Claim
                                                            Core_MDF_Co_Marketing_Activity_id__c != NULL AND 
                                                            Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId != NULL AND
                                                            Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId IN :accountIdSet) OR
                                                            (RecordType.DeveloperName =: Label.Core_MDF_ClaimCaseReviewResult_RecordType  AND //Core_MDF_Claim_Case_Review_Result
                                                            Core_MDF_Case_ID_Number_id__c != NULL AND Core_MDF_Case_ID_Number_id__r.AccountId IN :accountIdSet)) AND 
                                                            Core_MDF_Claim_Number_id__c = NULL AND 
                                                            Core_MDF_Escalation_Status_nm__c != : Label.Core_MDF_Exception_Cancelled_Status AND Core_MDF_Escalation_Status_nm__c != : Label.Core_MDF_Exception_Denied_Status]){
            if(escalationRecord.RecordType.DeveloperName == Label.Core_MDF_ClaimCaseReviewResult_RecordType){accountIdWithEscalationSet.add(escalationRecord.Core_MDF_Case_ID_Number_id__r.AccountId);
            }
            else{
                accountIdWithEscalationSet.add(escalationRecord.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId);
            }
        }
        return accountIdWithEscalationSet;
    }

}