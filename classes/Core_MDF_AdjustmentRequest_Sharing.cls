/****************************************************************************************************************************************
* Method Name  : Core_MDF_AdjustmentRequest_Sharing
* Version     : 1.0
* Created Date: 07-06-2019
* Modification Log :
* Developer            Date                 Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JV      07/06/2019           Created for sharing the Adjustment Request record during the creation and owner change .
*****************************************************************************************************************************************/
public without sharing class Core_MDF_AdjustmentRequest_Sharing {
    
    /*****************************************************************************************************
Method Name:        shareAdjustmentRequestToInternalUsers
@return  :          void
@parameters:        claimList - This will contain all the pfc records to be shared
Description:        Whenever a record is inserted/updated of Adjustment Request, this method shares the Claim to the Internal Managers
according the Account Node on which the Claim is created
@Added By:          Accenture - JV - 07-06-2019
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void shareAdjustmentRequestToInternalUsers(List<Core_MDF_Adjustment_Request__c> adjustmentRequestList) {
        
        // Set of Adjustment Claim ids from Adjustment Requests
        Set<ID> adjClaimIds = new Set<ID>();
        
        //Map<adjustmentClaimNbr, AdjRequestId>
        Map<String,Id> adjClaimNbrToAdjReqIdMap = new Map<String,Id>();
        
        // Channel program Sharing      
        List<Core_MDF_RecordGeoShare> recordGeoShareList= new List<Core_MDF_RecordGeoShare>();
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        
        //map of record id and group id with which it needs to be shared - VD  
        Map<Id,List<Id>> adjReqIdGroupIdListMap = new Map<Id,List<Id>>();
        
        try {
            
            for(Core_MDF_Adjustment_Request__c adjRequest: adjustmentRequestList) {
                adjClaimNbrToAdjReqIdMap.put(adjRequest.Core_MDF_Adjustment_Claim_Nbr__c,adjRequest.Id);
                adjClaimIds.add(adjRequest.Core_MDF_Adjustment_Claim_Nbr__c);
            }
            Map<Id,PartnerFundClaim> claimMap = new Map<Id,PartnerFundClaim>([SELECT Id, Core_MDF_AccountCompany__c,Core_MDF_Program__c,ChannelPartner.Core_MDF_Channel_Program__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c,
                                                                              ChannelPartner.Core_MDF_Channel_Program__r.Name,ChannelPartner.Core_MDF_Group_Id__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Budget_Type_Options_Nm__c
                                                                              FROM PartnerFundClaim
                                                                              WHERE ID IN: adjClaimIds]);
            
            if(claimMap != NULL && claimMap.size() > 0) {
                for (PartnerFundClaim pfc : claimMap.values()) {
                    
                    //To share record on the basis of Channel Program and geo 
                    if(pfc.Core_MDF_Program__c==Label.Core_MDF_IPA_Program_Name)
                    {
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(adjClaimNbrToAdjReqIdMap.get(pfc.ID),pfc.Core_MDF_Region_Cd__c,pfc.Core_MDF_Sub_Region_Cd__c,pfc.Core_MDF_Program__c,pfc.Core_MDF_Budget_Type_Options_Nm__c));
                        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(adjClaimNbrToAdjReqIdMap.get(pfc.ID),pfc.Core_MDF_Region_Cd__c,pfc.Core_MDF_Sub_Region_Cd__c,pfc.Core_MDF_Program__c,pfc.Core_MDF_Budget_Type_Options_Nm__c,pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
                    }
                    else
                    {
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(adjClaimNbrToAdjReqIdMap.get(pfc.ID),pfc.Core_MDF_Region_Cd__c,pfc.Core_MDF_Sub_Region_Cd__c,pfc.Core_MDF_Program__c));
                        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(adjClaimNbrToAdjReqIdMap.get(pfc.ID),pfc.Core_MDF_Region_Cd__c,pfc.Core_MDF_Sub_Region_Cd__c,pfc.Core_MDF_Program__c,pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
                    }                    
                    //to create map of adjustement request Id and account Id for account group sharing - VD
                    if(pfc.ChannelPartner.Core_MDF_Channel_Program__c != Null && pfc.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c != Null
                       && Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(pfc.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c)
                       && adjClaimNbrToAdjReqIdMap.containskey(pfc.Id) && adjClaimNbrToAdjReqIdMap.get(pfc.Id)!=Null
                       && pfc.ChannelPartner.Core_MDF_Group_Id__c != Null)
                    {
                        adjReqIdGroupIdListMap.put(adjClaimNbrToAdjReqIdMap.get(pfc.Id),new List<Id>{pfc.ChannelPartner.Core_MDF_Group_Id__c});
                    }                                     
                }
            }
            //to share adjustment request record with its account group
            if(adjReqIdGroupIdListMap != NULL && !adjReqIdGroupIdListMap.isEmpty()){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Adjustment_Request__c', adjReqIdGroupIdListMap, 'Edit', 'Manual');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }  
            
            //To share record on the basis of Channel Program and geo 
            if(recordGeoShareList != null && recordGeoShareList.size() >0){
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Core_MDF_Adjustment_Request__c',recordGeoShareList);
            }
            // Passing the Parameters to the Generic Share Record Class method 
            // to share the Payment to the respective Group
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Core_MDF_Adjustment_Request__c', recordPGMShareList);
            }                        
        }   catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /*****************************************************************************************************
Method Name:        shareAdjustmentRequestToPartnerUsers
@return  :          void
@parameters:        newAdjustmentRequestTobeShared - This will contain all the adjustment Records to be shared
Description:        Whenever a record is inserted/updated of Adjustment Request, this method shares the Claim to the Partner Users
according the Account Node on which the Claim is created
@Added By:          Accenture - JV - 07-06-2019
Modified By:        Date:       Changes:
******************************************************************************************************
public static void shareAdjustmentRequestToPartnerUsers(Map<Id, Core_MDF_Adjustment_Request__c> newAdjustmentRequestTobeShared){

// querying the Account Node on the Related Adjustment Claim on the Adjustment Record
newAdjustmentRequestTobeShared = new Map<Id,Core_MDF_Adjustment_Request__c>([SELECT Id,Core_MDF_Adjustment_Claim_Nbr__c,Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId
FROM Core_MDF_Adjustment_Request__c 
WHERE Id IN: newAdjustmentRequestTobeShared.keySet()]);
//Map<AdjClaimId, AdjustmentRequestId>
Map<String,Id> adjClaimNbrToAdjReqIdMap = new Map<String,Id>();

//Map<adjustmentRequestId, List<Users>>
Map<Id,List<Id> > adjReqShareList = new Map<Id,List<Id> >();

//Set<channelPartnerIds>
Set<Id> accountNodeIdSet = new Set<Id>();

// Map<accountId,UserList>
Map<Id,List<Id> > accountUserList = new Map<Id,List<Id> >();

for(Core_MDF_Adjustment_Request__c adjustmentRequest: newAdjustmentRequestTobeShared.values()) {
adjClaimNbrToAdjReqIdMap.put(adjustmentRequest.Core_MDF_Adjustment_Claim_Nbr__c,adjustmentRequest.Id);
//retrieve the Account Node Id for the claim
accountNodeIdSet.add(adjustmentRequest.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId);
}

for(Core_MDF_Partner_Node_User_Mapping__c pnumRec: [SELECT Id, Core_MDF_Account__c, Core_MDF_User__c
FROM Core_MDF_Partner_Node_User_Mapping__c
WHERE Core_MDF_Account__c IN : accountNodeIdSet and Core_MDF_User__r.IsActive = true]) {

if(accountUserList.containsKey(pnumRec.Core_MDF_Account__c)) {
accountUserList.get(pnumRec.Core_MDF_Account__c).add(pnumRec.Core_MDF_User__c);
}
else {
accountUserList.put(pnumRec.Core_MDF_Account__c, new List<Id> {pnumRec.Core_MDF_User__c});
}

}

for(Core_MDF_Adjustment_Request__c adjustmentRequest : newAdjustmentRequestTobeShared.values()) {
//For each claim add claim Id and list of users to whom the claim record to be shared
if(accountUserList.get(adjustmentRequest.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId)!=null && accountUserList.get(adjustmentRequest.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId).size() > 0)
{
adjReqShareList.put(adjustmentRequest.Id, accountUserList.get(adjustmentRequest.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId));
}
}

if(adjReqShareList!=null && adjReqShareList.size() > 0) {

//Call the generic sharing method to share the list of claims and corresponding list of users
Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Adjustment_Request__c',adjReqShareList, 'Edit');
Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);

}
}*/
    
    /*****************************************************************************************************
Method Name:        recalculateShareAdjustmentRequestWhenOwnerChange
@return  :          void
@parameters:        adjRequestList - This will contain all the pfc records to be shared
Description:        Whenever the owner inserted/updated of Adjustment Request, this method shares the Claim to the Internal Managers
according the Account Node on which the Claim is created
@Added By:          Accenture - JV - 07-06-2019
Modified By:        Date:       Changes:
******************************************************************************************************/
    
    public static void recalculateShareAdjustmentRequestWhenOwnerChange(List<Core_MDF_Adjustment_Request__c> adjRequestList, Map<Id,Core_MDF_Adjustment_Request__c> oldadjRequestMap) {
        
        List<Core_MDF_Adjustment_Request__c> adjustmentRequestsTobeReshared = new List<Core_MDF_Adjustment_Request__c>();
        Map<ID,Core_MDF_Adjustment_Request__c> adjustmentRequestsTobeResharedMap = new Map<ID,Core_MDF_Adjustment_Request__c>();
        // Check whether the Owner is updated from the new and old list
        for(Core_MDF_Adjustment_Request__c newadjRequest : adjRequestList) {
            
            if(newadjRequest.OwnerId != oldadjRequestMap.get(newadjRequest.Id).OwnerId) {
                adjustmentRequestsTobeReshared.add(newadjRequest);
                adjustmentRequestsTobeResharedMap.put(newadjRequest.Id,newadjRequest);
            }
        }
        // Share the Claims to Internal Account Managers
        if(adjustmentRequestsTobeReshared!=null && adjustmentRequestsTobeReshared.size()>0) {
            shareAdjustmentRequestToInternalUsers(adjustmentRequestsTobeReshared);
            shareAdjustmentRequestToPartnerUsers(adjustmentRequestsTobeResharedMap);
            
        }
    }
    /*******************************************************************************************************************/
    
    /*******************************************************************************************************************/
    /*******************************************************************************************************************/
    public static void shareAdjustmentRequestToPartnerUsers(Map<Id, Core_MDF_Adjustment_Request__c> newAdjustmentRequestTobeShared){
        
        // querying the Account Node on the Related Adjustment Claim on the Adjustment Record
        newAdjustmentRequestTobeShared = new Map<Id,Core_MDF_Adjustment_Request__c>([SELECT Id,Core_MDF_Adjustment_Claim_Nbr__c,Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId,
                                                                                     Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartner.Core_MDF_External_Group_Id__c FROM Core_MDF_Adjustment_Request__c 
                                                                                     WHERE Id IN: newAdjustmentRequestTobeShared.keySet()]);  
        
        //Map<adjustmentRequestId, List<Users>>
        Map<Id,List<Id> > adjReqShareList = new Map<Id,List<Id> >();
        //Set<channelPartnerIds>
        Set<Id> accountNodeIdSet = new Set<Id>();
        //Map of Acc Id to Ext Group Id
        Map<Id, Id> accountIdGroupIdMap = new Map<Id, Id>();
       /* for(Core_MDF_Adjustment_Request__c adjustmentRequest: newAdjustmentRequestTobeShared.values()) {
            //retrieve the Account Node Id for the claim
            accountNodeIdSet.add(adjustmentRequest.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId);
        }
        for(Account acc : [Select id,Core_MDF_External_Group_Id__c from Account where id in:accountNodeIdSet and Core_MDF_External_Group_Id__c != null]){
            accountIdGroupIdMap.put(acc.Id, acc.Core_MDF_External_Group_Id__c);
        } */
        for(Core_MDF_Adjustment_Request__c adjustmentRequest : newAdjustmentRequestTobeShared.values()) {
            //For each claim add claim Id and list of users to whom the claim record to be shared
            if(adjustmentRequest.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartner.Core_MDF_External_Group_Id__c!=null)
            {
                adjReqShareList.put(adjustmentRequest.Id, new List<Id>{adjustmentRequest.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartner.Core_MDF_External_Group_Id__c});
            }
        }
        if(adjReqShareList!=null && adjReqShareList.size() > 0) {
            //Call the generic sharing method to share the list of claims
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Adjustment_Request__c',adjReqShareList, 'Edit');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
    }
    
}