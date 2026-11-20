/**************************************************************************************
Apex Class Name:  Core_UpdateOppsConcateFields
Version     : 1.0 
Created Date: 2/03/2023
Description: This class is used for to deduplicate the Concatenated field values.
User Story:TWC3123-3499
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pratik Padwal              2/03/2023                Initial Revision
*************************************************************************************/
public class Core_UpdateOppsConcateFields {
    //This is method used is flow under apex action.
    @InvocableMethod
    public static list<Opportunity> removeDuplicateValues(list<Opportunity> oppsRecords) {
        list<Opportunity> toBeUpdaatedOpps = new list<Opportunity>();
        if(oppsRecords !=Null && oppsRecords.size() > 0 )
        {
            for(Opportunity getOpps : oppsRecords){
                getOpps.Core_Concatenated_Industry_use_case__c = deduplicateTheValues(getOpps.Core_Concatenated_Industry_use_case__c);
                getOpps.Core_Concatenated_Application_workload__c = deduplicateTheValues(getOpps.Core_Concatenated_Application_workload__c);
                getOpps.Core_Concatenated_Technology_Enabled__c = deduplicateTheValues(getOpps.Core_Concatenated_Technology_Enabled__c);
                toBeUpdaatedOpps.add(getOpps);
            }
            return toBeUpdaatedOpps;
        }
        return OppsRecords;
    }
    
    //Function for deduplicate the string values.
    public static String deduplicateTheValues(String value)
    {
        if(value != null && value.contains(';')){
            String uniqueValueString=null;
            List<String> stringList = new List<String>();
            stringList=value.split(';');

            for(String checkStr : stringList)
            { 
                String Trimmed=checkStr.trim();
                if(string.isBlank(uniqueValueString)){
                    uniqueValueString=Trimmed;
                }
                else{
                    if(!uniqueValueString.contains(checkstr)){
                        uniqueValueString+=';';
                        uniqueValueString +=checkstr;
                    }
                }
            }
            return uniqueValueString; 
        }
        return value;
    }
}