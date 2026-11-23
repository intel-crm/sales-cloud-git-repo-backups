/*********************************************************************************************************************
Class Name    : Sales_RemoveLicUserOnLicenseRecordCtrl
Version       : 1.0
Created Date  : Aug 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma          2-Aug-2021             US1072058:Remove licensed user
* *********************************************************************************************************************/

@isTest
public with sharing class Sales_RemoveLicUserOnLicenseRecordCtrl {
/*
    @AuraEnabled
    public static Boolean removeLicUserFromUser(String recordId){
        Boolean isLicUserBlank=false; 
        Sales_License__c updateLicRecord =[Select Id,Sales_License_Lic_User_Contact_ID__c,Sales_Lic_User_Contact_Txt__c from Sales_License__c where Id=:recordId limit 1][0];
        
        if(updateLicRecord.Sales_License_Lic_User_Contact_ID__c!=null){
            updateLicRecord.Sales_License_Lic_User_Contact_ID__c=null;
            updateLicRecord.Sales_Lic_User_Contact_Txt__c='';
            update updateLicRecord; //updating license record with no lic User reference}
            isLicUserBlank=true;    // true if license user updated
        }
        
        return isLicUserBlank;
    }
     @AuraEnabled
    public static String removeHostfromLicenseRecord(String recordId){
   
        String isReturnMsg='';
        Sales_License__c updateLicRecord =[Select Id,Sales_License_Host_Node_Id__c,Sales_License_Avbl_Rehost_Nbr__c from Sales_License__c where Id=:recordId limit 1][0];
        if(updateLicRecord.Sales_License_Host_Node_Id__c==null){
             isReturnMsg='Failure';
        }
        else if(updateLicRecord.Sales_License_Host_Node_Id__c!=null){
            //updateLicRecord.Sales_License_Avbl_Rehost_Nbr__c=updateLicRecord.Sales_License_Avbl_Rehost_Nbr__c-1;
            updateLicRecord.Sales_License_Host_Node_Id__c=null;
            update updateLicRecord; 
            isReturnMsg='Success';// true if Host is updated
        }
       /* else if(updateLicRecord.Sales_License_Avbl_Rehost_Nbr__c==0){
             isReturnMsg = System.Label.Sales_avlbeRehostZeroErrMsg;
        }
        else if(updateLicRecord.Sales_License_Avbl_Rehost_Nbr__c==null){
              isReturnMsg = System.Label.Sales_avlbeRehostNullErrMsg;
        }
        */
/*        
        return isReturnMsg;
    }
*/    
}