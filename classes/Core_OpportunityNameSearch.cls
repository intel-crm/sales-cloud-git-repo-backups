/**************************************************************************************************************
Apex Class Name:  Core_OpportunityNameSearch
Version     : 1.0 
Created Date: 11 APR 2016
Function    : Custom REST service for Opportunity Name Search
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Dave Hood             04/11/2016        Initial version
* Biswa                 05/20/2024        Replaced CIM ID with Unified ID
***************************************************************************************************************/
@RestResource(urlMapping='/Opportunity/Search')
global without sharing class Core_OpportunityNameSearch {

    global class OpportunityInfo {
        @testVisible String Id = '';
        @testVisible String Name = '';
        @testVisible String AccountName = '';
        //@testVisible String AccountCIMId = ''; 
        @testVisible String AccountUnifiedId = '';
        
        OpportunityInfo(String oppId, String oppName, String acctName, String acctUnifiedId) {
            Id = oppId;
            Name = oppName;
            AccountName = acctName; 
            AccountUnifiedId = acctUnifiedId;//AccountCIMId = acctCIMId;
        }
    }

    // Call with a request body like this:
    // { "wwid" : "99999992", "searchString" : "testing opp" }
    // { "wwid" : "99999992", "searchString" : "006210000024v17AAA" }
    // { "wwid" : "99999992", "searchString" : "006210000024v17AAA,006210000022u0IAAQ,00621000002GZL4AAO" }
    // 
    // Response looks like this:
    // [ { "Name" : "", "Id" : "006210000022oPEAAY", "AccountName" : "" },
    //   { "Name" : "testing oppty", "Id" : "006210000022olAAAQ", "AccountName" : "PC Source, LLC" },
    //   { "Name" : "Testing Oppty Geo Calculation", "Id" : "006210000027AEMAA2", "AccountName" : "Dave's Pizza" } ]
    //
    // For testing, use real WWIDs, or these fake WWIDs (in Dev):
    //   Sales Rep1 Test: 99999991
    //   Test Agent1 VSC: 99999992
    //   
    @HttpPost
    global static List<OpportunityInfo> doPost(String wwid, String searchString) {
        
        RestResponse res = RestContext.response;
        Boolean isSalesforceUser = true;
        List<OpportunityInfo> opptyInfoToReturn = new List<OpportunityInfo>();
        boolean ucdSwitch = Core_CRM_Utility.isUCDSwitchOn(); //TWC4767-3431 - implementation of UCD and CIM logic switch
        Id userId;
        List<User> matchingUserIds = [select Id from User where Core_WWID__c = :wwid and IsActive = true];
        
        if (matchingUserIds.size() == 0) {
            isSalesforceUser = false;
        }
        else if (matchingUserIds.size() > 1) {
            // Originally we were returning 300 and null here, but it was requested that we handle it like a non-Salesforce user
            //res.statusCode = 300;
            //return null;
            isSalesforceUser = false;
        }
        else {
            isSalesforceUser = true;
            userId = matchingUserIds[0].Id;
        }
        
        List<Opportunity> matchingOpptys;
        
        if (searchString.left(3) == '006') {
            // Search by ID, which can be one or multiple
            List<String> oppIds = searchString.split(',');
            matchingOpptys = [select Id, Name, Account.Name, Account.Core_CIM_ID__c, Account.Core_Business_Party_Id__c from Opportunity where Id in :oppIds];
        }
        else {
            // Search across all opportunities in the system for the given search string.
            // Note: for the Opportunity object, "NAME FIELDS" is only the Name field.
            matchingOpptys = [FIND :searchString IN NAME FIELDS
                              RETURNING Opportunity(Id, Name, Account.Name,Account.Core_CIM_ID__c, Account.Core_Business_Party_Id__c LIMIT 2000)][0];
        }

        if (matchingOpptys.size() > 10) {
            // Return an error, saying they need to be more specific
            res.statusCode = 413;
            return null;
        }
        else {
            if (isSalesforceUser) {
                // Place the opportunity IDs in a set, and the names in a map, for later use
                Set<Id> matchingOpptyIds = new Set<Id>();
                Map<Id,String[]> opptyIdMap = new Map<Id,String[]>();
                
                for (Opportunity oppty : matchingOpptys) {
                    matchingOpptyIds.add(oppty.Id);
                    //if(ucdSwitch == true) {
                    if(String.isNotBlank(oppty.Account.Core_Business_Party_Id__c)) { //TWC4767-3983
                        opptyIdMap.put(oppty.Id, new List<String>{oppty.Name, oppty.Account.Name, oppty.Account.Core_Business_Party_Id__c});
                    }
                    else{ //TWC4767-3983
                        opptyIdMap.put(oppty.Id, new List<String>{oppty.Name, oppty.Account.Name, oppty.Account.Core_CIM_ID__c});
                    }
                }
                
                // Query the user's access to the set of opportunity IDs
                List<UserRecordAccess> opptyAccessList = [select RecordId, HasReadAccess from UserRecordAccess
                                                          where UserId = :userId and RecordId in :matchingOpptyIds];
                
                // Build our list of opportunity info to return, based on the user's access (if they don't have access, leave it blank)
                for (UserRecordAccess access : opptyAccessList) {
                    if (access.HasReadAccess) {
                        opptyInfoToReturn.add(new OpportunityInfo(access.RecordId, opptyIdMap.get(access.RecordId)[0],
                                                                  opptyIdMap.get(access.RecordId)[1], opptyIdMap.get(access.RecordId)[2]));
                    }
                    else {
                        opptyInfoToReturn.add(new OpportunityInfo(access.RecordId, '', opptyIdMap.get(access.RecordId)[1],
                                                                  opptyIdMap.get(access.RecordId)[2]));
                    }
                }
                
                res.statusCode = 200;
                return opptyInfoToReturn;
            }
            else {
                for (Opportunity oppty : matchingOpptys) {
                    //if(ucdSwitch == true) { //TWC4767-3983
                    if(String.isNotBlank(oppty.Account.Core_Business_Party_Id__c)) {
                        opptyInfoToReturn.add(new OpportunityInfo(oppty.Id, '', oppty.Account.Name, oppty.Account.Core_Business_Party_Id__c));
                    }
                    else { //TWC4767-3983
                        opptyInfoToReturn.add(new OpportunityInfo(oppty.Id, '', oppty.Account.Name, oppty.Account.Core_CIM_ID__c));
                    }
                }
                res.statusCode = 200;
                return opptyInfoToReturn;
                
            }
        }
    }
}