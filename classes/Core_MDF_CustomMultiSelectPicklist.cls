/***************************************************************************************************** 
Class Name :    Core_MDF_CustomMultiSelectPicklist
Description:    This is the apex class for Core_MDF_CustomMultiSelectPicklist component
Added By   :    Vivek 
Modified By:                      Date:09/11/2019                     Changes:None  
******************************************************************************************************/
public with sharing class Core_MDF_CustomMultiSelectPicklist {
    
    @AuraEnabled
    public static PicklistOptionsWrapper fetchmultipicklist(string objObject,string fldName,Id recordId)
    {       
        PicklistOptionsWrapper availOpts = new PicklistOptionsWrapper();
        List<string> selectedOptionLst = new List<string>(); 
        String sanitizedObjectName = String.escapeSingleQuotes(objObject);
        String sanitizedfldName = String.escapeSingleQuotes(fldName);
        String sanitizedrecordId;
        if(recordId != NULL){
            sanitizedrecordId = String.escapeSingleQuotes(recordId);
        }
        try
        { 
            if(sanitizedrecordId != null){
                String squery = 'SELECT Id,' + sanitizedfldName + ' FROM ' + sanitizedObjectName + ' WHERE Id = :sanitizedrecordId';
                sObject sObj = database.query(squery);
                
                String fldvalue = (string)sObj.get(sanitizedfldName);
                if(fldvalue!=null) //Check if there is saved value for the field
                {
                    selectedOptionLst.addAll(fldvalue.split(';'));
                    selectedOptionLst.sort();    
                }                
            }
            availOpts.selectedOptionLst = selectedOptionLst;
            
        }
        catch(exception e){
        Core_MDF_CCP_UtilityClass.logError(e);} 
        return availOpts; 
    } 
    
    
    public class PicklistOptionsWrapper
    {
        @AuraEnabled
        public List<string> selectedOptionLst = new List<string>();             
    }
    
    
}