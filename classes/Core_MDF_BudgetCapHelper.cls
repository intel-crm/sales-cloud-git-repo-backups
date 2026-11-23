/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetCapHelper 
* Version     : 1.0 
* Created Date: 04-30-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar K        5/09/2019                 Prevents the claim creation/Update if claimed amount exceeds the remaining budget cap
* NP(11630236)                  15-4-2020                 US633341 - Enabling Multiple Budget Cap Functionality
* NP(11630236)                  29-4-2020                 DE76638: Not updating the Budget Cap Claimed Amount when Claim is Denied since pfc.Amount - 0
*****************************************************************************************************************************************/
public without sharing class Core_MDF_BudgetCapHelper{  
    /****************************************************************************************************************************************
        Method Name:                                             checkBudgetAvailabiltyOnClaimInsert
        @return  :                                               return null.
        @parameters:                                             Claim oldMap and Claim newMap
        Description:                                             Prevents the claim creation if claimed amount exceeds the remaining budget cap
        Added By:                                                Accenture – Shridhar K  -  5/09/2019
        Modified By:                  Date:                      Changes: 
        Accenture – Shridhar K        5/09/2019                 Created.
    *****************************************************************************************************************************************/      
        public static void checkBudgetAvailabiltyOnClaimInsert(List<PartnerFundClaim> newClaimList){
            try{
                Set<Id> prfIdSet = new Set<Id>();           
                for(PartnerFundClaim pfc: newClaimList){ 
                    prfIdSet.add(pfc.RequestId);
                }
    
                Set<Id> budgetIdSet = new Set<Id>();
                for(PartnerFundRequest pfr: [SELECT Id, BudgetId FROM PartnerFundRequest WHERE Id IN: prfIdSet]){
                    if(pfr.BudgetId != null){
                        budgetIdSet.add(pfr.BudgetId);
                    }
                }
                //Determination of Cap Type begins
                //Collect metadata 
                Boolean active = True ;
                if(test.isRunningTest()){
                    active = false;
                }
                List<Core_MDF_CCP_Activity_Budget_Cap_Window__mdt> metadataList = [SELECT Core_MDF_Field_Name_1_txt__c, Core_MDF_Field_Name_2_txt__c, Core_MDF_Operator_1_nm__c, Core_MDF_Operator_2_nm__c,Core_MDF_Value_1_txt__c, Core_MDF_Value_2_txt__c,Cap_Type__c, Core_MDF_Channel_Program_Name__c, Core_MDF_Active_ind__c FROM Core_MDF_CCP_Activity_Budget_Cap_Window__mdt WHERE Core_MDF_Active_ind__c=:active]; 
                                                                                     
                                                                                     
                                                                                    
                                                                                    
                        
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
                pfrQuery = pfrQuery + ' FROM PartnerFundRequest WHERE BudgetId IN: budgetIdSet LIMIT 50000';
                
                List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
                pfrList = Database.query(pfrQuery);
                
                //Check whether budget Cap is available or not        
                Boolean isBudgetCapAvailable = false;
                Map<String,Core_MDF_Budget_Cap__c> budgetIdCapTypeWithRamainingAmount = new Map<String,Core_MDF_Budget_Cap__c>();
                Map<String,Decimal> budgetIdCapTypeWithClaimedAmount = new Map<String,Decimal>();
                for(Core_MDF_Budget_Cap__c budgetCap : [SELECT Id,Core_MDF_Cap_Type_nm__c,Core_MDF_Remaining_Cap_amt__c,Core_MDF_Budget_Name_id__c,
                                                    Core_MDF_Claimed_Cap_amt__c,Core_MDF_Approved_Cap_amt__c,Core_MDF_Cap_Status_nm__c FROM Core_MDF_Budget_Cap__c WHERE Core_MDF_Budget_Name_id__c IN : budgetIdSet]){
                    isBudgetCapAvailable = true;
                    budgetIdCapTypeWithRamainingAmount.put(budgetCap.Core_MDF_Budget_Name_id__c+'#'+budgetCap.Core_MDF_Cap_Type_nm__c,
                                                        budgetCap);  
                    budgetIdCapTypeWithClaimedAmount.put(budgetCap.Core_MDF_Budget_Name_id__c+'#'+budgetCap.Core_MDF_Cap_Type_nm__c,budgetCap.Core_MDF_Claimed_Cap_amt__c);                                             
                }
                        
                //Return if budget Cap is not Available
                if(!isBudgetCapAvailable){
                    return;
                }
                                             
                //Determine Activities          
                Boolean isCriteriaMatched = false;          
                Schema.DescribeSObjectResult dsr = Schema.SObjectType.PartnerFundRequest;
                Schema.DescribeFieldResult sObjField;
                Map<Id,set<String>> pfrIdWithCapType = new Map<Id,set<String>>(); 
                Map<Id,String> pfrIdWithBudgetId = new Map<Id,String>();
                
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
                                prfIdSet.add(pfr.Id);   
                                //pfrIdWithCapType.put(pfr.Id,mdt.Cap_Type__c);
                                pfrIdWithBudgetId.put(pfr.Id,pfr.BudgetId);
                                
                                //US633341 - Enabling Multiple Budget Cap Functionality
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
                Map<Id,Core_MDF_Budget_Cap__c> budgetCapToBeUpdatedMap = new Map<Id,Core_MDF_Budget_Cap__c>();
                
                //Validation Begins
                for(PartnerFundClaim pfc: newClaimList){
    
                    List<String> capTypes = new List<String>(pfrIdWithCapType.get(pfc.RequestId));
                    
                    for(string captype: capTypes){
                        if(pfrIdWithCapType.containsKey(pfc.RequestId) && pfrIdWithCapType.get(pfc.RequestId) != null &&
                            pfrIdWithBudgetId.containsKey(pfc.RequestId) && pfrIdWithBudgetId.get(pfc.RequestId) != null &&            
                            budgetIdCapTypeWithRamainingAmount.containsKey(pfrIdWithBudgetId.get(pfc.RequestId)+'#'+captype) &&
                            budgetIdCapTypeWithRamainingAmount.get(pfrIdWithBudgetId.get(pfc.RequestId)+'#'+captype) != null){
                                Decimal totalClaimedAmount = budgetIdCapTypeWithClaimedAmount.get(pfrIdWithBudgetId.get(pfc.RequestId)+'#'+captype);
                                    if( totalClaimedAmount + pfc.Amount > 
                                        budgetIdCapTypeWithRamainingAmount.get(pfrIdWithBudgetId.get(pfc.RequestId)+'#'+captype).Core_MDF_Approved_Cap_amt__c && budgetIdCapTypeWithRamainingAmount.get(pfrIdWithBudgetId.get(pfc.RequestId)+'#'+captype).Core_MDF_Cap_Status_nm__c =='Approved'){ 
                                            pfc.addError(Label.Core_MDF_ClaimExceedsCapRemainder_ErrorMsg);               
                                    }
                                    else{
                                        //Handling Multiple Budget Cap
                                        pfc.Core_MDF_Cap_Type_nm__c = pfc.Core_MDF_Cap_Type_nm__c==null?captype : pfc.Core_MDF_Cap_Type_nm__c + ';' + captype;
                                        Id budgetCapId = budgetIdCapTypeWithRamainingAmount.get(pfrIdWithBudgetId.get(pfc.RequestId)+'#'+captype).Id;
                                        totalClaimedAmount = totalClaimedAmount + pfc.Amount;
                                        budgetIdCapTypeWithClaimedAmount.put(pfrIdWithBudgetId.get(pfc.RequestId)+'#'+captype,totalClaimedAmount);
                                            
                                        Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
                                        budgetCap.Id = budgetCapId;
                                        budgetCap.Core_MDF_Claimed_Cap_amt__c = totalClaimedAmount; 
                                        budgetCapToBeUpdatedMap.put(budgetCapId,budgetCap);
                                    }
                            }
                        }
                    }
                    
                    //Update Budget Cap
                    if(budgetCapToBeUpdatedMap.size()>0){
                        Database.update(budgetCapToBeUpdatedMap.values());
                    }
                }
                catch(Exception e){
                    String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,'Exception occured in checkBudgetAvailabiltyOnClaimInsert method');
                }           
        }
        
    /****************************************************************************************************************************************
        Method Name:                                             checkBudgetAvailabiltyOnClaimUpdate
        @return  :                                               return null.
        @parameters:                                             Claim oldMap and Claim newMap
        Description:                                             Prevents the claim update if claimed amount exceeds the remaining budget cap
        Added By:                                                Accenture – Shridhar K  -  5/09/2019
        Modified By:                  Date:                      Changes: 
        Accenture – Shridhar K        5/09/2019                 Created.
    *****************************************************************************************************************************************/ 
        public static void checkBudgetAvailabiltyOnClaimUpdate(Map<Id,PartnerFundClaim> newClaimMap, Map<Id,PartnerFundClaim> oldClaimMap ){
            try{
                Set<Id> budgetIdSet = new Set<Id>();
                Set<Id> excludeClaimSet = new Set<Id>();
                Map<String, Decimal> budgetCapTypeClaimedAmount = new Map<String, Decimal>();
                List<PartnerFundClaim> claimsToBeProcessed = new List<PartnerFundClaim> ();
                
                List<String> claimStatusToBeExcluded = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStatusToBeExcludForBudCap').split(',');
                                        
                for(PartnerFundClaim pfc: newClaimMap.values()){
                    if((pfc.Amount != oldClaimMap.get(pfc.Id).Amount || pfc.Core_MDF_Status__c != oldClaimMap.get(pfc.Id).Core_MDF_Status__c) 
                        && pfc.BudgetId != null && pfc.Core_MDF_Cap_Type_nm__c != null){
                        budgetIdSet.add(pfc.BudgetId);
                        claimsToBeProcessed.add(pfc);
                        if(claimStatusToBeExcluded.contains(pfc.Core_MDF_Status__c) && !claimStatusToBeExcluded.contains(oldClaimMap.get(pfc.Id).Core_MDF_Status__c)){
                            excludeClaimSet.add(pfc.Id);
                        }            
                    }
                }
                
                if(claimsToBeProcessed.size()<1){
                    return;
                }
                
                //Check whether budget Cap is available or not        
                Boolean isBudgetCapAvailable = false;
                Map<String,Core_MDF_Budget_Cap__c> budgetIdCapTypeWithBudgetCap = new Map<String,Core_MDF_Budget_Cap__c>();
                for(Core_MDF_Budget_Cap__c budgetCap : [SELECT Id,Core_MDF_Cap_Type_nm__c,Core_MDF_Remaining_Cap_amt__c,Core_MDF_Budget_Name_id__c,
                                                        Core_MDF_Approved_Cap_amt__c,Core_MDF_Claimed_Cap_amt__c, Core_MDF_Cap_Status_nm__c FROM Core_MDF_Budget_Cap__c WHERE Core_MDF_Budget_Name_id__c IN : budgetIdSet]){
                    isBudgetCapAvailable = true;
                    budgetIdCapTypeWithBudgetCap.put(budgetCap.Core_MDF_Budget_Name_id__c+'#'+budgetCap.Core_MDF_Cap_Type_nm__c,budgetCap);           
                    budgetCapTypeClaimedAmount.put(budgetCap.Core_MDF_Budget_Name_id__c+'#'+budgetCap.Core_MDF_Cap_Type_nm__c,budgetCap.Core_MDF_Claimed_Cap_amt__c );           
                }
                        
                //Return if budget Cap is not Available
                if(!isBudgetCapAvailable){
                    return;
                }       
                            
                //Validation Begins 
                Map<Id,Core_MDF_Budget_Cap__c> budgetCapToBeUpdatedMap = new Map<Id,Core_MDF_Budget_Cap__c>();
                
                for(PartnerFundClaim pfc: claimsToBeProcessed){
                    //Handling Multiple Budget Cap
                    String pfcCapType = pfc.Core_MDF_Cap_Type_nm__c;
                    List<string> capTypes = pfcCapType.split(';');
                    
                    for(string capType: capTypes){
                        if(budgetCapTypeClaimedAmount.containsKey(pfc.BudgetId+'#'+capType) &&
                        budgetCapTypeClaimedAmount.get(pfc.BudgetId+'#'+capType) != null){
                        Decimal totalClaimedAmount = budgetCapTypeClaimedAmount.get(pfc.BudgetId+'#'+capType);
                        
                            if(excludeClaimSet.contains(pfc.Id)){
                                //Reduce the Cancelled/Denied/Adjusted amount from total claimed amount
                                //DE76638: Not updating the Budget Cap Claimed Amount when Claim is Denied since pfc.Amount - 0
                                totalClaimedAmount = totalClaimedAmount - oldClaimMap.get(pfc.Id).Amount;
                                budgetCapTypeClaimedAmount.put(pfc.BudgetId+'#'+capType,totalClaimedAmount);
                                budgetCapTypeClaimedAmount.put(pfc.BudgetId+'#'+capType,totalClaimedAmount);
                                Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
                                budgetCap.Id = budgetIdCapTypeWithBudgetCap.get(pfc.BudgetId+'#'+capType).Id;
                                budgetCap.Core_MDF_Claimed_Cap_amt__c = totalClaimedAmount;
                                budgetCapToBeUpdatedMap.put(budgetCap.Id,budgetCap);                                                
                            }
                            else{                   
                                //Compare approved cap amount with sum of all claimed amount
                                totalClaimedAmount = totalClaimedAmount + (pfc.Amount - oldClaimMap.get(pfc.Id).Amount);
        
                                    if(totalClaimedAmount > budgetIdCapTypeWithBudgetCap.get(pfc.BudgetId+'#'+capType).Core_MDF_Approved_Cap_amt__c && budgetIdCapTypeWithBudgetCap.get(pfc.BudgetId+'#'+capType).Core_MDF_Cap_Status_nm__c =='Approved'){
                                        pfc.addError(Label.Core_MDF_ClaimExceedsCapRemainder_ErrorMsg);
                                    }
                                    else{
                                        budgetCapTypeClaimedAmount.put(pfc.BudgetId+'#'+capType,totalClaimedAmount);
                                        Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
                                        budgetCap.Id = budgetIdCapTypeWithBudgetCap.get(pfc.BudgetId+'#'+capType).Id;
                                        budgetCap.Core_MDF_Claimed_Cap_amt__c = totalClaimedAmount; 
                                        budgetCapToBeUpdatedMap.put(budgetCap.Id,budgetCap);                                
                                    }
                            }                                        
                            }
                        }                                     
                    }
                //Update Budget Cap with new claimed amount
                if(budgetCapToBeUpdatedMap.size()>0){
                    Database.update(budgetCapToBeUpdatedMap.values());
                }   
            }
            catch(Exception e){
                String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,'Exception occured in checkBudgetAvailabiltyOnClaimUpdate method');
            }       
        }   
                
        
    /****************************************************************************************************************************************
        Method Name:                                             isCriteriaMatching
        @return  :                                               return boolean.
        @parameters:                                             recordValue, Operator, Value and fieldType
        Description:                                             Compares fieldValue with criteria rule value based on criteria operator.
        Added By:                                                Accenture – Shridhar K  -  08/06/2018
        Modified By:                  Date:                      Changes: 
        Accenture – Shridhar K        08/06/2018                 Created.
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
            //Returning false if user selects inappropriate operator 
            return false;
        }          
    }