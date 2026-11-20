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
        //if(vatEligibleClaimIds != null && vatEligibleClaimIds.size()>0)
        //{
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
            
        //}
        
    }
    
}