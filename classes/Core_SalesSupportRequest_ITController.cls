/**************************************************************************************
Apex Class Name:  Core_SalesSupportRequest_ITController
Version     : 1.0 
Created Date: 5 JUN 2023
Function    : Controller for Core_SalesSupportRequest_IT
Modification Log :
* Developer           Date               Description
* ----------------------------------------------------------------------------
* Ketki  Dhapke     5 JUN 2023      Original Version
*************************************************************************************/
public with sharing class Core_SalesSupportRequest_ITController {
    @Auraenabled(cacheable=true)
    public static List<String> getUserRegionUITheme() {
        List<String> UserRegionUITheme = new String[2];
        User userObj = [select Id, Core_WWID__c, Core_User_Geo__c, Profile.Name from User where Id = :UserInfo.getUserID()];
        UserRegionUITheme.add(0,UserInfo.getUiThemeDisplayed());
        if(userObj.Core_User_Geo__c != null){        
            UserRegionUITheme.add(1,userObj.Core_User_Geo__c);
        }
        System.debug('##Reg'+UserRegionUITheme);
        return UserRegionUITheme;        
    }
}