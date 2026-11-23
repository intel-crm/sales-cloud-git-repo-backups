public without sharing class PRM_CompanyProfile_Utility {
    
    //this method is used to fetch profile information on partner benefit experience
    @AuraEnabled(cacheable=true)
    public static UserProfile getProfileInfo(){
        String loggedInUserName = UserInfo.getUserName();
        UserProfile userData = new UserProfile();
        if(loggedInUserName != null){
            User cont= [select id,LanguageLocaleKey,LocaleSidKey,contact.id,contact.title,contact.name,contact.Core_Job_Function__c, account.name,contact.phone,account.id,contact.Email from user where id= :UserInfo.getUserId()]; //: userID//0058A000004C0JPQA0 -bishal intelacc 0058A000004AfSoQAK 0058A000004Cl5HQAS-opid acc 0058A000004tKyK
            //Contact cont = [SELECT id,title, Name,AccountId,Core_IPA_Partner_Role__c,Core_Preferred_Language__c,Core_Job_Function__c,phone, email,
                            //(SELECT Id,PRM_Relationship_Id__r.Name,PRM_Account_Id__r.Id FROM Account_Contact_Relationships__r)
                            //FROM Contact WHERE Core_Login_Id__c= :loggedInUserName];
            //userData.userId = cont.id;
            userData.contactId = cont.id;//c.contact.id; 0038A00000R10qRQAR  //0038A00000R10p0QAB 
            userData.companyProfileId = cont.AccountId;  
            userData.marqueeTitle = System.label.PRM_CP_CompanyProfile_Title;
            companyProfile singleProf = new companyProfile();
            singleProf.label =System.label.IPA_BuilderRightPanel_CTA1Label;   
            //singleProf.externalUrl = 'https://www.intel.com';
            singleProf.externalUrl=URL.getSalesforceBaseUrl().toExternalForm()+Label.IPA_BuilderRightPanel_CTA1URL; 
            singleProf.communityPage= '';
            singleProf.objectPage = '';
            singleProf.recordId = cont.AccountId;
            userData.companyProfileLink = singleProf;
            dashboardProfileLink dasbboard = new dashboardProfileLink();
            dasbboard.label = System.label.IPA_BuilderRightPanel_ButtonLabel;
            dasbboard.externalUrl=URL.getSalesforceBaseUrl().toExternalForm()+Label.PRM_Dashboard_Url;
            System.debug('URL :'+URL.getSalesforceBaseUrl().toExternalForm());
            dasbboard.communityPage= '';
            dasbboard.objectPage = '';
            dasbboard.recordId = '';
            userData.dashboardLink = dasbboard;
            mProfileLink profile = new mProfileLink();
            profile.label =System.label.IPA_BuilderRightPanel_CTA2Label;  
            profile.externalUrl = 'https://www.intel.com';
                   
            profile.communityPage= '';
            profile.objectPage = '';
            profile.recordId = cont.AccountId;
            userData.myProfileLink = profile;            
            /*
            userData.name = cont.name;    
            userData.title = cont.title;
            //userData.responsibility = cont.Core_Job_Function__c;    
            userData.phone = cont.phone;
            userData.email = cont.Email;  
			userData.userLanguage = cont.LanguageLocaleKey;
			*/
            userData.name = String.isEmpty(cont.contact.name) ? '': cont.contact.name;    
            //userData.title = cont.contact.title;
            userData.title = cont.contact.Core_Job_Function__c;
            userData.responsibility = cont.contact.Core_Job_Function__c;    
            userData.phone = cont.contact.phone;
            userData.email = cont.contact.Email;  
			userData.userLanguage = cont.LanguageLocaleKey;
            userData.faIcon = 'fa-intel-user-o';  
            //userData.tier = 'Titanium Tier';  
            //userData.benefitDescription = 'The following snapshot is based on your Titanium Tier status and <a target="_blank" href="555"> Primary Contact</a> role.';  
            
            
        }
        System.debug('userData--->'+userData);
        System.debug('Number of Queries used in this apex code so far:'+Limits.getQueries());
        System.debug('GetCpuTime():'+Limits.getCpuTime());
        System.debug('TimeStamp>>>>getProfileInfo>>>>end'+ DateTime.now().getTime());
        return userData;
    }
    
    //return data for user profile in structure format
    public class UserProfile{
        @AuraEnabled public string userId{get; set;}
        @AuraEnabled public string contactId{get; set;}
        @AuraEnabled public string companyProfileId{get; set;}
        @AuraEnabled public string  marqueeTitle{get; set;}
        @AuraEnabled public companyProfile companyProfileLink {get; set; }   
        @AuraEnabled public dashboardProfileLink dashboardLink {get; set; }
        @AuraEnabled public mProfileLink myProfileLink {get; set; } 
        @AuraEnabled public string name{get; set;}
        @AuraEnabled public string title { get; set; } 
        @AuraEnabled public string responsibility { get; set; } 
        @AuraEnabled public string phone{get; set;}
        @AuraEnabled public string email{get; set;}
        @AuraEnabled public string faIcon{get; set;}
        @AuraEnabled public string tier{get; set;}
        @AuraEnabled public string benefitDescription{get; set;}
        @AuraEnabled public string userLanguage{get; set;}
    }
    public class companyProfile {
        @AuraEnabled public string label{get; set;}
        @AuraEnabled public string externalUrl{get; set;}
        @AuraEnabled public string communityPage{get; set;}
        @AuraEnabled public string objectPage{get; set;}
        @AuraEnabled public string recordId{get; set;}    
    }
    
    public class dashboardProfileLink {
        @AuraEnabled public string label{get; set;}
        @AuraEnabled public string externalUrl{get; set;}
        @AuraEnabled public string communityPage{get; set;}
        @AuraEnabled public string objectPage{get; set;}
        @AuraEnabled public string recordId{get; set;}  
    }
    public class mProfileLink {
        @AuraEnabled public string label{get; set;}
        @AuraEnabled public string externalUrl{get; set;}
        @AuraEnabled public string communityPage{get; set;}
        @AuraEnabled public string objectPage{get; set;}
        @AuraEnabled public string recordId{get; set;}  
    }
}