public class Core_BannerDisplay {

     public static string message{get;set;}
    @auraEnabled
    public static String getBannerText(){
        Core_Banner_Setting__c bannerSetting = Core_Banner_Setting__c.getInstance();
        
        if(bannerSetting.IsBannerVisible__c == true){
            return Label.Core_Banner;
        }else return null;
    }
    
     
    public static void getBannerTextMsg(){
        Core_Banner_Setting__c bannerSetting = Core_Banner_Setting__c.getInstance();
        
        if(bannerSetting.IsBannerVisible__c == true){
            message=Label.Core_Banner;
        }
    }
}