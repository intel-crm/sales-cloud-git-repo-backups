@isTest
public class Core_BannerDisplayTest {

    static testMethod void getBannerTextTest(){
        Core_Banner_Setting__c bannerSetting = new Core_Banner_Setting__c();
        bannerSetting.IsBannerVisible__c = false;
        insert bannerSetting;
        Core_BannerDisplay.getBannerText();
        Core_BannerDisplay.getBannerTextMsg();
        bannerSetting.IsBannerVisible__c = true;
        update bannerSetting;
        Core_BannerDisplay.getBannerText();
        Core_BannerDisplay.getBannerTextMsg();
    }
}