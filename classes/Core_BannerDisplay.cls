public class Core_BannerDisplay {

     public static string message{get;set;}
    @auraEnabled
    public static String getBannerText(){
        Core_Banner_Setting__c bannerSetting = Core_Banner_Setting__c.getInstance();
        system.debug(bannerSetting.IsBannerVisible__c);
        if(bannerSetting.IsBannerVisible__c == true){
            return Label.Core_Banner;
        }else return null;
    }
    
     
   public static void getBannerTextMsg() {
    
    // Retrieve the banner settings
    Core_Banner_Setting__c bannerSetting = Core_Banner_Setting__c.getInstance();
    System.debug(bannerSetting.IsBannerVisible__c);
    
    // Check if the banner is visible
    if (bannerSetting.IsBannerVisible__c == true) {
        // Query for the custom banner text
        List<Core_Banner_Text__c> bannerTextList = [
            SELECT Core_Text_Message__c 
            FROM Core_Banner_Text__c 
            WHERE core_CRM_type__c = 'Home Page' 
            LIMIT 1
        ];
        
        // If a message was found, assign it to the variable
        if (!bannerTextList.isEmpty()) {
            message = bannerTextList[0].Core_Text_Message__c;
            System.debug('Banner Message: ' + message);
        }
        
        // If no message was found, fall back to the default message
        if (message == null) {
            List<Core_Banner_Text__c> defaultBannerTextList = [
                SELECT Core_Text_Message__c 
                FROM Core_Banner_Text__c 
                WHERE core_CRM_type__c = 'Home Page Default' 
                LIMIT 1
            ];
            
            // Assign the default message if found
            if (!defaultBannerTextList.isEmpty()) {
                message = defaultBannerTextList[0].Core_Text_Message__c;
                System.debug('Default Banner Message: ' + message);
            }
        }
    }
    
    system.debug('line 59'+message);
}
}