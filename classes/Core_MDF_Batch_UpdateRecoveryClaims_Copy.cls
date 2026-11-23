/****************************************************************************************************************************************
* Class Name  : Core_MDF_Batch_UpdateRecoveryClaims 
* Version     : 1.0   
* Created Date: 23/march/2022
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture         23/march/2022                    Batch class to process the Recovery records and handle the CLaim updates     
*****************************************************************************************************************************************/
public class Core_MDF_Batch_UpdateRecoveryClaims_Copy implements Database.Batchable<sObject>,Database.Stateful {
    
    //Claim Statuses allowed for Recovery (Payment Due and Pending Available Funds)
    public List<String> statusesAllowedForRecovery= Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Status_allowed_for_Recovery');
    public String claimType=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Type');
    //map to store the claims
    public Map<Id,PartnerFundClaim> mapOfClaims = new Map<Id,PartnerFundClaim>();
    //map to store the claim ID with list of recoveries
    public Map<ID,List<Core_MDF_Recovery__c>> clmIdToClmRecovery=new Map<ID,List<Core_MDF_Recovery__c>>();

    //List of Incoming RecoveryRecoveryRequestWrap wrapper
    public List<RecoveryRecoveryRequestWrap> recoveryWrapperList = new List<RecoveryRecoveryRequestWrap>();
    
    /******************************************
     Recovery & Recovery Request Wrapper
     ******************************************/
    /*public class RecoveryRecoveryRequestWrap
    {
        public Core_MDF_Recovery__c recovery;
        public Core_MDF_Recovery_Request__c recRequest;
    }*/
    
    //contructor to get the list of claims
	public Core_MDF_Batch_UpdateRecoveryClaims_Copy(List<RecoveryRecoveryRequestWrap> recWrapperList){
        
        this.recoveryWrapperList = recWrapperList;
        try
        {
            system.debug('recWrapperList: '+ recWrapperList);
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

            System.debug('94'+clmIdToClmRecovery);
            if(!clmIdToClmRecovery.isEmpty() && clmIdToClmRecovery.size()>0)
            {
                system.debug('--->'+claimType);
                system.debug('------->'+statusesAllowedForRecovery);
                //Map of claims to process for amount and status update
                mapOfClaims=new Map<Id,PartnerFundClaim> ([SELECT Id,Amount,Core_MDF_Status__c,Core_MDF_Requested_Reimbursement_Amt__c, Core_MDF_Total_Claim_Recovery_Amount__c,AllocationId, Allocation.Amount, Allocation.TotalApprovedFcs,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,
                                                                                    Core_MDF_Claim_Previous_Status__c,ChannelPartnerId,ChannelPartner.Core_MDF_Auto_Transfer_Account__c,Request.ChannelPartnerId,
                                                                                    Allocation.Core_MDF_Available_Allocation_Amount__c,CreatedDate,BudgetId,Status,Core_MDF_Number_Of_Recoveries_Nbr__c from PartnerFundClaim where Id IN :clmIdToClmRecovery.KeySet() AND Core_MDF_Type_Txt__c=:claimType AND Core_MDF_Status__c IN: statusesAllowedForRecovery]);
            }
        }
        Catch(Exception e){system.debug(e.getMessage());}
    }

      
    public  Iterable<sObject> start(Database.BatchableContext bContext) 
    {
        system.debug('---map'+mapOfClaims.size());
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
                system.debug(claim);
                system.debug(this.clmIdToClmRecovery);
                if(claim.Amount!=Null && claim.Amount>0 && clmIdToClmRecovery.containsKey(claim.id)){
                    //Loop through recoveries for each claim
                    for(Core_MDF_Recovery__c recovery:clmIdToClmRecovery.get(claim.id)){
                        system.debug('Claim amount --'+claim.Amount + ' Recovery amount'+recovery.Core_MDF_Amount_Amt__c);
                        if(claim.Amount>=recovery.Core_MDF_Amount_Amt__c){
                            claim.Amount =(claim.Amount - recovery.Core_MDF_Amount_Amt__c);
                            if(claim.Core_MDF_Number_Of_Recoveries_Nbr__c!=null){
                                claim.Core_MDF_Number_Of_Recoveries_Nbr__c += 1;
                            }
                            else
                                claim.Core_MDF_Number_Of_Recoveries_Nbr__c = 1;
                            if(claim.Amount==0){
                                claim.Core_MDF_Status__c=Label.Core_MDF_Status_Paid;  
                            }
                            if(claim.Core_MDF_Status__c =='Pending Available Fund'){
                                system.debug('117'+claim.Amount);
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
                }
            }
            system.debug('**PGM**'+mapOfPAFClaim);
            List<Database.SaveResult> updateResults = new List<Database.SaveResult>();
            //Non PAF
            if(!mapOfNonPAFClaims.isempty()){
                system.debug('131');
                updateResults.addAll(Database.update(mapOfNonPAFClaims.values(),false));
            }
            //PAF
            if(!mapOfPAFClaim.isempty()){
                system.debug('135');
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
                                                Core_MDF_Recovery_Amount_Amt__c,Core_MDF_RecoveredPartnershipScoreDetail__c from Core_MDF_Recovery_Request__c where id in:recReqIdSet]);
                
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
                            recovertyRequestsToUpdate.add(recRequest);
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
        
    }
}