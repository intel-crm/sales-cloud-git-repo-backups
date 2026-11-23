public class Core_BannerDisplay {
@auraEnabled
    public static String getBannerText(){
        Core_Banner_Setting__c bannerSetting = Core_Banner_Setting__c.getInstance();
        system.debug(bannerSetting.IsBannerVisible__c);
        if(bannerSetting.IsBannerVisible__c == true){
            return Label.Core_Banner;
        }else return null;
    }
}