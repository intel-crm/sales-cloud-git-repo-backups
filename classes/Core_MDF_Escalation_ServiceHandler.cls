/****************************************************************************************************************************************
* Class Name  : Core_MDF_Escalation_ServiceHandler 
* Created Date: 15-05-2019
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shridhar             15-05-2019         Service Class for updating Channel Program on Escalations for Sharing the records
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Escalation_ServiceHandler {
    public static Boolean iserrorOccured = false;
    public static Boolean isBusinessErrorOccured = false;
    public static String errorMessage = '';    
    
    /*************************************************************************************************** 
    Method Name:        initializeEscalationFields
    @return  :          void
    @parameters:        List<Core_MDF_Escalation__c> List of updated escalations
    Description:        This method is used to intialize the escalation fields
    Added By:           Accenture - SK - 19/5/2019
    Modified By:        Date:       Changes: 
    Manasa              24-6-2019   Modified code to include Activity Lookup changes
    *******************************************************************************************************/
    public static void initializeEscalationFields(List<Core_MDF_Escalation__c> escalationList, Map<Id,Core_MDF_Escalation__c> escalationOldMap,Boolean isInsert){
        try{
            Id escBudgetRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Budget').getRecordTypeId();
            Id escCaseRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId(); 
            Id escActivityRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();   
            
            List<Core_MDF_Escalation__c> escalationToBoProcessed  = new List<Core_MDF_Escalation__c>();
            
            Set<Id> budgetIdSet = new Set<Id>();
            Set<Id> caseIdSet = new Set<Id>();
            Set<Id> activityIdSet = new Set<Id>();
            Map<Id,Id> budgetIdWithProgramId = new Map<Id,Id>();
            Map<Id,Id> caseIdWithProgramId = new Map<Id,Id>();
            Map<Id,Id> activityIdWithProgramId = new Map<Id,Id>();
            Map<Id,String> activityIdWithAccountId = new Map<Id,String>();
            Set<Id> actIdAccIdSet = new Set<Id>();
            Set<Id> clmIdAccIdSet = new Set<Id>();
            Set<Id> clmIdBankIdSet = new Set<Id>();
            Map<Id,String> caseIdWithAccIdBankIdMap = new Map<Id,String>();
            Map<String, Boolean> abmActiveMap = new Map<String, Boolean>();
            Set<Id> abmAccIdSet = new Set<Id>();
            Map<Id, Boolean> accIdWithActiveInd = new Map<Id, Boolean>();
            Map<Id, Core_MDF_Escalation__c> accIdWithEsc = new Map<Id, Core_MDF_Escalation__c>();
            
            //Key = Case id; Value = Sum of all the Escalation's approved amount
            Map<Id, Decimal> caseIdEscalationAmountMap = new Map<Id, Decimal>();
            
            //Key = Case Id; Value = Claim Adjustment Amount
            Map<Id, Decimal> caseIdAdjustmentAmountMap = new Map<Id, Decimal>();
            
            //Conatins denied and cancelled escalation status
            List<String> deniedAndCancelledStatusList = label.Core_MDF_InvalidEscalationStatus.Split(',');
            
            //US625712 : Late Claim - Escalation Creation SLA
            Map<String,Date> dueDateMap = new Map<String,Date>();
            Map<String,Date> submissionWindowMap = new Map<String,Date>();
            Map<String,Date> closureWindowMap = new Map<String,Date>(); 
            Map<id,string> pfrIdToKeyMap = new Map<id,string>();
            
            Map<Id,String> escIdWithCountryMap = new Map<Id,String>();
                        
            for(Core_MDF_Escalation__c esc: escalationList){
                               
                //Set Status to Pending Review for all escalation
                if(isInsert){
                    esc.Core_MDF_Approved_Amount_amt__c = esc.Core_MDF_Total_Dollar_Impact_amt__c;
                    esc.Core_MDF_Escalation_Status_nm__c = 'Pending Review';
                }
                if(esc.recordTypeId == escBudgetRecTypeId && esc.Core_MDF_Budget_ID_Number_id__c != null &&
                   (isInsert || esc.Core_MDF_Budget_ID_Number_id__c != escalationOldMap.get(esc.Id).Core_MDF_Budget_ID_Number_id__c)){
                    escalationToBoProcessed.add(esc);
                    budgetIdSet.add(esc.Core_MDF_Budget_ID_Number_id__c);                
                }
                
                if(esc.recordTypeId == escCaseRecTypeId && esc.Core_MDF_Case_ID_Number_id__c != null &&
                   (isInsert || esc.Core_MDF_Case_ID_Number_id__c != escalationOldMap.get(esc.Id).Core_MDF_Case_ID_Number_id__c)){
                    escalationToBoProcessed.add(esc);
                    caseIdSet.add(esc.Core_MDF_Case_ID_Number_id__c);
                }                                       
                
                //checking if Core_MDF_Co_Marketing_Activity_id__c is not null and adding it to activityIdSet
                if(esc.recordTypeId == escActivityRecTypeId && esc.Core_MDF_Co_Marketing_Activity_id__c != null &&
                   (isInsert || esc.Core_MDF_Co_Marketing_Activity_id__c != escalationOldMap.get(esc.Id).Core_MDF_Co_Marketing_Activity_id__c)){
                       escalationToBoProcessed.add(esc);
                       activityIdSet.add(esc.Core_MDF_Co_Marketing_Activity_id__c);
                       }
            }
               
            
            if(budgetIdSet.size() > 0 ){
                for(PartnerMarketingBudget pmb: [SELECT Id, Core_MDF_Program__c FROM PartnerMarketingBudget WHERE Id IN: budgetIdSet]){
                    budgetIdWithProgramId.put(pmb.Id,pmb.Core_MDF_Program__c);
                    }           
            }
            
            if(caseIdSet.size() > 0){
                for(PartnerFundclaim pfc: [SELECT Id, ChannelPartnerId,RequestId, Request.Core_MDF_Budget_Type_txt__c, Core_MDF_Bank__c, Core_MDF_Claim_Review_Case__c, 
                                           Core_MDF_Claim_Review_Case__r.AccountId, Core_MDF_Claim_Review_Case__r.Account.Core_MDF_Channel_Program__c,
                                           ChannelPartner.Core_MDF_Active_Ind__c, RecordType.DeveloperName,Core_MDF_Audit_Adjustment_Amount__c,
                                           Core_MDF_Claim_Review_Case__r.Core_MDF_Adjustment_Amount_USD_Amt__c,
                                           Core_MDF_Region_Cd__c,Core_MDF_Country_Location_nm__c
                                           FROM PartnerFundclaim
                                           WHERE Core_MDF_Claim_Review_Case__c IN: caseIdSet]){
                    caseIdWithProgramId.put(pfc.Core_MDF_Claim_Review_Case__c, pfc.Core_MDF_Claim_Review_Case__r.Account.Core_MDF_Channel_Program__c);
                    clmIdAccIdSet.add(pfc.ChannelPartnerId);
                    clmIdBankIdSet.add(pfc.Core_MDF_Bank__c);
                                               
                    escIdWithCountryMap.put(pfc.Core_MDF_Claim_Review_Case__c,pfc.Core_MDF_Country_Location_nm__c);      
                                               
                    //Prepare Map to fetch Account+Bank from Claim  
                    //if(pfc.RecordType.DeveloperName != Label.Core_MDF_RMF_MD_Record_Type_Developer_Name){ 
                    if(pfc.Request.Core_MDF_Budget_Type_txt__c != 'RSA MD'){ 
                        caseIdWithAccIdBankIdMap.put(pfc.Core_MDF_Claim_Review_Case__c, (String)pfc.ChannelPartnerId+pfc.Core_MDF_Bank__c);
                    }
                    accIdWithActiveInd.put(pfc.ChannelPartnerId, pfc.ChannelPartner.Core_MDF_Active_Ind__c);                     
                    //caseIdAdjustmentAmountMap.put(pfc.Core_MDF_Claim_Review_Case__c,pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Adjustment_Amount_USD_Amt__c);
                    caseIdAdjustmentAmountMap.put(pfc.Core_MDF_Claim_Review_Case__c,
                                                  pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Adjustment_Amount_USD_Amt__c != NULL ? (pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Adjustment_Amount_USD_Amt__c.setScale(2,System.RoundingMode.HALF_UP)) : pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Adjustment_Amount_USD_Amt__c);
                }
                
                //Get the escalations created on the case
                for(Core_MDF_Escalation__c esc : [SELECT Id, Core_MDF_Case_ID_Number_id__c, Core_MDF_Approved_Amount_amt__c
                                                  FROM Core_MDF_Escalation__c
                                                  WHERE Core_MDF_Case_ID_Number_id__c IN: caseIdSet AND
                                                  Core_MDF_Escalation_Status_nm__c NOT IN: deniedAndCancelledStatusList]){
                    Decimal totalAmount;
                    if(caseIdEscalationAmountMap.containsKey(esc.Core_MDF_Case_ID_Number_id__c)){
                        totalAmount = caseIdEscalationAmountMap.get(esc.Core_MDF_Case_ID_Number_id__c) + esc.Core_MDF_Approved_Amount_amt__c;
                        caseIdEscalationAmountMap.put(esc.Core_MDF_Case_ID_Number_id__c, totalAmount);
                    }else{
                        caseIdEscalationAmountMap.put(esc.Core_MDF_Case_ID_Number_id__c, esc.Core_MDF_Approved_Amount_amt__c);
                    }
                }
            
            }  
            
            System.debug('clmIdAccIdSet---' + clmIdAccIdSet);
            System.debug('clmIdBankIdSet---' + clmIdBankIdSet);
            
            //Query Channel Program from Activity and add channel program Id to activityIdWithProgramId Map
            if(activityIdSet.size() > 0){
                for(PartnerFundRequest pfr: [SELECT Id, ChannelPartner.Core_MDF_Channel_Program__c, 
                                             ChannelPartner.Core_MDF_Active_Ind__c, ChannelPartnerId,
                                             Core_MDF_Program__c, Core_MDF_Budget_Type_txt__c, 
                                             Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c, 
                                             Core_MDF_Country_nm__c, Core_MDF_End_Date__c 
                                             FROM PartnerFundRequest 
                                             WHERE Id IN: activityIdSet]){
                    activityIdWithProgramId.put(pfr.Id,pfr.ChannelPartner.Core_MDF_Channel_Program__c);
                                                 
                    escIdWithCountryMap.put(pfr.Id,pfr.Core_MDF_Country_nm__c);
                                                    
                    //Prepare Map to fetch Activity's Account
                    if(pfr.Core_MDF_Budget_Type_txt__c != 'RSA MD'){ 
                         activityIdWithAccountId.put(pfr.Id,(String)pfr.ChannelPartnerId);
                         actIdAccIdSet.add(pfr.ChannelPartnerId);                           
                    }
                    accIdWithActiveInd.put(pfr.ChannelPartnerId, pfr.ChannelPartner.Core_MDF_Active_Ind__c);
                    
                    if(pfr.Core_MDF_Program__c == 'Retail Marketing Funds'){
                        string key = pfr.Core_MDF_Program__c+
                                ':'+pfr.Core_MDF_Budget_Type_txt__c+
                                ':'+pfr.Core_MDF_Region_cd__c+
                                ':'+pfr.Core_MDF_Sub_Region_cd__c+
                                ':'+pfr.Core_MDF_Country_nm__c+
                                ':'+pfr.Core_MDF_End_Date__c.format(); 
                        key = key.deleteWhitespace();
                        dueDateMap.put(key,null);
                        pfrIdToKeyMap.put(pfr.id,key); 
                    }
                                   
                }           
            }
            
            if(pfrIdToKeyMap != null && !pfrIdToKeyMap.isEmpty()){
                submissionWindowMap = Core_MDF_ProcessClaimSubmissionClosure.getSubmissionDueDate(dueDateMap);                
                closureWindowMap = Core_MDF_ProcessClaimSubmissionClosure.getEscSubDate(dueDateMap);
            }
            
            for(Core_MDF_Account_Bank_Mapping__c abm: [Select Id, Core_MDF_Account__c, Core_MDF_Bank__c, Core_MDF_Active_ind__c, Core_MDF_AccountIdBankIdMapping__c 
                                                       from Core_MDF_Account_Bank_Mapping__c 
                                                       where ((Core_MDF_Account__c IN: actIdAccIdSet) OR 
                                                       (Core_MDF_Account__c IN: clmIdAccIdSet AND Core_MDF_Bank__c IN: clmIdBankIdSet))]){
                if(!abmActiveMap.containskey(abm.Core_MDF_Account__c)){
                    abmActiveMap.put(abm.Core_MDF_Account__c, abm.Core_MDF_Active_ind__c);
                }else if(abmActiveMap.containskey(abm.Core_MDF_Account__c) && !abmActiveMap.get(abm.Core_MDF_Account__c) && abm.Core_MDF_Active_ind__c){    
                    abmActiveMap.put(abm.Core_MDF_Account__c, abm.Core_MDF_Active_ind__c);
                }     
                
                if(!abmActiveMap.containskey((String)abm.Core_MDF_Account__c+abm.Core_MDF_Bank__c)){
                    abmActiveMap.put((String)abm.Core_MDF_Account__c+abm.Core_MDF_Bank__c, abm.Core_MDF_Active_ind__c);
                }else if(abmActiveMap.containskey((String)abm.Core_MDF_Account__c+abm.Core_MDF_Bank__c) && 
                         !abmActiveMap.get((String)abm.Core_MDF_Account__c+abm.Core_MDF_Bank__c) && 
                         abm.Core_MDF_Active_ind__c){
                    abmActiveMap.put((String)abm.Core_MDF_Account__c+abm.Core_MDF_Bank__c, abm.Core_MDF_Active_ind__c);
                }                                            
                
            }
            
            System.debug('abmActiveMap---' + abmActiveMap);
            
            List<Core_MDF_Escalation__c> listEscToBeUpdated = new List<Core_MDF_Escalation__c>();
            
            //Set Program for esclation
            for(Core_MDF_Escalation__c esc: escalationToBoProcessed){
                                
                if(esc.recordTypeId == escBudgetRecTypeId && budgetIdSet.size() > 0 && budgetIdWithProgramId.containsKey(esc.Core_MDF_Budget_ID_Number_id__c)){
                    esc.Core_MDF_Program_txt__c = budgetIdWithProgramId.get(esc.Core_MDF_Budget_ID_Number_id__c);
                    esc.Core_MDF_Channel_Program_id__c = budgetIdWithProgramId.get(esc.Core_MDF_Budget_ID_Number_id__c); 
                  }
                
                if(esc.recordTypeId == escCaseRecTypeId && caseIdSet.size() > 0 && caseIdWithProgramId.containsKey(esc.Core_MDF_Case_ID_Number_id__c)){
                    system.debug('caseIdWithAccIdBankIdMap--'+caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c));
                    if(caseIdWithAccIdBankIdMap.containsKey(esc.Core_MDF_Case_ID_Number_id__c) && caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c) != NULL){
                        String accountId = caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c).left(18);
                    
                    //Check if case account is active
                    if(((abmActiveMap.containsKey(caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c)) &&
                         !abmActiveMap.get(caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c))) ||
                        (!abmActiveMap.containsKey(caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c)))) && accIdWithActiveInd.get(accountId)){
                            esc.addError(Label.Core_MDF_Escalation_Error_for_Inactive_ABM);
                        }
                    }
                    
                    Decimal totalEscalationAmount;
                    
                    if(caseIdAdjustmentAmountMap.containsKey(esc.Core_MDF_Case_ID_Number_id__c) &&
                      caseIdAdjustmentAmountMap.get(esc.Core_MDF_Case_ID_Number_id__c) != NULL){
                        //Check if escalations are created on the same case, 
                        //then add the current escalation's impact amount to the total Approved amount
                        if(caseIdEscalationAmountMap.containsKey(esc.Core_MDF_Case_ID_Number_id__c) && 
                           caseIdEscalationAmountMap.get(esc.Core_MDF_Case_ID_Number_id__c) != NULL){
                               totalEscalationAmount = caseIdEscalationAmountMap.get(esc.Core_MDF_Case_ID_Number_id__c) + esc.Core_MDF_Total_Dollar_Impact_amt__c;   
                           }
                          //If there are no escalations created, then validate current escalation's impact amount
                          else{
                              totalEscalationAmount = esc.Core_MDF_Total_Dollar_Impact_amt__c;
                          }
                          
                          if(totalEscalationAmount > caseIdAdjustmentAmountMap.get(esc.Core_MDF_Case_ID_Number_id__c)){
                              //Total Dollar Impact amount cannot be greater than adjustment amount.
                              esc.addError(Label.Core_MDF_EscalationAmountExceedsAdjustmentAmount);
                          }else{
                              caseIdEscalationAmountMap.put(esc.Core_MDF_Case_ID_Number_id__c, totalEscalationAmount);
                          }
                      }
                    esc.Core_MDF_Program_txt__c = caseIdWithProgramId.get(esc.Core_MDF_Case_ID_Number_id__c);
                    esc.Core_MDF_Channel_Program_id__c = caseIdWithProgramId.get(esc.Core_MDF_Case_ID_Number_id__c);  
                                      
                    if(escIdWithCountryMap != null && escIdWithCountryMap.containsKey(esc.Core_MDF_Case_ID_Number_id__c)){
                          
                           esc.Core_MDF_Country_txt__c = escIdWithCountryMap.get(esc.Core_MDF_Case_ID_Number_id__c);
                       }
                    
                }
            
                // setting Channel Program Name and Program Id based on Activity
                if(esc.recordTypeId == escActivityRecTypeId && activityIdSet.size() > 0 && activityIdWithProgramId.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                    if(activityIdWithAccountId.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c) && activityIdWithAccountId.get(esc.Core_MDF_Co_Marketing_Activity_id__c) != NULL){
                        String accId = activityIdWithAccountId.get(esc.Core_MDF_Co_Marketing_Activity_id__c);                        
                        //Check if activity's account is active
                        if(accIdWithActiveInd.get(accId)){
                            //Check if abm is present for that account 
                            if(!abmActiveMap.containskey(accId)){
                                esc.addError(Label.Core_MDF_Escalation_Error_when_no_ABM_exists);
                            }
                            //Check if active abm is present for that Account
                            else if(abmActiveMap.containsKey(accId) && !abmActiveMap.get(accId)){
                                esc.addError(Label.Core_MDF_Escalation_Error_for_Inactive_ABM);
                            }
                        }
                    }
                    esc.Core_MDF_Program_txt__c = activityIdWithProgramId.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                    esc.Core_MDF_Channel_Program_id__c = activityIdWithProgramId.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                    
                    if(escIdWithCountryMap != null && escIdWithCountryMap.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                           
                           esc.Core_MDF_Country_txt__c = escIdWithCountryMap.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                       }
                                        
                    //need to validate claimsubmissionwindow to create escalation
                    if(pfrIdToKeyMap != null && pfrIdToKeyMap.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                        string key = pfrIdToKeyMap.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                        Date dtToday = System.today();
                        
                        if(submissionWindowMap != null && submissionWindowMap.containsKey(key) && closureWindowMap != null && closureWindowMap.containsKey(key) ){
                            Date submissionDueDate = submissionWindowMap.get(key);
                            Date closureDueDate = closureWindowMap.get(key);
                            esc.Core_MDF_Esc_Submission_End_Date_dtm__c = closureDueDate;
                            if(submissionDueDate != null && closureDueDate != null){
                                if(!(dtToday > submissionDueDate && dtToday <= closureDueDate)){
                                   esc.addError(Label.Core_MDF_Late_Claim_Escalation_Creation_Error);
                                }
                            }
                        }
                        
                    }
                   /* if(accIdWithEsc != null && accIdWithEsc.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                        
                        listEscToBeUpdated = [select id from Core_MDF_Escalation__c
                                              where id =: accIdWithEsc.get(esc.Core_MDF_Co_Marketing_Activity_id__c).id];
                        
                        //Unlock the Pending Approval PFR records
                        List<Approval.UnlockResult> ulrList = Approval.unlock(listEscToBeUpdated, false);     
                        System.debug('ulrlust'+ ulrList );
                       } */
                    
                }           
            } 
                   
        }
        catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,Label.Core_MDF_Set_Program_for_Escalation);
        } 
    }
    
    /*************************************************************************************************** 
    Method Name:        shareEscalation
    @return  :          void
    @parameters:        List<Core_MDF_Escalation__c> List of updated escalations
    Description:        This method is used to provide sharing
    Added By:           Accenture - SK - 19/5/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static void shareEscalation(Map<Id,Core_MDF_Escalation__c> escalationMap, Map<Id,Core_MDF_Escalation__c> escalationOldMap,Boolean isInsert){
        try{
            Id escBudgetRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Budget').getRecordTypeId();
            Id escCaseRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId(); 
            Id escActivityRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();           
            
            List<Id> escalationIdList  = new List<Id>();
            Set<Id> budgetIdSet = new Set<Id>();
            Set<Id> caseIdSet = new Set<Id>();
            Set<Id> activityIdSet = new Set<Id>();            
            Set<Id> intelAccSet = new Set<Id>();
            Set<Id> channelProgramIdSet = new Set<Id>();            

            for(Core_MDF_Escalation__c esc : escalationMap.values()){
                if(isInsert || esc.OwnerId != escalationOldMap.get(esc.Id).OwnerId){
                    escalationIdList.add(esc.Id);
                }
            }            
            
            List<Core_MDF_Escalation__c> escalationList = [SELECT Id, recordTypeId, OwnerId,
                                                           Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c, 
                                                           Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program_id__c,
                                                           Core_MDF_Case_ID_Number_id__r.Core_Account_Geo__c,
                                                           Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_cd__c,
                                                           Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,
                                                           Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Geo__c,
                                                           Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c,
                                                           Core_MDF_Case_ID_Number_id__r.Core_IPS_Account_Sub_Geo__c,
                                                           Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_cd__c,
                                                           Core_MDF_Channel_Program_id__r.Name,
                                                           Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Id
                                                           FROM Core_MDF_Escalation__c 
                                                           WHERE ID IN: escalationIdList];
            
            List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
            
            List<String> nonCcpProgramList = Label.Core_MDF_Retail_Channel_Program_Name.split(';');
            
            Set<Id> activityAccountIdSet = new Set<Id>();
            Map<Id,Set<Id>> accIdUserIdSetMap = new Map<Id,Set<Id>>();
            Set<Id> userIdSet = new Set<Id>();
            Set<Id> userWithRequiredPermissionSet = new Set<Id>();
            List<String> permissionSetNameList = Label.Core_MDF_Retail_Claim_Submitter_Permission_Set.split(';');
            
            for(Core_MDF_Escalation__c esc : escalationList){
                channelProgramIdSet.add(esc.Core_MDF_Channel_Program_id__c);
                
                //For Budget Escalation
                if(esc.recordTypeId == escBudgetRecTypeId && esc.Core_MDF_Budget_ID_Number_id__c != null){
                    
                    budgetIdSet.add(esc.Core_MDF_Budget_ID_Number_id__c);
                    intelAccSet.add(esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c);
                    
                    if(esc.Core_MDF_Channel_Program_id__r.Name == Label.Core_MDF_Retail_Channel_Program_Name){
                        //For Finance Manager Sharing
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(esc.Id,
                                                                           esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Geo__c,
                                                                           esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c,
                                                                           esc.Core_MDF_Channel_Program_id__r.Name));
                    }
                }
                
                //For Case Escalation
                if(esc.recordTypeId == escCaseRecTypeId && esc.Core_MDF_Case_ID_Number_id__c != null){
                    
                    caseIdSet.add(esc.Core_MDF_Case_ID_Number_id__c);
                    intelAccSet.add(esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c);
                    
                    //For Finance Manager Sharing
                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(esc.Id,
                                                                       esc.Core_MDF_Case_ID_Number_id__r.Core_Account_Geo__c.trim(),
                                                                       esc.Core_MDF_Case_ID_Number_id__r.Core_IPS_Account_Sub_Geo__c.trim(),
                                                                       esc.Core_MDF_Channel_Program_id__r.Name));
                }
                
                //For Late Claim Escalaytion (Activity)
                if(esc.recordTypeId == escActivityRecTypeId && esc.Core_MDF_Co_Marketing_Activity_id__c != null){
                    
                    activityIdSet.add(esc.Core_MDF_Co_Marketing_Activity_id__c);
                    intelAccSet.add(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c);
                    
                    //For Finance Manager Sharing
                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(esc.Id,
                                                                       esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_cd__c,
                                                                       esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_cd__c,
                                                                       esc.Core_MDF_Channel_Program_id__r.Name));
                    
                    if(esc.Core_MDF_Channel_Program_id__r.Name == Label.Core_MDF_Retail_Channel_Program_Name){
                        activityAccountIdSet.add(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Id);
                    }
                }                
            }
            
            if(intelAccSet.size()<1){
                return;
            }
            
            if(activityAccountIdSet != NULL && activityAccountIdSet.Size() > 0){
                for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id, Core_MDF_Account__c, Core_MDF_User__c
                                                                  FROM Core_MDF_Partner_Node_User_Mapping__c
                                                                  WHERE Core_MDF_Account__c IN: activityAccountIdSet AND
                                                                  Core_MDF_User__r.IsActive = TRUE]){
                    userIdSet.add(pnum.Core_MDF_User__c);
                    if(accIdUserIdSetMap.containsKey(pnum.Core_MDF_Account__c)){
                        accIdUserIdSetMap.get(pnum.Core_MDF_Account__c).add(pnum.Core_MDF_User__c);
                    }else{
                        accIdUserIdSetMap.put(pnum.Core_MDF_Account__c,new Set<Id>{pnum.Core_MDF_User__c});
                    }
                }
            }
            
            if(userIdSet != NULL && userIdSet.Size() > 0){
                for(PermissionSetAssignment psa : [SELECT Id, PermissionSet.Name,AssigneeId
                                                   FROM PermissionSetAssignment
                                                   WHERE AssigneeId IN: userIdSet AND
                                                   PermissionSet.Name IN: permissionSetNameList]){
                    userWithRequiredPermissionSet.add(psa.AssigneeId);                                  
                }
            }
            
            //Fetching PGM records and storing them in map with Account
            Map<String,List<Id>> intelAccIdWithGroup = new Map<String,List<Id>>();
            Map<String,Id> pgmForSubGeoMap = new Map<String,Id>();
            Map<String,Id> pgmForGeoMap = new Map<String,Id>();
            Map<String,Id> pgmForWWMap = new Map<String,Id>();
            
            for(Core_MDF_Partner_Group_Mapping__c pgm:[SELECT Id, Core_MDF_Group_Id__c, Core_MDF_Account__c, 
                                                       Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Name,
                                                       Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c
                                                       FROM Core_MDF_Partner_Group_Mapping__c 
                                                       WHERE Core_MDF_Type_of_Access__c='Internal' AND 
                                                       Core_MDF_Account__c IN :intelAccSet AND
                                                      Core_MDF_Channel_Program__c IN :channelProgramIdSet ]){
                String accIdCpId = (String)pgm.Core_MDF_Account__c+pgm.Core_MDF_Channel_Program__c;
                                                           
                //To share budget escalation of CCP programs with all PGM
                if(!nonCcpProgramList.contains(pgm.Core_MDF_Channel_Program__r.Name)){    
                    if(intelAccIdWithGroup.containsKey(accIdCpId)){
                        intelAccIdWithGroup.get(accIdCpId).add(pgm.Core_MDF_Group_Id__c);
                    }                                                         
                    else{
                        List<Id> tempPGM = new List<Id>();
                        tempPGM.add(pgm.Core_MDF_Group_Id__c);
                        intelAccIdWithGroup.put(accIdCpId,tempPGM);
                    }
                }
                
                String accIdCpIdGeoSubGeo, accIdCpIdGeo;
                                                           
                //Sub Region != Null i.e. for Retail and ASMO - LAR & NAR specific                                          
                if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                    accIdCpIdGeoSubGeo = (String)pgm.Core_MDF_Account__c+pgm.Core_MDF_Channel_Program__c+pgm.Core_MDF_Region_cd__c+pgm.Core_MDF_Sub_Region_cd__c;
                    pgmForSubGeoMap.put(accIdCpIdGeoSubGeo, pgm.Core_MDF_Group_Id__c);
                    
                }
                //For all CCP Programs including Retail(APJ,EMEA,PRC)
                else {
                    accIdCpIdGeo = (String)pgm.Core_MDF_Account__c+pgm.Core_MDF_Channel_Program__c+pgm.Core_MDF_Region_cd__c;
                    pgmForGeoMap.put(accIdCpIdGeo, pgm.Core_MDF_Group_Id__c);
                }    
                
                //For CCP Programs and PGM of type WW
                accIdCpId = accIdCpId.left(36);
                if(pgm.Core_MDF_Region_cd__c == 'WW'){
                    pgmForWWMap.put(accIdCpId,pgm.Core_MDF_Group_Id__c);                                        
                }
            }
            
            //Create escalation share records 
            Map<Id,List<Id>> esclationWithGroupId = new Map<Id,List<Id>>();
            List<Core_MDF_Escalation__c> listEscToBeUpdated = new List<Core_MDF_Escalation__c>();       
            for(Core_MDF_Escalation__c esc: escalationList){
                
                List<Id> groupIdList = new List<Id>();
                List<Id> internalGroupId = new List<Id>();
                String accIdCpId, accIdCpIdGeo, accIdCpIdGeoSubGeo;
                //Budget Escalation
                if(esc.recordTypeId == escBudgetRecTypeId && budgetIdSet.contains(esc.Core_MDF_Budget_ID_Number_id__c)){
                    
                    accIdCpIdGeoSubGeo = (String)esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c +esc.Core_MDF_Channel_Program_id__c + esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Geo__c + esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c;
                    accIdCpIdGeo = (String)esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c + esc.Core_MDF_Channel_Program_id__c + esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_Geo__c;
                    accIdCpId = (String)esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c + esc.Core_MDF_Channel_Program_id__c;
                    
                    if(intelAccIdWithGroup.containsKey(accIdCpId) && intelAccIdWithGroup.get(accIdCpId) != NULL){
                        groupIdList.addAll(intelAccIdWithGroup.get(accIdCpId));
                    }
                    else if(pgmForSubGeoMap.containsKey(accIdCpIdGeoSubGeo) && pgmForSubGeoMap.get(accIdCpIdGeoSubGeo) != NULL){
                        groupIdList.add(pgmForSubGeoMap.get(accIdCpIdGeoSubGeo));
                    }
                    else if(pgmForGeoMap.containsKey(accIdCpIdGeo) && pgmForGeoMap.get(accIdCpIdGeo) != NULL){
                        groupIdList.add(pgmForGeoMap.get(accIdCpIdGeo));
                    }
                    
                    internalGroupId.addAll(groupIdList);
                }
                //Case Escalation
                if(esc.recordTypeId == escCaseRecTypeId && caseIdSet.contains(esc.Core_MDF_Case_ID_Number_id__c )){
                    
                    accIdCpIdGeoSubGeo = (String)esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c + esc.Core_MDF_Channel_Program_id__c+esc.Core_MDF_Case_ID_Number_id__r.Core_Account_Geo__c.trim() +esc.Core_MDF_Case_ID_Number_id__r.Core_IPS_Account_Sub_Geo__c.trim();
                    accIdCpIdGeo = (String)esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c +esc.Core_MDF_Channel_Program_id__c+esc.Core_MDF_Case_ID_Number_id__r.Core_Account_Geo__c.trim();
                    accIdCpId = (String)esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c +esc.Core_MDF_Channel_Program_id__c;
                        
                    if(pgmForSubGeoMap.containsKey(accIdCpIdGeoSubGeo) && pgmForSubGeoMap.get(accIdCpIdGeoSubGeo) != NULL){
                        groupIdList.add(pgmForSubGeoMap.get(accIdCpIdGeoSubGeo));
                    }
                    else if(pgmForGeoMap.containsKey(accIdCpIdGeo) && pgmForGeoMap.get(accIdCpIdGeo) != NULL){
                        groupIdList.add(pgmForGeoMap.get(accIdCpIdGeo));
                    }
                    
                    if(pgmForWWMap.containsKey(accIdCpId) && pgmForWWMap.get(accIdCpId) != NULL){
                        groupIdList.add(pgmForWWMap.get(accIdCpId));
                    }
                    
                    internalGroupId.addAll(groupIdList);
                }
                
                //Activity Escalation
                if(esc.recordTypeId == escActivityRecTypeId && activityIdSet.contains(esc.Core_MDF_Co_Marketing_Activity_id__c )){
                    
                    accIdCpIdGeoSubGeo = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+ esc.Core_MDF_Channel_Program_id__c+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_cd__c+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_cd__c;
                    accIdCpIdGeo = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_cd__c;
                    accIdCpId = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c;
                    
                    if(pgmForSubGeoMap.containsKey(accIdCpIdGeoSubGeo) && pgmForSubGeoMap.get(accIdCpIdGeoSubGeo) != NULL){
                        groupIdList.add(pgmForSubGeoMap.get(accIdCpIdGeoSubGeo));
                    }
                    else if(pgmForGeoMap.containsKey(accIdCpIdGeo) && pgmForGeoMap.get(accIdCpIdGeo) != NULL){
                        groupIdList.add(pgmForGeoMap.get(accIdCpIdGeo));
                    }
                    
                    if(pgmForWWMap.containsKey(accIdCpId) && pgmForWWMap.containsKey(accIdCpId) != NULL){
                        groupIdList.add(pgmForWWMap.get(accIdCpId));
                    }
                    
                    internalGroupId.addAll(groupIdList);
                    
                    if(accIdUserIdSetMap.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Id) && 
                       accIdUserIdSetMap.get(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Id) != NULL){
                        for(Id userId : accIdUserIdSetMap.get(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Id)){
                            if(userWithRequiredPermissionSet.contains(userId)){
                                groupIdList.add(userId);
                            }
                        }
                    }
                }
                
                if(groupIdList.Size() > 0){
                    esclationWithGroupId.put(esc.Id,groupIdList);
                    
                    //To update PGM of Internal type group Id 
                    Core_MDF_Escalation__c escalation = new Core_MDF_Escalation__c();
                    escalation.Id = esc.Id;
                    if(internalGroupId != NULL && internalGroupId.Size() > 0){
                        escalation.Core_MDF_PGM_Internal_Group_Id_txt__c = String.join(internalGroupId, ';');
                        listEscToBeUpdated.add(escalation);
                    }
                }  
            }
                        
            if(listEscToBeUpdated != NULL && listEscToBeUpdated.Size() > 0){
                database.update(listEscToBeUpdated);
            }
            
            //Call Generic Approval Process class to create escalation Share records        
            if(esclationWithGroupId.size()>0){
                //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Escalation__c', esclationWithGroupId); 
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Escalation__c',esclationWithGroupId, 'Edit');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);

            }
            
            if(recordGeoShareList != NULL && recordGeoShareList.size() >0){                        
                Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroup('Core_MDF_Escalation__c',recordGeoShareList);
            }              
        }
        catch(Exception e){ String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,Label.Core_MDF_Escalation_Sharing );
        } 
    } 
    
    /*************************************************************************************************** 
    Method Name:        approvalAction
    @return  :          void
    @parameters:        List<Core_MDF_Escalation__c> escalationList, Map<Id,Core_MDF_Escalation__c> escalationOldMap
    Description:        This method will perform the approval action for claim review result 
    Added By:           Accenture - SK - 20/06/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/    
    public static void approvalAction(List<Core_MDF_Escalation__c> escalationList, Map<Id,Core_MDF_Escalation__c> escalationOldMap){
        
        try{
            Map<Id, Core_MDF_Escalation__c> escToBeProcessedMap = new Map<Id, Core_MDF_Escalation__c>();
            
            Id escCaseRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId(); 
                                 
            Set<Id> caseIdSet = new Set<Id>();
            List<Core_MDF_Escalation__c> listEscToBeUpdated = new List<Core_MDF_Escalation__c>();
            
             
            for(Core_MDF_Escalation__c esc: escalationList){
                
               if(esc.recordTypeId == escCaseRecTypeId && esc.Core_MDF_Case_ID_Number_id__c != null &&  
                  ((!esc.Core_MDF_Do_not_Auto_Create_Claim_Ind__c &&
                  esc.Core_MDF_Escalation_Status_nm__c != escalationOldMap.get(esc.Id).Core_MDF_Escalation_Status_nm__c &&
                  esc.Core_MDF_Escalation_Status_nm__c == Label.Core_MDF_Status_Approved) || 
                  (esc.Core_MDF_Do_not_Auto_Create_Claim_Ind__c && 
                  esc.Core_MDF_Claim_Number_id__c != escalationOldMap.get(esc.Id).Core_MDF_Claim_Number_id__c))){
                    
                     escToBeProcessedMap.put(esc.Core_MDF_Case_ID_Number_id__c, esc);
                }
                
                                
            }
            System.debug('escToBeProcessedMap:'+escToBeProcessedMap);
            
            List<Case> toBeUpdatedCases = new List<Case>();
            List<PartnerFundClaim>  toBeUpdatedClaims = new List<PartnerFundClaim>();
            List<Core_MDF_Adjustment_Request__c> toBeInsertedAdjustmentRec = new List<Core_MDF_Adjustment_Request__c>();
            
            for(PartnerFundClaim pfc: [SELECT Id, Core_MDF_Claim_Review_Case__c, Core_MDF_Status__c, Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Review_Case_Status__c
                                        ,Core_MDF_Claim_Review_Case__r.Core_MDF_Claim_Conversion_Exchange_Rate__c FROM PartnerFundClaim WHERE Core_MDF_Claim_Review_Case__c IN : escToBeProcessedMap.keySet()]){
                            
                    String claimStatus = pfc.Core_MDF_Status__c;
                    List<String> nonPaidclmStsLst = System.Label.Core_MDF_Pre_Payment_Claim_Statuses.split(';');
                    List<String> paidclmStsLst = System.Label.Core_MDF_Post_Payment_Claim_Statuses.split(';');
                                            
                    //If claim is in Pending Available Fund, Payment Due, Hold OR If claim is in Pending Payment, Paid, Cancelled, Denied                       
                    if(nonPaidclmStsLst.contains(claimStatus) || paidclmStsLst.contains(claimStatus)){                        
                                            
                        if(!escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Do_not_Auto_Create_Claim_Ind__c ||
                          (escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Do_not_Auto_Create_Claim_Ind__c &&
                           escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Claim_Number_id__c != NULL)){
                               // if claims are denied                
                                    if(pfc.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_Denied){
                                        pfc.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Adjusted;
                                        Case cs = new Case();
                                        cs.Id = pfc.Core_MDF_Claim_Review_Case__c;
                                        cs.Core_MDF_Review_Case_Status__c = Label.Core_MDF_Case_Status_Compliant;
                                        cs.Core_MDF_Status__c = Label.Core_MDF_Case_Status_Compliant;   
                                        toBeUpdatedCases.add(cs);                   
                                    }
                           }
                                   
                            //If Core_MDF_Do_not_Auto_Create_Claim__c is unchecked, auto create claim
                            if(!escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Do_not_Auto_Create_Claim_Ind__c){

                                Core_MDF_Adjustment_Request__c adjRec = new Core_MDF_Adjustment_Request__c();
                                adjRec.Core_MDF_Amount_Amt__c = escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Approved_Amount_amt__c;
                                adjRec.Core_MDF_Reference_Claim_Nbr__c = pfc.Id;
                                adjRec.Core_MDF_Reason_Cd__c = Label.Core_MDF_Claim_Review_Results_Positive;
                                adjRec.Core_MDF_Escalation_Id__c = escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Id;
                                toBeInsertedAdjustmentRec.add(adjRec); 
                             }
                            //If Core_MDF_Do_not_Auto_Create_Claim__c is checked, create Claim manually and change the Old Denied Claim and Case Statuses
                            if(escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Do_not_Auto_Create_Claim_Ind__c &&
                               escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Claim_Number_id__c != NULL){
                                   
                                   Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
                                   adjReq.Core_MDF_Amount_Amt__c = escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Approved_Amount_amt__c;
                                   adjReq.Core_MDF_Reference_Claim_Nbr__c = pfc.Id;
                                   adjReq.Core_MDF_Adjustment_Claim_Nbr__c = escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Claim_Number_id__c ;
                                   adjReq.Core_MDF_Reason_Cd__c = Label.Core_MDF_Claim_Review_Results_Positive;
                                   adjReq.Core_MDF_Escalation_Id__c = escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Id;
                                   toBeInsertedAdjustmentRec.add(adjReq); 
                            }  
                        
                            //If claim is in Pending Available Fund, Payment Due, Hold      
                            if(nonPaidclmStsLst.contains(claimStatus)){ 
                                Decimal currentAdjAmount = pfc.Core_MDF_Audit_Adjustment_Amount__c -
                                                                escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Approved_Amount_amt__c;
                                //Add Error if adjustment amount is less than 0
                                if(currentAdjAmount < 0){
                                    escalationList[0].addError(Label.Core_MDF_Adjustment_Amount_Error);                                                             
                                }                    
                             }  
                        
                      }  
                                            
                toBeUpdatedClaims.add(pfc); 
                                        }
                                    
            if(toBeUpdatedCases.size() > 0){
                Database.update(toBeUpdatedCases);
            }
            
            if(toBeUpdatedClaims.size() > 0){
                Database.update(toBeUpdatedClaims);
            }
            
            if(toBeInsertedAdjustmentRec.size() > 0){
                Database.insert(toBeInsertedAdjustmentRec);  
            }            
        }        
        catch(Exception e){ 
            errorMessage = Core_MDF_CCP_UtilityClass.getErrorDetails(e); 
            iserrorOccured = true;
            
            //Check for budget cap error
            if(!String.isBlank(errorMessage) && errorMessage.contains(Label.Core_MDF_ClaimExceedsCapRemainder_ErrorMsg)){
                isBusinessErrorOccured = true; 
                escalationList[0].addError(Label.Core_MDF_Escalation_Approval_Error_Message);
            }
            //Check for activity budget error
            else if(!String.isBlank(errorMessage) && errorMessage.contains(Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt)){
                //Commenting the below lines as tehre is no need to send notification.
                //Approvers can edit the amount and approve in case claim amt is greater than budget amt.
                //isBusinessErrorOccured = true; 
                escalationList[0].addError(Label.Core_MDF_Escalation_Approval_Budget_Error_Msg);
            }
            else{
                //System.debug('Came Here');
                escalationList[0].addError(Label.Core_MDF_ApplicationErrorMessage); //                                                           
            }                                      
        }
        finally{
            System.debug('iserrorOccured: '+iserrorOccured);
            System.debug('errorMessage: '+errorMessage);
            if(iserrorOccured){
                Core_MDF_Notify_Account_Manager__e notificationEvent = new Core_MDF_Notify_Account_Manager__e();
                notificationEvent.Core_MDF_Escalation_Id_txt__c = String.valueOf(escalationList[0].Id);
                notificationEvent.Core_MDF_isBusinessError_ind__c = isBusinessErrorOccured == true ? true : false;
                notificationEvent.Core_MDF_errorMessage_txt__c = errorMessage;
                // Call method to publish events
                Database.SaveResult sr = EventBus.publish(notificationEvent);
            }
        }       
    }  
    
    /****************************************************************************************************** 
    Method Name:        isUserEligibiletoCreateClaim
    @parameters:        NA
    Description:        This method is used to check if user has the permission to create Claim from Escalation.
    Added By:           Manasa Accenture - 27/06/2019
    *******************************************************************************************************/
    //to cache the data
    @AuraEnabled(cacheable=true)
    public static Boolean isUserEligibletoCreateClaim(){
        Boolean usrHasPer = false;
        try {            
            Schema.DescribeSObjectResult chkPer = Schema.sObjectType.PartnerFundClaim;
            usrHasPer = chkPer.isCreateable();
            system.debug('usrHasPer@@'+usrHasPer);
            return usrHasPer;            
        }     
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);return false;}
    }
    
    /****************************************************************************************************** 
    Method Name:        getEscalationFields
    @parameters:        escalation Id
    Description:        This method is used to check if Core_MDF_Do_not_Auto_Create_Claim_Ind__c is checked or not.
    Added By:           Manasa Accenture - 26/01/2020
    *******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean getEscalationFields(Id escRecord){
        
        List<Core_MDF_Escalation__c> esc= new List<Core_MDF_Escalation__c>();
        Boolean doNotAutoCreateClaim = false;
        Id escCaseRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId(); 
        try{
            for(Core_MDF_Escalation__c escl: [SELECT Id, Core_MDF_Case_ID_Number_id__r.Core_MDF_Activity_ID__c, Core_MDF_Do_not_Auto_Create_Claim_Ind__c, Core_MDF_Claim_Number_id__c 
                                              FROM Core_MDF_Escalation__c
                                              WHERE (Id=:escRecord AND RecordTypeId =: escCaseRecTypeId)]) { 
                if(!escl.Core_MDF_Do_not_Auto_Create_Claim_Ind__c && escl.Core_MDF_Claim_Number_id__c != NULL){
                    doNotAutoCreateClaim = true;
                }   
            }       
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return doNotAutoCreateClaim;
    }
    
    /****************************************************************************************************** 
    Method Name:        populateApproverNameAndComments
    @parameters:        List of Escalation
    Description:        This method is used to populate approver comments and approver names into escalation record
    Added By:           Sugathri Accenture - 13/05/2020
    *******************************************************************************************************/
   
   public static void populateApproverNameAndComments(List<Core_MDF_Escalation__c> escalationList){
        
        try{            
            Map<Id,Id> escIdProcessInstanceId = new Map<Id,Id>();
            List<Id> escalationIdList = new List<Id>();
            Map<Id,List<ProcessInstanceStep>> piPiStepMap = new Map<Id,List<ProcessInstanceStep>>();
            List<Core_MDF_Escalation__c> escToBeUpdated = new List<Core_MDF_Escalation__c>();
            
            for(Core_MDF_Escalation__c esc : escalationList){
                escalationIdList.add(esc.Id);
            }
            
            for(ProcessInstance pi : [SELECT Id,TargetObjectId 
                                      FROM ProcessInstance 
                                      WHERE TargetObjectId IN: escalationIdList]){
                escIdProcessInstanceId.put(pi.TargetObjectId, pi.Id);
            }
            
            System.debug('escIdProcessInstanceId---' + escIdProcessInstanceId);
            
            for(ProcessInstanceStep piStep : [SELECT Id,ActorId,StepStatus,ProcessInstanceId,Comments 
                                              FROM ProcessInstanceStep 
                                              WHERE ProcessInstanceId IN: escIdProcessInstanceId.values() AND
                                              StepStatus != 'NoResponse' 
                                              ORDER BY CreatedDate ASC]){
                if(piPiStepMap.containsKey(piStep.ProcessInstanceId)){
                    piPiStepMap.get(piStep.ProcessInstanceId).add(piStep);
                }else{
                    piPiStepMap.put(piStep.ProcessInstanceId, new List<ProcessInstanceStep>{piStep});
                }
            }
            
            System.debug('piPiStepMap---' + piPiStepMap);
            System.debug('piPiStepMapSize---' + piPiStepMap.Size());
            
            for(Core_MDF_Escalation__c esc : escalationList){
                if(escIdProcessInstanceId.containsKey(esc.Id) && escIdProcessInstanceId.get(esc.Id) != NULL){
                    Id processInstanceId = escIdProcessInstanceId.get(esc.Id);
                    if(piPiStepMap.containsKey(processInstanceId) && piPiStepMap.get(processInstanceId) != NULL){
                        Core_MDF_Escalation__c escInst = new Core_MDF_Escalation__c();
                        escInst.Id = esc.Id;

                        for(integer i = 1; i < piPiStepMap.get(processInstanceId).Size() ; i++){
                            
                            String approver = 'Core_MDF_Approver_'+i+'_Name_Id__c';
                            String comments = 'Core_MDF_Approver_'+i+'_Comments_txt__c';
                            
                            if(esc.get(approver) == NULL && piPiStepMap.get(processInstanceId)[i] != NULL){
                                escInst.put(approver,piPiStepMap.get(processInstanceId)[i].ActorId);
                                escInst.put(comments,piPiStepMap.get(processInstanceId)[i].Comments);
                                escInst.Core_MDF_Approval_Flag_ind__c = FALSE;
                            }
                        }
                        escToBeUpdated.add(escInst);
                    }
                }
            }
            
            if(escToBeUpdated != NULL && escToBeUpdated.Size() > 0){
                database.update(escToBeUpdated);
            }
        }
       catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
   }
       
   /****************************************************************************************************** 
    Method Name:        checkEscLateClaimCreation
    @parameters:        escalation Id
    Description:        
    Added By:           Sugathri Accenture - 26/05/2020
    *******************************************************************************************************/
    @AuraEnabled
    public static string checkEscLateClaimCreation(Id RecordId){
        string response ='SUCCESS';
        Id escActivityRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();   
        Map<String,Date> submissionWindowMap = new Map<String,Date>();
        Map<String,Date> closureWindowMap = new Map<String,Date>();
        // the key will be-> pgm:budgettype:geo:subgeo:country:date
        Core_MDF_Escalation__c esc = [Select Core_MDF_Claim_Number_id__c, Core_MDF_Co_Marketing_Activity_id__c, 
                                      Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_txt__c,
                                      Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_cd__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_cd__c,
                                      Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Country_nm__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_End_Date__c
                                      FROM Core_MDF_Escalation__c 
                                      WHERE id = : RecordId]; 
        
        try{
                        
            if(esc.Core_MDF_Co_Marketing_Activity_id__c != null && esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c == 'Retail Marketing Funds'){
                map<String,Date> dueDateMap = new map<String,Date>();
                string key = esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c+
                    ':'+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Budget_Type_txt__c+
                    ':'+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_cd__c+
                    ':'+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Sub_Region_cd__c+
                    ':'+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Country_nm__c+
                    ':'+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_End_Date__c.format(); 
                key = key.deleteWhitespace();
                dueDateMap.put(key,null);
                submissionWindowMap = Core_MDF_ProcessClaimSubmissionClosure.getSubmissionDueDate(dueDateMap);
                closureWindowMap = Core_MDF_ProcessClaimSubmissionClosure.getEscSubDate(dueDateMap);
                if(dueDateMap != null && submissionWindowMap != null && closureWindowMap != null){
                    Date dtInstance = System.today();
                    if(submissionWindowMap != null && !submissionWindowMap.isEmpty() && closureWindowMap != null && !closureWindowMap.isEmpty()){
                        Date submissionDueDate = submissionWindowMap.values()[0];
                        Date closureDueDate = closureWindowMap.values()[0];
                        if(!(dtInstance > submissionDueDate && dtInstance <= closureDueDate)){
                            response = Label.Core_MDF_Escalation_Error_Message_Late_Claim;
                        }
                    }
                }
            }
            if(esc.Core_MDF_Co_Marketing_Activity_id__c != null &&
               esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Program__c == 'Retail Marketing Funds' && 
               esc.Core_MDF_Claim_Number_id__c != null){
                    response = Label.Core_MDF_Escalation_Error_Message_Create_Multiple_Claim;
            }   
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return response;
    }
    
     /****************************************************************************************************** 
    Method Name:        removeRecordFromApprovalProcess
    @parameters:        List<Core_MDF_Escalation__c> escalationList, Map<Id,Core_MDF_Escalation__c> escalationOldMap
    Description:        This method is used to remove expired records from approval process
    Added By:           Sugathri Accenture - 11/06/2020
    *******************************************************************************************************/
   
   public static void removeRecordFromApprovalProcess(List<Core_MDF_Escalation__c> recordIdList){
        
        try{       
            
            List<Id> listEscToBeUpdated = new List<Id>();
            List<Approval.ProcessWorkitemRequest> processRequestList = new List<Approval.ProcessWorkitemRequest> ();
            List<ProcessInstanceWorkItem> processInstanceWIList = new List<ProcessInstanceWorkItem>();    
            
            /*for(Core_MDF_Escalation__c esc: recordIdList){            
                       listEscToBeUpdated.add(esc.id);             
            }
            System.debug('escToBeProcessedMap:'+listEscToBeUpdated);*/
            
            if(recordIdList != null && recordIdList.size() > 0){
                            
                //Get Process Instance Work Items
                processInstanceWIList = [SELECT Id FROM ProcessInstanceWorkItem
                                         WHERE ProcessInstance.TargetObjectId IN :recordIdList
                                         AND ProcessInstance.Status = 'Pending']; 
                System.debug('worktiesm'+processInstanceWIList);
                
            } 
                        
            for(ProcessInstanceWorkItem pIWorkItem : processInstanceWIList){
                Approval.ProcessWorkitemRequest workItemRequest = new Approval.ProcessWorkitemRequest();
                workItemRequest.setAction('Removed');
                workItemRequest.setWorkitemId(pIWorkItem.Id);
                processRequestList.add(workItemRequest);
            } 
            System.debug('worktiesm'+processInstanceWIList);

            if(!processRequestList.isEmpty()){
                List<Approval.ProcessResult> processResults = Approval.process(processRequestList);
                System.debug('result '+processResults);
            }
            List<Core_MDF_Escalation__c> escList = new List<Core_MDF_Escalation__c>();
            for(Core_MDF_Escalation__c esc1 : [Select id, Core_MDF_Escalation_Status_nm__c from Core_MDF_Escalation__c
                                               WHERE id in: recordIdList]){
                esc1.Core_MDF_Escalation_Status_nm__c = 'Expired';
                escList.add(esc1);                                         
            }                                             
            Database.update(escList);
                        
            /*if(processInstanceWIList.size() > 0){  
                System.debug('piList-> '+processInstanceWIList);
                Database.delete(processInstanceWIList);                
            }  */
        }   
       
       catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
   }
    
    /***************************************************************************************************** 
    Class Name    :        initialInputs
    Description   :        contains all the invocable variables
    Added By      :        Accenture - Sugathri - 06/15/2020
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public class InitialInputs{
                            
        @InvocableVariable(label = 'record' required = true)
        public Core_MDF_Escalation__c escRecord;
       
        @InvocableVariable(label = 'status' required = true)
        public string status;   
        
        @InvocableVariable(label = 'approvalFlag' required = true)
        public Boolean approvalFlag;
    } 
    
    /***************************************************************************************************** 
    Method Name   :        determineMethod
    @return       :        void
    @parameters   :        List of initialInputs defined
    Description   :        Analyse the input parameters and call respective methods
    Added By      :        Accenture - Sugathri - 06/15/2020
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    @InvocableMethod
    public static void determineMethod(List<initialInputs> processInput){
        List<Core_MDF_Escalation__c> appCommentsList = new List<Core_MDF_Escalation__c>();
        List<Core_MDF_Escalation__c> expiredEscList = new List<Core_MDF_Escalation__c>();
        try{
            for(initialInputs inputs : processInput){
                if(inputs.status == 'Expired'){
                    expiredEscList.add(inputs.escRecord);
                }
                if(inputs.status != 'Expired' || inputs.approvalFlag){
                    appCommentsList.add(inputs.escRecord);
                }
            }
            if(expiredEscList != NULL && expiredEscList.Size() > 0){
                removeRecordFromApprovalProcess(expiredEscList);
            }
            if(appCommentsList != NULL && appCommentsList.Size() > 0){
                populateApproverNameAndComments(appCommentsList);
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
}