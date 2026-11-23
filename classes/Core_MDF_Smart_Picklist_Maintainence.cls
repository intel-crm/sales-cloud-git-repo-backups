public without sharing class Core_MDF_Smart_Picklist_Maintainence {

 
    /*@AuraEnabled(cacheable=true)
    public static List<Wrapper> getTreeGridData(){
        Set<String> objSet = new Set<String>();
        List<string > result = new List<string >();
 
        
        for(core_MDF_Picklist_Maintainance__mdt obj : [select Core_MDF_Picklist_Maintanance__c from core_MDF_Picklist_Maintainance__mdt order by Core_MDF_Picklist_Maintanance__c ]){
		result.add(obj.Core_MDF_Picklist_Maintanance__c);
	    }
        for(Core_MDF_Smart_Picklist_Maintenance__mdt obj : [Select id,Core_MDF_Object_API_nm__c from Core_MDF_Smart_Picklist_Maintenance__mdt]){
		objSet.add(obj.Core_MDF_Object_API_nm__c);
	    }
        result.addAll(objSet);
        List<Wrapper> returnlist = new List<Wrapper>();
        for( String obj: result )
        {
        if (obj=='Case'||obj == 'Campaign'||obj=='PartnerFundRequest'||obj=='PartnerFundClaim'||obj == 'Core_MDF_Escalation__c'||obj=='PartnerMarketingBudget'||obj == 'Core_MDF_PFRCustomPicklist__c')
           
         
        {
       	List<Schema.RecordTypeInfo> RT = Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfos();
        Wrapper aWraper = new Wrapper() ; 
        Wrapper fWraper = new Wrapper() ;
   		aWraper.name = Schema.getGlobalDescribe().get(obj).getDescribe().getLabel(); //get api name "getname" //get the Name
        aWraper.ConCatname = Schema.getGlobalDescribe().get(obj).getDescribe().getLabel();
        List<Items> rectype = new List<Items>();
        
		rectype = GetRecordType(obj); 
        aWraper.items = rectype;
       	returnlist.add(aWraper);
        }
        }
		return returnlist ;
  	
    }*/
   
    @AuraEnabled(cacheable=true)//fetching the Core_MDF record types based on object
    public Static List<Items> GetRecordType (string ObjName)
    {
        
		
       List<Items> rectyp = new List<Items>();		
        
       for(Schema.RecordTypeInfo RTI : Schema.getGlobalDescribe().get(ObjName).getDescribe().getRecordTypeInfosByName().values())
        {
            if(RTI.getDeveloperName().contains('Core_MDF_'))
            {

             Items RecTypeWrapp = new Items();
             RecTypeWrapp.developerName = RTI.getDeveloperName();
			 RecTypeWrapp.name =  RTI.getName();
             RecTypeWrapp.ConCatname = ObjName+'+'+RTI.getName()+'+'+RTI.getRecordTypeId();
             RecTypeWrapp.items = GetFields(ObjName,RTI.getRecordTypeId());
             rectyp.add(RecTypeWrapp);
        }
         
    }
        return rectyp;
    }
    
   @AuraEnabled(cacheable=true)
    public Static List<Items> GetFields (String ObjName,String Rectype) //Fetchning the picklist fields based on Record type
    {
         Map < String, Schema.SObjectField > fieldMap =  Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
         List<Items> fld = new List<Items>();
        List<Items> fldv = new List<Items>();
                	     for(Schema.SObjectField key:fieldMap.values()){
                             
           				 		Schema.DescribeFieldResult f = key.getDescribe();
           				
            			 		 if(String.valueOf(f.getType()).contains('PICKLIST')){
                                     
             			 		 	 Items FieldTypeWrapp = new Items();
                          			 FieldTypeWrapp.name= f.getLabel();
                                     FieldTypeWrapp.ConCatname= ObjName+'+'+Rectype+'+'+f.getName();
                                     //FieldTypeWrapp.items = GetFieldValues (ObjName,Rectype,f.getName());
                                    // FieldTypeWrapp.items = GetFieldValues ('Case','0121J000000uIJ8QAM','Core_MDF_Brand__c');
						  			 fld.add(FieldTypeWrapp);
                                   
                                     
   }
                             
    }
       return fld;
    }
    
  
   
/****************************************************POC changes - start****************************************************/
/****************************************************************************************************** 
Method Name:        getProgramData
@return  :          List<String> (Program values)
Description:        This method is used to fetch Program values available for selection on UI
Added By:           Accenture - AN - 16/11/2023
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    
    @AuraEnabled
    public static List<String> getProgramData() {
        Set<String> progOptSet = new Set<String>();
        List<String> programOptions = new List<String>(); 
        try{
            for(Core_MDF_Smart_Picklist_Maintenance__mdt  obj : [select Core_MDF_Project_nm__c from Core_MDF_Smart_Picklist_Maintenance__mdt order by Core_MDF_Project_nm__c]){
            progOptSet.add(obj.Core_MDF_Project_nm__c);
            }
            programOptions.addAll(progOptSet);
            system.debug('PROG OPTIONS:'+programOptions);
        }
        catch(Exception e){
            system.debug('Exception is:'+e.getMessage());
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        
        return programOptions;
        
    }

/****************************************************************************************************** 
Method Name:        getObjectData
@return  :          Map<String,String> (Object api name, Object label)
Parameter :         String (Program Name)
Description:        This method is used to fetch Object values available for selection based on Program selection on UI
Added By:           Accenture - AN - 16/11/2023
Modified By:        Date:       Changes: 
*******************************************************************************************************/   
    @AuraEnabled
    public static Map<String, String> getObjectData(String program){
        Map<String, String> objectMap = new Map<String, String>();
        try{
            for(Core_MDF_Smart_Picklist_Maintenance__mdt  obj : [select  Core_MDF_Object_Label_nm__c, Core_MDF_Object_API_nm__c from Core_MDF_Smart_Picklist_Maintenance__mdt where Core_MDF_Project_nm__c =: program order by Core_MDF_Object_Label_nm__c]){
                objectMap.put(obj.Core_MDF_Object_API_nm__c, obj.Core_MDF_Object_Label_nm__c);
	        }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
            
        }
        return objectMap;
    }
/************************************************************************************************************ 
Method Name:        getFieldData
@return  :          Map<String,String> (field api name, field label)
Parameter :         String,String (Object api name, Program name)
Description:        This method is used to fetch all the picklist fields based on Program & Object selection
Added By:           Accenture - AN - 16/11/2023
Modified By:        Date:       Changes: 
*************************************************************************************************************/   
    @AuraEnabled
    public static Map<String, String> getFieldData(String objName, String program){
        Map<String, String> fieldMap = new Map<String, String>();
        try{
            for(Core_MDF_Smart_Picklist_Maintenance__mdt  obj : [select  Core_MDF_PicklistField_Label_txt__c, Core_MDF_PicklistField_APIName_txt__c from Core_MDF_Smart_Picklist_Maintenance__mdt where Core_MDF_Object_API_nm__c =: objName and Core_MDF_Project_nm__c =: program order by Core_MDF_PicklistField_Label_txt__c]){
                fieldMap.put(obj.Core_MDF_PicklistField_APIName_txt__c, obj.Core_MDF_PicklistField_Label_txt__c);
	        }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
            
        }
        return fieldMap;
    }
/************************************************************************************************************ 
Method Name:        getPickListValuesData
@return  :          List<String> (Picklist values)
Parameter :         String, String (Object api name, Field api name)
Description:        This method is used to get picklist values of the field
Added By:           Accenture - AN - 16/11/2023
Modified By:        Date:       Changes: 
*************************************************************************************************************/   
    
    @AuraEnabled
    public static List<String> getPickListValuesData(String objName, String picklistField){
               
       List<String> picklistValues = new List<String>(); 
       try{
	   Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(picklistField).getDescribe();
		//if (fieldResult.isPicklist()) {
         List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
         for (Schema.PicklistEntry entry : entries) {
             //picklistValues.add(entry.getValue());
             picklistValues.add(entry.getLabel());
            }
        //}
            
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
            
        }
        
        return picklistValues;
        
    }
/************************************************************************************************************ 
Method Name:        fieldAttributesDetails
@return  :          fieldDetailsWrapper
Parameter :         String, String, String (Program name, Object api name, Field api name)
Description:        This method is used to get attributes required for fetching/displaying data(Example: Sort, refers Global value set, Global Value Set Name)
Added By:           Accenture - AN - 16/11/2023
Modified By:        Date:       Changes: 
*************************************************************************************************************/   	
    @AuraEnabled
    public static fieldDetailsWrapper fieldAttributesDetails(String program, String objName, String fldName){
        fieldDetailsWrapper fdW = new fieldDetailsWrapper();
        try{
            Core_MDF_Smart_Picklist_Maintenance__mdt mdtRec = [Select Core_MDF_IsLabel_SameAs_APIName_Ind__c,Core_MDF_Sort_Ind__c,Core_MDF_RecordType_TabName_txt__c,Core_MDF_GlobalValueSet_Reference_Ind__c,Core_MDF_GlobalValueSetName_txt__c from Core_MDF_Smart_Picklist_Maintenance__mdt where Core_MDF_Project_nm__c =: program and Core_MDF_Object_API_nm__c =: objName and Core_MDF_PicklistField_APIName_txt__c =:fldName];
            fdW.isLabelNameSameAsAPIName = mdtRec.Core_MDF_IsLabel_SameAs_APIName_Ind__c;
            fdW.sorted = mdtRec.Core_MDF_Sort_Ind__c;
            fdW.recordTypeTabName = mdtRec.Core_MDF_RecordType_TabName_txt__c!= null ? mdtRec.Core_MDF_RecordType_TabName_txt__c:'Picklist Value by RecordType';
            fdW.gvsReferenceInd = mdtRec.Core_MDF_GlobalValueSet_Reference_Ind__c;
            fdW.globalValueSetName = mdtRec.Core_MDF_GlobalValueSetName_txt__c;
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return fdW;
    }
/************************************************************************************************************ 
Method Name:        getDependentfields
@return  :          Map<String,String> (Dependent field api name, Dependent field label)
Parameter :         String, String(Object api name, Field api name)
Description:        This method is used to get dependent fields of the controlling field
Added By:           Accenture - AN - 16/11/2023
Modified By:        Date:       Changes: 
*************************************************************************************************************/   	
    //method to retrive the dependent fields 
    @AuraEnabled
    public static Map<String,String> getDependentfields(String objName, String fldName){
        sObjectField[] deps;
        String[] str;
        Map<String,String> depfldMap = new Map<String,String>();
        try{
            Schema.SobjectField fld = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fldName);
            Map<String,List<String>> dependencies = new Map<String,List<String>>();
            Map<String,String> fieldapitofldLabelMap = new Map<String,String>();
            //for(sObjectField field: sObjectType.Core_MDF_Custom_Picklist__c.fields.getMap().values()) {
            for(sObjectField field: Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().values()){
                DescribeFieldResult res = field.getDescribe();
                fieldapitofldLabelMap.put(String.valueOf(res.getName()),String.valueOf(res.getLabel()));
                if(res.isDependentPicklist()) {
                    //Map<String,String>
                    //Map<String,String> fmap = new Map<String,String>();
                if(dependencies.containskey(String.valueOf(res.getController()))){
                    //fmap.put(res.getName(),res.getLabel());
                    dependencies.get(String.valueOf(res.getController())).add(String.valueOf(res.getName()));
                }
                else{
                    //fmap.put(res.getName(),res.getLabel());
                    dependencies.put(String.valueOf(res.getController()),new List<String> {String.valueOf(res.getName())});
                }
                }
            }
            //sObjectField[] fldDependnecies= dependencies.get(Core_MDF_Custom_Picklist__c.Core_MDF_Controlling_Field_nm__c);
            List<String> fldDependnecies= dependencies.get(fldName);
            List<String> dependentFldList = new List<String>();
            //Map<String,String> depfldMap = new Map<String,String>();
            if(fldDependnecies!=null){
            for(String f:fldDependnecies){
                //dependentFldList.add(String.valueOf(f));
                if(fieldapitofldLabelMap.containsKey(f)){
                    depfldMap.put(f,fieldapitofldLabelMap.get(f));
                }
                //depfldMap.put(String.valueOf(f),  f.getDescribe().getLabel());
            }
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        //return dependentFldList;*/
        return depfldMap;

    }
/************************************************************************************************************ 
Method Name:        getDependentPicklistValues
@return  :          Map<String,List<String>> (Control values, List of Dependent values)
Parameter :         String, String, Id(Object api name, Field api name, recordTypeId)
Description:        This method is used to get dependent picklist values for each control value
Added By:           Accenture - AN - 16/11/2023
Modified By:        Date:       Changes: 
*************************************************************************************************************/   
@AuraEnabled
public static Map<String,List<String>> getDependentPicklistValues(String objName, String fieldAPI, Id recordtypeId){
    Map<String, List<String>> fdvaluesmap=new Map<String, List<String>>();
    try{
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:PicklistNamedCredential/'+objName+'/picklist-values/'+recordtypeId);
        request.setHeader('Content-Type', 'application/json; charset=UTF-8'); 
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        String res = response.getBody();
        Map<String, Object> tempData= (Map<String, Object>) JSON.deserializeUntyped(res);
        fdvaluesmap = parseDependentPicklistValues(tempData, fieldAPI);
    }
    catch(Exception e){
        Core_MDF_CCP_UtilityClass.logError(e);
        throw new AuraHandledException(e.getMessage());
    }
    System.debug('fieldValuesMap'+fdvaluesmap);
    return fdvaluesmap;
}

public static Map<String, List<String>> parseDependentPicklistValues(Map<String, Object> response, String fieldAPIName) {
        Map<String, List<String>> fdvaluesmap=new Map<String, List<String>>();
        Map<String, Object> picklistfieldsData = (Map<String, Object>)response.get('picklistFieldValues');
        //Controller values map
        Map<String,Object> fldData = (Map<String, Object>)picklistfieldsData.get(fieldAPIName);
        Map<String,Object> controllerValuesMap = ( Map<String,Object>)fldData.get('controllerValues');
        Map<String,String> convertedCVmap = new Map<String, String>();
        for(String s:controllerValuesMap.keyset()){
                String i=String.valueOf(controllerValuesMap.get(s));
                convertedCVmap.put(i,s);
        }
        List<Object> valuesList = (List<Object>)fldData.get('values');
        for(String s:convertedCVmap.keySet()){
            String controllingval = convertedCVmap.get(s);
            for (Object valueObj : valuesList) {
                Map<String, Object> valueMapObj = (Map<String, Object>) valueObj;
                String label = (String) valueMapObj.get('label');
                String value = (String) valueMapObj.get('value');
                
                Object validFor = (Object)valueMapObj.get('validFor');
            
                List<String> objAsStrings = (List<String>) JSON.deserialize(JSON.serialize(validFor), List<String>.class);
                if(objAsStrings.contains(s)){
                    if(fdvaluesmap.containskey(controllingval)){
                        fdvaluesmap.get(controllingval).add(value);
                        }
                    else{
                        fdvaluesmap.put(controllingval,new List<String>{value});
                    }
                }
            }
        
        }
        return fdvaluesmap;
}
/************************************************************************************************************ 
Method Name:        getRTdetailsBasedOnObjectSelection
@return  :          List<rtWrapper>
Parameter :         String, String(Object api name, Field api name)
Description:        This method is used to fetch Record Type Details from metadata based on Object and field selection
Added By:           Accenture - AN - 16/11/2023
Modified By:        Date:       Changes: 
*************************************************************************************************************/   
//Method to get record type details based on Object and field Selection
@AuraEnabled 
public static List<rtWrapper> getRTdetailsBasedOnObjectSelection(String objName, String fieldAPI){
    List<rtWrapper> rtwList = new List<rtWrapper>();
    List<String> recordTypeList = new List<String>();
    try{
        Core_MDF_Smart_Picklist_Maintenance__mdt m= [Select Core_MDF_RecordTypeAPIName_txt__c	 from Core_MDF_Smart_Picklist_Maintenance__mdt where Core_MDF_Object_API_nm__c =:objName and Core_MDF_PicklistField_APIName_txt__c =:fieldAPI];
        String rtString= m.Core_MDF_RecordTypeAPIName_txt__c	;
        recordTypeList=rtString.split(',');
        for(RecordType r1:[Select id,Name,DeveloperName from RecordType where SobjectType =:objName]){
            if(recordTypeList.contains(r1.DeveloperName)){
            rtWrapper RT = new rtWrapper();
            RT.recordTypeId = r1.id;
            RT.developerName = r1.DeveloperName;
            RT.name = r1.Name;
            rtwList.add(RT);
            }
        }
    }
    catch(Exception e){
        Core_MDF_CCP_UtilityClass.logError(e);
        throw new AuraHandledException(e.getMessage());
    }

      return rtwList;
}

/************************************************************************************************************ 
Method Name:        getPicklistValFromGVS
@return  :          List<PickListWrapper>
Parameter :         String (Global Value Set Name)
Description:        This method is used to fetch picklist values from Global Value set if the field refers Global Value Set
Added By:           Accenture - AN - 16/11/2023
Modified By:        Date:       Changes: 
*************************************************************************************************************/   

//Method to fetch picklist values from GlobalValueSet for the fields which refers GVS
    @AuraEnabled
    public static List<PickListWrapper> getPicklistValFromGVS(String globalValueSetName){
        
    List<PickListWrapper> globalpickValuesMap = new List<PickListWrapper>();
    try{
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:PicklistNamedCredentialForGVS/services/data/v50.0/tooling/query/?q=Select+Metadata,Id+FROM+GlobalValueSet+WHERE+DeveloperName=\''+globalValueSetName+'\'');
        req.setHeader('Content-Type', 'application/json; charset=UTF-8'); 
        req.setMethod('GET');
        
        Http request = new Http();
        HttpResponse res  = request.send(req);
        String resBody = res.getBody();
        if(res.getStatusCode()==200){
            Map<String, Object> deserialized = (Map<String, Object>)JSON.deserializeUntyped(resBody);
            List<Map<String, Object>> data = new List<Map<String, Object>>();
            for (Object instance : (List<Object>)deserialized.get('records')){
                data.add((Map<String, Object>)instance); 
            }
            Map<String,Object> mapmetadata = (Map<String,Object>)data[0].get('Metadata');
            List<Object> objlist = (List<Object>) mapmetadata.get('customValue');
            List<Map<String, Object>> resultList1 = new List<Map<String, Object>>();
            
            // Iterate through each object in the response array
            for (Object obj : (List<Object>)objlist) {
                // Check if the object is a Map
                if (obj instanceof Map<String, Object>) {
                    // If it's a Map, add it to the resultList
                    resultList1.add((Map<String, Object>)obj);
                }
            }
            for(Map<String,Object> fmap:resultList1){
                if(fmap.get('isActive')!=false){
                    PickListWrapper wrapper = new PickListWrapper();
                    wrapper.label = String.valueOf(fmap.get('label'));
                    wrapper.value = String.valueOf(fmap.get('valueName'));
                    wrapper.isActive = true;
                    wrapper.isDefaultValue = Boolean.valueOf(fmap.get('default'));
                    globalpickValuesMap.add(wrapper);
                }
            }
            return globalpickValuesMap;
        }
    }
    catch(Exception e){
        Core_MDF_CCP_UtilityClass.logError(e);
        throw new AuraHandledException(e.getMessage());
    }
    return globalpickValuesMap;
    }
 //Wrapper used for FieldDetails
    public class fieldDetailsWrapper{
        @AuraEnabled
        public boolean isLabelNameSameAsAPIName {set; get;}
        @AuraEnabled
        public boolean sorted {set; get;}
        @AuraEnabled
        public String recordTypeTabName {set;get;}
        @AuraEnabled
        public boolean gvsReferenceInd {set;get;}
        @AuraEnabled
        public String globalValueSetName {set;get;}
    }
//Wrapper used for recordTypeDetails 
    public class rtWrapper{
        @AuraEnabled
        public id recordTypeId{set; get;}
        @AuraEnabled
        public string name{set; get;}
        @AuraEnabled
        public string developerName{set; get;}
    }
//Wrapper used for PicklistValueDetails
    public class PickListWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        @AuraEnabled
        public Boolean isActive {get; set;}
        @AuraEnabled
        public Boolean isDefaultValue {get; set;}
        @AuraEnabled
        public boolean isNew {get;set;}
    }

   /*public Class Wrapper{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String ConCatname {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }*/

    public Class Items{
         @AuraEnabled
         public String developerName {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String ConCatname {get;set;}
        //@AuraEnabled
        //public String label {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }


}