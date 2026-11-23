/****************************************************************************************************** 
Class Name:         Core_MDF_UpdateActivityFields
@parameters:        N/A
Description:        Before Insert/Upadte call these functions and update the activity to be closed date
Added By:           Sridhar   06-17-2019
Modified By:        Date:           Changes:
Shivaprasad         08-29-2019      Added the condition to check closed status of PFR records in populateBackEndFieldsUpdate method.
*******************************************************************************************************/
public without sharing class Core_MDF_UpdateActivityFields {
    
    public static Map<Id, PartnerFundRequest> oldStaticPFRMap = new Map<Id, PartnerFundRequest>();
    
    /****************************************************************************************************** 
    Method Name:        populateBackEndFieldsUpdate
    @return  :          void
    @parameters:        PFR Map
    Description:        This method is used to update the to be closed date before update trigger
    Added By:           Sridhar - 06/17/2019
    Modified By:        Date:         Changes: 
    Shivaprasad         08-29-2019    Added the condition to check closed status of PFR records.
    *******************************************************************************************************/
    
    public static void populateBackEndFieldsUpdate(Map<Id,PartnerFundRequest> newMap, Map<Id,PartnerFundRequest> oldMap)
    {
        try
        {
            if(oldMap != NULL && oldMap.size() > 0){
                oldStaticPFRMap = oldMap;
            }
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            List<PartnerFundRequest> budgetCurrencyExchangeRatePFRList = new List<PartnerFundRequest>();
            for(PartnerFundRequest pfr: newMap.values()){
                    pfrList.add(pfr);   
                
                /*//Check if there is change in data - Budget Amount local, exchange rate, Currency
                if(pfr.Core_MDF_Budget_Currency_cd__c != oldMap.get(pfr.Id).Core_MDF_Budget_Currency_cd__c ||
                   pfr.Core_MDF_Budget_Amount_Local_amt__c != oldMap.get(pfr.Id).Core_MDF_Budget_Amount_Local_amt__c ||
                   pfr.Core_MDF_Exchange_Rate_ptc__c != oldMap.get(pfr.Id).Core_MDF_Exchange_Rate_ptc__c){
                    budgetCurrencyExchangeRatePFRList.add(pfr);
                }*/
            }
            if (pfrList != NULL && pfrList.size() > 0)
            {
                retailApprovalError(pfrList,oldMap);
                processPFRRecords(pfrList,oldMap);
            }

            /*if(budgetCurrencyExchangeRatePFRList != NULL && budgetCurrencyExchangeRatePFRList.size() > 0){
                calculateBackEndFields(budgetCurrencyExchangeRatePFRList,newMap);
            }*/
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    /****************************************************************************************************** 
    Method Name:        calculateBackEndFields
    @return  :          void
    @parameters:        PFR Map
    Description:        This method calculate the Budget Amount in USD
    Added By:           NZ - 02/25/2020
    Modified By:        Date:      Changes: 
    ******************************************************************************************************
    public static void calculateBackEndFields(List<PartnerFundRequest> newPFRList, Map<Id,PartnerFundRequest> newMap){
        //Call method to calculate USD Budget Amount
        Set<Core_MDF_PartnerFundRequestCreatePage.ExchangeRateConvertedAmountWrapper> excRateConvAmntWrpInstSet = new Set<Core_MDF_PartnerFundRequestCreatePage.ExchangeRateConvertedAmountWrapper>();
        
        //Check if User had Access to Edit Activity from Backend
        excRateConvAmntWrpInstSet = Core_MDF_PartnerFundRequestCreatePage.getExchangeRateConvertedAmountWrapperList(newPFRList);
        
        for(Core_MDF_PartnerFundRequestCreatePage.ExchangeRateConvertedAmountWrapper exchRateAmountInst : excRateConvAmntWrpInstSet)
        {
            newMap.get(exchRateAmountInst.pfrId).RequestedAmount = exchRateAmountInst.usdBudgetAmount;newMap.get(exchRateAmountInst.pfrId).Core_MDF_Exchange_Rate_ptc__c = exchRateAmountInst.exchangeRate;
        }
    }*/
    /****************************************************************************************************** 
    Method Name:        populateBackEndFieldsInsert
    @return  :          void
    @parameters:        PFR Map
    Description:        This method is used to update the to be closed date in before insert
    Added By:           Sridhar - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static void populateBackEndFieldsInsert(List<PartnerFundRequest> newList)
    {
        try
        {
            if (newList != NULL && newList.size() > 0)
            {
                
                //close activity & activity event rules method call
                processPFRRecords(newList,NULL);
                
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
     /****************************************************************************************************** 
    Method Name:        retailApprovalError
    @return  :          void
    @parameters:        PFR List and OldPfrMap
    Description:        This method is used to throw an errror on approval request record for the activities which has passed the start date
    Added By:           Hamza - 01/24/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static void retailApprovalError(List<PartnerFundRequest> newPFRList, Map<Id,PartnerFundRequest> oldPfrMap)
    {
        //Map of PartnerFundRequest Id
        Map<Id, PartnerFundRequest> pfrMap = new Map<Id, PartnerFundRequest>();
        //Map of Record Type id and Record Type Developer Name
        Map<Id, String> recordTypeIdDevName = new Map<Id, String>();
        
        for(RecordType recordType : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'PartnerFundRequest' ] )
        {
            recordTypeIdDevName.put(recordType.Id ,recordType.DeveloperName);
        }
        for(PartnerFundRequest pfr: newPFRList)
        {
            if(oldPfrMap != NULL && oldPfrMap.size() > 0 && recordTypeIdDevName.get(pfr.RecordTypeId) == Label.Core_MDF_PFR_Retail)
            {
                Date startDate = pfr.Core_MDF_Start_Date__c;Date todayDate = System.today();
                Integer daysDifference = todayDate.daysBetween(startDate);
                if(daysDifference < 0 && pfr.Core_MDF_Fund_Request_Status__c != Label.Core_MDF_Activity_Cancelled_Status && pfr.Core_MDF_Fund_Request_Status__c != Label.Core_MDF_PFR_Status_PendingReview && oldPfrMap.get(pfr.Id).Core_MDF_Approval_Step_Completed__c <= 0 && ((oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Status_PendingReview )|| pfr.Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Status_RevisionRequired))
                {
                    pfrMap.put(pfr.Id, pfr);  
                }

            }   
        }
        
        if (!pfrMap.isEmpty() || (oldPfrMap != NULL && oldPfrMap.size() > 0 ))  
        {
            List<Id> processInstanceIds = new List<Id>();
            //query on the process instance where the TargetObjectId is the Id which we fetched above and stored in pfrMap
            for (ProcessInstance pi : [SELECT TargetObjectId
                                       FROM ProcessInstance
                                       WHERE TargetObjectId IN :pfrMap.keySet()
                                       AND Status = 'Pending']) 
            {   processInstanceIds.add(pi.Id);
                pfrMap.get(pi.TargetObjectId).addError(Label.Core_MDF_Retail_Approval_Error);
                
            }  
        }
        
    }
    
    /****************************************************************************************************** 
    Method Name:        processPFRRecords
    @return  :          void
    @parameters:        list of PFR
    Description:        proess all the records and update the to be closed date and event activity validation
    Added By:           Sridhar - 06/17/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    
    public static void processPFRRecords(List<PartnerFundRequest> pfrList, Map<Id,PartnerFundRequest> oldPfrMap)
    {
        try{
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
            
            //hasCustomPermission is Boolean type contains whether the Internal Account Manager custom permission is present or not
            Boolean hasCustomPermission = FeatureManagement.checkPermission(Label.Core_MDF_Custom_Permission_IAM);
            //Retail 14 day validation
            Boolean hasRetailCustomPermission = FeatureManagement.checkPermission(Label.Core_MDF_Custom_Permission_IAM_Retail);
            
            //loop meta data and form Map --> Record type id, list of metadata //Record type restrict
            
            Map<String,List<Core_MDF_PFR_Event_Rule__mdt>> pfrRecordTypeEventMetadataMap = new Map<String,List<Core_MDF_PFR_Event_Rule__mdt>>();
            pfrRecordTypeEventMetadataMap = Core_MDF_PartnerFundRequest_Utility.getPfrEventRulesMetadata();
            // Attributes Map metadata
            Map<String,List<CCP_Attributes_Map__mdt>> pfrRecordTypeAttributeMetadataMap = new Map<String,List<CCP_Attributes_Map__mdt>>();
            pfrRecordTypeAttributeMetadataMap = Core_MDF_PartnerFundRequest_Utility.getCCPAttributeMapMetadata();
            
            // Auto closure Maps for Retail to get from submission winodw meta data
            Map<String,Date> quarterEndRsltMap = new Map<String,Date>();

            // Country Geo Map
            Map<String , String> countryGeoMap = new Map <String , String>();
            Map<String , String> countrySubGeoMap = new Map <String , String>();

            for (Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMetaData : [SELECT Id, MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c FROM Core_MDF_CCP_Country_Geo_Mapping__mdt]){
                countryGeoMap.put(countryGeoMetaData.MasterLabel , countryGeoMetaData.Core_MDF_Geo__c );
                countrySubGeoMap.put(countryGeoMetaData.MasterLabel, countryGeoMetaData.Core_MDF_Sub_Geo__c);
            }
            if(pfrList != NULL && pfrList.size() > 0 ){
             
                // Get activity closure date for retail
               quarterEndRsltMap = getActivityClosureDate(pfrList,ccpRecordTypeIds);
          
                for(PartnerFundRequest pfr: pfrList){                    
                    Boolean errorthrown = false;
                    // List<String> countryList = pfr.Core_MDF_Country_nm__c.split(';');
                    Date startDate = pfr.Core_MDF_Start_Date__c;
                    Date todayDate = System.today()    ;
                    Integer daysDifference = todayDate.daysBetween(startDate);
                    String dayDifference = String.valueOf(daysDifference);
                    String amount = String.valueOf(pfr.RequestedAmount); //looping over the queried metadata list
                   
                    // Set the to be closed date based on the values configured in meta data
                    //closed date validations
                    String progName = ccpRecordTypeIds.get(pfr.recordTypeId);
                    String key = '';

                    if (oldPfrMap != null && oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == 'Cancelled'
                        && pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled')
                    {
                        pfr.Core_MDF_Fund_Request_Status__c = 'Cancelled';
                    }
                            
                    // Start - auto closure logic
                    if ((pfr.Core_MDF_Fund_Request_Status__c != 'Closed' && pfr.Core_MDF_Fund_Request_Status__c != 'Cancelled')
                        && (oldPfrMap == null || (oldPfrMap != null && (oldPfrMap.get(pfr.Id).Core_MDF_End_Date__c != pfr.Core_MDF_End_Date__c 
                                    || oldPfrMap.get(pfr.Id).Core_MDF_Budget_Type_txt__c != pfr.Core_MDF_Budget_Type_txt__c ))))
                    {
                        // RMF auto closure
                        if (progName == Label.Core_MDF_Retail_Program && quarterEndRsltMap != null){

                            key = buildKeyForActivityClosure(pfr,progName);
                            Date toBeClosedDate = quarterEndRsltMap.get(key);
                            //system.debug('##NewtoBeClosedDate->' + toBeClosedDate);
                            pfr.Core_MDF_ToBeClosedDate__c = toBeClosedDate;
                        }
                        // Non RMF auto closure
                        else if (progName != Label.Core_MDF_Retail_Program && metadtMap.containsKey(progName)){

                            Date endDate = null;
                            endDate = pfr.Core_MDF_End_Date__c;
                            Integer actCloseDays  = (Integer)metadtMap.get(progName);
                            pfr.Core_MDF_ToBeClosedDate__c = endDate.addDays(actCloseDays);
                        }
                    }
                    
                    //closed date validations complete

                    // Update OOTB amount field as 0 if its null to avoid salesforce error
                    if (pfr.Amount == NULL){
                        pfr.Amount = 0;
                    }
                    //End - Update OOTB amount field as 0 if its null to avoid salesforce error

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
                                if(customMetadata.Core_MDF_PFR_RecordType__c == ccpRecordTypeIds.get(pfr.RecordTypeId) &&   customMetadata.Core_MDF_Activity_Category__c == pfr.Core_MDF_ActivityCategory__c &&  customMetadata.Core_MDF_Activity_Types__c.contains(pfr.Core_MDF_Activity_Types__c) && !(pfr.Core_MDF_Fund_Request_Status__c.Contains(Label.Core_MDF_PFR_Status))) {
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
                            if((oldPfrMap != NULL && oldPfrMap.get(pfr.Id).Core_MDF_Start_Date__c != pfr.Core_MDF_Start_Date__c && oldPfrMap.size() > 0) || (pfr.Id == NULL) || oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Label.Core_MDF_PFR_Status_RevisionRequired)
                            {
                                if(!(pfr.Core_MDF_Fund_Request_Status__c.Contains(Label.Core_MDF_PFR_Status)) && customMetadata.Core_MDF_PFR_RecordType__c == ccpRecordTypeIds.get(pfr.RecordTypeId) && ccpRecordTypeIds.get(pfr.RecordTypeId) == Label.Core_MDF_PFR_Retail && daysDifference < Integer.valueOf(customMetadata.Core_MDF_Day_Difference__c))
                                {
                                    pfr.addError(Label.Core_MDF_Activity_Retail_14_Days); errorthrown = true; break;
                                }                                       
                            }                           
                        }
                       
                    }
                }
                    //closed date validations
                    if(!errorthrown){
                        Set<String> geoSet = new Set<String>();
                        Set<String> subGeoSet = new Set<String>();
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
                            
                            if(geoSet != NULL && geoSet.size() > 1 ){
                                pfr.addError(Label.Core_MDF_Country_Multiple_Geo_Error);
                                break;
                            }else if(subGeoSet != NULL && subGeoSet.size() > 1
                                && (programGeoReqMap != NULL && programGeoReqMap.size() > 0 && programGeoReqMap.containsKey(ccpRecordTypeIds.get(pfr.RecordTypeId)))){
                                pfr.addError(Label.Core_MDF_Country_Multiple_SubGeo_Error);
                                break;
                            }else{
                                List<String> geoSetList = new List<String>();                                
                                geoSetList.addAll(geoSet);
                                pfr.Core_MDF_Region_cd__c =  geoSetList[0];
                                if(programGeoReqMap != NULL && programGeoReqMap.size() > 0 && ccpRecordTypeIds.containsKey(pfr.RecordTypeId) && programGeoReqMap.containsKey(ccpRecordTypeIds.get(pfr.RecordTypeId))){
                                    List<String> geoProgramList = programGeoReqMap.get(ccpRecordTypeIds.get(pfr.RecordTypeId));
                                    if(geoProgramList != NULL && geoProgramList.contains(geoSetList[0])){
                                        List<String> subGeoSetList = New List<String>();
                                        subGeoSetList.addAll(subGeoSet);
                                        pfr.Core_MDF_Sub_Region_cd__c = subGeoSetList[0];
                                    }
                                }
                            }
                                
                        }
                        
                        //Populating Activity Pillar and Secondary Pillar values from the CCP Attributes Metadata
                        if(pfrRecordTypeAttributeMetadataMap != NULL && pfrRecordTypeAttributeMetadataMap.size() > 0){
                            Core_MDF_PartnerFundRequest_Utility.getActivityPillarAndActivitySecondaryPillar(pfr, ccpRecordTypeIds.get(pfr.RecordTypeId));
                        }
                    }
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }

    /****************************************************************************************************** 
    Method Name:        getActivityClosureDate
    @return  :          Map<String,Date>
    @parameters:        list of PFR and Map <id ,string> to get record type names by ids
    Description:        Build the key and get the closure SLA details from Core_MDF_ProcessClaimSubmissionClosure
    Added By:           Sridhar - 06/30/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/

    private static Map<String,Date> getActivityClosureDate(List<PartnerFundRequest> pfrList,Map<Id,string> ccpRecordTypeIds){

        Map<String,Date> quarterEndDateMap = new Map<String,Date>();
        Map<String,Date> quarterEndRsltMap = new Map<String,Date>();

        // This for loop will return the activity closure dates for Retail based on the quarter end date
        for(PartnerFundRequest pfr: pfrList){
            String progName = ccpRecordTypeIds.get(pfr.recordTypeId);
            String key = '';

            key = buildKeyForActivityClosure(pfr,progName);
            if (!String.isEmpty(key))
            {
                quarterEndDateMap.put(key, null);
            }
        }

        if (quarterEndDateMap != null && !quarterEndDateMap.isEmpty()){
            quarterEndRsltMap = Core_MDF_ProcessClaimSubmissionClosure.getActSubDueDate(quarterEndDateMap);
        }

        return quarterEndRsltMap;
    }

    /****************************************************************************************************** 
    Method Name:        buildKeyForActivityClosure
    @return  :          string
    @parameters:        pfr and program name
    Description:        Build the key based on the PFR values
    Added By:           Sridhar - 06/30/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/

    private static string buildKeyForActivityClosure(PartnerFundRequest pfr, string progName){

        string progLabel = '';
        string key = '';
        if (progName == Label.Core_MDF_Retail_Program) //&& pfr.Core_MDF_Budget_Type_txt__c == Label.Core_MDF_Retail_RSA_MD_Budget_Type
        {
            progLabel = Label.Core_MDF_Retail_Program_Name;
            key = progLabel + ':' +
                    pfr.Core_MDF_Budget_Type_txt__c + ':' +
                    'null' + ':' +
                    'null' + ':' +
                    'null' + ':';
            key += pfr.Core_MDF_End_Date__c.format();
            key = key.deleteWhitespace();
        }
               
        return key;
        
    }
     
}