/**************************************************************************************
Apex Class Name : EPUM_EUPMUtility
Version     : 1.0 
Created Date: 26th April 2020
Description : This class is created to add reusable logic for EPUM functionality
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Vaibhav                  26/04/2020             Original Version
*************************************************************************************/

public without sharing class EPUM_Utility{


    public static EPUM_Log__c createEPUMLogs(String actionType, String actionResult, DateTime startLog, String emailSearch){
    
        
        //List<EPUM_Log__c> lstEPUMLogs = new List<EPUM_Log__c>(); 
        EPUM_Log__c epumLogs = new EPUM_Log__c();
        epumLogs.EPUM_Search_Text__c = emailSearch;
        //epumLogs.EPUM_Project_Txt__c = 'EPUM';
        epumLogs.EPUM_Severity_Txt__c = 'Information';
        epumLogs.OwnerId = userInfo.getUserId();
        
        if (actionType == 'SalesCRMSearch') {
            epumLogs.EPUM_Project_Txt__c = 'EPUM - Search';
            epumLogs.EPUM_Origin_Txt__c = '1 - Sales CRM Search';            
            epumLogs.EPUM_When_Dtm__c = startLog;            
            if (actionResult == 'Yes') {
                epumLogs.EPUM_Message_Txt__c = 'Result found in Sales CRM Search.';
                epumLogs.EPUM_Action_Result_Ind__c = 'Yes';     
                epumLogs.EPUM_Details_Dsc__c = 'Results are found in Sales CRM Search for the email id';
            }
            if (actionResult == 'No') {
                epumLogs.EPUM_Message_Txt__c = 'Result not found in Sales CRM Search.';
                epumLogs.EPUM_Action_Result_Ind__c = 'No';      
                epumLogs.EPUM_Details_Dsc__c = 'Results are not found in Sales CRM Search for the email id.';
            }
        }
        // for pending contact 
        if (actionType == 'ContactStatusSearch') {
            epumLogs.EPUM_Project_Txt__c = 'EPUM - Search';
            epumLogs.EPUM_Origin_Txt__c = '4 - Contact Available';            
            epumLogs.EPUM_When_Dtm__c = startLog;
            //Active Contact
            if (actionResult == 'Yes') {
                epumLogs.EPUM_Message_Txt__c = 'Result found in Approved Contact Search.';
                epumLogs.EPUM_Action_Result_Ind__c = 'Yes';     
                epumLogs.EPUM_Details_Dsc__c = 'Results are found in Sales Approved Contact Search for the email id';
            }
            //Pending Contact
            if (actionResult == 'No') {
                epumLogs.EPUM_Message_Txt__c = 'Result not found in Approved Contact Sales CRM Search.';
                epumLogs.EPUM_Action_Result_Ind__c = 'No';      
                epumLogs.EPUM_Details_Dsc__c = 'Results are not found in Approved Contact Search for the email id.';
            }
        }
        if (actionType == 'OPIDSearch') {
            epumLogs.EPUM_Project_Txt__c = 'EPUM - Search';
            epumLogs.EPUM_Origin_Txt__c = '2 - One Partner Id Search';
            epumLogs.EPUM_When_Dtm__c = startLog;
            if (actionResult == 'Yes') {
                epumLogs.EPUM_Message_Txt__c = 'Result found in One Partner Id Search.';
                epumLogs.EPUM_Action_Result_Ind__c = 'Yes';     
                epumLogs.EPUM_Details_Dsc__c = 'Results are found in One Partner Id Search for email id.';
            }
            if (actionResult == 'No') {
                epumLogs.EPUM_Message_Txt__c = 'Result not found in One Partner Id Search.';
                epumLogs.EPUM_Action_Result_Ind__c = 'No';      
                epumLogs.EPUM_Details_Dsc__c = 'Results are not found in One Partner Id Search for email id.';
            }
        }
        if (actionType == 'PartnerRoleSearch') {
            epumLogs.EPUM_Project_Txt__c = 'EPUM - Search';
            epumLogs.EPUM_Origin_Txt__c = '3 - Partner Role Search';
            epumLogs.EPUM_When_Dtm__c = startLog;
            if (actionResult == 'Yes') {
                epumLogs.EPUM_Message_Txt__c = 'Result found in Partner Role Search.';
                epumLogs.EPUM_Action_Result_Ind__c = 'Yes';     
                epumLogs.EPUM_Details_Dsc__c = 'Results are found in Partner Role Search for email id.';
            }
            if (actionResult == 'No') {
                epumLogs.EPUM_Message_Txt__c = 'Result not found in Partner Role Search.';
                epumLogs.EPUM_Action_Result_Ind__c = 'No';      
                epumLogs.EPUM_Details_Dsc__c = 'Results are not found in Partner Role Search for email id.';
            }
        }
        
        //logic to cature logs from List view
        if (actionType == 'ListViewContact') {
            epumLogs.EPUM_Project_Txt__c = 'EPUM - ListView';
            epumLogs.EPUM_Origin_Txt__c = 'List View Contact';
            epumLogs.EPUM_When_Dtm__c = startLog;
            epumLogs.EPUM_Message_Txt__c = 'Contact found in List View.';
            epumLogs.EPUM_Action_Result_Ind__c = 'Yes';       
            epumLogs.EPUM_Details_Dsc__c = 'Results are found in List View for email id.';          
        }
        
        //logic to cature logs from Invite Contact
        if (actionType == 'InviteContact') {
            epumLogs.EPUM_Project_Txt__c = 'EPUM - Invite';
            epumLogs.EPUM_Origin_Txt__c = 'Invite Contact';
            epumLogs.EPUM_When_Dtm__c = startLog;
            epumLogs.EPUM_Message_Txt__c = 'Request to Invite contact initiated.';
            epumLogs.EPUM_Action_Result_Ind__c = 'Yes';       
            epumLogs.EPUM_Details_Dsc__c = 'Request to Invite contact initiated via button.';          
        }
        
        //logic to cature logs from Send Invite
        if (actionType == 'SendInvite') {
            epumLogs.EPUM_Project_Txt__c = 'EPUM - Invite';
            epumLogs.EPUM_Origin_Txt__c = 'Invite Sent to Contact';
            epumLogs.EPUM_When_Dtm__c = startLog;
            epumLogs.EPUM_Message_Txt__c = 'Request to Invite contact Completed.';
            epumLogs.EPUM_Action_Result_Ind__c = 'Yes';       
            epumLogs.EPUM_Details_Dsc__c = 'Request to Invite contact Completed via button.';          
        }
        
        return epumLogs;
        
    }

}