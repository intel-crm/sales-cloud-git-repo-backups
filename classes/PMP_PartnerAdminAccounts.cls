public with sharing class PMP_PartnerAdminAccounts {
    
    @AuraEnabled(cacheable = true)
    public static List <Contact> getPartnerAdminAccounts() {
                
        Core_Account_Group_Member__c pagMember = new Core_Account_Group_Member__c();
           PMP_OPID_MPI_Rel__c pagMemberMPI = new PMP_OPID_MPI_Rel__c();
           List<PMP_OPID_MPI_Rel__c> pagMemberOPIDList = new List<PMP_OPID_MPI_Rel__c>();
           List<Core_Account_Group_Member__c> pagMemberList = new List<Core_Account_Group_Member__c>();
           List<String> pagMemberOPIDListids = new List<String>();
           List<String> intelAccountIds = new List<String>();
           List<String> partnerUserIds = new List<String>();
           List<String> partnerAdminUserIds = new List<String>();
           //List<String> PartnerAdminUser = new List<String>();
           User user = [SELECT AccountId FROM User WHERE id =:Userinfo.getUserId()];
           try{
               pagMember = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c =: user.AccountId and Core_Inactive_Ind__c = false LIMIT 1 ];
               pagMemberMPI = [SELECT id, PMP_One_Partner_ID__c, PMP_Marketing_Profile_Id__c from PMP_OPID_MPI_Rel__c Where Is_Active__c = true AND PMP_One_Partner_ID__c =:pagMember.Core_Partner_Account_Id__c];
               pagMemberOPIDList = [SELECT id, PMP_One_Partner_ID__c from PMP_OPID_MPI_Rel__c Where Is_Active__c = true AND PMP_Marketing_Profile_Id__c =:pagMemberMPI.PMP_Marketing_Profile_Id__c];
           if(pagMemberOPIDList != null && !pagMemberOPIDList.isEmpty()){
               for(PMP_OPID_MPI_Rel__c singlerecord :pagMemberOPIDList){
               //system.debug('OPIDList:::'+singlerecord.PMP_One_Partner_ID__c);    
               pagMemberOPIDListids.add(singlerecord.PMP_One_Partner_ID__c);
               }
           }
               pagMemberList = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c in:pagMemberOPIDListids and Core_Inactive_Ind__c = false];
               // system.debug('pagMemberList:::'+pagMemberList);
           }catch(Exception e){
               //System.debug('No PAG Records found : ' + e.getMessage());
           }
           
           
           for(Core_Account_Group_Member__c mem : pagMemberList){
               intelAccountIds.add(mem.Core_Intel_Account_Id__c);
           }
           
           List<Contact> partnerUserList = [Select id, Name from Contact where Account.id in: intelAccountIds ];
           
           for(Contact u : partnerUserList){
               // system.debug('partnerUserList:::'+ u.id);
               partnerUserIds.add(u.id);
           }
           
           List<Core_Contact_Entitlement__c> partnerAdminAssignmentList = [ Select id,Core_Contact_Id__r.Id from Core_Contact_Entitlement__c where Core_Contact_Id__r.id in:partnerUserIds AND Core_Entitlement_Id__r.Name = 'Partner Admin'];
         
           
           for(Core_Contact_Entitlement__c pa : partnerAdminAssignmentList){
               // system.debug('partnerAdminAssignmentList:::'+pa.Core_Contact_Id__r.Id);
               partnerAdminUserIds.add(pa.Core_Contact_Id__r.Id);
           }
               
           List<Contact> partnerAdminUserList = [SELECT id,Name,Email,Phone from Contact where id in:partnerAdminUserIds];
           // system.debug('partnerAdminUserList before calling:::'+partnerAdminUserList);
           return partnerAdminUserList;
       }
}