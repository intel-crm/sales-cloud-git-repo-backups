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
        String legacyBudget ='Yes';
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 10
        if ('Account'.equalsIgnoreCase(sanitizedObjectName)) { //; sanitizedObjectName == 'PartnerMarketingBudget'
            sQuery = 'SELECT Id, Name, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Channel_Program__c, Core_MDF_CoMarketing_Ultimate_Account__c';
        }
        else
        {
            sQuery = 'SELECT Id, Name' ;
        }

        if ('campaign'.equalsIgnoreCase(sanitizedObjectName)){
            sQuery=sQuery+',Core_MDF_Supports_legacy_program__c, Core_MDF_Is_Opal__c, Core_MDF_Priority__c,Core_MDF_Program__c, Core_MDF_Priority_2_nm__c,Core_MDF_Priority_3_nm__c, Core_MDF_Account__r.Name, Core_MDF_Account__c,'+
                'Core_MDF_Industry_Nm__c, Core_MDF_Initiative_nm__c, Core_MDF_Ecosystem_Partner_Nm__c, Core_MDF_IPA_Priority_nm__c, Core_MDF_Focus_Area_nm__c,'+
                'Core_MDF_Budget_Type_txt__c,Core_MDF_Opal_Budget_Type_Txt__c,tolabel(Core_MDF_Opal_Budget_Type_Txt__c) localizedBudType, Core_MDF_Channel_Program__c,Core_MDF_Reimbursement_Rate__c,Core_MDF_ReimbursementRate_pct__c,RecordType.Name,RecordType.DeveloperName,'+
                'Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Channel_Program__r.Name, Core_MDF_Technology__c,Core_MDF_Audience__c,Core_MDF_Product_Type__c,Core_MDF_Brand__c,Core_MDF_Market__c,Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__r.name,Core_MDF_Strategic_Marketing_Fund_Ind__c,Core_MDF_Proposal_Based_Ind__c, Core_MDF_Reimbursement_Amount_Amt__c, Core_MDF_Activity_Category_Type__c, Core_MDF_Activity_Category__c, Core_MDF_CampOutcomeOpt_In_Ind__c';
        }

        sQuery = sQuery + ' FROM ' + sanitizedObjectName;
        if(UserInfo.getUserType().indexOf('PowerPartner') >= 0)
        {
            sQuery= sQuery + ' WHERE Name LIKE \'' + sanitizedSearchKey + '\' AND ' + sanitizedAdditionalFilter ;
            if ('campaign'.equalsIgnoreCase(sanitizedObjectName))
            {   
                
              //sQuery= sQuery + ' AND Core_MDF_External_Visibility_Date__c <= TODAY AND Status !=\''+ String.escapeSingleQuotes(System.Label.Core_MDF_Status_Cancelled)+'\' ORDER BY CreatedDate DESC LIMIT 10';
                sQuery= sQuery + ' AND Core_MDF_External_Visibility_Date__c <= TODAY AND Status !=\''+ String.escapeSingleQuotes(System.Label.Core_MDF_Status_Cancelled)+
                    '\' AND Core_MDF_Opal_Budget_Type_Txt__c!=\''+String.escapeSingleQuotes(System.Label.Core_MDF_BudgetType_CCF1_0)+
                    '\' AND Core_MDF_Opal_Budget_Type_Txt__c!=\''+String.escapeSingleQuotes(System.Label.Core_MDF_BudgetType_DCF1_0)+
                    '\' AND RecordType.DeveloperName!=\''+String.escapeSingleQuotes(System.Label.Core_MDF_PFR_SPCF)+
                    '\' AND RecordType.DeveloperName!=\''+String.escapeSingleQuotes(System.Label.Core_MDF_PFR_CCF_Boost)+'\' ORDER BY CreatedDate DESC LIMIT 10';
            }else
            {
                if ('Account'.equalsIgnoreCase(sanitizedObjectName)){
                    //Akash - as part of this story changed order by created date desc to order by name asc for account lookup,[KIIT] Sort the custom account list picklist based on ascending order
                	sQuery= sQuery + ' ORDER BY Name ASC';
                }else{
                    sQuery= sQuery + ' ORDER BY CreatedDate DESC LIMIT 10';
                }
            }
        }
        else if(sanitizedAdditionalFilter != null && sanitizedAdditionalFilter != '' )
        {
            if ('campaign'.equalsIgnoreCase(sanitizedObjectName))
            {
                //sQuery= sQuery + ' WHERE Name LIKE \'' + sanitizedSearchKey + '\' AND ' + sanitizedAdditionalFilter + ' AND Status !=\''+ String.escapeSingleQuotes(System.Label.Core_MDF_Status_Cancelled)+'\' ORDER BY CreatedDate DESC LIMIT 10';
                sQuery= sQuery + ' WHERE Name LIKE \'' + sanitizedSearchKey + '\' AND ' + sanitizedAdditionalFilter + ' AND Status !=\''+ String.escapeSingleQuotes(System.Label.Core_MDF_Status_Cancelled)+
                    '\' AND Core_MDF_Opal_Budget_Type_Txt__c!=\''+String.escapeSingleQuotes(System.Label.Core_MDF_BudgetType_CCF1_0)+
                    '\' AND Core_MDF_Opal_Budget_Type_Txt__c!=\''+String.escapeSingleQuotes(System.Label.Core_MDF_BudgetType_DCF1_0)+
                    '\' AND RecordType.DeveloperName!=\''+String.escapeSingleQuotes(System.Label.Core_MDF_PFR_SPCF)+
                    '\' AND RecordType.DeveloperName!=\''+String.escapeSingleQuotes(System.Label.Core_MDF_PFR_CCF_Boost)+'\' ORDER BY CreatedDate DESC LIMIT 10';
            	  
            }
            else if ('Account'.equalsIgnoreCase(sanitizedObjectName))
            {
                //Akash - as part of this story changed order by created date desc to order by name asc for account lookup,[KIIT] Sort the custom account list picklist based on ascending order
                sQuery= sQuery + ' WHERE Name LIKE \'' + sanitizedSearchKey + '\' AND ' + sanitizedAdditionalFilter + ' ORDER BY Name ASC LIMIT 10';
            }
            else
            {
                sQuery= sQuery + ' WHERE Title LIKE \'' + sanitizedSearchKey + '\' AND ' + sanitizedAdditionalFilter + ' ORDER BY CreatedDate DESC LIMIT 10';
            }
        }
        else
        {       //Akash - as part of this story changed order by created date desc to order by name asc for account lookup,[KIIT] Sort the custom account list picklist based on ascending order
                if ('Account'.equalsIgnoreCase(sanitizedObjectName)){
                    sQuery =  sQuery + ' WHERE Name LIKE \'' + sanitizedSearchKey + '\' ORDER BY Name ASC LIMIT 10';
                }
                else{
                    sQuery =  sQuery + ' WHERE Name LIKE \'' + sanitizedSearchKey + '\' ORDER BY CreatedDate DESC LIMIT 10';
                }
        }
        List < sObject > lstOfRecords  = new List<sObject>();
        List < sObject > lstOfAccounts  = new List<sObject>();
        
        Map < Id,sObject > mapOfAccount= new Map < Id,sObject > ();
	// Skip the partner account search if no filter is provided to avoid a query error.
        Boolean skipPartnerAccountLookup = 'Account'.equalsIgnoreCase(sanitizedObjectName) && UserInfo.getUserType() == 'PowerPartner' && String.isBlank(sanitizedAdditionalFilter);
        if (!skipPartnerAccountLookup && (('campaign'.equalsIgnoreCase(sanitizedObjectName) && sanitizedAdditionalFilter.indexOf('startDate') > 0) || sanitizedObjectName != 'Campaign')) {
        //if(('campaign'.equalsIgnoreCase(sanitizedObjectName) && sanitizedAdditionalFilter.indexOf('startDate')>0 ) || (sanitizedObjectName != 'Campaign')){
            lstOfRecords = Database.query(sQuery);
            
            if('Account'.equalsIgnoreCase(sanitizedObjectName) && UserInfo.getUserType()=='PowerPartner'){
                for (sObject obj: lstOfRecords) {
                    mapOfAccount.put(obj.Id,obj);
                }
            }else{
                returnList = lstOfRecords;
            }
            /*for (sObject obj: lstOfRecords) {
                if('Account'.equalsIgnoreCase(sanitizedObjectName) && UserInfo.getUserType()=='PowerPartner'){
                    mapOfAccount.put(obj.Id,obj); 
                }else{
                    returnList.add(obj);
                }
                
            }*/
            if(!mapOfAccount.isEmpty()){
                for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id,Core_MDF_Account__c, Core_MDF_User__c,
                                                                  Core_MDF_Account__r.Name,Core_MDF_Account__r.Core_MDF_Channel_Program__c,
                                                                  Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c
                                                                  FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                                  WHERE Core_MDF_Account__c IN : mapOfAccount.keyset() 
                                                                  AND Core_MDF_Active_Ind__c = TRUE AND Core_MDF_User__c=:UserInfo.getUserId()
                                                                  AND (Core_MDF_User__r.IsActive = TRUE OR Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE)]){   
                                                                      if(mapOfAccount.containskey(pnum.Core_MDF_Account__c)){
                                                                          sObject acc = mapOfAccount.get(pnum.Core_MDF_Account__c);
                                                                          lstOfAccounts.add(acc);
                                                                      }
                                                                      if(lstOfAccounts.size()<=10){
                                                                         returnList = lstOfAccounts;
                                                                      }else{
                                                                          break;
                                                                      }
                                                                      
                                                                  }
            }
        }

        return returnList;
    }
}