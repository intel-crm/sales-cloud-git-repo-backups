/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_Sharing
* Version     : 1.0
* Created Date: 18-11-2018
* Modification Log :
* Developer            Date                 Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture  - Anjali Haryani       18/11/2018           Created for sharing the claim record.
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PFC_Sharing {
    public static List<PartnerFundClaim> listOfClaims = new List<PartnerFundClaim>();
    
    /***************************************************************************************************** 
Method Name:        shareClaimToInternalUsers
@return  :          void
@parameters:        claimList - This will contain all the pfc records to be shared 
Description:        Whenever a record is inserted/updated of Partner Fund Claim, this method shares the Claim to the Internal Managers 
according the Account Node on which the Claim is created
@Added By:          Accenture - JV - 15-11-2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    
    public static void shareClaimToInternalUsers(List<PartnerFundClaim> claimList) {  
        
        // Company Account Set 
        Set<ID> companyAccountSet = new Set<ID>();//ID
        
        //Channel program Set
        Set<ID> channelProgramSet = new Set<ID>();//ID
        
        //Create Region Set
        Set<String> regionSet = new Set<String>();
        
        //key=accId+program+Geo, value=List<ClaimId>
        Map<String,List<Id>> accountIdProgramIdGeoClaimIdListMap = new Map<String,List<Id>>();
        
        //key=accId+ProgramId+Geo+SubGeo, value=List<ClaimId>
        Map<String,List<Id>> accountIdProgramIdGeoSubGeoClaimIdListMap = new Map<String,List<Id>>();
        
        //for WW -> key=accId+ProgramId, value=List<ClaimId>
        Map<String,List<Id>> accountIdProgramIdClaimIdListMap = new Map<String,List<Id>>();
        
        // Channel program Sharing      
        List<Core_MDF_RecordGeoShare> recordGeoShareList= new List<Core_MDF_RecordGeoShare>();
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        
        //map of record id and group id with which it needs to be shared - VD  
        Map<Id,List<Id>> claimIdGroupIdListMap = new Map<Id,List<Id>>();
        Set<Id> claimIdSet = new Set<Id>();
        
        try {
            for(PartnerFundClaim claim : claimList){
                claimIdSet.add(claim.Id);
            }
            listOfClaims = [SELECT Id, Request.Campaign.Core_MDF_Account__c,Request.Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c,Request.Campaign.Core_MDF_Account__r.Core_MDF_Group_Id__c,Core_MDF_AccountCompany__c,ChannelPartner.Core_Geo__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Group_Id__c,Core_MDF_Program__c,Core_MDF_Budget_Type_Options_Nm__c,
                            ChannelPartner.Core_MDF_Channel_Program__r.Name,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Country_Location_nm__c,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c, Core_MDF_Claim_Id__c 
                            FROM PartnerFundClaim WHERE ID IN:claimIdSet AND Core_MDF_Claim_Id__c = null];    
            
            if(listOfClaims != NULL && listOfClaims.size() > 0){ 
                for (PartnerFundClaim pfc : listOfClaims) {
                    
                    //To share record on the basis of Channel Program and geo 
                    if(pfc.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name')){
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfc.ID,pfc.ChannelPartner.Core_Geo__c,NULL,pfc.Core_MDF_Program__c,pfc.Core_MDF_Budget_Type_Options_Nm__c));   
                        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfc.ID,pfc.ChannelPartner.Core_Geo__c,NULL,pfc.Core_MDF_Program__c,pfc.Core_MDF_Budget_Type_Options_Nm__c,pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
                    }else{   
                        if(pfc.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM) {
                            if(pfc.Core_MDF_Region_Cd__c != null){
                                recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfc.ID,pfc.Core_MDF_Region_Cd__c,pfc.Core_MDF_Sub_Region_Cd__c,pfc.Core_MDF_Program__c,pfc.Core_MDF_Budget_Type_Options_Nm__c));   
                                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfc.ID,pfc.Core_MDF_Region_Cd__c,pfc.Core_MDF_Sub_Region_Cd__c,pfc.Core_MDF_Program__c,pfc.Core_MDF_Budget_Type_Options_Nm__c,pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
                            }else{
                                List<String> regions = Core_MDF_CCP_ConstantClass.CAMPAIGN_ALL_REGION.split(';');
                                for(String geo: regions) {
                                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfc.ID,geo,NULL,pfc.Core_MDF_Program__c,pfc.Core_MDF_Budget_Type_Options_Nm__c));   
                                    recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfc.ID,geo,NULL,pfc.Core_MDF_Program__c,pfc.Core_MDF_Budget_Type_Options_Nm__c,pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));                                
                                }
                            }
                        } else {
                            recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfc.ID,pfc.Core_MDF_Region_Cd__c,pfc.Core_MDF_Sub_Region_Cd__c,pfc.Core_MDF_Program__c));   
                            recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfc.ID,pfc.Core_MDF_Region_Cd__c,pfc.Core_MDF_Sub_Region_Cd__c,pfc.Core_MDF_Program__c,pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
                        }
                        //added by JK - Claim sharing to primary partner accounts with read only access
                        if(pfc.Core_MDF_Program__c == 'Ecosystem Extension Fund'){
                            recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfc.ID,pfc.Core_MDF_Region_Cd__c,pfc.Core_MDF_Sub_Region_Cd__c,pfc.Core_MDF_Program__c,null,pfc.Request.Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c,'Read'));
                        }
                    }
                    
                    //Storing claim Id and its account's group id for sharing it with account group-VD  
                    if(pfc.ChannelPartner.Core_MDF_Channel_Program__c != Null && pfc.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c != Null
                       && Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(pfc.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c)
                       && pfc.ChannelPartner.Core_MDF_Group_Id__c != Null){
                           claimIdGroupIdListMap.put(pfc.Id,new List<Id>{pfc.ChannelPartner.Core_MDF_Group_Id__c});               
                       }
                }
            }
            //To share claim record with its account's group - VD            
            if(claimIdGroupIdListMap != NULL && !claimIdGroupIdListMap.isEmpty()){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundClaim', claimIdGroupIdListMap, 'Edit', 'Manual');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
            //To share record on the basis of Channel Program and geo 
            if(recordGeoShareList != null && recordGeoShareList.size() >0){
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('PartnerFundClaim',recordGeoShareList);
            }
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('PartnerFundClaim', recordPGMShareList);
            }  
        } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        
    }
    
    /***************************************************************************************************** 
Method Name:        recalculateShareClaimWhenOwnerChange
@return  :          void
@parameters:        claimList - This will contain all the pfc records to be shared 
Description:        Whenever the owner inserted/updated of Partner Fund Claim, this method shares the Claim to the Internal Managers 
according the Account Node on which the Claim is created, also to the all the Users according to PNUM entries
@Added By:          Accenture - JV - 15-11-2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    
    public static void recalculateShareClaimWhenOwnerChange(List<PartnerFundClaim> claimList, Map<Id,PartnerFundClaim> oldClaimMap) {  
        
        List<PartnerFundClaim> claimsTobeReshared = new List<PartnerFundClaim>();
        // Check whether the Owner is updated from the new and old list
        for(PartnerFundClaim newpfc : claimList){
            
            if(newpfc.OwnerId != oldClaimMap.get(newpfc.Id).OwnerId  && newpfc.Core_MDF_Claim_Id__c == null){
                claimsTobeReshared.add(newpfc);
            }
            
        }
        // Share the Claims to Internal Account Managers
        if(claimsTobeReshared!=null && claimsTobeReshared.size()>0){
            shareClaimToInternalUsers(claimsTobeReshared);
            
            // Share the Claims to Based on Partner Node User Mapping Entries
            Map<ID,PartnerFundClaim> claimIdToClaimMap = new Map<ID,PartnerFundClaim>(claimsTobeReshared);
            shareClaimToPartnerUsers(claimIdToClaimMap);
        }  
    }
    
    
    /************************************
* 
* **********************************/
    public static void shareClaimToPartnerUsers(Map<Id, PartnerFundClaim> newPFCTobeShared){
        
        Set<Id> accountNodeIdSet = new Set<Id>();
        Map<Id,PartnerFundClaim> accountIdToClaimMap = new Map<Id,PartnerFundClaim>();
        //Map of account Id and Group Id
        Map<Id, Id> accountIdGroupIdMap = new Map<Id, Id>();
        Map<Id,List<Id>> pfcGroupShareList = new Map<Id,List<Id>>();
        Map<Id,List<Id>> pfcEEFPrimaryGroupShareList = new Map<Id,List<Id>>();
        Map<Id,Id> pfcIdCampaignAccountIdMap =  new Map<Id,Id>();
        Map<Id,List<Id>> pfcEEFGroupShareList = new Map<Id,List<Id>>(); 
        String eefProgramName = Core_MDF_CCP_ConstantClass.EEF_PROGRAM;
        
        for(PartnerFundClaim pfc : newPFCTobeShared.values()){ 
            accountNodeIdSet.add(pfc.ChannelPartnerId);
            accountIdToClaimMap.put(pfc.ChannelPartnerId,pfc);
        }
        for(PartnerFundClaim pfc:listOfClaims){
            if(pfc.Core_MDF_Program__c == eefProgramName){
                accountNodeIdSet.add(pfc.Request.Campaign.Core_MDF_Account__c);
                pfcIdCampaignAccountIdMap.put(pfc.Id,pfc.Request.Campaign.Core_MDF_Account__c);
            }
        }
        
        for(Account acc : [Select id,Core_MDF_External_Group_Id__c from Account 
                           where id in:accountNodeIdSet and Core_MDF_External_Group_Id__c != null]){
                               accountIdGroupIdMap.put(acc.Id, acc.Core_MDF_External_Group_Id__c);
                           }
        
        for(PartnerFundClaim pfc : newPFCTobeShared.values())
        {      
            //For each claim add claim Id and list of users to whom the claim record to be shared 
            if(accountIdGroupIdMap.containsKey(pfc.ChannelPartnerId) && accountIdGroupIdMap.get(pfc.ChannelPartnerId)!=null && pfc.Core_MDF_Claim_Id__c == null){
                pfcGroupShareList.put(pfc.Id, new list<Id> {accountIdGroupIdMap.get(pfc.ChannelPartnerId)});
            }
            if(pfc.Core_MDF_Program__c == eefProgramName && accountIdGroupIdMap.containsKey(pfcIdCampaignAccountIdMap.get(pfc.Id)) && accountIdGroupIdMap.get(pfcIdCampaignAccountIdMap.get(pfc.Id)) != NULL){
                pfcEEFGroupShareList.put(pfc.Id,new list<Id> {accountIdGroupIdMap.get(pfcIdCampaignAccountIdMap.get(pfc.Id))});
            }
        }
        if(pfcGroupShareList!=null && pfcGroupShareList.size() > 0)
        {
            //Call the generic sharing method to share the list of claims and corresponding node Groups
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundClaim',pfcGroupShareList, 'Edit');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
        if(pfcEEFGroupShareList !=null && pfcEEFGroupShareList.size() > 0)
        {
            //Call the generic sharing method to share the list of claims and corresponding node Groups
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundClaim',pfcEEFGroupShareList, 'Read');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
    }
}