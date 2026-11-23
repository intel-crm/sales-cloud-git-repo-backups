public without sharing class Pricing_CreateInternalTestUser {
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
    
    public static void createSDMuser(String firstName, String email, String wwid, String accId){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser]; //For SDM
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
                        objUser.FirstName='SDM_' + firstName;
                        objUser.LastName = 'Tender';
                        objUser.Alias = uniqueName.substring(18, 23);
                        objUser.Email = email;
                        objUser.Username = 'SDM_' + firstName +'_tender@intel.com.crm.crmqa3';
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
        Id usrId;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){            
            usrId = userId.Id;
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = cpqPS.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
        }   
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        
        List<GroupMember> GMlist = new List<GroupMember>();
        for(user userId : lstUser) {
            GMlist.add(new GroupMember(GroupId = '00G2D0000029QhlUAE',UserOrGroupId = userId.Id)); //AGS_All Internal Tender Users
        }
        
        
        if(!GMList.isEmpty()) {
            insert GMList;
        }
        system.debug('usrid'+ usrId);
        addInToAccountTeamMember(usrId,accId);        
    }
    
    @future
    public static void addInToAccountTeamMember(Id usrId,String accId){
        List<AccountTeamMember> lstAccountTeamMember = new List<AccountTeamMember>();
        List<AccountShare> lstAccountShare = new List<AccountShare>();
        lstAccountShare.add(new AccountShare (AccountId = accId,
                                                         AccountAccessLevel ='Read',
                                                         OpportunityAccessLevel ='None',
                                                         CaseAccessLevel='None',
                                                         UserOrGroupId = usrId));
            
            lstAccountTeamMember.add(new AccountTeamMember(AccountId = accId,
                                                                            TeamMemberRole = 'Team Member (100%)',
                                                                            AccountAccessLevel ='Read',
                                                                            OpportunityAccessLevel ='None',
                                                                            CaseAccessLevel='None',
                                                                            UserId = usrId));
        
        if(!lstAccountTeamMember.isEmpty()) {
            insert lstAccountTeamMember;
        }
        
        if(!lstAccountShare.isEmpty()) {
            insert lstAccountShare;
        }
    }
}