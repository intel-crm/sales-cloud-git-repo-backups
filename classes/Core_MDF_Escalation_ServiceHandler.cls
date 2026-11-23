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
    public static Boolean isBudgetCapErrorOccured = false;
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
            //List<Core_MDF_Escalation__c> activityEscToBoProcessed  = new List<Core_MDF_Escalation__c>();
            Set<Id> budgetIdSet = new Set<Id>();
            Set<Id> caseIdSet = new Set<Id>();
            Set<Id> activityIdSet = new Set<Id>();
            Map<Id,Id> budgetIdWithProgramId = new Map<Id,Id>();
            Map<Id,Id> caseIdWithProgramId = new Map<Id,Id>();
            Map<Id,Id> activityIdWithProgramId = new Map<Id,Id>();
            Map<Id,String> activityIdWithAccountId = new Map<Id,String>();
            Set<Id> clmIdAccIdSet = new Set<Id>();
            Set<Id> clmIdBankIdSet = new Set<Id>();
            Map<Id,String> caseIdWithAccIdBankIdMap = new Map<Id,String>();
            Map<String, Boolean> abmActiveMap = new Map<String, Boolean>();
            Set<Id> abmAccIdSet = new Set<Id>();
            Map<Id, Boolean> accIdWithActiveInd = new Map<Id, Boolean>();
            
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
                for(PartnerFundclaim pfc: [SELECT Id, ChannelPartnerId, Core_MDF_Bank__c, Core_MDF_Claim_Review_Case__c, 
                                           Core_MDF_Claim_Review_Case__r.AccountId, Core_MDF_Claim_Review_Case__r.Account.Core_MDF_Channel_Program__c,
                                           ChannelPartner.Core_MDF_Active_Ind__c
                                           FROM PartnerFundclaim
                                           WHERE Core_MDF_Claim_Review_Case__c IN: caseIdSet]){
                    caseIdWithProgramId.put(pfc.Core_MDF_Claim_Review_Case__c, pfc.Core_MDF_Claim_Review_Case__r.Account.Core_MDF_Channel_Program__c);
                    clmIdAccIdSet.add(pfc.ChannelPartnerId);
                    clmIdBankIdSet.add(pfc.Core_MDF_Bank__c);
                    //Prepare Map to fetch Account+Bank from Claim  
                    caseIdWithAccIdBankIdMap.put(pfc.Core_MDF_Claim_Review_Case__c, (String)pfc.ChannelPartnerId+pfc.Core_MDF_Bank__c);
                    accIdWithActiveInd.put(pfc.ChannelPartnerId, pfc.ChannelPartner.Core_MDF_Active_Ind__c);

                }           
            }
            
            //Query Channel Program from Activity and add channel program Id to activityIdWithProgramId Map
            if(activityIdSet.size() > 0){
                for(PartnerFundRequest pfr: [SELECT Id, ChannelPartner.Core_MDF_Channel_Program__c, 
                                             ChannelPartner.Core_MDF_Active_Ind__c, ChannelPartnerId 
                                             FROM PartnerFundRequest 
                                             WHERE Id IN: activityIdSet]){
                    activityIdWithProgramId.put(pfr.Id,pfr.ChannelPartner.Core_MDF_Channel_Program__c);
                    //Prepare Map to fetch Activity's Account
                    activityIdWithAccountId.put(pfr.Id,(String)pfr.ChannelPartnerId);
                    accIdWithActiveInd.put(pfr.ChannelPartnerId, pfr.ChannelPartner.Core_MDF_Active_Ind__c);
                }           
                }           
            
            System.debug('activityIdWithAccountId---' + activityIdWithAccountId);            
            
            for(Core_MDF_Account_Bank_Mapping__c abm: [Select Id, Core_MDF_Account__c, Core_MDF_Bank__c, Core_MDF_Active_ind__c, Core_MDF_AccountIdBankIdMapping__c 
                                                       from Core_MDF_Account_Bank_Mapping__c 
                                                       where ((Core_MDF_Account__c IN: activityIdWithAccountId.values()) OR 
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
            //Set Program for esclation
            for(Core_MDF_Escalation__c esc: escalationToBoProcessed){
                if(esc.recordTypeId == escBudgetRecTypeId && budgetIdSet.size() > 0 && budgetIdWithProgramId.containsKey(esc.Core_MDF_Budget_ID_Number_id__c)){
                    esc.Core_MDF_Program_txt__c = budgetIdWithProgramId.get(esc.Core_MDF_Budget_ID_Number_id__c);
                    esc.Core_MDF_Channel_Program_id__c = budgetIdWithProgramId.get(esc.Core_MDF_Budget_ID_Number_id__c);                
                }
                
                if(esc.recordTypeId == escCaseRecTypeId && caseIdSet.size() > 0 && caseIdWithProgramId.containsKey(esc.Core_MDF_Case_ID_Number_id__c)){
                    
                    String accountId = caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c).left(18);
                    
                    //Check if case account is active
                    if(((abmActiveMap.containsKey(caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c)) &&
                         !abmActiveMap.get(caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c))) ||
                        (!abmActiveMap.containsKey(caseIdWithAccIdBankIdMap.get(esc.Core_MDF_Case_ID_Number_id__c)))) && accIdWithActiveInd.get(accountId)){
                            esc.addError(Label.Core_MDF_Escalation_Error_for_Inactive_ABM);
                        }
                    esc.Core_MDF_Program_txt__c = caseIdWithProgramId.get(esc.Core_MDF_Case_ID_Number_id__c);
                    esc.Core_MDF_Channel_Program_id__c = caseIdWithProgramId.get(esc.Core_MDF_Case_ID_Number_id__c);                
                } 
                
                // setting Channel Program Name and Program Id based on Activity
                if(esc.recordTypeId == escActivityRecTypeId && activityIdSet.size() > 0 && activityIdWithProgramId.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c)){
                    
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
                    esc.Core_MDF_Program_txt__c = activityIdWithProgramId.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                    esc.Core_MDF_Channel_Program_id__c = activityIdWithProgramId.get(esc.Core_MDF_Co_Marketing_Activity_id__c);                
                } 
                
            }  
        }
        catch(Exception e){
            String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,Label.Core_MDF_Set_Program_for_Escalation);
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
            
            List<Core_MDF_Escalation__c> escalationToBoProcessed  = new List<Core_MDF_Escalation__c>();
            Set<Id> budgetIdSet = new Set<Id>();
            Set<Id> caseIdSet = new Set<Id>();
            Set<Id> activityIdSet = new Set<Id>();
            Map<Id,String> budgetIdWithIntelAccId = new Map<Id,String>();
            Map<Id,String> caseIdWithIntelAccId = new Map<Id,String>();
            Map<Id,String> activityIdWithIntelAccId = new Map<Id,String>();
            Set<Id> intelAccSet = new Set<Id>();
            
            for(Core_MDF_Escalation__c esc: escalationMap.values()){
                if(esc.recordTypeId == escBudgetRecTypeId && esc.Core_MDF_Budget_ID_Number_id__c != null &&
                   (isInsert || esc.OwnerId != escalationOldMap.get(esc.Id).OwnerId)){
                       escalationToBoProcessed.add(esc);
                       budgetIdSet.add(esc.Core_MDF_Budget_ID_Number_id__c);
                   }
                
                if(esc.recordTypeId == escCaseRecTypeId && esc.Core_MDF_Case_ID_Number_id__c != null &&
                   (isInsert || esc.OwnerId != escalationOldMap.get(esc.Id).OwnerId)){
                       escalationToBoProcessed.add(esc);
                       caseIdSet.add(esc.Core_MDF_Case_ID_Number_id__c);
                   }
                
                //adding Core_MDF_Co_Marketing_Activity_id__c to activityIdSet
                if(esc.recordTypeId == escActivityRecTypeId && esc.Core_MDF_Co_Marketing_Activity_id__c != null &&
                   (isInsert || esc.OwnerId != escalationOldMap.get(esc.Id).OwnerId)){
                       escalationToBoProcessed.add(esc);
                       activityIdSet.add(esc.Core_MDF_Co_Marketing_Activity_id__c);
                   }                       
            }
           
            //Fetching Account from Escalation based on Budget, Case and Late Claim
            for(Core_MDF_Escalation__c esc: [SELECT Id, recordTypeId, Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c, 
                                             Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program_id__c,
                                             Core_MDF_Case_ID_Number_id__r.Core_Account_Geo__c,
                                             Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_cd__c,
                                             Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c 
                                             FROM Core_MDF_Escalation__c where ID IN: escalationMap.keySet()]){
                
                //if Budget's Account is not null, storing Account into budgetIdWithIntelAccId Map and add Account to intelAccSet Set
                if(budgetIdSet.size() > 0 && esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c != null){
                    budgetIdWithIntelAccId.put(esc.Core_MDF_Budget_ID_Number_id__c, esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c);
                    intelAccSet.add(esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c);
                }
                
                //if Case's Account is not null, storing Account into caseIdWithIntelAccId Map and add Account to intelAccSet Set
                if(caseIdSet.size() > 0 && esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c != null){
                    String accIdProgramIdGeoFromCase = (String)esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c+esc.Core_MDF_Case_ID_Number_id__r.Core_Account_Geo__c.trim();
                    caseIdWithIntelAccId.put(esc.Core_MDF_Case_ID_Number_id__c, accIdProgramIdGeoFromCase);
                    intelAccSet.add(esc.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c);                                        
                }
                
                //if Activity's Account is not null, storing Account into activityIdWithIntelAccId Map and add Account to intelAccSet Set                                    
                if(activityIdSet.size() > 0 && esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c != null){
                    String accIdProgramIdGeoFromActivity = (String)esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+esc.Core_MDF_Channel_Program_id__c+esc.Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Region_cd__c;
                    activityIdWithIntelAccId.put(esc.Core_MDF_Co_Marketing_Activity_id__c, accIdProgramIdGeoFromActivity);
                    intelAccSet.add(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c);
                }
                
            }
            
            
            if(intelAccSet.size()<1){
                return;
            }
            
            //Fetching PGM records and storing them in map with Account
            
            Map<String,List<Id>> intelAccIdWithGroup = new Map<String,List<Id>>();
            Map<String,Id> pgmForGeoMap = new Map<String,Id>();
            Map<String,Id> pgmForWWMap = new Map<String,Id>();
            for(Core_MDF_Partner_Group_Mapping__c pgm:[SELECT Id, Core_MDF_Group_Id__c, Core_MDF_Account__c, Core_MDF_Channel_Program__c,Core_MDF_Region_cd__c
                                                       FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Type_of_Access__c='Internal' 
                                                       AND Core_MDF_Account__c IN :intelAccSet]){
                //To share escalation of budget type with all pgm                                           
                if(intelAccIdWithGroup.containsKey(pgm.Core_MDF_Account__c+'#'+pgm.Core_MDF_Channel_Program__c)){
                    intelAccIdWithGroup.get(pgm.Core_MDF_Account__c+'#'+pgm.Core_MDF_Channel_Program__c).add(pgm.Core_MDF_Group_Id__c);
                }
                else{
                    List<Id> tempPGM = new List<Id>();
                    tempPGM.add(pgm.Core_MDF_Group_Id__c);
                    intelAccIdWithGroup.put(pgm.Core_MDF_Account__c+'#'+pgm.Core_MDF_Channel_Program__c,tempPGM);
                }
				
				//To share case and activity escalation with geo specific and ww groups
				String accProgramGeoFromPGM = (String)pgm.Core_MDF_Account__c+pgm.Core_MDF_Channel_Program__c+pgm.Core_MDF_Region_cd__c;
				pgmForGeoMap.put(accProgramGeoFromPGM,pgm.Core_MDF_Group_Id__c);
				accProgramGeoFromPGM = accProgramGeoFromPGM.left(36);
				if(pgm.Core_MDF_Region_cd__c == 'WW'){
                   pgmForWWMap.put(accProgramGeoFromPGM,pgm.Core_MDF_Group_Id__c);                                        
				}
            }
            System.debug('pgmForGeoMap---' + pgmForGeoMap);
            System.debug('pgmForWWMap---' + pgmForWWMap);
            //Create escalation share records 
            Id intelAccountId;
            Map<Id,List<Id>> esclationWithGroupId = new Map<Id,List<Id>>();
            
            for(Core_MDF_Escalation__c esc: escalationToBoProcessed){
            List<Id> groupIdList = new List<Id>();
                //Budget Escalation
                if(esc.recordTypeId == escBudgetRecTypeId && budgetIdWithIntelAccId.containsKey(esc.Core_MDF_Budget_ID_Number_id__c ) &&
                   budgetIdWithIntelAccId.get(esc.Core_MDF_Budget_ID_Number_id__c )!= null){
                       intelAccountId = budgetIdWithIntelAccId.get(esc.Core_MDF_Budget_ID_Number_id__c );
                       if(intelAccIdWithGroup.containsKey(intelAccountId+'#'+esc.Core_MDF_Channel_Program_id__c) && 
                          intelAccIdWithGroup.get(intelAccountId+'#'+esc.Core_MDF_Channel_Program_id__c)!=null){
                              esclationWithGroupId.put(esc.Id,intelAccIdWithGroup.get(intelAccountId+'#'+esc.Core_MDF_Channel_Program_id__c));
                          }
                   }
                //Case Escalation
                if(esc.recordTypeId == escCaseRecTypeId && caseIdWithIntelAccId.containsKey(esc.Core_MDF_Case_ID_Number_id__c )){
                    String key = caseIdWithIntelAccId.get(esc.Core_MDF_Case_ID_Number_id__c);
                    if(pgmForGeoMap.containsKey(key)){
                        groupIdList.add(pgmForGeoMap.get(key));
                    }
                    key = key.left(36);
                    if(pgmForWWMap.containsKey(key)){
                        groupIdList.add(pgmForWWMap.get(key));
                    }
                }
                
                //Activity Escalation
                if(esc.recordTypeId == escActivityRecTypeId && activityIdWithIntelAccId.containsKey(esc.Core_MDF_Co_Marketing_Activity_id__c )){
                   String key = activityIdWithIntelAccId.get(esc.Core_MDF_Co_Marketing_Activity_id__c);
                    System.debug('key---' + key);
                    if(pgmForGeoMap.containsKey(key)){
                        groupIdList.add(pgmForGeoMap.get(key));
                    }
                    key = key.left(36);
                    if(pgmForWWMap.containsKey(key)){
                        groupIdList.add(pgmForWWMap.get(key));
                    }
                }
                
                System.debug('groupIdList---' + groupIdList);
                if(groupIdList.Size() > 0){
                    esclationWithGroupId.put(esc.Id,groupIdList);
                }            	
            }
            
            //Call Generic Approval Process class to create escalation Share records        
            if(esclationWithGroupId.size()>0){
                //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Escalation__c', esclationWithGroupId); 
            	Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Escalation__c',esclationWithGroupId, 'Edit');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
        }
        catch(Exception e){ 
            String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,Label.Core_MDF_Escalation_Sharing );
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
            // Map<caseId,escalationRecord>
            Map<Id, Core_MDF_Escalation__c> escToBeProcessedMap = new Map<Id, Core_MDF_Escalation__c>();
            Id escCaseRecTypeId = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId(); 
            
            Set<Id> caseIdSet = new Set<Id>();
            List<Core_MDF_Escalation__c> listEscToBeUpdated = new List<Core_MDF_Escalation__c>();       
            for(Core_MDF_Escalation__c esc: escalationList){
                
                if(esc.recordTypeId == escCaseRecTypeId && esc.Core_MDF_Case_ID_Number_id__c != null &&
                    esc.Core_MDF_Escalation_Status_nm__c != escalationOldMap.get(esc.Id).Core_MDF_Escalation_Status_nm__c &&
                    esc.Core_MDF_Escalation_Status_nm__c == Label.Core_MDF_Status_Approved){
                        escToBeProcessedMap.put(esc.Core_MDF_Case_ID_Number_id__c, esc);
                }       
            }
            System.debug('escToBeProcessedMap:'+escToBeProcessedMap);
            List<Case> toBeUpdatedCases = new List<Case>();
            List<PartnerFundClaim>  toBeUpdatedClaims = new List<PartnerFundClaim>();
            List<Core_MDF_Adjustment_Request__c> toBeInsertedAdjustmentRec = new List<Core_MDF_Adjustment_Request__c>();
            //Map<Id,Id> claimIdWithCaseIdMap = new Map<Id,Id>(); 
            
            for(PartnerFundClaim pfc: [SELECT Id, Core_MDF_Claim_Review_Case__c, Core_MDF_Status__c, Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Review_Case_Status__c
                                        ,Core_MDF_Claim_Review_Case__r.Core_MDF_Claim_Conversion_Exchange_Rate__c FROM PartnerFundClaim WHERE Core_MDF_Claim_Review_Case__c IN : escToBeProcessedMap.keySet()]){
                            
               		String claimStatus = pfc.Core_MDF_Status__c;
                    List<String> nonPaidclmStsLst = System.Label.Core_MDF_Pre_Payment_Claim_Statuses.split(';');
                    List<String> paidclmStsLst = System.Label.Core_MDF_Post_Payment_Claim_Statuses.split(';');
                                            
                    //If claim is in Pending Available Fund, Payment Due, Hold OR If claim is in Pending Payment, Paid, Cancelled, Denied                       
                    if(nonPaidclmStsLst.contains(claimStatus) || paidclmStsLst.contains(claimStatus)){
                        
                      Core_MDF_Adjustment_Request__c adjRec = new Core_MDF_Adjustment_Request__c();
                      adjRec.Core_MDF_Amount_Amt__c = escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Approved_Amount_amt__c;
                      adjRec.Core_MDF_Reference_Claim_Nbr__c = pfc.Id;
                      adjRec.Core_MDF_Reason_Cd__c = Label.Core_MDF_Claim_Review_Results_Positive;
                      adjRec.Core_MDF_Escalation_Id__c = escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Id;
                      toBeInsertedAdjustmentRec.add(adjRec);  
                        //If claim is in Pending Available Fund, Payment Due, Hold      
                        if(nonPaidclmStsLst.contains(claimStatus)){ 
                            
                            //Decimal previousAdjAmount = pfc.Core_MDF_Audit_Adjustment_Amount__c;
                            Decimal currentAdjAmount = pfc.Core_MDF_Audit_Adjustment_Amount__c -
                                                        escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Approved_Amount_amt__c;
                            
                            
                            //Replaced Core_MDF_Total_Dollar_Impact_amt__c with Core_MDF_Approved_Amount_amt__c to calculate Adjustment Amount (USD) on Claim based on Escalation Approved Amount
                            /*pfc.Core_MDF_Audit_Adjustment_Amount__c = pfc.Core_MDF_Audit_Adjustment_Amount__c -
                                                                        escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Approved_Amount_amt__c;
                            
                            Case caseToBeUpdated = new Case();
                            caseToBeUpdated.Id = pfc.Core_MDF_Claim_Review_Case__c;
                            //Replaced Core_MDF_Total_Dollar_Impact_amt__c with Core_MDF_Approved_Amount_amt__c to calculate Adjustment Amount (Local Currency) on Case based on Escalation Approved Amount
                            caseToBeUpdated.Core_MDF_Adjustment_Amount_Local__c  = (previousAdjAmount - escToBeProcessedMap.get(pfc.Core_MDF_Claim_Review_Case__c).Core_MDF_Approved_Amount_amt__c)/pfc.Core_MDF_Claim_Review_Case__r.Core_MDF_Claim_Conversion_Exchange_Rate__c;
                            caseToBeUpdated.Core_MDF_Adjustment_Amount_USD_Amt__c = pfc.Core_MDF_Audit_Adjustment_Amount__c; 
                            toBeUpdatedCases.add(caseToBeUpdated);*/
                            
                            //Add Error if adjustment amount is less than 0
                            //if(pfc.Core_MDF_Audit_Adjustment_Amount__c < 0){
                            if(currentAdjAmount < 0){
                                escalationList[0].addError(Label.Core_MDF_Adjustment_Amount_Error);                                                             
                            }                    
                        }  
                         //If claim is in Pending Payment, Paid, Cancelled, Denied   
                         //Claims after payment 
                         //Create Adjustment Request Record
                         else if(paidclmStsLst.contains(claimStatus)){
                                    
                                //claimIdWithCaseIdMap.put(pfc.Id,pfc.Core_MDF_Claim_Review_Case__c);            
                                // if claims are denied or cancelled                
                                if(pfc.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_Denied){
                                    pfc.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Adjusted;
                                    Case cs = new Case();
                                    cs.Id = pfc.Core_MDF_Claim_Review_Case__c;
                                    cs.Core_MDF_Review_Case_Status__c = Label.Core_MDF_Case_Status_Compliant;
                                    cs.Core_MDF_Status__c = Label.Core_MDF_Case_Status_Compliant;   
                                    toBeUpdatedCases.add(cs);                   
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
            if(listEscToBeUpdated.size() > 0){
                Database.update(listEscToBeUpdated);
            }
        }        
        catch(Exception e){
            errorMessage = Core_MDF_CCP_UtilityClass.getErrorDetails(e); 
            iserrorOccured = true;
            
            //Check for budget cap error
            if(!String.isBlank(errorMessage) && errorMessage.contains(Label.Core_MDF_ClaimExceedsCapRemainder_ErrorMsg)){
                isBudgetCapErrorOccured = true;
                escalationList[0].addError(Label.Core_MDF_Escalation_Approval_Error_Message);
            }else{
                //System.debug('Came Here');
                escalationList[0].addError(Label.Core_MDF_ApplicationErrorMessage); //                                                           
            }                                      
        }
        finally{
            System.debug('isBudgetCapErrorOccured: '+isBudgetCapErrorOccured);
            System.debug('iserrorOccured: '+iserrorOccured);
            System.debug('errorMessage: '+errorMessage);
            if(iserrorOccured){
                Core_MDF_Notify_Account_Manager__e notificationEvent = new Core_MDF_Notify_Account_Manager__e();
                notificationEvent.Core_MDF_Escalation_Id_txt__c = String.valueOf(escalationList[0].Id);
                notificationEvent.Core_MDF_isBusinessError_ind__c = isBudgetCapErrorOccured == true ? true : false;
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
       try {
            Boolean usrHasPer = false;
            Schema.DescribeSObjectResult chkPer = Schema.sObjectType.PartnerFundClaim;
            usrHasPer = chkPer.isCreateable();
            return usrHasPer; 
    }     
    catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);return false;}
    }           
}