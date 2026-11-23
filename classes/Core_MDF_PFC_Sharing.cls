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
    /****************************************************************************************************************************************
    * Method Name  : Core_MDF_PFC_Sharing
    * Version     : 1.0 
    * Created Date: 16-11-2018
    * Modification Log :
    * Developer            Date                 Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Intel - Amal Thomas       16/11/2018           Created for sharing the claim record during the creation and owner change .
    *****************************************************************************************************************************************/
    public static void shareClaimToPartnerUsers(Map<Id, PartnerFundClaim> newPFCTobeShared){
    
        Map<Id,List<Id>> pfcUserShareList = new Map<Id,List<Id>>(); 
    
        Set<Id> accountNodeIdSet = new Set<Id>();
        
        Map<Id,List<Id>> accountUserList = new Map<Id,List<Id>>(); 
        //Retrieve each claims from the incoming list and share it with the node
        for(Id pfcId : newPFCTobeShared.keySet()){
        
            //retrieve the Account Node Id for the claim
            accountNodeIdSet.add(newPFCTobeShared.get(pfcId).ChannelPartnerId);
            /* Retrieve all the node user mapping from account Id
            Prepare the map with Account(Node) Id and corresponding users list    
            */
        }
        for(Core_MDF_Partner_Node_User_Mapping__c pnumRec: [SELECT Id, Core_MDF_Account__c, Core_MDF_User__c 
                                                            FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                            WHERE Core_MDF_Account__c IN : accountNodeIdSet and Core_MDF_User__r.IsActive = true]){
    
            if(accountUserList.containsKey(pnumRec.Core_MDF_Account__c)){
                accountUserList.get(pnumRec.Core_MDF_Account__c).add(pnumRec.Core_MDF_User__c);
            }
            else {
                accountUserList.put(pnumRec.Core_MDF_Account__c, new List<Id>{pnumRec.Core_MDF_User__c});
            }
    
        }
                
        for(PartnerFundClaim pfc : newPFCTobeShared.values()){      
                //For each claim add claim Id and list of users to whom the claim record to be shared 
                if(accountUserList.get(pfc.ChannelPartnerId)!=null && accountUserList.get(pfc.ChannelPartnerId).size() > 0)
                {
                    pfcUserShareList.put(pfc.Id, accountUserList.get(pfc.ChannelPartnerId));
                }
        }
        
        if(pfcUserShareList!=null && pfcUserShareList.size() > 0){
            
            //Call the generic sharing method to share the list of claims and corresponding list of users
            //Core_MDF_GenericShareRecordActionClass.createShareRecordList('PartnerFundClaim',pfcUserShareList);
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundClaim', pfcUserShareList, 'Edit', 'Manual');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            
        }
        
    }
    
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
        
        try {
            claimList = [SELECT Id, Core_MDF_AccountCompany__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Program__c,
                         ChannelPartner.Core_MDF_Channel_Program__r.Name,Core_MDF_Country_Location_nm__c,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c 
                         FROM PartnerFundClaim
                         WHERE ID IN:claimList];    
            
            if(claimList != NULL && claimList.size() > 0){ 
                for (PartnerFundClaim pfc : claimList) {
                    companyAccountSet.add(pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c);//Core_MDF_AccountCompany__c
                    channelProgramSet.add(pfc.ChannelPartner.Core_MDF_Channel_Program__c);
                    regionSet.add(pfc.Core_MDF_Region_Cd__c);
                    
                     //String to store Account, program and Region
                    String accountIdProgramIdGeo = (String)pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+ (String)pfc.ChannelPartner.Core_MDF_Channel_Program__c +pfc.Core_MDF_Region_Cd__c;
                    
                    //String to store Account, program, Region and Sub Region
                    String accountIdProgramIdGeoSubGeo = (String)pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + (String)pfc.ChannelPartner.Core_MDF_Channel_Program__c +pfc.Core_MDF_Region_Cd__c+pfc.Core_MDF_Sub_Region_Cd__c;
                    
                    //string to store Account and Program
                    String accountIdProgramId = (String)pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c +(String)pfc.ChannelPartner.Core_MDF_Channel_Program__c; 
                    //Only Geo
                    if(accountIdProgramIdGeoClaimIdListMap.containsKey(accountIdProgramIdGeo)){
                        accountIdProgramIdGeoClaimIdListMap.get(accountIdProgramIdGeo).add(pfc.Id);
                    }
                    else{
                        accountIdProgramIdGeoClaimIdListMap.put(accountIdProgramIdGeo, new List<Id>{pfc.Id});
                    }
                    
                    //Only Geo & Sub Geo
                    if(accountIdProgramIdGeoSubGeoClaimIdListMap.containsKey(accountIdProgramIdGeoSubGeo)){
                        accountIdProgramIdGeoSubGeoClaimIdListMap.get(accountIdProgramIdGeoSubGeo).add(pfc.Id);
                    }
                    else{
                        accountIdProgramIdGeoSubGeoClaimIdListMap.put(accountIdProgramIdGeoSubGeo, new List<Id>{pfc.Id});
                    }
                    //FOR WW
                    if(accountIdProgramIdClaimIdListMap.containsKey(accountIdProgramId)){
                        accountIdProgramIdClaimIdListMap.get(accountIdProgramId).add(pfc.Id);
                    }
                    else{
                        accountIdProgramIdClaimIdListMap.put(accountIdProgramId, new List<Id>{pfc.Id});
                    }
                }
            }

            // Passing the Parameters to the Generic Share Record Class method 
            // to share the Claim to the respective Group
            if((accountIdProgramIdGeoSubGeoClaimIdListMap.size()>0||(accountIdProgramIdGeoClaimIdListMap.size()>0))||(accountIdProgramIdClaimIdListMap.size()>0)){
                Core_MDF_CCP_GenericUtility.createShareRecordsForInternal('PartnerFundClaim', companyAccountSet, channelProgramSet, regionSet, 
                                                                          accountIdProgramIdGeoSubGeoClaimIdListMap, accountIdProgramIdGeoClaimIdListMap, 
                                                                          accountIdProgramIdClaimIdListMap);
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
                
                if(newpfc.OwnerId != oldClaimMap.get(newpfc.Id).OwnerId){
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
}