/**************************************************************************************************
* Apex Class Name   : Core_Utility
* Created Date      : 03 OCT 2014
* Description       : Utility methods to handle generic functions
* 
* Developer             Date        Description
* -------------------------------------------------------------------------------------------------                 
* Srikant Joshi         10/03/2014  Original Version
* Jishad P A            12/12/2014  Updated the sObjectGeoMappingField method to work around 
*                                    Salesforce issue
*Mahesh                 3/29/2019    Added a getPicklistValuesSet method  to fetch the active Lov's from Picklist 
**************************************************************************************************/
public class Core_Utility{
    
    /*
    * Method name  : sObjectGeoMappingField
    * Description  : Matches the Billing state in the accounts and populates Geo/Sub Geo fields 
    * Return Type  : VOID
    * Parameter    : List Trigger.new, MAP Trigger.newmap,MAP Trigger.oldmap,Country field of Sobject
    */
    public static void sObjectGeoMappingField(list<sObject> listNewSObject, map<Id,sObject> mapOldsObject, 
                list<String> countryFields, list <String> stateFields, String sGeoField, String sSubGeoField){
        
        //String Variables to hold the set of new values for Country/State fields
        String sNewCountry;
        String sNewCountryCode;
        String sNewState;
        String sNewStateCode;
        
        //String Variables to hold the set of Old values for Country/State fields
        sObject oOldSObject;
        String sOldCountry;
        String sOldCountryCode;
        String sOldState;
        String sOldStateCode;
        
        // Boolean to hold the reference to check if the country has any state
        boolean bHasValidStates;
        
        //map to hold the reference to the Country State custom setting data
        map<String, Core_Country_Reference__c> mCountryCodeGeoRef = new map<String, Core_Country_Reference__c>();
                    
        //map to hold the reference to the Country State custom setting data
        map<String, Core_Country_Reference__c> mCountryCodeGeoRef1 = new map<String, Core_Country_Reference__c>();
                    
        //Check if the Sobject is of type lead
        boolean bIsLeadOp = Schema.Lead.getSObjectType() == listNewSObject[0].getSobjectType() ? true: false;
        
        // Capture the set of status for which the validation rule must be applicable
        Set<String> setLeadStatuses = new Set<String>{ System.Label.Core_LeadStatusSalesAcceptedLead
                                                    };
        
        //call the function to store the User record    
        Set<String> sProfileName = new Set<String>{}; 
        
        //Get the Profile Name for which the Validation needs to be bypassed
        if(!System.Label.Core_ProfileNameforBypassGeo.contains(';'))
             sProfileName.add(System.Label.Core_ProfileNameforBypassGeo);
        else{//Get the list of Profile Names for which the Validation needs to be bypassed
            for(String sProflname : System.Label.Core_ProfileNameforBypassGeo.split(';'))
                sProfileName.add(sProflname);
        }
        
        //Get the Profile Name of the current User                                     
        Core_Utility.getcurrentUser();                                           
        
        //Returns a map of the data sets defined for the custom setting with ISO Code as keyset.
        for(Core_Country_Reference__c sobjStateRef : Core_Country_Reference__c.getall().values()){
            mCountryCodeGeoRef.put(sobjStateRef.Core_ISO_Code__c,sobjStateRef);
            //Added by Kavyashree HR(Infosys Team) for the US781258
            mCountryCodeGeoRef1.put(sobjStateRef.Name,sobjStateRef);
        }

        // iterate over the new set of records
        for(sObject thisSObj : listNewSObject){
            try{
                sNewCountry = String.valueOf(thisSObj.get(countryFields[0]));
                sNewCountryCode = String.valueOf(thisSObj.get(countryFields[1]));
                sNewState = String.valueOf(thisSObj.get(stateFields[0]));
                sNewStateCode = String.valueOf(thisSObj.get(stateFields[1]));
                
                //Get the field values of the Country / State field of the old set of records
                if(!Trigger.isInsert){
                    oOldSObject = mapOldsObject.get(String.valueOf(thisSObj.get('Id')));
                    sOldCountry = String.valueOf(oOldSObject.get(countryFields[0]));
                    sOldCountryCode = String.valueOf(oOldSObject.get(countryFields[1]));
                    sOldState = String.valueOf(oOldSObject.get(stateFields[0]));
                    sOldStateCode = String.valueOf(oOldSObject.get(stateFields[1]));
                }
                
                // If the operation is insert then enter the loop or if there is any change in the field values
                if(Trigger.isInsert || sNewCountry != sOldCountry || sNewCountryCode != sOldCountryCode
                    || sNewState!=sOldState || sNewStateCode!=sOldStateCode 
                    || (bIsLeadOp && thisSObj.get('Status') != oOldSObject.get('Status'))){
                    
                    if((String.isNotEmpty(sNewCountryCode) && mCountryCodeGeoRef.containskey(sNewCountryCode))
                        || (String.isNotEmpty(sNewCountry) && mCountryCodeGeoRef.containsKey(sNewCountry))){
                        
                        //Set the values of the field using the custom setting Country State reference 
                        // Use the Country Code as primary key to get to the correct data
                        if(mCountryCodeGeoRef.containsKey(sNewCountryCode)){
                            System.debug('------&&'+mCountryCodeGeoRef.get(sNewCountryCode).Core_Geo__c);
                            thisSObj.put(sGeoField, mCountryCodeGeoRef.get(sNewCountryCode).Core_Geo__c);
                            thisSObj.put(sSubGeoField, mCountryCodeGeoRef.get(sNewCountryCode).Core_Sub_Geo__c);
                            bHasValidStates = mCountryCodeGeoRef.get(sNewCountryCode).Core_Has_States__c;
                        // Use the Country as primary key to get to the correct data   
                        } else if(mCountryCodeGeoRef.containsKey(sNewCountry)){
                            thisSObj.put(sGeoField, mCountryCodeGeoRef.get(sNewCountry).Core_Geo__c);
                            thisSObj.put(sSubGeoField, mCountryCodeGeoRef.get(sNewCountry).Core_Sub_Geo__c);
                            bHasValidStates = mCountryCodeGeoRef.get(sNewCountry).Core_Has_States__c;
                        }
                        
                        //Validation to throw an an addError if the state field is not present
                        if(sNewStateCode == NULL && sNewState==NULL && bHasValidStates && !sProfileName.contains(currentUser.Profile.Name)){
                            //If the Object is NOT lead, throw the exception if the state is NOT populated 
                            if(!bIsLeadOp){
                                thisSObj.addError(system.label.Core_State_Validation_Error);
                            //If the Object is lead, throw the exception if the state is NOT populated ONLY for 2 statuses
                            } else if(setLeadStatuses.contains(String.valueOf(thisSObj.get('Status')))){
                                thisSObj.addError(system.label.Core_State_Validation_Error);
                            }
                        } 
                    }
                    // If both the above condition are not met, then populate the Geo/Sub geo fields as blank
                    else{
                        //Assign empty value if the combination is NOT present
                        thisSObj.put(sGeoField,NULL);
                        thisSObj.put(sSubGeoField,NULL); 
                    }
                         if(String.isNotEmpty(sNewCountry)){
                         // Additional conditions are added by Kavyashree HR(Infosys Team) for the US781258
                         if(mCountryCodeGeoRef1.containsKey(sNewCountry) && bIsLeadOp && thisSObj.get('Core_Prospect__c')!= null && Trigger.isInsert){
                            thisSObj.put(sGeoField, mCountryCodeGeoRef1.get(sNewCountry).Core_Geo__c);
                            thisSObj.put(sSubGeoField, mCountryCodeGeoRef1.get(sNewCountry).Core_Sub_Geo__c);
                        }
                         }
                }               
            } catch(Exception e){
                //If there is any exception, append it to the list of sobject records
                thisSObj.addError(System.Label.Core_Exception+e.getMessage());       
            }
        }
    }
    
    
    public static Map<String, Schema.SObjectField> getAllFields(String sObjectName){
        
        if(Schema.getGlobalDescribe().containsKey(sObjectName)){
            return (Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap());
        }
            
        return new Map<String, Schema.SObjectField>();
    }
    
