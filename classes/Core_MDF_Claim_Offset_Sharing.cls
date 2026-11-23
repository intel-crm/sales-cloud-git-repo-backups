/****************************************************************************************************************************************
 * Method Name  : Core_MDF_Claim_Offset_Sharing 
 * Version     : 1.0
 * Created Date: 07-06-2019
 * Modification Log :
 * Developer            Date                 Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture - JV      07/06/2019           Created for sharing the Claim offset record during the creation and owner change .
 *****************************************************************************************************************************************/

public without sharing class Core_MDF_Claim_Offset_Sharing {

/*****************************************************************************************************
   Method Name:        shareClaimOffsetToInternalAccountManagers
   @return  :          void
   @parameters:        claimOffsetList - This will contain all the claim offset records to be shared
   Description:        Whenever a record is inserted/updated of Claim Offset, this method shares the Claim to the Internal Managers
                                        according the Account Node on which the Claim is created
   @Added By:          Accenture - JV - 10-06-2019
   Modified By:        Date:       Changes:
 ******************************************************************************************************/

public static void shareClaimOffsetToInternalAccountManagers(List<Core_MDF_Claim_Offset__c> claimOffsetList) {
/*
    // Company Account Set
    Set<ID> companyAccountSet = new Set<ID>();//ID

    //List of Partner Group Mapping Object with the Company Account
    List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();

    // Create a Map<ClaimOffset, List<GroupId>>
    Map<ID,List<ID> > claimOffsetIdToGroupIdMap = new Map<ID,List<ID> >();

    // List of Adjustment Claim ids from Claim Offsets
    List<ID> adjustmentClaimIds = new List<ID>();

    //Map<AdjClaimId, claimOffsetId>
    Map<ID,ID> adjustmentClaimToClaimOffsetIdMap = new Map<ID,ID>();

    try {

        for(Core_MDF_Claim_Offset__c claimOffset: claimOffsetList) {
            adjustmentClaimToClaimOffsetIdMap.put(claimOffset.Core_MDF_Adjustment_Claim_Nbr__c,claimOffset.Id);
            adjustmentClaimIds.add(claimOffset.Core_MDF_Adjustment_Claim_Nbr__c);
        }

        Map<Id,PartnerFundClaim> claimMap = new Map<Id,PartnerFundClaim>([SELECT Id, Core_MDF_AccountCompany__c,ChannelPartner.Core_MDF_Channel_Program__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,
                                                                          ChannelPartner.Core_MDF_Channel_Program__r.Name,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c
                                                                          FROM PartnerFundClaim
                                                                          WHERE ID IN: adjustmentClaimIds]);

        if(claimMap != NULL && claimMap.size() > 0) {
            for (PartnerFundClaim pfc : claimMap.values()) {
                companyAccountSet.add(pfc.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c);
            }
        }

        pgmList = [SELECT ID, Core_MDF_Account__c,Core_MDF_Channel_Program__c,Core_MDF_Group_Id__c,Core_MDF_Group_Name__c,
                   Core_MDF_Type_of_Access__c,Core_MDF_Works_For__c FROM Core_MDF_Partner_Group_Mapping__c
                   WHERE Core_MDF_Account__c IN: companyAccountSet AND Core_MDF_Type_of_Access__c = 'Internal'];

        if(pgmList != NULL && pgmList.size() > 0)
        {
            for (PartnerFundClaim pfc : claimMap.values())
            {
                for (Core_MDF_Partner_Group_Mapping__c pgm : pgmList)
                {
                    if(pgm.Core_MDF_Channel_Program__c == pfc.ChannelPartner.Core_MDF_Channel_Program__c
                       && pgm.Core_MDF_Account__c == pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c
                       ) {

                        claimOffsetIdToGroupIdMap.put(adjustmentClaimToClaimOffsetIdMap.get(pfc.ID), new List<ID> {pgm.Core_MDF_Group_Id__c});
                    }
                }
            }

            // Passing the Map<ClaimOffset Object, List<GroupID> to the Generic Share Record Class method
            // to share the Claim to the respective Group
            Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Claim_Offset__c',claimOffsetIdToGroupIdMap);
        }
    } catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}*/

}

/*****************************************************************************************************
   Method Name:        shareClaimOffsetToPartnerUsers
   @return  :          void
   @parameters:        newClaimOffsetTobeShared - This will contain all the claim offset records to be shared
   Description:        Whenever a record is inserted/updated of Claim Offset, this method shares the Claim to the Partner Users
                                        according the Account Node on which the Claim is created
   @Added By:          Accenture - JV - 10-06-2019
   Modified By:        Date:       Changes:
 ******************************************************************************************************/
public static void shareClaimOffsetToPartnerUsers(Map<Id, Core_MDF_Claim_Offset__c> newClaimOffsetTobeShared){
/*
    // querying the Account Node on the Related Adjustment Claim on the Claim offset
    newClaimOffsetTobeShared = new Map<Id, Core_MDF_Claim_Offset__c>([SELECT Id,Core_MDF_Adjustment_Claim_Nbr__c,Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId
                                                                    FROM Core_MDF_Claim_Offset__c WHERE ID IN:newClaimOffsetTobeShared.keySet()]);

    //Map<AdjClaimId, claimOffsetId>
    Map<String,Id> adjustmentClaimToClaimOffsetIdMap = new Map<String,Id>();

    //Map<claimoffsetId, List<Users>>
    Map<Id,List<Id> > claimOffsetShareList = new Map<Id,List<Id> >();

    //Set<channelPartnerIds>
    Set<Id> accountNodeIdSet = new Set<Id>();

    // Map<accountId,UserList>
    Map<Id,List<Id> > accountUserList = new Map<Id,List<Id> >();

    for(Core_MDF_Claim_Offset__c claimOffset: newClaimOffsetTobeShared.values()) {
        adjustmentClaimToClaimOffsetIdMap.put(claimOffset.Core_MDF_Adjustment_Claim_Nbr__c,claimOffset.Id);
    }

    //Retrieve each claims from the incoming list and share it with the node
    for(Id claimOffsetId : newClaimOffsetTobeShared.keySet()) {

        //retrieve the Account Node Id for the claim
        accountNodeIdSet.add(newClaimOffsetTobeShared.get(claimOffsetId).Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId);
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

    for(Core_MDF_Claim_Offset__c claimOffset : newClaimOffsetTobeShared.values()) {
        //For each claim add claim Id and list of users to whom the claim record to be shared
        if(accountUserList.get(claimOffset.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId)!=null && accountUserList.get(claimOffset.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId).size() > 0)
        {
            claimOffsetShareList.put(claimOffset.Id, accountUserList.get(claimOffset.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId));
        }
    }

    if(claimOffsetShareList!=null && claimOffsetShareList.size() > 0) {

        //Call the generic sharing method to share the list of claims and corresponding list of users
        Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Claim_Offset__c',claimOffsetShareList);

    }*/

}

/*****************************************************************************************************
   Method Name:        recalculateShareClaimOffsetWhenOwnerChange
   @return  :          void
   @parameters:        adjRequestList - This will contain all the pfc records to be shared
   Description:        Whenever the owner inserted/updated of Adjustment Request, this method shares the Claim to the Internal Managers
                                        according the Account Node on which the Claim is created
   @Added By:          Accenture - JV - 07-06-2019
   Modified By:        Date:       Changes:
 ******************************************************************************************************/

public static void recalculateShareClaimOffsetWhenOwnerChange(List<Core_MDF_Claim_Offset__c> claimOffsetList, Map<Id,Core_MDF_Claim_Offset__c> oldClaimOffsetMap) {
/*
    List<Core_MDF_Claim_Offset__c> claimOffsetsTobeReshared = new List<Core_MDF_Claim_Offset__c>();
    Map<ID,Core_MDF_Claim_Offset__c> claimOffsetsTobeResharedMap = new Map<ID,Core_MDF_Claim_Offset__c>();
    // Check whether the Owner is updated from the new and old list
    for(Core_MDF_Claim_Offset__c newaclaimOffset : claimOffsetList) {

        if(newaclaimOffset.Core_MDF_Offset_Claim_Nbr__r.OwnerId != oldClaimOffsetMap.get(newaclaimOffset.Id).Core_MDF_Offset_Claim_Nbr__r.OwnerId) {
            claimOffsetsTobeReshared.add(newaclaimOffset);
            claimOffsetsTobeResharedMap.put(newaclaimOffset.Id,newaclaimOffset);
        }
    }
    // Share the Claim Offsets to Internal Account Managers
    if(claimOffsetsTobeReshared!=null && claimOffsetsTobeReshared.size()>0) {
        shareClaimOffsetToInternalAccountManagers(claimOffsetsTobeReshared);
        shareClaimOffsetToPartnerUsers(claimOffsetsTobeResharedMap);
    }*/
}

}