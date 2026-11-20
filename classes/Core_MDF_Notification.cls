public without sharing class Core_MDF_Notification {
    public static List<String> appSupportedLang = Core_MDF_CCP_ConstantClass.CCP_SUPPORTED_LOCALE.split(','); 
    /*This Method is used to fetch content configuration records based on section code passed*/
    @AuraEnabled
    public static String getContent(String project, String type) { // e.g., type = 'Home_KeyResources_IPA'
        
        Core_Banner_Text__c bannerText = new Core_Banner_Text__c();
        String loggedinUserLang =''; //Get LoggedIn users language
        String finalContent = '';
        try{
            loggedinUserLang = appSupportedLang.contains(UserInfo.getLanguage()) ? UserInfo.getLanguage() : 'en_US' ;
            if(string.isNotBlank(type) && string.isNotBlank(loggedinUserLang)){
                finalContent = getData(project, type,loggedinUserLang);
            }
        }
        catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return finalContent;
    }

    public static String getData (String project, String type, String loggedInUserLang){
        List<Core_Banner_Text__c> bannerText = new List<Core_Banner_Text__c>();
        String labelToBeQueried = '';
        String finalContent = '';
        String projectStr = String.escapeSingleQuotes(project);
        String typeStr = String.escapeSingleQuotes(type);
        String loggedInUserLangStr = String.escapeSingleQuotes(loggedInUserLang);
        Date currentDate = System.today();
        if(String.isNotBlank(projectStr) && String.isNotBlank(typeStr) && String.isNotBlank(loggedInUserLangStr)){
            //Based on loggedin user's language get the value of label & URL from corresponding fields
            labelToBeQueried = loggedInUserLangStr != 'en_US' ? 'Core_Label_'+ loggedInUserLangStr + '_txt__c' : 'Core_Text_Message__c' ;

            string qryStr = 'SELECT Id, core_CRM_type__c, core_isActive__c, Core_Start_Date__c, Core_End_Date__c, ' +
                + (loggedInUserLangStr != 'en_US' ? 'Core_Text_Message__c,' : '') +
                + String.escapeSingleQuotes(labelToBeQueried) + 
                ' FROM Core_Banner_Text__c' +
                ' WHERE core_CRM_type__c =: typeStr' +
                ' AND Core_CRM_Project__c =: projectStr' +
                ' AND core_isActive__c = True' +
                ' AND Core_Start_Date__c <=: currentDate' +
                ' AND Core_End_Date__c >=: currentDate LIMIT 1';
            
            bannerText = Database.query(qryStr);
            if(!bannerText.isEmpty()){
                //Get the localized value and return.
                //If the localized value is blank return the value available in English
                finalContent = bannerText[0].get(labelToBeQueried) != null ? String.valueOf(bannerText[0].get(labelToBeQueried)) : bannerText[0].get('Core_Text_Message__c') != null ? String.valueOf(bannerText[0].get('Core_Text_Message__c')) : '';
            }
            
        }
        return finalContent;
    }

}