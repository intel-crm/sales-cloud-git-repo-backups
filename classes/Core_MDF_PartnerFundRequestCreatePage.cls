/***************************************************************************************************** 
Class Name :    Core_MDF_PartnerFundRequestCreatePage
Description:    Server side controller for Core_Intel_createEditPFR
Added By   :    Accenture - AS 
Modified By:                      Date:07/25/2018                     Changes:None  
******************************************************************************************************/
public with sharing class Core_MDF_PartnerFundRequestCreatePage{
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static Boolean exchangeRateFlag = False;
    /***************************************************************************************************** 
    Method Name :   savenSendRecordId
    @return     :   RecordId
    @parameters :   PartnerFundRequest form data
    Description :   US106541 - Create Activity initial screen
    Added By    :   Accenture - AS 
    Modified By :                      Date:07/25/2018                     Changes:None                               
    ******************************************************************************************************/
    
    @AuraEnabled
    public static Id savenSendRecordId(PartnerFundRequest pfr, List<String> contentdocumentids, Boolean budgetException){ 
        PartnerFundRequest partnerFundRequestRecord = new PartnerFundRequest();
        partnerFundRequestRecord = pfr;
        List<String> cdocumentids = contentdocumentids;
        String partnerFundError = '';
        Boolean isError = false;
        Boolean isCPAdded = false;
        Boolean isOCPAdded = false;       
               
        if(budgetException == true)
        {
             partnerFundError=partnerFundError + System.Label.Core_MDF_Currency_Error +'<br>';
             isError = true;
        }
        if(partnerFundRequestRecord.CampaignId == null ){
            partnerFundError=System.Label.Core_MDF_CampaignErrorMessage + '<br/>';
            isError = true;
        }
        if(partnerFundRequestRecord.ChannelPartnerId == null){
            partnerFundError=partnerFundError+System.Label.Core_MDF_ChannelPartnerError +'<br>';            
            isError = true;
        }
       
        if(String.isBlank(partnerFundRequestRecord.Core_MDF_TargetAudience__c) ){
            partnerFundError=partnerFundError + System.Label.Core_MDF_TargetAudienceError +'<br>';
            isError = true;
        }
        if(String.isBlank(partnerFundRequestRecord.Core_MDF_Brand__c)){
            partnerFundError=partnerFundError + System.Label.Core_MDF_BrandError +'<br>';
            isError = true;
        }
        if(String.isBlank(partnerFundRequestRecord.Core_MDF_ActivityCategory__c)){
            partnerFundError=partnerFundError + System.Label.Core_MDF_ActivityCategoryError +'<br>';
            isError = true;
        }
        if(String.isBlank(partnerFundRequestRecord.Core_MDF_Activity_Types__c)){
            partnerFundError=partnerFundError + System.Label.Core_MDF_ActivityTypeError + '<br>';
            isError = true;
        }
        
       //Country validation
       if(String.isBlank(partnerFundRequestRecord.Core_MDF_Country_nm__c)){
            partnerFundError = partnerFundError + System.Label.Core_MDF_MarketError + '<br>';
            isError = true;
        }
        if(String.isBlank(partnerFundRequestRecord.Core_MDF_Priorities__c)){
            partnerFundError=partnerFundError + System.Label.Core_MDF_Priority_Error + '<br>';
            isError = true;
        }
            
        if(partnerFundRequestRecord.Core_MDF_Activity_Types__c == System.Label.Core_MDF_Channel_Partner_Website_Online_Ad
           || partnerFundRequestRecord.Core_MDF_Activity_Types__c == System.Label.Core_MDF_Channel_Partner_Owned_Event
           || partnerFundRequestRecord.Core_MDF_Activity_Types__c == System.Label.Core_MDF_Channel_Partner_Participation_in_Third_Party_Event)
        {
            
            if (partnerFundRequestRecord.Core_MDF_Channel_Partner_Led__c == false )  //&& isCPAdded == false)
            {
                partnerFundError=partnerFundError + System.Label.Core_MDF_CP_ReqError + '<br>';
                isError = true;
                //isCPAdded = true;
            }
            else if (String.isBlank(partnerFundRequestRecord.Core_MDF_Channel_Partner__c))// && isCPAdded == false)
            {
                partnerFundError=partnerFundError + System.Label.Core_MDF_CP_ReqError + '<br>';
                isError = true;
                //isCPAdded = true;
            }
            else if (String.isBlank(partnerFundRequestRecord.Core_MDF_Other_Channel_Partner__c)
                     && partnerFundRequestRecord.Core_MDF_Channel_Partner__c == 'Others') //&& isOCPAdded == false)
            {
                partnerFundError=partnerFundError + System.Label.Core_MDF_Other_CP_Error + '<br>';
                isError = true;
                //isOCPAdded = true;
            }
        }
        else if(partnerFundRequestRecord.Core_MDF_Channel_Partner_Led__c == true
                && String.isBlank(partnerFundRequestRecord.Core_MDF_Channel_Partner__c)){
                    partnerFundError=partnerFundError + System.Label.Core_MDF_CP_ReqError + '<br>';
                    isError = true;
                    //isCPAdded = true;
                }
        else if(partnerFundRequestRecord.Core_MDF_Channel_Partner_Led__c == true
                && String.isBlank(partnerFundRequestRecord.Core_MDF_Other_Channel_Partner__c)
                && partnerFundRequestRecord.Core_MDF_Channel_Partner__c == 'Others'){
                    partnerFundError=partnerFundError + System.Label.Core_MDF_Other_CP_Error + '<br>';
                    isError = true;
                    //isOCPAdded = true;
                }
      
        if(isError){
            AuraHandledException ex = new AuraHandledException(partnerFundError);
            ex.setMessage(partnerFundError);
            throw ex;
        }
        try{ 
            
            //Boolean createdDateFlag = false;
            //if(pfr.CreatedDate == null){
              //  createdDateFlag = true;
            //}
            //ExchangeRateConvertedAmountWrapper exchangeRateAndConvertedAmtWrap  = budgetAmountCalculatePFR(Pfr,partnerFundRequestRecord.Core_MDF_Budget_Currency_cd__c,createdDateFlag);
            //partnerFundRequestRecord.Core_MDF_Exchange_Rate_ptc__c = exchangeRateAndConvertedAmtWrap.exchangeRate;
            //partnerFundRequestRecord.RequestedAmount = exchangeRateAndConvertedAmtWrap.usdBudgetAmount;
            
            if(partnerFundRequestRecord.Id == null){
                Core_MDF_PFR_Utility.insertPFR(partnerFundRequestRecord);
            }
            else{
                
                //Remove Approval Record lock before Update
                  if(Approval.isLocked(partnerFundRequestRecord.Id))
                    {
                      List<PartnerFundRequest> pfrlst = new List<PartnerFundRequest>();
                          pfrlst.add(partnerFundRequestRecord);
                          boolean apprlck = Core_MDF_ProcessCCP_PartnerFundRequest.RemoveApprovalLock(pfrlst);
                    }                                                 
                                   
                  Core_MDF_PFR_Utility.updatePFR(partnerFundRequestRecord);
                
            }
            if(cdocumentids != null ){
                List<ContentDocumentLink> conDocuLink = new List<ContentDocumentLink>();
                
                List<FeedItem> chatterfiles = new List<FeedItem>();
                for(ContentDocument docuLink : [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE Id IN: cdocumentids]){
                    ContentDocumentLink odocLink = new ContentDocumentLink(ContentDocumentId = docuLink.Id,LinkedEntityId=partnerFundRequestRecord.Id,ShareType='I',Visibility='AllUsers');
                    // docuLink.LinkedEntityId = partnerFundRequestRecord.Id;
                    FeedItem chatterDetail = new FeedItem();
                    chatterDetail.ParentId = partnerFundRequestRecord.Id;
                    chatterDetail.RelatedRecordId = docuLink.LatestPublishedVersionId;
                    chatterDetail.Type = 'ContentPost';
                    chatterDetail.Visibility = 'AllUsers';
                    
                    chatterfiles.add(chatterDetail);
                    conDocuLink.add(odocLink);
                }
                insert(conDocuLink);
                 insert(chatterfiles);
                
            }
           
        }catch(AuraHandledException e){
            Core_MDF_CCP_UtilityClass.logError(e);throw e;
        }
        return partnerFundRequestRecord.Id;
    }
    
    /***************************************************************************************************** 
    Method Name : loadPFRRecord
    @return     : Object
    @parameters : PFR Record
    Description : US106541 - Create Activity initial screen
    Added By    : Accenture - AS
    Modified By :                      Date:07/25/2018                    Changes:None                                
    ******************************************************************************************************/
    @AuraEnabled
    public static PartnerFundRequest loadPFRRecord(String pfrId){
        Set<String> sQueryfields = new Set<String>();
        String sanitiziedpfrId = String.escapeSingleQuotes(pfrId);
        String sQuery='SELECT ';
        for(Schema.FieldSetMember f : SObjectType.PartnerFundRequest.FieldSets.Core_MDF_Activity_FieldList.getFields()) {
            sQueryfields.add(f.getFieldPath());         
        }      
        for(String fs : sQueryfields){
            sQuery += fs + ',';
        }
        
        //Added curency and budget amount field 
        sQuery += 'Campaign.Name,Campaign.Core_MDF_Priority__c,Campaign.Core_MDF_Priority_2_nm__c,Campaign.Core_MDF_Priority_3_nm__c,Core_MDF_Region_cd__c,'+
            'Campaign.Core_MDF_Reimbursement_Rate__c,ChannelPartner.Name,RecordType.Name,RecordType.DeveloperName,Id,Core_MDF_Budget_Currency_cd__c,Core_MDF_Exchange_Rate_ptc__c, Core_MDF_POP_Requirements_txt__c,'+
            'Core_MDF_Joint_Content_ind__c, Core_MDF_Budget_Amount_Local_amt__c,Core_MDF_Budget_Type_txt__c,Core_MDF_Priorities__c,CreatedDate,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,ChannelPartner.Core_MDF_Channel_Program__c,'+
            'BudgetId,Core_MDF_Channel_Partner__c,Core_MDF_Channel_Partner_Led__c,Core_MDF_Other_Channel_Partner__c,Core_MDF_Country_nm__c,'+
            'Campaign.StartDate, Campaign.EndDate, Campaign.Core_MDF_Account__c, Campaign.Core_MDF_Account__r.Name,Campaign.Core_MDF_Campaign_Status__c,'+
            'Campaign.Core_MDF_Channel_Program__c,Campaign.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Campaign.Core_MDF_Technology__c FROM PartnerFundRequest WHERE Id =:sanitiziedpfrId'; 
        
        PartnerFundRequest pfrRecord = Database.query(sQuery);
        
        system.debug('sQuery-' + sQuery);
        return pfrRecord;
    }
    /***************************************************************************************************** 
    Method Name : fetchMetadataMapping
    @return     : Custom Metadata
    @parameters : NA
    Description : Created for fetching Metadata Mapping and sending it to client-side controller
    Added By    : Accenture - AS
    Modified By :                      Date:07/25/2018                    Changes:None                                
    ******************************************************************************************************/
    @AuraEnabled
    public static List<CCP_Attributes_Map__mdt> fetchMetadataMapping(){
        return [SELECT Id,DeveloperName,MasterLabel,Budget_Amount__c,Category__c,Core_MDF_Enable_Channel_Partner_Led__c,Core_MDF_Enable_Event_Format_Ind__c, Core_MDF_POP_Requirements_txt__c,
                Core_MDF_Enable_ELC_Reminder__c,Enable_Event_Popup__c,Core_MDF_Enable_File_Upload__c,Core_MDF_Enable_Question__c,RecordType_Name__c,Type__c,Govt_Nexus_Flag__c,
                Print__c,Channel_Partner__c,Record_Type_Picklist__c,Core_MDF_Activity_Description_Txt__c,Activity_Sub_Type__c FROM CCP_Attributes_Map__mdt];
    }
    
    /***************************************************************************************************** 
    Method Name : calculateIncentiveForActivity
    @return     : Custom Metadata
    @parameters : NA
    Description : Created for fetching Incentive Questions
    Added By    : Vivek K
    Modified By :                      Date:03/20/2020                    Changes:None                                
    ******************************************************************************************************/
    @AuraEnabled
    public static Core_MDF_ChannelProgram__mdt fetchVRMetadataMapping(string channelProgram){
        return [SELECT Id,Core_MDF_Technical_Program_Name__c,Core_MDF_InctQuest_Label_Ref__c FROM Core_MDF_ChannelProgram__mdt where Core_MDF_Technical_Program_Name__c =:channelProgram];
    }
    
    /***************************************************************************************************** 
    Method Name : calculateIncentiveForActivity
    @return     : Custom Metadata
    @parameters : NA
    Description : Created for fetching Incentives and sending it to client-side controller
    Added By    : Accenture - SS
    Modified By :                      Date:03/10/2020                    Changes:None                                
    ******************************************************************************************************/
    @AuraEnabled
    public static List<PartnerFundRequest> calculateIncentiveForActivity(PartnerFundRequest pfr,Id channelProgramId){
        Map<PartnerFundRequest, Id> pfrCPIdMap = new Map<PartnerFundRequest, Id>();
        pfrCPIdMap.put(pfr, channelProgramId);
        return Core_MDF_PFR_Reimbursement_Handler.calculateVariableReimbursement(pfrCPIdMap);
        //return Core_MDF_PFR_TriggerServiceHandler.calculateVariableReimbursement(pfrList);
    }
    /***************************************************************************************************** 
    Method Name : ischannelpartner
    @return     : Custom Metadata
    @parameters : activity category and type
    Description : Created for fetching Metadata Mapping and sending it to client-side controller
    Added By    : Sridhar
    Modified By :                      Date:08/18/2018                    Changes:None                                
    ******************************************************************************************************/
    @AuraEnabled
    public static Boolean ischannelpartner(String activityCategory, String activityType, String recordType){
        
        List<CCP_Attributes_Map__mdt> metaData = fetchMetadataMapping();
        Boolean isCP = false;
        
        for(CCP_Attributes_Map__mdt metData : metaData){
            if(activityCategory.equalsIgnoreCase(metData.Category__c.trim()) 
               && activityType.equalsIgnoreCase(metData.Type__c.trim()) && metData.Channel_Partner__c == true
               && recordType.equalsIgnoreCase(metData.Record_Type_Picklist__c)){
                   isCP = true;
                   break;
               }
        }
        return isCP;
    }
    /***************************************************************************************************** 
    Method Name : mainPicklistFetcher
    @return     : Map<String,Object>
    @parameters : String recordTypeName
    Description : Calls the class Core_Intel_customPicklistController for the picklist values
    Added By    : Accenture - VK
    Modified By :                      Date:07/25/2018                    Changes:None                                
    ******************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> mainPicklistFetcher(String recordTypeName){ 
        String rec = recordTypeName;
        return Core_Intel_customPicklistController.picklistFetcher(rec);
    }
    /***************************************************************************************************** 
    Method Name : ExternalOrInternal
    @return     : boolean
    @parameters : None
    Description : US149042 - Cancel Activity - status
    Added By    : Accenture - ashar
    Modified By :                      Date:08/31/2018                    Changes:None                                
    ******************************************************************************************************/
    /*@AuraEnabled
    public static boolean ExternalOrInternal(){
    Id profileId = UserInfo.getProfileId();
    List<Profile> profileName = [Select Name from Profile where Id =: profileId];
    if(profileName[0].Name == System.Label.Core_MDF_ExternalUserProfileName)
    return true;
    return false;   
    }*/
    
    /******************************************************************
     * *********************************** 
    Method Name : UserHasPermissionSet
    @return     : boolean
    @parameters : perset
    Description : Validate whether the user has the permission associated or not
    Added By    : Sridhar
    Modified By :                      Date:09/01/2018                    Changes:None                                
    ******************************************************************************************************/
    @AuraEnabled
    public static UserPermissionSetWrapper userHasPermissionSet(Map<String,List<String>> permissionsets){
        String userId = UserInfo.getUserId();
        UserPermissionSetWrapper usrprmissionWrapper = new UserPermissionSetWrapper();
        Map<String,boolean> userPermissions = new Map<String,boolean>();
        List<PermissionSetAssignment> userPerSets = new List<PermissionSetAssignment>();
        
        userPerSets = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId];
    
        for(String perKey : permissionsets.keySet())
        {
            for(String perSet : permissionsets.get(perKey))
            {
                for(PermissionSetAssignment dbPer : userPerSets)
                {
                    if (dbPer.PermissionSet.Name.contains(perSet) && !userPermissions.containsKey(perKey))
                    {
                        userPermissions.put(perKey,true);
                    }
                }
            }
            if (!userPermissions.containsKey(perKey))
            {
                userPermissions.put(perKey,false);
            }

        }
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_isActivityReviewRequired') &&
           mapFunctionalityNameTriggerExecution.get('Core_MDF_isActivityReviewRequired').Core_Active__c){
            usrprmissionWrapper.isActivityReviewRequired = true;
        }
        usrprmissionWrapper.userPermissions = userPermissions;
        return usrprmissionWrapper;   
    }
    
    /***************************************************************************************************** 
    Method Name :   userPermissionSetWrapper (Created a Wrapper to reduce the server side call)
    Added By   :    Accenture - SS 
    Modified By:                      Date:10/25/2018                     Changes:None  
    ******************************************************************************************************/
    public class UserPermissionSetWrapper{
        @AuraEnabled   
        public Map<String,boolean> userPermissions;
        @AuraEnabled
        public Boolean isActivityReviewRequired;
    }

    /***************************************************************************************************** 
    Method Name :   getLabelApiMapforPicklistfields
    Added By   :    Accenture - AS 
    Description :   Get the all the values of all the picklist field on the load of the page.
    Modified By:                      Date:10/15/2018                     Changes:None  
    ******************************************************************************************************/
    
    @AuraEnabled
    public static Map<String, String> getLabelApiMapforPicklistfields (String objName, List <String> pfrPiclistField){
        String objectname = objName;
        List <String> picklistfields = pfrPiclistField;
        System.debug('api to label map line 382-->'+ Core_Intel_customPicklistController.apitoLabelReference(objectname , pfrPiclistField));
        return Core_Intel_customPicklistController.apitoLabelReference(objectname , pfrPiclistField);
    }
    /***************************************************************************************************** 
    Method Name :   recalculatebudgetAmountOnPFR
    Added By   :    Accenture - SS
    Description :   Recalculates the budget amount on PFR Record
    Modified By:                      Date:10/15/2018                     Changes:None  
    ******************************************************************************************************/
    @AuraEnabled
    public static PartnerFundRequest recalculatebudgetAmountOnPFR (PartnerFundRequest newPFR, PartnerFundRequest oldPFR){
		PartnerFundRequest returnPFR = new PartnerFundRequest();
        Date todayDate = date.newInstance(System.today().year(), System.today().month(), System.today().day());
        Date pfrcreatedDate = date.newInstance(newPFR.createdDate.year(), newPFR.createdDate.month(), newPFR.createdDate.day());
        Integer numberDaysDue = pfrcreatedDate.daysBetween(todayDate);
        Integer activityDateChangeRange = Integer.valueOf(System.Label.Core_MDF_Activity_Budget_Date_Change_Range) == NULL  ? 180 : Integer.valueOf(System.Label.Core_MDF_Activity_Budget_Date_Change_Range) ;
        //Integer numberMonthsSDue = pfrcreatedDate.monthsBetween(todayDate);
        // if : -Less than 6 months
        if(numberDaysDue <= activityDateChangeRange){ // Need to put in custom label
            // If Currency is changes and Currency is Not USD
            if(newPFR.Core_MDF_Budget_Currency_cd__c != NULL && oldPFR.Core_MDF_Budget_Currency_cd__c != NULL 
            && newPFR.Core_MDF_Budget_Currency_cd__c != oldPFR.Core_MDF_Budget_Currency_cd__c && newPFR.Core_MDF_Budget_Currency_cd__c != 'USD' ){
                // Calculate Budget Currency
                PartnerFundRequest newPFRExchange = calculateExchangeRateAndAmount(newPFR);
                returnPFR.RequestedAmount = newPFRExchange.RequestedAmount;
                returnPFR.Core_MDF_Exchange_Rate_ptc__c = newPFRExchange.Core_MDF_Exchange_Rate_ptc__c;
            }else{ // Else of Currency Change and if USD
                if(newPFR.Core_MDF_Budget_Currency_cd__c != 'USD'){ // If Amount got changed and is not USD
                    if(oldPFR.Core_MDF_Exchange_Rate_ptc__c != NULL){ // If Exchange Rate for new currency is avaliable
                        returnPFR.RequestedAmount = (newPFR.Core_MDF_Budget_Amount_Local_amt__c * oldPFR.Core_MDF_Exchange_Rate_ptc__c).setScale(2,RoundingMode.HALF_UP);
                        returnPFR.Core_MDF_Exchange_Rate_ptc__c = oldPFR.Core_MDF_Exchange_Rate_ptc__c;
                    }else{ // If exchange rate of the currency is not avaliable
                        PartnerFundRequest newPFRExchange = calculateExchangeRateAndAmount(newPFR);
                        returnPFR.RequestedAmount = newPFRExchange.RequestedAmount;
                        returnPFR.Core_MDF_Exchange_Rate_ptc__c = newPFRExchange.Core_MDF_Exchange_Rate_ptc__c;
                    }
                }else{ // If Amount got changed and is USD
                    returnPFR.RequestedAmount = newPFR.Core_MDF_Budget_Amount_Local_amt__c;
                    returnPFR.Core_MDF_Exchange_Rate_ptc__c = 1;
                }
            }
        }else{// Else of if days difference is 6 Months
            returnPFR.RequestedAmount = null;
            returnPFR.Core_MDF_Exchange_Rate_ptc__c = null;
        }
        returnPFR.Core_MDF_Budget_Currency_cd__c = newPFR.Core_MDF_Budget_Currency_cd__c;
		return returnPFR;
    }
    /****************************************************************************************************** 
    Method Name:        calculateExchangeRateAndAmount
    @return  :          PartnerFundRequest
    @parameters:        PartnerFundRequest 
    Description:        To Calculate the Exchange Rate and Converted Amount if its null
    Added By:           Accenture - SS  - 04/28/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static PartnerFundRequest calculateExchangeRateAndAmount (PartnerFundRequest pfr){
        PartnerFundRequest returnPFR = new PartnerFundRequest();
        ExchangeRateConvertedAmountWrapper exchangeRateAndConvertedAmtWrap  = budgetAmountCalculatePFR(pfr,false);
        if(exchangeRateAndConvertedAmtWrap != NULL && exchangeRateAndConvertedAmtWrap.exchangeRate != NULL && exchangeRateAndConvertedAmtWrap.usdBudgetAmount != NULL){
            returnPFR.RequestedAmount = exchangeRateAndConvertedAmtWrap.usdBudgetAmount;
            returnPFR.Core_MDF_Exchange_Rate_ptc__c = exchangeRateAndConvertedAmtWrap.exchangeRate;
            returnPFR.Core_MDF_Budget_Currency_cd__c = pfr.Core_MDF_Budget_Currency_cd__c;
        }else{
            returnPFR.RequestedAmount = null;
            returnPFR.Core_MDF_Exchange_Rate_ptc__c = null;
            returnPFR.Core_MDF_Budget_Currency_cd__c = null;
        }
		System.debug('calculateExchangeRateAndAmount -> returnPFR: Amount: ' + returnPFR.RequestedAmount + '<-->Exchange Rate: ' + returnPFR.Core_MDF_Exchange_Rate_ptc__c);
        return returnPFR;
    }
    /****************************************************************************************************** 
    Method Name:        ExchangeRateConvertedAmountWrapper
    @return  :          None
    @parameters:        None 
    Description:        This warpper is used to store Budget Amount from Local Currency to USD
    Added By:           Accenture - SS  - 12/27/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public class ExchangeRateConvertedAmountWrapper{
        @AuraEnabled   
        public Decimal usdBudgetAmount = 0 ;
        @AuraEnabled   
        public Decimal exchangeRate = 0 ;
        @AuraEnabled   
        public Id pfrId;
    }
    /****************************************************************************************************** 
    Method Name:        budgetAmountCalculatePFR 
    @return  :          ExchangeRateConvertedAmountWrapper
    @parameters:        PFR 
    Description:        This method is used to calulate Budget Amount from Local Currency to USD[Bulkified]
    Added By:           NZ 
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled  
    public static ExchangeRateConvertedAmountWrapper budgetAmountCalculatePFR(PartnerFundRequest pfr, Boolean createdDateCloneFlag){
        //Set of Wrapper to store the Requested Amount, ExchangeRate and PFRId
        Set<ExchangeRateConvertedAmountWrapper> convertedAmountAndExchangeRateSet = new Set<ExchangeRateConvertedAmountWrapper>();
        
        //PFR list to PFR which has change in Currency
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        
        //Instance of Wrapper Class
        ExchangeRateConvertedAmountWrapper exchngeRateWrapperInstn = new ExchangeRateConvertedAmountWrapper();
        
        if(pfr.Core_MDF_Budget_Currency_cd__c != NULL && pfr.Core_MDF_Budget_Amount_Local_amt__c >0){
            pfrList.add(pfr);
        }
        //If Change in currency, PFR list will have data
        if(pfrList.size()>0){
            Boolean budgetflag = TRUE;
            //Call method to Fetch , USD Amount of Local currency, and Exchange Rate
            convertedAmountAndExchangeRateSet = getExchangeRateConvertedAmountWrapperList(pfrList,budgetflag,createdDateCloneFlag);
            //Check if there is convertedAmountAndExchangeRateSet has data
            if(convertedAmountAndExchangeRateSet != NULL && convertedAmountAndExchangeRateSet.size() > 0){
                exchngeRateWrapperInstn = (new list<ExchangeRateConvertedAmountWrapper>(convertedAmountAndExchangeRateSet))[0];
            }
            else{
                exchngeRateWrapperInstn = NULL;
            }
        }
		return exchngeRateWrapperInstn;
    }
    /****************************************************************************************************** 
    Method Name:        getExchangeRateConvertedAmountWrapperList
    @return  :          ExchangeRateConvertedAmountWrapper
    @parameters:        PFR list
    Description:        This method is used to calulate Budget Amount from Local Currency to USD[Bulkified]
    Added By:           SB
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/ 

    public static Set<ExchangeRateConvertedAmountWrapper> getExchangeRateConvertedAmountWrapperList(List<PartnerFundRequest> pfrList, Boolean budgetflag, Boolean createdDateCloneFlag){
        
        // Error Messages for Exchange Rates
        String partnerFundErrorBudgetUSD = System.Label.Core_MDF_Budget_Amount_Error +'<br/>';
        String partnerFundErrorCurrency = System.Label.Core_MDF_Currency_Error +'<br/>';
        
        //Map : key --> String of (Budget Amount + Currency + Date), Value --> PFRId's
        Map<String,Set<Id>> budgetAmountCurrencyDateStrPFRIdSetMap = new Map<String,Set<Id>>();
        
        
        //Set of ExchangeRateConvertedAmountWrapper
        Set<ExchangeRateConvertedAmountWrapper> convertedAmountAndExchangeRateSet = new Set<ExchangeRateConvertedAmountWrapper>();
        
        //InputList to pass as param to  Core_MDF_CCP_Multicurrency Class
        List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> inputList = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
        String keyValue;
        try{            
            for(PartnerFundRequest pfr : pfrList){
                if(pfr.Core_MDF_Budget_Amount_Local_amt__c != NULL && pfr.Core_MDF_Budget_Currency_cd__c != NULL){
                    //Get the required information of currency, amount and date to fetch Exchnage rate
                  	Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount input = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
                    input.inputCurrency = pfr.Core_MDF_Budget_Currency_cd__c;
                    input.inputAmount = pfr.Core_MDF_Budget_Amount_Local_amt__c;
                    //key -> String of (Budget Amount + Currency + Date)
                    if(createdDateCloneFlag){
                        
                        input.inputDate = System.today() ;
                        keyValue = pfr.Core_MDF_Budget_Amount_Local_amt__c + '\t' + pfr.Core_MDF_Budget_Currency_cd__c + '\t' +  string.valueof(System.today() );
                                   
                    }else{
                        input.inputDate = pfr.createdDate == NULL  ? System.today() : pfr.createdDate.Date() ;
                        keyValue = pfr.Core_MDF_Budget_Amount_Local_amt__c + '\t' + pfr.Core_MDF_Budget_Currency_cd__c + '\t' + string.valueof(pfr.createdDate == NULL  ? System.today() : pfr.createdDate.Date());
                     }
                    inputList.add(input);
                    //loop over and fetch all PFRId's with the  #426 key 
                    if(budgetAmountCurrencyDateStrPFRIdSetMap.containsKey(keyValue)){
                        Set<Id> pfrIdSet = new Set<Id>();pfrIdSet = budgetAmountCurrencyDateStrPFRIdSetMap.get(keyValue);pfrIdSet.add(pfr.Id);budgetAmountCurrencyDateStrPFRIdSetMap.put(keyValue, pfrIdSet);
                        
                    }
                    else{
                        
                        Set<Id> pfrIdSet = new Set<Id>();
                        pfrIdSet.add(pfr.Id);
                        budgetAmountCurrencyDateStrPFRIdSetMap.put(keyValue, pfrIdSet);
                    }
                }else{
                    AuraHandledException ex = new AuraHandledException(partnerFundErrorBudgetUSD); ex.setMessage(partnerFundErrorBudgetUSD);throw ex;
                }
            }
            //Call to Core_MDF_CCP_Multicurrency method
            Map<String,Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> usdAmountMap = Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(inputList);
            system.debug('usdAmountMap-->'+usdAmountMap);
            //Check if usdAmountMap && budgetAmountCurrencyDateStrPFRIdSetMap has data ,
            //if yes then loop over and store inforamtion in ExchangeRateConvertedAmountWrapper Wrapper
            if(budgetflag == true && usdAmountMap != NULL && usdAmountMap.size()>0){
                ExchangeRateConvertedAmountWrapper ercaw = new ExchangeRateConvertedAmountWrapper();
                if(usdAmountMap.containsKey(keyValue) && usdAmountMap.size() > 0 && usdAmountMap.get(keyValue).conversionRate != NULL)
                {
                    ercaw.usdBudgetAmount = usdAmountMap.get(keyValue).convertedAmount.setScale(2,RoundingMode.HALF_UP);
                    ercaw.exchangeRate= usdAmountMap.get(keyValue).conversionRate;
                    convertedAmountAndExchangeRateSet.add(ercaw);
                }
                else{
                    AuraHandledException ex = new AuraHandledException(partnerFundErrorCurrency);
                    ex.setMessage(partnerFundErrorCurrency);
                    throw ex;
                }
            }else if(budgetAmountCurrencyDateStrPFRIdSetMap.size()>0 && usdAmountMap != NULL && usdAmountMap.size()>0){
                for(String key : usdAmountMap.keySet()){
                  if(usdAmountMap.containsKey(key) && usdAmountMap.get(key).conversionRate != NULL ){
                    for(Id activityId : budgetAmountCurrencyDateStrPFRIdSetMap.get(key)){
                            ExchangeRateConvertedAmountWrapper ercaw = new ExchangeRateConvertedAmountWrapper();
                            ercaw.usdBudgetAmount = usdAmountMap.get(key).convertedAmount.setScale(2,RoundingMode.HALF_UP);
                            ercaw.exchangeRate = usdAmountMap.get(Key).conversionRate;ercaw.pfrId = activityId; convertedAmountAndExchangeRateSet.add(ercaw);
                        }
                    }
                    else{
                        AuraHandledException ex = new AuraHandledException(partnerFundErrorCurrency);
                        ex.setMessage(partnerFundErrorCurrency);
                        throw ex;
                    }
               }
            }
        }catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);  throw e;                          
          }
        return convertedAmountAndExchangeRateSet;
    }
    /***************************************************************************************************** 
    Method Name : validateIfInApprvlQue
    @return     : Boolean
    @parameters : PFR Record Id
    Description : Validate if Activity is  in Approval Queue
    Added By    : NZ                       
    ******************************************************************************************************/
    @AuraEnabled
    public static Boolean validateIfInApprvlQue(String pfrId){
        Boolean apprvalQueueFlag = false; 
        try{List<ProcessInstanceWorkItem> piwitm = [SELECT ProcessInstance.TargetObjectId, Id 
                                                    FROM ProcessInstanceWorkItem 
                                                    WHERE ProcessInstance.Status = :'Pending' AND ProcessInstance.TargetObjectId = :pfrId LIMIT 1];
            if(piwitm != NULL && piwitm.size() > 0) {
                apprvalQueueFlag = true;
            }    
        }catch(Exception e) {      Core_MDF_CCP_UtilityClass.logError(e);  throw e;            }
        return apprvalQueueFlag;
    }
    /*****************************************************************************************************
    Method Name : Fund Allocation Creation
    Added By    : HA
    @return     : Allocation Id
    Description : Creation of new Fund Allocation with Zero Budget
    Modified By :               Date : 24-10-2018 
    *******************************************************************************************************/
    /*@AuraEnabled
    public static Id fundAllocationCreation(PartnerFundRequest pfr)
    { 
        try{  
            Datetime sd = pfr.Core_MDF_Start_Date__c;
            Datetime ed = pfr.Core_MDF_End_Date__c;
            String startDate = sd.format(System.Label.Core_MDF_PFR_Date_Format);            
            String endDate = ed.format(System.Label.Core_MDF_PFR_Date_Format);
            List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
            // Fetching Campaign's Account to Find Budget Association
            List <Campaign> campaignList = [SELECT Id, Core_MDF_Account__c
                                            FROM Campaign
                                            WHERE Id =: pfr.CampaignId];
            // Variables created to store Ids of Campaign's Account Id to Query Budget
            Id campAccId = campaignList[0].Core_MDF_Account__c;
            //Variable created to store Ids of PartnerFundRequest's Account Id to Query Allocation
            Id pfrAccId = pfr.ChannelPartnerId;
            
            if(campaignList != NULL && campaignList.size() > 0){
                
                // Helper Class Called to fetch the bugdet data
                budgetList = Core_MDF_PFRCreatePageHelper.fetchPFRCampaignAccountsBudget(startDate ,endDate , campAccId);
                
                //Since Budget will be created for Single year we are taking the first budget in the Query
                if(budgetList.size() > 0){
                    Id budgetIdFromCampaignAccount = budgetList[0].Id;
                    // Getting Fund Allocation if Exist
                    List<PartnerFundAllocation> fundAllocationList = [SELECT Id, BudgetId
                                                                      FROM PartnerFundAllocation
                                                                      WHERE BudgetId =: budgetIdFromCampaignAccount AND 
                                                                      ChannelPartnerId =: pfrAccId
                                                                      ORDER BY LastModifiedDate DESC
                                                                      LIMIT 1];
                    
                    if(fundAllocationList != NULL && fundAllocationList.size() > 0){
                        pfr.allocationId = fundAllocationList[0].Id;    
                        return (pfr.allocationId);
                    } 
                    // If not creating the new one  
                    else{
                        Id pfrRecordTypeId = pfr.RecordTypeId;
                        String newPFATitle = budgetList[0].Title;
                        Id campAccBudgetId = budgetList[0].Id;
                        Id pfrChannelProgramId = pfr.ChannelPartnerId;
                        PartnerFundAllocation pfa;
                        // Calling Helper Method On To Create Zero Fund Allocations
                        pfa =   Core_MDF_PFRCreatePageHelper.createPFAOnPFR(pfrRecordTypeId, campAccBudgetId, pfrChannelProgramId, newPFATitle);                     
                        pfr.allocationId = pfa.Id;                    
                        return (pfr.allocationId);
                    }
                }
            }
            return NULL;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); return NULL;}
        
    }*/
}