/***********************************************************************************************************************************
* Class Name  : Core_MDF_Batch_updateClaimOnBankHold 
* Version     : 1.0    
* Created Date: 05-27-2021
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - NK      05/27/2021      This batch Updates Status and Hold indicators on Claims whenever related bank is put on Hold
*************************************************************************************************************************************/
public class Core_MDF_Batch_UpdateClaimOnBankHold implements Database.Batchable<sObject> {
    public Map<Id,List<String>> bankIdToReasonList = new Map<Id,List<String>>();
    public Core_MDF_Batch_UpdateClaimOnBankHold (Map<Id,List<String>> bankIdToReasonList) {
        this.bankIdToReasonList = bankIdToReasonList;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bContext) {   
        Set<Id> bankIds = bankIdToReasonList.keySet();
        Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('CLAIM_STATUS_FOR_BANK_HOLD');  //Pending Available Fund,Payment Due,Hold,PIC Pending,Resubmission Required,Pending Documents
        List<String> claimStatusList = new List<String>();
        claimStatusList = config.Core_MDF_Value__c.split(',');
        // querying claims with type as Claim and status as Pending Available fund/Hold/Payment Due
        String strQuery = '';
        strQuery = 'SELECT Id,Core_MDF_Bank__r.Core_MDF_Bank_Status__c,Core_MDF_PIC_Review_Completed__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Bank__r.Core_MDF_Hold_Payments_from_AP_file_ind__c,Core_MDF_Bank__r.Core_MDF_ESD_Hold_Indicator__c,Core_MDF_Program__c,Core_MDF_Claim_Approval_Dt__c,Core_MDF_Approval_Step_Counter_nbr__c FROM PartnerFundClaim where Core_MDF_Bank__c IN:bankIds '
            +'AND Core_MDF_Type_Txt__c=\'Claim\' AND  Core_MDF_Status__c IN: claimStatusList'; // Ajinkya Added

        system.debug('strQuery@@@' + strQuery);
        return Database.getQueryLocator(strQuery);     
        
    }
    
    public void execute(Database.BatchableContext bContext, List<PartnerFundClaim> claimList) {
        List<PartnerFundClaim> claimsToUpdate = new List<PartnerFundClaim>();
        Map<String, Object> databaseResult = new map<String,Object>();
        Map<id,string> idAndUpdateStatus = new Map<id,string>();
        
        List<String> ignoreBankDocHoldBudgetTypeList = new List<String>();
        Core_MDF_Configuration__c budgetTypes = Core_MDF_Configuration__c.getValues('BUDGET_TYPE_SKIP_BANK_DOC_HOLD');  //RSA MD
        if(budgetTypes != null){
            ignoreBankDocHoldBudgetTypeList = budgetTypes.Core_MDF_Value__c.split(';');
        }
        
        String logEntryMsg = '';
        try{
            system.debug('claimList@@@' + claimList);
            for(PartnerFundClaim claim:claimList) {
               
                if(claim.Core_MDF_Bank__c!=null && bankIdToReasonList.containsKey(claim.Core_MDF_Bank__c) && bankIdToReasonList.get(claim.Core_MDF_Bank__c).contains(Label.Core_MDF_Bank_Document_Hold) 
                   && !ignoreBankDocHoldBudgetTypeList.contains(claim.Core_MDF_Budget_Type_Options_Nm__c)){
                       
                        claim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = true;  
                        if(claim.Core_MDF_PIC_Review_Completed__c || (claim.Core_MDF_Claim_Approval_Dt__c != null && claim.Core_MDF_Approval_Step_Counter_nbr__c == 0)){ //Ajinkya Added
                            claim.Core_MDF_Bank_Doc_Hold_Ind__c = true;
                            claim.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold');

                        }
                }
                if(claim.Core_MDF_Bank__r.Core_MDF_ESD_Hold_Indicator__c == True){
                    claim.Core_MDF_ESD_Hold__c = true;
                    if(claim.Core_MDF_PIC_Review_Completed__c || (claim.Core_MDF_Claim_Approval_Dt__c != null && claim.Core_MDF_Approval_Step_Counter_nbr__c == 0)){ //Ajinkya Added
                        claim.Core_MDF_Status__c = 'Hold';
                    }
                }
                if(claim.Core_MDF_Bank__r.Core_MDF_Hold_Payments_from_AP_file_ind__c == 'Yes'){
                    claim.Core_MDF_Payment_Hold_ind__c = true;
                    if(claim.Core_MDF_PIC_Review_Completed__c || (claim.Core_MDF_Claim_Approval_Dt__c != null && claim.Core_MDF_Approval_Step_Counter_nbr__c == 0)){ //Ajinkya Added
                        claim.Core_MDF_Status__c = 'Hold';
                    }
                }
                
                claimsToUpdate.add(claim);

            }
            if(claimsToUpdate != Null && claimsToUpdate.size() > 0) {
                databaseResult = Core_MDF_CCP_UtilityClass.updateListAndLogErrors(claimsToUpdate, 'claims hold failed');
                idAndUpdateStatus = (Map<id,string>) databaseResult.get('DatabaseResult');
                logEntryMsg = (string)databaseResult.get('ErrorMessage');
            }
            
        } catch (Exception exce) {logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(exce);}
        finally
        {           
            if(logEntryMsg!=Null && logEntryMsg!=''){Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Core_MDF_Batch_UpdateClaimOnBankHold');}
        }  
    }
    public void finish(Database.BatchableContext bContext) {
        
    }
}