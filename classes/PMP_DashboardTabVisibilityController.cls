/****************************************************************************************************************************************
* Class Name  : PMP_DashboardTabVisibilityController 
* Version     : 1.0 
* Created Date: 10-Mar-2020
* Modification Log :
* Created By : Tanzanite Team Infosys
* Developer       Date                     Description
* ----------------------------------------------------------------------------
* Manjula          3/10/2020               Created to check the visibility of dashboard tabs
*****************************************************************************************************************************************/
public with sharing class PMP_DashboardTabVisibilityController {
    //Method to fetch the Intel Admin permission set to show up the Partner tab in dashboard - Added by Manjula[US602030]    
    @AuraEnabled(cacheable=true)
    public static Boolean isMPAdmin(){
        
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        Boolean result = false;
        /*Commented below query since it is not as part of WW22*/
        /*  permissionSetList = [SELECT Id,Assignee.Profile.Name  FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()
                             AND ((PermissionSet.Name =:PMP_StaticConstants_Partner.INTEL_ADMIN OR PermissionSet.Name =:PMP_StaticConstants_Partner.INTEL_EMPLOYEE) OR (Assignee.Profile.Name IN ('System Administrator','IT Admin')))];*/   
        permissionSetList = [SELECT Id,Assignee.Profile.Name  FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()
                             AND ((PermissionSet.Name =:PMP_StaticConstants_Partner.INTEL_ADMIN OR PermissionSet.Name =:PMP_StaticConstants_Partner.INTEL_EMPLOYEE) OR (Assignee.Profile.Name IN ('System Administrator','IT Admin')))];
        System.debug('the name'+PermissionSet.Name);
        if(permissionSetList.size()>0){
            
            result =true;
        }
        System.debug('the result'+result);
        return result;
    }
    // Method to fetch benefit to show/hide Offerings and OfferingKeyMetrics tabs in dashboard Added By Manjula[US528775]   
    @AuraEnabled(cacheable=true)
    public static Boolean isBasicProfileBenefit(){
        Boolean result = false;
        List<PRM_AccountBenefitAssociation__c> accountBenefit = new List<PRM_AccountBenefitAssociation__c>();
        Id accountId=[SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId()].AccountId;
        try
        {
            //if(accountId!='')  //Added by sooriya for DE71852
            //{
                accountBenefit =[SELECT PRM_Account_Id__c, PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c FROM PRM_AccountBenefitAssociation__c 
                                 where PRM_Account_Id__c=:accountId AND (PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c =:PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE AND PRM_Status_Nm__c = 'Active')]; 
                System.debug('accountBenefit'+accountBenefit);
                if(accountBenefit.size()>0)
                {
                    result =true;
                }
           
           // }
            
        }
        catch(Exception e){ throw new AuraHandledException(e.getMessage());}
        
        return result;
    }
    @AuraEnabled
    public static Boolean isEmployee(){
        
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        
        List<PRM_AccountBenefitAssociation__c> accountBenefit = new List<PRM_AccountBenefitAssociation__c>();
        Set<String> permissioneSets = new Set<String>();
        Id userAccountId = [SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId()].AccountId;
        Boolean result = false;
        try{
            
            List<PMP_Dashboard_Tab__mdt> dashTab=[Select Id,PMP_Is_Active_Ind__c,PMP_Permission_Set_Name_Txt__c from PMP_Dashboard_Tab__mdt where PMP_Is_Active_Ind__c=True];
            permissionSetList = [SELECT Id,PermissionSet.Name  FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()
                                 AND (PermissionSet.Name =:PMP_StaticConstants_Partner.EMPLOYEE )];
            System.debug('permissionSetList'+permissionSetList);
            System.debug('dashTab'+dashTab);
            if(permissionSetList.size()>0){
                for(PermissionSetAssignment perms : permissionSetList ){
                    
                    
                    permissioneSets.add(perms.PermissionSet.Name);
                }
                
                   if(dashTab.size()>0){
              for(PMP_Dashboard_Tab__mdt dashtb : dashTab){
                    
                    if(permissioneSets.contains(dashtb.PMP_Permission_Set_Name_Txt__c)){
                        
                    
                            result= true;
                        
                        
                        
                    }
                }
            }
                
            }
           
       
        }
        catch(Exception e){throw new AuraHandledException(e.getMessage());}
        
        return result;
    }
    @AuraEnabled
    public static Boolean isLeadTabforAdminsAndLDR(){
        Boolean result = false;
        
     
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        Id userAccountId = [SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId()].AccountId;
        try
        {
                               
        permissionSetList = [SELECT Id,Assignee.Profile.Name  FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()
                             AND ((PermissionSet.Name =:PMP_StaticConstants_Partner.INTEL_ADMIN OR PermissionSet.Name =:PMP_StaticConstants_Partner.INTEL_EMPLOYEE OR PermissionSet.Name =:PMP_StaticConstants_Partner.LDR  OR PermissionSet.Name =:PMP_StaticConstants_Partner.PARTNER_ADMIN) OR (Assignee.Profile.Name IN ('System Administrator','IT Admin')))];
           
                    if(permissionSetList.size()>0){
                        result =true;
                    } 
                    
                }
                


        catch(Exception e)
        { throw new AuraHandledException(e.getMessage());}
        return result;   
    }
    
}