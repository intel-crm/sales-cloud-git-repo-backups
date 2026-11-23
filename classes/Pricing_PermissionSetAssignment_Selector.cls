/**
 * @description       : Making the class name with the object type and extends it with fflib_SObjectSelector
 * @author            : Rakshitha BR
 * @group             : Gravity
 * @last modified on  : 03-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public inherited sharing class Pricing_PermissionSetAssignment_Selector extends fflib_SObjectSelector {
    public Pricing_PermissionSetAssignment_Selector() {
          super(false,true,true,false);
    }
    
    /**
    * @description Creating the new instance method
    * @author Rakshitha BR | 03-28-2022 
    * @return Pricing_PermissionSetAssignment_Selector 
    **/
    public static Pricing_PermissionSetAssignment_Selector newInstance(){
        
        
        return (Pricing_PermissionSetAssignment_Selector) Pricing_IQR_Application.Selector.newInstance(PermissionSetAssignment.SObjectType);
    }
    
    /**
    * @description getSObjectFieldList to get the list of feilds
    * @author Rakshitha BR | 03-28-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    /**
    * @description getSObjectType to know the type of object
    * @author Rakshitha BR | 03-28-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return PermissionSetAssignment.sObjectType;
    }   
    
    /**
    * @description Add the Method type and its parameter
    * @author Rakshitha BR | 03-28-2022 
    * @param userId 
    * @param permissionSet 
    * @return Boolean 
    **/
    public Boolean selectByName(Id userId,Set<String> permissionSet){
        System.debug('Inside selector');
        Integer count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId = : userId AND PermissionSet.Name IN: permissionSet
                        ];
        return count > 0;
    }
    public list<PermissionSetAssignment> selectbyUserId(Id userId){
        return [SELECT Id, PermissionSet.Name, AssigneeId, Assignee.ContactId FROM PermissionSetAssignment WHERE AssigneeId =: userId];                                                                                           
    }
    public Integer getCountbyName(Id userId,Set<String> permissionSet){
        return [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = : userId AND PermissionSet.Name IN: permissionSet];                                                                                           
    }
    
    public list<PermissionSetAssignment> selectByPSName(Id userId,Set<String> permissionSet){
        System.debug('Inside selector');
        return [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = : userId  AND PermissionSet.Name IN: permissionSet];
    }
}