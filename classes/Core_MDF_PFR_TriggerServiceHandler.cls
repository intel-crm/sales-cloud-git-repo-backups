/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFR_TriggerServiceHandler
* Version     : 1.0
* Created Date: 11-19-2018
* Modification Log : 
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* SS                       02/20/2020                   Contains the bussiness logic of trigger to throw error
* Ganapati                 08/18/2020                   Added shareActivityToAccManagers method to share activity records to account managers       
*****************************************************************************************************************************************/
public with sharing class Core_MDF_PFR_TriggerServiceHandler {
    //Trigger Functionality Switch
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static boolean isInsertFirstRun = false;
    public static boolean isUpdateFirstRun = false;
    /*****************************************************************************************************
    Method Name :   validateActivityWithCampaign
    @return     :   NULL
    @parameters :   Map of old Activity record and Map of new Activity record
    Description :   It throws the error if Sum of Activity Amount Increase beyond Campaign Amount
    Added By    :   SS
    Modified By :                      Date:07/16/2020                     Changes:None
    ******************************************************************************************************/
    public static void validateActivityWithCampaign(Map<Id,PartnerFundRequest> oldMap, List<PartnerFundRequest> newList){
        // Get all the activities whose Amount is decreased
        Map<Id, Set<PartnerFundRequest>> campActivitiesSetMap = new Map<Id, Set<PartnerFundRequest>>();
        //Set<String> programsForActBudgetAmtCheck = new Set<String>();
        Set<Id> pfrIds = new Set<Id>();

        //Map to store the Activity as key and its Available Budget Amount.
        Map<Id,Decimal> mapOfCampWithAvailableBudget = new Map<Id,Decimal>();

        List<String> programsForActBudgetAmtCheck = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Prog_For_Bgt_Validation_PFR').split(';');
        for(PartnerFundRequest pfr : newList){
            system.debug('Here-->35'+programsForActBudgetAmtCheck.contains(pfr.Core_MDF_Program__c));
            if(programsForActBudgetAmtCheck.contains(pfr.Core_MDF_Program__c)){
                if(oldMap != NULL && !oldMap.isEmpty()){
                  //Update Scenario
                  if((pfr.RequestedAmount != oldMap.get(pfr.Id).RequestedAmount) &&
                  (pfr.RequestedAmount > oldMap.get(pfr.Id).RequestedAmount) &&
                  ((pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled') || oldMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != 'Cancelled' )){ // Use Cancel From Label
                        if(campActivitiesSetMap.containsKey(pfr.CampaignId)){
                            campActivitiesSetMap.get(pfr.CampaignId).add(pfr);
                        }
                        else{
                            campActivitiesSetMap.put(pfr.CampaignId, new Set<PartnerFundRequest>{pfr});
                        }
                        pfrIds.add(pfr.Id);
                    }
                }
                else{//New Scenario
                    if(campActivitiesSetMap.containsKey(pfr.CampaignId)){
                        system.debug('Here-->'+campActivitiesSetMap.get(pfr.CampaignId));
                        campActivitiesSetMap.get(pfr.CampaignId).add(pfr);
                    }
                    else{
                        system.debug('Here-->0'+campActivitiesSetMap.get(pfr.CampaignId));
                        campActivitiesSetMap.put(pfr.CampaignId, new Set<PartnerFundRequest>{pfr});
                    }
                }
            }
        }
        
        // Calculate the Total Amaount of Activities Under Same Campaign
        if(campActivitiesSetMap != NULL && campActivitiesSetMap.size() > 0){
            // Get the Campaigns Amount
            for(Campaign camp : [Select Id, Core_MDF_Total_Campaign_Cost_Amt__c from Campaign where Id IN : campActivitiesSetMap.keySet()])
            {
                // Add Campaigns Id and Amount in Map
                system.debug('Here-->1'+camp.Id+'--'+camp.Core_MDF_Total_Campaign_Cost_Amt__c);
                mapOfCampWithAvailableBudget.put(camp.Id, camp.Core_MDF_Total_Campaign_Cost_Amt__c);
            }
            //Aggregate result to the Sum of Claims Amount on an Activity
            List<AggregateResult> sumofPFRRequestedAmount = [SELECT CampaignID, SUM(RequestedAmount) pfrRequestedAmt, MAX(Campaign.Core_MDF_Total_Campaign_Cost_Amt__c) pfrCampaignAmount 
                                                             FROM PartnerFundRequest
                                                             WHERE CampaignID IN :campActivitiesSetMap.keySet() AND
                                                                   Core_MDF_Fund_Request_Status__c <> 'Cancelled' AND
                                                                     Id Not IN :pfrIds
                                                             GROUP BY CampaignID];
            //To Obtain the Available Amount by decducting the sum of the Request Amount from the Camapign Budget Amount
            if(sumofPFRRequestedAmount != null && sumofPFRRequestedAmount.size() > 0){
                for(AggregateResult agg : sumofPFRRequestedAmount){
                    Decimal pfrCampaignAmount =(Decimal)agg.get('pfrCampaignAmount');
                    Decimal pfrRequestedAmt=(Decimal)agg.get('pfrRequestedAmt');
                    mapOfCampWithAvailableBudget.put((id)agg.get('CampaignID'), pfrCampaignAmount - pfrRequestedAmt);
                }
            }
        }
        // Map of Campaign and PFR Set where Ammount is exceeding the campaigns amount
        Map< Id, Set<PartnerFundRequest>> errorPFRRecordsWithExceedingBudgets = New Map<Id, Set<PartnerFundRequest>>();
        //their Amount lies within the corresponding Campaign's Budget Amount
        if(campActivitiesSetMap != NULL && !campActivitiesSetMap.isEmpty()){
            for(Id campId : campActivitiesSetMap.keySet()){
                //get the list of pfrs for a given campaign
                Set<PartnerFundRequest> pfrSet = campActivitiesSetMap.get(campId);
                if(pfrSet != NULL && !pfrSet.isEmpty()){
                    for(PartnerFundRequest pfr : pfrSet){
                        //Get the corresponding Actvity's Available Budget Amount
                        Decimal availableAmount = mapOfCampWithAvailableBudget.get(pfr.CampaignId);
                        System.debug('availableAmount:::'+availableAmount);
                        System.debug('pfr.RequestedAmount:::'+pfr.RequestedAmount);
                        System.debug('pfr.RequestedAmount:::'+mapOfCampWithAvailableBudget.get(pfr.CampaignId));
                        if(pfr.RequestedAmount > availableAmount)
                        {
                            errorPFRRecordsWithExceedingBudgets.put(campId, pfrSet);
                            break;                      }
                        else
                        {
                            //If Activity Amount is lesser than or equal to the Campaign Amount,
                            //process it by deducting Requested Amount from the Available Amount
                            mapOfCampWithAvailableBudget.put(pfr.CampaignId, availableAmount - pfr.RequestedAmount);
                        }
                    }
                }
            }
        }
        if(errorPFRRecordsWithExceedingBudgets != NULL && !errorPFRRecordsWithExceedingBudgets.isEmpty()){
            for(Id errorCampId : errorPFRRecordsWithExceedingBudgets.keySet()){
                for(PartnerFundRequest errorPFR : errorPFRRecordsWithExceedingBudgets.get(errorCampId)){
                    //Add error if activity amount is more than the campaign's available amount
                    errorPFR.addError('Sum of all requested Amount cannot be greater than Propasal Amount');
                }
            }
        }
    }
    /*****************************************************************************************************
    Method Name :   validateActivityWithClaims
    @return     :   NULL
    @parameters :   Map of old Activity record and Map of new Activity record
    Description :   It throws the error if Activity Claim Submitter is trying to cancel Activity
                    record wiht In-Progres status and which has valid claims or complies date range or amount
    Added By    :   SS
    Modified By :                      Date:02/20/2020                     Changes:None
    ******************************************************************************************************/
    public static void validateActivityWithClaims(Map<Id,PartnerFundRequest> oldMap, Map<Id,PartnerFundRequest> newMap){
        //Get all the activity whose either Date or Status (Only In-Progress, Cancelled or Rejected) or Budget Amount Change
        Map<Id, PartnerFundRequest> activitiesWithClaimMap = new Map<Id, PartnerFundRequest>();
        for(PartnerFundRequest pfr : oldMap.values()){
            System.debug('Status '+pfr.Core_MDF_Fund_Request_Status__c);
            System.debug('old Start date '+pfr.Core_MDF_Start_Date__c);
            System.debug('New Start date '+newMap.get(pfr.Id).Core_MDF_Start_Date__c);
            System.debug('Old End Date '+pfr.Core_MDF_End_Date__c);
            System.debug('New End Date '+newMap.get(pfr.Id).Core_MDF_End_Date__c);
            System.debug('old RequestedAmount '+pfr.RequestedAmount);
           // System.debug('New RequestedAmount ' + newMap.get(pfr.Id).RequestedAmount );
            
            if(((pfr.Core_MDF_Fund_Request_Status__c.Equals(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_pfrInprogress')))||
                (pfr.Core_MDF_Fund_Request_Status__c.Equals(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status_Closed')))
                ) &&
               ((newMap.get(pfr.Id).Core_MDF_Start_Date__c != pfr.Core_MDF_Start_Date__c) ||
                (newMap.get(pfr.Id).Core_MDF_End_Date__c != pfr.Core_MDF_End_Date__c) ||
                (newMap.get(pfr.Id).RequestedAmount != pfr.RequestedAmount) ||
                ((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFRStatus')).contains(newMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c))
               )
              )
            {
                activitiesWithClaimMap.put(pfr.Id, pfr);
            }
        }
        // Get valid Claims
        if(activitiesWithClaimMap != NULL && activitiesWithClaimMap.size() > 0){
            Map<Id, PartnerFundClaim> validClaimsOnActivity = Core_MDF_PartnerFundRequest_Utility.getValidClaims(activitiesWithClaimMap);
            try{
                //Get RecordTypes for which budget is required
                Set <Id> recordTypeApplicableForAmountValidation = new Set<Id>();

                // Look into metadata for recordtype which is applicable for budget amount check
                List <String> recordTypeDevNameList = Core_MDF_PartnerFundRequest_Utility.getRecordTypeForWhichBudgetCheckRequired();

                // Get the recordtypeId as before Update does not developername
                for(RecordType recordType : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'PartnerFundRequest'
                                             AND DeveloperName IN : recordTypeDevNameList ] )
                {
                    recordTypeApplicableForAmountValidation.add(recordType.Id);
                }

                //US850621
                Map<Id, RecordType> recTypeMap = new Map<Id, RecordType>([SELECT Id FROM RecordType WHERE SobjectType = 'PartnerFundRequest' AND DeveloperName IN : recordTypeDevNameList]);
                if(recTypeMap != null && !recTypeMap.isEmpty()) {
                    recordTypeApplicableForAmountValidation.addAll(recTypeMap.keySet());
                }

                // Validates if the Claims or Budget on activity has been properly changes
                validatePFRDateBudgetAgainstActiveClaim(oldMap, newMap, validClaimsOnActivity, recordTypeApplicableForAmountValidation);
            }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        }
    }
    /*****************************************************************************************************
    Method Name :   validatePFRDateBudgetAgainstActiveClaim
    @return     :   NULL
    @parameters :   Map of old Activity record and Map of new Activity record and Map of validClaim
    Description :   It throws the error if Activity Claim Submitter is trying change the end date
                    and start date and it reaches out of date range of Claims.
    Added By    :   SS
    Modified By :                      Date:02/20/2020                     Changes:None
    ******************************************************************************************************/
    public static void validatePFRDateBudgetAgainstActiveClaim(Map<Id,PartnerFundRequest> oldPFRMap, Map<Id,PartnerFundRequest> newPFRMap,
                                                               Map<Id, PartnerFundClaim> validClaimMap, Set<Id> validBudgetCheckPFRRecordTypeIdSet){
        // Check Amount on Activity for Amount Change
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ActivityAmountValidation') &&
               mapFunctionalityNameTriggerExecution.get('Core_MDF_ActivityAmountValidation').Core_Active__c){
            validateBudgetAmount(oldPFRMap, newPFRMap, validClaimMap, validBudgetCheckPFRRecordTypeIdSet);
        }
        // Check Valid Claims on Activity for Status Change
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ActivityClaimsValidation') &&
                mapFunctionalityNameTriggerExecution.get('Core_MDF_ActivityClaimsValidation').Core_Active__c){
            validateActiveClaims(oldPFRMap, newPFRMap, validClaimMap);
        }
        // Check Date Change on Activity for Date Change
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ActivityDateValidation') &&
                mapFunctionalityNameTriggerExecution.get('Core_MDF_ActivityDateValidation').Core_Active__c){
            validateActivityDate(oldPFRMap, newPFRMap, validClaimMap);
        }
    }
    /*****************************************************************************************************
    Method Name :   validateBudgetAmount
    @return     :   NULL
    @parameters :   Map of old Activity record and Map of new Activity record
    Description :   It throws the error if Activity Claim Submitter is trying change the end date
                    and start date and it reaches out of date range of Claims.
    Added By    :   SS
    Modified By :                      Date:02/20/2020                     Changes:None
    ******************************************************************************************************/
    public static void validateBudgetAmount(Map<Id,PartnerFundRequest> oldPFRMap, Map<Id,PartnerFundRequest> newPFRMap , Map<Id, PartnerFundClaim> validClaimMap, Set<Id> validBudgetCheckPFRRecordTypeIdSet){
        Map<Id, Decimal> activityClaimAmountSumMap = new Map<Id, Decimal>();
        for(PartnerFundClaim claim : validClaimMap.values()){
            if(activityClaimAmountSumMap.containsKey(claim.RequestId)){
                system.debug('Check for negative claim, escalation');
                Decimal claimAmount = activityClaimAmountSumMap.get(claim.RequestId) + claim.Amount;
                activityClaimAmountSumMap.put(claim.RequestId, claimAmount);
            }else{
                activityClaimAmountSumMap.put(claim.RequestId, claim.Amount);
            }
        }
        for(PartnerFundRequest pfr : newPFRMap.values()){
            if(validBudgetCheckPFRRecordTypeIdSet.contains(pfr.RecordTypeId)){//check for Record Types
                if(activityClaimAmountSumMap != NULL && activityClaimAmountSumMap.containsKey(pfr.Id)){
                    if(pfr.RequestedAmount != (oldPFRMap.get(pfr.Id)).RequestedAmount &&
                       pfr.RequestedAmount < (activityClaimAmountSumMap.get(pfr.Id))){
                        //Get the valid Error message from Erika
                        pfr.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Decrease_Budget_Amount_Error'));//Budget Amount Cannot be less than claimed Amount
                        break;
                    }
                }
            }
        }
    }
    /*****************************************************************************************************
    Method Name :   validateActiveClaims
    @return     :   NULL
    @parameters :   Map of old Activity record and Map of new Activity record
    Description :   It throws the error if Activity Claim Submitter is trying change the end date
                    and start date and it reaches out of date range of Claims.
    Added By    :   SS
    Modified By :                      Date:02/20/2020                     Changes:None
    ******************************************************************************************************/
    public static void validateActiveClaims(Map<Id,PartnerFundRequest> oldPFRMap, Map<Id,PartnerFundRequest> newPFRMap , Map<Id, PartnerFundClaim> validClaimMap){
        Map<Id,List<Id>> activityClaimMap = new Map<Id,List<Id>>();
        for(PartnerFundClaim claim : validClaimMap.values()){
            if(activityClaimMap.containsKey(claim.RequestId)){
                activityClaimMap.get(claim.RequestId).add(claim.Id);
            }
            else{
                activityClaimMap.put(claim.RequestId,new List<Id>{claim.Id});
            }
        }
        //Core_MDF_PFRStatus : - Cancelled,Rejected
        //Core_MDF_pfrInprogess : - In-Progress
        ////(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status_Closed')).contains(pfr.Core_MDF_Fund_Request_Status__c)
        for(PartnerFundRequest pfr : newPFRMap.values()){
            if(activityClaimMap.containsKey(pfr.Id)  &&
               !(System.Label.Core_MDF_Is_ValidationBypassed == 'TRUE' &&
                System.Label.Core_MDF_VRBypassByUser.contains(UserInfo.getUserName()))){
                if(((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFRStatus')).contains(pfr.Core_MDF_Fund_Request_Status__c)
                   || (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status_Closed')).Equals(pfr.Core_MDF_Fund_Request_Status__c)) &&
                ((oldPFRMap.get(pfr.Id)).Core_MDF_Fund_Request_Status__c.Equals(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_pfrInprogress'))
                  || (oldPFRMap.get(pfr.Id)).Core_MDF_Fund_Request_Status__c.Equals(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status_Closed')))){
                    pfr.addError(Label.Core_MDF_ValidClaimError); //Activity cannot be cancelled
                    break;
                }
            }
        }
    }
    /*****************************************************************************************************
    Method Name :   validateActivityDate
    @return     :   NULL
    @parameters :   Map of old Activity record and Map of new Activity record
    Description :   It throws the error if Activity Claim Submitter is trying change the end date
                    and start date and it reaches out of date range of Claims.
    Added By    :   SS
    Modified By :                      Date:02/20/2020                     Changes:None
    ******************************************************************************************************/
    public static void validateActivityDate(Map<Id,PartnerFundRequest> oldMap,Map<Id,PartnerFundRequest> newMap, Map<Id, PartnerFundClaim> validClaimMap){
        //Creating Map which will hold pfrId and list of PartnerFundClaim
        Map<Id,List<PartnerFundClaim>> activityClaimMap = new Map<Id,List<PartnerFundClaim>>();
        List<String> claimStatusStrList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_InactiveStatusForClaim').split(';');
        //Populating activityClaimMap with valid claim records only
        for(PartnerFundClaim claim : validClaimMap.values()){
            if(activityClaimMap.containsKey(claim.RequestId)){
                activityClaimMap.get(claim.RequestId).add(claim);
            }
            else{
                activityClaimMap.put(claim.RequestId,new List<PartnerFundClaim>{claim});
            }
        }
        for(PartnerFundRequest pfr : newMap.values()){
            //Check for activity records with valid claims only
            if(activityClaimMap.keySet().contains(pfr.Id)){
                //Throw error when the actvity date goes out of claim date range
                if(pfr.Core_MDF_Start_Date__c != oldMap.get(pfr.Id).Core_MDF_Start_Date__c ||
                   pfr.Core_MDF_End_Date__c != oldMap.get(pfr.Id).Core_MDF_End_Date__c ){
                    for(PartnerFundClaim pfc : activityClaimMap.get(pfr.Id)){
                        if(pfr.Core_MDF_Start_Date__c > pfc.Core_MDF_Ad_Run_Start_Date__c ||
                           pfr.Core_MDF_End_Date__c < pfc.Core_MDF_Ad_Run_End_Date__c){
                               pfr.addError(Label.Core_MDF_ClaimDateError); //Activity date range must comply with Claim date range.
                               break;
                           }
                    }
                }
            }
        }
    }
    /*****************************************************************************************************
    Method Name :   updateActivityFields
    @return     :   NULL
    @parameters :   Map of old Activity record and Map of new Activity record
    Description :   It throws the error if Activity Claim Submitter is trying change the end date
                    and start date and it reaches out of date range of Claims.
    Added By    :   SS
    Modified By :                      Date:02/20/2020                     Changes:None
    ******************************************************************************************************/
   /* public static void updateActivityFields(Map<Id,PartnerFundRequest> newMap, Map<Id,PartnerFundRequest> oldMap){
        Core_MDF_UpdateActivityFields.populateBackEndFieldsUpdate(newMap,oldMap);
    }*/
    /*****************************************************************************************************
    Method Name :   insertActivityFields
    @return     :   NULL
    @parameters :   Map of old Activity record and Map of new Activity record
    Description :   It throws the error if Activity Claim Submitter is trying change the end date
                    and start date and it reaches out of date range of Claims.
    Added By    :   SS
    Modified By :                      Date:02/20/2020                     Changes:None
    ******************************************************************************************************/
    /*public static void insertActivityFields(List<PartnerFundRequest> newPFRList){
        Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(newPFRList);
    }*/
    
    /*
    * Method Name : shareActivityWithAccNodeGroup
    * Description : shares records with account manager group
    * Input Params: Map<Id,PartnerFundRequest> from Trigger.newMap, Map<Id,PartnerFundRequest> from Trigger.oldMap
    * Return       : None
    */ 
    public static void shareActivityWithAccNodeGroup(Map<Id,PartnerFundRequest> newActivityMap){
        Map<Id,Id> pfrIdAccIdMap = new Map<Id,Id>();
        Map<Id,Id> accIdGroupIdMap = new Map<Id,Id>();
        List<PartnerFundRequestShare> pfrShareList = new List<PartnerFundRequestShare>();
        Map<Id,List<Id>> objectIdUserGroupIdListMap = new Map<Id,List<Id>>();

        for(Id pfrId : newActivityMap.keySet()) {           
            pfrIdAccIdMap.put(pfrId, newActivityMap.get(pfrId).ChannelPartnerId);           
        }

        if(pfrIdAccIdMap != NULL && !pfrIdAccIdMap.isEmpty()){
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Core_MDF_Group_Id__c, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c
                                                                FROM Account
                                                                WHERE Id IN :pfrIdAccIdMap.values() 
                                                                AND Core_MDF_Group_Id__c != NULL]);
            if(accountMap != NULL && !accountMap.isEmpty()) {
                for(Id pfrId : pfrIdAccIdMap.keySet()){
                    if(pfrIdAccIdMap.get(pfrId) != NULL && accountMap.get(pfrIdAccIdMap.get(pfrId)) != NULL && 
                       (Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd((accountMap.get(pfrIdAccIdMap.get(pfrId))).Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c))){ 
                        objectIdUserGroupIdListMap.put(pfrId, new List<Id>{accountMap.get(pfrIdAccIdMap.get(pfrId)).Core_MDF_Group_Id__c});
                    }
                }

                if(objectIdUserGroupIdListMap != NULL && !objectIdUserGroupIdListMap.isEmpty()){
                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundRequest', objectIdUserGroupIdListMap, 'Edit', 'Manual');
                    Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
                    //Core_MDF_GenericShareRecordActionCopy.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionCopy.RecordManualShareClass('PartnerFundRequest', objectIdUserGroupIdListMap, 'Edit', 'Manual');
                    //Core_MDF_GenericShareRecordActionCopy.createShareRecordList(rmsInst);
                }
            }
        }
    }
    
    /*****************************************************************************************************
    Method Name :   calculateRR
    @return     :   NULL
    @parameters :   List of new PFR Records
    Description :   Based of US824858, calculating Activity Reimbursment Rate for all Programs. 
    Added By    :   Manasa - 10/29/2020
    ******************************************************************************************************/
    public static void calculateRR(List<PartnerFundRequest> newList){
        //Core_MDF_UpdateActivityFields.computeRR(newList);
    }
    
}