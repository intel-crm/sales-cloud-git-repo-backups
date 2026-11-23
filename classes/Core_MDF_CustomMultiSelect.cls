public with sharing class Core_MDF_CustomMultiSelect {
    
     @AuraEnabled
    public static PicklistOptionsWrapper fetchmultipicklist(string objObject,string fldName,Id recordId)
    {
        
        //List < String > allOpts = new list < String > ();
        PicklistOptionsWrapper availOpts = new PicklistOptionsWrapper();
        Map<String, String> OptionsMap = new Map<String, String>();
        List<string> selectedOptionLst = new List<string>();
       
        try
        {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objObject);
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            list < Schema.PicklistEntry > values = objDescribe.fields.getMap().get(fldName).getDescribe().getPickListValues();
            
            //Load all the options for picklist
            for (Schema.PicklistEntry a: values) 
            {
                //allOpts.add(a.getValue());
                 OptionsMap.put(a.getLabel(),a.getValue());
            }
                           
                        
            if(recordId != null)
            {
                string squery = 'SELECT Id,'+fldName+' FROM '+objObject+' WHERE id=:recordId';
                system.debug(squery);
                sObject sObj = database.query(squery);
                String fldvalue = (string)sObj.get(fldName);  
                
                if(fldvalue!=null) //Check if there is saved value for the field
                {
                    selectedOptionLst.addAll(fldvalue.split(';'));
                    selectedOptionLst.sort();    
                }
                
            }                
            
            availOpts.OptionsMap = OptionsMap;
            availOpts.selectedOptionLst = selectedOptionLst;
            system.debug('Selected Options-' +selectedOptionLst);
            
        }
          catch(exception e){system.debug('Error occured due to '+ e.getMessage());}
           
       return availOpts; 
    } 
    
    
    public class PicklistOptionsWrapper
    {
        @AuraEnabled
        public Map<String, String> OptionsMap = new Map<String, String>();
        @AuraEnabled
        public List<string> selectedOptionLst = new List<string>();
    }
    

}