public without sharing class GetFieldsList {
//It is use return the Fields of account
@AuraEnabled
public static List < Map < String, String >> getObjectFields (String objName)
{
    List < Map < String, String >> options = new List < Map < String, String >> ();
  // map<string,list<string>> retVal = new map<string,list<string>>();
    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
    for (String fieldName: fieldMap.keySet())
    { // Schema.sObjectType.Contact.fields.Name.isAccessible()
        string fieldType = String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
        if(fieldType != 'TEXTAREA'  )
        {
            String FieldAPI=fieldMap.get(fieldName).getDescribe().getName();
            List<String> listStrings = new List<String>();
            listStrings.add(FieldAPI);
           // listStrings.add(fieldType); //Adding field type 
            string FieldLabelName=fieldMap.get(fieldName).getDescribe().getLabel();
            System.debug('FieldLabelName'+FieldLabelName);
            //retVal.put(FieldLabelName,listStrings); 
         
            Map < String, String > values = new Map < String, String > {
              'label' =>FieldLabelName ,
              'value' =>FieldAPI
          };
          options.add(values);    
 }       
}
    return options;
}

@AuraEnabled
public static List < Map < String, String >> getFieldsType (String objName)
{
    List < Map < String, String >> options = new List < Map < String, String >> ();
  // map<string,list<string>> retVal = new map<string,list<string>>();
    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
    for (String fieldName: fieldMap.keySet())
    { // Schema.sObjectType.Contact.fields.Name.isAccessible()
        string fieldType = String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
        if(fieldType != 'TEXTAREA'  )
        {
            string FieldLabelName=fieldMap.get(fieldName).getDescribe().getLabel();
            System.debug('FieldLabelName'+FieldLabelName);
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
      Map < String, Schema.SObjectType > objGlobalMap = Schema.getGlobalDescribe();
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
          Map < String, String > pickList = new Map < String, String > {
              'label' => f.getLabel(),
              'value' => f.getValue()
          };
          options.add(pickList);
      }
      System.debug('pickList'+options);
      return options;
  }  
    
    
    
}
/*@AuraEnabled
public static List<wrapperClass> getObjectType (String objName)
{
    //List < Map < String, String >> options = new List < Map < String, String >> ();
  // map<string,list<string>> retVal = new map<string,list<string>>();
    List<wrapperClass> options = new List<wrapperClass>();
    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
    for (String fieldName: fieldMap.keySet())
    { // Schema.sObjectType.Contact.fields.Name.isAccessible()
        string fieldType = String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
        if(fieldType != 'TEXTAREA'  )
        {
            String FieldAPI=fieldMap.get(fieldName).getDescribe().getName();
            string FieldLabelName=fieldMap.get(fieldName).getDescribe().getLabel();
            System.debug('FieldLabelName'+FieldLabelName);
            options.add(new wrapperClass(FieldLabelName,FieldAPI,FieldType));
 }       
}
    return options;
}
    
    public without sharing class wrapperClass {
    @AuraEnabled
    public String FieldLabelName;
    @AuraEnabled
    public String FieldApiName;
    @AuraEnabled
    public String FieldType;
    public wrapperClass(String FieldLabelName,String FieldApiName,String FieldType ){
            this.FieldLabelName = FieldLabelName;
            this.FieldApiName = FieldApiName;
            this.FieldType=FieldType;
        }
   
}*/