/**************************************************************************************************
* Apex Class Name   : Core_UtilityController
* Created Date      : 12 Aug 2019
* Description       : Utility methods to handle generic functions
* 
* Developer             Date        Description
* -------------------------------------------------------------------------------------------------                 
* Sandip Ghosh         08/12/2019  Original Version
**************************************************************************************************/
public without sharing class  Core_UtilityController { 

    
    public static final String PMP_INTERNAL_ADMIN_STR = '%PMP_Internal_Intel_Admin%';
    public static final String ACTIVE_STATUS = 'Active';
    @AuraEnabled 
    public static user fetchUser(){
        // query current user information  
        User oUser;
        try{
        oUser= [select id,Name,Email,ContactId,FederationIdentifier,Contact.Email,Contact.Core_eRPM_Person_Id__c 
                      FROM User  Where id =: userInfo.getUserId() ];
        }   
        catch(System.QueryException qe) {
            System.debug(qe.getMessage());
    }
        return oUser;
    }
    
    @AuraEnabled 
    public static String fetchPermissionSetName(){
        
        String permissionSetName = '';
        // query current user information
        List<PermissionSetAssignment> permAssignmentList;
        
        try{
            permAssignmentList = [SELECT PermissionSetId, PermissionSet.Name FROM PermissionSetAssignment 
                                                            where PermissionSet.Name LIKE :PMP_INTERNAL_ADMIN_STR
                                                            AND AssigneeId = :userInfo.getUserId()]; /*0050n00000236Y4*/ //:userInfo.getUserId()
        }
        catch(System.QueryException qe) {
            System.debug(qe.getMessage());
    }
        PermissionSetAssignment permissionSetAssignment;
        if(permAssignmentList != null && !permAssignmentList.isEmpty()){
            permissionSetAssignment =  permAssignmentList[0];
            if(permissionSetAssignment.PermissionSet != null){
                permissionSetName = permissionSetAssignment.PermissionSet.Name;
            }
            
        }
        return permissionSetName;
    }
    
    @AuraEnabled 
    public static Map<String, Boolean> checkForCustomPermission(){
        
        PMP_CustomPermissionsReader cpr = new PMP_CustomPermissionsReader();
        List<String> listOfPermissions = Label.PMP_All_Custom_Permissions.split(';');
        return cpr.hasPermission(listOfPermissions);
    }
    
    //Gireesh:Refractored the code
    @AuraEnabled
    public static String checkBenefitLevel(){ //String userId//Id userId
        // query current user information
        String benefitName = '';
        List<User> oUserList = new List<User>();        
        
        oUserList = PMP_Utility.getLoggedInUser();
        
        if(oUserList != null && !oUserList.isEmpty()){
            
            User oUser =  oUserList[0];
            //if(oUser.AccountId != null){
            if(oUser.Core_IPA_One_Partner_Id__c != null){
                
                //Get Company Info and Benefit details for OPID
                List<PMP_Company__c> companyBenefits = PMP_Utility.getCompanyInfoForOpid(oUser.Core_IPA_One_Partner_Id__c);
                //system.debug('company = ' + companyBenefits[0]);
                if(companyBenefits!=null && !companyBenefits.isEmpty()){
                    PMP_Company__c companyBenefit = companyBenefits[0];
                    if(companyBenefit.PMP_Benefit_Update_Ind__c != true && companyBenefit.PMP_Partner_Inactive_Ind__c != true){
                        
                            benefitName = companyBenefit.PMP_Partner_Benefit_Type__c;
                        
                    }
                                            
                }                
            }
             if(oUser.AccountId != null){
                //Get Company Info and Benefit details for Location account
                List<PMP_Company__c> locCompanyList;
                try{
                /* Commented as part of OPID Restructure - Sathish    
                locCompanyList = [SELECT id, PMP_Partner_Benefit_Type__c,PMP_Benefit_Update_Ind__c,PMP_Partner_Inactive_Ind__c
                                                       from PMP_Company__c where PMP_Is_Published_Ind__c =true and PMP_Account_Id__c =: oUser.AccountId ]; */
                List<PMP_OPID_MPI_Rel__c> junctionObjects= PMP_Utility.getJunctionAccountToMpiByAccountId(new Set<Id>{oUser.AccountId});
                List<Id> listMpiIds = PMP_Utility.getListMpiIds(junctionObjects);
                locCompanyList = [SELECT id, PMP_Partner_Benefit_Type__c,PMP_Benefit_Update_Ind__c,PMP_Partner_Inactive_Ind__c
                from PMP_Company__c where PMP_Is_Published_Ind__c =true and id in: listMpiIds];    

                }
                catch(System.QueryException qe) {
                    System.debug(qe.getMessage());
            }
                //system.debug('company = ' + locCompanyList[0]);
                if(locCompanyList!=null && !locCompanyList.isEmpty()){
                    if(locCompanyList[0].PMP_Benefit_Update_Ind__c!=true && locCompanyList[0].PMP_Partner_Inactive_Ind__c != true){
                        
                            benefitName = locCompanyList[0].PMP_Partner_Benefit_Type__c;
                        
                    }
                    
                }
            }
            
        }
        return benefitName;
    }
    
    /*
* @Description:Returns the Company associated with a user (or null if no company is associated with them).
* @Author:Gireesh:US707407, MGDANIES
* */ 
    @AuraEnabled
    public static PMP_Company__c getCompany(){
        
        List<User> oUserList = new List<User>();
        oUserList = PMP_Utility.getLoggedInUser();
        if(oUserList != null && !oUserList.isEmpty()){
            User oUser =  oUserList[0];
            if(oUser.Core_IPA_One_Partner_Id__c != null && oUser.IsPortalEnabled){
                List<PMP_Company__c> companyInformation = PMP_Utility.getCompanyInfoForOpid(oUser.Core_IPA_One_Partner_Id__c);
                if(companyInformation.size()>0){
                    PMP_Company__c company = companyInformation[0];
                    return company;
                }                                
            }
        }
        return null;
    }
    
    /*
    * @Description:Returns the Company associated with a user (or null if no company is associated with them).
    * @Author:Gireesh: US707407
    * */        
    @AuraEnabled
    public static String getCompanyId(){        
        
        PMP_Company__c company = getCompany();
        if (company != null) {
            return company.Id;    
        }
        else{
            return null;
        }   
    }  
}