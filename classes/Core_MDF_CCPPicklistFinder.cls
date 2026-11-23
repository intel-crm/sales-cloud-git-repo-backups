public without sharing class Core_MDF_CCPPicklistFinder {


    @AuraEnabled
    public static List < Map < String, String >> getRecordTypePickListValues(String objName) {
        List < Map < String, String >> recordTypeOptions = new List < Map < String, String >> ();
        system.debug('objName:'+objName);        
        if(String.isNotBlank(objName)){
            for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByName().values()){
                
                Map < String, String > values = new Map < String, String > {
                    'label' => recInfo.getName(),
                    'value' => recInfo.getDeveloperName()
                };
                recordTypeOptions.add(values);
            }
        }
        return recordTypeOptions;
        
        
        
    }
    
    public static Map <String,String> getRecordTypePickListValues2(String objName) {
        Map <String,String> recordTypeOptions = new Map <String,String> ();
        system.debug('objName:'+objName);        
        if(String.isNotBlank(objName)){
            for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByName().values()){
                if(recInfo.getDeveloperName().contains('Core_MDF_')){
                    recordTypeOptions.put(recInfo.getName(),objName+'+'+recInfo.getDeveloperName());
                }
                
            }
        }
        system.debug('Here'+recordTypeOptions);
        return recordTypeOptions;
    }
                
