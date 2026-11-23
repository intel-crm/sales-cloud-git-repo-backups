/**
 * @description       : Making the class name with the object type and extends it with fflib_SObjectSelector
 * @author            : Rakshitha BR
 * @group             : Gravity
 * @last modified on  : 03-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_ContentDocumentLink_Selector extends fflib_SObjectSelector {
    
    /**
    * @description Creating the new instance method
    * @author Rakshitha BR  | 03-28-2022 
    * @return Pricing_ContentDocumentLink_Selector 
    **/
    public static Pricing_ContentDocumentLink_Selector newInstance() {
        
        
        return (Pricing_ContentDocumentLink_Selector) Pricing_IQR_Application.selector.newInstance(ContentDocumentLink.SObjectType);
    }
    
    /**
    * @description getSObjectType to know the type of object
    * @author Rakshitha BR | 03-28-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType(){
        return ContentDocumentLink.sObjectType;
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
    * @description Add the Method type and its parameter
    * @author Rakshitha BR | 03-28-2022 
    * @param recordTypeId 
    * @return Integer 
    **/
    public Integer selectByRecordType(Id recordTypeId){       
        return Database.countQuery('SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId =:recordTypeId');
    }
}