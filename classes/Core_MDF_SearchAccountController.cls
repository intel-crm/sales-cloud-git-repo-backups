/****************************************************************************************************************************************
* Class Name  : Core_MDF_SearchAccountController (renamed Core_SearchAccountController)
* Version     : 1.0 
* Created Date: 5/26/2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Pratiksha M        5/26/2019                   Created to fetch Account picklist values and save contact
*****************************************************************************************************************************************/
public without sharing class Core_MDF_SearchAccountController {

    @AuraEnabled
    public static List<PickListValueWrapper> fetchPicklistValues(List<String> salutationPickListNames) {
        List<PickListValueWrapper> pickListNameToValueSet = new List<PickListValueWrapper>();
        Map<String, String> pickistNameValue = new Map<String, String>(); 
        for(String pickListName : salutationPickListNames){
            pickistNameValue.put(pickListName, pickListName); 
        }
        
        
        //for(String pickistValue : pickistNameValue){  
        //for(String pickListName : salutationPickListNames){
        Map<String, Schema.SObjectField> FieldMap = Schema.SObjectType.Contact.fields.getMap();
        for (Schema.SObjectField field : FieldMap.values()) {
            Schema.DescribeFieldResult DescField = field.getDescribe();             
            if(DescField.getType() != null && DescField.getType() ==  Schema.DisplayType.PICKLIST
               && pickistNameValue.containsKey(DescField.getName())){
                   
                   List<Schema.PicklistEntry> pickListEntries = DescField.getPicklistValues();
                   PickListValueWrapper pickListWrapper = new PickListValueWrapper();
                   List<PickListEntry> pickListValueList = new List<PickListEntry>();
                   
                   for(Schema.PicklistEntry schPickListEntry : pickListEntries){
                       PickListEntry pEntry = new PickListEntry();
                       pEntry.label = schPickListEntry.getLabel();
                       pEntry.value = schPickListEntry.getValue();
                       pickListValueList.add(pEntry);
                   }
                   
                   pickListWrapper.picklistName = DescField.getName();
                   pickListWrapper.valueList = pickListValueList;
                   pickListNameToValueSet.add(pickListWrapper);
               }
        }
        //}
        return pickListNameToValueSet;
    }
    
    
    public class PickListValueWrapper {
        @AuraEnabled
        public String picklistName;
        @AuraEnabled
        public List<PickListEntry> valueList;
    }
    
    class PickListEntry {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
    
    
    @AuraEnabled
    public static List<Account> fetchAccountList(String userId,String AccType) {
        
        
        List<Account> lstOfAccount = new List<Account>();
        String ContactId1;
        string loggdInUserAccountId;
        
        List<User> users = [Select Id, ContactId from User where Id = :userId];
        if(users != null && !users.isEmpty()){
            ContactId1 = users[0].ContactId;
        }
        List<Contact> contList = [Select Id,AccountId from Contact where Id = :ContactId1];
        if(contList != null && !contList.isEmpty()){
            loggdInUserAccountId = contList[0].AccountId;
        }
        
        List<GroupMember> gmList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember where UserOrGroupId = :userId];
        
        Set<Id> loggedInUserGroupIds = new Set<id>();
        for(GroupMember gMember : gmList){
            loggedInUserGroupIds.add(gMember.GroupId);
        }
       
        
         List<String> ccpProgramList = Label.Core_MDF_CCP_Program_Names.split(';');
         Set<String> ccpProgramSet = new Set<String>(ccpProgramList);
        
        List<Core_MDF_Partner_Group_Mapping__c>  pgMappingList = [SELECT Core_MDF_Account__c, Core_MDF_Works_For__c, Core_MDF_Channel_Program_Name_Txt__c 
                                                                  FROM Core_MDF_Partner_Group_Mapping__c  
                                                                  where Core_MDF_Group_Id__c IN :loggedInUserGroupIds and Core_MDF_Inactive_Ind__c = false
                                                                  AND Core_MDF_Channel_Program_Name_Txt__c IN :ccpProgramSet];
        
        Set<Id> accIds = new Set<id>();
        Set<Id> corpAccIds = new Set<id>();
        
        if( !String.isBlank(loggdInUserAccountId)){
            List<Core_MDF_Partner_Group_Mapping__c> usertype = [Select Core_MDF_Account__c,Core_MDF_Works_For__c,
                                                                Core_MDF_Group_Id__c, Core_MDF_Group_Name__c, Core_MDF_Channel_Program_Name_Txt__c from 
                                                                Core_MDF_Partner_Group_Mapping__c
                                                                where Core_MDF_Account__c = :loggdInUserAccountId 
                                                                AND Core_MDF_Group_Id__c in :loggedInUserGroupIds AND Core_MDF_Inactive_Ind__c = false
                                                               	AND Core_MDF_Channel_Program_Name_Txt__c IN :ccpProgramSet];
            

            
            if(!usertype.isEmpty() && usertype != null && usertype[0].Core_MDF_Works_For__c == null) // User is a corporate Admin 
            {
                if(AccType == 'Corporate'){
                    for(Core_MDF_Partner_Group_Mapping__c pgMappingMember : pgMappingList){
                        if(pgMappingMember.Core_MDF_Works_For__c == null){
                            corpAccIds.add(pgMappingMember.Core_MDF_Account__c);
                        }
                    }
                    List<Account> corpAcc = [Select Id,Name,Core_MDF_CoMarketingActive__c from Account where Id IN :corpAccIds];
                    for(Account corpAccMember : corpAcc)
                    {
                        if(corpAccMember.Core_MDF_CoMarketingActive__c == true)
                        {
                            accIds.add(corpAccMember.Id);
                        }
                    }
                }
                else if(AccType == 'Agency') {
                    for(Core_MDF_Partner_Group_Mapping__c pgMappingMember : pgMappingList){
                        if(pgMappingMember.Core_MDF_Works_For__c != null){
                            accIds.add(pgMappingMember.Core_MDF_Account__c);
                        }
                    }
                }
                
                
            }
            else{// User is an agency user
                if(AccType == 'Corporate'){
                    accIds.add(null);
                }
                else if(AccType == 'Agency') {
                    if(loggdInUserAccountId != null){
                        accIds.add(loggdInUserAccountId);
                    }
                }
            }
        }
        
        lstOfAccount = [select Id, Name from Account WHERE Id in :accIds];  

        return lstOfAccount;
    }
    
    @AuraEnabled
    public static Boolean saveContact(String userId,String title,String salutation,String phone,
                                      String first_name,String last_name,String mobile,
                                      String email,String country,String region,String accId){
                                          //('cont1test1@dell.com','India','',)
                                          
                                          Boolean saveRetvalue = false;

                                          
                                          String emailDomain = '';
                                          if(!String.isBlank(email)){
                                              List<String> emailParts = email.split('@');
                                              if(emailParts.size() > 1)
                                                  emailDomain = emailParts[1];
                                          }
                                          if(!String.isBlank(emailDomain)){
                                              saveRetvalue = checkForValidEmailDomain(emailDomain,userId,accId);
                                          }
                                          
                                          if(saveRetvalue){
                                              Contact contactToBeInserted = new Contact(Title=title,Salutation=salutation,Phone=phone,FirstName=first_name,LastName=last_name,MobilePhone=mobile,Email = email, AccountId = accId, MailingCountry = country);
                                              Database.SaveResult dsr = Database.insert(contactToBeInserted, false); 

                                          }                                                      
                                          return saveRetvalue;                             
                                          //Contact con = new Contact(Title=title,Salutation=salutation,Phone=phone,First Name=first_name,Last Name=last_name,MobilePhone=mobile);
                                      }
    
    private static Boolean checkForValidEmailDomain(String emailDomain, String userId, String accId ){
        Boolean returnValue = false;
        
        List<GroupMember> gmList = [SELECT Id, GroupId, UserOrGroupId FROM 
                                    GroupMember where UserOrGroupId = :userId];
        
        Set<Id> loggedInUserGroupIds = new Set<id>();
        for(GroupMember gMember : gmList){
            loggedInUserGroupIds.add(gMember.GroupId);
        }
        
        string loggdInUserAccountId;
        
        List<User> users = [Select Id, ContactId from User where Id = :userId];
        Id ContactId1;
        if(users != null && !users.isEmpty()){
            ContactId1 = users[0].ContactId;

        }
        List<Contact> contList = [Select Id,AccountId from Contact where Id = :ContactId1];
        if(contList != null && !contList.isEmpty()){
            loggdInUserAccountId = contList[0].AccountId;

        }
        
        List<String> ccpProgramList = Label.Core_MDF_CCP_Program_Names.split(';');
        Set<String> ccpProgramSet = new Set<String>(ccpProgramList);
        
        List<Core_MDF_Partner_Group_Mapping__c>  pgMappingList = [SELECT Id, Core_MDF_Account__c, Core_MDF_Works_For__c,
                                                                  Core_Allowed_Email_Domains_txt__c, Core_MDF_Channel_Program_Name_Txt__c
                                                                  FROM Core_MDF_Partner_Group_Mapping__c  
                                                                  where Core_MDF_Group_Id__c IN :loggedInUserGroupIds
                                                                  and Core_MDF_Inactive_Ind__c = false 
                                                                  and  Core_MDF_Account__c = :accId
                                                                  and Core_MDF_Channel_Program_Name_Txt__c IN :ccpProgramSet];
        

        
         Set<String> validEmailDomainsSet = new Set<String>();
        
        if(pgMappingList != null && pgMappingList.size() > 0) {
            //collect the pgmmappingIds
            Set<Id> mappingIds = new Set<Id>();
            for (Core_MDF_Partner_Group_Mapping__c pgm : pgMappingList) {
						mappingIds.add(pgm.Id);
				}
            if(!mappingIds.isEmpty()){
            List<Core_MDF_Partner_Group_Domain_Mapping__c> pgDominMappingList = [SELECT id, Name from Core_MDF_Partner_Group_Domain_Mapping__c 
                                                                                where Core_MDF_Partner_Group_Mapping_Id__c IN: mappingIds    
                                                                                and Core_MDF_Active_Ind__c = true];                                                      
        
           
            for(Core_MDF_Partner_Group_Domain_Mapping__c pgdm : pgDominMappingList) {
                if(!String.isBlank(pgdm.Name)){
                validEmailDomainsSet.add(pgdm.Name);
                }
            }
            
            returnValue = validEmailDomainsSet.contains(emailDomain);
          
        }
        }

        return returnValue;
    }
}