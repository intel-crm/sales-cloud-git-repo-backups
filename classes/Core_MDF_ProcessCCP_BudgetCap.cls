/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_BudgetCap 
* Version     : 1.0 
* Created Date: 05-09-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar K        5/09/2019                    Created Core_MDF_ProcessCCP_BudgetCap class to throw error if Request Cap Amount is
                                                             less than Claimed Cap Amount
* NP(11630236)          15-04-2020           US633341 - Enabling Multiple Budget Cap Functionality
* NP(11630236)          27-04-2020           DE76218 - Unable to Reject Budget Cap if Claimed Amount > Requested Amount
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ProcessCCP_BudgetCap {

/****************************************************************************************************************************************
Method Name:                                             getSumOfClaimedAmount
@return  :                                               --
@parameters:                                             List of budgetCap records, budgetCap oldMap, isInsert and isUpdate
Description:                                             getting sum of claimed amount based on cap type
Added By:                                                Accenture – Shridhar K  -  5/09/2019
Modified By:                  Date:                      Changes: 
Accenture – Shridhar K       5/09/2019                   Created.
*****************************************************************************************************************************************/
    public static void getSumOfClaimedAmount(List<Core_MDF_Budget_Cap__c> budgetCapList, Map<Id,Core_MDF_Budget_Cap__c> budgetCapOldMap, boolean isInsert, boolean isUpdate){
        try{
            
            List<Id> budgetIdList = new List<Id>();
            Map<Id,Decimal> totalAmountMap = new Map<Id,Decimal>();
            List<Core_MDF_Budget_Cap__c> toBeProcessedBudgetCapList = new List<Core_MDF_Budget_Cap__c>();

            for(Core_MDF_Budget_Cap__c budgetCap : budgetCapList){
                if((isInsert || (isUpdate && (budgetCap.Core_MDF_Requested_Cap_amt__c != budgetCapOldMap.get(budgetCap.Id).Core_MDF_Requested_Cap_amt__c || budgetCap.Core_MDF_Cap_Status_nm__c != budgetCapOldMap.get(budgetCap.Id).Core_MDF_Cap_Status_nm__c))) &&
                    budgetCap.Core_MDF_Budget_Name_id__c != null){
                        budgetIdList.add(budgetCap.Core_MDF_Budget_Name_id__c);
                        toBeProcessedBudgetCapList.add(budgetCap);
                }
            }
            
            if(toBeProcessedBudgetCapList.size()<1){
                return;
            }
            
            Boolean active = True ;
            if(test.isRunningTest()){
                active = false;
            }
            //Collect metadata 
            List<Core_MDF_CCP_Activity_Budget_Cap_Window__mdt> metadataList = [SELECT Core_MDF_Field_Name_1_txt__c, Core_MDF_Field_Name_2_txt__c, Core_MDF_Operator_1_nm__c, Core_MDF_Operator_2_nm__c,  Core_MDF_Value_1_txt__c, Core_MDF_Value_2_txt__c, Cap_Type__c, Core_MDF_Channel_Program_Name__c, Core_MDF_Active_ind__c FROM Core_MDF_CCP_Activity_Budget_Cap_Window__mdt WHERE Core_MDF_Active_ind__c=:active];
                                                                              
                                                                                
                                                                                
            
            
            //Construct Activity Query
            Set<String> activitFieldSet = new Set<String>();
            Map<String, List<Core_MDF_CCP_Activity_Budget_Cap_Window__mdt>> programSpecificMDT = new Map<String, List<Core_MDF_CCP_Activity_Budget_Cap_Window__mdt>>();
            for(Core_MDF_CCP_Activity_Budget_Cap_Window__mdt mdt :metadataList){
                
                activitFieldSet.add(mdt.Core_MDF_Field_Name_1_txt__c);
                if(mdt.Core_MDF_Field_Name_2_txt__c != null){
                    activitFieldSet.add(mdt.Core_MDF_Field_Name_2_txt__c);
                }
                
       
                if(programSpecificMDT.containsKey(mdt.Core_MDF_Channel_Program_Name__c)){
                    programSpecificMDT.get(mdt.Core_MDF_Channel_Program_Name__c).add(mdt);
                }else{
                    List<Core_MDF_CCP_Activity_Budget_Cap_Window__mdt> tempMDT = new List<Core_MDF_CCP_Activity_Budget_Cap_Window__mdt>();
                    tempMDT.add(mdt);
                    programSpecificMDT.put(mdt.Core_MDF_Channel_Program_Name__c,tempMDT);
                }
            }
            
            
            String pfrQuery = 'SELECT Id, BudgetId, Campaign.Core_MDF_Program__c';
            for(String fieldName : activitFieldSet){
                //pfrQuery = pfrQuery +', ' + fieldName;
        //Added String.escapeSingleQuotes() to avoid SOQL Injection
                pfrQuery = pfrQuery +', ' + String.escapeSingleQuotes(fieldName); 
            }
            pfrQuery = pfrQuery + ' FROM PartnerFundRequest WHERE BudgetId IN: budgetIdList LIMIT 50000';
            
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            pfrList = Database.query(pfrQuery);
            
            Map<String, List<Id>> budgetCapTypeWithActivity = new Map<String, List<Id>>();          
            
            //Determine Activities          
            Boolean isCriteriaMatched = false;          
            Schema.DescribeSObjectResult dsr = Schema.SObjectType.PartnerFundRequest;
            Schema.DescribeFieldResult sObjField;
            Set<Id> prfIdSet = new Set<Id>();
            Map<Id,set<String>> pfrIdWithCapType = new Map<Id,set<String>>(); 
            
            for(PartnerFundRequest pfr: pfrList){
                SObject sObj = (SObject)pfr;
                if(programSpecificMDT.containsKey(pfr.Campaign.Core_MDF_Program__c)){
                    for(Core_MDF_CCP_Activity_Budget_Cap_Window__mdt mdt: programSpecificMDT.get(pfr.Campaign.Core_MDF_Program__c)){
                        isCriteriaMatched = false;
                        sObjField = dsr.fields.getMap().get(mdt.Core_MDF_Field_Name_1_txt__c).getDescribe();
                        
                        //Criteria 1 Validation
                        isCriteriaMatched = isCriteriaMatching(String.valueOf(sObj.get(mdt.Core_MDF_Field_Name_1_txt__c)),mdt.Core_MDF_Value_1_txt__c,mdt.Core_MDF_Operator_1_nm__c,string.valueOf(sObjField.getType()));
                        
                        //Criteria 2 Validation                     
                        if(isCriteriaMatched && mdt.Core_MDF_Field_Name_2_txt__c != null){
                            sObjField = dsr.fields.getMap().get(mdt.Core_MDF_Field_Name_2_txt__c).getDescribe();
                            isCriteriaMatched = isCriteriaMatching(String.valueOf(sObj.get(mdt.Core_MDF_Field_Name_2_txt__c)),mdt.Core_MDF_Value_2_txt__c,mdt.Core_MDF_Operator_2_nm__c,string.valueOf(sObjField.getType()));                         
                        }
                        
                        
            
                        
                        if(isCriteriaMatched){
                            if(budgetCapTypeWithActivity.containsKey(pfr.BudgetId+'#'+mdt.Cap_Type__c)){
                                budgetCapTypeWithActivity.get(pfr.BudgetId+'#'+mdt.Cap_Type__c).add(pfr.Id);
                            }
                            else{
                                List<Id> tempIdList = new List<Id>();
                                tempIdList.add(pfr.Id);
                                budgetCapTypeWithActivity.put(pfr.BudgetId+'#'+mdt.Cap_Type__c,tempIdList);
                            }
                            prfIdSet.add(pfr.Id);   
                            //US633341 - Handling Multiple Budget Caps on single Activity
                            if(pfrIdWithCapType.containsKey(pfr.id)){
                                pfrIdWithCapType.get(pfr.id).add(mdt.Cap_Type__c);
                            }
                            else{
                                pfrIdWithCapType.put(pfr.id, new set<String>{mdt.Cap_Type__c});
                            }                    
                        }                       
                    }
                }
            }
            
            
            
            //Collect All the Claims associated the with budgtes
            Map<Id,Decimal> pfrIdWithAmountSum = new Map<Id,Decimal>();
            
            List<String> claimStatusToBeExcluded = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_ClaimStatusToBeExcludForBudCap',',');
            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            pfcList = [SELECT Id, Core_MDF_Cap_Type_nm__c, Amount,RequestId,Core_MDF_Status__c FROM PartnerFundClaim WHERE
                                        RequestId IN: prfIdSet AND Core_MDF_Status__c NOT IN: claimStatusToBeExcluded];
            for(PartnerFundClaim pfc : pfcList){
                if(pfrIdWithAmountSum.containsKey(pfc.RequestId)){
                    Decimal tempAmount = 0;
                    tempAmount = pfrIdWithAmountSum.get(pfc.RequestId) + pfc.Amount;
                    pfrIdWithAmountSum.put(pfc.RequestId,tempAmount);
                }else{
                    pfrIdWithAmountSum.put(pfc.RequestId,pfc.Amount);
                }                   
            }
            
            //Validation begins
            for(Core_MDF_Budget_Cap__c budgetCap : toBeProcessedBudgetCapList){
                Decimal sumofClaimAmount = 0;
                if(budgetCapTypeWithActivity.containsKey(budgetCap.Core_MDF_Budget_Name_id__c+'#'+budgetCap.Core_MDF_Cap_Type_nm__c)){
                    for(Id pfrId: budgetCapTypeWithActivity.get(budgetCap.Core_MDF_Budget_Name_id__c+'#'+budgetCap.Core_MDF_Cap_Type_nm__c)){                       
                        if(pfrIdWithAmountSum.containsKey(pfrId)){
                            sumofClaimAmount = sumofClaimAmount + pfrIdWithAmountSum.get(pfrId);
                        }                       
                    }
                }
                budgetCap.Core_MDF_Claimed_Cap_amt__c = sumofClaimAmount;
               
                //DE76218 - Unable to Reject Budget Cap if Claimed Amount > Requested Amount
                if(sumofClaimAmount > budgetCap.Core_MDF_Requested_Cap_amt__c && budgetCap.Core_MDF_Cap_Status_nm__c != 'Revision Required'){
                    budgetCap.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Requested_Cap_Amount_ErrorMsg')+' '+sumofClaimAmount );
                }               
            }

            //Update Claims
            List<PartnerFundClaim> toBeUpdatedClaimList = new List<PartnerFundClaim>();
            List<string> existingCapTypesList = new List<string>();
            
            for(PartnerFundClaim pfc: pfcList){
                if(pfrIdWithCapType.containsKey(pfc.RequestId) && pfrIdWithCapType.get(pfc.RequestId) != null){
                    List<String> toBeAssignedCapTypes = new List<String>(pfrIdWithCapType.get(pfc.RequestId));
                    string existingCapTypes = pfc.Core_MDF_Cap_Type_nm__c; 
  
                    //If the Cap Type field on the claim is null -> Assign the Activity's Cap Type to the Claim and update
                    if(pfc.Core_MDF_Cap_Type_nm__c == null){
                        pfc.Core_MDF_Cap_Type_nm__c = toBeAssignedCapTypes.size()>1 ? string.join(toBeAssignedCapTypes,';'): toBeAssignedCapTypes[0];
                        toBeUpdatedClaimList.add(pfc);
                    }
                    
                    //If there is an existing value on the Cap Type field on claim
                    else{
                        if(existingCapTypes.contains(';')){existingCapTypesList = existingCapTypes.split(';');}
                        else{existingCapTypesList.add(existingCapTypes);}
                        
                        for(string tbaCapType: toBeAssignedCapTypes){
                            //Check if the value already exists on the Cap Type field on Claim
                            if(!existingCapTypesList.contains(tbaCapType)){
                                //If value doesn't exist on the Cap Type field, update with the Cap Type values
                                pfc.Core_MDF_Cap_Type_nm__c = pfc.Core_MDF_Cap_Type_nm__c == null ? tbaCapType : pfc.Core_MDF_Cap_Type_nm__c + ';' + tbaCapType;
                                toBeUpdatedClaimList.add(pfc);
                            }
                        }
                    }
                    //pfc.Core_MDF_Cap_Type_nm__c = capTypes;    
                }
            }
            
            if(toBeUpdatedClaimList.size()>0){
                Database.SaveResult[] srList = Database.update(toBeUpdatedClaimList, false);
                //Calling insertLogEntryRecord method to insert log entry for failed record
                insertLogEntryRecord(srList);                
            }
            
        }
        catch(Exception e){
            String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,'Exception occured in getSumOfClaimedAmount method');
        }
    }
    
