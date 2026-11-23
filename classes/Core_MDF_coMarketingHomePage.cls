public class Core_MDF_coMarketingHomePage {
 @AuraEnabled 
    public static user fetchUser(){
       User u = [select id,FirstName, Name from User where id =: userInfo.getUserId()];
        return u;
    }
}