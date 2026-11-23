/****************************************************************************************************************************************
* Class Name        : Core_MDF_Audit_Document_Sharing
* Test Class  : Core_MDF_Audit_Document_Trigger_Test
* 				Core_MDF_PGM_BatchHelper_Test
* Created Date      : 7/28/2023
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Sandesh   28-07-2023         Created for sharing the Audit Document record. 
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Audit_Document_Sharing {
    
    /***************************************************************************************************** 
Method Name   :        shareAuditDocToInternalUsers
@return       :        void
@parameters   :        List<Core_MDF_Audit_Document__c>
Description   :         Whenever a record is inserted/updated of Audit Document, this method shares the Audit Document to the Internal Managers 
according the Account Node on which the Audit Document is created .
Added By      :        Accenture - Sandesh H - 07/28/2023
Modified By   :        Date:            Changes: 
******************************************************************************************************/  
    
    public static void shareAuditDocToInternalUsers(List<Core_MDF_Audit_Document__c> auditDocList) {
        
        // Channel program Sharing      
        List<Core_MDF_RecordGeoShare> recordGeoShareList= new List<Core_MDF_RecordGeoShare>();
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        
        //map of Audit Document id and group id with which it needs to be shared - VD  
        Map<Id,List<Id>> auditDocIdGroupIdListMap = new Map<Id,List<Id>>();
        
        List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        
        //Map<AuditDocClaimNbr, AuditDocId>
        Map<String,Id> auditDocClaimIdNbrToAudiDocIdMap = new Map<String,Id>();
        
        Set<Id> auditDocClaimIds = new Set<Id>();
        
        try {
            System.debug('auditDocList1-> '+auditDocList);
            
            for(Core_MDF_Audit_Document__c auditDoc: auditDocList) {
                auditDocClaimIdNbrToAudiDocIdMap.put(auditDoc.Core_MDF_Claim__c, auditDoc.Id);
                auditDocClaimIds.add(auditDoc.Core_MDF_Claim__c);
            }
            System.debug('auditDocClaimIds-> '+auditDocClaimIds);
            claimList = [SELECT Id, Core_MDF_AccountCompany__c,ChannelPartner.Core_Geo__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Group_Id__c,Core_MDF_Program__c,Core_MDF_Budget_Type_Options_Nm__c,
                         ChannelPartner.Core_MDF_Channel_Program__r.Name,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Country_Location_nm__c,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c 
                         FROM PartnerFundClaim where Id IN: auditDocClaimIds];
            
            System.debug('claimList-> '+claimList);
            
            if(claimList != NULL && claimList.size() > 0){ 
                for (PartnerFundClaim pfc : claimList) {
                    
                    //To share record on the basis of Channel Program and geo 
                    //if(pfc.Core_MDF_Program__c==Label.Core_MDF_IPA_Program_Name)
                    if(pfc.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name'))
                    {
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(auditDocClaimIdNbrToAudiDocIdMap.get(pfc.ID),pfc.ChannelPartner.Core_Geo__c,NULL,pfc.Core_MDF_Program__c,pfc.Core_MDF_Budget_Type_Options_Nm__c));   
                        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(auditDocClaimIdNbrToAudiDocIdMap.get(pfc.ID),pfc.ChannelPartner.Core_Geo__c,NULL,pfc.Core_MDF_Program__c,pfc.Core_MDF_Budget_Type_Options_Nm__c,pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
                    }/*else if(pfc.Core_MDF_Program__c == Label.Core_MDF_CMDF_Program_Name)
{
recordGeoShareList.add(new Core_MDF_RecordGeoShare(auditDocClaimIdNbrToAudiDocIdMap.get(pfc.ID),pfc.Core_MDF_Region_Cd__c,pfc.Core_MDF_Sub_Region_Cd__c,pfc.Core_MDF_Program__c,pfc.Core_MDF_Budget_Type_Options_Nm__c));   
recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(auditDocClaimIdNbrToAudiDocIdMap.get(pfc.ID),pfc.Core_MDF_Region_Cd__c,pfc.Core_MDF_Sub_Region_Cd__c,pfc.Core_MDF_Program__c,pfc.Core_MDF_Budget_Type_Options_Nm__c,pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
}*/
                    else
                    {
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(auditDocClaimIdNbrToAudiDocIdMap.get(pfc.ID),pfc.Core_MDF_Region_Cd__c,pfc.Core_MDF_Sub_Region_Cd__c,pfc.Core_MDF_Program__c));   
                        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(auditDocClaimIdNbrToAudiDocIdMap.get(pfc.ID),pfc.Core_MDF_Region_Cd__c,pfc.Core_MDF_Sub_Region_Cd__c,pfc.Core_MDF_Program__c,pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
                    }
                    System.debug('recordGeoShareList 2->'+recordGeoShareList);
                    System.debug('recordPGMShareList 3->'+recordPGMShareList);
                    
                    //Storing claim Id and its account's group id for sharing it with account group-VD  
                    if(pfc.ChannelPartner.Core_MDF_Channel_Program__c != Null && pfc.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c != Null
                       && Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(pfc.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c)
                       && auditDocClaimIdNbrToAudiDocIdMap.containskey(pfc.Id) && auditDocClaimIdNbrToAudiDocIdMap.get(pfc.Id)!=Null
                       && pfc.ChannelPartner.Core_MDF_Group_Id__c != Null){
                           auditDocIdGroupIdListMap.put(auditDocClaimIdNbrToAudiDocIdMap.get(pfc.Id),new List<Id>{pfc.ChannelPartner.Core_MDF_Group_Id__c});                                 
                       }                 
                }
            }
            
            //To share Audit Document record with its account's group         
            if(auditDocIdGroupIdListMap != NULL && !auditDocIdGroupIdListMap.isEmpty()){
                System.debug('auditDocIdGroupIdListMap-> '+auditDocIdGroupIdListMap);
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Audit_Document__c', auditDocIdGroupIdListMap, 'Edit', 'Manual');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            } 
            //To share record on the basis of Channel Program and geo 
            if(recordGeoShareList != null && recordGeoShareList.size() >0){
                System.debug('recordGeoShareList-> '+recordGeoShareList);
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Core_MDF_Audit_Document__c',recordGeoShareList);
            }
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                System.debug('recordGeoShareList-> '+recordGeoShareList);
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Core_MDF_Audit_Document__c', recordPGMShareList);
            }       
            
        } catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        
    }
    
    /***************************************************************************************************** 
Method Name   :        shareAuditDocToclaim
@return       :        void
@parameters   :        Map<Id, Core_MDF_Audit_Document__c>
Description   :         Whenever a record is inserted/updated of Audit Document, this method shares the Audit Document to claims sharing groups.
Added By      :        Accenture - Sandesh H - 07/28/2023
Modified By   :        Date:            Changes: 
******************************************************************************************************/ 
    
    public static void shareAuditDocToclaim(Map<Id, Core_MDF_Audit_Document__c> newAuditDocTobeShared){
        Set<Id> claimNodeIdSet = new Set<Id>();
        Map<Id,List<Id>> claimIdToPFCShareMapRead = new Map<Id,List<Id>>();
        Map<Id,List<Id>> claimIdToPFCShareMapWrite = new Map<Id,List<Id>>();
        Map<Id,List<Id>> auditDocGroupSharingRead = new Map<Id,List<Id>>();
        Map<Id,List<Id>> auditDocGroupSharingWrite = new Map<Id,List<Id>>();
        try { 
            List<String> programsForAllUserCCPGroupList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Prog_For_AllUserCCPGroupSharing').split(',');
            List<Group> groupList = [Select Id from Group where Name  = 'AGS_All Users - CCP Internal' limit 1]; //HP:ATHR Fix
            for(Core_MDF_Audit_Document__c auditDoc : newAuditDocTobeShared.values()){ 
                claimNodeIdSet.add(auditDoc.Core_MDF_Claim__c);
            }
            
            List<PartnerFundClaimShare> claimShareList = !claimNodeIdSet.isEmpty() ? [SELECT Id, ParentId, UserOrGroupId, UserOrGroup.Name, AccessLevel, RowCause, Parent.Core_MDF_Program__c FROM PartnerFundClaimShare WHERE ParentId IN :claimNodeIdSet AND RowCause = 'Manual'] : new List<PartnerFundClaimShare>();
            
            for(PartnerFundClaimShare pfcShare : claimShareList){
                
                if(!claimIdToPFCShareMapRead.containsKey(pfcShare.ParentId)){
                    claimIdToPFCShareMapRead.put(pfcShare.ParentId, new List<Id>());
                }
                if(!claimIdToPFCShareMapWrite.containsKey(pfcShare.ParentId)){
                    claimIdToPFCShareMapWrite.put(pfcShare.ParentId, new List<Id>());
                }
                
                if(pfcShare.AccessLevel == 'Read'){
                    claimIdToPFCShareMapRead.get(pfcShare.ParentId).add(pfcShare.UserOrGroupId);
                }
                
                if(pfcShare.AccessLevel == 'Edit'){
                    claimIdToPFCShareMapWrite.get(pfcShare.ParentId).add(pfcShare.UserOrGroupId);
                }
                
                if(groupList != null && !groupList.isEmpty() && programsForAllUserCCPGroupList.contains(pfcShare.Parent.Core_MDF_Program__c)){
                    List<Id> groupIdList = claimIdToPFCShareMapWrite.get(pfcShare.ParentId);
                    if(groupIdList!=null && groupIdList.size() > 0 && !groupIdList.contains(groupList[0].Id)){
                        claimIdToPFCShareMapWrite.get(pfcShare.ParentId).add(groupList[0].Id);
                    }
                }
            }
            
            for(Core_MDF_Audit_Document__c auditDoc : newAuditDocTobeShared.values())
            {      
                if(claimIdToPFCShareMapRead.containsKey(auditDoc.Core_MDF_Claim__c) && claimIdToPFCShareMapRead.get(auditDoc.Core_MDF_Claim__c)!=null) 
                {
                    auditDocGroupSharingRead.put(auditDoc.Id, claimIdToPFCShareMapRead.get(auditDoc.Core_MDF_Claim__c));
                }
                
                if(claimIdToPFCShareMapWrite.containsKey(auditDoc.Core_MDF_Claim__c) && claimIdToPFCShareMapWrite.get(auditDoc.Core_MDF_Claim__c)!=null) 
                {
                    auditDocGroupSharingWrite.put(auditDoc.Id, claimIdToPFCShareMapWrite.get(auditDoc.Core_MDF_Claim__c));
                }
            }
            
            
            if(auditDocGroupSharingRead!=null && auditDocGroupSharingRead.size() > 0)
            {
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Audit_Document__c',auditDocGroupSharingRead, 'Read');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
            
            if(auditDocGroupSharingWrite!=null && auditDocGroupSharingWrite.size() > 0)
            {
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Audit_Document__c',auditDocGroupSharingWrite, 'Edit');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
            
        }catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        
    }
}