   /*
    * Method name  : 
    * Description  : 
    * Return Type  : 
    * Parameter    : 
    */
    public Static String buildQuery(String sObjectName, List<String> lstFields){
        String sQuery = 'SELECT ';
        
        if(Schema.getGlobalDescribe().containsKey(sObjectName) && !lstFields.isEmpty()){
           for(String sFields : lstFields) 
               sQuery  += sFields + ',';
        }
        
        sQuery = sQuery.subString(0,sQuery.length()-1);
        sQuery += ' FROM ' + sObjectName + ' '; 
        
        return sQuery;
    }
    
    /*
    * Method name  : 
    * Description  : 
    * Return Type  : 
    * Parameter    : 
    */
    public static String replaceSpecialCharacWithUnderscore(String sStringToBeReplaced){
        // Exception Handling fix: Regex too complicated
        try
        {
        //Run the loop for the special characters
        for(String sSpecialCharc : System.Label.Core_SpecialCharacter.Split(';')){
            //if(String.isNotBlank(sStringToBeReplaced))
                sStringToBeReplaced = sStringToBeReplaced.replace(sSpecialCharc,'_');  
        }
        sStringToBeReplaced = sStringToBeReplaced.replace('__','_');
        sStringToBeReplaced = sStringToBeReplaced.removeEnd('_');
        
        return sStringToBeReplaced;
    }
        catch(exception ex)
        {
            system.debug('Unsucessful send email :::: ' + ex.getMessage());
            
        }        
        return null;         
    }
    
