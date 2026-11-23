/****************************************************************************************************************************************************
    Class Name : Core_MDF_GeneralPurpose_UI_Utility
    Test Class : Core_MDF_GeneralPurpose_UI_Utility_Test
    ----------------------------------------------------------------------
    Modification Log:
    ----------------------------------------------------------------------
    Change#     Modified By         Date                Description
    -----------------------------------------------------------------------
    1          Prashant            01/28/2022          Initial version.
    2          Ayush               01/13/2025          Added changes for "Reclaiming SF Partner License"
    /**********************************************************************************************************************************************/
    public  without sharing Class Core_MDF_GeneralPurpose_UI_Utility{
        //Variable Declcartions
        public static List<String> geoList;
        public static List<String> subGeoList;

        /*-------------------------------------------------------------------------------------------------------
        Method Name         : getIntelActivityOwners
        @Input Parameters   : AccountId, porgramName, List of coutries, budgteType
        @return             : returns List of IntelOwnerWrapper contains the User details
        Description         : Get the List of users by fetching the userds if IUPGM is created for those users.
        ---------------------------------------------------------------------------------------------------------*/
        @AuraEnabled
        public static IntelMainOwnerWrapper getIntelActivityOwners(String accId, String primaryAcctId, String program, List<String> country, String budgetType, Boolean isPlannedEdited) {
            ActivityOwnerRequest request = new ActivityOwnerRequest(accId, primaryAcctId, program, country, budgetType, isPlannedEdited);
            return getIntelActivityOwners(request);
        }

        private static IntelMainOwnerWrapper getIntelActivityOwners(ActivityOwnerRequest request) {
            System.debug('=== METHOD START ===');
            System.debug('Input Parameters - accId: ' + request.accId + ', primaryAcctId: ' + request.primaryAcctId + ', program: ' + request.program + ', country: ' + request.country + ', budgetType: ' + request.budgetType + ', isPlannedEdited: ' + request.isPlannedEdited);
            String region = '';

            Map<String, List<String>> programBudgetTypeWiseAcctMgrMap = new Map<String, List<String>>();
            IntelMainOwnerWrapper resultWrapper = new IntelMainOwnerWrapper();

            Map<String, String> recordtypeMap = new Map<String, String>();
            List<String> accountList = new List<String>();

            recordtypeMap.put('Core_MDF_Client_CoMarketing_Fund', Core_MDF_CCP_ConstantClass.CCF_TECHNICAL_PROGRAM_NAME);
            recordtypeMap.put('Core_MDF_Client_CoMarketing_Fund_Boost', 'Client CoMarketing Fund Boost');
            recordtypeMap.put('Core_MDF_Data_Center_CoMarketing_Fund', Core_MDF_CCP_ConstantClass.DCF_TECHNICAL_PROGRAM_NAME);
            recordtypeMap.put('Core_MDF_Intel_Partner_Alliance', 'Intel Partner Alliance');
            recordtypeMap.put('Core_MDF_Retail_Marketing_Funds', 'Retail Marketing Funds');
            recordtypeMap.put('Core_MDF_Service_Provider_CoMarketing_Fund', 'Service Provider CoMarketing Fund');
            recordtypeMap.put('Core_MDF_Ecosystem_Extension_Fund', 'Ecosystem Extension Fund');

            String program = request.program;
            if(recordtypeMap.containsKey(program)){
                program = recordtypeMap.get(program);
            }

            getGeoDetails(request.country);
            programBudgetTypeWiseAcctMgrMap = getAccountMannagerRoles();

            String primaryAccountId;
            if(program == Core_MDF_CCP_ConstantClass.PFR_EEF_PROGRAM){
                primaryAccountId = getUltimateAccountId(request.primaryAcctId);
                accountList.add(primaryAccountId);
            }

            String accountId = getUltimateAccountId(request.accId);
            accountList.add(accountId);

            List<String> roleList = new List<String>();
            String key;
            if(program == 'Intel Partner Alliance'){
                key = program;
            }else{
                key = program + request.budgetType;
            }

            if(programBudgetTypeWiseAcctMgrMap.containsKey(key)){
            roleList.addAll(programBudgetTypeWiseAcctMgrMap.get(key));
            }

            if(geoList == null){
                geoList = new List<String>();
            }
            geoList.add('WW');

            String qryStr = '';
            if(request.isPlannedEdited){
                qryStr = 'SELECT Id, Core_MDF_User_id__c ,Core_MDF_Role_nm__c'+
                            ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
                            ' WHERE Core_MDF_Program_nm__c =:program' +
                            ' and Core_MDF_Account_id__c IN :accountList ' +
                            ' and Core_MDF_Region_cd__c INCLUDES :geoList ' +
                            ' and Core_MDF_Role_nm__c IN :roleList' +
                            ' and Core_MDF_is_User_Active_ind__c = true ' +
                            ' and Core_MDF_Active_Ind__c = true' +
                            ' and Core_MDF_Is_Not_an_Approver_Ind__c = false';
            } else {
                qryStr = 'SELECT Id, Core_MDF_User_id__c ,Core_MDF_Role_nm__c'+
                            ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
                            ' WHERE Core_MDF_Program_nm__c =:program' +
                            ' and Core_MDF_Account_id__c IN :accountList' +
                            ' and Core_MDF_Region_cd__c INCLUDES :geoList ' +
                            ' and Core_MDF_Role_nm__c IN :roleList';
            }

            try{
                Set<Id> primaryUserIdSet = new Set<Id>();
                Set<Id> activityUserIdSet = new Set<Id>();
                List<String> primaryOwnerRoles = new List<String>{'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr'};

                List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = Database.Query(qryStr);
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm: iupgmList){
                    if(primaryOwnerRoles.contains(iupgm.Core_MDF_Role_nm__c)){
                        primaryUserIdSet.add(iupgm.Core_MDF_User_id__c);
                    } else {
                        activityUserIdSet.add(iupgm.Core_MDF_User_id__c);
                    }
                }

                 List<User> userList = [SELECT Id, Name, FirstName, LastName, Email FROM User WHERE (Id IN :primaryUserIdSet OR Id IN :activityUserIdSet) ORDER BY Name ASC];
                 for(User userObj : userList){
					if(primaryUserIdSet.contains(userObj.Id)){
                        resultWrapper.intelPrimaryOwnerList.add(getWrapperInstance(userObj, true));
                    }
                    if(activityUserIdSet.contains(userObj.Id)){
                        resultWrapper.intelActivityOwnerList.add(getWrapperInstance(userObj, false));
                    }
                }
            } catch(Exception e){
                Core_MDF_CCP_UtilityClass.logError(e);
            }

            return resultWrapper;
        }

        public static IntelOwnerWrapper getWrapperInstance(User userObj, Boolean isPrimary){
            IntelOwnerWrapper intelOwnerObj = new IntelOwnerWrapper();
            intelOwnerObj.isPrimary = isPrimary;
            intelOwnerObj.userId = userObj.Id;
            intelOwnerObj.fullName = userObj.Name;
            intelOwnerObj.firstName = userObj.FirstName;
            intelOwnerObj.lastName = userObj.LastName;
            intelOwnerObj.email = userObj.Email;
            return intelOwnerObj;
        }
        
        /*-------------------------------------------------------------------------------------------------------
            Method Name         : isUserApprover
            @Input Parameters   : AccountId, porgramName, List of coutries, budgteType, user Id
            @return             : Boolean
            Description         : Idetify is looged in user is approver for record.
        ---------------------------------------------------------------------------------------------------------*/
        @AuraEnabled
        public static Boolean isApprover(String accId, String primaryAcctId, String program, List<String> country, String budgetType, String userId) {
            ActivityOwnerRequest request = new ActivityOwnerRequest(accId, primaryAcctId, program, country, budgetType, userId);
            return isApprover(request);
        }

        private static Boolean isApprover(ActivityOwnerRequest request) {
            Boolean result;
            // Highlight: Unused Local Variable - 14285
            // Set<String> customPermissionSet = new Set<String>();
            // String role;
            String region ='';
            // Highlight: Unused Local Variable - 14285
            // Set<String> roles = new Set<String>();
            // Set<Id> userIdSet = new Set<Id>();
            List<string> roleList = new List<string>(); //EEF
            List<Id> accountIdList = new List<Id>();
            String primaryAccountId;
                         
            //Map<String, string> programBudgetTypeWiseAcctMgrMap = new Map<String,String>();
            Map<String, List<String>> programBudgetTypeWiseAcctMgrMap = new Map<String, List<String>>();
            Map<String,String> recordtypeMap = new Map<String,String>();        
            //recordtypeMap.put('Core_MDF_Channel_MDF','Channel MDF');
            recordtypeMap.put('Core_MDF_Client_CoMarketing_Fund', Core_MDF_CCP_ConstantClass.CCF_TECHNICAL_PROGRAM_NAME);
            recordtypeMap.put('Core_MDF_Client_CoMarketing_Fund_Boost','Client CoMarketing Fund Boost');
            recordtypeMap.put('Core_MDF_Data_Center_CoMarketing_Fund', Core_MDF_CCP_ConstantClass.DCF_TECHNICAL_PROGRAM_NAME);
            recordtypeMap.put('Core_MDF_Intel_Partner_Alliance','Intel Partner Alliance');
            recordtypeMap.put('Core_MDF_Retail_Marketing_Funds','Retail Marketing Funds'); 
            recordtypeMap.put('Core_MDF_Service_Provider_CoMarketing_Fund','Service Provider CoMarketing Fund');
            recordtypeMap.put('Core_MDF_Ecosystem_Extension_Fund','Ecosystem Extension Fund');
            recordtypeMap.put('Core_MDF_Co_GTM','CoGTM');
           
            String program = request.program;
            if(program !=null && recordtypeMap.containsKey(program)){
                program = recordtypeMap.get(program);
            }
            getGeoDetails(request.country);
            if(geoList == null){
                geoList = new List<String>();
            }
            geoList.add('WW');
            // List<IntelActivityOwnerWrapper> resultWrapperList = new List<IntelActivityOwnerWrapper>();

           
            programBudgetTypeWiseAcctMgrMap = getAccountMannagerRoles(); 
            String accountId ='';
            if(request.accId != ''){
               accountId = getUltimateAccountId(request.accId); 
            }
            if(program == Core_MDF_CCP_ConstantClass.PFR_EEF_PROGRAM && request.primaryAcctId != '' ){ 
                primaryAccountId = getUltimateAccountId(request.primaryAcctId);
                accountIdList.add(primaryAccountId);
            }
            accountIdList.add(accountId);
            String key;
            
           if(program=='Intel Partner Alliance'){
                key =program;
            }else{
                key =program + request.budgetType;   
            }
            
           /* if(programBudgetTypeWiseAcctMgrMap.containsKey(key)){
                roles.add(programBudgetTypeWiseAcctMgrMap.get(key));
            }*/
            if(programBudgetTypeWiseAcctMgrMap.containsKey(key)){
                roleList.addAll(programBudgetTypeWiseAcctMgrMap.get(key));
            }
                //String geoStr='';
                //String acctstr='';
                //string roleStr='';
                 //string accountUltimate='';
                 //string roleNames='';
                    if(geoList == null){
                        geoList = new List<String>();
                    }
                	geoList.add('WW');
            //Fix start
                if(!geoList.isEmpty()){
                    String geoStr = '(\'' + String.join(geoList, '\', \'') + '\')';
                    region = String.escapeSingleQuotes(geoStr).replaceAll('\\\\','');
                }
           //Fix End
                if(!geoList.isEmpty()){
                   // geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';
                    //region = String.escapeSingleQuotes(geoStr).replaceAll('\\\\','');
                   }  
            
               if(!accountIdList.isEmpty()){
                //acctstr ='(\'' + String.join(accountIdList, '\', \'') + '\')';
                    //accountUltimate = String.escapeSingleQuotes(acctstr).replaceAll('\\\\','');
              }

              if(!roleList.isEmpty()){
                //roleStr ='(\'' + String.join(roleList, '\', \'') + '\')';
                //roleNames = String.escapeSingleQuotes(roleStr).replaceAll('\\\\','');
              }
            
            try{      
                // String loggedinUserId =  UserInfo.getUserId();
                    String qryStr = 'SELECT Id, Core_MDF_User_id__c '+
                                ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
                                ' WHERE Core_MDF_Program_nm__c =: program' +
                                ' and Core_MDF_Account_id__c IN :accountIdList' +
                                ' and Core_MDF_Region_cd__c INCLUDES :geoList' +
                                ' and Core_MDF_Role_nm__c IN :roleList' +
                                ' and Core_MDF_is_User_Active_ind__c = true '+
                                ' and Core_MDF_Active_Ind__c = true' +
                                ' and Core_MDF_Is_Not_an_Approver_Ind__c = false'+  
                                ' and Core_MDF_User_id__c =:userId';
                
                //String userId = request.userId;

                System.debug('ISAPPROVER PROGRAM = [' + program + ']');
System.debug('ISAPPROVER KEY = [' + key + ']');
System.debug('ISAPPROVER AVAILABLE KEYS = ' + programBudgetTypeWiseAcctMgrMap.keySet());
System.debug('ISAPPROVER ROLE LIST = ' + roleList);
System.debug('ISAPPROVER FINAL QUERY = ' + qryStr);

                List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList= Database.Query(qryStr);
              
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
                                                                    FROM Core_MDF_CCP_Country_Geo_Mapping__mdt LIMIT 1000];
                
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
        public static Map<String, List<String>> getAccountMannagerRoles(){
            //Map<String, String> resultMap = new Map<String, String>();
           Map<String, List<String>> resultMap = new Map<String,List<String>>(); 
           String key;
            try{
                for(Core_MDF_Program_Budget_RecordType__mdt programBudgetRecTypeObj :[SELECT Id, Core_MDF_BudgetType__c,
                                                                                      Core_MDF_Program__c, Core_MDF_Account_Manager_PS_API_Name__c
                                                                                      FROM Core_MDF_Program_Budget_RecordType__mdt 
                                                                                      WHERE Core_MDF_Account_Manager_PS_API_Name__c !=null]){
                                                                                          if(programBudgetRecTypeObj.Core_MDF_Program__c=='Intel Partner Alliance'){
                                                                                              key = programBudgetRecTypeObj.Core_MDF_Program__c;
                                                                                          }else{
                                                                                              key = programBudgetRecTypeObj.Core_MDF_Program__c + programBudgetRecTypeObj.Core_MDF_BudgetType__c;
                                                                                          }
                                                                                          if(!resultMap.containsKey(key)){
                                                                                              resultMap.put(key, new List<string>());
                                                                                          }
                                                                                          resultMap.get(key).add(programBudgetRecTypeObj.Core_MDF_Account_Manager_PS_API_Name__c);  
                                                                                      }
            
              
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
    Modified By:        Date:              Changes: 
    Ayush               13/01/2025         Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License" 
    ---------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<MemberActivityOwnerWrapper> getMemberactivityOwners(String accId, Boolean isPlannedEdit) { 
       
        Map<Id, Core_MDF_Partner_Node_User_Mapping__c> userIdDetailsMap = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>();
        
        
        String qryStr = '';
        if(isPlannedEdit){
            
            qryStr = 'SELECT Id, Core_MDF_User__c, Core_MDF_User__r.Name,Core_MDF_User__r.FirstName,Core_MDF_User__r.LastName,Core_MDF_User__r.Email'+                          
                ' FROM Core_MDF_Partner_Node_User_Mapping__c' +
                ' WHERE Core_MDF_Account__c =:accId' +
                ' and Core_MDF_Active_Ind__c = true' +
                ' and (Core_MDF_User__r.isActive = true or Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE)'; //Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
        }
        else if (!isPlannedEdit){
            
            qryStr = 'SELECT Id, Core_MDF_User__c,Core_MDF_User__r.Name,Core_MDF_User__r.FirstName,Core_MDF_User__r.LastName,Core_MDF_User__r.Email'+
                ' FROM Core_MDF_Partner_Node_User_Mapping__c'+
                ' WHERE Core_MDF_Account__c =:accId';
        }
       
        List<MemberActivityOwnerWrapper> resultWrapperList = new List<MemberActivityOwnerWrapper>();
        
        
        try{
            if(String.isNotBlank(accId)){
                List<Core_MDF_Partner_Node_User_Mapping__c> pnumList= Database.Query(qryStr);
                for( Core_MDF_Partner_Node_User_Mapping__c pnumObj: pnumList){   
                    userIdDetailsMap.put(pnumObj.Core_MDF_User__c, pnumObj);
                }
                
                
                if(userIdDetailsMap.keySet() != NULL  && userIdDetailsMap.keySet().size() > 0){
                    for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId, Assignee.AccountId, Assignee.IsActive,Assignee.Partner_License_Reclaimed__c, PermissionSet.Name 
                                                        FROM PermissionSetAssignment WHERE AssigneeId IN :userIdDetailsMap.keySet()
                                                        AND (PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Submitter') OR 
                                                             PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_EEF_Activity_Submitter'))]) {
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
           
        
        
        try{
            String qryStr = 'SELECT Id,Core_MDF_User__c,Core_MDF_User__r.isActive'+
                ' FROM Core_MDF_Partner_Node_User_Mapping__c' +
                ' WHERE Core_MDF_Account__c =:accId' +
                ' and Core_MDF_Active_Ind__c = true' +
                ' and (Core_MDF_User__r.isActive = true or Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE)'+
                ' and Core_MDF_User__c =:userId';
            
            List<Core_MDF_Partner_Node_User_Mapping__c> pnumList= Database.Query(qryStr);
            
            
            if(pnumList!=null && !pnumList.isEmpty()){
                result = true;
            }
            else{
                result = false;
            }
            
            
        } 
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        
    return result;
        
    }
        
        
        /*----------------------------------------------------------------------------
Class Name   : IntelMainOwnerWrapper
Description  : Wrapper class for User details
------------------------------------------------------------------------------*/
        public class IntelMainOwnerWrapper{ 
            @AuraEnabled public list<IntelOwnerWrapper> intelActivityOwnerList=new list<IntelOwnerWrapper>();
            @AuraEnabled public list<IntelOwnerWrapper> intelPrimaryOwnerList=new list<IntelOwnerWrapper>();
        }
        
        /*----------------------------------------------------------------------------
Class Name   : IntelOwnerWrapper
Description  : Wrapper class for User details
------------------------------------------------------------------------------*/
        public class IntelOwnerWrapper{ 
            @AuraEnabled public boolean isPrimary{get;set;}
            @AuraEnabled public String fullName{get;set;}    
            @AuraEnabled public String firstName{get;set;}
            @AuraEnabled public String lastName{get;set;}
            @AuraEnabled public String email{get;set;}
            @AuraEnabled public String userId{get;set;}     
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
            RecordApprovalRequest request = new RecordApprovalRequest(accId, program, country, approvalStage, userId);
            return isRecordApprover(request);
        }

        private static Boolean isRecordApprover(RecordApprovalRequest request) {
            Boolean result;
            // Highlight: Unused Local Variable - 14285
            // List<String> roles = new List<String>();
            // List<String> pctRolesList = new List<String>();
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            String pctRoleSet;
            
            Map<String,Object> programNameByRecTypeDevNameMap = getProgramNameByRecordTypeDevName();
            String program = request.program;
            if(programNameByRecTypeDevNameMap.containsKey(program)){
                program = (String)programNameByRecTypeDevNameMap.get(program);
            }
            
            String accountId = getUltimateAccountId(request.accId);
            getGeoDetails(request.country);
            String geoStr='';
            if(!geoList.isEmpty()){
                geoList.add('WW');
                geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';
            }
            if(request.approvalStage == 'Price Reviewer'){
                pctRoleSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Price_Reviewer_Roles');
            }
            else if(request.approvalStage == 'L1 Approval'){
                pctRoleSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Proposal_L1_Approver');
            }
            else if(request.approvalStage =='Program Office Reviewer'){
                pctRoleSet = 'Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver'; 
            }
            else if(request.approvalStage =='L2 Approval'){
                pctRoleSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Proposal_L2_Approver');
            }
            else if(request.approvalStage =='Geo Lead Approval'){
                pctRoleSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Geo_Lead_Roles');
            }
            
           
            try{
                iupgmList = getIupgmRecords(accountId, program, request.userId, geoStr, pctRoleSet); 
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
    Method Name   :        isRecordApproverWithBudgetType
    @return       :        Boolean
    @parameters   :        AccountId, programName, List of coutries, user Id, Role, BudgetType
    Description   :        Returns true if IUPGM exists - Identify is logged in user is approver for record.
    Added By      :        Ayush - 05/09/2022
    ******************************************************************************************************/     
        @AuraEnabled
        public static Boolean isRecordApproverWithBudgetType(String accId, String program, List<String> country, String approvalStage, String userId, String budgetType) {
            RecordApprovalRequest request = new RecordApprovalRequest(accId, program, country, approvalStage, userId, budgetType);
            return isRecordApproverWithBudgetType(request);
        }

        private static Boolean isRecordApproverWithBudgetType(RecordApprovalRequest request) {
            Boolean result;
            // Highlight: Unused Local Variable - 14285
            // List<String> roles = new List<String>();
            // List<String> pctRolesList = new List<String>();
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            String pctRoleSet;
            try{
                Map<String,Object> programNameByRecTypeDevNameMap = getProgramNameByRecordTypeDevName();
                String program = request.program;
                if(programNameByRecTypeDevNameMap.containsKey(program)){
                    program = (String)programNameByRecTypeDevNameMap.get(program);
                }
            
                String accountId = getUltimateAccountId(request.accId);
                getGeoDetails(request.country);
                String geoStr='';
                if(!geoList.isEmpty()){
                    geoList.add('WW');
                    geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';
                }
                if(request.approvalStage == 'Price Reviewer'){
                    pctRoleSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Price_Reviewer_Roles');
                }
                else if(request.approvalStage == 'L1 Approval'){
                    if(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name').equals(program) ){
                        pctRoleSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Proposal_L1_Approver'); 
                    }
                }
                else if(request.approvalStage =='Program Office Reviewer'){
                    pctRoleSet = 'Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver'; 
                }
                else if(request.approvalStage =='L2 Approval'){
                    pctRoleSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Proposal_L2_Approver');
                }
                
                iupgmList = getIupgmRecordsWithBudgetType(accountId, program, request.userId, geoStr, pctRoleSet, request.budgetType); 
               
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
    IupgmQueryRequest request = new IupgmQueryRequest(accId, program, userId, geoStr, roles);
    return getIupgmRecords(request);
}

private static List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> getIupgmRecords(IupgmQueryRequest request) {
    String accId = request.accId;
    String program = request.program;
    String userId = request.userId;
    String geoStr = request.geoStr;
    String roles = request.roles;

    List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
    String category = 'Core_MDF_GeneralPurpose_UI_Utility_Role_Mappings';
    String allAccountsYes = 'Yes';
    String allAccountsNo = 'No';
    
    try{
        List<Core_MDF_Custom_Label_Configration__mdt> mdtRecList = [SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,
                                                                    Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c 
                                                                    FROM Core_MDF_Custom_Label_Configration__mdt WHERE Core_MDF_Category_Txt__c =: category
                                                                    AND Core_MDF_Value_Txt__c =: program AND Core_MDF_Value2_Txt__c =: roles LIMIT 1];
        String value ='';
        if(!mdtRecList.isEmpty() && mdtRecList.size() > 0){
            value = mdtRecList[0].Core_MDF_Value3_Txt__c;
        }

        
        List<String> geoList = new List<String>();
        if(String.isNotBlank(geoStr)){
            
            String cleanGeoStr = geoStr.replaceAll('[()\'"]', '').trim();
            for(String geo : cleanGeoStr.split(',')) {
                String trimmedGeo = geo.trim();
                if(String.isNotBlank(trimmedGeo)) {
                    geoList.add(trimmedGeo);
                }
            }
        }

        String qryStr = 'SELECT Id, Core_MDF_User_id__c '+
            ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
            ' WHERE Core_MDF_Program_nm__c = :program' +
            ' AND Core_MDF_Region_cd__c INCLUDES :geoList' +         
            ' AND Core_MDF_Role_nm__c = :roles'+                     
            ' AND Core_MDF_is_User_Active_ind__c = true '+
            ' AND Core_MDF_Active_Ind__c = true' +
            ' AND Core_MDF_Is_Not_an_Approver_Ind__c = false'+
            ' AND Core_MDF_User_id__c = :userId';

        
        switch on value{
           when 'allAccountsYesOrNo'{
            qryStr += ' AND (Core_MDF_All_Accounts_cd__c = :allAccountsYes' +
                      ' OR (Core_MDF_All_Accounts_cd__c = :allAccountsNo' +
                      ' AND Core_MDF_Account_id__c = :accId))';
            }
            when 'allAccountsNo'{
            qryStr += ' AND (Core_MDF_All_Accounts_cd__c = :allAccountsNo' +
                      ' AND Core_MDF_Account_id__c = :accId)';
            }
            when 'allAccountsYes'{
                qryStr += ' AND Core_MDF_All_Accounts_cd__c = :allAccountsYes';
            }
        }
        
        System.debug('Final Query: ' + qryStr);
        System.debug('Parameters - program: ' + program + ', geoList: ' + geoList + ', roles: ' + roles + ', userId: ' + userId + ', accId: ' + accId);
        
        iupgmList = Database.Query(qryStr);
        
    } catch(Exception e){
        Core_MDF_CCP_UtilityClass.logError(e);
    }      
    return iupgmList;
}
        /***************************************************************************************************** 
    Method Name   :        getIupgmRecordsWithBudgetType
    @return       :        List of IUPGM records
    @parameters   :        AccountId, programName, List of coutries, user Id, Role, BudgetType
    Description   :        Returns IUPGM records if IUPGM exists given program, account id, user, geos and budgetType.
    Added By      :        Ayush - 05/09/2022
    ******************************************************************************************************/    
@AuraEnabled
public static List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> getIupgmRecordsWithBudgetType(String accId, String program, String userId, String geoStr, String roles, String budgetType) {
    IupgmQueryRequest request = new IupgmQueryRequest(accId, program, userId, geoStr, roles, budgetType);
    return getIupgmRecordsWithBudgetType(request);
}

private static List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> getIupgmRecordsWithBudgetType(IupgmQueryRequest request) {
    String accId = request.accId;
    String program = request.program;
    String userId = request.userId;
    String geoStr = request.geoStr;
    String roles = request.roles;
    String budgetType = request.budgetType;

    List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
    String category = 'Core_MDF_GeneralPurpose_UI_Utility_Role_Mappings';
    String allAccountsYes = 'Yes';
    String allAccountsNo = 'No';
    
    try{
        List<Core_MDF_Custom_Label_Configration__mdt> mdtRecList = [SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,
                                                                    Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c 
                                                                    FROM Core_MDF_Custom_Label_Configration__mdt WHERE Core_MDF_Category_Txt__c =: category
                                                                    AND Core_MDF_Value_Txt__c =: program AND Core_MDF_Value2_Txt__c =: roles LIMIT 1];
        String value ='';
        if(mdtRecList !=null && mdtRecList.size() > 0){
            value = mdtRecList[0].Core_MDF_Value3_Txt__c;
        } 
        

        List<String> geoList = new List<String>();
        if(String.isNotBlank(geoStr)){
            String cleanGeoStr = geoStr.replaceAll('[()\'"]', '').trim();
            for(String geo : cleanGeoStr.split(',')) {
                String trimmedGeo = geo.trim();
                if(String.isNotBlank(trimmedGeo)) {
                    geoList.add(trimmedGeo);
                }
            }
        }


        
        String qryStr = 'SELECT Id, Core_MDF_User_id__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c'+
            ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
            ' WHERE Core_MDF_Program_nm__c = :program' +
            ' AND Core_MDF_Region_cd__c INCLUDES :geoList' +                    
            ' AND Core_MDF_Role_nm__c = :roles'+                                
            ' AND Core_MDF_is_User_Active_ind__c = true '+
            ' AND Core_MDF_Active_Ind__c = true' +
            ' AND Core_MDF_Is_Not_an_Approver_Ind__c = false'+
            ' AND Core_MDF_User_id__c = :userId'+
            ' AND (Core_MDF_All_Budget_Type_Access_Ind__c = true OR Core_MDF_Budget_Type_nm__c INCLUDES :budgetType)';  

        
        switch on value{
            when 'allAccountsYesOrNo'{
                qryStr += ' AND (Core_MDF_All_Accounts_cd__c = :allAccountsYes' +
                    ' OR (Core_MDF_All_Accounts_cd__c = :allAccountsNo' +
                    ' AND Core_MDF_Account_id__c = :accId))';
            }
            when 'allAccountsNo'{
                qryStr += ' AND (Core_MDF_All_Accounts_cd__c = :allAccountsNo' +
                    ' AND Core_MDF_Account_id__c = :accId)';
            }
            when 'allAccountsYes'{
                qryStr += ' AND Core_MDF_All_Accounts_cd__c = :allAccountsYes';
            }
        }
        
        
        System.debug('Final Query: ' + qryStr);
        System.debug('Parameters - program: ' + program + ', geoList: ' + geoList + ', roles: ' + roles + ', budgetType: ' + budgetType + ', userId: ' + userId + ', accId: ' + accId);
        
        // Execute query and process results
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRecord: Database.Query(qryStr)){
            if(iupgmRecord.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null){
                for(String geoBudgetTypeStr : iupgmRecord.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';')){
                    String geo = geoBudgetTypeStr.split('->')[0];                             
                    String budtype = geoBudgetTypeStr.split('->')[1];
                    if(geo == 'ASMO-LAR' || geo == 'ASMO-NAR' || geo == 'ASMO'){
                        geo = 'ASMO';
                    }
                    
                    Boolean geoMatch = false;
                    for(String geoItem : geoList) {
                        if(geoItem.equals(geo)) {
                            geoMatch = true;
                            break;
                        }
                    }
                    if(geoMatch && budtype.equals(budgetType)){
                        iupgmList.add(iupgmRecord);
                        break;
                    }
                }
            }
            else{
                iupgmList.add(iupgmRecord);
            }
        }
       
    } catch(Exception e){
        Core_MDF_CCP_UtilityClass.logError(e);
        System.debug('Exception in getIupgmRecordsWithBudgetType: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }      
    return iupgmList;
}
        
	public static Map<String, Map<String, List<Id>>> getIupgmRecordsForApprovers(List<String> accList, List<String> progList, List<String> geoList, List<String> roles, String category) {  //Roshan
        //public static Map<String, Map<String, List<Id>>> getIupgmRecordsForApprovers(List<String> accList, List<String> progList, List<String> geoList, List<String> roles) {  
            // Highlight: Unused Local Variable - 14285
            // Map<String,String> recordtypeMap = new Map<String,String>();
            List<String> program = new List<String>();
            //String classificationVal;
            Map<String,Object> programNameByRecNameMap = getProgramNameByRecName();
            for(String prgm : progList){
                if(programNameByRecNameMap.containsKey(prgm)){
                    program.add((String)programNameByRecNameMap.get(prgm));
                }
            }
            
            Map<String,string> roleCheckforAccountAccessMap = new Map<String,string>();
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            //Roshan
            if (String.isBlank(category)) {category = 'Core_MDF_GeneralPurpose_UI_Utility_Role_Mappings';}

            List<Core_MDF_Custom_Label_Configration__mdt> mdtRecList = [SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,
                                                                        Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c
                                                                        FROM Core_MDF_Custom_Label_Configration__mdt WHERE Core_MDF_Category_Txt__c =: category
                                                                        AND Core_MDF_Value_Txt__c IN: program AND Core_MDF_Value2_Txt__c IN: roles];
        
            system.debug('mdtRecList@@@' + mdtRecList);
            // Highlight: Unused Local Variable - 14285
            // List<String> values = new List<String>();
            

            for(Core_MDF_Custom_Label_Configration__mdt mdtRec: mdtRecList){
                    roleCheckforAccountAccessMap.put(mdtRec.Core_MDF_Value_Txt__c+mdtRec.Core_MDF_Value2_Txt__c,mdtRec.Core_MDF_Value3_Txt__c);
            }

            Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
            String qryStr;
            String geoStr='';
            geoList.add('WW');
            
            if(!geoList.isEmpty()){
                geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';   
            }  
        if(String.isNotBlank(geoStr)){
                    geoStr = String.escapeSingleQuotes(geoStr);
                    geoStr = geoStr.replaceAll('\\\\','');
            }

            system.debug('geoStr@@@' + geoStr);
        
            try{
                qryStr = 'SELECT Id, Core_MDF_User_id__c,Core_MDF_Region_cd__c, '+
                    ' Core_MDF_Program_nm__c, Core_MDF_Role_nm__c, ' +
                    ' Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c ' +
                    ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
                    ' WHERE Core_MDF_Program_nm__c IN: program' +
                    ' and Core_MDF_Region_cd__c INCLUDES ' +geoStr  +
                ' and Core_MDF_Role_nm__c IN: roles'+
                    ' and Core_MDF_is_User_Active_ind__c = true '+
                    ' and Core_MDF_Active_Ind__c = true' +
                    ' and Core_MDF_Is_Not_an_Approver_Ind__c = false';
                
            
                system.debug('qryStr@@@' + qryStr);

                iupgmList= Database.Query(qryStr);
                Map<string,List<Id>> subMap = new Map<string,List<Id>>();
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmObj : iupgmList){
                    
                    String key =iupgmObj.Core_MDF_Program_nm__c +iupgmObj.Core_MDF_Role_nm__c;                
                   //early return
                   ////US - TWC702-14285: Flatten nested IFs (no logic change)
                    if(!roleCheckforAccountAccessMap.containsKey(key)){
                        System.debug('DEBUG: Key not found → ' + key);
                        continue;
                    }
                        List<String> geoStrList;
                        if(iupgmObj.Core_MDF_Region_cd__c != NULL){
                            geoStrList = iupgmObj.Core_MDF_Region_cd__c.split(';');
                        }
                        for(String geo: geoStrList){
                        String subMapKey =iupgmObj.Core_MDF_Program_nm__c +geo+iupgmObj.Core_MDF_Role_nm__c+iupgmObj.Core_MDF_Account_id__c;
                        subMap = new Map<string,List<Id>>();
                        if(roleCheckforAccountAccessMap.get(key) == 'allAccountsYesOrNo'){ 
                            if(resultMap.containsKey(iupgmObj.Core_MDF_Role_nm__c)){
                                subMap = resultMap.get(iupgmObj.Core_MDF_Role_nm__c);
                            }
                            if(!subMap.containsKey(subMapKey)){
                                subMap.put(subMapKey, new List<Id>());
                            }
                            subMap.get(subMapKey).add(iupgmObj.Core_MDF_User_id__c);
                            resultMap.put(iupgmObj.Core_MDF_Role_nm__c, subMap);
                            
                        }
                        else if(roleCheckforAccountAccessMap.get(key) == 'allAccountsYes' && iupgmObj.Core_MDF_All_Accounts_cd__c=='YES'){
                        
                        if(resultMap.containsKey(iupgmObj.Core_MDF_Role_nm__c)){
                                subMap = resultMap.get(iupgmObj.Core_MDF_Role_nm__c);
                            }
                            if(!subMap.containsKey(subMapKey)){
                                subMap.put(subMapKey, new List<Id>());
                            }
                            subMap.get(subMapKey).add(iupgmObj.Core_MDF_User_id__c);
                            resultMap.put(iupgmObj.Core_MDF_Role_nm__c, subMap);
                        }
                        else if(roleCheckforAccountAccessMap.get(key) == 'allAccountsNo' && iupgmObj.Core_MDF_All_Accounts_cd__c=='NO' && accList.contains(iupgmObj.Core_MDF_Account_id__c)){
                            if(resultMap.containsKey(iupgmObj.Core_MDF_Role_nm__c)){
                                subMap = resultMap.get(iupgmObj.Core_MDF_Role_nm__c);
                            }
                            if(!subMap.containsKey(subMapKey)){
                                subMap.put(subMapKey, new List<Id>());
                            }
                            subMap.get(subMapKey).add(iupgmObj.Core_MDF_User_id__c);
                            resultMap.put(iupgmObj.Core_MDF_Role_nm__c, subMap);
                        }
                    }
                    
                }
                System.debug('@@resultMap: '+resultMap);
            
            } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
            return resultMap;
    }
    /***************************************************************************************************** 
    Method Name   :        getIupgmForApproversWithBudgetType
    @return       :        List of IUPGM records for all Approvers
    @parameters   :        AccountId, programName, List of coutries, user Id, budgetType
    Description   :        Returns IUPGM records if IUPGM exists given program, account id, user, geos and budgetType.
    Added By      :        Ayush - 02/09/2022
    ******************************************************************************************************/         
    public static Map<String, Map<String, List<Id>>> getIupgmForApproversWithBudgetType(List<String> accList, List<String> progList, List<String> geoList, List<String> roles, List<String> budgetTypeList,List<String> approvalStageList) {     
        // Highlight: Unused Local Variable - 14285
        // Map<String,String> recordtypeMap = new Map<String,String>();
        List<String> program = new List<String>();

        List<String> classificationValList = new List<String>();
        String classificationValStr;
        Boolean budgetTypeCheck = false;

        //Boolean allBudgetType = false;
        Map<String,Object> programNameByRecNameMap = getProgramNameByRecName();
        Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
        try{
        for(String prgm : progList){
            if(programNameByRecNameMap.containsKey(prgm)){
                program.add((String)programNameByRecNameMap.get(prgm));
                //Akash - Commented as part of the KIIT Metadata Cleanup story 
                // if(!approvalStageList.isEmpty()){
                //     if(approvalStageList.contains('Additional Reviewer')){
		    	//         program.add(prgm);
                //     }
                // }
            }
        }
        
        Map<String,string> roleCheckforAccountAccessMap = new Map<String,string>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        String category = 'Core_MDF_GeneralPurpose_UI_Utility_Role_Mappings';
        List<Core_MDF_Custom_Label_Configration__mdt> mdtRecList = [SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,
                                                                    Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c
                                                                    FROM Core_MDF_Custom_Label_Configration__mdt WHERE Core_MDF_Category_Txt__c =: category
                                                                    AND Core_MDF_Value_Txt__c IN: program AND Core_MDF_Value2_Txt__c IN: roles];
            
        // Highlight: Unused Local Variable - 14285
        // List<String> values = new List<String>();
        for(Core_MDF_Custom_Label_Configration__mdt mdtRec: mdtRecList){
                roleCheckforAccountAccessMap.put(mdtRec.Core_MDF_Value_Txt__c+mdtRec.Core_MDF_Value2_Txt__c,mdtRec.Core_MDF_Value3_Txt__c);
        }
    
        //Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
        String qryStr;
        String geoStr='';
        String budgetStr = '';
        geoList.add('WW');
        String L2IupgmRole = Core_MDF_CCP_ConstantClass.L2_Iupgm_Role;

            if(!geoList.isEmpty()){
                geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';  
            }  
            if(String.isNotBlank(geoStr)){
                geoStr = String.escapeSingleQuotes(geoStr);
                geoStr = geoStr.replaceAll('\\\\','');
            }
            if(budgetTypeList != null && !budgetTypeList.isEmpty()){
                budgetStr ='(\'' + String.join(budgetTypeList, '\', \'') + '\')';  
            }  
            if(String.isNotBlank(budgetStr)){
                budgetStr = String.escapeSingleQuotes(budgetStr);
                budgetStr = budgetStr.replaceAll('\\\\','');
            }

            if(!program.isEmpty() && program.contains(Core_MDF_CCP_ConstantClass.IPA_PROGRAM)){
                budgetTypeCheck = true;
            }
        
            if(!approvalStageList.isEmpty()){
                if(approvalStageList.contains(Core_MDF_CCP_ConstantClass.L2_REGIONAL_SALES)){
                    classificationValList.add('Sales');
                }
                if(approvalStageList.contains(Core_MDF_CCP_ConstantClass.L2_REGIONAL_MARKETING)){
                    classificationValList.add('Marketing');
                }
            }
            
            if(!classificationValList.isEmpty()){
                classificationValStr ='(\'' + String.join(classificationValList, '\', \'') + '\')'; 
            }  
            if(String.isNotBlank(classificationValStr)){
                classificationValStr = String.escapeSingleQuotes(classificationValStr);
                classificationValStr = classificationValStr.replaceAll('\\\\','');
            }

            qryStr = 'SELECT Id, Core_MDF_User_id__c,Core_MDF_Region_cd__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c, '+
                ' Core_MDF_Program_nm__c, Core_MDF_Role_nm__c, Core_MDF_Activity_Classification_nm__c, ' +
                ' Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c, Core_MDF_All_Budget_Type_Access_Ind__c, Core_MDF_Budget_Type_nm__c ' +
                ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
                ' WHERE Core_MDF_Program_nm__c IN: program' +
                ' and Core_MDF_Region_cd__c INCLUDES ' +geoStr  +
                ' and Core_MDF_Role_nm__c IN: roles'+
                ' and Core_MDF_is_User_Active_ind__c = true '+
                ' and Core_MDF_Active_Ind__c = true'+
                ' and Core_MDF_Is_Not_an_Approver_Ind__c = false ';
                
            if(budgetTypeCheck){
               qryStr += ' and (Core_MDF_All_Budget_Type_Access_Ind__c = true or Core_MDF_Budget_Type_nm__c INCLUDES '+budgetStr +' )';
            }
            if(String.isNotBlank(classificationValStr)){
                qryStr += ' and ((Core_MDF_Role_nm__c =: L2IupgmRole AND Core_MDF_Activity_Classification_nm__c INCLUDES ' + classificationValStr +' ) or (Core_MDF_Role_nm__c !=: L2IupgmRole AND Core_MDF_Activity_Classification_nm__c = \'\'))';
            }
           
            iupgmList = Database.Query(qryStr);
           
            Map<string,List<Id>> subMap = new Map<string,List<Id>>();
            //List<String> pctAndBudgetApproverRoleList = new List<String>{'Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver','Core_MDF_CCP_Internal_DCF_MDF_Budget_Approver','Core_MDF_CCP_Internal_Price_Reviewer'};
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmObj : iupgmList){
                //Akash 
                String key = iupgmObj.Core_MDF_Program_nm__c + iupgmObj.Core_MDF_Role_nm__c;
                // if(pctAndBudgetApproverRoleList.contains(iupgmObj.Core_MDF_Role_nm__c)){
                //     key =iupgmObj.Core_MDF_Program_nm__c + iupgmObj.Core_MDF_Role_nm__c;
                // }else{
                //     key =(iupgmObj.Core_MDF_Program_nm__c=='Client Comarketing Fund'?'Client':iupgmObj.Core_MDF_Program_nm__c=='Data Center Comarketing Fund'?'Datacenter':iupgmObj.Core_MDF_Program_nm__c) +iupgmObj.Core_MDF_Role_nm__c;
                // }
                //String key =(iupgmObj.Core_MDF_Program_nm__c=='Client Comarketing Fund'?'Client':iupgmObj.Core_MDF_Program_nm__c=='Data Center Comarketing Fund'?'Datacenter':iupgmObj.Core_MDF_Program_nm__c) +iupgmObj.Core_MDF_Role_nm__c;
                    
                // Early exit if key not found
                //US - TWC702-14285: Flatten nested IFs (no logic change)
            if(!roleCheckforAccountAccessMap.containsKey(key)){
                System.debug('DEBUG: Key not found in map → ' + key);
                continue; // or continue if this is in a loop 
            }

            // Process geo budget type list
            List<String> geoBudgetTypeList = new List<String>();

            if(iupgmObj.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null){
                for(String geoBudgetTypeStr : iupgmObj.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';')){
                    String geo = geoBudgetTypeStr.split('->')[0];                             
                    String budtype = geoBudgetTypeStr.split('->')[1];
                    
                   if(geo == 'ASMO-LAR' || geo == 'ASMO-NAR' || geo == 'ASMO'){
                                geo = 'ASMO';
                            }
                            geoBudgetTypeList.add(geo+budtype);
                }
            }
            else if(iupgmObj.Core_MDF_Region_cd__c != NULL){
                geoBudgetTypeList.addAll(iupgmObj.Core_MDF_Region_cd__c.split(';'));
            }

            // Process each geo in the list
            for(String geo : geoBudgetTypeList){
                String baseSubMapKey = iupgmObj.Core_MDF_Program_nm__c + geo + iupgmObj.Core_MDF_Role_nm__c + iupgmObj.Core_MDF_Account_id__c;
                system.debug('subMapKey@@@' + baseSubMapKey);
                
                String accessType = roleCheckforAccountAccessMap.get(key);
                
                // Check if this record should be processed
                //US - TWC702-14285: Flatten nested IFs (no logic change)
                Boolean shouldProcess = false;
                
                if(accessType == 'allAccountsYesOrNo'){
                    shouldProcess = true;
                }
                System.debug('DEBUG: Final shouldProcess = ' + shouldProcess);
                
                if(!shouldProcess && accessType == 'allAccountsYes' && iupgmObj.Core_MDF_All_Accounts_cd__c == 'YES'){
                    shouldProcess = true;
                }
                
                if(!shouldProcess && accessType == 'allAccountsNo' && 
                iupgmObj.Core_MDF_All_Accounts_cd__c == 'NO' && 
                accList.contains(iupgmObj.Core_MDF_Account_id__c)){
                    shouldProcess = true;
                }
                
                // Skip if conditions not met
                //US - TWC702-14285: Flatten nested IFs (no logic change)
                if(!shouldProcess){
                    System.debug('DEBUG: Skipping record. shouldProcess = ' + shouldProcess + ', key = ' + key);
                    continue;
                }
                
                // Get or create subMap
                subMap = new Map<String, List<Id>>();
                if(resultMap.containsKey(iupgmObj.Core_MDF_Role_nm__c)){
                    subMap = resultMap.get(iupgmObj.Core_MDF_Role_nm__c);
                }
                
                // Process classifications or use base key
                if(iupgmObj.Core_MDF_Activity_Classification_nm__c != null){
                    for(String classification : iupgmObj.Core_MDF_Activity_Classification_nm__c.split(';')){
                        String subMapKey = baseSubMapKey + classification;
                        
                        if(!subMap.containsKey(subMapKey)){
                            subMap.put(subMapKey, new List<Id>());
                        }
                        subMap.get(subMapKey).add(iupgmObj.Core_MDF_User_id__c);
                    }
                } else {
                    if(!subMap.containsKey(baseSubMapKey)){
                        subMap.put(baseSubMapKey, new List<Id>());
                    }
                    subMap.get(baseSubMapKey).add(iupgmObj.Core_MDF_User_id__c);
                }
                
                resultMap.put(iupgmObj.Core_MDF_Role_nm__c, subMap);
            }
            }
            
        } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        System.debug('resultMap-> '+resultMap);
        return resultMap;
        
    } 
        
        @AuraEnabled
        public static Map<String, Map<String, List<Id>>> getIupgmRecordsPCT(List<String> accList, List<String> progList, List<String> geoList, String roles) {     
            
            List<String> program = new List<String>();     
            Map<String,Object> programNameByRecNameMap = getProgramNameByRecName();
            system.debug('programNameByRecNameMap@@@' + programNameByRecNameMap);
            for(String prgm : progList){
                system.debug('prgm@@@' + prgm);
                if(programNameByRecNameMap.containsKey(prgm)){
                    program.add((String)programNameByRecNameMap.get(prgm));
                }
            }

            system.debug('program@@@' + program);
            system.debug('roles@@@' + roles);
            
           
            Map<String,string> roleCheckforAccountAccessMap = new Map<String,string>();
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            String category = 'Core_MDF_GeneralPurpose_UI_Utility_Role_Mappings';
            List<Core_MDF_Custom_Label_Configration__mdt> mdtRecList = [SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,
                                                                        Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c
                                                                        FROM Core_MDF_Custom_Label_Configration__mdt WHERE Core_MDF_Category_Txt__c =: category
                                                                        AND Core_MDF_Value_Txt__c IN: program AND Core_MDF_Value2_Txt__c =: roles];
            // Highlight: Unused Local Variable - 14285
            // List<String> values = new List<String>();
            for(Core_MDF_Custom_Label_Configration__mdt mdtRec: mdtRecList){
                    roleCheckforAccountAccessMap.put(mdtRec.Core_MDF_Value_Txt__c+mdtRec.Core_MDF_Value2_Txt__c,mdtRec.Core_MDF_Value3_Txt__c);
            }
           
            Map<String, Map<String, List<Id>>> resultMap = new Map<String, Map<String, List<Id>>>();
            String qryStr;
            String geoStr='';
            geoList.add('WW');
           
            if(!geoList.isEmpty()){
                geoStr ='(\'' + String.join(geoList, '\', \'') + '\')';
             
            }
            
        if(String.isNotBlank(geoStr)){
                geoStr = String.escapeSingleQuotes(geoStr);
                
                geoStr = geoStr.replaceAll('\\\\','');
        }
            
            try{
                qryStr = 'SELECT Id, Core_MDF_User_id__c,Core_MDF_Region_cd__c, '+
                    ' Core_MDF_Program_nm__c, Core_MDF_Role_nm__c,Core_MDF_Approval_Region_nm__c, ' +
                    ' Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c ' +
                    ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c'+
                    ' WHERE Core_MDF_Program_nm__c =:program' +
                    //' and Core_MDF_Region_cd__c INCLUDES ' + geoStr +
                    ' and Core_MDF_Role_nm__c =:roles'+
                    ' and Core_MDF_is_User_Active_ind__c = true '+
                    ' and Core_MDF_Active_Ind__c = true' +
                    ' and Core_MDF_Is_Not_an_Approver_Ind__c = false';
                
                //qryStr += (isApprovalBasedOnApprovalRegion(program[0],roles)) ? ' and Core_MDF_Approval_Region_nm__c INCLUDES' + geoStr : 'and Core_MDF_Region_cd__c INCLUDES' + geoStr;

                system.debug('queryString@@@' + qryStr);
               
                iupgmList= Database.Query(qryStr);

                system.debug('iupgmList@@@' + iupgmList);
                system.debug('roleCheckforAccountAccessMap@@@' + roleCheckforAccountAccessMap);
                
                Map<string,List<Id>> subMap = new Map<string,List<Id>>();
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmObj : iupgmList){
                    String key =iupgmObj.Core_MDF_Program_nm__c +iupgmObj.Core_MDF_Role_nm__c;                
                    //early exit
                    //US - TWC702-14285: Flatten nested IFs (no logic change)
                    if(!roleCheckforAccountAccessMap.containsKey(key)){
                        System.debug('DEBUG: key not found in roleCheckforAccountAccessMap → ' + key);
                        continue;
                    }
                        List<String> geoStrList;
                         geoStrList = iupgmObj.Core_MDF_Approval_Region_nm__c != null 
                        ? iupgmObj.Core_MDF_Approval_Region_nm__c.split(';') : iupgmObj.Core_MDF_Region_cd__c != null 
                        ? iupgmObj.Core_MDF_Region_cd__c.split(';') : new List<string>();

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
                
            } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
            return resultMap;
        }
        public static Map<String,Object> getProgramNameByRecName(){
            String jsonInputString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ProgramMappingByName');
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInputString);
            
            return resultMap;
        }
        public static Map<String,Object> getProgramNameByRecordTypeDevName(){
            String jsonInputString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ProgramMappingByDevloperName');
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInputString);
            
            return resultMap;
        }
    /*
    Method Name     : isRecordApprover
    Input Parameters : Sobject and userId
    Return type : Boolean
    Description : Returns the result if user has an access in IUPGM for input record and if an approver
    */
    public static Boolean isRecordApprover(sObject sObj, String userId){
        Boolean result = false;
        String recordTypeDevName;
        String accountId;
        String geo;
        String subGeo;
        String hostGeo;
        String approvalStage;
        String program; 
        String budgetType;
        String activityClassification;
    String reviewType;
        Map<String,Object> programNameByRecTypeDevNameMap;
        Boolean isProposalBased = false;
        // Highlight: Unused Local Variable - 14285
        // List<String> activityClassficationList = new List<String>();
        InputDetailsWrapper resultObj;
        //get Object Name for sobject   
        String objectName = sObj != null ? sObj.id.getSObjectType().getDescribe().getName() :'';
        Map<String,Object> programNameByRecNameMap = getProgramNameByRecName();
        
       
        //Switch case Start.
        if(String.isNotBlank(objectName)){
            switch on objectName {
                when 'PartnerFundRequest' {     // when PartnerFundRequest
                    PartnerFundRequest pfrObj = (PartnerFundRequest)sObj;
                    recordTypeDevName = pfrObj.recordType.DeveloperName;
                    accountId = pfrObj.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM && (pfrObj.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER || pfrObj.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_PRIMARY_APPROVAL) ? pfrObj.Core_MDF_Campaign_Ultimate_Account_Id__c : pfrObj.Core_MDF_Ultimate_Account_Id__c;
                    //geo = pfrObj.Core_MDF_Region_nm__c;
                    geo = pfrObj.Core_MDF_Host_Region_or_Region_txt__c;//For IPA & !PCT it stores Host Geo, else Transaction geo.
                    subGeo = pfrObj.Core_MDF_Sub_Region_nm__c;
                    //hostGeo = pfrObj.Core_MDF_Host_Region_txt__c; //This code is removed since above geo will dynamically get host/transaction geo
                    //approvalStage = pfrObj.Core_MDF_Approval_Stage__c;
                    approvalStage = pfrObj.Core_MDF_Proposal_Based_Ind__c == false ? pfrObj.Core_MDF_Approval_Stage__c : pfrObj.Campaign.Core_MDF_Approval_Stage_nm__c;
                    budgetType = pfrObj.Core_MDF_Budget_Type_nm__c;         
                    isProposalBased = pfrObj.Core_MDF_Proposal_Based_Ind__c;
            reviewType = pfrObj.Core_MDF_Additional_Review_Type_txt__c;
                    program = pfrObj.recordType.DeveloperName;
                    //Activity classification
                    if(approvalStage == Core_MDF_CCP_ConstantClass.L2_REGIONAL_MARKETING){
                        activityClassification = 'Marketing';
                    }
                    else if(approvalStage == Core_MDF_CCP_ConstantClass.L2_REGIONAL_SALES){
                        activityClassification = 'Sales';
                    }else{
                        activityClassification = '';
                    }
                }
                when 'Campaign' {       // when Campaign
                    Campaign campaignObj = (Campaign)sObj;
                    recordTypeDevName = campaignObj.recordType.DeveloperName;    
                    accountId = campaignObj.Core_MDF_Ultimate_Account_txt__c;
                    //geo = campaignObj.recordType.DeveloperName == 'Core_MDF_Co_GTM' ? 'WW' : campaignObj.Core_MDF_Region_cd__c;   //Roshan - Added for inprogress Co-GTM changes. 
                    geo = campaignObj.Core_MDF_Region_cd__c;
                    subGeo = campaignObj.Core_MDF_Sub_Region_cd__c;
                    hostGeo = campaignObj.Core_MDF_Host_Region_cd__c;
                    approvalStage = campaignObj.Core_MDF_Approval_Stage_nm__c;
                    budgetType = campaignObj.Core_MDF_Budget_Type_txt__c;
                    isProposalBased = campaignObj.Core_MDF_Proposal_Based_Ind__c;
                    program = campaignObj.Core_MDF_Program__c;
                    //Activity classification
                    if(approvalStage == Core_MDF_CCP_ConstantClass.L2_REGIONAL_MARKETING){
                        activityClassification = 'Marketing';
                    }
                    else if(approvalStage == Core_MDF_CCP_ConstantClass.L2_REGIONAL_SALES){
                        activityClassification = 'Sales';
                    }
                    
                    else{
                        activityClassification = '';
                    }

                }
                when 'PartnerMarketingBudget' {     // when PartnerFundRequest
                    system.debug('Processing PartnerMarketingBudget');
                    PartnerMarketingBudget pmbObj = (PartnerMarketingBudget)sObj;
                    system.debug('Processing pmbObj: ' + pmbObj);
                    recordTypeDevName = pmbObj.recordType.DeveloperName;
                    system.debug('Processing recordTypeDevName: ' + recordTypeDevName);
                    accountId = pmbObj.Core_MDF_Ultimate_Account_Id__c;
                    system.debug('Processing accountId: ' + accountId);
                    geo = 'WW';
                    budgetType = pmbObj.Core_MDF_Budget_Type_Txt__c;
                    system.debug('Processing budgetType: ' + budgetType);
                    program = programNameByRecNameMap.containsKey(pmbObj.Core_MDF_Program_Nm__c) ? (String)programNameByRecNameMap.get(pmbObj.Core_MDF_Program_Nm__c) : pmbObj.Core_MDF_Program_Nm__c;
                    system.debug('Processing program: ' + program);
                    //program = program.replaceAll('[^a-zA-Z0-9\\s+]', '');
                    approvalStage = 'None';
                }
                when 'PartnerFundClaim' {  //Claim approval setup
                    PartnerFundClaim pfcObj = (PartnerFundClaim)sObj;
                    recordTypeDevName = pfcObj.recordType.DeveloperName;
                    accountId = pfcObj.Core_MDF_Ultimate_Account_ID__c;
                    geo = pfcObj.Core_MDF_Campaign_Id__r.Core_MDF_Region_cd__c;  //used for cogtm
                    //hostGeo = pfcObj.Core_MDF_Campaign_Id__r.Core_MDF_Host_Region_cd__c;  //used for ipa outcome based
                    hostGeo = pfcObj.Request.Core_MDF_Host_Region_txt__c;  //Roshan - Super Activity changes
                    budgetType = pfcObj.Core_MDF_Budget_Type_Options_Nm__c;
                    isProposalBased = pfcObj.Core_MDF_Proposal_Based_Ind__c;
                    //program = pfcObj.Core_MDF_Campaign_Id__r.Core_MDF_Program__c;
                    //program = (recordTypeDevName == Core_MDF_CCP_ConstantClass.CMP_CO_GTM_RECORDTYPE) ? pfcObj.Core_MDF_Campaign_Id__r.Core_MDF_Program__c : pfcObj.Core_MDF_Program__c;  //Roshan - Super Activity changes
                    program = pfcObj.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;  //Roshan - Super Activity changes
                    approvalStage = pfcObj.Core_MDF_Approval_Stage_nm__c;
                }
                when else {
                    system.debug('1453@@');       
                    return false;
                }       
            }
            //Switch case end.
        
            //Get the program Name.
            programNameByRecTypeDevNameMap = getProgramNameByRecordTypeDevName();
            if(programNameByRecTypeDevNameMap.containsKey(program)){
                program = (String)programNameByRecTypeDevNameMap.get(program);
            }
            //Get geo/hostGeo based on program
            geo= String.isNotBlank(geo)? String.escapeSingleQuotes(geo):'';
            hostGeo = String.isNotBlank(hostGeo)? String.escapeSingleQuotes(hostGeo):'';
            geo  = string.isNotBlank(hostGeo) ? hostGeo : geo;
            String geoStr = getGeoWithWWAsString(geo);  // ('EMEA', 'PRC', 'APJ', 'ASMO', 'INDIA', 'WW')
            String geoBudgetTypeStr =  getGeoBudgetTypeWithWWAsString(geo, budgetType);  // ('EMEA;PRC;APJ;ASMO;INDIA->Account Plan', 'WW->Account Plan')
            //Activity classfication check
            activityClassification = (String.isNotBlank(activityClassification)) ?  activityClassification.contains(',') ?  activityClassification : getActivityClassificationAsString(activityClassification) :'';     
            //prepare inputwrapper instance
            InputDetailsWrapper objInputDetailsWrapper = new InputDetailsWrapper();
            objInputDetailsWrapper.objectName = objectName;
            objInputDetailsWrapper.programName = program;
            objInputDetailsWrapper.approvalStage = approvalStage;
            objInputDetailsWrapper.accountId = accountId;
            objInputDetailsWrapper.region =  geoStr;
            objInputDetailsWrapper.bugetType = budgetType;
            objInputDetailsWrapper.geoBudgetType = geoBudgetTypeStr;
            objInputDetailsWrapper.isProposalBased = isProposalBased;
            objInputDetailsWrapper.activityClassification = activityClassification;
            objInputDetailsWrapper.userId = userId;

            system.debug('objInputDetailsWrapper@@@' + objInputDetailsWrapper);

            
            //Get the role by approval stage
            if(objInputDetailsWrapper != null){
                resultObj = getRoleNameByApprovalStage(objInputDetailsWrapper);
                if(approvalStage=='Additional Reviewer'){
            resultObj.role=(program=='Client CoMarketing Fund' && reviewType=='Field Review') ? 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr':
                    (program=='Client CoMarketing Fund' && reviewType=='Marketing Review') ? 'Core_MDF_CCP_Internal_CCF_Acct_Mgr':
                    (program=='Data Center CoMarketing Fund' && reviewType=='Field Review') ? 'Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr':
                    (program=='Data Center CoMarketing Fund' && reviewType=='Marketing Review') ? 'Core_MDF_CCP_Internal_DCF_Acct_Mgr':null;                
        }
            }
            //Get the role by approval stage
            /*if(objInputDetailsWrapper != null){
                resultObj = getRoleNameByApprovalStage(objInputDetailsWrapper);
            }*/

          
            if(resultObj != null){
                system.debug('resultObj@@@' + resultObj);
                List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> resultList = getIUPGMRecords(resultObj);
                system.debug('result@@@' + resultList);
               
                if(resultList !=null && !resultList.isEmpty()){
                    
                    result = true;
                }
                else{
                    result = false;
                }
            }else{
                return false;
            }
        }
        return result;
    }
        
        public static string getGeoWithWWAsString(String geo) {
            String geoStr;
          
            List<String> varGeoList = new List<String>();
            if(String.isNotBlank(geo)) {
        
                //varGeoList.add(geo);

                // Roshan - CoGTM multi geo fix
                if(geo.contains(';')) {
                    for (String g : geo.split(';')) {
                        if (String.isNotBlank(g)) {
                            varGeoList.add(g);
                        }
                    }
                } else {
                    varGeoList.add(geo);
                }

                varGeoList.add('WW');
                geoStr ='(\'' + String.join(varGeoList, '\', \'') + '\')';
            }
            return geoStr;
        }
        
        public static string getGeoBudgetTypeWithWWAsString(String geo, String budgetType){
        String geoBudgetStr;
        List<String> varGeoBudgetTypeList = new List<String>();
        if(String.isNotBlank(geo)){
                varGeoBudgetTypeList.add(geo + '->' + budgetType);
                varGeoBudgetTypeList.add('WW' + '->' + budgetType);
                geoBudgetStr ='(\'' + String.join(varGeoBudgetTypeList, '\', \'') + '\')';
        }
        return geoBudgetStr;
        }
        public static string getActivityClassificationAsString(String activityClassification){
        String activityClassificationStr;
        List<String> activityClassificationList = new List<String>();
        if(String.isNotBlank(activityClassification)){
                activityClassificationList.add(activityClassification);
                activityClassificationStr ='(\'' + String.join(activityClassificationList, '\', \'') + '\')';
        }
        return activityClassificationStr;
        }
        /*
            This method used to get approver role based on program, approval stage
            Also this method sets the 2 static attributes isBudgetTypeCheckRequired and isActivityClassificationCheckReq
            i. isBudgetTypeCheckRequired -> Based on the role configured in IUPGM for geo/geoBudgetType , logic sets it as per the IUPGM role configuration
            ii.isActivityClassificationCheckReq -> it is used to identyfing IUPGM records if role is based on activity classification

        */
    
    public static InputDetailsWrapper getRoleNameByApprovalStage(InputDetailsWrapper inputWrapperObj){
        String objName = '';
            
        InputDetailsWrapper resultObj;
        if(inputWrapperObj != null ){       
            objName = inputWrapperObj.objectName;
            String program = String.isNotBlank(inputWrapperObj.programName) ? inputWrapperObj.programName :'';
            Boolean isProposalBased = inputWrapperObj.isProposalBased != null && inputWrapperObj.isProposalBased == true ? inputWrapperObj.isProposalBased : false;
            String approvalStage = String.isNotBlank(inputWrapperObj.approvalStage) ? inputWrapperObj.approvalStage : '' ;
            resultObj = inputWrapperObj;
         
            List<Core_MDF_CCP_IUPGM_Approver_Mapping__c> approverMappingList = [SELECT Id,Core_MDF_Role_txt__c,Core_MDF_Budget_Type_Access_ind__c,Core_MDF_Activity_Classification_ind__c
                                                                                FROM Core_MDF_CCP_IUPGM_Approver_Mapping__c
                                                                                WHERE Core_MDF_Object_Name_txt__c =:objName
                                                                                AND Core_MDF_Program_txt__c =: program
                                                                                AND Core_MDF_Approval_Stage_txt__c =:approvalStage
                                                                                AND Core_MDF_Active_ind__c = true];
            
            
            if(approverMappingList !=null && !approverMappingList.isEmpty()){
                resultObj.role =  approverMappingList[0].Core_MDF_Role_txt__c;
                resultObj.isActivityClassificationCheckRequired = approverMappingList[0].Core_MDF_Activity_Classification_ind__c;
                resultObj.isBudgetTypeCheckRequired = approverMappingList[0].Core_MDF_Budget_Type_Access_ind__c;
                
            }else{
                return resultObj;
            }   
            
        }
        return resultObj;
    }
        //This method used to get the IUPGM records based on input paramaters.
        public static List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> getIUPGMRecords(InputDetailsWrapper inputWrapperObj){
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmRecordList;
        if(inputWrapperObj != null){
        //String category = 'Core_MDF_GeneralPurpose_UI_Utility_Role_Mappings';
        String allAccountsYes = 'Yes';
        String allAccountsNo = 'No';
        String role =  String.isNotBlank(inputWrapperObj.role) ? inputWrapperObj.role : '';
        String program = String.isNotBlank(inputWrapperObj.programName) ? inputWrapperObj.programName : '';
        String userId = String.isNotBlank(inputWrapperObj.userId)? inputWrapperObj.userId : '';
        String accId = String.isNotBlank(inputWrapperObj.accountId)? inputWrapperObj.accountId : '';
        String region = String.isNotBlank(inputWrapperObj.region)? inputWrapperObj.region : '';
        String geoBudgetType = String.isNotBlank(inputWrapperObj.geoBudgetType)? inputWrapperObj.geoBudgetType : '';
        String activityClassification = String.isNotBlank(inputWrapperObj.activityClassification)? inputWrapperObj.activityClassification : '';
        Boolean isActivityClassificationCheckReq = inputWrapperObj.isActivityClassificationCheckRequired != null && inputWrapperObj.isActivityClassificationCheckRequired == true ? inputWrapperObj.isActivityClassificationCheckRequired: false;
        Boolean isBudgetTypeCheckRequired = inputWrapperObj.isBudgetTypeCheckRequired != null &&  inputWrapperObj.isBudgetTypeCheckRequired == true? inputWrapperObj.isBudgetTypeCheckRequired : false;
       
        // Get the role and All accounts opptions based on the configuration
                    String qryStr = 'SELECT Id, Core_MDF_User_id__c '+
                    ' FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c' +
                    ' WHERE Core_MDF_Program_nm__c =: program' +              
                    ' and Core_MDF_Role_nm__c =: role'+
                    ' and Core_MDF_is_User_Active_ind__c = true '+
                    ' and Core_MDF_Active_Ind__c = true' +
                    ' and Core_MDF_Is_Not_an_Approver_Ind__c = false'; 
                    //' and Core_MDF_User_id__c =: userId';
                    
                    System.debug('First check '+ qryStr);
                    if(String.isNotBlank(userId)){
                        qryStr += ' and Core_MDF_User_id__c =: userId';
                    }
                        qryStr += ' and (Core_MDF_All_Accounts_cd__c = ' + '\'' + String.escapeSingleQuotes(allAccountsYes) + '\'' +
                            ' OR (Core_MDF_All_Accounts_cd__c = ' +  '\'' + String.escapeSingleQuotes(allAccountsNo) + '\'' +
                            ' and Core_MDF_Account_id__c =:accId))';
                            System.debug('second check '+ qryStr);
            
            geoBudgetType = String.escapeSingleQuotes(geoBudgetType).replaceAll('\\\\','');
         region = String.escapeSingleQuotes(region).replaceAll('\\\\','');
         activityClassification = String.escapeSingleQuotes(activityClassification).replaceAll('\\\\','');
         System.debug('third check '+ geoBudgetType);
          System.debug('fourth check '+ region);
           System.debug('fifth check '+ activityClassification);
            
            //2. Filter condition for Geo/Geo->BudgetType 
            // CHANGE START - Added by Shravani as part of Unhandled Exception fix (added null checks for region and geoBudgetType) 
            //region = String.isBlank(region) ? '(\'WW\')' : region; // if regoin is blank use WW
            if(String.isBlank(region)){
                region = '(\'WW\')'; 
            }
            if(isBudgetTypeCheckRequired){
                if(String.isNotBlank(geoBudgetType)){
                    qryStr +=' and ((Core_MDF_All_Budget_Type_Access_Ind__c = false and Core_MDF_GeoSubGeo_Budget_Type_nm__c INCLUDES ' + geoBudgetType +')' 
                            + ' OR (Core_MDF_All_Budget_Type_Access_Ind__c = true and Core_MDF_Region_cd__c INCLUDES ' + region +'))'; 
                            System.debug('6th check '+ qryStr); 
                }else{
                    qryStr +=' and (Core_MDF_All_Budget_Type_Access_Ind__c = true and Core_MDF_Region_cd__c INCLUDES ' + region +')'; 
                            System.debug('6th check for else'+ qryStr); 

                }
            }else if(isApprovalBasedOnApprovalRegion(program,role)){
                qryStr +=' and (Core_MDF_Approval_Region_nm__c INCLUDES ' + region + ')'; 
                System.debug('7th check '+ qryStr);   
            }else{
                qryStr +=' and (Core_MDF_Region_cd__c INCLUDES ' + region + ')'; 
                System.debug('8th check '+ qryStr);      
            }
            // CHANGE END - Unhandled Exception fix
        
                    
            // 3. Filter condition for Activity classification
            if(isActivityClassificationCheckReq && String.isNotBlank(activityClassification)){
                qryStr += ' and Core_MDF_Activity_Classification_nm__c INCLUDES ' + activityClassification;
                System.debug('9th check '+ qryStr); 
            }
            system.debug('role@@@' + role);
            system.debug('query@@@' + userId);
            system.debug('query@@@' + qryStr);
            // Fetch the query data
            iupgmRecordList =  Database.Query(qryStr);
            system.debug('iupgmRecordList@@@' + iupgmRecordList);
        
        //}
        }
        else{
            return null;
        }
        return iupgmRecordList;
    }
   
    public static Boolean isApprovalBasedOnApprovalRegion(string program, string role){
        string IPA_PROG = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
        string PRICE_REVIEWER = Core_MDF_CCP_ConstantClass.CCF_PRICE_REVIEWER;
        Boolean isReferApprovalRegion = false;

        isReferApprovalRegion = (program == IPA_PROG && role == PRICE_REVIEWER) ? true : false;
        return isReferApprovalRegion;
    }

            
    /***************************************************************************************************** 
    Method Name   :        getByPassFieldValidationConfiq
    @return       :        fieldToByPassFlag Map
    Description   :        Pass required parameter to byPass field level validation
    Added By      :        Shiva
    ******************************************************************************************************/  
        
    public static Map<string,Boolean> getByPassFieldValidationConfiq(string objectName, string progName, Datetime createdDate){
        Map<string,Boolean> fieldToByPassIndMap = new Map<string,Boolean>();
        List<Core_MDF_ByPass_FieldValidation__c> byPassCsList =  [SELECT Id, Core_MDF_Object__c,Core_MDF_Field_Api_Name__c,
                                                                        Core_MDF_Program__c, Core_MDF_Release__c,Core_MDF_ByPass_Validation_Date__c,
                                                                        Core_MDF_Active__c,Core_MDF_ByPass_for_All_Program__c 
                                                                        FROM Core_MDF_ByPass_FieldValidation__c 
                                                                        WHERE Core_MDF_Object__c =: objectName
                                                                        AND (Core_MDF_ByPass_for_All_Program__c = true OR Core_MDF_Program__c =: progName)
                                                                        AND Core_MDF_Active__c = true];

        if(byPassCsList != null && !byPassCsList.isEmpty()){
            for(Core_MDF_ByPass_FieldValidation__c csRec: byPassCsList){
                    Date validationDate = csRec.Core_MDF_ByPass_Validation_Date__c;
                    Boolean byPassValidation = (createdDate < validationDate) ? true : false;
                    fieldToByPassIndMap.put(csRec.Core_MDF_Field_Api_Name__c,byPassValidation);
            }
        }
        
        return fieldToByPassIndMap;
    }
    
    
    public static boolean isByPassFieldValidation(Map<string,Boolean> fieldToByPassFlagMap, string fieldApiName){
        Boolean bypass = false;
        if(fieldToByPassFlagMap.containsKey(fieldApiName) && fieldToByPassFlagMap.get(fieldApiName)){
            bypass = true;
        }
        return bypass;
    }



    //Wrapper class for input details
    public Class InputDetailsWrapper{
        public String objectName {get;set;}
        public String programName {get;set;}
        public String approvalStage{get;set;}
        public String accountId {get;set;}
        public String role{get;set;}
        public String region {get;set;}
        public String bugetType {get;set;}
        public String geoBudgetType {get;set;}
        public String activityClassification {get;set;}
        public String userId {get;set;}
        public Boolean isProposalBased {get;set;}
        public Boolean isActivityClassificationCheckRequired {get;set;}
        public Boolean isBudgetTypeCheckRequired {get;set;}
        public InputDetailsWrapper(){}
    }

    /*---------------------------------------------------------------------------------------------
    Class Name          : ActivityOwnerRequest
    Description         : Request wrapper for activity owner related methods (getIntelActivityOwners, isApprover)
    ---------------------------------------------------------------------------------------------- */
    public class ActivityOwnerRequest {
        public String accId;
        public String primaryAcctId;
        public String program;
        public List<String> country;
        public String budgetType;
        public Boolean isPlannedEdited;
        public String userId; // used for isApprover

        public ActivityOwnerRequest(String accId, String primaryAcctId, String program, List<String> country, String budgetType, Boolean isPlannedEdited) {
            this.accId = accId;
            this.primaryAcctId = primaryAcctId;
            this.program = program;
            this.country = country;
            this.budgetType = budgetType;
            this.isPlannedEdited = isPlannedEdited;
        }

        public ActivityOwnerRequest(String accId, String primaryAcctId, String program, List<String> country, String budgetType, String userId) {
            this.accId = accId;
            this.primaryAcctId = primaryAcctId;
            this.program = program;
            this.country = country;
            this.budgetType = budgetType;
            this.userId = userId;
        }
    }

    /*---------------------------------------------------------------------------------------------
    Class Name          : RecordApprovalRequest
    Description         : Request wrapper for record approval methods (isRecordApprover, isRecordApproverWithBudgetType)
    ---------------------------------------------------------------------------------------------- */
    public class RecordApprovalRequest {
        public String accId;
        public String program;
        public List<String> country;
        public String approvalStage;
        public String userId;
        public String budgetType; // optional, null for isRecordApprover

        public RecordApprovalRequest(String accId, String program, List<String> country, String approvalStage, String userId) {
            this.accId = accId;
            this.program = program;
            this.country = country;
            this.approvalStage = approvalStage;
            this.userId = userId;
            this.budgetType = null;
        }

        public RecordApprovalRequest(String accId, String program, List<String> country, String approvalStage, String userId, String budgetType) {
            this.accId = accId;
            this.program = program;
            this.country = country;
            this.approvalStage = approvalStage;
            this.userId = userId;
            this.budgetType = budgetType;
        }
    }

    /*---------------------------------------------------------------------------------------------
    Class Name          : IupgmQueryRequest
    Description         : Request wrapper for IUPGM query methods (getIupgmRecords, getIupgmRecordsWithBudgetType)
    ---------------------------------------------------------------------------------------------- */
    public class IupgmQueryRequest {
        public String accId;
        public String program;
        public String userId;
        public String geoStr;
        public String roles;
        public String budgetType; // optional

        public IupgmQueryRequest(String accId, String program, String userId, String geoStr, String roles) {
            this.accId = accId;
            this.program = program;
            this.userId = userId;
            this.geoStr = geoStr;
            this.roles = roles;
            this.budgetType = null;
        }

        public IupgmQueryRequest(String accId, String program, String userId, String geoStr, String roles, String budgetType) {
            this.accId = accId;
            this.program = program;
            this.userId = userId;
            this.geoStr = geoStr;
            this.roles = roles;
            this.budgetType = budgetType;
        }
    }

    }