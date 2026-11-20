/*************************************************************************************************************************************************************************
* Class Name  : PSS_Utility 
* Version     : 1.0 
* Created Date: 4/06/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Swathi              M-01    : Original version       4/06/2021                         Utility class for commonly used methods
**************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
public without sharing class PSS_Utility {
    
    public static Boolean isWorking() {
        return true;
    }
    
   
    /**
    * @description method to the user details PermissionSetAssignmenList , who are assigned with the given permissionset    
    * @param Set<Id> userIds
    * @param List<String> allowedPermissionSet
    * @return List<PermissionSetAssignment> permissionAssignmentList 
    **/
//     public static List<PermissionSetAssignment> getUsersWithAssignedPermissionSet(Set<Id> userIds, List<String> allowedPermissionSet){
//         List<PermissionSetAssignment> permissionAssignmentList = New List<PermissionSetAssignment>();
//         permissionAssignmentList= [SELECT Id,Assignee.Id,PermissionSet.name ,Assignee.Name,Assignee.Contact.Email
//                                    FROM PermissionSetAssignment  where Assignee.Id in:userIds  
//                                    and PermissionSet.name in : allowedPermissionSet];   // dont remove any fields from this query
//         return permissionAssignmentList;
//     }
    
//     /**
// * @description Method to calculate number of values selected in multipicklist field
// * @param String
// * @return number
// **/
//     @AuraEnabled( cacheable=true ) 
//     public static Integer geNumberOfValuesSelected(String fieldValue) {
//         Integer noOfValuesSelected = 0;
//         if(string.isNotBlank(fieldValue)){
//             List<String> values = fieldValue.split(';');
//             noOfValuesSelected = values.size();
//         }
//         return noOfValuesSelected;
//     }
    
//     /**
// * @description Method to calculate number of values selected in multipicklist field with delimeter character
// * @param String
// * @param String delimeter
// * @return number
// **/
//     @AuraEnabled( cacheable=true ) 
//     public static Integer geNumberOfValuesSelected(String fieldValue,String delimeter) {
//         Integer noOfValuesSelected = 0;
//         if(string.isNotBlank(fieldValue)){
//             List<String> values = fieldValue.split(delimeter);
//             noOfValuesSelected = values.size();
//         }
//         return noOfValuesSelected;
//     }
//     @AuraEnabled
//     public static boolean isLoggedInUserIsIntelEmployee(){
//         Boolean isEmployee=false;
//         Set<Id> idSet=new Set<Id>();
//         idSet.add(UserInfo.getUserId());// setting the current logged in user.
//         List<String> permissionSetList=new List<String>();
//         String permissionSet=PMP_Utility.getValue('PSS_PermissionSetAssignment');
//         permissionSetList=permissionSet.split(':');
//         List<PermissionSetAssignment> assignedList=PSS_Utility.getUsersWithAssignedPermissionSet(idSet,permissionSetList);
//         List<String> namesOfAssignedPermissionList= new  List<String>();
//         for(PermissionSetAssignment assignedPermission:assignedList){
//             namesOfAssignedPermissionList.add(assignedPermission.PermissionSet.name);
//         }
//         if(namesOfAssignedPermissionList.size()==1 && namesOfAssignedPermissionList.contains('PMP_Internal_Intel_Read_Only')){
//             isEmployee=true;
//         }
//         else if(namesOfAssignedPermissionList.size()>1 && namesOfAssignedPermissionList.contains('PMP_Internal_Intel_Read_Only')){
//             isEmployee=true;
//         }
//         return isEmployee;
//         //if(permissionSetList.contains)
        
//     }
}