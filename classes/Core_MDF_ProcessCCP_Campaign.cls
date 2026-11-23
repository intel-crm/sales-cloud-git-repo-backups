/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_Campaign 
* Version     : 1.0 
* Created Date: 7-10-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar K        7/5/2018                    Created Core_MDF_ProcessCCP_Campaign class to block campaign creation if the first year amount/second year amount exceeds the available budget amount.
* Accenture - Shridhar K        7/31/2018                   Commented block campaign creation logic as the US95990 is deleted.
* Accenture - Shridhar K        7/31/2018                   Populating Activity Type and Activity Category values from Activity Category -> Type.
* Accenture - Shridhar K        7/31/2018                   Populating Activity Type and Activity Category values from Activity Category -> Type.
* Intel – Narayani Perachi      9/24/2018                   Replaced variables from DCFRecordTypeId to dcfRecordTypeId, ccfRecordTypeId to ccfRecordTypeId as per Code Scan suggestions
* Intel - Narayani Perachi      9/24/2018                   Added without sharing to class Core_MDF_ProcessCCP_Campaign
* Accenture - Shridhar K        2/08/2019                   Co-marketing recordType check is modified to handle new recordType dynamically 
* Intel - NP(11630236)          12/24/2019                  US535221: Cancel Campaign - Remove Approval lock from PFR
* Accenture - Varun             03/18/2020                  US601433: [CCF/DCF/SPCF] Campaign: Cannot edit Technology field in Campaign when there's at least 1 activity created 
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ProcessCCP_Campaign {

    //public static Id dcfRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Data_Center_CoMarketing_Fund').getRecordTypeId();
    //public static Id ccfRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund').getRecordTypeId();    
    //public static Id retailRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();    

    //Below list and Static block is added by Shridhar to fetch all Co-Marketing record type
    public static List<Id> coMarketingCampaignRecordTypeID  = new List<Id>();   

    //Below list will contain CCP Campaign Record Types like CCF/DCF/SPCF/CCF Boost
    public static List<Id> countryRecordTypeIdList = new List<Id>();

    //Below list will contain CCP Campaign Record Types like Retail
    public static List<Id> geoRecordTypeIdList = new List<Id>();

    //Below Map will contain Map of country and countryGeoSubGeoWrapper
    public static Map<String,Core_MDF_GeoBasedGenericSharing.countryGeoSubGeoWrapper> wrapperMap = new Map<String,Core_MDF_GeoBasedGenericSharing.countryGeoSubGeoWrapper>();

    Static{
        //Call the getCountryGeoMap method from Core_MDF_GeoBasedGenericSharing class
        wrapperMap = Core_MDF_GeoBasedGenericSharing.getCountryGeoMap();
        
        List<String> recTypeDeveloperName = Label.Core_MDF_CCP_RecordType_API_Name.split(',');
        for(String str: recTypeDeveloperName){
            coMarketingCampaignRecordTypeID.add(Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(str).getRecordTypeId());
            if(!Label.Core_MDF_CampaignWithoutCountry.Contains(str)){
                countryRecordTypeIdList.add(Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(str).getRecordTypeId());
            }
            if(Label.Core_MDF_CampaignWithoutCountry.Contains(str)){
                geoRecordTypeIdList.add(Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(str).getRecordTypeId());
            }
        }
        System.debug('countryRecordTypeIdList: '+countryRecordTypeIdList); 
        System.debug('geoRecordTypeIdList: '+geoRecordTypeIdList); 
        System.debug('coMarketingCampaignRecordTypeID: '+coMarketingCampaignRecordTypeID);              
    }
   
    /****************************************************************************************************************************************
    Method Name:                                             determineCampaignAttributes
    @return  :                                               List of Campaigns with budgtes
    @parameters:                                             List of campaigns, campaigns oldMap, isInsert and isUpdate                                 
    Description:                                             US95990 - block campaign creation if the first year amount/second year amount exceeds the available budget amount.
    Added By:                                                Accenture – Shridhar K  -  7/5/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar K        7/5/2018                   Created.
    Accenture - Shridhar K        7/31/2018                  Commented block campaign creation logic as the US95990 is deleted.
    Accenture - Shridhar K        7/31/2018                  Populating Activity Type and Activity Category values from Activity Category -> Type.
    Intel - Narayani Perachi      8/1/2018                   Setting Channel Program lookup field in Campaign.
    Intel - Narayani Perachi      8/1/2018                   Setting Status as Cancelled when 'Cancel campaign' button is clicked. 
    Intel - Narayani Perachi      8/21/2018                  Added code to restrict Cancel campaign on Completed campaigns. 
    Accenture - Shridhar K        2/08/2019                  Co-marketing recordType check is modified to handle new recordType dynamically
    Accenture - Varun             3/18/2020                  Added check to restrict technology edit if there are activities created
    *****************************************************************************************************************************************/
    public static void determineCampaignAttributes(List<Campaign> newCmpList, Map<Id,Campaign> campOldMap, Boolean isInsert, Boolean isUpdate){       
        
        //list<Campaign> coMarketingCamaigns = new list<Campaign>();
        String tempStr;
        List<String> listTempString = new list<String>();
        List<String> activityWithCategory = new list<String>();
        Set<String> activitySet = new Set<String>();
        Set<String> categorySet = new Set<String>();      
        list<ChannelProgram> program = new list<ChannelProgram>();
        
        Set<Id> accIdSet = new Set<Id>();
        Map<Id,String> accIdGeoMap = new Map<Id,String>();
        //Map of accId and acc's sub geo 
        Map<Id,String> accIdSubGeoMap = new Map<Id,String>();
        Set<String> finalGeoSet = new Set<String>();
        
        //Label contains CCF/DCF/SPCF
        List<String> campaignsToCheckForTechnologyEdit = Label.Core_MDF_CampProgramsForTechnologyCheck.split(';');
        
        //Set of CCF/DCF/SPCF campaign ids
        Set<Id> campaignIdSet = new Set<Id>();
        
        //Retrieve Id for Channel Programs
        program = [select id , Core_MDF_Technical_Program_Name__c from ChannelProgram where Core_MDF_Technical_Program_Name__c LIKE '%Marketing%'];
        Map<String, Id> programtype = new Map<String, Id>();
        for(ChannelProgram cp: program)
        {
            programtype.put(cp.Core_MDF_Technical_Program_Name__c, cp.id);
        }
        
        //Populate accIdSet for Retail Record Type
        for(Campaign cmp: newCmpList){
            if(geoRecordTypeIdList.contains(cmp.RecordTypeId)){
                accIdSet.add(cmp.Core_MDF_Account__c);  
                
            }
            //Set containing CCF/DCF/SPCF campaign Id to get PFR
            if(isUpdate && ((campaignsToCheckForTechnologyEdit.contains(cmp.Core_MDF_Program__c)) && 
                            (cmp.Core_MDF_Technology__c != campOldMap.get(cmp.Id).Core_MDF_Technology__c))){
                for(String oldTechnology : campOldMap.get(cmp.Id).Core_MDF_Technology__c.Split(';')){
                    if(!cmp.Core_MDF_Technology__c.Split(';').contains(oldTechnology)){
                        campaignIdSet.add(cmp.Id);
                    }
                }
            }
        }
        
        //Key = Campaign Id, Value = List of PFR Ids
        Map<Id,Set<Id>> campaignIdToPfrIdSetMap = new Map<Id,Set<Id>>();
        
        //Get the list of pfr created on that campaign and prepare campaignIdToPfrIdSetMap
        if(campaignIdSet != NULL && campaignIdSet.Size() > 0){
            for(PartnerFundRequest pfr : [SELECT Id, CampaignId 
                                          FROM PartnerFundRequest 
                                          WHERE CampaignId IN: campaignIdSet]){
                if(campaignIdToPfrIdSetMap.containsKey(pfr.CampaignId)){
                    campaignIdToPfrIdSetMap.get(pfr.CampaignId).add(pfr.Id);
                }else{
                    campaignIdToPfrIdSetMap.put(pfr.CampaignId, new Set<Id>{pfr.Id});
                }
            }
        }
    
        //Prepare Map of accId and acc's geo 
        if(accIdSet.size() > 0){
            for(Account acc : [SELECT Id, Core_Geo__c, Core_Sub_Geo__c FROM Account WHERE Id IN : accIdSet]){
                accIdGeoMap.put(acc.Id, acc.Core_Geo__c);
                System.debug('accIdGeoMap@@@'+accIdGeoMap);
                if(acc.Core_Sub_Geo__c != NULL){
                //Prepare Map of accId and acc's sub geo 
                accIdSubGeoMap.put(acc.Id, acc.Core_Sub_Geo__c);
              System.debug('accIdSubGeoMap@@@'+accIdSubGeoMap);
                }
            }
        }

        for(Campaign cmp: newCmpList){          
            //Below if condition is modified by Shridhar
            //To handle recordType check dynamically            
            //if((cmp.RecordTypeId == dcfRecordTypeId || cmp.RecordTypeId == ccfRecordTypeId) ){    
            
            //Added as part of US601433
            if(campaignIdSet.contains(cmp.Id)){
                //Check if there are activities created on the campaign
                if(campaignIdToPfrIdSetMap.containsKey(cmp.Id) && campaignIdToPfrIdSetMap.get(cmp.Id) != NULL){
                    cmp.addError(Label.Core_MDF_Cannot_Remove_Technology);                   
                }
            }
            if(coMarketingCampaignRecordTypeID.contains(cmp.RecordTypeId)){                        
                
                //Setting Channel Program lookup value in Campaign
                /*if(cmp.RecordTypeId == dcfRecordTypeId)
                {
                    cmp.Core_MDF_Channel_Program__c = programtype.get(cmp.Core_MDF_Program__c);
                }
                if(cmp.RecordTypeId == ccfRecordTypeId)
                {
                    cmp.Core_MDF_Channel_Program__c = programtype.get(cmp.Core_MDF_Program__c);
                }*/
                if(programtype.containsKey(cmp.Core_MDF_Program__c) && programtype.get(cmp.Core_MDF_Program__c) != NULL ){
                    cmp.Core_MDF_Channel_Program__c = programtype.get(cmp.Core_MDF_Program__c);
                }
                                
                 //Setting Status as In Progress if starts date is today
                if((isInsert || (isUpdate && cmp.StartDate != campOldMap.get(cmp.Id).StartDate)) && cmp.StartDate <= system.today() ){
                    cmp.Status = 'In Progress'; 
                }
                else if((isInsert || (isUpdate && cmp.StartDate != campOldMap.get(cmp.Id).StartDate))){
                    cmp.Status = 'Planned'; 
                }
                
                //Setting Status as Cancelled when 'Cancel campaign' button is clicked and if previous campaign status is not Completed
                if(isUpdate && cmp.Core_MDF_Campaign_Status__c == 'Cancelled')
                {
                    if(campOldMap.get(cmp.Id).Status != 'Completed'){
                        cmp.Status = 'Cancelled';
                    }  
                    else{
                        cmp.addError(Label.Core_MDF_Cancel_Campaign_Error_Message);
                    }
                }
                 System.debug('geoRecordTypeIdList1@@@'+geoRecordTypeIdList);
                //Check if Record Type is Retail and Update the Geo on campaign from Account
                if(geoRecordTypeIdList.contains(cmp.RecordTypeId) && (isInsert || (isUpdate && campOldMap.get(cmp.Id).Core_MDF_Account__c != cmp.Core_MDF_Account__c))){
                    if(accIdGeoMap.get(cmp.Core_MDF_Account__c) != NULL){
                    cmp.Core_MDF_Region_cd__c = accIdGeoMap.get(cmp.Core_MDF_Account__c);
                    }
                    //if(cmp.Core_MDF_Region_cd__c == Label.Core_MDF_ASMO_Region){
                      if(accIdSubGeoMap.get(cmp.Core_MDF_Account__c) != NULL){  
                        cmp.Core_MDF_Sub_Region_cd__c = accIdSubGeoMap.get(cmp.Core_MDF_Account__c);
                    }
                    /*else{
                        cmp.Core_MDF_Sub_Region_cd__c = null;
                    }*/
                }
                
                  System.debug('cmp.Core_MDF_Region_cd__c@@@'+cmp.Core_MDF_Region_cd__c);                  

               /*  //Check if Record Type is Retail and Region is ASMO, update Sub Geo on campaign from Account
                if(geoRecordTypeIdList.contains(cmp.RecordTypeId) && (cmp.Core_MDF_Region_cd__c == Label.Core_MDF_ASMO_Region) && (isInsert || (isUpdate && campOldMap.get(cmp.Id).Core_MDF_Account__c != cmp.Core_MDF_Account__c))){
                    cmp.Core_MDF_Sub_Region_cd__c = accIdSubGeoMap.get(cmp.Core_MDF_Account__c);
                 }else{
                     cmp.Core_MDF_Sub_Region_cd__c = null;
                  }
                 System.debug('cmp.Core_MDF_Sub_Region_cd__c@@@'+cmp.Core_MDF_Sub_Region_cd__c);*/
                             
               
                

                //Check if the record is of CCF/DCF/CCFB/SPCF
                 if(countryRecordTypeIdList.contains(cmp.RecordTypeId) && (isInsert || (isUpdate && campOldMap.get(cmp.Id).Core_MDF_Market__c != cmp.Core_MDF_Market__c))){
                    for(String countryStr : cmp.Core_MDF_Market__c.split(';')){
                        if(!finalGeoSet.contains(wrapperMap.get(countryStr).geo)){
                            finalGeoSet.add(wrapperMap.get(countryStr).geo);
                            String finalGeoString = String.join(new List<String>(finalGeoSet), ';');
                            cmp.Core_MDF_Region_cd__c = finalGeoString;
                             //System.debug('cmp.Core_MDF_Region_cd__c---' + cmp.Core_MDF_Region_cd__c);
                        }
                    }
                }
                
                System.debug('cmp.Core_MDF_Region_cd__c---' + cmp.Core_MDF_Region_cd__c);
                
                
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
        }   
    }
    
     /***************************************************************************************************** 
    Method Name   :        createCampaignShare
    @return       :        CampaignShare record
    @parameters   :        CampaignId and GroupId
    Description   :        Creates a campaign share record for incoming parameters
    Added By      :        Accenture - VK - 10/07/2019
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
    public static CampaignShare createCampaignShare(Id campaignId, Id groupId){
        
        try{
            CampaignShare shareRecord = new CampaignShare();
            shareRecord.CampaignId = campaignId;
            shareRecord.RowCause = 'Manual';
            shareRecord.CampaignAccessLevel = Label.Core_MDF_Read_Access;
            shareRecord.UserOrGroupId = groupId;
            return shareRecord;
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);return null;}
    }
    
    /*****************************************************************************************************************************************
    Method Name:                                             shareUnshareCampaign
    @return  :                                               
    @parameters:                                             List of campaigns, campaigns oldMap                                 
    Description:                                             US106392 - Change External Campaign 
    ibility Date. Campaign record will be shared with
                                 external users based on External Visibilty date.
    Added By:                                                Accenture – Raj D  -  8/8/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar K        8/21/2018                  Added  conditions to handle sharing and unsharing of record on change of owner and External 
                                                             Visibility date, Owner is changed and Visibility date <= TODAY then it will be shred again.
    Accenture – Shridhar K        09/04/2018                 Added channel program criteria in determine group process. 
    Accenture - Shridhar K        2/08/2019                   Co-marketing recordType check is modified to handle new recordType dynamically 
    *****************************************************************************************************************************************/
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
                            Core_MDF_RecordGeoShare recGeoShr = new Core_MDF_RecordGeoShare(cmp.Id,geo,cmp.Core_MDF_Sub_Region_cd__c,cpIdNameMap.get(cmp.Core_MDF_Channel_Program__c));
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
    public static void removeApprovalLock(List<id> campaignID)
    {           
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        try
        {                 
          pfrList = [select id from PartnerFundRequest
                        where CampaignId =: campaignID
                        and Core_MDF_Fund_Request_Status__c = 'Pending Review'];
            
            //Unlock the Pending Approval PFR records
            List<Approval.UnlockResult> ulrList = Approval.unlock(pfrList, false);     
        }
        catch(exception ex){          
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(Core_MDF_CCP_UtilityClass.getErrorDetails(ex),Label.Core_MDF_Activity_Recall_Exception_Origin);           
        } 
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