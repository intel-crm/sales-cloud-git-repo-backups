/*
* Class Name        : Core_MDF_Exception_TriggerServiceHandler
* Created Date      : 19-06-2019
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture SS        19-06-2019          Exception Trigger Service Handler which handles the sharing of the Exception with appropriate users
Accenture Bharath   05-10-2020          US623829 - Added new method to Update Approver Comments
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Exception_TriggerServiceHandler {
    public class CustomException extends Exception{}
    
    static Boolean flag = false;
    public static Map<Id,List<string>> accIdToPartnerTypeMap = new Map<Id,List<string>>();
    public static Map<Id,List<Core_MDF_Exception__c>> ultimateAccountIdToExceptionMap = new Map<Id,List<Core_MDF_Exception__c>>();
    static final String STR_WW ='WW';
    static final String STR_AllAccount_Yes ='Yes';
    static final String STR_AllAccount_No ='No';
    static final String IPA_RecordType ='Core_MDF_Intel_Partner_Alliance';
    static final String Datacenter_Program = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_DCF');
    static final String Client_Program = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_CCF');
    static final String IPA_Program ='Intel Partner Alliance';
    static final String EXCEPTION_PENDING_REVIEW_STATUS = 'Pending Review'; 
    static final Integer BATCH_LIMIT = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExceptionBulkDMLSync_Limit')); 
    static final Integer EXCEPTION_SHARE_INSERT_BATCH_LIMIT = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExceptionShareInsert_BatchLimit'));
    static final Integer EXCEPTION_SHARE_DEL_BATCH_LIMIT = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExceptionShareDel_BatchLimit'));
    static Boolean isCSCUser = FeatureManagement.checkPermission('Core_MDF_Internal_CSC_User');  
    /****************************************************************************************************************************************
* Method Name           : shareExceptionRecordsWithUsersForUpdate
* Created Date          : 19-06-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture SS         19-06-2019          Exception Trigger Service Handler method for update scenario which handles setting the flag to true
*****************************************************************************************************************************************/
    public static void shareExceptionRecordsWithUsersForUpdate(Map <Id , Core_MDF_Exception__c> newExceptionMap,  Map <Id , Core_MDF_Exception__c> excpOldMap){
        Map<Id, Core_MDF_Exception__c> excpNewMap = new  Map<Id, Core_MDF_Exception__c>();
        Map<Id, Core_MDF_Exception__c> excpAllAccNewMap = new  Map<Id, Core_MDF_Exception__c>();
        flag = true;
        try{
            for(Core_MDF_Exception__c excpOnUpdate : newExceptionMap.Values()){
                if(excpOnUpdate.Core_MDF_Select_All_Accounts_ind__c == false &&
                   (excpOnUpdate.Core_MDF_Budget_Type_nm__c != excpOldMap.get(excpOnUpdate.id).Core_MDF_Budget_Type_nm__c
                   || excpOnUpdate.Core_MDF_Country_Region_nm__c != excpOldMap.get(excpOnUpdate.id).Core_MDF_Country_Region_nm__c 
                   || excpOnUpdate.OwnerId != excpOldMap.get(excpOnUpdate.id).OwnerId 
                   || excpOnUpdate.Core_MDF_Select_All_Country_ind__c != excpOldMap.get(excpOnUpdate.id).Core_MDF_Select_All_Country_ind__c))
                   {
                       excpNewMap.put(excpOnUpdate.id,excpOnUpdate);
                   }else if(excpOnUpdate.Core_MDF_Select_All_Accounts_ind__c == true &&
                   (excpOnUpdate.Core_MDF_Budget_Type_nm__c != excpOldMap.get(excpOnUpdate.id).Core_MDF_Budget_Type_nm__c
                   || excpOnUpdate.Core_MDF_Select_All_Accounts_ind__c != excpOldMap.get(excpOnUpdate.id).Core_MDF_Select_All_Accounts_ind__c
                   || excpOnUpdate.Core_MDF_Country_Region_nm__c != excpOldMap.get(excpOnUpdate.id).Core_MDF_Country_Region_nm__c 
                   || excpOnUpdate.OwnerId != excpOldMap.get(excpOnUpdate.id).OwnerId 
                   || excpOnUpdate.Core_MDF_Select_All_Country_ind__c != excpOldMap.get(excpOnUpdate.id).Core_MDF_Select_All_Country_ind__c)){
                       excpAllAccNewMap.put(excpOnUpdate.id,excpOnUpdate);
                   }
            }
            List<Core_MDF_Exception__Share> exceptionShareList = new List<Core_MDF_Exception__Share>();
            List<Core_MDF_Exception_Account_Mapping__Share> exceptionAccMapShareList = new List<Core_MDF_Exception_Account_Mapping__Share>();
            if((excpNewMap != null && !excpNewMap.isEmpty()) || (excpAllAccNewMap != null && !excpAllAccNewMap.isEmpty())){
                for(Core_MDF_Exception__Share exceptionShareRecord : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                                      FROM Core_MDF_Exception__Share
                                                                      WHERE (ParentId IN :excpNewMap.keySet() OR ParentId in :excpAllAccNewMap.keySet()) AND  
                                                                      RowCause =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RowCause_Manual')]){
                                                                          exceptionShareList.add(exceptionShareRecord);
                                                                      }
            }
            if((excpAllAccNewMap != null && !excpAllAccNewMap.isEmpty())){
                for(Core_MDF_Exception_Account_Mapping__Share exceptionAccMapShareRecord : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                                      FROM Core_MDF_Exception_Account_Mapping__Share
                                                                      WHERE Parent.Core_MDF_Exception_id__c IN :excpNewMap.keySet()AND
                                                                      RowCause =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RowCause_Manual')]){
                                                                          exceptionAccMapShareList.add(exceptionAccMapShareRecord);
                                                                      }
            }
            
            if(exceptionShareList != NULL && !exceptionShareList.isEmpty()){
                Core_MDF_Expt_AccMap_ServiceHandler.deleteShareRecord(exceptionShareList);
            }
            
             if(exceptionAccMapShareList != NULL && !exceptionAccMapShareList.isEmpty()){
                Core_MDF_Expt_AccMap_ServiceHandler.deleteShareRecord(exceptionAccMapShareList);
            }
            
            Map<Id,Core_MDF_Exception_Account_Mapping__c> newMapEAM = new Map<Id,Core_MDF_Exception_Account_Mapping__c>(
                                                                      [SELECT Id,Core_MDF_Country_Region_txt__c,Core_MDF_Account_id__c,Core_MDF_Program_txt__c,Core_MDF_HostRegion_txt__c,Core_MDF_Budget_Type_txt__c,Core_MDF_Exception_id__c,Core_MDF_Exception_Status_txt__c,Core_MDF_Select_All_Accounts_ind__c,Core_MDF_Select_All_Country_ind__c
                                                                       FROM Core_MDF_Exception_Account_Mapping__c 
                                                                       WHERE Core_MDF_Exception_id__c IN: excpNewMap.keySet()]);
            
            if(newMapEAM!= null && !newMapEAM.isEmpty()){
                Core_MDF_Expt_AccMap_ServiceHandler.shareEAM(newMapEAM);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
                           throw new CustomException(system.label.Core_MDF_ApplicationErrorMessage);}
    }

    /*****************************************************************************************************
Method Name:        isExceptionReviewer
@return  :          Boolean
@parameters:
Description:        This method is used to check if the "Exception Reviewer" Custom permission is assigned to the User
Added By:           Accenture SB
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static Boolean isExceptionReviewer(){
        return isCustomPermissionAssigned('Core_MDF_ExceptionReviewer');
    }
    
    /*****************************************************************************************************
Method Name:        isCustomPermissionAssigned
@return  :          Boolean
@parameters:        String - Custom Permission Name
Description:        This method is used to check if the Custom permission is assigned to the User
Added By:           Accenture SB
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static Boolean isCustomPermissionAssigned(String customPermissionNameStr){
        if(customPermissionNameStr != NULL && String.isNotBlank(customPermissionNameStr)){
            return FeatureManagement.checkPermission(customPermissionNameStr);
        }
        else{
            return false;
        }
    }
    
    
    
    
    /****************************************************************************************************************************************
* Method Name           : updateExceptionApproverComments
* Created Date          : 05-10-2020
* @return               : void
* @parameters           : exceptionList - List of all the Exception Records when status is updated to Approved/Denied
* Modification Log
* Developer             Date                Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture-Bharath         05-10-2020      US623829 - To Update all the Approvers comments in the Exception
*****************************************************************************************************************************************/
    
    @InvocableMethod(label='Update Exception Approvers Comment')
    public static void updateExceptionApproverComments(List<Core_MDF_Exception__c> exceptionList){
        Map<Id,Id> excepIdProcessInstId = new Map<Id,Id>();
        Set<Id> exceptionIdSet = new Set<Id>();
        Map<Id,List<ProcessInstanceStep>> piAndListofPiStepMap = new Map<Id,List<ProcessInstanceStep>>();
        List<Core_MDF_Exception__c> toUpdateExceptionRecs = new List<Core_MDF_Exception__c>();
        
        if(exceptionList!= null &&  exceptionList.size() >0){
            for(Core_MDF_Exception__c ex:exceptionList){
                exceptionIdSet.add(ex.Id);
            } 
        }
        if(exceptionIdSet != null && exceptionIdSet.size() > 0){
            for(ProcessInstance pi : [SELECT Id,TargetObjectId FROM ProcessInstance 
                                      WHERE TargetObjectId IN: exceptionIdSet]){
                                          excepIdProcessInstId.put(pi.TargetObjectId, pi.Id);
                                      }
        }
        If(excepIdProcessInstId != null && excepIdProcessInstId.size() > 0){
            for(ProcessInstanceStep piStep : [SELECT Id,ActorId,Actor.Name,StepStatus,ProcessInstanceId,Comments FROM ProcessInstanceStep 
                                              WHERE ProcessInstanceId IN: excepIdProcessInstId.values() ORDER BY CreatedDate ASC]){
                                                  if(piAndListofPiStepMap.containsKey(piStep.ProcessInstanceId) && piStep !=null){
                                                      piAndListofPiStepMap.get(piStep.ProcessInstanceId).add(piStep);
                                                  }else{
                                                      if(piStep != null){
                                                          piAndListofPiStepMap.put(piStep.ProcessInstanceId, new List<ProcessInstanceStep>{piStep});}
                                                  }
                                              }
        }
        if(exceptionList != null && exceptionList.size() >0 && piAndListofPiStepMap != null && piAndListofPiStepMap.size() > 0){
            for(Core_MDF_Exception__c exp : exceptionList){
                if(excepIdProcessInstId.containsKey(exp.Id) && excepIdProcessInstId.get(exp.Id) != NULL){
                    Id processInstanceId = excepIdProcessInstId.get(exp.Id);
                    if(piAndListofPiStepMap.containsKey(processInstanceId) && piAndListofPiStepMap.get(processInstanceId) != NULL){
                        Core_MDF_Exception__c excep = new Core_MDF_Exception__c();
                        excep.Id = exp.Id;
                        String approverComments = '';
                        for(ProcessInstanceStep pistep: piAndListofPiStepMap.get(processInstanceId)){
                            if(String.isBlank(approverComments) && pistep.Comments != null){
                                approverComments = pistep.Actor.Name+' - '+pistep.Comments;
                            }else if(String.isNotBlank(approverComments) && pistep.Comments != null){
                                approverComments = approverComments +'\n'+pistep.Actor.Name+' - '+pistep.Comments;
                            }
                        }
                        excep.Core_MDF_Approver_1_Comments_Txt__c = approverComments;
                        toUpdateExceptionRecs.add(excep);
                    }
                }
            }
            try{
                if(toUpdateExceptionRecs != null && toUpdateExceptionRecs.size() > 0){
                    Update toUpdateExceptionRecs;
                }
            }catch(Exception e){
                Core_MDF_CCP_UtilityClass.logError(e);
            }
        }
    }
    
    //Method to check if Activity Category Type is applicable for selected Budget Type
    public static void checkActCatTypeWithBudgetType(List<Core_MDF_Exception__c> exceptionList, Map<Id,Core_MDF_Exception__c> expOldMap, Boolean isInsert){
        
        List<Core_MDF_Exception__c> expToBeProcessed  = new List<Core_MDF_Exception__c>(); 
        Map<String, String> actCatTypeBTMap = new Map<String, String>();
        Map<String, Set<String>> actCatTypeBTMapVar = new Map<String, Set<String>>();
        String query = 'SELECT Core_MDF_Field_5_txt__c, ' +
                        'Core_MDF_Checkbox_Field_1_Ind__c, ' +
                        'Core_MDF_Is_Active_Ind__c, ' +
                        'Core_MDF_Field_4_txt__c, ' +
                        'Core_MDF_Field_7_txt__c ' +
                        'FROM Core_MDF_CCP_Custom_Metadata_Utility__c ' +
                        'WHERE Core_MDF_Category__c = \'' + String.escapeSingleQuotes(Core_MDF_CCP_ConstantClass.OPAL_CATEGORY) + '\' ' + 
                        'AND Core_MDF_Is_Active_Ind__c = TRUE ' + 
                        'AND Core_MDF_Field_4_txt__c != NULL';


		List<Core_MDF_CCP_Custom_Metadata_Utility__c> customMetadataUtilityRecords = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecordsUsingDynamicQuery(query);
        for(Core_MDF_CCP_Custom_Metadata_Utility__c mtd : customMetadataUtilityRecords)
        /*for(Core_MDF_OPAL_Category_Type_Mapping__mdt mtd: [SELECT Id, Core_MDF_Activity_Category_Type_txt__c, Blue_Activity_Type_ind__c, Green_Activity_Type_ind__c,
                                                           Active_ind__c, Core_MDF_Supported_Budget_Type_1_txt__c, Core_MDF_Supported_Budget_Type_2_txt__c
                                                           FROM Core_MDF_OPAL_Category_Type_Mapping__mdt 
WHERE (Active_ind__c = True AND Core_MDF_Supported_Budget_Type_1_txt__c != NULL)])*/{ 
    String supportedBudgetTypes;
    //supportedBudgetTypes = String.isBlank(mtd.Core_MDF_Supported_Budget_Type_2_txt__c) ? mtd.Core_MDF_Supported_Budget_Type_1_txt__c : mtd.Core_MDF_Supported_Budget_Type_1_txt__c +';'+mtd.Core_MDF_Supported_Budget_Type_2_txt__c;        
    supportedBudgetTypes = String.isBlank(mtd.Core_MDF_Field_7_txt__c) ? mtd.Core_MDF_Field_4_txt__c : mtd.Core_MDF_Field_4_txt__c +';'+mtd.Core_MDF_Field_7_txt__c; 
    actCatTypeBTMap.put(mtd.Core_MDF_Field_5_txt__c, supportedBudgetTypes);
    if(!actCatTypeBTMapVar.containsKey(mtd.Core_MDF_Field_5_txt__c)){
        actCatTypeBTMapVar.put(mtd.Core_MDF_Field_5_txt__c, new Set<String>());
    }
    actCatTypeBTMapVar.get(mtd.Core_MDF_Field_5_txt__c).add(supportedBudgetTypes);
    
}
        //including only OPAL programs 
        for(Core_MDF_Exception__c exp: exceptionList){ 
            if((isInsert || (exp.Core_MDF_Activity_Cate_and_Type_nm__c != expOldMap.get(exp.Id).Core_MDF_Activity_Cate_and_Type_nm__c ||
                             exp.Core_MDF_Budget_Type_nm__c != expOldMap.get(exp.Id).Core_MDF_Budget_Type_nm__c)) && 
                            exp.Core_MDF_Budget_Type_nm__c != NULL && exp.Core_MDF_Activity_Cate_and_Type_nm__c != NULL && 
                            (exp.Core_MDF_Program_nm__c== Client_Program ||  exp.Core_MDF_Program_nm__c== Datacenter_Program)){
                   
                                expToBeProcessed.add(exp);   
               }            
        }
        for(Core_MDF_Exception__c expn: expToBeProcessed){ 
            for(String expActCatType: expn.Core_MDF_Activity_Cate_and_Type_nm__c.split(';')){
                Boolean isActCatTypeApplicable = false;
                String supportedBT = '';
                Set<String> supportedBTSet = new Set<String>();
                supportedBT = actCatTypeBTMap.get(expActCatType);               
                supportedBTSet = actCatTypeBTMapVar.get(expActCatType);
                String budgetString;
                if(supportedBTSet!=null){
                    budgetString = String.join(new List<String>(supportedBTSet), ';');
                }
                for(String expBudgetType: expn.Core_MDF_Budget_Type_nm__c.split(';')){ 
                    if(budgetString !=null && budgetString.contains(expBudgetType)){                 
                        isActCatTypeApplicable = true;
                        break;
                    }
                }
                if(!isActCatTypeApplicable){
                    expn.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CheckActCatTypeWithBudgetType'));
                }
            }                            
        }       
    }

    /****************************************************************************************************************************************
* Metthod Name        : exceptionDataValidation
* Created Date      : 25/7/2023
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture Bishanka         25/7/2023      Method to call validation logic for exception
*****************************************************************************************************************************************/
    public static void exceptionDataValidation(List<Core_MDF_Exception__c> newExceptionList)
    {
        Core_MDF_Exception_Utility.ExceptionUserIUPGMWrapper exptUserIUPGMWrap = Core_MDF_Exception_Utility.getIUPGMDataForExceptionUser();
        //ExceptionDataSetWrapper excpWrapper = prepareDataSetForValidation(newExceptionList);
        
        // Check if any error related to Account or Program or Country associated to user is present on the record or not
        for(Core_MDF_Exception__c expt : newExceptionList)
        {
            if(expt.Core_MDF_Select_All_Accounts_ind__c){
            //validateException(expt, exptUserIUPGMWrap, excpWrapper);
              if(!isExceptionReviewer()){
                    expt.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExceptionSelectAllAccounts_Err'));
               }
            }
        }
    }
    
    
    /****************************************************************************************************************************************
* Metthod Name        : validateActivityCategoryType
* Created Date      : 17/09/2024
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture Ayush         17/09/2024      Method to call validation logic for Activity Category
Modified By - Akash 28/02/2025
*****************************************************************************************************************************************/
    
    public static void validateActivityCategoryType(List<Core_MDF_Exception__c> exceptionList, Map<Id,Core_MDF_Exception__c> expOldMap, Boolean isInsert){
        Set<String> exceptionProgramList = new Set<String>(); 
        List<String> categoryTypeList = new List<String>();
        Set<String> categoryList = new Set<String>();
        List<Core_MDF_Exception__c> filteredExceptionList = new List<Core_MDF_Exception__c>();
        for(Core_MDF_Exception__c exceptionRecord : exceptionList){
            if(expOldMap == null || (expOldMap != null && expOldMap.get(exceptionRecord.Id).Core_MDF_Exception_Start_Date_dt__c != exceptionRecord.Core_MDF_Exception_Start_Date_dt__c 
                                     || expOldMap.get(exceptionRecord.Id).Core_MDF_Activity_Cate_and_Type_nm__c != exceptionRecord.Core_MDF_Activity_Cate_and_Type_nm__c)){
                                         exceptionProgramList.add(exceptionRecord.Core_MDF_Program_nm__c);
                                         filteredExceptionList.add(exceptionRecord);
                                     }
        }
        if(!filteredExceptionList.isEmpty() && !exceptionProgramList.isEmpty()){
            Map<String,List<String>> programToCategoryValuesMap = getNewCategoryValues(exceptionProgramList);
            
            if(programToCategoryValuesMap != null){
                for(Core_MDF_Exception__c exceptionRecord : filteredExceptionList){
                    
                    categoryTypeList.addAll(exceptionRecord.Core_MDF_Activity_Cate_and_Type_nm__c.split(';'));
                    for(String categoryTypeValue : categoryTypeList){
                        categoryList.add(categoryTypeValue.split('->')[0]);
                    }
                    //If start year is greater than or equal to 2025 checking and allowing only 2025 Activity catagory/type.
                    if(exceptionRecord.Core_MDF_Exception_Start_Date_dt__c.year() >= Integer.valueOf(System.label.Core_MDF_NewCategoryDate)){
                        for(String categoryValue : categoryList){
                            if(programToCategoryValuesMap.containsKey(exceptionRecord.Core_MDF_Program_nm__c) && !programToCategoryValuesMap.get(exceptionRecord.Core_MDF_Program_nm__c).contains(categoryValue)){
                                exceptionRecord.addError(System.label.Core_MDF_ExceptionNewCategoryError);
                            }
                        }   
                    }
                    //Commented else part because as per story TWC702-11922 we don't want to restrict user to select Activity catagory/type if start year is 2024.
                    //else{
                        //for(String categoryValue : categoryList){
                            //if(programToCategoryValuesMap.containsKey(exceptionRecord.Core_MDF_Program_nm__c) && !programToCategoryValuesMap.get(exceptionRecord.Core_MDF_Program_nm__c).contains(categoryValue)){
                               // exceptionRecord.addError(System.label.Core_MDF_ExceptionNewCategoryError);
                            //}
                       // }
                    //}
                }  
            }   
        }  
    }
    
    public static Map<String,List<String>> getNewCategoryValues (Set<String> program){
        
        Map<String,List<String>> programToCategoryValuesMap = new Map<String,List<String>>();
        try{
            for(Core_MDF_ActivityCategoryMapping__c categoryMappingRecord : [SELECT Id, Core_MDF_Category_Name_txt__c , Core_MDF_Program_txt__c
                                                                             FROM Core_MDF_ActivityCategoryMapping__c 
                                                                             WHERE Core_MDF_Program_txt__c IN: program
                                                                             AND Core_MDF_Is_Active_Ind__c = TRUE]){
                                                                                 if(!programToCategoryValuesMap.containsKey(categoryMappingRecord.Core_MDF_Program_txt__c)){
                                                                                     programToCategoryValuesMap.put(categoryMappingRecord.Core_MDF_Program_txt__c, new List<String>());
                                                                                 }
                                                                                 programToCategoryValuesMap.get(categoryMappingRecord.Core_MDF_Program_txt__c).add(categoryMappingRecord.Core_MDF_Category_Name_txt__c);
                                                                             }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw e;
        }
        return programToCategoryValuesMap;
    }
    /****************************************************************************************************************************************
* Metthod Name        : prepareAccountTypeForException
* Created Date        : 17/9/2024 
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture Akanksha         17/9/2024      Method to prepare Map of Ultimate Exception AccountId and Partner Type
*****************************************************************************************************************************************/  
    public static void prepareAccountTypeForException(List<Core_MDF_Exception__c> exceptionList,Map<Id,Core_MDF_Exception__c> oldExceptionMap){
        
        String CO_MARKETING_ACCOUNT = Core_MDF_CCP_ConstantClass.CO_MARKETING_ACCOUNT;
        String INTEL_ACCOUNT = Core_MDF_CCP_ConstantClass.INTEL_ACCOUNT;
        
        // Highlight: Unused Local Variable - 14285 - Indira
         // String PRIMARY_PARTNER = Core_MDF_CCP_ConstantClass.PRIMARY_PARTNER;
         // List<Core_MDF_Exception__c> listOfException = new List<Core_MDF_Exception__c>();
        
        
        //Map<Id,List<string>> accIdToPartnerTypeMap = new Map<Id,List<string>>();
        try{
            //US - TWC702-14285: Flatten nested IFs (no logic change) - Original code is commented
            //if(accIdToPartnerTypeMap.isEmpty()){
                //US - TWC702-14285: Flatten nested IFs (no logic change) - Begin
                if(!accIdToPartnerTypeMap.isEmpty()){ 
                    return;
                }
                //US - TWC702-14285: Flatten nested IFs (no logic change) - End
                //iterate on the incoming exception list
                for(Core_MDF_Exception__c itrOnExcep : exceptionList){
                    //compare the program name and check if the exception account is not null
                    if(itrOnExcep.Core_MDF_Program_nm__c == Label.Core_MDF_EEF_RecordType && itrOnExcep.Core_MDF_Account_id__c != NULL && 
                       (oldExceptionMap == NULL || ( oldExceptionMap != NULL && oldExceptionMap.containsKey(itrOnExcep.Id) &&
                                                    itrOnExcep.Core_MDF_Account_id__c != oldExceptionMap.get(itrOnExcep.Id).Core_MDF_Account_id__c))){
                                                        //prepare a map of Exception Account and List of Exceptions
                                                        if(!ultimateAccountIdToExceptionMap.containskey(itrOnExcep.Core_MDF_Account_id__c)){
                                                            ultimateAccountIdToExceptionMap.put(itrOnExcep.Core_MDF_Account_id__c, new List<Core_MDF_Exception__c>{itrOnExcep});
                                                        }else{
                                                            ultimateAccountIdToExceptionMap.get(itrOnExcep.Core_MDF_Account_id__c).add(itrOnExcep);
                                                        }  
                                                    }
                }
                if(!ultimateAccountIdToExceptionMap.isEmpty()){
                    //fetching the virtual corp accounts associated to the exception account.
                    for(Account acc : [SELECT Id,Core_MDF_Partner_Type_nm__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                       FROM Account 
                                       WHERE Core_MDF_CoMarketing_Ultimate_Account__c IN: ultimateAccountIdToExceptionMap.keySet()
                                       AND Core_MDF_Parent_Fund_Account__r.RecordType.Name =: INTEL_ACCOUNT AND RecordType.Name =: CO_MARKETING_ACCOUNT 
                                       AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Name =: Label.Core_MDF_EEF_Program_Name]){
                                           //Check the account is meant for which Partner Type
                                           List<string> partnerTypeList = string.isNotBlank(acc.Core_MDF_Partner_Type_nm__c) ? acc.Core_MDF_Partner_Type_nm__c.split(';') : new List<string>();
                                           //prepare a map of Ultimate account and partner type
                                           accIdToPartnerTypeMap.put(acc.Core_MDF_CoMarketing_Ultimate_Account__c,partnerTypeList);                            
                                       }
                }
          //  }
        }catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        } 
    }
    /****************************************************************************************************************************************
* Metthod Name        : validateSelectedAccount
* Created Date        : 17/9/2024 
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture Akanksha         17/9/2024      Method to call validate accounts on the Exception Record
*****************************************************************************************************************************************/                                          
    public static void validateSelectedAccount(List<Core_MDF_Exception__c> exceptionList,Map<Id,Core_MDF_Exception__c> oldExceptionMap){
        
        Boolean hasPrimaryPermission = FeatureManagement.checkPermission(Core_MDF_CCP_ConstantClass.PRIMARY_PARTNER_CUSTOM_PERMISSION);
        String NO_ACCESS_ERROR_MSG = Core_MDF_CCP_ConstantClass.NO_ACCESS_ERROR_MSG;
        try{
            if(!ultimateAccountIdToExceptionMap.isEmpty() && !accIdToPartnerTypeMap.isEmpty()){
                for(Id accId: ultimateAccountIdToExceptionMap.keySet()){
                    for(Core_MDF_Exception__c excep: ultimateAccountIdToExceptionMap.get(accId)){
                        //accIdToPartnerTypeMap - map being populated in the beforeInsert Trigger.
                        //The Map will store - key as Exception Ultimate AccountId and value as Partner Type
                        if(validateAccount(excep,accIdToPartnerTypeMap,hasPrimaryPermission)){
                            excep.addError(NO_ACCESS_ERROR_MSG);
                        }
                    }
                }
            }
        }catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        
    }
    //method to validate the type of account and the user creating the exception
    public static Boolean validateAccount(Core_MDF_Exception__c excep, Map<Id,List<string>> ultimateAccIdToParterMap, Boolean hasPrimaryPermission){
        
        Boolean isInvalidAccount = false;
        try{
            if(!ultimateAccIdToParterMap.containsKey(excep.Core_MDF_Account_id__c) ||
               (ultimateAccIdToParterMap.containsKey(excep.Core_MDF_Account_id__c) && 
                ultimateAccIdToParterMap.get(excep.Core_MDF_Account_id__c) != NULL && 
                ultimateAccIdToParterMap.get(excep.Core_MDF_Account_id__c).contains(Core_MDF_CCP_ConstantClass.PRIMARY_PARTNER) && !hasPrimaryPermission)){
                    //if the User doesnot have the Primary Account Manager Custom Permission and is trying to add a Primary account on the exception record throw error.
                    isInvalidAccount = true;
                }  
        }catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        
        return isInvalidAccount;
        
    }
       /****************************************************************************************************************************************
* Metthod Name        : shareExceptionRecordsWithExtUsers
* Created Date        : 12/20/2024 
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture Mohit         12/20/2024      Method to share exceptions with external user
*****************************************************************************************************************************************/ 
    public static void shareExceptionRecordsWithExtUsers( Map<Id , Core_MDF_Exception__c> newExceptionMap, Map <Id , Core_MDF_Exception__c> excpOldMap){
        shareExceptionRecordsWithExtUsers(newExceptionMap, excpOldMap, false);
    }

    public static void shareExceptionRecordsWithExtUsers(
        Map<Id, Core_MDF_Exception__c> newExceptionMap,
        Map<Id, Core_MDF_Exception__c> excpOldMap,
        Boolean forceRefresh
    ){
        Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdAccIdExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
        Set<Id> rmfAccIdSet = new Set<Id>();
        Map<Id,Id> accIdGrpIdMap = new Map<Id,Id>();
        List<Core_MDF_Exception_Account_Mapping__c> listRmfExpt = new List<Core_MDF_Exception_Account_Mapping__c>();
        // Highlight: Unused Local Variable - 14285 - Indira 
        // List<Core_MDF_Exception__c> listExptNonRmf = new List<Core_MDF_Exception__c>();
        Set< Core_MDF_Exception__Share > exptShareSet = new Set< Core_MDF_Exception__Share >();
        Set< Core_MDF_Exception_Account_Mapping__Share > exptAccMapShareSet = new Set< Core_MDF_Exception_Account_Mapping__Share >();
        Set<id> exceptionChannelPrgIdsSet = new Set<Id>();
        // Highlight: Unused Local Variable - 14285 - Indira
        // Set<Id> intelAccSet = new Set<Id>();
        Set<Id> intelAccountIdSet = new Set<Id>();
        String CO_MARKETING_ACCOUNT = Core_MDF_CCP_ConstantClass.CO_MARKETING_ACCOUNT;
        Map<Id , Core_MDF_Exception_Account_Mapping__c> eefExceptionMap= new Map<Id , Core_MDF_Exception_Account_Mapping__c>();
        //Set<String> channelPrgIdAccId = new Set<String>();
        //mapOfExpIdToActAccId - map of Exception Id to associcated Activating AccountId
        Map<Id,List<Id>> mapOfExpIdToActAccId = new Map<Id,List<Id>>();
        //mapOfExpIdToPrimaryAccId - map of Exception Id to Associated Primary AccountId
        Map<Id,List<Id>> mapOfExpIdToPrimaryAccId = new Map<Id,List<Id>>();
        //Map of Program Api name to Program Name Label
        Map<String,String> channelProgramNameMap = new Map<String,String>();
        //Map of Exception ID to Exception Account Mapping
        Map<Id, Core_MDF_Exception_Account_Mapping__c> excpNewMap = new  Map<Id, Core_MDF_Exception_Account_Mapping__c>();
        

		Set<Id> ExcId = new Set<Id>();
		for(Core_MDF_Exception__c exc : newExceptionMap.values()){
			ExcId.add(exc.Id);
		}

        Map<Id, Core_MDF_Exception_Account_Mapping__c> EAPMap = new  Map<Id, Core_MDF_Exception_Account_Mapping__c>(
            [Select id,Core_MDF_Account_id__c,Core_MDF_Exception_id__c,Core_MDF_Program_txt__c,Core_MDF_Exception_Status_txt__c,Core_MDF_Select_All_Accounts_ind__c,Core_MDF_Expose_Externally_ind__c,Core_MDF_OwnerId_txt__c,Core_MDF_Active_ind__c from Core_MDF_Exception_Account_Mapping__c where Core_MDF_Exception_id__c IN : ExcId]);

        //Iterating over exceptions newmap for which we have to delete existing share record and create new based on account select
        for(Core_MDF_Exception_Account_Mapping__c excpOnUpdate : EAPMap.values()){
                if(forceRefresh
                   || (excpOnUpdate.Core_MDF_Exception_Status_txt__c == Label.Core_MDF_Exception_Approved_Status && 
                    excpOnUpdate.Core_MDF_Account_id__c != NULL)
                   || (excpOnUpdate.Core_MDF_Select_All_Accounts_ind__c != excpOldMap.get(excpOnUpdate.Core_MDF_Exception_id__c).Core_MDF_Select_All_Accounts_ind__c
                       && excpOnUpdate.Core_MDF_Select_All_Accounts_ind__c == true)
                   || excpOnUpdate.Core_MDF_OwnerId_txt__c != excpOldMap.get(excpOnUpdate.Core_MDF_Exception_id__c).OwnerId 
                   //Akash - Added Or condition to check if checkbox is true and then exception reviewer changes to false so in that case need to hide the record, Exception Enhancements- New Flag to control external exposure
                   || (excpOnUpdate.Core_MDF_Expose_Externally_ind__c == false && (excpOnUpdate.Core_MDF_Expose_Externally_ind__c != excpOldMap.get(excpOnUpdate.Core_MDF_Exception_id__c).Core_MDF_Expose_Externally_ind__c)) 
                   || excpOnUpdate.Core_MDF_Exception_Status_txt__c != Label.Core_MDF_Exception_Approved_Status){
                       excpNewMap.put(excpOnUpdate.Core_MDF_Exception_id__c,excpOnUpdate);   
                   }
        }
        //Getting share record which has to be deleted
        List<Core_MDF_Exception__Share> exceptionShareList = new List<Core_MDF_Exception__Share>();
        List<Core_MDF_Exception_Account_Mapping__Share> exceptionAccMapShareList = new List<Core_MDF_Exception_Account_Mapping__Share>();
        if(excpNewMap != null && !excpNewMap.isEmpty()){
            for(Core_MDF_Exception__Share exceptionShareRecord : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                                  FROM Core_MDF_Exception__Share
                                                                  WHERE ParentId IN :excpNewMap.keySet() AND
                                                                  RowCause = 'Exception_External_Sharing__c']){
                                                                      exceptionShareList.add(exceptionShareRecord);
                                                                  }
            for(Core_MDF_Exception_Account_Mapping__Share exceptionAccMapShareRecord : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                                      FROM Core_MDF_Exception_Account_Mapping__Share
                                                                      WHERE Parent.Core_MDF_Exception_id__c IN: excpNewMap.keySet()  AND
                                                                      RowCause ='Core_MDF_EAM_External_Sharing__c']){
                                                                                          exceptionAccMapShareList.add(exceptionAccMapShareRecord);  
                                                                                        }
        }
        
        if(exceptionShareList != NULL && !exceptionShareList.isEmpty()){
                delete exceptionShareList;
        }
        if(exceptionAccMapShareList != NULL && !exceptionAccMapShareList.isEmpty()){
                delete exceptionAccMapShareList;
        }
        //Avoid using Soql / Sosl queries without filters and limits
       /* for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem : ([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c, Core_MDF_Entitlement_Name__c
                                                                   FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt Limit 5000])){
                                                                       channelProgramNameMap.put(bpem.Core_MDF_Bank_Program_Name__c , bpem.Core_MDF_Channel_Program__c);
                                                                       System.debug('channelProgramNameMap---1290'+ channelProgramNameMap);
                                                                   }*/
        for(Core_MDF_ChannelProgram__mdt bpem : ([SELECT Label, Core_MDF_Bank_Program_Value__c
                                                                   FROM Core_MDF_ChannelProgram__mdt Limit 1000])){
                                                                       channelProgramNameMap.put(bpem.Core_MDF_Bank_Program_Value__c , bpem.Label);
         }//Core_MDF_BankProgram_Entitlement_Mapping__mdt optimization
        
         Map<String,String> channelProgramNameIdMap = new Map<String,String>();
        //Map of Program Name to Channel Program ID
         for (ChannelProgram cpList : [SELECT Id, Name
                                      FROM ChannelProgram
                                      WHERE Name =: channelProgramNameMap.values()
                                      ORDER BY CreatedDate] ){
                                          channelProgramNameIdMap.put( cpList.Name , cpList.Id );
                                      }//core_mdf_client=client,cklient = idclient
        
        //Creating map of eef exception to get activating and primary partner
        for(Core_MDF_Exception_Account_Mapping__c expt: EAPMap.values()){
            if(expt.Core_MDF_Program_txt__c == Label.Core_MDF_EEF_RecordType && expt.Core_MDF_Account_id__c != Null
               && expt.Core_MDF_Active_ind__c
               && expt.Core_MDF_Exception_Status_txt__c == Label.Core_MDF_Exception_Approved_Status){
                eefExceptionMap.put(expt.Id, expt);
            }
        }
      
        //To get Activating & Primary Partner Account for EEF Exceptions
        if(!eefExceptionMap.isEmpty()){
            //excpEEFWrapper - wrapper to prepare the list of activating accounts/primary accounts associated to the exception accounts
            Core_MDF_Expt_AccMap_ServiceHandler.ExceptionEEFDataWrapper excpEEFWrapper = Core_MDF_Expt_AccMap_ServiceHandler.prepareDataForEEFSharing(eefExceptionMap.values(),accIdToPartnerTypeMap);
            system.debug('accIdToPartnerTypeMap-->'+accIdToPartnerTypeMap);
            intelAccountIdSet = excpEEFWrapper.intelAccountIdSet;//set to store the Intel Account id of Primary and Activating accounts.
            mapOfExpIdToActAccId = excpEEFWrapper.mapOfExpIdToActAccId; 
            mapOfExpIdToPrimaryAccId = excpEEFWrapper.mapOfExpIdToPrimaryAccId; 
        }
        //Iterating over account specific exception
        //All account exception sharing is achieved from sharing rule
        for(Core_MDF_Exception_Account_Mapping__c expt: EAPMap.values()){
            Set<String> channelPrgIdAccId = new Set<String>();
            
            //Akash - Added check here to show record to external user expose externally, Exception Enhancements- New Flag to control external exposure
            if(expt.Core_MDF_Program_txt__c != Null && expt.Core_MDF_Account_id__c != NUll
               && expt.Core_MDF_Active_ind__c
               && expt.Core_MDF_Exception_Status_txt__c == Label.Core_MDF_Exception_Approved_Status
               && expt.Core_MDF_Expose_Externally_ind__c){
                if(expt.Core_MDF_Program_txt__c != Label.Core_MDF_Retail_Program){
                    String progName = channelProgramNameMap!=null && channelProgramNameMap.containskey(expt.Core_MDF_Program_txt__c)?
                        												channelProgramNameMap.get(expt.Core_MDF_Program_txt__c) :'';
                    
                    if(String.isNotBlank(progName) && channelProgramNameIdMap!=NULL && channelProgramNameIdMap.containskey(progName))
                    {    
                        exceptionChannelPrgIdsSet.add(channelProgramNameIdMap.get(progName));
                    }
                    
                    Set< Core_MDF_Exception_Account_Mapping__c > exptSet = new Set< Core_MDF_Exception_Account_Mapping__c >{expt};
                        if(expt.Core_MDF_Program_txt__c == Label.Core_MDF_EEF_RecordType){
// US - TWC702-14285: Flatten nested IFs (no logic change) - Begin original code commented
                        /*
                        //preparing the channelprgIdAccIdSet for EEF Activating Account
                        if(!mapOfExpIdToActAccId.isEmpty() && mapOfExpIdToActAccId.size()>0){
                            for(Id accId : mapOfExpIdToActAccId.get(expt.Core_MDF_Exception_id__c)){
                                channelPrgIdAccId.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)accId);
                    
                            }   
                        }
                        
                        //preparing the channelprgIdAccIdSet for EEF Priamary Account
                        if(!mapOfExpIdToPrimaryAccId.isEmpty() && mapOfExpIdToPrimaryAccId.size()>0){
                            for(Id accId : mapOfExpIdToPrimaryAccId.get(expt.Core_MDF_Exception_id__c)){
                                channelPrgIdAccId.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)accId);
                            }
                        }
                        */
                        // US - TWC702-14285: Flatten nested IFs (no logic change) - End original code
                        // US - TWC702-14285: Flatten nested IFs (no logic change) - Begin new flattened code
                        // Combine both ID lists into a single collection to eliminate duplicate loop structures
						List<Id> associatedAccountIds = new List<Id>();

						List<Id> activatingAccs = mapOfExpIdToActAccId.get(expt.Core_MDF_Exception_id__c);
						if (activatingAccs != null) associatedAccountIds.addAll(activatingAccs);

						List<Id> primaryAccs = mapOfExpIdToPrimaryAccId.get(expt.Core_MDF_Exception_id__c);
						if (primaryAccs != null) associatedAccountIds.addAll(primaryAccs);

						// Single, flat loop with no nested if statements
						for (Id accId : associatedAccountIds) {
    						channelPrgIdAccId.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)accId);
						}

                        // US - TWC702-14285: Flatten nested IFs (no logic change) - End new flattened code
                    }
                    channelPrgIdAccId.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (string)expt.Core_MDF_Account_id__c);   
                    
                    //string channelPrgIdAccId = (String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_nm__c)) + (string)expt.Core_MDF_Account_id__c;
                    //Adding expt to set with key as channelprogram id and account id
                    
                    
                    for(String cpIdAccId : channelPrgIdAccId){
                        if(channelPrgIdAccIdExptSetMap.containskey(cpIdAccId)){
                            channelPrgIdAccIdExptSetMap.get(cpIdAccId).add(expt);
                        }else{
                            channelPrgIdAccIdExptSetMap.put(cpIdAccId,exptSet); 
                        }
                    }

            
                    intelAccountIdSet.add(expt.Core_MDF_Account_id__c);
                    
                }else{
                    rmfAccIdSet.add(expt.Core_MDF_Account_id__c);
                    listRmfExpt.add(expt);
                }
            }
        }
        
        
        if(!rmfAccIdSet.isEmpty()){
            for(Account rmfNodes : [SELECT Id, Core_MDF_External_Group_Id__c FROM Account WHERE Id IN: rmfAccIdSet AND RecordType.Name =: CO_MARKETING_ACCOUNT]){
                accIdGrpIdMap.put(rmfNodes.id,rmfNodes.Core_MDF_External_Group_Id__c);
            }
        }
        if(!accIdGrpIdMap.isEmpty()){
            for(Core_MDF_Exception_Account_Mapping__c expt: listRmfExpt){
                if(accIdGrpIdMap.containskey(expt.Core_MDF_Account_id__c)){
                    exptShareSet.add(createExceptionShareExt(expt.Core_MDF_Exception_id__c,accIdGrpIdMap.get(expt.Core_MDF_Account_id__c)));
                    exptAccMapShareSet.add(createExceptionAccShareExt(expt.id,accIdGrpIdMap.get(expt.Core_MDF_Account_id__c)));
                }
            }
        }
       
        String pgmQueryStr = '';
        String accessType = 'External';  // US - TWC702-14285: Avoid Untrusted/Unescaped Variables in DML Query 
        pgmQueryStr = 'SELECT Id, Core_MDF_Account__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Name,Core_MDF_Group_Id__c,' +
                'Core_MDF_Group_Name__c, Core_MDF_Type_of_Access__c ' +
                'FROM Core_MDF_Partner_Group_Mapping__c ' +
                'WHERE Core_MDF_Channel_Program__c IN :exceptionChannelPrgIdsSet ' +
                'AND Core_MDF_Type_of_Access__c = :accessType ' +   // US - TWC702-14285: Avoid Untrusted/Unescaped Variables in DML Query
                'AND Core_MDF_Inactive_Ind__c = false ' +
                'AND Core_MDF_Group_Id__c != NULL '+
                'AND Core_MDF_Account__c IN :intelAccountIdSet';
            for(Core_MDF_Partner_Group_Mapping__c pgm : Database.query(pgmQueryStr)){
                string pgmChannelPrgIdAccId =(String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c;
                if(channelPrgIdAccIdExptSetMap.containskey(pgmChannelPrgIdAccId)){
                    for(Core_MDF_Exception_Account_Mapping__c expt: channelPrgIdAccIdExptSetMap.get(pgmChannelPrgIdAccId)){
                        exptShareSet.add(createExceptionShareExt(expt.Core_MDF_Exception_id__c,pgm.Core_MDF_Group_Id__c));
                        exptAccMapShareSet.add(createExceptionAccShareExt(expt.id,pgm.Core_MDF_Group_Id__c));
                    }
                }
            }
        
        if(!exptShareSet.isEmpty()){
        List <Core_MDF_Exception__Share> exptShareList = new List< Core_MDF_Exception__Share >();
        exptShareList.addAll(exptShareSet);
        database.insert(exptShareList,false);
        }
        
        if(!exptAccMapShareSet.isEmpty()){
        List <Core_MDF_Exception_Account_Mapping__Share> exptAccMapShareList = new List< Core_MDF_Exception_Account_Mapping__Share >();
        exptAccMapShareList.addAll(exptAccMapShareSet);
        database.insert(exptAccMapShareList,false);
        }
        
    }
    
    public static Core_MDF_Exception__Share createExceptionShareExt(String exceptionId, String ugId){
        Core_MDF_Exception__Share expShare = new Core_MDF_Exception__Share();
        expShare.ParentId = exceptionId;
        expShare.RowCause = 'Exception_External_Sharing__c';
        expShare.AccessLevel = 'Read';
        expShare.UserOrGroupId = ugId;
        return expShare;
    } 
    
    public static Core_MDF_Exception_Account_Mapping__Share createExceptionAccShareExt(String exceptionId, String ugId){
        Core_MDF_Exception_Account_Mapping__Share expShare = new Core_MDF_Exception_Account_Mapping__Share();
        expShare.ParentId = exceptionId;
        expShare.RowCause = 'Core_MDF_EAM_External_Sharing__c';
        expShare.AccessLevel = 'Edit';
        expShare.UserOrGroupId = ugId;
        return expShare;
    }     
}