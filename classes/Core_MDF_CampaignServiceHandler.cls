public without sharing class Core_MDF_CampaignServiceHandler {

    public static void determineProgram(Boolean isInsert,Boolean isUpdate, List<Campaign> newCampaignList, Map<Id,Campaign> oldCampaignMap, String context){
        
        List<String> ccpCampaignRecordTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Camp_Record_Type_Dev_Name').Split(';');
       	List<String> ipaCampaignRecordTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Campaign_Rcrd_Type_Dev_Name').Split(';');
        List<String> coGTMCampaignRecordTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NRE_RecordType').Split(';');
        
        List<Id> ccpCampaignRecordTypeIdList = new List<Id>();
        List<Id> ipaCampaignRecordTypeIdList = new List<Id>();
        
        List<String> allCampaignRecordTypeList = new List<String>();
        Set<Id> allCampaignRecTypeIdsList = new Set<Id>();
        allCampaignRecordTypeList.addAll(ccpCampaignRecordTypeList);
        allCampaignRecordTypeList.addAll(ipaCampaignRecordTypeList);
        allCampaignRecordTypeList.addAll(coGTMCampaignRecordTypeList);
        
        List<Campaign> ccpCampaignList = new List<Campaign>();
        List<Campaign> ipaCampaignList = new List<Campaign>();
        
        Map<Id,Campaign> ccpCampaignOldMap = new Map<Id,Campaign>();
        Map<Id,Campaign> ipaCampaignOldMap = new Map<Id,Campaign>();

        Map<Id,Campaign> ipaCampaignNewMap = new Map<Id,Campaign>();
        Map<Id,Campaign> ccpCampaignNewMap = new Map<Id,Campaign>();

        //Roshan - Proposal based trigger optimisation (will collect both ipa prop based and cogtm prop based)
        List<Campaign> proposalBasedCampaignList = new List<Campaign>(); 
        Map<Id,Campaign> proposalBasedCampaignOldMap = new Map<Id,Campaign>();
        Map<Id,Campaign> proposalBasedCampaignNewMap = new Map<Id,Campaign>();
        
        for(String recordTypeDevName : allCampaignRecordTypeList){
            Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
            allCampaignRecTypeIdsList.add(recordTypeId);
            if(ccpCampaignRecordTypeList.Contains(recordTypeDevName)){
                ccpCampaignRecordTypeIdList.add(recordTypeId);
            }else if(ipaCampaignRecordTypeList.Contains(recordTypeDevName)){
                ipaCampaignRecordTypeIdList.add(recordTypeId);
            }
        }
                
        for(Campaign cmp : newCampaignList){

            //Campaign trigger optimisation
            if(!allCampaignRecTypeIdsList.contains(cmp.RecordTypeId)) { continue; }  // Skipping non CCP campaign record types
            if(cmp.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name') && (context == 'beforeUpdate'  || context == 'beforeInsert')) {
                cmp.Core_MDF_Opal_Budget_Type_Txt__c = cmp.Core_MDF_Budget_Type_txt__c;  
            }

            if(cmp.Core_MDF_Proposal_Based_Ind__c) {
                if(ipaCampaignRecordTypeIdList.contains(cmp.RecordTypeId)) {
                    ipaCampaignList.add(cmp);
                }
                proposalBasedCampaignList.add(cmp);
                if(isUpdate) {
                    if(oldCampaignMap.containsKey(cmp.Id) && oldCampaignMap.get(cmp.Id) != NULL){ 
                        if(ipaCampaignRecordTypeIdList.contains(cmp.RecordTypeId)) {
                            ipaCampaignOldMap.put(cmp.Id,oldCampaignMap.get(cmp.Id));
                        }
                        proposalBasedCampaignOldMap.put(cmp.Id,oldCampaignMap.get(cmp.Id)); 
                    } 
                    proposalBasedCampaignNewMap.put(cmp.Id,cmp);
                }
            } else {
                ccpCampaignList.add(cmp);
                    if(isUpdate) {
                        if(oldCampaignMap.containsKey(cmp.Id) && oldCampaignMap.get(cmp.Id) != NULL){ 
                            ccpCampaignOldMap.put(cmp.Id,oldCampaignMap.get(cmp.Id));   
                        } 
                    ccpCampaignNewMap.put(cmp.Id,cmp);
                }
            }

            // if(ccpCampaignRecordTypeIdList.contains(cmp.RecordTypeId)){
            //     // Added to stored budget type value in opal budget type global multiselect picklist --US1036792: [KIIT]: Budget Type field consolidation at Campaign for RMF
            //    if(cmp.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name') && ( context == 'beforeUpdate'  || context == 'beforeInsert' )){
            //     cmp.Core_MDF_Opal_Budget_Type_Txt__c = cmp.Core_MDF_Budget_Type_txt__c;  
            //     }
            //      // Added to stored budget type value in opal budget type global multiselect picklist --US1036792: - end
            //     ccpCampaignList.add(cmp);
            //     if(isUpdate){
            //         if(oldCampaignMap.containsKey(cmp.Id) && oldCampaignMap.get(cmp.Id) != NULL){
            //             ccpCampaignOldMap.put(cmp.Id,oldCampaignMap.get(cmp.Id));
            //         }
            //         ccpCampaignNewMap.put(cmp.Id,cmp);
            //     }
            // }
            // //Differenciation of Account and Proposal Based
            // else if(ipaCampaignRecordTypeIdList.contains(cmp.RecordTypeId)){
            //     if(cmp.Core_MDF_Proposal_Based_Ind__c)
            //     {
            //         ipaCampaignList.add(cmp); 
            //         proposalBasedCampaignList.add(cmp);  //Roshan - Proposal based trigger optimisation
            //     }
            //     else{ccpCampaignList.add(cmp);}
                
            //     if(isUpdate){
            //         if(oldCampaignMap.containsKey(cmp.Id) && oldCampaignMap.get(cmp.Id) != NULL){ 
                    
            //             if(cmp.Core_MDF_Proposal_Based_Ind__c) {
            //                 ipaCampaignOldMap.put(cmp.Id,oldCampaignMap.get(cmp.Id));
            //                 proposalBasedCampaignOldMap.put(cmp.Id,oldCampaignMap.get(cmp.Id));  //Roshan - Proposal based trigger optimisation
            //         }
            //             else{ ccpCampaignOldMap.put(cmp.Id,oldCampaignMap.get(cmp.Id));}
            //         }
            //         if(cmp.Core_MDF_Proposal_Based_Ind__c){
            //             ipaCampaignNewMap.put(cmp.Id,cmp);
            //             proposalBasedCampaignNewMap.put(cmp.Id,cmp);  //Roshan - Proposal based trigger optimisation
            //         }
            //         else{ccpCampaignNewMap.put(cmp.Id,cmp);}
                     
            //     }
            // }
            
            // //Roshan - Co-GTM campaign setup - added proposal based check
            // else if (coGTMCampaignRecordTypeIdList.contains(cmp.RecordTypeId)) {
            //     if (cmp.Core_MDF_Proposal_Based_Ind__c) {
            //         coGTMCampaignList.add(cmp); 
            //         proposalBasedCampaignList.add(cmp);  //Roshan - Proposal based trigger optimisation
            //     }
            //     if (isUpdate) {
            //         if (oldCampaignMap.containsKey(cmp.Id) && oldCampaignMap.get(cmp.Id) != NULL) { 
            //             if (cmp.Core_MDF_Proposal_Based_Ind__c) {
            //                 coGTMCampaignOldMap.put(cmp.Id, oldCampaignMap.get(cmp.Id));
            //                 proposalBasedCampaignOldMap.put(cmp.Id,oldCampaignMap.get(cmp.Id));  //Roshan - Proposal based trigger optimisation
            //             }
            //         }
            //         if (cmp.Core_MDF_Proposal_Based_Ind__c) {
            //             coGTMCampaignNewMap.put(cmp.Id, cmp);
            //             proposalBasedCampaignNewMap.put(cmp.Id,cmp);  //Roshan - Proposal based trigger optimisation
            //         }
            //     }
            // }
        }
        
        if(context == 'beforeInsert') {
            if(ccpCampaignList != NULL && ccpCampaignList.Size() > 0){
                Core_MDF_ProcessCCP_Campaign.determineCampaignAttributes(ccpCampaignList, ccpCampaignOldMap, isInsert, isUpdate);               
            }
            if (proposalBasedCampaignList != NULL && proposalBasedCampaignList.Size() > 0) {                 
                Core_MDF_Proposal_Based_Campaign_Process.processPropBasedCampaignsBeforeInsertUpdate(proposalBasedCampaignList, proposalBasedCampaignOldMap, isInsert, isUpdate);
            }
        }

        if(context == 'beforeUpdate') {
            if(ccpCampaignList != NULL && ccpCampaignList.Size() > 0){
                Core_MDF_ProcessCCP_Campaign.determineCampaignAttributes(ccpCampaignList, ccpCampaignOldMap, isInsert, isUpdate);   
            }
	        if (proposalBasedCampaignList != NULL && proposalBasedCampaignList.Size() > 0) {                  
                Core_MDF_Proposal_Based_Campaign_Process.processPropBasedCampaignsBeforeInsertUpdate(proposalBasedCampaignList, proposalBasedCampaignOldMap, isInsert, isUpdate);
            }
            if(ipaCampaignList != NULL && ipaCampaignList.Size() > 0){  
                Core_MDF_Proposal_Based_Campaign_Process.validateSingleGeoOnCampaign(ipaCampaignList);
            } 
        }
        
        if(context == 'afterInsert'){
            if(ccpCampaignList != NULL && ccpCampaignList.Size() > 0){
                Core_MDF_ProcessCCP_Campaign.shareUnshareCampaign(ccpCampaignList, ccpCampaignOldMap, isInsert, isUpdate);
                Core_MDF_ProcessCamp_RelatedRecords.insertUpdateCategoryOrRegionRecords(ccpCampaignList, ccpCampaignOldMap, isInsert, isUpdate);
            }
            if (proposalBasedCampaignList != NULL && proposalBasedCampaignList.Size() > 0) {                 
                Core_MDF_ProcessCCP_Campaign.shareUnshareCampaign(proposalBasedCampaignList, proposalBasedCampaignOldMap, isInsert, isUpdate);
            }
        }
        
        if(context == 'afterUpdate'){
            if(ccpCampaignList != NULL && ccpCampaignList.Size() > 0){
                Core_MDF_ProcessCCP_Campaign.shareUnshareCampaign(ccpCampaignList, ccpCampaignOldMap, isInsert, isUpdate); 
                Core_MDF_ProcessCamp_RelatedRecords.insertUpdateCategoryOrRegionRecords(ccpCampaignList, ccpCampaignOldMap, isInsert, isUpdate);
                Core_MDF_ProcessCCP_Campaign.updateRelatedRecords(ccpCampaignNewMap,ccpCampaignOldMap);
            }
            if (proposalBasedCampaignNewMap != NULL && proposalBasedCampaignNewMap.Size() > 0) {               
                Core_MDF_Proposal_Based_Campaign_Process.processPropBasedCamapignsAfterUpdate(proposalBasedCampaignNewMap, proposalBasedCampaignOldMap);
            }
	        if (proposalBasedCampaignList != NULL && proposalBasedCampaignList.Size() > 0) {
                Core_MDF_ProcessCCP_Campaign.shareUnshareCampaign(proposalBasedCampaignList, proposalBasedCampaignOldMap, isInsert, isUpdate);
            }
            if(ipaCampaignList != NULL && ipaCampaignList.Size() > 0){
                Core_MDF_Proposal_Based_Campaign_Process.budgetCapConsumption(ipaCampaignOldMap, ipaCampaignList);
            }
        }

        if (context == 'beforeDelete') {
            if (ccpCampaignList != NULL && !ccpCampaignList.isEmpty()) {
                Core_MDF_ProcessCCP_Campaign.blockCampaignDeletion(ccpCampaignList);
            }
            if (proposalBasedCampaignList != NULL && !proposalBasedCampaignList.isEmpty()) {
                Core_MDF_ProcessCCP_Campaign.blockCampaignDeletion(proposalBasedCampaignList);
            }
        }
    }
    
     //US1048034-[IPA MDF] - Notifications- Show comments in notifications
   /****************************************************************************************************************************************
    * Method Name           : updateIpaL1ApproverComments
    * Created Date          : 20-8-2021
    * @return               : void
    * @parameters           : List of all the Campaign Records 
    * Modification Log
    * Developer             Date                Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
      Accenture-Karan       20-8-2021           US1048034-[IPA MDF] - Notifications- Show comments in notifications
    *****************************************************************************************************************************************/
    @InvocableMethod
    public static void updateIpaL1ApproverComments(list<Campaign> cmp) {
        
        //String Comment='';
        Map<Id,Id> campIdProcessInstId = new Map<Id,Id>();
        Set<Id> campIdSet = new Set<Id>();
        Map<Id,List<ProcessInstanceStep>> piAndListofPiStepMap = new Map<Id,List<ProcessInstanceStep>>();
        List<Campaign> toUpdateCampRecList = new List<Campaign>();
        //Boolean hasL1ProposalApproverPS  = FeatureManagement.checkPermission('Core_MDF_CCP_Int_IPA_ProposalL1_Approver');
        try{  
            
            for(Campaign camp : cmp){
                campIdSet.add(camp.Id);
            }         
            
            for(ProcessInstance pi : [SELECT Id,TargetObjectId,(SELECT Id, StepStatus, Comments FROM Steps WHERE StepStatus = 'Approved' order by CreatedDate asc LIMIT 1),(SELECT Id, StepStatus, Comments FROM StepsAndWorkitems) FROM ProcessInstance 
                                      WHERE TargetObjectId IN :campIdSet AND Status ='Pending']){
                                          campIdProcessInstId.put(pi.TargetObjectId, pi.Id);
                                          piAndListofPiStepMap.put(pi.Id,pi.Steps);
                                          
                                      }
            
            if(piAndListofPiStepMap != null && piAndListofPiStepMap.size() > 0){
                for(Campaign c :cmp ){
                    Campaign newCmp = new Campaign();
                    newCmp.Id = c.Id;
                    if(campIdProcessInstId.containsKey(c.Id) && campIdProcessInstId.get(c.Id) != NULL){
                        Id processInstanceId = campIdProcessInstId.get(c.Id);
                        if(piAndListofPiStepMap.containsKey(processInstanceId) && piAndListofPiStepMap.get(processInstanceId) != NULL){
                            for(ProcessInstanceStep pistep: piAndListofPiStepMap.get(processInstanceId)){
                                if(pistep.StepStatus == 'Approved'){
                                    newCmp.Core_MDF_Comments_Appvr_Only_txt__c = pistep.Comments;
                                    toUpdateCampRecList.add(newCmp);
                                    
                                }  
                            }
                        }
                    }
                }
              //  update toUpdateCampRecList;
            }
          //  Core_MDF_IPA_Campaign_Functionality.notifyExternalReviewers(cmp);
            
        }catch(Exception e){}
    }
    
}