/****************************************************************************************************************************************
    Method Name:                                             isCriteriaMatching
    @return  :                                               return boolean.
    @parameters:                                             recordValue, Operator, Value and fieldType
    Description:                                             Compares fieldValue with criteria rule value based on criteria operator.
    Added By:                                                Accenture – Shridhar K  -  05/08/2019
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar K        05/08/2019                 Created.
*****************************************************************************************************************************************/ 
    public static boolean isCriteriaMatching(String recValue, String crtValue, String operator, String fieldType){
        
        // Classifying the field type.
        // String comparison
        String stringType = 'REFERENCE;STRING;BOOLEAN;EMAIL;PICKLIST;PHONE;ENCRYPTEDSTRING;TEXTAREA;URL';
        String numberType = 'CURRENCY;DOUBLE;PERCENT';
        String dateType = 'DATE;DATETIME;TIME';
        String multiSelectType = 'MULTIPICKLIST';
        
        //Comparing Null/Blank values
        if(String.isBlank(crtValue) &&
            ((operator == 'Equal' &&  String.isBlank(recValue)) || 
            (operator == 'Not Equal' && !(String.isBlank(recValue))) ||
            (operator == 'In' && String.isBlank(recValue)) ||
            (operator == 'Not In' && !String.isBlank(recValue)))){
                return true;
        }
        if(String.isBlank(recValue) &&
            ((operator == 'Equal' &&  String.isBlank(crtValue)) || 
            (operator == 'Not Equal' && !(String.isBlank(crtValue))) ||
            (operator == 'In' && String.isBlank(crtValue)) ||
            (operator == 'Not In' && !String.isBlank(crtValue)))){
                return true;
        }
        if(String.isBlank(crtValue) || String.isBlank(recValue)){
            return false;
        }
        
        //Comparing other than blank values        
        //String type comparison with all appropriate operators
        if(stringType.contains(fieldType)){
            if((operator == 'Not Equal' && recValue != crtValue) || (operator == 'Equal' && recValue == crtValue)){            
                return true;
            }
            if(operator == 'In'){
                list<String> mainString = crtValue.toLowerCase().split(';');
                if(mainString.contains(recValue.toLowerCase())){
                    return true;
                }
                else{
                    return false;
                }
            }
            if(operator == 'Not In'){
                list<String> mainString = crtValue.toLowerCase().split(';');
                if(!mainString.contains(recValue.toLowerCase())){
                    return true;
                }
                else{
                    return false;
                }
            }               
            return false;
        }
        
        //Number type comparison with all appropriate operators
        if(numberType.contains(fieldType)){
            if((operator == 'Not Equal' && Decimal.valueof(recValue) != Decimal.valueof(crtValue)) || (operator == 'Equal' && Decimal.valueof(recValue) == Decimal.valueof(crtValue)) 
                || (operator == 'Greater Than' && Decimal.valueof(recValue) > Decimal.valueof(crtValue)) || (operator == 'Greater Than or Equal' && Decimal.valueof(recValue) >= Decimal.valueof(crtValue))
                || (operator == 'Less Than' && Decimal.valueof(recValue) < Decimal.valueof(crtValue)) || (operator == 'Less Than or Equal' && Decimal.valueof(recValue) <= Decimal.valueof(crtValue))){
                return true;
            }
            else
            {
                return false;
            }
        }
        
        //Date type comparison with all appropriate operators
        if(dateType.contains(fieldType)){
            if((operator == 'Not Equal' && Date.valueof(recValue) != Date.valueof(crtValue)) || (operator == 'Equal' && Date.valueof(recValue) == Date.valueof(crtValue)) 
                || (operator == 'Greater Than' && Date.valueof(recValue) > Date.valueof(crtValue)) || (operator == 'Greater Than or Equal' && Date.valueof(recValue) >= Date.valueof(crtValue))
                || (operator == 'Less Than' && Date.valueof(recValue) < Date.valueof(crtValue)) || (operator == 'Less Than or Equal' && Date.valueof(recValue) <= Date.valueof(crtValue))){
               
                return true;
            }
            else
            {
                return false;
            }
        }
        //Multi-Select type comparison with all appropriate operators
        if(multiSelectType.contains(fieldType)){
            if(operator == 'Equal'){
                if(crtValue.split(';').size() != recValue.split(';').size()){
                    return false;
                }
                list<String> mainString = crtValue.toLowerCase().split(';');
                for(String str: recValue.split(';')){
                    if(!mainString.contains(str.toLowerCase())){
                        return false;
                    }
                }
                return true;
            }
            if(operator == 'Not Equal'){
                list<String> mainString = crtValue.toLowerCase().split(';');                
                for(String str: recValue.split(';')){
                    if(!mainString.contains(str.toLowerCase())){
                        return true;
                    }
                }
                return false;
            }
            if(operator == 'In'){
                list<String> mainString = crtValue.toLowerCase().split(';');
                        
                for(String str: recValue.toLowerCase().split(';')){  
                   
                    if(!mainString.contains(str.toLowerCase())){
                        return false;
                    }
                }
                return true;
            }
            if(operator == 'Not In'){
                list<String> mainString = crtValue.toLowerCase().split(';');
                for(String str: recValue.toLowerCase().split(';')){                 
                    if(mainString.contains(str.toLowerCase())){
                        return false;
                    }
                }
                return true;
            }           
            return false;
        }
        //Return false if user selects inappropriate operator 
        return false;
    }
    
    // This method will insert log entry records for failed records
    public static void insertLogEntryRecord(Database.SaveResult[] srList){
        try{
            String errorMessage = '';
            for(Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        errorMessage = errorMessage + err.getMessage()+ '\t';                   
                    }
                    errorMessage = errorMessage + '\n';
                }                       
            }
            if(!String.isBlank(errorMessage)){
                String trimmedString = '';
                if(errorMessage.getChars().size() > 30000){
                    trimmedString = errorMessage.substring(0, 30000);
                    Core_MDF_CCP_UtilityClass.logErrorinLogObject(trimmedString,'Core_MDF_ClaimReviewCaseProcessHelper.execute');       
                }
                else{
                    Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorMessage,'Core_MDF_ClaimReviewCaseProcessHelper.execute');        
                }
                
            }
        }
        catch(exception ex){
            //System.debug('ex.getMessage(): '+ex.getMessage());
        }  
    }     
    
    /***************************************************************************************************** 
    Method Name   :        shareWithFinMgr
    @return       :        void
    @parameters   :        BudgetCap list from trigger.new, BudgetCap old Map, isInsert and Isupdate boolean 
    Description   :        To share the budget cap record with Finance Manager group based on geo 
    Added By      :        Accenture - VK - 12/16/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    public static void shareWithFinMgr(List<Core_MDF_Budget_Cap__c> budgetCapList, Map<Id, Core_MDF_Budget_Cap__c> oldBudgetCapMap, Boolean isInsert, Boolean isUpdate){
        
        List<Core_MDF_RecordGeoShare> recGeoShrLst = new List<Core_MDF_RecordGeoShare>();
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        for(Core_MDF_Budget_Cap__c bCap : [SELECT Id, Core_MDF_Budget_Name_id__r.Core_MDF_Program__r.Name,
                                           Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_Geo__c,
                                           Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c,
                                           Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c,
                                           OwnerId
                                           FROM Core_MDF_Budget_Cap__c 
                                           WHERE Id IN: budgetCapList]){
            if(isInsert || (isUpdate && bCap.OwnerId != oldBudgetCapMap.get(bCap.Id).OwnerId)){                                   
                Core_MDF_RecordGeoShare recGeoShare = new Core_MDF_RecordGeoShare(bCap.Id, 
                                                                                bCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_Geo__c,
                                                                                bCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c,
                                                                                bCap.Core_MDF_Budget_Name_id__r.Core_MDF_Program__r.Name);
                recGeoShrLst.add(recGeoShare);
                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(bCap.id, bCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_Geo__c, bCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c, bCap.Core_MDF_Budget_Name_id__r.Core_MDF_Program__r.Name, bCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c));
            }
        }
        
        //Sharing for FM Group
        if(recGeoShrLst.size() > 0){
            Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Core_MDF_Budget_Cap__c', recGeoShrLst);
        }
        if(recordPGMShareList != null && recordPGMShareList.size() >0){
            Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Core_MDF_Budget_Cap__c', recordPGMShareList);
        }
    }
}