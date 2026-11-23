/****************************************************************************************************
Apex Class Name : Psg_Bot_Prechat
Version         : 1.0 
Created Date    : 02/08/2023
Function        : Prechat controller class
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ranjit                    02/08/2023                Created
*****************************************************************************************************/
public without sharing class Psg_Bot_Prechat {
    @AuraEnabled
    public static String getCurrentUser(){
        Map<String,Object> output = new Map<String,Object>();
        User u = [Select Username, FirstName, LastName, Email, contactId From User Where Id = :UserInfo.getUserId()];
            output.put('userId', u.Id);
            output.put('firstName', u.FirstName);
            output.put('lastName', u.LastName);
            output.put('email', u.Email);
        return JSON.serialize(output);
    }
}