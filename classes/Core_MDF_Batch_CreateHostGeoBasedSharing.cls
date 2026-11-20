/****************************************************************************************************************************************
 * Class Name        : Core_MDF_Batch_CreateHostGeoBasedSharing
 * Test Class		: Core_MDF_HostRegion_Sharing_Test
 * Created Date      : 06/10/2023
 * Modification Log
 * Developer            Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture - Mayuri       06/10/2023        Batch class to call the respective objects sharing class on Host Geo Update
 *****************************************************************************************************************************************/
global without sharing class Core_MDF_Batch_CreateHostGeoBasedSharing implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {

    global String sobjectName;  
    global String accQuery;
    global String programQuery;

    Set<String> hostGeo = new Set<String>();
	Set<Id> setOfAccountId = new Set<Id>();
	Set<Id> setOfProgramId = new Set<Id>();
	Set<String> accIdProgramIdSet = new Set<String>();
	
    
    //Constructor called from PGM_BatchHelper class
    global Core_MDF_Batch_CreateHostGeoBasedSharing(String objectName, String firstQuery, String secondQuery, 
                                                    Set<Id> accIdSet, Set<Id> programIdSet, Set<String> uniqueKeySet, Set<String> hostGeo) {
        this.sobjectName = objectName;
        this.accQuery = firstQuery;
        this.setOfAccountId = accIdSet;
        this.accIdProgramIdSet = uniqueKeySet;

        if(programIdSet != null) {
            this.setOfProgramId = programIdSet;
        }

        if(secondQuery != null) {
            this.programQuery = secondQuery;
        }
        this.hostGeo = hostGeo;
    }
    
	/*****************************************************************************************************
	   Method Name :   start
	   @return     :   List of records
	   @parameters :   Database.BatchableContext
	   Description :   It fetches all records based on input parameters
	   Added By    :   Accenture - Mayuri - 06/10/2023
	   Modified By :                               Date:                   Changes:
	 ******************************************************************************************************/
	global Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            if(sobjectName == 'Core_MDF_Escalation__c') {
                accQuery = accQuery.replace('toAddIntelAccSet', ':setOfAccountId');
                return Database.getQueryLocator(accQuery + programQuery + ':setOfProgramId' + ')');
            }
            else if(programQuery != null && setOfProgramId != null) {
                return Database.getQueryLocator(accQuery + ':setOfAccountId' + programQuery + ':setOfProgramId');
            } 
            else {
                return Database.getQueryLocator(accQuery + ':setOfAccountId');
            }
        } catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }

	}

	/********************************************************************************************************
	   Method Name :   execute
	   @return     :   void
	   @parameters :   Database.BatchableContext
	   Description :   Calls the respective method for sharing
	   Added By    :   Accenture - Mayuri - 06/10/2023
	   Modified By :                               Date:         Changes:
	 **********************************************************************************************************/
	global void execute(Database.BatchableContext bc, List<sObject> scope) {		            
        
        try{
            switch on sobjectName {
                when 'Account' {
                    List<Account> accList = (List<Account>) scope;
                    List<Account> accListToBeProcessed = new List<Account>();
                    Set<Id> accountIds = new Set<Id>();

                    for(Account acc :accList) {
                        if(accIdProgramIdSet.contains((String) acc.Core_MDF_CoMarketing_Ultimate_Account__c + acc.Core_MDF_Channel_Program__c)){
                            accListToBeProcessed.add(acc);
                            accountIds.add(acc.Id);
                        }
                    }
                    
                    
                    if(accListToBeProcessed != NULL && accListToBeProcessed.Size() > 0) {
                        createAccountShareRecords(accListToBeProcessed,accountIds);
                    }
                }
              
                when 'Campaign' {
                    List<Campaign> campaignList = (List<Campaign>) scope;
                    List<Campaign> campaignListToBeProcessed = new List<Campaign>();
                    Set<Id> campaignIds = new Set<Id>();
                    for(Campaign cmp :campaignList) {
                        if(accIdProgramIdSet.contains((String) cmp.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + cmp.Core_MDF_Channel_Program__c)) {
                            campaignListToBeProcessed.add(cmp);
                            campaignIds.add(cmp.Id);
                        }
                    }
                    
                    if(campaignListToBeProcessed != NULL && campaignListToBeProcessed.Size() > 0) {
                        campaignShare(campaignListToBeProcessed,campaignIds);
                    }
                }
    
                when 'PartnerFundRequest' {
                    List<PartnerFundRequest> pfrList = (List<PartnerFundRequest>) scope;
                    List<PartnerFundRequest> pfrListToBeProcessed = new List<PartnerFundRequest>();
                    Set<Id> pfrIds = new Set<Id>();
                    for(PartnerFundRequest pfr :pfrList) {
                        if(accIdProgramIdSet.contains((String) pfr.Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + pfr.ChannelPartner.Core_MDF_Channel_Program__c)) {
                            pfrListToBeProcessed.add(pfr);
                            pfrIds.add(pfr.Id);
                        }
                    }
                    
                    if(pfrListToBeProcessed != NULL && pfrListToBeProcessed.Size() > 0) {
                        pfrShare(pfrListToBeProcessed,pfrIds);
                    }
                }
    
                when 'PartnerFundClaim' {
                    List<PartnerFundClaim> pfcList = (List<PartnerFundClaim>) scope;
                    List<PartnerFundClaim> pfcListToBeProcessed = new List<PartnerFundClaim>();
                    Set<ID> claimIds = new Set<Id>();
                    for(PartnerFundClaim pfc :pfcList) {
                        if(accIdProgramIdSet.contains((String) pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + pfc.ChannelPartner.Core_MDF_Channel_Program__c)){
                            pfcListToBeProcessed.add(pfc);
                            claimIds.add(pfc.Id);
                        }
                    }
                    
                    if(pfcListToBeProcessed != NULL && pfcListToBeProcessed.Size() > 0) {
                        createClaimAndPaymentShareRecords(pfcListToBeProcessed,claimIds);
                    }
                }
                
                when 'Core_MDF_Audit_Document__c'{
                    
                    List<Core_MDF_Audit_Document__c> auditDocList = (List<Core_MDF_Audit_Document__c>) scope;
                    List<Core_MDF_Audit_Document__c> auditDocListToBeProcessed = new List<Core_MDF_Audit_Document__c>();
                    Set<Id> auditDocIds = new Set<Id>();
                    for(Core_MDF_Audit_Document__c auditDoc :auditDocList) {
                        if(accIdProgramIdSet.contains((String) auditDoc.Core_MDF_Claim__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + auditDoc.Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__c)){
                            auditDocListToBeProcessed.add(auditDoc);
                            auditDocIds.add(auditDoc.Id);
                        }
                    }
                    
                    if(auditDocListToBeProcessed != NULL && auditDocListToBeProcessed.Size() > 0) {
                        createAuditDocShareRecords(auditDocListToBeProcessed,auditDocIds);
                    }
                    
                }

                when 'Case' {
                    List<Case> caseList = (List<Case>) scope;
                    List<Case> caseListToBeProcessed = new List<Case>();
                    Set<Id> CaseId = new Set<ID>();
                    for(Case cs : caseList) {
                        if(accIdProgramIdSet.contains((String) cs.Account.Core_MDF_CoMarketing_Ultimate_Account__c + cs.Account.Core_MDF_Channel_Program__c)){
                            caseListToBeProcessed.add(cs);
                            CaseId.add(cs.Id);
                        }
                    }
                    
                    if(caseListToBeProcessed != NULL && caseListToBeProcessed.Size() > 0) {
                        caseShare(caseListToBeProcessed,CaseId);
                    }
                }
    
                when 'Core_MDF_Escalation__c' {
                    List<Core_MDF_Escalation__c> escalationList = (List<Core_MDF_Escalation__c>) scope;
                    List<Core_MDF_Escalation__c> esclnToBeProcessed = new List<Core_MDF_Escalation__c>();
                    Set<Id> escalationIds= new Set<Id>();
                    for(Core_MDF_Escalation__c escln :escalationList) {
                        if(escln.Core_MDF_Budget_ID_Number_id__c != NULL &&
                           (accIdProgramIdSet.contains((String) escln.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c + escln.Core_MDF_Channel_Program_id__c))){
                               esclnToBeProcessed.add(escln);
                               escalationIds.add(escln.Id);
                           }
                        else if(escln.Core_MDF_Case_ID_Number_id__c != NULL &&
                                (accIdProgramIdSet.contains((String) escln.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c + escln.Core_MDF_Channel_Program_id__c))){
                                    esclnToBeProcessed.add(escln);
                                    escalationIds.add(escln.Id);
                                }
                        else if(escln.Core_MDF_Co_Marketing_Activity_id__c != NULL &&
                                (accIdProgramIdSet.contains((String) escln.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + escln.Core_MDF_Channel_Program_id__c))){
                                    esclnToBeProcessed.add(escln);
                                    escalationIds.add(escln.Id);
                                    
                                }
                    }

                    if(esclnToBeProcessed != NULL && esclnToBeProcessed.Size() > 0) {
                        escalationShare(esclnToBeProcessed,escalationIds);
                    }
                }
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
    }

    /*****************************************************************************************************
       Method Name   :        createAccountShareRecords
       @return       :        void
       @parameters   :        List of Account
       Description   :        method to call the flow for Account Share
       Added By      :        Accenture - Mayuri - 06/10/2023
       Modified By   :        Date:             Changes:
     ******************************************************************************************************/
    public void createAccountShareRecords(List<Account> accList, Set<Id> accountIds)  {
         List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper> wrapper = new List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper>();
        try{     

                wrapper.add(Core_MDF_BulkAPI_Operations.deleteShareBulkRecords(accountIds,hostGeo,'AccountShare','AccountId'));
                List<Id> accountIdsList = new List<Id>();
                accountIdsList.addAll(accountIds);
                if(wrapper != null)
                {
                    Core_MDF_BulkAPI_Operations.insertAsyncBulkRecords(wrapper);
                }
                
                 Core_MDF_Account_Sharing.invokeAccountShareRecordToGeoGroup(accList);
            
        }catch(Exception e) { 
            Core_MDF_BulkAPI_Operations.insertAsyncBulkRecordsByPE(wrapper);
            Core_MDF_CCP_UtilityClass.logError(e);}
	}
    

    /*****************************************************************************************************
       Method Name   :        campaignShare
       @return       :        void
       @parameters   :        List of Campaigns
       Description   :        method to call batch for Campaign Share
       Added By      :        Accenture - Mayuri - 06/10/2023
       Modified By   :        Date:             Changes:
     ******************************************************************************************************/
    public void campaignShare(List<Campaign> campaignList, Set<Id> CampaignIds) {
        
        List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper> wrapper = new List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper>();
        
        try{
                wrapper.add(Core_MDF_BulkAPI_Operations.deleteShareBulkRecords(CampaignIds,hostGeo,'CampaignShare','CampaignId'));
               
                if(wrapper != null){
                    Core_MDF_BulkAPI_Operations.insertAsyncBulkRecords(wrapper);
                }
                
            if(campaignList != NULL && campaignList.Size() > 0){
                Core_MDF_ProcessCCP_Campaign.shareUnshareCampaign(campaignList, null, true, false);
            }
            
        }catch(Exception e) { 
           Core_MDF_BulkAPI_Operations.insertAsyncBulkRecordsByPE(wrapper);
           Core_MDF_CCP_UtilityClass.logError(e);}
    }

    /*****************************************************************************************************
       Method Name   :        pfrShare
       @return       :        void
       @parameters   :        List of PFR
       Description   :        method to call class for PFR Share
       Added By      :        Accenture - Mayuri - 06/10/2023
       Modified By   :        Date:             Changes:
     ******************************************************************************************************/
    public void pfrShare(List<PartnerFundRequest> pfrList, Set<Id> pfrIds) {
        List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper> wrapper = new List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper>();
        try{
   
                wrapper.add(Core_MDF_BulkAPI_Operations.deleteShareBulkRecords(pfrIds,hostGeo,'PartnerFundRequestShare','ParentId'));
                
                if(wrapper != null){
                Core_MDF_BulkAPI_Operations.insertAsyncBulkRecords(wrapper);
                }

            List<Id> pfrIdList = new List<Id>();
            for(PartnerFundRequest pFRRecord :pfrList) {
                pfrIdList.add(pFRRecord.Id);
            }
            if(pfrIdList.size() > 0) {
                Core_MDF_GeoBasedGenericSharing.createShareForPFR(pfrIdList);
            }
        }catch(Exception e) { 
            Core_MDF_BulkAPI_Operations.insertAsyncBulkRecordsByPE(wrapper);
             Core_MDF_CCP_UtilityClass.logError(e);}
	}

    /*****************************************************************************************************
       Method Name   :        createClaimAndPaymentShareRecords
       @return       :        void
       @parameters   :        List of Claims
       Description   :        method to call class for PFC & Payment Share
       Added By      :        Accenture - Mayuri - 06/10/2023
       Modified By   :        Date:             Changes:
     ******************************************************************************************************/
    public void createClaimAndPaymentShareRecords(List<PartnerFundClaim> pfcList, Set<Id> claimIds) {
        List<String> legacyPaidclmStsLst = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_PostPaid_Legacy_Claim_Statuses');
        List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper> wrapper = new List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper>();

        try{ 
               wrapper.add(Core_MDF_BulkAPI_Operations.deleteShareBulkRecords(claimIds,hostGeo,'PartnerFundClaimShare','ParentId'));

            Core_MDF_PFC_Sharing.shareClaimToInternalUsers(pfcList);

            if(wrapper != null)
            {
                Core_MDF_BulkAPI_Operations.insertAsyncBulkRecords(wrapper);
            }
           
        }catch(Exception e) { 
            Core_MDF_BulkAPI_Operations.insertAsyncBulkRecordsByPE(wrapper);
             Core_MDF_CCP_UtilityClass.logError(e);}
	}

    
    /*****************************************************************************************************
       Method Name   :        createAuditDocShareRecords
       @return       :        void
       @parameters   :        List of Audit Document
       Description   :        method to call class for Audit Document Share
       Added By      :        Accenture - Mayuri - 06/10/2023
       Modified By   :        Date:             Changes:
     ******************************************************************************************************/
    
    public void createAuditDocShareRecords(List<Core_MDF_Audit_Document__c> auditDocList, Set<Id> auditDocIds) {
        
        List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper> wrapper = new List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper>();
        
        try{   
                wrapper.add(Core_MDF_BulkAPI_Operations.deleteShareBulkRecords(auditDocIds,hostGeo,'Core_MDF_Audit_Document__Share','ParentId'));
                if(wrapper != null){
                Core_MDF_BulkAPI_Operations.insertAsyncBulkRecords(wrapper);
                }

           if(auditDocList.size() > 0) {
                Core_MDF_Audit_Document_Sharing.shareAuditDocToInternalUsers(auditDocList);
            }
        }catch(Exception e) { 
            Core_MDF_BulkAPI_Operations.insertAsyncBulkRecordsByPE(wrapper);
             Core_MDF_CCP_UtilityClass.logError(e);}
    }


    /*****************************************************************************************************
       Method Name   :        caseShare
       @return       :        void
       @parameters   :        List of Case
       Description   :        method to call class for Case Share
       Added By      :        Accenture - Mayuri - 06/10/2023
       Modified By   :        Date:             Changes:
     ******************************************************************************************************/
    public void caseShare(List<Case> caseList, Set<Id> CaseId) {
        List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper> wrapper = new List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper>();
        
        try{           
                wrapper.add(Core_MDF_BulkAPI_Operations.deleteShareBulkRecords(CaseId,hostGeo,'CaseShare','CaseId'));
                if(wrapper != null){
                Core_MDF_BulkAPI_Operations.insertAsyncBulkRecords(wrapper);
                }
            if(caseList.size() > 0) {
                Core_MDF_ClaimReviewCaseShare.claimReviewCaseShare(caseList);
            }
        }catch(Exception e) {  
            Core_MDF_BulkAPI_Operations.insertAsyncBulkRecordsByPE(wrapper);
            Core_MDF_CCP_UtilityClass.logError(e);
        }
	}
    

    /*****************************************************************************************************
       Method Name   :        escalationShare
       @return       :        void
       @parameters   :        List of Escalation
       Description   :        method to call class for Escalation Share
       Added By      :        Accenture - Mayuri - 06/10/2023
       Modified By   :        Date:             Changes:
     ******************************************************************************************************/
    public void escalationShare(List<Core_MDF_Escalation__c> escalationList, Set<Id> escalationIds) {
      
        List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper> wrapper = new List<Core_MDF_BulkAPI_Operations.AysncJobDetailWrapper>();
        try{ 
                wrapper.add(Core_MDF_BulkAPI_Operations.deleteShareBulkRecords(escalationIds,hostGeo,'Core_MDF_Escalation__Share','ParentId'));

                if(wrapper != null){
                Core_MDF_BulkAPI_Operations.insertAsyncBulkRecords(wrapper);
                }

            Map<Id, Core_MDF_Escalation__c> escalationMap = new Map<Id, Core_MDF_Escalation__c>();
    
            for(Core_MDF_Escalation__c escalation :escalationList) {
                escalationMap.put(escalation.Id, escalation);
            }
            if(escalationMap.size() > 0) {
                Core_MDF_Escalation_ServiceHandler.shareEscalation(escalationMap, null, true);
            }
        }catch(Exception e) { 
            Core_MDF_BulkAPI_Operations.insertAsyncBulkRecordsByPE(wrapper);
            Core_MDF_CCP_UtilityClass.logError(e);}
	}
    
	/*****************************************************************************************************
	   Method Name :   finish
	   @return     :   void
	   @parameters :   Database.BatchableContext
	   Description :
	   Added By    :   Accenture - Mayuri - 06/10/2023
	   Modified By :                               Date:                     Changes:None
	 ******************************************************************************************************/
	global void finish(Database.BatchableContext bc) {
		
	}    
}