/****************************************************************************************************************************************
* Class Name        : Core_MDF_Expt_AccMap_ServiceHandler
* Created Date        : 24-03-2025
* Developer Name      : Mohit Sharma
* Last Modified Name  : 
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture MS      24-03-2025       Created Service Handler for Exception Account Mapping Trigger Handler class
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Expt_AccMap_ServiceHandler {
    
    static Boolean flag = false;
    public static Map<Id,List<string>> accIdToPartnerTypeMap = new Map<Id,List<string>>();
    public static Map<Id,List<Core_MDF_Exception_Account_Mapping__c>> ultimateAccountIdToExceptionMap = new Map<Id,List<Core_MDF_Exception_Account_Mapping__c>>();
    static final String STR_WW ='WW';
    static final String STR_AllAccount_Yes ='Yes';
    static final String STR_AllAccount_No ='No';
    static final String IPA_RecordType ='Core_MDF_Intel_Partner_Alliance';
    static final String IPA_Program ='Intel Partner Alliance';
    static final String EXCEPTION_PENDING_REVIEW_STATUS = 'Pending Review'; 
    static final Integer BATCH_LIMIT = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExceptionBulkDMLSync_Limit')); 
    static final Integer EXCEPTION_SHARE_INSERT_BATCH_LIMIT = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExceptionShareInsert_BatchLimit'));
    static final Integer EXCEPTION_SHARE_DEL_BATCH_LIMIT = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExceptionShareDel_BatchLimit'));
    static Boolean isCSCUser = FeatureManagement.checkPermission('Core_MDF_Internal_CSC_User');  
    public static List<string> exptMapAccCreationStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Expt_AccMap_CreationStatus').split(';');
    
/****************************************************************************************************************************************
* Method Name           : initializeEAM
* Created Date          : 24-03-2025
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture SB        24-03-2025         Method to initialize fields for Exception Account Mapping
*****************************************************************************************************************************************/     
    public static void initializeEAM (List<Core_MDF_Exception_Account_Mapping__c> listOfEAM){
        List<Id> exptIds = new List<Id>();
        List<Id> accIds = new List<Id>();
        List<Id> ipaExptIds = new List<Id>();
        List<Id> ipaAccIds = new List<Id>();
        try{
        for(Core_MDF_Exception_Account_Mapping__c eam: listOfEAM){
            exptIds.add(eam.Core_MDF_Exception_id__c);
            accIds.add(eam.Core_MDF_Account_id__c);
        }
        //Querying the assoicated exception fields and stamping the same on Exception Account Mapping
        Map<Id,Core_MDF_Exception__c> exptMap = new Map<Id,Core_MDF_Exception__c>(
            									[Select id,Core_MDF_Country_Region_nm__c,Core_MDF_Exception_Status_nm__c,Core_MDF_Program_nm__c,Core_MDF_Region_txt__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Select_All_Accounts_ind__c from Core_MDF_Exception__c Where id IN: exptIds]);
        
        Map<Id,Account> accMap = new Map<Id,Account>(
            									[Select id,RecordType.Name from Account Where id IN: accIds]);
        
        for(Core_MDF_Exception__c expt:exptMap.values()){
            if(expt.Core_MDF_Program_nm__c == 'Core_MDF_Intel_Partner_Alliance'){ipaExptIds.add(expt.id);
            }
        }
        
        for(Core_MDF_Exception_Account_Mapping__c eam: listOfEAM){
            if(ipaExptIds.contains(eam.Core_MDF_Exception_id__c)){ipaAccIds.add(eam.Core_MDF_Account_id__c);
            }
        }
        
        List<Account> ipaAccList = [Select id,ParentId,Core_MDF_Parent_Fund_Account__c,RecordType.Name,Core_Geo__c,Core_MDF_Virtual_Corp_Account_Id__c,Core_MDF_Channel_Program__r.Name from Account Where Core_MDF_Parent_Fund_Account__c IN: ipaAccIds and RecordType.Name ='CoMarketing' and Core_MDF_Channel_Program__r.Name ='Intel Partner Alliance' and Core_MDF_Virtual_Corp_Account_Id__c = null];
        
        Core_MDF_Exception_Utility.ExceptionUserIUPGMWrapper exptUserIUPGMWrap = Core_MDF_Exception_Utility.getIUPGMDataForExceptionUser();
        ExceptionDataSetWrapper excpWrapper = prepareDataSetForValidation(listOfEAM);
        
        for(Core_MDF_Exception_Account_Mapping__c eam: listOfEAM){
            string exptProg = exptMap.get(eam.Core_MDF_Exception_id__c).Core_MDF_Program_nm__c;
            Account accRec = accMap.get(eam.Core_MDF_Account_id__c);
            string exptStatus = exptMap.get(eam.Core_MDF_Exception_id__c).Core_MDF_Exception_Status_nm__c;
            string accRecType = accRec.RecordType.name;
            if(exptMap.containskey(eam.Core_MDF_Exception_id__c) && String.isNotBlank(exptProg) && exptProg.equals('Core_MDF_Retail_Marketing_Funds')
               && accMap.containskey(eam.Core_MDF_Account_id__c) && String.isNotBlank(accRecType) && accRecType.equals('Intel Account')){eam.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Expt_Account_Map_AccountTypeErr'));
            }

            if(!Core_MDF_Utility.byPassFeature('ByPass_Status_Check_For_EAMCreation') && exptMap.containskey(eam.Core_MDF_Exception_id__c) 
               && String.isNotBlank(exptStatus) && !exptMapAccCreationStatus.contains(exptStatus)){eam.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exception_Status_Check'));
            }
            eam.Core_MDF_Country_Region_txt__c = exptMap.get(eam.Core_MDF_Exception_id__c).Core_MDF_Country_Region_nm__c;
            eam.Core_MDF_ExceptionIdAccountId_txt__c = String.valueOf(eam.Core_MDF_Exception_id__c) + String.valueOf(eam.Core_MDF_Account_id__c);
            //eam.Core_MDF_Region_txt__c = exptMap.get(eam.Core_MDF_Exception_id__c).Core_MDF_Region_txt__c;
            eam.Core_MDF_Budget_Type_txt__c = exptMap.get(eam.Core_MDF_Exception_id__c).Core_MDF_Budget_Type_nm__c;
            eam.Core_MDF_Program_nm__c = exptMap.get(eam.Core_MDF_Exception_id__c).Core_MDF_Program_nm__c;
            
            if(ipaExptIds.contains(eam.Core_MDF_Exception_id__c)){
                for(Account ipaAcc: ipaAccList){if(ipaAcc.Core_MDF_Parent_Fund_Account__c == eam.Core_MDF_Account_id__c){eam.Core_MDF_HostRegion_txt__c = ipaAcc.Core_Geo__c;
                    }
                }
            }
            validateException(eam, exptUserIUPGMWrap, excpWrapper);
        }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    } 

/****************************************************************************************************************************************
* Method Name           : validateException
* Created Date          : 01/14/2020
* Modification Log
* Developer              Date               Method to throw validation errors by checking account, 
geo and program in exception
if user does not have access to any of them             
* ---------------------------------------------------------------------------------------------------------------------------------------

*****************************************************************************************************************************************/
    //Exception Enhancement - This is not required as Account field moved from Exception to Exception Account Mapping
    private static void validateException(Core_MDF_Exception_Account_Mapping__c excpt, Core_MDF_Exception_Utility.ExceptionUserIUPGMWrapper excptUserData,ExceptionDataSetWrapper excpWrapper){
        Map<String,String> countryGeoMap = excpWrapper.countryGeoMap;
        String programName = excpWrapper.channelProgramNameMap.get(excpt.Core_MDF_Program_nm__c);
        Map<Id, Set<String>> accountIdProgramStrSetMap  =excpWrapper.accountIdProgramStrSetMap;
        Boolean isExceptionReviewerFlag = isExceptionReviewer();
        if(!isExceptionReviewerFlag){
            //Check All Accounts condition on exception
            if(validateExceptionAccountAccess(excpt, isExceptionReviewerFlag,programName, excptUserData.exptUserIUPGMAccountProgramStrSet)) { if (programName =='Retail Marketing Funds'){validateExceptionAccountProgramAccess(excpt, accountIdProgramStrSetMap, programName);}else{
                    //validateExceptionAccountProgramAccess(excpt, accountIdProgramStrSetMap, programName);
                    if(validateExceptionCountryAccess (excpt, programName, excptUserData.exptUserIUPGMAccountProgramStrSet, excptUserData.exptUserIUPGMAccountProgramGeoStrSet,countryGeoMap)){ /* Check if any error is associated or program on the exception or not.*/ validateExceptionAccountProgramAccess(excpt, accountIdProgramStrSetMap, programName);
                    }
                }
            }
        }
        else{
            // Check if any error is associated or program on the exception or not.
            validateExceptionAccountProgramAccess(excpt, accountIdProgramStrSetMap, programName);
        }
    }
 /****************************************************************************************************************************************
* Method Name           : validateExceptionAccountAccess
* Created Date          : 01/14/2020
* Modification Log
* Developer              Date          Method to throw validation errors if user does not have access
for account chosen in Exception
* ---------------------------------------------------------------------------------------------------------------------------------------

*****************************************************************************************************************************************/
    private static Boolean validateExceptionAccountAccess(Core_MDF_Exception_Account_Mapping__c excpt ,Boolean excptReviewerCheck,String exceptionChannelprogram, Set<String> exptUserIUPGMAccountProgramStrSet){
        String program = '';program = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(exceptionChannelprogram);
        //Constructing key first to check all country condition
        //program = exceptionChannelprogram.replaceAll('-', '');
        if(!Core_MDF_Utility.byPassFeature('Bypass_ValidateAccountAccessonEAM') && !system.isBatch()) {if(excpt.Core_MDF_Account_id__c!= null && !isCSCUser){//For CSC User this error is handled from Validation rule
                    System.debug('EXCEPTION----'+excpt.Core_MDF_Account_id__c+'-'+program+'-'+STR_AllAccount_No);
                    System.debug('exptUserIUPGMAccountProgramStrSet----'+exptUserIUPGMAccountProgramStrSet);//001g0000024cgUuAAI-Client CoMarketing Fund-No
            if((!exptUserIUPGMAccountProgramStrSet.contains(excpt.Core_MDF_Account_id__c+'-'+program+'-'+STR_AllAccount_No) && !exptUserIUPGMAccountProgramStrSet.contains(program+'-'+STR_AllAccount_Yes)) && !excptReviewerCheck){excpt.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExceptionAccountAccessError'));return false;}}}return true;}
/****************************************************************************************************************************************
* Method Name           : ValidateExceptionAccountProgramAccess
* Created Date          : 01/14/2020
* Modification Log
* Developer              Date               Method to throw validation errors if account does not have access
to program chosen in exception
* ---------------------------------------------------------------------------------------------------------------------------------------

*****************************************************************************************************************************************/
 private static Boolean validateExceptionAccountProgramAccess(Core_MDF_Exception_Account_Mapping__c excpt,
                                                                 Map<Id, Set<String>> accIdProgramStrSetMap, String excptChannelProgram )
    {if(!Core_MDF_Utility.byPassFeature('Bypass_ValidateAccProgAccessOnEAM') && !system.isBatch())
        {   System.debug('accIdProgramStrSetMap ===1073'+ accIdProgramStrSetMap);
            // Validation for the scenario where intel account is created but child accounts are not created
            if(accIdProgramStrSetMap.size() == 0 && !accIdProgramStrSetMap.containsKey(excpt.Core_MDF_Account_id__c) && !excpt.Core_MDF_Select_All_Accounts_ind__c){excpt.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExceptionAccountProgramError'));return false;}
            // Program validation for RMF where child account is selected on Exception
            else if(accIdProgramStrSetMap != NULL && accIdProgramStrSetMap.size() > 0 && accIdProgramStrSetMap.containsKey(excpt.Core_MDF_Account_id__c) &&!accIdProgramStrSetMap.get(excpt.Core_MDF_Account_id__c).contains(excptChannelProgram)){excpt.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExceptionAccountProgramError'));return false;}} return true;
  }

 /****************************************************************************************************************************************
* Method Name           : validateExceptionCountryAccess
* Created Date          : 01/14/2020
* Modification Log
* Developer              Date               Method to throw validation errors if user does not have access
to country chosen in exception
* ---------------------------------------------------------------------------------------------------------------------------------------

*****************************************************************************************************************************************/
    private static Boolean validateExceptionCountryAccess(Core_MDF_Exception_Account_Mapping__c excpt, String exceptionChannelprogram, Set<String> accountProgramStrSet,
                                                          Set<String> accountProgramGeoStrSet, Map<String , String> countryGeoMap){
                                                              Map< Core_MDF_Exception_Account_Mapping__c , Boolean>exceptionIdCountryErrorCheckMap = new Map< Core_MDF_Exception_Account_Mapping__c , Boolean>();
                                                              String program = '';program = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(exceptionChannelprogram);
                                                              //Constructing key first to check all country condition
                                                              //program = exceptionChannelprogram.replaceAll('-', '');
                                                              
                                                              if(!Core_MDF_Utility.byPassFeature('ByPass_ValidateCountryAccessOnEAM') && !system.isBatch() && !isCSCUser)
                                                              {if(excpt.Core_MDF_Account_id__c != NULL){exceptionIdCountryErrorCheckMap.put(excpt, false);
                                                                      if(excpt.Core_MDF_Select_All_Country_ind__c){String progRegionkey = program+'-'+STR_AllAccount_Yes+'-'+STR_WW;String accProgRegionkey = excpt.Core_MDF_Account_id__c+'-'+program+'-'+STR_AllAccount_No+'-'+STR_WW;
                                                                          // Error to be thrown only when user does not have access to all regions in iupgm 
                                                                          if(!accountProgramGeoStrSet.contains(accProgRegionkey) &&!accountProgramGeoStrSet.contains(progRegionkey)){excpt.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExceptionSelectAllCountry_Error'));return false;}
                                                                      }else{if(excpt.Core_MDF_Country_Region_txt__c != null){
                                                                              for(String countryStr : excpt.Core_MDF_Country_Region_txt__c.split(';')){
                                                                                  //Updating key to check multiple country condition
                                                                                  if(accountProgramGeoStrSet.contains(excpt.Core_MDF_Account_id__c+'-'+program+'-'+STR_AllAccount_No+'-'+countryGeoMap.get(countryStr)) || accountProgramGeoStrSet.contains(program+'-'+STR_AllAccount_Yes+'-'+countryGeoMap.get(countryStr)) || accountProgramGeoStrSet.contains(excpt.Core_MDF_Account_id__c+'-'+program+'-'+STR_AllAccount_No+'-'+STR_WW) || accountProgramGeoStrSet.contains(program+'-'+STR_AllAccount_Yes+'-'+STR_WW)){
                                                                                         if(!exceptionIdCountryErrorCheckMap.get(excpt)){exceptionIdCountryErrorCheckMap.put(excpt, false);}}
                                                                                  else{exceptionIdCountryErrorCheckMap.put(excpt, true);}}}}
                                                                          if(exceptionIdCountryErrorCheckMap.get(excpt)){excpt.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exception_MultiGeo_Error'));return false;}}}
                                                              return true;
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
        return isCustomPermissionAssigned('Core_MDF_ExceptionReviewer');}
    
 /*****************************************************************************************************
Method Name:        isCustomPermissionAssigned
@return  :          Boolean
@parameters:        String - Custom Permission Name
Description:        This method is used to check if the Custom permission is assigned to the User
Added By:           Accenture SB
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static Boolean isCustomPermissionAssigned(String customPermissionNameStr){
        if(customPermissionNameStr != NULL && String.isNotBlank(customPermissionNameStr)){return FeatureManagement.checkPermission(customPermissionNameStr);}
        else{ return false;}
    }     
 /****************************************************************************************************************************************
* Method Name           : shareEAMonHostGeoUpdate
* Created Date          : 24-03-2025
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture SB        24-03-2025         Exception Trigger Service Handler which handles the sharing of the Exception Account Mapping & Exception with appropriate Internal users
*****************************************************************************************************************************************/    
    public static void shareEAMonHostGeoUpdate(Map<Id,Core_MDF_Exception_Account_Mapping__c> newMapEAM,Map<Id,Core_MDF_Exception_Account_Mapping__c> oldMapEAM){
        Set<Id> exptIdset = new Set<Id>();
        List<Core_MDF_Exception__Share> exceptionShareList = new List<Core_MDF_Exception__Share>();
        List<Core_MDF_Exception_Account_Mapping__Share> exceptionAccMapShareList = new List<Core_MDF_Exception_Account_Mapping__Share>();
        try{
            for(Core_MDF_Exception_Account_Mapping__c exptOnUpdate : newMapEAM.values()){
                if(exptOnUpdate.Core_MDF_HostRegion_txt__c != oldMapEAM.get(exptOnUpdate.id).Core_MDF_HostRegion_txt__c || exptOnUpdate.OwnerId != oldMapEAM.get(exptOnUpdate.id).OwnerId){exptIdset.add(exptOnUpdate.Core_MDF_Exception_id__c);
                }
            }
            if(exptIdset != null && exptIdset.isEmpty()){
                for(Core_MDF_Exception__Share exceptionShareRecord : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Core_MDF_Exception__Share WHERE ParentId IN: exptIdset AND RowCause =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RowCause_Manual')]){
                                                                          exceptionShareList.add(exceptionShareRecord);
                                                                      }
                
                for(Core_MDF_Exception_Account_Mapping__Share exceptionAccMapShareRecord : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Core_MDF_Exception_Account_Mapping__Share WHERE Parent.Core_MDF_Exception_id__c IN :exptIdset AND RowCause =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RowCause_Manual')]){
                                                                          exceptionAccMapShareList.add(exceptionAccMapShareRecord);
                                                                      }
            }
            
             if(exceptionShareList!=null && !exceptionShareList.isEmpty()){deleteShareRecord(exceptionShareList);
            }
            if(exceptionAccMapShareList!=null && !exceptionAccMapShareList.isEmpty()){deleteShareRecord(exceptionAccMapShareList);
            }
            
            Map<Id,Core_MDF_Exception_Account_Mapping__c> newMapOfEAM = new Map<Id,Core_MDF_Exception_Account_Mapping__c>(
                                                                      [SELECT Id,Core_MDF_Country_Region_txt__c,Core_MDF_Account_id__c,Core_MDF_Select_All_Accounts_ind__c,Core_MDF_Program_txt__c,Core_MDF_HostRegion_txt__c,Core_MDF_Budget_Type_txt__c,Core_MDF_Exception_id__c,Core_MDF_Select_All_Country_ind__c FROM Core_MDF_Exception_Account_Mapping__c WHERE Core_MDF_Exception_id__c IN: exptIdset]);
            shareEAM(newMapOfEAM);
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
  /****************************************************************************************************************************************
* Method Name           : shareAEM
* Created Date          : 24-03-2025
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture SB        24-03-2025         Exception Trigger Service Handler which handles the sharing of the Exception Account Mapping & Exception with appropriate Internal users
*****************************************************************************************************************************************/    
    public static void shareEAM(Map<Id,Core_MDF_Exception_Account_Mapping__c> newMapAEM){
		try{
            
            List<Id> priamryAccId = new List<Id>();
            List<Id> activatingAccId = new List<Id>();
            Set<Id> intelAccountIdSet = new Set<Id>();
            Set<Id> intelAccountIdSetEEF = new Set<Id>();
            Set<Id> programIdSet = new Set<Id>();
            Set<Id> programIdRMFSet = new Set<Id>();
            Map<String,Set<String>> geoSubGeoSetMap = new Map<String,Set<String>>();
            Map< String, String > AccountIdGroupIdMap = new Map< String, String>();
            Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdAccIdGeoExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
            Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdBudgetTypeExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
            Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdGeoAllAccountExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
            Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdWWAllAccountExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
            Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdWWAllBudTypeAccountExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
            Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdAccIdGeoSubGeoExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
            Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdAccIdWWExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
            Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdAccIdExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
            Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdGeoExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
            Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdGeoSubGeoExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
            Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdWWExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
            Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
            
            //Set which stores Exception Channel Program Id's
            Set<String> exceptionChannelPrgIdsSet = new Set<String>();
            
            //Fetch associated channel partner Core_MDF Name
            Map<String,  String> channelProgramNameMap = new Map<String,  String>();
            
            // Map of Channel Program Id and Channel Program Name
            Map<String,  String> channelProgramNameIdMap = new Map< String,  String >();
            
            //key=country, value=geo
            Map<String,String> countryGeoMap = new Map<String,String>();
            
            //key=country, value=SubGeo
            Map<String,String> countrySubGeoMap = new Map<String,String>();
            
            Boolean blnAllAccountsFlag = false;
            Boolean queryNodeGrp = false;
            
            
            String pgmQueryStr = '';
            String AccQueryStr = '';
            
            String strAccountWHEREClause = '';
            
            //Construct Share Records
            Set< Core_MDF_Exception_Account_Mapping__Share > exptAccMapShareSet = new Set< Core_MDF_Exception_Account_Mapping__Share >();
            Set< Core_MDF_Exception__Share> exptShareSet = new Set< Core_MDF_Exception__Share >();
            
            Set<String> exceptionIdGroupIdStrSet = new Set<String>();
            
            Set<String> subGeoStringSet = new Set<String>();
            
            List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>(); 
            List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
			List<Core_MDF_RecordGeoShare> recordGeoShareListEAM = new List<Core_MDF_RecordGeoShare>(); 
            List<Core_MDF_RecordPGMShareWrapper> recordPGMShareListEAM= new List<Core_MDF_RecordPGMShareWrapper>();            
            
            //This contains the mapping of account Id and its related programs. This will be fetched from the Account Hierarchy
            Map<Id, Set<String>> accountIdProgramStrSetMap = new Map<Id, Set<String>>();
            Set<String> loggedInUserAccountProgramGeoStrSet = new Set<String>();
            Map<String,String> recTypeGroupMap = new Map<String,String>();
            Map<String,Id> groupDevNameIdMap = new Map<String,Id>();
            
            ExceptionDataSetWrapper excpWrapper = prepareDataSetForValidation(newMapAEM.values());
            channelProgramNameMap = excpWrapper.channelProgramNameMap;
            countryGeoMap = excpWrapper.countryGeoMap;
            intelAccountIdSet = excpWrapper.intelAccountIdSet;
            programIdSet = excpWrapper.programIdSet; 
            programIdRMFSet = excpWrapper.programIdRMFSet;
            queryNodeGrp = excpWrapper.queryNodeGrp;
            blnAllAccountsFlag = excpWrapper.blnAllAccountsFlag;
            accountIdProgramStrSetMap = excpWrapper.accountIdProgramStrSetMap; 
            channelProgramNameIdMap = excpWrapper.channelProgramNameIdMap;
            AccountIdGroupIdMap = excpWrapper.AccountIdGroupIdMap;
            countrySubGeoMap = excpWrapper.countrySubGeoMap;
            geoSubGeoSetMap = excpWrapper.geoSubGeoSetMap;
            subGeoStringSet = excpWrapper.subGeoStringSet;
            strAccountWHEREClause = excpWrapper.strAccountWHEREClause;
            // Storing all data from wrapper into local variables
            
            for(Core_MDF_CCP_RecordTypes__c recTypeMetadata : [select Core_MDF_Allocation_RT_DeveloperName__c,Core_MDF_Exception_SharingGroup__c from Core_MDF_CCP_RecordTypes__c
                                                               where Core_MDF_Exception_SharingGroup__c!=null])
            {
                //Querying for exception sharing super group from metadata
                recTypeGroupMap.put(recTypeMetadata.Core_MDF_Allocation_RT_DeveloperName__c,recTypeMetadata.Core_MDF_Exception_SharingGroup__c);
            }
            
            Set<String> sharingGroupNameSet = new Set<String>(recTypeGroupMap.values());
            if(!sharingGroupNameSet.isEmpty())
            {
                for(Group exptGroup : [Select Id,DeveloperName from Group where DeveloperName in: sharingGroupNameSet])
                {
                    //Creating a map for storing group Id for corresponding group name
                    groupDevNameIdMap.put(exptGroup.DeveloperName,exptGroup.Id);
                }
            }
            
            
            /**EEF Changes */
            //mapOfExpIdToActAccId - map of Exception Id to associcated Activating AccountId
            Map<Id,List<Id>> mapOfExpIdToActAccId = new Map<Id,List<Id>>();
            //mapOfExpIdToPrimaryAccId - map of Exception Id to Associated Primary AccountId
            Map<Id,List<Id>> mapOfExpIdToPrimaryAccId = new Map<Id,List<Id>>();
            //eefExceptionMap - map Of Exception Id and Exception Record for EEF Program
            Map<Id,Core_MDF_Exception_Account_Mapping__c> eefExceptionMap= new Map<Id,Core_MDF_Exception_Account_Mapping__c>();
            for(Core_MDF_Exception_Account_Mapping__c expt : newMapAEM.values()){
                if(expt.Core_MDF_Program_txt__c == Label.Core_MDF_EEF_RecordType){
                    eefExceptionMap.put(expt.Id, expt);
                }
            }
            
            if(!eefExceptionMap.isEmpty()){
                //excpEEFWrapper - wrapper to prepare the list of activating accounts/primary accounts associated to the exception accounts
                ExceptionEEFDataWrapper excpEEFWrapper = prepareDataForEEFSharing(eefExceptionMap.values(),accIdToPartnerTypeMap);
                intelAccountIdSet = excpEEFWrapper.intelAccountIdSet;//set to store the Intel Account id of Primary and Activating accounts.
                mapOfExpIdToActAccId = excpEEFWrapper.mapOfExpIdToActAccId; 
                mapOfExpIdToPrimaryAccId = excpEEFWrapper.mapOfExpIdToPrimaryAccId;
            }
            
            for(Core_MDF_Exception_Account_Mapping__c expt : newMapAEM.values()){
                // Add all the ids channel program ids in the set
                String progName = channelProgramNameMap!=null && channelProgramNameMap.containskey(expt.Core_MDF_Program_txt__c)?channelProgramNameMap.get(expt.Core_MDF_Program_txt__c) :'';
                if(String.isNotBlank(progName) && channelProgramNameIdMap!=NULL && channelProgramNameIdMap.containskey(progName))
                {    
                    exceptionChannelPrgIdsSet.add(channelProgramNameIdMap.get(progName));
                }
                List<Id> groupIdList = new List<Id>();
                //If country is blank then set the boolean to true else set false
                Boolean allCountry = String.isBlank(expt.Core_MDF_Country_Region_txt__c);
                
                if(expt.Core_MDF_Account_id__c != NULL){// If the exception has one account selected
                    if(AccountIdGroupIdMap!=NULL && AccountIdGroupIdMap.containskey(expt.Core_MDF_Account_id__c))
                    {groupIdList.add(AccountIdGroupIdMap.get(expt.Core_MDF_Account_id__c));exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, AccountIdGroupIdMap.get(expt.Core_MDF_Account_id__c)));exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, AccountIdGroupIdMap.get(expt.Core_MDF_Account_id__c)));
                    }
                    //Account       Country
                    //Single        Multi
                    if(expt.Core_MDF_Program_txt__c != IPA_RecordType){ 
                        if(expt.Core_MDF_Country_Region_txt__c != NULL){//Check if it is Multi Select Country
                            Map<Id,Set<String>> exptIdGeoSetMap = new Map<Id,Set<String>>();
                            Map<Id,Set<String>> exptIdGeoSubgeoSetMap = new Map<Id,Set<String>>();
                            
                            //exceptionId, Set<APJSA,EMEACER>
                            for(String countryStr : expt.Core_MDF_Country_Region_txt__c.split(';')){//Split the Countries and iterate over them
                                if(countryGeoMap.containsKey(countryStr)){
                                    Set<Core_MDF_Exception_Account_Mapping__c> exptSet = new Set<Core_MDF_Exception_Account_Mapping__c>{expt};
                                        if(countrySubGeoMap.containsKey(countryStr)){
                                            String geoSubGeoStr = countryGeoMap.get(countryStr) + countrySubGeoMap.get(countryStr);
                                            if(exptIdGeoSubgeoSetMap.containsKey(expt.Id)){
                                                if(!exptIdGeoSubgeoSetMap.get(expt.Id).contains(geoSubGeoStr)){
                                                    exptIdGeoSubgeoSetMap.get(expt.Id).add(geoSubGeoStr);
                                                    //exp id, geo, subseo, program
                                                    recordGeoShareListEAM.add(new Core_MDF_RecordGeoShare(expt.Id, countryGeoMap.get(countryStr), countrySubGeoMap.get(countryStr), (String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)));
                                                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(expt.Core_MDF_Exception_id__c, countryGeoMap.get(countryStr), countrySubGeoMap.get(countryStr), (String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)));
                                                }
                                            }
                                            else{
                                                Set<String> existingGeoSubGeoSet = new Set<String>();
                                                existingGeoSubGeoSet.add(geoSubGeoStr);
                                                exptIdGeoSubgeoSetMap.put(expt.Id, existingGeoSubGeoSet);
                                                //exp id, geo, subseo, program
                                                recordGeoShareListEAM.add(new Core_MDF_RecordGeoShare(expt.Id, countryGeoMap.get(countryStr), countrySubGeoMap.get(countryStr), (String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)));
                                                recordGeoShareList.add(new Core_MDF_RecordGeoShare(expt.Core_MDF_Exception_id__c, countryGeoMap.get(countryStr), countrySubGeoMap.get(countryStr), (String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)));
                                            }
                                            
                                            //channelprgIdAccIdGeoSubGeoSet - set for EEF Program
                                            Set<String> channelprgIdAccIdGeoSubGeoSet = new Set<String>();
                                            
                                            If(expt.Core_MDF_Program_txt__c == Label.Core_MDF_EEF_RecordType){//constant class
                                                //Added for EEF - Activating
                                                if(!mapOfExpIdToActAccId.isEmpty() && mapOfExpIdToActAccId.size() > 0){
                                                    for(Id accId : mapOfExpIdToActAccId.get(expt.Id)){
                                                        channelprgIdAccIdGeoSubGeoSet.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)accId + countryGeoMap.get(countryStr) + countrySubGeoMap.get(countryStr));
                                                    }
                                                }
                                                //Added for EEF - Primary
                                                if(!mapOfExpIdToPrimaryAccId.isEmpty() && mapOfExpIdToPrimaryAccId.size()>0){
                                                    for(Id accId : mapOfExpIdToPrimaryAccId.get(expt.Id)){channelprgIdAccIdGeoSubGeoSet.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)accId + countryGeoMap.get(countryStr) + countrySubGeoMap.get(countryStr));
                                                    }
                                                }
                                            }
                                            channelprgIdAccIdGeoSubGeoSet.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)expt.Core_MDF_Account_id__c + countryGeoMap.get(countryStr) + countrySubGeoMap.get(countryStr));
                                            
                                            
                                            for(String channelprgIdAccIdGeoSubGeoKey : channelprgIdAccIdGeoSubGeoSet){
                                                //Geo and SubGeo //if already the key exists, then add the Exception to the already existing Exception Set 
                                                if(channelPrgIdAccIdGeoSubGeoExptSetMap.containsKey(channelprgIdAccIdGeoSubGeoKey)){channelPrgIdAccIdGeoSubGeoExptSetMap.get(channelprgIdAccIdGeoSubGeoKey).add(expt);
                                                }
                                                else{//otherwise add the exception to the new set and then add it to the Map
                                                    channelPrgIdAccIdGeoSubGeoExptSetMap.put(channelprgIdAccIdGeoSubGeoKey, exptSet );
                                                } 
                                            }
                                        }
                                    
                                    
                                    if(exptIdGeoSetMap.containsKey(expt.Id)){Set<String> existingGeoSet = exptIdGeoSetMap.get(expt.Id);existingGeoSet.add(countryGeoMap.get(countryStr));exptIdGeoSetMap.put(expt.Id, existingGeoSet);
                                                                            }
                                    else{
                                        Set<String> existingGeoSet = new Set<String>();
                                        existingGeoSet.add(countryGeoMap.get(countryStr));
                                        exptIdGeoSetMap.put(expt.Id, existingGeoSet);
                                    }
                                    // Constructing Map Key with ChannelProgramId, AccountId and Single Geo
                                    Set<String> channelprgIdAccIdGeoSet = new Set<String>();
                                    //add the comments
                                    If(expt.Core_MDF_Program_txt__c == Label.Core_MDF_EEF_RecordType){
                                        //Added for EEF - Activating
                                        //preparing the channelprgIdAccIdGeoSet for EEF Activating Account
                                        if(!mapOfExpIdToActAccId.isEmpty() && mapOfExpIdToActAccId.size() >0){
                                            for(Id accId : mapOfExpIdToActAccId.get(expt.Id)){
                                                channelprgIdAccIdGeoSet.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)accId + countryGeoMap.get(countryStr));
                                            } 
                                        }
                                        //Added for EEF - Primary
                                        //preparing the channelprgIdAccIdGeoSet for EEF Primary Account
                                        if(!mapOfExpIdToPrimaryAccId.isEmpty() && mapOfExpIdToPrimaryAccId.size()>0){
                                            for(Id accId : mapOfExpIdToPrimaryAccId.get(expt.Id)){channelprgIdAccIdGeoSet.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)accId + countryGeoMap.get(countryStr));
                                            }
                                        }
                                        
                                    }
                                    channelprgIdAccIdGeoSet.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)expt.Core_MDF_Account_id__c + countryGeoMap.get(countryStr));
                                    
                                    
                                    for(String channelprgIdAccIdGeoKey : channelprgIdAccIdGeoSet){
                                        //Only Geo
                                        if(channelPrgIdAccIdGeoExptSetMap.containsKey(channelprgIdAccIdGeoKey)){//if already the key exists, then add the Exception to the already existing Exception Set.
                                            channelPrgIdAccIdGeoExptSetMap.get(channelprgIdAccIdGeoKey).add(expt);
                                        }
                                        else{//otherwise add the exception to the new set and then add it to the Map
                                            channelPrgIdAccIdGeoExptSetMap.put(channelprgIdAccIdGeoKey, exptSet );
                                        }
                                    }
                                    
                                    //for WW
                                    Set<String> channelprgIdAccIdSet = new Set<String>();
                                    
                                    If(expt.Core_MDF_Program_txt__c == Label.Core_MDF_EEF_RecordType){
                                        //preparing the channelprgIdAccIdGeoSet for EEF Activating Account
                                        if(!mapOfExpIdToActAccId.isEmpty() && mapOfExpIdToActAccId.size()>0){
                                            for(Id accId : mapOfExpIdToActAccId.get(expt.Id)){
                                                channelprgIdAccIdSet.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)accId);
                                            }   
                                        }
                                        
                                        //preparing the channelprgIdAccIdGeoSet for EEF Priamary Account
                                        if(!mapOfExpIdToPrimaryAccId.isEmpty() && mapOfExpIdToPrimaryAccId.size()>0){
                                            for(Id accId : mapOfExpIdToPrimaryAccId.get(expt.Id)){channelprgIdAccIdSet.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)accId);
                                            }
                                        }
                                        
                                    }
                                    channelprgIdAccIdSet.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)expt.Core_MDF_Account_id__c);
                                    
                                    
                                    for(String channelprgIdAccIdGeoKey : channelprgIdAccIdSet){
                                        if(channelPrgIdAccIdWWExptSetMap.containsKey(channelprgIdAccIdGeoKey)){//if already the key exists, then add the Exception to the already existing Exception Set.
                                            channelPrgIdAccIdWWExptSetMap.get(channelprgIdAccIdGeoKey).add(expt);
                                        }
                                        else{//otherwise add the exception to the new set and then add it to the Map
                                            channelPrgIdAccIdWWExptSetMap.put(channelprgIdAccIdGeoKey, exptSet );
                                        }
                                    }
                                    
                                }
                                
                            }
                        }
                        //Account       Country
                        //Single        All
                        //if all country checkbox is set to true
                        else if(allCountry){//Check if it is All Country
                            Set<Core_MDF_Exception_Account_Mapping__c> exptSet = new Set<Core_MDF_Exception_Account_Mapping__c >{expt};
                                
                                //Added for EEF
                                // Constructing Map Key with ChannelProgramId and AccountId
                                Set<String> channelprgIdAccIdSet = new Set<String>();
                            
                            If(expt.Core_MDF_Program_txt__c == Label.Core_MDF_EEF_RecordType){
                                //Added for EEF - Activating
                                if(!mapOfExpIdToActAccId.isEmpty() && mapOfExpIdToActAccId.size()>0){
                                    for(Id accId : mapOfExpIdToActAccId.get(expt.Id)){channelprgIdAccIdSet.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)accId);
                                    } 
                                }
                                
                                //Added for EEF - Primary
                                if(!mapOfExpIdToPrimaryAccId.isEmpty() && mapOfExpIdToPrimaryAccId.size()>0){
                                    for(Id accId : mapOfExpIdToPrimaryAccId.get(expt.Id)){channelprgIdAccIdSet.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)accId);
                                    }  
                                }
                                
                            }
                            channelprgIdAccIdSet.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)expt.Core_MDF_Account_id__c);
                            
                            
                            recordGeoShareListEAM.addAll(getRecordShareList(expt.Id, (String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c), geoSubGeoSetMap));
                            recordGeoShareList.addAll(getRecordShareList(expt.Core_MDF_Exception_id__c, (String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c), geoSubGeoSetMap));
                            for(String channelprgIdAccIdKey : channelprgIdAccIdSet){
                                if(channelPrgIdAccIdExptSetMap.containsKey(channelprgIdAccIdKey)){  channelPrgIdAccIdExptSetMap.get(channelprgIdAccIdKey).add(expt);
                                }
                                else{
                                    channelPrgIdAccIdExptSetMap.put(channelprgIdAccIdKey, exptSet );
                                }
                            }
                        }
                    } 
                    //Single Account+IPA+Host Region+BudgetType
                    if(!expt.Core_MDF_Select_All_Accounts_ind__c && expt.Core_MDF_Program_txt__c ==  IPA_RecordType){
                            for(String budgetTypeStr : expt.Core_MDF_Budget_Type_txt__c.split(';')){
                                //Sharing Record for Exception Account Mapping Object related to IPA Exception Account Mapping
                                //Preparing list to share with programGeoGroup Metadata
                                recordGeoShareListEAM.add(new Core_MDF_RecordGeoShare(expt.Id, expt.Core_MDF_HostRegion_txt__c, null,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c),budgetTypeStr));
                                
                                recordPGMShareListEAM.add(new Core_MDF_RecordPGMShareWrapper(expt.ID,expt.Core_MDF_HostRegion_txt__c,NULL,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c),budgetTypeStr,expt.Core_MDF_Account_id__c));
                                
                                //Single Account+IPA+WW+BudgetType 
                                //Preparing list to share with programGeoGroup Metadata
                                recordGeoShareListEAM.add(new Core_MDF_RecordGeoShare(expt.Id, STR_WW, null,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c),budgetTypeStr));
                                recordPGMShareListEAM.add(new Core_MDF_RecordPGMShareWrapper(expt.ID,STR_WW,NULL,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c),budgetTypeStr,expt.Core_MDF_Account_id__c));
                                
                                //Single Account+IPA+Region+
                                //Preparing list to share with programGeoGroup Metadata
                                recordGeoShareListEAM.add(new Core_MDF_RecordGeoShare(expt.Id, expt.Core_MDF_HostRegion_txt__c,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)));
                                //Preparing a key to share exception with PGM
                                recordPGMShareListEAM.add(new Core_MDF_RecordPGMShareWrapper(expt.ID,expt.Core_MDF_HostRegion_txt__c,NULL,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c),null,expt.Core_MDF_Account_id__c));
                                //Single Account+IPA+WW
                                //Preparing list to share with programGeoGroup Metadata
                                recordGeoShareListEAM.add(new Core_MDF_RecordGeoShare(expt.Id, STR_WW,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)));
                                //Preparing a key to share exception with PGM
                                recordPGMShareListEAM.add(new Core_MDF_RecordPGMShareWrapper(expt.ID,STR_WW,NULL,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c),null,expt.Core_MDF_Account_id__c)); 
                                
                                //Sharing Record for Exception Object related to IPA Exception
                                recordGeoShareList.add(new Core_MDF_RecordGeoShare(expt.Core_MDF_Exception_id__c, expt.Core_MDF_HostRegion_txt__c, null,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c),budgetTypeStr));
                                
                                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(expt.Core_MDF_Exception_id__c,expt.Core_MDF_HostRegion_txt__c,NULL,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c),budgetTypeStr,expt.Core_MDF_Account_id__c));
                                
                                //Single Account+IPA+WW+BudgetType 
                                //Preparing list to share with programGeoGroup Metadata
                                recordGeoShareList.add(new Core_MDF_RecordGeoShare(expt.Core_MDF_Exception_id__c, STR_WW, null,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c),budgetTypeStr));
                                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(expt.Core_MDF_Exception_id__c,STR_WW,NULL,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c),budgetTypeStr,expt.Core_MDF_Account_id__c));
                                
                                //Single Account+IPA+Region+
                                //Preparing list to share with programGeoGroup Metadata
                                recordGeoShareList.add(new Core_MDF_RecordGeoShare(expt.Core_MDF_Exception_id__c, expt.Core_MDF_HostRegion_txt__c,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)));
                                //Preparing a key to share exception with PGM
                                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(expt.Core_MDF_Exception_id__c,expt.Core_MDF_HostRegion_txt__c,NULL,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c),null,expt.Core_MDF_Account_id__c));
                                //Single Account+IPA+WW
                                //Preparing list to share with programGeoGroup Metadata
                                recordGeoShareList.add(new Core_MDF_RecordGeoShare(expt.Core_MDF_Exception_id__c, STR_WW,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)));
                                //Preparing a key to share exception with PGM
                                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(expt.Core_MDF_Exception_id__c,STR_WW,NULL,(String)channelProgramNameMap.get(expt.Core_MDF_Program_txt__c),null,expt.Core_MDF_Account_id__c)); 
                            
                            } 
                    }
                }
            }
            
            
            
            if(intelAccountIdSet != Null && intelAccountIdSet.size() > 0 ){ strAccountWHEREClause = ' AND Core_MDF_Account__c IN :intelAccountIdSet';
                                                                          }
            
            pgmQueryStr = 'SELECT Id, Core_MDF_Account__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Name, Core_MDF_BudgetType_nm__c , Core_MDF_Group_Id__c, ' +
                'Core_MDF_Group_Name__c, Core_MDF_Type_of_Access__c, Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c ' +
                'FROM Core_MDF_Partner_Group_Mapping__c ' +
                'WHERE Core_MDF_Channel_Program__c IN :exceptionChannelPrgIdsSet ' +
                'AND Core_MDF_Type_of_Access__c = ' + '\'' + 'Internal' + '\' ' +
                'AND Core_MDF_Region_cd__c != NULL ' +
                'AND Core_MDF_Inactive_Ind__c = false ' +
                'AND Core_MDF_Group_Id__c != NULL'+ String.escapeSingleQuotes(strAccountWHEREClause);
            for( Core_MDF_Partner_Group_Mapping__c pgm : Database.query(pgmQueryStr)){
                if(pgm.Core_MDF_Region_cd__c != 'WW'){//if PGM is not for Worldwide (WW)
                    if(pgm.Core_MDF_Channel_Program__r.Name == IPA_Program){
                        if(pgm.Core_MDF_BudgetType_nm__c != null && pgm.Core_MDF_Sub_Region_cd__c == null){//Sub Region is NULL
                            String programIdBudgetStr = (String)pgm.Core_MDF_Channel_Program__c +pgm.Core_MDF_Region_cd__c+pgm.Core_MDF_BudgetType_nm__c ;
                            if(channelPrgIdBudgetTypeExptSetMap.containsKey(programIdBudgetStr)){
                                for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdBudgetTypeExptSetMap.get(programIdBudgetStr)){
                                    if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){
                                        exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                                    }
                                }
                            }
                        }   
                        //All Account    geo+Program for IPA
                        if(pgm.Core_MDF_Sub_Region_cd__c == null && pgm.Core_MDF_BudgetType_nm__c == null){//Sub Region is NULL
                            String programIdGeoAllAccountStr = (String)pgm.Core_MDF_Channel_Program__c +pgm.Core_MDF_Region_cd__c ;
                            if(channelPrgIdGeoAllAccountExptSetMap.containsKey(programIdGeoAllAccountStr)){
                                for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdGeoAllAccountExptSetMap.get(programIdGeoAllAccountStr)){
                                    if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){
                                        exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                    }
                                }
                            }
                        }
                    }
                    if(pgm.Core_MDF_Sub_Region_cd__c == NULL && pgm.Core_MDF_Channel_Program__r.name != IPA_Program){//Sub Region is NULL
                        //Account       Country
                        //Single        Multi
                        String programIdAccountIdGeoStr = (String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c + pgm.Core_MDF_Region_cd__c;
                        if(channelPrgIdAccIdGeoExptSetMap.containsKey(programIdAccountIdGeoStr)){
                            for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdAccIdGeoExptSetMap.get(programIdAccountIdGeoStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){
                                    exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c)); exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                }
                            }
                        }
                        //Account       Country
                        //Single        All
                        String programIdAccountIdStr = (String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c;
                        if(channelPrgIdAccIdExptSetMap.containsKey(programIdAccountIdStr)){
                            for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdAccIdExptSetMap.get(programIdAccountIdStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){
                                    exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                }
                                
                            }
                            
                        }
                        //Account       Country
                        //All           Multi
                        String programIdGeoStr = (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                        if(channelPrgIdGeoExptSetMap.containsKey(programIdGeoStr)){
                            for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdGeoExptSetMap.get(programIdGeoStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                }
                            }
                        }
                        //Account       Country
                        //All           All
                        String programIdStr = (String)pgm.Core_MDF_Channel_Program__c;
                        if(channelPrgIdExptSetMap.containsKey(programIdStr)){
                            for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdExptSetMap.get(programIdStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                }
                            }
                        }
                    }
                    else{//Sub Region is NOT NULL
                        //Account       Country
                        //Single        Multi
                        String programIdAccountIdGeoSubGeoStr = (String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                        if(channelPrgIdAccIdGeoSubGeoExptSetMap.containsKey(programIdAccountIdGeoSubGeoStr) && pgm.Core_MDF_Channel_Program__r.name != IPA_Program){
                            for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdAccIdGeoSubGeoExptSetMap.get(programIdAccountIdGeoSubGeoStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                                                                                                          }
                            }
                        }
                        
                        //Account       Country
                        //Single        All
                        String programIdAccountIdStr = (String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c;
                        if(channelPrgIdAccIdExptSetMap.containsKey(programIdAccountIdStr) &&  pgm.Core_MDF_Channel_Program__r.name != IPA_Program){
                            for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdAccIdExptSetMap.get(programIdAccountIdStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                                                                                                          }
                            }
                        }
                        
                        //Account       Country
                        //All           Multi
                        String programIdGeoSubGeoStr = (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                        if(channelPrgIdGeoSubGeoExptSetMap.containsKey(programIdGeoSubGeoStr) &&  pgm.Core_MDF_Channel_Program__r.name != IPA_Program){
                            for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdGeoSubGeoExptSetMap.get(programIdGeoSubGeoStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                                                                                                          }
                            }
                        }
                        
                        //Account       Country
                        //All           All
                        String programIdStr = (String)pgm.Core_MDF_Channel_Program__c;
                        if(channelPrgIdExptSetMap.containsKey(programIdStr) &&  pgm.Core_MDF_Channel_Program__r.name != IPA_Program){
                            for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdExptSetMap.get(programIdStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                                                                                                                          }
                            }
                        }
                    }
                }
                else{//if PGM is for Worldwide (WW)
                    //All Account
                    if(pgm.Core_MDF_Channel_Program__r.Name == IPA_Program){
                        if(pgm.Core_MDF_Sub_Region_cd__c == null){
                            if(pgm.Core_MDF_BudgetType_nm__c != null){//Sub Region is NULL
                                String programIdBudgetStr = (String)pgm.Core_MDF_Channel_Program__c +STR_WW+pgm.Core_MDF_BudgetType_nm__c ;
                                if(channelPrgIdWWAllBudTypeAccountExptSetMap.containsKey(programIdBudgetStr)){
                                    for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdWWAllBudTypeAccountExptSetMap.get(programIdBudgetStr)){
                                        if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                        }
                                    }
                                }
                            }
                            //All Account    WW+Program for IPA
                            if(pgm.Core_MDF_BudgetType_nm__c == null){//Sub Region is NULL
                                String programIdGeoAllAccountStr = (String)pgm.Core_MDF_Channel_Program__c +STR_WW;
                                if(channelPrgIdWWAllAccountExptSetMap.containsKey(programIdGeoAllAccountStr)){
                                    for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdWWAllAccountExptSetMap.get(programIdGeoAllAccountStr)){
                                        if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){ exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else{
                        String programIdAccountIdWW = (String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c;
                        if(channelPrgIdAccIdWWExptSetMap.containsKey(programIdAccountIdWW)){
                            for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdAccIdWWExptSetMap.get(programIdAccountIdWW)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){
                                    exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);
                                    exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                                    exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                }
                            }
                        }
                        //Account       Country
                        //All           Multi
                        String programIdWWStr = (String)pgm.Core_MDF_Channel_Program__c;
                        if(channelPrgIdWWExptSetMap.containsKey(programIdWWStr)){
                            for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdWWExptSetMap.get(programIdWWStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){
                                    exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));
                                    exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                }
                            }
                        }
                        
                        //Account       Country
                        //Single        All
                        String programIdAccountIdStr = (String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c;
                        if(channelPrgIdAccIdExptSetMap.containsKey(programIdAccountIdStr)){
                            for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdAccIdExptSetMap.get(programIdAccountIdStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                                                                                                          }
                            }
                        }
                        
                        //Account       Country
                        //All           All
                        String programIdStr = (String)pgm.Core_MDF_Channel_Program__c;
                        if(channelPrgIdExptSetMap.containsKey(programIdStr)){
                            for(Core_MDF_Exception_Account_Mapping__c expt : channelPrgIdExptSetMap.get(programIdStr)){
                                if(!exceptionIdGroupIdStrSet.contains((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c)){
                                    exceptionIdGroupIdStrSet.add((String)expt.Id + (String)pgm.Core_MDF_Group_Id__c);exptAccMapShareSet.add(createExceptionAccShareInternal(expt.Id, pgm.Core_MDF_Group_Id__c));exptShareSet.add(createExceptionShareInternal(expt.Core_MDF_Exception_id__c, pgm.Core_MDF_Group_Id__c));
                                }
                            }
                        }
                    }
                }
            }
            //Insert Share Records For the Exception
            if(exptAccMapShareSet != NULL && exptAccMapShareSet.size() > 0){
                List < Core_MDF_Exception_Account_Mapping__Share > exptAccMapShareList = new List< Core_MDF_Exception_Account_Mapping__Share >();
                exptAccMapShareList.addAll(exptAccMapShareSet);
                
                if(!System.isBatch() && exptAccMapShareList.size() > BATCH_LIMIT ) {Database.executeBatch(new Core_MDF_BulkInsert_Batch(exptAccMapShareList), EXCEPTION_SHARE_INSERT_BATCH_LIMIT);
                }
                else{
                    database.insert(exptAccMapShareList , false);
                    
                } 
                
            }
            
            if(exptShareSet != NULL && exptShareSet.size() > 0){
                List < Core_MDF_Exception__Share > exptShareList = new List< Core_MDF_Exception__Share >();
                exptShareList.addAll(exptShareSet);
                
                if(!System.isBatch() && exptShareList.size() > BATCH_LIMIT ) {Database.executeBatch(new Core_MDF_BulkInsert_Batch(exptShareList), EXCEPTION_SHARE_INSERT_BATCH_LIMIT);
                }
                else{
                    database.insert(exptShareList, false);
                    
                } 
                
            }
            
            if(recordGeoShareList != NULL && recordGeoShareList.size() >0){
                Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroup('Core_MDF_Exception_Account_Mapping__c', recordGeoShareListEAM);
                Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroup('Core_MDF_Exception__c', recordGeoShareList);
            }
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Core_MDF_Exception_Account_Mapping__c', recordPGMShareListEAM);Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Core_MDF_Exception__c', recordPGMShareList);

            } }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
                           }
    }
     /****************************************************************************************************************************************
* Metthod Name        : prepareDataSetForValidation
* Created Date      :  10/5/2025
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture Mohit         10/5/2025     Method to create datasets for using in sharing logic
*****************************************************************************************************************************************/
    public static ExceptionDataSetWrapper prepareDataSetForValidation(List<Core_MDF_Exception_Account_Mapping__c> newExceptionList)
    {
        
        ExceptionDataSetWrapper excpDataWrapper = new ExceptionDataSetWrapper();
        Map<String,String> channelProgramNameMap = new Map<String,String>();
        Map<String,String> countryGeoMap  = new Map<String,String>();
        Set<Id> intelAccountIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>(); 
        Set<Id> programIdRMFSet = new Set<Id>();
        Boolean queryNodeGrp = false;
        Boolean blnAllAccountsFlag = false;
        Map<Id,Set<String>> accountIdProgramStrSetMap = new Map<Id,Set<String>>(); 
        Map<String,String> channelProgramNameIdMap = new Map<String,String>();
        Map<String,String> AccountIdGroupIdMap = new Map<String,String>();
        Map<String,String> countrySubGeoMap = new Map<String,String>();
        Map<String,Set<String>> geoSubGeoSetMap = new Map<String,Set<String>>();
        
        String strAccountWHEREClause = '';
        String AccQueryStr = '';
        Set<String> subGeoStringSet;
        
        /*for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem : ([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c, Core_MDF_Entitlement_Name__c
                                                                   FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt])){
                                                                       channelProgramNameMap.put(bpem.Core_MDF_Bank_Program_Name__c , bpem.Core_MDF_Channel_Program__c);
                                                                   }*/
        for(Core_MDF_ChannelProgram__mdt bpem : ([SELECT Label, Core_MDF_Bank_Program_Value__c FROM Core_MDF_ChannelProgram__mdt LIMIT 1000])){
                channelProgramNameMap.put(bpem.Core_MDF_Bank_Program_Value__c , bpem.Label);
            }//Core_MDF_BankProgram_Entitlement_Mapping__mdt optimization
        
        //Get Channel program Id and Core_MDF name
        for (ChannelProgram cpList : [SELECT Id, Name
                                      FROM ChannelProgram
                                      WHERE Name =: channelProgramNameMap.values()
                                      ORDER BY CreatedDate] ){
                                          channelProgramNameIdMap.put( cpList.Name , cpList.Id );
                                      }
        
        //Get the Map of Country code and Geo using Country Geo Mapping Metadata
        for(Core_MDF_CCP_Country_Geo_Mapping__mdt cgm : [SELECT MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c
                                                         FROM Core_MDF_CCP_Country_Geo_Mapping__mdt where Core_MDF_Geo__c != '0']){
                                                             countryGeoMap.put(cgm.MasterLabel,cgm.Core_MDF_Geo__c);
                                                             countrySubGeoMap.put(cgm.MasterLabel,cgm.Core_MDF_Sub_Geo__c);
                                                             if(geoSubGeoSetMap.containsKey(cgm.Core_MDF_Geo__c)){
                                                                 if(!geoSubGeoSetMap.get(cgm.Core_MDF_Geo__c).contains(cgm.Core_MDF_Sub_Geo__c)){
                                                                     subGeoStringSet = new Set<String>();
                                                                     subGeoStringSet = geoSubGeoSetMap.get(cgm.Core_MDF_Geo__c);
                                                                     subGeoStringSet.add(cgm.Core_MDF_Sub_Geo__c);
                                                                     geoSubGeoSetMap.put(cgm.Core_MDF_Geo__c, subGeoStringSet);
                                                                 }
                                                             }
                                                             else{
                                                                 subGeoStringSet = new Set<String>();
                                                                 subGeoStringSet.add(cgm.Core_MDF_Sub_Geo__c);
                                                                 geoSubGeoSetMap.put(cgm.Core_MDF_Geo__c, subGeoStringSet);
                                                             }
                                                         }
        // To check whether the user has geo access for which he is creating exception
        for(Core_MDF_Exception_Account_Mapping__c expt : newExceptionList){
            if(expt.Core_MDF_Program_txt__c != NULL){
                programIdSet.add(channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)));
                if (expt.Core_MDF_Program_txt__c == 'Core_MDF_Retail_Marketing_Funds'){
                    queryNodeGrp = true;
                    programIdRMFSet.add(channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)));}
            }
            if(expt.Core_MDF_Account_id__c != NULL){
                intelAccountIdSet.add(expt.Core_MDF_Account_id__c);
            }
            if(expt.Core_MDF_Select_All_Accounts_ind__c){blnAllAccountsFlag = true;
            }
        }
        
        
        if(intelAccountIdSet!=Null  && intelAccountIdSet.size()>0){ strAccountWHEREClause = 'OR ' +'(' +'Core_MDF_Channel_Program__c IN :programIdSet ' + 'AND ' + '(' + 'Core_MDF_CoMarketing_Ultimate_Account__c IN :intelAccountIdSet ' +
            'OR Id IN :intelAccountIdSet' +')'+')';                
                                                                  }
        if ((blnAllAccountsFlag || queryNodeGrp) || !blnAllAccountsFlag )
        {
            AccQueryStr = 'SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program__c, ' +
                'Core_MDF_Channel_Program__r.Name, RecordType.DeveloperName, Core_MDF_Group_Id__c ' +
                'FROM Account ' +
                'WHERE Core_MDF_Channel_Program__c IN :programIdRMFSet ' +
                String.escapeSingleQuotes(strAccountWHEREClause);
        }
        
        for (Account childAccount : Database.query(AccQueryStr)){
            
            if (childAccount.RecordType.DeveloperName =='Core_MDF_Co_Marketing')
            {
                if (childAccount.Core_MDF_Group_Id__c!=Null && String.isNotBlank(childAccount.Core_MDF_Group_Id__c)){AccountIdGroupIdMap.put(childAccount.Id,childAccount.Core_MDF_Group_Id__c);
                }
                if(accountIdProgramStrSetMap.containsKey(childAccount.Id)){accountIdProgramStrSetMap.get(childAccount.Id).add(childAccount.Core_MDF_Channel_Program__c);
                                                                          }
                else{
                    accountIdProgramStrSetMap.put(childAccount.Id, new Set<String>{
                        childAccount.Core_MDF_Channel_Program__r.Name});
                }
                
            }
            else{
                if(accountIdProgramStrSetMap.containsKey(childAccount.Core_MDF_CoMarketing_Ultimate_Account__c)){accountIdProgramStrSetMap.get(childAccount.Core_MDF_CoMarketing_Ultimate_Account__c).add(childAccount.Core_MDF_Channel_Program__c);
                }
                else{
                    accountIdProgramStrSetMap.put(childAccount.Core_MDF_CoMarketing_Ultimate_Account__c, new Set<String>{
                        childAccount.Core_MDF_Channel_Program__r.Name});
                }
            }
        }
        excpDataWrapper.subGeoStringSet = subGeoStringSet;
        excpDataWrapper.channelProgramNameMap = channelProgramNameMap;
        excpDataWrapper.countryGeoMap = countryGeoMap;
        excpDataWrapper.intelAccountIdSet = intelAccountIdSet;
        excpDataWrapper.programIdSet = programIdSet; 
        excpDataWrapper.programIdRMFSet = programIdRMFSet;
        excpDataWrapper.queryNodeGrp = queryNodeGrp;
        excpDataWrapper.blnAllAccountsFlag = blnAllAccountsFlag;
        excpDataWrapper.accountIdProgramStrSetMap = accountIdProgramStrSetMap; 
        excpDataWrapper.channelProgramNameIdMap = channelProgramNameIdMap;
        excpDataWrapper.AccountIdGroupIdMap = AccountIdGroupIdMap;
        excpDataWrapper.countrySubGeoMap = countrySubGeoMap;
        excpDataWrapper.geoSubGeoSetMap = geoSubGeoSetMap;
        excpDataWrapper.strAccountWHEREClause = strAccountWHEREClause;
        return excpDataWrapper;
        
    }
    public class ExceptionDataSetWrapper
    {   
        public Map<String,String> channelProgramNameMap;
        public Map<String,String> countryGeoMap;
        public Set<Id> intelAccountIdSet;
        public Set<Id> programIdSet; 
        public Set<Id> programIdRMFSet;
        public Boolean queryNodeGrp;
        public Boolean blnAllAccountsFlag;
        public Map<Id,Set<String>> accountIdProgramStrSetMap; 
        public Map<String,String> channelProgramNameIdMap;
        public Map< String,String > AccountIdGroupIdMap;
        public Map<String,String> countrySubGeoMap;
        public Map<String,Set<String>> geoSubGeoSetMap;
        public Set<String> subGeoStringSet;
        public String strAccountWHEREClause;
    }
    
    public class ExceptionEEFDataWrapper
    {   
        public Map<Id,List<Id>> mapOfExpIdToPrimaryAccId;
        public Map<Id,List<Id>> mapOfExpIdToActAccId;
        public Set<Id> intelAccountIdSet;
    }
    
      /****************************************************************************************************************************************
* Method Name           : createExceptionAccShareInternal
* Created Date          : 10/5/2025
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture SN         10/5/2025          Exception Account Mapping Share creations
*****************************************************************************************************************************************/
    public static Core_MDF_Exception_Account_Mapping__Share createExceptionAccShareInternal(String exceptionId, String ugId){
        Core_MDF_Exception_Account_Mapping__Share expShare = new Core_MDF_Exception_Account_Mapping__Share();
        expShare.ParentId = exceptionId;
        expShare.RowCause = 'Manual';
        expShare.AccessLevel = 'Edit';
        expShare.UserOrGroupId = ugId;
        return expShare;
    }
    
