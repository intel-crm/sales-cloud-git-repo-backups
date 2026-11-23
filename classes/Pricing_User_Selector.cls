/**
 * @description       : Making the class name with the object type and extends it with fflib_SObjectSelector
 * @author            : Rakshitha BR
 * @group             : Gravity
 * @last modified on  : 03-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_User_Selector extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static Pricing_User_Selector newInstance() {
        
        
        return (Pricing_User_Selector) Pricing_IQR_Application.selector.newInstance(User.SObjectType);
    }
    
    /**
    * @description getSObjectType to know the type of object
    * @author Rakshitha BR | 03-28-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType(){
        return User.sObjectType;
    }
    
    /**
    * @description getSObjectFieldList to get the list of feilds
    * @author Rakshitha BR| 03-28-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    /**
    * @description Add the Method type and its parameter
    * @author Rakshitha BR | 03-28-2022 
    * @param userId 
    * @return Boolean 
    **/
    public Boolean selectById(Id userId){
        System.debug('Inside selector');
        Integer count = [select count() from user 
                         where id = :userId
                         AND id in (select userorgroupid from groupmember where group.DeveloperName =:Label.Pricing_Tender_PublicGroup_AllPricingReadOnlyUsersGroup)];
                      
                        
        return count > 0;
    }
    
    public User selectbyId(){
        return [SELECT Id,AccountId FROM User WHERE Id = : UserInfo.getUserId()];
    }
    
    public List<User> selectbyUserId(Id usrId){
        return [SELECT Id,Name,Core_WWID__c,DelegatedApproverId FROM User WHERE Id = : usrId];
    }
    
    public List<User> selectbyContactId(Id conId){
        return [Select Id, ContactId from User where ContactId = :conId];
    }
}