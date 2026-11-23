/******************************************************************************************************************************************
Class Name  : Core_UpdateDoNotContactField
Version     : 1.0
Created Date: 07 APR 2021
Function    : Update Sales Do Not Contact Date and Marketing Do Not Contact Date fields

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Dave Hood                 04/07/2021              Original version
*****************************************************************************************************************************************/

public without sharing class Core_UpdateDoNotContactField {

    public static void updateDoNotContactFields(List<Contact> newList/*, Map<Id, Contact> oldList*/) {
            for(Contact newContact: newList){
                if(newContact.Core_Sales_Do_Not_Contact_Ind__c){ //SalesDoNotContact
                   newContact.Core_Do_Not_Contact_Dtm__c=DateTime.now(); //SalesDoNotContactDate
                }
                else{
                    newContact.Core_Do_Not_Contact_Dtm__c=Null;//SalesDoNotContactDate
                }
                
                
                if(newContact.Core_Do_Not_Contact__c){ //MarketingDoNotContact
                   newContact.Core_Marketing_Do_Not_Contact_Dtm__c=DateTime.now(); //MarketingDoNotContactDate
                }
                else{
                    newContact.Core_Marketing_Do_Not_Contact_Dtm__c=Null;//MarketingDoNotContactDate
                }      
            }
    }    
}