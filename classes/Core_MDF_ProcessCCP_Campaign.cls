//Core_MDF_ProcessCCP_Campaign_Test
public without sharing class Core_MDF_ProcessCCP_Campaign {
    
    public static Id dcfRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Data_Center_CoMarketing_Fund').getRecordTypeId();
    public static Id ccfRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId(); 
    public static Id ipaRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    public static Id retailRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();    
    public static Id eefRecordTypeId =  Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();   
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();    
    Public static string TYPE_CLAIM = Core_MDF_CCP_ConstantClass.TYPE_CLAIM;
    Public static string ESC_APPROVED_STATUS = Core_MDF_CCP_ConstantClass.ESC_APPROVED_STATUS;
    public static String EEF_PROGRAM = 'Ecosystem Extension Fund';
    
    //Below list and Static block is added by Shridhar to fetch all Co-Marketing record type
    public static List<Id> coMarketingCampaignRecordTypeID  = new List<Id>();
    public static List<Id> opalCampaignRecordTypeID  = new List<Id>();      
    
    //Below list will contain CCP Campaign Record Types like CCF/DCF/SPCF/CCF Boost
    public static List<Id> countryRecordTypeIdList = new List<Id>();
    
    //Below list will contain CCP Campaign Record Types like Retail
    public static List<Id> geoRecordTypeIdList = new List<Id>();
    
    //Below Map will contain Map of country and countryGeoSubGeoWrapper
    public static Map<String,Core_MDF_GeoBasedGenericSharing.countryGeoSubGeoWrapper> wrapperMap = new Map<String,Core_MDF_GeoBasedGenericSharing.countryGeoSubGeoWrapper>();
    
    Static{
        //Call the getCountryGeoMap method from Core_MDF_GeoBasedGenericSharing class
        wrapperMap = Core_MDF_GeoBasedGenericSharing.getCountryGeoMap();
        
        List<String> recTypeDeveloperName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_RecordType_API_Name').split(',');
        for(String str: recTypeDeveloperName){
            coMarketingCampaignRecordTypeID.add(Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(str).getRecordTypeId());
            if(!Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CampaignWithoutCountry').Contains(str)){
                countryRecordTypeIdList.add(Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(str).getRecordTypeId());
            }
            if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CampaignWithoutCountry').Contains(str)){
                geoRecordTypeIdList.add(Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(str).getRecordTypeId());
            }
        }
                   
    }
    public static void determineCampaignAttributes(List<Campaign> newCmpList, Map<Id,Campaign> campOldMap, Boolean isInsert, Boolean isUpdate){       
        String tempStr;
        Boolean getvirtualcorp=false;
        List<String> listTempString = new list<String>();
        List<String> activityWithCategory = new list<String>();
        Set<String> activitySet = new Set<String>();
        Set<String> categorySet = new Set<String>();      
        list<ChannelProgram> program = new list<ChannelProgram>();
        List<Campaign> cmpListForGeoUpdate = new List<Campaign>();
        Set<Id> accIdSet = new Set<Id>();
        Map<Id,String> accIdGeoMap = new Map<Id,String>();
        Set<Id> accIdPmbSet = new Set<Id>();
        Set<String> BudgetTypeCamp = new Set <String>();
        Date CampEarliestStartDate = Date.today();
        Date CampEarliestFutureStartDate = Date.today();
        List<Campaign> RMFBudgettoCampaignList = new List<Campaign>();
        //Map of accId and acc's sub geo 
        Map<Id,String> accIdSubGeoMap = new Map<Id,String>();
        Set<String> finalGeoSet = new Set<String>();
        //US819148 : [CCP] Campaign Level CAP - Campaign Validations
        Map<id,decimal> campaignIDToCAPAmountMap = new Map<id,decimal>();
        Map<id,decimal> campaignIDToExistingCAPAmountMap = new Map<id,decimal>();
        Map<id,String> campaignIDToBudgetRecord = new Map<id,String>();
        Map<String,List<PartnerMarketingBudget>> RMFCamptoBudgettypeMap = new Map<String,List<PartnerMarketingBudget>>();
        Map<Id, Set<Id>> accIdSetUltimate = new Map<Id,Set<Id>>();
        Map <Id,Id> AccNodeVirtualCorpMap = new Map <Id,Id> ();
        List<Campaign> ipaCmpList = new  List<Campaign>();
        Map<Id,Campaign> ipaOldMap = new Map<Id,Campaign>();
        List<Campaign> ccfCmpList = new  List<Campaign>();
        Map<Id,Campaign> ccfOldMap = new Map<Id,Campaign>();
        List<Campaign> dcfCmpList = new  List<Campaign>();
        Map<Id,Campaign> dcfOldMap = new Map<Id,Campaign>();
        List<Campaign> rmfCmpList = new  List<Campaign>();
        Map<Id,Campaign> rmfOldMap = new Map<Id,Campaign>();
        List<Campaign> eefCmpList = new  List<Campaign>();
        Map<Id,Campaign> eefOldMap = new Map<Id,Campaign>();
        boolean error = false;
        
        //Label contains CCF/DCF/SPCF
        //List<String> campaignsToCheckForTechnologyEdit = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CampProgramsForTechnologyCheck').split(';');
        
        //Retrieve Id for Channel Programs
        program = [select id , Core_MDF_Technical_Program_Name__c from ChannelProgram LIMIT 100];
        //where Core_MDF_Technical_Program_Name__c LIKE '%Marketing%'
        Map<String, Id> programtype = new Map<String, Id>();
        for(ChannelProgram cp: program){
            programtype.put(cp.Core_MDF_Technical_Program_Name__c, cp.id);
        }
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Campaign').getDescribe().fields.getMap();
        
        Set<Id> campIdSet = new Set<Id>();  
        Map<Id,List<Id>> cmpIdPfrIdListMap = new Map<Id,List<Id>>();
        Map<String,List<Id>> cmpIdPfrIdBudgetListMap = new Map<String,List<Id>>();
        Map<String,List<Id>> cmpIdBudgetIdListMap = new Map<String,List<Id>>();
        Map<Id,List<String>> cmpIdfieldListMap = new Map<Id,List<String>>();
        Map<Id,List<String>> cmpIdTextFieldListMap = new Map<Id,List<String>>();
        Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
        Map<Id,PartnerFundRequest> pfrBudgetMap = new Map<Id,PartnerFundRequest>();
        Map<Id,Core_MDF_Campaign_Budgets__c > BudgetMap = new Map<Id,Core_MDF_Campaign_Budgets__c>();
        
        //US630940
        Map<String, String> cmpProgWithTextfieldsMap = new Map<String, String>();
        Map<String, String> cmpProgWithPLfieldsMap = new Map<String, String>();
        Map<String, String> cmpProgWithCampNotEditFieldsMap = new Map<String, String>();
        List<String> subGeoLst = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SubGeos').split(';');
        Map<String, Schema.DisplayType> cmpFieldtoFieldDataType = new Map<String, Schema.DisplayType>();
        Map<String, String> cmpFieldtoFieldLabel = new Map<String, String>();
        
        
        for(Core_MDF_ChannelProgram__mdt cp : [Select Id, Core_MDF_Technical_Program_Name__c,Core_MDF_Campaign_Picklist_Fields__c,
                                                Core_MDF_Campaign_Text_Fields__c,Core_MDF_CampNotEditFieldsWhenPFRExists__c
                                               FROM Core_MDF_ChannelProgram__mdt LIMIT 1000]){
                                                   String key = cp.Core_MDF_Technical_Program_Name__c;
                                                   cmpProgWithPLfieldsMap.put(key, cp.Core_MDF_Campaign_Picklist_Fields__c);
                                                   cmpProgWithTextfieldsMap.put(key, cp.Core_MDF_Campaign_Text_Fields__c);        
                                                    cmpProgWithCampNotEditFieldsMap.put(key, cp.Core_MDF_CampNotEditFieldsWhenPFRExists__c);
                                               }
        
        for(Campaign cmp: newCmpList){
                if (cmp.Status != null && cmp.Status != 'Draft' &&  cmp.Core_MDF_External_Visibility_Date__c== null && cmp.Core_MDF_Campaign_Source_nm__c != 'Target Setting') {
                    cmp.Core_MDF_External_Visibility_Date__c = Date.today();
                }
                Integer startYear = cmp.startDate.year();
            	Integer endYear = cmp.EndDate.year();
                cmp.Core_MDF_Supports_legacy_program__c = setSupportLegacyProgramField(startYear,cmp.Core_MDF_Opal_Budget_Type_Txt__c,cmp.Core_MDF_Program__c,endYear); 
            if(geoRecordTypeIdList.contains(cmp.RecordTypeId)){                
                accIdSet.add(cmp.Core_MDF_Account__c);
                //Populate Budget type and start date and end date//btype,sd,ed,account
                if(isInsert || (isUpdate && (campOldMap.get(cmp.Id).Core_MDF_Opal_Budget_Type_Txt__c != cmp.Core_MDF_Opal_Budget_Type_Txt__c ||
                                             campOldMap.get(cmp.Id).StartDate != cmp.StartDate || campOldMap.get(cmp.Id).EndDate != cmp.EndDate ||
                                             campOldMap.get(cmp.Id).Core_MDF_Account__c != cmp.Core_MDF_Account__c)))
                {
                    if (cmp.Core_MDF_Opal_Budget_Type_Txt__c =='Retail MDF'){
                        BudgetTypeCamp.add(cmp.Core_MDF_Opal_Budget_Type_Txt__c);
                        
                        if(cmp.StartDate < CampEarliestFutureStartDate ){
                            if(cmp.StartDate < CampEarliestStartDate ){   
                                CampEarliestStartDate =cmp.StartDate;
                            }
                        }
                        else{
                            CampEarliestFutureStartDate = cmp.StartDate;
                            if(cmp.StartDate < CampEarliestFutureStartDate ){   
                                CampEarliestFutureStartDate =cmp.StartDate;     
                            }
                        }
                        RMFBudgettoCampaignList.add(cmp);
                    }
                }
                
            }
            //US773772: All CCP Programs - Editing Campaign Start date and end date when an activity already exists
            //Populate campIdSet when Start/End Date changed for CCP Campaigns
	    
            if((countryRecordTypeIdList.contains(cmp.RecordTypeId) || cmp.RecordTypeId  == retailRecordTypeId) && (isUpdate && (cmp.StartDate != campOldMap.get(cmp.Id).StartDate || cmp.EndDate != campOldMap.get(cmp.Id).EndDate || (cmp.Status == 'Cancelled' && cmp.Status != campOldMap.get(cmp.Id).Status)))){  
                campIdSet.add(cmp.Id);
            } 
            //Populate campIdSet when Budget_Amount changes for Retail Campaign
            if((cmp.RecordTypeId  == retailRecordTypeId ||cmp.RecordTypeId == ccfRecordTypeId)  && (isUpdate && (cmp.Core_MDF_Budget_Amount_amt__c != campOldMap.get(cmp.Id).Core_MDF_Budget_Amount_amt__c ))){ 
                if((cmp.Core_MDF_Budget_Amount_amt__c > campOldMap.get(cmp.Id).Core_MDF_Budget_Amount_amt__c ) && cmp.RecordTypeId  == retailRecordTypeId)
                {
                    cmp.Core_MDF_RMF_Delta_Budget_Amt__c = cmp.Core_MDF_Budget_Amount_amt__c - campOldMap.get(cmp.Id).Core_MDF_Budget_Amount_amt__c;
                }
                campIdSet.add(cmp.Id); 
            }
            if(cmp.RecordTypeId  == ccfRecordTypeId && cmp.Core_MDF_Supports_legacy_program__c != 'Yes' && isUpdate){
                
                campIdSet.add(cmp.Id);
            }
            //NP- WW33 Check if Total Campaign Cost and Country/Region is changed
                if(((cmp.RecordTypeId  == ipaRecordTypeId && !cmp.Core_MDF_Proposal_Based_Ind__c) || cmp.RecordTypeId == eefRecordTypeId) && isUpdate){
                    campIdSet.add(cmp.Id);
            }
            
            if(isUpdate){
                    //NP - WW33 IPA Account Based - Do not edit RR, Custom RR and Budget type if active activites are present
                    /*else if(cmp.RecordTypeId  == ipaRecordTypeId && !cmp.Core_MDF_Proposal_Based_Ind__c){
                        String removeAllAttr =   cmpProgWithPLfieldsMap.remove(cmp.Core_MDF_Program__c);
                        cmpProgWithPLfieldsMap.put(cmp.Core_MDF_Program__c,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Account_Fields_Validation'));
                        
                    }*/
                    
                    // US773817,US773834 Edit OPAL campaign, if campaign has active activities and fields " Priorities, Audience, Technology, Activity Category, Country/Region, Brand" are change to some other values it throws and error - END
                for(String strField: cmpProgWithPLfieldsMap.get('All Campaign Fields').Split(',')){
                    Schema.DisplayType campFieldDataType = fieldMap.get(strField).getDescribe().getType();
                    if(campFieldDataType != null){
                        cmpFieldtoFieldDataType.put(strField,campFieldDataType);
                        }    
                    String labelValue = fieldMap.get(strField).getDescribe().getLabel();
                    if(labelValue != null){
                        cmpFieldtoFieldLabel.put(strField,labelValue);
                    }
                }
                //for text fields
                if(cmpProgWithTextfieldsMap.containsKey(cmp.Core_MDF_Program__c) && cmpProgWithTextfieldsMap.get(cmp.Core_MDF_Program__c) != NULL){
                    for(String textFields: cmpProgWithTextfieldsMap.get(cmp.Core_MDF_Program__c).Split(',')){
                        if(campOldMap.get(cmp.Id).get(textFields) != NULL && campOldMap.get(cmp.Id).get(textFields) != cmp.get(textFields)){                              
                            campIdSet.add(cmp.Id);
                            String labelValue = fieldMap.get(textFields).getDescribe().getLabel();
                            
                            if(labelValue == 'Name'){
                                labelValue = labelValue.replace('Name','Campaign Name');
                            }
                            if(cmpIdTextFieldListMap.containsKey(cmp.Id)){
                                
                                cmpIdTextFieldListMap.get(cmp.Id).add(labelValue);
                            }else{
                                cmpIdTextFieldListMap.put(cmp.Id, new List<String>{labelValue});
                                
                            }
                        }
                    } 
                }
                //US819148 : [CCP] Campaign Level CAP - Campaign Validations
                if(cmp.Core_MDF_Spending_Cap_Amt__c != campOldMap.get(cmp.Id).Core_MDF_Spending_Cap_Amt__c){
                    campaignIDToCAPAmountMap.put(cmp.id,cmp.Core_MDF_Spending_Cap_Amt__c);
                } 
                 //Adding new Campaign Id and Old campaign in Map based on Program
                if(cmp.RecordTypeId  == ipaRecordTypeId && !cmp.Core_MDF_Proposal_Based_Ind__c){
                    ipaCmpList.add(cmp);
                    ipaOldMap.put(cmp.id,campOldMap.get(cmp.Id));
                }
                if(cmp.RecordTypeId == retailRecordTypeId){
                    rmfCmpList.add(cmp);
                    rmfOldMap.put(cmp.id,campOldMap.get(cmp.Id));
                }
                if(cmp.RecordTypeId == ccfRecordTypeId){
                    ccfCmpList.add(cmp);
                    ccfOldMap.put(cmp.id,campOldMap.get(cmp.Id));
                }
                if(cmp.RecordTypeId == dcfRecordTypeId){
                    dcfCmpList.add(cmp);
                    dcfOldMap.put(cmp.id,campOldMap.get(cmp.Id));
                }
                    if(cmp.RecordTypeId == eefRecordTypeId){
                        eefCmpList.add(cmp);
                        eefOldMap.put(cmp.id,campOldMap.get(cmp.Id));
            }
        }
            }
        
        if(campaignIDToCAPAmountMap.size() > 0){
            campaignIDToExistingCAPAmountMap = calculatecampaignCAPAmount(campaignIDToCAPAmountMap.keyset());
        }
        
        //NP - WW33 Check if picklist is used in Active Activities and remove if not used
            //Calling UscheckIfFieldsUsedInActivityNotRemoved based on Program.
            if(cmpProgWithPLfieldsMap.size()>0 && cmpFieldtoFieldDataType.size()>0 &&  cmpFieldtoFieldLabel.size()>0 && cmpProgWithCampNotEditFieldsMap.size()>0){
        if(ipaCmpList.size()>0){
                    error = Core_MDF_Proposal_Based_Campaign_Process.checkIfFieldsUsedInActivityNotRemoved(ipaCmpList,ipaOldMap,'Intel Partner Alliance',cmpProgWithPLfieldsMap,cmpFieldtoFieldDataType,cmpFieldtoFieldLabel,cmpProgWithCampNotEditFieldsMap);  //Roshan - Campaign trigger optimisation
            }
            if(rmfCmpList.size()>0){
                    error = Core_MDF_Proposal_Based_Campaign_Process.checkIfFieldsUsedInActivityNotRemoved(rmfCmpList,rmfOldMap,'Retail Marketing Funds',cmpProgWithPLfieldsMap,cmpFieldtoFieldDataType,cmpFieldtoFieldLabel,cmpProgWithCampNotEditFieldsMap);  //Roshan - Campaign trigger optimisation
            }
            if(ccfCmpList.size()>0){
                    error = Core_MDF_Proposal_Based_Campaign_Process.checkIfFieldsUsedInActivityNotRemoved(ccfCmpList,ccfOldMap, Core_MDF_CCP_ConstantClass.CCF_TECHNICAL_PROGRAM_NAME,cmpProgWithPLfieldsMap,cmpFieldtoFieldDataType,cmpFieldtoFieldLabel,cmpProgWithCampNotEditFieldsMap);  //Roshan - Campaign trigger optimisation
            }
            if(dcfCmpList.size()>0){
                    error = Core_MDF_Proposal_Based_Campaign_Process.checkIfFieldsUsedInActivityNotRemoved(dcfCmpList,dcfOldMap, Core_MDF_CCP_ConstantClass.DCF_TECHNICAL_PROGRAM_NAME,cmpProgWithPLfieldsMap,cmpFieldtoFieldDataType,cmpFieldtoFieldLabel,cmpProgWithCampNotEditFieldsMap);  //Roshan - Campaign trigger optimisation
            }
                if(eefCmpList.size()>0){
                    error = Core_MDF_Proposal_Based_Campaign_Process.checkIfFieldsUsedInActivityNotRemoved(eefCmpList,eefOldMap,EEF_PROGRAM,cmpProgWithPLfieldsMap,cmpFieldtoFieldDataType,cmpFieldtoFieldLabel,cmpProgWithCampNotEditFieldsMap);  //Roshan - Campaign trigger optimisation
                }
            }
        
        
        Set<Id> pfrIdToQueryClaimAmount = new Set<Id>();
        List<String> validClaimStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStatus_ActivityAutoClose').split(';');
        Map<Id, Decimal> pfrClaimAmtMap = new Map<Id, Decimal>();
        Map<Id, Decimal> pfrEscAmtMap = new Map<Id, Decimal>();
        //check if the Campaign has activity associated with it
        if(campIdSet != NULL){
            for(PartnerFundRequest pfr : [SELECT Id, CampaignId, Core_MDF_Fund_Request_Status__c, Amount,
                                            Core_MDF_Start_Date__c, Core_MDF_End_Date__c,Core_MDF_Budget_Type_nm__c,RequestedAmount,
                                            Core_MDF_Activity_Reimbursement_Amt_nbr__c,Core_MDF_Country_nm__c
                                          FROM PartnerFundRequest
                                          WHERE CampaignId IN: campIdSet AND Core_MDF_Fund_Request_Status__c != 'Cancelled' AND 
                                          ((Core_MDF_Fund_Request_Status__c = 'Closed' AND Core_MDF_Activity_Closure_Type__c IN ('Auto', 'Manual')) OR (Core_MDF_Fund_Request_Status__c != 'Closed'))]){
                                              if(cmpIdPfrIdListMap.containsKey(pfr.CampaignId)){
                                                  cmpIdPfrIdListMap.get(pfr.CampaignId).add(pfr.Id);
                                              }else{
                                                  cmpIdPfrIdListMap.put(pfr.CampaignId, new List<Id>{pfr.Id});
                                              }
                                              if(cmpIdPfrIdBudgetListMap.containsKey(pfr.CampaignId)){
                                                  cmpIdPfrIdBudgetListMap.get(pfr.CampaignId+pfr.Core_MDF_Budget_Type_nm__c).add(pfr.Id);
                                              }else{
                                                  cmpIdPfrIdBudgetListMap.put(pfr.CampaignId+pfr.Core_MDF_Budget_Type_nm__c, new List<Id>{pfr.Id});
                                              }
                                              if(pfr.Core_MDF_Fund_Request_Status__c == 'Closed')
                                              {
                                                  pfrIdToQueryClaimAmount.add(pfr.Id);
                                              }
                                              //US773772                             
                                              pfrMap.put(pfr.Id, pfr); 
                                              
                                              
                                          }
                if(pfrIdToQueryClaimAmount.size() > 0)
                {
                    for(PartnerFundClaim pfcObj : [SELECT Id, Amount, Core_MDF_Status__c, RequestId,BudgetId FROM PartnerFundClaim WHERE RequestId IN :pfrIdToQueryClaimAmount
                                                  and Core_MDF_Status__c IN :validClaimStatus and Core_MDF_Type_Txt__c =: TYPE_CLAIM AND Core_MDF_Escalation_Id__c = null])
                    {
                        if(pfrClaimAmtMap.containsKey(pfcObj.RequestId)){
                            pfrClaimAmtMap.put(pfcObj.RequestId, pfrClaimAmtMap.get(pfcObj.RequestId) + pfcObj.Amount);
                        }
                        else{pfrClaimAmtMap.put(pfcObj.RequestId, pfcObj.Amount);
                            }  
                    }
                    for(Core_MDF_Escalation__c escObj : [SELECT Core_MDF_Co_Marketing_Activity_id__c,Core_MDF_Approved_Amount_amt__c
                                                                                      FROM Core_MDF_Escalation__c
                                                                                      WHERE Core_MDF_Co_Marketing_Activity_id__c IN:pfrIdToQueryClaimAmount AND Core_MDF_Escalation_Status_nm__c =: ESC_APPROVED_STATUS])
                    {
                        if(pfrEscAmtMap.containsKey(escObj.Core_MDF_Co_Marketing_Activity_id__c)){
                            pfrEscAmtMap.put(escObj.Core_MDF_Co_Marketing_Activity_id__c, pfrEscAmtMap.get(escObj.Core_MDF_Co_Marketing_Activity_id__c) + escObj.Core_MDF_Approved_Amount_amt__c);
                        }
                        else{pfrEscAmtMap.put(escObj.Core_MDF_Co_Marketing_Activity_id__c, escObj.Core_MDF_Approved_Amount_amt__c);
                            }  
                    }
                }
            
            for(Core_MDF_Campaign_Budgets__c  cmpbudgets : [select id,Core_MDF_Budget_Amt__c,Core_MDF_Budget_Type_Nm__c,Core_MDF_Campaign_Id__c from Core_MDF_Campaign_Budgets__c  
                                          WHERE Core_MDF_Campaign_Id__c IN: campIdSet ]){ //cmpIdBudgetIdListMap//BudgetMap
                                              if(cmpIdBudgetIdListMap.containsKey(cmpbudgets.Core_MDF_Campaign_Id__c)){
                                                  cmpIdBudgetIdListMap.get(cmpbudgets.Core_MDF_Campaign_Id__c+cmpbudgets.Core_MDF_Budget_Type_Nm__c).add(cmpbudgets.Id+cmpbudgets.Core_MDF_Budget_Type_Nm__c);
                                              }else{
                                                  cmpIdBudgetIdListMap.put(cmpbudgets.Core_MDF_Campaign_Id__c+cmpbudgets.Core_MDF_Budget_Type_Nm__c, new List<Id>{cmpbudgets.Id});
                                              }
                                                                           
                                              BudgetMap.put(cmpbudgets.Id, cmpbudgets);
                                          }
            
        }
        //Prepare Map of accId and acc's geo 
        if(accIdSet.size() > 0){
            for(Account acc : [SELECT Id, Core_Geo__c, Core_Sub_Geo__c,
                               Core_MDF_CoMarketing_Ultimate_Account__c,
                               Core_MDF_Parent_Fund_Account__c FROM Account WHERE Id IN : accIdSet]){
                                   
                                   accIdGeoMap.put(acc.Id, acc.Core_Geo__c);
                                   if(subGeoLst.contains(acc.Core_Sub_Geo__c)){    
                                       //Prepare Map of accId and acc's sub geo for ASMO-LAR/NAR
                                       accIdSubGeoMap.put(acc.Id, acc.Core_Sub_Geo__c);
                                       
                                   }
                                   if (acc.Core_MDF_CoMarketing_Ultimate_Account__c != acc.Core_MDF_Parent_Fund_Account__c )//node account
                                   { //get the Id of the Virtual corp account
                                       getvirtualcorp=true;
                                       //AccNodeVirtualCorpMap.put(acc.id,acc.Core_MDF_Parent_Fund_Account__c);
                                       if(accIdSetUltimate.get(acc.Core_MDF_CoMarketing_Ultimate_Account__c)==null)
                                       {
                                           set<Id> nodeId = new set<Id>();
                                           nodeId.add(acc.Id);
                                           accIdSetUltimate.put(acc.Core_MDF_CoMarketing_Ultimate_Account__c,nodeId);
                                           
                                       }
                                       else{
                                           accIdSetUltimate.get(acc.Core_MDF_CoMarketing_Ultimate_Account__c).add(acc.Id);
                                       }
                                   }
                                   else{ //VirtualCorp
                                       accIdPmbSet.add(acc.Id);
                                       AccNodeVirtualCorpMap.put(acc.Id,acc.Id);
                                   }
                                   
                               }
            if(getvirtualcorp=true)
            {
                for (Account acc : [SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c FROM Account WHERE Core_MDF_Parent_Fund_Account__c IN: accIdSetUltimate.keyset() and Core_MDF_Channel_Program__r.name = 'Retail Marketing Funds' ])
                {
                    //Added by Sai for null pointer error fix
                    if(accIdSetUltimate.get(acc.Core_MDF_CoMarketing_Ultimate_Account__c) != null){
                        for(Id acc1 : accIdSetUltimate.get(acc.Core_MDF_CoMarketing_Ultimate_Account__c)){
                            AccNodeVirtualCorpMap.put(acc1,acc.id);
                        }
                    }
                    accIdPmbSet.add(acc.Id);
                    
                }
            }
            
        }
        if (accIdPmbSet.size()>0){
            RMFCamptoBudgettypeMap = queryPmbRecords(BudgetTypeCamp,CampEarliestStartDate,CampEarliestFutureStartDate,accIdPmbSet);
        }
        for(Campaign cmp: newCmpList){          
            String errorpickfields ='';
            String errortxtfields ='';           
            
            if(campIdSet.contains(cmp.Id) && cmpIdPfrIdListMap.containsKey(cmp.Id) && cmpIdPfrIdListMap.get(cmp.Id) != NULL){
                                           
            
                //US773772
                //Iterate over Activty ID's associated with Campaign
                //US773772 Edit OPAL campaign, if campaign has active activites and fields "Start Date , End date" are change it throws and error - start
                //TWC702-336
                if(cmp.RecordTypeId == retailRecordTypeId || (cmp.RecordTypeId == dcfRecordTypeId || cmp.RecordTypeId == ccfRecordTypeId ) || cmp.RecordTypeId == ipaRecordTypeId || cmp.RecordTypeId == eefRecordTypeId){
                    if(cmp.Core_MDF_Supports_legacy_program__c != 'Yes'){
                        for(Id pfr: cmpIdPfrIdListMap.get(cmp.Id)){                    
                            if(pfrMap.get(pfr) != NULL && (cmp.StartDate > pfrMap.get(pfr).Core_MDF_Start_Date__c || cmp.EndDate < pfrMap.get(pfr).Core_MDF_End_Date__c)){
                                cmp.addError(Label.Core_MDF_Campaign_Date_Check_Error); //Core_MDF_Campaign_Date_Check_Error //Core_MDF_Campaign_Date_Error: Campaign Date should comply with Activity Date.
                            }
                        }  
                        
                    }     
                }
                //Core_MDF_MDF_BudgetTypes - MDF;MDF+;Retail MDF;Account Plan
                List<String> mdfBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MDF_BudgetTypes').split(';');
                List<String> nonMdfBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NonMDF_BudgetTypes').split(';');
                //List<String> selectedBudgetType = cmp.Core_MDF_Opal_Budget_Type_Txt__c.split(';');
                    if((cmp.RecordTypeId == retailRecordTypeId || cmp.RecordTypeId == eefRecordTypeId || (cmp.RecordTypeId  == ipaRecordTypeId && !cmp.Core_MDF_Proposal_Based_Ind__c)) && !error){
                    
                    decimal Amt = 0;
                    decimal totalEscAmt = 0.0;
                    decimal totalClaimedAmt = 0.0;
                    decimal totalClaimEscConsumedAmt = 0.0;
                    decimal finalAmount = 0.0;
                    decimal displayAmt = 0.0;
                    
                    List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
                    for(Id pfr: cmpIdPfrIdListMap.get(cmp.Id)){
                        if(mdfBudgetTypeList.contains(pfrMap.get(pfr).Core_MDF_Budget_Type_nm__c))
                           {
                              Amt =  Amt+pfrMap.get(pfr).Amount; 
                           }
                        else if(nonMdfBudgetTypeList.contains(pfrMap.get(pfr).Core_MDF_Budget_Type_nm__c)){
                            
                               if(pfrMap.get(pfr).Core_MDF_Fund_Request_Status__c == 'Closed'){
                                   
                                   if(pfrClaimAmtMap.containsKey(pfr)){
                                       totalClaimedAmt = pfrClaimAmtMap.get(pfr);
                                   }
                                   if(pfrEscAmtMap.containsKey(pfr)){
                                       totalEscAmt = pfrEscAmtMap.get(pfr);
                                   }
                                   totalClaimEscConsumedAmt = totalEscAmt + totalClaimedAmt;
                                   finalAmount = totalClaimEscConsumedAmt >= pfrMap.get(pfr).Core_MDF_Activity_Reimbursement_Amt_nbr__c
                                        ? pfrMap.get(pfr).Core_MDF_Activity_Reimbursement_Amt_nbr__c : totalClaimEscConsumedAmt;
                                   Amt =  Amt+finalAmount;
                               }
                               else
                               {
                                   Amt =  Amt+pfrMap.get(pfr).Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                               } 
                               
                          }
                    }
                    
                    if(cmp.RecordTypeId == retailRecordTypeId) {
                    if (cmp.Core_MDF_Budget_Amount_amt__c < Amt && !(System.Label.Core_MDF_Bypass_RMF_Budget_Notification  == 'TRUE' )){
                        cmp.addError(Label.Core_MDF_Camp_Budget_Msg+' $'+Amt);
                    }
                    if (cmp.Core_MDF_First_Year_Budget_Amount__c < Amt){
                        cmp.addError(Label.Core_MDF_Camp_Budget_Msg+' $'+Amt);
                    }
                    }
                        if(cmp.RecordTypeId == ipaRecordTypeId || cmp.RecordTypeId == eefRecordTypeId) {
                        displayAmt = (Amt/Integer.valueOf(cmp.Core_MDF_ReimbursementRate_pct__c.removeEnd('%')))*100;
                        if (cmp.Core_MDF_Reimbursement_Amt__c < Amt){
                            cmp.addError(Label.Core_MDF_Camp_Budget_Msg+' $'+displayAmt.setScale(2));
                        }
                    }
                }
                //US773772 Edit OPAL campaign, if campaign has active activites and fields "Start Date , End date" are change it throws and error - end
                
                if(cmpIdTextFieldListMap.containsKey(cmp.Id) && cmpIdTextFieldListMap.get(cmp.Id) != NULL ){ 
                    errortxtfields = String.join(cmpIdTextFieldListMap.get(cmp.Id),', ') +' '+Label.Core_MDF_Cannot_Remove_TextFields;
                }     
                if((String.IsNotBlank(errorpickfields) || String.IsNotBlank(errortxtfields)) && !(System.Label.Core_MDF_Is_ValidationBypassed == 'TRUE' && System.Label.Core_MDF_VRBypassByUser.contains(UserInfo.getUserName()))){ 
                    cmp.addError(errorpickfields +' '+ errortxtfields);
                }
                //NP - WW33 IPA Account - Total Campaign Amount should comply with the sum of all active activites
        /*       if(cmp.RecordTypeId  == ipaRecordTypeId && !cmp.Core_MDF_Proposal_Based_Ind__c && !error){
                    
                    decimal Amt = 0; decimal activityAmount = 0; Decimal displayAmt = 0;
                    for(Id pfr: cmpIdPfrIdListMap.get(cmp.Id)){ 
                        activityAmount = pfrMap.get(pfr).Core_MDF_Activity_Reimbursement_Amt_nbr__c == null ? 0 :pfrMap.get(pfr).Core_MDF_Activity_Reimbursement_Amt_nbr__c;
                        Amt =  Amt+ activityAmount;
                    }
                    displayAmt = (Amt/Integer.valueOf(cmp.Core_MDF_ReimbursementRate_pct__c.removeEnd('%')))*100;
                    if (cmp.Core_MDF_Reimbursement_Amt__c < Amt){
                        cmp.addError(Label.Core_MDF_Camp_Budget_Msg+' $'+displayAmt.setScale(2));
                    }
                }   */
            }
            
            if(coMarketingCampaignRecordTypeID.contains(cmp.RecordTypeId)){                         
                //Setting Channel Program lookup value in Campaign
                if(programtype.containsKey(cmp.Core_MDF_Program__c) && programtype.get(cmp.Core_MDF_Program__c) != NULL ){
                    cmp.Core_MDF_Channel_Program__c = programtype.get(cmp.Core_MDF_Program__c);
                }
                
                //Setting Status as In Progress if starts date is today
                //Updated below condition as part of US1048029 changes
                //if((isInsert || (isUpdate && cmp.StartDate != campOldMap.get(cmp.Id).StartDate)) && cmp.StartDate <= system.today()){
                    if((((isInsert || (isUpdate && (cmp.Core_MDF_External_Visibility_Date__c != campOldMap.get(cmp.Id).Core_MDF_External_Visibility_Date__c || cmp.StartDate != campOldMap.get(cmp.Id).StartDate))) && cmp.StartDate <= system.today() && cmp.EndDate >= system.today()) || 
                    (isUpdate && cmp.EndDate != campOldMap.get(cmp.Id).EndDate && cmp.EndDate >= system.today() && cmp.StartDate <= system.today())) && (cmp.Core_MDF_Campaign_Source_nm__c != 'Target Setting' || cmp.Core_MDF_External_Visibility_Date__c !=null)){
                       cmp.Status = 'In Progress'; 
                   }
                 else if((isInsert || (isUpdate && ( cmp.Core_MDF_External_Visibility_Date__c != campOldMap.get(cmp.Id).Core_MDF_External_Visibility_Date__c || cmp.StartDate != campOldMap.get(cmp.Id).StartDate))) && cmp.StartDate > system.today() && (cmp.Core_MDF_Campaign_Source_nm__c != 'Target Setting' || cmp.Core_MDF_External_Visibility_Date__c !=null)){
                    cmp.Status = 'Planned'; 
                    }else if(isUpdate && cmp.EndDate != campOldMap.get(cmp.Id).EndDate && cmp.EndDate < system.today() && ((cmp.Status == 'Draft' && cmp.Core_MDF_External_Visibility_Date__c != campOldMap.get(cmp.Id).Core_MDF_External_Visibility_Date__c) || cmp.Status != 'Draft')){
                    cmp.Status = 'Completed';
                }else if(isInsert && cmp.RecordTypeId == ipaRecordTypeId && !cmp.Core_MDF_Proposal_Based_Ind__c && cmp.StartDate < system.today()  && cmp.EndDate < system.today()){
                    cmp.Status = 'Completed';
                }
                    else if(isUpdate && cmp.EndDate < system.today() && cmp.Status == 'Draft' && cmp.RecordTypeId != ipaRecordTypeId){
                        cmp.Status = 'Cancelled';
                    
		}
                //Setting Status as Cancelled when 'Cancel campaign' button is clicked and if previous campaign status is not Completed 
                //and there are no active activities associated with it - added by Sarah TWC742-776
                if(isUpdate && cmp.Status == 'Cancelled')
                {
                    if(cmpIdPfrIdListMap.containsKey(cmp.Id) && cmpIdPfrIdListMap.get(cmp.Id).size() > 0) {
                            cmp.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CancelCampError'));
                        }
                        if(campOldMap.get(cmp.Id).Status == 'Completed' && cmpIdTextFieldListMap.get(cmp.Id) != NULL  && !(System.Label.Core_MDF_Is_ValidationBypassed == 'TRUE' && System.Label.Core_MDF_VRBypassByUser.contains(UserInfo.getUserName()))) {
                            cmp.addError(Label.Core_MDF_Cancel_Campaign_Error_Message);
                        }
                }
                
                //Check if Record Type is Retail and Update the Geo on campaign from Account
                if(geoRecordTypeIdList.contains(cmp.RecordTypeId) && (isInsert || (isUpdate && campOldMap.get(cmp.Id).Core_MDF_Account__c != cmp.Core_MDF_Account__c))){
                    if(accIdGeoMap.get(cmp.Core_MDF_Account__c) != NULL){
                        cmp.Core_MDF_Region_cd__c = accIdGeoMap.get(cmp.Core_MDF_Account__c);
                    }
                    //Populate SubGeo from Account only for ASMO Region
                    if(accIdSubGeoMap.get(cmp.Core_MDF_Account__c) != NULL){  
                        cmp.Core_MDF_Sub_Region_cd__c = accIdSubGeoMap.get(cmp.Core_MDF_Account__c);
                    }
                }
                
                              
                
                //Check if the record is of CCF/DCF/CCFB/SPCF
                //NP - WW33 Check for Region change too
                if(countryRecordTypeIdList.contains(cmp.RecordTypeId) && 
                   (isInsert || (isUpdate && (campOldMap.get(cmp.Id).Core_MDF_Market__c != cmp.Core_MDF_Market__c || campOldMap.get(cmp.Id).Core_MDF_Region_cd__c != cmp.Core_MDF_Region_cd__c)))){
                        if(cmp.Core_MDF_Market__c != null){
                    String geo = returnsGeoForCampaign(cmp.Core_MDF_Market__c.split(';'));
                    if(String.isNotBlank(geo) && (geo.contains('ASMO-LAR') || geo.contains('ASMO-NAR'))){
                            geo= geo.replace('ASMO-LAR','ASMO');
                            geo= geo.replace('ASMO-NAR','ASMO'); 
                    }
                    list<String> geoList = geo.split(';');
                    Set<String> geoSet = new set<String>();
                    if(geoList != null && !geoList.isEmpty()){
                        geoSet.addAll(geoList);
                    }
                    String finalGeoString = String.join(new List<String>(geoSet), ';');
                    
                    cmp.Core_MDF_Region_cd__c = finalGeoString;
                        }else{
                            cmp.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Campaign_Country_Field_Error'));
                        }
                }
                
                
                if(cmp.Core_MDF_Activity_Category_Type__c != NULL && (isInsert || (isUpdate && cmp.Core_MDF_Activity_Category_Type__c != campOldMap.get(cmp.Id).Core_MDF_Activity_Category_Type__c ))){
                    tempStr = cmp.Core_MDF_Activity_Category_Type__c; 
                    
                    //Splitting multi-select Activity Category ->Type
                    listTempString = tempStr.split(';');
                    
                    //Processing all Activity Category ->Type picklist values
                    for(String str : listTempString){
                        activityWithCategory.clear();                    
                        //Splitting Activity Category ->Type into activity and category
                        activityWithCategory = str.split('->');
                        if(activityWithCategory.size() >= 2){
                            categorySet.add(activityWithCategory[0].trim());
                            activitySet.add(activityWithCategory[1].trim());
                        }
                    }                       
                    
                    //Preparing activity picklist value by iterating activity set
                    String activity = '';
                    for(String str1 : activitySet){
                        activity = activity + str1 +';';
                    }
                    if(activity != NULL){
                        cmp.Core_MDF_Activity_Type__c = activity;                    
                    }
                    
                    //Preparing category picklist value by iterating category set
                    String category = '';
                    for(String str2 : categorySet){
                        category = category + str2 +';';
                    }
                    if(category != NULL){
                        cmp.Core_MDF_Activity_Category__c = category;                    
                    }
                    categorySet.clear();
                    activitySet.clear();
                    finalGeoSet.clear();                    
                }
            }
            
            //US819148 : [CCP] Campaign Level CAP - Campaign Validations
            if(campaignIDToCAPAmountMap.containsKey(cmp.id) && (campaignIDToCAPAmountMap.get(cmp.id)< campaignIDToExistingCAPAmountMap.get(cmp.id))){cmp.addError(Label.Core_MDF_Campaign_CAP_Error_Message + campaignIDToExistingCAPAmountMap.get(cmp.id));    
                                                                                                                                                    } 
        }
        //RMFCamptoBudgettypeMap = queryPmbRecords(BudgetTypeCamp,CampEarliestStartDate,CampEarliestFutureStartDate,accIdPmbSet);
        if ((RMFBudgettoCampaignList.size()>0)&& mapFunctionalityNameTriggerExecution != null 
            &&mapFunctionalityNameTriggerExecution.containsKey('BypassRetailMDFBudgetValidation') && 
            !mapFunctionalityNameTriggerExecution.get('BypassRetailMDFBudgetValidation').Core_Active__c)
        {
            
            validateBudgetToCampaignMap(RMFBudgettoCampaignList,RMFCamptoBudgettypeMap,AccNodeVirtualCorpMap);
        }
    }
    
    public static Map <String,List<PartnerMarketingBudget>> queryPmbRecords(Set<String> Budgettypes , Date EarliestStartDate,Date CampEarliestFutureStartDate,Set<Id>accIdPmbSet){
        Map <String,List<PartnerMarketingBudget>> PartnerMarketingBudgetListMap = new Map <String,List<PartnerMarketingBudget>> ();
        Boolean istrue = false;
        
        List<PartnerMarketingBudget> PmbList=[Select id,StartDate,EndDate ,Core_MDF_Budget_Type_Txt__c,Core_MDF_Budget_Partner__c,
                                              Core_MDF_Program_Nm__c from PartnerMarketingBudget where   
                                              Core_MDF_Budget_Type_Txt__c  IN: Budgettypes
                                              AND Core_MDF_Budget_Partner__c IN: accIdPmbSet
                                              AND (TotalAllocatedAmount > 0)
                                              AND ((StartDate <=: EarliestStartDate 
                                                    AND EndDate >=: EarliestStartDate)
                                                   OR (StartDate <=: CampEarliestFutureStartDate
                                                       and EndDate >=:CampEarliestFutureStartDate)) order by StartDate  ];
        for (PartnerMarketingBudget budget :PmbList){
            string key = budget.Core_MDF_Budget_Type_Txt__c + budget.Core_MDF_Budget_Partner__c;
            if(PartnerMarketingBudgetListMap.get(key) == null){ 
                List <PartnerMarketingBudget> BudgetList = new List <PartnerMarketingBudget> ();
                BudgetList.add(budget);
                PartnerMarketingBudgetListMap.put(key,BudgetList);   
            }
            else{
                PartnerMarketingBudgetListMap.get(key).add(budget);    
            }
        }
        
        return PartnerMarketingBudgetListMap ;
    }
    
    //Map the BudgetRecord on Campaign
    public static void validateBudgetToCampaignMap(List<Campaign> RMFBudgettoCampaignList,Map<String,List<PartnerMarketingBudget>> RMFCamptoBudgettypeMap,Map <id,id>AccNodeVirtualCorpMap){
        try{ 
            for (Campaign cmp : RMFBudgettoCampaignList)
            {   
                boolean var = false;
                
                if (RMFCamptoBudgettypeMap.containsKey(cmp.Core_MDF_Opal_Budget_Type_Txt__c+AccNodeVirtualCorpMap.get(cmp.Core_MDF_Account__c))){
                    for( PartnerMarketingBudget pmbbudget : RMFCamptoBudgettypeMap.get(cmp.Core_MDF_Opal_Budget_Type_Txt__c+AccNodeVirtualCorpMap.get(cmp.Core_MDF_Account__c))){
                        if(cmp.StartDate >= pmbbudget.StartDate && cmp.EndDate <= pmbbudget.EndDate && cmp.Core_MDF_Opal_Budget_Type_Txt__c==pmbbudget.Core_MDF_Budget_Type_Txt__c){
                            var =true;
                            break;
                        }
                    }
                }
                
                if (!var){
                    cmp.addError('No Budget exists for the account that you are trying to create a Campaign for. Please contact Finance User to load budget for the account');    
                }        
            }  
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}     
        
    }
    
    public static Map<id,decimal> calculatecampaignCAPAmount(Set<id> campaignIds){
        List<String> claimStatusToBeExcluded = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStatusToBeExcForBudgetCap').split(',');
        Map<Id,Decimal> campIdWithCAPAmount = new Map<Id,Decimal>();
        
        try{
            for(PartnerFundClaim pfc : [SELECT Id, Amount,Core_MDF_Campaign_Id__c,Core_MDF_Status__c FROM PartnerFundClaim WHERE
                                        Core_MDF_Campaign_Id__c IN: campaignIds AND Core_MDF_Status__c NOT IN: claimStatusToBeExcluded]){
                                            if(campIdWithCAPAmount.containsKey(pfc.Core_MDF_Campaign_Id__c)){
                                                Decimal tempAmount = 0;
                                                tempAmount = campIdWithCAPAmount.get(pfc.Core_MDF_Campaign_Id__c) + pfc.Amount;
                                                campIdWithCAPAmount.put(pfc.Core_MDF_Campaign_Id__c,tempAmount);
                                            }
                                            else{
                                                campIdWithCAPAmount.put(pfc.Core_MDF_Campaign_Id__c,pfc.Amount);
                                            } 
                                        }
            
              
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}        
        return campIdWithCAPAmount;    
    }
    
    public static String returnsGeoForCampaign (List<String> countryList){        
        String finalGeoString;
        Set<String> geoSet = new Set<String>();
        
        for(String countryStr : countryList){
            if(wrapperMap.containsKey(countryStr) && wrapperMap.get(countryStr) != NULL && !geoSet.contains(wrapperMap.get(countryStr).geo)){
                if(wrapperMap.get(countryStr).subgeo.equals('LAR') || wrapperMap.get(countryStr).subgeo.equals('NAR')){
                    geoSet.add(wrapperMap.get(countryStr).geo+'-'+wrapperMap.get(countryStr).subgeo);
                }
                
                else{
                    geoSet.add(wrapperMap.get(countryStr).geo);
                }
                finalGeoString = String.join(new List<String>(geoSet), ';');
            }
        }        
        return finalGeoString;
    }
    
    public static Boolean checkEdit(Campaign newCampaign, Campaign oldCampaign, String field){
        
        Boolean isRemoved = FALSE;
        String oldFieldValue = (String)oldCampaign.get(field);
        String newFieldValue = (String)newCampaign.get(field);
        if(oldFieldValue != NULL){
            for(String oldValue : oldFieldValue.Split(';')){
                if(newFieldValue == NULL || !newFieldValue.Split(';').contains(oldValue)){
                    isRemoved = TRUE;
                }
            }
        }
        return isRemoved;
    }
    
    public class CampaignEditWrapper{
        public Campaign newCmp;
        public Campaign oldCmp;
        public String field;
    }
    
    /*public static CampaignShare createCampaignShare(Id campaignId, Id groupId){
        
        try{
            CampaignShare shareRecord = new CampaignShare();
            shareRecord.CampaignId = campaignId;
            shareRecord.RowCause = 'Manual';
            shareRecord.CampaignAccessLevel = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Read_Access');
            shareRecord.UserOrGroupId = groupId;
            return shareRecord;
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);return null;}
    }*/
    
    public static void shareUnshareCampaign(List<Campaign> newCmpList, Map<Id,Campaign> campOldMap, boolean isInsert, boolean isUpdate){ 
        
        Set<Id> accId = new Set<Id>();
        Set<Id> ultimateAccId = new Set<Id>();
        List<Id> ultimateAccIdList = new List<Id>();
        Set<Id> programIdSet = new Set<Id>();
	List<Id> programIdList = new List<Id>();
        Set<String> geoSet = new Set<String>();
        Map<Id, String> cpIdNameMap = new Map<Id, String>();
        
        //List of campaign to be shared
        List<Campaign> campaignToBeShared = new List<Campaign>();
        
        //List of Campaign's Id whose share record has to be deleted
        List<Id> campaignShareToBeDeleted = new List<Id>();
        
        //Campaign Share records from the above list
        List<CampaignShare> campaignShareList = new List<CampaignShare>();
        
        //List of campaign share records to be inserted
        List<CampaignShare> cmpShareList = new List<CampaignShare>();
        
        //List of group Ids which is used to share for region or category wise budget
        //List<Id> userorGroupIdToShare = new List<Id>();
        Map<Id,List<Id>> objectIdUserGroupIdListMapToShare = new Map<Id,List<Id>> ();
        
        //Key-AccountId, Value-ParentFundAccount Id
        Map<Id,Id> accountMap = new Map<Id,Id>();
        
        //Key-AccountId, Value-ParentFundAccount Id
        Map<Id, Set<Id>> accountIdPFAIdMap = new Map<Id,Set<Id>>();
        
        Map<Id, Set<Id>> pnumAccIdUserIdMap = new Map<Id,Set<Id>>();
        
        Map<Id, List<Id>> campIdUserIdMap = new Map<Id,List<Id>>();
        List<Core_MDF_RecordGeoShare> recGeoShrLst = new List<Core_MDF_RecordGeoShare>();
        
        Map<Id, Id> accountIdExternalGroupIdMap = new Map<Id, Id>();
        Map<Id, List<Id>> campIdExternalGroupIdMap = new Map<Id, List<Id>>();
        Map<Id, List<Id>> campIdInternalGroupIdMap = new Map<Id, List<Id>>();
        Map<Id,String> cmpAcctGeo = new Map<Id,String>();

        List<String> hostRegionSharingReqProg = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_HostRegionSharingReqProg');
        List<String> objectsForHostRegSharing = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_HostRegionSharingReqObj');

        String objectName = 'Campaign';

        List<Campaign> cmpToBeUpdated = new List <Campaign>();
        Map<Id,List<Id>> AcctBasedcampIdGroupIdListMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> PropBasedcampIdGroupIdListMap = new Map<Id,List<Id>>();
        Set<Id> campEEFSet = new Set<Id>();

        //Iterate over campaign list and get geoSet, accId, programIdSet, campaignToBeShared and campaignShareToBeDeleted
        for(Campaign cmp : newCmpList){          
            if((isInsert || (isUpdate && 
                             (cmp.OwnerId != campOldMap.get(cmp.Id).OwnerId || 
                              ((cmp.Core_MDF_External_Visibility_Date__c != campOldMap.get(cmp.Id).Core_MDF_External_Visibility_Date__c ||
                              cmp.Core_MDF_Region_cd__c != campOldMap.get(cmp.Id).Core_MDF_Region_cd__c) && cmp.Core_MDF_Program__c !=Label.Core_MDF_IPA_Program_Name) ||
                              cmp.Core_MDF_Account__c != campOldMap.get(cmp.Id).Core_MDF_Account__c ||
                              cmp.Core_MDF_Opal_Budget_Type_Txt__c != campOldMap.get(cmp.Id).Core_MDF_Opal_Budget_Type_Txt__c ||
                              cmp.Core_MDF_Partner_Mapping_Txt__c != campOldMap.get(cmp.Id).Core_MDF_Partner_Mapping_Txt__c)))){ 
                                  
                                  programIdSet.add(cmp.Core_MDF_Channel_Program__c);                                  
                                  accId.add(cmp.Core_MDF_Account__c);
                                  campaignToBeShared.add(cmp);
                                  
                                  //Check if Region or Account or External Visibility date or Budget Type has been changed, if yes then the share records has to be deleted
                                  if(isUpdate && (cmp.Core_MDF_Region_cd__c != campOldMap.get(cmp.Id).Core_MDF_Region_cd__c || 
                                                  cmp.Core_MDF_Account__c != campOldMap.get(cmp.Id).Core_MDF_Account__c ||
                                                  cmp.Core_MDF_External_Visibility_Date__c != campOldMap.get(cmp.Id).Core_MDF_External_Visibility_Date__c || 
                                                  cmp.Core_MDF_Opal_Budget_Type_Txt__c != campOldMap.get(cmp.Id).Core_MDF_Opal_Budget_Type_Txt__c ||
                                                  cmp.Core_MDF_Partner_Mapping_Txt__c != campOldMap.get(cmp.Id).Core_MDF_Partner_Mapping_Txt__c)){
                                                      campaignShareToBeDeleted.add(cmp.Id);
                                                  }
                                  if(cmp.Core_MDF_Program__c == Label.Core_MDF_EEF_Program_Name){
                                      accId.addAll((List<Id>)cmp.Core_MDF_Partner_Mapping_Txt__c.split(';'));
                                      
                                      if(isUpdate){
                                          campEEFSet.add(cmp.Id);
                                      }
                                  }
                              }
        }
        programIdList.addAll(programIdSet);
        
        if(campEEFSet!=null && campEEFSet.size()>0){
            Map<id,Core_MDF_Camp_to_ActPartner__c> campToActPartnerMap = new Map<id,Core_MDF_Camp_to_ActPartner__c>([Select id,Core_MDF_Activating_Partner_Account_id__c, Core_MDF_PrimPartner_Ultimate_Acc_Id__c,Core_MDF_ActPartner_Ultimate_Acc_Id__c,Core_MDF_Channel_Program__c,Core_MDF_Campaign_Id__c,
                                                                                                                     Core_MDF_Campaign_Id__r.Core_MDF_Region_cd__c,Core_MDF_Campaign_Id__r.Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Campaign_Id__r.Core_MDF_External_Visibility_Date__c,Core_MDF_Active_Ind__c from Core_MDF_Camp_to_ActPartner__c where Core_MDF_Campaign_Id__c IN: campEEFSet]);       
            if(campToActPartnerMap != null && campToActPartnerMap.size() >0){
                Core_MDF_CampActPartnerServiceHandler.unShareCampActPartner(new List<id>(campToActPartnerMap.keySet()));
                Core_MDF_CampActPartnerServiceHandler.shareCamToActPartner(campToActPartnerMap.values());
            }
        }            
        
        //Get the Parent Fund Account Id set from accId set //Ultimate account
        //Key = Acc Id; Value = Group Id on Account
        Map<Id,Id> accIdToAccGroupIdMap = new Map<Id,Id>();
        if(accId !=Null && accId.Size() > 0){
            for(Account acc: [SELECT Id, Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketing_Ultimate_Account__c,
                              Core_MDF_Channel_Program__r.Name, Core_MDF_Channel_Program__c, 
                              Core_MDF_Group_Id__c, Core_MDF_External_Group_Id__c, Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c,
                              Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, 
                              Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c
                              FROM Account WHERE Id IN : accId]){
                                  if(acc.Core_MDF_CoMarketing_Ultimate_Account__c != null){
                                      ultimateAccId.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                                      accountMap.put(acc.Id, acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                                      cpIdNameMap.put(acc.Core_MDF_Channel_Program__c, acc.Core_MDF_Channel_Program__r.Name);                                       
                                      
                                  }
                                  // Checking if Program equals RMF/IPA, then share campaign with the external group of all the nodes above in the hiearrchy
                                  if(acc.Core_MDF_Channel_Program__r.Name == Label.Core_MDF_Retail_Program_Name){
                                      // Updating accountIdPFAIdMap with key as acc.Id and value as associated accounts
                                      accountIdPFAIdMap.put(acc.Id, new Set<Id> {acc.Id,acc.Core_MDF_Parent_Fund_Account__c,acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c});                                    
                                      if(acc.Core_MDF_External_Group_Id__c != NULL){
                                          accountIdExternalGroupIdMap.put(acc.Id, acc.Core_MDF_External_Group_Id__c);
                                      }
                                      if(acc.Core_MDF_Parent_Fund_Account__c != null && acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c != null){
                                          accountIdExternalGroupIdMap.put(acc.Core_MDF_Parent_Fund_Account__c, acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c);
                                          
                                      }
                                      if(acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c != null 
                                         && acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c != null){
                                             accountIdExternalGroupIdMap.put(acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c);
                                         }
                                      
                                  }
                                  if((acc.Core_MDF_Channel_Program__r.Name == Label.Core_MDF_IPA_Program_Name || acc.Core_MDF_Channel_Program__r.Name == Label.Core_MDF_Co_GTM_program_name) && acc.Core_MDF_External_Group_Id__c != NULL)
                                  {
                                      accountIdPFAIdMap.put(acc.Id, new Set<Id> {acc.Id});
                                      accountIdExternalGroupIdMap.put(acc.Id, acc.Core_MDF_External_Group_Id__c);
                                  }
                                  //Internal Node based sharing
                                  if(acc.Core_MDF_Group_Id__c != NULL){
                                      accIdToAccGroupIdMap.put(acc.Id,acc.Core_MDF_Group_Id__c); 
                                  }
                              }  
            ultimateAccIdList.addAll(ultimateAccId);
                           
        }
        
        //Delete share records
        if(campaignShareToBeDeleted != NULL && campaignShareToBeDeleted.size() > 0){
            for(CampaignShare cmpShare : [SELECT Id, CampaignId, UserOrGroupId, Campaign.Core_MDF_Program__c, Campaign.Core_MDF_Account__c
                                          FROM CampaignShare WHERE CampaignId IN : campaignShareToBeDeleted AND 
                                          RowCause =: Schema.CampaignShare.RowCause.Manual]){
                                              if(String.valueOf(cmpShare.UserOrGroupId).startsWith('00G')){
                                                  CampaignShareList.add(cmpShare);
                                              }
                                          }
        }
        if(campaignShareList != NULL && campaignShareList.size() > 0){
            delete campaignShareList;
        }
        
        Core_MDF_PGM_Utility.pgmKeyGroupIdWrapper pgmKeyGrpIdWrapper = new Core_MDF_PGM_Utility.pgmKeyGroupIdWrapper();
        pgmKeyGrpIdWrapper = Core_MDF_PGM_Utility.getAccPGMKeyGrpIdMap(ultimateAccIdList,programIdList,null);
        Map<String,Id> intPGMAccKeyGroupIdMap = pgmKeyGrpIdWrapper.intPGMKeyGroupIdMap;
        Map<String,Id> extPGMAccKeyGroupIdMap = pgmKeyGrpIdWrapper.extPGMKeyGroupIdMap;

        //Iterate over campaignToBeShared and prepare share records for each campaign
        for(Campaign cmp : campaignToBeShared){
            
            //List<Id> userorGroupIdToShare = new List<Id>();
            //Set<Id> groupIdSet = new Set<Id>();
            List<String> geoLst = new List<String>();// = cmp.Core_MDF_Region_cd__c.Split(';');
            List<Id> grpLst = new List<Id>();
            Set<Id> grpSet = new Set<Id>();
            if(cmp.Core_MDF_Program__c == Label.Core_MDF_Retail_Program_Name){
                geoLSt = new list<String>{'APJ','EMEA','PRC','ASMO','INDIA'};
                    }else if(hostRegionSharingReqProg.contains(cmp.Core_MDF_Program__c) && objectsForHostRegSharing.contains(objectName))
                    {
                        geoLSt.add(cmp.Core_MDF_Host_Region_cd__c);
                    }
                    else{
                        geoLst = cmp.Core_MDF_Region_cd__c.Split(';');
                    }
            
            for(String geo : geoLst){
                
                if(cmp.Core_MDF_Program__c == Label.Core_MDF_EEF_Program_Name){
                    grpSet = partnerAccountEEFSharing(grpSet, cmp, accountMap, geo, intPGMAccKeyGroupIdMap, extPGMAccKeyGroupIdMap, accountIdPFAIdMap, accountIdExternalGroupIdMap, accIdToAccGroupIdMap);
                }
                //Internal and External PGM group Sharing
                String accountIdProgramIdGeo = (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + geo;
                String accountIdProgramIdSubGeo = (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + geo + cmp.Core_MDF_Sub_Region_cd__c;
                String accountIdProgramIdGeoBudgetType = (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + geo + cmp.Core_MDF_Opal_Budget_Type_Txt__c;
                String accountIdProgramIdsubGeoBudgetType = (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + geo + cmp.Core_MDF_Sub_Region_cd__c + cmp.Core_MDF_Opal_Budget_Type_Txt__c;
                String accountIdProgramIdBudgetType = (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + cmp.Core_MDF_Opal_Budget_Type_Txt__c;
                String accountIdProgramId = (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c;
                
                //Geo groups
                if(intPGMAccKeyGroupIdMap.containsKey(accountIdProgramIdGeo)){
                    //groupIdSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramIdGeo));
                    grpSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramIdGeo));
                }
                //Subgeo groups
                if(cmp.Core_MDF_Program__c == Label.Core_MDF_Retail_Program_Name && geo =='ASMO'){
                    List<String> subGeo = new List<String>{'NAR','LAR'};
                        for(String subG : subGeo){
                            accountIdProgramIdSubGeo = (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + geo + subG;
                            if(intPGMAccKeyGroupIdMap.containsKey(accountIdProgramIdSubGeo)){
                                grpSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramIdSubGeo));
                            }
                        }
                }else{
                    if(intPGMAccKeyGroupIdMap.containsKey(accountIdProgramIdSubGeo)){
                        grpSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramIdSubGeo));
                    }
                }
                // Geo Subgeo budget type group
                if(intPGMAccKeyGroupIdMap.containsKey(accountIdProgramIdGeoBudgetType)){
                    grpSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramIdGeoBudgetType));
                }
                if(intPGMAccKeyGroupIdMap.containsKey(accountIdProgramIdsubGeoBudgetType)){
                    grpSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramIdsubGeoBudgetType));
                }
                //WW group
                if(intPGMAccKeyGroupIdMap.containsKey(accountIdProgramId)){
                    //groupIdSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramId));
                    grpSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramId));
                }                
                //WW with budget type group
                if(intPGMAccKeyGroupIdMap.containsKey(accountIdProgramIdBudgetType)){
                    grpSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramIdBudgetType));
                }
                
                //If external visibility date is Less than or equal to today's date and if Record Type is CCF/DCF/SPCF/CCFB, then share the campaign with internal and external groups
                if((cmp.Core_MDF_External_Visibility_Date__c <= Date.Today() && extPGMAccKeyGroupIdMap.containsKey(accountIdProgramId)) && !(cmp.Core_MDF_Program__c == Label.Core_MDF_IPA_Program_Name) && cmp.Core_MDF_Program__c != Label.Core_MDF_Co_GTM_Technical_program_name){                    
                    grpSet.add(extPGMAccKeyGroupIdMap.get(accountIdProgramId));
                }
                
                // For Retail and IPA  External node group Sharing
                // Iterating over Campaigns to prepare the campId and the set of all account id's associated to the campaign - For RMF Max 3 levels and for IPA Max 5 levels
                if(accountIdPFAIdMap.containsKey(cmp.Core_MDF_Account__c) && accountIdPFAIdMap.get(cmp.Core_MDF_Account__c) != NULL){
                    for(Id accountId : accountIdPFAIdMap.get(cmp.Core_MDF_Account__c)){
                        if(cmp.Core_MDF_Program__c != Label.Core_MDF_Co_GTM_Technical_program_name){
                            grpSet.add(accountIdExternalGroupIdMap.get(accountId)); 
                        }else if(cmp.Core_MDF_Program__c == Label.Core_MDF_Co_GTM_Technical_program_name && cmp.Core_MDF_External_Visibility_Date__c <= Date.Today()){
                            grpSet.add(accountIdExternalGroupIdMap.get(accountId));
                        }
                    }                    
                }
                
                //If Node based sharing is required, then share cmapaign with Internal Node groups
                if(geoRecordTypeIdList.contains(cmp.RecordTypeId)){
                    
                    if(accIdToAccGroupIdMap.containsKey(cmp.Core_MDF_Account__c) && accIdToAccGroupIdMap.get(cmp.Core_MDF_Account__c) != NULL){
                        grpSet.add(accIdToAccGroupIdMap.get(cmp.Core_MDF_Account__c)); 
                    }
                }
                
                
                //Metadata group sharing
                if(cmp.Core_MDF_Program__c == Label.Core_MDF_IPA_Program_Name || cmp.Core_MDF_Program__c == Label.Core_MDF_Co_GTM_Technical_program_name){
                    Core_MDF_RecordGeoShare recGeoShr = new Core_MDF_RecordGeoShare(cmp.Id,geo,cmp.Core_MDF_Sub_Region_cd__c,cpIdNameMap.get(cmp.Core_MDF_Channel_Program__c),cmp.Core_MDF_Opal_Budget_Type_Txt__c,'Edit');
                    recGeoShrLst.add(recGeoShr); 
                }else if(cmp.Core_MDF_Program__c == Label.Core_MDF_NonTranslateEEFRecordType)
                {
                    Core_MDF_RecordGeoShare recGeoShr = new Core_MDF_RecordGeoShare(cmp.Id,geo,cmp.Core_MDF_Sub_Region_cd__c,cpIdNameMap.get(cmp.Core_MDF_Channel_Program__c),cmp.Core_MDF_Opal_Budget_Type_Txt__c,'Read');
                    recGeoShrLst.add(recGeoShr); 
                }else if(cmp.Core_MDF_Program__c == Label.Core_MDF_Retail_Program_Name){
                    if(geo == cmp.Core_MDF_Region_cd__c){
                        Core_MDF_RecordGeoShare recGeoShr = new Core_MDF_RecordGeoShare(cmp.Id,geo,cmp.Core_MDF_Sub_Region_cd__c,cpIdNameMap.get(cmp.Core_MDF_Channel_Program__c),'','Edit');
                        recGeoShrLst.add(recGeoShr);
                    }
                }else{
                    Core_MDF_RecordGeoShare recGeoShr = new Core_MDF_RecordGeoShare(cmp.Id,geo,null,cpIdNameMap.get(cmp.Core_MDF_Channel_Program__c),'','Edit');
                    recGeoShrLst.add(recGeoShr);
                    
                }
            //Revisit logic here
            /*if(groupIdSet != NULL && groupIdSet.Size() > 0 && (cmp.Core_MDF_Program__c == Label.Core_MDF_IPA_Program_Name && cmp.Core_MDF_Proposal_Based_Ind__c == true)){
                String groupIds = '';                              
                for(String ids: groupIdSet){                               
                    groupIds = groupIds + ids +';';                              
            }
                Campaign cmpIst = new Campaign();
                cmpIst.Id = cmp.Id;
                cmpIst.Core_MDF_PGM_Internal_Group_Id_txt__c = groupIds;
                cmpToBeUpdated.add(cmpIst);
                }*/
            }
        grpLst.addAll(grpSet); 
        if(cmp.Core_MDF_Proposal_Based_Ind__c == True){ 
                PropBasedcampIdGroupIdListMap.put(cmp.Id,grpLst);
        }
        else {
                AcctBasedcampIdGroupIdListMap.put(cmp.Id,grpLst);
            }   
        }
        
    if(PropBasedcampIdGroupIdListMap != NULL && PropBasedcampIdGroupIdListMap.size() > 0){
               Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Campaign', PropBasedcampIdGroupIdListMap, 'Edit');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
   
        }
        
    if(AcctBasedcampIdGroupIdListMap !=NuLL && AcctBasedcampIdGroupIdListMap.size() >0)
    {
        Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Campaign', AcctBasedcampIdGroupIdListMap, 'Read');
        Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
    }


    //Metadata share record Insertion
    if(recGeoShrLst !=NULL && recGeoShrLst.size() > 0){
            
            Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Campaign', recGeoShrLst);
        }
        
    //Update Core_MDF_PGM_Internal_Group_Id_txt__c field on campaign for proposal notifications
    /*if(cmpToBeUpdated != NULL && cmpToBeUpdated.size() > 0){
            Database.update(cmpToBeUpdated,false);
    }

    if(objectIdUserGroupIdListMapToShare.size() > 0){
            
            //Creating share records for categoryWiseBudget and regionWiseBudget        
            Map<Id,List<Id>> categoryWiseShareMap = new Map<Id,List<Id>>();
            Map<Id,List<Id>> regionWiseShareMap = new Map<Id,List<Id>>();
            
            for(Core_MDF_Regionwise_Campaign_Budget__c rWise : [Select Id, Core_MDF_Campaign__c FROM Core_MDF_Regionwise_Campaign_Budget__c 
                                                                WHERE Core_MDF_Campaign__c IN:objectIdUserGroupIdListMapToShare.Keyset()]){
                                                                    regionWiseShareMap.put(rWise.Id, objectIdUserGroupIdListMapToShare.get(rWise.Core_MDF_Campaign__c));                                          
                                                                }
            
            for(Core_MDF_Categorywise_Campaign_Budget__c cWise : [Select Id, Core_MDF_Campaign__c FROM Core_MDF_Categorywise_Campaign_Budget__c 
                                                                  WHERE Core_MDF_Campaign__c IN:objectIdUserGroupIdListMapToShare.Keyset()]){
                                                                      categoryWiseShareMap.put(cWise.Id, objectIdUserGroupIdListMapToShare.get(cWise.Core_MDF_Campaign__c));                                          
                                                                  }
            
            //Creating Share Records for Region Wise Campaign Budget
            if(regionWiseShareMap.size() > 0){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Regionwise_Campaign_Budget__c',regionWiseShareMap, 'Edit');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
            
            //Creating Share Records for Category Wise Campaign Budget
            if(categoryWiseShareMap.size() > 0){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst1 = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Categorywise_Campaign_Budget__c',categoryWiseShareMap, 'Edit');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst1);
            }
    }*/
    
    }
    
    public static Set<Id> partnerAccountEEFSharing(Set<Id> grpSet, Campaign cmp, Map<Id,Id> accountMap, String geo, Map<String,Id> intPGMAccKeyGroupIdMap,  Map<String,Id> extPGMAccKeyGroupIdMap,  Map<Id, Set<Id>> accountIdPFAIdMap, Map<Id, Id> accountIdExternalGroupIdMap, Map<Id,Id> accIdToAccGroupIdMap){
        for(Id partAcc : (List<Id>)cmp.Core_MDF_Partner_Mapping_Txt__c.split(';')){
            //Internal and External PGM group Sharing
            String accountIdProgramIdGeo = (String)accountMap.get(partAcc) + (String)cmp.Core_MDF_Channel_Program__c + geo;
            String accountIdProgramIdGeoBudgetType = (String)accountMap.get(partAcc) + (String)cmp.Core_MDF_Channel_Program__c + geo + cmp.Core_MDF_Opal_Budget_Type_Txt__c;
            String accountIdProgramIdBudgetType = (String)accountMap.get(partAcc) + (String)cmp.Core_MDF_Channel_Program__c + cmp.Core_MDF_Opal_Budget_Type_Txt__c;
            String accountIdProgramId = (String)accountMap.get(partAcc) + (String)cmp.Core_MDF_Channel_Program__c;
            
            //Geo groups
            if(intPGMAccKeyGroupIdMap.containsKey(accountIdProgramIdGeo)){
                //groupIdSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramIdGeo));
                grpSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramIdGeo));
            }
            
            if(intPGMAccKeyGroupIdMap.containsKey(accountIdProgramIdGeoBudgetType)){
                grpSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramIdGeoBudgetType));
            }

            //WW group
            if(intPGMAccKeyGroupIdMap.containsKey(accountIdProgramId)){
                //groupIdSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramId));
                grpSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramId));
            }

            //WW with budget type group
            if(intPGMAccKeyGroupIdMap.containsKey(accountIdProgramIdBudgetType)){
                grpSet.add(intPGMAccKeyGroupIdMap.get(accountIdProgramIdBudgetType));
            }
            
             if((cmp.Core_MDF_External_Visibility_Date__c <= Date.Today() && extPGMAccKeyGroupIdMap.containsKey(accountIdProgramId))){
                grpSet.add(extPGMAccKeyGroupIdMap.get(accountIdProgramId));
            }
            
             // Iterating over Campaigns to prepare the campId and the set of all account id's associated to the campaign - For RMF Max 3 levels and for IPA Max 5 levels
            if(accountIdPFAIdMap.containsKey(partAcc) && accountIdPFAIdMap.get(partAcc) != NULL){
                for(Id accountId : accountIdPFAIdMap.get(partAcc)){
                    grpSet.add(accountIdExternalGroupIdMap.get(accountId)); 
                }
                
            }
            
            //If Node based sharing is required, then share cmapaign with Internal Node groups
            if(geoRecordTypeIdList.contains(cmp.RecordTypeId)){
            
                if(accIdToAccGroupIdMap.containsKey(partAcc) && accIdToAccGroupIdMap.get(partAcc) != NULL){
                    grpSet.add(accIdToAccGroupIdMap.get(partAcc)); 
                }
            }
        }
        return grpSet;
    }
    
    //US535221: On Cancel Campaign - Remove Approval lock on Activities
    @InvocableMethod
    public static void removeApprovalLock(List<id> campaignID){           
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        try{
            pfrList = [select id from PartnerFundRequest
                       where CampaignId =: campaignID
                       and Core_MDF_Fund_Request_Status__c = 'Pending Review'];
            
            //Unlock the Pending Approval PFR records
            List<Approval.UnlockResult> ulrList = Approval.unlock(pfrList, false);
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    //US952018: [Technical] [Opal & SPCF] - Case- Display Strategic Marketing Fund Checkbox
    //TWC702-196 : [Legacy CCP] - Synch RR% change between Campaign and activity
    public static void updateRelatedRecords(Map<Id,Campaign> newCmpList, Map<Id,Campaign> campOldMap){
        Set<id> checkForCase = new Set<id>();
        List<Case> caseList = new List<Case>();
        List<Core_MDF_Bulk_Transaction__e> updateRecordList = new List<Core_MDF_Bulk_Transaction__e>();
        Map<Id,String> cmpRRMap = new Map<Id,String>();
        List<Campaign> rmfNotificationLst = new list<Campaign>();
        
        try{
            for(campaign cmp: newCmpList.values()){
                if(campOldMap != null && campOldMap.size() > 0 &&
                   campOldMap.get(cmp.ID).Core_MDF_Strategic_Marketing_Fund_Ind__c != cmp.Core_MDF_Strategic_Marketing_Fund_Ind__c){
                       checkForCase.add(cmp.ID);
                   }
                //RR% synch between Campaign and Activity
                if(((cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.CCF_TECHNICAL_PROGRAM_NAME && cmp.Core_MDF_Opal_Budget_Type_Txt__c == 'CCF 1.0') || (cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.DCF_TECHNICAL_PROGRAM_NAME && cmp.Core_MDF_Opal_Budget_Type_Txt__c == 'DCF 1.0') 
                    || cmp.Core_MDF_Program__c == 'Client CoMarketing Fund Boost' || cmp.Core_MDF_Program__c == 'Service Provider CoMarketing Fund') && cmp.Core_MDF_Reimbursement_Rate__c != campOldMap.get(cmp.Id).Core_MDF_Reimbursement_Rate__c){
                        cmpRRMap.put(cmp.Id,cmp.Core_MDF_Reimbursement_Rate__c);
                    }
                 if(Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_NotifyFinanceUsers')!=null && Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_NotifyFinanceUsers') && cmp.RecordTypeId == retailRecordTypeId && cmp.Core_MDF_Budget_Amount_amt__c > campOldMap.get(cmp.Id).Core_MDF_Budget_Amount_amt__c && cmp.Status!='Cancelled'){//TWC3117-14967 - Stop Campaign budget Increase Notifications using custom mdt
                    
                    rmfNotificationLst.add(cmp);
                    
                    
                }
                
            }
            if(rmfNotificationLst.size() > 0){
                Core_MDF_CampaignUtility.notifyFinanceusers(rmfNotificationLst);  
            }
            if(checkForCase!=null && checkForCase.size()>0){
                for(Case record:[select id,Core_MDF_Strategic_Marketing_Fund_Ind__c,Core_MDF_Campaign_ID__c from Case 
                                 where Core_MDF_Campaign_ID__c in: checkForCase and RecordType.DeveloperName='Core_MDF_Audit']){
                                     record.Core_MDF_Strategic_Marketing_Fund_Ind__c = newCmpList.get(record.Core_MDF_Campaign_ID__c).Core_MDF_Strategic_Marketing_Fund_Ind__c;
                                     caseList.add(record);
                                     
                                     Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e(); 
                                     evtObj.Core_MDF_JSON_Data__c = JSON.serialize(record); 
                                     evtObj.Core_MDF_Object_Name__c = 'Case';
                                     updateRecordList.add(evtObj);
                                 }
            }
            
            if(cmpRRMap != null && !cmpRRMap.isEmpty()){
                for(PartnerFundRequest pfr:[Select Id,Core_MDF_Program__c,Core_MDF_Reimbursement_Rate_txt__c,campaignId from PartnerFundRequest where campaignId IN:cmpRRMap.keySet() AND Core_MDF_Fund_Request_Status__c != 'Cancelled']){
                    if(cmpRRMap.containsKey(pfr.campaignId) && cmpRRMap.get(pfr.CampaignId) != null/* && pfr.Core_MDF_Program__c!='Intel Partner Alliance'*/){
                        pfr.Core_MDF_Reimbursement_Rate_txt__c = cmpRRMap.get(pfr.CampaignId);
                        Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e(); 
                        evtObj.Core_MDF_JSON_Data__c = JSON.serialize(pfr); 
                        evtObj.Core_MDF_Object_Name__c = 'PartnerFundRequest';
                        updateRecordList.add(evtObj);
                    }
                }
            }
            
            if(updateRecordList!=null && updateRecordList.size()>0){
                List<Database.SaveResult> results = EventBus.publish(updateRecordList);
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                       // System.debug('Successfully published event.');
                    } 
                    else { 
                        for(Database.Error err : sr.getErrors()) { 
                           // System.debug('Error returned: ' + err.getStatusCode() ); 
                        }
                    }
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    //Campaign Sharing Generic Method
    public static void shareUnshareCampaignGenericMethod(Map<Id, Campaign> campMap, Map<Id, Set<Id>> campIdToGrpsToBeDeleted){
        Map<Id, Id> accountIdExternalGroupIdMap = new Map<Id, Id>();
        List<CampaignShare> campaignShareList = new List<CampaignShare>();
        Map<Id, List<Id>> campIdExternalGroupIdMap = new Map<Id,List<Id>>(); 
        Map<Id, Set<Id>> accountIdPFAIdMap = new Map<Id,Set<Id>>();
        Set<Id> accountNodeSet = new Set<Id>();
        
        for(Campaign camp : campMap.values()){
            accountNodeSet.add(camp.Core_MDF_Account__c);
        }
        
        if(accountNodeSet.Size() > 0){
            for(Account acc: [SELECT Id, Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketing_Ultimate_Account__c,
                              Core_MDF_Channel_Program__r.Name, Core_MDF_Channel_Program__c, Core_MDF_External_Group_Id__c,
                              Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c, Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,
                              Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c
                              FROM Account WHERE Id IN : accountNodeSet]){
                                  accountIdPFAIdMap.put(acc.Id, new Set<Id> {acc.Id,acc.Core_MDF_Parent_Fund_Account__c,acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c});
                                  if(acc.Core_MDF_External_Group_Id__c != NULL){
                                      accountIdExternalGroupIdMap.put(acc.Id, acc.Core_MDF_External_Group_Id__c);
                                  }
                                  if(acc.Core_MDF_Parent_Fund_Account__c != null && acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c != null){
                                      accountIdExternalGroupIdMap.put(acc.Core_MDF_Parent_Fund_Account__c, acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c);
                                  }
                                  if(acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c != null 
                                     && acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c != null){
                                         accountIdExternalGroupIdMap.put(acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c);
                                     }
                                  
                                  
                              }
        }
        //Delete share records
        if(campMap.size() > 0){
            for(CampaignShare cmpShare : [SELECT Id, CampaignId, UserOrGroupId, Campaign.Core_MDF_Program__c, Campaign.Core_MDF_Account__c
                                          FROM CampaignShare WHERE CampaignId IN : campMap.keySet() AND 
                                          RowCause =: Schema.CampaignShare.RowCause.Manual]){
                                              if(campIdToGrpsToBeDeleted.get(cmpShare.CampaignId).contains(cmpShare.UserOrGroupId)){
                                                  campaignShareList.add(cmpShare);
                                              }
                                          }
        }
        if(campaignShareList != NULL && campaignShareList.size() > 0){
            delete campaignShareList;
        }
        
        for(Campaign cmp : campMap.values()){
            // Checking if accountIdPFAIdMap contains campaign's account id and getting the value from it
            if(accountIdPFAIdMap.containsKey(cmp.Core_MDF_Account__c) && accountIdPFAIdMap.get(cmp.Core_MDF_Account__c) != NULL){
                for(Id accountId : accountIdPFAIdMap.get(cmp.Core_MDF_Account__c)){
                    if(campIdExternalGroupIdMap.containsKey(cmp.Id)){
                        if(accountIdExternalGroupIdMap.get(accountId) != null){
                            campIdExternalGroupIdMap.get(cmp.Id).add(accountIdExternalGroupIdMap.get(accountId));
                        }
                    }
                    else{
                        if(accountIdExternalGroupIdMap.get(accountId) != null){
                            campIdExternalGroupIdMap.put(cmp.Id, new List<Id> {accountIdExternalGroupIdMap.get(accountId)});
                        }
                    }  
                }
            }
        }
        if(campIdExternalGroupIdMap.size() > 0){
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass retailShare = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Campaign', campIdExternalGroupIdMap, 'Read');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(retailShare);
        }
    }
    
    public static string setSupportLegacyProgramField(Integer startYear,String budgetTypes,String programName,Integer endYear){
        String supportLegacy = '';
        if(startYear != NULL && budgetTypes != NULL && programName != NULL){
            if((programName == Label.Core_MDF_IPA_Program_Name || programName == Label.Core_MDF_Retail_Program_Name) && (startYear < 2025 && endYear != NULL && endYear >= 2025)){
                supportLegacy = 'All MDF or both CMP & MDF';
            }
            else{
                if((budgetTypes.contains('OEM CMP') || budgetTypes.contains('Service Provider CMP')) && (!budgetTypes.contains('MDF') && !budgetTypes.contains('MDF+'))){
                    supportLegacy = startYear >= 2025 ? 'New CMP only' : 'CMP Only';
                }
            	else{
                    supportLegacy = startYear >= 2025 ? 'New MDF or both CMP & MDF' : 'MDF or both CMP & MDF';
                }
            }
                
        }
        return supportLegacy;
    }

    // Block CCP campaign deletion - TWC3117-13710
    public static void blockCampaignDeletion(List<Campaign> newCmpList) {
        for (Campaign camp : newCmpList) {
            camp.addError(Label.Core_MDF_BlockCampaignDeletion);
        }
    }
}