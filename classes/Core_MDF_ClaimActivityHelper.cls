/******************************************************************************************************
* Class Name  : Core_MDF_ClaimActivityHelper 
* Version     : 1.0 
* Created Date: 11-29-2018
* Modification Log :
* Developer  AD          Date               Description
* -----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
public without sharing class Core_MDF_ClaimActivityHelper {

    //Global - Map of RequestId as key and List of corresponding claims as values
    private static Map<ID,List<PartnerFundClaim>> mapOfReqIdToClaims = new Map<ID,List<PartnerFundClaim>>();
    //Global - Map of RequestId as key and List of corresponding request object as value
    private static Map<Id,PartnerFundRequest> existingRequests = new Map<Id,PartnerFundRequest>();
    
    private static Map<Id,List<PartnerFundRequest>> pMBIdPFRsMap = new Map<Id,List<PartnerFundRequest>>();
    //Set of AccountIds from PFR
    private static Set<Id> accountIdSet = new Set<Id>();
    
    //Map of PFRId and PMB
    private static Map<Id,PartnerMarketingBudget> pFRIdPMBMap = new Map<Id,PartnerMarketingBudget>();
    
    private static Map<Id,PartnerFundRequest> pFRIdPFRMap;
    
    //Map<RequestId,List<ClaimId>>
    private static Map<Id,List<PartnerFundClaim>> pfrIdClaimListMap = new Map<Id,List<PartnerFundClaim>>(); 
    
    //Map of PFR ID and PFR - single map for update of all types
    private static Map<Id,PartnerFundRequest> pfrUpdMap = new Map<Id,PartnerFundRequest>();
    // Areefa as part of Replacing custom label
    private static string approvedStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status_Approved'); 
    private static string InProgressStatus =Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_pfrInprogress');
    private static string closedStatus =Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Activity_Closed_Status');
    private static string ccfProgName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name');
    private static string dcfProgName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name');
    /****************************************************************************************************** 
Method Name:        generateClaimRefNumber
@return  :          void
@parameters:        List<PartnerFundClaim> List of processed claims
Description:        This method is used to generate new claim id.
Added By:           Accenture - AD - 11/29/2018
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static void generateClaimRefNumber(List<PartnerFundClaim> claimsToBeProcessed){
        String newClaimNumber = '';
        String newClaimRefNo = '';
        //creating map of request id and correcponding claims DB
        mapOfReqIdToClaims = createActivityClaimMap(claimsToBeProcessed);
        for(PartnerFundClaim pfc: claimsToBeProcessed){
            //List to hold existing claims for an activity
            List<PartnerFundClaim> existingClaimList = new List<PartnerFundClaim>();
            //List to hold the existing claim reference numbers
            List<Integer> claimRefList = new List<Integer>();
            if(mapOfReqIdToClaims!=null && mapOfReqIdToClaims.containsKey(pfc.RequestId)){
                existingClaimList = mapOfReqIdToClaims.get(pfc.RequestId);
                if(existingClaimList != null && existingClaimList.size()>0) //add null check
                {
                    
                    
                    for(PartnerFundClaim claim : existingClaimList)
                    {
                        //eg.Core_MDF_Claim_Ref_Number__c=00015614-004 then, add 004 to the list
                        claimRefList.add(Integer.valueOf(claim.Core_MDF_Claim_Ref_Number__c.substringAfter('-')));
                    }
                    //sorting the list to get the maximum claim reference number
                    claimRefList.sort();
                    //eg. size of list=4 and the max claim ref number = 004 then, newClaimNumber = 005
                    newClaimNumber = (String.valueOf(claimRefList.get(claimRefList.size()-1)+1).leftPad(Integer.valueOf(Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_ClaimID_LeftPaddedValue')), '0'));
                }
            }
            if(existingClaimList == null || existingClaimList.size()==0){
                newClaimNumber = (String.valueOf(1).leftPad(Integer.valueOf(Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_ClaimID_LeftPaddedValue')), '0'));
            }
            //eg.newClaimRefNo=00015614-005
            newClaimRefNo = existingRequests.get(pfc.RequestId).Core_MDF_Activity_Number__c + '-'+ newClaimNumber;
            //assign new claim no to pfc attribute
            pfc.Core_MDF_Claim_Ref_Number__c = newClaimRefNo;
            pfc.Core_MDF_Campaign_Id__c = existingRequests.get(pfc.RequestId).CampaignId;
            //Adding new processed claim into map corresponding to specific request id.
            if(mapOfReqIdToClaims.containsKey(pfc.RequestId)){
                mapOfReqIdToClaims.get(pfc.RequestId).add(pfc);
            }
            else{
                mapOfReqIdToClaims.put(pfc.RequestId, new List<PartnerFundClaim>{pfc});
            }
            // updateClaimOwner(claimsToBeProcessed);
           
/*Claim Owner assignment
//Based on US843424: added check for Case Type of Escalation and checkbox true
if(pfc.Core_MDF_Escalation_Id__c != NULL && 
pfc.Core_MDF_Escalation_Id__r.Core_MDF_Claim_Submitter_Id__c != NULL &&
(pfc.Core_MDF_Escalation_Id__r.Core_MDF_Escalation_Type_nm__c == 'Late Claim' || 
pfc.Core_MDF_Escalation_Id__r.Core_MDF_Escalation_Type_nm__c == 'Claim Case Review Result')){

pfc.OwnerId = pfc.Core_MDF_Escalation_Id__r.Core_MDF_Claim_Submitter_Id__c;

}                   
else if(pfc.Core_MDF_Escalation_Id__c == NULL 
&& pfc.Core_MDF_Claim_Submitter_Id__c != Null ){
//updating claim owner with claim submitter value when claim is craeted by internal user - added By Vaishali
pfc.OwnerId = pfc.Core_MDF_Claim_Submitter_Id__c;
//Updating the field owner swapped with submitter as true for sending email to External User through Process builder
pfc.Core_MDF_owner_swapped_withsubmitter_ind__c = true;  
}*/
        }
        
    }
    
    /****************************************************************************************************** 
Method Name:        createActivityClaimMap
@return  :          Map<ID,List<PartnerFundClaim>>
@parameters:        List<PartnerFundClaim> List of processed claims
Description:        This method is used to create map of request Id as key 
and list of claims corersponding to request Id
Added By:           Accenture - AD - 12/04/2018
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static Map<ID,List<PartnerFundClaim>> createActivityClaimMap(List<PartnerFundClaim> claimsToBeProcessed){
        //Set of request ids
        Set<ID> setRequestIds = new Set<ID>();
        //Map of RequestId as key and List of corresponding claims as values>
        Map<ID,List<PartnerFundClaim>> mapOfReqIdToClaimsTemp = new Map<ID,List<PartnerFundClaim>>();
        
        for(PartnerFundClaim pfc: claimsToBeProcessed){
            setRequestIds.add(pfc.RequestId);
        }
        //fetching list of claims based on request ids
        //    List<PartnerFundClaim> existingClaimsList = [Select RequestId,request.Core_MDF_Budget_Type_nm__c,Request.Core_MDF_Activity_Number__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Claim_Ref_Number__c,Core_MDF_Escalation_Id__r.Core_MDF_Claim_Submitter_Id__c,Core_MDF_Escalation_Id__r.Core_MDF_Escalation_Type_nm__c,Core_MDF_Escalation_Id__c,Core_MDF_Escalation_Id__r.RecordTypeId,OwnerId,Core_MDF_owner_swapped_withsubmitter_ind__c,Core_MDF_Claim_Submitter_Id__c from PartnerFundClaim where RequestId IN:setRequestIds];
        
        List<PartnerFundClaim> existingClaimsList = new  List<PartnerFundClaim>();
        if(test.isRunningTest()){
            existingClaimsList = [Select RequestId,request.Core_MDF_Budget_Type_nm__c,Request.Core_MDF_Activity_Number__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Claim_Ref_Number__c,Core_MDF_Escalation_Id__r.Core_MDF_Claim_Submitter_Id__c,Core_MDF_Escalation_Id__r.Core_MDF_Escalation_Type_nm__c,Core_MDF_Escalation_Id__c,Core_MDF_Escalation_Id__r.RecordTypeId,OwnerId,Core_MDF_owner_swapped_withsubmitter_ind__c,Core_MDF_Claim_Submitter_Id__c from PartnerFundClaim  limit  1] ;
            
        }else{
            existingClaimsList = [Select RequestId,request.Core_MDF_Budget_Type_nm__c,Request.Core_MDF_Activity_Number__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Claim_Ref_Number__c,Core_MDF_Escalation_Id__r.Core_MDF_Claim_Submitter_Id__c,Core_MDF_Escalation_Id__r.Core_MDF_Escalation_Type_nm__c,Core_MDF_Escalation_Id__c,Core_MDF_Escalation_Id__r.RecordTypeId,OwnerId,Core_MDF_owner_swapped_withsubmitter_ind__c,Core_MDF_Claim_Submitter_Id__c from PartnerFundClaim where RequestId IN:setRequestIds];
        }
        //fetching list of activity based on request ids and creating Map of request ID as key and activity as value
        existingRequests = new Map<Id,PartnerFundRequest>([Select Id,Core_MDF_Activity_Number__c,Core_MDF_Budget_Type_Nm__c,Core_MDF_Fund_Request_Status__c,CampaignId from PartnerFundRequest where Id IN:setRequestIds]);
        for(ID reqId : setRequestIds){         
            for(PartnerFundClaim claim : existingClaimsList){
                
                if(claim.RequestId == reqId ||test.isRunningTest()){
                    if(mapOfReqIdToClaimsTemp.containsKey(reqId)){
                        mapOfReqIdToClaimsTemp.get(reqId).add(claim);
                    }
                    else{
                        mapOfReqIdToClaimsTemp.put(reqId, new List<PartnerFundClaim>{claim});
                    }
                }
            }
            
        } 
        //List of processed claims and Map of existingRequests as parameters
        populateButgetTypeOnClaim(claimsToBeProcessed,existingRequests);
        return mapOfReqIdToClaimsTemp;
    }  
    
    /****************************************************************************************************** 
Method Name:        populateButgetTypeOnClaim
@parameters:        List<PartnerFundClaim> List of processed claims,Map<Id,PartnerFundRequest> Map of existingRequests
Description:        This method is used to populate Budget Type Picklist on Claims from Activity for Using in Reports Filter
Added By:           Accenture - AD - 09/08/2021
Modified By:        Jayaprakash
*******************************************************************************************************/
    public static void populateButgetTypeOnClaim (List<PartnerFundClaim> newclaimList,Map<Id,PartnerFundRequest> requestMap){
        for(PartnerFundClaim pfc: newclaimList){         
            if(requestMap.get(pfc.requestId)!=null && requestMap.containskey(pfc.requestId)){
                pfc.Core_MDF_Budget_Type_Options_Nm__c=requestMap.get(pfc.RequestId).Core_MDF_Budget_Type_Nm__c;
            } 
        }
    }
    
        /****************************************************************************************************** 
Method Name:        populateTimeSpendOnClaim
@parameters:        List<PartnerFundClaim> List of processed claims
Description:        This method is used to populate current time.
Added By:           Accenture - 22/06/2023
Modified By:        shiva
*******************************************************************************************************/
public static void populateTimeSpendOnClaim (List<PartnerFundClaim> newclaimList){
    for(PartnerFundClaim pfc: newclaimList){         
        if(pfc.Core_MDF_StartTime_dtm__c == null){
            pfc.Core_MDF_StartTime_dtm__c = System.now();
        } 
        if(pfc.Core_MDF_EndTime_dtm__c == null){
            pfc.Core_MDF_EndTime_dtm__c = System.now();
        } 
    }
}
    
    /****************************************************************************************************** 
Method Name:        processActivityOnClaims
@return  :          void
@parameters:        List<PartnerFundClaim> List of processed claims
Description:        This Method is Used to Process Activities on the List of input Claims 
Added By:           Accenture - JV - 22/01/2019
Modified By:        Date:       Changes: 
Sarah Intel
*******************************************************************************************************/
    public static void processActivityOnClaims(List<PartnerFundClaim> claimsToBeProcessed){
        Set<Id> pfrIds = new Set<Id>();
        Set<Id> campaignIdsForIPAAndProposalBased = new Set<Id>();
        Set<Id> ipaPfrIds = new Set<Id>();
        Set<Id> legacyPfrIds = new Set<Id>();
        Map<Id, PartnerFundRequest> partnerFundRequestListMap = new Map<Id, PartnerFundRequest>();
        Map<Id, PartnerFundRequest> pfrIdToPfrRecordMapForUpdate = new Map<Id, PartnerFundRequest>();
        Map<Id, PartnerFundRequest> pfrIdToPfrRecordMap = new Map<Id, PartnerFundRequest>();
        List<Campaign> campaignListForIPAAndProposalBased = new List<Campaign>();
        List<PartnerFundClaim> pfcListForLegacy = new List<PartnerFundClaim>();
        string isclaimAdjustmentType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Adjustment_Type');
        
        //get the activity ids
        for(PartnerFundClaim pfc : claimsToBeProcessed) {
            if(!Core_MDF_Claim_Utility.isType(pfc, isclaimAdjustmentType))
            {
                pfrIds.add(pfc.RequestId);
            }
            //IPA
            if(pfc.Core_MDF_Program__c == Label.Core_MDF_IPA_Program_Name &&  pfc.Core_MDF_Proposal_Based_Ind__c) {
                   campaignIdsForIPAAndProposalBased.add(pfc.Core_MDF_Campaign_Id__c);//ipaPFRIds
                   ipaPfrIds.add(pfc.RequestId);
                   
               }
            //Legacy
            if(pfc.Core_MDF_Legacy_Claim_Ind__c ){
                pfcListForLegacy.add(pfc);
                legacyPfrIds.add(pfc.RequestId);
            }
        }
        
        
        if(pfrIds.size() > 0) {
            partnerFundRequestListMap = new Map<Id,PartnerFundRequest>([Select Id, Status, Core_MDF_Fund_Request_Status__c, AllocationId, BudgetId, CampaignId, Core_MDF_Start_Date__c, Core_MDF_End_Date__c, RecordTypeId,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, 
                                                                        ChannelPartner.Core_MDF_Channel_Program__c, RecordType.DeveloperName, Core_MDF_Program__c, Core_MDF_Budget_Type_nm__c, ChannelPartnerId
                                                                        from PartnerFundRequest where Id IN : pfrIds and Core_MDF_Fund_Request_Status__c not in  ('In-Progress', 'In-Progress Pending Review', 'In-Progress Pending Approval','In-Progress Revision Required')]);
        }
        
        if(!partnerFundRequestListMap.isEmpty()) {
            for(PartnerFundRequest pfr : partnerFundRequestListMap.values()) {
                List<String> cmpBudgetTypes = new List<String>();
                cmpBudgetTypes = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_CMP_BudgetType');
                //This If is executed when BudgetId and AllocationId are stamped on Activity during activity creation - OPAL budget Types, Retail MDF, Channel MDF(Account Based Ones)
                if(String.isNotBlank(String.valueOf(pfr.BudgetId)) && String.isNotBlank(String.valueOf(pfr.AllocationId))) {
                    if(pfr.Core_MDF_Fund_Request_Status__c != closedStatus) {
                        if(pfr.Status == Label.Core_MDF_PFR_Status_Draft_IPA && (cmpBudgetTypes != null && cmpBudgetTypes.contains(pfr.Core_MDF_Budget_Type_nm__c))){                       
                            pfrIdToPfrRecordMapForUpdate.put(pfr.Id,new PartnerFundRequest(Id = pfr.Id,Status=approvedStatus,Core_MDF_Fund_Request_Status__c = InProgressStatus));
                        }else if(pfr.Status == approvedStatus) {
                            pfrIdToPfrRecordMapForUpdate.put(pfr.Id, new PartnerFundRequest(Id = pfr.Id, Core_MDF_Fund_Request_Status__c = InProgressStatus));
                        }
                    }else{
                        if(pfr.Status == Label.Core_MDF_PFR_Status_Draft_IPA && (cmpBudgetTypes != null && cmpBudgetTypes.contains(pfr.Core_MDF_Budget_Type_nm__c))){                       
                            pfrIdToPfrRecordMapForUpdate.put(pfr.Id,new PartnerFundRequest(Id = pfr.Id,Status=approvedStatus));
                        }
                    }
                }
            }
            
            //Proposal Based Ones
            if(!campaignIdsForIPAAndProposalBased.isEmpty()) {
                //updateBudgetAllocForIPAActivity(claimsToBeProcessed, campaignIdsForIPAAndProposalBased, pfrIds);
                List<Campaign> campaignList = new List<Campaign>();
                set<Id> pmbIds = new Set<Id>();
                Map<Id, String> campIdTocampAccBudMap = new Map<Id, String>();
                Map<String, PartnerFundAllocation> pfaBudTopfaRecordMap = new Map<String, PartnerFundAllocation>();
                List<PartnerFundAllocation> allocationList = new List<PartnerFundAllocation>();
                Map<String, PartnerFundAllocation> allocationMap = new Map<String, PartnerFundAllocation>();
                //CampaignList
                campaignList = [Select Id, Core_MDF_Budget__c, Core_MDF_Account__c from Campaign  where Id IN : campaignIdsForIPAAndProposalBased];
                for(Campaign camp : campaignList) {
                    pmbIds.add(camp.Core_MDF_Budget__c);
                    campIdTocampAccBudMap.put(camp.Id, camp.Core_MDF_Account__c+'_'+camp.Core_MDF_Budget__c);
                }
                if(pmbIds.size() > 0 && !campIdTocampAccBudMap.isEmpty()) {
                    allocationList = [select Id, BudgetId, ChannelPartnerId from PartnerFundAllocation where budgetId IN: pmbIds];
                    for(PartnerFundAllocation pfa : allocationList) {
                        allocationMap.put(pfa.ChannelPartnerId+'_'+pfa.BudgetId, pfa);
                    }
                }
                
                //IPA, proposal based ones
                //Budget transfer scenario - add post unit testing
                for(Id pfrId : ipaPfrIds) {
                    if(partnerFundRequestListMap.containsKey(pfrId)) {
                        // status - Draft, Fund request status - planned
                        if(partnerFundRequestListMap.get(pfrId).Status == Label.Core_MDF_PFR_Status_Draft_IPA) {
                            if(allocationMap.containsKey(campIdTocampAccBudMap.get(partnerFundRequestListMap.get(pfrId).CampaignId)) && allocationMap.get(campIdTocampAccBudMap.get(partnerFundRequestListMap.get(pfrId).CampaignId)) != null) {//containsKey
                                PartnerFundAllocation allocation = allocationMap.get(campIdTocampAccBudMap.get(partnerFundRequestListMap.get(pfrId).CampaignId));
                                if(partnerFundRequestListMap.get(pfrId).Core_MDF_Fund_Request_Status__c != closedStatus) {
                                    pfrIdToPfrRecordMapForUpdate.put(pfrId, new PartnerFundRequest(Id = pfrId, AllocationId = allocation.Id, Core_MDF_Fund_Request_Status__c = InProgressStatus, Status = approvedStatus));
                                } else {
                                    pfrIdToPfrRecordMapForUpdate.put(pfrId, new PartnerFundRequest(Id = pfrId, AllocationId = allocation.Id, Status = approvedStatus));
                                }
                            }
                        }
                        // status - Approved, Fund request status - planned
                        else if(partnerFundRequestListMap.get(pfrId).Status == approvedStatus) {
                            if(allocationMap.containsKey(campIdTocampAccBudMap.get(partnerFundRequestListMap.get(pfrId).CampaignId)) && allocationMap.get(campIdTocampAccBudMap.get(partnerFundRequestListMap.get(pfrId).CampaignId)) != null) {
                                if(partnerFundRequestListMap.get(pfrId).Core_MDF_Fund_Request_Status__c != closedStatus) {
                                    pfrIdToPfrRecordMapForUpdate.put(pfrId, new PartnerFundRequest(Id = pfrId, Core_MDF_Fund_Request_Status__c = InProgressStatus));
                                }
                            }
                        }
                    }
                }
                
            }
            
            //Legacy ones
            if(!pfcListForLegacy.isEmpty()) {
                Map<Id, PartnerMarketingBudget> pfrIdToPmbRecordMap = new Map<Id, PartnerMarketingBudget>();
                Set<Id> pmBudgetIds = new Set<Id>();
                List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
                Map<Id, PartnerFundAllocation> pfaIdAllocationMap = new Map<Id, PartnerFundAllocation>();
                Map<Id,PartnerFundRequest> pfrDetailsAfterCheckingPFA = new Map<Id,PartnerFundRequest>();
                List<PartnerFundRequest> partnerFundRequestList = new List<PartnerFundRequest>();
                //fetch partnerFundRequestList of CCF 1.0, DCF 1.0, CCFB, SPCF, RSA MD
                if(legacyPfrIds.size() > 0) {
                    for(Id pfrId : legacyPfrIds) {
                        if(partnerFundRequestListMap.containsKey(pfrId)) {
                            partnerFundRequestList.add(partnerFundRequestListMap.get(pfrId));
                        }
                    }
                }
                checkIfBudgetExistsForActivity(pfcListForLegacy, partnerFundRequestList);
                pfrDetailsAfterCheckingPFA = checkAllocationOnActivityAndUpdateActivityStatus(pfcListForLegacy);
                if(pfrDetailsAfterCheckingPFA.size() > 0) {
                    for(PartnerFundRequest activity : pfrDetailsAfterCheckingPFA.values()) {
                        pfrIdToPfrRecordMapForUpdate.put(activity.Id, activity);
                    }
                }
            }
        }
        
        if(pfrIdToPfrRecordMapForUpdate.size() > 0) {
            try {
                Database.update(pfrIdToPfrRecordMapForUpdate.values(), true);
            } catch(Exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);}
        }
        
    }
    
    
    
    /****************************************************************************************************** 
Method Name:        checkIfBudgetExistsForActivity
@return  :          Map<Id,PartnerMarketingBudget>
@parameters:        List<PartnerFundClaim> List of processed claims
Description:        This method is used to check if the Budget on the Activity is present,
If no, then throw the error with specific message
Added By:           Accenture - JV - 22/01/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static Map<Id,PartnerMarketingBudget> checkIfBudgetExistsForActivity(List<PartnerFundClaim> claimsToBeProcessed, List<PartnerFundRequest> partnerFundRequestList){
        //Map of pfrId and CampaignId
        Map<Id,Id> pfrIdCampaignIdMap = new Map<Id,Id>();
        
        // PartnerFundRequest Set to be prepared from claimsToBeProcessed
        Set<Id> pfrSet = new Set<Id>();
        Map<Id, Id> pfrIdToPfrUltiAccId = new Map<Id, Id>();
        Map<String, Id> ultimateAccToVirtualCorpId = new Map<String, Id>();
        Map<String, Id> pfrProgramToPfrUltiAccId = new Map<String, Id>();
        String isClaimm;
        string isclaimAdjustmentType;
        isclaimAdjustmentType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Adjustment_Type');
        pFRIdPFRMap = new Map<Id, PartnerFundRequest>();
        Set<Id> pfrProgramIdsList = new Set<Id>();
        
        for(PartnerFundClaim pfc :claimsToBeProcessed){
            //pfrIdClaimListMap - Used to fetch the claims with no budgets
            if(pfrIdClaimListMap.containsKey(pfc.RequestId))
            {
                pfrIdClaimListMap.get(pfc.RequestId).add(pfc);
            }
            else
            {
                pfrIdClaimListMap.put(pfc.RequestId, new List<PartnerFundClaim>{pfc});
            }
        }
        
        for(PartnerFundRequest pfrRecord : partnerFundRequestList) {
            if(pfrRecord.Status == Label.Core_MDF_PFR_Status_Draft_IPA || pfrRecord.Status == approvedStatus) {//partnerFundRequest Obj: Status - Draft, Approved
                accountIdSet.add(pfrRecord.ChannelPartnerId); //this will be used in for finding Allocations - referred in checkAllocationOnActivityAndUpdateActivityStatus
                pFRIdPFRMap.put(pfrRecord.Id, pfrRecord);
                //Map of PFR Id as Key and ultimate Account as value - Based on this ultimate Account, fetch the virtual corp accounts to get the partner marketing budgets
                pfrIdToPfrUltiAccId.put(pfrRecord.Id, pfrRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c);
                pfrProgramIdsList.add(pfrRecord.ChannelPartner.Core_MDF_Channel_Program__c); // Program Ids  from activity
            }
        }
        
        if(!pfrIdToPfrUltiAccId.isEmpty()) {
            //query the Virtual Corp Account based on Ultimate Account and program
            for(Account acc: [select Id, Name, Core_MDF_Parent_Fund_Account__c, Core_MDF_Channel_Program__c, Core_MDF_Channel_Program__r.Name from Account where Core_MDF_Parent_Fund_Account__c  IN : pfrIdToPfrUltiAccId.values() and Core_MDF_Channel_Program__c IN : pfrProgramIdsList]) {
                String ultimateAccountAndProgramId = acc.Core_MDF_Parent_Fund_Account__c+'_'+acc.Core_MDF_Channel_Program__c;
                //ultimateAccToVirtualCorpId - used to query the PartnerMarketingBudget based on the virtual Corp Ids
                //Map of 'ultimateAccount+Program' as Key and corresponding virtual Corp as key
                ultimateAccToVirtualCorpId.put(ultimateAccountAndProgramId, acc.Id);
            }
            
            
            if(!ultimateAccToVirtualCorpId.isEmpty())
            {  
                Map<Id,List<PartnerMarketingBudget>> accountIdPMBsMap = new Map<Id,List<PartnerMarketingBudget>>();
                for(PartnerMarketingBudget pmb : [SELECT Id, Title,Core_MDF_Budget_Partner__c, StartDate, EndDate, 
                                                  Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c,
                                                  Core_MDF_Budget_Partner__r.Core_MDF_Channel_Program__c,
                                                  Core_MDF_Budget_Type_Txt__c,RecordType.DeveloperName
                                                  FROM PartnerMarketingBudget 
                                                  WHERE Core_MDF_Budget_Partner__c IN : ultimateAccToVirtualCorpId.values()])
                {
                    if(accountIdPMBsMap.containsKey(pmb.Core_MDF_Budget_Partner__c))
                    {
                        accountIdPMBsMap.get(pmb.Core_MDF_Budget_Partner__c).add(pmb);
                    }
                    else
                    {
                        accountIdPMBsMap.put(pmb.Core_MDF_Budget_Partner__c, new List<PartnerMarketingBudget>{pmb});
                    }
                }
                Set<PartnerFundClaim> noBudgetClaims = new Set<PartnerFundClaim>();
                
                //populate pFRIdPMBMap and pMBIdPFRsMap
                for(PartnerFundRequest pfrRecord : pFRIdPFRMap.values())
                {
                    if(accountIdPMBsMap.size() > 0)
                    {   
                        Datetime sd = pfrRecord.Core_MDF_Start_Date__c;
                        Datetime ed = pfrRecord.Core_MDF_End_Date__c;
                        
                        if((ultimateAccToVirtualCorpId.containsKey(pfrRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+pfrRecord.ChannelPartner.Core_MDF_Channel_Program__c) && ultimateAccToVirtualCorpId.get(pfrRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+pfrRecord.ChannelPartner.Core_MDF_Channel_Program__c) != NULL) &&
                        (accountIdPMBsMap.containsKey(ultimateAccToVirtualCorpId.get(pfrRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+pfrRecord.ChannelPartner.Core_MDF_Channel_Program__c)) && accountIdPMBsMap.get(ultimateAccToVirtualCorpId.get(pfrRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+pfrRecord.ChannelPartner.Core_MDF_Channel_Program__c)) != NULL))
                        {
                            Boolean isBudgetInRange = false;
                            Boolean isPFRPMBProgamMatch = false;  
                            List<PartnerMarketingBudget> budgetList = accountIdPMBsMap.get(ultimateAccToVirtualCorpId.get(pfrRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+pfrRecord.ChannelPartner.Core_MDF_Channel_Program__c));
                            for(PartnerMarketingBudget pmb : budgetList)
                            {
                                //to get the budget with the matching budget type of activity
                                isPFRPMBProgamMatch = checkPFRPMBBudgetType(pmb,pfrRecord);
                                if(isPFRPMBProgamMatch)
                                {
                                    if(pmb.StartDate <= sd && pmb.EndDate >= ed && 
                                       pfrRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c == pmb.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c &&
                                       pfrRecord.ChannelPartner.Core_MDF_Channel_Program__c == pmb.Core_MDF_Budget_Partner__r.Core_MDF_Channel_Program__c   
                                      )
                                    {
                                        isBudgetInRange = true;
                                        if(pMBIdPFRsMap.containsKey(pmb.Id))
                                        { 
                                            pMBIdPFRsMap.get(pmb.Id).add(pfrRecord);
                                        }
                                        else
                                        {   
                                            pMBIdPFRsMap.put(pmb.Id, new List<PartnerFundRequest>{pfrRecord});
                                        }
                                        pFRIdPMBMap.put(pfrRecord.Id,pmb);//zero dollar allocation
                                    }
                                }
                            }
                            
                            if(isBudgetInRange == false)
                            {
                                noBudgetClaims.addAll(pfrIdClaimListMap.get(pfrRecord.Id));
                            }
                        }
                        else {
                            // Throw Error if Budget Does not exists
                            noBudgetClaims.addAll(pfrIdClaimListMap.get(pfrRecord.Id));
                            
                        }
                        
                    }else {
                        // Throw Error if Budget Does not exists
                        noBudgetClaims.addAll(pfrIdClaimListMap.get(pfrRecord.Id));
                        
                    }
                    
                }
                
                if(noBudgetClaims != NULL){
                    for(PartnerFundClaim pfc : noBudgetClaims){
                        pfc.addError(System.Label.Core_MDF_No_Budget_Exist);
                    }
                }
                
            }else{
                //If there is no account
                if(claimsToBeProcessed!=null){
                    for(PartnerFundClaim pfcRecord :claimsToBeProcessed){
                        if(!Core_MDF_Claim_Utility.isType(pfcRecord, isclaimAdjustmentType))
                        {
                            pfcRecord.addError(System.Label.Core_MDF_No_Budget_Exist);
                        }
                    }
                }
            }
        } 
        return pFRIdPMBMap;
    }
    
    public static boolean checkPFRPMBBudgetType(PartnerMarketingBudget pmb,PartnerFundRequest pfr){
        // if Retail program and BudgetType is same as PFR, set BudgetInRange as True else return false. For all other program
        // method updated to return true if the budget type on budget and the pfr matches, else return false for all programs
        if(pmb.Core_MDF_Budget_Type_Txt__c==pfr.Core_MDF_Budget_Type_nm__c){
            return true;
        }
        else{
            return false;
        }
    }
    
    /****************************************************************************************************** 
Method Name:        createOrUpdateAllocationOnActivity
@return  :          void
@parameters:        no paramters
Description:        This method is used to check if the Allocation for the filtered Activities 
are present or not, If Allocation doesn't exists,It creates Allocation and Updates the Activity Status
Else it only updates the Activity Status
Added By:           Accenture - JV - 22/01/2019
Modified By:        Date:       Changes: 
Accenture - VD      05-02-2019  Added SPCF recordtype in PFA and PFR
*******************************************************************************************************/
    
    public static Map<Id,PartnerFundRequest> checkAllocationOnActivityAndUpdateActivityStatus(List<PartnerFundClaim> claimList)
    {
        // Map<AcitivityId,AllocationId>
        Map<Id,Id> pFRIdPFAIdMap = new Map<Id,Id>();
        String pFRIdPFA;
        // Final PFR Map to be Updated
        Map<Id,PartnerFundRequest> pfrMapToBeUpdated = new Map<Id,PartnerFundRequest>();
        
        //Map of pfrId and AllocationId
        Map<Id,Id> pfrIdAllocationIdMap = new Map<Id,Id>();
        String pftIdAll;
        //Assign all record type meta data
        Map<String,Core_MDF_ObjRecType_Budget_FieldSetMap__mdt> recTypeMetaDataMap = Core_MDF_Claim_Utility.mapOfRecTypeMetadata; //TWC3117-18333
        if(pMBIdPFRsMap != null && pMBIdPFRsMap.size() > 0){
            for(PartnerFundAllocation pfa : [SELECT Id, BudgetId, ChannelPartnerId
                                             FROM PartnerFundAllocation
                                             WHERE BudgetId IN: pMBIdPFRsMap.keySet() AND
                                             ChannelPartnerId IN :accountIdSet
                                             ORDER BY LastModifiedDate DESC])
            {
                for(PartnerFundRequest pfr : pMBIdPFRsMap.get(pfa.BudgetId))
                {
                    if(pfa.ChannelPartnerId == pfr.ChannelPartnerId)
                    {
                        if(pfr.Status == Label.Core_MDF_PFR_Status_Draft_IPA)
                        {   
                            if(pfr.Core_MDF_Fund_Request_Status__c != closedStatus) {
                                pfrMapToBeUpdated.put(pfr.Id,new PartnerFundRequest(Id = pfr.Id, AllocationId = pfa.Id,Status=approvedStatus, Core_MDF_Fund_Request_Status__c = InProgressStatus));
                            } else {
                                pfrMapToBeUpdated.put(pfr.Id,new PartnerFundRequest(Id = pfr.Id, AllocationId = pfa.Id,Status=approvedStatus));
                            }
                        } else if(pfr.Status == approvedStatus) {
                            if(pfr.Core_MDF_Fund_Request_Status__c != closedStatus) {
                                pfrMapToBeUpdated.put(pfr.Id,new PartnerFundRequest(Id = pfr.Id, Core_MDF_Fund_Request_Status__c = InProgressStatus));
                            }
                        }
                        pfrIdAllocationIdMap.put(pfr.Id, pfa.Id);
                        pFRIdPMBMap.remove(pfr.Id);
                        pFRIdPFRMap.remove(pfr.Id);
                    }
                }
            }
        }
        Map<Id,PartnerFundAllocation> pFRIdPFAMap = new Map<Id,PartnerFundAllocation>();
        Map<String,PartnerFundAllocation> budgetIdAccountIdPFAMap = new Map<String,PartnerFundAllocation>();
        Map<String,List<PartnerFundRequest>> budgetIdAccountIdPFRListMap = new Map<String,List<PartnerFundRequest>>();
        Map<String,Schema.RecordTypeInfo> allocationRecordTypeMap = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName();
        if(pFRIdPMBMap.size() > 0){
            for(Id pfrId : pFRIdPMBMap.keySet()){
                PartnerFundRequest pfrRecord = pFRIdPFRMap.get(pfrId);
                String budgetIdAccountIdStr = pFRIdPMBMap.get(pfrId).Id;
                if(pfrRecord != NULL){
                    budgetIdAccountIdStr += pfrRecord.ChannelPartnerId;
                    if(!(budgetIdAccountIdPFAMap.containsKey(budgetIdAccountIdStr)))
                    {                            
                        budgetIdAccountIdPFRListMap.put(budgetIdAccountIdStr, new List<PartnerFundRequest>{pfrRecord});
                        if(recTypeMetaDataMap !=null && recTypeMetaDataMap.containsKey(pfrRecord.RecordType.DeveloperName)){
                            String allocationRecTypeDevName = recTypeMetaDataMap.get(pfrRecord.RecordType.DeveloperName).Core_MDF_Allocation_RecordType_txt__c;
                            if(allocationRecTypeDevName!=null){
                                Id pfaRecordTypeId= allocationRecordTypeMap.get(allocationRecTypeDevName).getRecordTypeId();
                                budgetIdAccountIdPFAMap.put(budgetIdAccountIdStr, 
                                                            new PartnerFundAllocation(Title = pFRIdPMBMap.get(pfrId).Title,Amount = 0,BudgetId = pFRIdPMBMap.get(pfrId).Id,ChannelPartnerId = pfrRecord.ChannelPartnerId,RecordTypeId = pfaRecordTypeId));
                            }
                        }
                    }
                    else{
                        budgetIdAccountIdPFRListMap.get(budgetIdAccountIdStr).add(pfrRecord);
                    }
                }
            }
            if(budgetIdAccountIdPFAMap.values().size() > 0){ 
                //insert the Allocations created above
                insert budgetIdAccountIdPFAMap.values();
                for(String budgetIdAccountIdStr : budgetIdAccountIdPFAMap.keySet()){
                    for(PartnerFundRequest pfrRecord : budgetIdAccountIdPFRListMap.get(budgetIdAccountIdStr)){
                        if(pfrRecord.Core_MDF_Fund_Request_Status__c != closedStatus){
                            pfrMapToBeUpdated.put(pfrRecord.Id,new PartnerFundRequest(Id = pfrRecord.Id,AllocationId = budgetIdAccountIdPFAMap.get(budgetIdAccountIdStr).Id,Status = approvedStatus,Core_MDF_Fund_Request_Status__c=InProgressStatus));
                        }
                        else
                        {
                            pfrMapToBeUpdated.put(pfrRecord.Id,new PartnerFundRequest(Id = pfrRecord.Id, AllocationId = budgetIdAccountIdPFAMap.get(budgetIdAccountIdStr).Id, Status = approvedStatus));
                        }
                        
                        pfrIdAllocationIdMap.put(pfrRecord.Id, budgetIdAccountIdPFAMap.get(budgetIdAccountIdStr).Id);
                        pFRIdPFRMap.remove(pfrRecord.Id);
                    }
                }
                budgetIdAccountIdPFAMap = NULL;
                budgetIdAccountIdPFRListMap = NULL;
            }
        }        
       return pfrMapToBeUpdated;
    }   
    
    
    
    /****************************************************************************************************** 
Method Name:        updateClaimOwner
@return  :          void
@parameters:        List<PartnerFundClaim>
Description:        This method is used to update the owner field with the claim submitter field
Added By:           HA
Modified By:        Date:    19-07-2021   Changes: 
*******************************************************************************************************/ 
    public static void updateClaimOwner(List<PartnerFundClaim> claimsToBeProcessed){
        Set<Id> escalationIdSet = new Set<Id>();
        //This list contains the escalation type values: Late Claim , Claim Case Review Result
        List<String> escalationTypeList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_EscalationTypes',',');
        //collecting all the claim's related escalation Id's in a set
        for(PartnerFundClaim pfc: claimsToBeProcessed){
            if(pfc.Core_MDF_Escalation_Id__c != NULL){
                escalationIdSet.add(pfc.Core_MDF_Escalation_Id__c);
            }
        }
        Map<Id, Core_MDF_Escalation__c> escalationMap;
        if(!escalationIdSet.isEmpty()){
            //Query on escalation to get the context of the escalation fields such as claim submitter field and escalation type field.
            escalationMap = new Map<Id, Core_MDF_Escalation__c>([SELECT ID, Core_MDF_Claim_Submitter_Id__c, Core_MDF_Escalation_Type_nm__c, Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Activity_Level_nm__c FROM Core_MDF_Escalation__c WHERE ID IN: escalationIdSet]);
        }
        
        for(PartnerFundClaim claimObj: claimsToBeProcessed){
            if (claimObj.Core_MDF_Escalation_Id__c != null && escalationMap != null && escalationMap.containsKey(claimObj.Core_MDF_Escalation_Id__c) &&
                escalationMap.get(claimObj.Core_MDF_Escalation_Id__c).Core_MDF_Co_Marketing_Activity_id__r.Core_MDF_Activity_Level_nm__c == 'Sub Activity'){                
                    claimObj.addError('Unable to create late claim. The selected escalation is invalid. Please select a valid escalation and try again.');
                    continue;
                }
            if(UserInfo.getUserType() == 'PowerPartner') {
                claimObj.Core_MDF_Claim_Submitter_Id__c = NULL;
            }
            else{
                //Claim Owner assignment
                //Based on US843424: added check for Case Type of Escalation and checkbox true
                if(claimObj.Core_MDF_Escalation_Id__c != NULL && escalationMap!= NULL && escalationMap.containsKey(claimObj.Core_MDF_Escalation_Id__c) &&
                   escalationMap.get(claimObj.Core_MDF_Escalation_Id__c).Core_MDF_Claim_Submitter_Id__c != NULL && escalationTypeList.contains(escalationMap.get(claimObj.Core_MDF_Escalation_Id__c).Core_MDF_Escalation_Type_nm__c)){
                       claimObj.OwnerId = escalationMap.get(claimObj.Core_MDF_Escalation_Id__c).Core_MDF_Claim_Submitter_Id__c;
                   }                   
                else if(claimObj.Core_MDF_Escalation_Id__c == NULL 
                        && claimObj.Core_MDF_Claim_Submitter_Id__c != NULL ){
                            //updating claim owner with claim submitter value when claim is craeted by internal user - added By Vaishali
                            claimObj.OwnerId = claimObj.Core_MDF_Claim_Submitter_Id__c;
                            //Updating the field owner swapped with submitter as true for sending email to External User through Process builder
                            claimObj.Core_MDF_owner_swapped_withsubmitter_ind__c = true; 
                        }
            }
        }
    }
    
}