/***********************************************************************************************************************************
* Class Name  : PMP_CompanyInfoNotificationsBatch 
* Version     : 1.0 
* Created Date: 05/22/2020
* Modification Log :
* Developer:Abhishek
* Description : Batch to send apex emails based on the conditions present in the Core_Apex_EmailNotification__c records
* batch Size: Batch size should always be 1.[Very Important] 
************************************************************************************************************************************/

global class PMP_CompanyInfoNotificationsBatch implements Database.Batchable<sObject>, Database.Stateful{ 


    global Database.QueryLocator  start(Database.BatchableContext bc) {
        //Query the apex email records related to the PMP_Company__c Object.
        //Very Important- Batch size should always be 1!
       // string query  = PMP_Utility.queryAllFields('Core_Apex_EmailNotification__c', true);
       // query = query + ' Where Core_Object_Nm__c = \'PMP_Company__c\'';
       string query = 'SELECT Id, Core_Query_String_Txt__c, Core_Allowed_Permission_Nm__c, Core_Date_Reference_Txt__c, Core_Email_Template_Nm__c, Core_IsActive_Ind__c, Core_IsRecurring_Ind__c, Core_NumberOfDays_Nbr__c ' +
            			 ' FROM Core_Apex_EmailNotification__c' +
            			' WHERE Core_Object_Nm__c = \'PMP_Company__c\'';
        Return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Core_Apex_EmailNotification__c> records) {
        Core_Apex_EmailNotification__c apexEmailRec = records.isEmpty() ? null : records[0];
        if (apexEmailRec != null && apexEmailRec.Core_IsActive_Ind__c) {
            List<String> allowedPermissionSets = apexEmailRec.Core_Allowed_Permission_Nm__c.split(',');
            String query = PMP_Utility.queryAllFields('PMP_Company__c', true);

            if (!String.isEmpty(apexEmailRec.Core_Query_String_Txt__c)) {
                query += ' WHERE ' + apexEmailRec.Core_Query_String_Txt__c;
            }

            List<PMP_Company__c> compInfo = Database.query(query);
            List<PMP_Company__c> companyInfoList = new List<PMP_Company__c>();
            Map<Id, Id> userCompanyMap = new Map<Id, Id>();

            if (!compInfo.isEmpty() && !String.isBlank(apexEmailRec.Core_Date_Reference_Txt__c)) {
                for (PMP_Company__c comp : compInfo) {
                    if (comp.get(apexEmailRec.Core_Date_Reference_Txt__c) != null) {
                        Date referenceDate = Date.valueOf(comp.get(apexEmailRec.Core_Date_Reference_Txt__c));

                        if (apexEmailRec.Core_IsRecurring_Ind__c) {
                            Integer differenceDays = referenceDate.daysBetween(Date.today());
                            Integer modValue = Math.mod(differenceDays, Integer.valueOf(apexEmailRec.Core_NumberOfDays_Nbr__c));

                            if (differenceDays >= apexEmailRec.Core_NumberOfDays_Nbr__c && modValue == 0) {
                                companyInfoList.add(comp);
                            }
                        } else {
                            if (referenceDate.daysBetween(Date.today()) == apexEmailRec.Core_NumberOfDays_Nbr__c) {
                                companyInfoList.add(comp);
                            }
                        }
                    }
                }
            }

            if (!companyInfoList.isEmpty()) {
                userCompanyMap = PMP_Utility.fetchUsersMapFromPagMember(companyInfoList, allowedPermissionSets);

                if (!userCompanyMap.keySet().isEmpty() && !Test.isRunningTest()) {
                    PMP_Utility.sendEmailAndLogData(apexEmailRec.Core_Email_Template_Nm__c, userCompanyMap);
                } else if (Test.isRunningTest()) { // TODO: Remove after email logging logic is implemented
                    List<PMP_Company__c> compList = new List<PMP_Company__c>();

                    for (PMP_Company__c comp : companyInfoList) {
                        comp.Name += '_EmailSent';
                        compList.add(comp);
                    }

                    update compList;
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc){
        
    }    
    
}