/**************************************************************************************
Apex Class Name:  Core_Revive_Button_Controller
Version     : 1.0 
Created Date: 27 Sep 2018
Function    : Controller for Core_Revivebutton Component
Description: US147275- Update the Lead Status from Revive Button
Modification Log :
* Developer                       Date                    Description
* ----------------------------------------------------------------------------                 
* Sathishkumar Chennaiyan             27/09/2018              Original Version
*************************************************************************************/
public class Core_Revive_Button_Controller{
    @auraEnabled
    public static String updateLead(String leadId) {
        List<Lead> leadList;
        leadList = [Select Id, Core_Lead_Status__c, Status from Lead where id = : leadId and (status = 'Tele Accepted Lead' or status = 'Sales Accepted Lead') and Core_Lead_Status__c = 'Unreachable' and (RecordType.Name = 'Lead' or RecordType.Name = 'Sales Lead')];
        String alertMessage;
        List<Lead> newList = new List<Lead>();
        if (leadList.size() == 0){
            alertMessage = Label.Core_ReviveButtonFailure;
        }else{
            for(Lead ld: leadList){
                if(ld.status == 'Tele Accepted Lead' && ld.Core_Lead_Status__c == 'Unreachable'){
                    ld.Core_Exit_Date_TAL__c = null;
                    ld.Core_Lead_Status__c = 'Accepted';
                      ld.Core_Unreachable_flag__c =false;
                    ld.Core_Lead_State__c = 'In Pursuit';
                    ld.Core_Unreachable_End_Date__c = System.now();
                    newList.add(ld);
                }
                else if(ld.status == 'Sales Accepted Lead' && ld.Core_Lead_Status__c == 'Unreachable'){
                     ld.Core_Unreachable_flag__c =false;
                    ld.Core_Exit_Date_SAL__c = null;
                    ld.Core_Lead_Status__c = 'Accepted';
                    ld.Core_Lead_State__c = 'In Pursuit';
                    ld.Core_Unreachable_End_Date__c = System.now();
                    newList.add(ld);
                }
            }}
        try{     
            if(newList.size()>0){
                update newList;
                alertMessage=Label.Core_ReviveButtonSuccess; 
            } 
        }
        catch(Exception e){
            alertMessage='An error has occurred while updating lead '+e.getMessage();
        } 
        return alertMessage;
    }  
}