@AuraEnabled
    public static List < Map < String, String >> getFieldValues(String objName) {
        List < Map < String, String >> options = new List < Map < String, String >> ();
                
         // Get the object type of the SObject.
  Schema.sObjectType objType = Schema.getGlobalDescribe().get(objName);
 
  // Describe the SObject using its object type.
  Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // Get a map of fields for the SObject
  map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        for(Schema.SObjectField key:fieldMap.values()){
            Schema.DescribeFieldResult f = key.getDescribe();
            system.debug('f:'+f);
            if(String.valueOf(f.getType()).contains('PICKLIST') && f.getName().contains('Core_MDF_')){
                system.debug('f:'+f.getLabel()+':::'+f.getType()+':::'+f.getName()+':::'+f.isDependentPicklist());
                Map < String, String > values = new Map < String, String > {
                        'label' => f.getLabel(),
                        'value' => f.getName()
                    };
                    options.add(values);
            }
            
        }
        
return options;
                
    }
    
    
    public static Map < String, String > getFieldValues2(String objName,String recTypeItem) {
        Map < String, String > options = new Map < String, String > ();
                
         // Get the object type of the SObject.
  Schema.sObjectType objType = Schema.getGlobalDescribe().get(objName);
 
  // Describe the SObject using its object type.
  Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // Get a map of fields for the SObject
  map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        for(Schema.SObjectField key:fieldMap.values()){
            Schema.DescribeFieldResult f = key.getDescribe();
            if(String.valueOf(f.getType()).contains('PICKLIST') && f.getName().contains('Core_MDF_')){
                system.debug('f:'+f.getLabel()+':::'+f.getType()+':::'+f.getName()+':::'+f.isDependentPicklist());
                options.put(f.getLabel(),objName+'+'+recTypeItem+'+'+f.getName());
            }
            
        }
        
return options;
                
    }

            @AuraEnabled
    public static List<String> getPickListValuesBasedOnRecordType(String objApiName,String recordTypeName, String fieldName) {
                List < Map < String, String >> options = new List < Map < String, String >> ();
                List<String> listofavailablevalue = new List<String>();
        
        listofavailablevalue = getPicklist(objApiName,recordTypeName,fieldName);
        
        return listofavailablevalue;
               
            }
    
    public static List<String> getPicklist(String objApiName,String recordTypeName,String fieldName){
        List<String> listofavailablevalue = new List<String>();
        String objectRecordType = objApiName + '.' + recordTypeName;
        
        Map<String,String> picklistToGlobalValueSetMap = new Map<String,String>{};
        
        for(Picklist_To_GlobalValueSet_Mapping__mdt mdt:[Select Picklist_FieldName__c,Object_ApiName__c,GlobalValueSet_Name__c from Picklist_To_GlobalValueSet_Mapping__mdt where Object_ApiName__c=:objApiName and Picklist_FieldName__c=:fieldName]){
            picklistToGlobalValueSetMap.put(mdt.Picklist_FieldName__c,mdt.GlobalValueSet_Name__c);
        }
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        //service.SessionHeader.sessionId = UserInfo.getSessionId();
        String content = Page.Core_Fetch_SessionId.getContent().toString();
        Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                e = content.indexOf('End_Of_Session_Id');
        String sessionId = content.substring(s, e);
        service.SessionHeader.sessionId = sessionId;
        //service.endpoint_x = 'https://intel--crmdevccp--c.cs17.visual.force.com';
        MetadataService.RecordType recordType = (MetadataService.RecordType) service.readMetadata('RecordType', new String[] { objectRecordType }).getRecords()[0];
        for ( MetadataService.RecordTypePicklistValue rpk : recordType.picklistValues ) {
            //system.debug('rpk:'+rpk);
            //rpk.picklist comes as __c in case of custom picklist field else if its a global picklist then comes with global picklist name
            if ( rpk.picklist == fieldName ) {
                for ( MetadataService.PicklistValue pk : rpk.values ) {
                    listofavailablevalue.add(String.valueof(pk.fullName));
                }
            }
            else if(picklistToGlobalValueSetMap.containsKey(fieldName) && rpk.picklist == picklistToGlobalValueSetMap.get(fieldName)){
                for ( MetadataService.PicklistValue pk : rpk.values ) {
                    listofavailablevalue.add(String.valueof(pk.fullName));
                }
            }
        }
        return listofavailablevalue;
    }
    
    
    public static Map<String,String> getPicklist2(String objApiName,String recordTypeName,String fieldName){
        Map<String,String> listofavailablevalue = new Map<String,String>();
        String objectRecordType = objApiName + '.' + recordTypeName;
        
        Map<String,String> picklistToGlobalValueSetMap = new Map<String,String>{};
        
        for(Picklist_To_GlobalValueSet_Mapping__mdt mdt:[Select Picklist_FieldName__c,Object_ApiName__c,GlobalValueSet_Name__c from Picklist_To_GlobalValueSet_Mapping__mdt where Object_ApiName__c=:objApiName and Picklist_FieldName__c=:fieldName]){
            picklistToGlobalValueSetMap.put(mdt.Picklist_FieldName__c,mdt.GlobalValueSet_Name__c);
        }
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        //service.SessionHeader.sessionId = UserInfo.getSessionId();
        String content = Page.Core_Fetch_SessionId.getContent().toString();
        Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                e = content.indexOf('End_Of_Session_Id');
        String sessionId = content.substring(s, e);
        service.SessionHeader.sessionId = sessionId;
        //service.endpoint_x = 'https://intel--crmdevccp--c.cs17.visual.force.com';
        MetadataService.RecordType recordType = (MetadataService.RecordType) service.readMetadata('RecordType', new String[] { objectRecordType }).getRecords()[0];
        for ( MetadataService.RecordTypePicklistValue rpk : recordType.picklistValues ) {
            //system.debug('rpk:'+rpk);
            //rpk.picklist comes as __c in case of custom picklist field else if its a global picklist then comes with global picklist name
            if ( rpk.picklist == fieldName ) {
                for ( MetadataService.PicklistValue pk : rpk.values ) {
                    listofavailablevalue.put(String.valueof(pk.fullName),objApiName+'+'+recordTypeName+'+'+fieldName+'+'+String.valueof(pk.fullName));
                }
            }
            else if(picklistToGlobalValueSetMap.containsKey(fieldName) && rpk.picklist == picklistToGlobalValueSetMap.get(fieldName)){
                for ( MetadataService.PicklistValue pk : rpk.values ) {
                    listofavailablevalue.put(String.valueof(pk.fullName),objApiName+'+'+recordTypeName+'+'+fieldName+'+'+String.valueof(pk.fullName));
                }
            }
        }
        return listofavailablevalue;
    }
    
    
    //get dependent picklist values
    
    public static void getDependentPicklistValues(String objName,String fieldName){
         Map<String,String> picklistToGlobalValueSetMap = new Map<String,String>{};
        
        for(Picklist_To_GlobalValueSet_Mapping__mdt mdt:[Select Picklist_FieldName__c,Object_ApiName__c,GlobalValueSet_Name__c from Picklist_To_GlobalValueSet_Mapping__mdt where Object_ApiName__c='PartnerFundRequest' and Picklist_FieldName__c='Core_MDF_Activity_Types__c']){
            picklistToGlobalValueSetMap.put(mdt.Picklist_FieldName__c,mdt.GlobalValueSet_Name__c);
        }

Schema.sObjectField dependentField;
Schema.sObjectType objType = Schema.getGlobalDescribe().get(objName);
// Describe the SObject using its object type.
Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
// Get a map of fields for the SObject
map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
  for(Schema.SObjectField key:fieldMap.values()){
     Schema.DescribeFieldResult f = key.getDescribe();
     if(String.valueOf(f.getType()).contains('PICKLIST') && f.getName().contains(fieldName)){
     dependentField = key;
         break;
     }
  }



Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        //Get dependent field result
        Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
        //Get dependent field controlling field 
        Schema.sObjectField controllerField = dependentFieldResult.getController();
        //Check controlling field is not null
Schema.DescribeFieldResult f = controllerField.getDescribe();
        String cf = f.getName();
        cf = (picklistToGlobalValueSetMap.containsKey(cf))?picklistToGlobalValueSetMap.get(cf):cf;
system.debug('controllerField:'+cf);

Schema.sObjectField controllerField1;
  // Get a map of fields for the SObject
map < String, Schema.SObjectField > fieldMap2 = objDescribe.fields.getMap();
  for(Schema.SObjectField key:fieldMap2.values()){
     Schema.DescribeFieldResult f1 = key.getDescribe();
     if(String.valueOf(f1.getType()).contains('PICKLIST') && f1.getName().contains(cf)){
     controllerField1 = key;
         break;
     }
  }
        //Get controlling field result
        Schema.DescribeFieldResult controllerFieldResult = controllerField1.getDescribe();
        //Get controlling field picklist values if controlling field is not a checkbox
        List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());
         system.debug('controllerValues:'+controllerValues);
        //It is used to decode the characters of the validFor fields. 
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
         
        for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
            if (entry.isActive()){
            //The PicklistEntry is serialized and deserialized using the Apex JSON class and it will check to have a 'validFor' field
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer i = 0; i < controllerValues.size(); i++){
                    Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getLabel() : null));
                    Integer bitIndex = i / 6;
                    Integer bitShift = 5 - Math.mod(i, 6 );
                    /*if(controllerValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0){
                        continue;
                    } */
                    if (!dependentPicklistValues.containsKey(controllerValue)){
                        dependentPicklistValues.put(controllerValue, new List<String>());
                    }
                    dependentPicklistValues.get(controllerValue).add(entry.getLabel());
                }
            }
        }
        system.debug('dependentPicklistValues:'+dependentPicklistValues);
    }
    
    
    /*second approach*/
    
    public static List<item> frameParent(String type,Map<String,String> values){
        List<item> items = new List<item>();
        if(type=='OBJECT'){
        for(String v: values.keySet()){
            item objitem = new item(v,values.get(v), false,true,false,false, null);
            items.add(objitem);
        }
        }
        if(type=='RECORDTYPE'){
        for(String v: values.keySet()){
            item recTypeItem = new item(v,values.get(v), false,false,true,false, null);
            items.add(recTypeItem);
        }
        }
        if(type=='FIELD'){
        for(String v: values.keySet()){
            item fieldItem = new item(v,values.get(v), false,false,false,true, null);
            items.add(fieldItem);
        }
        }
    return items;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<item> getRecTypeItems(String objName){
        List<item> recTypeItems = new List<item>();
        Map<String,String> recTypes = getRecordTypePickListValues2(objName);
        recTypeItems = frameParent('RECORDTYPE',recTypes); 
        return recTypeItems;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<item> getFieldItems(String objName){
        List<String> splittedInput = new List<String>();
        if(objName.contains('+')){
            splittedInput = objName.split('\\+');
        }
        List<item> picklistItems = new List<item>();
        Map<String,String> picklist = getFieldValues2(splittedInput[0],splittedInput[1]);
        picklistItems = frameParent('FIELD',picklist); 
        return picklistItems;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<item> getValueItems(String objName){
        List<String> splittedInput = new List<String>();
        if(objName.contains('+')){
            splittedInput = objName.split('\\+');
        }
        List<item> picklistValueItems = new List<item>();
        Map<String,String> picklistValues = getPicklist2(splittedInput[0],splittedInput[1],splittedInput[2]);
        picklistValueItems = frameParent('FIELD',picklistValues); 
        system.debug('picklistValueItems:'+picklistValueItems);
        return picklistValueItems;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<item> getObjects(){
        List<item> items = new List<item>();
        Map<String,String> objList = new Map<String,String>();
        objList.put('Campaign [CCF,DCF,SPCF,CCFB,IPA,RMF]','Campaign');
        objList.put('Co-Marketing Activity','PartnerFundRequest');
        objList.put('Case','Case');
        objList.put('Claim','PartnerFundClaim');
      //  objList.put('Exception','Core_MDF_Exception__c');
        objList.put('Escalation','Core_MDF_Escalation__c');
        items = frameParent('OBJECT',objList);
        system.debug('items:'+items);
        return items;        
        /*for(String recTypeMapKey: recTypes.keySet()){
                for(String fieldKey: fields.keySet()){
                    List<String> picklistVal = getPicklist(obj,recTypes.get(recTypeMapKey),fields.get(fieldKey));
                    FieldToValueMap.put(obj+':'+recTypeMapKey+':'+fieldKey,picklistVal);
                    for(String v:picklistVal){
                        item valueitem = new item(v, v, false, null);
                        valueItems.add(valueitem);
                    }
                }
            }
            system.debug('FieldToValueMap:'+FieldToValueMap);*/
    }
     
    
    //Item Wrapper Class
    public class item{
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public Boolean expanded {get; set;}
        @AuraEnabled
        public Boolean isObject {get; set;}
        @AuraEnabled
        public Boolean isRecType {get; set;}
        @AuraEnabled
        public Boolean isField {get; set;}
        @AuraEnabled
        public List<item> items {get; set;}
        
        
        
        
        public item(String label, String name, Boolean expanded,Boolean isObject,Boolean isRecType,Boolean isField, List<item> items){
            this.label = label;
            this.name = name;
            this.expanded = expanded;
            this.isObject=isObject;
            this.isRecType=isRecType;
            this.isField=isField;
            if(items != null && items.size() > 0){
            this.items = items;
        }else{
            this.items = new List<item>();
        }
        }
    }
}