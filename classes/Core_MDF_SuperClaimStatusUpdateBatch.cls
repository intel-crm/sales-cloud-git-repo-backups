/*********************************
Class Name  : Core_MDF_SuperClaimStatusUpdateBatch
Function    : [Final Outcome Base]: Daily Job sync of Super claim status
Modification Log :
* Developer              Date          Description
* ---------------------------------------------------------------------------- 
* Naveen Valmiki     13/01/2026    Original version
**********************************/
public without sharing class Core_MDF_SuperClaimStatusUpdateBatch implements Database.Batchable<SObject>{
   
    public String statusToSet;     
    public Core_MDF_CCP_Custom_Metadata_Utility__c superClaimRec;
    public Map<String, String> finalStatusMap;
    public Map<String, Integer> pref;    
    public Set<String> superClaimstatus = new Set<String>();
    public Decimal bestRank ;
    public Set<Id> superClaimIds;
    public DateTime lastBatchRunDate;
    public DateTime CurrentDateTime;
   
    public Core_MDF_SuperClaimStatusUpdateBatch() {
        superClaimRec = getMetadataUtility();
        finalStatusMap = finalStatusMethod();
        pref = preferenceStatus();
        bestRank = pref.size();
        CurrentDateTime = System.now();
    }

    public Core_MDF_SuperClaimStatusUpdateBatch(Set<id> superClaimIds,DateTime lastBatchRunDate) {
        superClaimRec = getMetadataUtility();
        finalStatusMap = finalStatusMethod();
        pref = preferenceStatus();
        bestRank = pref.size();
        CurrentDateTime = System.now();
        this.superClaimIds = superClaimIds;
        this.lastBatchRunDate = lastBatchRunDate;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Integer SOQL_Limit = Integer.valueOf(superClaimRec.Core_MDF_Number_1_num__c);
        Integer SOQL_Days = Integer.valueOf(superClaimRec.Core_MDF_Value__c);
        Set<id> superClaimId = new Set<id>();
        superClaimstatus=pref.keyset();
        String soql = 'SELECT PartnerFundClaim.Core_MDF_Claim_Id__c FROM PartnerFundClaimHistory where Field=\'Core_MDF_Status__c\' AND PartnerFundClaim.Core_MDF_Claim_Id__c!=null AND ';
        if(lastBatchRunDate!=null){
        soql += ' CreatedDate>='+lastBatchRunDate;
        } 
        else{
            soql += ' CreatedDate>= LAST_N_DAYS:'+SOQL_Days;
        }
        soql += ' LIMIT :SOQL_Limit';
        for(PartnerFundClaimHistory ch : Database.Query(soql)){
            superClaimId.add(ch.PartnerFundClaim.Core_MDF_Claim_Id__c);
        }
        if(superClaimIds!=null){
            return Database.getQueryLocator('SELECT Id,Core_MDF_Status__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,(select id,Core_MDF_Status__c from claims__r) from PartnerFundClaim where Core_MDF_Status__c in :superClaimstatus AND id in :superClaimIds');
        } else {
            return Database.getQueryLocator('SELECT Id,Core_MDF_Status__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,(select id,Core_MDF_Status__c from claims__r) from PartnerFundClaim where Core_MDF_Status__c in :superClaimstatus AND id in :superClaimId');
        }
    }

    public void execute(Database.BatchableContext bc, List<PartnerFundClaim> scope) {    
        if(!scope.isEmpty()){  
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            claimList.addAll((List<PartnerFundClaim>) scope);
            List<Partnerfundclaim> updateClaimList = new List<Partnerfundclaim>();
            for(Partnerfundclaim claim : claimList){
                system.debug('@@@claim parent is'+claim);
            if(claim.Core_MDF_Status__c.equals(superClaimRec.Core_MDF_Field_5_txt__c) && (claim.Core_MDF_Member_Manual_Hold_Ind__c || claim.Core_MDF_Intel_Manual_Hold_Ind__c)){
                    continue;
            }
            String bestStatus='';
            Boolean otherStatus = false;
            Boolean pendingPayment;
            Decimal bestOrder = bestRank;
            for (Partnerfundclaim cl : claim.claims__r) {
                system.debug('@@@claim child is'+cl);
                if(!pref.keyset().contains(cl.Core_MDF_Status__c)){
                    otherStatus=true;
                    break;
                }
                if(cl.Core_MDF_Status__c.equals(superClaimRec.Core_MDF_Field_4_txt__c)){
                    if(pendingPayment!=false){
                    pendingPayment = true;
                    }
                }else {
                    pendingPayment = false;
                }
                if (pref.containsKey(cl.Core_MDF_Status__c)) {
                    Decimal r = pref.get(cl.Core_MDF_Status__c);

                    if (r < bestOrder) {
                        bestOrder = r;
                        bestStatus = cl.Core_MDF_Status__c;
                    }
                }
            }
            if((!otherStatus) && ((pendingPayment && claim.Core_MDF_Status__c!=superClaimRec.Core_MDF_Field_4_txt__c) || 
            (!String.isBlank(bestStatus) && finalStatusMap.containsKey(bestStatus) && claim.Core_MDF_Status__c!=finalStatusMap.get(bestStatus)))){
	            Partnerfundclaim updateclaim = new Partnerfundclaim();
	            updateclaim.id = claim.id;
                if(pendingPayment){
                    updateclaim.Core_MDF_Status__c = superClaimRec.Core_MDF_Field_4_txt__c;
                }
                else {
	            updateclaim.Core_MDF_Status__c = finalStatusMap.get(bestStatus);
                }
                system.debug('@@@updateclaim is'+updateclaim);
	            updateClaimList.add(updateclaim);
            }
        }
        if(!updateClaimList.isEmpty()){
        Database.SaveResult[] results = Database.update(updateClaimList, false);        
        String errorMessage = '';
        try{
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                Id failedId = updateClaimList[i].Id;
                errorMessage='FAILED Id = ' + failedId;
                for (Database.Error err : results[i].getErrors()) {
                    errorMessage+='-Error = ' + err.getMessage()+ '\n';
                }
            }
        }
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
            List<Map<String, String>> coreLogMaps = new List<Map<String, String>>();
            Map<String, String> coreLogMap = new Map<String, String>();
        if(!String.isBlank(errorMessage)){
            coreLogMap.put('Core_Origin__c', 'Core_MDF_SuperClaimStatusUpdateBatch');
            coreLogMap.put('Core_Severity__c', 'High');
            coreLogMap.put('Core_sObjectType__c', 'PartnerFundClaim');
            coreLogMap.put('Core_Project__c', 'Consolidated Co-Marketing Program (CCP)');
            coreLogMap.put('Core_Details__c', errorMessage);
            coreLogMaps.add(coreLogMap);
        }
        if (!coreLogMaps.isEmpty()) {
            Core_MDF_CCP_UtilityClass.createLogEntries(coreLogMaps);
        }
        }
    }
    }
    public void finish(Database.BatchableContext bc) {  }
        
    private Map<String, Integer> preferenceStatus() {
        Map<String, Integer> prefStatus = new Map<String, Integer>();
        List<String> claimSt = superClaimRec.Core_MDF_Field_2_txt__c.split(',');
        for(Integer i = 0; i < claimSt.size(); i++){
            prefStatus.put(claimSt[i], i);
        }
        return prefStatus;
    }

    private Map<String, String> finalStatusMethod() {
        Map<String, String> finalStatus = new Map<String, String>();
        List<String> finalClaimSt = superClaimRec.Core_MDF_Field_3_txt__c.split(','); 
        for(Integer i = 0; i < finalClaimSt.size(); i += 2){
            finalStatus.put(finalClaimSt[i], finalClaimSt[i+1]);
        }
        return finalStatus;
    }

    private Core_MDF_CCP_Custom_Metadata_Utility__c getMetadataUtility() {
        String className = Core_MDF_SuperClaimStatusUpdateBatch.class.getName();
        Core_MDF_CCP_Custom_Metadata_Utility__c superClaimRec = [Select id,Core_MDF_Field_2_txt__c,Core_MDF_Field_5_txt__c,Core_MDF_Field_3_txt__c,Core_MDF_Field_4_txt__c,Core_MDF_Number_1_num__c,Core_MDF_Value__c from Core_MDF_CCP_Custom_Metadata_Utility__c where name=:className Limit 1];
        return superClaimRec;
    }

}