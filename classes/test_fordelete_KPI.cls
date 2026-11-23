/****************************************************************************************************************************************
* Class Name  : Core_MDF_KPIDetailPage 
* Version     : 1.0 
* Created Date: 16-Feb-2020
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Vivek K        02/16/2020                   Class to fetch KPI details based on Program, Module, Activity type, Activity Category  
*****************************************************************************************************************************************/

public with sharing class test_fordelete_KPI {     

    static string sanitizeRecdId = '';
    static string sanitizedObjname = '';
    static string strProgramName = '';
    static string strActCatVal = '';
    static string strActTypeVal = '';
    //test code begins
    static string strActSubTypeVal = '';
    
    //test code ends
    
    @AuraEnabled(cacheable=true)
    //public static Map<String,String> getKPIvalues(string recordId,string objectApiName)
    //public static KPIWrapper getKPIvalues(string recordId,string objectApiName,string displayHeader)
    public static POPWrapper getPOPvalues(string recordId,string objectApiName)
    {
        List<String> lstKPImdata = new List<String>();
        Map<String,String> apiValueMap = new Map<String,String>();               
        string strlabel = '';

        try
        {  
            if(String.isBlank(recordId) || string.isBlank(objectApiName) || !(recordId instanceOf Id) || Schema.getGlobalDescribe().get(objectApiName) == null)
            { 
                System.debug('Argument is null');
                return new POPWrapper();
            }

            sanitizeRecdId = string.escapeSingleQuotes(recordId);
            sanitizedObjname = string.escapeSingleQuotes(objectApiName);

            // sanitizeRecdId = getActClaimId(sanitizeRecdId,sanitizedObjname);                         
            //sanitizeRecdId = getActClaimId();
            
            // fetchActCatType(sanitizeRecdId,sanitizedObjname);                                   
            fetchActCatType();

            //test for POP begins
            strlabel = fetchPOPMetadata(strActCatVal,strActTypeVal);

        

       
            
    }
    catch(Exception ex)
        {   
            System.debug(''+ex.getMessage());
            Core_MDF_CCP_UtilityClass.logError(ex);
        }

        POPWrapper obj = new POPWrapper();
        obj.datamap = strlabel;
        obj.displayHeader = 'POP';

        return obj;

}
   
/****************************************************************************************************************************************
Method Name:                                   fetchActCatType
Description:                                   Fetch Activity Category and Type for PFR/PFC
Added By:                                      Vivek K - 16-Feb-2020
Modified By:                  Date:            Changes: 
Vivek K                      02/16/2020        Created.
*****************************************************************************************************************************************/
    private static void fetchActCatType()
    {
        string strCat = '';
        string strtype = '';  
        string strProgram = ''; 
        string strQuery = '';
        string strSubtype = '';

        if(sanitizedObjname == System.Label.Core_MDF_PFRText)
        {
            strCat = string.escapeSingleQuotes(System.Label.Core_MDF_PFR_ActCat);
        }
            else if(sanitizedObjname == System.Label.Core_MDF_PFCText)
        {
            strCat = string.escapeSingleQuotes(System.Label.Core_MDF_PFC_ActCat);               
        }
            
        strtype = string.escapeSingleQuotes(System.Label.Core_MDF_PFRC_ActType);
        strProgram = string.escapeSingleQuotes(System.Label.Core_MDF_PFRC_Program);
        //test code begins
        strSubtype = string.escapeSingleQuotes(System.Label.Core_MDF_PFR_ActSubType);
        //test code ends

        if(string.isNotBlank(strCat))
        {
            //test code begins
            //strQuery = 'SELECT Id,' + strProgram + ',' + strCat + ',' + strtype + ' FROM ' + sanitizedObjname + ' WHERE Id=:sanitizeRecdId';
            strQuery = 'SELECT Id,' + strProgram + ',' + strCat + ',' + strtype + ','+ strSubtype + ' FROM ' + sanitizedObjname + ' WHERE Id=:sanitizeRecdId';
            System.debug(strQuery);
            //test code ends
            SObject pfObj = Database.query(strQuery) ;

            if(pfObj!=null)
            {
                strActCatVal = string.valueOf(pfObj.get(strCat)) ;
                strActTypeVal = string.valueOf(pfObj.get(strtype)) ;  
                strProgramName = string.valueOf(pfObj.get(strProgram));
                //test code begins
                if(string.isNotBlank(strProgramName) && strProgramName != System.Label.Core_MDF_PFR_IPA)
                {
                    strActSubTypeVal = string.valueOf(pfObj.get(strSubtype));
                }                
                System.debug(strActSubTypeVal);
                //test code ends
            }
        }
       
    }
    
/****************************************************************************************************************************************
Method Name:                                   fetchMetadata
Description:                                   Fetch KPI metadata for PartnerFundRequest/PartnerFundClaim Object
Added By:                                      Vivek K - 16-Feb-2020
Modified By:                  Date:            Changes: 
Vivek K                      02/16/2020        Created.
*****************************************************************************************************************************************/
    //test code begins
    // private static List<String> fetchMetadata(string stractCat, string stractType)
    // {        
    //     if(stractCat!=null && stractType!=null && strProgramName!=null)
    //     {
    //         for(CCP_Activity_Type_dependent_fields__mdt kpiVal: [SELECT Core_MDF_Object_API_Field_Name__c,Core_MDF_Sort_Order_Nbr__c from CCP_Activity_Type_dependent_fields__mdt
    //                                                              WHERE Core_MDF_Program_Txt__c =: strProgramName and Core_MDF_Module__c =: sanitizedObjname and Core_MDF_Activity_Category_Txt__c =: stractCat and Core_MDF_Activity_Type_Txt__c =:stractType order by Core_MDF_Sort_Order_Nbr__c])            
    //         {           	                
    //             kpimVal.add(kpiVal.Core_MDF_Object_API_Field_Name__c);
    //         }
    //     }            	       		            			                                
    //     return kpimVal;                   
    // }

  /*  private static List<String> fetchMetadata(string stractCat, string stractType,string stractSubtype)
    {     
        List<String> kpimVal = new List<String>();

        if(stractCat!=null && stractType!=null && strProgramName!=null)
        {
            for(CCP_Activity_Type_dependent_fields__mdt kpiVal: [SELECT Core_MDF_Object_API_Field_Name__c,Core_MDF_Sort_Order_Nbr__c from CCP_Activity_Type_dependent_fields__mdt
                                                                 WHERE Core_MDF_Program_Txt__c =: strProgramName and Core_MDF_Module__c =: sanitizedObjname and Core_MDF_Activity_Category_Txt__c =: stractCat and Core_MDF_Activity_Type_Txt__c =:stractType 
                                                                 and Core_MDF_Activity_Subtype_Txt__c =: stractSubtype order by Core_MDF_Sort_Order_Nbr__c])            
            {           	                
                kpimVal.add(kpiVal.Core_MDF_Object_API_Field_Name__c);
            }
        }            	       		            			                                
        return kpimVal;                   
    } */

    private static String fetchPOPMetadata(string stractCat,string stractType)
    {
        String userLang = 'en_US';
        String strLabel = '';


        userLang = (UserInfo.getLanguage() != null) ? UserInfo.getLanguage() : 'en_US';
        String colToBeQueried = 'Core_MDF_'+userLang+'_cd__c';
        CCP_MDF_POP_Translation__mdt[] langTrans;

        String query = 'Select '+String.escapeSingleQuotes(colToBeQueried)+ ' from CCP_MDF_POP_Translation__mdt where Core_MDF_Activity_Category_Txt__c=\''
           +stractCat+'\'' + 'and Core_MDF_Activity_Type_Txt__c = \''+stractType+'\'';
            system.debug('query:'+query);
            String v1 = query;
            langTrans=Database.query(v1);
            system.debug('langTrans:'+langTrans);

            if(langTrans != null && langTrans.size() > 0){
                if(langTrans[0].get(colToBeQueried) != null){
                    strLabel = String.valueOf(langTrans[0].get(colToBeQueried)).trim();
                }               
            }

        return strLabel;    
    }
    //test code ends
    
/****************************************************************************************************************************************
Method Name:                                   fetchsavedValues
Description:                                   Fetch KPI saved values for PartnerFundRequest/PartnerFundClaim Object
Added By:                                      Vivek K - 16-Feb-2020
Modified By:                  Date:            Changes: 
Vivek K                      02/16/2020        Created.
*****************************************************************************************************************************************/ 
  /*  private static SObject fetchsavedValues(List<String> lstKPImdata)
    {
        SObject pfObj;
        string strfield = '';
        string strQuery = '';            
        
        strfield = String.join(lstKPImdata,',');           
        strQuery = 'SELECT id,' + strfield + ' FROM ' + sanitizedObjname + ' WHERE Id=: sanitizeRecdId';
        
        pfObj = Database.query(strQuery); 
        
        return pfObj;
    } */

/****************************************************************************************************************************************
Method Name:                                   getActClaimId
Description:                                   Check for Claim object and return Act/Claim ID
Added By:                                      Vivek K - 16-Feb-2020
Modified By:                  Date:            Changes: 
Vivek K                      02/16/2020        Created.
*****************************************************************************************************************************************/ 
 /*   private static String getActClaimId()
    {
        String returnId;
        Schema.SObjectType objtype;

        if(String.isNotBlank(sanitizeRecdId))
        {
            objtype = ((Id)sanitizeRecdId).getSobjectType();
        }      

        if(objtype != null && objtype == Case.SobjectType)         
        {
            string strQuery = 'select id,Core_MDF_Activity_ID__c, Core_MDF_Claim_ID__c from case where id=:sanitizeRecdId';
        
            Case pfObj = Database.query(strQuery);
            
            if(pfObj!=null)
            {
                if(sanitizedObjname == System.Label.Core_MDF_PFRText)
                {           
                    returnId = pfObj.Core_MDF_Activity_ID__c;                             
                }

                if(sanitizedObjname == System.Label.Core_MDF_PFCText)
                {
                    returnId = pfObj.Core_MDF_Claim_ID__c; 
                }
            }  
        }
                
        return string.isBlank(returnId)?sanitizeRecdId:returnId;               
    } */
   
/****************************************************************************************************************************************
Method Name:                                   getActClaimId
Description:                                   Check for Claim object and return Act/Claim ID
Added By:                                      Vivek K - 06-Jul-2020
Modified By:                  Date:            Changes: 
Vivek K                      07/06/2020        Created.
*****************************************************************************************************************************************/
   /* private static String fetchLabel(string displayHeader)
    {   
        String userLang = 'en_US';
        String strLabel = '';

        if(String.isNotBlank(displayHeader))
        {
           //Get the user language.
           userLang = (UserInfo.getLanguage() != null) ? UserInfo.getLanguage() : 'en_US';
           String colToBeQueried = 'Core_MDF_'+userLang+'_cd__c';
           Core_MDF_History_Header_Translation__mdt[] langTrans;

           String query = 'Select '+String.escapeSingleQuotes(colToBeQueried)+ ' from Core_MDF_History_Header_Translation__mdt where DeveloperName=\''
           +String.escapeSingleQuotes(displayHeader)+'\'';
            system.debug('query:'+query);
            String v1 = query;
            langTrans=Database.query(v1);
            system.debug('langTrans:'+langTrans);

            if(langTrans != null && langTrans.size() > 0){
                if(langTrans[0].get(colToBeQueried) != null){
                    strLabel = String.valueOf(langTrans[0].get(colToBeQueried)).trim();
                }               
            }
        }

        return strLabel;

    } 

    public class KPIWrapper{
        @AuraEnabled
        public Map<String,String> datamap = new Map<String,String>();
        @AuraEnabled
        public string displabel = '';
    } */ 
    
    public class POPWrapper{
        @AuraEnabled
        public String datamap = '';
        @AuraEnabled
        public string displayHeader = '';
    }
    
}