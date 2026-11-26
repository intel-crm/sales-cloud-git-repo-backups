/****************************************************************************************************************************************
* Class Name       : Core_MDF_POP_Details 
* Test Class Name  : Core_MDF_POP_Details_test
* Version          : 1.0 
* Created Date     : 16-Sep-2020
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Vivek K        09/16/2020                   Class to fetch POP details based on Program, Activity type, Activity Category  
* Ganapati       01/12/2020                   US851171 - [RMF Activity] - Claiming Deadline Text in POP Requirement Section
* Ganapati       04/12/2020                   US849793: [KIIT]: Replace Label with Metadata record reference for POP display on Activity POP component
*****************************************************************************************************************************************/

public with sharing class Core_MDF_POP_Details {     
    
    static String sanitizeRecdId = '';
    static String sanitizedObjname = '';
    static String strProgramName = '';
    static String strActCatVal = '';
    static String strActTypeVal = '';
    static String strActSubTypeVal = '';
    public static List<string> languages = (Core_MDF_CCP_ConstantClass.CCP_SUPPORTED_LOCALE).split(',');
    
    @AuraEnabled(cacheable=true)   
    public static POPWrapper getPOPvalues(String popDetail) {   
        Map<String, Object> queryVariabels = (Map<String, Object>) JSON.deserializeUntyped(popDetail);
              
        
        String strLabel = '';
        String strHeader = '';
        String recordId=(String)queryVariabels.get('recordId');
        String objectApiName=(String)queryVariabels.get('objectApiName');
        
        String displayLabel=(String)queryVariabels.get('displayLabel');
        strProgramName = (String)queryVariabels.get('recTypeName');
        strActCatVal = (String)queryVariabels.get('actCat'); 
        strActTypeVal = (String)queryVariabels.get('actType');
        strActSubTypeVal = (String)queryVariabels.get('actSubType'); 
        
        try {   
            if((String.isBlank(recordId) || String.isBlank(objectApiName) || !(recordId instanceOf Id) || Schema.getGlobalDescribe().get(objectApiName) == null) 
               && (String.isBlank(strActCatVal) || String.isBlank(strActTypeVal)||String.isBlank(strProgramName))
              ) {
                  return new POPWrapper();
              }
            
            if(String.isNotBlank(recordId) && String.isNotBlank(objectApiName)) {
                sanitizeRecdId = String.escapeSingleQuotes(recordId);
                //To get original value of record id unescaping sanitizeRecdId
                sanitizeRecdId = sanitizeRecdId.unescapeHtml4();
                sanitizedObjname = String.escapeSingleQuotes(objectApiName);
                fetchActCatType();   
            }
            strLabel = fetchPOPMetadata();      
            strHeader = fetchLabel(displayLabel);
            
            /* US851171 - [RMF Activity] - Claiming Deadline Text in POP Requirement Section - Start */
            if(System.Label.Core_MDF_Retail_Program_Name.equalsIgnoreCase(strProgramName) && String.isNotBlank(strLabel)) {
                strLabel = strLabel + '<br /><br />' +System.Label.Core_MDF_ClaimSubmissionDeadlines;    
            } 
            /* US851171 - [RMF Activity] - Claiming Deadline Text in POP Requirement Section - end */
        } catch(Exception ex) { 
            logErrorAsync(Core_MDF_CCP_UtilityClass.getErrorDetails(ex));
        }
        
        POPWrapper obj = new POPWrapper();
        obj.datamap = strLabel;
        obj.displayHeader = strHeader;
        
        return obj;
    }
    
    /****************************************************************************************************************************************
Method Name:                                   fetchActCatType
Description:                                   Fetch Activity Category and Type for PFR/PFC
Added By:                                      Vivek K - 16-Sep-2020
Modified By:                  Date:            Changes: 
Vivek K                      09/16/2020        Created.
*****************************************************************************************************************************************/
    private static void fetchActCatType() {
        String strCat = '';
        String strtype = '';  
        String strProgram = ''; 
        String strQuery = '';

        String strSType = '';
        
        strCat = String.escapeSingleQuotes(System.Label.Core_MDF_PFR_ActCat); 
        strtype = String.escapeSingleQuotes(System.Label.Core_MDF_PFRC_ActType);
        strProgram = String.escapeSingleQuotes(System.Label.Core_MDF_PFRC_Program);
        strSType = String.escapeSingleQuotes('Core_MDF_Activity_SubType_nm__c');
        
        
        if(String.isNotBlank(strCat) && String.isNotBlank(strtype) && String.isNotBlank(strProgram)) {
            strQuery = 'SELECT Id,' + strProgram + ',' + strCat + ',' + strtype + ',' + strSType +' FROM ' + sanitizedObjname + ' WHERE Id=:sanitizeRecdId';   
            
            SObject pfObj = Database.query(strQuery) ;
            
            if(pfObj!=null) {
                strActCatVal = String.valueOf(pfObj.get(strCat)) ;
                strActTypeVal = String.valueOf(pfObj.get(strtype)) ;  
                strProgramName = String.valueOf(pfObj.get(strProgram));
                strActSubTypeVal =  String.valueOf(pfObj.get(strSType));              
            }
        }
        
    }
    
    /****************************************************************************************************************************************
Method Name:                                   fetchPOPMetadata
Description:                                   Fetch POP content
Added By:                                      Vivek K - 06-Sep-2020
Modified By: Akanksha                          Date: 28/10/2024            Changes: 
Vivek K                      09/06/2020        Created.
*****************************************************************************************************************************************/    
    private static String fetchPOPMetadata() {
        //exception fix 
        if(String.isBlank(strActCatVal) || String.isBlank(strActTypeVal) || String.isBlank(strProgramName)){return '';}
        String userLang = UserInfo.getLanguage();
        String strLabel = '';
        String objectFieldApiName;
        userLang = (userLang != null && languages.contains(userLang)) ? userLang : 'en_US';
        String colToBeQueried = 'Core_MDF_'+userLang+'_cd__c';
        String categoryPopName = Core_MDF_CCP_ConstantClass.POP_TRANSLATION;
        try{
            //Custom Setting records to fetch mapping of the language specific field with Core_MDF_CCP_Custom_Metadata_Utility__c Object field
            Core_MDF_Metadata_Utility_mapping__c csRecord = Core_MDF_Metadata_Utility_mapping__c.getvalues(colToBeQueried);
            objectFieldApiName = csRecord.Core_MDF_Object_Field_API_Name__c != NULL ? csRecord.Core_MDF_Object_Field_API_Name__c : '';
            //CCP_MDF_POP_Translation__mdt[] langTrans;
            List<Core_MDF_CCP_Custom_Metadata_Utility__c> langTransList = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
            String query;
            if (String.isNotBlank(objectFieldApiName)) {
                String baseQuery = 'SELECT ' + String.escapeSingleQuotes(objectFieldApiName) + 
                    ' FROM Core_MDF_CCP_Custom_Metadata_Utility__c ' +
                    ' WHERE Core_MDF_Field_1_txt__c = \'' + String.escapeSingleQuotes(strActCatVal) + '\' ' +
                    ' AND Core_MDF_Field_2_txt__c = \'' + String.escapeSingleQuotes(strActTypeVal) + '\' ' +
                    ' AND Core_MDF_Program__c = \'' + String.escapeSingleQuotes(strProgramName) + '\' ' +
                    ' AND Core_MDF_Is_Active_Ind__c = TRUE';
                
                if (System.Label.Core_MDF_Retail_Program_Name.equalsIgnoreCase(strProgramName) && String.isNotBlank(strActSubTypeVal)) {
                    query = baseQuery + 
                        ' AND Core_MDF_Field_3_txt__c = \'' + String.escapeSingleQuotes(strActSubTypeVal) + '\' ' +
                        ' AND Core_MDF_Category__c = \'' + String.escapeSingleQuotes(categoryPopName) + '\'';
                } else {
                    query = baseQuery + 
                        ' AND Core_MDF_Category__c = \'' + String.escapeSingleQuotes(categoryPopName) + '\'';
                }
            }
            
            if(String.isNotBlank(query)){
                langTransList= Core_MDF_Custom_Metadata_Utility.getCustomObjectRecordsUsingDynamicQuery(query);
            } 
            if(langTransList != null && langTransList.size() > 0 && langTransList[0].get(objectFieldApiName) != null) {
                strLabel = String.valueOf(langTransList[0].get(objectFieldApiName)).trim();
            }
            
        }catch(Exception ex) { 
            logErrorAsync(Core_MDF_CCP_UtilityClass.getErrorDetails(ex));
        }
        return strLabel;    
    }
    
    /****************************************************************************************************************************************
Method Name:                                   fetchLabel
Description:                                   Fetch POP header label
Added By:                                      Vivek K - 06-Sep-2020
Modified By:                  Date:            Changes: 
Vivek K                      09/06/2020        Created.
*****************************************************************************************************************************************/
    private static String fetchLabel(string displayHeader) {   
        String userLang = UserInfo.getLanguage();
        String strLabel = '';
        
        if(String.isNotBlank(displayHeader)) {
            try {
                //Get the user language.
                userLang = (userLang != null && languages.contains(userLang)) ? userLang : 'en_US';

                Core_MDF_History_Header_Translation__mdt[] langTrans;
                String query = 'Select toLabel(Core_MDF_History_Header_Translation_nm__c) '/*String.escapeSingleQuotes(colToBeQueried)*/+
                    ' from Core_MDF_History_Header_Translation__mdt where DeveloperName=\''
                    +String.escapeSingleQuotes(displayHeader)+'\'';
                String v1 = query;
            
                langTrans=Database.query(v1);
                if(langTrans != null && langTrans.size() > 0 /*&& langTrans[0].get(colToBeQueried) != null*/) {
                    
                   strLabel = String.valueOf(langTrans[0].Core_MDF_History_Header_Translation_nm__c);
                }
            } catch(Exception ex) { 
                logErrorAsync(Core_MDF_CCP_UtilityClass.getErrorDetails(ex));
            }
        }
        return strLabel;    
    } 
    
    public class POPWrapper{
        @AuraEnabled public String datamap = '';
        @AuraEnabled public string displayHeader = '';
    }  

/****************************************************************************************************************************************
    Method Name:                                   logErrorAsync
    Description:                                   Logs error details asynchronously to ensure that failures during error logging
                                                do not impact the main business transaction. 
    Added By:                                      Shravani
    Created Date:                                  05/06/2026
*****************************************************************************************************************************************/
    @future
    public static void logErrorAsync(String errorDetails) {
        Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails, 'Core_MDF_POP_Details');
    }
}