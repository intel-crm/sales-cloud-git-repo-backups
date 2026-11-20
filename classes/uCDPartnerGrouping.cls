/****************************************************************************************************************************
Apex Class Name     : uCDPartnerGrouping 
Version             : 1.0
Created Date        : Aug 2024
Function            : Handler class fro Relink scnearios

Modification Log    :
* Developer                  Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Utkarsh                   Aug-2024                 Handler class fro Relink scnearios
* Nandana                   May- 2025                Optimized the code
****************************************************************************************************************************/
public with sharing class uCDPartnerGrouping {
    public static final String LOG_ENTRY_ORIGIN = 'uCDPartnerGrouping';
    public static final String LOG_ENTRY_PROJECT = 'IPA';
    public static final String LOG_ENTRY_SCOPE = 'uCDPartnerGrouping';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String STATUS_NEW = 'NEW';
    public static final String GROUPING_METHOD_GLOBAL = 'GLBL';
    public static final String GROUPING_METHOD_LOB = 'LINEOFBUSNS';
    public static final Id INTEL_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();

    /**
        *  @description      : gets the accounts in the hierarchy to be associated to 1PID
        *  @name             : getAccountHierarchy
        *  @param            : String recordId, String picklistValue, boolean showFullHierarchy
        *  @throws exception : NONE
        * @userstory         : 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountHierarchy(String recordId, String picklistValue, Boolean showFullHierarchy) {
        if (String.isBlank(recordId) || String.isBlank(picklistValue)) {
            return new List<Account>();
        }
        //Querying UCD primary
        Account accRecord = [
            SELECT Id, Name, Core_Unified_Global_Customer_BP_Id__c, Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c,
                   Unified_Hierarchy_View__c, Core_Intel_Partner_Alliance_PartnerGroup__c, Core_Unified_Intermediate_Customer_BP_Id__c,Core_Unified_Intermdt_Customer_2_BP_Id__c,
                   Core_Customer_Aggregation_Type__c
            FROM Account
            WHERE Id = :recordId AND RecordTypeId = :INTEL_ACCOUNT_RT_ID
        ];

        if (accRecord == null) {
            return new List<Account>();
        }

        List<Account> accList = new List<Account>();

        //returning null to display error message
        if (!showFullHierarchy) {
            if ((picklistValue == 'Line of Business' && accRecord.Core_Customer_Aggregation_Type__c == 'UNFD_GLBL_CUST') ||
                (picklistValue == 'Global' && accRecord.Core_Customer_Aggregation_Type__c == 'UNFD_INTRMD_CUST')) {
                return null;
            }

            if (picklistValue == 'Line of Business' &&
                accRecord.Core_Business_Party_Id__c != accRecord.Core_Unified_Intermediate_Customer_BP_Id__c &&
                accRecord.Core_Business_Party_Id__c != accRecord.Core_Unified_Intermdt_Customer_2_BP_Id__c) {
                return null;
            }
	    
            accList.add(accRecord);
        } 
        else {
            if (picklistValue == 'Global') {
                accList.addAll(getChildAccounts(accRecord.Core_Unified_Global_Customer_BP_Id__c, picklistValue));
            } else if (picklistValue == 'Line of Business') {
                if (accRecord.Core_Business_Party_Id__c == accRecord.Core_Unified_Intermediate_Customer_BP_Id__c) {
                    accList.addAll(getChildAccounts(accRecord.Core_Unified_Intermediate_Customer_BP_Id__c, 'intrmd level 1'));
                } else if (accRecord.Core_Business_Party_Id__c == accRecord.Core_Unified_Intermdt_Customer_2_BP_Id__c) {
                    accList.addAll(getChildAccounts(accRecord.Core_Unified_Intermdt_Customer_2_BP_Id__c, 'intrmd level 2'));
                }
            }
        }

        return accList;
    }

    /**
        *  @description      : queries accounts based on the unified ids and level provided
        *  @name             : getChildAccounts
        *  @param            : String parentGlobalAccountId, String level
        *  @throws exception : NONE
        * @userstory         : 
    **/
    public static List<Account> getChildAccounts(String parentGlobalAccountIds, String level) {
        if (parentGlobalAccountIds == null) {
            return new List<Account>();
        }
	
        List<Account> accList = new List<Account>();
        
        String queryFilter;
            if (level == 'intrmd level 1') {
                queryFilter = 'Core_Unified_Intermediate_Customer_BP_Id__c =:parentGlobalAccountIds';
            } else if (level == 'intrmd level 2') {
                queryFilter = 'Core_Unified_Intermdt_Customer_2_BP_Id__c =:parentGlobalAccountIds';
            } else if (level == 'Global') {
                queryFilter = 'Core_Unified_Global_Customer_BP_Id__c =:parentGlobalAccountIds';
            }
        
        String Finalquery = 'SELECT Id, Name, Core_Unified_Global_Customer_BP_Id__c, Core_Unified_Global_Customer_Name__c, Core_Business_Party_Id__c, Core_Parent_Business_Party_Id__c,'+
                            'Unified_Hierarchy_View__c, Core_Intel_Partner_Alliance_PartnerGroup__c, Core_Unified_Intermediate_Customer_BP_Id__c,'+
                            'Core_Unified_Intermdt_Customer_2_BP_Id__c, ParentId,'+
                            '(select Id from Partner_Account_Group_Members1__r where Core_Inactive_Ind__c =false limit 1) '+
                            'FROM Account '+
                            'WHERE RecordTypeId = :INTEL_ACCOUNT_RT_ID AND '+
                            'Core_Deactivated__c = false AND '+queryFilter;

            
        List<Account> childAccounts = Database.query(Finalquery);
            for(Account acc : childAccounts){
                if(acc.Partner_Account_Group_Members1__r.size()==0){
                    accList.add(acc);
                }
            }
        return accList;
    }

    /**
        *  @description      : gets the picklist values to be displayed
        *  @name             : getPicklistValues
        *  @param            : String objectName, String fieldName
        *  @throws exception : NONE
        * @userstory         : 
    **/
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectName, String fieldName) {

        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

        List<String> picklistValues = new List<String>();
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getLabel());
        }

        return picklistValues;
    }

    /**
        *  @description      : creates inbound records based on the account id and picklist value provided
        *  @name             : createInboundRecords
        *  @param            : String accountId, String opidName, String picklistValue, String comments
        *  @throws exception : NONE
        * @userstory         : 
    **/
    @AuraEnabled 
    public static void createInboundRecords(String accountId, String opidName, String picklistValue, String comments) {
        if (String.isBlank(accountId) || String.isBlank(picklistValue)) {
            return;
        }
        String errorLogMsg ='';

        List<Account> accList = getAccountHierarchy(accountId, picklistValue, true);
        if (accList.isEmpty()) {
            return;
	    }
        Integer ucd_OnePartnerID = integer.valueOf(PRM_ACMTriggerHandlerNew.fetchOpidNumber());
        List<Core_OnePartner_Inbound_Message__c> inboundMessages = new List<Core_OnePartner_Inbound_Message__c>();
            for (Account acc : accList) {
                Core_OnePartner_Inbound_Message__c inboundMessage = new Core_OnePartner_Inbound_Message__c();
                inboundMessage.Core_OnePartnerID__c = ucd_OnePartnerID;
                inboundMessage.Core_OnePartner_Account_Name__c = picklistValue == 'Line of Business' ? opidName : acc.Core_Unified_Global_Customer_Name__c+' - Global';
                inboundMessage.Core_SalesCloud_AccountID__c = acc.Id;
                inboundMessage.Core_Status__c = STATUS_NEW;
                inboundMessage.Core_PAG_Grouping_Method__c = picklistValue == 'Global' ? GROUPING_METHOD_GLOBAL : GROUPING_METHOD_LOB;
                inboundMessage.Core_CIM_ID__c = Decimal.valueOf(acc.Core_Business_Party_Id__c);
                inboundMessage.Core_Effective_Start_Date_Time__c = System.now();
                inboundMessage.Primary_Account__c = acc.id==accountId ? TRUE : FALSE;
                inboundMessage.Comments__c = comments;
                inboundMessage.Delink_Association_User__c = UserInfo.getUserId();
                inboundMessages.add(inboundMessage);
            }

	    //insertion of inbounds and tracker record creation
        if (!inboundMessages.isEmpty()) {
            try {
                PRM_ACMTriggerHandlerNew.updateOpidNumber(inboundMessages);
                Database.SaveResult[] saveResultList = Database.insert(inboundMessages, false);
                List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
                Map<id,Core_OnePartner_Inbound_Message__c> inboundRecMap = new Map<id,Core_OnePartner_Inbound_Message__c>(inboundMessages);
                
                for(Database.SaveResult result: saveResultList){//loop start
                    if(result.isSuccess()){
                        Id sId = result.getId();
                        if(sId!=null && inboundRecMap.keySet().contains(sId) ){
                            PRM_Tracker__c tracker = new PRM_Tracker__c();
                            tracker.PRM_Type__c = 'OPID Updates';
                            tracker.PRM_Milestone__c = 'INBND_CRTD';
                            tracker.PRM_Location_Account__c = inboundRecMap.get(sId).Core_SalesCloud_AccountID__c;
                            tracker.PRM_Milestone_Display_Name__c = 'OPID Request Created';
                            tracker.PRM_Completed__c = true;
                            trackerList.add(tracker);    
                        }
                    }
                    else if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()) {
                            errorLogMsg+= 'Message: ' + err.getMessage() + '\n'
                                        + 'Fields: ' + err.Fields.toString() + '\n'
                                        + 'StatusCode: ' + err.getStatusCode() + '\n';
                        }
                    }
                }//loop ends here..
                if (!trackerList.isEmpty()) {
                    List<Database.SaveResult> insertTrackerResult = new List<Database.SaveResult>();
                    insertTrackerResult = Database.insert(trackerList,false); 
                    for(Database.SaveResult result: saveResultList){//loop start
                        if (!result.isSuccess()){
                            for (Database.Error err : result.getErrors()) {
                                errorLogMsg+= 'Message: ' + err.getMessage() + '\n'
                                            + 'Fields: ' + err.Fields.toString() + '\n'
                                            + 'StatusCode: ' + err.getStatusCode() + '\n';
                            }
                        }
                    }//loop end
                }
            } 
	        catch (Exception ex) {
                errorLogMsg+= ex.getMessage();
		    }
	        finally{
                Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT,LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY,'',errorLogMsg ,'', '', '');
	        }
        }
}
}