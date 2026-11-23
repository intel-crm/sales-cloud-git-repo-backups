/****************************************************************************************************************************************
* Class Name  : Core_MDF_SurePay_Batch 
* Version     : 1.0 
* Created Date: 23-02-2025
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Amey 		 23-02-2025					  Batch class to create recoveries agianst payment due and PAF sure pay claims.
*													  Scope: Sure pay claims which are audited and has scored 0 or has manual recovery
*                                                     and not opted for VAT.
****************************************************************************************************************************************/
public without sharing class Core_MDF_SurePay_Batch implements Database.Batchable<sObject>, Database.Stateful,Core_MDF_BatchSchedulerInterface {
    public List<Core_MDF_Recovery_Request__c> finalRecoveryReqList = new List<Core_MDF_Recovery_Request__c>();
    public Map<Id,PartnerFundClaim> mapOfPAFClaim = new Map<Id,PartnerFundClaim>();
    public Map<Id,list<PartnerFundClaim>> mapOfNodeAccToPAFClaimLst = new Map<Id,list<PartnerFundClaim>>();
    public Map<Id,list<id>> mapOfNodeAccToPAFClaimIdsLst = new Map<Id,list<id>>();
    public string program;
    public static object generateInstance(String jsonText, String classSignature){
        object des_Obj;
        map<String,object> parmValueMap = (Map<String, Object>)JSON.deserializeUntyped(jsonText);
            if(classSignature == 'Core_MDF_SurePay_Batch(string pgm)'){
                string pgm = string.valueOf(parmValueMap.get('pgm'));
                des_Obj = new Core_MDF_SurePay_Batch(pgm);
            }
            
        return des_Obj;
    }
    public Core_MDF_SurePay_Batch(string pgm)
    {
        this.program = pgm;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        string vatValue = Label.Core_MDF_Service_Invoice_to_Intel;
        finalRecoveryReqList = new List<Core_MDF_Recovery_Request__c>();
        set<string> clmStatusSet = new set<string>{'Payment Due', 'Pending Available Fund'};
        string caseStatus = 'Review Completed';
        string surePayVal = 'Settle, then get paid';
        //Swati - exclude RSA MD         
        String RSA_MDbudget = Core_MDF_CCP_ConstantClass.RMF_RSA_MD_BUDGET_TYPE;
        Date excludeDate = Date.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exclude_RSA_MD'));
        
        String query = 'SELECT Id,Core_MDF_Claim_Ref_Number__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Budget_Type_Options_Nm__c,AllocationId,Allocation.Amount,Allocation.TotalApprovedFcs,Core_MDF_Activity_Category__c,Core_MDF_Activity_Types__c, ChannelPartnerId,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,Core_MDF_VAT_Opt_In_txt__c, Core_MDF_Program__c, Core_MDF_Region_Cd__c, Amount, Core_MDF_Status__c,Core_MDF_Ultimate_Account_ID__c,Core_MDF_Processing_Preference_nm__c,Core_MDF_SurePay_Processed_Ind__c,Core_MDF_Excess_Requested_Amount__c,Core_MDF_Requested_Reimbursement_Amt__c,  '+
                       'Core_MDF_Claim_Review_Case__r.Core_MDF_Scorecard_Score_Nbr__c,Core_MDF_Country_Location_nm__c, Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c,Core_MDF_Claim_Review_Case__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Number_Of_Recoveries_Nbr__c '+
                       'FROM PartnerFundClaim '+
                       'WHERE Core_MDF_Status__c IN :clmStatusSet '+
                       'AND Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c = :caseStatus '+ 
                       'AND (Core_MDF_Claim_Review_Case__r.Core_MDF_Scorecard_Score_Nbr__c =0 OR Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c > 0) and Core_MDF_Processing_Preference_nm__c = :surePayVal '+
                        'AND Core_MDF_Program__c = :program AND Core_MDF_SurePay_Processed_Ind__c = false '+
                        'AND ( Core_MDF_Claim_Review_Case__r.Core_MDF_Budget_Type_nm__c != :RSA_MDbudget OR ( Core_MDF_Claim_Review_Case__r.Core_MDF_Budget_Type_nm__c = :RSA_MDbudget AND DAY_ONLY(Core_MDF_Claim_Review_Case__r.ClosedDate) <= :excludeDate ))';
                        if(Core_MDF_Utility.byPassFeature('bypass_VATClaimsForRecovery')){
                                
                            query += ' AND Core_MDF_VAT_Opt_In_txt__c != :vatValue ';
                        }
        return Database.getQueryLocator(String.escapeSingleQuotes(query));  
    }
    
    // process each batch of records
    public void execute(Database.BatchableContext bc, List<PartnerFundClaim > claimList) {
        
        list<PartnerFundClaim> claimsToBeUpdated = new list<PartnerFundClaim>();
        //Map<Id,PartnerFundClaim> mapOfPAFClaim = new Map<Id,PartnerFundClaim>();
        //Map<Id,PartnerFundClaim> mapOfNonPAFClaims = new Map<Id,PartnerFundClaim>();  //ATHR Comment - 17214 (unused local variable)
        set<id> caseIds = new set<id>();
        //set<String> qtrSet = new set<String>();  //ATHR Comment - 17214 (unused local variable)
        ClaimDetails claimDetails = new ClaimDetails();
        Decimal recoveryAmt = 0;
        List<Core_MDF_Recovery_Request__c> recoveryReqListTobeInserted = new List<Core_MDF_Recovery_Request__c>();
        //List<Core_MDF_Recovery_Request__c> recoveryReqListTobeReturned = new List<Core_MDF_Recovery_Request__c>();  //ATHR Comment - 17214 (unused local variable)
        
        List<Core_MDF_Recovery__c> recoveryListTobeInserted = new List<Core_MDF_Recovery__c>();
        Savepoint sp = Database.setSavepoint();
        try{
            if(mapOfNodeAccToPAFClaimIdsLst == null){
                                mapOfNodeAccToPAFClaimIdsLst = new Map<Id,list<id>>();
            }
            if(claimList != null && claimList.size() > 0){
                //collect list of caseIds
                	for(PartnerFundClaim clm : claimList)
                    {
                        claimDetails.claimIdToClaimMap.put(clm.id,clm);
                        caseIds.add(clm.Core_MDF_Claim_Review_Case__c);
                    }
                // get the corresponding Recovery Dashboard for each case Ids
                    for(Core_MDF_Recovery_Dashboard__c recDashboard : [select id,Core_MDF_Partnership_Score_Detail_Id__c,Core_MDF_Scorecard_Id__r.Core_MDF_Case_Id__r.Core_MDF_Claim_ID__c,Core_MDF_Partnership_Score_Id__c,Core_MDF_Partnership_Score_Detail_Id__r.Core_MDF_Quarter_Year_Nm__c,Core_MDF_Is_Active_Ind__c 
                                                                        from Core_MDF_Recovery_Dashboard__c 
                                                                        WHERE Core_MDF_Scorecard_Id__r.Core_MDF_Case_Id__c in: caseIds and Core_MDF_Is_Active_Ind__c = true]){
                                                   claimDetails.claimIdtoQtr.put(recDashboard.Core_MDF_Scorecard_Id__r.Core_MDF_Case_Id__r.Core_MDF_Claim_ID__c,recDashboard.Core_MDF_Partnership_Score_Detail_Id__r.Core_MDF_Quarter_Year_Nm__c);                         
                    							   claimDetails.claimToPSD.put(recDashboard.Core_MDF_Scorecard_Id__r.Core_MDF_Case_Id__r.Core_MDF_Claim_ID__c,recDashboard.Core_MDF_Partnership_Score_Detail_Id__c); 
                                                   claimDetails.claimToPartnerGradient.put(recDashboard.Core_MDF_Scorecard_Id__r.Core_MDF_Case_Id__r.Core_MDF_Claim_ID__c,recDashboard.Core_MDF_Partnership_Score_Id__c);
                    }
                	for(PartnerFundClaim clm : claimList)
                    {
                        PartnerFundClaim newClaimInstance = new PartnerFundClaim();
                        newClaimInstance.id = clm.id;
                        newClaimInstance.Core_MDF_Status__c = clm.Core_MDF_Status__c;
                        newClaimInstance.Core_MDF_Number_Of_Recoveries_Nbr__c = clm.Core_MDF_Number_Of_Recoveries_Nbr__c;
                        newClaimInstance.Amount = clm.amount;
                        if(clm.Core_MDF_Claim_Review_Case__r.Core_MDF_Scorecard_Score_Nbr__c == 0){
                            recoveryAmt = clm.Core_MDF_Requested_Reimbursement_Amt__c - clm.Core_MDF_Excess_Requested_Amount__c ;
                            
                        }else if(clm.Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c!=null && clm.Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c != 0){
                            recoveryAmt = clm.Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c;
                        }
                        if(recoveryAmt > clm.Amount){
                        	recoveryAmt = clm.amount;
                            newClaimInstance.Amount = 0;
                        }else{
                            newClaimInstance.Amount = clm.Amount - recoveryAmt;
                        }
                         if(newClaimInstance.Amount == 0){
                                newClaimInstance.Core_MDF_Status__c ='Paid';
                        }
                        if(clm.Core_MDF_Number_Of_Recoveries_Nbr__c!=null){
                        	newClaimInstance.Core_MDF_Number_Of_Recoveries_Nbr__c += 1;
                        }else{
                            newClaimInstance.Core_MDF_Number_Of_Recoveries_Nbr__c = 1;
                        }
                        if(newClaimInstance.Core_MDF_Status__c =='Pending Available Fund'){
                            
                            //if(mapOfNodeAccToPAFClaimIdsLst!=null){
                                if(mapOfNodeAccToPAFClaimIdsLst == null){//ATHR Fix WW19
                                    continue;
                                }
                                if(mapOfNodeAccToPAFClaimIdsLst.containsKey(clm.ChannelPartnerId )){
                                	mapOfNodeAccToPAFClaimIdsLst.get(clm.ChannelPartnerId).add(clm.id);
                                }
                                else{
                                    mapOfNodeAccToPAFClaimIdsLst.put(clm.ChannelPartnerId ,new list<id>{clm.id});
                                }
                            //}
                            
                        }

                        

			//create recovery instance
					claimDetails.claimIdToNewClaimInstance.put(clm.id,newClaimInstance);
					Core_MDF_Recovery__c recoveryObj = createRecoveryIns(clm,claimDetails,recoveryAmt);
                
                    recoveryListTobeInserted.add(recoveryObj);

                    }
            }
            
            Database.SaveResult[] recSaveResults = Database.insert(recoveryListTobeInserted, true);
            for (Integer i = 0; i < recSaveResults.size(); i++) {
                Database.SaveResult sr = recSaveResults[i];
                Core_MDF_Recovery__c currentRec = recoveryListTobeInserted[i]; // Original recv reference
                
                // Check if the insert was successful
                if (sr.isSuccess()) {
                    Core_MDF_Recovery_Request__c rr = createRecoveryReqIns(claimDetails.claimIdToClaimMap.get(currentRec.Core_MDF_Claim_Id__c),claimDetails,currentRec);
                    recoveryReqListTobeInserted.add(rr);
                    //if(claimDetails.claimIdToNewClaimInstance.size() > 0){
                        if(claimDetails.claimIdToNewClaimInstance.size() == 0){ //ATHR Fix WW19
                            continue;
                        }
                    	PartnerFundClaim newClaimInstance = claimDetails.claimIdToNewClaimInstance.get(currentRec.Core_MDF_Claim_Id__c);
                        if(newClaimInstance != null){
                            newClaimInstance.Core_MDF_SurePay_Processed_Ind__c = true;
                            claimsToBeUpdated.add(newClaimInstance);
                        }
                    //}
                }
            }

            if(recoveryReqListTobeInserted.isEmpty()){
                Return;
            }

            
            insert recoveryReqListTobeInserted;
           
            update claimsToBeUpdated;

            if(finalRecoveryReqList == null || finalRecoveryReqList.size() == 0){
            	finalRecoveryReqList = new List<Core_MDF_Recovery_Request__c>();
            }
	    if(recoveryReqListTobeInserted!=null && !recoveryReqListTobeInserted.isEmpty() && recoveryReqListTobeInserted.size()>0){
            	finalRecoveryReqList.addAll(recoveryReqListTobeInserted);
           	}
            
        }catch(Exception e){ 
            Core_MDF_CCP_UtilityClass.logError(e);
            Database.rollback(sp); 
        }
         
    }
    
    
    public void finish(Database.BatchableContext bc) {
        String logAccounts  = '';
        try{
            if(finalRecoveryReqList != null && finalRecoveryReqList.size() > 0){
                List<Core_MDF_Partnership_Score_Detail__c> scoreDetailTobeUpdated = updatePartnershipScoreDetailMapping(finalRecoveryReqList);
                
                Core_MDF_Batch_Bulk_CRUD_Operations updateRecBatch = new Core_MDF_Batch_Bulk_CRUD_Operations(scoreDetailTobeUpdated,'update',true);
                database.executeBatch(updateRecBatch,50);
                
                
                list<id> pafClaimIdLst = new list<id>();
                Integer count = 0;
                //to get 100 account based claim which needs to go through fund reservation
                for(Id nodeAccId : mapOfNodeAccToPAFClaimIdsLst.keySet()){
                    
                    if(mapOfNodeAccToPAFClaimIdsLst.get(nodeAccId).size() > 50){// wecan use recoveryBatchSize than 50
                        logAccounts +=  logAccounts +';'+nodeAccId;//which accounts she wants to log? processed ones or not processed ons
                        continue;
                    }
                    count = count + mapOfNodeAccToPAFClaimIdsLst.get(nodeAccId).size();
                    if(count > 50){
                        break;
                    }
                    else{
                        pafClaimIdLst.addAll(mapOfNodeAccToPAFClaimIdsLst.get(nodeAccId));
                    }
                    
                }
                mapOfPAFClaim = new Map<Id, PartnerFundClaim>([SELECT Id,Core_MDF_Claim_Ref_Number__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Budget_Type_Options_Nm__c,AllocationId,Allocation.Amount,Allocation.TotalApprovedFcs,Core_MDF_Activity_Category__c,Core_MDF_Activity_Types__c, ChannelPartnerId,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,Core_MDF_VAT_Opt_In_txt__c, Core_MDF_Program__c, Core_MDF_Region_Cd__c, Amount, Core_MDF_Status__c,Core_MDF_Ultimate_Account_ID__c,Core_MDF_Processing_Preference_nm__c,Core_MDF_SurePay_Processed_Ind__c,  
                       Core_MDF_Claim_Review_Case__r.Core_MDF_Scorecard_Score_Nbr__c,Core_MDF_Country_Location_nm__c, Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c,Core_MDF_Claim_Review_Case__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Number_Of_Recoveries_Nbr__c 
                       from PartnerFundClaim where id in: pafClaimIdLst and Core_MDF_Status__c =: 'Pending Available Fund']);
                
                Core_MDF_ProcessCCP_Claim.fundReservation(mapOfPAFClaim,true);
                update(mapOfPAFClaim.values());
                
                if(logAccounts!=''){
                    Core_MDF_Error_Logging__e el = new Core_MDF_Error_Logging__e();
                    el.Core_MDF_Details_txt__c = logAccounts;
                    el.Core_MDF_Apex_Class_Name_Txt__c = 'Core_MDF_SurePay_Batch';
                    el.Core_MDF_Exception_Message_Txt__c = 'Action Required: List of Accounts With PAF Claims.';
                    el.Core_MDF_Severity_txt__c = 'Normal';
                    el.Core_MDF_Project_nm__c = Label.Core_MDF_Program_Name;
                    el.Core_MDF_Tag_txt__c = 'Sure Pay';
                    el.Core_MDF_Object_Name_Nm__c = 'Sure Pay';
                    EventBus.publish(el);
                }
            }
        }
        catch(Exception e){ 
            Core_MDF_CCP_UtilityClass.logError(e); 
        } 

        
    }
    
/***********************************************************************************************************   
Method Name:        updatePartnershipScoreDetailMapping 
@return  :           List<Core_MDF_Partnership_Score_Detail__c>
Parameter :        	List<Core_MDF_Recovery_Request__c> recoveryReqList
Description:        method to form partnership score detail record list with recovered amount
Added By:           Accenture - Amey - 05/03/2025
Modified By:        Date:       Changes: 
*************************************************************************************************************/
    
    public static List<Core_MDF_Partnership_Score_Detail__c>  updatePartnershipScoreDetailMapping(List<Core_MDF_Recovery_Request__c> recoveryReqList)
    { 
        try{
            Map<Id,decimal> partnerScoreDetailtoAmtMap = new Map<Id,decimal>();
            for(Core_MDF_Recovery_Request__c recoveryReq : recoveryReqList)
            {
                List<string> recoveredPartnershipScoreDetailLst = recoveryReq.Core_MDF_RecoveredPartnershipScoreDetail__c.split(';');
                for(string recoveredPartnershipScoreDetail : recoveredPartnershipScoreDetailLst)
                {
                    List<string> psdAmountSplit = recoveredPartnershipScoreDetail.split('-');
                    Id psdId = psdAmountSplit[0];
                    decimal amount = decimal.valueOf(psdAmountSplit[1]);
                    if(partnerScoreDetailtoAmtMap.containsKey(psdId)){
                        partnerScoreDetailtoAmtMap.put(psdId,partnerScoreDetailtoAmtMap.get(psdId)+amount);
                    }
                    else{
                        partnerScoreDetailtoAmtMap.put(psdId, amount);
                    }
                    
                }
                
            }
            Map<Id,Core_MDF_Partnership_Score_Detail__c> scoreDetailMap = new Map<Id,Core_MDF_Partnership_Score_Detail__c>([Select id, Core_MDF_Recovered_Amt__c
                                                                                                                            from Core_MDF_Partnership_Score_Detail__c
                                                                                                                            where id in :partnerScoreDetailtoAmtMap.keySet()]);
            List<Core_MDF_Partnership_Score_Detail__c> scoreDetailTobeUpdated = new List<Core_MDF_Partnership_Score_Detail__c>();
            
            for(Id psd : scoreDetailMap.keyset())
            {
                Core_MDF_Partnership_Score_Detail__c scoreDetailRec = scoreDetailMap.get(psd);
                scoreDetailRec.Core_MDF_Recovered_Amt__c = (scoreDetailRec.Core_MDF_Recovered_Amt__c == null? 0:scoreDetailRec.Core_MDF_Recovered_Amt__c) + partnerScoreDetailtoAmtMap.get(psd);
                scoreDetailTobeUpdated.add(scoreDetailRec);
            }
            return scoreDetailTobeUpdated;
        }catch(Exception e){ 
            Core_MDF_CCP_UtilityClass.logError(e);
            throw e;} 
    }
    
     /***********************************************************************************************************   
wrapper class Name:        ClaimDetails 
@return  :           
Parameter :        	
Description:        wrapper to store claim data
Added By:           Accenture - Amey - 05/03/2025
Modified By:        Date:       Changes: 
*************************************************************************************************************/
    
    public class ClaimDetails {        
        public String onlyReadyToRecoverMonths = '';
        public Map<Id, Core_MDF_Recovery_Request__c> claimIdToRR = new Map<Id, Core_MDF_Recovery_Request__c>();
        public Map<Id,Core_MDF_Recovery__c> claimToRecoveryMap = new Map<Id,Core_MDF_Recovery__c>();
        public Map<Id,PartnerFundClaim> claimIdToClaimMap = new Map<Id,PartnerFundClaim>();
        public Map<Id,PartnerFundClaim> claimIdToNewClaimInstance = new Map<Id,PartnerFundClaim>();
        public Map<Id,String> claimIdtoQtr = new Map<Id,String>();
        public Map<Id,Id> claimToPartnerGradient = new Map<Id,Id>();
        public Map<Id,Id> claimToPSD = new Map<Id,Id>();
    }
/***********************************************************************************************************   
Method Name:        createRecoveryReqIns 
@return  :          Core_MDF_Recovery_Request__c
Parameter :         PartnerFundClaim, ClaimDetails, Decimal(PFC Record Instance, Wrapper Instance, Amount)
Description:        This method is used create instance of SObject Core_MDF_Recovery_Request__c for a particular 
                    recovery against a claim
Added By:           Accenture - Amey - 05/03/2025
Modified By:        Date:       Changes: 
*************************************************************************************************************/ 
    public Core_MDF_Recovery_Request__c createRecoveryReqIns(PartnerFundClaim claimrec,ClaimDetails claimdet,Core_MDF_Recovery__c recovery){
        String extClaimId = claimdet.claimIdtoQtr.get(claimrec.id)+'='+claimrec.Core_MDF_Budget_Type_Options_Nm__c+'='+claimrec.Core_MDF_Region_Cd__c+'='+claimrec.id;
        Core_MDF_Recovery_Request__c rr = new Core_MDF_Recovery_Request__c();
                            rr.Core_MDF_Account_Id__c = claimrec.ChannelPartnerId;
                            rr.Core_MDF_Claim_Id__c = claimrec.id;
                            //null check
                            rr.Core_MDF_Partnership_Grade_Maint_Id__c = claimdet.claimToPartnerGradient.get(claimrec.Id);
                            rr.Core_MDF_Program_Nm__c = claimrec.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
                            rr.Core_MDF_Quarter_Year_Nm__c = claimdet.claimIdtoQtr.get(claimrec.id);
                            rr.Core_MDF_Recovery_Amount_Amt__c = recovery.Core_MDF_Amount_Amt__c;//
                            rr.Core_MDF_Recovered_Budget_Nm__c = claimrec.Core_MDF_Budget_Type_Options_Nm__c+';'+claimrec.Core_MDF_Region_Cd__c+'='+recovery.Core_MDF_Amount_Amt__c;//
                            rr.Core_MDF_RecoveredPartnershipScoreDetail__c =  claimdet.claimToPSD.get(claimrec.id)+'-'+recovery.Core_MDF_Amount_Amt__c;//
                            rr.Core_MDF_Is_System_Created_Ind__c = true;
                            rr.Core_MDF_Recovery__c = recovery.id;
                            rr.Core_MDF_Active_Ind__c = false;
                            rr.Core_MDF_Ready_to_Recover_Ind__c = false;
                            rr.Core_MDF_Claim_External_ID__c = extClaimId+'='+recovery.Id;
                            
         return rr;
    }
/***********************************************************************************************************   
Method Name:        createRecoveryIns 
@return  :          Core_MDF_Recovery__c
Parameter :         PartnerFundClaim, ClaimDetails, Decimal(PFC Record Instance, Wrapper Instance, Amount)
Description:        This method is used create instance of SObject Core_MDF_Recovery__c for a particular claim
Added By:           Accenture - Amey - 05/03/2025
Modified By:        Date:       Changes: 
*************************************************************************************************************/  
    public Core_MDF_Recovery__c createRecoveryIns(PartnerFundClaim claimrec,ClaimDetails claimdet,Decimal recoveryAmt){
                        Core_MDF_Recovery__c recoveryObj = new Core_MDF_Recovery__c();
                        recoveryObj.Core_MDF_Amount_Amt__c =  recoveryAmt;
                        recoveryObj.Core_MDF_Claim_Id__c = claimrec.id;
                        recoveryObj.Core_MDF_PartnershipGradeMaintenance_Nbr__c=claimdet.claimToPartnerGradient.get(claimrec.id);
                        recoveryObj.Core_MDF_Recovered_Budget_Nm__c = claimrec.Core_MDF_Budget_Type_Options_Nm__c+';'+claimrec.Core_MDF_Region_Cd__c+'='+recoveryAmt;
                        recoveryObj.Core_MDF_Sure_Pay_Ind__c = true;  
        return recoveryObj;
    }

}