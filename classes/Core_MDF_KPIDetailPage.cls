/****************************************************************************************************************************************
* Class Name       : Core_MDF_KPIDetailPage 
* Test Class Name  : Core_MDF_KPIDetailPage_test
* Version          : 1.0 
* Created Date     : 16-Feb-2020
* Modification Log :
* Developer            Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Vivek K           02/16/2020                   Class to fetch KPI details based on Program, Module, Activity type, Activity Category 
* Ganapati          01/14/2021                   Modified for - adding toLabel to picklist field api 
*****************************************************************************************************************************************/

public with sharing class Core_MDF_KPIDetailPage {     
    
    static String sanitizeRecdId = '';
    static String sanitizedObjname = '';
    static String strProgramName = '';
    static String strActCatVal = '';
    static String strActTypeVal = '';
    static String strActSubTypeVal = '';
    static String strPropBasedInd = '';
    static String multiSubType = '';
    //public static List<string> languages = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCPSupportedLocale').split(',');
    public static List<string> languages = (Core_MDF_CCP_ConstantClass.CCP_SUPPORTED_LOCALE).split(',');
    
    @AuraEnabled(cacheable=true)
    public static KPIWrapper getKPIvalues(String recordId, String objectApiName, String displayHeader) {
        Map<String,String> lstKPImdata = new Map<String,String>();
        Map<String,String> apiValueMap = new Map<String,String>();
        Map<String,String> apiHelpTextMap = new Map<String,String>();
        Map<string, String> fldLabelToAPINameMap = new Map<String, String>();   
        
        System.debug('RecordId RP: ' + recordId);
        System.debug('ObjectApiName RP: ' + objectApiName);
        System.debug('DisplayHeader RP: ' + displayHeader);

        // try-catch intentionally removed to allow exceptions to propagate to LWC for client-side handling and logging 
            if(String.isBlank(recordId) || String.isBlank(objectApiName) || !(recordId instanceOf Id) || Schema.getGlobalDescribe().get(objectApiName) == null) { 
                
                return new KPIWrapper();
            }
            
            sanitizeRecdId = String.escapeSingleQuotes(recordId);
            sanitizedObjname = String.escapeSingleQuotes(objectApiName);
            
            // sanitizeRecdId = getActClaimId(sanitizeRecdId,sanitizedObjname);                         
            sanitizeRecdId = getActClaimId();
            
            // fetchActCatType(sanitizeRecdId,sanitizedObjname);                                   
            fetchActCatType();
            
            // ATHR Avoid long parameter lists - US 14285 - Indira
            //Fetch metadata details                 
            lstKPImdata = fetchMetadata(new FetchMetadataContext(
                strActCatVal,
                strActTypeVal,
                strActSubTypeVal,
                strProgramName,
                strPropBasedInd,
                displayHeader
            ));
            
            if(lstKPImdata !=null && lstKPImdata.size()>0) {      
                //Fetch saved values  
                SObject pfdata = fetchsavedValues(lstKPImdata.values()); 
                Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sanitizedObjname).getDescribe().fields.getMap(); 
                
                //Build final Map
                if(pfdata!=null) {                          
                    for(String fld:lstKPImdata.keySet()) {
                        String value = String.valueOf(pfdata.get(fld));
                        apiValueMap.put(fieldMap.get(fld).getDescribe().getLabel(), String.isBlank(value)?'':value);  
                        fldLabelToAPINameMap.put(fieldMap.get(fld).getDescribe().getLabel(), fieldMap.get(fld).getDescribe().getName());  
                        apiHelpTextMap.put(fieldMap.get(fld).getDescribe().getLabel(),fieldMap.get(fld).getDescribe().getInlineHelpText());                                                   
                    }                                                              
                }                                                                                                      
            }                       
        
        KPIWrapper obj = new KPIWrapper();
        obj.datamap = apiValueMap;
        obj.displabel = fetchLabel(displayHeader);
        obj.helpTextMap = apiHelpTextMap;
        obj.fldLabelToAPINameMap = fldLabelToAPINameMap;     
        return obj;
    }
    
    /****************************************************************************************************************************************
    Method Name:                                   fetchActCatType
    Description:                                   Fetch Activity Category and Type for PFR/PFC
    Added By:                                      Vivek K - 16-Feb-2020
    Modified By:                  Date:            Changes: 
    Vivek K                      02/16/2020        Created.
    *****************************************************************************************************************************************/
    private static void fetchActCatType() {
        String strCat = '';
        String strtype = '';  
        String strProgram = ''; 
        String strQuery = '';
        String strSubtype = '';
        String subtypeListStr = '';
        List<String> actSubTypeList = new List<String>();
        
        if(sanitizedObjname == System.Label.Core_MDF_PFRText) {
            strCat = String.escapeSingleQuotes(System.Label.Core_MDF_PFR_ActCat);
        }
        else if(sanitizedObjname == System.Label.Core_MDF_PFCText) {
            strCat = String.escapeSingleQuotes(System.Label.Core_MDF_PFC_ActCat);               
        }
        
        strtype = String.escapeSingleQuotes(System.Label.Core_MDF_PFRC_ActType);
        strProgram = String.escapeSingleQuotes(System.Label.Core_MDF_PFRC_Program);
        strSubtype = String.escapeSingleQuotes(System.Label.Core_MDF_PFR_ActSubType);
        
        if(String.isNotBlank(strCat)) {            
            strQuery = 'SELECT Id, Core_MDF_Proposal_Based_Ind__c,' + strProgram + ',' + strCat + ',' + strtype + ','+ strSubtype + ' FROM ' + sanitizedObjname + ' WHERE Id=:sanitizeRecdId';
            //SObject pfObj = Database.query(strQuery) ;
            List<SObject> results = Database.query(strQuery);
            // US - TWC702-14285: Flatten nested IFs (no logic change) - Oroginal code commented
            /*if(pfObj!=null) {
                strActCatVal = String.valueOf(pfObj.get(strCat)) ;
                strActTypeVal = String.valueOf(pfObj.get(strtype)) ;  
                strProgramName = String.valueOf(pfObj.get(strProgram));
                strPropBasedInd = String.valueOf(pfObj.get('Core_MDF_Proposal_Based_Ind__c'));
                ///*&& strProgramName != System.Label.Core_MDF_PFR_IPA
            if(String.isNotBlank(strProgramName)  && String.isNotBlank(String.valueOf(pfObj.get(strSubtype)))) { //changes for IPA KPI Metrics
                    strActSubTypeVal = String.valueOf(pfObj.get(strSubtype));
                    if(strProgramName == System.Label.Core_MDF_PFR_IPA){ //changes for IPA KPI Metrics
                        actSubTypeList = strActSubTypeVal.split(';');
                       
                        if(actSubTypeList != null && !actSubTypeList.isEmpty()){
                            subtypeListStr ='(\'' + String.join(actSubTypeList, '\', \'') + '\')';
                            multiSubType = String.escapeSingleQuotes(subtypeListStr).replaceAll('\\\\','');
                        }
                    }
            }                
            }*/
            // US - TWC702-14285: Flatten nested IFs (no logic change) - Begin
            If(!results.isEmpty()){
            //if (pfObj != null) {
                SObject pfObj = results[0];
                strActCatVal    = String.valueOf(pfObj.get(strCat));
                strActTypeVal   = String.valueOf(pfObj.get(strtype));
                strProgramName  = String.valueOf(pfObj.get(strProgram));
                strPropBasedInd = String.valueOf(pfObj.get('Core_MDF_Proposal_Based_Ind__c'));

                String subTypeVal = String.valueOf(pfObj.get(strSubtype));

                Boolean hasProgramAndSubtype = String.isNotBlank(strProgramName) && String.isNotBlank(subTypeVal);
                Boolean isIPAProgram         = strProgramName == System.Label.Core_MDF_PFR_IPA;

                if (hasProgramAndSubtype) {
                    strActSubTypeVal = subTypeVal;
                }

                if (hasProgramAndSubtype && isIPAProgram) {
                    actSubTypeList = strActSubTypeVal.split(';');
                }

                if (hasProgramAndSubtype && isIPAProgram && actSubTypeList != null && !actSubTypeList.isEmpty()) {
                    subtypeListStr = '(\'' + String.join(actSubTypeList, '\', \'') + '\')';
                    multiSubType = String.escapeSingleQuotes(subtypeListStr).replaceAll('\\\\','');
                }
            }
            // US - TWC702-14285: Flatten nested IFs (no logic change) - End
        }
    }
    
    /****************************************************************************************************************************************
    Method Name:                                   fetchMetadata
    Description:                                   Fetch KPI metadata for PartnerFundRequest/PartnerFundClaim Object
    Added By:                                      Vivek K - 16-Feb-2020
    Modified By:                  Date:            Changes: 
    Vivek K                      02/16/2020        Created.
    Ganapati                     01/14/2020        Modified for - adding toLabel to picklist field api 
    *****************************************************************************************************************************************/  
    // ATHR Avoid long parameter lists - US 14285 - Indira  
    private static Map<String,String> fetchMetadata(FetchMetadataContext ctx) {     
        //  unpack wrapper into local variables; do not use ctx directly after this.
        String stractCat = ctx.actCat;
        String stractType = ctx.actType;
        String stractSubtype = ctx.actSubtype;
        String strProgramName = ctx.programName;
        String strPropBasedInd = ctx.propBasedInd;
        String displayHeader = ctx.displayHeader;

        Map<String,String> kpimVal = new Map<String,String>();
        // Highlight: Unused Local Variable - 14285
        // List<Core_MDF_CCP_Custom_Metadata_Utility__c> actDepMdtList = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
        if(stractCat!=null && stractType!=null && stractSubtype!=null && strProgramName!=null) {
           
          /*   String mdtQuery = 'SELECT Core_MDF_Object_API_Field_Name__c, Core_MDF_Sort_Order_Nbr__c, Core_MDF_Picklist_ind__c, Core_MDF_Is_Proposal_Based_Ind__c FROM CCP_Activity_Type_dependent_fields__mdt WHERE Core_MDF_Program_Txt__c =: strProgramName AND Core_MDF_Module__c =: sanitizedObjname AND Core_MDF_Activity_Category_Txt__c =: stractCat AND Core_MDF_Activity_Type_Txt__c =:stractType AND Core_MDF_Activity_Subtype_Txt__c =: stractSubtype';
            if(sanitizedObjname == System.Label.Core_MDF_PFRText && displayHeader == System.Label.Core_MDF_PlannedKPILabel && strPropBasedInd == 'true') {
                mdtQuery = mdtQuery + ' AND Core_MDF_Is_Inactive_For_Activity_Ind__c = true  Order by Core_MDF_Sort_Order_Nbr__c';  //hide addtional KPI fields for IPA proposal based PFRS
            } else if(sanitizedObjname == System.Label.Core_MDF_PFCText) {
                mdtQuery = mdtQuery + ' AND Core_MDF_Is_Inactive_For_Claim_Ind__c = false Order by Core_MDF_Sort_Order_Nbr__c';
            } else if(sanitizedObjname == System.Label.Core_MDF_PFRText) {
                String propStr = '';
                if(strProgramName == 'Intel Partner Alliance'){
                    if(strPropBasedInd == 'true'){
                        propStr = 'Core_MDF_Is_Proposal_Based_Ind__c = ' +true;
                    } else {
                        propStr = 'Core_MDF_Is_Account_Based__c = ' +true;
                    }
                }
                
                if(propStr != '') {
                    mdtQuery = mdtQuery + ' AND Core_MDF_Is_Inactive_For_Activity_Ind__c = false AND '+ propStr + ' Order by Core_MDF_Sort_Order_Nbr__c';
                } else {
                    mdtQuery = mdtQuery + ' AND Core_MDF_Is_Inactive_For_Activity_Ind__c = false  Order by Core_MDF_Sort_Order_Nbr__c';
                }  
                //mdtQuery = mdtQuery + ' AND Core_MDF_Is_Inactive_For_Activity_Ind__c = false  Order by Core_MDF_Sort_Order_Nbr__c';  
            }

           

            
            actDepMdtList = Database.query(mdtQuery);
            
            if(actDepMdtList != null && actDepMdtList.size() > 0) {
                for(CCP_Activity_Type_dependent_fields__mdt kpiVal: actDepMdtList) {
                    if(strProgramName == 'Intel Partner Alliance'){
                        if(kpiVal.Core_MDF_Is_Proposal_Based_Ind__c == Boolean.valueOf(strPropBasedInd)){
                            if(kpiVal.Core_MDF_Picklist_ind__c) {
                                kpimVal.put(kpiVal.Core_MDF_Object_API_Field_Name__c, 'toLabel('+ kpiVal.Core_MDF_Object_API_Field_Name__c +')');
                            } else {
                                kpimVal.put(kpiVal.Core_MDF_Object_API_Field_Name__c, kpiVal.Core_MDF_Object_API_Field_Name__c);    
                            }
                        } 
                    }else{
                        if(kpiVal.Core_MDF_Picklist_ind__c) {
                            kpimVal.put(kpiVal.Core_MDF_Object_API_Field_Name__c, 'toLabel('+ kpiVal.Core_MDF_Object_API_Field_Name__c +')');
                        } else {
                            kpimVal.put(kpiVal.Core_MDF_Object_API_Field_Name__c, kpiVal.Core_MDF_Object_API_Field_Name__c);    
                        }
                    } 
                }
            }  */


            String categoryName = 'KPI';
            String whereClause = '';
            if(multiSubType != '' && multiSubType != null){
                whereClause = 'Core_MDF_Program__c = \'' + strProgramName + '\' ' + 
                                    'AND Core_MDF_Field_1_txt__c = \'' + stractCat + '\' ' + 
                                    'AND Core_MDF_Field_2_txt__c = \'' + stractType + '\' ' + 
                                    'AND (Core_MDF_Field_3_txt__c IN ' + multiSubType + ' OR Core_MDF_Field_3_txt__c = NULL) ' +
                                    'AND Core_MDF_Sub_Category__c = \'' + sanitizedObjname + '\' ' + 
                                    'AND Core_MDF_Category__c = \'' + categoryName + '\'';


            }
            else{
                whereClause = 'Core_MDF_Program__c = \'' + strProgramName + '\' ' + 
                                'AND Core_MDF_Field_1_txt__c = \'' + stractCat + '\' ' + 
                                'AND Core_MDF_Field_2_txt__c = \'' + stractType + '\' ' + 
                                'AND (Core_MDF_Field_3_txt__c = \'' + stractSubtype + '\' OR Core_MDF_Field_3_txt__c = NULL) ' + 
                                'AND Core_MDF_Sub_Category__c = \'' + sanitizedObjname + '\' ' + 
                                'AND Core_MDF_Category__c = \'' + categoryName + '\'';



            }
            String propStr = '';
            //Avoid Deeply Nested IF Statements
            // if(strProgramName == Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM){
            //     if(strPropBasedInd == 'true'){
            //         propStr = 'Core_MDF_Checkbox_Field_2_Ind__c = ' +true;
            //     } else {
            //         propStr = 'Core_MDF_Checkbox_Field_5_Ind__c = ' +true;
            //     }
            // }
            Boolean isPfrIpaProgram = (strProgramName == Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM);
            Boolean isPropBased = (strPropBasedInd == 'true');
            if (isPfrIpaProgram) {
                String fieldName = isPropBased 
                    ? 'Core_MDF_Checkbox_Field_2_Ind__c' 
                    : 'Core_MDF_Checkbox_Field_5_Ind__c';
                propStr = fieldName + ' = ' + true;
            }
            if(sanitizedObjname == System.Label.Core_MDF_PFRText && displayHeader == System.Label.Core_MDF_PlannedKPILabel && strPropBasedInd == 'true') {
                whereClause = whereClause + ' AND Core_MDF_Is_Active_Ind__c = True Order by Core_MDF_Sort_Order_Nbr__c';
            }
                //Avoid Deeply Nested IF Statements 
             //} else if(sanitizedObjname == System.Label.Core_MDF_PFCText) {
            //     if(propStr != '') {
            //         whereClause = whereClause + ' AND Core_MDF_Checkbox_Field_4_Ind__c = false AND '+ propStr + ' AND Core_MDF_Is_Active_Ind__c = True Order by Core_MDF_Sort_Order_Nbr__c';
            //     } else {
            //         whereClause = whereClause + ' AND Core_MDF_Checkbox_Field_4_Ind__c = false AND Core_MDF_Is_Active_Ind__c = True Order by Core_MDF_Sort_Order_Nbr__c';
            //     }  

            //     //whereClause = whereClause + ' AND Core_MDF_Is_Inactive_For_Claim_Ind__c = false Order by Core_MDF_Sort_Order_Nbr__c';
            // } else if(sanitizedObjname == System.Label.Core_MDF_PFRText) {                
            //     if(propStr != '') {
            //         whereClause = whereClause + ' AND Core_MDF_Checkbox_Field_3_Ind__c = false AND '+ propStr + ' AND Core_MDF_Is_Active_Ind__c = True Order by Core_MDF_Sort_Order_Nbr__c';
            //     } else {
            //         whereClause = whereClause + ' AND Core_MDF_Checkbox_Field_3_Ind__c = false AND Core_MDF_Is_Active_Ind__c = True Order by Core_MDF_Sort_Order_Nbr__c';
            //     }  
            //     //mdtQuery = mdtQuery + ' AND Core_MDF_Is_Inactive_For_Activity_Ind__c = false  Order by Core_MDF_Sort_Order_Nbr__c';  
            // }
            else if (sanitizedObjname == System.Label.Core_MDF_PFCText || sanitizedObjname == System.Label.Core_MDF_PFRText) {
                Boolean isPFC = sanitizedObjname == System.Label.Core_MDF_PFCText;
                String checkboxField = isPFC ? 'Core_MDF_Checkbox_Field_4_Ind__c' : 'Core_MDF_Checkbox_Field_3_Ind__c';
                
                whereClause += ' AND ' + checkboxField + ' = false';
                whereClause += (propStr != '' ? ' AND ' + propStr : '');
                whereClause += ' AND Core_MDF_Is_Active_Ind__c = True Order by Core_MDF_Sort_Order_Nbr__c';
            }

    
            System.debug('WHERE CLAUSE IN KPI Detail Page----'+ whereClause);
            List<Core_MDF_CCP_Custom_Metadata_Utility__c> kpiVals = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecords(whereClause);
            

            if(kpiVals != null && kpiVals.size() > 0) {
                for(Core_MDF_CCP_Custom_Metadata_Utility__c kpiVal: kpiVals) {
                        //Avoid Deeply Nested IF Statements
                        // if(kpiVal.Core_MDF_Checkbox_Field_1_Ind__c) {
                        //     kpimVal.put(kpiVal.Core_MDF_Field_4_txt__c, 'toLabel('+ kpiVal.Core_MDF_Field_4_txt__c +')');
                        // } else {
                        //     kpimVal.put(kpiVal.Core_MDF_Field_4_txt__c, kpiVal.Core_MDF_Field_4_txt__c);    
                        // }
                        String fieldValue = kpiVal.Core_MDF_Field_4_txt__c;
                        String mapValue = kpiVal.Core_MDF_Checkbox_Field_1_Ind__c
                            ? 'toLabel(' + fieldValue + ')'
                            : fieldValue;
                        kpimVal.put(fieldValue, mapValue);
                }
            }
        }
      
        return kpimVal;  

    }
    
    /****************************************************************************************************************************************
    Method Name:                                   fetchsavedValues
    Description:                                   Fetch KPI saved values for PartnerFundRequest/PartnerFundClaim Object
    Added By:                                      Vivek K - 16-Feb-2020
    Modified By:                  Date:            Changes: 
    Vivek K                      02/16/2020        Created.
    *****************************************************************************************************************************************/ 
    private static SObject fetchsavedValues(List<String> lstKPImdata) {
        SObject pfObj;
        String strfield = '';
        String strQuery = '';            
        strfield = String.join(lstKPImdata,',');           
        strQuery = 'SELECT id, ' + strfield + ' FROM ' + sanitizedObjname + ' WHERE Id=: sanitizeRecdId';
        pfObj = Database.query(strQuery); 
        return pfObj;
    } 
    
    /****************************************************************************************************************************************
    Method Name:                                   getActClaimId
    Description:                                   Check for Claim object and return Act/Claim ID
    Added By:                                      Vivek K - 16-Feb-2020
    Modified By:                  Date:            Changes: 
    Vivek K                      02/16/2020        Created.
    *****************************************************************************************************************************************/ 
    private static String getActClaimId() {
        String returnId;
        Schema.SObjectType objtype;
        
        if(String.isNotBlank(sanitizeRecdId)) {
            objtype = ((Id)sanitizeRecdId).getSobjectType();
        }      
        
        if(objtype != null && objtype == Case.SobjectType) {
            String strQuery = 'select id,Core_MDF_Activity_ID__c, Core_MDF_Claim_ID__c from case where id=:sanitizeRecdId';
            Case pfObj = Database.query(strQuery);
            //Avoid Deeply Nested IF Statements
            //if(pfObj!=null) {
                if(pfObj!=null && sanitizedObjname == System.Label.Core_MDF_PFRText) {           
                    returnId = pfObj.Core_MDF_Activity_ID__c;                             
                }
                if(pfObj!=null && sanitizedObjname == System.Label.Core_MDF_PFCText) {
                    returnId = pfObj.Core_MDF_Claim_ID__c; 
                }
            //}  
        }
        return String.isBlank(returnId)?sanitizeRecdId:returnId;               
    } 
    
    /****************************************************************************************************************************************
    Method Name:                                   getActClaimId
    Description:                                   Check for Claim object and return Act/Claim ID
    Added By:                                      Vivek K - 06-Jul-2020
    Modified By:                  Date:            Changes: 
    Vivek K                      07/06/2020        Created.
    *****************************************************************************************************************************************/
    private static String fetchLabel(String displayHeader) {   
        String userLang = UserInfo.getLanguage();
        String strLabel = '';
        
        if(String.isNotBlank(displayHeader)) {
            //Get the user language.
            userLang = (userLang != null && languages.contains(userLang)) ? userLang : 'en_US';
            // Highlight: Unused Local Variable - 14285
            // String colToBeQueried = 'Core_MDF_'+userLang+'_cd__c';
            Core_MDF_History_Header_Translation__mdt[] langTrans;
            String query = 'Select  toLabel(Core_MDF_History_Header_Translation_nm__c) '/*+String.escapeSingleQuotes(colToBeQueried)*/+ ' from Core_MDF_History_Header_Translation__mdt where DeveloperName=\''+String.escapeSingleQuotes(displayHeader)+'\'';
            String v1 = query;
            langTrans=Database.query(v1);
            
            if(langTrans != null && langTrans.size() > 0 /*&& langTrans[0].get(colToBeQueried) != null*/) {
                //strLabel = String.valueOf(langTrans[0].get(colToBeQueried)).trim();
                strLabel = String.valueOf(langTrans[0].Core_MDF_History_Header_Translation_nm__c);
            }
            
        }
        return strLabel;
    }
      // ATHR Avoid long parameter lists - US 14285 - Indira
    // Wrapper to avoid long parameter list for fetchMetadata
    private class FetchMetadataContext {
        public String actCat;
        public String actType;
        public String actSubtype;
        public String programName;
        public String propBasedInd;
        public String displayHeader;

        public FetchMetadataContext(String actCat, String actType, String actSubtype,
                                    String programName, String propBasedInd, String displayHeader) {
            this.actCat = actCat;
            this.actType = actType;
            this.actSubtype = actSubtype;
            this.programName = programName;
            this.propBasedInd = propBasedInd;
            this.displayHeader = displayHeader;
        }
    }
    
 // Start: unhandeled exceptions, added by : Shravani

    /****************************************************************************************************************************************
    Method Name:        logErrorImperative
    Description:        Logs client-side errors via an imperative call. Introduced to handle logging outside 
                        getKPIvalues(), as it is cacheable and does not allow DML operations.
                        Unhandeled exception fix.

    Created By:        Shravani
    Created Date:      19/03/2026
    ****************************************************************************************************************************************/
    @AuraEnabled
    public static void logErrorImperative(String errorMessage, String objectApiName) {
        if(String.isBlank(errorMessage)) return;
        Core_MDF_CCP_UtilityClass.logErrorAsNormal(errorMessage,objectApiName);
    }
 // End: unhandeled exceptions, added by : Shravani

    public class KPIWrapper {
        @AuraEnabled public Map<String,String> datamap = new Map<String,String>();
        @AuraEnabled public String displabel = '';
        @AuraEnabled public Map<String,String> helpTextMap = new Map<String,String>();
        @AuraEnabled public Map<String,String> fldLabelToAPINameMap = new Map<String,String>();
    }

}