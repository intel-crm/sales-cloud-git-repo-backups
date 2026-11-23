/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetTypeCap_Utility 
* Version     : 1.0   
* Created Date: 24/05/2021 
* Modification Log :
* Developer                 Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Pranav            24/05/2021                    Class contains all the methods supporting Linking/ Delinking of Campaigns 
                                                          with the relavant Budget Cap
*****************************************************************************************************************************************/

public without sharing class Core_MDF_BudgetTypeCap_Utility {
    
    // Map of Budget Cap Unique Key and Campaigns to be used on Insertion
    public static Map<String,List<Campaign>> budgetCapUniqueKeyToCampaigns;
    // ma of Cap Id and Campaigns to be used on Update
    public static Map<Id,List<Campaign>> budgetCapIdToCampaigns;    
    // Map containing Delinked and Linked campaigns for final updation
    public static Map<Id, Campaign> mapOfCampaignsToBeUpdated;    
    // List of Budget caps for further linking of campaigns during update
    public static List<Core_MDF_Budget_Cap__c> budgetCapsForCampaignLink = new List<Core_MDF_Budget_Cap__c>();
    // Map of Budget Cap's Record Type id and Record type info
    public static Map<ID, Schema.RecordTypeInfo> budgetCapRecTypeMap = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosById();
    // Map of Budget Cap's Record Type developer name and channel program info
    public static Map<String,String> budCapRecTypeToProg = new Map<String,String>();
    static{

        for(Core_MDF_ObjRecType_Budget_FieldSetMap__mdt  budTypeCapRT : [SELECT Id,Core_MDF_Channel_Program_Name_txt__c, Core_MDF_Budget_Cap_RecType_DevName_Txt__c FROM Core_MDF_ObjRecType_Budget_FieldSetMap__mdt  WHERE Core_MDF_Budget_Cap_RecType_DevName_Txt__c != NULL]){
            budCapRecTypeToProg.put(budTypeCapRT.Core_MDF_Budget_Cap_RecType_DevName_Txt__c,budTypeCapRT.Core_MDF_Channel_Program_Name_txt__c);
        }
    }
    public static Id ipaBudTypeCapRecordtype = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId(); 
    private Static String IPATechnicalProgram=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name');
    /***************************************************************************************************** 
    Method Name   :        budgetTypeCapOverlapDupCheck
    @return       :        void
    @parameters   :        BudgetCap list from trigger.new, BudgetCap old Map, isInsert and Isupdate boolean 
    Description   :        To check if the budget cap is a duplicate or overlapping record With the Incoming List as Well 
                           as the Existing records in the database and throw Errors accordingly
    Added By      :        Accenture - HP - 15/03/2021
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/
    public static List<Core_MDF_Budget_Cap__c> budgetTypeCapOverlapDupCheck(List<Core_MDF_Budget_Cap__c> newBudTypeCapList, Map<Id, Core_MDF_Budget_Cap__c> oldBudgetCapMap, Boolean isInsert, Boolean isUpdate) {
        // set of Budget Cap records
        Set<Id> budTypeCapIdOnUpdate = new Set<Id>();              
        // Map with Key as Budget Type name and Value as List of Budget Caps to Store Budget Caps in the database
        Map<String, List<Core_MDF_Budget_Cap__c>> existingBudgetTypeBudCapMap = new Map<String, List<Core_MDF_Budget_Cap__c>>();
        // to get Budget Type Cap Record Type Id
        Set<String> budgetTypes = new Set<String>();
        // List of Non Overlapping and Non Duplicate Budget caps
        List<Core_MDF_Budget_Cap__c> nonOverlapNonDuplicateBdgetCaps = new List<Core_MDF_Budget_Cap__c>();
        // Set of RecordType Id's
        Set<Id> budTypeCapRecTypeIds =  new Set<Id>();
        // List of Geo's
        //Set<String> budTypeCapGeoSet = new Set<String>();
        //budTypeCapGeoSet.add('WW');
        // Get Id Of Budget Cap's IPA Record Type 
        //Id ipaBudTypeCapRecordtype = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId(); 
        Date minDate;
        Date maxDate;
        if(newBudTypeCapList != NULL && newBudTypeCapList.size()>0){
            minDate = newBudTypeCapList[0].Core_MDF_Effective_Start_Date_Dt__c ;
            maxDate = newBudTypeCapList[0].Core_MDF_Effective_End_Date_Dt__c;
        }
        List<String> recTypeDeveloperNameLst = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_BudgetTypeCap_RecordTypes');
        try {
            List<Core_MDF_Budget_Cap__c> budgetTypeCapList = new List<Core_MDF_Budget_Cap__c>();
            for(Core_MDF_Budget_Cap__c budTypeCap : newBudTypeCapList) {
                //ATHR - Deeply Nested if 16209
                if(budTypeCap.RecordTypeId != ipaBudTypeCapRecordtype){
                    continue;
                }
                    // Add All the Incoming records While Insert But On Update, Add Only Those Record with specific Fields update
                    if(isInsert || (isUpdate && (budTypeCap.Core_MDF_Effective_Start_Date_Dt__c != oldBudgetCapMap.get(budTypeCap.ID).Core_MDF_Effective_Start_Date_Dt__c 
                    || budTypeCap.Core_MDF_Effective_End_Date_Dt__c != oldBudgetCapMap.get(budTypeCap.ID).Core_MDF_Effective_End_Date_Dt__c 
                    || budTypeCap.Core_MDF_Budget_Type_nm__c != oldBudgetCapMap.get(budTypeCap.ID).Core_MDF_Budget_Type_nm__c
                    || budTypeCap.Core_MDF_Region_nm__c      != oldBudgetCapMap.get(budTypeCap.ID).Core_MDF_Region_nm__c
                    || (budTypeCap.Core_MDF_Cap_Status_nm__c != oldBudgetCapMap.get(budTypeCap.ID).Core_MDF_Cap_Status_nm__c && budTypeCap.Core_MDF_Cap_Status_nm__c == 'Active')))){
                        // Adding the record's Id in a List In Update Scenario
                        if(isUpdate){ budTypeCapIdOnUpdate.add(budTypeCap.Id);
                        }
                        // Incoming Budget Cap's Budget Types
                        budgetTypes.add(budTypeCap.Core_MDF_Budget_Type_nm__c);
                        //Incoming budget Cap Records
                        budgetTypeCapList.add(budTypeCap);
                        //Incoming Budget Cap Record Ids
                        budTypeCapRecTypeIds.add(budTypeCap.RecordTypeId);
                        
                    }
					if(budTypeCap.Core_MDF_Effective_Start_Date_Dt__c < minDate){
                	minDate = budTypeCap.Core_MDF_Effective_Start_Date_Dt__c;
            		}
            		if(budTypeCap.Core_MDF_Effective_End_Date_Dt__c > maxDate){
                	maxDate = budTypeCap.Core_MDF_Effective_End_Date_Dt__c;
            		}                    
                
            }
            
            //Looping over existing budget caps corresponding to budget type and Geo But Excluding The Budgets Caps Which are going to be Updated
            for(Core_MDF_Budget_Cap__c existingBudTypeCap : [SELECT Id,Name,RecordTypeId, Core_MDF_Effective_End_Date_Dt__c, Core_MDF_Effective_Start_Date_Dt__c, Core_MDF_Budget_Type_nm__c,Core_MDF_Cap_Status_nm__c,Core_MDF_Region_nm__c
                                                             FROM Core_MDF_Budget_Cap__c 
                                                             WHERE Core_MDF_Budget_Type_nm__c IN :budgetTypes 
                                                             AND RecordTypeId IN : budTypeCapRecTypeIds 
                                                             AND Core_MDF_Cap_Status_nm__c =: 'Active'
                                                             AND ((Core_MDF_Effective_Start_Date_Dt__c >=: minDate AND Core_MDF_Effective_Start_Date_Dt__c <=: maxDate) OR (Core_MDF_Effective_End_Date_Dt__c >=: minDate AND Core_MDF_Effective_End_Date_Dt__c <=: maxDate) OR (Core_MDF_Effective_Start_Date_Dt__c <=: minDate AND Core_MDF_Effective_End_Date_Dt__c >=: maxDate))
                                                             AND Id NOT IN : budTypeCapIdOnUpdate]){
                                                                //Preparing Map of Existing Budget Caps Records with their Budget Types
                                                                if(existingBudgetTypeBudCapMap.containsKey(existingBudTypeCap.RecordTypeId + existingBudTypeCap.Core_MDF_Budget_Type_nm__c)){
                                                                    existingBudgetTypeBudCapMap.get(existingBudTypeCap.RecordTypeId + existingBudTypeCap.Core_MDF_Budget_Type_nm__c).add(existingBudTypeCap);
                                                                }else{
                                                                    existingBudgetTypeBudCapMap.put(existingBudTypeCap.RecordTypeId + existingBudTypeCap.Core_MDF_Budget_Type_nm__c, new List<Core_MDF_Budget_Cap__c>{existingBudTypeCap});
                                                                }
            }
            // Looping Over the Incoming List
            for(Integer OuterIndex = 0; OuterIndex < budgetTypeCapList.size(); OuterIndex++){
                
                // Error for Duplicate Records in Incoming List in Insert Scenario
                String duplicateErrorsInNew = '';
                // Error for Overlapping Records in Incoming List in Insert Scenario
                String overlappingErrorsInNew = '';
                // List to Store Duplicate Budget Cap Names From Existing as well as in New Records
                List<String> listOfDuplicateBudgetCaps = new List<String>();
                // List to Store Overlapping Budget Cap Names From Existing as well as in New Records
                List<String> listOfOverlappingBudgetCaps = new List<String>();
                Core_MDF_Budget_Cap__c budTypeCap = budgetTypeCapList[OuterIndex];
                if(budTypeCap.Core_MDF_Cap_Status_nm__c != 'Active'){continue;}
                // Looping again over the new List to check for any duplicate/Overlapping in the incoming List
                for(Integer innerIndex = 0; innerIndex < budgetTypeCapList.size(); innerIndex++){  
                    Core_MDF_Budget_Cap__c newBudTypeCapToCompare = budgetTypeCapList[innerIndex];  
                    // Skipping for - same record OR Record Type is Not IPA OR Different Budget Types OR Inactive Caps
                    if((innerIndex == OuterIndex) || /*(newBudTypeCapToCompare.RecordTypeId != ipaBudTypeCapRecordtype) ||*/ 
                        ((budTypeCap.RecordTypeId + budTypeCap.Core_MDF_Budget_Type_nm__c) != (newBudTypeCapToCompare.RecordTypeId + newBudTypeCapToCompare.Core_MDF_Budget_Type_nm__c))/*||
                        (budTypeCap.Core_MDF_Cap_Status_nm__c != 'Active')*/){
                            continue;}

                    // Check for the Duplicate budget caps
                    if(isBudgetTypeCapDuplicate(budTypeCap,newBudTypeCapToCompare)) {
                        // On Update, Add Duplicate Caps names in the List
                        if(newBudTypeCapToCompare.Id != NULL){ listOfDuplicateBudgetCaps.add(newBudTypeCapToCompare.Name);
                        }
                        else{
                            if(duplicateErrorsInNew == NULL || duplicateErrorsInNew == ''){
                                duplicateErrorsInNew = 'Duplicate Budget Cap in Incoming List';
                            }
                        }                           
                    }
                    // Check for the Overlapping Budget Caps
                    if(isBudgetTypeCapOverlapping(budTypeCap, newBudTypeCapToCompare)){
                        // On Update, Add Overlapping Caps names in the List
                        if(newBudTypeCapToCompare.Id != NULL){ listOfOverlappingBudgetCaps.add(newBudTypeCapToCompare.Name);
                        }
                        else{
                            if(overlappingErrorsInNew == NULL || overlappingErrorsInNew == ''){
                                overlappingErrorsInNew = 'Overlapping Budget Cap With Incoming List';
                            }
                        }
                    }
                }  
                if(existingBudgetTypeBudCapMap.containsKey(budTypeCap.RecordTypeId + budTypeCap.Core_MDF_Budget_Type_nm__c) && existingBudgetTypeBudCapMap.get(budTypeCap.RecordTypeId + budTypeCap.Core_MDF_Budget_Type_nm__c) != NULL){
                    // Looping over the Existing Budget Caps of Current Budget Cap's Budget type in the database to check for any Duplicate/Overlapping with the Incoming record
                    for(Core_MDF_Budget_Cap__c existingbudTypeCap : existingBudgetTypeBudCapMap.get(budTypeCap.RecordTypeId + budTypeCap.Core_MDF_Budget_Type_nm__c)){
                                // Check for the Duplicate Caps
                                if(isBudgetTypeCapDuplicate(budTypeCap,existingbudTypeCap)){
                                //Duplicate budget cap error
                                    listOfDuplicateBudgetCaps.add(existingbudTypeCap.Name);
                                } 
                                // Check for the Overlapping Budget Caps and add all the Overlapping Budget Caps in a List
                                if(isBudgetTypeCapOverlapping (budTypeCap, existingbudTypeCap)) {
                                    listOfOverlappingBudgetCaps.add(existingbudTypeCap.Name);
                                }
                            //}
                        //}
                    }                                    
                }
                // Consolidating all the errors in single String
                String recorderrors = '';                    
                recorderrors+= (listOfDuplicateBudgetCaps != NULL && listOfDuplicateBudgetCaps.size()>0) ?  '\n' + 'There is an existing Budget Cap called ' + String.join(listOfDuplicateBudgetCaps, ', ') + ' active for the same Budget Type, Geo and Time Period.' : (duplicateErrorsInNew != NULL && duplicateErrorsInNew != '') ? duplicateErrorsInNew : '';
                recorderrors+= (listOfOverlappingBudgetCaps != NULL && listOfOverlappingBudgetCaps.size()>0) ? '\n' + 'Budget Cap for the said Budget Type is overlapping with existing Budget Cap ' + String.join(listOfOverlappingBudgetCaps, ', ') : (overlappingErrorsInNew != NULL && overlappingErrorsInNew != '') ? '\n' + overlappingErrorsInNew : '';
                
                // Throwing error on the record
                if(recorderrors != NULL && recorderrors != ''){
                    budgetTypeCapList[OuterIndex].addError(recorderrors);
                }
                else{
                    nonOverlapNonDuplicateBdgetCaps.add(budgetTypeCapList[OuterIndex]);
                }
            }
        return nonOverlapNonDuplicateBdgetCaps;            
        } catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e;}
    }
    
    /***************************************************************************************************** 
    Method Name   :        checkBudgetTypeCapDupRecords
    @return       :        void
    @parameters   :        2 Budget Caps
    Description   :        To check if the budget cap is a duplicate with the One Used for camparison
    Added By      :        Accenture - PS - 21/04/2021
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/
    
    public static boolean isBudgetTypeCapDuplicate(Core_MDF_Budget_Cap__c newBudTypeCap, Core_MDF_Budget_Cap__c budgetTypeCapToCompare){
        try{
            Boolean duplicateBudgetTypeCap = false;
            if(newBudTypeCap.Core_MDF_Effective_Start_Date_Dt__c == budgetTypeCapToCompare.Core_MDF_Effective_Start_Date_Dt__c
            && newBudTypeCap.Core_MDF_Effective_End_Date_Dt__c == budgetTypeCapToCompare.Core_MDF_Effective_End_Date_Dt__c
            && newBudTypeCap.Core_MDF_Budget_Type_nm__c == budgetTypeCapToCompare.Core_MDF_Budget_Type_nm__c 
            && newBudTypeCap.Core_MDF_Cap_Status_nm__c == budgetTypeCapToCompare.Core_MDF_Cap_Status_nm__c
            && newBudTypeCap.RecordTypeId == budgetTypeCapToCompare.RecordTypeId
            && (newBudTypeCap.RecordTypeId == ipaBudTypeCapRecordtype 
                    && (newBudTypeCap.Core_MDF_Region_nm__c == budgetTypeCapToCompare.Core_MDF_Region_nm__c 
                        || (newBudTypeCap.Core_MDF_Region_nm__c != budgetTypeCapToCompare.Core_MDF_Region_nm__c 
                            && (newBudTypeCap.Core_MDF_Region_nm__c == 'WW'||budgetTypeCapToCompare.Core_MDF_Region_nm__c == 'WW'))))){
                
                duplicateBudgetTypeCap = true;
            }
            
            return duplicateBudgetTypeCap;
        }
        catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e; } 
    }

    /***************************************************************************************************** 
    Method Name   :        checkOverlapBudgetCap
    @return       :        Boolean
    @parameters   :        New Budget Cap record and existing budget cap record 
    Description   :        To check if the budget cap is overlapping record
    Added By      :        Accenture - HP - 15/03/2021
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/
    public static boolean isBudgetTypeCapOverlapping(Core_MDF_Budget_Cap__c newBudTypeCap, Core_MDF_Budget_Cap__c existingbudTypeCap) {
        try{
            //flag to hold result
            Boolean overlappingBudTypeCap = false;
            if((newBudTypeCap != null && existingbudTypeCap != null) && 
                    ((newBudTypeCap.Core_MDF_Effective_Start_Date_Dt__c == existingbudTypeCap.Core_MDF_Effective_End_Date_Dt__c || newBudTypeCap.Core_MDF_Effective_End_Date_Dt__c == existingbudTypeCap.Core_MDF_Effective_Start_Date_Dt__c) 
                    || (newBudTypeCap.Core_MDF_Effective_Start_Date_Dt__c > existingbudTypeCap.Core_MDF_Effective_Start_Date_Dt__c && newBudTypeCap.Core_MDF_Effective_End_Date_Dt__c < existingbudTypeCap.Core_MDF_Effective_End_Date_Dt__c) 
                    || (newBudTypeCap.Core_MDF_Effective_Start_Date_Dt__c > existingbudTypeCap.Core_MDF_Effective_Start_Date_Dt__c && newBudTypeCap.Core_MDF_Effective_Start_Date_Dt__c < existingbudTypeCap.Core_MDF_Effective_End_Date_Dt__c && newBudTypeCap.Core_MDF_Effective_End_Date_Dt__c > existingbudTypeCap.Core_MDF_Effective_End_Date_Dt__c) 
                    || (newBudTypeCap.Core_MDF_Effective_Start_Date_Dt__c == existingbudTypeCap.Core_MDF_Effective_Start_Date_Dt__c && 
                        ((newBudTypeCap.Core_MDF_Effective_End_Date_Dt__c > existingbudTypeCap.Core_MDF_Effective_Start_Date_Dt__c && newBudTypeCap.Core_MDF_Effective_End_Date_Dt__c < existingbudTypeCap.Core_MDF_Effective_End_Date_Dt__c) 
                        || newBudTypeCap.Core_MDF_Effective_End_Date_Dt__c > existingbudTypeCap.Core_MDF_Effective_End_Date_Dt__c)) 
                    || (newBudTypeCap.Core_MDF_Effective_End_Date_Dt__c == existingbudTypeCap.Core_MDF_Effective_End_Date_Dt__c && 
                        ((newBudTypeCap.Core_MDF_Effective_Start_Date_Dt__c > existingbudTypeCap.Core_MDF_Effective_Start_Date_Dt__c && newBudTypeCap.Core_MDF_Effective_Start_Date_Dt__c < existingbudTypeCap.Core_MDF_Effective_End_Date_Dt__c)
                        || newBudTypeCap.Core_MDF_Effective_Start_Date_Dt__c < existingbudTypeCap.Core_MDF_Effective_Start_Date_Dt__c)) 
                    || (newBudTypeCap.Core_MDF_Effective_Start_Date_Dt__c < existingbudTypeCap.Core_MDF_Effective_Start_Date_Dt__c && 
                        ((newBudTypeCap.Core_MDF_Effective_End_Date_Dt__c > existingbudTypeCap.Core_MDF_Effective_Start_Date_Dt__c && newBudTypeCap.Core_MDF_Effective_End_Date_Dt__c < existingbudTypeCap.Core_MDF_Effective_End_Date_Dt__c) 
                        || newBudTypeCap.Core_MDF_Effective_End_Date_Dt__c > existingbudTypeCap.Core_MDF_Effective_End_Date_Dt__c)))
                        && (newBudTypeCap.RecordTypeId == ipaBudTypeCapRecordtype 
                                && (newBudTypeCap.Core_MDF_Region_nm__c == existingbudTypeCap.Core_MDF_Region_nm__c 
                                    || (newBudTypeCap.Core_MDF_Region_nm__c != existingbudTypeCap.Core_MDF_Region_nm__c 
                                        && (newBudTypeCap.Core_MDF_Region_nm__c == 'WW' || existingbudTypeCap.Core_MDF_Region_nm__c == 'WW'))))){
                        
                overlappingBudTypeCap = true;
            }
            return overlappingBudTypeCap;
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); throw e; } 
    }
    
    /****************************************************************************************************************************************
    Method Name:                                  getClaimedAmtOfBudgetCapsOnInsert
    @return  :                                    void
    @parameters:                                  List of New budgetCap records
    Description:                                  During Budget Cap insertion, this method creates Map of Unique key and List of campaigns 
                                                  to be associated and calculate claimed cap amount on budget caps        
    Added By:                                     Accenture – Pranav -  5/25/2021
    Modified By:                  Date:           Changes: 
    *****************************************************************************************************************************************/
        
    public static void getClaimedAmtOfBudgetCapsOnInsert(List<Core_MDF_Budget_Cap__c> newBudTypeCapList){
        
        budgetCapUniqueKeyToCampaigns= new Map<String,List<Campaign>>();        
        // Map of Budget Type to List of Campaigns
        Map<String, List<Campaign>> budgetTypeToCampaignsList = new Map<String, List<Campaign>>();      
        // in this method, Budget Type and List of Campaigns will be mapped and returned
        budgetTypeToCampaignsList = createBudgetTypeToCampaignListMapping(newBudTypeCapList);   
        
        for(Core_MDF_Budget_Cap__c budgetCap : newBudTypeCapList){            
            Decimal claimedCapAmount = 0;
            //Key prepare for Program + BudgetType + Eff St Date + Eff Ed Date for Program + Budget Type + Eff St Date + Eff Ed Date + Geo for ipa to add the related campaigns.
            String budgetCapUniqueKey='';
            if(budgetCap.RecordTypeId == ipaBudTypeCapRecordtype) 
                budgetCapUniqueKey = budgetCap.RecordTypeId + budgetCap.Core_MDF_Budget_Type_nm__c + budgetCap.Core_MDF_Effective_Start_Date_Dt__c + budgetCap.Core_MDF_Effective_End_Date_Dt__c + budgetCap.Core_MDF_Region_nm__c;            
            else
                budgetCapUniqueKey = budgetCap.RecordTypeId + budgetCap.Core_MDF_Budget_Type_nm__c + budgetCap.Core_MDF_Effective_Start_Date_Dt__c + budgetCap.Core_MDF_Effective_End_Date_Dt__c;

            // Get all the campaigns for the current Budget cap's Budget type
            System.debug('MDT OPtimisation budCapRecTypeToProg '+ budCapRecTypeToProg);
            if(budgetTypeToCampaignsList != NULL && budgetTypeToCampaignsList.size()>0 && budgetTypeToCampaignsList.containsKey(budCapRecTypeToProg.get(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName()) + budgetCap.Core_MDF_Budget_Type_nm__c)
              && budgetTypeToCampaignsList.get(budCapRecTypeToProg.get(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName()) + budgetCap.Core_MDF_Budget_Type_nm__c) != NULL){
                for(Campaign camp : budgetTypeToCampaignsList.get(budCapRecTypeToProg.get(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName()) + budgetCap.Core_MDF_Budget_Type_nm__c))
                {
                    // Skip the campaign which is already attached to some Budget cap
                    if(camp.Core_MDF_Budget_Cap__c != NULL){continue;}
                    // If Campaign Start Date lies between Budget cap Effective start date and effective end date- Map it with it's (Budget Cap's) unique key
                    //ATHR - Deeply Nested if 16209
                    if(!((budgetCap.RecordTypeId == ipaBudTypeCapRecordtype && (budgetCap.Core_MDF_Region_nm__c == camp.Core_MDF_Host_Region_cd__c || (budgetCap.Core_MDF_Region_nm__c != camp.Core_MDF_Host_Region_cd__c && (budgetCap.Core_MDF_Region_nm__c == 'WW')))) && camp.startDate >= budgetCap.Core_MDF_Effective_Start_Date_Dt__c && camp.StartDate <= budgetCap.Core_MDF_Effective_End_Date_Dt__c)){
                        continue;
                    }
                    if(!budgetCapUniqueKeyToCampaigns.containsKey(budgetCapUniqueKey)){
                        budgetCapUniqueKeyToCampaigns.put(budgetCapUniqueKey, new List<Campaign>{camp});                                                       
                    }
                    budgetCapUniqueKeyToCampaigns.get(budgetCapUniqueKey).add(camp); 
                    // For Specific campaign status only take the sum of amount of campaigns and assign into Budget cap's claimed cap amount field                    
                    if(checkCampaignStatusForCapAmount(String.valueOf(camp.Status),Double.valueOf(camp.Core_MDF_Approval_Step_Counter_nbr__c))){
                        claimedCapAmount += (camp.Core_MDF_Reimbursement_Amt__c != NULL)? Double.valueOf(camp.Core_MDF_Reimbursement_Amt__c) : 0;
                    }
                }
            }
            // summed up campaign's amount of specific statuses will be assigned into Budget cap's claimed amount field
            budgetCap.Core_MDF_Claimed_Cap_amt__c = claimedCapAmount;            
        }
    }  
    
    /****************************************************************************************************************************************
    Method Name:                                  linkCampaignsToBudgetTypeCap
    @return  :                                    void
    @parameters:                                  List of New budgetCap records
    Description:                                  This method assigns Budget cap lookup field on IPA campaigns during budget cap Insertion          
    Added By:                                     Accenture – Pranav -  5/25/2021
    Modified By:                  Date:           Changes: 
    *****************************************************************************************************************************************/
    
    public static void linkCampaignsToBudgetTypeCap(List<Core_MDF_Budget_Cap__c> newBudTypeCapList){
        try{
            // Campaigns to be be updated after Budget cap lookup assignment
            List<Campaign> campaignList= new List<Campaign>();            
            for(Core_MDF_Budget_Cap__c budgetCap : newBudTypeCapList){ 
                // create same key that is used in the Map 
                String key ='';               
                //Key prepare for Program + BudgetType + Eff St Date + Eff Ed Date for Program + Budget Type + Eff St Date + Eff Ed Date + Geo for ipa to get the related campaigns.
                if(budgetCap.RecordTypeId == ipaBudTypeCapRecordtype) 
                    key =  budgetCap.RecordTypeId + budgetCap.Core_MDF_Budget_Type_nm__c + budgetCap.Core_MDF_Effective_Start_Date_Dt__c + budgetCap.Core_MDF_Effective_End_Date_Dt__c + budgetCap.Core_MDF_Region_nm__c;            
                else
                    key =  budgetCap.RecordTypeId + budgetCap.Core_MDF_Budget_Type_nm__c + budgetCap.Core_MDF_Effective_Start_Date_Dt__c + budgetCap.Core_MDF_Effective_End_Date_Dt__c;
                // Get all the campaigns for the unique key and assign the Budget cap lookup field and add the campaigns in the final list
                if(budgetCapUniqueKeyToCampaigns != NULL && budgetCapUniqueKeyToCampaigns.size()>0 && budgetCapUniqueKeyToCampaigns.containsKey(key)){                    
                    for(Campaign cmp : budgetCapUniqueKeyToCampaigns.get(key)){                        
                        cmp.Core_MDF_Budget_Cap__c = budgetCap.Id;
                        campaignList.add(cmp);
                    }
                }
            }
            if(campaignList != NULL && campaignList.size()>0){
                // Get the Batch size from custom setting record and execute a batch for updating budget caps lookup on campaigns
                Integer campaignBatchSize = Integer.valueOf(Core_MDF_Configuration__c.getValues('UPDATE_CAMPAIGN_BATCH_SIZE').Core_MDF_Value__c);
                Core_MDF_Batch_UpdateCampaigns updateCampaignbatch = new Core_MDF_Batch_UpdateCampaigns(campaignList);
                Database.executeBatch(updateCampaignbatch, campaignBatchSize);
            }
        }
        catch(Exception exc){
            Core_MDF_CCP_UtilityClass.logError(exc);
            throw exc;
        }
    }
    
    /****************************************************************************************************************************************
    Method Name:                                  identifyBudgetTypesCapsForLinkDelink
    @return  :                                    Set of Budget caps Ids
    @parameters:                                  List of New budgetCap records, Old Map of Budget caps
    Description:                                  This Method creates Separate List and Set to be used for Delinking and Linking campaigns
    Added By:                                     Accenture - Pranav –  5/25/2021
    Modified By:                  Date:           Changes: 
    *****************************************************************************************************************************************/
    
    public static Set<Id> identifyBudgetTypesCapsForLinkDelink(List<Core_MDF_Budget_Cap__c> newBudTypeCapList, Map<Id,Core_MDF_Budget_Cap__c> budgetCapOldMap){
        
        // Set of Budget cap Ids to return
        Set<Id> budgetCapIdsForDelinkSet = new Set<Id>();
        // Looping on the Budget cap records - Only Budget caps with their time period Changed Or if unactivated will be considered for delinking
        for(Core_MDF_Budget_Cap__c budgetCap : newBudTypeCapList){ 
            // If the Cap Status of Budget cap is changed
            if(budgetCap.Core_MDF_Cap_Status_nm__c != budgetCapOldMap.get(budgetCap.Id).Core_MDF_Cap_Status_nm__c){
                // If new status is Inactive then It will be considered ONLY for delinking and Claimed Cap Amount is set to 0
                if(budgetCap.Core_MDF_Cap_Status_nm__c == 'Inactive'){
                    budgetCap.Core_MDF_Claimed_Cap_amt__c = 0;
                    budgetCapIdsForDelinkSet.add(budgetCap.Id);
                }
                // If new status id Active ;It will be ONLY considered for linking
                else if(budgetCap.Core_MDF_Cap_Status_nm__c == 'Active'){
                    budgetCapsForCampaignLink.add(budgetCap);
                }
            }
            // If Either Start date Or End Date is changed then It will be considered for both linking as well as delinking
            // and Claimed Cap Amount is set to 0
            else if(budgetCap.Core_MDF_Cap_Status_nm__c == 'Active' && (budgetCap.Core_MDF_Effective_Start_Date_Dt__c != budgetCapOldMap.get(budgetCap.Id).Core_MDF_Effective_Start_Date_Dt__c || 
                    budgetCap.Core_MDF_Effective_End_Date_Dt__c != budgetCapOldMap.get(budgetCap.Id).Core_MDF_Effective_End_Date_Dt__c))
            {
                budgetCap.Core_MDF_Claimed_Cap_amt__c = 0;
                budgetCapIdsForDelinkSet.add(budgetCap.Id);
                budgetCapsForCampaignLink.add(budgetCap);
            }
        }
        return budgetCapIdsForDelinkSet;
    }
    /****************************************************************************************************************************************
    Method Name:                                  delinkCampaignsFromBudgetTypeCap
    @return  :                                    void 
    @parameters:                                  Set of Budget cap Ids
    Description:                                  This Method Delinks or Nullify all the campaigns of the Budget Cap If the Budget cap is 
                                                  Inactivated or Efeective start Date or effective End Date is changed   
    Added By:                                     Accenture – Pranav -  5/25/2021
    Modified By:                  Date:           Changes: 
    *****************************************************************************************************************************************/    
    
    public static void delinkCampaignsFromBudgetTypeCap(Set<Id> budgetCapIdsForDelinkSet){
                
        if(budgetCapIdsForDelinkSet != NULL && budgetCapIdsForDelinkSet.size()>0){
            // Query the Campaigns associated with the Budget caps ; Those Campaigns will be delinked from the Budget cap        
            mapOfCampaignsToBeUpdated = new Map<Id, Campaign>([SELECT Id, StartDate,Core_MDF_Opal_Budget_Type_Txt__c ,Core_MDF_Budget_Cap__c,Status FROM Campaign WHERE Core_MDF_Budget_Cap__c IN: budgetCapIdsForDelinkSet]);        
            for(Campaign campaign : mapOfCampaignsToBeUpdated.values()){
                // Nullify the budget cap Lookup field on Campaign
                campaign.Core_MDF_Budget_Cap__c = NULL;
            }
        }
    }
        
    /****************************************************************************************************************************************
    Method Name:                                  getClaimedCapAmtOfBudgetCapsOnUpdate
    @return  :                                    void
    @parameters:                                  -
    Description:                                  This Method creates a Map of Budget cap Id and List of Campaigns that needs to be associated 
                                                  in the after update and also calculate New claimed Cap amount due to date change or inactivation
    Added By:                                     Accenture – Pranav -  5/25/2021
    Modified By:                  Date:           Changes: 
    *****************************************************************************************************************************************/
    
    public static void getClaimedCapAmtOfBudgetCapsOnUpdate(){
        
        budgetCapIdToCampaigns= new Map<Id,List<Campaign>>();
        // map of Budget Types to List of campaigns
        Map<String, List<Campaign>> budgetTypeToCampaignsList = new Map<String, List<Campaign>>();
        // calling this method to prepare Budget type to relavant Campaigns List 
            budgetTypeToCampaignsList = createBudgetTypeToCampaignListMapping(budgetCapsForCampaignLink);   
            
        for(Core_MDF_Budget_Cap__c budgetCap : budgetCapsForCampaignLink){
            Decimal claimedCapAmount = 0;
            //ATHR - Deeply Nested if 16209
            if (budgetTypeToCampaignsList == NULL || budgetTypeToCampaignsList.size() == 0 || !budgetTypeToCampaignsList.containsKey(budCapRecTypeToProg.get(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName()) + budgetCap.Core_MDF_Budget_Type_nm__c) || budgetTypeToCampaignsList.get(budCapRecTypeToProg.get(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName()) + budgetCap.Core_MDF_Budget_Type_nm__c) == NULL){
                budgetCap.Core_MDF_Claimed_Cap_amt__c = claimedCapAmount;
                continue;
            }

                // Looping over the campaigns
                for(Campaign campaign : budgetTypeToCampaignsList.get(budCapRecTypeToProg.get(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName()) + budgetCap.Core_MDF_Budget_Type_nm__c))
                {
				
                    // If the campaign start date lies within Budget Cap's effective start date and end date - map that campaign with the budget cap id
                if(budgetCap.RecordTypeId != ipaBudTypeCapRecordtype || !(budgetCap.Core_MDF_Region_nm__c == campaign.Core_MDF_Host_Region_cd__c || budgetCap.Core_MDF_Region_nm__c == 'WW') || !(campaign.StartDate >= budgetCap.Core_MDF_Effective_Start_Date_Dt__c && campaign.StartDate <= budgetCap.Core_MDF_Effective_End_Date_Dt__c)) {
                    continue;
                }
                    
                if(budgetCapIdToCampaigns.containsKey(budgetCap.Id)){
                    budgetCapIdToCampaigns.get(budgetCap.Id).add(campaign);                           
                }
                else{
                    budgetCapIdToCampaigns.put(budgetCap.Id, new List<Campaign>{campaign});
                }
                // For specific campaign statuses , sum up the campaign's amount to finally assign it to budget cap's claimed cap amount field
                if(checkCampaignStatusForCapAmount(String.valueOf(campaign.Status),Double.valueOf(campaign.Core_MDF_Approval_Step_Counter_nbr__c))){
                    claimedCapAmount += (campaign.Core_MDF_Reimbursement_Amt__c != NULL) ? Double.valueOf(campaign.Core_MDF_Reimbursement_Amt__c) : 0;
                }
                }
            // summed up campaign's amount of specific statuses will be assigned into Budget cap's claimed amount field
            budgetCap.Core_MDF_Claimed_Cap_amt__c = claimedCapAmount;
        }
    }
    
    /****************************************************************************************************************************************
    Method Name:                                  linkCampaignsToBudgetTypeCapOnUpdate
    @return  :                                    void
    @parameters:                                  List of New budgetCap records
    Description:                                  This Method associates the campaigns with the Budget caps by populating Budget cap lookup on 
                                                  Campaigns and Update the campaigns
    Added By:                                     Accenture – Pranav -  5/25/2021
    Modified By:                  Date:           Changes: 
    *****************************************************************************************************************************************/ 
    
    public static void linkCampaignsToBudgetTypeCapOnUpdate(List<Core_MDF_Budget_Cap__c> budgetCapList){
        try{
            if(mapOfCampaignsToBeUpdated == NULL){
                mapOfCampaignsToBeUpdated = new Map<Id, Campaign>();
            }
            // Looping on the Budget caps 
            for(Core_MDF_Budget_Cap__c budgetCap : budgetCapList){                                
                Id key = budgetCap.Id; 
                // Looping on all the campaigns associated with the budget cap
                if(budgetCapIdToCampaigns!= NULL && budgetCapIdToCampaigns.size()>0 && budgetCapIdToCampaigns.containsKey(key)){                    
                    // Getting the campaigns associated with the Budget cap Id
                    for(Campaign cmp : budgetCapIdToCampaigns.get(key)){
                        // Assigning Budget Cap lookup field with Budget Cap id 
                        cmp.Core_MDF_Budget_Cap__c = budgetCap.Id;                        
                        // Putting all campaigns in final map that will be updated                        
                        mapOfCampaignsToBeUpdated.put(cmp.Id, cmp);
                    }
                }
            }
            if(mapOfCampaignsToBeUpdated != NULL && mapOfCampaignsToBeUpdated.size()>0){
                // Get the Batch size from custom setting record and execute a batch for updating budget caps lookup on campaigns
                Integer campaignBatchSize = Integer.valueOf(Core_MDF_Configuration__c.getValues('UPDATE_CAMPAIGN_BATCH_SIZE').Core_MDF_Value__c);
                Core_MDF_Batch_UpdateCampaigns updateCampaignbatch = new Core_MDF_Batch_UpdateCampaigns(mapOfCampaignsToBeUpdated.values());
                Database.executeBatch(updateCampaignbatch, campaignBatchSize);
            }
        }
        catch(Exception exc){
            Core_MDF_CCP_UtilityClass.logError(exc);
            throw exc;
        }
    } 

    /****************************************************************************************************************************************
    Method Name:                                  createBudgetTypeToCampaignListMapping
    @return  :                                    Map of Budget Type and List of Campaigns
    @parameters:                                  List of budgetCap records
    Description:                                  This Method creates Mapping of Budget Type and Campaigns 
    Added By:                                     Accenture - Pranav –  5/25/2021
    Modified By:                  Date:           Changes: 
    *****************************************************************************************************************************************/     
    
    public static Map<String,List<Campaign>> createBudgetTypeToCampaignListMapping (List<Core_MDF_Budget_Cap__c> newBudTypeCapList){
        // Variables for storing Set of Budget Types, oldest Effective Start date and Newest effective end date and Map of Budget Type to Campaigns 
        Set<String> BudgetTypes = new Set<String>();
        Date minDate;
        Date maxDate;
        List<String> campStatusToExcludeForLinking = Core_MDF_Configuration__c.getValues('CAMPAIGN_STATUS_IGNOREDFOR_BDGTCAPLINK').Core_MDF_Value__c.split(',');
        Set<String> progSet = new Set<String>();        
            
        // Initialise both the dates with the first Budget cap value
        if(newBudTypeCapList != NULL && newBudTypeCapList.size()>0){
            minDate = newBudTypeCapList[0].Core_MDF_Effective_Start_Date_Dt__c ;
            maxDate = newBudTypeCapList[0].Core_MDF_Effective_End_Date_Dt__c;
        }
        Map<String, List<Campaign>> budgetTypesToCampaignList = new Map<String, List<Campaign>>();
        Set<Id> budgetCapIds = new Set<Id>();
        // Fetching Budget Types from Incoming List and calculating oldest Effective Start date and Latest effective end date
        for(Core_MDF_Budget_Cap__c budgetCap : newBudTypeCapList)
        {
            BudgetTypes.add(budgetCap.Core_MDF_Budget_Type_nm__c);
            if(budgetCap.Core_MDF_Effective_Start_Date_Dt__c < minDate){
                minDate = budgetCap.Core_MDF_Effective_Start_Date_Dt__c;
            }
            if(budgetCap.Core_MDF_Effective_End_Date_Dt__c > maxDate){
                maxDate = budgetCap.Core_MDF_Effective_End_Date_Dt__c;
            }
            if(budgetCap.id != NULL){
                budgetCapIds.add(budgetCap.id);
            }
            if(budgetCapRecTypeMap.containsKey(budgetCap.RecordTypeId) && budgetCapRecTypeMap.get(budgetCap.RecordTypeId) != NULL){
                progSet.add(budCapRecTypeToProg.get(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName()));
            }            
        }
        //Set<String> geoSet = new Set<String>{'APJ','ASMO','EMEA','PRC','WW'};  //and Core_MDF_Region_cd__c IN : geoSet
        
        // Querying IPA Campaigns with status not cancelled whose start lies between minimum budget cap start date 
        // and max budget cap end date from incoming list - use MDF config custom setting for status
        for(Campaign campaign : [Select ID,StartDate,EndDate,Core_MDF_Program__c,Core_MDF_Opal_Budget_Type_Txt__c ,Core_MDF_Budget_Cap__c,Status,Core_MDF_Reimbursement_Amt__c,Core_MDF_Approval_Step_Counter_nbr__c,Core_MDF_Region_cd__c,Core_MDF_Host_Region_cd__c,Core_MDF_Approval_Stage_nm__c from Campaign
                                 where Core_MDF_Program__c IN : progSet and status NOT IN:campStatusToExcludeForLinking and Core_MDF_Opal_Budget_Type_Txt__c  IN : BudgetTypes
                                 and ((StartDate >=: minDate AND StartDate <=: maxDate) and (Core_MDF_Budget_Cap__c =: NULL OR Core_MDF_Budget_Cap__c IN: budgetCapIds))])
        {
            
            // Creating Budget Type to List of Campaigns Map
                if(!budgetTypesToCampaignList.containsKey(campaign.Core_MDF_Program__c + campaign.Core_MDF_Opal_Budget_Type_Txt__c )){
                    budgetTypesToCampaignList.put(campaign.Core_MDF_Program__c + campaign.Core_MDF_Opal_Budget_Type_Txt__c,new List<Campaign>{campaign});
                }
                else{
                    budgetTypesToCampaignList.get(campaign.Core_MDF_Program__c + campaign.Core_MDF_Opal_Budget_Type_Txt__c ).add(campaign);
                }
            
            
        }
        return budgetTypesToCampaignList;
    }
    
    /* This method checks where for a given campaign's status amount should be summed or not and based on that return true/false*/
    public static Boolean checkCampaignStatusForCapAmount(String campaignStatus, Double approvalStepCounterNo){
        
        Boolean isStatusReqdForClmdAmtSum = false;
        // Set the boolean to true for Campaign status for which campaign amount is going to be summed up  
        List<String> campaignStatusForClaimedCapAmt = Core_MDF_Configuration__c.getValues('CAMPAIGN_STATUS_FOR_BUDGETCAPAMT').Core_MDF_Value__c.split(',');                 
        if(campaignStatusForClaimedCapAmt.contains(campaignStatus) /*|| (campaignStatus == 'Pending Review'  && approvalStepCounterNo >= 1
                                                                      )*/){
            isStatusReqdForClmdAmtSum = true;
        }   
        return isStatusReqdForClmdAmtSum;
    }
    
    public static void shareRecordToGeoGroup(List<Core_MDF_Budget_Cap__c> newIPABudgetCapList) {
        //To share record on the basis of Channel Program and geo
        List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
        
        try
        {
            for(Core_MDF_Budget_Cap__c ipaBudgetCapRec :newIPABudgetCapList) {
                
                If(ipaBudgetCapRec.RecordTypeId == ipaBudTypeCapRecordtype  && ipaBudgetCapRec.Core_MDF_Region_nm__c != null){
                String program = budCapRecTypeToProg.get(budgetCapRecTypeMap.get(ipaBudgetCapRec.RecordTypeId).getDeveloperName());
                
                //recordGeoShareList.add(new Core_MDF_RecordGeoShare(ipaBudgetCapRec.id, ipaBudgetCapRec.Core_MDF_Region_nm__c,null,program,ipaBudgetCapRec.Core_MDF_Budget_Type_nm__c));
            	if(ipaBudgetCapRec.Core_MDF_Region_nm__c == 'WW'){
                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(ipaBudgetCapRec.id, 'APJ',null,program,ipaBudgetCapRec.Core_MDF_Budget_Type_nm__c));
                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(ipaBudgetCapRec.id, 'EMEA',null,program,ipaBudgetCapRec.Core_MDF_Budget_Type_nm__c));
                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(ipaBudgetCapRec.id, 'PRC',null,program,ipaBudgetCapRec.Core_MDF_Budget_Type_nm__c));
                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(ipaBudgetCapRec.id, 'ASMO',null,program,ipaBudgetCapRec.Core_MDF_Budget_Type_nm__c));
                    //recordGeoShareList.add(new Core_MDF_RecordGeoShare(ipaBudgetCapRec.id, 'INDIA',null,program,ipaBudgetCapRec.Core_MDF_Budget_Type_nm__c));
                    //recordGeoShareList.add(new Core_MDF_RecordGeoShare(ipaBudgetCapRec.id, 'ASMO','LAR',program,ipaBudgetCapRec.Core_MDF_Budget_Type_nm__c));
                    //recordGeoShareList.add(new Core_MDF_RecordGeoShare(ipaBudgetCapRec.id, 'ASMO','NAR',program,ipaBudgetCapRec.Core_MDF_Budget_Type_nm__c));
                }
                /*else If(ipaBudgetCapRec.Core_MDF_Region_nm__c == 'ASMO'){
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(ipaBudgetCapRec.id, ipaBudgetCapRec.Core_MDF_Region_nm__c,'LAR',program,ipaBudgetCapRec.Core_MDF_Budget_Type_nm__c));
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(ipaBudgetCapRec.id, ipaBudgetCapRec.Core_MDF_Region_nm__c,'NAR',program,ipaBudgetCapRec.Core_MDF_Budget_Type_nm__c));
                        }*/
                        Else{
                            recordGeoShareList.add(new Core_MDF_RecordGeoShare(ipaBudgetCapRec.id, ipaBudgetCapRec.Core_MDF_Region_nm__c,null,program,ipaBudgetCapRec.Core_MDF_Budget_Type_nm__c));
            	        }
                }
            }
        
            //To share record on the basis of Channel Program and geo
          
            if(recordGeoShareList != null && recordGeoShareList.size() > 0) {
                Core_MDF_ShareRecordToGeoSpecificGroup.shareRecordToGeoSpecificGroup('Core_MDF_Budget_Cap__c', recordGeoShareList);
            } 
            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
        
    }
    
    
    Public static void reshareBudgetCapRecords(List<Core_MDF_Budget_Cap__c> newBudgetCapRec,Map<Id,Core_MDF_Budget_Cap__c> oldBudgetCapRec){
    	
        List<Core_MDF_Budget_Cap__c> budgetCapUpdatedList =new List<Core_MDF_Budget_Cap__c>();
        List<id> budgetCapGeoUpdatedList =new List<id>();
        try{
            for(Core_MDF_Budget_Cap__c budgetTypeCap : newBudgetCapRec){
                //Owner or Geo Update check
                id recId = budgetTypeCap.id;
                if(oldBudgetCapRec.containskey(recId) && oldBudgetCapRec.get(recId).RecordTypeId == ipaBudTypeCapRecordtype ){
                    //Owner or Geo Update check
                    if(oldBudgetCapRec.get(recId).OwnerId != budgetTypeCap.OwnerId){
                    
                        budgetCapUpdatedList.add(budgetTypeCap);
           		    }
                     
                    if(oldBudgetCapRec.get(recId).Core_MDF_Region_nm__c != null && oldBudgetCapRec.get(recId).Core_MDF_Region_nm__c != budgetTypeCap.Core_MDF_Region_nm__c)
                    {
                      budgetCapGeoUpdatedList.add(budgetTypeCap.id);
                      budgetCapUpdatedList.add(budgetTypeCap);
                    }
                }  
            }
            List<Core_MDF_Budget_Cap__Share> existingSharedBudTypeCap =new list<Core_MDF_Budget_Cap__Share>([select id from Core_MDF_Budget_Cap__Share where ParentId IN : budgetCapGeoUpdatedList and RowCause = 'Manual']);
           
            if(!existingSharedBudTypeCap.isEmpty()){
            	delete existingSharedBudTypeCap;
            }
            
            if(!budgetCapUpdatedList.isEmpty()){
            	//Core_MDF_BudgetTypeCap_Utility.ipaBudgetCapSharingMainMethod((List<Core_MDF_Budget_Cap__c>) ipaBudgetCapOwnerUpdatedList);
            	Core_MDF_BudgetTypeCap_Utility.shareRecordToGeoGroup(budgetCapUpdatedList);
            }
            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
    }
   
        /****************************************************************************************************************************************
    Method Name:                                  validateBudgetTypeCapCreationOrUpdateAccess
    @return  :                                    Void
    @parameters:                                  List of IPA budgetCap records
    Description:                                  This Method throws error for a user having not required IUPGM access 
    Added By:                                     Accenture amey
    Modified By:                  Date:           Changes: 
    *****************************************************************************************************************************************/
    
    //putting IPA recordType records in this method
    public static void validateBudgetTypeCapCreationOrUpdateAccess(List<Core_MDF_Budget_Cap__c> ipaBudgetTypeCapList) {
        //List to store Roles
        List<String> rolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Finance_Roles');//Core_MDF_CCP_Internal_IPA_Finance_Usr
        //List to store assigned permission sets
        List<String> assignedPS = new List<String>();
        // List to store Program List
        List<String> progList = new List<String>();
        //progList.add(Label.Core_MDF_IPA_Technical_program_name);
        progList.add(IPATechnicalProgram);//Intel Partner Alliance	
        
        //map to store BudgetType to Geo values (for 1 budType - set of geos)
        Map<String,set<String>> btToGeoMap = new Map<String,set<String>>();
        //To Store IUPGM Unique keys 
        Set<String> iupgmUniqueKeySet = new Set<String>();
        try{
            for(PermissionSetAssignment psa : [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId() and PermissionSet.Name IN: rolesList]){
                assignedPS.add(psa.PermissionSet.Name);
            }
            //ATHR - Deeply Nested if 16209
            if(assignedPS.isEmpty()){
                return;
            }
                //if yes then only run for loop to check for IUPGM for that user
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRecord : [SELECT Id,Core_MDF_Channel_Program_id__c,Core_MDF_Region_cd__c,Core_MDF_Budget_Type_nm__c,/*Core_MDF_Budget_Type_txt__c,*/ Core_MDF_All_Budget_Type_Access_Ind__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c,Core_MDF_Program_nm__c
                                                                         FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                         WHERE Core_MDF_Active_Ind__c= TRUE 
                                                                         AND Core_MDF_is_User_Active_ind__c= TRUE 
                                                                         AND Core_MDF_User_id__c=:UserInfo.getUserId()
                                                                         AND Core_MDF_Program_nm__c IN: progList
                                                                         AND Core_MDF_Role_nm__c IN: assignedPS])
            {
                if(iupgmRecord.Core_MDF_All_Budget_Type_Access_Ind__c && iupgmRecord.Core_MDF_Region_cd__c != NULL){
                    for(String geo : iupgmRecord.Core_MDF_Region_cd__c.split(';')){
                        //If Geo from IUPGM is WW , creating keys for all geos ELSE (Program + respective geo) specific keys
                        switch on geo {
                        	when 'WW' {
                            	iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Program_nm__c)+'WW');
                            	iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Program_nm__c)+'APJ');
                            	iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Program_nm__c)+'PRC');
                            	iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Program_nm__c)+'EMEA');
                            	iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Program_nm__c)+'ASMO');
                            	//iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Program_nm__c)+'INDIA');
                            }                        
                        	when else {
                            	iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Program_nm__c)+geo);
                            }
                        }
                    }
                    continue;
                }
                if(iupgmRecord.Core_MDF_All_Budget_Type_Access_Ind__c || iupgmRecord.Core_MDF_GeoSubGeo_Budget_Type_nm__c == null){
                    continue;
                }
                
                             //Map<String,set<String>> btToGeoMap = new Map<String,set<String>>();
                             
                    for(String btList : iupgmRecord.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';')){//ASMO-LAR->Global Ericsson Acceleration - MDF;APJ->Business Client Acceleration - MDF
                        //splitting the field as we get values for Geo And budget type
                        List<String> geoBTList = btList.split('->');// APJ->Data Centric Acceleration - MDF
                        //ATHR - Deeply Nested if 16209
                        if(geoBTList.size() <= 1){
                            continue;
                        }
                        	String geo = geoBTList[0];
                        	String budgetType = geoBTList[1];
                        
                            // Intel Partner AllianceAPJData Centric Acceleration - MDF, Intel Partner AllianceASMOGlobal Ericsson Acceleration - MDF
                            //iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Program_nm__c)+geo.split('-')[0]+budgetType);///ASMO-LAR
                        	 iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Program_nm__c)+geo+budgetType);
                        	//to check if a budget type have all geo access
                        	//to create key for a single budget type and WW geo access
                        	if(btToGeoMap.containsKey(budgetType)){
                            	btToGeoMap.get(budgetType).add(geo);
                        	}else{
                            	btToGeoMap.put(budgetType, new set<String>{geo});
                        	}
                    }
                    if(btToGeoMap != NULL && btToGeoMap.size()>0){
                        for(String bt : btToGeoMap.keySet()){
                            //if(btToGeoMap.containsKey(bt) && btToGeoMap.get(bt) != NULL){
                                if(btToGeoMap.get(bt).contains('APJ') && btToGeoMap.get(bt).contains('EMEA') /*&& btToGeoMap.get(bt).contains('INDIA')*/ && btToGeoMap.get(bt).contains('PRC') && /*(btToGeoMap.get(bt).contains('ASMO-LAR') && btToGeoMap.get(bt).contains('ASMO-NAR'))||(*/btToGeoMap.get(bt).contains('ASMO')/*))*/){
                                    //key for a single budget type and WW geo access
                                    iupgmUniqueKeySet.add(String.valueOf(iupgmRecord.Core_MDF_Program_nm__c)+'WW'+bt);
                                }
                            //}
                        }
                    }
            }
            for(Core_MDF_Budget_Cap__c budgetTypeCapRec : ipaBudgetTypeCapList){
                 
                String combinationOfProgGeo = '';
                String combinationOfProgGeoBudType = '';
                //ATHR - Deeply Nested if 16209
                if(budgetTypeCapRec.Core_MDF_Region_nm__c == null || budgetTypeCapRec.Core_MDF_Budget_Type_nm__c == null){
                    continue;
                }
                	if(!(budCapRecTypeToProg.containsKey(budgetCapRecTypeMap.get(budgetTypeCapRec.RecordTypeId).getDeveloperName()) || budCapRecTypeToProg.get(budgetCapRecTypeMap.get(budgetTypeCapRec.RecordTypeId).getDeveloperName()) == NULL)){
                        continue;
                    }
                    	//string to contain (Program + Geo) key
                		combinationOfProgGeo = (budCapRecTypeToProg.get(budgetCapRecTypeMap.get(budgetTypeCapRec.RecordTypeId).getDeveloperName()))+budgetTypeCapRec.Core_MDF_Region_nm__c;
                		//String to contain (Program + Geo + BudgetType) key
                		combinationOfProgGeoBudType = (budCapRecTypeToProg.get(budgetCapRecTypeMap.get(budgetTypeCapRec.RecordTypeId).getDeveloperName()))+budgetTypeCapRec.Core_MDF_Region_nm__c+budgetTypeCapRec.Core_MDF_Budget_Type_nm__c;
                	
                    	//if iupgmUniqeKeySet is empty OR if its not empty and progGeo is not in that keySet and prgram+geo+budgetType key also not in the keySet
                		//then throwing error
                	if(iupgmUniqueKeySet.isEmpty() || (!iupgmUniqueKeySet.isEmpty() && !iupgmUniqueKeySet.contains(combinationOfProgGeo) && !iupgmUniqueKeySet.contains(combinationOfProgGeoBudType))){
                	//comparing the budgetcap unique value with IUPGM unique value and displaying error message if it is not matching
                    	budgetTypeCapRec.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetCapFinUserRole_ErrorMsg'));
                	}
              
            }
            
        }catch(Exception ex){ Core_MDF_CCP_UtilityClass.logError(ex);}
    }
}