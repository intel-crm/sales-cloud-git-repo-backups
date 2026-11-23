/***************************************************************************************************
Class Name:  Core_IPS_BES_CCG_CustomLogic
Created Date: 17 Sept 2023
Function    : This class contains CCG and also the Status/SubStatus Inbound Flow of DCG related custom logic(New HSD Bridge)
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavani                     17/09/2023              Created
* Pavani                     26/02/2024              DCG Status/SubStatus Logic for Inbound flow - TWC745-5487
****************************************************************************************************/

public class Core_IPS_BES_CCG_CustomLogic {
    public class CustomException extends Exception {}
/***************************************************************************************************
Method Name:  getsubmitterOrgValue
Created Date: 17 Sept 2023
Function    : This method is used to get the submitter org value based on the category and subcategory on the case in the outbound flow for CCG - case promotion
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavani                     17/09/2023             Created
****************************************************************************************************/

    public static String getsubmitterOrgValue(sObject sobj,Map<String, List<Core_IPS_BES_AllTenants_CustomMapping__c>> customMapping){
        String submitterOrgValue = 'ccg_cce_wed';
       
        if(customMapping.size() > 0){  //29/12/2023
        	for(Core_IPS_BES_AllTenants_CustomMapping__c rec : customMapping.get('CC - HSDES Client Platform')){
        		if(String.isNotBlank(String.ValueOf(sObj.get('Core_External_Issue_Subcategory__c'))) && String.ValueOf(sObj.get('Core_External_Issue_Category__c')).equalsIgnoreCase(rec.Source_Value__c) && rec.Field_API_Name__c.equalsIgnoreCase('Core_External_Issue_Category__c')){
             		submitterOrgValue = rec.Target_Value__c;
                	break;
        		}
        		else if(String.isNotBlank(String.ValueOf(sObj.get('Core_External_Issue_Subcategory__c'))) && String.ValueOf(sObj.get('Core_External_Issue_Subcategory__c')).equalsIgnoreCase(rec.Source_Value__c) && rec.Field_API_Name__c.equalsIgnoreCase('Core_External_Issue_Subcategory__c')){
            		submitterOrgValue = rec.Target_Value__c; 
        		}           
        	}
        }
        
        return submitterOrgValue;
    }
/***************************************************************************************************
Method Name:  getReportTypeValue
Created Date: 17 Sept 2023
Function    : This method is used to get the report type value based on the category of the case in the outbound flow for CCG - case promotion
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavani                     17/09/2023             Created
****************************************************************************************************/

    public static String getReportTypeValue(sObject sobj,String field){
        String reportTypeValue = 'sighting';
        if(String.ValueOf(sObj.get(field)) != '' && String.ValueOf(sObj.get(field)).equalsIgnoreCase('NOVA')){
             reportTypeValue = 'presighting';
        }
        return reportTypeValue;                        
    }
/***************************************************************************************************
Method Name:  processStatusReasonLogic
Created Date: 17 Sept 2023
Function    : In the Inbound flow whenever we get the status and reason values of HSD we will check if there is any match in the custom setting, 
if the value mapping found then split the target value and update status and substatus on the case otherwise create a BES error log
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavani                     17/09/2023             Created
* Pavani					 26/02/2024				Status/SubStatus logic changes for Inbound Flow in DCG - TWC745-5487
****************************************************************************************************/

    public static Map<String,String> processStatusReasonLogic(String status,String reason,String backendSysName,String caseId){
        Map<String, List<Core_IPS_BES_AllTenants_CustomMapping__c>> customMapping = new Map<String,List<Core_IPS_BES_AllTenants_CustomMapping__c>>(); //15-9-23
        customMapping = Core_IPS_BES_Generate_CaseJSON.prepareCustomSettingData();
        Map<String,String> statusSubStatus = new Map<String,String>();
        Boolean statusMatchFound = false;
        Boolean substatusMatchFound = false;
        if(status!='' || reason!=''){
            for(Core_IPS_BES_AllTenants_CustomMapping__c rec : customMapping.get(backendSysName)){
                if(rec.Field_API_Name__c.equalsIgnoreCase('Status') && status!='' && status!=null && rec.Source_Value__c.equalsIgnoreCase(status)){
                    if(rec.Target_Value__c.contains('.')){
                        
                        
                        List<String> valueLst = rec.Target_Value__c.split('\\.');
                        
                        statusSubStatus.put('Status',valueLst[0]);
                        statusSubStatus.put('Core_Sub_Status__c',valueLst[1]);
                    }
                    else{
                        statusSubStatus.put('Status',rec.Target_Value__c);
                    }
                    statusMatchFound= true;
                }
                if(rec.Field_API_Name__c.equalsIgnoreCase('Core_Sub_Status__c') && reason!='' && reason!=null && rec.Source_Value__c.equalsIgnoreCase(reason)){
                	//statusSubStatus.put('Core_Sub_Status__c',rec.Target_Value__c);
                	if(rec.Target_Value__c.contains('.')){
                        
                        
                        List<String> valueLst = rec.Target_Value__c.split('\\.');
                        
                        statusSubStatus.put('Status',valueLst[0]);
                        statusSubStatus.put('Core_Sub_Status__c',valueLst[1]);
                    }
                    substatusMatchFound = true;
                }           
            }
        }
        // Added by Pavani for creating BES Error log when the value mapping is not present for status and reason TWC745-5487 - 26/02/2024
        if(statusMatchFound==false && String.isNotBlank(status) && status!='open'){
                Core_IPS_BES_LogEntry_Utility.insertLog(new CustomException('No Status Value Mapping found for Case Object : '+ status ), null, null, null, caseId);
            
        }
        if(substatusMatchFound==false && String.isNotBlank(reason)){
                Core_IPS_BES_LogEntry_Utility.insertLog(new CustomException('No SubStatus Value Mapping found for Case Object : '+reason), null, null, null, caseId);
            
        }
        // End by Pavani - TWC745-5487 - 26/02/2024
        return statusSubStatus;
    }
    
    
}