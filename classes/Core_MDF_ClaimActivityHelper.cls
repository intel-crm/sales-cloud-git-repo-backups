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
                    newClaimNumber = (String.valueOf(claimRefList.get(claimRefList.size()-1)+1).leftPad(Integer.valueOf(System.Label.Core_MDF_ClaimID_LeftPaddedValue), '0'));
                }
            }
            if(existingClaimList == null || existingClaimList.size()==0){
                newClaimNumber = (String.valueOf(1).leftPad(Integer.valueOf(System.Label.Core_MDF_ClaimID_LeftPaddedValue), '0'));
            }
            //eg.newClaimRefNo=00015614-005
            newClaimRefNo = existingRequests.get(pfc.RequestId).Core_MDF_Activity_Number__c + '-'+ newClaimNumber;
            
            //assign new claim no to pfc attribute
            pfc.Core_MDF_Claim_Ref_Number__c = newClaimRefNo;
            //Adding new processed claim into map corresponding to specific request id.
            if(mapOfReqIdToClaims.containsKey(pfc.RequestId)){
                mapOfReqIdToClaims.get(pfc.RequestId).add(pfc);
                system.debug('new claim size'+mapOfReqIdToClaims.get(pfc.RequestId).size());
            }
            else{
                mapOfReqIdToClaims.put(pfc.RequestId, new List<PartnerFundClaim>{pfc});
            }
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
        system.debug('requestIDs'+setRequestIds);
        //fetching list of claims based on request ids
        List<PartnerFundClaim> existingClaimsList = [Select RequestId,Request.Core_MDF_Activity_Number__c,Core_MDF_Claim_Ref_Number__c from PartnerFundClaim where RequestId IN:setRequestIds];
        //fetching list of activity based on request ids and creating Map of request ID as key and activity as value
        existingRequests = new Map<Id,PartnerFundRequest>([Select Id,Core_MDF_Activity_Number__c,Core_MDF_Fund_Request_Status__c from PartnerFundRequest where Id IN:setRequestIds]);
        for(ID reqId : setRequestIds){
            for(PartnerFundClaim claim : existingClaimsList){
                if(claim.RequestId == reqId){
                    if(mapOfReqIdToClaimsTemp.containsKey(reqId)){
                        mapOfReqIdToClaimsTemp.get(reqId).add(claim);
                    }
                    else{
                        mapOfReqIdToClaimsTemp.put(reqId, new List<PartnerFundClaim>{claim});
                    }
                }
            }
        }
        return mapOfReqIdToClaimsTemp;
    }
    
    /****************************************************************************************************** 
Method Name:        processActivityOnClaims
@return  :          void
@parameters:        List<PartnerFundClaim> List of processed claims
Description:        This Method is Used to Process Activities on the List of input Claims 
Added By:           Accenture - JV - 22/01/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static void processActivityOnClaims(List<PartnerFundClaim> claimsToBeProcessed){
        checkIfBudgetExistsForActivity(claimsToBeProcessed);
        checkAllocationOnActivityAndUpdateActivityStatus();
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
    public static Map<Id,PartnerMarketingBudget> checkIfBudgetExistsForActivity(List<PartnerFundClaim> claimsToBeProcessed){
        
        //Map of pfrId and CampaignId
        Map<Id,Id> pfrIdCampaignIdMap = new Map<Id,Id>();
        
        // PartnerFundRequest Set to be prepared from claimsToBeProcessed
        Set<Id> pfrSet = new Set<Id>();
        for(PartnerFundClaim pfc :claimsToBeProcessed){
            //check if adjustment then break
            if(!Core_MDF_Claim_Utility.isType(pfc, Label.Core_MDF_Claim_Adjustment_Type))
            {
                pfrSet.add(pfc.RequestId);
            } 
            if(pfrIdClaimListMap.containsKey(pfc.RequestId))
            {
                pfrIdClaimListMap.get(pfc.RequestId).add(pfc);
            }
            else
            {
                pfrIdClaimListMap.put(pfc.RequestId, new List<PartnerFundClaim>{pfc});
            }
        }
        
        //Map of pfrId and PFR record itself
        pFRIdPFRMap = new Map<Id,PartnerFundRequest>([SELECT Id,CampaignId,ChannelPartnerId,Core_MDF_Start_Date__c,
                                                      Core_MDF_Fund_Request_Status__c,Status,Core_MDF_End_Date__c,
                                                      RecordTypeId,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,
                                                      ChannelPartner.Core_MDF_Channel_Program__c,RecordType.DeveloperName
                                                      FROM PartnerFundRequest
                                                      WHERE Id IN: pfrSet]);
        for(PartnerFundRequest pfrRecord : pFRIdPFRMap.values()){
            pfrIdCampaignIdMap.put(pfrRecord.Id, pfrRecord.CampaignId); //this will be used in a query below
            accountIdSet.add(pfrRecord.ChannelPartnerId); //this will be used in for finding Allocations
        }
        
        //Map<CampaignId, AccountId>;
        Map<Id,Id> campaignIdAccountIdMap = new Map<Id,Id>();
        
        for(Campaign campaignRecord : [SELECT Id, Core_MDF_Account__c
                                       FROM Campaign
                                       WHERE Id IN: pfrIdCampaignIdMap.values()]){
                                           campaignIdAccountIdMap.put(campaignRecord.Id, campaignRecord.Core_MDF_Account__c);
                                       }
        
        if(campaignIdAccountIdMap.size() > 0)
        {
            Map<Id,List<PartnerMarketingBudget>> accountIdPMBsMap = new Map<Id,List<PartnerMarketingBudget>>();
            for(PartnerMarketingBudget pmb : [SELECT Id, Title,Core_MDF_Budget_Partner__c, StartDate, EndDate, 
                                              Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c,
                                              Core_MDF_Budget_Partner__r.Core_MDF_Channel_Program__c
                                              FROM PartnerMarketingBudget 
                                              WHERE Core_MDF_Budget_Partner__c IN :campaignIdAccountIdMap.values()])
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
                    
                    if(pfrIdCampaignIdMap.get(pfrRecord.Id) != NULL && 
                       campaignIdAccountIdMap.get(pfrIdCampaignIdMap.get(pfrRecord.Id)) != NULL && 
                       accountIdPMBsMap.get(campaignIdAccountIdMap.get(pfrIdCampaignIdMap.get(pfrRecord.Id))) != NULL)
                    {
                        Boolean isBudgetInRange = false;
                        for(PartnerMarketingBudget pmb : accountIdPMBsMap.get(campaignIdAccountIdMap.get(pfrIdCampaignIdMap.get(pfrRecord.Id))))
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
                                pFRIdPMBMap.put(pfrRecord.Id,pmb);
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
            
        }
        return pFRIdPMBMap;
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
    public static void checkAllocationOnActivityAndUpdateActivityStatus()
    {
        // Map<AcitivityId,AllocationId>
        Map<Id,Id> pFRIdPFAIdMap = new Map<Id,Id>();
        
        // Final PFR Map to be Updated
        Map<Id,PartnerFundRequest> pfrMapToBeUpdated = new Map<Id,PartnerFundRequest>();
        
        //Map of pfrId and AllocationId
        Map<Id,Id> pfrIdAllocationIdMap = new Map<Id,Id>();
        
        //Assign all record type meta data
        Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> recTypeMetaDataMap = Core_MDF_Claim_Utility.mapOfRecTypeMetadata;
        
        
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
                    if(pfr.Status != Label.Core_MDF_PFR_Status_Approved)
                    {
                        if(pfr.Core_MDF_Fund_Request_Status__c != Label.Core_MDF_Claim_Activity_Closed_Status){
                            pfrMapToBeUpdated.put(pfr.Id,new PartnerFundRequest(Id = pfr.Id, AllocationId = pfa.Id,Status=Label.Core_MDF_PFR_Status_Approved,Core_MDF_Fund_Request_Status__c=Label.Core_MDF_pfrInprogress));
                        }
                        
                        else{
                            pfrMapToBeUpdated.put(pfr.Id,new PartnerFundRequest(Id = pfr.Id, AllocationId = pfa.Id,Status=Label.Core_MDF_PFR_Status_Approved));
                        }
                    }
                    pfrIdAllocationIdMap.put(pfr.Id, pfa.Id);
                    pFRIdPMBMap.remove(pfr.Id);
                    pFRIdPFRMap.remove(pfr.Id);
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
                                                            new PartnerFundAllocation(Title = pFRIdPMBMap.get(pfrId).Title,
                                                                                      Amount = 0,
                                                                                      BudgetId = pFRIdPMBMap.get(pfrId).Id,
                                                                                      ChannelPartnerId = pfrRecord.ChannelPartnerId,
                                                                                      RecordTypeId = pfaRecordTypeId));
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
                        if(pfrRecord.Core_MDF_Fund_Request_Status__c != Label.Core_MDF_Claim_Activity_Closed_Status){
                            pfrMapToBeUpdated.put(pfrRecord.Id,new PartnerFundRequest(Id = pfrRecord.Id, 
                                                                                      AllocationId = budgetIdAccountIdPFAMap.get(budgetIdAccountIdStr).Id,
                                                                                      Status = Label.Core_MDF_PFR_Status_Approved,Core_MDF_Fund_Request_Status__c=Label.Core_MDF_pfrInprogress));
                        }
                        else
                        {
                            pfrMapToBeUpdated.put(pfrRecord.Id,new PartnerFundRequest(Id = pfrRecord.Id, 
                                                                                      AllocationId = budgetIdAccountIdPFAMap.get(budgetIdAccountIdStr).Id,
                                                                                      Status = Label.Core_MDF_PFR_Status_Approved));
                        }
                        
                        pfrIdAllocationIdMap.put(pfrRecord.Id, budgetIdAccountIdPFAMap.get(budgetIdAccountIdStr).Id);
                        pFRIdPFRMap.remove(pfrRecord.Id);
                    }
                }
                budgetIdAccountIdPFAMap = NULL;
                budgetIdAccountIdPFRListMap = NULL;
            }
        }
        if(pfrMapToBeUpdated != NULL && pfrMapToBeUpdated.size() > 0){
            List<Database.SaveResult> updateResults = Database.update(pfrMapToBeUpdated.values(), true); 
        }
        
    }    
}