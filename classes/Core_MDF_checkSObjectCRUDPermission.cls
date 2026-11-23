/***************************************************************************************************** 
Class Name :    Core_MDF_checkSObjectCRUDPermission
Description:    Server side controller for Core_MDF_PFR_Community_New/Edit button
                component which checks whether user have object access or not
Added By   :    Accenture - SS 
Modified By:                      Date:09/04/2018                     Changes:None  
******************************************************************************************************/
public with sharing class Core_MDF_checkSObjectCRUDPermission {
	
	// ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
	// Static cache added at class level — shared across all 4 permission methods
	private static Map<String, Schema.DescribeSObjectResult> describeCache = new Map<String, Schema.DescribeSObjectResult>();

	// Private helper replaces getGlobalDescribe() in all 4 methods
	private static Schema.DescribeSObjectResult getSObjectDescribe(String objectName) {
    	if (String.isBlank(objectName)) { return null; }
    	String key = objectName.toLowerCase();
    	if (!describeCache.containsKey(key)) {
        	try {
            	Schema.DescribeSObjectResult[] results = Schema.describeSObjects(new List<String>{ objectName });
            	if (results != null && !results.isEmpty()) {
                	describeCache.put(key, results[0]);
            	}
        	} catch (Exception e) {
            			Core_MDF_CCP_UtilityClass.logError(e);
        	}
    	}
    	return describeCache.containsKey(key) ? describeCache.get(key) : null;
	}

    
    /***************************************************************************************************** 
    Method Name :   checkSObjectCreatePermission
    Added By   :    Accenture - SS
    Modified By:                      Date:09/04/2018                     Changes:None  
    *******************************************************************************************************/
        @AuraEnabled
        public static Boolean checkSObjectCreatePermission(String objectName){
        
        	// ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
	    	Schema.DescribeSObjectResult r = getSObjectDescribe(objectName);
	    	Boolean checkReadAccess = false;
			if(r != null){
    			checkReadAccess = r.createable;
			}
			return checkReadAccess;
        }
        
    /***************************************************************************************************** 
    Method Name :   checkSObjectEditPermission
    Added By   :    Accenture - SS
    Modified By:                      Date:09/04/2018                     Changes:None  
    ******************************************************************************************************/
        @AuraEnabled
        public static Boolean checkSObjectEditPermission(String objectName){
        	
			// ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
        	Schema.DescribeSObjectResult r = getSObjectDescribe(objectName);
	    	Boolean checkReadAccess = false;
			if(r != null){
    			checkReadAccess = r.updateable;
			}
			return checkReadAccess;
  
        }
        
    /***************************************************************************************************** 
    Method Name :   checkSObjectDeletePermission
    Added By   :    Accenture - KK
    Modified By:                      Date:08/08/2019                     Changes:None  
    ******************************************************************************************************/
        @AuraEnabled
        public static Boolean checkSObjectDeletePermission(String objectName){
     		
			// ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
        	Schema.DescribeSObjectResult r = getSObjectDescribe(objectName);
	    	Boolean checkReadAccess = false;
			if(r != null){
    			checkReadAccess = r.deletable;
			}
			return checkReadAccess;
  
        }
    
        /***************************************************************************************************** 
        Method Name :   getPFRDetails
        Added By   :    Accenture 
        Modified By:                      Date:02/08/2020                     Changes:None  
        ******************************************************************************************************/
        @AuraEnabled
        public static String getActivityRecordTypeDevname(String recordId){
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
           try{
            if(String.isNotBlank(recordId))
            {
                pfrList = [SELECT Id, RecordType.DeveloperName FROM PartnerFundRequest WHERE Id=:recordId];
            }
            }
            catch(Exception e){
                Core_MDF_CCP_UtilityClass.logError(e);
                throw new AuraHandledException(e.getMessage());
            }
            if(!pfrList.isEmpty())
            {
                return pfrList[0].RecordType.DeveloperName;
            }
            else
            {
                return null;
            }
        }
        
        /***************************************************************************************************** 
        Method Name :   checkForEditAccess
        Added By   :    Accenture 
        Modified By:                      Date:02/08/2020                     Changes:None  
        ******************************************************************************************************/
         @AuraEnabled
        public static Boolean checkForEditAccess(String objectName, String recTypeDevloperName, String status, Id activityId, Boolean proposalBasedIndicator, Date startDate){
            Core_MDF_PartnerFundRequestCreatePage.activityEditWrapper editableFields = new Core_MDF_PartnerFundRequestCreatePage.activityEditWrapper();
            Boolean hasFieldEditAccess = false;   
            try{
            editableFields = Core_MDF_PartnerFundRequestCreatePage.getFieldEditibilityMappingActivity(objectName, recTypeDevloperName, status, activityId, proposalBasedIndicator, startDate);
           
            List<String> editableFieldsList = editableFields.fieldApiName;
            if(editableFieldsList != null && !editableFieldsList.isEmpty()) {
                hasFieldEditAccess = true;
            }        
            }
            catch(Exception e){
                Core_MDF_CCP_UtilityClass.logError(e);
                throw new AuraHandledException(e.getMessage());
             }
            return hasFieldEditAccess;
        }
        
         @AuraEnabled
        public static PartnerFundRequest loadActivityRecord(String pfrId){
            Set<String> sQueryfields = new Set<String>();
            PartnerFundRequest pfrRecord = new PartnerFundRequest();
            try{
            String sanitiziedpfrId = String.escapeSingleQuotes(pfrId);
            String sQuery='SELECT ';
            for(Schema.FieldSetMember f : Schema.SObjectType.PartnerFundRequest.FieldSets.Core_MDF_Activity_FieldList.getFields()) {
                sQueryfields.add(f.getFieldPath());         
            }  
            for(String fs : sQueryfields){
                sQuery += fs + ',';
            }
                sQuery += 'Campaign.Name,Campaign.Core_MDF_Supports_legacy_program__c,Campaign.Core_MDF_Is_Opal__c, Campaign.Core_MDF_Priority__c,Campaign.Core_MDF_Opal_Budget_Type_Txt__c,Campaign.Core_MDF_Budget_Type_txt__c,Campaign.Core_MDF_Priority_2_nm__c,Campaign.Core_MDF_Priority_3_nm__c, '+
                ' Campaign.Core_MDF_Reimbursement_Rate__c,Campaign.Core_MDF_ReimbursementRate_pct__c,Campaign.Core_MDF_Strategic_Marketing_Fund_Ind__c,Campaign.Core_MDF_Account_Based_Ind__c,Campaign.Core_MDF_Proposal_Based_Ind__c,ChannelPartner.Name,RecordType.Name,RecordType.DeveloperName,Id, Campaign.Core_MDF_Product_Type__c, '+
                ' CreatedDate,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Campaign.Core_MDF_Budget_Cap__c, Campaign.Core_MDF_Available_BudgetCap_amt__c, Campaign.Core_MDF_Reimbursement_Amount_Amt__c, '+
                ' ChannelPartner.Core_MDF_Channel_Program__c, '+
                ' Campaign.StartDate, Campaign.EndDate, Campaign.Core_MDF_Account__c, Campaign.Core_MDF_Account__r.Name, Campaign.Core_MDF_Campaign_Status__c,'+
                ' Campaign.Core_MDF_Channel_Program__c,Campaign.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Campaign.Core_MDF_Technology__c, Campaign.Status, Campaign.Core_MDF_Market__c,Campaign.Core_MDF_Brand__c, ' +
                ' Campaign.Core_MDF_Approver_1_id__c, Campaign.Core_MDF_Approver_2_id__c, Campaign.Core_MDF_Approver_3_id__c, Campaign.Core_MDF_Approver_4_id__c, Campaign.Core_MDF_Approver_5_id__c, '+
                ' Campaign.Core_MDF_Approver_6_id__c, Campaign.Core_MDF_Approver_7_id__c, Campaign.Core_MDF_Approver_8_id__c, Campaign.Core_MDF_Approver_9_id__c, Campaign.Core_MDF_Approver_10_id__c, '+
                ' Campaign.Core_MDF_Claims_Created_Ind__c, Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__r.name,Core_MDF_Intel_Activity_Owner_Id__c,Core_MDF_Intel_Activity_Owner_Id__r.Name,Core_MDF_Member_Acceptor_Id__r.Name, Campaign.Core_MDF_Program__c,Core_MDF_Member_Owner_txt__c,Core_MDF_Approval_Stage__c,tolabel(Campaign.Core_MDF_Opal_Budget_Type_Txt__c) localizedBudType, Core_MDF_Is_Outcome_Based_Ind__c FROM PartnerFundRequest WHERE Id =:sanitiziedpfrId';
            //test code ends for Digital Media
             pfrRecord = Database.query(sQuery);
            }
            catch(Exception e){
                Core_MDF_CCP_UtilityClass.logError(e);
                throw new AuraHandledException(e.getMessage());
            }
            return pfrRecord;
        }
    /***************************************************************************************************** 
        Method Name :   getActRecordTypeDevNamePropInd
        Added By   :    Accenture 
        Modified By:                      Date:04-07-2022                   
    ******************************************************************************************************/
        /*@AuraEnabled
        public static Map<String, boolean> getActRecordTypeDevNamePropInd(String recordId){
            Map<String, boolean> pfrMap = new Map<String, boolean>();
            PartnerFundRequest pfr = [SELECT Id, RecordType.DeveloperName, Core_MDF_Proposal_Based_Ind__c 
                                      FROM PartnerFundRequest 
                                      WHERE Id=:recordId];
            if(pfr!=null){
            pfrMap.put(pfr.RecordType.DeveloperName, pfr.Core_MDF_Proposal_Based_Ind__c);
            }
            return pfrMap;
        }*/

        @AuraEnabled
        public static PartnerFundRequest getActRecordTypeDevNamePropInd(String recordId){
            Map<String, boolean> pfrMap = new Map<String, boolean>();
            PartnerFundRequest pfr = [SELECT Id, RecordType.Name, RecordType.DeveloperName, Core_MDF_Proposal_Based_Ind__c, Core_MDF_Is_Outcome_Based_Ind__c 
                                      FROM PartnerFundRequest 
                                      WHERE Id=:recordId LIMIT 1];
            return pfr;
        }
        
    /***************************************************************************************************** 
    Method Name :   checkSObjectReadPermission
    Added By   :    Accenture 
    Modified By:    Vinodhini/Aswin              Date:21/May/2022                     Changes:None  
    ******************************************************************************************************/
        @AuraEnabled
        public static Boolean checkSObjectReadPermission(String objectName){
            
	    	// ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
        	Schema.DescribeSObjectResult r = getSObjectDescribe(objectName);
	    	Boolean checkReadAccess = false;
			if(r != null){
    			checkReadAccess = r.accessible;
			}
			return checkReadAccess;
        }
    /***************************************************************************************************** 
    Method Name :   checkRecordEditAccess
    Added By   :    Accenture 
    Modified By:    Mayuri             Date:                     Changes:  
    Description : Checked whether logged in user has edit access for the record or not
    ******************************************************************************************************/
        @AuraEnabled
        public static Boolean checkRecordEditAccess(Id RecordId){
            Boolean hasRecEditAccess = false;
            try{
            UserRecordAccess userAccess = [SELECT RecordId, HasEditAccess
                                               FROM UserRecordAccess 
                                               WHERE UserId=:UserInfo.getUserId() AND RecordId =: RecordId LIMIT 1];
            if(userAccess != Null) {
                if(userAccess.HasEditAccess) {
                      hasRecEditAccess = true;
                }   
            }
            }catch(Exception e){
                Core_MDF_CCP_UtilityClass.logError(e);
                throw new AuraHandledException(e.getMessage());
            }
        return hasRecEditAccess;
        }
        
    }