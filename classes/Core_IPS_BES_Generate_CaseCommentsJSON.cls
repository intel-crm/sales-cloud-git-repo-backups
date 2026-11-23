public with sharing class Core_IPS_BES_Generate_CaseCommentsJSON{
    
    public static Map<String, JSONGenerator> getJsonForCommentObject(List<Id> commentsIdList){
        String sObjectFields = '';
        String objName ='Core_IPS_Case_Comments__c';
        Map<String,List<IPS_Case_Comment_Fields__c>> dataX = new Map<String,List<IPS_Case_Comment_Fields__c>>();    //building a map from custom setting as Object name as key and Object as value.
        Map<String,String> ccfieldMap = new Map<String, String>();     //contains commentobject Map
        Map<String, JSONGenerator> genMap = new Map<String, JSONGenerator>();
        String jsonData = '';
        
        try{
            if(IPS_Case_Comment_Fields__c.SObjectType.getDescribe().isQueryable()) {
                if(commentsIdList.size()>0){                            
                    List<IPS_Case_Comment_Fields__c> commentCustomSettings =[Select id, Object_Name__c, Comment_Field_Type__c, Comment_Field_API_Name__c, JSON_Field_Name__c from IPS_Case_Comment_Fields__c order by name DESC ];
                    for(IPS_Case_Comment_Fields__c cc : commentCustomSettings) {                   
                        ccfieldMap.put(cc.Comment_Field_API_Name__c, cc.JSON_Field_Name__c); 
                        
                    }
                }
            }
            
            sObjectFields = String.join(new List<String>(ccfieldMap.keySet()),',');        
            String soqlQuery = 'SELECT '+ sObjectFields +',Core_IPS_Case__c FROM '+objName+' WHERE Id IN: commentsIdList'; //Dynamic SOQL Query with all fields
            List<sObject> sObjList = Database.Query(soqlQuery);
            
            for(sObject sobj: sObjList){ 
                JSONGenerator gen = JSON.createGenerator(true);
                
                gen.writeStartObject();            
                for(String field: ccfieldMap.keySet()){  
                    if(field.contains('.')){                     
                        list<String> templist = new list<String>();
                        templist = field.split('\\.');
                       
                        if(sObj.getsObject(templist[0])!= null
                           && sObj.getsObject(templist[0]).get(templist[1])!=null && String.ValueOf(sObj.getsObject(templist[0]).get(templist[1]))!=null && ccfieldMap.get(field)!=null && String.isNotBlank(String.ValueOf(sObj.getsObject(templist[0]).get(templist[1])))){
                               gen.writeStringField(ccfieldMap.get(field),  String.ValueOf(sObj.getsObject(templist[0]).get(templist[1])));
                           }else{
                               gen.writeStringField(ccfieldMap.get(field), '');
                           }
                    } 
                    else if(sObj.get(field) != null && String.ValueOf(sObj.get(field))!=null && String.isNotBlank(String.ValueOf(sObj.get(field)))){
                       
                        if(field.equalsIgnoreCase('Core_IPS_Rich_Comment__c')){
                            gen.writeStringField(ccfieldMap.get(field), Core_IPS_JSON_Utility.getBase64ImgConvert(String.ValueOf(sObj.get(field)))); 
                        }
                        else {
                            gen.writeStringField(ccfieldMap.get(field), String.ValueOf(sObj.get(field)));
                        }
                    }
                    else {
                        gen.writeStringField(ccfieldMap.get(field), '');
                    } 
                }
                
                gen.writeEndObject(); 
                //end Getting the JSON String Data
                genMap.put(String.ValueOf(sObj.get('Core_IPS_Case__c'))+String.ValueOf(sObj.get('Id')), gen);
            } 
        }
        catch(Exception e){            
           Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join(commentsIdList,','));
        }
        return genMap;
    }
}