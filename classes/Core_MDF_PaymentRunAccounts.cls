/****************************************************************************************************************************************
* Class Name      : Core_MDF_PaymentRunAccounts
* Version               : 1.0 
* Created Date          : 26-09-2021
* Modification Log      : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - NK     26-09-2021        Payment Run Accounts Handler class for MDF/MDF+ payments.
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PaymentRunAccounts {
    /***************************************************************************************************** 
Method Name:        fetchAllMappedAccounts
Description:        To fetch Accounts mapped to logged-in user through IUPGM
@Added By:          Accenture - NK - 26-09-2021
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static IupgmWrapper fetchAllMappedAccounts(){
        IupgmWrapper iupgmWrap = new IupgmWrapper();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        List<String> listOfIUPGMRoleValues = new List<String>();
        Boolean loggedInUserHasIUPGMReqdRole = false;
        Boolean iupgmAllAccountsFlag = false;
        Set<Id> allMappedAccountIds = new Set<Id>();
        List<String> allMappedAccountNames = new List<String>();
        // Fetching IUPGM Role Picklist Values 
        listOfIUPGMRoleValues = getIUPGMRolePickListValues();
        // Method to check If logged In User has IUPGM Required role
        loggedInUserHasIUPGMReqdRole = checkLoggedInUserhasReqdRole(listOfIUPGMRoleValues);
        //ATHR - Deeply Nested if 16209
        if(!loggedInUserHasIUPGMReqdRole){
            iupgmWrap.allAccountsAccess = iupgmAllAccountsFlag;
            iupgmWrap.selectedAccIdsInIUPGM = allMappedAccountIds;
            iupgmWrap.selectedAccNamesInIUPGM = allMappedAccountNames;
            return iupgmWrap;
        }
        //f(loggedInUserHasIUPGMReqdRole){
            //List<String> channelProgramsList = new List<String>();
            // Querying All Accounts that are mapped with the logged In User through IUPGM
            iupgmList = [SELECT Core_MDF_Account_id__c,Core_MDF_Program_nm__c,Core_MDF_All_Accounts_cd__c,Core_MDF_Account_id__r.Name, Core_MDF_Account_id__r.Core_MDF_CoMarketingActive__c,Core_MDF_Account_id__r.RecordType.DeveloperName, Core_MDF_Account_id__r.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_User_id__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c WHERE Core_MDF_User_id__c =: Userinfo.getUserId() AND Core_MDF_User_id__r.IsActive = true AND Core_MDF_Active_Ind__c = true];
            if(iupgmList != NULL && iupgmList.size()>0){
               
                // Adding Ultimate Accounts in a Set
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
                    // If All Accounts field on iupgm is set to Yes then set the boolean to true and Add the Programs into List
                    //ATHR - Deeply Nested if 16209
                    if(iupgm.Core_MDF_All_Accounts_cd__c != Label.Core_MDF_NonTranslateYes && iupgm.Core_MDF_Account_id__c != NULL && iupgm.Core_MDF_Account_id__r.RecordType.DeveloperName != 'Core_MDF_Co_Marketing'){ 
                        //if(iupgm.Core_MDF_Account_id__c != NULL && iupgm.Core_MDF_Account_id__r.RecordType.DeveloperName != 'Core_MDF_Co_Marketing'){
                            allMappedAccountIds.add(iupgm.Core_MDF_Account_id__c);
                            allMappedAccountNames.add(iupgm.Core_MDF_Account_id__r.Name);
                        //}
                    }
                    else{
                        iupgmAllAccountsFlag = true;
                    }
                }
            } 
        //}        
        iupgmWrap.allAccountsAccess = iupgmAllAccountsFlag;
        iupgmWrap.selectedAccIdsInIUPGM = allMappedAccountIds;
        iupgmWrap.selectedAccNamesInIUPGM = allMappedAccountNames;
        return iupgmWrap;
    }
 /***************************************************************************************************** 
Method Name:        getIUPGMRolePickListValues
Description:        Getting IUPGM Role Picklist field Values
@Added By:          Accenture - NK - 26-09-2021
Modified By:        Date:       Changes: 
******************************************************************************************************/  
    public static List<String> getIUPGMRolePickListValues(){
        List<String> listOfPicklistValues= new List<String>();
        Schema.DescribeFieldResult fieldResult = Core_MDF_Int_Users_Partner_Geo_Mapping__c.Core_MDF_Role_nm__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            listOfPicklistValues.add(pickListVal.getValue());
        }
        return listOfPicklistValues;
    }
  
