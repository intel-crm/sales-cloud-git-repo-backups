/******************************************************
Component Name    : Sales_ValidateUserEditAccess
Created Date      : Aug 2022
Function          : [ TWC3144-496 ] This class will check if Logged In User is having access to edit the record he is trying to access.
Modification Log :
Developer                       Date                    Description
Bharath Indla                 08/05/2022                TWC3144-496
*****************************************************/
@isTest
public with sharing class Sales_ValidateUserEditAccess {
    /*public class Input {
        @InvocableVariable
        public Id userID;
        @InvocableVariable
        public Id recordId;
    }
    public class Output {
        @InvocableVariable
        public boolean AccessCheck;
    }
    @InvocableMethod(label='Check Access on record' description='it will check for user access on record' )
    public static List<Output> validateUserAccessFromFlow(List<Input> input){
        List<Output> outputList = new List<Output>();
        Output output = new Output();
        Boolean checkAccess=validateUserAccess(input[0].userID,input[0].recordId);
        output.AccessCheck=checkAccess;
        outputList.add(output);
        return outputList;
    }
    @AuraEnabled
    public static Boolean  validateUserAccess(Id userID , Id recordId){
        Boolean editAccess = false;
        UserRecordAccess userAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId=:userID AND RecordId=:recordId LIMIT 1];
        if(userAccess != null && userAccess.HasEditAccess){
            editAccess=true;
        }
        return editAccess;
    }
    @AuraEnabled
    public static boolean BypassRehostForCustomOps(){
        List<PermissionSetAssignment> permissionSetRecord=[SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId()];
        List<String> lstPermissionSet=new List<String>();
        for(PermissionSetAssignment pc:permissionSetRecord){
            lstPermissionSet.add(pc.PermissionSet.Name);
        }
        if(lstPermissionSet!=null && lstPermissionSet.contains('PSG_Internal_Customer_Ops')) {
            return true;
        }
        else{
            return false;
        }
    }*/ 
}