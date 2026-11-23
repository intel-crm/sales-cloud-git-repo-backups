/**********************************************************************
Class Name : Core_MDF_GeneralPurpose_UI_Utility
Test Class : Core_MDF_GeneralPurpose_UI_Utility_Test
----------------------------------------------------------------------
Modification Log:
----------------------------------------------------------------------
Change#     Modified By         Date                Description
-----------------------------------------------------------------------
 1          Prashant            01/28/2022          Initial version.
/**********************************************************************/
public  without sharing Class Core_MDF_GeneralPurpose_UI_Utility{
    //Variable Declcartions
    public static List<String> geoList;
    public static List<String> subGeoList;  

    /*-------------------------------------------------------------------------------------------------------
    Method Name         : getIntelActivityOwners
    @Input Parameters   : AccountId, porgramName, List of coutries, budgteType
    @return             : returns List of IntelActivityOwnerWrapper contains the User details
    Description         : Get the List of users by fetching the userds if IUPGM is created for those users.
    ---------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<IntelActivityOwnerWrapper> getIntelActivityOwners(String accId,String program, List<String> country,String budgetType,Boolean isPlannedEdited) { 
        Set<String> customPermissionSet = new Set<String>();
        String role;
        Set<String> roles = new Set<String>();
        Set<Id> userIdSet = new Set<Id>();
        Map<String, string> programBudgetTypeWiseAcctMgrMap = new Map<String,String>();
        
        Map<String,String> recordtypeMap = new Map<String,String>();    
         System.debug('input program>>'+program);
        recordtypeMap.put('Core_MDF_Channel_MDF','Channel MDF');
        recordtypeMap.put('Core_MDF_Client_CoMarketing_Fund','Client CoMarketing Fund');
        recordtypeMap.put('Core_MDF_Client_CoMarketing_Fund_Boost','Client CoMarketing Fund Boost');
        recordtypeMap.put('Core_MDF_Data_Center_CoMarketing_Fund','Data Center CoMarketing Fund');
        recordtypeMap.put('Core_MDF_Intel_Partner_Alliance','Intel Partner Alliance');
        recordtypeMap.put('Core_MDF_Retail_Marketing_Funds','Retail Marketing Funds'); 
        recordtypeMap.put('Core_MDF_Service_Provider_CoMarketing_Fund','Service Provider CoMarketing Fund');
        if(recordtypeMap.containsKey(program)){
            program = recordtypeMap.get(program);
        }
        getGeoDetails(country);
        programBudgetTypeWiseAcctMgrMap = getAccountMannagerRoles();    
        String accountId = getUltimateAccountId(accId);
        system.debug('accountId:'+accountId);   
        String key =program + budgetType; 
        System.debug('<<key>>'+key);
         if(programBudgetTypeWiseAcctMgrMap.containsKey(key)){
             roles.add(programBudgetTypeWiseAcctMgrMap.get(key));
         }
         System.debug('program>>'+program);
         System.debug('geoList>>'+geoList);
         System.debug('subGeoList>>'+subGeoList);
         System.debug('roles>>'+roles);
         List<IntelActivityOwnerWrapper> resultWrapperList = new List<IntelActivityOwnerWrapper>();
            String geoStr='';
            geoList.add('WW');
            if(!geoList.isEmpty()){
                geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';
                        // geoStr = String.escapeSingleQuotes(geoStr);
          }  
            System.debug('<<geoStr>>'+geoStr);
            String qryStr = '';
        if(isPlannedEdited){
            qryStr = 'SELECT Id, Core_MDF_User_id__c '+
                            ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
                            ' WHERE Core_MDF_Program_nm__c =:program' +
                            ' and Core_MDF_Account_id__c =:accountId' +
                            ' and Core_MDF_Region_cd__c INCLUDES ' + geoStr +
                            ' and Core_MDF_Role_nm__c IN : roles'+
                            ' and Core_MDF_is_User_Active_ind__c = true '+
                            ' and Core_MDF_Active_Ind__c = true' +
                            ' and Core_MDF_Is_Not_an_Approver_Ind__c = false';
        }
        else if (!isPlannedEdited){
            qryStr = 'SELECT Id, Core_MDF_User_id__c '+
                            ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
                            ' WHERE Core_MDF_Program_nm__c =:program' +
                            ' and Core_MDF_Account_id__c =:accountId' +
                            ' and Core_MDF_Region_cd__c INCLUDES ' + geoStr +
                            ' and Core_MDF_Role_nm__c IN : roles';
        }
            System.debug('<<qryStr>>'+qryStr); 
          try{
              
              List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList= Database.Query(qryStr);
             for( Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm: iupgmList){   
                  userIdSet.add(iupgm.Core_MDF_User_id__c);
             }
             System.debug('userIdSet>>'+userIdSet);
             if(!userIdSet.isEmpty()){
                 for(user userObj : [SELECT Id, Name,FirstName, LastName, Email FROM User WHERE Id IN: userIdSet Order by Name asc]){
                                    IntelActivityOwnerWrapper actOwnerObj = new IntelActivityOwnerWrapper();
                                    actOwnerObj.userId = userObj.Id; 
                                    actOwnerObj.fullName= userObj.Name;
                                    actOwnerObj.firstName = userObj.FirstName;
                                    actOwnerObj.lastName = userObj.LastName;
                                    actOwnerObj.email = userObj.Email;
                                    resultWrapperList.add(actOwnerObj);
                 }
              }
          } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
          
         system.debug('resultWrapperList:'+resultWrapperList);
     return resultWrapperList;
    
    }
    /*-------------------------------------------------------------------------------------------------------
        Method Name         : isUserApprover
        @Input Parameters   : AccountId, porgramName, List of coutries, budgteType, user Id
        @return             : Boolean
        Description         : Idetify is looged in user is approver for record.
    ---------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean isApprover(String accId,String program, List<String> country,String budgetType,String userId) { 
        Boolean result;
        Set<String> customPermissionSet = new Set<String>();
        String role;
        Set<String> roles = new Set<String>();
        Set<Id> userIdSet = new Set<Id>();
        Map<String, string> programBudgetTypeWiseAcctMgrMap = new Map<String,String>();
        
        Map<String,String> recordtypeMap = new Map<String,String>();        
        recordtypeMap.put('Core_MDF_Channel_MDF','Channel MDF');
        recordtypeMap.put('Core_MDF_Client_CoMarketing_Fund','Client CoMarketing Fund');
        recordtypeMap.put('Core_MDF_Client_CoMarketing_Fund_Boost','Client CoMarketing Fund Boost');
        recordtypeMap.put('Core_MDF_Data_Center_CoMarketing_Fund','Data Center CoMarketing Fund');
        recordtypeMap.put('Core_MDF_Intel_Partner_Alliance','Intel Partner Alliance');
        recordtypeMap.put('Core_MDF_Retail_Marketing_Funds','Retail Marketing Funds'); 
        recordtypeMap.put('Core_MDF_Service_Provider_CoMarketing_Fund','Service Provider CoMarketing Fund');
        if(recordtypeMap.containsKey(program)){
            program = recordtypeMap.get(program);
        }
        getGeoDetails(country);
        programBudgetTypeWiseAcctMgrMap = getAccountMannagerRoles();    
        String accountId = getUltimateAccountId(accId);
        system.debug('accountId:'+accountId);   
        String key =program + budgetType; 
         if(programBudgetTypeWiseAcctMgrMap.containsKey(key)){
             roles.add(programBudgetTypeWiseAcctMgrMap.get(key));
         }
         System.debug('program>>'+program);
         System.debug('geoList>>'+geoList);
         System.debug('subGeoList>>'+subGeoList);
         System.debug('roles>>'+roles);
         List<IntelActivityOwnerWrapper> resultWrapperList = new List<IntelActivityOwnerWrapper>();
            String geoStr='';
            geoList.add('WW');
        system.debug('----geoList'+geoList);
            if(!geoList.isEmpty()){
                geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';
                        // geoStr = String.escapeSingleQuotes(geoStr);
          }          
          try{      
             // String loggedinUserId =  UserInfo.getUserId();
                String qryStr = 'SELECT Id, Core_MDF_User_id__c '+
                            ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
                            ' WHERE Core_MDF_Program_nm__c =: program' +
                            ' and Core_MDF_Account_id__c =:accountId' +
                            ' and Core_MDF_Region_cd__c INCLUDES ' + geoStr +
                            ' and Core_MDF_Role_nm__c IN : roles'+
                            ' and Core_MDF_is_User_Active_ind__c = true '+
                            ' and Core_MDF_Active_Ind__c = true' +
                            ' and Core_MDF_Is_Not_an_Approver_Ind__c = false'+  
                            ' and Core_MDF_User_id__c =:userId';
             System.debug('<<qryStr>>'+qryStr); 
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList= Database.Query(qryStr);
              system.debug('--iupgmList-'+iupgmList);
            if(iupgmList!=null && !iupgmList.isEmpty()){
                result = true;
            }
              else{
                  result = false;
              }
            
          } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
             
     return result;
    
    }
    
    
    
    /*---------------------------------------------------------------------------------------------------
        Method Name         : getGeoDetails
        @Input Parameters   : List of coutry names
        @return             : void
        Description         : Fetch the geo details
    ----------------------------------------------------------------------------------------------------*/
    public static void getGeoDetails (List<String> countryList){
        try{
             geoList = new List<String>();
             subGeoList = new List<String>();
             Map<String,countryGeoSubGeoWrapper> wrapperMap = new Map<String,countryGeoSubGeoWrapper>();
             wrapperMap = getCountryGeoMap();
            System.debug('<<wrapperMap >>'+ wrapperMap );
            for(String countryStr : countryList){
                if(wrapperMap.containsKey(countryStr) && wrapperMap.get(countryStr) != NULL ){
                    if(wrapperMap.get(countryStr).subgeo.equals('LAR') || wrapperMap.get(countryStr).subgeo.equals('NAR')){
                        subGeoList.add(wrapperMap.get(countryStr).subgeo);
                    }
                    geoList.add(wrapperMap.get(countryStr).geo);
                }
            }  
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
          
    }
    
    /*---------------------------------------------------------------------------------------------
        Method Name         : getUltimateAccountId
        @Input Parameters   : accountId
        @return             : Id
        Description         : returns ultimate accountId
    -----------------------------------------------------------------------------------------------*/
    public static Id getUltimateAccountId(String accId){
        Id accountId;
        try{
            List<Account> accountList =[SELECT Id,Core_MDF_CoMarketing_Ultimate_Account__c FROM Account WHERE Id =:accId LIMIT 1];
            if(accountList != null && !accountList.isEmpty()){
                accountId = accountList[0].Core_MDF_CoMarketing_Ultimate_Account__c;
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        return accountId;
    }
       
    /*---------------------------------------------------------------------------------------------
        Method Name         : getCountryGeoMap
        @Input Parameters   : --
        @return             : Map of Country and CountryGeoSubGeoWrapper
        Description         : Prepares the country-geo-subGeo mapping
    -----------------------------------------------------------------------------------------------*/
    public static Map<String,countryGeoSubGeoWrapper> getCountryGeoMap(){
        
        Map<String,countryGeoSubGeoWrapper> countryWrapperMap = new Map<String,countryGeoSubGeoWrapper>();
        
        try{
            List<Core_MDF_CCP_Country_Geo_Mapping__mdt> cgmList = [SELECT MasterLabel, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c, Core_MDF_Code_2_Digits__c
                                                                   FROM Core_MDF_CCP_Country_Geo_Mapping__mdt];
            
            if(cgmList != NULL && cgmList.size() > 0){
                for(Core_MDF_CCP_Country_Geo_Mapping__mdt mdt : cgmList){
                    countryGeoSubGeoWrapper countryGeoSubGeoInst = new countryGeoSubGeoWrapper();
                    countryGeoSubGeoInst.country = mdt.MasterLabel;
                    countryGeoSubGeoInst.geo = mdt.Core_MDF_Geo__c;
                    countryGeoSubGeoInst.subGeo = mdt.Core_MDF_Sub_Geo__c;
                    countryGeoSubGeoInst.countryCode = mdt.Core_MDF_Code_2_Digits__c;
                    countryWrapperMap.put(countryGeoSubGeoInst.country, countryGeoSubGeoInst);
                }
            }                                                 
            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        return countryWrapperMap;
    }
    
    /*---------------------------------------------------------------------------------------------
        Method Name         : getAccountMannagerRoles
        @Input Parameters   : --
        @return             : Map of programBudget and account manager PS name
        Description         : Get the account manager role on program and budget typw
    -----------------------------------------------------------------------------------------------*/
    public static Map<String, String> getAccountMannagerRoles(){
        Map<String, String> resultMap = new Map<String, String>();
        try{
            for(Core_MDF_Program_Budget_RecordType__mdt programBudgetRecTypeObj :[SELECT Id, Core_MDF_BudgetType__c,
                                            Core_MDF_Program__c, Core_MDF_Account_Manager_PS_API_Name__c
                                            FROM Core_MDF_Program_Budget_RecordType__mdt 
                                            WHERE Core_MDF_Account_Manager_PS_API_Name__c !=null]){
                String key = programBudgetRecTypeObj.Core_MDF_Program__c + programBudgetRecTypeObj.Core_MDF_BudgetType__c;
                resultMap.put(key, programBudgetRecTypeObj.Core_MDF_Account_Manager_PS_API_Name__c);
            }
            System.debug('<<resultMap>>'+resultMap);
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        return resultMap;
    }
    
  /*----------------------------------------------------------------------------------------------
        Class Name          : CountryGeoSubGeoWrapper
        Description         : Wrapper class for Geo details
    ---------------------------------------------------------------------------------------------*/
    public class CountryGeoSubGeoWrapper{
        public String country;
        public String geo;
        public String subGeo;
        public String countryCode;
    }
        
    /*-------------------------------------------------------------------------------------------------------
Method Name         : getMemberactivityOwners
@Input Parameters   : AccountId
@return             : returns List of MemberActivityOwnerWrapper contains the User details
Description         : Get the List of users by fetching the userds if PNUM is created for those users.
---------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<MemberActivityOwnerWrapper> getMemberactivityOwners(String accId, Boolean isPlannedEdit) { 
        System.debug('<<method called 2>>');
         system.debug('<<accIdExt>>' + accId + isPlannedEdit);
        Map<Id, Core_MDF_Partner_Node_User_Mapping__c> userIdDetailsMap = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>();
        
        
        String qryStr = '';
        if(isPlannedEdit){
            qryStr = 'SELECT Id, Core_MDF_User__c, Core_MDF_User__r.Name,Core_MDF_User__r.FirstName,Core_MDF_User__r.LastName,Core_MDF_User__r.Email'+                          
                ' FROM Core_MDF_Partner_Node_User_Mapping__c' +
                ' WHERE Core_MDF_Account__c =:accId' +
                ' and Core_MDF_Active_Ind__c = true' +
                ' and Core_MDF_User__r.isActive = true';
        }
        else if (!isPlannedEdit){
            qryStr = 'SELECT Id, Core_MDF_User__c,Core_MDF_User__r.Name,Core_MDF_User__r.FirstName,Core_MDF_User__r.LastName,Core_MDF_User__r.Email'+
                ' FROM Core_MDF_Partner_Node_User_Mapping__c'+
                ' WHERE Core_MDF_Account__c =:accId';
        }
        System.debug('<<qryStr1>>'+qryStr);
        List<MemberActivityOwnerWrapper> resultWrapperList = new List<MemberActivityOwnerWrapper>();
        
        
        try{
            if(String.isNotBlank(accId)){
                List<Core_MDF_Partner_Node_User_Mapping__c> pnumList= Database.Query(qryStr);
                for( Core_MDF_Partner_Node_User_Mapping__c pnumObj: pnumList){   
                    userIdDetailsMap.put(pnumObj.Core_MDF_User__c, pnumObj);
                }
                
                
                if(userIdDetailsMap.keySet() != NULL  && userIdDetailsMap.keySet().size() > 0){
                    for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId, Assignee.AccountId, Assignee.IsActive, PermissionSet.Name 
                                                          FROM PermissionSetAssignment WHERE AssigneeId IN :userIdDetailsMap.keySet()
                                                          AND PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Submitter')]) {
                                                              MemberActivityOwnerWrapper extActSubmitterObj = new MemberActivityOwnerWrapper();
                                                              extActSubmitterObj.userId = usrPer.AssigneeId;
                                                              extActSubmitterObj.fullName= userIdDetailsMap.get(usrPer.AssigneeId).Core_MDF_User__r.Name;
                                                              extActSubmitterObj.firstName = userIdDetailsMap.get(usrPer.AssigneeId).Core_MDF_User__r.FirstName;
                                                              extActSubmitterObj.lastName = userIdDetailsMap.get(usrPer.AssigneeId).Core_MDF_User__r.LastName;
                                                              extActSubmitterObj.email = userIdDetailsMap.get(usrPer.AssigneeId).Core_MDF_User__r.Email;
                                                              resultWrapperList.add(extActSubmitterObj);
                                                          }
                }
            }
            
            
        } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        
        system.debug('resultWrapperList:'+resultWrapperList);
        return resultWrapperList;
        
    }
 /*---------------------------------------------------------------------------------------------------
Method Name         : CheckExternalActivitySubmitterActive
@Input Parameters   : Account, User Id
@return             : Boolean
Description         : Identify if External Submitter Active.
----------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean isSubmitterActive(String accId, String userId) {
        Boolean result;
        System.debug('<<values>>'+accId +userId);
        
        
        try{
            String qryStr = 'SELECT Id,Core_MDF_User__c,Core_MDF_User__r.isActive'+
                ' FROM Core_MDF_Partner_Node_User_Mapping__c' +
                ' WHERE Core_MDF_Account__c =:accId' +
                ' and Core_MDF_Active_Ind__c = true' +
                ' and Core_MDF_User__r.isActive = true'+
                ' and Core_MDF_User__c =:userId';
            System.debug('<<qryStr>>'+qryStr);
            List<Core_MDF_Partner_Node_User_Mapping__c> pnumList= Database.Query(qryStr);
            System.debug('<<pnumList>>'+pnumList);
            
            if(pnumList!=null && !pnumList.isEmpty()){
                result = true;
            }
            else{
                result = false;
            }
            System.debug('<<result>>'+result);
              
        } 
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        
      return result;
        
    }
    
    /*----------------------------------------------------------------------------
        Class Name   : IntelActivityOwnerWrapper
        Description  : Wrapper class for User details
    ------------------------------------------------------------------------------*/
    public class IntelActivityOwnerWrapper{ 
        @AuraEnabled public String fullName{get;set;}    
        @AuraEnabled public String firstName{get;set;}
        @AuraEnabled public String lastName{get;set;}
        @AuraEnabled public String email{get;set;}
        @AuraEnabled public String userId{get;set;}     
    }
        /*----------------------------------------------------------------------------
        Class Name   : MemberActivityOwnerWrapper
        Description  : Wrapper class for User details
    ------------------------------------------------------------------------------*/
    public class MemberActivityOwnerWrapper{ 
        @AuraEnabled public String fullName{get;set;}    
        @AuraEnabled public String firstName{get;set;}
        @AuraEnabled public String lastName{get;set;}
        @AuraEnabled public String email{get;set;}
        @AuraEnabled public String userId{get;set;}     
    }

/***************************************************************************************************** 
Method Name   :        isRecordApprover
@return       :        Boolean
@parameters   :        AccountId, programName, List of coutries, user Id
Description   :        Returns true if IUPGM exists for PCT approver - Identify is logged in user is approver for record.
Added By      :        Accenture - Sai - 29/03/2021
******************************************************************************************************/ 
    
    @AuraEnabled
    public static Boolean isRecordApprover(String accId, String program, List<String> country, String approvalStage, String userId) { 
        Boolean result;
        List<String> roles = new List<String>();
        List<String> pctRolesList = new List<String>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        String pctRoleSet;
        
        Map<String,Object> programNameByRecTypeDevNameMap = getProgramNameByRecordTypeDevName();
            if(programNameByRecTypeDevNameMap.containsKey(program)){
                program = (String)programNameByRecTypeDevNameMap.get(program);
            }
        
        String accountId = getUltimateAccountId(accId);
        getGeoDetails(country);
        String geoStr='';
        if(!geoList.isEmpty()){
            geoList.add('WW');
            geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';
        }
        if(approvalStage == 'Price Reviewer'){
            pctRoleSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Price_Reviewer_Roles');
        }
        try{
            iupgmList = getIupgmRecords(accountId, program, userId, geoStr, pctRoleSet); 
            if(iupgmList != null && iupgmList.size() > 0){
                result = true;
            }
            else{
                result = false;
            }
        } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}      
        return result;
    }
    
/***************************************************************************************************** 
Method Name   :        getIupgmRecords
@return       :        List of IUPGM records
@parameters   :        AccountId, programName, List of coutries, user Id
Description   :        Returns IUPGM records if IUPGM exists given program, account id, user and geos.
Added By      :        Accenture - Sai - 04/03/2021
******************************************************************************************************/ 
    @AuraEnabled
    public static List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> getIupgmRecords(String accId, String program, String userId, String geoStr, String roles) { 
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        String category = 'Core_MDF_GeneralPurpose_UI_Utility_Role_Mappings';
        String allAccountsYes = 'Yes';
        String allAccountsNo = 'No';
        try{
        List<Core_MDF_Custom_Label_Configration__mdt> mdtRecList = [SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,
                                                                    Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c 
                                                                    FROM Core_MDF_Custom_Label_Configration__mdt WHERE Core_MDF_Category_Txt__c =: category
                                                                    AND Core_MDF_Value_Txt__c =: program AND Core_MDF_Value2_Txt__c =: roles LIMIT 1];
        String value = mdtRecList != null ? mdtRecList[0].Core_MDF_Value3_Txt__c : '';
        String qryStr;
        if(String.isNotBlanK(geoStr)){
            system.debug('geoStr--'+geoStr);
            geoStr = String.escapeSingleQuotes(geoStr);
            system.debug('geoStr--'+geoStr);
            geoStr = geoStr.replaceAll('\\\\','');
            system.debug('geoStr--'+geoStr);

        }
            qryStr = 'SELECT Id, Core_MDF_User_id__c '+
                ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
                ' WHERE Core_MDF_Program_nm__c =: program' +
                ' and Core_MDF_Region_cd__c INCLUDES ' + geoStr +
                ' and Core_MDF_Role_nm__c =: roles'+
                ' and Core_MDF_is_User_Active_ind__c = true '+
                ' and Core_MDF_Active_Ind__c = true' +
                ' and Core_MDF_Is_Not_an_Approver_Ind__c = false'+
                ' and Core_MDF_User_id__c =:userId';
            switch on value{
                when 'allAccountsYesOrNo'{
                    qryStr += ' and (Core_MDF_All_Accounts_cd__c = ' + '\'' + String.escapeSingleQuotes(allAccountsYes) + '\'' +
                        ' OR (Core_MDF_All_Accounts_cd__c = ' +  '\'' + String.escapeSingleQuotes(allAccountsNo) + '\'' +
                        ' and Core_MDF_Account_id__c =:accId))';
                }
                when 'allAccountsNo'{
                    qryStr += ' (Core_MDF_All_Accounts_cd__c = ' + '\'' + String.escapeSingleQuotes(allAccountsNo) + '\'' +
                        ' and Core_MDF_Account_id__c =:accId)' ;
                }
                when 'allAccountsYes'{
                    qryStr += 'Core_MDF_All_Accounts_cd__c = ' + '\'' + String.escapeSingleQuotes(allAccountsYes) + '\'';
                }
            }
            System.debug('CHECK Query::'+qryStr);
            iupgmList= Database.Query(qryStr);
        } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}      
        return iupgmList;
    }
    @AuraEnabled
    public static Map<String, Map<String, List<Id>>> getIupgmRecordsPCT(List<String> accList, List<String> progList, List<String> geoList, String roles) {     
        
        List<String> program = new List<String>();     
        Map<String,Object> programNameByRecNameMap = getProgramNameByRecName();
        for(String prgm : progList){
            if(programNameByRecNameMap.containsKey(prgm)){
                program.add((String)programNameByRecNameMap.get(prgm));
            }
        }
        
        System.debug('<<input values 506>>' + accList + progList + program + geoList + roles);
        System.debug('<<programNameByRecNameMap>>' + programNameByRecNameMap);
        Map<String,string> roleCheckforAccountAccessMap = new Map<String,string>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        String category = 'Core_MDF_GeneralPurpose_UI_Utility_Role_Mappings';
        List<Core_MDF_Custom_Label_Configration__mdt> mdtRecList = [SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,
                                                                    Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c
                                                                    FROM Core_MDF_Custom_Label_Configration__mdt WHERE Core_MDF_Category_Txt__c =: category
                                                                    AND Core_MDF_Value_Txt__c IN: program AND Core_MDF_Value2_Txt__c =: roles];
        List<String> values = new List<String>();
        for(Core_MDF_Custom_Label_Configration__mdt mdtRec: mdtRecList){
                roleCheckforAccountAccessMap.put(mdtRec.Core_MDF_Value_Txt__c+mdtRec.Core_MDF_Value2_Txt__c,mdtRec.Core_MDF_Value3_Txt__c);
        }
        System.debug('<<roleCheckforAccountAccessMap>>' + roleCheckforAccountAccessMap);
        Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
        String qryStr;
        String geoStr='';
        geoList.add('WW');
        system.debug('----geoList'+geoList);
        if(!geoList.isEmpty()){
            geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';
            system.debug('----geoStr'+geoStr);
        }
        if(String.isNotBlank(geoStr)){
                geoStr = String.escapeSingleQuotes(geoStr);
                system.debug('beforeEscape--'+geoStr);
                geoStr = geoStr.replaceAll('\\\\','');
        }
        
        try{
            qryStr = 'SELECT Id, Core_MDF_User_id__c,Core_MDF_Region_cd__c, '+
                ' Core_MDF_Program_nm__c, Core_MDF_Role_nm__c, ' +
                ' Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c ' +
                ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
                ' WHERE Core_MDF_Program_nm__c IN: program' +
                ' and Core_MDF_Region_cd__c INCLUDES ' + geoStr +
                ' and Core_MDF_Role_nm__c =: roles'+
                ' and Core_MDF_is_User_Active_ind__c = true '+
                ' and Core_MDF_Active_Ind__c = true' +
                ' and Core_MDF_Is_Not_an_Approver_Ind__c = false';
            System.debug('<<qryStr>>' + qryStr);
            iupgmList= Database.Query(qryStr);
            Map<string,List<Id>> subMap = new Map<string,List<Id>>();
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmObj : iupgmList){
                String key =iupgmObj.Core_MDF_Program_nm__c +iupgmObj.Core_MDF_Role_nm__c;                
                if(roleCheckforAccountAccessMap.containsKey(key)){
                    List<String> geoStrList;
                    if(iupgmObj.Core_MDF_Region_cd__c != NULL){
                        System.debug('<<iupgmObj.Core_MDF_Region_cd__c>>' + iupgmObj.Core_MDF_Region_cd__c);
                         geoStrList = iupgmObj.Core_MDF_Region_cd__c.split(';');
                        System.debug('<<geoStrList>>' + geoStrList);
                      }
                    for(String geo: geoStrList){
                    String subMapKey =iupgmObj.Core_MDF_Program_nm__c +geo+iupgmObj.Core_MDF_Role_nm__c+iupgmObj.Core_MDF_Account_id__c;
                    subMap = new Map<string,List<Id>>();
                    if(roleCheckforAccountAccessMap.get(key) == 'allAccountsYesOrNo'){ 
                        if(resultMap.containsKey('allAccountsYesOrNo')){
                            subMap = resultMap.get('allAccountsYesOrNo');
                        }
                        if(!subMap.containsKey(subMapKey)){
                            subMap.put(subMapKey, new List<Id>());
                        }
                        subMap.get(subMapKey).add(iupgmObj.Core_MDF_User_id__c);
                        resultMap.put('allAccountsYesOrNo', subMap);
                        System.debug('<<resultMap>>' + resultMap);
                    }
                    else if(roleCheckforAccountAccessMap.get(key) == 'allAccountsYes' && iupgmObj.Core_MDF_All_Accounts_cd__c=='YES'){
                       if(resultMap.containsKey('allAccountsYes')){
                            subMap = resultMap.get('allAccountsYes');
                        }
                        if(!subMap.containsKey(subMapKey)){
                            subMap.put(subMapKey, new List<Id>());
                        }
                        subMap.get(subMapKey).add(iupgmObj.Core_MDF_User_id__c);
                        resultMap.put('allAccountsYes', subMap);
                    }
                    else if(roleCheckforAccountAccessMap.get(key) == 'allAccountsNo' && iupgmObj.Core_MDF_All_Accounts_cd__c=='NO' && accList.contains(iupgmObj.Core_MDF_Account_id__c)){
                        if(resultMap.containsKey('allAccountsNo')){
                            subMap = resultMap.get('allAccountsNo');
                        }
                        if(!subMap.containsKey(subMapKey)){
                            subMap.put(subMapKey, new List<Id>());
                        }
                        subMap.get(subMapKey).add(iupgmObj.Core_MDF_User_id__c);
                        resultMap.put('allAccountsNo', subMap);
                    }
                    }
                }
            }
            System.debug('<<resultMapFinal>>' + resultMap);
        } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        return resultMap;
    }
    public static Map<String,Object> getProgramNameByRecName(){
        String jsonInputString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ProgramMappingByName');
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInputString);
        System.debug('<<resultMapOutput>>'+resultMap);
        return resultMap;
    }
     public static Map<String,Object> getProgramNameByRecordTypeDevName(){
        String jsonInputString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ProgramMappingByDevloperName');
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInputString);
        System.debug('<<resultMap>>'+resultMap);
        return resultMap;
    } 
 }