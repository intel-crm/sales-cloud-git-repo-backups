/*
* Class Name  : Core_MDF_ProcessCCPEscalation 
* Version     : 1.0 
* Created Date: 16/5/2019
* Modification Log :
* Developer               Date                          Description 
* -----------------------------------------------------------------------------------------------------------------------------------------------------
* Accenture – SA          16/5/2019                     Created  
-------------------------------------------------------------------------------------------------------------------------------------------------------
*/

public with Sharing class Core_MDF_ProcessCCPEscalation {
    
    Public static Id Escalationlc = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
    
    /****************************************************************************************************** 
Method Name:        updateActivityOnEscalation
@return  :          void
@parameters:        List<Core_MDF_Escalation__c> List of escalations
Description:        This method is used to update the activity value on Escalation based on Activity number entered by user
Added By:           Accenture - SA - 17/5/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    Public static void updateActivityOnEscalation(List<Core_MDF_Escalation__c> EscalationList){
        try{
            Set<String> activityNobyUser= new Set<String>();
            List<Core_MDF_Escalation__c> escalationToBeProcessed = new List<Core_MDF_Escalation__c>();
            
            for(Core_MDF_Escalation__c  esclate: EscalationList){
                if(esclate.RecordTypeId==Escalationlc && esclate.Core_MDF_Activity_Number_txt__c!=''){
                    //checking if Activity# is less than 8 digits
                    if(esclate.Core_MDF_Activity_Number_txt__c.length()!=8){
                        // append leading zeroes
                        esclate.Core_MDF_Activity_Number_txt__c = esclate.Core_MDF_Activity_Number_txt__c.leftPad(8, '0');
                    }
                    
                    activityNobyUser.add(esclate.Core_MDF_Activity_Number_txt__c);
                    escalationToBeProcessed.add(esclate);    
                }
            }
            
            Map<String, PartnerFundRequest> ActivityNumberWithId = new Map<String, PartnerFundRequest>();
            List<PartnerFundRequest> AllActivities = [select id, Title, Core_MDF_Activity_Number__c, Campaign.Core_MDF_Channel_Program__c from PartnerFundRequest where Core_MDF_Activity_Number__c in :activityNobyUser];
            
            if(AllActivities.size()>0){
                for(PartnerFundRequest pfRequest: AllActivities){
                    if(pfRequest.Core_MDF_Activity_Number__c!=null){
                        ActivityNumberWithId.put(pfRequest.Core_MDF_Activity_Number__c, pfRequest); 
                    }
                    
                }
            }
            
            for(Core_MDF_Escalation__c escalation: escalationToBeProcessed){
                if(ActivityNumberWithId.containsKey(escalation.Core_MDF_Activity_Number_txt__c)){    
                    escalation.Core_MDF_Activity_Id_txt__c =  ActivityNumberWithId.get(escalation.Core_MDF_Activity_Number_txt__c).id;
                    escalation.Core_MDF_Channel_Program_id__c =  ActivityNumberWithId.get(escalation.Core_MDF_Activity_Number_txt__c).Campaign.Core_MDF_Channel_Program__c; 
                    escalation.Core_MDF_Program_txt__c =  ActivityNumberWithId.get(escalation.Core_MDF_Activity_Number_txt__c).Campaign.Core_MDF_Channel_Program__c;                                               
                    escalation.Core_MDF_Activity_Name_txt__c= ActivityNumberWithId.get(escalation.Core_MDF_Activity_Number_txt__c).Title;    
                } 
                else{
                    escalation.Core_MDF_Activity_Number_txt__c.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Unavailable_Error_Msg'));  
                }
            }
            
        }
        catch(Exception e){
            String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,Label.Core_MDF_Escalation_UpdateActivity_Exception);
        }
    }
}