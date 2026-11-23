public without sharing class Pricing_CreateInternalTestUser {
    @AuraEnabled
    public static void createPricingManageruser(String firstName, String email, String wwid){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager]; //For RPM
        PermissionSet cpqPS = [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User Limit 1]; //CPQ PS
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT Id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
                    userProfileIdSet.add(proId.Id);
                }  
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        list<User> lstUser = new list<User>();
        for(Id profileId : userProfileIdSet){
                        //Add User Information
                        User objUser = new User();
                        objUser.FirstName='RPM_' + firstName;
                        objUser.LastName = 'Tender';
                        objUser.Alias = uniqueName.substring(18, 23);
                        objUser.Email = email;
                        objUser.Username = 'RPM_' + firstName +'_tender@intel.com.crm.crmqa3';
                        objUser.ProfileId = profileId;
                        objUser.Core_WWID__c = wwid;
                        objUser.Core_Employee_Type_Code__c = 'EMP'; 
                        objUser.Core_Employee_Status_Code__c = 'A';
                        objUser.TimeZoneSidKey = 'America/Los_Angeles';
                        objUser.LanguageLocaleKey = 'en_US';
                        objUser.EmailEncodingKey = 'UTF-8';
                        objUser.LocaleSidKey = 'en_US';
                        lstUser.add(objUser);
        }
        insert lstUser;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = cpqPS.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
        }   
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        
        List<GroupMember> GMlist = new List<GroupMember>();
        for(user userId : lstUser) {
            GMlist.add(new GroupMember(GroupId = '00G2i00000168nbEAA',UserOrGroupId = userId.Id)); //AGS_All Internal Tender Users
            GMlist.add(new GroupMember(GroupId = '00G2i00000168ndEAA',UserOrGroupId = userId.Id)); //AGS_Pricing Manager Group
        }
        if(!GMList.isEmpty()) {
            insert GMList;
        }
    }
    
    @AuraEnabled
    public static void createSDMuser(String firstName, String email, String wwid, String userType){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser]; //For SDM
        PermissionSet aeps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive]; //For AE
        PermissionSet raps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderRebateAnalyst]; //For RA
        PermissionSet cpqPS = [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User Limit 1]; //CPQ PS
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT Id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
                    userProfileIdSet.add(proId.Id);
                }
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        String frstNameAlias = userType == 'SDM' ? 'SDM_' : userType == 'AE' ? 'AE_' : 'RA_';
            
        list<User> lstUser = new list<User>();
        for(Id profileId : userProfileIdSet){
                        //Add User Information
                        User objUser = new User();
                        objUser.FirstName=frstNameAlias + firstName;
                        objUser.LastName = 'Tender';
                        objUser.Alias = uniqueName.substring(18, 23);
                        objUser.Email = email;
                        objUser.Username = frstNameAlias + firstName +'_tender@intel.com.crm.crmqa3';
                        objUser.ProfileId = profileId;
                        objUser.Core_WWID__c = wwid;
                        objUser.Core_Employee_Type_Code__c = 'EMP'; 
                        objUser.Core_Employee_Status_Code__c = 'A';
                        objUser.TimeZoneSidKey = 'America/Los_Angeles';
                        objUser.LanguageLocaleKey = 'en_US';
                        objUser.EmailEncodingKey = 'UTF-8';
                        objUser.LocaleSidKey = 'en_US';
                        lstUser.add(objUser);
        }
        insert lstUser;
        /*List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = cpqPS.Id));
            if(userType == 'SDM'){
				permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));  
            } else if(userType == 'AE'){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = aeps1.Id));
            } else if(userType == 'RA'){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = raps1.Id));
            }            
        }   
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        
        List<GroupMember> GMlist = new List<GroupMember>();
        for(user userId : lstUser) {
            GMlist.add(new GroupMember(GroupId = '00G2i00000168nbEAA',UserOrGroupId = userId.Id)); //AGS_All Internal Tender Users
            if(userType == 'RA'){
                GMlist.add(new GroupMember(GroupId = '00G2i000003CqhEEAS',UserOrGroupId = userId.Id)); //Pricing_All_Rebate_Analyst_Group
            }
        }
        
        
        if(!GMList.isEmpty()) {
            insert GMList;
        }*/
    }
}