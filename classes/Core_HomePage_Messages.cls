public class Core_HomePage_Messages {
    public static string message{get;set;}
    public static string kpiheadermsg{get;set;}
    public static string kpibodymsg{get;set;}
    
    public static void getBannerTextMsg() {
        // Retrieve the banner settings
        Core_Banner_Setting__c bannerSetting = Core_Banner_Setting__c.getInstance();
        System.debug(bannerSetting.IsBannerVisible__c);
        
        // Check if the banner is visible
        if (bannerSetting.IsBannerVisible__c == true) {
            Date today = Date.today();
            // Query for the custom banner text
            List<Core_Banner_Text__c> bannerTextList = [SELECT Core_Text_Message__c FROM Core_Banner_Text__c WHERE core_CRM_type__c = 'Home Page' AND core_isActive__c=true AND Core_Start_Date__c <= :today AND Core_End_Date__c >= :today LIMIT 1];
            
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
    }
      
   public static void getkpiTextMsg() {
        Date today = Date.today();
        List<Core_Banner_Text__c> bannerMessages = [
            SELECT Core_Text_Message__c, core_CRM_type__c FROM Core_Banner_Text__c 
            WHERE core_CRM_type__c IN ('KPI header', 'KPI body') AND core_isActive__c=true
            AND Core_Start_Date__c <= :today AND Core_End_Date__c >= :today
        ];
        
        Map<String, String> kpiDefaults = new Map<String, String>();
        List<Core_Banner_Text__c> defaultBannerMessages = [
            SELECT Core_Text_Message__c, core_CRM_type__c FROM Core_Banner_Text__c 
            WHERE core_CRM_type__c IN ('KPI header default', 'KPI body default')
        ];
        
        for (Core_Banner_Text__c defaultBanner : defaultBannerMessages) {
            kpiDefaults.put(defaultBanner.core_CRM_type__c, defaultBanner.Core_Text_Message__c);
        }
        
        for (Core_Banner_Text__c banner : bannerMessages) {
            if (banner.core_CRM_type__c == 'KPI header') {
                kpiheadermsg = banner.Core_Text_Message__c;
            } else if (banner.core_CRM_type__c == 'KPI body') {
                kpibodymsg = banner.Core_Text_Message__c;
            }
        }
        system.debug('line65'+kpiheadermsg);
        if (kpiheadermsg == null) {
            system.debug('line67');
            kpiheadermsg = kpiDefaults.get('KPI Header Default');
        }
        if (kpibodymsg == null) {
            kpibodymsg = kpiDefaults.get('KPI Body Default');
        }
       system.debug('line 73'+kpiheadermsg);
    }
    
  /*  @AuraEnabled(cacheable=true)
    public static string getBannerTextMsgLWC() {
        string bannerMessage = '';
        // Retrieve the banner settings
        Core_Banner_Setting__c bannerSetting = Core_Banner_Setting__c.getInstance();
        System.debug(bannerSetting.IsBannerVisible__c);
        
        // Check if the banner is visible
        if (bannerSetting.IsBannerVisible__c == true) {
            // Query for the custom banner text
            List<Core_Banner_Text__c> bannerTextList = [SELECT Core_Text_Message__c FROM Core_Banner_Text__c WHERE core_CRM_type__c = 'Home Page' LIMIT 1];
            
            // If a message was found, assign it to the variable
            if (!bannerTextList.isEmpty()) {
                bannerMessage = bannerTextList[0].Core_Text_Message__c;
                System.debug('Banner Message: ' + bannerMessage);
            }
            
        }
        return bannerMessage;
    }
    
    @AuraEnabled(cacheable=true)
    public static map<string,string> getkpiTextMsgLWC(){
        
        map<string,string> kpiMsgMap = new map<string,string>();
        // Query for both KPI header and body in a single query
        List<Core_Banner_Text__c> bannerMessages = [SELECT Core_Text_Message__c, core_CRM_type__c FROM Core_Banner_Text__c WHERE core_CRM_type__c IN ('KPI header', 'KPI body') ];
        
        // Loop through the results and assign messages based on the type
        for (Core_Banner_Text__c banner : bannerMessages) {
            if (banner.core_CRM_type__c == 'KPI header') {
                kpiheadermsg = banner.Core_Text_Message__c;
                kpiMsgMap.put('Head',kpiheadermsg);
            } else if (banner.core_CRM_type__c == 'KPI body') {
                kpibodymsg = banner.Core_Text_Message__c;
                kpiMsgMap.put('Body',kpibodymsg);
            }
        }
        return kpiMsgMap;
        
    }*/
}