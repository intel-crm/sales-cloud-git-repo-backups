public without sharing class Core_MDF_CCP_GetFieldsList {

@AuraEnabled
public static List < Map < String, String >> getObjectFields (String objName)
{
    List < Map < String, String >> options = new List < Map < String, String >> ();
    if(objName != null){
    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
    Map<String,String> fieldAPIToLabelMap = new Map<String,String>();
  
    for(String fieldApi :fieldMap.keySet()){
         fieldAPIToLabelMap.put(fieldMap.get(fieldApi).getDescribe().getLabel(),fieldApi); 
    }
    List<String>  fieldNameList = new List<String>(fieldAPIToLabelMap.keySet());
    List<String>  apiSortedList = new List<String>();
    	fieldNameList.sort();
    for(String fieldname :fieldNameList){
        apiSortedList.add(fieldAPIToLabelMap.get(fieldname));
    }
    
   
	
    for (String fieldName: apiSortedList)
    { 
        string fieldType = String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
        if(fieldType != 'TEXTAREA'  )
        {
            String FieldAPI=fieldMap.get(fieldName).getDescribe().getName();
            List<String> listStrings = new List<String>();
            listStrings.add(FieldAPI);
         
            string FieldLabelName=fieldMap.get(fieldName).getDescribe().getLabel();
            
            
         
            Map < String, String > values = new Map < String, String > {
              'label' =>FieldLabelName ,
              'value' =>FieldAPI
          };
          options.add(values);    
 }       
}
    }
    return options;
}

@AuraEnabled
public static List < Map < String, String >> getFieldsType (String objName)
{
    List < Map < String, String >> options = new List < Map < String, String >> ();

    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
    for (String fieldName: fieldMap.keySet())
    { 
        string fieldType = String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
        if(fieldType != 'TEXTAREA'  )
        {
            string FieldLabelName=fieldMap.get(fieldName).getDescribe().getLabel();
           
            Map < String, String > values = new Map < String, String > {
              'label' =>FieldLabelName,
              'value' => fieldType
          };
          options.add(values);    
 }       
}
    return options;
} 
    @AuraEnabled
     public static List < Map < String, String >> getPickListValues(String objApiName, String fieldName) {
      List < Map < String, String >> options = new List < Map < String, String >> ();
     // Highlight: Unused Local Variable - 14285
     // Map < String, Schema.SObjectType > objGlobalMap = Schema.getGlobalDescribe();
      Map < String, String > pListMap = new Map <String, String>();
      List<String> sortedPlist = new List<String>();
      Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
      if (objType == null) {
          return options;
      }
      Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
      Map < String, Schema.SObjectField > fieldMap = sobjectDescribe.fields.getMap();
      if (fieldMap.get(fieldName) == null) {
          return options;
      }
      List < Schema.PicklistEntry > pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();// get values of picklist
      for (Schema.PicklistEntry f: pickListValues) {
          pListMap.put(f.getLabel(),f.getValue());
          sortedPlist.add(f.getLabel());
      }
      sortedPlist.sort();
         for(String pistSort : sortedPlist){
             Map < String, String > pickList = new Map < String, String > {
              'label' => pistSort,
              'value' => pListMap.get(pistSort)
          };
          options.add(pickList);
         }
      
      return options;
  }  
    
    
    
}