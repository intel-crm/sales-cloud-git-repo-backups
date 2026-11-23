public class Core_MDF_Dynamic_Content_Creation {
     Public static List<string> appSupportedLang = Core_MDF_CCP_ConstantClass.CCP_SUPPORTED_LOCALE.split(','); 
@AuraEnabled
    public static Map<String,list<ContentWrapperObj>> getContent(string sectionCode) {
      List<ContentWrapperObj> resultList = new List<ContentWrapperObj>();
      List<Core_MDF_Content_Configuration__c> contentConfigsList = new List<Core_MDF_Content_Configuration__c>();
        String labelToBeQueried = '';
        String urlToBeQuried = '';
        String helptextToBeQueried = '';
        String sectionCodeStr = String.escapeSingleQuotes(sectionCode);
        String loggedinUserLang = appSupportedLang.contains(UserInfo.getLanguage()) ? UserInfo.getLanguage() : 'en_US' ;
        Map<String, List<ContentWrapperObj>> resultMap = new Map<String, List<ContentWrapperObj>>();

       // ContentInputWrapper ContentWrap = new ContentInputWrapper();
        if(String.isNotBlank(sectionCodeStr)){
            //Based on loggedin user's language get the value of label & URL from corresponding fields
                labelToBeQueried = loggedInUserLang != 'en_US' ? 'Core_MDF_Label_'+loggedInUserLang+'_txt__c' : 'Core_MDF_Content_Label_txt__c' ;
                urlToBeQuried    = loggedInUserLang != 'en_US' ? 'Core_MDF_'+loggedInUserLang+'_URL__c' : 'Core_MDF_Content_URL__c';
                helptextToBeQueried = loggedInUserLang != 'en_US' ? 'Core_MDF_HelpText_'+loggedInUserLang+'_txt__c' : 'Core_MDF_Content_HelpText_txt__c';
            
            string qryStr = 'SELECT Id,Core_MDF_Section_Code_txt__c,Core_MDF_Section_SubHeader_txt__c,Core_MDF_Sub_Header_Seq_No_nbr__c,Core_MDF_Sort_Order_nbr__c,Core_MDF_Is_Icon_Required_ind__c,Core_MDF_Icon_URL__c,'+
                +labelToBeQueried+ ',' +urlToBeQuried+ ',' +helptextToBeQueried+ 
                ' FROM Core_MDF_Content_Configuration__c'+
                ' WHERE Core_MDF_Section_Code_txt__c = : sectionCodeStr'+
                ' AND Core_MDF_isActive_Ind__c = True'+
                ' Order BY Core_MDF_Sub_Header_Seq_No_nbr__c,Core_MDF_Sort_Order_nbr__c';
            
            contentConfigsList = Database.query(qryStr);
     
        
        
        
        
    }
        return resultMap;
    }
    
    //Wrapper Class for Output Details
    public class ContentWrapperObj{
        @AuraEnabled public String contentLabel;  //Holds value of label to be displayed on community 
        @AuraEnabled public String contentUrl;    //Holds value of URL to be displayed on community
        @AuraEnabled public String contentHelpText; //Holds Value of description on hoverover of icon & label on community 
        @AuraEnabled public Boolean isIconRequired;  //Holds Value of boolean value of isIcon required on community
        @AuraEnabled public String iconUrl;          //Holds value of static resource url of icon on community
    }
}