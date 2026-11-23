/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_Campaign
* Version     : 1.0 
* Created Date: 10-13-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Anish Patole                  03/10/2020                  US773772,US773817,US773834 Edit OPAL campaign, if campaign has active activites and fields "Start Date , End date , Priorities, Audience, Technology, Activity Category, Country/Region, Brand" are change to some other values its throws and error.
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ProcessCCP_Campaign {
    
    public static Id dcfRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Data_Center_CoMarketing_Fund').getRecordTypeId();
    public static Id ccfRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId(); 
    //public static Id channelRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Channel_MDF').getRecordTypeId();  
    public static Id retailRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();    
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();    

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
        System.debug('countryRecordTypeIdList: '+countryRecordTypeIdList); 
        System.debug('geoRecordTypeIdList: '+geoRecordTypeIdList); 
        System.debug('coMarketingCampaignRecordTypeID: '+coMarketingCampaignRecordTypeID);              
    }
    public static void determineCampaignAttributes(List<Campaign> newCmpList, Map<Id,Campaign> campOldMap, Boolean isInsert, Boolean isUpdate){       
        
        //list<Campaign> coMarketingCamaigns = new list<Campaign>();
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
     
        //Label contains CCF/DCF/SPCF
        //List<String> campaignsToCheckForTechnologyEdit = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CampProgramsForTechnologyCheck').split(';');
        
        //Set of CCF/DCF/SPCF campaign ids 
        //Set<Id> campaignIdSet = new Set<Id>();
        
        //Retrieve Id for Channel Programs
        program = [select id , Core_MDF_Technical_Program_Name__c from ChannelProgram];
        //where Core_MDF_Technical_Program_Name__c LIKE '%Marketing%'
        Map<String, Id> programtype = new Map<String, Id>();
        for(ChannelProgram cp: program){
            programtype.put(cp.Core_MDF_Technical_Program_Name__c, cp.id);
        }
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Campaign').getDescribe().fields.getMap();
        
        Set<Id> campIdSet = new Set<Id>();  
        Map<Id,List<Id>> cmpIdPfrIdListMap = new Map<Id,List<Id>>();
        Map<Id,List<String>> cmpIdfieldListMap = new Map<Id,List<String>>();
        Map<Id,List<String>> cmpIdTextFieldListMap = new Map<Id,List<String>>();
        Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
        
        List<Core_MDF_ProcessCCP_Campaign.campaignEditWrapper> wrapperList = new List<Core_MDF_ProcessCCP_Campaign.campaignEditWrapper>();
        
        //US630940
        Map<String, String> cmpProgWithTextfieldsMap = new Map<String, String>();
        Map<String, String> cmpProgWithPLfieldsMap = new Map<String, String>();
        List<String> subGeoLst = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SubGeos').split(';');
        
        for(Core_MDF_ChannelProgram__mdt cp : [Select Id, Core_MDF_Technical_Program_Name__c,Core_MDF_Campaign_Picklist_Fields__c,
                                               Core_MDF_Campaign_Text_Fields__c
                                               FROM Core_MDF_ChannelProgram__mdt]){
                                                   String key = cp.Core_MDF_Technical_Program_Name__c;
                                                   cmpProgWithPLfieldsMap.put(key, cp.Core_MDF_Campaign_Picklist_Fields__c);
                                                   cmpProgWithTextfieldsMap.put(key, cp.Core_MDF_Campaign_Text_Fields__c);        
                                               }
        
        for(Campaign cmp: newCmpList){
            
            if(geoRecordTypeIdList.contains(cmp.RecordTypeId)){                
                accIdSet.add(cmp.Core_MDF_Account__c);
                    //Populate Budget type and start date and end date//btype,sd,ed,account
                    if(isInsert || (isUpdate && (campOldMap.get(cmp.Id).Core_MDF_Opal_Budget_Type_Txt__c != cmp.Core_MDF_Opal_Budget_Type_Txt__c ||
                                                 campOldMap.get(cmp.Id).StartDate != cmp.StartDate || campOldMap.get(cmp.Id).EndDate != cmp.EndDate ||
                                                 campOldMap.get(cmp.Id).Core_MDF_Account__c != cmp.Core_MDF_Account__c)))
                    {
                        if (cmp.Core_MDF_Opal_Budget_Type_Txt__c =='Retail MDF')
                        {
                        BudgetTypeCamp.add(cmp.Core_MDF_Opal_Budget_Type_Txt__c);

                          if(cmp.StartDate < CampEarliestFutureStartDate )
                            {
                                if(cmp.StartDate < CampEarliestStartDate )
                                 {   
                                  CampEarliestStartDate =cmp.StartDate;
                                }
                    
                             }
                            else{
                                    CampEarliestFutureStartDate = cmp.StartDate;
                                    if(cmp.StartDate < CampEarliestFutureStartDate )
                                    {   
                                         CampEarliestFutureStartDate =cmp.StartDate;     
                                    }
                                }
                        
                             RMFBudgettoCampaignList.add(cmp);
                        }
                    }
               
            }
            //US773772: All CCP Programs - Editing Campaign Start date and end date when an activity already exists
            //Populate campIdSet when Start/End Date changed for CCP Campaigns
            if(countryRecordTypeIdList.contains(cmp.RecordTypeId) && (isUpdate && (cmp.StartDate != campOldMap.get(cmp.Id).StartDate || cmp.EndDate != campOldMap.get(cmp.Id).EndDate))){ 
                campIdSet.add(cmp.Id);
            } 
            //Populate campIdSet when Budget_Amount changes for Retail Campaign
            if(cmp.RecordTypeId  == retailRecordTypeId  && (isUpdate && (cmp.Core_MDF_Budget_Amount_amt__c != campOldMap.get(cmp.Id).Core_MDF_Budget_Amount_amt__c ))){ 
                 if(cmp.Core_MDF_Budget_Amount_amt__c > campOldMap.get(cmp.Id).Core_MDF_Budget_Amount_amt__c)
                 {
                cmp.Core_MDF_RMF_Delta_Budget_Amt__c = cmp.Core_MDF_Budget_Amount_amt__c - campOldMap.get(cmp.Id).Core_MDF_Budget_Amount_amt__c;
                 }
                campIdSet.add(cmp.Id);
                
            } 
            
            if(isUpdate){
                if(cmpProgWithPLfieldsMap.containsKey(cmp.Core_MDF_Program__c) && cmpProgWithPLfieldsMap.get(cmp.Core_MDF_Program__c) != NULL){
                    //for picklist fields
                   // US773817,US773834 Edit OPAL campaign, if campaign has active activities and fields " Priorities, Audience, Technology, Activity Category, Country/Region, Brand" are change to some other values it throws and error.- Start
                    if((cmp.RecordTypeId  == dcfRecordTypeId || cmp.RecordTypeId  == ccfRecordTypeId ) && cmp.Core_MDF_Opal_Budget_Type_Txt__c != null ){
                        List<String> selectedBudgetType = cmp.Core_MDF_Opal_Budget_Type_Txt__c.split(';');
                        //DE121674
                        List<String> oldSelectedBudgetType = campOldMap.get(cmp.Id).Core_MDF_Opal_Budget_Type_Txt__c.split(';');
                        if(selectedBudgetType.size()>0){ // check for CCF/DCF
                            if((!selectedBudgetType.contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CCF1_0')) 
                                || !selectedBudgetType.contains(label.Core_MDF_BudgetType_DCF1_0)) 
                                || (oldSelectedBudgetType != null  
                                    && (!oldSelectedBudgetType.contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CCF1_0'))
                                        || !oldSelectedBudgetType.contains(label.Core_MDF_BudgetType_DCF1_0)) 
                                    && (selectedBudgetType.contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CCF1_0')) 
                                        || selectedBudgetType.contains(label.Core_MDF_BudgetType_DCF1_0)))
                              ) {
                                String getAllAttr = cmpProgWithPLfieldsMap.get(cmp.Core_MDF_Program__c);
                                String removeFieldsNotForOpal = getAllAttr.remove(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Remove_Fields_Validation_OPAL'));// remove fields that are not needed in OPAL
                                String removeAllOPALAttr =  cmpProgWithPLfieldsMap.remove(cmp.Core_MDF_Program__c);// remove all the values
                                cmpProgWithPLfieldsMap.put(cmp.Core_MDF_Program__c,removeFieldsNotForOpal); // add the new values removing the fields not needed in OPAL
                            } else {
                                if(selectedBudgetType.contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CCF1_0'))){
                                String removeAllAttr =   cmpProgWithPLfieldsMap.remove(cmp.Core_MDF_Program__c);// remove the value from metadata, as its contains OPAL ccf fields
                                    cmpProgWithPLfieldsMap.put(cmp.Core_MDF_Program__c,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Fields_Validation')); //add validation fields of ccf
                            }
                            else if(selectedBudgetType.contains(label.Core_MDF_BudgetType_DCF1_0)){
                                String removeAllAttr =   cmpProgWithPLfieldsMap.remove(cmp.Core_MDF_Program__c);// remove the value from metadata, as its contains OPAL dcf fields
                                    cmpProgWithPLfieldsMap.put(cmp.Core_MDF_Program__c,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Fields_Validation'));  //add validation fields of dcf
                                }
                            }
                            /*
                            else{
                                //Inside OPAL CCF/DCF
                                String getAllAttr = cmpProgWithPLfieldsMap.get(cmp.Core_MDF_Program__c);
                                String removeFieldsNotForOpal = getAllAttr.remove(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Remove_Fields_Validation_OPAL'));// remove fields that are not needed in OPAL
                                String removeAllOPALAttr =  cmpProgWithPLfieldsMap.remove(cmp.Core_MDF_Program__c);// remove all the values
                                cmpProgWithPLfieldsMap.put(cmp.Core_MDF_Program__c,removeFieldsNotForOpal); // add the new values removing the fields not needed in OPAL
                                                     
                            }*/
                        }
                    }
                   // US773817,US773834 Edit OPAL campaign, if campaign has active activities and fields " Priorities, Audience, Technology, Activity Category, Country/Region, Brand" are change to some other values it throws and error - END
                    for(String strField: cmpProgWithPLfieldsMap.get(cmp.Core_MDF_Program__c).Split(',')){
                        if(campOldMap.get(cmp.Id).get(strField) != cmp.get(strField)){
                            Core_MDF_ProcessCCP_Campaign.campaignEditWrapper wrapper = new Core_MDF_ProcessCCP_Campaign.campaignEditWrapper();
                            wrapper.field = strField;
                            wrapper.newCmp = cmp;
                            wrapper.oldCmp = campOldMap.get(cmp.Id);
                            wrapperList.add(wrapper);    
                        }    
                    }
                }
                //for text fields
                if(cmpProgWithTextfieldsMap.containsKey(cmp.Core_MDF_Program__c) && cmpProgWithTextfieldsMap.get(cmp.Core_MDF_Program__c) != NULL){
                    for(String textFields: cmpProgWithTextfieldsMap.get(cmp.Core_MDF_Program__c).Split(',')){
                        if(campOldMap.get(cmp.Id).get(textFields) != NULL && campOldMap.get(cmp.Id).get(textFields) != cmp.get(textFields)){                              
                            campIdSet.add(cmp.Id);
                            String labelValue = fieldMap.get(textFields).getDescribe().getLabel();
                            System.debug('labelvalue@@'+labelvalue);
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
               system.debug('campaignIDToCAPAmountMap' + campaignIDToCAPAmountMap + cmp.Core_MDF_Spending_Cap_Amt__c + campOldMap.get(cmp.Id).Core_MDF_Spending_Cap_Amt__c);
            }
        }
        
        if(campaignIDToCAPAmountMap.size() > 0){
            campaignIDToExistingCAPAmountMap = calculatecampaignCAPAmount(campaignIDToCAPAmountMap.keyset());
        }
        
        if(wrapperList != NULL && wrapperList.Size() > 0){
            for(Core_MDF_ProcessCCP_Campaign.campaignEditWrapper wrapper : wrapperList){
                Boolean isRemoved = checkEdit(wrapper.newCmp, wrapper.oldCmp, wrapper.field);
                if(isRemoved){
                    campIdSet.add(wrapper.newCmp.Id);
                    String labelValue = fieldMap.get(wrapper.field).getDescribe().getLabel();
                    if(cmpIdfieldListMap.containsKey(wrapper.newCmp.Id)){
                        cmpIdfieldListMap.get(wrapper.newCmp.Id).add(labelValue);
                    }else{
                        cmpIdfieldListMap.put(wrapper.newCmp.Id, new List<String>{labelValue});
                    }
                }
            }
        }
        
        //check if the Campaign has activity associated with it
        if(campIdSet != NULL){
            for(PartnerFundRequest pfr : [SELECT Id, CampaignId, Core_MDF_Fund_Request_Status__c, Core_MDF_Start_Date__c, Core_MDF_End_Date__c,Core_MDF_Budget_Type_nm__c,RequestedAmount
                                          FROM PartnerFundRequest
                                          WHERE CampaignId IN: campIdSet AND Core_MDF_Fund_Request_Status__c != 'Cancelled']){
                                              
                                              if(cmpIdPfrIdListMap.containsKey(pfr.CampaignId)){
                                                  cmpIdPfrIdListMap.get(pfr.CampaignId).add(pfr.Id);
                                              }else{
                                                  cmpIdPfrIdListMap.put(pfr.CampaignId, new List<Id>{pfr.Id});
                                              }
                                              //US773772                              
                                              pfrMap.put(pfr.Id, pfr); 
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
                    System.debug('accIdSubGeoMap@@@'+accIdSubGeoMap);
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
             
                        if(accIdSetUltimate.get(acc.Core_MDF_CoMarketing_Ultimate_Account__c) != null){
                            for(Id acc1 : accIdSetUltimate.get(acc.Core_MDF_CoMarketing_Ultimate_Account__c))
                        {
                           AccNodeVirtualCorpMap.put(acc1,acc.id);
                        }
                        }
                        accIdPmbSet.add(acc.Id);
                        system.debug('line 290'+acc.Id);

                    }
            }
        
        }
        if (accIdPmbSet.size()>0)
        {
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
                if((cmp.RecordTypeId == dcfRecordTypeId || cmp.RecordTypeId == ccfRecordTypeId) ){
                   if(cmp.Core_MDF_Supports_legacy_program__c != 'Yes'){
                        for(Id pfr: cmpIdPfrIdListMap.get(cmp.Id)){                    
                            if(pfrMap.get(pfr) != NULL && (cmp.StartDate > pfrMap.get(pfr).Core_MDF_Start_Date__c || cmp.EndDate < pfrMap.get(pfr).Core_MDF_End_Date__c)){cmp.addError(Label.Core_MDF_Campaign_Date_Check_Error); //Core_MDF_Campaign_Date_Check_Error //Core_MDF_Campaign_Date_Error: Campaign Date should comply with Activity Date.
                                                                                                                                                                         }
                        }  
                    }     
                }
                if(cmp.RecordTypeId == retailRecordTypeId){
                    decimal Amt = 0;
                    List<Core_MDF_GenericClassToSendMail.MailParams> inputList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
                    for(Id pfr: cmpIdPfrIdListMap.get(cmp.Id)){ 
                        Amt =  Amt+pfrMap.get(pfr).RequestedAmount;
                    }
                    system.debug('Value of total activity amount'+Amt);
                    system.debug('Value of budget type at Campaign level'+cmp.Core_MDF_Budget_Amount_amt__c);
                    if (cmp.Core_MDF_Budget_Amount_amt__c < Amt && !(System.Label.Core_MDF_Bypass_RMF_Budget_Notification  == 'TRUE' ))
                    {
                        cmp.addError('The Campaign Budget Amount Entered is less than the Sum of all Active Activities. Enter an amount Greater than or equal to $'+Amt);
                    }
                    
                   
       
                }
               //US773772 Edit OPAL campaign, if campaign has active activites and fields "Start Date , End date" are change it throws and error - end
              if(cmpIdfieldListMap.containsKey(cmp.Id) && cmpIdfieldListMap.get(cmp.Id) != NULL){  errorpickfields =  String.join(cmpIdfieldListMap.get(cmp.Id),', ') +' '+Label.Core_MDF_Cannot_Remove_PicklistFields;
                    //cmp.addError(errorpickfields);
                }
                if(cmpIdTextFieldListMap.containsKey(cmp.Id) && cmpIdTextFieldListMap.get(cmp.Id) != NULL){ errortxtfields = String.join(cmpIdTextFieldListMap.get(cmp.Id),', ') +' '+Label.Core_MDF_Cannot_Remove_TextFields;
                    //cmp.addError(errortxtfields);    
                }     
                if((String.IsNotBlank(errorpickfields) || String.IsNotBlank(errortxtfields)) && !(System.Label.Core_MDF_Is_ValidationBypassed == 'TRUE' && System.Label.Core_MDF_VRBypassByUser.contains(UserInfo.getUserName()))){ cmp.addError(errorpickfields +' '+ errortxtfields);
                } 
               // cmp.addError(errorpickfields +' '+ errortxtfields);
            }
            
            if(coMarketingCampaignRecordTypeID.contains(cmp.RecordTypeId)){                         
                
                //Setting Channel Program lookup value in Campaign
                
                if(programtype.containsKey(cmp.Core_MDF_Program__c) && programtype.get(cmp.Core_MDF_Program__c) != NULL ){
                    cmp.Core_MDF_Channel_Program__c = programtype.get(cmp.Core_MDF_Program__c);
                }
                
                //Setting Status as In Progress if starts date is today
                //Updated below condition as part of US1048029 changes
                //if((isInsert || (isUpdate && cmp.StartDate != campOldMap.get(cmp.Id).StartDate)) && cmp.StartDate <= system.today()){
                if(((isInsert || (isUpdate && cmp.StartDate != campOldMap.get(cmp.Id).StartDate)) && cmp.StartDate <= system.today() && cmp.EndDate >= system.today()) || 
                    (isUpdate && cmp.EndDate != campOldMap.get(cmp.Id).EndDate && cmp.EndDate >= system.today() && cmp.StartDate <= system.today())){
                    cmp.Status = 'In Progress'; 
                }
                else if((isInsert || (isUpdate && cmp.StartDate != campOldMap.get(cmp.Id).StartDate)) && cmp.StartDate > system.today()){
                    cmp.Status = 'Planned'; 
                }else if(isUpdate && cmp.EndDate != campOldMap.get(cmp.Id).EndDate && cmp.EndDate < system.today()){
                    cmp.Status = 'Completed';
                }
                
                //Setting Status as Cancelled when 'Cancel campaign' button is clicked and if previous campaign status is not Completed
                if(isUpdate && cmp.Status == 'Cancelled')
                {
                    if(campOldMap.get(cmp.Id).Status != 'Completed'){
                        cmp.Status = 'Cancelled';
                    }  
                    else{ if(cmpIdTextFieldListMap.get(cmp.Id) != NULL  && !(System.Label.Core_MDF_Is_ValidationBypassed == 'TRUE' && System.Label.Core_MDF_VRBypassByUser.contains(UserInfo.getUserName()))){
                        cmp.addError(Label.Core_MDF_Cancel_Campaign_Error_Message);
                    }
                }
                }
                System.debug('geoRecordTypeIdList1@@@'+geoRecordTypeIdList);
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
                
                System.debug('cmp.Core_MDF_Region_cd__c@@@'+cmp.Core_MDF_Region_cd__c);  
                System.debug('cmp.Core_MDF_Sub_Region_cd__c@@@'+cmp.Core_MDF_Sub_Region_cd__c);                  
                
                //Check if the record is of CCF/DCF/CCFB/SPCF
                if(countryRecordTypeIdList.contains(cmp.RecordTypeId) && (isInsert || (isUpdate && campOldMap.get(cmp.Id).Core_MDF_Market__c != cmp.Core_MDF_Market__c))){
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
                }
                
                System.debug('cmp.Core_MDF_Region_cd__c---' + cmp.Core_MDF_Region_cd__c);
                /*
                //NP - WIP Opal Changes - DO NOT DELETE
                if((cmp.Core_MDF_Activity_Category_Type__c != NULL || cmp.Core_MDF_CMP_Activity_Category_Type_Txt__c !=NULL || cmp.Core_MDF_Flex_Activity_Category_Type_Txt__c !=NULL) && (isInsert || (isUpdate && (cmp.Core_MDF_Activity_Category_Type__c != campOldMap.get(cmp.Id).Core_MDF_Activity_Category_Type__c || cmp.Core_MDF_CMP_Activity_Category_Type_Txt__c != campOldMap.get(cmp.Id).Core_MDF_CMP_Activity_Category_Type_Txt__c || cmp.Core_MDF_Flex_Activity_Category_Type_Txt__c != campOldMap.get(cmp.Id).Core_MDF_Flex_Activity_Category_Type_Txt__c) ))){
                    //coMarketingCamaigns.add(cmp);
                    
                    List<String> opalRecTypeDeveloperName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Opal_Campaign_RecordType_API_Nm').split(',');
                    for(String str: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Opal_Campaign_RecordType_API_Nm').split(',')){
                        opalCampaignRecordTypeID.add(Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(str).getRecordTypeId());
                    }
                    
                    system.debug('opalCampaignRecordTypeID' + opalCampaignRecordTypeID);
                    
                    if(opalCampaignRecordTypeID.contains(cmp.RecordTypeId)){
                        if(cmp.Core_MDF_CMP_Activity_Category_Type_Txt__c != null){
                            tempStr = cmp.Core_MDF_CMP_Activity_Category_Type_Txt__c;
                        }
                        if(cmp.Core_MDF_Flex_Activity_Category_Type_Txt__c != null){
                            tempStr = tempStr==null? cmp.Core_MDF_Flex_Activity_Category_Type_Txt__c : tempStr +';'+ cmp.Core_MDF_Flex_Activity_Category_Type_Txt__c;
                        }
                        system.debug('tempStr' + tempStr);
                    }
                    else{
                        tempStr = cmp.Core_MDF_Activity_Category_Type__c;       
                    }*/
                    
                    if(cmp.Core_MDF_Activity_Category_Type__c != NULL && (isInsert || (isUpdate && cmp.Core_MDF_Activity_Category_Type__c != campOldMap.get(cmp.Id).Core_MDF_Activity_Category_Type__c ))){
                    //coMarketingCamaigns.add(cmp);
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
                    system.debug('activity: '+activity);
                    if(activity != NULL){
                        cmp.Core_MDF_Activity_Type__c = activity;                    
                    }
                    
                    //Preparing category picklist value by iterating category set
                    String category = '';
                    for(String str2 : categorySet){
                        category = category + str2 +';';
                    }
                    system.debug('category:'+category);
                    if(category != NULL){
                        cmp.Core_MDF_Activity_Category__c = category;                    
                    }
                    
                    categorySet.clear();
                    activitySet.clear();
                    finalGeoSet.clear();                    
                }
            }
            
            //US819148 : [CCP] Campaign Level CAP - Campaign Validations
            system.debug('campaignIDToCAPAmountMap.get(campID)' + campaignIDToCAPAmountMap.get(cmp.id));
            system.debug('campaignIDToExistingCAPAmountMap.get(campID)' + campaignIDToExistingCAPAmountMap.get(cmp.id));
            if(campaignIDToCAPAmountMap.containsKey(cmp.id) && (campaignIDToCAPAmountMap.get(cmp.id)< campaignIDToExistingCAPAmountMap.get(cmp.id))){cmp.addError(Label.Core_MDF_Campaign_CAP_Error_Message + campaignIDToExistingCAPAmountMap.get(cmp.id));    
            } 
        }
        //RMFCamptoBudgettypeMap = queryPmbRecords(BudgetTypeCamp,CampEarliestStartDate,CampEarliestFutureStartDate,accIdPmbSet);
        system.debug('Here 511'+RMFCamptoBudgettypeMap);
        if (RMFBudgettoCampaignList.size()>0 
             && mapFunctionalityNameTriggerExecution != null 
             &&mapFunctionalityNameTriggerExecution.containsKey('BypassRetailMDFBudgetValidation') && 
             !mapFunctionalityNameTriggerExecution.get('BypassRetailMDFBudgetValidation').Core_Active__c)
        {
        system.debug('Line 518'+RMFBudgettoCampaignList);
        validateBudgetToCampaignMap(RMFBudgettoCampaignList,RMFCamptoBudgettypeMap,AccNodeVirtualCorpMap);
        }
       
        }
    
 
    
    public static Map <String,List<PartnerMarketingBudget>> queryPmbRecords(Set<String> Budgettypes , Date EarliestStartDate,Date CampEarliestFutureStartDate,Set<Id>accIdPmbSet){
         Map <String,List<PartnerMarketingBudget>> PartnerMarketingBudgetListMap = new Map <String,List<PartnerMarketingBudget>> ();
         Boolean istrue = false;
         system.debug('Line 457'+EarliestStartDate);
          system.debug('Line 458'+CampEarliestFutureStartDate);
         List<PartnerMarketingBudget> PmbList=[Select id,StartDate,EndDate ,Core_MDF_Budget_Type_Txt__c,Core_MDF_Budget_Partner__c,
                                               Core_MDF_Program_Nm__c from PartnerMarketingBudget where   
                                               Core_MDF_Budget_Type_Txt__c  IN: Budgettypes
                                               AND Core_MDF_Budget_Partner__c IN: accIdPmbSet
                                               AND (TotalAllocatedAmount > 0)
                                               AND ((StartDate <=: EarliestStartDate 
                                               AND EndDate >=: EarliestStartDate)
                                                OR (StartDate <=: CampEarliestFutureStartDate
                                                   and EndDate >=:CampEarliestFutureStartDate)) order by StartDate  ];
  
       
        
       for (PartnerMarketingBudget budget :PmbList) {
            string key = budget.Core_MDF_Budget_Type_Txt__c + budget.Core_MDF_Budget_Partner__c;
            if(PartnerMarketingBudgetListMap.get(key) == null)
            {
                
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
    public static void validateBudgetToCampaignMap(List<Campaign> RMFBudgettoCampaignList,Map<String,List<PartnerMarketingBudget>> RMFCamptoBudgettypeMap,Map <id,id>AccNodeVirtualCorpMap)
    {
        try
        { 
               for (Campaign cmp : RMFBudgettoCampaignList)
                {   
                     boolean var = false;
                     system.debug('549'+RMFBudgettoCampaignList);
                     system.debug('550'+RMFCamptoBudgettypeMap);
                     system.debug('551'+AccNodeVirtualCorpMap);
                    
                   if (RMFCamptoBudgettypeMap.containsKey(cmp.Core_MDF_Opal_Budget_Type_Txt__c+AccNodeVirtualCorpMap.get(cmp.Core_MDF_Account__c)))
                   {
                     system.debug('Enter 556');
                     for( PartnerMarketingBudget pmbbudget : RMFCamptoBudgettypeMap.get(cmp.Core_MDF_Opal_Budget_Type_Txt__c+AccNodeVirtualCorpMap.get(cmp.Core_MDF_Account__c)))//+othermap.get(cmp.accid)) )
                         {
                           system.debug('Enter 559');
                           if(cmp.StartDate >= pmbbudget.StartDate && cmp.EndDate <= pmbbudget.EndDate && cmp.Core_MDF_Opal_Budget_Type_Txt__c==pmbbudget.Core_MDF_Budget_Type_Txt__c)
                            {
                                system.debug('Enter 562');
                                var =true;
                                break;
                            }

                         }
                    }
                    system.debug ('Value of var'+var);
                    if (!var)
                    {
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
                
                system.debug('campIdWithCAPAmount' + campIdWithCAPAmount);  
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
        
        public static CampaignShare createCampaignShare(Id campaignId, Id groupId){
            
            try{
                CampaignShare shareRecord = new CampaignShare();
                shareRecord.CampaignId = campaignId;
                shareRecord.RowCause = 'Manual';
                shareRecord.CampaignAccessLevel = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Read_Access');
                shareRecord.UserOrGroupId = groupId;
                return shareRecord;
            }
            catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);return null;}
        }
        
        public static void shareUnshareCampaign(List<Campaign> newCmpList, Map<Id,Campaign> campOldMap, boolean isInsert, boolean isUpdate){ 
            
            Set<Id> accId = new Set<Id>();
            Set<Id> ultimateAccId = new Set<Id>();
            Set<Id> programIdSet = new Set<Id>();
            Set<String> geoSet = new Set<String>();
            Map<Id, String> cpIdNameMap = new Map<Id, String>();
            
            //List of campaign to be shared
            List<Campaign> campaignToBeShared = new List<Campaign>();
            
            //List of Campaign's Id whose share record has to be deleted
            List<Id> campaignShareToBeDeleted = new List<Id>();
            
            //Campaign Share records from the above list
            List<CampaignShare> campaignShareList = new List<CampaignShare>();
            
            //Map used to determine geo based internal group; key - AccId+ProgramId+Geo and Value - GroupId
            Map<String,Id> geoInternalMap = new Map<String,Id>();
            
            //Map used to determine subgeo based internal group; key - AccId+ProgramId+Geo+SubGeo and Value - GroupId
            Map<String,Id> subgeoInternalMap = new Map<String,Id>();
            
            //Map used to determine WW group; key - AccId+ProgramId and Value - GroupId
            Map<String,Id> wwInternalMap = new Map<String,Id>();
            
            //Map used to determine external group; key - AccId+ProgramId and Value - GroupId
            Map<String,Id> externalMap = new Map<String,Id>();
            
            //Map used to determine budget type group; key- AccId+ProgramId+BudgetType and Value - GroupId
            Map<String,Id> budgetTypeMap = new Map<String,Id>();
            
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
            
            //Iterate over campaign list and get geoSet, accId, programIdSet, campaignToBeShared and campaignShareToBeDeleted
            for(Campaign cmp : newCmpList){          
                system.Debug('---cmp'+coMarketingCampaignRecordTypeID.contains(cmp.RecordTypeId));
                if((isInsert || (isUpdate && 
                                 (cmp.OwnerId != campOldMap.get(cmp.Id).OwnerId || 
                                  cmp.Core_MDF_External_Visibility_Date__c != campOldMap.get(cmp.Id).Core_MDF_External_Visibility_Date__c ||
                                  cmp.Core_MDF_Region_cd__c != campOldMap.get(cmp.Id).Core_MDF_Region_cd__c ||
                                  cmp.Core_MDF_Account__c != campOldMap.get(cmp.Id).Core_MDF_Account__c))) && 
                   coMarketingCampaignRecordTypeID.contains(cmp.RecordTypeId)){
                       system.Debug('---insidr=e if ');
                       List<String> geoList = cmp.Core_MDF_Region_cd__c.split(';');
                       for(String geo : geoList){                    
                           geoSet.add(geo);   
                       }
                       
                       /*if(cmp.Core_MDF_Program__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name')){
            programIdSet.add(cmp.Core_MDF_Channel_Program__c);
            }*/
                       
                       Boolean isNodeBasedSharingReqd = Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(cmp.Core_MDF_Program__c);
                       
                   //   if(!isNodeBasedSharingReqd){
                           programIdSet.add(cmp.Core_MDF_Channel_Program__c); 
                      // }                                  
                       
                       accId.add(cmp.Core_MDF_Account__c);
                       campaignToBeShared.add(cmp);
                       //Check if Region or Account or External Visibility date has been changed, if yes then the share records has to be deleted
                       if(isUpdate && (cmp.Core_MDF_Region_cd__c != campOldMap.get(cmp.Id).Core_MDF_Region_cd__c || 
                                       cmp.Core_MDF_Account__c != campOldMap.get(cmp.Id).Core_MDF_Account__c ||
                                       cmp.Core_MDF_External_Visibility_Date__c != campOldMap.get(cmp.Id).Core_MDF_External_Visibility_Date__c)){
                                           campaignShareToBeDeleted.add(cmp.Id);
                                       }
                   }
            }
            
            //Get the Parent Fund Account Id set from accId set //Ultimate account
            //Key = Acc Id; Value = Group Id on Account
            Map<Id,Id> accIdToAccGroupIdMap = new Map<Id,Id>();
            if(accId.Size() > 0){
                for(Account acc: [SELECT Id, Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketing_Ultimate_Account__c,
                                  Core_MDF_Channel_Program__r.Name, Core_MDF_Channel_Program__c, 
                                  Core_MDF_Group_Id__c, Core_MDF_External_Group_Id__c, Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c,
                                  Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, 
                                  Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c
                                  FROM Account 
                                  WHERE Id IN : accId]){
                                      if(acc.Core_MDF_CoMarketing_Ultimate_Account__c != null){
                                          ultimateAccId.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                                          accountMap.put(acc.Id, acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                                          cpIdNameMap.put(acc.Core_MDF_Channel_Program__c, acc.Core_MDF_Channel_Program__r.Name);                                       
                                      }
                                      // Checking if Program equals RMF or not
                                      if(acc.Core_MDF_Channel_Program__r.Name.equals(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name'))){
                                          // Updating accountIdPFAIdMap with key as acc.Id and value as associated accounts
                                          accountIdPFAIdMap.put(acc.Id, new Set<Id> {acc.Id,acc.Core_MDF_Parent_Fund_Account__c,acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c});
                                          if(acc.Core_MDF_Group_Id__c != NULL){
                                              accIdToAccGroupIdMap.put(acc.Id,acc.Core_MDF_Group_Id__c); 
                                          }
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
                                                              }
            
            //Delete share records
            if(campaignShareToBeDeleted.size() > 0){
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
            
            // For Retail External Sharing
            // Iterating over Campaigns to prepare the campId and the set of all account id's associated to the campaign - Max 3 levels
            for(Campaign cmp : newCmpList){
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
            
            //Prepare geoInternalMap, subgeoInternalMap, wwInternalMap and externalMap
            if(programIdSet != NULL && programIdSet.Size() > 0){
                for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Core_MDF_Group_Id__c,Id, Name, Core_MDF_Account__c, Core_MDF_Group_Name__c,
                                                             Core_MDF_Type_of_Access__c,Core_MDF_Works_For__c, Core_MDF_Channel_Program__c, Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c,Core_MDF_BudgetType_nm__c/*Core_MDF_Budget_Type_nm__c*/,Core_MDF_Channel_Program__r.Name
                                                             FROM Core_MDF_Partner_Group_Mapping__c 
                                                             WHERE Core_MDF_Account__c IN : ultimateAccId AND
                                                             Core_MDF_Channel_Program__c IN : programIdSet]){
                                                             
                                                                 if(pgm.Core_MDF_Type_of_Access__c == 'INTERNAL' && (geoSet.Contains(pgm.Core_MDF_Region_cd__c) || pgm.Core_MDF_Channel_Program__r.Name == 'Retail Marketing Funds') && pgm.Core_MDF_BudgetType_nm__c == null){
                                                                 system.debug('PGM data==>'+pgm.Id);                                            
                                                                     if(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                                                                         String accountIdProgramIdSubGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                                                                         subgeoInternalMap.put(accountIdProgramIdSubGeo, pgm.Core_MDF_Group_Id__c); 
                                                                     }   
                                                                     else{
                                                                         String accountIdProgramIdGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                                                                         geoInternalMap.put(accountIdProgramIdGeo, pgm.Core_MDF_Group_Id__c);     
                                                                     }
                                                                     system.debug('geoInternalMap1==>'+geoInternalMap);
                                                                 } 
                                                                 if(pgm.Core_MDF_Type_of_Access__c == 'INTERNAL' && pgm.Core_MDF_Region_cd__c == 'WW'){
                                                                     if(pgm.Core_MDF_BudgetType_nm__c == null){
                                                                         String accountIdProgramId = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                                                                         wwInternalMap.put(accountIdProgramId,pgm.Core_MDF_Group_Id__c);
                                                                     }else{ // for WW with budget type
                                                                         String accountIdProgramIdBudget = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_BudgetType_nm__c;
                                                                         wwInternalMap.put(accountIdProgramIdBudget,pgm.Core_MDF_Group_Id__c);
                                                                     }
                                                                 }
                                                                 
                                                                 if(pgm.Core_MDF_Type_of_Access__c == 'EXTERNAL'){
                                                                     String accountIdProgramId = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                                                                     externalMap.put(accountIdProgramId,pgm.Core_MDF_Group_Id__c);
                                                                 }
                                                                 
                                                                 // budget type sharing
                                                                 if(pgm.Core_MDF_Type_of_Access__c == 'INTERNAL' && pgm.Core_MDF_BudgetType_nm__c != null){
                                                                    String accountIdProgramIdBudgetType = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c + pgm.Core_MDF_BudgetType_nm__c;
                                                                    budgetTypeMap.put(accountIdProgramIdBudgetType,pgm.Core_MDF_Group_Id__c);
                                                                }
                                                                 system.debug('budgetTypeMap1==>'+budgetTypeMap);
                                                             }
            }
            
            // Channel MDF program list
            List<String> newProgramList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name').Split(';');
            
            //Iterate over campaignToBeShared and prepare share records for each campaign
            for(Campaign cmp : campaignToBeShared){
                
                List<Id> userorGroupIdToShare = new List<Id>();
                List<String> geoLst = new List<String>();// = cmp.Core_MDF_Region_cd__c.Split(';');
                if(cmp.Core_MDF_Program__c == 'Retail Marketing Funds'){
                    geoLSt = new list<String>{'APJ','EMEA','PRC','ASMO'};
                }else{
                    geoLst = cmp.Core_MDF_Region_cd__c.Split(';');
                }
                //If external visibility date is Less than or equal to today's date and if Record Type is CCF/DCF/SPCF/CCFB, then share the campaign with internal and external groups
               // if(countryRecordTypeIdList.contains(cmp.RecordTypeId)){
                    //List<String> geoLst = cmp.Core_MDF_Region_cd__c.Split(';');
                    for(String geo : geoLst){
                        String accountIdProgramId = (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c;
                        String accountIdProgramIdGeo = (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + geo;
                        //String accountIdProgramIdBudgetType =  (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + geo + (String)cmp.Core_MDF_Budget_Type_txt__c;
                        String accountIdProgramIdBudgetType =  (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + geo + cmp.Core_MDF_Sub_Region_cd__c + cmp.Core_MDF_Opal_Budget_Type_Txt__c;
                        String accountIdProgramIdBudget = (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + cmp.Core_MDF_Opal_Budget_Type_Txt__c;
                        String accountIdProgramIdSubGeo = (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + geo + cmp.Core_MDF_Sub_Region_cd__c;
                        
                        
                        if(geoInternalMap.containsKey(accountIdProgramIdGeo)){
                            cmpShareList.add(createCampaignShare(cmp.Id, geoInternalMap.get(accountIdProgramIdGeo)));
                            userorGroupIdToShare.add(geoInternalMap.get(accountIdProgramIdGeo));
                        }
                        
                        if(wwInternalMap.containsKey(accountIdProgramId)){
                            cmpShareList.add(createCampaignShare(cmp.Id, wwInternalMap.get(accountIdProgramId)));
                            userorGroupIdToShare.add(wwInternalMap.get(accountIdProgramId));
                        }
                        
                        if(cmp.Core_MDF_External_Visibility_Date__c <= Date.Today() && externalMap.containsKey(accountIdProgramId)){
                            cmpShareList.add(createCampaignShare(cmp.Id, externalMap.get(accountIdProgramId)));
                            userorGroupIdToShare.add(externalMap.get(accountIdProgramId));
                        }
                        
                        // for budget type
                        if(budgetTypeMap.containsKey(accountIdProgramIdBudgetType)){
                            cmpShareList.add(createCampaignShare(cmp.Id, budgetTypeMap.get(accountIdProgramIdBudgetType)));
                           // userorGroupIdToShare.add(budgetTypeMap.get(accountIdProgramIdBudgetType));
                            system.debug('budget type group==>'+budgetTypeMap.get(accountIdProgramIdBudgetType));
                        }
                        
                        // for WW with budget type
                        if(wwInternalMap.containsKey(accountIdProgramIdBudget)){
                            cmpShareList.add(createCampaignShare(cmp.Id, wwInternalMap.get(accountIdProgramIdBudget)));
                            userorGroupIdToShare.add(wwInternalMap.get(accountIdProgramIdBudget));
                        }
                        if(cmp.Core_MDF_Program__c == 'Retail Marketing Funds' && geo =='ASMO'){
                            List<String> subGeo = new List<String>{'NAR','LAR'};
                            for(String subG : subGeo){
                                accountIdProgramIdSubGeo = (String)accountMap.get(cmp.Core_MDF_Account__c) + (String)cmp.Core_MDF_Channel_Program__c + geo + subG;
                        if(subgeoInternalMap.containsKey(accountIdProgramIdSubGeo)){
                            cmpShareList.add(createCampaignShare(cmp.Id, subgeoInternalMap.get(accountIdProgramIdSubGeo)));
                            userorGroupIdToShare.add(subgeoInternalMap.get(accountIdProgramIdSubGeo));
                            system.debug('subgeoInternalMap group==>'+subgeoInternalMap.get(accountIdProgramIdSubGeo));
                        }
                            }
                        }else{
                            if(subgeoInternalMap.containsKey(accountIdProgramIdSubGeo)){
                                cmpShareList.add(createCampaignShare(cmp.Id, subgeoInternalMap.get(accountIdProgramIdSubGeo)));
                                userorGroupIdToShare.add(subgeoInternalMap.get(accountIdProgramIdSubGeo));
                            }
                        }
                        
                        system.debug('geo'+geo);
                        system.debug('cpIdNameMap==>'+cpIdNameMap);
                        system.debug('cmp.Core_MDF_Channel_Program__c==>'+cmp.Core_MDF_Channel_Program__c);
                        
                        //if(cmp.Core_MDF_Program__c== Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name')){
                        if(newProgramList.contains(cmp.Core_MDF_Program__c)){
                            Core_MDF_RecordGeoShare recGeoShr = new Core_MDF_RecordGeoShare(cmp.Id,geo,cmp.Core_MDF_Sub_Region_cd__c,cpIdNameMap.get(cmp.Core_MDF_Channel_Program__c),cmp.Core_MDF_Opal_Budget_Type_Txt__c);
                            recGeoShrLst.add(recGeoShr); 
                            System.debug('recGeoShr'+recGeoShr);
                        } else if(cmp.Core_MDF_Program__c == 'Retail Marketing Funds'){
                            if(geo == cmp.Core_MDF_Region_cd__c){
                                Core_MDF_RecordGeoShare recGeoShr = new Core_MDF_RecordGeoShare(cmp.Id,geo,null,cpIdNameMap.get(cmp.Core_MDF_Channel_Program__c));
                                recGeoShrLst.add(recGeoShr);                  
                          }
                        } else{
                            Core_MDF_RecordGeoShare recGeoShr = new Core_MDF_RecordGeoShare(cmp.Id,geo,null,cpIdNameMap.get(cmp.Core_MDF_Channel_Program__c));
                            recGeoShrLst.add(recGeoShr);
                        }
                                     
                  //  }
                }
                //If Record Type is Retail, then share the campaign with internal and external groups
                if(geoRecordTypeIdList.contains(cmp.RecordTypeId)){
                    
                    if(accIdToAccGroupIdMap.containsKey(cmp.Core_MDF_Account__c) && accIdToAccGroupIdMap.get(cmp.Core_MDF_Account__c) != NULL){
                        cmpShareList.add(createCampaignShare(cmp.Id, accIdToAccGroupIdMap.get(cmp.Core_MDF_Account__c)));
                    }
                    
                    //Sharing for FM grp  
                    Core_MDF_RecordGeoShare recGeoShr = new Core_MDF_RecordGeoShare(cmp.Id,cmp.Core_MDF_Region_cd__c, cmp.Core_MDF_Sub_Region_cd__c,cpIdNameMap.get(cmp.Core_MDF_Channel_Program__c));
                    recGeoShrLst.add(recGeoShr);
                }
                
                
                //This map will be used to share region wise and category wise records
                if(userorGroupIdToShare.Size() > 0){
                    objectIdUserGroupIdListMapToShare.Put(cmp.Id, userorGroupIdToShare);
                }   
            }
            
            if(cmpShareList.Size() > 0){
                system.debug('line 1011'+cmpShareList);
                database.insert(cmpShareList);
            }
            
            if(recGeoShrLst.size() > 0){
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Campaign', recGeoShrLst);
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
                    //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Regionwise_Campaign_Budget__c',regionWiseShareMap);
                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Regionwise_Campaign_Budget__c',regionWiseShareMap, 'Edit');
                    Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
                }
                
                //Creating Share Records for Category Wise Campaign Budget
                if(categoryWiseShareMap.size() > 0){
                    //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Categorywise_Campaign_Budget__c',categoryWiseShareMap);
                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst1 = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Categorywise_Campaign_Budget__c',categoryWiseShareMap, 'Edit');
                    Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst1);
                }
            }
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
                if(((cmp.Core_MDF_Program__c == 'Client CoMarketing Fund' && cmp.Core_MDF_Opal_Budget_Type_Txt__c == 'CCF 1.0') || (cmp.Core_MDF_Program__c == 'Data Center CoMarketing Fund' && cmp.Core_MDF_Opal_Budget_Type_Txt__c == 'DCF 1.0') 
                    || cmp.Core_MDF_Program__c == 'Client CoMarketing Fund Boost' || cmp.Core_MDF_Program__c == 'Service Provider CoMarketing Fund') && cmp.Core_MDF_Reimbursement_Rate__c != campOldMap.get(cmp.Id).Core_MDF_Reimbursement_Rate__c){
                    cmpRRMap.put(cmp.Id,cmp.Core_MDF_Reimbursement_Rate__c);
                }
                   if(cmp.RecordTypeId == retailRecordTypeId && cmp.Core_MDF_Budget_Amount_amt__c > campOldMap.get(cmp.Id).Core_MDF_Budget_Amount_amt__c && cmp.Status!='Cancelled'){
                   
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
                for(PartnerFundRequest pfr:[Select Id,Core_MDF_Reimbursement_Rate_txt__c,campaignId from PartnerFundRequest where campaignId IN:cmpRRMap.keySet() AND Core_MDF_Fund_Request_Status__c != 'Cancelled']){
                    if(cmpRRMap.containsKey(pfr.campaignId) && cmpRRMap.get(pfr.CampaignId) != null){
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
                        System.debug('Successfully published event.');
                    } 
                    else { 
                        for(Database.Error err : sr.getErrors()) { 
                            System.debug('Error returned: ' + err.getStatusCode() ); 
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
        
    }