/***************************************************************************************************** 
Method Name:        checkLoggedInUserhasReqdRole
Description:        Method to Check If Logged In User has IUPGM Required Role
@Added By:          Accenture - NK - 26-09-2021
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static Boolean checkLoggedInUserhasReqdRole(List<String> iupgmRoleValues){
        Boolean loggedInUserHasIUPGMReqdRole = false;
        List<PermissionSetAssignment> iupgmPermissionSetsAssigned = new List<PermissionSetAssignment>();
        // Querying All IUPGM Required Permission Sets Assigned to the Logged In User
        iupgmPermissionSetsAssigned = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name IN: iupgmRoleValues];
        // If the User has at least single Role Set the flag to true
        if(iupgmPermissionSetsAssigned != NULL && iupgmPermissionSetsAssigned.size()>0){
            loggedInUserHasIUPGMReqdRole = true;
        }
        return loggedInUserHasIUPGMReqdRole;
    }
    
/***************************************************************************************************** 
Method Name:        fetchAccounts
Description:        Fetch accounts from payment run backend account field to display on detail page
@Added By:          Accenture - NK - 26-09-2021
Modified By:        Date:       Changes: 
******************************************************************************************************/        
    @AuraEnabled(cacheable = true)
    public static List<Account> fetchAccounts(Id paymentRunId){
        Core_MDF_Payment_Run__c pRun = [select Id,Core_MDF_Payment_run_for_Accounts__c from Core_MDF_Payment_Run__c where Id =:paymentRunId];
         List<String> AccIdList = new  List<String>();
        List<Account> accList;
        if(pRun != null && String.isNotBlank(pRun.Core_MDF_Payment_run_for_Accounts__c)){
            AccIdList = pRun.Core_MDF_Payment_run_for_Accounts__c.split('[,;]');
        }
        if(!AccIdList.isEmpty()){
            accList = [select Id,Name from Account where Id in : AccIdList];
        }
        return accList;
    }
 /***************************************************************************************************** 
Method Name:        ValidateAccountProgram
Description:        method to returm program mapped to each account in PGM
@Added By:          Accenture - NK - 26-09-2021
Modified By:        Date:       Changes: 
******************************************************************************************************/   
    public static Map<Id,List<String>> FetchAccountProgramMapping(Set<Id> AccIds){
       Map<Id,List<String>> accIdToProgramsMap = new Map<Id,List<String>>();
         List<Core_MDF_Partner_Group_Mapping__c> pgms =new List<Core_MDF_Partner_Group_Mapping__c>();
        if(!AccIds.isEmpty())
        {
         //pgms = [Select Id,Core_MDF_Account__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Account__c IN :AccIds AND Core_MDF_Inactive_Ind__c = false AND Core_MDF_Type_of_Access__c='External'AND Core_MDF_CoMarketingActive_Ind__c=true ]; 
         pgms = Core_MDF_PGM_Utility.fetchExternalPGMRecords(null,AccIds,null,null,null,true);
        }
        If(pgms != Null && pgms.size()>0)
        {
            For(Core_MDF_Partner_Group_Mapping__c pgm : pgms)
            {
                if(accIdToProgramsMap.containsKey(pgm.Core_MDF_Account__c)){
                    accIdToProgramsMap.get(pgm.Core_MDF_Account__c).add(pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
                }
                else{
                    accIdToProgramsMap.put(pgm.Core_MDF_Account__c,new List<String>{pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c});
                }
                
            }
        }
        
        return accIdToProgramsMap;
    }
    
     /***************************************************************************************************** 
Class Name:        IupgmWrapper 
Description:       Wrapper to pass IUPGM details of logged-in user
@Added By:         Accenture - NK - 26-09-2021
Modified By:       Date:       Changes: 
******************************************************************************************************/ 
    Public class IupgmWrapper{
        public Boolean allAccountsAccess;
        public Set<Id> selectedAccIdsInIUPGM;
        public list<String> selectedAccNamesInIUPGM;         
    }
}