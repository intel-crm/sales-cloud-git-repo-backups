/****************************************************************************************************** 
Class Name:         Core_MDF_UpdateActivityFields
@parameters:        N/A
Description:        Before Insert/Upadte call these functions and update the activity to be closed date
Added By:           Sridhar   06-17-2019
Modified By:        Date:           Changes:
Shivaprasad         08-29-2019      Added the condition to check closed status of PFR records in populateBackEndFieldsUpdate method.
*******************************************************************************************************/
public without sharing class Core_MDF_UpdateActivityFields_HemaPriya  {
    
    @Invocablemethod(label='Get PFR records updated to Revision Required' category='PartnerFundRequest')
    public static void getActivityRejectionComments(List<flowInputs> inputIdList){
        Set<Id> pfrIDSet = new Set<Id>();
        Set<Id> acctIdSet = new Set<Id>();
        Map<Id,String> pfrIdCommentsMap = new Map<Id,String>();
        Map<Id,String> pfrIdmemberIdMap = new Map<ID,String>();
        List<PartnerFundRequest> ipaPFRList = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        Map<Id,List<ProcessInstanceStep>> piAndListofPiStepMap = new Map<Id,List<ProcessInstanceStep>>();
        Map<Id,Id> pfrIdProcessInstId = new Map<Id,Id>();
        Set<Id> stepNodeIdSet = new Set<Id>();
        Map<Id,String> stepNodeIdStepNameMap = new Map<Id,String>();
        Map<Id,List<String>> actorIDPermSetMap = new map<Id,List<String>>();
        List<Id> processDefList = new List<id>();
        Boolean priceReviewerFlag = FeatureManagement.checkPermission('Core_MDF_PriceReviewer');
        try{
            for(flowInputs pfr : inputIdList){
                pfrIDSet.add(pfr.pfrId);
                if(pfr.program == 'Intel Partner Alliance' && pfr.proposalBasedIndicator == false && pfr.createdByExternal == true && pfr.pfrStatus == 'Revision Required'){
                    pfrIdmemberIdMap.put(pfr.pfrId,pfr.createdById);    
                }
                else{
                    if(pfr.memberId != null && pfr.memberId !=''){
                    pfrIdmemberIdMap.put(pfr.pfrId,pfr.memberId);
                    }
                }
            }
            /*for(ProcessInstance pi : [SELECT Id,TargetObjectId, Status, ProcessDefinitionId, (SELECT Id, StepStatus, Comments, ActorId, StepNodeId FROM Steps WHERE StepStatus = 'Rejected' Order By CreatedDate ASC Limit 1) FROM ProcessInstance 
                                      WHERE TargetObjectId IN :pfrIDSet order by createdDate desc limit 1]){
                                          pfrIdProcessInstId.put(pi.TargetObjectId, pi.Id);
                                          piAndListofPiStepMap.put(pi.Id,pi.Steps);
                                          processDefList.add(pi.ProcessDefinitionId);
                                      }*/
            
            for(ProcessInstance pi : [SELECT Id,TargetObjectId, Status, ProcessDefinitionId, (SELECT Id, StepStatus, Comments, ActorId, StepNodeId FROM Steps WHERE StepStatus = 'Rejected' Order By CreatedDate ASC Limit 1) FROM ProcessInstance 
                                      WHERE TargetObjectId IN :pfrIDSet order by createdDate desc]){
                                          if(!pfrIdProcessInstId.containsKey(pi.TargetObjectId)){
                                              pfrIdProcessInstId.put(pi.TargetObjectId, pi.Id);  
                                          }
                                          piAndListofPiStepMap.put(pi.Id,pi.Steps);
                                          processDefList.add(pi.ProcessDefinitionId);
                                      }
            
            if(processDefList != null && processDefList.size() > 0){
                for(ProcessNode pn : [Select Id,Name, ProcessDefinition.Description From ProcessNode Where ProcessDefinition.Id IN :processDefList]){
                    stepNodeIdStepNameMap.put(pn.Id, pn.Name);
                }
            }
            if(piAndListofPiStepMap != null && piAndListofPiStepMap.size() > 0){
                for(Id pfr : pfrIDSet){
                    PartnerFundRequest p = new PartnerFundRequest();
                    p.Id = pfr;
                    if(pfrIdProcessInstId.containsKey(p.Id) && pfrIdProcessInstId.get(p.Id) != NULL){
                        Id processInstanceId = pfrIdProcessInstId.get(p.Id);
                        if(piAndListofPiStepMap.containsKey(processInstanceId) && piAndListofPiStepMap.get(processInstanceId) != NULL){
                            for(ProcessInstanceStep pistep: piAndListofPiStepMap.get(processInstanceId)){
                                if(pistep.StepStatus == 'Rejected'){
                                    if(stepNodeIdStepNameMap.get(pistep.StepNodeId) != 'Price Reviewer'){
                                        p.Core_MDF_Rejection_Comments_txt__c = pistep.Comments != null ? pistep.Comments : '';
                                    }else if(priceReviewerFlag && stepNodeIdStepNameMap.get(pistep.StepNodeId) == 'Price Reviewer'){
                                        p.Core_MDF_Rejection_Comments_txt__c=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PCTApprover_GenericComment'); }
                                    else if( !priceReviewerFlag && stepNodeIdStepNameMap.get(pistep.StepNodeId) == 'Price Reviewer'){
                                        p.Core_MDF_Rejection_Comments_txt__c = pistep.Comments;
                                    }
                                    pfrList.add(p);
                                }  
                            }
                        }
                    }
                }
            }
            List<PartnerFundRequest> activityList = [Select Id,ChannelPartnerId,Core_MDF_Approval_Step_Completed__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Program__c,Core_MDF_Internal_Approval_Comment_txt__c,Core_MDF_Proposal_Based_Ind__c
                                                     FROM PartnerFundRequest 
                                                     WHERE Id IN:pfrIDSet];
            if(activityList!= null && activityList.size()>0){
                for(PartnerFundRequest pfr1 : activityList){
                    acctIdSet.add(pfr1.ChannelPartnerId);
                    if(pfr1.Core_MDF_Program__c =='Intel Partner Alliance' && pfr1.Core_MDF_Proposal_Based_Ind__c == false && pfr1.Core_MDF_Fund_Request_Status__c =='Pending Approval'){
                        ipaPFRList.add(pfr1);
                    }
                }
            }
            Database.update(pfrList,false);
            if(ipaPFRList != null){
                Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(ipaPFRList,acctIdSet);
            }
            
            notifyExternalUsers(pfrIdmemberIdMap);             
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    public static void notifyExternalUsers(Map<Id,Id> activityIdmemberIdMap){
        try{
            
            Id extUser;
            List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
            for(Id pfrId : activityIdmemberIdMap.keySet()){
                List<Id> extUserList = new List<Id>();    
                System.debug('pfrId'+pfrId);
                
                extUser = activityIdmemberIdMap.get(pfrId);
                extUserList.add(extUser);
                System.debug('extUserList'+extUser);
                Core_MDF_GenericClassToSendMail.MailParams sendEmailToExt = new Core_MDF_GenericClassToSendMail.MailParams();
                sendEmailToExt.recordId = pfrId;
                System.debug('Core_MDF_NotifyRejectionComments_ExtUser'+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NotifyRejectionComments_ExtUser'));
                sendEmailToExt.templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NotifyRejectionComments_ExtUser');
                sendEmailToExt.userIdList = extUserList;
                sendEmailToExt.sendDiff = false;
                inputList.add(sendEmailToExt);
            }
            if(inputList != NULL && inputList.size() >0){
                Core_MDF_GenericClassToSendMail.sendEmailMethod(inputList);
            }
            
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    public class flowInputs{
        @InvocableVariable(label='PartnerFundRequest Id')
        public Id pfrId;
        
        @InvocableVariable(label='Member Activity Owner Id of PFR')
        public String memberId;
        
        @InvocableVariable(label='Program of PFR')
        public String program;
        
        @InvocableVariable
        public Boolean proposalBasedIndicator;
        
        @InvocableVariable
        public Boolean createdByExternal;
        
        @InvocableVariable
        public String createdById;
        
        @InvocableVariable
        public String pfrStatus;
    }
    
} 
    //public static Boolean emailSendOnce = true;
    //public static Map<Id, PartnerFundRequest> oldStaticPFRMap = new Map<Id, PartnerFundRequest>();
    //public static Map<Id,String> accIdRegionMap = new Map<Id,String>();
    //public static Id channelMDFRecordType = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get(Label.Core_MDF_Channel_MDF).getRecordTypeId();
    //public static Id IPARecordType = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get(Label.Core_MDF_IPA_RecordType).getRecordTypeId();

    //public static Boolean stopStatusUpdate = false;
    /****************************************************************************************************** 
    Method Name:        populateBackEndFieldsUpdate
    @return  :          void
    @parameters:        PFR Map
    Description:        This method is used to update the to be closed date before update trigger
    Added By:           Sridhar - 06/17/2019
    Modified By:        Date:         Changes: 
    Shivaprasad         08-29-2019    Added the condition to check closed status of PFR records.
    *******************************************************************************************************/
    
    /*public static void populateBackEndFieldsUpdate(Map<Id,PartnerFundRequest> newMap, Map<Id,PartnerFundRequest> oldMap)
    {
        try
        {
            if(oldMap != NULL && oldMap.size() > 0){
                oldStaticPFRMap = oldMap;
            }
            if(oldStaticPFRMap != null && !oldStaticPFRMap.isEmpty()){
                system.debug('oldMap>>update>'+oldMap);
                   system.debug('oldMap>>update111>'+oldStaticPFRMap);
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            List<PartnerFundRequest> budgetCurrencyExchangeRatePFRList = new List<PartnerFundRequest>();
            for(PartnerFundRequest pfr: newMap.values()){
                    pfrList.add(pfr);
            }
            if (pfrList != NULL && pfrList.size() > 0)
            {
                processPFRRecords(pfrList,oldMap);
            }
		  }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }*/

    /****************************************************************************************************** 
    Method Name:        populateBackEndFieldsInsert
    @return  :          void
    @parameters:        PFR Map
    Description:        This method is used to update the to be closed date in before insert
    Added By:           Sridhar - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    /*public static void populateBackEndFieldsInsert(List<PartnerFundRequest> newList)
    {
        try
        {
            if (newList != NULL && newList.size() > 0)
            {
                System.debug('Inside 1');
                //close activity & activity event rules method call
                processPFRRecords(newList,NULL);
                
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }*/
   
    
    /****************************************************************************************************** 
    Method Name:        processPFRRecords
    @return  :          void
    @parameters:        list of PFR
    Description:        proess all the records and update the to be closed date and event activity validation
    Added By:           Sridhar - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    
    /*public static void processPFRRecords(List<PartnerFundRequest> pfrList, Map<Id,PartnerFundRequest> oldPfrMap)
    {
      
        try{
            system.debug('oldPfrMap--->'+oldPfrMap);
            Core_MDF_PartnerFundRequest_Utility.ClaimActAllocRecTypeMappingWrapper claimActAllocRecTypeMapWrapInstance = Core_MDF_PartnerFundRequest_Utility.getMetaDataValues();
            
            // Mapping Of RecordType and associated close date
            Map<string,Integer> metadtMap = new Map<string,Integer>();
            metadtMap = claimActAllocRecTypeMapWrapInstance.activityRecordTypeCloseDateMap;
            
            // Program and Required Geo Map
            Map<String, List<String>> programGeoReqMap = new Map<String,List<String>>();
            programGeoReqMap = claimActAllocRecTypeMapWrapInstance.activityRecordTypeGeoListMap;
                
            // RecordTypeId and RecordType DeveloperName Map 
            Map<Id,string> ccpRecordTypeIds = new Map<Id,string>();
            ccpRecordTypeIds = Core_MDF_PartnerFundRequest_Utility.getCCPRTNames(metadtMap);
            system.debug('hemaRec'+ccpRecordTypeIds);
            
            //hasCustomPermission is Boolean type contains whether the Internal Account Manager custom permission is present or not
            Boolean hasCustomPermission = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Custom_Permission_IAM'));
            //Retail 14 day validation
            Boolean hasRetailCustomPermission = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Custom_Permission_IAM_Retail'));
            Boolean hasGeoApproverCustomPermission = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Geo_Lead_Custom_Perm'));
           // List<String> atfPermsets = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ATF_Acct_Mgr_Perm_Set').Split(';'));
            //loop meta data and form Map --> Record type id, list of metadata //Record type restrict
            
            Map<String,List<Core_MDF_PFR_Event_Rule__mdt>> pfrRecordTypeEventMetadataMap = new Map<String,List<Core_MDF_PFR_Event_Rule__mdt>>();
            pfrRecordTypeEventMetadataMap = Core_MDF_PartnerFundRequest_Utility.getPfrEventRulesMetadata();
            // Attributes Map metadata
            Map<String,List<CCP_Attributes_Map__mdt>> pfrRecordTypeAttributeMetadataMap = new Map<String,List<CCP_Attributes_Map__mdt>>();
            pfrRecordTypeAttributeMetadataMap = Core_MDF_PartnerFundRequest_Utility.getCCPAttributeMapMetadata();

            // Auto closure Maps for Retail to get from submission winodw meta data
            Map<String,Date> quarterEndRsltMap = new Map<String,Date>();
             Map<String, Date> closeDateExtensionMap = new Map<String, Date>();
            // Country Geo Map
            Map<String , String> countryGeoMap = new Map <String , String>();
            Map<String , String> countrySubGeoMap = new Map <String , String>();

      Set<Id> campaignIds = new Set<Id>();
      Set<Id> CMDFcampaignIds = new Set<Id>();
              Map<String, Date> quarterEndDateMap = new Map<String, Date>();
            //List of SPIF Activity Types
            List<String> spifActivityTypesList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPIF_Activity_Types').Split(';');
            List<String> otherActivityTypesList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Other_Activity_Types').Split(';');
      Map<Id,Id> pfrIdAccIdMap = new Map<Id,Id>();    
            
            //US964831
            Boolean ccfFieldOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Field_Owner'));
            Boolean dcfFieldOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Field_Owner'));
            Boolean ccfMarketingOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Marketing_Owner'));
            Boolean dcfMarketingOwner = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Marketing_Owner'));
            Boolean geoApprover = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver');
        Boolean retailAccMgrPS = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_RMF_Account_Manager'); 
            Boolean ipaL1ApproverPS = FeatureManagement.checkPermission('Core_MDF_CCP_Int_IPA_ProposalL1_Approver');  
            String atfClosedStatus = System.Label.Core_MDF_ATF_Closed_Status;
            //AFT
        //TWC702-760
            List<PartnerFundRequest> pendingApprovalPfrList = new List<PartnerFundRequest>();
            List<PartnerFundRequest> externalPendingApprovalPfrList = new List<PartnerFundRequest>();
           
            Set<Id> accIdSet = new Set<Id>();
            
            Map<Id,Id> crtdByIdPfrIdMap = new Map<Id,Id>();
            Map<Id,Id> pfrIdMgrIdMap = new Map<Id,Id>();
            Set<Id> userIdSet = new Set<Id>(); 
            Map<Id,Id> userIdManagerMap = new Map<Id,Id>();
            if(oldPfrMap == NULL){
                for(partnerFundRequest pfr1 : pfrList)
                {
                    if(pfr1.RecordTypeId == channelMDFRecordType && (pfr1.Core_MDF_Proposal_Based_Ind__c  == false))
                    {
                        pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
                    }
                }
            }
            
            //Setting bypass flag for bypassing ATF Flag Stamp for manual edit/batch process
            Boolean bypassFlag = false;
                Boolean bypassFlagBatch = Core_MDF_Utility.byPassFeature('Core_MDF_EnableATFFlagUpdateBatch');
                Boolean bypassFlagATFUpdate=Core_MDF_Utility.byPassFeature('Core_MDF_BypassATFFlagUpdate');
                if(!bypassFlagBatch && bypassFlagATFUpdate){
                	bypassFlag = true;
                }
                else if(!System.isBatch() && bypassFlagATFUpdate)
                {
                    bypassFlag = true;
                }
                else if(System.isBatch() && !bypassFlagBatch)
                {
                    bypassFlag = true;
                }
                else
                {
                    bypassFlag = false;
                }
            
           
            
            for(partnerFundRequest pfr1 : pfrList){
                if(pfr1.RecordTypeId == channelMDFRecordType|| pfr1.RecordTypeID == IPARecordType){
                       CMDFcampaignIds.add(pfr1.CampaignId); 
                    }
            }
            
            //Owner Id - pfrId & MAp
            //Query - pfrId & MngMap
            //assign - fetch & assign
            
            List<Core_MDF_CCP_Country_Geo_Mapping__mdt> countryGeoMetaDataList = Core_MDF_CCP_Country_Geo_Mapping__mdt.getAll().values();
            
            List<Campaign> CMDFCampList = [Select id,Core_MDF_Approval_Stage_nm__c,Status,Core_MDF_Proposal_Based_Ind__c from Campaign where id in : CMDFcampaignIds ];
            
            
            Boolean isPropBasedCamp = false;         
           
            for (Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMetaData : countryGeoMetaDataList){
                countryGeoMap.put(countryGeoMetaData.MasterLabel , countryGeoMetaData.Core_MDF_Geo__c );
                countrySubGeoMap.put(countryGeoMetaData.MasterLabel, countryGeoMetaData.Core_MDF_Sub_Geo__c);
            }
            Set<Id> ipaL1ApprovercmpId =  new Set<Id>();
            for(Campaign camp : CMDFCampList){
                
                if(camp.Core_MDF_Proposal_Based_Ind__c == true){
                    isPropBasedCamp = true;
                }
               // Added for cancelling activity when L1 Approver provides 0 in budget amount for IPA proposal flow
               if(camp.Core_MDF_Program__c == 'Intel Partner Alliance' && camp.Core_MDF_Proposal_Based_Ind__c == true && (camp.Core_MDF_Approval_Stage_nm__c == 'L1 Approval' || ipaL1ApproverPS)){
                   ipaL1ApprovercmpId.add(camp.Id);
                    }  
             }
        
            if(pfrList != NULL && pfrList.size() > 0 ){
                    for(PartnerFundRequest pfr: pfrList){
                        
                        System.debug('pfr status-->'+pfr.Core_MDF_Fund_Request_Status__c);
                        
                        if(!bypassFlag) //Calling ATF code
                    	{
							setATFFlag(pfr,oldPfrMap);                 
                    	}
                        if(geoApprover){
                            crtdByIdPfrIdMap.put(pfr.CreatedById,pfr.Id);
                        }
                        /* DE114779 - WW18 | QA3 | Approval notifications are triggering in localized language for Internal users - start*/
                        /*String emailBody ='Activity Type: '+ pfr.Core_MDF_Activity_Types__c +'\n\n';
                        emailBody +='      Status History: '+ pfr.Core_MDF_Fund_Request_Status__c +'\n\n';
                        emailBody +='      Countries/Locations: '+ pfr.Core_MDF_Country_nm__c +'\n';
                        pfr.Core_MDF_Email_body_Field_Values_txt__c = emailBody;
            /* DE114779 - WW18 | QA3 | Approval notifications are triggering in localized language for Internal users - end*/
            //For RR
           /* if(String.isNotBlank(pfr.CampaignId)){
                            campaignIds.add(pfr.CampaignId);
                        }          
            //1. Based on US846955-US849167, preparing map of Retail activity Id and its acc Id- used as filter on Account query
            if(Label.Core_MDF_Retail_Program.equalsIgnoreCase(ccpRecordTypeIds.get(pfr.RecordTypeId))) {
                pfrIdAccIdMap.put(pfr.Id, pfr.ChannelPartnerId);
            }
                      Set<String> geoSet = new Set<String>();
                        Set<String> subGeoSet = new Set<String>();
                        //String geoStr = '';
                        if(pfr.Core_MDF_Country_nm__c != NULL){ 
            
              
                        List<String> splitCountry = pfr.Core_MDF_Country_nm__c.split(';');
                          for(String Country : splitCountry){
                                    if(countryGeoMap.containsKey(Country)){
                                        if(countrySubGeoMap.containsKey(Country)){
                                            subGeoSet.add(countrySubGeoMap.get(Country));
                                        }
                                        geoSet.add(countryGeoMap.get(Country));
                                        
                                    }                                
                                }
                            
                           if(pfr.Core_MDF_Program__c !='Intel Partner Alliance' && !isPropBasedCamp)
                                
                           {
                                
                                if(geoSet != NULL && geoSet.size() > 1 ){
                                    pfr.addError(Label.Core_MDF_Country_Multiple_Geo_Error);
                                    break;
                                }else if(subGeoSet != NULL && subGeoSet.size() > 1 && 
                                (programGeoReqMap != NULL && programGeoReqMap.size() > 0 && 
                                programGeoReqMap.containsKey(ccpRecordTypeIds.get(pfr.RecordTypeId)) &&
                                programGeoReqMap.get(ccpRecordTypeIds.get(pfr.RecordTypeId)).contains(new List<String>(geoSet)[0]))){
                                    pfr.addError(Label.Core_MDF_Country_Multiple_SubGeo_Error);
                                    break;
                                }else{
                                    List<String> geoSetList = new List<String>();                                
                                    geoSetList.addAll(geoSet);
                                    //US1098882
                                    pfr.Core_MDF_Region_cd__c =  geoSetList[0];
                                    pfr.Core_MDF_Region_nm__c =  geoSetList[0];
                                    if(programGeoReqMap != NULL && programGeoReqMap.size() > 0 && ccpRecordTypeIds.containsKey(pfr.RecordTypeId) && 
                                    programGeoReqMap.containsKey(ccpRecordTypeIds.get(pfr.RecordTypeId))){
                                        List<String> geoProgramList = programGeoReqMap.get(ccpRecordTypeIds.get(pfr.RecordTypeId));
                                        if(geoProgramList != NULL && geoProgramList.contains(geoSetList[0])){
                                            List<String> subGeoSetList = New List<String>();
                                            subGeoSetList.addAll(subGeoSet);
                                            //US1098882
                                            pfr.Core_MDF_Sub_Region_cd__c = subGeoSetList[0];
                                            pfr.Core_MDF_Sub_Region_nm__c = subGeoSetList[0];
                                        }
                                        else{
                                            //US1098882
                                            pfr.Core_MDF_Sub_Region_cd__c = NULL;
                                            pfr.Core_MDF_Sub_Region_nm__c = NULL;
                                        }
                                    }
                                    else{
                                        //US1098882
                                        pfr.Core_MDF_Sub_Region_cd__c = NULL;
                                        pfr.Core_MDF_Sub_Region_nm__c = NULL;
                                    }
                                    
                                }
                               }
                            else  if(pfr.Core_MDF_Program__c =='Intel Partner Alliance' || (pfr.Core_MDF_Program__c =='Channel MDF' && pfr.Core_MDF_Proposal_Based_Ind__c == true)){
                                
                                List<String> geoSetList = new List<String>();
                                List<String> geoSubSetList = new List<String>();
                                geoSetList.addAll(geoSet);
                                geoSubSetList.addAll(subGeoSet);
                                
                               
                               
                                String region='';
                                String subRegion='';
                               
                                
                                
                                for(String geoSub : geoSubSetList){
                                    if((geoSub.equals('LAR') || geoSub.equals('NAR'))){
                                        subRegion += geoSub+';';
                                       
                                    }
                                    
                                }
                                
                                for(String geo : geoSetList){
                                    region += geo+';';
                                   
                                }
                                
                                pfr.Core_MDF_Region_nm__c = region;
                                pfr.Core_MDF_Sub_Region_nm__c = subRegion;
                                
                               
                                    
                            }
    }
    }
        //2. Based on US846955-US849167,fetching Geo of Ultimate Acc
        if(pfrIdAccIdMap != null && !pfrIdAccIdMap.isEmpty()){
           Set<Id> retailAccIdSet = new Set<Id>();
           retailAccIdSet.addAll(pfrIdAccIdMap.values());
           for(Account accObj : [SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c, Core_MDF_CoMarketing_Ultimate_Account__r.Core_Account_Country__c 
                                 FROM Account WHERE Id IN :retailAccIdSet]) {
            accIdRegionMap.put(accObj.Id, accObj.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c);
           }
        }

        if(campaignIds != NULL && !campaignIds.isEmpty()){
          populateRR(pfrList, campaignIds);
        }   
                
                 for(PartnerFundRequest pfr: pfrList){
                String progName = ccpRecordTypeIds.get(pfr.recordTypeId);
                    String key = '';
                    key = buildKeyForActivityClosure(pfr, progName);
                    if (!String.isEmpty(key)){
                        quarterEndDateMap.put(key, null);
                    }
            }
        // Get activity closure date for retail
              
                  if(quarterEndDateMap != null && !quarterEndDateMap.isEmpty()){
                    quarterEndRsltMap = getActivitySubDueDate(quarterEndDateMap);
                    System.debug('INSIDE quarterEndRsltMap:: '+quarterEndRsltMap);
                }
                 if(quarterEndDateMap != null && !quarterEndDateMap.isEmpty()){
                    closeDateExtensionMap = getActClosureExtensionDate(quarterEndDateMap);
                    System.debug('INSIDE closeDateExtensionMap:: '+closeDateExtensionMap);
                }
                
                //Get the Qtr start and end dates based on PFR date
                Map<Id,List<Date>> pfrDateMap = new Map<Id,List<Date>>();
                pfrDateMap = getQtrStartAndEndDates(pfrList,ccpRecordTypeIds); 
                
                if(geoApprover && crtdByIdPfrIdMap != null && crtdByIdPfrIdMap.size()>0){
                    for(User usr: [Select Id, ManagerId 
                                   FROM User 
                                   Where Id =: crtdByIdPfrIdMap.keySet()]){
                        pfrIdMgrIdMap.put(crtdByIdPfrIdMap.get(usr.Id),usr.ManagerId);  
                    }   
                }
                    for(PartnerFundRequest pfr: pfrList){
                        
                           
                            
                        //Updating Budget Local Amount and Budget Currency     
						if(oldPfrMap != null && String.isBlank(pfr.Core_MDF_Budget_Currency_cd__c)
                           && pfr.Core_MDF_Budget_Amount_Local_amt__c == null
                           && pfr.Core_MDF_Fund_Request_Status__c != oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c && 
                          (pfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_CCP_Planned_Status 
                           || pfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Revision_Required 
                           || oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Status_PendingReview))
                        {
                            pfr.Core_MDF_Budget_Amount_Local_amt__c = pfr.RequestedAmount;
                            pfr.Core_MDF_Budget_Currency_cd__c = 'USD';
                        }
                        
                    
                     //Set the Activity First Approver as Geo Approver so that email is triggered to this user on Rejection
                    // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                    if(oldPfrMap != NULL && oldPfrMap.size() > 0 &&
                        oldPfrMap.get(pfr.Id).Core_MDF_Approval_Step_Completed__c != pfr.Core_MDF_Approval_Step_Completed__c && 
                           pfr.Core_MDF_Approval_Step_Completed__c == 1 && pfr.Core_MDF_Program__c == 'Retail Marketing Funds'){
                            pfr.Core_MDF_Activity_First_Approver_txt__c = UserInfo.getUserId();   
                        
                        } 
                                    
                        Boolean errorthrown = false;
                       
                        Date startDate = pfr.Core_MDF_Start_Date__c;
                        Date todayDate = System.today()    ;
                        Integer daysDifference = todayDate.daysBetween(startDate);
                        String dayDifference = String.valueOf(daysDifference);
                        String amount = String.valueOf(pfr.RequestedAmount); //looping over the queried metadata list
                    
                        // Set the to be closed date based on the values configured in meta data
                        //closed date validations
                        String progName = ccpRecordTypeIds.get(pfr.recordTypeId);
                        String autoClosurekeyStr = '';

                    if (oldPfrMap != null && oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Cancelled'
                        && pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled')
                    {
                        pfr.Core_MDF_Fund_Request_Status__c = 'Cancelled';
                    }
                        
                      
                      
                        if(checkForAutoClosure(pfr, progName, oldPfrMap)){
                        if(quarterEndRsltMap != null){
                            autoClosurekeyStr = buildKeyForActivityClosure(pfr, progName);
                           
                               if(pfr.Core_MDF_ToBeClosedDate__c != quarterEndRsltMap.get(autoClosurekeyStr) && (pfr.Core_MDF_ATF_Flag_nm__c == null || pfr.Core_MDF_ATF_Flag_nm__c != null)) {
                                   pfr.Core_MDF_ToBeClosedDate__c = quarterEndRsltMap.get(autoClosurekeyStr);
                            }
                          if((oldPfrMap == NULL && pfr.Core_MDF_ToBeClosedDate__c < System.today()))
                           {
                                
                                pfr.Core_MDF_ToBeClosedDate__c = closeDateExtensionMap.get(autoClosurekeyStr);
                              if (pfr.Core_MDF_Program__c != Label.Core_MDF_CCFB_Program_Name && pfr.Core_MDF_Program__c != Label.Core_MDF_SPCF_Program_Name  
                                  && pfr.Core_MDF_Budget_Type_nm__c != Label.Core_MDF_BudgetType_CCF1_0 && pfr.Core_MDF_Budget_Type_nm__c != Label.Core_MDF_BudgetType_DCF1_0){
                               pfr.Core_MDF_ATF_Flag_nm__c=atfClosedStatus;
                                  }
                               pfr.Core_MDF_End_Date_Is_Changed_ind__c=false;
                               
                           }
                        }
                    } 
                   /* // Start - auto closure logic
                    if (checkForAutoClosure(pfr,progName,oldPfrMap))
                    {
                        // RMF/IPA auto closure
                       
                        if ((progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program') 
                             || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType')) 
                            && quarterEndRsltMap != null){
      
                            autoClosurekeyStr = buildKeyForActivityClosure(pfr,progName);
                                system.debug('autoClosurekeyStr>>>'+autoClosurekeyStr);
                                system.debug('autoClosurekeyStr>>>'+quarterEndRsltMap);
                              if(pfr.Core_MDF_ToBeClosedDate__c != quarterEndRsltMap.get(autoClosurekeyStr)){
                                pfr.Core_MDF_ToBeClosedDate__c = quarterEndRsltMap.get(autoClosurekeyStr);
                              }
                        }
                        // Non RMF auto closure
                        else if (metadtMap.containsKey(progName)){
                             system.debug('autoClosurekeyStr'+progName);
                            Date endDate = pfr.Core_MDF_End_Date__c;
                            Integer actCloseDays  = (Integer)metadtMap.get(progName);
                            pfr.Core_MDF_ToBeClosedDate__c = endDate.addDays(actCloseDays);
                        }
                    }*/
                      //closed date validations complete
                        
                        // Update OOTB amount field as 0 if its null to avoid salesforce error
                       /* if (pfr.Amount == NULL){
                            pfr.Amount = 0;
                        }
                        //End - Update OOTB amount field as 0 if its null to avoid salesforce error
                       
                        //Update Price reviewer check field if the activity type is of SPIF type
                        if(!pfr.Core_MDF_Is_Activity_Approved_ind__c){
                            system.debug('<<INSIDE Core_MDF_Is_Activity_Approved_ind__c>>');
                            if((progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program') || 
                                progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_PFRRecordTypeDevName') || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_PFRRecordTypeDevName') || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program') || 
                                progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Channel_MDF_Program') || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') )
                               && spifActivityTypesList.contains(pfr.Core_MDF_Activity_Types__c)){
                                   system.debug('<<InsideSPIF1>>');
                                   pfr.Core_MDF_Price_reviewer_check_ind__c = TRUE;
                               }else{
                                   system.debug('<<InsideSPIF2>>');
                                   pfr.Core_MDF_Price_reviewer_check_ind__c = FALSE;
                               }
                            if((progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_PFRRecordTypeDevName') || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_PFRRecordTypeDevName') || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Channel_MDF_Program') || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType')) && otherActivityTypesList.contains(pfr.Core_MDF_Activity_Types__c)){
                                pfr.Core_MDF_Program_Office_Check_ind__c = TRUE;
                            }else{
                                pfr.Core_MDF_Program_Office_Check_ind__c = FALSE;
                            }
                        }
                        
                        if((progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_PFRRecordTypeDevName') || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_PFRRecordTypeDevName') || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program')|| progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Channel_MDF_Program') || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType'))
                            && spifActivityTypesList.contains(pfr.Core_MDF_Activity_Types__c)){
                                system.debug('<<InsideSPIF3>>');
                                pfr.Core_MDF_Price_reviewer_check_ind__c = TRUE;
                            }else{
                                system.debug('<<InsideSPIF4>>');
                                pfr.Core_MDF_Price_reviewer_check_ind__c = FALSE;
                            }
                        
             if((progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_PFRRecordTypeDevName')
                             || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_PFRRecordTypeDevName') || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Intel_Camp_Record_Type_Dev_Name') || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Channel_MDF_Program') || progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType'))
                           && otherActivityTypesList.contains(pfr.Core_MDF_Activity_Types__c)){
                 pfr.Core_MDF_Program_Office_Check_ind__c = TRUE;
                            }else{ 
                pfr.Core_MDF_Program_Office_Check_ind__c = FALSE;
                               }
                        // Added for cancelling activity when L1 Approver provides 0 in budget amount for IPA proposal flow
                        if(pfr.Core_MDF_Budget_Amount_Local_amt__c == 0 && pfr.RecordTypeId == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') && ipaL1ApprovercmpId != null && ipaL1ApprovercmpId.contains(pfr.CampaignId))
                        {
                            pfr.Core_MDF_Fund_Request_Status__c ='Cancelled';                
                        }
                               
                        
                       
                         
                        //US964831: Setting Step/ Status to trigger approval when OEM CMP Activity created by Internal AM                       
                        String ccfRecType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_PFRRecordTypeDevName');
                        String dcfRecType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_PFRRecordTypeDevName'); 
                        System.debug('<<Core_MDF_Require_Additional_Review_ind__c>>' + pfr.Core_MDF_Require_Additional_Review_ind__c + '<<status>>' + pfr.Core_MDF_Fund_Request_Status__c +
                                     '<<stepcompleted>>' + pfr.Core_MDF_Approval_Step_Completed__c + '<<PriorValueOfStatus__c>>' + pfr.Core_MDF_PriorValueOfStatus__c +
                                     '<<Core_MDF_Activity_CreatedByExternalUsr__c>>' + pfr.Core_MDF_Activity_CreatedByExternalUsr__c + '<<Core_MDF_Is_Field_Modified__c>>' + pfr.Core_MDF_Is_Field_Modified__c                                       
                                    );                        
                      
                        if((ccfFieldOwner || dcfFieldOwner || ccfMarketingOwner || dcfMarketingOwner || pfr.Core_MDF_UserRole_txt__c == 'Program Office Review') && (progName == ccfRecType || progName == dcfRecType) && 
                           (pfr.Core_MDF_Budget_Type_nm__c == 'OEM CMP' || pfr.Core_MDF_Budget_Type_nm__c == 'Service Provider CMP') && pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled'){
                               //On creation, to go to L2(FAM) Approval, if Additional Review is checked
                               if(pfr.Core_MDF_Require_Additional_Review_ind__c && pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' && pfr.Core_MDF_Approval_Step_Completed__c == 0 && oldPfrMap == NULL)
                               {   
                                   system.debug('<<Inside If>>');
                                   pfr.Core_MDF_Approval_Step_Completed__c = 1;                                 
                               }
                               //On creation, to go to CA Approval, if Additional Review is checked/ unchecked
                               else if(((pfr.Core_MDF_Approval_Step_Completed__c == 4 &&
                                         pfr.Core_MDF_Require_Additional_Review_ind__c && 
                                        pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' &&
                                         (pfr.Core_MDF_Activity_CreatedByExternalUsr__c == false || (pfr.Core_MDF_Activity_CreatedByExternalUsr__c == true && pfr.Core_MDF_Is_Field_Modified__c == true )))|| 
                                        (!pfr.Core_MDF_Program_Office_Check_ind__c && !pfr.Core_MDF_Require_Additional_Review_ind__c && oldPfrMap == NULL) || (pfr.Core_MDF_Program_Office_Check_ind__c && pfr.Core_MDF_Approval_Step_Completed__c == 2 && !pfr.Core_MDF_Require_Additional_Review_ind__c && oldPfrMap != null)))
                               {    
                                   system.debug('<<Inside else If>>');
                                   pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
                               }
                               //In Pending Review status if field/marketing owner edits an actiivty created by external user sent it to customer acceptance for approval
                               else if(oldPfrMap != null && (pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled' && pfr.Core_MDF_Fund_Request_Status__c != 'Closed') 
                                       && (pfr.Core_MDF_PriorValueOfStatus__c == 'Pending Review' || pfr.Core_MDF_PriorValueOfStatus__c == 'Planned') 
                                       && pfr.Core_MDF_Approval_Step_Completed__c == 1 && !pfr.Core_MDF_Require_Additional_Review_ind__c 
                                       && !pfr.Core_MDF_Program_Office_Check_ind__c && pfr.Core_MDF_Is_Field_Modified__c == true
                                        && (pfr.Core_MDF_Budget_Type_nm__c == 'OEM CMP' || pfr.Core_MDF_Budget_Type_nm__c == 'Service Provider CMP' ||
                                            ((pfr.Core_MDF_Program__c =='Channel MDF' || pfr.Core_MDF_Program__c == 'Intel Partner Alliance') &&
                                             pfr.Core_MDF_Proposal_Based_Ind__c == false))){ 
                                         
                                        pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
                               }
                              
       							
                               
                           }
                          // Added for IPA - setting status to Pending Approval 
                          // Start
                          //IPA Level1 approves non SPIF activity
                          System.debug('oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c-->'+oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c);
                         if(pfr.Core_MDF_Program__c == 'Intel Partner Alliance' && pfr.Core_MDF_Proposal_Based_Ind__c == false && pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' && (pfr.Core_MDF_Activity_CreatedByExternalUsr__c != true || (pfr.Core_MDF_Activity_CreatedByExternalUsr__c == true &&( pfr.Core_MDF_Is_Field_Modified__c == true || pfr.Core_MDF_Metrics_Modified_ind__c==true))))
                         {
                           if(pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c < 25000 && pfr.Core_MDF_Approval_Step_Completed__c == 1 && !pfr.Core_MDF_Program_Office_Check_ind__c && !pfr.Core_MDF_Price_reviewer_check_ind__c ){
                                   system.debug('<<IPAaCCOUNTBASED>>');
                               //pfr.Core_MDF_PriorValueOfStatus__c = pfr.Core_MDF_Fund_Request_Status__c;
                                
                               		system.debug('Core_MDF_PriorValueOfStatus__c-->'+pfr.Core_MDF_Fund_Request_Status__c);
                               		system.debug('Core_MDF_PriorValueStatusForExternalUser__c-->'+pfr.Core_MDF_PriorValueStatusForExternalUser__c);
                               		//pfr.Core_MDF_PriorValueStatusForExternalUser__c = pfr.Core_MDF_Fund_Request_Status__c;
                                    pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
                               }
                             //IPA Level1 Manager Approves NON-SPIF/NON-POR activity
                             else if(pfr.Core_MDF_Approval_Step_Completed__c == 2 && pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c > 25000 && !pfr.Core_MDF_Program_Office_Check_ind__c && !pfr.Core_MDF_Price_reviewer_check_ind__c ){
                                   system.debug('<<IPAaCCOUNTBASED>>');
                                        pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
                                   }
                               // If IPA POR approves SPIF activity
                             else if(pfr.Core_MDF_Approval_Step_Completed__c == 3 && ((pfr.Core_MDF_Program_Office_Check_ind__c && !pfr.Core_MDF_Price_reviewer_check_ind__c ) || (!pfr.Core_MDF_Program_Office_Check_ind__c && pfr.Core_MDF_Price_reviewer_check_ind__c ))) {
                                   system.debug('<<IPAaCCOUNTBASED>>');
                                    pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
                               }
                              else if(pfr.Core_MDF_Approval_Step_Completed__c == 4 && pfr.Core_MDF_Program_Office_Check_ind__c && pfr.Core_MDF_Price_reviewer_check_ind__c ){
                                   system.debug('<<IPAaCCOUNTBASED>>');
                                    pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
                         }
                             //Requested Amounf > 25000 SPIF/Non-POR
                             else if(pfr.Core_MDF_Approval_Step_Completed__c == 4 && !pfr.Core_MDF_Program_Office_Check_ind__c && pfr.Core_MDF_Price_reviewer_check_ind__c ){
                                   system.debug('<<IPAaCCOUNTBASED>>');
                                    pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
									}
						 }
                            //Updating prior status value when activity status is changed
                            if(oldPfrMap != NULL && oldPfrMap.size() > 0 && pfr.Core_MDF_Fund_Request_Status__c != oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c){ 
                               System.debug('oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c'+oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c);
                               pfr.Core_MDF_PriorValueOfStatus__c =  oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c ;
                               if(pfr.Core_MDF_Activity_CreatedByExternalUsr__c)
                                   {
                                       pfr.Core_MDF_PriorValueStatusForExternalUser__c = oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c; 
                                   	   //Updating prior status value when status changed by external user
                                   }
                                }
                        //End
                        //TWC702-760 
                        String cmdfRecType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Channel_MDF_Program');
                     
                         //TWC702-760 
                        if(((oldPfrMap != NULL && oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Pending Review' &&
                                   pfr.Core_MDF_Fund_Request_Status__c == 'Pending Approval') || (oldPfrMap != NULL && oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Pending Approval' &&
                                    pfr.Core_MDF_Fund_Request_Status__c == 'Pending Approval')) ){
                                       
                                        if(pfr.Core_MDF_Member_Acceptor_Id__c != NULL){
                                           externalPendingApprovalPfrList.add(pfr); 
                                            System.debug('Inside if 640-->');
                                        }else if(progName == cmdfRecType && pfr.Core_MDF_Proposal_Based_Ind__c == false){
                                                pendingApprovalPfrList.add(pfr);
                                                accIdSet.add(pfr.ChannelPartnerId);
                                            	System.debug('Inside if 644-->');
                                             }
                                           
                                                                                                                       
                                 }
                        
                         

                        //TWC702-1949: [Technical] [X-Platform] - Account Based PCT approvers 
                        List<String> budTypesList = System.Label.Core_MDF_OPAL_BudgetTypes.split(';');
                         
                       
                        //Modified by Hema for IPA
                        if(pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' && pfr.Core_MDF_Price_reviewer_check_ind__c && 
                            (budTypesList.contains(pfr.Core_MDF_Budget_Type_nm__c) &&  
                            ((pfr.Core_MDF_UserRole_txt__c == 'L1 Approver' && !pfr.Core_MDF_Program_Office_Check_ind__c && !pfr.Core_MDF_Activity_CreatedByExternalUsr__c) ||
                            (pfr.Core_MDF_UserRole_txt__c == 'Program Office Review' && pfr.Core_MDF_Program_Office_Check_ind__c) ||
                            (pfr.Core_MDF_Approval_Step_Completed__c == 1 && !pfr.Core_MDF_Program_Office_Check_ind__c))) || 
                            (pfr.Core_MDF_Program__c == 'Retail Marketing Funds' && ((pfr.RequestedAmount < 25000 && pfr.Core_MDF_UserRole_txt__c == 'Geo Lead') ||
                            (pfr.RequestedAmount >= 25000 && pfr.RequestedAmount < 250000 && pfr.Core_MDF_UserRole_txt__c == 'L1 Mgr') ||
                                                                                     /*(pfr.RequestedAmount >= 250000 && pfr.Core_MDF_UserRole_txt__c == 'L2 Mgr') || (pfr.Core_MDF_UserRole_txt__c == 'PCT')))){
                           
                                pfr.Core_MDF_Approval_Stage__c = 'Price Reviewer';
                        }
                        
                        else if(pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' && pfr.Core_MDF_Price_reviewer_check_ind__c &&  pfr.Core_MDF_Program__c == 'Intel Partner Alliance' && ((pfr.Core_MDF_UserRole_txt__c == 'L1 Approver' && !pfr.Core_MDF_Program_Office_Check_ind__c && pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c < 25000 && !pfr.Core_MDF_Activity_CreatedByExternalUsr__c) ||
                                                                                        (pfr.Core_MDF_UserRole_txt__c == 'L1 Mgr' && pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c >= 25000 && !pfr.Core_MDF_Program_Office_Check_ind__c) ||
                                                                                        (pfr.Core_MDF_UserRole_txt__c == 'Program Office Review' && pfr.Core_MDF_Program_Office_Check_ind__c && pfr.Core_MDF_Approval_Step_Completed__c == 3) ||
                                                                                        (pfr.Core_MDF_Approval_Step_Completed__c == 1 && pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c < 25000 && !pfr.Core_MDF_Program_Office_Check_ind__c))){
                                                                                            pfr.Core_MDF_Approval_Stage__c = 'Price Reviewer';
                                                                                        }
                       else if( pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' && (pfr.Core_MDF_Program__c == 'Intel Partner Alliance' && pfr.Core_MDF_Proposal_Based_Ind__c == false)){                                                                    
                        	if(pfr.Core_MDF_Approval_Step_Completed__c == 0){
                               pfr.Core_MDF_Approval_Stage__c = 'L1 Approval';
                        		}
                        	else if(pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c >= 25000 && pfr.Core_MDF_Approval_Step_Completed__c == 1){
                                    pfr.Core_MDF_Approval_Stage__c = 'L2 Approval';
                        }
                        else if((pfr.Core_MDF_Approval_Step_Completed__c == 1 || pfr.Core_MDF_Approval_Step_Completed__c == 2) && pfr.Core_MDF_Program_Office_Check_ind__c == true){
                                 pfr.Core_MDF_Approval_Stage__c = 'Program Office Reviewer';
                        }
                     }
                        else {
                     
                            pfr.Core_MDF_Approval_Stage__c = 'None';
                        }
                        
                        if(oldPfrMap != NULL && oldPfrMap.get(pfr.Id).Core_MDF_Approval_Step_Completed__c != pfr.Core_MDF_Approval_Step_Completed__c &&
                        pfr.Core_MDF_Approval_Step_Completed__c == 1 &&
                        (pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review' || pfr.Core_MDF_Fund_Request_Status__c == 'Pending Approval') && UserInfo.getUserType() == 'Standard' &&
                        pfr.Core_MDF_Activity_CreatedByExternalUsr__c == true &&   
                           (progName == ccfRecType || progName == dcfRecType || ((progName == cmdfRecType || Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_IPA').equals(pfr.Core_MDF_Program__c)) && pfr.Core_MDF_Proposal_Based_Ind__c == false))){     
                                      pfr.Core_MDF_L1_Approver_Id__c = UserInfo.getUserId();
     
                                 }
                        
                        if(!geoApprover){
                            if(pfr.Core_MDF_Activity_CreatedByExternalUsr__c){
                                userIdSet.add(pfr.Core_MDF_L1_Approver_Id__c);  
                            }
                            else{
                                userIdSet.add(pfr.OwnerId);                                
                            }     
                            System.debug('<<userIdSet>>' + userIdSet);
                        }
                        if(!geoApprover && userIdSet != null && userIdSet.size()>0){
                            for(User usr: [Select Id, ManagerId 
                                           FROM User 
                                           Where Id =: userIdSet and ManagerId != NULL]){
                                               userIdManagerMap.put(usr.Id,usr.ManagerId); 
                                               
                                           }   
                        }
                        System.debug('<<userIdManagerMap>>' + userIdManagerMap);
                       //stamping manager id after level 1 user approves the activity
                        if(userIdManagerMap != NULL && userIdManagerMap.size() > 0 && pfr.Core_MDF_Approval_Step_Completed__c == 1 && (pfr.Core_MDF_Budget_Type_nm__c == 'MDF+' || pfr.Core_MDF_Budget_Type_nm__c == 'MDF' || 
                       ((Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name').equals(pfr.Core_MDF_Program__c) /*|| (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name').equals(pfr.Core_MDF_Program__c))*//*) && pfr.Core_MDF_Proposal_Based_Ind__c == false))){                           
                        /*   if(pfr.Core_MDF_Activity_CreatedByExternalUsr__c == true){
                                pfr.Core_MDF_Activity_First_Approver_txt__c = userIdManagerMap.get(pfr.Core_MDF_L1_Approver_Id__c);    
                            }
                            else{
                                 pfr.Core_MDF_Activity_First_Approver_txt__c = userIdManagerMap.get(pfr.OwnerId);
                            }                            
                        }
                      
                        if(pfrRecordTypeEventMetadataMap.get(ccpRecordTypeIds.get(pfr.RecordTypeId)) != NULL)
                        {
                            for(Core_MDF_PFR_Event_Rule__mdt customMetadata : pfrRecordTypeEventMetadataMap.get(ccpRecordTypeIds.get(pfr.RecordTypeId))) {
                                if(pfr.Core_MDF_Country_nm__c != NULL){
                                    List< String > countryList = pfr.Core_MDF_Country_nm__c.split(';');
                                    if(countryList != null && countryList.size() > 0){
                                        for(String country : countryList){
                                            if(customMetadata.Core_MDF_Country_Picklist_Value__c != NULL && ccpRecordTypeIds.get(pfr.RecordTypeId) == customMetadata.Core_MDF_PFR_RecordType__c && customMetadata.Core_MDF_PFR_StartDate__c > pfr.Core_MDF_Start_Date__c && !customMetadata.Core_MDF_Country_Picklist_Value__c.contains(country)){
                                                pfr.addError(Label.Core_MDF_Country_CCFB_2020_Validation);errorthrown = true;break;
                                            }                                                           
                                        }
                                    }
                                }
                                if(!hasCustomPermission){
                                    if((oldPfrMap != NULL && oldPfrMap.size() > 0 && ((oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c != pfr.Core_MDF_Start_Date__c) || (oldPfrMap.get(pfr.Id).Core_MDF_ActivityCategory__c != pfr.Core_MDF_ActivityCategory__c ) || (oldPfrMap.get(pfr.Id).Core_MDF_Activity_Types__c != pfr.Core_MDF_Activity_Types__c) || (oldPfrMap.get(pfr.Id).RequestedAmount != pfr.RequestedAmount))) || (pfr.Id == NULL)){     //Calling the Generic Compare Method
                                        Boolean checkDate = Core_MDF_GenericApprovalProcess.validateRule(customMetadata.Core_MDF_Day_Difference__c, dayDifference, customMetadata.Core_MDF_Days_Difference_Operator__c, 'DOUBLE');
                                        Boolean checkAmount = Core_MDF_GenericApprovalProcess.validateRule(customMetadata.Core_MDF_Requested_Amount__c,amount, customMetadata.Core_MDF_Amount_Operator__c, 'DOUBLE');
                                        //checking the pfr recordtype, pfr activity category, pfr activity type, pfr status
                                        if(customMetadata.Core_MDF_PFR_RecordType__c == ccpRecordTypeIds.get(pfr.RecordTypeId) &&   customMetadata.Core_MDF_Activity_Category__c == pfr.Core_MDF_ActivityCategory__c &&  customMetadata.Core_MDF_Activity_Types__c.contains(pfr.Core_MDF_Activity_Types__c) && !(pfr.Core_MDF_Fund_Request_Status__c.Contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status')))) {
                                            // 30 and 60 days validation for event activity starting from 01.01.2020 with budget less than and greater than or equal 50K
                                            if(startDate >= customMetadata.Core_MDF_PFR_StartDate__c && checkDate && checkAmount){ pfr.addError(customMetadata.Core_MDF_Error_Message__c); errorthrown = true;break;
                                                                                                                                 }
                                            // 22 days validation for event activity starting before 01.01.2020
                                            else if(startDate < customMetadata.Core_MDF_PFR_StartDate__c && pfr.RequestedAmount >= (Double.valueof(customMetadata.Core_MDF_Requested_Amount__c)) && customMetadata.Core_MDF_Activity_Category__c == pfr.Core_MDF_ActivityCategory__c && daysDifference < Integer.valueOf(Label.Core_MDF_22_Days_More_Than_50K) && pfr.Core_MDF_Activity_Types__c != Label.Core_MDF_Activity_Type_Promotion){
                                                pfr.addError(Label.Core_MDF_Activity_Event_22_Days);errorthrown = true;break;
                                            }
                                        }
                                    }
                                }
                        
                                //Retail start date validation 
                                if(hasRetailCustomPermission)
                                {  
                                   
                                    
                                    //3. Based on US846955-US849167, check if Japan cycle 
                                    Boolean chkJapanCycle = false;
                                    if(pfr != NULL){
                                        chkJapanCycle = checkJapanCycle(pfr, progName);
                                    }
                                    
                                    
                                    if(chkJapanCycle && pfrDateMap!=null){ //isJapanCycle
                                        //Japan cycle Activity dates validation
                                        string validatemsg = validateJapanCycleDates(pfr,pfrDateMap); //Activity dates cannot overlap cycles.  
 
                                        /*Date- 01-04-2022 by Ravi
                                         * Added for TWC702-355
                                          Date- 01-04-2022 by Ravi
                                         */
                                       /* if(string.isNotBlank(validatemsg) && pfr.Core_MDF_Program__c != 'Retail Marketing Funds'){
                                            pfr.addError(validatemsg); errorthrown = true; break;
                                        }
                                    }                                 
                                }
                                
                            }
                        }
                    //closed date validations
                    if(!errorthrown){
                        
                        //Populating Activity Pillar and Secondary Pillar values from the CCP Attributes Metadata
                        if(pfrRecordTypeAttributeMetadataMap != NULL && pfrRecordTypeAttributeMetadataMap.size() > 0){
                            Core_MDF_PartnerFundRequest_Utility.getActivityPillarAndActivitySecondaryPillar(pfr, ccpRecordTypeIds.get(pfr.RecordTypeId));
                        }
                        if(pfr.Core_MDF_Program__c == 'Retail Marketing Funds'){                           
                            if(oldPfrMap != null && oldPfrMap.size() > 0 
                   && oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != 'Cancelled' 
                               && oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != 'Closed'
                               && pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled' 
                               && pfr.Core_MDF_Fund_Request_Status__c != 'Closed'
                               && oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != 'Pending Approval'
                               && pfr.Core_MDF_Fund_Request_Status__c != 'Pending Approval' 
                               && oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != 'Planned'
                               && pfr.Core_MDF_Fund_Request_Status__c != 'Planned' 
                               
                              ){
                                  setStatusRetailExternal(pfr);   
                            }
                            if(pfr.RequestedAmount >= 25000 && geoApprover && !retailAccMgrPS && pfrIdMgrIdMap.containsKey(pfr.Id) && pfrIdMgrIdMap.get(pfr.Id) != null){
                                pfr.Core_MDF_Approver_1__c = pfrIdMgrIdMap.get(pfr.Id);
                            }
                        }
                    }
                        
                        //Below code is to update 
                        //[i]Standard Amount field on PFR on creation and on edit of amount fields
                        //[ii]Standard status to Approved on create
                        //[iii]Set Standard status to Draft if Activity Status is Cancelled
                        //Varun
                        //String budgetTypesApplicableForAmountUpdate = 'MDF;MDF+';
                        //List<String> budgetTypesList = budgetTypesApplicableForAmountUpdate.split(';');
                        //Commented as part of CMP Activity
                       // List<String> budgetTypesList = Label.Core_MDF_OPAL_BudgetTypes.split(';'); //MDF;OEM CMP;MDF+;Service Provider CMP
                        List<String> budgetTypesList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bdgt_Types_For_Amount_Update').split(';');
                        List<String> cmpBudgetType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CMP_BudgetType').split(';');
                        
                        if(cmpBudgetType.contains(pfr.Core_MDF_Budget_Type_nm__c)){
                               if(pfr.Core_MDF_Fund_Request_Status__c == 'Cancelled'){
                                   pfr.Status = 'Rejected';
                               }
                           }
                        
                        if((pfr.Core_MDF_Budget_Type_nm__c != NULL && budgetTypesList.contains(pfr.Core_MDF_Budget_Type_nm__c))||(pfr.Core_MDF_Program__c =='Intel Partner Alliance'&& !isPropBasedCamp)){
                           System.debug('>>>>Inside MainIf');
                            if(pfr.Core_MDF_Fund_Request_Status__c == 'Cancelled'){
                                pfr.Status = 'Rejected';
                            }else{
                                pfr.Status = 'Approved';
                            }
                           System.debug('>>>>>>oldPfrMap'+oldPfrMap);
                             
                            if((oldPfrMap == NULL || ((oldPfrMap != NULL && oldPfrMap.containsKey(pfr.Id) && oldPfrMap.get(pfr.Id) != NULL) &&
                                                      (pfr.RequestedAmount != oldPfrMap.get(pfr.Id).RequestedAmount)|| (pfr.Core_MDF_Reimbursement_Rate_txt__c != oldPfrMap.get(pfr.Id).Core_MDF_Reimbursement_Rate_txt__c)) && 
                               (pfr.Core_MDF_Program__c == 'Intel Partner Alliance'&& !isPropBasedCamp && pfr.RequestedAmount != NULL))){
                                   
                                    System.debug('>>Inside SubIf');
                                   Decimal intelContribution = 0;
                                   if(pfr.Core_MDF_Reimbursement_Rate_txt__c != NULL && pfr.Core_MDF_Reimbursement_Rate_txt__c != '' ){
                                        
                                       intelContribution = (pfr.RequestedAmount * decimal.valueOf(pfr.Core_MDF_Reimbursement_Rate_txt__c.removeEnd('%')))/100;
                                       pfr.Amount = intelContribution;
                                       
                                   }else {
                                        
                                       intelContribution = (pfr.RequestedAmount * decimal.valueOf(pfr.Core_MDF_Campaign_Reimbursement_Rate_txt__c.removeEnd('%')))/100;
                                       pfr.Amount =intelContribution;
                                      
                                   }
                                   
                               }
                            
                            else if(pfr.Core_MDF_Program__c != 'Intel Partner Alliance' && (oldPfrMap == NULL || (oldPfrMap != NULL && oldPfrMap.containsKey(pfr.Id) && oldPfrMap.get(pfr.Id) != NULL &&
                                                      (pfr.RequestedAmount != oldPfrMap.get(pfr.Id).RequestedAmount ||
                                                       pfr.Core_MDF_MDFReimbursement_Amt__c != oldPfrMap.get(pfr.Id).Core_MDF_MDFReimbursement_Amt__c || pfr.Core_MDF_Reimbursement_Rate_txt__c != oldPfrMap.get(pfr.Id).Core_MDF_Reimbursement_Rate_txt__c)))){   
                                 System.debug('>>>>Inside ELSEIf');
                                if(pfr.Core_MDF_MDFReimbursement_Amt__c > 0){
                                    pfr.Amount = pfr.Core_MDF_MDFReimbursement_Amt__c;
                                }else if(pfr.RequestedAmount != NULL && pfr.Core_MDF_Reimbursement_Rate_txt__c != NULL){
                                    Decimal activityReimbursementAmount = 0;
                                    activityReimbursementAmount = (pfr.RequestedAmount * decimal.valueOf(pfr.Core_MDF_Reimbursement_Rate_txt__c.removeEnd('%')))/100;
                                    pfr.Amount = activityReimbursementAmount;
                                }
                                  system.debug('>>RequestedAmount'+pfr.RequestedAmount);
                           }
                        
                        }//End of if- Standard Amount & Status field update to check Allocation validation
                        
                }
                
             
                //TWC702-760
                if( pendingApprovalPfrList != NULL && pendingApprovalPfrList.Size() > 0 && accIdSet != NULL && accIdSet.Size() > 0 && emailSendOnce){
                         
                    Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(pendingApprovalPfrList,accIdSet);
                    emailSendOnce = false;
                } 
                if( externalPendingApprovalPfrList != NULL && externalPendingApprovalPfrList.Size() > 0 && emailSendOnce){
                                  
                    Core_MDF_ProcessCCP_PartnerFundRequest.notifyCCFDCFExternalReviewer(externalPendingApprovalPfrList);
                    emailSendOnce = false;
                }
               
            }
            
           
         
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
  }*/
    /****************************************************************************************************** 
    Method Name:        setStatusRetailExternal
    @return  :          void
    @parameters:        PFR 
    Description:        Set status as Pending Approval if external approval required - DE121489 Production Issue: ATF flow still  failing to next step once ATF approver approves from L1 step
    Added By:           Accenture - NZ - 08/02/2021
    Modified By:        Date:      Changes: 
  
    *******************************************************************************************************/
    
   /* public static void setStatusRetailExternal(PartnerFundRequest pfr){
        Boolean geoApprover = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver');
     
        
        if(pfr.Core_MDF_Program__c == 'Retail Marketing Funds'  && pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review'){
            //
            if ((pfr.RequestedAmount < 25000 && 
                 ((pfr.Core_MDF_Approval_Step_Completed__c == 1 && !pfr.Core_MDF_Price_reviewer_check_ind__c)
                  || (pfr.Core_MDF_Approval_Step_Completed__c == 2 && pfr.Core_MDF_Price_reviewer_check_ind__c)))
                
                ||
                
                ((pfr.RequestedAmount >= 25000 && pfr.RequestedAmount < 250000) && 
                 ((pfr.Core_MDF_Approval_Step_Completed__c == 2 && !pfr.Core_MDF_Price_reviewer_check_ind__c)
                  || (pfr.Core_MDF_Approval_Step_Completed__c == 3 && pfr.Core_MDF_Price_reviewer_check_ind__c)))
                ||
                
                (pfr.RequestedAmount > 250000 &&((pfr.Core_MDF_Approval_Step_Completed__c == 3 && !pfr.Core_MDF_Price_reviewer_check_ind__c)
                  || (pfr.Core_MDF_Approval_Step_Completed__c == 4 && pfr.Core_MDF_Price_reviewer_check_ind__c)))
                //added condition to set the status as pending approval when the ATF user approves past dated the activity created by RSM
                 //|| 
                 

               ){
                   
                   pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval'; 
               }
            
        }
        
    } */

  

    /****************************************************************************************************** 
    Method Name:        buildKeyForActivityClosure
    @return  :          string
    @parameters:        pfr and program name
    Description:        Build the key based on the PFR values
    Added By:           Sridhar - 06/30/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/

   /*public static string buildKeyForActivityClosure(PartnerFundRequest pfr, string progName){

        string key = '';
        string rmfLabel = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name');
        string ipaLabel = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name');
        String channelMDFLabel = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CMDF_Program');
     //  system.debug('ccfLabel'+ccfLabel);
       system.debug('progName'+progName);
    string japanCntry;
        string ultimateAccGeo;  

            if (progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program')) //&& pfr.Core_MDF_Budget_Type_nm__c == Label.Core_MDF_Retail_RSA_MD_Budget_Type
            {
        //4. Based on US846955-US849167, getting Ultimate Account's Country and its Geo
        if(pfr != NULL && accIdRegionMap.get(pfr.ChannelPartnerId) != NULL){
          japanCntry = pfr.Core_MDF_Ultimate_Account_Country_txt__c;
                    ultimateAccGeo = accIdRegionMap.get(pfr.ChannelPartnerId);                    
        }
                if(String.isNotBlank(japanCntry)) {
                    japanCntry = japanCntry.toUpperCase();
                } 
    // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                if (pfr.Core_MDF_Budget_Type_nm__c == Label.Core_MDF_Retail_RSA_MD_Budget_Type ||
                    pfr.Core_MDF_Budget_Type_nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RetailMDF_BudgetType')){
          //5. Based on US846955-US849167 checking if Country is JAPAN and its Geo from Ultimate Acc to form key
                    if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Country_JAPAN').equals(japanCntry)){
                        key = rmfLabel + ':' +
                            pfr.Core_MDF_Budget_Type_nm__c + ':' +
                            ultimateAccGeo + ':' + 
                            'null' + ':' +
                            japanCntry + ':'; 
                    }else{
                        key = rmfLabel + ':' +
                            pfr.Core_MDF_Budget_Type_nm__c + ':' +
                            'null' + ':' +
                            'null' + ':' +
                            'null' + ':';                        
                    }
                }
               else{
                key = rmfLabel + ':' +
                    pfr.Core_MDF_Budget_Type_nm__c + ':' +
                    'null' + ':' +
                    'null' + ':' +
                    'null' + ':';
            }
        }
        else if (progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType')){

            key = ipaLabel + ':' +
                    'NA' + ':' +
                    'null' + ':' +
                    'null' + ':' +
                    'null' + ':';
        }
        else if (progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Channel_MDF_Program')){//added for channelMDF
            key = channelMDFLabel + ':' +
                'NA' + ':' +
                'null' + ':' +
                'null' + ':' +
                'null' + ':';
        }
       else if (progName == 'Core_MDF_Client_CoMarketing_Fund_Boost'){
           
            key = pfr.Core_MDF_Program__c + ':' +
                'NA' + ':' +
                'null' + ':' +
                'null' + ':' +
                'null' + ':';
        }
       else if (progName == 'Core_MDF_Service_Provider_CoMarketing_Fund'){
          
            key = pfr.Core_MDF_Program__c + ':' +
                'NA' + ':' +
                'null' + ':' +
                'null' + ':' +
                'null' + ':';
        }
        else{
            key = pfr.Core_MDF_Program__c + ':' +
                pfr.Core_MDF_Budget_Type_nm__c + ':' +
                'null' + ':' +
                'null' + ':' +
                'null' + ':';
        }
     
        key += pfr.Core_MDF_End_Date__c.format(); // valiate with different locale
        key = key.deleteWhitespace();
       
        
        return key;
    }*/
    

    /****************************************************************************************************** 
    Method Name:        checkForAutoClosure
    @return  :          boolean
    @parameters:        pfr, program name and oldpfrmap
    Description:        check if auto closure is required
    Added By:           Sridhar - 08/03/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/

        /*private static Boolean checkForAutoClosure(PartnerFundRequest pfr, string progName,Map<Id,PartnerFundRequest> oldPfrMap){
          
            Boolean geoApprover = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver');
        
        // US949836 : New Budget Type field changes replaced txt field with new global picklist field  
            if (((geoApprover && pfr.Core_MDF_Fund_Request_Status__c =='Closed') || 
                (pfr.Core_MDF_Fund_Request_Status__c != 'Closed' && pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled'))
                && (oldPfrMap == null 
                || (progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program') && oldPfrMap != null && (oldPfrMap.get(pfr.Id).Core_MDF_End_Date__c != pfr.Core_MDF_End_Date__c 
                            || oldPfrMap.get(pfr.Id).Core_MDF_Budget_Type_nm__c != pfr.Core_MDF_Budget_Type_nm__c || oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c != pfr.Core_MDF_Start_Date__c)/* || aftrTheFactPSFlag*/ //)
               /* || (progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') && oldPfrMap != null && (oldPfrMap.get(pfr.Id).Core_MDF_End_Date__c != pfr.Core_MDF_End_Date__c
                            ))
                || (oldPfrMap != null && progName != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_RecordType') && progName != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program') && (oldPfrMap.get(pfr.Id).Core_MDF_End_Date__c != pfr.Core_MDF_End_Date__c
                            ))       
            )){
                return true;
            }
            return false;

        }*/

        
        /****************************************************************************************************** 
        Method Name:        getQtrstartenddates
        @return  :          Map<Id,List<Date>>
        @parameters:        list of PFR and Map <id ,string> to get record type names by ids
        Description:        Fetch Qtr start and end dates
        Added By:           Vivek - 09/29/2020
        Modified By:        Date:      Changes: 
        *******************************************************************************************************/
        /*private static Map<Id,List<Date>> getQtrStartAndEndDates(List<PartnerFundRequest> pfrList, Map<Id,string> ccpRecordTypeIds){        
            Map<string,List<date>> dateMapRes = new Map<string,List<date>>(); //Date map returned from ClaimSubmissionClosure class method
            map<string,date> dueDateMap=new map<string,date>{}; //Map of key and null to be passed to ClaimSubmissionClosure class method            
            Map<string,Id> pfrkeymap = new Map<string,Id>();
            Map<Id,List<date>> pfrdatemap = new Map<Id,List<date>>();
            for(PartnerFundRequest pfr: pfrList){
                String progName = ccpRecordTypeIds.get(pfr.recordTypeId);
                String key = '';
                
                if(progName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program')){
                  key = buildKeyForActivityClosure(pfr,progName);    
                }
                              
                if (!String.isEmpty(key))
                {
                    dueDateMap.put(key, null);
                    pfrkeymap.put(key,pfr.Id);
                }
            }

            if(dueDateMap!=null && !dueDateMap.isEmpty()){
                dateMapRes = Core_MDF_ProcessClaimSubmissionClosure.getQuarterStartAndEndDate(dueDateMap);
            }

            if(dateMapRes!= null && dateMapRes.size() > 0){
                for(String key:dateMapRes.keySet()){
                    for(String pfrkey:pfrkeymap.keySet()){
                        if(key==pfrkey){
                            pfrdatemap.put(pfrkeymap.get(pfrkey),dateMapRes.get(key));
                        }
                    }
                }
            }
            return pfrdatemap;

        }*/
        
        /****************************************************************************************************** 
        Method Name:        validateJapanCycleDates
        @return  :          string
        @parameters:        PFR and Map <id ,List<Date>> 
        Description:        Validate activity start date and end date validations for Japan cycle
        Added By:           Vivek - 09/29/2020
        Modified By:        Date:      Changes: 
        *******************************************************************************************************/
        /*private static string validateJapanCycleDates(PartnerFundRequest pfr,Map<Id,List<Date>> pfrDateMap){
            List<Date> datelst = new List<Date>(); 
            Date qtrstartdate;
            Date qtrenddate;
            string errormsg = '';

            if(pfrDateMap!=null && pfrDateMap.size()>0){
                datelst = pfrDateMap.get(pfr.Id);
            }
                
            if(datelst!= null && datelst.size()>0){
                qtrstartdate = datelst.get(0);
                qtrenddate = datelst.get(1);
            }

            if((qtrstartdate!= null && qtrenddate!= null) && (!(pfr.Core_MDF_Start_Date__c >= qtrstartdate && pfr.Core_MDF_Start_Date__c <= qtrenddate) || !(pfr.Core_MDF_End_Date__c >= qtrstartdate && pfr.Core_MDF_End_Date__c <= qtrenddate))) {
                errormsg =  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_JPN_Dates_Validation');
            } 

            return errormsg;
        }   */
    
  /****************************************************************************************************** 
        Method Name:        checkJapanCycle
        @return  :          Boolean
        @parameters:        PFR and String
        Description:        Validate Japan cycle
        Added By:           Manasa - 11/12/2020
        Modified By:        Date:      Changes: 
        *******************************************************************************************************/
        /*public static Boolean checkJapanCycle(PartnerFundRequest pfr, string program){
            Boolean japanRetailer = false;         
            
      if(pfr != NULL && string.isNotBlank(program)){                
                //if country-Japan, Program-Retail, BudgetType-RSA MD, return true
    // US949836 : New Budget Type field changes replaced txt field with new global picklist field
                if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Country_JAPAN').equalsIgnoreCase(pfr.Core_MDF_Ultimate_Account_Country_txt__c) && Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Retail').equals(program) && 
                   Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_RSAMD_UnTranslated').equals(pfr.Core_MDF_Budget_Type_nm__c )
                   ){
                       japanRetailer = true;                       
                }
            }
            return japanRetailer;
        }*/
    /****************************************************************************************************** 
        Method Name:        populateRR
        @return  :          NULL
        @parameters:        List of new PFR Records
        Description:        Based on US824858, calculating Activity Reimbursment Rate for all Programs. 
        Added By:           Manasa - 10/29/2020
        *******************************************************************************************************/
        /*public static void populateRR(List<PartnerFundRequest> newList, Set<Id> campaignIds){
            String reimursmentRate, rRate;
            Decimal decimalRR;
            Map<Id, String> campIdRRStrMap = new Map<Id, String>();
            Map<Id,String> campaignIdToBudgetTypeMap = new Map<Id,String>();
            Map<Id, String> cmpRRateMap = new Map<Id, String>();
            String ccfProgramName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name');
            String dcfProgramName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name');
            List<String> budgetTypeCCFDCF1_0 = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetTypeToExclude').split(';');
            for(Campaign campaignRecord : [SELECT Id, Core_MDF_Reimbursement_Rate__c, Core_MDF_Budget_Type_txt__c,Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Supports_legacy_program__c,Recordtype.DeveloperName, Core_MDF_ReimbursementRate_pct__c
                                           FROM Campaign
                                           WHERE Id IN :campaignIds AND
                                           Core_MDF_Reimbursement_Rate__c != NULL]){
                  campIdRRStrMap.put(campaignRecord.Id, campaignRecord.Core_MDF_ReimbursementRate_pct__c);                         
                   if(String.isNotBlank(campaignRecord.Core_MDF_Opal_Budget_Type_Txt__c) && campaignRecord.Core_MDF_Supports_legacy_program__c == 'Yes'){
                        campaignIdToBudgetTypeMap.put(campaignRecord.Id,campaignRecord.Core_MDF_Opal_Budget_Type_Txt__c);
                   }                
            }
            for(Core_MDF_Campaign_Budgets__c cmpBudget : [select id, Core_MDF_Budget_Name_Id__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Reimbursement_Rate_Pct__c from  Core_MDF_Campaign_Budgets__c 
                                                          WHERE Core_MDF_Campaign_Id__c IN :campaignIds]){
                cmpRRateMap.put(cmpBudget.Core_MDF_Budget_Name_Id__c, cmpBudget.Core_MDF_Reimbursement_Rate_Pct__c);            
            }
            
            for(PartnerFundRequest pfr: newlist){
                //Added as part of US1095440 changes:To update Budget type for Non-Opal Activities
                if((pfr.Core_MDF_Program__c == ccfProgramName || pfr.Core_MDF_Program__c == dcfProgramName) && String.isBlank(pfr.Core_MDF_Budget_Type_nm__c)
                     && campaignIdToBudgetTypeMap.containsKey(pfr.CampaignId) && budgetTypeCCFDCF1_0.contains(campaignIdToBudgetTypeMap.get(pfr.CampaignId))){
                        pfr.Core_MDF_Budget_Type_nm__c = campaignIdToBudgetTypeMap.get(pfr.CampaignId);
                        pfr.Core_MDF_Budget_Type_txt__c = campaignIdToBudgetTypeMap.get(pfr.CampaignId);
                }
                //US1095440 - changes end
              //For Retail & IPA Programs
            // US949836 : New Budget Type field changes replaced txt field with new global picklist field
             
              if(pfr.Core_MDF_Program__c == 'Channel MDF' && pfr.Core_MDF_Proposal_Based_Ind__c == true){
                  pfr.Core_MDF_Reimbursement_Rate_txt__c = campIdRRStrMap.get(pfr.CampaignId);
              }
              if(pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name')){
                   pfr.Core_MDF_Reimbursement_Rate_txt__c = pfr.Core_MDF_Reimbursement_Rate_pct__c;                  
              }else if((pfr.Core_MDF_Budget_Type_nm__c == 'CCF 1.0' || pfr.Core_MDF_Budget_Type_nm__c == 'DCF 1.0') || 
                         pfr.Core_MDF_Budget_Type_nm__c == NULL){
                    //For CCP Programs
                    //To calculate Incentive
                    Decimal pfrInc = (pfr.Core_MDF_Incentive_pct__c != NULL? (pfr.Core_MDF_Incentive_pct__c) : 0);
                    if(String.isNotBlank(pfr.CampaignId)){
                        reimursmentRate = campIdRRStrMap.get(pfr.CampaignId);
                    }                        
                    
                    //To remove '%' from Campaign.Core_MDF_Reimbursement_Rate__c
                    Decimal rrWoPercentage = Decimal.valueof(reimursmentRate.left(reimursmentRate.length()-1));
                    
                    if(pfr.Core_MDF_ActivityCategory__c == 'Event' && pfr.Core_MDF_Competitive_Elements__c == 'Yes'){
                        decimalRR = (rrWoPercentage + pfrInc)/ 2; 
                    }
                    else {
                        if(pfr.Core_MDF_ActivityCategory__c == 'Print Media'){
                            decimalRR = ((rrWoPercentage + pfrInc)*((pfr.Core_MDF_EligibleSpace__c).setScale(2))).setScale(1);                         
                        }else {                                
                            decimalRR = (rrWoPercentage + pfrInc);
                        }
                        decimalRR = (decimalRR > 100? 100: decimalRR);
                    }
                    rRate = String.valueOf(decimalRR);
                    if(rRate.endswith('.0')){  rRate = rRate.removeEnd('.0'); 
                    }
        if(rRate.endswith('.00')){  rRate = rRate.removeEnd('.00'); 
                    }
                    //To append '%' for RR                              
                    if(String.isNotBlank(rRate) && !rRate.endsWith('%')){
                        rRate = rRate + '%';
                    } 
                    pfr.Core_MDF_Reimbursement_Rate_txt__c = rRate;
                }                                             
             //TWC702-121-CMP Budget Type - RR% change on Competitive Elements Question
                 else if(pfr.Core_MDF_Budget_Type_nm__c == 'OEM CMP' || pfr.Core_MDF_Budget_Type_nm__c == 'Service Provider CMP'){
                    Decimal pfrInc = (pfr.Core_MDF_Incentive_pct__c != NULL? (pfr.Core_MDF_Incentive_pct__c) : 0);
                    if(String.isNotBlank(pfr.BudgetId)){
                        reimursmentRate = cmpRRateMap.get(pfr.BudgetId);
                    }   
                    //To remove '%' from Campaign.Core_MDF_Reimbursement_Rate__c
                    Decimal rrWoPercentage = Decimal.valueof(reimursmentRate.left(reimursmentRate.length()-1));      
                    if(pfr.Core_MDF_ActivityCategory__c == 'Event' && (pfr.Core_MDF_Activity_Types__c == 'Joint Event' || pfr.Core_MDF_Activity_Types__c == 'Third Party Event') && pfr.Core_MDF_Competitive_Elements__c == 'Yes'){
                        decimalRR = (rrWoPercentage + pfrInc)/ 2; 
                    }else {                                
                            decimalRR = (rrWoPercentage + pfrInc);
                    }
                    rRate = String.valueOf(decimalRR);
                    
                    if(rRate.endswith('.0')){   
                        rRate = rRate.removeEnd('.0'); 
                    }
                    if(rRate.endswith('.00')){
                        rRate = rRate.removeEnd('.00'); 
                    }         
                    //To append '%' for RR                              
                    if(String.isNotBlank(rRate) && !rRate.endsWith('%')){
                        rRate = rRate + '%';
                    } 
                    pfr.Core_MDF_Reimbursement_Rate_txt__c = rRate; 
                } 
                
            }//end of for  
        	}*/
    
        
/****************************************************************************************************** 
Method Name:        setATFFlag
@return  :          
@parameters:        pfr list, oldpfr map
Description:        Setting of ATF Flag in different statuses 

Added By:           Bishanka 
Date:               16/08/2022
*******************************************************************************************************/
    /*public static void setATFFlag(PartnerFundRequest pfr,Map<Id,PartnerFundRequest> oldPfrMap)
    {
        //ATF Flag
        String atfDate = System.Label.Core_MDF_ATF_Insertion_Status;
        String atfPlannedStatus = System.Label.Core_MDF_ATF_Planned_Status;
        String atfRRStatus = System.Label.Core_MDF_ATF_RR;
        String atfClosedStatus = System.Label.Core_MDF_ATF_Closed_Status;
        Boolean isfieldModified;
        
        if(oldPfrMap != NULL && (oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Revision Required' 
                                || oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Planned')){
            isfieldModified = isfieldModified('PartnerFundRequest', 'Core_MDF_Activity_UI_Fieldset', pfr, oldPfrMap);
        }
       if(pfr.Core_MDF_Program__c != Label.Core_MDF_CCFB_Program_Name  && 
               pfr.Core_MDF_Program__c != Label.Core_MDF_SPCF_Program_Name  && 
               pfr.Core_MDF_Budget_Type_nm__c != Label.Core_MDF_BudgetType_CCF1_0 
               && pfr.Core_MDF_Budget_Type_nm__c != Label.Core_MDF_BudgetType_DCF1_0){
                
                // Insert Record
                if((oldPfrMap == NULL && pfr.Core_MDF_Start_Date__c < System.today()) || 
                   (oldPfrMap != NULL && oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c != pfr.Core_MDF_Start_Date__c && pfr.Core_MDF_Start_Date__c < System.today())){
                       if(String.isBlank(pfr.Core_MDF_ATF_Flag_nm__c)){
                           pfr.Core_MDF_ATF_Flag_nm__c= atfDate ;
                       }
                       else if(!pfr.Core_MDF_ATF_Flag_nm__c.contains(atfDate)){
                           pfr.Core_MDF_ATF_Flag_nm__c=pfr.Core_MDF_ATF_Flag_nm__c+';'+atfDate ;
                       }
                   }
                
                // Update Record
                if((oldPfrMap !=NULL && pfr.Core_MDF_Start_Date__c < System.today() && oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c < System.today()) ||
                   (oldPfrMap != NULL && oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c < System.today()
                    && oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c != pfr.Core_MDF_Start_Date__c ))
                {
                   
                     if (oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Revision Required' 
                        && isfieldModified == true){
                        if(String.isBlank(pfr.Core_MDF_ATF_Flag_nm__c)){
                            pfr.Core_MDF_ATF_Flag_nm__c= atfRRStatus ;
                        }
                        else if(!pfr.Core_MDF_ATF_Flag_nm__c.contains(atfRRStatus)){
                            pfr.Core_MDF_ATF_Flag_nm__c=pfr.Core_MDF_ATF_Flag_nm__c+';'+ atfRRStatus ;
                        }
                    }
                    // Setting ATF Flag for edit in Planned Status
                    if (oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Planned' && isfieldModified == true)
                       {
                           
                            if(String.isBlank(pfr.Core_MDF_ATF_Flag_nm__c)){
                                pfr.Core_MDF_ATF_Flag_nm__c = atfPlannedStatus ;
                            }
                            else if(!pfr.Core_MDF_ATF_Flag_nm__c.contains(atfPlannedStatus)){
                                pfr.Core_MDF_ATF_Flag_nm__c=pfr.Core_MDF_ATF_Flag_nm__c+';'+atfPlannedStatus ;
                            }
                        }
                }
        }
    }*/
 
/****************************************************************************************************** 
Method Name:        isfieldModified
@return  :          Boolean
@parameters:        objectName, fieldSetName, newObject, oldObjectmap
Description:        Get boolean value if any field modified from oldObjRecord to newObjeRecord using fieldset
Added By:           Saikat 
Date:               29/08/2022
*******************************************************************************************************/    

    /*public static Boolean isfieldModified(String objectName, String fieldSetName, 
                                           SObject newObject, Map<Id, SObject> oldObjectmap){        
        Boolean isFldModified = false;    
        List<Schema.FieldSetMember> fieldSetMemberList =  Schema.getGlobalDescribe().get(objectName).getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
          if(!fieldSetMemberList.isEmpty()){
             for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
                 String fieldAPIName = (String)fieldSetMemberObj.getFieldPath();
                 String fieldType = String.valueOf(fieldSetMemberObj.getType());
                 if((fieldType == 'STRING' || fieldType == 'TEXTAREA') && 
                    oldObjectmap.get(newObject.Id).get(fieldAPIName) != NULL &&  newObject.get(fieldAPIName) != NULL){
                     string oldFieldVal = (string)oldObjectmap.get(newObject.Id).get(fieldAPIName);
                     string newFieldVal = (string)newObject.get(fieldAPIName);
                     if(!oldFieldVal.equals(newFieldVal)){
                         isFldModified = true;
                         break;
                     }
                 } else {
                     if(oldObjectmap.get(newObject.Id).get(fieldAPIName) != newObject.get(fieldAPIName)){
                         isFldModified = true;
                         break;
                     } 
                 }
              }
          }
        return isFldModified;
    }*/
    
    /*public static String getRecordTypeDevloperNameById(String objName, Id recTypeId)
    {
        return Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosById().get(recTypeId).getDeveloperName();
    }
    public static Map<String, Date> getActivitySubDueDate(Map<String, Date> dueDateMap){
        Map<String, Date> actSubDueDateMap = getDueDate(dueDateMap,'ActSubDueDate');
        return actSubDueDateMap;
    }
      public static map<string,date> getActClosureExtensionDate(map<string,date> dueDateMap){
        map<string,date> actSubDueDateMap = getDueDate(dueDateMap,'ActClosureDate');
        
        return actSubDueDateMap;
    }
     private static Map<String, Date> getDueDate(Map<String, Date> submissionDueDateMap, String window){
        Map<String, Date> dueDateMap = new Map<String, Date>();
        Map<String, List<InternalMetdata>> ruleToMtdMap = new Map<String, List<InternalMetdata>>{};
            
            // the key will be-> pgm:budgettype:geo:subgeo:country:date
            // date will be input and parsed as per user locale. input date = date.format()(may need to change after discussion)
            
            Set<String> keySet = new Set<String>{};
                try{
                    for(String strKey : submissionDueDateMap.keySet()){
                        String key = strKey.substringbeforelast(':');
                        keySet.add(key);
                       
                    }
                     
                    Map<String, Core_MDF_CCP_Submission_Window__mdt> inputKeyToMtdMap = getMetadataValuesForKeyApplied(keySet);
                    
                    if(submissionDueDateMap != null && !submissionDueDateMap.isEmpty()){
                        for(String strKey : submissionDueDateMap.keySet()){
                            
                            if(dueDateMap.containsKey(strKey)){
                                continue;
                            }
                            String key = strKey.substringbeforelast(':');
                            String dtStr = strKey.substringafterlast(':');
                            date dt;
                            try{
                                dt = date.parse(dtStr);
                            }catch(Exception ex){
                                
                                continue;
                            }
                            if(dt != null){
                                Core_MDF_CCP_Submission_Window__mdt mtd = inputKeyToMtdMap.get(key);
                                // get quarter value from metadata
                                if(mtd != null && mtd.Core_MDF_Quarter__c != null){
                                    integer qtrVal = integer.valueOf(mtd.Core_MDF_Quarter__c);
                                    date qtrEndDate = getQuarterEndDate(dt,qtrVal);
                                   
                                    if(window.equalsIgnoreCase('ActSubDueDate')){
                                        InternalMetdata intMtd = new InternalMetdata();
                                        intMtd.rule=mtd.Core_MDF_Activity_Auto_Closure_Rule__c;
                                        intMtd.mtd=mtd;
                                        intMtd.dt=qtrEndDate;
                                        dueDateMap.put(strKey, getDate(intMtd));                                
                                    }
                                     if(window.equalsIgnoreCase('ActClosureDate')){
                                        InternalMetdata intMtd = new InternalMetdata();
                                        intMtd.rule=mtd.Core_MDF_Closure_date_Extension_Rule__c;
                                        intMtd.mtd=mtd;
                                        intMtd.dt=qtrEndDate;
                                        dueDateMap.put(strKey, getDate(intMtd));                                
                                    } 
                                }
                            }
                        }
                    } 
                }
        catch(exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        
        return dueDateMap;
    }
      private static Map<String,Core_MDF_CCP_Submission_Window__mdt> getMetadataValuesForKeyApplied(Set<String> keySet){
        Map<String,Core_MDF_CCP_Submission_Window__mdt> keyToAppliedMetadataMap = new Map<String,Core_MDF_CCP_Submission_Window__mdt>{};  
            Map<String,Core_MDF_CCP_Submission_Window__mdt> ncClosureMap = createSubmissionAndClosureMap();       
       
        for(String key : keySet){
            Core_MDF_CCP_Submission_Window__mdt mtd;
            if(ncClosureMap != null && !ncClosureMap.isEmpty()){
                String keyApplied;
                // get the metadata as per the key pgm:budgettype:geo:subgeo:country
                if(ncClosureMap.containsKey(key)){
                    keyApplied=key;
                    mtd = ncClosureMap.get(key);
                }else{
                    // if no metadata as per above, then keep checking the metdatda by subgeo, geo, budgettype, programme
                    list<String> keyList = key.split(':');
                    String programme = keyList[0];
                    String budgetType = keyList[1];
                    String geo = keyList[2];
                    String subGeo = keyList[3];
                    
                    String keySubGeo = programme +':'+ budgetType +':'+ geo +':'+ subGeo +':'+ 'null';
                    String keyGeo = programme +':'+ budgetType +':'+ geo +':'+ 'null' +':'+ 'null';
                    String keyPgmBudget = programme +':'+ budgetType +':'+ 'null' +':'+ 'null' +':'+ 'null';
                    String keyPgm = programme +':'+ 'null' +':'+ 'null' +':'+ 'null' +':'+ 'null';
                    
                    
                    if(ncClosureMap.containsKey(keySubGeo)){
                        keyApplied = keySubGeo;
                    }else if(ncClosureMap.containsKey(keyGeo)){
                        keyApplied = keyGeo;
                    }else if(ncClosureMap.containsKey(keyPgmBudget)){
                        keyApplied = keyPgmBudget;
                    }else if(ncClosureMap.containsKey(keyPgm)){
                        keyApplied = keyPgm;
                    }
                    
                    
                    if(String.isNotBlank(keyApplied)){
                        mtd = ncClosureMap.get(keyApplied);
                    }
                }

            }
            keyToAppliedMetadataMap.put(key,mtd);
        }
        
      
        return keyToAppliedMetadataMap;
    }
    
    private static Map<String,Core_MDF_CCP_Submission_Window__mdt> createSubmissionAndClosureMap(){
        Map<String,Core_MDF_CCP_Submission_Window__mdt> submissionAndClosureMap = new Map<String,Core_MDF_CCP_Submission_Window__mdt>();
        List<Core_MDF_CCP_Submission_Window__mdt> ncClosureMtdList = [SELECT Core_MDF_Program__c, Core_MDF_Budget_Type__c, 
                                                                      Core_MDF_Geo__c, Core_MDF_Sub_Geo__c, Core_MDF_Country__c,
                                                                      Core_MDF_Quarter__c,Core_MDF_Case_SLA__c, Core_MDF_Claim_Submission_Window_mnth__c, Core_MDF_Claim_Submission_Window_days__c,
                                                                      Core_MDF_Doc_Submission_Window__c,Core_MDF_Doc_Submission_Rule__c,
                                                                      Core_MDF_Escalation_Submission_Window__c,Core_MDF_Escalation_Submission_Rule__c,
                                                                      Core_MDF_Activity_Auto_Closure_SLA__c,Core_MDF_Closure_date_Extension_Rule__c,Core_MDF_Closure_Date_Extension__c,Core_MDF_Activity_Auto_Closure_SLA_Month__c,
                                                                      Core_MDF_Activity_Auto_Closure_Rule__c    
                                                                      FROM Core_MDF_CCP_Submission_Window__mdt
                                                                      WHERE Core_MDF_Active__c = TRUE
                                                                      AND Core_MDF_Program__c != NULL 
                                                                     
                                                                     ];
      
        for(Core_MDF_CCP_Submission_Window__mdt mtd : ncClosureMtdList){
            String key = mtd.Core_MDF_Program__c +':'+mtd.Core_MDF_Budget_Type__c+':'+mtd.Core_MDF_Geo__c +':'+mtd.Core_MDF_Sub_Geo__c +':'+mtd.Core_MDF_Country__c; 
            key = key.deleteWhitespace();
            submissionAndClosureMap.put(key,mtd);
        }
      
        return submissionAndClosureMap;
    }
    
    private static Date getDate(InternalMetdata intMtd){
        
        List<String> rulesplit = new List<String>();
        Date returnDate = intMtd.dt;
        if(intMtd.rule.contains('+')){
            rulesplit = intMtd.rule.split('\\+');
        }
        else{
            rulesplit.add(intMtd.rule);
        }
      
        if(rulesplit!=null){
            for(String rule : rulesplit){
                if(rule=='Core_MDF_Activity_Auto_Closure_SLA__c'){
                   
                    returnDate = getActSubDueDate(returnDate,intMtd.mtd);
                }
                if(rule=='Core_MDF_Activity_Auto_Closure_SLA_Month__c'){
                    returnDate = getActSubDueDate(returnDate,intMtd.mtd);
                }
                if(rule=='Core_MDF_Closure_Date_Extension__c'){
                   
                   returnDate = getcloseExtensionDate(returnDate,intMtd.mtd); 
                }
                
            }
        }
   
        return returnDate;
    }
    
    private static date getQuarterEndDate(date dt, integer qtrVal){
        date qtrEndDate;
        if(qtrVal == 0){
            qtrEndDate = dt;
        }
        else{
            integer noOfMonthsPerQtr = 12/qtrVal;
            date firstDayCurrentYear = date.newinstance(dt.year(),1,1);
          
            date claimSubmissionDueDt;
            for(integer i=noOfMonthsPerQtr; i<=12; i+=noOfMonthsPerQtr){
                
                qtrEndDate = firstDayCurrentYear.addmonths(i);
                qtrEndDate = qtrEndDate.addDays(-1);
                if(dt <= qtrEndDate){
                    break;
                }
            }
        }
        
        return qtrEndDate;
    }
    
    private class InternalMetdata {
        String rule;
        Core_MDF_CCP_Submission_Window__mdt mtd;
        Date dt;
    }
    
    public static date getActSubDueDate(date dt, Core_MDF_CCP_Submission_Window__mdt mtd){
        date actSubDueDate;
        if(dt != null && mtd != null){
            if(mtd.Core_MDF_Activity_Auto_Closure_SLA_Month__c != null && mtd.Core_MDF_Activity_Auto_Closure_SLA_Month__c > 0 ){
                integer actSubClosureWindowAddMnths = integer.valueOf(mtd.Core_MDF_Activity_Auto_Closure_SLA_Month__c);
                actSubDueDate = dt.addMonths(actSubClosureWindowAddMnths);
                if(mtd.Core_MDF_Quarter__c > 0){
                    integer numberOfDays = Date.daysInMonth(actSubDueDate.year(), actSubDueDate.month());
                    actSubDueDate = Date.newInstance(actSubDueDate.year(), actSubDueDate.month(), numberOfDays);
                }
            }else if(mtd.Core_MDF_Activity_Auto_Closure_SLA__c != null && mtd.Core_MDF_Activity_Auto_Closure_SLA__c > 0 ){
                integer actSubClosureWindowAddDays = integer.valueOf(mtd.Core_MDF_Activity_Auto_Closure_SLA__c);
                actSubDueDate = dt.addDays(actSubClosureWindowAddDays);
                
            }

        }
        
        return actSubDueDate;
    }
    
     public static date getcloseExtensionDate(date dt, Core_MDF_CCP_Submission_Window__mdt mtd){
        date actSubDueDate;
        
        if(dt != null && mtd != null){
            if(mtd.Core_MDF_Closure_Date_Extension__c != null && mtd.Core_MDF_Closure_Date_Extension__c > 0){
                integer actSubClosureWindowAddDays =  integer.valueOf(mtd.Core_MDF_Closure_Date_Extension__c);
                actSubDueDate = system.today().addDays(actSubClosureWindowAddDays);
            }
            else
            {
                actSubDueDate = getActSubDueDate(dt, mtd);
            }
        }
        return actSubDueDate;
    }*/