public without sharing class Core_MDF_Community_Announcement {
    
    Public static List<string> LANGUAGES = Core_MDF_CCP_ConstantClass.CCP_SUPPORTED_LOCALE.split(',');
		 @AuraEnabled
    public static List<contentWrapper> getContent(String sectionCode){
        
        List<Core_MDF_Content_Configuration__c> contentConfigsList = new List<Core_MDF_Content_Configuration__c>();
        List<contentWrapper> resultList = new List<contentWrapper>();
        String userLang = UserInfo.getLanguage();
        String labelToBeQueried = '';
        String urlToBeQuried = '';
        String contentConfigQuery='';
        
        try{
            if(string.isNotBlank(sectionCode)){
                string sectionCodeStr = String.escapeSingleQuotes(sectionCode);
                
                if(string.isNotBlank(userLang) && LANGUAGES.contains(userLang)){
                    labelToBeQueried = userLang != 'en_US' ? 'Core_MDF_Label_'+userLang+'_txt__c' : 'Core_MDF_Content_Label_txt__c' ;
                    urlToBeQuried    = userLang != 'en_US' ? 'Core_MDF_'+userLang+'_URL__c' : 'Core_MDF_Content_URL__c' ;
                }
                
                if(string.isNotBlank(labelToBeQueried) && string.isNotBlank(urlToBeQuried)){
                   /* Date firstDayOfMonth = System.today();
                     Datetime startDateTime = datetime.newInstance(firstDayOfMonth.year(), firstDayOfMonth.month(), firstDayOfMonth.day());
            			string todaydate = startDateTime.format('yyyy-MM-dd');*/
                    String todayDate = String.valueOf(system.today()); 
                        contentConfigQuery = 'SELECT Id,Core_MDF_Section_Code_txt__c,Core_MDF_Sort_Order_nbr__c,Core_MDF_Effective_Start_Date__c,Core_MDF_Effective_End_Date__c,'
                       							 +labelToBeQueried+ ',' +urlToBeQuried+ 
                       							 ' FROM Core_MDF_Content_Configuration__c'+
                        						' WHERE Core_MDF_Section_Code_txt__c = : sectionCodeStr'+
                        						' AND Core_MDF_isActive_Ind__c = True ';
                    
                    if(sectionCode =='Home_Announcement'){
                        contentConfigQuery +=' AND Core_MDF_Category_nm__c = \'Community Announcement\' AND Core_MDF_Effective_Start_Date__c <= '+todayDate+' And Core_MDF_Effective_End_Date__c >= '+todayDate+' Order BY Core_MDF_Sort_Order_nbr__c';
                        
                    }else{
                        contentConfigQuery +=' AND Core_MDF_Category_nm__c = \'Community\' Order BY Core_MDF_Sort_Order_nbr__c';
                    }
                        
                    contentConfigsList = Database.query(contentConfigQuery);
                }
            }
            
            if(contentConfigsList != null && !contentConfigsList.isEmpty()){
                for (Core_MDF_Content_Configuration__c  content : contentConfigsList ) {
                    if(string.isNotBlank(string.valueof(content.get(labelToBeQueried)))){
                        contentWrapper wrapper = new contentWrapper();
                        wrapper.contentLabel = string.valueof(content.get(labelToBeQueried));
                        wrapper.contentUrl = string.valueof(content.get(urlToBeQuried));
                        resultList.add(wrapper);
                    }
                }  
            }
            
        }
        catch(Exception ex){
            //Core_MDF_CCP_UtilityClass.logError(ex);
            system.debug('exception'+ex.getMessage());
        }
        system.debug('resultList'+resultList);
        return resultList;
    }
     public class contentWrapper{
        @AuraEnabled public String contentLabel;
        @AuraEnabled public String contentUrl;
    }
}