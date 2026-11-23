/*********************************************************************************************************************
Class Name    : Pilot_Sales_RemoveLicUserOnLicRecCtrl
Version       : 1.0
Created Date  : Sep 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shalini Kumari            29/09/2021              Pilot Project for testing framework.
* ************************************************************************************************************************************************/
public with sharing class Pilot_Sales_RemoveLicUserOnLicRecCtrl {
 @AuraEnabled
    public static Boolean removeLicUserFromUser(String recordId){
        Boolean isLicUserBlank=false; 
        //Sales_License__c updateLicRecord =[Select Id,Sales_License_Lic_User_Contact_ID__c,Sales_Lic_User_Contact_Txt__c from Sales_License__c where Id=:recordId limit 1][0];
        Sales_License__c updateLicRecord = SEL_Sales_License.newInstance().selectByRecordIdString(recordId)[0];
        
        if(updateLicRecord.Sales_License_Lic_User_Contact_ID__c!=null){
            updateLicRecord.Sales_License_Lic_User_Contact_ID__c=null;
            updateLicRecord.Sales_Lic_User_Contact_Txt__c='';
            update updateLicRecord; //updating license record with no lic User reference}
            isLicUserBlank=true;    // true if license user updated
        }
        
        return isLicUserBlank;
    }
}