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
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String objectName,String sAdditionalFilter) {
        String searchKey = searchKeyWord + '%';
        //String Cancelled= System.Label.Core_MDF_Status_Cancelled;
        //system.debug('sAdditionalFilter-->' + sAdditionalFilter);
        List < sObject > returnList = new List < sObject > ();
        
        string additionalFilter = sAdditionalFilter;
        String sQuery  = null;
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 10 
        if(objectName=='PartnerMarketingBudget'){
            sQuery  =  'select id,Title' ;
        }
        else
        {
            sQuery  =  'select id,Name' ;
        }
        //String ccfProgramId = [Select id from ChannelProgram where name = 'Client Co-Marketing Fund' LIMIT 1].id ;
        //String dcfProgramId = [Select id from ChannelProgram where name = 'Data Center Co-Marketing Fund' LIMIT 1].id ;
        
        if(objectName == 'Campaign'){
            sQuery=sQuery+', Core_MDF_Priority__c, Core_MDF_Priority_2_nm__c,Core_MDF_Priority_3_nm__c, Core_MDF_Account__r.Name, Core_MDF_Account__c, '+
                'Core_MDF_Budget_Type_txt__c, Core_MDF_Channel_Program__c,'+
                'Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Technology__c';
        } 
        
        
        
        sQuery=sQuery+' From '+objectName;
        if(UserInfo.getUserType().indexOf('PowerPartner')>=0)
        {
            sQuery= sQuery + ' where Name LIKE: searchKey AND ' + additionalFilter ;
            if (objectName == 'campaign')
            {
                sQuery= sQuery + ' AND Core_MDF_External_Visibility_Date__c <= TODAY AND Core_MDF_Campaign_Status__c !=\''+ String.escapeSingleQuotes(System.Label.Core_MDF_Status_Cancelled)+'\' order by createdDate DESC limit 10';
            }
            
            system.debug('IF Block: External User Portal = ' +sQuery);
        }
        else if(sAdditionalFilter != null && sAdditionalFilter != '' )
        { 
            if (objectName == 'campaign')
            { 
                sQuery= sQuery + ' where Name LIKE: searchKey AND ' + additionalFilter + ' AND Core_MDF_Campaign_Status__c !=\''+ String.escapeSingleQuotes(System.Label.Core_MDF_Status_Cancelled)+'\' order by createdDate DESC limit 10'; 
            }
            else if(objectName == 'Account')
            {
                sQuery= sQuery + ' where Name LIKE: searchKey AND ' + additionalFilter + ' order by createdDate DESC limit 10';  
            }
            else
            {
                sQuery= sQuery + ' where Title LIKE: searchKey AND ' + additionalFilter + ' order by createdDate DESC limit 10';  
            }
            system.debug('Else if :External User Portal = ' +sQuery);
        }
        else{
                if(objectName == 'PartnerMarketingBudget')
                {
               		 sQuery =  sQuery + ' where Title LIKE: searchKey order by createdDate DESC limit 10';
                }
            else
            {
                 sQuery =  sQuery + ' where Name LIKE: searchKey order by createdDate DESC limit 10';
            }
            system.debug('Else :External User Portal = ' +sQuery);
        }
        system.debug('sQuery'+sQuery);
        List < sObject > lstOfRecords  = new List<sObject>();
        if((objectName == 'Campaign' && sAdditionalFilter.indexOf('startDate')>0 ) || (objectName != 'Campaign')){
            lstOfRecords = Database.query(sQuery);
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
        }
        system.debug('lstOfRecords'+lstOfRecords);
        return returnList;
    }
}