/****************************************************************************************************************************************
* Method Name           : createExceptionShareInternal
* Created Date          : 10/5/2025
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture SN         10/5/2025         Exception Share creations
*****************************************************************************************************************************************/
    public static Core_MDF_Exception__Share createExceptionShareInternal(String exceptionId, String ugId){
        Core_MDF_Exception__Share expShare = new Core_MDF_Exception__Share();
        expShare.ParentId = exceptionId;
        expShare.RowCause = 'Manual';
        expShare.AccessLevel = 'Edit';
        expShare.UserOrGroupId = ugId;
        return expShare;
    }
/*****************************************************************************************************
Method Name:        getRecordShareList
@return  :          List<Core_MDF_RecordGeoShare>
@parameters:        Id - recordId
String - Name of the Program
Map<String,Set<String>> - Map of Geo and its related SubGeos
Description:        This method is used to fetch the Record Geo Share List. This will be used for the records which does not have any Country.
Added By:           Accenture Mohit
Modified By:        Date: 10/5/2025      Changes:
******************************************************************************************************/
    public static List<Core_MDF_RecordGeoShare> getRecordShareList(Id recordId, String programName, Map<String,Set<String>> geoSubGeoSetMap){
        List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
        for(String geoStr : geoSubGeoSetMap.keySet()){
            for(String subGeoStr : geoSubGeoSetMap.get(geoStr)){
                recordGeoShareList.add(new Core_MDF_RecordGeoShare(recordId, geoStr, subGeoStr, programName));
            }
        }
        return recordGeoShareList;
    }
    
 /****************************************************************************************************************************************
* Metthod Name        : prepareDataForEEFSharing
* Created Date      : 10/5/2025
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture Mohit        10/5/2025   Method to prepare Data for Sharing EEF Records.
*****************************************************************************************************************************************/
    public static ExceptionEEFDataWrapper prepareDataForEEFSharing(List<Core_MDF_Exception_Account_Mapping__c> newExceptionList,Map<Id, List<String>> accIdToPartnerTypeMap)
    {
        ExceptionEEFDataWrapper excpEEFWrapper = new ExceptionEEFDataWrapper();
        Map<Id,List<Id>> mapOfPrimaryAccToExp = new Map<Id,List<Id>>();
        Map<Id,List<Id>> mapOfActiavtingAccToExp = new Map<Id,List<Id>>();
        
        Set<Id> priamryAccIdSet = new Set<Id>();//set to store Primary Account Id 
        Set<Id> activatingAccIdSet = new Set<Id>();//set to store Activating Account Id
        Set<Id> intelAccountIdSet = new Set<Id>();//set to store intel account Id
        
        Map<Id,List<Id>> mapOfExpIdToActAccId = new Map<Id,List<Id>>();//map to store exception id and exception account id
        Map<Id,List<Id>> mapOfExpIdToPrimaryAccId = new Map<Id,List<Id>>();//map to store exception id and primary account id
        Map<Id,List<Id>> mapOfPrimaryAccToActivating = new Map<Id,List<Id>>();//map to store Primary Acc Id and its associated activating account id.
        Map<Id,List<Id>> mapOfActivatingAccToPrimary = new Map<Id,List<Id>>();//map to store Activating Acc Id and its associated primary account id.
        for(Core_MDF_Exception_Account_Mapping__c expt : newExceptionList){
            if(expt.Core_MDF_Program_txt__c == Label.Core_MDF_EEF_RecordType){ 
                intelAccountIdSet.add(expt.Core_MDF_Account_id__c);
                if(accIdToPartnerTypeMap.containsKey(expt.Core_MDF_Account_id__c)){
                    for(String accType : accIdToPartnerTypeMap.get(expt.Core_MDF_Account_id__c)){
                        if(accType== Core_MDF_CCP_ConstantClass.PRIMARY_PARTNER){ 
                            //preparing a map of Primary Account and its associated exception records.
                            priamryAccIdSet.add(expt.Core_MDF_Account_id__c);
                            if(!mapOfPrimaryAccToExp.containsKey(expt.id)){
                                mapOfPrimaryAccToExp.put(expt.id, new List<Id>{expt.Core_MDF_Account_id__c});
                            }
                            mapOfPrimaryAccToExp.get(expt.id).add(expt.Core_MDF_Account_id__c);
                        }
                        else{activatingAccIdSet.add(expt.Core_MDF_Account_id__c);
                            //preparing a map of Activating Account and its associated exception records.
                            if(!mapOfActiavtingAccToExp.containsKey(expt.id)){mapOfActiavtingAccToExp.put(expt.id, new List<Id>{expt.Core_MDF_Account_id__c});}mapOfActiavtingAccToExp.get(expt.id).add(expt.Core_MDF_Account_id__c);
                        }                                
                    }
                }
            }
        }
        if(priamryAccIdSet.size()>0){
            //query to get the mapped activating partner ultimate account for primary account.
            for(Core_MDF_Partner_Mapping__c accId : [select Core_MDF_ActPartner_Ultimate_Acc_Id__c,Core_MDF_PrimPartner_Ultimate_Acc_Id__c from Core_MDF_Partner_Mapping__c where 
                                                     Core_MDF_PrimPartner_Ultimate_Acc_Id__c IN: priamryAccIdSet]){
                                                         if(!mapOfPrimaryAccToActivating.containsKey(accId.Core_MDF_PrimPartner_Ultimate_Acc_Id__c)){
                                                             mapOfPrimaryAccToActivating.put(accId.Core_MDF_PrimPartner_Ultimate_Acc_Id__c, new List<Id>{accId.Core_MDF_ActPartner_Ultimate_Acc_Id__c});
                                                         }
                                                         mapOfPrimaryAccToActivating.get(accId.Core_MDF_PrimPartner_Ultimate_Acc_Id__c).add(accId.Core_MDF_ActPartner_Ultimate_Acc_Id__c);
                                                         
                                                     }
        }
        if(activatingAccIdSet.size()>0){
            //query to get the mapped primary partner ultimate account for activating account.
            for(Core_MDF_Partner_Mapping__c accId : [select Core_MDF_PrimPartner_Ultimate_Acc_Id__c,Core_MDF_ActPartner_Ultimate_Acc_Id__c from Core_MDF_Partner_Mapping__c where Core_MDF_ActPartner_Ultimate_Acc_Id__c IN: activatingAccIdSet]){
                                                        if(!mapOfActivatingAccToPrimary.containsKey(accId.Core_MDF_PrimPartner_Ultimate_Acc_Id__c)){mapOfActivatingAccToPrimary.put(accId.Core_MDF_ActPartner_Ultimate_Acc_Id__c, new List<Id>{accId.Core_MDF_PrimPartner_Ultimate_Acc_Id__c});
                                                         }mapOfActivatingAccToPrimary.get(accId.Core_MDF_ActPartner_Ultimate_Acc_Id__c).add(accId.Core_MDF_PrimPartner_Ultimate_Acc_Id__c);
                                                         
                                                     }
        }
        //checking the size of mapOfPrimaryAccToExp to populate intelAccountIdSet
        if(!mapOfPrimaryAccToExp.isEmpty() && mapOfPrimaryAccToExp.size () >0){//Map- Key=exp id, value= associated acc (primary)
            for(Id expId : mapOfPrimaryAccToExp.keyset()){ // Itertaing the Keys of the map where we have the mapping of exp id with the primary acc
                for(Id accId : mapOfPrimaryAccToExp.get(expId)){ // Itertaing the values of the map where we have the mapping of exp id with the primary acc
                    if(mapOfPrimaryAccToActivating!=null && mapOfPrimaryAccToActivating.get(accId)!=null && 
                       mapOfPrimaryAccToActivating.containskey(accId)){
                           for(Id actAccId : mapOfPrimaryAccToActivating.get(accId)){
                               if(!mapOfExpIdToActAccId.containsKey(expId)){
                                   mapOfExpIdToActAccId.put(expId, new List<Id>{actAccId});
                               }else{
                                   mapOfExpIdToActAccId.get(expId).add(actAccId);   
                               }  
                               intelAccountIdSet.add(actAccId);                                  
                           }
                       }                      
                }
                
            }
        }
        
        //checking the size of mapOfActiavtingAccToExp to populate intelAccountIdSet
        if(!mapOfActiavtingAccToExp.isEmpty() && mapOfActiavtingAccToExp.size() > 0){
            for(Id expId : mapOfActiavtingAccToExp.keyset()){ // Itertaing the Keys of the map where we have the mapping of exp id with the primary acc
                for(Id accId : mapOfActiavtingAccToExp.get(expId)){ // Itertaing the values of the map where we have the mapping of exp id with the primary acc
                    if(mapOfActivatingAccToPrimary!=null && mapOfActivatingAccToPrimary.get(accId)!=null && mapOfActivatingAccToPrimary.containskey(accId)){
                           for(Id primaryAccId : mapOfActivatingAccToPrimary.get(accId)){
                               if(!mapOfExpIdToPrimaryAccId.containsKey(expId)){mapOfExpIdToPrimaryAccId.put(expId, new List<Id>{primaryAccId});
                               }else{mapOfExpIdToPrimaryAccId.get(expId).add(primaryAccId);   
                               }  intelAccountIdSet.add(primaryAccId);                                  
                           }
                       }
                }                        
            }
            
        }
        excpEEFWrapper.intelAccountIdSet = intelAccountIdSet;
        excpEEFWrapper.mapOfExpIdToActAccId = mapOfExpIdToActAccId;
        excpEEFWrapper.mapOfExpIdToPrimaryAccId = mapOfExpIdToPrimaryAccId;
        return excpEEFWrapper;
    }
    
 /****************************************************************************************************************************************
* Method Name           : validateActiveEAM
* Created Date          : 24-03-2025
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture SB        24-03-2025         Validate on EAM inactivation if atleast one active EAM exist or no case mapping exist associated to that account.
*****************************************************************************************************************************************/  
    public static void validateActiveEAM(Map<Id,Core_MDF_Exception_Account_Mapping__c> newMapEAM,Map<Id,Core_MDF_Exception_Account_Mapping__c> oldMapEAM){
        set<Id> exptIds = new set<Id>();
        set<Id> eamIds = new set<Id>();
        set<Id> accIds = new set<Id>();
        set<Id> ultimateAccIds = new set<Id>();
        Map<String,Boolean> exptAccMapToCaseMap = new Map<String,Boolean>();
        Map<Id, Boolean> expttoActiveEamMap = new Map<Id, Boolean>();
        try{
            for(Core_MDF_Exception_Account_Mapping__c eamOnUpdate: newMapEAM.values()){
                if(eamOnUpdate.Core_MDF_Active_ind__c == false &&
                   eamOnUpdate.Core_MDF_Active_ind__c != oldMapEAM.get(eamOnUpdate.id).Core_MDF_Active_ind__c){
                       exptIds.add(eamOnUpdate.Core_MDF_Exception_id__c);eamIds.add(eamOnUpdate.id);
                       expttoActiveEamMap.put(eamOnUpdate.Core_MDF_Exception_id__c,false);accIds.add(eamOnUpdate.Core_MDF_Account_id__c);
                       string exptIdAccidKeySet = (string)eamOnUpdate.Core_MDF_Exception_id__c+(string)eamOnUpdate.Core_MDF_Account_id__c;
                       exptAccMapToCaseMap.put(exptIdAccidKeySet,false);
                  }
            }
            if(!exptIds.isEmpty()){
                for(Core_MDF_Exception_Account_Mapping__c eam: [Select id,Core_MDF_Exception_id__c FROM Core_MDF_Exception_Account_Mapping__c 
                                                                Where Core_MDF_Active_ind__c = true and Core_MDF_Exception_id__c IN: exptIds and Id Not IN: eamIds]){
                                                                    if(expttoActiveEamMap.containskey(eam.Core_MDF_Exception_id__c)){expttoActiveEamMap.put(eam.Core_MDF_Exception_id__c,true);
                                                                    }
                                                                }
                string key;
                for(Core_MDF_Exception_Case_Mapping__c  ecmMap: [SELECT Id, Core_MDF_Case_id__c,Core_MDF_Case_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Exception_id__c,Core_MDF_Case_id__r.AccountId,Core_MDF_Program_txt__c
                                                                FROM Core_MDF_Exception_Case_Mapping__c WHERE (Core_MDF_Case_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c IN: accIds OR Core_MDF_Case_id__r.AccountId IN: accIds) AND Core_MDF_Exception_id__c IN: exptIds]){
                                                                    if(ecmMap.Core_MDF_Program_txt__c == 'Core_MDF_Retail_Marketing_Funds'){
                                                                        key = (string)ecmMap.Core_MDF_Exception_id__c+(string)ecmMap.Core_MDF_Case_id__r.AccountId;
                                                                        if(exptAccMapToCaseMap.containskey(key)){exptAccMapToCaseMap.put(key,true);
                                                                        }
                                                                    }else{key = (string)ecmMap.Core_MDF_Exception_id__c+(string)ecmMap.Core_MDF_Case_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c;if(exptAccMapToCaseMap.containskey(key)){exptAccMapToCaseMap.put(key,true);
                                                                        }
                                                                    }
                                                                }
            }
            for(Core_MDF_Exception_Account_Mapping__c eamOnUpdate: newMapEAM.values()){
                string exptIdAccIdKey = (string)eamOnUpdate.Core_MDF_Exception_id__c + (string)eamOnUpdate.Core_MDF_Account_id__c;
                if(!expttoActiveEamMap.isEmpty() && expttoActiveEamMap.containskey(eamOnUpdate.Core_MDF_Exception_id__c) && expttoActiveEamMap.get(eamOnUpdate.Core_MDF_Exception_id__c)==false){
                    eamOnUpdate.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EAM_Inactivation_Error'));
                }
                
                if(!exptAccMapToCaseMap.isEmpty() && exptAccMapToCaseMap.containskey(exptIdAccIdKey) && exptAccMapToCaseMap.get(exptIdAccIdKey)==true){
                    eamOnUpdate.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EAM_Case_Inactivation_Error'));
                }
            }}catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
     /****************************************************************************************************************************************
* Metthod Name        : prepareAccountTypeForException
* Created Date        : 17/9/2024 
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture Mohit         24/03/2025    Method to prepare Map of Ultimate Exception AccountId and Partner Type
*****************************************************************************************************************************************/  
    public static void prepareAccountTypeForException(List<Core_MDF_Exception_Account_Mapping__c> exceptionList,Map<Id,Core_MDF_Exception_Account_Mapping__c> oldExceptionMap){
        
        String CO_MARKETING_ACCOUNT = Core_MDF_CCP_ConstantClass.CO_MARKETING_ACCOUNT;
        String INTEL_ACCOUNT = Core_MDF_CCP_ConstantClass.INTEL_ACCOUNT;
        
        String PRIMARY_PARTNER = Core_MDF_CCP_ConstantClass.PRIMARY_PARTNER;
        
        List<Core_MDF_Exception_Account_Mapping__c> listOfException = new List<Core_MDF_Exception_Account_Mapping__c>();
        //Map<Id,List<string>> accIdToPartnerTypeMap = new Map<Id,List<string>>();
        try{
            
            if(accIdToPartnerTypeMap.isEmpty()){
                //iterate on the incoming exception list
                for(Core_MDF_Exception_Account_Mapping__c itrOnExcep : exceptionList){
                    //compare the program name and check if the exception account is not null
                    if(itrOnExcep.Core_MDF_Program_nm__c == Label.Core_MDF_EEF_RecordType && itrOnExcep.Core_MDF_Account_id__c != NULL && (oldExceptionMap == NULL || ( oldExceptionMap != NULL && oldExceptionMap.containsKey(itrOnExcep.Id) && itrOnExcep.Core_MDF_Account_id__c != oldExceptionMap.get(itrOnExcep.Id).Core_MDF_Account_id__c))){
                                                        //prepare a map of Exception Account and List of Exceptions
                                                        if(!ultimateAccountIdToExceptionMap.containskey(itrOnExcep.Core_MDF_Account_id__c)){
                                                            ultimateAccountIdToExceptionMap.put(itrOnExcep.Core_MDF_Account_id__c, new List<Core_MDF_Exception_Account_Mapping__c>{itrOnExcep});
                                                        }else{ultimateAccountIdToExceptionMap.get(itrOnExcep.Core_MDF_Account_id__c).add(itrOnExcep);
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
            }}catch(Exception ex){Core_MDF_CCP_UtilityClass.logError(ex);
        } 
    }
    
    public static void deleteShareRecord(List<sObject> records){
        try{
        if(!records.isEmpty() && records != null){
            if(!System.isBatch() && records.size() > BATCH_LIMIT ){Database.executeBatch(new Core_MDF_BulkDelete_Batch(records), EXCEPTION_SHARE_DEL_BATCH_LIMIT);
            }else{ delete records;}}}catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}   
    }
    
    public static void insertShareRecord(List<sObject> records){
        try{
        if(!records.isEmpty() && records != null){
            if(!System.isBatch() && records.size() > BATCH_LIMIT ) {Database.executeBatch(new Core_MDF_BulkInsert_Batch(records), EXCEPTION_SHARE_INSERT_BATCH_LIMIT);
            }else{
                database.insert(records , false);
            } 
        }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    public static void refreshExternalSharingForUpdatedEAM(
        Map<Id,Core_MDF_Exception_Account_Mapping__c> newEAMMap,
        Map<Id,Core_MDF_Exception_Account_Mapping__c> oldEAMMap
    ){
        Set<Id> exceptionIdsToRefresh = new Set<Id>();
        for(Core_MDF_Exception_Account_Mapping__c updatedEAM : newEAMMap.values()){
            Core_MDF_Exception_Account_Mapping__c oldEAM = oldEAMMap.get(updatedEAM.Id);
            if(updatedEAM.Core_MDF_Active_ind__c != oldEAM.Core_MDF_Active_ind__c
               || updatedEAM.Core_MDF_Exception_Status_txt__c != oldEAM.Core_MDF_Exception_Status_txt__c
               || updatedEAM.Core_MDF_Account_id__c != oldEAM.Core_MDF_Account_id__c
               || updatedEAM.Core_MDF_Program_txt__c != oldEAM.Core_MDF_Program_txt__c
               || updatedEAM.Core_MDF_Expose_Externally_ind__c != oldEAM.Core_MDF_Expose_Externally_ind__c){
                if(updatedEAM.Core_MDF_Exception_id__c != null){
                    exceptionIdsToRefresh.add(updatedEAM.Core_MDF_Exception_id__c);
                }
            }
        }
        if(!exceptionIdsToRefresh.isEmpty()){
            Map<Id,Core_MDF_Exception__c> exceptionsToRefresh = new Map<Id,Core_MDF_Exception__c>(
                [SELECT Id FROM Core_MDF_Exception__c WHERE Id IN :exceptionIdsToRefresh]
            );
            Core_MDF_Exception_TriggerServiceHandler.shareExceptionRecordsWithExtUsers(
                exceptionsToRefresh,
                exceptionsToRefresh,
                true
            );
        }
    }

       /****************************************************************************************************************************************
* Metthod Name        : shareRecordsWithExtUsers
* Created Date        : 12/20/2024 
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture Mohit         12/20/2024      Method to share exceptions and exception account mapping records with external user
*****************************************************************************************************************************************/ 
    public static void shareRecordsWithExtUsers(Map<Id,Core_MDF_Exception_Account_Mapping__c> newEAMmap){
        Map<String, Set<Core_MDF_Exception_Account_Mapping__c>> channelPrgIdAccIdExptSetMap = new Map<String, Set<Core_MDF_Exception_Account_Mapping__c>>();
        Set<Id> rmfAccIdSet = new Set<Id>();
        Map<Id,Id> accIdGrpIdMap = new Map<Id,Id>();
        List<Core_MDF_Exception_Account_Mapping__c> listRmfExpt = new List<Core_MDF_Exception_Account_Mapping__c>();
        List<Core_MDF_Exception__c> listExptNonRmf = new List<Core_MDF_Exception__c>();
        Set< Core_MDF_Exception__Share > exptShareSet = new Set< Core_MDF_Exception__Share >();
        Set< Core_MDF_Exception_Account_Mapping__Share > exptAccMapShareSet = new Set< Core_MDF_Exception_Account_Mapping__Share >();
        Set<id> exceptionChannelPrgIdsSet = new Set<Id>();
        Set<Id> intelAccSet = new Set<Id>();
        Set<Id> intelAccountIdSet = new Set<Id>();
        String CO_MARKETING_ACCOUNT = Core_MDF_CCP_ConstantClass.CO_MARKETING_ACCOUNT;
        Map<Id , Core_MDF_Exception_Account_Mapping__c> eefExceptionMap= new Map<Id , Core_MDF_Exception_Account_Mapping__c>();
        //mapOfExpIdToActAccId - map of Exception Id to associcated Activating AccountId
        Map<Id,List<Id>> mapOfExpIdToActAccId = new Map<Id,List<Id>>();
        //mapOfExpIdToPrimaryAccId - map of Exception Id to Associated Primary AccountId
        Map<Id,List<Id>> mapOfExpIdToPrimaryAccId = new Map<Id,List<Id>>();
        //Map of Program Api name to Program Name Label
        Map<String,String> channelProgramNameMap = new Map<String,String>();
        //Map of Exception ID to Exception Account Mapping
        Map<Id, Core_MDF_Exception_Account_Mapping__c> excpNewMap = new  Map<Id, Core_MDF_Exception_Account_Mapping__c>();
        

		
        //Iterating over exceptions newmap for which we have to delete existing share record and create new based on account select
        for(Core_MDF_Exception_Account_Mapping__c excpOnUpdate : newEAMmap.values()){
                if(excpOnUpdate.Core_MDF_Exception_Status_txt__c == Label.Core_MDF_Exception_Approved_Status && 
                    excpOnUpdate.Core_MDF_Account_id__c != NULL
                    && excpOnUpdate.Core_MDF_Active_ind__c
                    && excpOnUpdate.Core_MDF_Expose_Externally_ind__c == true
                   ){
                       excpNewMap.put(excpOnUpdate.Core_MDF_Exception_id__c,excpOnUpdate);   
                   }
        }
        if(excpNewMap!=null){
            //Getting share record which has to be deleted
            List<Core_MDF_Exception__Share> exceptionShareList = new List<Core_MDF_Exception__Share>();
            List<Core_MDF_Exception_Account_Mapping__Share> exceptionAccMapShareList = new List<Core_MDF_Exception_Account_Mapping__Share>();
    
           /* for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem : ([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c, Core_MDF_Entitlement_Name__c
                                                                       FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt])){
                                                                           channelProgramNameMap.put(bpem.Core_MDF_Bank_Program_Name__c , bpem.Core_MDF_Channel_Program__c);
                                                                       }*/
            for(Core_MDF_ChannelProgram__mdt bpem : ([SELECT Label, Core_MDF_Bank_Program_Value__c FROM Core_MDF_ChannelProgram__mdt LIMIT 1000])){
                channelProgramNameMap.put(bpem.Core_MDF_Bank_Program_Value__c , bpem.Label);
            }//Core_MDF_BankProgram_Entitlement_Mapping__mdt optimization
            
             Map<String,String> channelProgramNameIdMap = new Map<String,String>();
            //Map of Program Name to Channel Program ID
             for (ChannelProgram cpList : [SELECT Id, Name FROM ChannelProgram WHERE Name =: channelProgramNameMap.values() ORDER BY CreatedDate] ){
                                              channelProgramNameIdMap.put( cpList.Name , cpList.Id );
                                          }
            
            //Creating map of eef exception to get activating and primary partner
            for(Core_MDF_Exception_Account_Mapping__c expt: excpNewMap.values()){
                if(expt.Core_MDF_Program_txt__c == Label.Core_MDF_EEF_RecordType && expt.Core_MDF_Account_id__c != Null && expt.Core_MDF_Exception_Status_txt__c == Label.Core_MDF_Exception_Approved_Status){
                    eefExceptionMap.put(expt.Id, expt);
                }
            }
          
            //To get Activating & Primary Partner Account for EEF Exceptions Account Mapping
            if(!eefExceptionMap.isEmpty()){
                //excpEEFWrapper - wrapper to prepare the list of activating accounts/primary accounts associated to the exception account mapping's Account          
                Core_MDF_Expt_AccMap_ServiceHandler.ExceptionEEFDataWrapper excpEEFWrapper = Core_MDF_Expt_AccMap_ServiceHandler.prepareDataForEEFSharing(eefExceptionMap.values(),accIdToPartnerTypeMap);
                intelAccountIdSet = excpEEFWrapper.intelAccountIdSet;//set to store the Intel Account id of Primary and Activating accounts.
                mapOfExpIdToActAccId = excpEEFWrapper.mapOfExpIdToActAccId; mapOfExpIdToPrimaryAccId = excpEEFWrapper.mapOfExpIdToPrimaryAccId; 
            }
            //Iterating over account specific exception
            //All account exception sharing is achieved from sharing rule
            for(Core_MDF_Exception_Account_Mapping__c expt: excpNewMap.values()){
                Set<String> channelPrgIdAccId = new Set<String>();
                
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
                            If(expt.Core_MDF_Program_txt__c == Label.Core_MDF_EEF_RecordType){
                                //preparing the channelprgIdAccIdSet for EEF Activating Account
                                if(!mapOfExpIdToActAccId.isEmpty() && mapOfExpIdToActAccId.size()>0){
                                    for(Id accId : mapOfExpIdToActAccId.get(expt.Core_MDF_Exception_id__c)){channelPrgIdAccId.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)accId);
                    
                                    }   
                                }
                                
                                //preparing the channelprgIdAccIdSet for EEF Priamary Account
                                if(!mapOfExpIdToPrimaryAccId.isEmpty() && mapOfExpIdToPrimaryAccId.size()>0){
                                    for(Id accId : mapOfExpIdToPrimaryAccId.get(expt.Core_MDF_Exception_id__c)){channelPrgIdAccId.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (String)accId);
                                    }
                                }
                                
                            }
                        channelPrgIdAccId.add((String)channelProgramNameIdMap.get(channelProgramNameMap.get(expt.Core_MDF_Program_txt__c)) + (string)expt.Core_MDF_Account_id__c);                      
                        //Adding expt to set with key as channelprogram id and account id
                        for(String cpIdAccId : channelPrgIdAccId){
                            if(channelPrgIdAccIdExptSetMap.containskey(cpIdAccId)){channelPrgIdAccIdExptSetMap.get(cpIdAccId).add(expt);
                            }else{channelPrgIdAccIdExptSetMap.put(cpIdAccId,exptSet);
                            }}intelAccountIdSet.add(expt.Core_MDF_Account_id__c);
                        
                    }else{rmfAccIdSet.add(expt.Core_MDF_Account_id__c);listRmfExpt.add(expt);
                    }
                }
            }
            
            
            if(!rmfAccIdSet.isEmpty()){
                for(Account rmfNodes : [SELECT Id, Core_MDF_External_Group_Id__c FROM Account WHERE Id IN: rmfAccIdSet AND RecordType.Name =: CO_MARKETING_ACCOUNT]){accIdGrpIdMap.put(rmfNodes.id,rmfNodes.Core_MDF_External_Group_Id__c);
                }
            }
            if(!accIdGrpIdMap.isEmpty()){
                for(Core_MDF_Exception_Account_Mapping__c expt: listRmfExpt){if(accIdGrpIdMap.containskey(expt.Core_MDF_Account_id__c)){exptShareSet.add(createExceptionShareExt(expt.Core_MDF_Exception_id__c,accIdGrpIdMap.get(expt.Core_MDF_Account_id__c)));exptAccMapShareSet.add(createExceptionAccShareExt(expt.id,accIdGrpIdMap.get(expt.Core_MDF_Account_id__c)));
                    }
                }
            }
            String pgmQueryStr = '';
            pgmQueryStr = 'SELECT Id, Core_MDF_Account__c, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Name,Core_MDF_Group_Id__c,' +
                    'Core_MDF_Group_Name__c, Core_MDF_Type_of_Access__c ' +
                    'FROM Core_MDF_Partner_Group_Mapping__c ' +
                    'WHERE Core_MDF_Channel_Program__c IN :exceptionChannelPrgIdsSet ' +
                    'AND Core_MDF_Type_of_Access__c = ' + '\'' + 'External' + '\' ' +
                    'AND Core_MDF_Inactive_Ind__c = false ' +
                    'AND Core_MDF_Group_Id__c != NULL '+
                    'AND Core_MDF_Account__c IN :intelAccountIdSet';
                for(Core_MDF_Partner_Group_Mapping__c pgm : Database.query(pgmQueryStr)){
                    string pgmChannelPrgIdAccId =(String)pgm.Core_MDF_Channel_Program__c + (String)pgm.Core_MDF_Account__c;
                    if(channelPrgIdAccIdExptSetMap.containskey(pgmChannelPrgIdAccId)){
                        for(Core_MDF_Exception_Account_Mapping__c expt: channelPrgIdAccIdExptSetMap.get(pgmChannelPrgIdAccId)){exptShareSet.add(createExceptionShareExt(expt.Core_MDF_Exception_id__c,pgm.Core_MDF_Group_Id__c));exptAccMapShareSet.add(createExceptionAccShareExt(expt.id,pgm.Core_MDF_Group_Id__c));
                        }
                    }
                }
            
            if(!exptShareSet.isEmpty()){List <Core_MDF_Exception__Share> exptShareList = new List< Core_MDF_Exception__Share >();exptShareList.addAll(exptShareSet);database.insert(exptShareList,false);
            }
            
            if(!exptAccMapShareSet.isEmpty()){List <Core_MDF_Exception_Account_Mapping__Share> exptAccMapShareList = new List< Core_MDF_Exception_Account_Mapping__Share >();exptAccMapShareList.addAll(exptAccMapShareSet);database.insert(exptAccMapShareList,false);
            }
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