/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_BudgetCap 
* Version     : 1.0 
* Created Date: 05-09-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar K        5/09/2019                    Created Core_MDF_ProcessCCP_BudgetCap class to throw error if Request Cap Amount is
                                                             less than Claimed Cap Amount
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
                if((isInsert || (isUpdate && (budgetCap.Core_MDF_Requested_Cap_amt__c != budgetCapOldMap.get(budgetCap.Id).Core_MDF_Requested_Cap_amt__c)))&&
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
            List<Core_MDF_CCP_Activity_Budget_Cap_Window__mdt> metadataList = [SELECT Core_MDF_Field_Name_1_txt__c, Core_MDF_Field_Name_2_txt__c, Core_MDF_Field_Name_3_txt__c,
                                                                                Core_MDF_Field_Name_4_txt__c, Core_MDF_Field_Name_5_txt__c, Core_MDF_Field_Name_6_txt__c, Core_MDF_Field_Name_7_txt__c,
                                                                                Core_MDF_Field_Name_8_txt__c, Core_MDF_Field_Name_9_txt__c, Core_MDF_Field_Name_10_txt__c, Core_MDF_Operator_1_nm__c, Core_MDF_Operator_2_nm__c,
                                                                                Core_MDF_Operator_3_nm__c, Core_MDF_Operator_4_nm__c, Core_MDF_Operator_5_nm__c, Core_MDF_Operator_6_nm__c, Core_MDF_Operator_7_nm__c,
                                                                                Core_MDF_Operator_8_nm__c, Core_MDF_Operator_9_nm__c, Core_MDF_Operator_10_nm__c, Core_MDF_Value_1_txt__c, Core_MDF_Value_2_txt__c, 
                                                                                Core_MDF_Value_3_txt__c, Core_MDF_Value_4_txt__c, Core_MDF_Value_5_txt__c, Core_MDF_Value_6_txt__c, Core_MDF_Value_7_txt__c, Core_MDF_Value_8_txt__c,
                                                                                Core_MDF_Value_9_txt__c, Core_MDF_Value_10_txt__c, Cap_Type__c, Core_MDF_Channel_Program_Name__c, Core_MDF_Active_ind__c FROM Core_MDF_CCP_Activity_Budget_Cap_Window__mdt WHERE Core_MDF_Active_ind__c=:active]; 
                                                                                
            
            
            //Construct Activity Query
            Set<String> activitFieldSet = new Set<String>();
            Map<String, List<Core_MDF_CCP_Activity_Budget_Cap_Window__mdt>> programSpecificMDT = new Map<String, List<Core_MDF_CCP_Activity_Budget_Cap_Window__mdt>>();
            for(Core_MDF_CCP_Activity_Budget_Cap_Window__mdt mdt :metadataList){
                
                activitFieldSet.add(mdt.Core_MDF_Field_Name_1_txt__c);
                if(mdt.Core_MDF_Field_Name_2_txt__c != null){
                    activitFieldSet.add(mdt.Core_MDF_Field_Name_2_txt__c);
                }
                if(mdt.Core_MDF_Field_Name_3_txt__c != null){
                    activitFieldSet.add(mdt.Core_MDF_Field_Name_3_txt__c);
                }
                if(mdt.Core_MDF_Field_Name_4_txt__c != null){
                    activitFieldSet.add(mdt.Core_MDF_Field_Name_4_txt__c);
                }
                if(mdt.Core_MDF_Field_Name_5_txt__c != null){
                    activitFieldSet.add(mdt.Core_MDF_Field_Name_5_txt__c);
                }
                if(mdt.Core_MDF_Field_Name_6_txt__c != null){
                    activitFieldSet.add(mdt.Core_MDF_Field_Name_6_txt__c);
                }
                if(mdt.Core_MDF_Field_Name_7_txt__c != null){
                    activitFieldSet.add(mdt.Core_MDF_Field_Name_7_txt__c);
                }
                if(mdt.Core_MDF_Field_Name_8_txt__c != null){
                    activitFieldSet.add(mdt.Core_MDF_Field_Name_8_txt__c);
                }
                if(mdt.Core_MDF_Field_Name_9_txt__c != null){
                    activitFieldSet.add(mdt.Core_MDF_Field_Name_9_txt__c);
                }
                if(mdt.Core_MDF_Field_Name_10_txt__c != null){
                    activitFieldSet.add(mdt.Core_MDF_Field_Name_10_txt__c);
                }
				System.debug('activitFieldSet:' +activitFieldSet);
                if(programSpecificMDT.containsKey(mdt.Core_MDF_Channel_Program_Name__c)){
                    programSpecificMDT.get(mdt.Core_MDF_Channel_Program_Name__c).add(mdt);
                }else{
                    List<Core_MDF_CCP_Activity_Budget_Cap_Window__mdt> tempMDT = new List<Core_MDF_CCP_Activity_Budget_Cap_Window__mdt>();
                    tempMDT.add(mdt);
                    programSpecificMDT.put(mdt.Core_MDF_Channel_Program_Name__c,tempMDT);
                }
            }
            
            System.debug('programSpecificMDT: '+programSpecificMDT);
            String pfrQuery = 'SELECT Id, BudgetId, Campaign.Core_MDF_Program__c';
            for(String fieldName : activitFieldSet){
                pfrQuery = pfrQuery +', ' + fieldName;
            }
            pfrQuery = pfrQuery + ' FROM PartnerFundRequest WHERE BudgetId IN: budgetIdList LIMIT 50000';
            System.debug('pfrQuery: '+pfrQuery);
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            pfrList = Database.query(pfrQuery);
            
            Map<String, List<Id>> budgetCapTypeWithActivity = new Map<String, List<Id>>();          
            
            //Determine Activities          
            Boolean isCriteriaMatched = false;          
            Schema.DescribeSObjectResult dsr = Schema.SObjectType.PartnerFundRequest;
            Schema.DescribeFieldResult sObjField;
            Set<Id> prfIdSet = new Set<Id>();
            Map<Id,String> pfrIdWithCapType = new Map<Id,String>(); 
            
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
                        
                        //Criteria 3 Validation                     
                        if(isCriteriaMatched && mdt.Core_MDF_Field_Name_3_txt__c != null){
                            sObjField = dsr.fields.getMap().get(mdt.Core_MDF_Field_Name_3_txt__c).getDescribe();
                            isCriteriaMatched = isCriteriaMatching(String.valueOf(sObj.get(mdt.Core_MDF_Field_Name_3_txt__c)),mdt.Core_MDF_Value_3_txt__c,mdt.Core_MDF_Operator_3_nm__c,string.valueOf(sObjField.getType()));                               
                        }

                        //Criteria 4 Validation                     
                        if(isCriteriaMatched && mdt.Core_MDF_Field_Name_4_txt__c != null){
                            sObjField = dsr.fields.getMap().get(mdt.Core_MDF_Field_Name_4_txt__c).getDescribe();
                            isCriteriaMatched = isCriteriaMatching(String.valueOf(sObj.get(mdt.Core_MDF_Field_Name_4_txt__c)),mdt.Core_MDF_Value_4_txt__c,mdt.Core_MDF_Operator_4_nm__c,string.valueOf(sObjField.getType()));                         
                        }

                        //Criteria 5 Validation                     
                        if(isCriteriaMatched && mdt.Core_MDF_Field_Name_5_txt__c != null){
                            sObjField = dsr.fields.getMap().get(mdt.Core_MDF_Field_Name_5_txt__c).getDescribe();
                            isCriteriaMatched = isCriteriaMatching(String.valueOf(sObj.get(mdt.Core_MDF_Field_Name_5_txt__c)),mdt.Core_MDF_Value_5_txt__c,mdt.Core_MDF_Operator_5_nm__c,string.valueOf(sObjField.getType()));                         
                        }

                        //Criteria 6 Validation                     
                        if(isCriteriaMatched && mdt.Core_MDF_Field_Name_6_txt__c != null){
                            sObjField = dsr.fields.getMap().get(mdt.Core_MDF_Field_Name_6_txt__c).getDescribe();
                            isCriteriaMatched = isCriteriaMatching(String.valueOf(sObj.get(mdt.Core_MDF_Field_Name_6_txt__c)),mdt.Core_MDF_Value_6_txt__c,mdt.Core_MDF_Operator_6_nm__c,string.valueOf(sObjField.getType()));                                
                        }

                        //Criteria 7 Validation                     
                        if(isCriteriaMatched && mdt.Core_MDF_Field_Name_7_txt__c != null){
                            sObjField = dsr.fields.getMap().get(mdt.Core_MDF_Field_Name_7_txt__c).getDescribe();
                            isCriteriaMatched = isCriteriaMatching(String.valueOf(sObj.get(mdt.Core_MDF_Field_Name_7_txt__c)),mdt.Core_MDF_Value_7_txt__c,mdt.Core_MDF_Operator_7_nm__c,string.valueOf(sObjField.getType()));                          
                        }

                        //Criteria 8 Validation                     
                        if(isCriteriaMatched && mdt.Core_MDF_Field_Name_8_txt__c != null){
                            sObjField = dsr.fields.getMap().get(mdt.Core_MDF_Field_Name_8_txt__c).getDescribe();
                            isCriteriaMatched = isCriteriaMatching(String.valueOf(sObj.get(mdt.Core_MDF_Field_Name_8_txt__c)),mdt.Core_MDF_Value_8_txt__c,mdt.Core_MDF_Operator_8_nm__c,string.valueOf(sObjField.getType()));                           
                        }   

                        //Criteria 9 Validation                     
                        if(isCriteriaMatched && mdt.Core_MDF_Field_Name_9_txt__c != null){
                            sObjField = dsr.fields.getMap().get(mdt.Core_MDF_Field_Name_9_txt__c).getDescribe();
                            isCriteriaMatched = isCriteriaMatching(String.valueOf(sObj.get(mdt.Core_MDF_Field_Name_9_txt__c)),mdt.Core_MDF_Value_9_txt__c,mdt.Core_MDF_Operator_9_nm__c,string.valueOf(sObjField.getType()));                           
                        }
						System.debug('isCriteriaMatched9 :' + isCriteriaMatched);
                        
                        //Criteria 10 Validation                        
                        if(isCriteriaMatched && mdt.Core_MDF_Field_Name_10_txt__c != null){
                            sObjField = dsr.fields.getMap().get(mdt.Core_MDF_Field_Name_10_txt__c).getDescribe();
                            isCriteriaMatched = isCriteriaMatching(String.valueOf(sObj.get(mdt.Core_MDF_Field_Name_10_txt__c)),mdt.Core_MDF_Value_10_txt__c,mdt.Core_MDF_Operator_10_nm__c,string.valueOf(sObjField.getType()));                          
                        }
						System.debug('isCriteriaMatched10 :' + isCriteriaMatched);
                        
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
                            pfrIdWithCapType.put(pfr.Id,mdt.Cap_Type__c);                           
                            break; //Skipping Remaing meta data 
                        }                       

                    }
                }
            }
            
            System.debug('budgetCapTypeWithActivity: '+budgetCapTypeWithActivity);
            System.debug('budgetCapTypeWitt KeySet '+budgetCapTypeWithActivity.keySet());
            
            //Collect All the Claims associated the with budgtes
            Map<Id,Decimal> pfrIdWithAmountSum = new Map<Id,Decimal>();
            
            List<String> claimStatusToBeExcluded = Label.Core_MDF_ClaimStatusToBeExcludedForBudgetCap.split(',');
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
                System.debug('con: '+budgetCap.Core_MDF_Budget_Name_id__c+'#'+budgetCap.Core_MDF_Cap_Type_nm__c);
                System.debug(budgetCapTypeWithActivity.containsKey(budgetCap.Core_MDF_Budget_Name_id__c+'#'+budgetCap.Core_MDF_Cap_Type_nm__c));
                if(budgetCapTypeWithActivity.containsKey(budgetCap.Core_MDF_Budget_Name_id__c+'#'+budgetCap.Core_MDF_Cap_Type_nm__c)){
                    for(Id pfrId: budgetCapTypeWithActivity.get(budgetCap.Core_MDF_Budget_Name_id__c+'#'+budgetCap.Core_MDF_Cap_Type_nm__c)){                       
                        if(pfrIdWithAmountSum.containsKey(pfrId)){
                            sumofClaimAmount = sumofClaimAmount + pfrIdWithAmountSum.get(pfrId);
                        }                       
                    }
                }
                budgetCap.Core_MDF_Claimed_Cap_amt__c = sumofClaimAmount;
                System.debug('sumofClaimAmount: '+sumofClaimAmount);
                System.debug('budgetCap.Core_MDF_Requested_Cap_amt__c: '+budgetCap.Core_MDF_Requested_Cap_amt__c);
                System.debug('pfrIdWithCapType: '+pfrIdWithCapType);
                
                if(sumofClaimAmount > budgetCap.Core_MDF_Requested_Cap_amt__c){
                    budgetCap.addError(Label.Core_MDF_Requested_Cap_Amount_ErrorMsg+' '+sumofClaimAmount );
                }               
            }

            //Update Claims
            List<PartnerFundClaim> toBeUpdatedClaimList = new List<PartnerFundClaim>();
            for(PartnerFundClaim pfc: pfcList){
                if(pfrIdWithCapType.containsKey(pfc.RequestId) && pfrIdWithCapType.get(pfc.RequestId) != null && 
                pfc.Core_MDF_Cap_Type_nm__c != pfrIdWithCapType.get(pfc.RequestId)){
                    pfc.Core_MDF_Cap_Type_nm__c = pfrIdWithCapType.get(pfc.RequestId);
                    toBeUpdatedClaimList.add(pfc);
                }
            }
            System.debug('toBeUpdatedClaimList: '+toBeUpdatedClaimList);
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
                System.debug('mainString:'+mainString);             
                for(String str: recValue.toLowerCase().split(';')){  
                    System.debug('str.toLowerCase():'+str.toLowerCase());
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
            System.debug('ex.getMessage(): '+ex.getMessage());
        }  
    }     
                   
}