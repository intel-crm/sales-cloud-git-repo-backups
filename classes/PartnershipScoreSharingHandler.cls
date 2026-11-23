public without sharing class PartnershipScoreSharingHandler {

    public static List<Id> listOfAccIds = new List<Id>();
    public static Set<String> setOfChannelPrgm = new Set<String>();
    public static Set<Id> setOfChannelPrgmIds = new Set<Id>();
    public static void shareRecordtoPGMgroups (List <Core_MDF_Partnership_Score__c> newPartnerScoreList) {
        List<Core_MDF_Partnership_Score__c> newPartnerScoreData=[Select Core_MDF_Account_Id__c,Core_MDF_Account_Id__r.Core_Geo__c,Core_MDF_Channel_Program_Id__c,Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c from Core_MDF_Partnership_Score__c where Id IN :newPartnerScoreList];
        for (Core_MDF_Partnership_Score__c partnerScoreObj : newPartnerScoreData)
        {
            listOfAccIds.add(partnerScoreObj.Core_MDF_Account_Id__c);
            setOfChannelPrgm.add(partnerScoreObj.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c); 
            setOfChannelPrgmIds.add(partnerScoreObj.Core_MDF_Channel_Program_Id__c);
        }
        
        Set<Id> setOfPrgmsGeoBasedSharingReqdIds=new Set<Id>();
        
        //Getting programs where Geo based sharing is required
         for (Core_MDF_ChannelProgram__mdt cp:[select Core_MDF_Program_ID__c from Core_MDF_ChannelProgram__mdt where Core_MDF_Technical_Program_Name__c IN :setOfChannelPrgm and Geo_Based_Sharing_Required__c=:true]){
            setOfPrgmsGeoBasedSharingReqdIds.add(cp.Core_MDF_Program_ID__c);
             
         }
        
        
        //Preparing Map of programs and region from meta data
        Map<string,string> mapOfPrgmToRegion = new Map<string,string>();
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt cam:[Select id,Core_MDF_Region_cd__c,Core_MDF_Channel_Program_Name_txt__c from Core_MDF_ClaimActAllocRecTypeMapping__mdt where Core_MDF_Channel_Program_Name_txt__c IN :setOfChannelPrgm and Core_MDF_Region_cd__c!=null])
        {
            mapOfPrgmToRegion.put(cam.Core_MDF_Channel_Program_Name_txt__c,cam.Core_MDF_Region_cd__c);
        }
        List <Core_MDF_Partner_Group_Mapping__c> pgmList = [SELECT ID,Core_MDF_Account__c,Core_MDF_Region_cd__c,Core_MDF_Sub_Region_cd__c,Core_MDF_Type_of_Access__c,Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Group_Id__c FROM Core_MDF_Partner_Group_Mapping__c 
                                                       where Core_MDF_Account__c IN :listOfAccIds and Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c IN :setOfChannelPrgm];
        //List<Core_MDF_Partner_Group_Mapping__c> pgmList = Core_MDF_PGM_Utility.fetchExternalPGMRecords(setOfChannelPrgm,accountIds,null,null,null,null);
        List<Core_MDF_Partnership_Score__Share> listOfPartnerScore=new List<Core_MDF_Partnership_Score__Share>();
        //Iterate through new potential records
        try{
        if(!pgmList.isEmpty())
        {
        for (Core_MDF_Partnership_Score__c partnerScore : newPartnerScoreData)
        {    
         for(Core_MDF_Partner_Group_Mapping__c partnerGroup : pgmList)
            {
                if (partnerScore.Core_MDF_Account_Id__c == partnerGroup.Core_MDF_Account__c && partnerScore.Core_MDF_Channel_Program_Id__c == partnerGroup.Core_MDF_Channel_Program__c) 
                {
                    
                    //for programs where Geo based sharing is required and for internal
                    if(!(setOfPrgmsGeoBasedSharingReqdIds.isEmpty())&&(setOfPrgmsGeoBasedSharingReqdIds.contains(partnerScore.Core_MDF_Channel_Program_Id__c))&&(partnerGroup.Core_MDF_Type_of_Access__c=='Internal'))
                    {
                        
                        
                        if(((mapOfPrgmToRegion!=Null && !mapOfPrgmToRegion.isEmpty()))&&partnerScore.Core_MDF_Account_Id__r.Core_Geo__c==mapOfPrgmToRegion.get(partnerScore.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c))
                            {
                                
                            if((partnerScore.Core_MDF_Account_Id__r.Core_Geo__c==partnerGroup.Core_MDF_Region_cd__c) && (partnerScore.Core_MDF_Account_Id__r.Core_Sub_Geo__c==partnerGroup.Core_MDF_Sub_Region_cd__c))
                                {
                                    Core_MDF_Partnership_Score__Share partnerShare  = new Core_MDF_Partnership_Score__Share();
                                    partnerShare.ParentId = partnerScore.Id;
                                    partnerShare.UserOrGroupId = partnerGroup.Core_MDF_Group_Id__c;
                                    partnerShare.AccessLevel = 'Edit';
                                    partnerShare.RowCause = Schema.Core_MDF_Partnership_Score__Share.RowCause.Manual;
                                    listOfPartnerScore.add(partnerShare);
                                    
                                }
                            }
                        else if((partnerScore.Core_MDF_Account_Id__r.Core_Geo__c==partnerGroup.Core_MDF_Region_cd__c) && (partnerGroup.Core_MDF_Sub_Region_cd__c==null))
                            {
                                {
                                    Core_MDF_Partnership_Score__Share partnerShare  = new Core_MDF_Partnership_Score__Share();
                                    partnerShare.ParentId = partnerScore.Id;
                                    partnerShare.UserOrGroupId = partnerGroup.Core_MDF_Group_Id__c;
                                    partnerShare.AccessLevel = 'Edit';
                                    partnerShare.RowCause = Schema.Core_MDF_Partnership_Score__Share.RowCause.Manual;
                                    listOfPartnerScore.add(partnerShare);
                                    
                                }
                            }
                        
                    }
                    //for all other programs
                    else{
                        Core_MDF_Partnership_Score__Share partnerShare  = new Core_MDF_Partnership_Score__Share();
                        partnerShare.ParentId = partnerScore.Id;
                        partnerShare.UserOrGroupId = partnerGroup.Core_MDF_Group_Id__c;
                        partnerShare.AccessLevel = 'Edit';
                        partnerShare.RowCause = Schema.Core_MDF_Partnership_Score__Share.RowCause.Manual;
                        listOfPartnerScore.add(partnerShare);
                       } 
                 }
            }
        }
       }
         If(listOfPartnerScore.size()>0 && listOfPartnerScore !=null){
             Database.insert(listOfPartnerScore,false);
         }      
        }
         catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
    }
    
    /*****************************************************************************************************
Method Name:        shareRecordToGeoGroup
@return  :          void
@parameters:        List of Partnership score record
Description:        This method to perform account and program Based Sharing for a Partnership score record
Added By:           Accenture-MR
Date :                25-Feb-2022
Modified By:        Date:       Changes:
*****************************************************************************************************/
    public static void shareRecordToGeoGroup(List<Core_MDF_Partnership_Score__c> newPartnerScoreList) {
       		List<Core_MDF_Partnership_Score__c> newPartnerScoreData=[Select Core_MDF_Account_Id__c,Core_MDF_Account_Id__r.Core_Geo__c,Core_MDF_Channel_Program_Id__c,Core_MDF_Channel_Program_Id__r.Name,Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c from Core_MDF_Partnership_Score__c where Id IN :newPartnerScoreList];
            //To share record on the basis of Channel Program and geo
            List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
            //Map of account id and account
            Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>();
            Map<Id, String> mapOfScrIdToAccPgmId = new Map<Id, String>();
            try{
                if(listOfAccIds!=null){
                    accountIdToAccountMap = new Map<ID, Account>([Select Id, Core_Geo__c, Core_Sub_Geo__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c from Account where id IN :listOfAccIds and Core_MDF_CoMarketingActive__c=:true]);
                }
                
                for(Core_MDF_Partnership_Score__c partnerScore :newPartnerScoreData) {
                    if(accountIdToAccountMap.containskey(partnerScore.Core_MDF_Account_Id__c)){
                    Account account = accountIdToAccountMap.get(partnerScore.Core_MDF_Account_Id__c);
                    // Preparing final Map of partnerScore Id as key and Intel Account Id and Program Id as value
                    if(Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(partnerScore.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c)){
                        mapOfScrIdToAccPgmId.put(partnerScore.Id, String.valueOf(partnerScore.Core_MDF_Account_Id__c) + String.valueOf(partnerScore.Core_MDF_Channel_Program_Id__c));
                    }
                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(partnerScore.id, account.Core_Geo__c, account.Core_Sub_Geo__c, partnerScore.Core_MDF_Channel_Program_Id__r.Name));
                    }
                }
                
                //To share record on the basis of Channel Program and geo
                if(recordGeoShareList != null && recordGeoShareList.size() > 0) {
                    Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Core_MDF_Partnership_Score__c', recordGeoShareList);               
                
                } 
                //To share Partnership Score records with its account group            
                if(mapOfScrIdToAccPgmId!=Null && !mapOfScrIdToAccPgmId.isEmpty()){
                    Core_MDF_shareRecordToAccountGroup.shareRecordToAllAcctGroupInHierarchy(mapOfScrIdToAccPgmId, 'Core_MDF_Partnership_Score__c', listOfAccIds, new List<Id>(setOfChannelPrgmIds));
                } 
            }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
                    
    }
    Public static void reshareRecords(Map<Id, Core_MDF_Partnership_Score__c> oldPartnershipscore, Map<Id, Core_MDF_Partnership_Score__c> newPartnershipscore){
        List<Core_MDF_Partnership_Score__c> partnershipScoreOwnerUpdatedList =new List<Core_MDF_Partnership_Score__c>();
        for(Id partnershipScoreId:oldPartnershipscore.keySet()){
        if(oldPartnershipscore.get(partnershipScoreId).OwnerId != newPartnershipscore.get(partnershipScoreId).OwnerId){//Owner Update
                
                partnershipScoreOwnerUpdatedList.add(newPartnershipscore.get(partnershipScoreId));
                
            }
        }
        
        system.debug('partnershipScoreOwnerUpdatedList1'+partnershipScoreOwnerUpdatedList);
        if(!partnershipScoreOwnerUpdatedList.isEmpty()){
        Core_MDF_Batch_Partnership_Score_Sharing batchInstance=new Core_MDF_Batch_Partnership_Score_Sharing((List<Core_MDF_Partnership_Score__c>) partnershipScoreOwnerUpdatedList);
            Id batchId = Database.executeBatch(batchInstance,30);
        }
    }
    
    Public static void resetFlagAfterOwnerUpdate(Map<Id, Core_MDF_Partnership_Score__c> oldPartnershipscore, Map<Id, Core_MDF_Partnership_Score__c> newPartnershipscore){
        
        for(Core_MDF_Partnership_Score__c pscList : newPartnershipscore.values() )
        {
            if(oldPartnershipscore.get(pscList.Id).OwnerId != pscList.OwnerId){
                pscList.Core_MDF_IsRecordShared_ind__c=false;
            }
        }
    }
    
}