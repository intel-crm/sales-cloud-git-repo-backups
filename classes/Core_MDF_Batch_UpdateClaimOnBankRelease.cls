/***********************************************************************************************************************************
* Class Name  : Core_MDF_Batch_updateClaimOnBankRelease 
* Version     : 1.0    
* Created Date: 06-02-2021
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - NK      06/06/2021      This batch Updates Status and Hold indicators on Claims whenever related bank is released from Hold
*************************************************************************************************************************************/
public class Core_MDF_Batch_UpdateClaimOnBankRelease implements Database.Batchable<sObject> {
    public Map<Id,List<String>> bankIdToReasonList = new Map<Id,List<String>>();
    public Core_MDF_Batch_UpdateClaimOnBankRelease ( Map<Id,List<String>> bankIdToReasonList) {
        this.bankIdToReasonList = bankIdToReasonList;
    }
    public Database.QueryLocator start(Database.BatchableContext bContext) {   
        Set<Id> bankIds = bankIdToReasonList.keySet();
        String strQuery = '';
        strQuery = 'SELECT Id,Core_MDF_ESD_Hold__c,Core_MDF_Audit_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Criteria_Hold_Ind__c,'
            +'Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,'
            +'Core_MDF_VAT_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Bank__c,Core_MDF_Bank__r.Core_MDF_Bank_Status__c,Core_MDF_Bank__r.Core_MDF_Hold_Payments_from_AP_file_ind__c,'
            +'Core_MDF_Bank__r.Core_MDF_ESD_Hold_Indicator__c,Core_MDF_Document_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c, Core_MDF_Has_Sub_Claims_Ind__c FROM PartnerFundClaim where Core_MDF_Bank__c IN:bankIds '
            +'AND Core_MDF_Type_Txt__c=\'Claim\'';
        return Database.getQueryLocator(strQuery);         
    }
    
    public void execute(Database.BatchableContext bContext, List<PartnerFundClaim> claimList) {
        
        List<PartnerFundClaim> claimListForESDHold = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimListForAPHold = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimListForBankHold = new List<PartnerFundClaim>();

        List<PartnerFundClaim> claimsToUpdate = new List<PartnerFundClaim>();
        List<PartnerFundClaim> listOfClaimsToUpdate = new List<PartnerFundClaim>();
		Set<PartnerFundClaim> setClaimsToUpdate = new Set<PartnerFundClaim>();
        Map<String, Object> databaseResult = new map<String,Object>();
        Map<id,string> idAndUpdateStatus = new Map<id,string>();

       
        String logEntryMsg = '';
        try{
            if(claimList != null && claimList.size()>0){
                for(PartnerFundClaim claim : claimList){
					
                    //fetching banks with esd hold
                    if(bankIdToReasonList.get(claim.Core_MDF_Bank__c).contains(Label.Core_MDF_ESD_Hold)){
                        claimListForESDHold.add(claim);
                    }
                    //fetching banks with payment hold
                    if(bankIdToReasonList.get(claim.Core_MDF_Bank__c).contains(Label.Core_MDF_Payment_Hold)){
                        claimListForAPHold.add(claim);
                    }
                    
                    if(bankIdToReasonList.get(claim.Core_MDF_Bank__c).contains(Label.Core_MDF_Bank_Document_Hold)){
                        claim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = claim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c?false:claim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c;
                        claimListForBankHold.add(claim);
                    }
                }
                if(claimListForESDHold != Null && claimListForESDHold.size()>0){
                    //claimListForESDHold.addAll(claimSetForESDHold);
                    Core_MDF_Claim_Utility.processReleaseHold(claimListForESDHold,new List<string>{Label.Core_MDF_ESD_Hold});
                    ClaimsToUpdate.addAll(claimListForESDHold);
                }
                if(claimListForAPHold != Null && claimListForAPHold.size()>0){
                    //claimListForAPHold.addAll(claimSetForAPHold);
                    Core_MDF_Claim_Utility.processReleaseHold(claimListForAPHold,new List<string>{Label.Core_MDF_Payment_Hold});
                    ClaimsToUpdate.addAll(claimListForAPHold);
                }
                if(claimListForBankHold != Null && claimListForBankHold.size()>0){
                    //claimListForBankHold.addAll(claimSetForBankHold);
                    Core_MDF_Claim_Utility.processReleaseHold(claimListForBankHold,new List<string>{Label.Core_MDF_Bank_Document_Hold});
                    ClaimsToUpdate.addAll(claimListForBankHold);
                }
				
				if(ClaimsToUpdate!=null && ClaimsToUpdate.size()>0){	
					setclaimsToUpdate.addALL(ClaimsToUpdate);
				}
                if(setclaimsToUpdate != Null && setclaimsToUpdate.size()>0){
                    listOfClaimsToUpdate.addAll(setclaimsToUpdate);
                    databaseResult = Core_MDF_CCP_UtilityClass.updateListAndLogErrors(listOfClaimsToUpdate, 'claims hold failed');
                    idAndUpdateStatus = (Map<id,string>) databaseResult.get('DatabaseResult');
                    logEntryMsg = (string)databaseResult.get('ErrorMessage');
                }
            }
        }catch (Exception exce) {
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(exce);
           
        }
        finally
        {           
            if( logEntryMsg!=Null && logEntryMsg!='')
            {
                Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Core_MDF_Batch_UpdateClaimOnBankRelease');
            }
        } 
    }
    public void finish(Database.BatchableContext bContext) {
        
    }
}