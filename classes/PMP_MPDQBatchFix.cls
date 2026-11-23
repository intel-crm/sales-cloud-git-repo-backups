global class PMP_MPDQBatchFix
implements Database.Batchable<SObject>, Database.Stateful {
    
    public static final String INVALID_TIER = 'UNDETERMND';
    
    public static String logEntryMsgString = '';
    public List<PRM_IPA_DQ_Logs__c> dqLogList = new List<PRM_IPA_DQ_Logs__c>();
    public List<SObject> allCompanyUpdates = new List<SObject>();
    public List<SObject> allWorkingCopyUpdates = new List<SObject>();
    public List<SObject> allRelUpdates = new List<SObject>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        DateTime lastSuccessfulRun;
        Integer batchExecutionInterval = Integer.ValueOf(System.Label.PMP_MPDQBatch_ExecutionHours);
        DateTime batchExecutionHours = System.now().addHours(-batchExecutionInterval);        
        List<AsyncApexJob> lastBatchRun = [SELECT CompletedDate FROM AsyncApexJob WHERE ApexClass.Name ='PMP_MPDQBatchFix' AND Status = :System.Label.PRM_AsyncStatus ORDER BY CompletedDate DESC LIMIT 1];
        String excludedUserName = System.Label.PMP_MPDQBatchString1;        
        Boolean applyUserFilter = String.isNotBlank(excludedUserName) && excludedUserName != '__IGNORE__';
        
        String query ='SELECT Id, PRM_Account_Id__c, PRM_Account_Id__r.Id FROM PRM_AccountChannelMembership__c WHERE PRM_Account_Id__r.RecordType.DeveloperName = \'Core_Partner_Account_Group\' ';
        
        if (!lastBatchRun.isEmpty()) {
            lastSuccessfulRun = lastBatchRun[0].CompletedDate;
            query += 'AND (LastModifiedDate > :batchExecutionHours OR LastModifiedDate > :lastSuccessfulRun) ';
        } else {
            query += 'AND LastModifiedDate > :batchExecutionHours ';
        }
        
        if (applyUserFilter) {
            query += 'AND LastModifiedBy.Name != :excludedUserName ';
        }
        
        System.debug('PMP_MPDQBatchFix SOQL => ' + query);
        
        return Database.getQueryLocator(query);
    }
    /* =========================================================
EXECUTE
========================================================= */
    global void execute(Database.BatchableContext bc,List<PRM_AccountChannelMembership__c> scope) {       
        if (scope.isEmpty()) return;        
        /* ---------------------------------------------------------
1. OPID Accounts associated with the ACMs which got modified
--------------------------------------------------------- */
        Set<Id> impactedAccountIds = new Set<Id>();
        for (PRM_AccountChannelMembership__c acm : scope) {
            if (acm.PRM_Account_Id__c != null) {
                impactedAccountIds.add(acm.PRM_Account_Id__r.Id);
            }
        }
        if (impactedAccountIds.isEmpty()) return;
        
        //Get the PAG Accounts of those OPID's
        List<PMP_OPID_MPI_Rel__c> deltaRels = [SELECT Id, Is_Active__c,LastModifiedDate, PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c,PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c FROM PMP_OPID_MPI_Rel__c
                                               WHERE PMP_One_Partner_ID__c IN :impactedAccountIds AND /*Is_Active__c = true and*/ (PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c ='Published' or PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c ='Draft') ];
        if (deltaRels.isEmpty()) return;
        //store accid,active pag       
        Map<Id, List<PMP_OPID_MPI_Rel__c>> accIdToPAGs = new Map<Id, List<PMP_OPID_MPI_Rel__c>>();
        //Get the MPI ids of associated PAG's
        Set<Id> publishedCompanyIds = new Set<Id>();
        for (PMP_OPID_MPI_Rel__c r : deltaRels) {
            
            if (r.PMP_Marketing_Profile_Id__c != null) {
                publishedCompanyIds.add(r.PMP_Marketing_Profile_Id__c);
            }
        }
        if (publishedCompanyIds.isEmpty()) return;
        // Since the each MPI can have multiple PAG associations, query all the PAG's associated with each of the MPI
        List<PMP_OPID_MPI_Rel__c> allRels = [SELECT Id, Is_Active__c, LastModifiedDate, PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c FROM PMP_OPID_MPI_Rel__c
                                             WHERE PMP_Marketing_Profile_Id__c IN :publishedCompanyIds /*AND Is_Active__c = true*/];
        Map<Id,PMP_OPID_MPI_Rel__c> relIdMap = new Map<Id,PMP_OPID_MPI_Rel__c>();
        //optimisation Loop1
        /*
for(PMP_OPID_MPI_Rel__c rel : allRels){
relIdMap.put(rel.Id, rel);
}*/
        // ✅ NEW: Bulk fetch Is_Active__c history once
        Set<Id> relIds = new Set<Id>();
        //optimisation Loop2
        /*for (PMP_OPID_MPI_Rel__c r : allRels) {
if (r.PMP_One_Partner_ID__c != null /*&& r.Is_Active__c==true*///) {               
        /* if (!accIdToPAGs.containsKey(r.PMP_One_Partner_ID__c)) {
accIdToPAGs.put(r.PMP_One_Partner_ID__c, new List<PMP_OPID_MPI_Rel__c>());
}               
accIdToPAGs.get(r.PMP_One_Partner_ID__c).add(r);
}
relIds.add(r.Id);
}*/
        system.debug('accIdToPAGs---'+accIdToPAGs);
        
        Map<Id, Datetime> relLastDeactivatedMap = new Map<Id, Datetime>();
        
        // ✅ FINAL: Latest deactivated REL per ACCOUNT
        Map<Id, PMP_OPID_MPI_Rel__c> accToLatestRel = new Map<Id, PMP_OPID_MPI_Rel__c>();
        Map<Id, Datetime> accToLatestDate = new Map<Id, Datetime>();
        list<PMP_OPID_MPI_Rel__History> histPAG =  [
            SELECT ParentId, CreatedDate, NewValue
            FROM PMP_OPID_MPI_Rel__History
            WHERE Field = 'Is_Active__c'
            AND ParentId IN :relIds ORDER BY CreatedDate DESC
        ];
        for (PMP_OPID_MPI_Rel__History hist : histPAG) {
            if (String.valueOf(hist.NewValue) == 'false') {
                PMP_OPID_MPI_Rel__c rel = relIdMap.get(hist.ParentId);
                if (rel == null) {
                    continue;
                }
                Id accId = rel.PMP_One_Partner_ID__c;
                Datetime existing = accToLatestDate.get(accId);
                if (existing == null || hist.CreatedDate > existing) {
                    accToLatestDate.put(accId, hist.CreatedDate);
                    accToLatestRel.put(accId, rel);
                }
            }
        }
        system.debug('accToLatestRel---'+accToLatestRel);
        system.debug('accToLatestDate--'+accToLatestDate);
        //This map stores the  MPI ID, List<PAGs>
        Map<Id, List<PMP_OPID_MPI_Rel__c>> companyToRels = new Map<Id, List<PMP_OPID_MPI_Rel__c>>();
        //optimisation LOOp3
        /*for (PMP_OPID_MPI_Rel__c r : allRels) {
if (!companyToRels.containsKey(r.PMP_Marketing_Profile_Id__c)) {
companyToRels.put(r.PMP_Marketing_Profile_Id__c,new List<PMP_OPID_MPI_Rel__c>());
}
companyToRels.get(r.PMP_Marketing_Profile_Id__c).add(r);
}    */
        for (PMP_OPID_MPI_Rel__c rel : allRels) {                    
            relIdMap.put(rel.Id, rel);                   
            relIds.add(rel.Id);                    
            if (rel.PMP_One_Partner_ID__c != null) {                    
                if (accIdToPAGs.get(rel.PMP_One_Partner_ID__c) == null) {
                    accIdToPAGs.put(
                        rel.PMP_One_Partner_ID__c,
                        new List<PMP_OPID_MPI_Rel__c>()
                    );
                }                        
                accIdToPAGs.get(rel.PMP_One_Partner_ID__c).add(rel);
            }
            
            if (companyToRels.get(rel.PMP_Marketing_Profile_Id__c) == null) {
                companyToRels.put(rel.PMP_Marketing_Profile_Id__c,new List<PMP_OPID_MPI_Rel__c>());
            }                  
            companyToRels.get(rel.PMP_Marketing_Profile_Id__c).add(rel);
        }
        Map<Id, Set<Id>> companyToAccountIds = new Map<Id, Set<Id>>();
        Set<Id> allAccountIds = new Set<Id>();
        for (Id cid : companyToRels.keySet()) {
            Set<Id> accs = new Set<Id>();
            for (PMP_OPID_MPI_Rel__c r : companyToRels.get(cid)) {
                accs.add(r.PMP_One_Partner_ID__c);
                allAccountIds.add(r.PMP_One_Partner_ID__c);
            }
            companyToAccountIds.put(cid, accs);
        }
        //GET ALL PAG, AND ITS ACCOUNT . FROM THAT WE WILL CALCULATE THE LATEST RELATED PAG TO EACH ACCOUNT.
        //Get all the acms associated with each MPI
        Map<Id, List<PRM_AccountChannelMembership__c>> acctToActiveACMs = new Map<Id, List<PRM_AccountChannelMembership__c>>();
        for (PRM_AccountChannelMembership__c acm : [SELECT PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Account_Id__r.Core_Account_Type__c
                                                    FROM PRM_AccountChannelMembership__c WHERE PRM_Account_Id__c IN :allAccountIds AND PRM_Status_Nm__c = 'Approved' AND PRM_Partner_Role__c != 'Guest'
                                                   ]) {
                                                       if (!acctToActiveACMs.containsKey(acm.PRM_Account_Id__c)) {
                                                           acctToActiveACMs.put(acm.PRM_Account_Id__c,new List<PRM_AccountChannelMembership__c>());
                                                       }
                                                       acctToActiveACMs.get(acm.PRM_Account_Id__c).add(acm);
                                                   }
        
        Map<Id, PMP_Company__c> publishedCompanyMap =  new Map<Id, PMP_Company__c>([SELECT Id,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_IPA_Badge_Tier_Txt__c,PMP_Working_Copy_Id__r.PMP_Partner_Program_nm__c,
                                                                                    PMP_IPA_Badge_Tier_Txt__c, PMP_Partner_Program_nm__c,PMP_Account_Program_Membership__c,PMP_Working_Copy_Id__r.PMP_Account_Program_Membership__c,
                                                                                    PMP_Benefit_Update_Ind__c,PMP_Working_Copy_Id__r.PMP_Benefit_Update_Ind__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c
                                                                                    FROM PMP_Company__c WHERE Id IN :publishedCompanyIds]);
        //get the sf's associated to the ACM/Account , if the store front is inactive and also pag is inactive, we need to see which if the active account has any other sf/pag active associated, if not we need to active any one sf
        
        
        List<SObject> companyUpdates = new List<SObject>();
        List<SObject> workingCopyUpdates = new List<SObject>();
        List<PMP_OPID_MPI_Rel__c> relUpdates = new List<PMP_OPID_MPI_Rel__c>();
        Set<Id> queuedRelIds = new Set<Id>();
        Set<Id> workingCopyIds = new Set<Id>();
        //Map<Id,SObject> companyPcMap = new Map<Id,SObject>();
        Map<Id,PMP_Company__c> companyPcMap = new Map<Id,PMP_Company__c>();
        Map<String, Integer> tierRank = new Map<String, Integer>{'Member' => 1, 'Gold' => 2, 'Titanium' => 3,'Partner' => 4, 'Prestige' => 5};
            Map<Integer, String> rankToTier = new Map<Integer, String>{1 => 'Member', 2 => 'Gold', 3 => 'Titanium', 4 => 'Partner', 5 => 'Prestige'};
                
                //with that one OPID IS there any active store front presnt then dont do that in this parti
                for (Id companyId : companyToRels.keySet()) {        
                    PMP_Company__c pub = publishedCompanyMap.get(companyId);
                    if (pub == null) continue;            
                    List<PRM_AccountChannelMembership__c> activeACMs =
                        new List<PRM_AccountChannelMembership__c>();
                    Set<Id> accIds = companyToAccountIds.get(companyId);
                    for (Id accId : accIds) {                       
                        if (acctToActiveACMs.containsKey(accId)) {
                            activeACMs.addAll(acctToActiveACMs.get(accId));
                        }
                    }
                    
                    Boolean IfInactivatedMPI = false;            
                    
                    Boolean hasActiveACM = !activeACMs.isEmpty();           
                    Boolean hasAnyActivePAG = false;
                    
                    
                    
                    List<PMP_OPID_MPI_Rel__c> rels = companyToRels.get(companyId);
                    
                    for (PMP_OPID_MPI_Rel__c r : rels) {
                        if (r.Is_Active__c) {
                            hasAnyActivePAG = true;
                            break;
                        }
                    }
                    
                    Boolean changed = false;
                    Boolean inactivateMPI = false;
                    boolean inactiveOPIDMPIREL=false;
                    // accIdToPAGs
                    if(hasActiveACM  && hasAnyActivePAG && pub.PMP_Benefit_Update_Ind__c){ 
                        pub.PMP_Benefit_Update_Ind__c = false;
                        changed = true;
                    }
                    
                    else if(hasActiveACM && !hasAnyActivePAG){
                        
                        for (Id accId : accIds) {
                            
                            // Account must have approved ACM
                            if (!acctToActiveACMs.containsKey(accId)) {
                                continue;
                            }
                            
                            // Check whether account already has an active PAG anywhere
                            Boolean hasActivePagForAccount = false;
                            
                            if (accIdToPAGs.containsKey(accId)) {
                                
                                for (PMP_OPID_MPI_Rel__c rel : accIdToPAGs.get(accId)) {
                                    
                                    if (rel.Is_Active__c) {
                                        hasActivePagForAccount = true;
                                        break;
                                    }
                                }
                            }
                            
                            if (hasActivePagForAccount) {
                                continue;
                            }
                            
                            PMP_OPID_MPI_Rel__c latestRel = accToLatestRel.get(accId);
                            
                            if (latestRel == null || latestRel.Is_Active__c) {
                                continue;
                            }
                            
                            if (!queuedRelIds.contains(latestRel.Id)) {
                                latestRel.Is_Active__c = true;
                                relUpdates.add(latestRel);
                                queuedRelIds.add(latestRel.Id);                                
                                logEntryMsgString += '\nReactivated latest deactivated PAG '+ latestRel.Id + ' for Account ' + accId;
                            }
                        }
                    }    
                    /*  else if(hasActiveACM  && !hasAnyActivePAG){
//make the last associated mpi active
// Track if any active PAG exists across ALL companies for involved accounts
Boolean hasActivePAGAnywhere = false;
//JUST TAKE companyToRels ,LATETS T ONE AND ACTIVATE
PMP_OPID_MPI_Rel__c latestRel;
Datetime latestDate;

// Find latest relation for these accounts (you can refine ordering field)
for (PMP_OPID_MPI_Rel__c rel : rels) {
if (accIds.contains(rel.PMP_One_Partner_ID__c)) {
if (latestDate == null || rel.LastModifiedDate > latestDate) {
latestDate = rel.LastModifiedDate;
latestRel = rel;
}
}
}

// Activate the latest rel
if (latestRel != null && !latestRel.Is_Active__c) {
latestRel.Is_Active__c = true;
relUpdates.add(latestRel);
}
// Loop all rels (all companies) for these accounts
/* for (PMP_OPID_MPI_Rel__c rel : allRels) {
if (rel.Is_Active__c && accIds.contains(rel.PMP_One_Partner_ID__c)) {
hasActivePAGAnywhere = true;
break;
}
}
if (!hasActivePAGAnywhere) {

PMP_OPID_MPI_Rel__c latestRel;
Datetime latestDate;

// Find latest relation for these accounts (you can refine ordering field)
for (PMP_OPID_MPI_Rel__c rel : rels) {
if (accIds.contains(rel.PMP_One_Partner_ID__c)) {
if (latestDate == null || rel.LastModifiedDate > latestDate) {
latestDate = rel.LastModifiedDate;
latestRel = rel;
}
}
}

// Activate the latest rel
if (latestRel != null && !latestRel.Is_Active__c) {
latestRel.Is_Active__c = true;
relUpdates.add(latestRel);
}
}
}*/
                    // Case 3: ❌ ACM, ✅ PAG → MPI INACTIVE + PAG INACTIVE
                    else if (!hasActiveACM && hasAnyActivePAG) {
                        inactivateMPI = true;
                        inactiveOPIDMPIREL=true;
                        // deactivate all PAGs
                        for (PMP_OPID_MPI_Rel__c r : rels) {
                            if (r.Is_Active__c) {
                                r.Is_Active__c = false;
                                relUpdates.add(r);
                            }
                        }
                    }
                    
                    // Case 4: ❌ ACM, ❌ PAG → MPI INACTIVE
                    else if (!hasActiveACM && !hasAnyActivePAG) {
                        //check for benefit indicator
                        if (!pub.PMP_Benefit_Update_Ind__c) {
                            inactivateMPI = true;}
                    }
                    
                    /* =========================================================
APPLY MPI CHANGE
========================================================= */
                    
                    if (!inactiveOPIDMPIREL && inactivateMPI) {
                        if (!pub.PMP_Benefit_Update_Ind__c) {
                            pub.PMP_Benefit_Update_Ind__c = true;
                            IfInactivatedMPI = true;
                        }
                    }
                    if(!inactiveOPIDMPIREL && !IfInactivatedMPI && pub.PMP_Benefit_Update_Ind__c==false){
                        String programMembership = '';
                        String partnerProgram = '';
                        
                        
                        Integer highestRank = 0;
                        
                        for (PRM_AccountChannelMembership__c acm : activeACMs) {
                            
                            String tierName = acm.PRM_Channel_Program_Level_Id__r.Name;
                            if (tierRank.containsKey(tierName)) {
                                highestRank = Math.max(
                                    highestRank, tierRank.get(tierName)
                                );
                            }
                            
                            if (tierName != INVALID_TIER && String.isNotBlank(acm.PRM_Partner_Role__c)) {
                                
                                String progMembership =PMP_AccountBenefitPartnerUtility.getProgramMembership(acm);                     
                                programMembership =PMP_AccountBenefitPartnerUtility.formatAndPopulateMultiPicklistForProgramMembership(programMembership,progMembership);
                            }
                            
                            // ✅ USE UTILITY METHOD FOR PARTNER PROGRAM
                            if (String.isNotBlank(acm.PRM_Partner_Role__c)) {                       
                                partnerProgram = PMP_AccountBenefitPartnerUtility.formatAndPopulateMultiPicklist(partnerProgram,acm.PRM_Partner_Role__c);
                            }
                        }
                        
                        String finalTier = rankToTier.get(highestRank);
                        system.debug('finalTier----'+finalTier);
                        system.debug('pub.PMP_IPA_Badge_Tier_Txt__c=-='+pub.PMP_IPA_Badge_Tier_Txt__c);
                        if (pub.PMP_IPA_Badge_Tier_Txt__c != finalTier) {
                            pub.PMP_IPA_Badge_Tier_Txt__c = finalTier;
                            changed = true;
                        }
                        String existingProgram = normalizeProgramMembership(pub.PMP_Partner_Program_nm__c);
                        
                        String computedProgram =normalizeProgramMembership(partnerProgram);
                        
                        if (existingProgram != computedProgram) {
                            pub.PMP_Partner_Program_nm__c = partnerProgram;
                            changed = true;
                        }
                        system.debug('pub.PMP_Account_Program_Membership__c=='+pub.PMP_Account_Program_Membership__c);
                        system.debug('programMembership====='+programMembership);
                        /*  if (pub.PMP_Account_Program_Membership__c != programMembership) {
pub.PMP_Account_Program_Membership__c = programMembership;
changed = true;
}*/
                        String existingMembership = normalizeProgramMembership(pub.PMP_Account_Program_Membership__c);
                        
                        String computedMembership =normalizeProgramMembership(programMembership);
                        
                        
                        if (existingMembership != computedMembership) {
                            pub.PMP_Account_Program_Membership__c = programMembership;
                            changed = true;
                        }
                        /*if (pub.PMP_Benefit_Update_Ind__c) {
pub.PMP_Benefit_Update_Ind__c = false;
changed = true;
}*/}
                    
                    if (!inactiveOPIDMPIREL && (IfInactivatedMPI || changed)) {
                        companyUpdates.add(pub);
                        companyPcMap.put(pub.id,pub);
                        system.debug('companyUpdates.add(pub);'+companyUpdates);
                        workingCopyIds.add(pub.PMP_Working_Copy_Id__r.id);
                    }
                } 
        system.debug('workingCopyUpdatess1'+workingCopyUpdates);
        //GET THE WORKING COPIES FOR UPDATED PUBLISHED MPIS AND MAKE CHANGE ON THEM AS WELL
        List<PMP_Company__c> CompanyWCList = New List<PMP_Company__c>();
        CompanyWCList = [Select Id,PMP_Company_Lifecycle_Status_Nm__c,PMP_IPA_Badge_Tier_Txt__c,PMP_Partner_Program_nm__c,PMP_Account_Program_Membership__c,PMP_Benefit_Update_Ind__c,PMP_Published_Copy_Id__c,
                         PMP_Published_Copy_Id__r.PMP_IPA_Badge_Tier_Txt__c,PMP_Published_Copy_Id__r.PMP_Partner_Program_nm__c,PMP_Published_Copy_Id__r.PMP_Account_Program_Membership__c,PMP_Published_Copy_Id__r.PMP_Benefit_Update_Ind__c from PMP_Company__c where Id IN :workingCopyIds];
        for(PMP_Company__c wc:CompanyWCList){
            system.debug('companyUpdates.add(pub)11;'+companyPcMap);
            if (companyPcMap.get(wc.PMP_Published_Copy_Id__c) != null) {
                // PMP_Company__c wc = new PMP_Company__c( Id = pub.PMP_Working_Copy_Id__r.id);
                if(wc.PMP_Company_Lifecycle_Status_Nm__c=='Approved' || wc.PMP_Company_Lifecycle_Status_Nm__c=='Draft'){                  
                    //PMP_Company__c pubCompany =(PMP_Company__c) companyPcMap.get(wc.PMP_Published_Copy_Id__c);                    
                    PMP_Company__c pubCompany = companyPcMap.get(wc.PMP_Published_Copy_Id__c);
                    If(pubCompany.PMP_Benefit_Update_Ind__c && (wc.PMP_Benefit_Update_Ind__c!=pubCompany.PMP_Benefit_Update_Ind__c)){
                        wc.PMP_Benefit_Update_Ind__c = pubCompany.PMP_Benefit_Update_Ind__c;}
                    else{
                        wc.PMP_IPA_Badge_Tier_Txt__c = pubCompany.PMP_IPA_Badge_Tier_Txt__c;
                        wc.PMP_Partner_Program_nm__c = pubCompany.PMP_Partner_Program_nm__c;
                        wc.PMP_Account_Program_Membership__c = pubCompany.PMP_Account_Program_Membership__c;
                        wc.PMP_Benefit_Update_Ind__c = pubCompany.PMP_Benefit_Update_Ind__c;
                    }
                    
                    system.debug('workingCopyUpdatess'+workingCopyUpdates);
                    workingCopyUpdates.add(wc);
                }
            }
        }
        
        
        if (!companyUpdates.isEmpty()) {
            allCompanyUpdates.addAll(companyUpdates);
        }
        
        if (!workingCopyUpdates.isEmpty()) {
            allWorkingCopyUpdates.addAll(workingCopyUpdates);
        }
        if (!relUpdates.isEmpty()) {
            allRelUpdates.addAll(relUpdates);
        }
    }
    private void handleDml(List<SObject> records, String objectName) {
        if (records.isEmpty()) return;
        
        Database.SaveResult[] results = Database.update(records, false);
        
        String message = 'Time: ' + System.now();
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                for(Database.Error err: sr.getErrors()){
                    logEntryMsgString+= 'Message: ' + err.getMessage() + '\n' + 'Fields: ' + err.Fields.toString() + '\n' + 'StatusCode: ' + err.getStatusCode() + '\n';
                }
            } else {
                if(objectName =='PMP_Company__c')
                    message += '\nMPI Record Published Copy Update SUCCESS for matching Tier,Role,ProgramMembership and/or Benefit indicator with ACM – RecordId: ' + sr.getId();
                else if(objectName=='PMP_Company__c(Working Copy)')
                    message+='\nMPI Record Working Copy Update SUCCESS for matching Tier,Role,ProgramMembership and/or Benefit indicator with Published Copy – RecordId: ' + sr.getId();
                else if(objectName == 'PMP_OPID_MPI_Rel__c')
                    message+='\nOPID_MPI_Rel Record Update SUCCESS for matching isActive Indicator based on ACM – RecordId: ' + sr.getId();
                
            }
            
        }
        
        dqLogList.add(new PRM_IPA_DQ_Logs__c(
            PRM_Object_Name__c = objectName,
            PRM_Apex_Class_Name__c = 'PMP_MPDQBatchFix',
            PRM_Message__c = message
        ));
    }
    
    public void sendWarningEmail(List<sObject> dmlList, String objectName){
        
        try{
            Map<String, Map<String, Object>> dqObjectsMap = getCustomMetadataRecords();
            list<id> dmlids = new list<id>();
            // Get scenario description from custom metadata using helper method
            String scenarioDescription = '';
            // Get scenario description based on object name
            if(dqObjectsMap != null && !dqObjectsMap.isEmpty()){
                for(String metadataRec : dqObjectsMap.keySet()){
                    if(dqObjectsMap.get(metadataRec).get('Object__c') == objectName){
                        scenarioDescription = (String)dqObjectsMap.get(metadataRec).get('Scenario__c');
                        break;
                    }
                }
            }
            
            // Fallback to default message if no scenario found
            if(String.isEmpty(scenarioDescription)){
                scenarioDescription = 'There is some issue in the below MPI records. ';
            }
            
            // Prepare placeholder map similar to opidAssociationEmail
            Map<String,String> placeholderMap = new Map<String,String>();
            placeholderMap.put('%ObjectName%', objectName);
            placeholderMap.put('%RecordCount%', String.valueOf(dmlList.size()));
            placeholderMap.put('%ScenarioDescription%', scenarioDescription != null ? scenarioDescription : 'Records will be updated as part of PMP_MPDQBatchFix processing.');
            placeholderMap.put('%ProcessDate%', String.valueOf(System.today()));
            
            // Call email utility from PRM_OPIDProcessUtility
            PRM_OPIDProcessUtility.callSendEmailUtil(placeholderMap, 'IPA_DQ_Email');
            for(SObject c:dmlList){
                dmlids.add(c.id);
            }
            PRM_IPA_DQ_Logs__c dqLog = new PRM_IPA_DQ_Logs__c();
            dqLog.PRM_Object_Name__c=objectName;
            dqLog.PRM_Message__c = scenarioDescription + String.join(dmlids, ', ');
            dqLog.PRM_Apex_Class_Name__c = 'PMP_MPDQBatchFix';
            dqLogList.add(dqLog);
            logEntryMsgString += '\n[WarningEmailSent] Using PRM_EmailUtility for ' + objectName + ' with ' + dmlList.size() + ' records';           
        } catch(Exception e){
            logEntryMsgString += '\n[WarningEmailSendFailed] ' + e.getMessage();
        }
    }
    
    public  Map<String, Map<String, Object>> getCustomMetadataRecords (){
        Map<String, Map<String, Object>> dqObjectsMap = new Map<String, Map<String, Object>>();
        Core_CustomMetadataObjectController customMetadataController = new Core_CustomMetadataObjectController('DQ_Objects_mdt');
        dqObjectsMap = customMetadataController.getAll();
        return dqObjectsMap;
    }
    
    private static String normalizeProgramMembership(String value) {
        if (String.isBlank(value)) return '';
        
        List<String> parts = value.split(';');
        for (Integer i = 0; i < parts.size(); i++) {
            parts[i] = parts[i].trim();
        }
        parts.sort();
        return String.join(parts, ';');
    }
    
    
    global void finish(Database.BatchableContext bc) {
        Decimal threshold;
        Map<String, Map<String, Object>> dqObjectsMap = getCustomMetadataRecords();
        system.debug('dqObjectsMap===='+dqObjectsMap);
        if(dqObjectsMap != null && !dqObjectsMap.isEmpty()){
            if(dqObjectsMap.containsKey('Threshold')){
                threshold = Decimal.valueOf(String.valueOf(dqObjectsMap.get('Threshold').get('Threshold__c')));
            }}
        // Handle Published Company Updates
        if(test.isrunningtest()){
            threshold=3;
        }
        if (!allCompanyUpdates.isEmpty()) {
            if (allCompanyUpdates.size() < threshold) {
                handleDml(allCompanyUpdates, 'PMP_Company__c');
            } else {
                sendWarningEmail(allCompanyUpdates,'PMP_Company__c');
            }
        }
        
        // Handle Working Copy Updates
        if (!allWorkingCopyUpdates.isEmpty()) {
            if (allWorkingCopyUpdates.size() < threshold) {
                handleDml(allWorkingCopyUpdates,'PMP_Company__c(Working Copy)');
            } else {
                sendWarningEmail(allWorkingCopyUpdates,'PMP_Company__c(Working Copy)');
            }
        }
        if (!allRelUpdates.isEmpty()) {
            if (allRelUpdates.size() < threshold) {
                handleDml(allRelUpdates, 'PMP_OPID_MPI_Rel__c');
            } else {
                sendWarningEmail(allRelUpdates, 'PMP_OPID_MPI_Rel__c');
            }
        }
        List<Database.SaveResult> dqResultList = New List<Database.SaveResult> ();
        if (!dqLogList.isEmpty()) {
            dqResultList =  Database.insert(dqLogList, false);
        }
        if(!dqResultList.isEmpty()){
            for(Database.SaveResult dqResult: dqResultList){
                if(!dqResult.isSuccess()){
                    for (Database.Error err : dqResult.getErrors()) {
                        logEntryMsgString+= 'Message: ' + err.getMessage() + '\n'  + 'Fields: ' + err.Fields.toString() + '\n' + 'StatusCode: ' + err.getStatusCode() + '\n';
                    }
                }
            }
            string jobInitiatedDateTime = System.Now().format('MM/dd/YYYY HH:MM:SS','PST');
            if(logEntryMsgString!=''){// this block will create Log Entry records on the basis of length of logEntryMsg and Field limit.
                PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
                Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
                logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
                for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
                    Core_Log_Entry.logEntryWithDetails('PMP_MPDQFixBatch', 'MP', 'PMP_MPDQFixBatch', 'Medium','Job started at: '+ jobInitiatedDateTime +' PST' ,logEntryUtility.logEntryList[i] , '', '', '');
                }//loop ends here..
            }
        }
        /*  Long usedHeap   = Limits.getHeapSize();        
Long totalHeap  = Limits.getLimitHeapSize();
Decimal percent = (Decimal.valueOf(usedHeap) / Decimal.valueOf(totalHeap)) * 100;
System.debug('Heap Used (%): ' + percent.setScale(2));*/
        
    }
}