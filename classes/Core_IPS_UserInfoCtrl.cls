/***************************************************************************************************
Apex Class Name:  Core_IPS_UserInfoCtrl 
Version     : 1.0 
Created Date: 13 Nov 2021
Function    : This class is to get the information of currently LoggedIn User
Test Class  : Core_IPS_TestAllRecords_Test 
Modification Log :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------                 
* Farooq Ahmed                 13/11/2021               Created
* Vishal suryavanshi 		   13/12/2021				Modified	 	
* 
****************************************************************************************************/

public with sharing class Core_IPS_UserInfoCtrl {
    
    @AuraEnabled 
    public static user fetchUser(){
        // query current user information  
        User oUser = [select id,Name,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled 
                      FROM User Where id =: userInfo.getUserId()];
        
        return oUser;
    }
    @AuraEnabled 
    public static String formatLabels(){
        String userWelcomeMsg = Label.Core_IPS_UserWelcomeMsg_LWC;
        String userName = UserInfo.getFirstName();
        List<String> parameters = new List<String>();
        parameters.add(userName);
        String formatedLabel = String.format(userWelcomeMsg, parameters);
        
        return formatedLabel;
    }
    @AuraEnabled(cacheable=true)
    public static List<Core_Ips_BannerMessage__c> fetchCustomSetting(){
        List<Core_Ips_BannerMessage__c> casedef=new List<Core_Ips_BannerMessage__c>();
        if (Schema.sObjectType.Core_Ips_BannerMessage__c.isAccessible()){ 
            casedef = [SELECT Id, Name, Core_Ips_BannerMessage_Text_LWC__c,Core_Ips_BannerMessage_Checkbox_LWC__c FROM Core_Ips_BannerMessage__c];
        }
        List<Core_Ips_BannerMessage__c> caseList=new List<Core_Ips_BannerMessage__c>();
        for(Core_Ips_BannerMessage__c bannermsg:casedef){
            if(bannermsg.Core_Ips_BannerMessage_Checkbox_LWC__c==true){
                caseList.add(bannermsg); 
            }
            
        }
        return caseList;
    }
}