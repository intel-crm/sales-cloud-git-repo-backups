/****************************************************************************************************************************************
* Class Name  : Core_MDF_Batch_UpdateRecoveryClaims 
* Version     : 1.0   
* Created Date: 23/march/2022
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture         23/march/2022                    Batch class to process the Recovery records and handle the CLaim updates     
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Batch_UpdateRecoveryClaims implements Database.Batchable<sObject>,Database.Stateful {
    
    //Claim Statuses allowed for Recovery (Payment Due and Pending Available Funds)
    public List<String> statusesAllowedForRecovery= Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Status_allowed_for_Recovery');
    public String claimType=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Type');
    //map to store the claims
    public Map<Id,PartnerFundClaim> mapOfClaims = new Map<Id,PartnerFundClaim>();
    public static set<String> programs_For_Node_Account = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
    public static List<String> core_MDF_Program_Recovery_Preselection = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Program_Recovery_Preselection');

    //map to store the claim ID with list of recoveries
    public Map<ID,List<Core_MDF_Recovery__c>> clmIdToClmRecovery=new Map<ID,List<Core_MDF_Recovery__c>>();
    public static List<Integer> thirdMonthsList = Core_MDF_CustomLabelConfig.getIntegerList('Core_MDF_RecoveryRunMonthsCCF_DCF');
    public static String month_data = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Current_Month');
    //List of Incoming RecoveryRecoveryRequestWrap wrapper
    public List<RecoveryRecoveryRequestWrap> recoveryWrapperList = new List<RecoveryRecoveryRequestWrap>();
    //Set of claim ids for which recovery process was successfull
    public set<id> claimIdSet = new set<id>();
    public list<id> accountIdList = new list<id>();
    public list<id> expliciteAccIdlst = new list<id>();
    public list<string> budTypeList = new list<string>();
    public list<string> regionList = new list<string>();
    public string program;
    public string budgetType;
    public string quarterYear;
    public string accountIds;
    public string expliciteAccIds;
    public string regions;
    public string source;
    public boolean isRecReq_RecvryDone;
    public boolean isPreSelClaim_RecvryDone;
    public Core_MDF_Recovery_Batch.recoveryDataWrapper accProgBudTypRegnWrapper = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
    
    /******************************************
     Recovery & Recovery Request Wrapper
     ******************************************/
    /*public class RecoveryRecoveryRequestWrap
    {
        public Core_MDF_Recovery__c recovery;
        public Core_MDF_Recovery_Request__c recRequest;
    }*/
    
    //contructor to get the list of claims
	public Core_MDF_Batch_UpdateRecoveryClaims(List<RecoveryRecoveryRequestWrap> recWrapperList){
        
        this.recoveryWrapperList = recWrapperList;
        try
        {
            
            if(!recWrapperList.isEmpty())
            {
                for(RecoveryRecoveryRequestWrap recWrap : recWrapperList)
                {
                    if(!clmIdToClmRecovery.containsKey(recWrap.recovery.Core_MDF_Claim_Id__c))
                    {
                        clmIdToClmRecovery.put(recWrap.recovery.Core_MDF_Claim_Id__c,new List<Core_MDF_Recovery__c>());
                    }
                    clmIdToClmRecovery.get(recWrap.recovery.Core_MDF_Claim_Id__c).add(recWrap.recovery);
				}
            }

          
            if(!clmIdToClmRecovery.isEmpty() && clmIdToClmRecovery.size()>0)
            {
               
                //Map of claims to process for amount and status update
                mapOfClaims=new Map<Id,PartnerFundClaim> ([SELECT Id,Amount,Core_MDF_Status__c,Core_MDF_Requested_Reimbursement_Amt__c, Core_MDF_Total_Claim_Recovery_Amount__c,AllocationId, Allocation.Amount, Allocation.TotalApprovedFcs,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,
                                                                                    Core_MDF_Claim_Previous_Status__c,ChannelPartnerId,ChannelPartner.Core_MDF_Auto_Transfer_Account__c,Request.ChannelPartnerId,
                                                                                    Allocation.Core_MDF_Available_Allocation_Amount__c,CreatedDate,BudgetId,Status,Core_MDF_Number_Of_Recoveries_Nbr__c from PartnerFundClaim where Id IN :clmIdToClmRecovery.KeySet() AND Core_MDF_Type_Txt__c=:claimType AND Core_MDF_Status__c IN: statusesAllowedForRecovery]);
            }
        }
        Catch(Exception e){system.debug(e.getMessage());}
    }
    public Core_MDF_Batch_UpdateRecoveryClaims(List<RecoveryRecoveryRequestWrap> recWrapperList,Core_MDF_Recovery_Batch.recoveryDataWrapper wrapperForRerunBatch){
        this.recoveryWrapperList = recWrapperList;
        accProgBudTypRegnWrapper = wrapperForRerunBatch;
        try
        {
            
            if(!recWrapperList.isEmpty())
            {
                for(RecoveryRecoveryRequestWrap recWrap : recWrapperList)
                {
                    if(!clmIdToClmRecovery.containsKey(recWrap.recovery.Core_MDF_Claim_Id__c))
                    {
                        clmIdToClmRecovery.put(recWrap.recovery.Core_MDF_Claim_Id__c,new List<Core_MDF_Recovery__c>());
                    }
                    clmIdToClmRecovery.get(recWrap.recovery.Core_MDF_Claim_Id__c).add(recWrap.recovery);
				}
            }

        
            if(!clmIdToClmRecovery.isEmpty() && clmIdToClmRecovery.size()>0)
            {
               
                //Map of claims to process for amount and status update
                mapOfClaims=new Map<Id,PartnerFundClaim> ([SELECT Id,Amount,Core_MDF_Status__c,Core_MDF_Requested_Reimbursement_Amt__c, Core_MDF_Total_Claim_Recovery_Amount__c,AllocationId, Allocation.Amount, Allocation.TotalApprovedFcs,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,
                                                                                    Core_MDF_Claim_Previous_Status__c,ChannelPartnerId,ChannelPartner.Core_MDF_Auto_Transfer_Account__c,Request.ChannelPartnerId,
                                                                                    Allocation.Core_MDF_Available_Allocation_Amount__c,CreatedDate,BudgetId,Status,Core_MDF_Number_Of_Recoveries_Nbr__c from PartnerFundClaim where Id IN :clmIdToClmRecovery.KeySet() AND Core_MDF_Type_Txt__c=:claimType AND Core_MDF_Status__c IN: statusesAllowedForRecovery]);
            }
        }
        Catch(Exception e){system.debug(e.getMessage());}
        
        program = wrapperForRerunBatch.program;
        if(wrapperForRerunBatch.bdgtTypeList != null){
        budgetType = String.join(wrapperForRerunBatch.bdgtTypeList,',');
        budTypeList = wrapperForRerunBatch.bdgtTypeList;
        }
        quarterYear =wrapperForRerunBatch.qtryr;
        if(wrapperForRerunBatch.accntListId != null){
        accountIds =String.join(wrapperForRerunBatch.accntListId,',');
        accountIdList = wrapperForRerunBatch.accntListId;
        }
        if(wrapperForRerunBatch.regionList != null){
        regions =String.join(wrapperForRerunBatch.regionList,',');
        regionList = wrapperForRerunBatch.regionList;
        }
        source =wrapperForRerunBatch.source;
        isRecReq_RecvryDone =wrapperForRerunBatch.isRecReq_RecvryDone;
        isPreSelClaim_RecvryDone = wrapperForRerunBatch.isPreSelClaim_RecvryDone;
        expliciteAccIds = wrapperForRerunBatch.expliciteAccIds;
        if(!String.isBlank(expliciteAccIds)){
            expliciteAccIdlst = expliciteAccIds.split(',');
        }

    }

      
    public  Iterable<sObject> start(Database.BatchableContext bContext) 
    {
        
        return mapOfClaims.values();
    }
    
    public void execute(Database.BatchableContext bContext, List<sObject> scopeRecords) {
        //map to store the non-PAF claims (payment due)
        Map<Id,PartnerFundClaim> mapOfNonPAFClaims=new Map<Id,PartnerFundClaim>();
        //map to store the PAF claims
        Map<Id,PartnerFundClaim> mapOfPAFClaim = new Map<Id,PartnerFundClaim>();
        Map<Id,List<Core_MDF_Recovery__c>> mapOfRecoveriesToInsert = new Map<Id,List<Core_MDF_Recovery__c>>();
        List<Core_MDF_Recovery__c> recoveriesToInsert = new List<Core_MDF_Recovery__c>();
        try{
            
            for(PartnerFundClaim claim:(List<PartnerFundClaim>) scopeRecords){
                //checking if claim amount is greater that recovery amount,reducing recovery amount from claim amount

                //ATHR - Deeply Nested if 16209
                if(claim == null || claim.Amount == null || claim.Amount <= 0 || !clmIdToClmRecovery.containsKey(claim.Id)) {
                    continue;
                }
                
                    //Loop through recoveries for each claim
                    for(Core_MDF_Recovery__c recovery:clmIdToClmRecovery.get(claim.id)){
                        //ATHR - Deeply Nested if 16209
                        if(recovery == null || claim.Amount < recovery.Core_MDF_Amount_Amt__c) {
                            continue;
                        }

                            claim.Amount =(claim.Amount - recovery.Core_MDF_Amount_Amt__c);
                            if(claim.Core_MDF_Number_Of_Recoveries_Nbr__c!=null){
                                claim.Core_MDF_Number_Of_Recoveries_Nbr__c += 1;
                            }
                            else
                                claim.Core_MDF_Number_Of_Recoveries_Nbr__c = 1;  
                            if(claim.Amount==0){
                                claim.Core_MDF_Status__c=Label.Core_MDF_Status_Paid;
                                claim.Core_MDF_Recovery_Hold_Ind__c = false;  
                            }
                            
                            if(claim.Core_MDF_Status__c =='Pending Available Fund'){
                              
                                mapOfPAFClaim.put(claim.id,claim);
                            }
                            else{
                                mapOfNonPAFClaims.put(claim.id,claim);
                            }
                            //recoveriesToInsert.add(recovery);
                            if(!mapOfRecoveriesToInsert.containsKey(claim.id)){
                                mapOfRecoveriesToInsert.put(claim.id, new List<Core_MDF_Recovery__c>());
                            }
                            mapOfRecoveriesToInsert.get(claim.id).add(recovery);
                    }
            }
            
            List<Database.SaveResult> updateResults = new List<Database.SaveResult>();
            //Non PAF
            if(!mapOfNonPAFClaims.isempty()){
               
                updateResults.addAll(Database.update(mapOfNonPAFClaims.values(),false));
            }
            //PAF
            if(!mapOfPAFClaim.isempty()){
                
                Core_MDF_ProcessCCP_Claim.fundReservation(mapOfPAFClaim,true);
                updateResults.addAll(Database.update(mapOfPAFClaim.values(),false));
            }
            //Update failed claims, recoveries are removed for insert 
            for(Database.SaveResult res : updateResults){
              
                if(!res.isSuccess()){
                    mapOfRecoveriesToInsert.remove(res.getId());
                }
            }
            //iterating all the final recoveries to insert
            for(List<Core_MDF_Recovery__c> recoveries:mapOfRecoveriesToInsert.values()){
                recoveriesToInsert.addAll(recoveries);
            }
            //Insert all eligible recoveries with rollback if any recovery failed to insert: AllorNone insert.        
            List<Database.SaveResult> recoveriesResult = Database.insert(recoveriesToInsert,true);
            
            //Get the recovery request records and match claim id and recovered amount from recovery and update
            List<Core_MDF_Recovery_Request__c> recovertyRequestsToUpdate = new List<Core_MDF_Recovery_Request__c>();
            if(!recoveriesResult.isEmpty())
            {
                Set<Id> recReqIdSet = new Set<Id>();
                for(RecoveryRecoveryRequestWrap recWrapper :recoveryWrapperList){
                    recReqIdSet.add(recWrapper.recRequest.Id);
                }
               
               Map<Id,Core_MDF_Recovery_Request__c> idToRecReqMap = New Map<Id,Core_MDF_Recovery_Request__c>([Select id , Core_MDF_Active_Ind__c, Core_MDF_Claim_Id__c,Core_MDF_Recovery__c,
                                                Core_MDF_Recovery_Amount_Amt__c,Core_MDF_RecoveredPartnershipScoreDetail__c, Core_MDF_Claim_External_ID__c, Core_MDF_Ready_to_Recover_Ind__c from Core_MDF_Recovery_Request__c where id in:recReqIdSet]);
                
                for(Core_MDF_Recovery__c insertedRecovery : recoveriesToInsert){
                    for(RecoveryRecoveryRequestWrap recWrapper :recoveryWrapperList){
                       if(recWrapper.recovery.Core_MDF_Claim_Id__c==insertedRecovery.Core_MDF_Claim_Id__c
                        && idToRecReqMap.containsKey(recWrapper.recRequest.Id) && idToRecReqMap.get(recWrapper.recRequest.Id).Core_MDF_Claim_Id__c != null
                        && idToRecReqMap.get(recWrapper.recRequest.Id).Core_MDF_Claim_Id__c ==insertedRecovery.Core_MDF_Claim_Id__c
                        && recWrapper.recovery.Core_MDF_Amount_Amt__c==insertedRecovery.Core_MDF_Amount_Amt__c)
                        {
                            Core_MDF_Recovery_Request__c recRequest = new Core_MDF_Recovery_Request__c();
                            recRequest = idToRecReqMap.get(recWrapper.recRequest.Id);
                            recRequest.Core_MDF_Recovery__c = insertedRecovery.id;
                            recRequest.Core_MDF_Active_Ind__c = false;
                            recRequest.Core_MDF_Ready_to_Recover_Ind__c = false;
                            recRequest.Core_MDF_Claim_External_ID__c = recRequest.Core_MDF_Claim_External_ID__c+'='+insertedRecovery.Id;
                            recovertyRequestsToUpdate.add(recRequest);
                            //Collecting claim ids of successful recoveries
                            claimIdSet.add(insertedRecovery.Core_MDF_Claim_Id__c);
                        }    
                    }
                }
            }
            if(!recovertyRequestsToUpdate.isEmpty()){
                update recovertyRequestsToUpdate;
                Core_MDF_Recovery_Utility.updatePartnershipScoreDetailMapping(recovertyRequestsToUpdate);
            }
                
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new DMLException('Exception Occured:::'+e);}
        //Loop through all claims for recoveries
        
    }
    
    public void finish(Database.BatchableContext bContext) {
        Integer currMonth = System.today().month();
            if(month_data!=null && month_data!=''){
                currMonth = Integer.valueOf(month_data);
            }
            else{
                currMonth = System.today().month(); 
            }
        Integer batchSize = Integer.ValueOf(Core_MDF_Configuration__c.getValues('Core_MDF_RecoveryClaimUpdateBatch_Size').Core_MDF_Value__c);
        List<Core_MDF_Batch_Scheduler__c> batchSchedulerList = new List<Core_MDF_Batch_Scheduler__c>();
        if(source == 'Payment Run' && isRecReq_RecvryDone == false && isPreSelClaim_RecvryDone == false){
            // try{
            
            // Core_MDF_Recovery_Batch recoveryBatchReRun = new Core_MDF_Recovery_Batch(program,  budgetType,  quarterYear,  accountIds, regions, source, true, false);
            // database.executeBatch(recoveryBatchReRun,batchSize);
            // }
            // catch(Exception e){
              
                try{
                    if(programs_For_Node_Account.contains(program)||((core_MDF_Program_Recovery_Preselection.contains(program)) && thirdMonthsList.contains(currMonth))){
                        Core_MDF_Recovery_Batch recoveryBatchReRun = new Core_MDF_Recovery_Batch(program,  budgetType,  quarterYear,  accountIds, regions, source, true, false);
                        database.executeBatch(recoveryBatchReRun,batchSize);
                    }
                }
                catch(Exception e){
                    Core_MDF_Recovery_Batch.runBatch(program,  budgetType,  quarterYear,  accountIds, regions, source, true, false); 
                    
                }
                // Core_MDF_Batch_Scheduler__c customSch = new Core_MDF_Batch_Scheduler__c();
                // /*customSch.Core_MDF_Object_JSON_Txt__c = '{"program" : "' + program + '","budgetType" : "' + budgetType + '","quarterYear" : "' + quarterYear + '","accountIds" : "' + accountIds + 
                // '","regions" : "' + regions + '","source" : "' + source + '","isRecReq_RecvryDone" : ' + isRecReq_RecvryDone_batch_scheduler 
                // + ',"isPreSelClaim_RecvryDone" : ' + isPreSelClaim_RecvryDone_batch_scheduler + ',"Ultimate_Node_Account_Map" : ' + Ultimate_Node_Account_Map +
                // ',"finalRecoveryList" : ' + finalRecoveryList +',"isRecoveryAllowed" : ' + isRecoveryAllowed +'}';*/

                // customSch.Core_MDF_Object_JSON_Txt__c = '{"program" : "' + program + '","budgetType" : "' + budgetType + '","quarterYear" : "' + quarterYear + '","accountIds" : "' + accountIds + 
                // '","regions" : "' + regions + '","source" : "' + source + '","isRecReq_RecvryDone" : ' + true 
                // + ',"isPreSelClaim_RecvryDone" : ' + false +'}';

                // customSch.Core_MDF_Batch_Size_Nbr__c = 50;
                // Datetime now = Datetime.now();
                
                // customSch.Scheduled_Time_Dt__c = now.addMinutes(10);
                               
                // customSch.Core_MDF_Batch_Class_Name_Txt__c = 'Core_MDF_Recovery_Batch';
                // customSch.Core_MDF_Job_Frequency__c = 'Once';
                // customSch.Core_MDF_Priority__c = 'High';
                // customSch.Core_MDF_Program_Txt__c = 'CCP';
           
                // batchSchedulerList.add(customSch);
                // if(!batchSchedulerList.isEmpty()){
                //     Database.insert(batchSchedulerList);
                // }
                
            //}

        }else if(source == 'Payment Run' && ((isRecReq_RecvryDone == true && isPreSelClaim_RecvryDone == false) ||(isRecReq_RecvryDone == true && isPreSelClaim_RecvryDone == true))){
            //query claims which are recovery hold to true and update the claim with recvoery hold as false
            Core_MDF_Batch_ClmRemoveRecoveryHold removeRecoveryHoldBatchRun = new Core_MDF_Batch_ClmRemoveRecoveryHold(expliciteAccIdlst,budTypeList,regionList,program,claimIdSet);
            database.executeBatch(removeRecoveryHoldBatchRun,batchSize);
            
            //uncheckClmRecoveryHoldInd();
        }
        
               

    }
    //in case recovery hold marked true but for that account nothing to be recvoered so then how those claims will be revered?(assuming we are providing account in claim query below)
    //i was thingking if we have general query to get claim based only on recovery hold to true
    //if for a program if there are no amount to be recvoery then as well we'll uncheck the claim's recvoery hold right? for that program?
    //in this case we'll need to excute this method in th beginning of the recovery batch as well 
    public void uncheckClmRecoveryHoldInd() {
        //accProgBudTypRegnWrapper
        
        //list<PartnerFundClaim> clmLst = [select id,Core_MDF_Recovery_Hold_Ind__c,Core_MDF_Program__c from PartnerFundClaim where Core_MDF_Recovery_Hold_Ind__c =true  and Core_MDF_Program__c = :program];
        String strQuery = '';
        strQuery = 'select id,Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_Region_Cd__c,';
        strQuery += ' Core_MDF_Program__c, ChannelPartnerId, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Recovery_Hold_Ind__c ';
        strQuery += 'from PartnerFundClaim ';
        strQuery += 'where Core_MDF_Recovery_Hold_Ind__c =true and ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =:program and ';
        if(programs_For_Node_Account.contains(program)){
            strQuery += 'ChannelPartnerId in:accountIdList ';
        }
        else{
            strQuery += 'ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c in:accountIdList ';
        }
    
        if(budTypeList!= null && budTypeList.size()>1){
                    strQuery += ' and Core_MDF_Budget_Type_Options_Nm__c in:budTypeList '; 
        }
        
        list<PartnerFundClaim> clmLst = Database.query(strQuery);
        
        list<PartnerFundClaim> clmlstToBUpdated = new list<PartnerFundClaim>();
        for(PartnerFundClaim clm : clmLst){
            clm.Core_MDF_Recovery_Hold_Ind__c = false;
            clmlstToBUpdated.add(clm);
        }
       
        if(clmlstToBUpdated.size()>0){
            update clmlstToBUpdated;
        }
    }
}