    //Variable to store the User record
    private static User currentUser{get;set;}
    
    /*
    * Method name  : getcurrentUser
    * Description  : Get the current user record attribute
    * Return Type  : User
    * Parameter    : NONE
    */
    public static User getcurrentUser(){
        if(currentUser!=null){
            return currentUser;
        } 
        else{
            List<User> userList = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
            if(userList.size() > 0) {
                currentUser = userList[0];
            }
            return null;
        }
    }
    
    /***************************************************************************************************
    Method Name:  readFieldSet
    Method Type: Utility Method 
    Version     : 1.0 
    Created Date: 14 Oct 2015
    Function    : Generic method to read field sets. 
    Input Parameters: Fieldset Name and Object api name
    Output Parameters: Fields 
    Description:   This is a generic method that takes field api name and object api name and returns the fields.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/14/2015              Created
    ****************************************************************************************************/        
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectApiName){
        if(fieldSetName==null || objectApiName==null){
            return null;
        }
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectApiName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
    }
    
    
        //**************************** Sent email to contacts ************************/
    public static void sendEmail(set<String> toAddresses, id templateId) 
    {  
        contact c = new contact();
    if(toaddresses!=null){
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if(Contact.SObjectType.getDescribe().isAccessible()){
        c=[select id, name from contact limit 1];
        }
        list<string> ls=new list<string>();
        
        for(string s:toaddresses)
             ls.add(s);
    email.setToAddresses(ls);
    email.setTemplateId(templateId);  
    email.setTargetObjectID(c.id);
    system.debug(LoggingLevel.INFO,'Email to:' + toAddresses + ' templateId:' + templateId);    
    try {        
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});        
    return;
    }    
    catch (EmailException e)
    {
    system.debug('Unsucessful send email :::: ' + e.getMessage());
    }
    }
    }
    
    
   /***************************************************************************************************
    Method Name:  SOSLQueryStringValidator
    Method Type: Utility Method 
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : Used to handle reserved characters for SOSL query.
    Input Parameters: Query String
    Output Parameters: Valid Query String
    Description:   This function is used to handle reserved characters of SOSL query. 
                   The reserved characters that are handled are ?, &, |,!,{,},[,],(,),^,~,*,:,+,-,/,//,\,\\,"
                   Function takes a string literal containing above characters as an input and adds escape character so that SOSL query runs without any issue. 
    Used in     : Across IPS
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/09/2015              Created
    ****************************************************************************************************/  
    public static String SOSLQueryStringValidator(string Checkinputstring){
        string CheckCharacter = Checkinputstring; 
        string FinalQueryString;
        if(checkinputString==null){
            return null;
        }
        for(integer i = 0; i < CheckCharacter.length(); i++) {
            if(CheckCharacter.substring(i, i + 1).contains('?')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }
            }
            else if(CheckCharacter.substring(i, i + 1).contains('&')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }
            }
            else if(CheckCharacter.substring(i, i + 1).contains('|')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains('!')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains('{')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains('}')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains('[')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains(']')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }           
            }
            else if(CheckCharacter.substring(i, i + 1).contains('(')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains(')')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains('^')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains('~')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains('*')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains(':')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains('+')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains('-')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains('"')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains('/')){
                if(i==0){
                    FinalQueryString = '//' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '//' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains('\\')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else if(CheckCharacter.substring(i, i + 1).contains('\'')){
                if(i==0){
                    FinalQueryString = '\\' +CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + '\\' +CheckCharacter.substring(i, i + 1);
                }               
            }
            else{
                if(i==0){
                    FinalQueryString = CheckCharacter.substring(i, i + 1);
                }
                else{
                    FinalQueryString = FinalQueryString + CheckCharacter.substring(i, i + 1);
                }
            }
        }
        return FinalQueryString;            
    }
    
    /***************************************************************************************************
    Method Name:  replaceSpecialChar 
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 17 Nov 2015
    Function    : Returns replaced String.
    Input Parameters: String
    Output Parameters: String
    Description: Returns the replaced String.
    Used in     : in Case and Case RTF
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya            Nov/17/2015                Created
    * JRK                      Nov/18/2015                Added missing special characters for replacement
    ****************************************************************************************************/
    public static String replaceSpecialChar(String str){    
 
        str = str.replaceAll('&#32;',' ');
        str = str.replaceAll('&#3;3;','!');
        str = str.replaceAll('&#34;','"');
        str = str.replaceAll('&#35;','#');
        str = str.replaceAll('&#36;','$');
        str = str.replaceAll('&#37;','%');
        str = str.replaceAll('&#38;','&');
        str = str.replaceAll('&#39;','\'');
        str = str.replaceAll('&#40;','(');
        str = str.replaceAll('&#41;',')');
        str = str.replaceAll('&#42;','*');
        str = str.replaceAll('&#43;','+');
        str = str.replaceAll('&#44;',',');
        str = str.replaceAll('&#45;','-');
        str = str.replaceAll('&#46;','.');
        str = str.replaceAll('&#47;','/');
        str = str.replaceAll('&#58;',':');
        str = str.replaceAll('&#59;',';');
        str = str.replaceAll('&#60;','<');
        str = str.replaceAll('&#61;','=');
        str = str.replaceAll('&#62;','>');
        str = str.replaceAll('&#63;','?');
        str = str.replaceAll('&#64;','@');
        str = str.replaceAll('&#91;','[');
        str = str.replaceAll('&#92;','\\');
        str = str.replaceAll('&#93;',']');
        str = str.replaceAll('&#94;','^');
        str = str.replaceAll('&#95;','_');
        str = str.replaceAll('&#96;','`');
        str = str.replaceAll('&#123;','{');
        str = str.replaceAll('&#124;','|');
        str = str.replaceAll('&#125;','}');
        str = str.replaceAll('&#126;','~');
        str = str.replaceAll('&#8211;','–');
        str = str.replaceAll('&#8212;','—');
        str = str.replaceAll('&#8216;','‘');
        str = str.replaceAll('&#8217;','’');
        str = str.replaceAll('&#09;','/r/r/r');
        str = str.replaceAll('&quot;','"');
        str = str.replaceAll('&amp;','&');
        str = str.replaceAll('&nbsp;','');
        str = str.replaceAll('&#174;;','®');
        str = str.replaceAll('&#8482;','™');
        str = str.replaceAll('&#169;','©'); 
        str = str.replaceAll('&gt;','>');
        str = str.replaceAll('&lt;','<');     
        return str;  
    }
    
    /***************************************************************************************************
    Method Name:  replaceHtmlTags
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 17 Nov 2015
    Function    : Returns replaced String with the HTML tags replaced.
    Input Parameters: String
    Output Parameters: String
    Description: Returns the replaced String.
    Used in     : in Case and Case RTF
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK            Nov/17/2015                Created
    ****************************************************************************************************/
    public static String replaceHtmlTagsCase(String str){     
        str = str.unescapeHTML4();
        str = str.replaceAll('<li>','\n');
        str = str.replaceAll('</li>','');
        str = str.replaceAll('<br>','');
        str = str.replaceAll('<p>','\n');
        str = str.replaceAll('</p>','\n');
        str = str.replaceAll('<div>','');
        str = str.replaceAll('</div>','');   
        str = str.replaceAll('<[^>]+>',' ');       
        return str;  
    }
    
    /***************************************************************************************************
    Method Name:  replaceHtmlTags
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 17 Nov 2015
    Function    : Returns replaced String with the HTML tags replaced.
    Input Parameters: String
    Output Parameters: String
    Description: Returns the replaced String.
    Used in     : in Case and Case RTF
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK            Nov/17/2015                Created
    ****************************************************************************************************/
    public static String replaceHtmlTags(String str){     
        str = str.unescapeHTML4();
        str = str.replaceAll('<li>','\n');
        str = str.replaceAll('</li>','');
        str = str.replaceAll('<br>','');
        str = str.replaceAll('<p>','\n');
        str = str.replaceAll('</p>','\n');
        str = str.replaceAll('<div>','');
        str = str.replaceAll('</div>','');   
        str = str.replaceAll('<[^>]+>',' ');       
        return str;  
    }
    
    /***************************************************************************************************
    Method Name:  replaceHtmlTags
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 17 Nov 2015
    Function    : Returns replaced String with the HTML tags replaced.
    Input Parameters: String
    Output Parameters: String
    Description: Returns the replaced String.
    Used in     : in Case and Case RTF
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK            Nov/17/2015                Created
    * Gourav       Feb16/2018               Modified to address RTF for Integration
    * Sumukh       March 5th/2018           Added method to diffrenciate the partner user for US - 83924
    * Sumukh       January 14th 2019        Added Logic for US244578 - To determine SOA permission set for Data ops user
    ****************************************************************************************************/
    public static boolean isLoggeInUserMigrationUser=false;
    
    public static String addBreaktags(String str){
        isLoggeInUserMigrationUser = Core_IPS_CaseTriggerHandler.isMigrationUser(string.valueof(userinfo.getuserId()));
        system.debug('coming in here test#####');
        str = str.replaceAll('\n','<br>');
        //By Gourav: For RTF
        boolean isLoggeInUserIntegrationUser = Core_IPS_Case_Comments_Handler.isIntegrationUser(string.valueof(userinfo.getuserId()));
        if((isLoggeInUserIntegrationUser && Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for Integ User') != null && Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for Integ User').Core_Feature_Enabled__c) || (!isLoggeInUserIntegrationUser  && !isLoggeInUserMigrationUser) ||(isLoggeInUserMigrationUser && Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for DM') != null && Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for DM').Core_Feature_Enabled__c) )
        str = str.unescapeHTML4();
        system.debug('unescape output>>>>>>>>'+str);      
        return str;  
    }
    
    // Added by sumukh for Partner profile permission check and assign author type
    public static String getPartnerUserType(String Userid){
        String authrType;
        String partUser;
        String prtCust = '0PS1J000000LIlp';//System.Label.Core_IPS_Partner_Customer_Permission_Set;
        String prtDFAE =  System.Label.Core_IPS_Partner_DFAE_Permission_Set;
        List<PermissionSetAssignment> partnersInPermsnSet = new List<PermissionSetAssignment>();
        partnersInPermsnSet = [Select id,PermissionSetId,AssigneeId from PermissionSetAssignment where AssigneeId = :userId and (PermissionSetId =:prtDFAE OR PermissionSetId =:prtCust) LIMIT 1];

          if(partnersInPermsnSet.size()>0 && partnersInPermsnSet !=null){
             for(PermissionSetAssignment permSet: partnersInPermsnSet ){
                 if(String.valueof(permSet.PermissionSetId).substring(0,15).contains(string.valueOf(prtDFAE).substring(0,15))){
                     authrType = 'Partner - DFAE';
                     partUser = 'Partner - DFAE';
                 }else if(String.valueof(permSet.PermissionSetId).substring(0,15).contains(string.valueOf(prtCust).substring(0,15))){
                     authrType = 'Partner';
                     partUser= 'Partner';
                 }
             }
         }
        return authrType +';'+ partUser;
    }
    
    // added by sumukh for US244578
    public static String isSupOrgAdmPermUser(String Userid){
       String authrType;
       String soaUser =  System.Label.Core_IPS_SupportOrgAdmin_Permission_Set;
       List<PermissionSetAssignment> soaUserPermSet= new List<PermissionSetAssignment>();
       soaUserPermSet = [Select id,PermissionSetId,AssigneeId from PermissionSetAssignment where AssigneeId = :userId and (PermissionSetId =:soaUser) LIMIT 1];

        if(soaUserPermSet !=null && soaUserPermSet.size()>0){
                     authrType = 'Agent';
              }else {
                     authrType = 'FAE';}
    return authrType ;
   } // end by sumukh for US244578
    
    /***************************************************************************************************
    Method Name:  replaceHtmlTags
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 17 Nov 2015
    Function    : Returns replaced String with the HTML tags replaced.
    Input Parameters: String
    Output Parameters: String
    Description: Returns the replaced String.
    Used in     : in Case and Case RTF
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK            Nov/17/2015                Created
    ****************************************************************************************************/
    public static String substituteHTMLTags(String str){     
        List<Core_IPS_RTF2TxtHTMLTagConversionMap__c> rtf2HTMLsettings = Core_IPS_RTF2TxtHTMLTagConversionMap__c.getall().values();
        for(Core_IPS_RTF2TxtHTMLTagConversionMap__c rtf2HtmlSetting:rtf2HTMLsettings){
            system.debug('entering ***');
            str = str.replaceAll(rtf2HtmlSetting.ReplacedTag__c,rtf2HtmlSetting.Core_IPS_ReplaceWith__c);
            system.debug('1st op>>>>>>>>>>>>>>'+str);
        }
        
        return str;  
    }
    /***************************************************************************************************
    Method Name:  replaceHtmlTags
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 17 Nov 2015
    Function    : Returns replaced String with the HTML tags replaced.
    Input Parameters: String
    Output Parameters: String
    Description: Returns the replaced String.
    Used in     : in Case and Case RTF
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK            Nov/17/2015                Created
    ****************************************************************************************************/
    
    public static String stripandunescapeHtmlTags(String str){     
        isLoggeInUserMigrationUser = Core_IPS_CaseTriggerHandler.isMigrationUser(string.valueof(userinfo.getuserId()));
        //By Gourav: For  Integration RTF
        boolean isLoggeInUserIntegrationUser = Core_IPS_Case_Comments_Handler.isIntegrationUser(string.valueof(userinfo.getuserId()));
        if((isLoggeInUserIntegrationUser && Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for Integ User') != null && Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for Integ User').Core_Feature_Enabled__c) || (!isLoggeInUserIntegrationUser  && !isLoggeInUserMigrationUser) ||(isLoggeInUserMigrationUser && Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for DM') != null && Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for DM').Core_Feature_Enabled__c) )
        str = str.unescapeHTML4(); 
       // if(!isLoggeInUserMigrationUser){
            str = str.striphtmlTags();//this should not be run for dm profile
       // }  
        system.debug('2nd opt>>>>>>>>>>'+str);
        return str;  
    }     
    
    /***************************************************************************************************
    Method Name:  doSort
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 06 Jan 2016
    Function    : Returns None.
    Input Parameters: List of SelectOptions and Enum Variable
    Output Parameters: None
    Description: Sort the SelectOption List.
    Used in     : Anywhere we want to sort the SelectOption.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya            Jan/06/2015                Created
    ****************************************************************************************************/
    public enum FieldToSort {
        Label, Value
    }
    public static void doSort(List<Selectoption> opts, FieldToSort sortField, String option) {
        
        Map<String, Selectoption> mapping = new Map<String, Selectoption>();
        // Suffix to avoid duplicate values like same labels or values are in inbound list 
        Integer suffix = 1;
        for (Selectoption opt : opts) {
            if (sortField!=null && sortField == FieldToSort.Label) {
                mapping.put(    // Done this cryptic to save scriptlines, if this loop executes 10000 times
                                // it would every script statement would add 1, so 3 would lead to 30000.
                             (opt.getLabel() + suffix++), // Key using Label + Suffix Counter  
                             opt);   
            } else {
                mapping.put(    
                             (opt.getValue() + suffix++), // Key using Label + Suffix Counter  
                             opt);   
            }
        }
        
        List<String> sortKeys = new List<String>();
        sortKeys.addAll(mapping.keySet());
        sortKeys.sort();
        // clear the original collection to rebuilt it
        opts.clear();
        if(option <> null && option.length() > 0)
            opts.add(new Selectoption('',option));
        for (String key : sortKeys) {
            opts.add(mapping.get(key));
        }
    }
    
    /***************************************************************************************************
    Method Name:  customSingleton
    Method Type: Utility Method 
    Version     : 1.0 
    Created Date: 23 Mar 2016
    Function    : Returns List of sobject.
    Input Parameters: New Query String, Old Query String and List of SObject
    Output Parameters: List<Sobject>
    Description: return the list of sobject.
    Used in     : Anywhere we want to enforce the custom singleton.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya            Mar/23/2016                Created
    ****************************************************************************************************/
    /*public static List<SObject> customSingleton(String newQuery, String oldQuery, List<SObject> result){
        if((oldQuery == '') || (newQuery <> '' && oldQuery <> '' && newQuery <> oldQuery)){
            return database.query(newQuery);
        }else{
            return result;
        }        
    }*/
    public static Boolean executeQuery(List<String> newIds, List<String> oldIds){
        if(Core_Utility.idsToString(newIds) <> Core_Utility.idsToString(oldIds)){
            return true;
        }else{
            return false;
        }        
    }
    /***************************************************************************************************
    Method Name: idsToString
    Method Type: Utility Method 
    Version     : 1.0 
    Created Date: 23 Mar 2016
    Function    : Returns List of sobject.
    Input Parameters: New Query String, Old Query String and List of SObject
    Output Parameters: List<Sobject>
    Description: return the list of sobject.
    Used in     : Anywhere we want to enforce the custom singleton.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya            Mar/23/2016                Created
    ****************************************************************************************************/
    public static String idsToString(List<String> strIds){
        String str='';
        if(strIds <> null && strIds.size() > 0){
            strIds.sort();
            for(String strId:strIds){
                str = str+ '\'' + strId + '\',';                
            }                     
            if(str <> ''){
                str = str.substring(0,str.length()-1);
            }               
        }        
        return str;
    }
    
    /*String xmlString = '<books><book>My Book</book><book>Your Book</book></books>';
    XmlStreamReader xsr = new XmlStreamReader(xmlString);*/
   /***************************************************************************************************
    Method Name:  removeImageTag
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 18 May 2016
    Function    : Returns replaced String with out the Image tag and includes all other html tags.
    Input Parameters: String
    Output Parameters: String
    Description: Returns the replaced String.
    Used in     : in Case Public and Prive comment RTF fields
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Kishore Chandolu            May/18/2016                Created
    * Brian Matthews              May-23-2016            Null check added.    
    ****************************************************************************************************/
    public static String removeImageTag(String str){     
        
        if (str == NULL)
            return str;
        
        // Regular expression to remove the image tag in the given string as parameter.
        str = str.replaceAll('<img[^>]+>','');       
        return str;  

    }
    
       /*
    * Method name  : getPicklistValuesSet
    * Description  : Describe call to get all the active LOVs for an object/field  
    * Return Type  : Set<String>
    * Parameter    : List Trigger.new, MAP Trigger.newmap,MAP Trigger.oldmap,Country field of Sobject
    */
    public static Set<String> getPicklistValuesSet(String objectAPI, String fieldAPI) {
        Schema.DescribeSObjectResult[] descResultsList = Schema.describeSObjects(
                new String[]{
                        objectAPI
                });
        Schema.DescribeSObjectResult descResult = descResultsList[0];
        Schema.SObjectField field = descResult.fields.getMap().get(fieldAPI);
        Schema.DescribeFieldResult dFieldResult = field.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = dFieldResult.getPicklistValues();
        
        Set<String> activeAllLOV = new Set<String>();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            activeAllLOV.add(picklistEntry.getValue());
        }
        return activeAllLOV;
    }
}