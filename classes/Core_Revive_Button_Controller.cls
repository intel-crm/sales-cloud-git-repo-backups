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
public class Core_Revive_Button_Controller {
    @auraEnabled
    public static String updateLead(String leadId) {
        String loggedInUserId = UserInfo.getUserId();
        List<Lead> leadList = [SELECT Id, Street, PostalCode, Core_Lead_Status__c, Core_Lead_Revive_Date_Original__c, Core_Lead_Revive_Date_Most_Recent__c, Status, RecordType.Name, Core_Existing_Covered_Account__r.RecordType.name FROM Lead WHERE Id = :leadId AND (RecordType.Name = 'Lead' OR RecordType.Name = 'Sales Lead')];
        
        if (leadList.isEmpty()) {
            return Label.Core_ReviveButtonFailure;
        }
        
        Lead lead = leadList[0];
        String alertMessage = validateLead(lead);
        if (alertMessage != null) {
            return alertMessage;
        }
        
        List<Lead> newList = new List<Lead>();
        for (Lead ld : leadList) {
            alertMessage = reviveLead(ld, loggedInUserId, newList);
            if (alertMessage != null) {
                return alertMessage;
            }
        }
        
        try {
            if (!newList.isEmpty()) {
                update newList;
                alertMessage = Label.Core_ReviveButtonSuccess;
            }
        } catch (Exception e) {
            alertMessage = 'An error has occurred while updating lead ' + e.getMessage();
        }
        
        return alertMessage;
    }
    
    private static String reviveLead(Lead ld, String loggedInUserId, List<Lead> newList) {
        if (ld.Status == 'Marketing Qualified Lead' && ld.Core_Lead_Status__c == 'Disqualified') {
            ld.OwnerId = loggedInUserId;
            ld.Status = 'Marketing Qualified Lead';
            ld.Core_Lead_Status__c = 'Accepted';
            ld.Core_Lead_Sub_Status__c = 'Attempting Contact';
            ld.Core_Lead_State__c = 'In Pursuit';
            ld.Core_Rejected_Flag__c = true;
            ld.Core_Entrance_Date_MAQL__c = System.now();
            ld.Core_Entrance_Date_MQL__c = System.now();
            ld.SWS_Claimed_Date__c = System.now();
            PopulateReviveDate(ld);
            newList.add(ld);
            
        } 
         else if (ld.Status == 'Sales Generated Lead' && ld.Core_Lead_Status__c == 'Disqualified') {
            ld.OwnerId = loggedInUserId;
            ld.Status = 'Sales Generated Lead';
            ld.Core_Lead_Status__c = 'Accepted';
            ld.Core_Lead_Sub_Status__c = 'Attempting Contact';
            ld.Core_Lead_State__c = 'In Pursuit';
            ld.Core_Rejected_Flag__c = true;
            ld.SWS_Entrance_Date_SGL__c = System.now();
            ld.SWS_Claimed_Date__c = System.now();
            PopulateReviveDate(ld);
            newList.add(ld);
         }
        	else if (ld.RecordType.Name == 'Sales Lead' && ld.Status == 'Sales Accepted Lead' && ld.Core_Lead_Status__c == 'Disqualified') {
            ld.OwnerId = loggedInUserId;
            ld.Status = 'Sales Generated Lead';
            ld.Core_Lead_Status__c = 'Accepted';
            ld.Core_Lead_Sub_Status__c = 'Attempting Contact';
            ld.Core_Lead_State__c = 'In Pursuit';
            ld.Core_Lead_BANT_Sub_Status__c = null;
            ld.Core_Lead_to_Opportunity_Conversion_flag__c = false;
            ld.Core_Rejected_Flag__c = true;
            ld.Core_Entrance_Date_SAL__c = null;
            ld.Core_Exit_Date_SAL__c = null;
            ld.SWS_Entrance_Date_SGL__c = System.now();
            ld.SWS_Claimed_Date__c = System.now();
            PopulateReviveDate(ld);
            newList.add(ld);
         }
        	else if (ld.RecordType.Name == 'Lead' && ld.Status == 'Sales Accepted Lead' && ld.Core_Lead_Status__c == 'Disqualified') {
            ld.OwnerId = loggedInUserId;
            ld.Status = 'Marketing Qualified Lead';
            ld.Core_Lead_Status__c = 'Accepted';
            ld.Core_Lead_Sub_Status__c = 'Attempting Contact';
            ld.Core_Lead_State__c = 'In Pursuit';
            ld.Core_Lead_BANT_Sub_Status__c = null;
            ld.Core_Lead_to_Opportunity_Conversion_flag__c = false;
            ld.Core_Rejected_Flag__c = true;
            ld.Core_Entrance_Date_SAL__c = null;
            ld.Core_Exit_Date_SAL__c = null;
            ld.Core_Entrance_Date_MAQL__c = System.now();
            ld.Core_Entrance_Date_MQL__c = System.now();
            ld.SWS_Claimed_Date__c = System.now();
            PopulateReviveDate(ld);
            newList.add(ld);
        } else if (ld.Core_Lead_Status__c != 'Disqualified') {
            return Label.Core_ReviveButtonFailure;
        }
        
        return null;
    }
    
    private static String validateLead(Lead lead) {
        if (String.isBlank(lead.Street) && String.isBlank(lead.PostalCode)) {
            return Label.Lead_Street_and_Postal_Code;
        } else if (String.isBlank(lead.Street)) {
            return Label.Lead_StreetEmpty;
        } else if (String.isBlank(lead.PostalCode)) {
            return Label.Lead_PostalCodeEmpty;
        }

        String accRecType = Label.Lead_CoveredAccountRecType;
        List<String> accList = accRecType.split(',');
        if (accList.contains(lead.Core_Existing_Covered_Account__r.RecordType.name)) {
            return Label.Lead_CoveredAccountError;
        }

        return null;
    }
    private static Void PopulateReviveDate(Lead ld) {
        if (ld.Core_Lead_Revive_Date_Original__c == null) {
                ld.Core_Lead_Revive_Date_Original__c = System.now();
            } else {
                ld.Core_Lead_Revive_Date_Most_Recent__c = System.now();
            }
    }
}