public with sharing class Core_MDF_DigitalMediaComp {

    @AuraEnabled
    public static PicklistOptionsWrapper fetchpicklistVal(string objObject,string fldname,Id recordId)
    {
        
         PicklistOptionsWrapper availOpts = new PicklistOptionsWrapper();
         //Map<String, String> OptionsMap = new Map<String, String>();
         string selectedKPIOption = '';
         string selectedPageToLinkOption = '';
        
        try
        {
                  
          /*  Schema.SObjectType objType = Schema.getGlobalDescribe().get(objObject);
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            list < Schema.PicklistEntry > values = objDescribe.fields.getMap().get(fldName).getDescribe().getPickListValues();
            
            //Load all the options for picklist
            for (Schema.PicklistEntry a: values) 
            {
                //allOpts.add(a.getValue());
                 OptionsMap.put(a.getLabel(),a.getValue());
            } */
        

            if(recordId != null)
            {
                                                            
                 string squery = 'SELECT Id,'+fldName+' FROM '+objObject+' WHERE id=:recordId';
                 system.debug(squery);
                 sObject sObj = database.query(squery);
                 //String fldvalue = (string)sObj.get(fldName);  
                 String[] fldlst = fldname.split(',');
                 String fldvalue = '';
                
                 for(String str :fldlst)  
                 {
                     fldvalue = (string)sObj.get(str);
                     
                     if(fldvalue!=null) //Check if there is saved value for the field
                     {
                        if(str=='Core_MDF_PagetoLink_Nm__c')
                            selectedPageToLinkOption = fldvalue;
                        if(str=='Core_MDF_KPI_Nm__c')
                            selectedKPIOption = fldvalue;
                     }
                                             
                 }
                                   
            }
            
            //availOpts.OptionsMap = OptionsMap;
            availOpts.selectedPageToLinkOption = selectedPageToLinkOption;
            availOpts.selectedKPIOption = selectedKPIOption;
            
            system.debug('PagetoLink-' +selectedPageToLinkOption);
            system.debug('KPI-' +selectedKPIOption);
        }
        
        catch(exception e){system.debug('Error occured due to '+ e.getMessage());}
                
        return availOpts;
    }
    
    
    public class PicklistOptionsWrapper
    {
       // @AuraEnabled
       // public Map<String, String> OptionsMap = new Map<String, String>();
        @AuraEnabled
        public string selectedPageToLinkOption;
        @AuraEnabled
        public string selectedKPIOption;
       
    }
}