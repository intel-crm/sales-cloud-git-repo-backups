/*********************************************************************************************************************
Class Name    : Sales_Bot_PreChatCmpCnt
Version       : 1.0
Created Date  : Sept 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           Sept-2021              Used in prechat form chatbot
* *********************************************************************************************************************/
public without sharing class Sales_Bot_PreChatCmpCnt {
    @auraenabled
    public static String getCurrentUser(){
        Map<String,Object> output = new Map<String,Object>();
        User u = [Select Id, Username, FirstName, LastName, Email, contactId From User Where Id = :UserInfo.getUserId()];
            output.put('userId', u.Id);
            output.put('firstName', u.FirstName);
            output.put('lastName', u.LastName);
            output.put('email', u.Email);
        return JSON.serialize(output);
    }
}