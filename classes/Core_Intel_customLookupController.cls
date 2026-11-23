/*****************************************************************************************************
Class Name :    Core_Intel_customLookupController
Description:    Server side controller for Core_Intel_customLookup component
Added By   :    Accenture - VK
Modified By:                      Date:07/25/2018                     Changes:None
******************************************************************************************************/
public with sharing class Core_Intel_customLookupController {


    /*****************************************************************************************************
Class Name :    fetchLookUpValues
Description:
Added By   :    Accenture - VK
Modified By:                      Date:07/25/2018                     Changes:None
******************************************************************************************************/
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String objectName, String sAdditionalFilter) {
        String sanitizedSearchKey = String.escapeSingleQuotes(searchKeyWord) + '%';
        String sanitizedObjectName = String.escapeSingleQuotes(objectName);
        String sanitizedAdditionalFilter = String.escapeSingleQuotes(sAdditionalFilter);
        sanitizedAdditionalFilter = sanitizedAdditionalFilter.replace('@quote;','\''); //replacing @quote; with '

        List < sObject > returnList = new List < sObject > ();
        String sQuery  = null;

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 10
        if ('Account'.equalsIgnoreCase(sanitizedObjectName)) { //; sanitizedObjectName == 'PartnerMarketingBudget'
            sQuery = 'SELECT Id, Name, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Channel_Program__c' ;
        }
        else
        {
            sQuery = 'SELECT Id, Name' ;
        }

        if ('campaign'.equalsIgnoreCase(sanitizedObjectName)){
            sQuery=sQuery+', Core_MDF_Priority__c, Core_MDF_Priority_2_nm__c,Core_MDF_Priority_3_nm__c, Core_MDF_Account__r.Name, Core_MDF_Account__c, '+
                'Core_MDF_Budget_Type_txt__c, Core_MDF_Channel_Program__c,Core_MDF_Reimbursement_Rate__c,'+
                'Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Technology__c';
        }

        sQuery = sQuery + ' FROM ' + sanitizedObjectName;
        if(UserInfo.getUserType().indexOf('PowerPartner') >= 0)
        {
            sQuery= sQuery + ' WHERE Name LIKE \'' + sanitizedSearchKey + '\' AND ' + sanitizedAdditionalFilter ;
            if ('campaign'.equalsIgnoreCase(sanitizedObjectName))
            {
                sQuery= sQuery + ' AND Core_MDF_External_Visibility_Date__c <= TODAY AND Core_MDF_Campaign_Status__c !=\''+ String.escapeSingleQuotes(System.Label.Core_MDF_Status_Cancelled)+'\' ORDER BY CreatedDate DESC LIMIT 10';
            }else
            {
                sQuery= sQuery + ' ORDER BY CreatedDate DESC LIMIT 10';
            }
        }
        else if(sanitizedAdditionalFilter != null && sanitizedAdditionalFilter != '' )
        {
            if ('campaign'.equalsIgnoreCase(sanitizedObjectName))
            {
                sQuery= sQuery + ' WHERE Name LIKE \'' + sanitizedSearchKey + '\' AND ' + sanitizedAdditionalFilter + ' AND Core_MDF_Campaign_Status__c !=\''+ String.escapeSingleQuotes(System.Label.Core_MDF_Status_Cancelled)+'\' ORDER BY CreatedDate DESC LIMIT 10';
            }
            else if ('Account'.equalsIgnoreCase(sanitizedObjectName))
            {
                sQuery= sQuery + ' WHERE Name LIKE \'' + sanitizedSearchKey + '\' AND ' + sanitizedAdditionalFilter + ' ORDER BY CreatedDate DESC LIMIT 10';
            }
            else
            {
                sQuery= sQuery + ' WHERE Title LIKE \'' + sanitizedSearchKey + '\' AND ' + sanitizedAdditionalFilter + ' ORDER BY CreatedDate DESC LIMIT 10';
            }
        }
        else
        {
                sQuery =  sQuery + ' WHERE Name LIKE \'' + sanitizedSearchKey + '\' ORDER BY CreatedDate DESC LIMIT 10';
        }
        List < sObject > lstOfRecords  = new List<sObject>();
        if(('campaign'.equalsIgnoreCase(sanitizedObjectName) && sanitizedAdditionalFilter.indexOf('startDate')>0 ) || (sanitizedObjectName != 'Campaign')){
            lstOfRecords = Database.query(sQuery);
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
        }

        return returnList;
    }
}