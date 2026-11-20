/**************************************************************************************
* Clas Name 		: Core_MDF_DynamicContentGenerator
* Test Class Name  : Core_MDF_DynamicContentGenerator_Test
* Description		: Generic class to fetch content configuration records 
***************************************************************************************/
public without sharing class Core_MDF_DynamicContentGenerator {
    /*This Method is used to fetch content configuration records based on section code and logged in user's language passed*/

    public static ContentInputWrapper getData (string sectionCode, string loggedInUserLang){
        List<Core_MDF_Content_Configuration__c> contentConfigsList = new List<Core_MDF_Content_Configuration__c>();
        String labelToBeQueried = '';
        String urlToBeQuried = '';
        String helptextToBeQueried = '';
        String sectionCodeStr = String.escapeSingleQuotes(sectionCode);
        String loggedInUserLangStr = String.escapeSingleQuotes(loggedInUserLang);
        ContentInputWrapper ContentWrap = new ContentInputWrapper();
        if(String.isNotBlank(sectionCodeStr) && String.isNotBlank(loggedInUserLangStr)){
            //Based on loggedin user's language get the value of label & URL from corresponding fields
            if(string.isNotBlank(loggedInUserLangStr)){
                labelToBeQueried = loggedInUserLangStr != 'en_US' ? 'Core_MDF_Label_'+loggedInUserLangStr+'_txt__c' : 'Core_MDF_Content_Label_txt__c' ;
                urlToBeQuried    = loggedInUserLangStr != 'en_US' ? 'Core_MDF_'+loggedInUserLangStr+'_URL__c' : 'Core_MDF_Content_URL__c';
                helptextToBeQueried = loggedInUserLangStr != 'en_US' ? 'Core_MDF_HelpText_'+loggedInUserLangStr+'_txt__c' : 'Core_MDF_Content_HelpText_txt__c';
            }
            string qryStr = 'SELECT Id,Core_MDF_Parent_Content_Config_Id__c,Core_MDF_Category_nm__c,Core_MDF_Section_Code_txt__c,Core_MDF_Sort_Order_nbr__c,Core_MDF_Is_Icon_Required_ind__c,Core_MDF_Icon_URL__c,Core_MDF_Style_txt__c,Core_MDF_rowspan_nbr__c,'+
                +String.escapeSingleQuotes(labelToBeQueried)+ ',' +String.escapeSingleQuotes(urlToBeQuried)+ ',' +String.escapeSingleQuotes(helptextToBeQueried)+ 
                ' FROM Core_MDF_Content_Configuration__c'+
                ' WHERE Core_MDF_Section_Code_txt__c = : sectionCodeStr'+
                ' AND Core_MDF_isActive_Ind__c = True'+
                ' Order BY Core_MDF_Sort_Order_nbr__c';
            
            contentConfigsList = Database.query(qryStr);
            ContentWrap.ContentConfigList=contentConfigsList;
            ContentWrap.labelfieldAPIName = labelToBeQueried;
            ContentWrap.URLfieldAPIName = urlToBeQuried;
            ContentWrap.helpTextFieldAPIName = helptextToBeQueried;
            
        }
        return ContentWrap;
    }
   //Wrapper Class to pass details
    public class ContentInputWrapper{
     public String labelfieldAPIName{get;set;}
     public string URLfieldAPIName{get;set;}   
     public string helpTextFieldAPIName {get;set;}
     public List<Core_MDF_Content_Configuration__c> ContentConfigList{get;set;}
    }
}