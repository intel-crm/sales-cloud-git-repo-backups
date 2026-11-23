/****************************************************************************************************************************************
* Class Name  : Core_MDF_Claim_VAT_Process 
* Version     : 1.0   
* Created Date: 7 Oct,2020
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Areefa         7 Oct,2020                 Created Core_MDF_Claim_VAT_Process for VAT process 
*                                                   Testclass coverage : Core_MDF_PFC_VAT_Test
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Claim_VAT_Process { 
    public static Map<Id,Core_MDF_Bank__c> claimIdBankMap;
    private static string nonTranslateYes =Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NonTranslateYes');
    public static string bankLE420 = Core_MDF_CCP_ConstantClass.Bank_LE420;
    public static string bankLE650 = Core_MDF_CCP_ConstantClass.Bank_LE650;
    /***************************************************************************************************** 
Method Name:        isClaimEligibleForVAT 
@return  :          void 
@parameters:        
Description:        This method is used to Enable the VAT Eligibility indicator of based on VAT criteria
Added By:           Intel       Areefa              7 Oct,2020
Modified By:        Date:       Changes:
Intel       Sarah               14 Oct,2020     added key check
Intel       Areefa              15 Nov,2020     Bulkified this method
******************************************************************************************************/
    public static void isClaimEligibleForVAT(List<PartnerFundClaim> inputClaims){
        //Set<String> vatEligiblePgms = new Set<String>();
        List<PartnerFundClaim> claimEligibleForVATProcessing = new List<PartnerFundClaim>();
        string isclaimAdjustmentType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Adjustment_Type');

        for(PartnerFundClaim pfc : inputClaims)
        {    
            if(pfc.Core_MDF_VAT_Opt_In__c == Label.Core_MDF_nonTranslate_Service_Invoice_to_Intel) //Areefa: if VAt optin=true & PIC review completed,than start VAT process && pfc.Core_MDF_PIC_Review_Completed__c
            {
                pfc.Core_MDF_VAT_Eligibility_Ind__c=true;
                
                //When STP=true or if it is postive Adj/claim case review result postive type Adj claim and adjustment claim we need to starte VAT Process
                if(Core_MDF_Claim_Utility.isType(pfc, isclaimAdjustmentType)){
                    claimEligibleForVATProcessing.add(pfc);
                }                
            }
            else{
                pfc.Core_MDF_VAT_Eligibility_Ind__c=false;
            }            
        }
        if(claimEligibleForVATProcessing !=null && claimEligibleForVATProcessing.size()>0){
            updateclaimVATInfo(claimEligibleForVATProcessing);            
        }
    }
    /***************************************************************************************************** 
Method Name:        updateclaimVATInfo 
@return  :          void 
@parameters:        
Description:        This method is used to update claim status and VAT hold indecator field on claim
Added By:           Intel       Areefa              7 Oct,2020
Modified By:        Date:       Changes:
Intel       Areefa              15 Nov,2020
******************************************************************************************************/
    public static List<PartnerFundClaim> updateclaimVATInfo(List<PartnerFundClaim> claimList){

        Set<ID> bankIds = new Set<ID>();
        List<PartnerFundClaim> vatEligibleClaimlist = new List<PartnerFundClaim>();
        
        for(PartnerFundClaim pfc: claimList){
            bankIds.add(pfc.Core_MDF_Bank__c);
        }
        // getting VAT% from Static map
        claimIdBankMap = Core_MDF_PFC_HoldCheck.bankIdTobankInstance;
        if(claimIdBankMap== null || claimIdBankMap.isEmpty()) 
        {   
         claimIdBankMap = new Map<Id,Core_MDF_Bank__c>([Select Id,Core_MDF_VAT_pct__c,Core_MDF_Intel_Company_Code__c from Core_MDF_Bank__c WHERE ID IN:bankIds]); // get from query incase bank switch is off in before insert 
 
        }            
        for(PartnerFundClaim claim : claimList){
            integer vatPercentage;
            Decimal vatAmount;
            if(claim.Core_MDF_VAT_Eligibility_Ind__c){            
                if(claimIdBankMap.size()>0 && claimIdBankMap.containsKey(claim.Core_MDF_Bank__c) ){
                    vatPercentage = String.isNotBlank(claim.Core_MDF_Applicable_VAT_Percentage_nm__c) ? Integer.valueOf(claim.Core_MDF_Applicable_VAT_Percentage_nm__c) : Integer.valueOf(claimIdBankMap.get(claim.Core_MDF_Bank__c).Core_MDF_VAT_pct__c);
                } 
                // Calculating Vat amount
                if(vatPercentage != null && ((claimIdBankMap.get(claim.Core_MDF_Bank__c).Core_MDF_Intel_Company_Code__c ==bankLE650 &&
                                              String.isNotBlank(claim.Core_MDF_Applicable_VAT_Percentage_nm__c )) || vatPercentage > 0)){
                                                  vatAmount = (claim.Amount*vatPercentage)/100;
                                              }
                

                // Update the claim status and vat hold flag only if vat amount is greater than 0
                if(vatAmount != NULL && 
                   ((claimIdBankMap.get(claim.Core_MDF_Bank__c).Core_MDF_Intel_Company_Code__c ==bankLE650 && String.isNotBlank(claim.Core_MDF_Applicable_VAT_Percentage_nm__c)) || Math.abs(vatAmount.setScale(2)) > 0)){ 
                       claim.Core_MDF_Status__c='Hold';
                       claim.Core_MDF_VAT_Hold_Ind__c =True;
                       
                   }
            }
            vatEligibleClaimlist.add(claim);
        }
        return vatEligibleClaimlist;  
        
    } 
    
    /***************************************************************************************************** 
Method Name:        processVATRecords 
@return  :          void 
@parameters:        
Description:        This method is used to update claim status and VAT hold indecator field on claim when there is chnage is Amount and bank
Added By:           Intel       Areefa              7 Oct,2020
Modified By:        Date:       Changes:
Intel       Areefa              13 Nov,2020
******************************************************************************************************/
    
    public static void processVATRecords(Map<Id,PartnerFundClaim> newclaimMap,Map<Id,PartnerFundClaim> oldClaimMap){ 
   
        List<PartnerFundClaim> claimEligibleForVATProcessing = new List<PartnerFundClaim>();
        Set<ID> bankIds = new Set<ID>();
        for(PartnerFundClaim pfc: newclaimMap.values()){
            if(pfc.Core_MDF_VAT_Opt_In__c == Label.Core_MDF_nonTranslate_Service_Invoice_to_Intel) 
            {
                pfc.Core_MDF_VAT_Eligibility_Ind__c = true;                
            }
            else{
                pfc.Core_MDF_VAT_Eligibility_Ind__c = false;
            }
            bankIds.add(pfc.Core_MDF_Bank__c);
        }
        for(PartnerFundClaim pfc: oldClaimMap.values()){
            if(pfc.Core_MDF_VAT_Eligibility_Ind__c || 
               newclaimMap.get(pfc.Id).Core_MDF_VAT_Eligibility_Ind__c!= oldClaimMap.get(pfc.Id).Core_MDF_VAT_Eligibility_Ind__c)
            {
                bankIds.add(pfc.Core_MDF_Bank__c);
            }
        }
        claimIdBankMap = Core_MDF_PFC_HoldCheck.bankIdTobankInstance;

        if(claimIdBankMap== null || claimIdBankMap.isEmpty()) 
        {     
         claimIdBankMap = new Map<Id,Core_MDF_Bank__c>([Select Id,Core_MDF_VAT_pct__c,Core_MDF_Intel_Company_Code__c from Core_MDF_Bank__c WHERE ID IN:bankIds]); // get from query incase bank switch is off in before insert 

        }    
        for(PartnerFundClaim newClaim: newclaimMap.values()){ 
            if(newClaim.Core_MDF_VAT_Eligibility_Ind__c){
                //Areefa:If there is change is Banks VAT %/VAT Amount or Amount or currency,VAT process should restart if claim is not in Audit process.
                if(((newClaim.Core_MDF_Total_Invoice_Amount_Local__c!=null && newClaim.Core_MDF_Total_Invoice_Amount_Local__c != oldClaimMap.get(newClaim.Id).Core_MDF_Total_Invoice_Amount_Local__c) 
                    ||(newClaim.Core_MDF_Audit_Adjustment_Amount__c!=null && newClaim.Core_MDF_Audit_Adjustment_Amount__c != oldClaimMap.get(newClaim.Id).Core_MDF_Audit_Adjustment_Amount__c)
                    ||(newClaim.Core_MDF_Currency__c != oldClaimMap.get(newClaim.Id).Core_MDF_Currency__c)
                    ||(newClaim.Core_MDF_VAT_Eligibility_Ind__c != oldClaimMap.get(newClaim.Id).Core_MDF_VAT_Eligibility_Ind__c)
                    ||(newclaim.Core_MDF_PIC_Review_Completed__c && !oldClaimMap.get(newClaim.Id).Core_MDF_PIC_Review_Completed__c)
                    
                    ||(newClaim.Core_MDF_Bank__c != oldClaimMap.get(newClaim.Id).Core_MDF_Bank__c && 
                       ((String.isNotBlank(newClaim.Core_MDF_Applicable_VAT_Percentage_nm__c) && newClaim.Core_MDF_Applicable_VAT_Percentage_nm__c != oldClaimMap.get(newClaim.Id).Core_MDF_Applicable_VAT_Percentage_nm__c) 
                        || (claimIdBankMap.get(newClaim.Core_MDF_Bank__c).Core_MDF_Intel_Company_Code__c != claimIdBankMap.get(oldClaimMap.get(newClaim.Id).Core_MDF_Bank__c).Core_MDF_Intel_Company_Code__c))))
                   && ((claimIdBankMap.get(newClaim.Core_MDF_Bank__c).Core_MDF_Intel_Company_Code__c ==bankLE650 && String.isNotBlank(newClaim.Core_MDF_Applicable_VAT_Percentage_nm__c)) 
                       || (String.isNotBlank(newClaim.Core_MDF_Applicable_VAT_Percentage_nm__c) && Integer.valueOf(newClaim.Core_MDF_Applicable_VAT_Percentage_nm__c) > 0))
                   && newClaim.Core_MDF_Status__c!='Denied' && newClaim.Core_MDF_Status__c!='Cancelled' && newclaim.Core_MDF_PIC_Review_Completed__c)
                {
                                      
                    claimEligibleForVATProcessing.add(newClaim); 
                }
            }
            
        }        
        if(claimEligibleForVATProcessing !=null && claimEligibleForVATProcessing.size()>0){
            updateclaimVATInfo(claimEligibleForVATProcessing);
        }
    }
    
    /***************************************************************************************************** 
Method Name:        createUpdateVATRecord 
@return  :          void 
@parameters:        
Description:        This method is used to create new VAT record if it not there,
else for existing vat record update claim status and VAT hold indicator field on claim when there is change is Amount and bank
Added By:           Intel       Areefa              13 Nov,2020
Modified By:        Date:       Changes:
Intel       Sara                17 Nov,2020 
******************************************************************************************************/   
    
    public static void createUpdateVATRecord(List<PartnerFundClaim> inputClaims,Map<Id,PartnerFundClaim> newclaimMap ,Map<Id,PartnerFundClaim> oldClaimMap){
       
        Set<Id> claimsAmtBankChangeToBeProcess = new Set<Id>();
        Set<Id> vatEligibleClaimIds = new Set<Id>(); 
        List<Id> existingVatIds = new List<Id>();
        //Set<Id> vatClaimsToBeCancelled = new Set<Id>();        
        Map<Id,Core_MDF_Claim_VAT_Info__c> claimsWithVatAvailible = new Map<Id,Core_MDF_Claim_VAT_Info__c>(); 
        List<Core_MDF_Claim_VAT_Info__c> vatRecToBeInsertedOrUpdated = new List<Core_MDF_Claim_VAT_Info__c>();  
        
        for(PartnerFundClaim claim : inputClaims){ 

            if (claim.Core_MDF_Has_Sub_Claims_Ind__c == true) { continue; }  //Roshan - Outcome based VAT process

            if(claim.Core_MDF_VAT_Eligibility_Ind__c || 
               (!claim.Core_MDF_VAT_Eligibility_Ind__c && claim.Core_MDF_VAT_Eligibility_Ind__c !=oldClaimMap.get(claim.Id).Core_MDF_VAT_Eligibility_Ind__c)){
                   // For All  input claim looking for Currency or Amount or Bank change
                   vatEligibleClaimIds.add(claim.Id); 
                   //ATHR - Deeply Nested if 16209
                   if(oldClaimMap == null && oldClaimMap.isEmpty()){
                    continue;
                   }
                   //if(oldClaimMap!=null && oldClaimMap.size()>0)
                   //{
                       if(((claim.Core_MDF_Total_Invoice_Amount_Local__c!=null && claim.Core_MDF_Total_Invoice_Amount_Local__c != oldClaimMap.get(claim.Id).Core_MDF_Total_Invoice_Amount_Local__c) ||
                           (claim.Core_MDF_Audit_Adjustment_Amount__c!=null && claim.Core_MDF_Audit_Adjustment_Amount__c != oldClaimMap.get(claim.Id).Core_MDF_Audit_Adjustment_Amount__c) || 
                           (claim.Core_MDF_Currency__c != oldClaimMap.get(claim.Id).Core_MDF_Currency__c) ||
                           (claim.Core_MDF_VAT_Eligibility_Ind__c && claim.Core_MDF_VAT_Eligibility_Ind__c !=oldClaimMap.get(claim.Id).Core_MDF_VAT_Eligibility_Ind__c) ||
                           
                           (claim.Core_MDF_Bank__c !=oldClaimMap.get(claim.Id).Core_MDF_Bank__c && 
                            ((String.isNotBlank(claim.Core_MDF_Applicable_VAT_Percentage_nm__c) && claim.Core_MDF_Applicable_VAT_Percentage_nm__c != oldClaimMap.get(claim.Id).Core_MDF_Applicable_VAT_Percentage_nm__c) 
                             || (claim.Core_MDF_Bank_Legal_Entity_Code_cd__c != oldClaimMap.get(claim.Id).Core_MDF_Bank_Legal_Entity_Code_cd__c) ))) 
                          
                          && ((claimIdBankMap.get(claim.Core_MDF_Bank__c).Core_MDF_Intel_Company_Code__c ==bankLE650 && String.isNotBlank(claim.Core_MDF_Applicable_VAT_Percentage_nm__c)) 
                              || (String.isNotBlank(claim.Core_MDF_Applicable_VAT_Percentage_nm__c) && Integer.valueOf(claim.Core_MDF_Applicable_VAT_Percentage_nm__c) > 0)) 
                          
                          &&  claim.Core_MDF_Status__c!='Denied'){
                                  claimsAmtBankChangeToBeProcess.add(claim.Id);                      
                              }  
                   //} 
               }   
        }
        //ATHR - Deeply Nested if 16209
        if(vatEligibleClaimIds == null || vatEligibleClaimIds.isEmpty()){
            return;
        }
            for(Core_MDF_Claim_VAT_Info__c vatInfo : [Select Core_MDF_Claim_Id__c, Id, Core_MDF_Status_Txt__c, Core_MDF_Sub_Claim_Id__c from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c IN :vatEligibleClaimIds OR Core_MDF_Sub_Claim_Id__c IN :vatEligibleClaimIds])
            {
                if(vatInfo.Core_MDF_Sub_Claim_Id__c == null){
             		claimsWithVatAvailible.put(vatInfo.Core_MDF_Claim_Id__c,vatInfo);  
                }
                else{
                    claimsWithVatAvailible.put(vatInfo.Core_MDF_Sub_Claim_Id__c,vatInfo);
                }
            }
            for(PartnerFundClaim claim : inputClaims)
            {
                if(claimsWithVatAvailible != null && claimsWithVatAvailible.containsKey(claim.Id))
                {

                    Core_MDF_Claim_VAT_Info__c vatInfoRec = claimsWithVatAvailible.get(claim.Id);  
                    if(claimsAmtBankChangeToBeProcess != null && claimsAmtBankChangeToBeProcess.contains(claim.Id) 
                       && (claim.Core_MDF_Bank_Legal_Entity_Code_cd__c ==bankLE650 &&
                           String.isNotBlank(claim.Core_MDF_Applicable_VAT_Percentage_nm__c ) ||  Math.abs(claim.Core_MDF_VAT_Amt__c) >0)
                       && claim.Core_MDF_VAT_Eligibility_Ind__c) 
                    {   
                        existingVatIds.add(vatInfoRec.Id);
                        vatInfoRec.Core_MDF_Status_Txt__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Case_Status_Pending_Document'); //Label.Core_MDF_Case_Status_Pending_Document;

                        //Roshan - TWC3117-19010
                        if (oldClaimMap.get(claim.Id).Core_MDF_VAT_Eligibility_Ind__c != true) { vatInfoRec.Core_MDF_VAT_Comments_txt__c = null; }

                        vatRecToBeInsertedOrUpdated.add(vatInfoRec);
                    }                    
                    else if((((claim.Core_MDF_Bank__c !=oldClaimMap.get(claim.Id).Core_MDF_Bank__c) || 
                              (claim.Core_MDF_Currency__c !=oldClaimMap.get(claim.Id).Core_MDF_Currency__c) || // Added currency check, if there is any change in currency and VAT amount becomes 0, then update the VAT status to Cancelled
                              (claim.Core_MDF_Total_Invoice_Amount_Local__c != oldClaimMap.get(claim.Id).Core_MDF_Total_Invoice_Amount_Local__c)) // Added Total Invoice Amount Check
                             && ((String.isBlank(claim.Core_MDF_Applicable_VAT_Percentage_nm__c) 
                                  && claim.Core_MDF_VAT_Amt__c==0) || (claim.Core_MDF_Bank_Legal_Entity_Code_cd__c ==bankLE420 && claim.Core_MDF_VAT_Amt__c==0)) )
                            || !claim.Core_MDF_VAT_Eligibility_Ind__c) // claim has VAT Record and there is change in VAT Amt 10 %  - 0% , 
                    {

                        existingVatIds.add(vatInfoRec.Id);
                        vatInfoRec.Core_MDF_Status_Txt__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Cancelled'); //Label.Core_MDF_Status_Cancelled;
                        vatRecToBeInsertedOrUpdated.add(vatInfoRec);
                    }
                }
                else if( claim.Core_MDF_VAT_Hold_Ind__c && claim.Core_MDF_Status__c.equals(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold')) &&
                        vatEligibleClaimIds.contains(claim.Id) && claimsWithVatAvailible!=null && !claimsWithVatAvailible.containsKey(claim.Id) && claim.Core_MDF_VAT_Amt__c!= null && ((String.isNotBlank(claim.Core_MDF_Applicable_VAT_Percentage_nm__c) && claim.Core_MDF_Bank_Legal_Entity_Code_cd__c ==bankLE650) || Math.abs(claim.Core_MDF_VAT_Amt__c) > 0) && claim.Core_MDF_VAT_Eligibility_Ind__c) // Core_MDF_VAT_Amt__c // Claim 0%, Audit:Partial comp, Bank= 0.00
                {
                    Core_MDF_Claim_VAT_Info__c newVatRec = new Core_MDF_Claim_VAT_Info__c();

                    //Roshan - Outcome based VAT process
                    if (claim.Core_MDF_Claim_Id__c != NULL) {
                        newVatRec.Core_MDF_Claim_Id__c = claim.Core_MDF_Claim_Id__c;
                        newVatRec.Core_MDF_Sub_Claim_Id__c = claim.Id;
                    } else {
                        newVatRec.Core_MDF_Claim_Id__c = claim.Id;
                    }
                    vatRecToBeInsertedOrUpdated.add(newVatRec);
                }
                
            }         
            
            if(existingVatIds!= null){ 
                Core_MDF_VAT_ApprovalQueueRemoval.removeRecordsFromApprovalQueue(existingVatIds); // unlock VAT record 
            }
            
            if(vatRecToBeInsertedOrUpdated!=null && vatRecToBeInsertedOrUpdated.size()>0){ 
                try{
                database.upsert(vatRecToBeInsertedOrUpdated);              
                } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}  
            }
            

        
    }

    // Roshan - TWC3117-19010
    public class VATCancellationDecision {
        @AuraEnabled public Boolean isSuperClaim { get; set; }
        @AuraEnabled public Boolean isEligible { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
        @AuraEnabled public List<SubClaimVATCancellationOption> subClaims { get; set; }
    }

    // supplies the fields displayed for each eligible subclaim
    public class SubClaimVATCancellationOption {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String accountNode { get; set; }
        @AuraEnabled public Decimal nodeAmount { get; set; }
        @AuraEnabled public String vatStatus { get; set; }
    }

    
    // returns a map of claim IDs to their corresponding PartnerFundClaim records
    private static Map<Id, PartnerFundClaim> getRelatedClaims(Id claimId, Set<Id> selectedClaimIds, Boolean lockRecords) {

        Set<Id> claimIds = new Set<Id>();

        String query = 'SELECT Id, ChannelPartner.Name, Core_MDF_Requested_Reimbursement_Amt__c, Core_MDF_Status__c, Core_MDF_VAT_Hold_Ind__c, Core_MDF_Has_Sub_Claims_Ind__c, Core_MDF_Claim_Id__c, Request.Core_MDF_Is_Outcome_Based_Ind__c,Core_MDF_ESD_Hold__c,Core_MDF_Audit_Hold__c, Core_MDF_Payment_Hold_ind__c, Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Intel_Manual_Hold_Ind__c, Core_MDF_Member_Manual_Hold_Ind__c, Core_MDF_Claim_Previous_Status__c, Core_MDF_Bank_Doc_Hold_Ind__c, Core_MDF_Document_Hold_Ind__c, Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c, Core_MDF_Bank_Legal_Entity_Code_cd__c FROM PartnerFundClaim ';
        if (selectedClaimIds == null) {
            query += 'WHERE Id = :claimId OR Core_MDF_Claim_Id__c = :claimId ';
        } else {
            claimIds.addAll(selectedClaimIds);
            claimIds.add(claimId);
            query += 'WHERE Id IN :claimIds ';
        }
        if (lockRecords) { query += ' FOR UPDATE'; }
            
        List<PartnerFundClaim> pfcList = Database.query(query);
        return new Map<Id, PartnerFundClaim>(pfcList);
    }

    // returns a map of claim IDs to their corresponding VAT info records
    private static Map<Id, List<Core_MDF_Claim_VAT_Info__c>> getVATInfoByClaimId(Set<Id> claimIds, Boolean lockRecords) {

        Set<String> CANCELLABLE_VAT_STATUSES = new Set<String>{'Pending Documents', 'Under Review'};
        Map<Id, List<Core_MDF_Claim_VAT_Info__c>> vatInfoByClaimId = new Map<Id, List<Core_MDF_Claim_VAT_Info__c>>();
            
        Set<String> cancellableStatuses = CANCELLABLE_VAT_STATUSES;
        String query = 'SELECT Id, Core_MDF_Claim_Id__c, Core_MDF_Sub_Claim_Id__c, Core_MDF_Status_Txt__c FROM Core_MDF_Claim_VAT_Info__c ' +
            'WHERE (Core_MDF_Sub_Claim_Id__c IN :claimIds OR (Core_MDF_Claim_Id__c IN :claimIds AND Core_MDF_Sub_Claim_Id__c = null)) AND Core_MDF_Status_Txt__c IN :cancellableStatuses';
        if (lockRecords) { query += ' FOR UPDATE'; }
            
        for (Core_MDF_Claim_VAT_Info__c vatRec : Database.query(query)) {
            Id claimId = vatRec.Core_MDF_Sub_Claim_Id__c == null ? vatRec.Core_MDF_Claim_Id__c : vatRec.Core_MDF_Sub_Claim_Id__c;
            if (!vatInfoByClaimId.containsKey(claimId)) {
                vatInfoByClaimId.put(claimId, new List<Core_MDF_Claim_VAT_Info__c>());
            }
            vatInfoByClaimId.get(claimId).add(vatRec);
        }
        return vatInfoByClaimId;
    }

    // reject pending VAT approval workItem requests
    private static void rejectPendingVATApprovals(Set<Id> vatInfoIds, String cancellationComment) {
        Set<Id> rejectedProcessIds = new Set<Id>();
        List<Approval.ProcessWorkitemRequest> rejectionRequests = new List<Approval.ProcessWorkitemRequest>();

        for (ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :vatInfoIds AND ProcessInstance.Status = 'Pending']) {
            if (rejectedProcessIds.contains(workItem.ProcessInstanceId)) { continue; }
            Approval.ProcessWorkitemRequest rejectionRequest = new Approval.ProcessWorkitemRequest();
            rejectionRequest.setWorkitemId(workItem.Id);
            rejectionRequest.setAction('Reject');
            rejectionRequest.setComments(cancellationComment);
            rejectionRequests.add(rejectionRequest);
            rejectedProcessIds.add(workItem.ProcessInstanceId);
        }
        if (!rejectionRequests.isEmpty()) {
            for (Approval.ProcessResult rejectionResult : Approval.process(rejectionRequests)) {
                if (!rejectionResult.isSuccess()) { throw new AuraHandledException(rejectionResult.getErrors()[0].getMessage()); }
            }
        }
    }

    // updates the given PartnerFundClaim and VAT info records
    private static void updateClaimAndVATRecords(List<PartnerFundClaim> claimUpdates, List<Core_MDF_Claim_VAT_Info__c> vatUpdates) {
        update claimUpdates;
        update vatUpdates;
    }

    @AuraEnabled
    public static VATCancellationDecision getVATCancellationOptions(Id claimId) {
        return new VATCancellationService().getVATCancellationOptions(claimId);
    }

    @AuraEnabled
    public static Boolean cancelClaimVAT(Id claimId) {
        return new VATCancellationService().cancelClaimVAT(claimId);
    }

    @AuraEnabled
    public static Boolean cancelSelectedSubClaimVAT(Id claimId, List<Id> subClaimIds) {
        return new VATCancellationService().cancelSelectedSubClaimVAT(claimId, subClaimIds);
    }

    private with sharing class VATCancellationService {
        // checks if the current user is an external claim submitter
        private Boolean isExternalClaimSubmitter() {
            boolean hasCancelAccess = FeatureManagement.checkPermission('Core_MDF_Cancel_VAT_Claim');
            return hasCancelAccess;
        }

        // returns a VATCancellationDecision object with eligibility and subclaim information for the given claim ID
        public VATCancellationDecision getVATCancellationOptions(Id claimId) {

            VATCancellationDecision cancellationDecision = new VATCancellationDecision();
            cancellationDecision.isSuperClaim = false;
            cancellationDecision.isEligible = false;
            cancellationDecision.subClaims = new List<SubClaimVATCancellationOption>();

            if (!isExternalClaimSubmitter()) { return cancellationDecision; }
            Map<Id, PartnerFundClaim> claimsById = Core_MDF_Claim_VAT_Process.getRelatedClaims(claimId, null, false);
            PartnerFundClaim claim = claimsById.get(claimId);

            cancellationDecision.isSuperClaim = claim.Core_MDF_Has_Sub_Claims_Ind__c == true && claim.Core_MDF_Claim_Id__c == null && claim.Request.Core_MDF_Is_Outcome_Based_Ind__c == true;

            if (cancellationDecision.isSuperClaim) {
                cancellationDecision.subClaims = getEligibleSubClaimVATOptions(claimId, claimsById);
                cancellationDecision.isEligible = !cancellationDecision.subClaims.isEmpty();
            } else if (!claim.Core_MDF_Has_Sub_Claims_Ind__c) {
                Map<Id, List<Core_MDF_Claim_VAT_Info__c>> vatInfoByClaimId = Core_MDF_Claim_VAT_Process.getVATInfoByClaimId(new Set<Id>{ claimId }, false);
                cancellationDecision.isEligible = getEligibleVATInfo(claim, vatInfoByClaimId) != null;
            }
            if (!cancellationDecision.isEligible) {
                cancellationDecision.errorMessage = getVATCancellationErrorMessage(claimId, cancellationDecision.isSuperClaim, claimsById);
            }
            return cancellationDecision;
        }

        private String getVATCancellationErrorMessage(Id claimId, Boolean isSuperClaim, Map<Id, PartnerFundClaim> claimsById) {
            for (PartnerFundClaim claim : claimsById.values()) {
                Boolean isVATApplicableClaim = isSuperClaim ? claim.Core_MDF_Claim_Id__c == claimId : claim.Id == claimId;
                if (isVATApplicableClaim && claim.Core_MDF_Has_Sub_Claims_Ind__c == false && claim.Core_MDF_Status__c == Label.Core_MDF_Status_Hold && claim.Core_MDF_VAT_Hold_Ind__c == true) {
                    return Label.Core_MDF_Cancel_VAT_Invalid_Status;
                }
            }
            return Label.Core_MDF_Claim_Not_On_VAT_Hold;
        }

        // returns a list of eligible subclaim VAT cancellation options for the given super claim ID
        private List<SubClaimVATCancellationOption> getEligibleSubClaimVATOptions(Id superClaimId, Map<Id, PartnerFundClaim> claimsById) {
            Set<Id> subClaimIds = new Set<Id>();
            for (PartnerFundClaim subClaim : claimsById.values()) {
                if (subClaim.Core_MDF_Claim_Id__c == superClaimId && subClaim.Core_MDF_Status__c == Label.Core_MDF_Status_Hold && subClaim.Core_MDF_VAT_Hold_Ind__c == true && subClaim.Core_MDF_Has_Sub_Claims_Ind__c != true) {
                    subClaimIds.add(subClaim.Id);
                }
            }

            Map<Id, List<Core_MDF_Claim_VAT_Info__c>> vatInfoBySubClaimId = Core_MDF_Claim_VAT_Process.getVATInfoByClaimId(subClaimIds, false);
            List<SubClaimVATCancellationOption> subClaimOptions = new List<SubClaimVATCancellationOption>();

            for (Id subClaimId : subClaimIds) {
                PartnerFundClaim subClaim = claimsById.get(subClaimId);
                List<Core_MDF_Claim_VAT_Info__c> vatInfoRecords = vatInfoBySubClaimId.get(subClaim.Id);

                if (vatInfoRecords == null || vatInfoRecords.size() != 1 || vatInfoRecords[0].Core_MDF_Claim_Id__c != superClaimId) { continue; }

                SubClaimVATCancellationOption subClaimOption = new SubClaimVATCancellationOption();
                subClaimOption.id = subClaim.Id;
                subClaimOption.accountNode = subClaim.ChannelPartner == null ? null : subClaim.ChannelPartner.Name;
                subClaimOption.nodeAmount = subClaim.Core_MDF_Requested_Reimbursement_Amt__c;
                subClaimOption.vatStatus = vatInfoRecords[0].Core_MDF_Status_Txt__c;
                subClaimOptions.add(subClaimOption);
            }
            return subClaimOptions;
        }

        // returns the eligible VAT info record for the given claim, or null if none exists
        private Core_MDF_Claim_VAT_Info__c getEligibleVATInfo(PartnerFundClaim claim, Map<Id, List<Core_MDF_Claim_VAT_Info__c>> vatInfoByClaimId) {

            if (claim.Core_MDF_Status__c != Label.Core_MDF_Status_Hold || claim.Core_MDF_VAT_Hold_Ind__c == false || claim.Core_MDF_Has_Sub_Claims_Ind__c == true) { return null; }

            List<Core_MDF_Claim_VAT_Info__c> vatInfoRecords = vatInfoByClaimId.get(claim.Id);

            if (vatInfoRecords == null || vatInfoRecords.size() != 1) { return null; }
            if (claim.Core_MDF_Claim_Id__c != null && (vatInfoRecords[0].Core_MDF_Sub_Claim_Id__c != claim.Id || vatInfoRecords[0].Core_MDF_Claim_Id__c != claim.Core_MDF_Claim_Id__c)) { return null; }

            return vatInfoRecords[0];
        }

        // cancels VAT for the given claim IDs and updates the related claims accordingly
        public Boolean cancelClaimVAT(Id claimId) {
            if (!isExternalClaimSubmitter()) { throw new AuraHandledException(Label.Core_MDF_Cancel_VAT_Claim_Submitter_Only); }
            return cancelVATAndUpdateClaims(new Set<Id>{ claimId }, null);
        }

        // cancels VAT for the selected subclaims of the given claim ID
        public Boolean cancelSelectedSubClaimVAT(Id claimId, List<Id> subClaimIds) {
            
            if (!isExternalClaimSubmitter()) {
                throw new AuraHandledException(Label.Core_MDF_Cancel_VAT_Claim_Submitter_Only);
            }
            if (claimId == null || subClaimIds == null || subClaimIds.isEmpty()) {
                throw new AuraHandledException(Label.Core_MDF_Select_Payment_Breakdown);
            }

            Set<Id> selectedSubClaimIds = new Set<Id>(subClaimIds);
            return cancelVATAndUpdateClaims(selectedSubClaimIds, claimId);
        }

        // performs the actual VAT cancellation and updates the related claims accordingly
        private Boolean cancelVATAndUpdateClaims(Set<Id> claimIds, Id superClaimId) {

            Savepoint checkpoint = Database.setSavepoint();
            try {
                Id actionClaimId = superClaimId == null ? claimIds.iterator().next() : superClaimId;
                
                Map<Id, PartnerFundClaim> claimsById = Core_MDF_Claim_VAT_Process.getRelatedClaims(actionClaimId, claimIds, true);
                Map<Id, List<Core_MDF_Claim_VAT_Info__c>> vatInfoByClaimId = Core_MDF_Claim_VAT_Process.getVATInfoByClaimId(claimIds, true);
                
                List<PartnerFundClaim> selectedClaims = new List<PartnerFundClaim>();
                List<Core_MDF_Claim_VAT_Info__c> vatInfoToCancel = new List<Core_MDF_Claim_VAT_Info__c>();
                Set<Id> vatInfoIds = new Set<Id>();
                for (Id claimId : claimIds) {
                    PartnerFundClaim claim = claimsById.get(claimId);                
                    Core_MDF_Claim_VAT_Info__c vatInfo = getEligibleVATInfo(claim, vatInfoByClaimId);
                    if (vatInfo == null) {
                        throw new AuraHandledException(Label.Core_MDF_Cancel_VAT_Invalid_Status);
                    }
                    selectedClaims.add(claim);  // list of claims to update
                    vatInfoToCancel.add(vatInfo);  // list of vat records to update
                    vatInfoIds.add(vatInfo.Id);
                }
                
                String cancellationComment = System.now().format('yyyy-MM-dd HH:mm:ss') + ' - ' + UserInfo.getName() + ': Recalled due to VAT cancellation.';
                Core_MDF_Claim_VAT_Process.rejectPendingVATApprovals(vatInfoIds, cancellationComment);
                
                // release only VAT hold using the existing blocking-hold rules.
                Core_MDF_Claim_Utility.processReleaseHold(selectedClaims, new List<String>{Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_VAT_Hold')});
                
                String holdStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold');            
                String submittedStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted');
                List<PartnerFundClaim> claimUpdates = new List<PartnerFundClaim>();
                
                for (PartnerFundClaim selectedClaim : selectedClaims) {
                    claimUpdates.add(
                        new PartnerFundClaim(
                            Id = selectedClaim.Id,
                            Core_MDF_Status__c = selectedClaim.Core_MDF_Status__c == holdStatus ? holdStatus : submittedStatus,
                            Core_MDF_VAT_Hold_Ind__c = selectedClaim.Core_MDF_VAT_Hold_Ind__c,
                            Core_MDF_VAT_Opt_In__c = 'Reimbursement Request for 3rd party payment (NET cost only)',
                            Core_MDF_Applicable_VAT_Percentage_nm__c = selectedClaim.Core_MDF_Bank_Legal_Entity_Code_cd__c == bankLE650 ? '0' : null,
                            Core_MDF_VAT_Eligibility_Ind__c = false
                        )
                    );
                }
                List<Core_MDF_Claim_VAT_Info__c> vatUpdates = new List<Core_MDF_Claim_VAT_Info__c>();
                for (Core_MDF_Claim_VAT_Info__c vatInfo : vatInfoToCancel){
                    vatUpdates.add(
                        new Core_MDF_Claim_VAT_Info__c(
                            Id = vatInfo.Id,
                            Core_MDF_Status_Txt__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Cancelled'),
                            Core_MDF_VAT_Comments_txt__c = cancellationComment
                        )
                    );
                }
                Core_MDF_Claim_VAT_Process.updateClaimAndVATRecords(claimUpdates, vatUpdates);            
                return true;            
            } catch (Exception e) {
                Database.rollback(checkpoint);
                if (e instanceof AuraHandledException) { throw e; }
                throw new AuraHandledException(e.getMessage());
            }        
        }
    }
}