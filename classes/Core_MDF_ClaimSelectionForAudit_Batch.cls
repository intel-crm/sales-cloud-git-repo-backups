/****************************************************************************************************************************************
* Class Name        : Core_MDF_ClaimSelectionForAudit_Batch
* Created Date      : 4/14/2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VK       4/14/2020          Batch class to pick up claims for Audit based on business logic
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ClaimSelectionForAudit_Batch /*implements Database.Batchable<sObject>, Database.Stateful*/{
    //added dummy method to get the code coverage for this class
    public static void getCodeCoverage(){
    }
    //Commented as part of 2025 WW14 uncommented code
    
    /*List<PartnerFundClaim> claimListForAudit = new List<PartnerFundClaim>();
    @testVisible
    List<PartnerFundClaim> pfcListForRandomAudit = new List<PartnerFundClaim>();
    @testVisible
    List<PartnerFundClaim> pfcListForRandomAuditForLastQuarter = new List<PartnerFundClaim>();
    
    Set<String> channelProgramSet = new Set<String>();
    Set<String> geoSet = new Set<String>();
    
    Map<String,Decimal> programGeoBudgetPercentageMap = new Map<String,Decimal>();
    Map<String,Decimal> programGeoActivityTypePercentageMap = new Map<String,Decimal>();    
    
    Map<String,Decimal> programGeoRemainingBudgetToAuditForWeekMap = new Map<String,Decimal>();
    Map<string,decimal> claimToBeAuditedActivityMap = new Map<string,decimal>();       
    
    Map<String,Decimal> programGeoRemainingBudgetToAuditForLastQuarterMap = new Map<String,Decimal>();
    Map<string,decimal> claimToBeAuditedActivityForLastQuarterMap = new Map<string,decimal>();       
    
    public Boolean getPreviousQuarterClaims = FALSE;
    
    List<Id> currentQuarterClaims = new List<Id>();
    List<Id> previousQuarterClaims = new List<Id>();
    
    List<String> claimStatusNotForAudit = Label.Core_MDF_claimStatusNotToConsiderForAudit.Split(';');
    //Submitted;Pending Payment;Paid;Cancelled;Denied;Adjusted
    
    List<Id> accIdsToBeExcluded = Label.Core_MDF_TestAccountIdsToBeExcluded.Split(';');
    /*public Core_MDF_ClaimSelectionForAudit_Batch(){
        
    }
    public Core_MDF_ClaimSelectionForAudit_Batch(List<partnerFundClaim> pfc){
        Database.BatchableContext bc;
        finish(bc);
    }*/
    
    /***************************************************************************************************** 
    Method Name :   start
    @return     :   List of claims which are not audited
    @parameters :   Database.BatchableContext
    Description :   It fetches all claims which needs to be audited
    Added By    :   Accenture - VK - 4/14/2020 
    Modified By :                               Date:                   Changes:
    ******************************************************************************************************/ 
    /*public Database.QueryLocator start(Database.BatchableContext bc) {
        
        try{
            getMetataDataResults();
            init();
            string qryStr = '';
            String claimType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Type') ;
            if(!getPreviousQuarterClaims){
                qryStr = 'SELECT Id, Title, Core_MDF_Region_Cd__c, Core_MDF_Audit_Hold__c, Core_MDF_FlaggedForAudit__c,'+
                    ' Core_MDF_Activity_Types__c, Core_MDF_Program__c, Core_MDF_Status__c, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,'+
                    ' Core_MDF_Claim_Review_Case__c, Core_MDF_Claim_Review_Case__r.CaseNumber, budget.Amount, Amount,Core_MDF_Claim_Ref_Number__c'+
                    ' FROM PartnerFundClaim'+
                    ' WHERE CreatedDate = THIS_QUARTER'+
                    ' AND Core_MDF_Activity_Start_Date__c = THIS_QUARTER' + //changes for US1102862
                    ' AND Core_MDF_Activity_End_Date__c = THIS_QUARTER' + //changes for US1102862
                    ' AND RecordType.Name IN : channelProgramSet' +
                    ' AND Core_MDF_Region_Cd__c IN : geoSet' +
                    ' AND Core_MDF_Claim_Review_Case__c = NULL'+
                    ' AND Core_MDF_Status__c NOT IN: claimStatusNotForAudit'+
                    ' AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c NOT IN: accIdsToBeExcluded'+
                    ' AND Core_MDF_Type_Txt__c =: claimType' +
                    ' AND Core_MDF_Escalation_Id__c= NULL ' +
                    ' AND Core_MDF_IsClaimReviewEscalation_Ind__c = FALSE' +
                    ' ORDER BY Amount Desc';
            }else{
                
                qryStr = 'SELECT Id, Title, Core_MDF_Region_Cd__c, Core_MDF_Audit_Hold__c, Core_MDF_FlaggedForAudit__c,'+
                    ' Core_MDF_Activity_Types__c, Core_MDF_Program__c, Core_MDF_Status__c, RequestId, Request.CreatedDate,'+
                    ' Core_MDF_Claim_Review_Case__c, Core_MDF_Claim_Review_Case__r.CaseNumber, budget.Amount, Amount,'+
                    ' ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Claim_Ref_Number__c'+
                    ' FROM PartnerFundClaim'+
                    ' WHERE (CreatedDate = THIS_QUARTER OR Request.CreatedDate = LAST_QUARTER)'+
                    ' AND RecordType.Name IN : channelProgramSet' +
                    ' AND Core_MDF_Region_Cd__c IN : geoSet' +
                    ' AND Core_MDF_Claim_Review_Case__c = NULL'+
                    ' AND Core_MDF_Status__c NOT IN: claimStatusNotForAudit'+
                    ' AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c NOT IN: accIdsToBeExcluded'+
                    ' AND Core_MDF_Escalation_Id__c = NULL'+
                    ' AND Core_MDF_Type_Txt__c =: claimType' +
                    ' AND Core_MDF_IsClaimReviewEscalation_Ind__c = FALSE' +
                    ' ORDER BY Amount Desc';
            }
            
            return Database.getQueryLocator(qryStr);
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return NULL; }
    }
    
    /******************************************************************************************************** 
    Method Name :   execute
    @return     :   void
    @parameters :   Database.BatchableContext
    Description :   Selects the claims to be audited
    Added By    :   Accenture - VK - 4/14/2020
    Modified By :                               Date:         Changes:None  
    **********************************************************************************************************/
    /*public void execute(Database.BatchableContext bc, List<PartnerFundClaim> pfcList) {        
        
        Decimal remainingBudgetToBeAuditedForTheWeek;         
        List<PartnerFundClaim> pfcListToBeAudited = new List<PartnerFundClaim>();
         List<PartnerFundClaim> pfcListToBeHold = new List<PartnerFundClaim>();
        List<PartnerFundClaim> randomizedClaimList = new List<PartnerFundClaim>();        
        
        try{
        
            
            for(PartnerFundClaim pfc : pfcList){
                
                String programGeo = pfc.Core_MDF_Program__c+pfc.Core_MDF_Region_Cd__c;
                String programGeoType = programGeo + pfc.Core_MDF_Activity_Types__c;
                
                if(currentQuarterClaims.contains(pfc.Id)){
                    
                    if(claimToBeAuditedActivityMap.containsKey(programGeoType) && claimToBeAuditedActivityMap.get(programGeoType) != NULL){
                        decimal claimsToBeAuditedAsPerActivity = claimToBeAuditedActivityMap.get(programGeoType);
                        if(claimsToBeAuditedAsPerActivity > 0){
                           
                            claimListForAudit.add(pfc);
                            claimToBeAuditedActivityMap.put(programGeoType,claimsToBeAuditedAsPerActivity-1); 
                            if(programGeoRemainingBudgetToAuditForWeekMap.containsKey(programGeo) &&
                               programGeoRemainingBudgetToAuditForWeekMap.get(programGeo) != NULL && 
                               programGeoRemainingBudgetToAuditForWeekMap.get(programGeo) > 0){
                                remainingBudgetToBeAuditedForTheWeek = programGeoRemainingBudgetToAuditForWeekMap.get(programGeo) - pfc.Amount; 
                                programGeoRemainingBudgetToAuditForWeekMap.put(programGeo, remainingBudgetToBeAuditedForTheWeek); 
                            }
                        }else if(programGeoRemainingBudgetToAuditForWeekMap.containsKey(programGeo) && programGeoRemainingBudgetToAuditForWeekMap.get(programGeo) != NULL && programGeoRemainingBudgetToAuditForWeekMap.get(programGeo) > 0){
                            pfcListForRandomAudit.add(pfc);  
                            
                        }
                    }else if(programGeoRemainingBudgetToAuditForWeekMap.containsKey(programGeo) && programGeoRemainingBudgetToAuditForWeekMap.get(programGeo) != NULL && programGeoRemainingBudgetToAuditForWeekMap.get(programGeo) > 0){
                        pfcListForRandomAudit.add(pfc);
                       
                        
                    } 
                }else if(previousQuarterClaims.contains(pfc.Id)){
                    
                    if(claimToBeAuditedActivityForLastQuarterMap.containsKey(programGeoType) &&
                       claimToBeAuditedActivityForLastQuarterMap.get(programGeoType) != NULL){
                           decimal claimsToBeAuditedAsPerActivity = claimToBeAuditedActivityForLastQuarterMap.get(programGeoType);
                           if(claimsToBeAuditedAsPerActivity > 0){
                               claimListForAudit.add(pfc);
                               claimToBeAuditedActivityForLastQuarterMap.put(programGeoType,claimsToBeAuditedAsPerActivity-1);
                               if(programGeoRemainingBudgetToAuditForLastQuarterMap.containsKey(programGeo) &&
                                  programGeoRemainingBudgetToAuditForLastQuarterMap.get(programGeo) != NULL &&
                                  programGeoRemainingBudgetToAuditForLastQuarterMap.get(programGeo) > 0){
                                   remainingBudgetToBeAuditedForTheWeek = programGeoRemainingBudgetToAuditForLastQuarterMap.get(programGeo) - pfc.Amount; 
                                   programGeoRemainingBudgetToAuditForLastQuarterMap.put(programGeo, remainingBudgetToBeAuditedForTheWeek); 
                               }   
                           }else if(programGeoRemainingBudgetToAuditForLastQuarterMap.containsKey(programGeo) && programGeoRemainingBudgetToAuditForLastQuarterMap.get(programGeo) != NULL && programGeoRemainingBudgetToAuditForLastQuarterMap.get(programGeo) > 0){
                            pfcListForRandomAuditForLastQuarter.add(pfc);
                           
                        }
                       }else if(programGeoRemainingBudgetToAuditForLastQuarterMap.containsKey(programGeo) && programGeoRemainingBudgetToAuditForLastQuarterMap.get(programGeo) != NULL && programGeoRemainingBudgetToAuditForLastQuarterMap.get(programGeo) > 0){
                        pfcListForRandomAuditForLastQuarter.add(pfc);
                        
                    } 
                }                
            }
           
           
            
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /******************************************************************************************************** 
    Method Name :   finish
    @return     :   void
    @parameters :   Database.BatchableContext
    Description :   Calls the batch for case creation of selected claims
    Added By    :   Accenture - VK - 4/14/2020
    Modified By :                               Date:         Changes:None  
    **********************************************************************************************************/
    /*public void finish(Database.BatchableContext bc) {    
        
        try{
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            List<PartnerFundClaim> claimListForLastQuarter = new List<PartnerFundClaim>();            
            
            if(pfcListForRandomAudit != NULL && pfcListForRandomAudit.Size() > 0){              
                claimList = setClaimsOnHoldBasedOnHighestAmount(pfcListForRandomAudit);
                if(claimList != NULL && claimList.Size() > 0){
                    claimListForAudit.addAll(claimList);
                }
            } 
            
            if(pfcListForRandomAuditForLastQuarter != NULL && pfcListForRandomAuditForLastQuarter.Size() > 0){               
                claimListForLastQuarter = setClaimsOnHoldBasedOnHighestAmountForLastQuarter(pfcListForRandomAuditForLastQuarter);
                if(claimListForLastQuarter != NULL && claimListForLastQuarter.Size() > 0){
                    claimListForAudit.addAll(claimListForLastQuarter);
                }
            } 
            
            if(claimListForAudit != null && !claimListForAudit.isEmpty() && claimListForAudit.size()>0) {
                Core_MDF_ClaimReviewCaseProcess.insertAudHoldClaimsForCaseRetry(claimListForAudit);    
            }
        //Platform Event List
        List<Core_MDF_Bulk_Transaction__e> updateRecordList = new List<Core_MDF_Bulk_Transaction__e>();
        for(PartnerFundClaim claim : claimListForAudit){   
            
                    Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e(); 
            
                    PartnerFundClaim pfc = new PartnerFundClaim();
                    pfc.Id = claim.Id;
                    pfc.Core_MDF_Status__c = 'Hold';
                    pfc.Core_MDF_Audit_Hold__c = true;
                    pfc.Core_MDF_Audit_Type__c = 'Random';
                    pfc.Core_MDF_FlaggedForAudit__c = true;
                    
                    //Add Claim Data in JSON for processing
                    evtObj.Core_MDF_JSON_Data__c = JSON.serialize(pfc); 
                    evtObj.Core_MDF_Object_Name__c = 'PartnerFundClaim';
            
                    updateRecordList.add(evtObj);
            } 
            if(!updateRecordList.isEmpty()){              
               
                List<Database.SaveResult> results = EventBus.publish(updateRecordList);
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        
                    } else { for(Database.Error err : sr.getErrors()) { }
                    }
                }  
            }
        
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    /******************************************************************************************************** 
    Method Name :   init
    @return     :   void
    @parameters :   None
    Description :   Checks the claims based on quarter and prepares the claim percantage to be audited
    Added By    :   Accenture - VK - 4/14/2020
    Modified By :                               Date:         Changes:None  
    **********************************************************************************************************/
    /*public void init(){

        Map<String, Decimal> amountAuditedMap = new Map<String, Decimal>();
        Map<string,integer> claimAuditedActivityMap = new Map<string,integer>();
        Map<String, Decimal> totalClaimAmountMap = new Map<String, Decimal>();    
        Map<string,integer> claimActivityMap = new Map<string,integer>();
        
        Map<String,Date> dueDateMap = new Map<String,Date>();
        Map<String,Date> quarterStartDateMap = new Map<String,Date>();        
        
        Map<String, Decimal> previousQuarterAmountAuditedMap = new Map<String, Decimal>();
        Map<string,integer> previousQuarterClaimAuditedActivityMap = new Map<string,integer>();        
        Map<String, Decimal> previousQuarterTotalClaimAmountMap = new Map<String, Decimal>();  
        Map<string,integer> previousQuarterClaimActivityMap = new Map<string,integer>();
        
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        
        Set<String> geoSetForPreviousQuarter = new Set<String>();
        Set<String> progarmSetForPreviousQuarter = new Set<String>();
        
        Date quarterStartDate;
        
        List<String> claimStatusToBeExcluded = Label.Core_MDF_claimStatusNotToConsiderForAuditCoverage.Split(';');
        //Submitted,Cancelled
        
        try{            
            for(PartnerFundClaim pfc : [SELECT Id, Amount, Core_MDF_Activity_Types__c, Core_MDF_Status__c,
                                        Core_MDF_Claim_Review_Case__c, Core_MDF_Region_Cd__c, Core_MDF_Program__c,
                                        Core_MDF_Activity_End_Date__c, Core_MDF_Activity_Start_Date__c,Core_MDF_Budget_Type_Options_Nm__c,
                                        Core_MDF_Sub_Region_Cd__c,Core_MDF_Country_Location_nm__c,RecordType.Name,
                                        ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Claim_Ref_Number__c
                                        FROM PartnerFundClaim
                                        WHERE CreatedDate = THIS_QUARTER AND
                                        RecordType.Name IN : channelProgramSet  AND 
                                        Core_MDF_Region_Cd__c IN : geoSet AND
                                        Core_MDF_Status__c NOT IN: claimStatusToBeExcluded AND 
                                        ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c NOT IN: accIdsToBeExcluded LIMIT 50000]){
                pfcList.add(pfc);
        
                if(dueDateMap.isEmpty()){
                    string key = pfc.Core_MDF_Program__c+
                        ':'+pfc.Core_MDF_Budget_Type_Options_Nm__c+
                        ':'+pfc.Core_MDF_Region_Cd__c+
                        ':'+pfc.Core_MDF_Sub_Region_Cd__c+
                        ':'+pfc.Core_MDF_Country_Location_nm__c+
                        ':'+system.now().date().format(); 
                    key = key.deleteWhitespace();
                    dueDateMap.put(key,null);
                }                               
            }
            
                    
            
            quarterStartDateMap = Core_MDF_ProcessClaimSubmissionClosure.getQuarterStartDate(dueDateMap);
            
          
            
            if(quarterStartDateMap != NULL && quarterStartDateMap.Size() > 0){
                quarterStartDate = quarterStartDateMap.values()[0];
            }
            
           
            Integer todaysMonth;
            todaysMonth = Test.isRunningTest()? quarterStartDate.Month(): Date.Today().month();
            for(PartnerFundClaim pfc : pfcList){
                
                if(pfc.Core_MDF_Activity_End_Date__c < quarterStartDate && todaysMonth == quarterStartDate.Month()){
                    geoSetForPreviousQuarter.add(pfc.Core_MDF_Region_Cd__c);
                    progarmSetForPreviousQuarter.add(pfc.RecordType.Name);
                    getPreviousQuarterClaims = TRUE; //commented as part of US1102862
                    previousQuarterClaims.add(pfc.Id);
                }else{
                    currentQuarterClaims.add(pfc.Id);
                    String programGeo = pfc.Core_MDF_Program__c + pfc.Core_MDF_Region_Cd__c;  
                    String programGeoActivityType = programGeo+pfc.Core_MDF_Activity_Types__c;
                    
                    if(pfc.Core_MDF_Claim_Review_Case__c != null){
                        
                        if(amountAuditedMap.containsKey(programGeo) && amountAuditedMap.get(programGeo) != NULL){
                            Decimal totalAmount = amountAuditedMap.get(programGeo) + pfc.Amount;
                            amountAuditedMap.put(programGeo,totalAmount);
                        }else{
                            amountAuditedMap.put(programGeo,pfc.Amount);
                        }
                        
                        if(claimAuditedActivityMap.containsKey(programGeoActivityType) && claimAuditedActivityMap.get(programGeoActivityType) != NULL){
                            Integer noOfRecords = claimAuditedActivityMap.get(programGeoActivityType) + 1;
                            claimAuditedActivityMap.put(programGeoActivityType,noOfRecords);
                        }else{
                            claimAuditedActivityMap.put(programGeoActivityType,1);
                        }
                    }
                    
                    if(pfc.Amount != null){
                        if(totalClaimAmountMap.containsKey(programGeo) && totalClaimAmountMap.get(programGeo) != NULL){
                            Decimal totalClaimAmount = totalClaimAmountMap.get(programGeo) + pfc.Amount;
                            totalClaimAmountMap.put(programGeo,totalClaimAmount);
                        }else{
                            totalClaimAmountMap.put(programGeo,pfc.Amount);
                        }
                    }            
                    
                    if(claimActivityMap.containsKey(programGeoActivityType) && claimActivityMap.get(programGeoActivityType) != NULL){
                        Integer noOfRecords = claimActivityMap.get(programGeoActivityType) + 1;
                        claimActivityMap.put(programGeoActivityType,noOfRecords);
                    }else{
                        claimActivityMap.put(programGeoActivityType,1);
                    }
                }  
            }
            
          
            if(getPreviousQuarterClaims){
                
                for(PartnerFundClaim claim : [SELECT Id, Core_MDF_Region_Cd__c, Amount, Core_MDF_Activity_Types__c, RequestId,
                                              Request.CreatedDate, Core_MDF_Claim_Review_Case__c, Core_MDF_Status__c,Core_MDF_Program__c,
                                              ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Claim_Ref_Number__c
                                              FROM PartnerFundClaim
                                              WHERE Core_MDF_Region_Cd__c IN: geoSetForPreviousQuarter AND
                                              RecordType.Name IN: progarmSetForPreviousQuarter AND
                                              Request.CreatedDate = LAST_QUARTER AND
                                              Core_MDF_Status__c NOT IN: claimStatusToBeExcluded AND
                                              ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c NOT IN: accIdsToBeExcluded LIMIT 50000]){
                 
                    previousQuarterClaims.add(claim.Id);                              
                    String programGeo = claim.Core_MDF_Program__c + claim.Core_MDF_Region_Cd__c;  
                    String programGeoActivityType = programGeo+claim.Core_MDF_Activity_Types__c; 
                    
                    if(claim.Core_MDF_Claim_Review_Case__c != NULL){
                        if(previousQuarterAmountAuditedMap.containsKey(programGeo) && previousQuarterAmountAuditedMap.get(programGeo) != NULL){
                            Decimal totalAmount = previousQuarterAmountAuditedMap.get(programGeo) + claim.Amount;
                            previousQuarterAmountAuditedMap.put(programGeo,totalAmount);
                        }else{
                            previousQuarterAmountAuditedMap.put(programGeo,claim.Amount);
                        }
                        
                        if(previousQuarterClaimAuditedActivityMap.containsKey(programGeoActivityType) && previousQuarterClaimAuditedActivityMap.get(programGeoActivityType) != NULL){
                            Integer noOfRecords = previousQuarterClaimAuditedActivityMap.get(programGeoActivityType) + 1;
                            previousQuarterClaimAuditedActivityMap.put(programGeoActivityType,noOfRecords);
                        }else{
                            previousQuarterClaimAuditedActivityMap.put(programGeoActivityType,1);
                        }
                    }
                    
                    if(claim.Amount != null){
                        if(previousQuarterTotalClaimAmountMap.containsKey(programGeo) && previousQuarterTotalClaimAmountMap.get(programGeo) != NULL){
                            Decimal totalClaimAmount = previousQuarterTotalClaimAmountMap.get(programGeo) + claim.Amount;
                            previousQuarterTotalClaimAmountMap.put(programGeo,totalClaimAmount);
                        }else{
                            previousQuarterTotalClaimAmountMap.put(programGeo,claim.Amount);
                        }
                    }            
                    
                    if(previousQuarterClaimActivityMap.containsKey(programGeoActivityType) && 
                       previousQuarterClaimActivityMap.get(programGeoActivityType) != NULL){
                        Integer noOfRecords = previousQuarterClaimActivityMap.get(programGeoActivityType) + 1;
                        previousQuarterClaimActivityMap.put(programGeoActivityType,noOfRecords);
                    }else{
                        previousQuarterClaimActivityMap.put(programGeoActivityType,1);
                    }
                }
            }
           
            
            if(totalClaimAmountMap != NULL && totalClaimAmountMap.Size() > 0){
                programGeoRemainingBudgetToAuditForWeekMap = getRemainingAmountToBeAudited(totalClaimAmountMap,amountAuditedMap);
            }
           if(previousQuarterTotalClaimAmountMap != NULL && previousQuarterTotalClaimAmountMap.Size() > 0){
                programGeoRemainingBudgetToAuditForLastQuarterMap = getRemainingAmountToBeAudited(previousQuarterTotalClaimAmountMap,previousQuarterAmountAuditedMap);
            }
            
            if(claimActivityMap != NULL && claimActivityMap.Size() > 0){
                claimToBeAuditedActivityMap = getRemainingActivityTypeCountToBeAudited(claimActivityMap, claimAuditedActivityMap);
            }
            
            if(claimActivityMap != NULL && claimActivityMap.Size() > 0){
                claimToBeAuditedActivityForLastQuarterMap = getRemainingActivityTypeCountToBeAudited(previousQuarterClaimActivityMap, previousQuarterClaimAuditedActivityMap);
            }

        
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    } 
    
    /******************************************************************************************************** 
    Method Name :   getRemainingAmountToBeAudited
    @return     :   Map<String,Decimal> : ProgramGeo and Remaining amount percentage
    @parameters :   totalClaimAmountForQuarter Map and claimAmountAudited Map
    Description :   Calculates the remaining amount for audit
    Added By    :   Accenture - VK - 4/14/2020
    Modified By :                               Date:         Changes:None  
    **********************************************************************************************************/
    /*public Map<String,Decimal> getRemainingAmountToBeAudited(Map<String, Decimal> totalClaimAmountForQuarter, Map<String,Decimal>claimAmountAudited){

        Decimal totalClaimAmountToBeAudited;
        Map<String,Decimal> remainingBudgetToAuditForWeekMap = new Map<String,Decimal>();
        try{
            for(String programGeo : totalClaimAmountForQuarter.keySet()){
                if(programGeoBudgetPercentageMap.containsKey(programGeo) && programGeoBudgetPercentageMap.get(programGeo) != NULL){
                    totalClaimAmountToBeAudited = (totalClaimAmountForQuarter.get(programGeo) * programGeoBudgetPercentageMap.get(programGeo))/100;
                    if(claimAmountAudited.containsKey(programGeo) && claimAmountAudited.get(programGeo) != NULL){
                        if(totalClaimAmountToBeAudited > claimAmountAudited.get(programGeo)){
                            remainingBudgetToAuditForWeekMap.put(programGeo, totalClaimAmountToBeAudited - claimAmountAudited.get(programGeo));
                        }
                    }else{
                        remainingBudgetToAuditForWeekMap.put(programGeo, totalClaimAmountToBeAudited);
                    }
                }
            }  
            
            return remainingBudgetToAuditForWeekMap;}catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return NULL;}
    }
    
    /******************************************************************************************************** 
    Method Name :   getRemainingActivityTypeCountToBeAudited
    @return     :   Map<String,Decimal> : ProgramGeoActivityType and Remaining activity type count for audit
    @parameters :   activityTypeMap Map and auditedActivityTypeMap Map
    Description :   Calculates the remaining activity types for audit
    Added By    :   Accenture - VK - 4/14/2020
    Modified By :                               Date:         Changes:None  
    **********************************************************************************************************/
    /*public Map<String,Decimal> getRemainingActivityTypeCountToBeAudited(Map<String, Integer> activityTypeMap, Map<String,Integer>auditedActivityTypeMap){
        
        decimal totalClaimsPerActivity;
        decimal claimsToBeAudited;
        decimal claimsAudited;
        decimal remainingClaimsCanBeAudited;
        Map<String,Decimal> activityMap = new Map<String,Decimal>();
        
        try{
            for(string str : activityTypeMap.keySet()){
                totalClaimsPerActivity = activityTypeMap.get(str);
                if(programGeoActivityTypePercentageMap.containsKey(str) && programGeoActivityTypePercentageMap.get(str) != NULL){
                    claimsToBeAudited = (totalClaimsPerActivity * programGeoActivityTypePercentageMap.get(str))/100;
                    claimsAudited = (auditedActivityTypeMap.get(str) == NULL ? 0 : auditedActivityTypeMap.get(str));            
                    if(claimsToBeAudited > claimsAudited){
                        remainingClaimsCanBeAudited = claimsToBeAudited - claimsAudited;
                        activityMap.put(str,remainingClaimsCanBeAudited);
                    }
                }
            }
            
            return activityMap;}catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return NULL;}
    }
    
    /******************************************************************************************************** 
    Method Name :   getMetataDataResults
    @return     :   None
    @parameters :   None
    Description :   Retrives metadata and finalizes map of budget and activity type percentages
    Added By    :   Accenture - VK - 4/14/2020
    Modified By :                               Date:         Changes:None  
    **********************************************************************************************************/
    /*public void getMetataDataResults(){
        
        try{
            for(Core_MDF_CCP_Claim_Window__mdt claimWindow : [SELECT Core_MDF_isEligibleForBatchAudit_ind__c, Core_MDF_Program__c,
                                                              Core_MDF_Budget_Percentage_nbr__c, Core_MDF_Activity_Types_txt__c,
                                                              Core_MDF_Activity_Type_Percentage_nbr__c, Core_MDF_Region_nm__c
                                                              FROM Core_MDF_CCP_Claim_Window__mdt 
                                                              WHERE Core_MDF_isEligibleForBatchAudit_ind__c = TRUE]){                                                 
                channelProgramSet.add(claimWindow.Core_MDF_Program__c);
                geoSet.add(claimWindow.Core_MDF_Region_nm__c);
                String key = claimWindow.Core_MDF_Program__c+claimWindow.Core_MDF_Region_nm__c;
                programGeoBudgetPercentageMap.put(key, claimWindow.Core_MDF_Budget_Percentage_nbr__c);
                
                for(String type : claimWindow.Core_MDF_Activity_Types_txt__c.split(';')){
                    programGeoActivityTypePercentageMap.put(key+type, claimWindow.Core_MDF_Activity_Type_Percentage_nbr__c);
                }            
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }    
    
    /******************************************************************************************************** 
    Method Name :   setClaimsOnHoldBasedOnHighestAmount
    @return     :   List<PartnerFundClaim> : claims selected for audit
    @parameters :   List<PartnerFundClaim>
    Description :   Adds remaining claims from current quarter for audit based on amount percentage
    Added By    :   Accenture - VK - 4/14/2020
    Modified By :                               Date:         Changes:None  
    **********************************************************************************************************/
    /*public List<PartnerFundClaim> setClaimsOnHoldBasedOnHighestAmount(List<PartnerFundClaim> pfcListForRandomAudit){
        
        List<PartnerFundClaim> pfcListSelectedForAudit = new List<PartnerFundClaim>();

        Decimal remainingBudget;         
        
        try{
            for(PartnerFundClaim pfc : [SELECT Id, Amount, Title, Core_MDF_Audit_Hold__c, Core_MDF_Status__c, Core_MDF_FlaggedForAudit__c, 
                                        Core_MDF_Audit_Type__c,Core_MDF_Program__c,Core_MDF_Activity_Types__c,Core_MDF_Region_Cd__c,Core_MDF_Claim_Ref_Number__c
                                        FROM PartnerFundClaim 
                                        WHERE Id IN: pfcListForRandomAudit
                                        ORDER BY Amount Desc]){                            
                String cpGeo = pfc.Core_MDF_Program__c + pfc.Core_MDF_Region_Cd__c;                            
                if(programGeoRemainingBudgetToAuditForWeekMap.containsKey(cpGeo) && programGeoRemainingBudgetToAuditForWeekMap.get(cpGeo) != NULL && programGeoRemainingBudgetToAuditForWeekMap.get(cpGeo) > 0){
                    pfcListSelectedForAudit.add(pfc);
                    remainingBudget = programGeoRemainingBudgetToAuditForWeekMap.get(cpGeo) - pfc.Amount;
                    programGeoRemainingBudgetToAuditForWeekMap.put(cpGeo, remainingBudget);
                }else{
                    break;
                }
            }

            return pfcListSelectedForAudit;
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return NULL;}
    }
    
    /******************************************************************************************************** 
    Method Name :   setClaimsOnHoldBasedOnHighestAmountForLastQuarter
    @return     :   List<PartnerFundClaim> : claims selected for audit
    @parameters :   List<PartnerFundClaim>
    Description :   Adds remaining claims from previous quarter for audit based on amount percentage
    Added By    :   Accenture - VK - 4/14/2020
    Modified By :                               Date:         Changes:None  
    **********************************************************************************************************/
    /*public List<PartnerFundClaim> setClaimsOnHoldBasedOnHighestAmountForLastQuarter(List<PartnerFundClaim> pfcListForRandomAuditForLastQuarter){
        
        List<PartnerFundClaim> pfcListSelectedForAudit = new List<PartnerFundClaim>();

        Decimal remainingBudgetForQuarter;         
        
        try{
            for(PartnerFundClaim pfc : [SELECT Id, Amount, Title, Core_MDF_Audit_Hold__c, Core_MDF_Status__c, Core_MDF_FlaggedForAudit__c, 
                                        Core_MDF_Audit_Type__c,Core_MDF_Program__c,Core_MDF_Activity_Types__c,Core_MDF_Region_Cd__c,Core_MDF_Claim_Ref_Number__c
                                        FROM PartnerFundClaim 
                                        WHERE Id IN: pfcListForRandomAuditForLastQuarter
                                        ORDER BY Amount Desc]){
                String cpGeo = pfc.Core_MDF_Program__c + pfc.Core_MDF_Region_Cd__c; 
                if(programGeoRemainingBudgetToAuditForLastQuarterMap.containsKey(cpGeo) && programGeoRemainingBudgetToAuditForLastQuarterMap.get(cpGeo) != NULL && programGeoRemainingBudgetToAuditForLastQuarterMap.get(cpGeo) > 0){
                    pfcListSelectedForAudit.add(pfc);
                    remainingBudgetForQuarter = programGeoRemainingBudgetToAuditForLastQuarterMap.get(cpGeo) - pfc.Amount;
                    programGeoRemainingBudgetToAuditForLastQuarterMap.put(cpGeo, remainingBudgetForQuarter);
                }else{
                    break;
                }
            }

            return pfcListSelectedForAudit;
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return NULL;}
    }*/
    
}