/***************************************************************************************************** 
Class Name :    Core_Intel_customPicklistController
Description:    Sever side controller for Core_Intel_customPicklist component
Added By   :    Accenture - AS 
Modified By:                      Date:07/25/2018                     Changes:None  
******************************************************************************************************/
public with sharing class Core_Intel_customPicklistController {
 
    /***************************************************************************************************** 
    Method Name :   getselectOptions
    Description :   Custom method to get picklist values
    Added By    :   Accenture - AS 
    Modified By :                      Date:07/25/2018                     Changes:None                               
    ******************************************************************************************************/
    @AuraEnabled
    public static Map < String, String > getselectOptions(String objObject, string fld, string parId, string parfldname,string recordTypeName,String sctrlvalue) {
        // Stores All the Values from Campaign
        List < String > allOpts = new List < String > ();
        //Returns as map<api, label>
        Map<String, String> mapAllOpts = new Map <String, String>();
        // Stores the Values from partner fund request
        Map<String,String> mapValueLabel = new Map<String,String>();
        String sanitizedparFldName = String.escapeSingleQuotes(parfldname);
        
        //Getting associated campaign from the PFR
        Id pId = String.escapeSingleQuotes(parId);
        String sobjectType = pId.getSObjectType().getDescribe().getName();
        String squery = 'SELECT Id, ' + sanitizedparFldName + ' FROM ' + String.escapeSingleQuotes(sobjectType) + ' WHERE Id = :pId';
        sObject sobj = database.query(squery);
        
        if(sobj != NULL && sobj.get(sanitizedparFldName) != null){
                
            String ofldvalue = (String) sobj.get(sanitizedparFldName);
            //String ofIdlabel = (String) tolabel(sobj.sanitizedparFldName);
            List<String> ofldvaluelst = ofldvalue.split(';');
            //Getting all the value of the field from the partner fund request object
            if( !ofldvaluelst.isEmpty()){
                // Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objObject);
                Schema.SObjectType objectType;
                if(objObject=='PartnerFundRequest'){
                    objectType = PartnerFundRequest.SObjectType;
                }
                else{
                    objectType = Schema.getGlobalDescribe().get(objObject);
                }
                Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
                Schema.SobjectField theField = fieldMap.get(fld);
                Schema.DescribeFieldResult fieldResult = theField.getDescribe();
                List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry v : values) {
                    mapValueLabel.put(v.getValue(),v.getLabel());        
                }
            }
            //Constructing map of api name and value
            for(String ostrvalue : ofldvaluelst){
                if(mapValueLabel.get(ostrvalue) != null ){
                    mapAllOpts.put(ostrvalue,mapValueLabel.get(ostrvalue));
                }
            }
        }
	return mapAllOpts; 
    }

    /***************************************************************************************************** 
    Method Name :   picklistFetcher
    Description :   Method to fetch picklist values from custom object using UI API
    Added By    :   Accenture - VK 
    Modified By :                      Date:08/17/2018                     Changes:None                               
    ******************************************************************************************************/
    
   public static Map<String, Object> picklistFetcher(string recordTypeName){
       Schema.DescribeSObjectResult resSchema = Core_MDF_PFRCustomPicklist__c.sObjectType.getDescribe();
       Map<String,Schema.RecordTypeInfo>  recordTypeInfo = resSchema.getRecordTypeInfosByDeveloperName();
       
       Id devRecordTypeId;
       //Calling Request for UI API Interface
              //if(recordTypeInfo.get(recordTypeName) != null){ 
              	devRecordTypeId = recordTypeInfo.get(recordTypeName).getRecordTypeId();
              //}

       HttpRequest req = new HttpRequest();
       req.setEndpoint('callout:UserInterfaceAPI/'+devRecordTypeId);
       req.setMethod('GET');
       req.setHeader('Content-Type', 'application/json');
       req.setTimeout(120000);
       Http http = new Http();       
       HTTPResponse res = http.send(req);
       String strResponse = res.getBody();
       /*
       String unescapeString;
        // unescapeString = unescapeString.replaceAll('""','"\"');
       
       if(devRecordTypeId =='012g00000003kQBAAY' || devRecordTypeId =='012g00000003kQB'){
           unescapeString = strResponse.unescapeHtml4();
       }
       else{
            unescapeString = strResponse;
       }*/
       Map<String, Object> m =  (Map<String, Object>)JSON.deserializeUntyped(strResponse);
    
       return m;     
    }
    /***************************************************************************************************** 
    Method Name :   customPicklistFetcher
    Description :   Method to fetch picklist values from custom object using UI API
    Added By    :   Accenture 
    Modified By :                      Date:08/17/2018                     Changes:None                               
    ******************************************************************************************************/
    
   public static Map<String, Object> customPicklistFetcher(string recordTypeName){
       Schema.DescribeSObjectResult resSchema = Core_MDF_Custom_Picklist__c.sObjectType.getDescribe();
       Map<String,Schema.RecordTypeInfo>  recordTypeInfo = resSchema.getRecordTypeInfosByDeveloperName();
       Id devRecordTypeId = recordTypeInfo.get(recordTypeName).getRecordTypeId();
       //Calling Request for UI API Interface
       HttpRequest req = new HttpRequest();
       req.setEndpoint('callout:Custom_Picklist_Values/'+devRecordTypeId);
       req.setMethod('GET');
       req.setHeader('Content-Type', 'application/json');
       req.setTimeout(120000);
       Http http = new Http();       
       HTTPResponse res = http.send(req);
       String strResponse = res.getBody();
       Map<String, Object> m =  (Map<String, Object>)JSON.deserializeUntyped(strResponse);
       return m;     
    }    
    
    /***************************************************************************************************** 
    Method Name : fetchIndPartnerCtryPgmMapping
    @return     : Custom Metadata
    @parameters : country
    Description : get the channel partners list for the country from custom meta data
    Added By    : Sridhar
    Modified By :                      Date:08/20/2018                    Changes:None                                
    ******************************************************************************************************/
    @AuraEnabled
    public static List<String> fetchIndPartnerCtryPgmMapping(String ctry,String prgName){
                   
        List<Core_MDF_CP_Countries__c> metaResp= new List<Core_MDF_CP_Countries__c>();
	 Set<String> channelpartnersSet = new Set<String>();
        
        List<string> ctrlst = ctry.split(';');
        String progName = '%' + prgName + '%';
        
        metaResp = [select id,Core_MDF_CP_Name__c,Core_MDF_All_Countries__c,Core_MDF_CP_Country__c,Core_MDF_Is_Applicable_All_Programs_Ind__c,
                    Core_MDF_Program_Name__c from Core_MDF_CP_Countries__c WHERE Core_MDF_Is_Active__c = true AND (Core_MDF_Is_Applicable_All_Programs_Ind__c = true       
					OR (Core_MDF_Is_Applicable_All_Programs_Ind__c = false AND Core_MDF_Program_Name__c LIKE :progName))    
                    AND  (Core_MDF_All_Countries__c  = true  OR  (Core_MDF_All_Countries__c = FALSE AND Core_MDF_CP_Country__c IN: ctrlst)) 
                   ORDER BY Core_MDF_CP_Name__c];
        for (Core_MDF_CP_Countries__c rec : metaResp)
        {
            channelpartnersSet.add(rec.Core_MDF_CP_Name__c);
        }
        List<String> channelpartners = new List<String>(channelpartnersSet);
        return channelpartners;
    }
    /***************************************************************************************************** 
    Method Name : ApitoLabelReference
    @return     : Map<String,string>
    @parameters : objName,fName
    Description : It returns map of picklist label to api values.
    Added By    : Accenture - ashar
    Modified By :                      Date:09/05/2018                    Changes:None                                
    ******************************************************************************************************/
    @AuraEnabled
    public static Map<String,String> apitoLabelReference(String objName, List <String> pfrPiclistField ){
    //Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objName);
    Schema.SObjectType objectType;

    switch on objName {
        when 'PartnerFundRequest' {
            objectType = PartnerFundRequest.SObjectType;
        }
        when 'Core_MDF_Custom_Picklist__c' {
            objectType = Core_MDF_Custom_Picklist__c.SObjectType;
        }
        when else {
            objectType = Schema.getGlobalDescribe().get(objName);
        }
    }
        Map<String,String> mapValueLabel = new Map<String,String>();
        Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        
        List <string> pfrPicField = pfrPiclistField;
        
        // Getting all the picklist value from PFR map<Value, Label> Pair
        for(String field :pfrPicField ){
            Schema.SobjectField theField = fieldMap.get(field);
            Schema.DescribeFieldResult fieldResult = theField.getDescribe();
            List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry v : values) {
                 mapValueLabel.put(v.getValue(),v.getLabel());        
            }   
        }
        
        return mapValueLabel;
    } 
    
    @AuraEnabled
    public static Map<String,String> apitoLabelReferenceCampaign(String objName, List <String> pfrPiclistField ){
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objName);
        Map<String,String> mapValueLabel = new Map<String,String>();
        Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        
        List <string> pfrPicField = pfrPiclistField;
        
        // Getting all the picklist value from PFR map<Value, Label> Pair
        for(String field :pfrPicField ){
            Schema.SobjectField theField = fieldMap.get(field);
            Schema.DescribeFieldResult fieldResult = theField.getDescribe();
            List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry v : values) {
                 mapValueLabel.put(v.getValue()+'-'+field,v.getLabel()); 
	    }   
        }
        
        return mapValueLabel;
    }
}