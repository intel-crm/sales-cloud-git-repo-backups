public class Pricing_IQR_Email_Preferences_Selector extends fflib_SObjectSelector {
    public static Pricing_IQR_Email_Preferences_Selector newInstance() {
        return (Pricing_IQR_Email_Preferences_Selector) Pricing_IQR_Application.selector.newInstance(Pricing_IQR_Email_Preferences__c.SObjectType);
    }
    public Schema.SObjectType getSObjectType(){
        return User.sObjectType;
    }
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    public List<Pricing_IQR_Email_Preferences__c> selectbyId(){
        return [SELECT Pricing_Notification_Name_Nm__c,Pricing_Template_API_Name_Nm__c, Pricing_Opt_In_Ind__c FROM Pricing_IQR_Email_Preferences__c WHERE Pricing_User__c = :UserInfo.getUserId() ORDER BY Pricing_Notification_Name_Nm__c];
        
    }
    public List<Pricing_IQR_Email_Preferences__c> selectbyIds(){
        return [SELECT OwnerId, Pricing_Notification_Name_Nm__c, Pricing_Opt_In_Ind__c FROM Pricing_IQR_Email_Preferences__c WHERE OwnerId = :UserInfo.getUserId()];
    }
    

}