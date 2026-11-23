public without sharing class Core_IPS_CaseTriggerHandler{
    /***********************************************************************************************
Version     : 1.0 
Created Date: 09 Oct 2015
Test Class  : Core_IPS_CaseTriggerHandler_Test 
Function    : This method executes Case Assignment Rule 
Input Parameters: Case Old Map, Case New List
Output Parameters: None 
Transactions: After Insert, After Update
Description: This method executes Case Assignment Rule as follows:
After insertion of case
After Update: If product on case changes or if GEC case is approved then assignment rule is retriggered.
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 2(one per transaction)
Number of Queries in Loop: 0
Number of Queries from Called methods:2
Number of times called: Once for trigger execution  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/09/2015              Created
* Jayaprakash T              10/28/2015              Updated code to check if GEC Approved flag is changed
* Abhishek Arya              02/04/2016              Updated TriggerUserEmail to False.   
* Ajay D S                   10/24/2017              DE31600 fix
* Aayushi Singhal            12/9/2017               US72184 for IRS change - Commented the Restricted Secret Content value
* Popcornapps                2/21/2018               US84968 Routing and Support Level for 'Partner Supported Account' Field
* Ashutosh                   27/06/2018              US106566 - Case sharing for NAC case when project based
* Aparna                     23/10/2018              US185521- Iteration:19-Reset Compliance Status for GEC Cases
* Aparna                     19/11/2018              US221489 - Iteration:21 - Classification field for private project cases
* Gourav Anand               19/11/2018              US221486- Modified existing logic to fetch Support Level based on Supported Contact_Account
* Gourav Anand               19/11/2018              US237240- Logic to fetch Support Level for GEC cases
* Gourav Anand               29/11/2018              US225815- Private case rerouting changes for case owner
* Aparna                     3/12/2018               US196940- Created method for case owner group updation
* Sumukh                     12/12/2018              DE27348
* Gourav                     14/01/2019              US252217- Project case and Private case rerouting changes for case owner/co-owner
* Sumukh                     30/01/2019              US261517 - Routing Cases when the Default Case Owner is Inactive
* Aparna                     22/2/2019               US253169- Logic to handle Minds-USA cases
* Sumukh                     26/02/2019              US293538- Logic to Populate Date/time close pending to calculate age in days
* Sumukh                     12/04/2019              US300792 - Edit of Case Contact should allow for another potential GEC review
* Sumukh                     08/05/2019              US340992 - MINDS Questionnaire field should be blank until required/completed
* Sneha                      22/05/2019              DE41482 - MINDS Use field not being reset when Case goes to Status = New
* Sumukh                     22/05/2019              US357190 - Update of Case's Contact to USA-based customer - comments insertion
* Sneha                      06/06/2019              DE43292 - The case record type of NAC case is becoming ‘IPS Case Create’ once the GEC NAC case is approved
* Sneha                      02/07/2019              US358368 - FAE an automatic Interested Party if creating a Case and not the Contact ISO
* Ranjini                    29/07/2019              Modified for US404759
* Ganapati                   09/08/2019              Modified for DE36247 - For project based NAC cases, ISO and PSO value is not getting copied from project
* Ganapati                   28/08/2019              Modified for DE49777
* Sneha                      26/11/2019              Modified for US372697 - ‘First response’ is not getting generated for CIV case currently.
* Ganapati                   06/12/2019              Modified for US431208 - Case records to now link to Case Owner Group (COG) records based on 'Case Owner Email' data
* Shobhit                    23/01/2024              Updated code to check is minds selected or not
* Pavani                     20/09/2024              Code Refactor Changes
* Chiranjeevi                23/09/2024              Code Refactor Changes
* Anjaneyalu                 24/09/2024              Static Code References Fixes
****************************************************************************************************/  
    
    //public static String newListStr;  //Commented as part of Code Refactor TWC745-6459
    //public static String oldMapStr;   //Commented as part of Code Refactor TWC745-6459
    public static Map<String,Id> mapProjProdOwner=new Map<String,Id>() ;
    //public static Map<Id,Id> mapProjOwner = new Map<Id,Id>() ; //Commented as part of Code Refactor TWC745-6459
    public static Map<Id,Id> mapCaseAssetSupProd = new Map<Id,Id>() ;
    public static Set<Id> supportedProdIDs= new Set<Id>()  ;
    public static Set<Id> projIDs= new Set<Id>();
    // Added by chetan as part of comment sertion for MINDS cases
    public static boolean  isCommentInserted = false ;
    
    //START - Added as part of Code Refactor TWC745-6459
    Public Static Map<Id,Contact> GlobalContactRecords = new Map<Id,Contact>();
    Public Static Map<Id,Asset> GlobalAssetRecords = new Map<Id,Asset>();
    Public Static Map<Id,User> GlobalUserRecords = new  Map<Id,User>();
    Public Static Map<Id,Id> GlobalContactUserIdMap = new  Map<Id,Id>();
    Public Static List<IPS_Case_Fields__c> allCustomSettings = new List<IPS_Case_Fields__c>();
    Public Static Map<String, String> customSettingMap = new Map<String,String>();
    Public static Map<Id,Core_IPS_Backend_System2__c> backendRecMap;
    Public static List<String> getNewBackendIdList = new List<String>();
    Public static List<String> getOldBackendIdList = new List<String>();
    Public static List<String> getOldCaseBackendIdList = new List<String>();
    public static Map<String, List<String>> oldRecIds = new Map<String, List<String>>{'AssetID' => new List<String>(),'UserID' => new List<String>(),'ContactID' => new List<String>()};
        public static List<String> OldprojectIds = new List<String>();
    public static List<Core_Ips_project__c> GlobalProjectRecords = new List<Core_Ips_project__c>();
    public static List<String> OldprojectIdList = new List<String>();
    public static List<Core_Ips_project__c> GlobalProjectRecordsList = new List<Core_Ips_project__c>();
    Public Static List<String> oldProductIds = new List<String>();
    //END   
    
    public static void executeCaseAssignmentRule(Map<Id,Case> oldMap,List<Case> newList){
        List<Case> caselist = new List<Case>();
        String isUpdate;
        String isInsert;
        String newListStr = JSON.serialize(newList);
        String oldMapStr= JSON.serialize(oldMap);
        
        //need to add a check for GEC and Backend Cases 09-24-2015
        if(Trigger.isInsert) {                                                   
            if(!String.isBlank(newListStr)) {          
                isInsert='insert';           
            }      
            //triggerAssignmentRuleAndProvideAccess(newListStr ,oldMapStr,isInsert) ; 
            if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('executeCaseAssignmentRule')){
                string ruleId = ((AssignmentRule)Database.query(System.Label.SOQL_Case_Assignment_Rule)).Id;
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.AssignmentRuleHeader.assignmentRuleId = ruleId;
                dmo.EmailHeader.triggerUserEmail = false;              
                List<Case> cases = new List<Case>();
                
                assignProjectCasesOwner(newList);
                if(Case.SObjectType.getDescribe().isQueryable()){ //FLS already added - Aditya
               	// APEX GURU - SOQL FIX
                    Map<Id, Case> newListMap = new Map<Id, Case>(newList);
                    caselist = [SELECT Id,RecordTypeId,OwnerId,Core_IPS_GEC_Status__c,ProductId,Asset.Core_Supported_Product__c,Core_IPS_Supported_Product__c,Core_IPS_Project_Case__c,Core_IPS_Project_Case__r.OwnerId,Core_IPS_Project_Case__r.Core_IPS_Private__c,Core_IPS_Private_Project__c,Core_Partner_Supported_Account__c from Case where Id in :newListMap.keyset()];  
             
                   // caselist = [SELECT Id,RecordTypeId,OwnerId,Core_IPS_GEC_Status__c,ProductId,Asset.Core_Supported_Product__c,Core_IPS_Supported_Product__c,Core_IPS_Project_Case__c,Core_IPS_Project_Case__r.OwnerId,Core_IPS_Project_Case__r.Core_IPS_Private__c,Core_IPS_Private_Project__c,Core_Partner_Supported_Account__c from Case where Id in :newList];  
                //US257271 - added GEC recordtype to fix GEC routing
                Id gECRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();               
                for(Case cs : caselist) {
                    String caseKey = (cs.Core_IPS_Supported_Product__c==null ? String.valueOf(cs.Asset.Core_Supported_Product__c) : String.valueOf(cs.Core_IPS_Supported_Product__c)) + 
                        String.valueOf(cs.Core_IPS_Project_Case__c);
                    
                    //US257271 - added GEC recordtype to fix GEC routing
                    
                        if(mapProjProdOwner !=null && mapProjProdOwner.containsKey(caseKey) && cs.RecordTypeId!=GECRecordTypeId && Schema.sObjectType.Case.fields.OwnerId.isUpdateable()){  
                        cs.OwnerId=mapProjProdOwner.get(caseKey);                        
                        } else if(Schema.sObjectType.Case.fields.OwnerId.isUpdateable() && mapProjProdOwner !=null && mapProjProdOwner.containsKey(cs.Core_IPS_Project_Case__c) && cs.Core_IPS_Project_Case__r.Core_IPS_Private__c && cs.RecordTypeId!=GECRecordTypeId ) {                           
                        cs.OwnerId = cs.Core_IPS_Project_Case__r.OwnerId;
                    } else {                       
                        cs.setOptions(dmo);                                               
                    }                    
                    cases.add(cs);
                }
                
                if(!cases.isempty()){
                    Database.update(cases);
                }                    
                }
            }
            
            triggerAssignmentRuleWithFuture(newListStr ,oldMapStr,isInsert) ;
            
        }else if(trigger.isUpdate){
            isUpdate='update';          
            if(!String.isBlank(newListStr)){
	     // Change Related to HSD Auto Promote                                      
                
                for(Case c : newList){
                    //if(Label.Core_IPS_BES_Case_AutoPromotion_Toggle == 'true' && c.Core_Product_Organization__c != oldMap.get(c.Id).Core_Product_Organization__c && (oldMap.get(c.Id).Core_IPS_Supported_Product__c != c.Core_IPS_Supported_Product__c || oldMap.get(c.Id).ownerId != c.OwnerId)){
                    if(Label.Core_IPS_BES_Case_AutoPromotion_Toggle == 'true' && ((c.Core_Product_Organization__c != oldMap.get(c.Id).Core_Product_Organization__c && (oldMap.get(c.Id).Core_IPS_Supported_Product__c != c.Core_IPS_Supported_Product__c || oldMap.get(c.Id).ownerId != c.OwnerId)) || 
                       (c.Core_IPS_gec_flag__c ==  true && oldMap.get(c.Id).Core_IPS_gec_status__c != c.Core_IPS_gec_status__c  && (c.Core_IPS_gec_status__c== 'Approved' || c.Core_IPS_gec_status__c== 'Approved with Guardrails')))){
                        Core_CaseTrigger_Dispatcher.IsAutoPromoteRequired = true;
                        break;
                    } 
                }
                if(Core_CaseTrigger_Dispatcher.IsAutoPromoteRequired){
                triggerAssignmentRuleAndProvideAccess(newListStr ,oldMapStr,isUpdate);
              }else {
              triggerAssignmentRuleWithFuture(newListStr ,oldMapStr,isUpdate);
            }
        }
    }
    }
     // Change Related to HSD Auto Promote
    @future
    public static void triggerAssignmentRuleWithFuture(String stringcaseList,String oldMapString,String triggerActionString){
        triggerAssignmentRuleAndProvideAccess(stringcaseList, oldMapString,triggerActionString);  
    }

    public static void triggerAssignmentRuleAndProvideAccess(String strcaseList,String oldMap,String triggerAction){   
        List<Case> caselist = new List<Case>();
        List<Case> newCaseList = (List<Case>)JSON.deserialize(strcaseList, List<Case>.class);
        Map<id,Case> oldCaseMap = (Map<id,Case>)JSON.deserialize(oldMap, Map<id,Case>.class);
        List<case> cases;         
        
        if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('executeCaseAssignmentRule')){ 
            string ruleId = ((AssignmentRule)Database.query(System.Label.SOQL_Case_Assignment_Rule)).Id;           
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.AssignmentRuleHeader.assignmentRuleId = ruleId;
            dmo.EmailHeader.triggerUserEmail = false;
            
            if(triggerAction=='update'){
                assignProjectCasesOwner(newCaseList);                
                cases = new List<Case>();  
                if(Case.SObjectType.getDescribe().isQueryable()){ //FLS check already added - Aditya
                 // APEX GURU - SOQL FIX
                 Map<Id, Case> newCaseListMap = new Map<Id, Case>(newCaseList);
                 // caseList= [select id,Contact.id,OwnerId,Core_IPS_GEC_Status__c,ProductId,Core_IPS_Supported_Product__c,Asset.Core_Supported_Product__c,Core_IPS_Project_Case__c,Core_IPS_Project_Case__r.OwnerId,Core_IPS_Private_Project__c,Core_Partner_Supported_Account__c from Case where Id in : newCaseList];
                    caseList= [select id,Contact.id,OwnerId,Core_IPS_GEC_Status__c,ProductId,Core_IPS_Supported_Product__c,Asset.Core_Supported_Product__c,Core_IPS_Project_Case__c,Core_IPS_Project_Case__r.OwnerId,Core_IPS_Private_Project__c,Core_Partner_Supported_Account__c,Core_IPS_New_Backend_System__c,Core_Product_Organization__c from Case where Id in : newCaseListMap.keyset()];
               for(case cs: caseList){
		 // Change Related to HSD Auto Promote
                  
                        // FLS Fix Applied as Part of Apex Guru
                        //if(Label.Core_IPS_BES_Case_AutoPromotion_Toggle == 'true' && Schema.sObjectType.Case.fields.Core_IPS_New_Backend_System__c.isUpdateable() && Core_CaseTrigger_Dispatcher.IsAutoPromoteRequired && cs.Core_Product_Organization__c != OldCaseMap.get(cs.Id).Core_Product_Organization__c && (OldCaseMap.get(cs.Id).Core_IPS_Supported_Product__c != cs.Core_IPS_Supported_Product__c || OldCaseMap.get(cs.Id).ownerId != cs.OwnerId)  ){
                         if(Label.Core_IPS_BES_Case_AutoPromotion_Toggle == 'true' && Schema.sObjectType.Case.fields.Core_IPS_New_Backend_System__c.isUpdateable() && Core_CaseTrigger_Dispatcher.IsAutoPromoteRequired && ( (cs.Core_Product_Organization__c != OldCaseMap.get(cs.Id).Core_Product_Organization__c && (OldCaseMap.get(cs.Id).Core_IPS_Supported_Product__c != cs.Core_IPS_Supported_Product__c || OldCaseMap.get(cs.Id).ownerId != cs.OwnerId))
                              || (cs.Core_IPS_gec_flag__c ==  true && oldCaseMap.get(cs.Id).Core_IPS_gec_status__c != cs.Core_IPS_gec_status__c  && ( cs.Core_IPS_gec_status__c== 'Approved' || cs.Core_IPS_gec_status__c== 'Approved with Guardrails')) ) ){     
                            cs.Core_IPS_New_Backend_System__c = null; 
                            //Core_CaseTrigger_Dispatcher.IsAutoPromoteRequired = false;
                   }
                    String caseKey = (cs.Core_IPS_Supported_Product__c==null ? String.valueOf(cs.Asset.Core_Supported_Product__c) : String.valueOf(cs.Core_IPS_Supported_Product__c)) + 
                        String.valueOf(cs.Core_IPS_Project_Case__c);
                    //added to future for email issue US257271
                    if(OldCaseMap.get(cs.id).productid != cs.productid|| OldCaseMap.get(cs.id).Core_IPS_Supported_Product__c != cs.Core_IPS_Supported_Product__c || OldCaseMap.get(cs.id).assetId != cs.AssetId  || (OldCaseMap.get(cs.id).Core_IPS_GEC_Status__c != cs.Core_IPS_GEC_Status__c && (cs.Core_IPS_GEC_Status__c == Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved')||cs.Core_IPS_GEC_Status__c == Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved_WithG')))){
                        if(mapProjProdOwner !=null && mapProjProdOwner.containsKey(caseKey)){   
                                                                                                cs.OwnerId=mapProjProdOwner.get(caseKey); 
												cases.add(cs);
                                                                                            } else if(mapProjProdOwner !=null && mapProjProdOwner.containsKey(cs.Core_IPS_Project_Case__c) && cs.Core_IPS_Private_Project__c){
                                                                                                cs.OwnerId = mapProjProdOwner.get(cs.Core_IPS_Project_Case__c); 
                                                                                                cases.add(cs);
                                                                                            }
                    }                     
                    //DE31600 - Defect fix by Ajay - Added 'Approved with Guardials' condition.                    
                    if(!cs.Core_IPS_Private_Project__c && (mapProjProdOwner ==null  || !mapProjProdOwner.containsKey(caseKey) ) && (OldCaseMap.get(cs.id).productid != cs.productid|| OldCaseMap.get(cs.id).Core_Partner_Supported_Account__c != cs.Core_Partner_Supported_Account__c ||(OldCaseMap.get(cs.id).Core_IPS_GEC_Status__c!=cs.Core_IPS_GEC_Status__c && (cs.Core_IPS_GEC_Status__c == Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved')||cs.Core_IPS_GEC_Status__c == Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved_WithG') )) || cs.Core_IPS_Supported_Product__c != OldCaseMap.get(cs.id).Core_IPS_Supported_Product__c )){                                                               
                        cs.setOptions(dmo);                     
                        cases.add(cs);                                            
                    }                                     
                    // Added by sumukh for US300792
                    else if( !cs.Core_IPS_Private_Project__c && (mapProjProdOwner ==null  || !mapProjProdOwner.containsKey(caseKey) ) && OldCaseMap.get(cs.id).Contactid != cs.Contactid ) {
                        cs.setOptions(dmo);                         
                        cases.add(cs);                                             
                    }// end by sumukh for US300792                  
                }
                    //FLS Added as Part of code refactor
                    if (Schema.sObjectType.Case.isUpdateable() && cases.size() > 0) {
                    Database.update(cases);
                } 
                }
            }
        }
        if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('provideCaseAccessToCreatedFAE')){
            provideCaseAccessToCreatedFAE(newCaseList);     
        }
    }
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 09 Oct 2015
Function    : This method is used to perform SLA Management
Input Parameters: Case Old Map, Case New List
Output Parameters: None
Transactions: Before Insert, Before Update
Description: This method is used for Case SLA Management:
Before insert: Assigns Business Hours to case based on Owner Id
Before Update: If owner of case changes, updates business hours based on the new owner. 
Ownership(Queue) and Business hours mapping is maintained in a custom setting Core_IPS_Q_Biz_hours_mapping__c
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:2
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/09/2015              Created
* Jayaprakash T              01/14/2016              Updated code for Milestone closure or retrigger based on case status
* Karthick                   07-02-2018             Modified - STOP SLA for customer actions,close pedning and deferred state
* Ganapati                   28/08/2019             Modified for DE49777
****************************************************************************************************/  
    public static User caseSLAManagementuserResult;
    public static void caseSLAManagement(Map<Id,Case> oldMap, List<case> newList)
    {
         List<CaseMilestone> lstCaseMilestone = new List<CaseMilestone>();
	 List<AggregateResult> lstAggregateResult = new List<AggregateResult>();
        if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('caseSLAManagement')){
            return;
        }    
        
        
        
        if (trigger.isUpdate)
        {
            //Added by Karthick - US92741 -Release 4            
            Set<string> subStatusSet = new Set<String>();        
            subStatusSet.addAll(Label.Core_IPS_Case_Stop_SLA.split(','));                
            for (Case cs:newList){     
                
                if( String.isNotBlank(cs.Core_Sub_Status__c) && subStatusSet.contains(cs.Core_Sub_Status__c)){
                    //US92741 - Complete the first response 
                    if(!cs.Core_First_Response_Completed__c){
                        cs.Core_First_Response_Completed__c  = true;
                        //   cs.Core_Next_Response_Due_Date__c = milestoneutils.getSetNextResponseDueDate(cs);
                    }
                }
            }
            
            milestoneUtils.AddCaseBizHoursOnOwnerUpdate(oldMap, newList);
            
            if(caseSLAManagementUserResult == null){
                //Start - Added as part of Code Refactor TWC745-6459
                if(Core_IPS_CaseTriggerHandler.GlobalUserRecords!=null && Core_IPS_CaseTriggerHandler.GlobalUserRecords.size()>0 && Core_IPS_CaseTriggerHandler.GlobalUserRecords.containskey(userInfo.getUserId())){
                    caseSLAManagementUserResult = Core_IPS_CaseTriggerHandler.GlobalUserRecords.get(userInfo.getUserId());
                }
                else{
                    //End 
                    caseSLAManagementUserResult = [SELECT Id, IsPortalEnabled FROM user WHERE id = :userInfo.getUserId() LIMIT 1];
                }
            }
            Set<Id> caseIds = new Set<Id>();
            for (Case cs : newList) {
                if (!caseIds.contains(cs.Id)){
                    caseIds.add(cs.Id);       
                }         
            }
            if(AggregateResult.SObjectType.getDescribe().isQueryable()||CaseMilestone.SObjectType.getDescribe().isQueryable()){
                lstAggregateResult = [SELECT caseId, MAX(startDate) maxStartDate
                                                        FROM CaseMilestone 
                                                        WHERE caseId IN :caseIds
                                                        GROUP BY caseId]; 
            Id caseId;                                      
            map<Id, DateTime> mapMaxStartDate = new map<Id, DateTime>();
            for (AggregateResult ar : lstAggregateResult) {
                
                
                
                caseId = Id.valueOf(String.valueOf(ar.get('caseId')));
                mapMaxStartDate.put(caseId, DateTime.valueOf(ar.get('maxStartDate')));                                                                                                                   
            }
            
            DateTime maxStartDate;
                if(CaseMilestone.SObjectType.getDescribe().isAccessible()){ //FLS check already added
                 	lstCaseMilestone = [SELECT Id, caseId, startDate, completionDate
                                                    FROM CaseMilestone 
                                                    WHERE caseId IN :caseIds 
                                                    AND completionDate = null];
                }
            Map<Id, CaseMilestone> mapCaseMilestone = new Map<Id, CaseMilestone>();
            for (CaseMilestone cm : lstCaseMilestone) {
                if (!mapCaseMilestone.keyset().contains(cm.caseId)) {
                    mapCaseMilestone.put(cm.caseId, cm);   
                }        
            }                
            
            CaseMilestone objCaseMilestone;
            List<CaseMileStone> lstUpdateCaseMilestone = new List<CaseMilestone>();
            
            /* Added by Ganapati for DE49777 - start */
            Set<Id> casesWithOrgConfigSet = new Set<Id>();
            casesWithOrgConfigSet = milestoneUtils.getCasesWithOrgConfigSet(newList);
            /* Added by Ganapati - end for DE49777*/
            
            for (Case cs:newList)
            {            
                // BM 7/31
                objCaseMilestone = mapCaseMilestone.get(cs.Id);
                maxStartDate     = mapMaxStartDate.get(cs.Id);
                
                Boolean changedNRDD  = (oldMap.get(cs.Id).Core_Next_Response_Due_Date__c != cs.Core_Next_Response_Due_Date__c);
                if (maxStartDate != NULL && changedNRDD) 
                {                    
                    if (cs.Core_Next_Response_Due_Date__c < maxStartDate) {
                        String strStartDate = maxStartDate.format('MM-dd-YY HH:mm:ss z');
                            cs.addError(Label.Core_IPS_Case_Milestone_Error + strStartDate);
                        
                    }
                }
                
                if (cs.Core_Sub_Status__c == NULL){
                    continue;
                }    
                
                // DEFECT DE10222 IPS case milestones no longer need to be stopped
                // Complete milestone
                
                //Added by Karthick - US92741 -Release 4
                //Set<string> subStatusSet = new Set<String>();        
                //subStatusSet.addAll(Label.Core_IPS_Case_Stop_SLA.split(','));                
                
                /* Modified below if condition by Ganapati for DE49777 */
                if((String.isNotBlank(cs.Core_Sub_Status__c) && subStatusSet.contains(cs.Core_Sub_Status__c)) 
                   || (oldMap.get(cs.Id).Priority != cs.Priority && !casesWithOrgConfigSet.isEmpty() && casesWithOrgConfigSet.contains(cs.Id))
                  ) {
                      
                      
                      if(!caseSLAManagementUserResult.isPortalEnabled) {
                          
                          objCaseMilestone = mapCaseMilestone.get(cs.Id);
                          if (objCaseMilestone <> null) {
                              
                              objCaseMilestone.completionDate = System.now();                            
                              
                              lstUpdateCaseMilestone.add(objCaseMilestone);
                          }
                      }
                  }
                
                if(!cs.isStopped)
                {
                    if(cs.recordTypeId==Core_IPS_Helper_Utility.getIPSLabel('GEC Record Type Id')){
                        milestoneUtils.stopMilestoneClockWhenAwaitingCustomerResponse(cs);
                    }   
                }
                else if((oldMap.get(cs.Id).recordTypeId==Core_IPS_Helper_Utility.getIPSLabel('GEC Record Type Id'))) 
                {  milestoneUtils.reStartMilestoneClockWhenCustomerresponded(cs); }
                
            }            
            
            if (lstUpdateCaseMilestone.size() > 0) {
                
                update lstUpdateCaseMilestone;   
            }            
        }
        }
        else if (trigger.isInsert) //Code added by Roshan-10/9/2015. This is to bulkify the code.
        {  //[Oct/15/2015 : START : As discussed with JP, Commenting the method named AddCaseBizHoursOnOwnerUpdate due to System.LimitException: Too many query rows: 50001.]
            
            milestoneUtils.AddCaseBizHoursOnOwnerUpdate(null, newList);
        }             
        
        
    }
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 09 Oct 2015
Function    : This method is used to Update Case Information with parent records related information. 

Input Parameters: Case New List
Output Parameters: None
Transactions: Before Insert, Before Update
Description: This method is used to Update Case Information with parent records related information:
Information from asset (product, supported product, product organization, product Name) is stamped on case using this method. 
A Wrapper class Core_IPS_CaseInformationByAsset is used to maintain the required information.
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:2
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/09/2015              Created
* Aayushi Singhal            15/12/2017              Modified
* Karthick                   09/03/2018              Modified
* Gourav Anand               19/11/18                US221486-Modified existing logic to fetch ISO based on Supported Contact
* Sumukh                     26/02/19                US293538-Added logic for populating Data/time close pending when the sub status of case is changed to close-pending to calculate age in days
****************************************************************************************************/      
    public static void assignCaseInformation(List<case> newList, Map<Id,Case> oldMap, Boolean isMigrationUser){

        //added as part of code refactor
        String groupName=System.Label.Core_IPS_GEC_Queue_DeveloperName;
        list<Group>listwithgroup=[SELECT Id, Name, DeveloperName 
                                  FROM Group 
                                  WHERE developerName = :groupName]; 
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('assignCaseInformation')){
            return;
        }    
        List<Case> refCaseList = new List<Case>();//US225807
        
        Set<String> contIdSet = new Set<String>();
        Set<String> assetIdSet = new Set<String>();
        Set<String> suppProdIdSet = new Set<String>();
        Set<Id> setProjectId = new Set<Id>(); //added for US137508
        
        Map<Id,Id> intelSupportOwnersByContact = new Map<Id,Id>();
        
        //Map<Id, Group> mapGroupById;        // Leave this NULL!  Don't make this static or global. //Commented as part of Code Refactor TWC745-6459
        Map<String, Group> mapGroupByName;  // Leave this NULL!  Don't make this static or global.
        
        
        for(Case cs:newList){
            
            //Updating Supported Contact for all the cases 
            if(cs.ContactId!=null) {
                cs.Core_IPS_Supported_Contact__c = cs.ContactId;                       
            }
            contIdSet.add(cs.Core_IPS_Supported_Contact__c); //US221486-Gourav: Updated Core_IPS_Supported_Contact__c
            assetIdSet.add(cs.assetId);
            
            

            suppProdIdSet.add(cs.Core_IPS_Supported_Product__c);
            if(cs.Core_IPS_Project_Case__c!=null) {
                setProjectId.add(cs.Core_IPS_Project_Case__c); // added for US137508 
            }    
            if(oldMap!=null && oldMap.get(cs.Id).Core_IPS_Project_Case__c!=null) {
                setProjectId.add(oldMap.get(cs.Id).Core_IPS_Project_Case__c); // added for US137508 
            }    
        }
        
        intelSupportOwnersByContact=Core_IPS_Helper_Utility.getIntelSupportOwnerByContact(contIdSet);
        Map<Id,Core_IPS_CaseInformation> caseInfoByAsset     = getCaseInformationByAssetOrSuppProd(assetIdSet,isMigrationUser);
        Map<Id,Core_IPS_CaseInformation> caseInfoBySuppProd  = getCaseInformationByAssetOrSuppProd(suppProdIdSet,isMigrationUser);
        Map<Id,Core_IPS_CaseInformation> caseInfoByCatSubCat = getCaseInfoByCatSubCat(newList);             
        
        boolean isLoggeInUserMigrationUser   = Core_IPS_CaseTriggerHandler.isMigrationUser(string.valueof(userinfo.getuserId()));
        boolean isLoggeInUserIntegrationUser = false;
        if(Core_IPS_CaseTriggerHandler.GlobalUserRecords!=null && Core_IPS_CaseTriggerHandler.GlobalUserRecords.size()>0 && Core_IPS_CaseTriggerHandler.GlobalUserRecords.containskey(userinfo.getuserId()) ){
          
            if(Core_IPS_CaseTriggerHandler.GlobalUserRecords.get(userinfo.getuserId()).Profile.Name == Label.Core_Integration_Profile_Name){ isLoggeInUserIntegrationUser = true; }
        }
        else{
          
            isLoggeInUserIntegrationUser = Core_IPS_Case_Comments_Handler.isIntegrationUser(string.valueof(userinfo.getuserId())); 
        }
        
        //Modified byUS221486 Gourav-for Supported Contact
        Map<Id,Contact> mapIdToContact = new Map<Id,Contact>(Core_IPS_Helper_Utility.getIntelSupportOwnerByContact_ResultList); // added by Sugandha
        
        //added for US137508
        Map<Id,Core_Ips_Project__c> projectMap = new Map<Id,Core_Ips_Project__c>();
        if(setProjectId.size()>0){
            projectMap = new Map<Id,Core_Ips_Project__c>([Select Id,Core_IPS_Intel_Support_Owner__c from Core_Ips_Project__c where Id IN :setProjectId]);
        }
        for(Case cs:newList){
            
            
            if(caseInfoByAsset.get(cs.assetId)!=null){
                cs.Core_IPS_Supported_Product__c = caseInfoByAsset.get(cs.assetId).supportedProduct;
                cs.Core_IPS_Product_Org1__c = caseInfoByAsset.get(cs.assetId).prodOrg;
                cs.Core_IPS_product_name__c =caseInfoByAsset.get(cs.assetId).prodName;
                cs.productId = caseInfoByAsset.get(cs.assetId).productId;
                
                If(cs <> null && cs.assetId <> null && caseInfoByAsset <> null && caseInfoByAsset.size() > 0 && caseInfoByAsset.get(cs.assetId) <> null && caseInfoByAsset.get(cs.assetId).codeName <> null && caseInfoByAsset.get(cs.assetId).codeName <> '')
                {    cs.Core_Code_Name__c = caseInfoByAsset.get(cs.assetId).codeName;
                }else{
                    cs.Core_Code_Name__c = '';
                }
                If(cs <> null && cs.assetId <> null && caseInfoByAsset <> null && caseInfoByAsset.size() > 0 && caseInfoByAsset.get(cs.assetId) <> null && caseInfoByAsset.get(cs.assetId).productType <> null && caseInfoByAsset.get(cs.assetId).productType <> '')
                {   
                    cs.Core_Product_Type__c = caseInfoByAsset.get(cs.assetId).productType;
                }    
            }
            
            if(caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c)!=null){
                cs.Core_IPS_Supported_Product__c = caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).supportedProduct;
                cs.Core_IPS_Product_Org1__c = caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).prodOrg;
                cs.Core_IPS_product_name__c = caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).prodName;
                cs.productId = caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).productId;
                If(cs <> null && cs.Core_IPS_Supported_Product__c <> null && caseInfoBySuppProd <> null && caseInfoBySuppProd.size() > 0 && caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c) <> null && caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).codeName <> null && caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).codeName <> '')                    
                {    cs.Core_Code_Name__c = caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).codeName;
                }else{
                    cs.Core_Code_Name__c = '';
                }
                If(cs <> null && cs.Core_IPS_Supported_Product__c <> null && caseInfoBySuppProd <> null && caseInfoBySuppProd.size() > 0 && caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c) <> null && caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).productType <> null && caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).productType <> '')                    
                {
                    cs.Core_Product_Type__c = caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).productType;                    
                }    
            }
            
            //added for US137508
            Boolean updateISO = true;
            if(projectMap.containsKey(cs.Core_IPS_Project_Case__c) && projectMap.get(cs.Core_IPS_Project_Case__c).Core_IPS_Intel_Support_Owner__c!=null) {
                updateISO = false;
            } else if(oldMap!=null && cs.Core_IPS_Project_Case__c!=oldMap.get(cs.Id).Core_IPS_Project_Case__c && 
                      (oldMap.get(cs.Id).Core_IPS_Project_Case__c!=null && projectMap.get(oldMap.get(cs.Id).Core_IPS_Project_Case__c).Core_IPS_Intel_Support_Owner__c!=null && 
                       ((projectMap.containsKey(cs.Core_IPS_Project_Case__c) && projectMap.get(cs.Core_IPS_Project_Case__c).Core_IPS_Intel_Support_Owner__c==null) || 
                        cs.Core_IPS_Project_Case__c==null)
                      )) {
                          cs.Core_Intel_Sup_Owner__c = null;
                      }
            
            //modified by Gourav US221486 Core_IPS_Supported_Contact__c    // added updateISOCheck for US137508
            if(cs.Core_IPS_Supported_Contact__c!= null && (cs.Core_Intel_Sup_Owner__c == null || cs.Core_IPS_Supported_Contact__c != oldMap.get(cs.Id).Core_IPS_Supported_Contact__c) && (mapIdToContact.get(cs.Core_IPS_Supported_Contact__c)!= null && mapIdToContact.get(cs.Core_IPS_Supported_Contact__c).Core_IPS_Alternate_Support_Owner__c != null && cs.Core_IPS_Product_Org1__c == mapIdToContact.get(cs.Core_IPS_Supported_Contact__c).Core_IPS_Alternate_Support_Org__c && updateISO)){                   
                cs.Core_Intel_Sup_Owner__c = mapIdToContact.get(cs.Core_IPS_Supported_Contact__c).Core_IPS_Alternate_Support_Owner__c;
            }
            //Added by Karthick - US92632 - Release 4 - I8
            //modified by Gourav US221486 Core_IPS_Supported_Contact__c // added updateISOCheck for US137508 //modified by Gourav Core_IPS_Supported_Contact__c  US221486
            else if(String.isNotBlank(cs.Core_IPS_Supported_Contact__c) && (String.isBlank(cs.Core_Intel_Sup_Owner__c) || (cs.Core_IPS_Supported_Contact__c != oldMap.get(cs.Id).Core_IPS_Supported_Contact__c && updateISO))){                
                cs.Core_Intel_Sup_Owner__c=intelSupportOwnersByContact.get(cs.Core_IPS_Supported_Contact__c);                
            }
            
            
            
            //Modified by karthick - 18/06/2018 - Category defect fix            
            if(caseInfoByCatSubCat!=null ){
                //cs.Core_External_Issue_Category__c=caseInfoByCatSubCat.get(cs.id).issueCategory;
                //cs.Core_External_Issue_Subcategory__c = caseInfoByCatSubCat.get(cs.id).issueSubCategory;
                
                cs.Core_External_Issue_Category__c= caseInfoByCatSubCat.containsKey(cs.Core_Case_Issue_Category__c)? caseInfoByCatSubCat.get(cs.Core_Case_Issue_Category__c).issueCategory:'';
                
                cs.Core_External_Issue_Subcategory__c = caseInfoByCatSubCat.containsKey(cs.Core_Case_Issue_Sub_Category__c)?caseInfoByCatSubCat.get(cs.Core_Case_Issue_Sub_Category__c).issueSubCategory:'';
                
            }
            //Modified by Ashirbad - 10/12/2018 - Category defect fix defect no DE27017 
            else{
                cs.Core_External_Issue_Category__c='';
                cs.Core_External_Issue_Subcategory__c = '';
            }
            
            
            //cs.Core_Issue_Description__c = Core_Utility.addBreaktags(cs.Core_Issue_Description__c);
            if((trigger.isinsert && cs.Core_Issue_Description__c <> null) ||( trigger.isupdate && oldMap.get(cs.Id).Core_Issue_Description__c <> null && cs.Core_Issue_Description__c <> null && oldMap.get(cs.Id).Core_Issue_Description__c <> cs.Core_Issue_Description__c )){

                string  strDescValue = Core_Utility.substituteHTMLTags(cs.Core_Issue_Description__c);//replaceHtmlTagsCase
                
                cs.Description =  Core_Utility.stripandunescapeHtmlTags(strDescValue);//replaceSpecialChar  
                
                //Updated by 11765018 ( Sourabh) : Added custom setting check here For DM and Integ users. Date : 9 feb 2018 
                /*if(Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for DM') != null && Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for DM').Core_Feature_Enabled__c && isLoggeInUserMigrationUser )
cs.Core_Issue_Description__c = Core_Utility.addBreaktags(cs.Core_Issue_Description__c);
if(Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for Integ User') != null && Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for Integ User').Core_Feature_Enabled__c && isLoggeInUserIntegrationUser) */
                if(isLoggeInUserMigrationUser || isLoggeInUserIntegrationUser)  {
                    cs.Core_Issue_Description__c = Core_Utility.addBreaktags(cs.Core_Issue_Description__c);
                }   
                
                //if(isLoggeInUserMigrationUser || isLoggeInUserIntegrationUser)
                //cs.Core_Issue_Description__c = Core_Utility.addBreaktags(cs.Core_Issue_Description__c);
            }
            
            //[START : 02/03/2016 : Assigning the Field Updates.]
            
            // Core IPS Case Non-SA Assigned
            // **For a case re-open, cs.Core_IPS_Self_Assigned__c will be set back to true, in another conditional.
            // Commented condition for US235077
            /* if(cs.RecordTypeId != Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS No Assigned Contact Case') && cs.Core_IPS_Self_Assigned__c == true && !isLoggeInUserMigrationUser){
cs.Core_IPS_Self_Assigned__c = false;
}*/
            
            //Core IPS Case Notif DCG Restricted Secret 
            // Commented by Aayushi as per US72184 for IRS change
            /*   if((oldMap == null && cs.Core_Product_Organization__c=='Data Center') || (oldMap != null && oldMap.get(cs.Id).Core_Product_Organization__c  <> cs.Core_Product_Organization__c && cs.Core_Product_Organization__c=='Data Center'))
{
cs.Core_IPS_Restricted_Secret_Content__c =  true;
} */
            //Core IPS GEC Status For Permanent Hold
            
            
            if((oldMap == null && cs.Core_IPS_GEC_Status__c == 'Not Approved' && (cs.Core_IPS_GEC_Flag__c || cs.Core_IPS_GEC_Case__c)) || (oldMap != null && (oldMap.get(cs.Id).Core_IPS_GEC_Status__c  <> cs.Core_IPS_GEC_Status__c || oldMap.get(cs.Id).Core_IPS_GEC_Flag__c  <> cs.Core_IPS_GEC_Flag__c || oldMap.get(cs.Id).Core_IPS_GEC_Case__c  <> cs.Core_IPS_GEC_Case__c) &&  cs.Core_IPS_GEC_Status__c == 'Not Approved' &&  (cs.Core_IPS_GEC_Flag__c || cs.Core_IPS_GEC_Case__c))){
                cs.Status = 'Closed';
            }
            
            //Core IPS Case SA Assigned
            if(cs.RecordTypeId == Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS No Assigned Contact Case') && cs.Core_IPS_Self_Assigned__c == false){
                cs.Core_IPS_Self_Assigned__c = true;
            }
            //Core IPS GEC Flow Changes
            
            
            
            if((oldMap == null && cs.Core_IPS_GEC_Case__c) || (oldMap <> null && oldMap.get(cs.Id).Core_IPS_GEC_Case__c <> cs.Core_IPS_GEC_Case__c && cs.Core_IPS_GEC_Case__c )) {
                
                
                cs.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS GEC ReadOnly');
                // Add to map IF it isn't already in the map  
                // added as part of code refactor
                mapGroupByName = loadGroupByName(listwithgroup, mapGroupByName);
                Group objGroup = mapGroupByName.get(System.Label.Core_IPS_GEC_Queue_DeveloperName);
                if (objGroup != NULL)        
                    //cs.OwnerId = objGroup.Id;   //'00G21000000MQ54';   //'GEC Case Queue';
                {
                    cs.Status = 'On Hold';
                }
                //cs.Core_IPS_GEC_Request_Status__c = 'MAG Questionnaire Required';   //Commented for US253171
                cs.Core_Sub_Status__c = 'GEC Hold';
                
            }
            
            // Added by sumukh for US300792
            Id recordTypeIdGEC = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();
            String embargoedCountries = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_EmbargoedCountryList');
            List<String> countryList = embargoedCountries.split(',');   
            
            if( oldMap!=null && oldMap.get(cs.id).Contactid != cs.Contactid && 
               (cs.Core_IPS_Minds__c && cs.Core_IPS_Country_Region__c != Core_IPS_Helper_Utility.getIPSLabel('USA'))){             
                   cs.Core_IPS_GEC_Flag__c = true;
                   cs.IsStopped = true;  
                   cs.Status = 'On Hold';
                   cs.Core_Sub_Status__c = 'GEC Hold';
                   cs.recordtypeID =  recordTypeIdGEC;                    
               }
            
            // End by sumukh for US300792  
            
            if(oldMap!=null && oldMap.get(cs.id).Contactid != cs.Contactid && (cs.Core_IPS_Minds__c && cs.Core_IPS_Country_Region__c ==Core_IPS_Helper_Utility.getIPSLabel('USA'))){ // added by sumukh for US357190
                cs.Core_IPS_GEC_Status__c = Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved_WithG');
            }
            
            // End by sumukh for US357190       
            
            //Added the below condition for resetting Compliance Status for GEC Cases-US185521(Iteration:19)
            if(oldMap!=null && oldMap.get(cs.id).RecordTypeId != cs.RecordTypeId && cs.RecordTypeId == Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS GEC ReadOnly'))
            {
                
                
                cs.Core_IPS_GEC_Status__c = '';
                
            }
            //end
            
            //Core IPS GEC Flow Changes
            //(Case: Military, Aerospace, or Gov’mt End UseequalsTrue) and (Case: Is Notification ActiveequalsTrue) and (Case: Case Record TypeequalsIPS No Assigned Contact Case,IPS Case Create,IPS Closed Case,IPS GEC ReadOnly)                 
            
            //Core IPS GEC Status For Approved
            //added by Abhishek Rajput for "Approved with Guardrails" condition on 28/07/2016 -- US37717 
            //Modified By: Neeti Jain(DE33336) to bypass this condition for migration user
            if((!isLoggeInUserMigrationUser &&(oldMap == null && (cs.Core_IPS_GEC_Status__c == 'Approved' || cs.Core_IPS_GEC_Status__c == 'Approved with Guardrails') && (cs.Core_IPS_GEC_Flag__c || cs.Core_IPS_GEC_Case__c)) || (oldMap!=null && (oldMap.get(cs.Id).Core_IPS_GEC_Status__c  <> cs.Core_IPS_GEC_Status__c || oldMap.get(cs.Id).Core_IPS_GEC_Flag__c  <> cs.Core_IPS_GEC_Flag__c || oldMap.get(cs.Id).Core_IPS_GEC_Case__c <> cs.Core_IPS_GEC_Case__c) && (cs.Core_IPS_GEC_Status__c == 'Approved' || cs.Core_IPS_GEC_Status__c == 'Approved with Guardrails') &&  (cs.Core_IPS_GEC_Flag__c || cs.Core_IPS_GEC_Case__c)))){             
                /* Sneha Iteration 11 DE43292 START */ 
                // When Minds use/GEC is set to false and If 'No Contact Assigned' checkbox is true, reverting the Case to NAC; defaulting to IPS Case Create otherwise.
                if(cs.Core_IPS_Self_Assigned__c){
                    cs.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS No Assigned Contact Case');
                }else{
                    cs.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS Case Create');
                }
                /* Sneha Iteration 11 DE43292 END */
                cs.IsStopped = false;
                cs.Core_Sub_Status__c = '';
                cs.Status = 'New';
                // Sneha Iteration 10 DE41482  - START 
                cs.Core_IPS_GEC_Case__c = FALSE;
                // Sneha Iteration 10 DE41482  - END 
            }
            
            //Core IPS Case Notif Ext Int Reopen WF
            if(cs.Status <> null && oldMap <> null && oldMap.size() > 0 && oldMap.get(cs.Id).Status <> null && oldMap.get(cs.Id).Status <> cs.Status && oldMap.get(cs.Id).Status == 'Closed' && (cs.Status == 'Open' || cs.Status == 'New') && cs.Core_IPS_Is_Notification_Active__c && Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId).contains('IPS'))
            {
                cs.Core_IPS_Reopen_Date__c = System.now();
                cs.Core_IPS_Reopen_Flag__c = true;
                
                // BM 6/13
                // Sync the Next Reponse Due Date with the newly created Milestone.
                cs.Core_Next_Response_Due_Date__c = milestoneutils.getSetNextResponseDueDate(cs);                
            }
            //Core IPS Case Notif Int GEC Case WF
            // Added by Neeti Jain as per US102974
            if(!isLoggeInUserMigrationUser &&((oldMap == null && cs.Core_IPS_GEC_Flag__c && cs.Core_IPS_Is_Notification_Active__c) || (oldMap <> null && (oldMap.get(cs.Id).Core_IPS_GEC_Flag__c <> cs.Core_IPS_GEC_Flag__c || oldMap.get(cs.Id).Core_IPS_Is_Notification_Active__c <> cs.Core_IPS_Is_Notification_Active__c ) && cs.Core_IPS_GEC_Flag__c  && cs.Core_IPS_Is_Notification_Active__c))){              
                cs.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS GEC ReadOnly');
                //cs.OwnerId = Core_IPS_CaseTriggerHandler.getGroupbyName(System.Label.Core_IPS_GEC_Queue_DeveloperName).get(System.Label.Core_IPS_GEC_Queue_DeveloperName).Id;//'00G21000000MQ54'; //'GEC Case Queue';
                cs.Status = 'On Hold';
                //cs.Core_IPS_GEC_Request_Status__c = 'MAG Questionnaire Required'; // Changes made by sumukh for US340992 on 08/05/2019
                cs.Core_Sub_Status__c = 'GEC Hold';
            }
            
            //Core_IPS_CaseClose_RecTypeChange
            //(Case: StatusequalsClosed) and (Case: Case Record TypeequalsIPS No Assigned Contact Case,IPS Case Create,IPS GEC ReadOnly,IPS Case Read Only) 
            if((Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId)=='IPS No Assigned Contact Case' || Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId)=='IPS Case Create' || Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId)=='IPS Case Read Only') && ((oldMap == null && Cs.status=='Closed') ||(oldMap != null && oldMap.get(cs.Id).status <> Cs.status && Cs.status=='Closed'))){              
                cs.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS Closed Case');                
            }
            
            //Core_IPS_Case_Populate_Assigned_Case_Field
            /**** code commented as functionality moved to Workflow || (22 Aug 2017) ********* 
if(string.valueOf(cs.OwnerId).startswith('00G') && Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId).contains('IPS')){
if (mapGroupById == NULL)
mapGroupById = loadGroupById(newList);
if (mapGroupById != NULL) {
// cs.Core_IPS_Assigned_Queue__c = Core_IPS_CaseTriggerHandler.getGroupbyId(cs.OwnerId).get(cs.OwnerId).Name; // cs.Owner.Name;
Group objGroup = mapGroupById.get(cs.OwnerId);
if (objGroup != NULL)
cs.Core_IPS_Assigned_Queue__c = objGroup.Name;   // cs.Owner.Name;
}    
}
**** code commented as functionality moved to Workflow || (22 Aug 2017) *********/
            
            //Core_IPS_Update Case Request Close Status
            //Case: Request Case CloseequalsClose Case              
            if((Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId).contains('IPS') && cs.Core_Request_Case_Close__c == 'Close Case') || (oldMap !=null && cs.Core_Request_Case_Close__c <> oldMap.get(cs.id).Core_Request_Case_Close__c && cs.Core_Request_Case_Close__c == 'Close Case')){
                cs.Core_Sub_Status__c = 'Customer Requesting Close*'; 
                cs.Status = 'Open';
            }
            
            // added by sumukh for US293538
            
            if(Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId).contains('IPS') && (oldMap !=null && oldMap.get(cs.id).Core_Sub_Status__c <> cs.Core_Sub_Status__c  && cs.Core_Sub_Status__c =='Close-Pending' && cs.Status =='Open')){                
            	
                cs.Core_IPS_Date_Time_Close_Pending__c = DateTime.Now(); 
            }
            // End by sumukh for US293538 
            
            //Core_IPS_UpdateCloseCaseRecordtype
            //AND(RecordType.DeveloperName = 'IPS_Closed_Case',ISPICKVAL(PRIORVALUE(Status), 'Closed'),NOT(ISPICKVAL(Status,'Closed')) ,OR(ContactId=null,ContactId=''))
            //modified by Gourav Core_IPS_Supported_Contact__c  US221486
            if(oldMap !=null && cs.Core_IPS_Supported_Contact__c == null && oldMap.get(cs.id).status == 'Closed' && cs.status <> 'Closed'  && Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId)=='IPS Closed Case'){
                cs.recordtypeID = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS No Assigned Contact Case');
                
                // ***BM 6/20 - A change to No Assigned Contact recordType should also set the flag.
                //  
                cs.Core_IPS_Self_Assigned__c = true;  
            }
            //Core_IPS_UpdateCloseCaseRecordtypeWithContact  //modified by Gourav Core_IPS_Supported_Contact__c  US221486                           
            if(oldMap !=null && cs.Core_IPS_Self_Assigned__c == false && oldMap.get(cs.id).status == 'Closed' && cs.status <> 'Closed' && Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId)=='IPS Closed Case' && cs.Core_IPS_Supported_Contact__c != null && !isLoggeInUserMigrationUser)
            {
                cs.recordtypeID = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS Case Create');                    
            }
            //modified by Gourav Core_IPS_Supported_Contact__c  US221486
            if(oldMap !=null && cs.Core_IPS_Self_Assigned__c && oldMap.get(cs.id).status == 'Closed' && cs.status <> 'Closed' && Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId)=='IPS Closed Case' && cs.Core_IPS_Supported_Contact__c != null && !isLoggeInUserMigrationUser){
                cs.recordtypeID = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS No Assigned Contact Case');
            }
            
            //Added by Gourav US225807
            supportedProdIDs.add(cs.Core_IPS_Supported_Product__c);
            projIDs.add(cs.Core_IPS_Project_Case__c);
            refCaseList.add(cs);
            //END  US225807  
            
        }      
        
    }
    
    //Modified by karthick  - Defect Fix- DE36996
    public static Map<Id, Core_IPS_CaseInformation> getCaseInfoByCatSubCat(List<Case> caseList){
        //Added by Geetha as per  DE33659
        Set<Id> setCaseCategoryId= new Set<Id>();        
        for(Case cs:caseList){
            if(cs.Core_Case_Issue_Category__c!=null){
                setCaseCategoryId.add(cs.Core_Case_Issue_Category__c); 
                setCaseCategoryId.add(cs.Core_Case_Issue_Sub_Category__c); 
            }
        }
        
        Map<id,Core_IPS_Product_Issue_Category__c> mapCaseCategory = new map<Id,Core_IPS_Product_Issue_Category__c>(
            [Select Id,name,Core_Issue_Sub_Category_Name__c,Core_Issue_Sub_Category_Name__r.name,Core_Issue_Category_Name__c,Core_Issue_Category_Name__r.Name FROM Core_IPS_Product_Issue_Category__c WHERE Id in:setCaseCategoryId ]);
        Map<Id,Core_IPS_CaseInformation> caseDetailsByCatSubCat = new Map<Id,Core_IPS_CaseInformation>();
        if(caseList <> null && caseList.size() > 0){
            for(case cs:caseList){
                Core_IPS_CaseInformation caseInfo = new Core_IPS_CaseInformation();
                if(cs.Core_Case_Issue_Category__c!=null){
                    //Added by Geetha as per  DE33659
                    caseInfo.issueCategory = mapCaseCategory.containsKey(cs.Core_Case_Issue_Category__c)? mapCaseCategory.get(cs.Core_Case_Issue_Category__c).Core_Issue_Category_Name__r.Name:'';
                    //Modified by karthick - 18/06/2018 - Category defect fix
                    caseDetailsByCatSubCat.put(cs.Core_Case_Issue_Category__c,caseInfo);
                }
                if(cs.Core_Case_Issue_Sub_Category__c!=null){
                    //Added by Geetha as per  DE33659
                    caseInfo.issueSubCategory = mapCaseCategory.containsKey(cs.Core_Case_Issue_Sub_Category__c)? mapCaseCategory.get(cs.Core_Case_Issue_Sub_Category__c).Core_Issue_Sub_Category_Name__r.Name:'';
                    //Modified by karthick - 18/06/2018 - Category defect fix
                    caseDetailsByCatSubCat.put(cs.Core_Case_Issue_Sub_Category__c,caseInfo);
                }
            }
        }
        
        if(caseDetailsByCatSubCat <> null && caseDetailsByCatSubCat.size()>0){
            return caseDetailsByCatSubCat;
        }else{
            return null;
        }
    }
    /***************************************************************************************************
Version     : 1.0 
Created Date: 09 Oct 2015
Function    : This method Retrieves Case Information from Asset. 
Input Parameters: Case New List
Output Parameters: None
Transactions: Before Insert, Before Update
Description: This method is used to Update Case Information with parent records related information:
Information from asset (product, supported product, product organization, product Name) is stamped on case using this method. 
A Wrapper class Core_IPS_CaseInformationByAsset is used to maintain the required information.
Used in     : assignCaseInformation method of this class
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods: 0
Number of times called: once per trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/09/2015              Created
****************************************************************************************************/     
    public static List<Asset> getCaseInformationByAssetResultList;
    public static List<Core_IPS_Supported_Product__c> getCaseInformationBySuppProdResultList;    
    public static List<String> getCaseInformationByAssetOldContIdList = new List<String>();
    public static List<String> getCaseInformationBySuppProdOldContIdList = new List<String>();
    public static List<String> getCaseInformationByAssetOrSuppProdNewContIdList = new List<String>();
    private static Map<Id,Core_IPS_CaseInformation> getCaseInformationByAssetOrSuppProd(Set<String> idSet,Boolean isMigrationUser){
        Map<Id,Core_IPS_CaseInformation> caseDetailsById = new Map<Id,Core_IPS_CaseInformation>();
	List<Asset> getCaseInformationByAssetResultList = new List<Asset>();
	List<Core_IPS_Supported_Product__c> getCaseInformationBySuppProdResultList = new List<Core_IPS_Supported_Product__c>();
        List<Id> idList = new List<Id>(); //Added logic as part of Code Refactor TWC745-6459
        //List<Asset> assetList = new List<Asset>();
        //List<core_IPS_supported_product__c> suppProdList = new List<core_IPS_supported_product__c>();
        if(idSet <> null && idSet.size() > 0){
            getCaseInformationByAssetOrSuppProdNewContIdList.clear();
            getCaseInformationByAssetOrSuppProdNewContIdList.addAll(idSet);
            //START - Added logic as part of Code Refactor TWC745-6459
            for(String c:idSet){
                if(String.isNotBlank(c)){
                    idList.add((Id) c);
                }
            }
            //END
            if(getCaseInformationByAssetResultList == null || Core_Utility.executeQuery(getCaseInformationByAssetOrSuppProdNewContIdList,getCaseInformationByAssetOldContIdList))
            {
                if(Asset.SObjectType.getDescribe().isAccessible()){ // FLS check already added
                    // added as part of code refactor
                    if(Core_IPS_CaseTriggerHandler.GlobalAssetRecords!=null &&  Core_IPS_CaseTriggerHandler.GlobalAssetRecords.size()>0 && !isQueryRequired(idList,Core_IPS_CaseTriggerHandler.GlobalAssetRecords,null)){
                      
                        for(Id value : idSet){
                            if(Core_IPS_CaseTriggerHandler.GlobalAssetRecords.containskey(value)){
                                getCaseInformationByAssetResultList.add(Core_IPS_CaseTriggerHandler.GlobalAssetRecords.get(value));   
                            }
                        }
                    }
                    //FLS Added as Part of code refactor
                    else if(Asset.SObjectType.getDescribe().isQueryable()){
                     
                getCaseInformationByAssetResultList = [select id, name,core_supported_product__c,product2Id, Core_Product_Organization__c from asset where id in:idSet];
                    }
                    //END
                }
                getCaseInformationByAssetOldContIdList.clear();
                getCaseInformationByAssetOldContIdList.addAll(idSet);
                
            }
            if(getCaseInformationBySuppProdResultList == null || Core_Utility.executeQuery(getCaseInformationByAssetOrSuppProdNewContIdList,getCaseInformationBySuppProdOldContIdList))
            {
                if(core_IPS_supported_product__c.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
                getCaseInformationBySuppProdResultList = [select id,Core_Supported_Product_Name__c, Name,Core_Product_Organization__c,Core_Product__c,Core_Product__r.name from core_IPS_supported_product__c where id in:idSet];
                }
                getCaseInformationBySuppProdOldContIdList.clear();
                getCaseInformationBySuppProdOldContIdList.addAll(idSet);
                
            }
        }
        
        //assetList = [select id, name,core_supported_product__c,product2Id, Core_Product_Organization__c from asset where id in:idSet];
        //suppProdList = [select id,Core_Supported_Product_Name__c, Name,Core_Product_Organization__c,Core_Product__c,Core_Product__r.name from core_IPS_supported_product__c where id in:idSet];        
        List<Id> suppProdIdList;
        Map<String,String> suppProdIdCodeNameMap;
        Map<String,Set<String>> vphSuppProdIdProdTypeMap;
        Map<String,Set<String>> vplhSuppProdIdProdTypeMap;
        if(getCaseInformationByAssetResultList <> null && getCaseInformationByAssetResultList.size() > 0){
            suppProdIdCodeNameMap = new Map<String,String>();
            vphSuppProdIdProdTypeMap = new Map<String,Set<String>>();
            vplhSuppProdIdProdTypeMap = new Map<String,Set<String>>();
            suppProdIdList = new List<Id>();            
            for(Asset asset:getCaseInformationByAssetResultList){
                suppProdIdList.add(asset.core_supported_product__c);
            }
            //Added logic as part of Code Refactor TWC745-6459
            querySupportedProduct(suppProdIdList);
            //END
            suppProdIdCodeNameMap = Core_IPS_CaseUtility.getCodeName(suppProdIdList);
            //Commented by JP for data migration
            if(isMigrationUser == false){
                vphSuppProdIdProdTypeMap = Core_IPS_CaseUtility.getVPHProductType(suppProdIdList);
                vplhSuppProdIdProdTypeMap = Core_IPS_CaseUtility.getVPLHProductType(suppProdIdList);
            }
            for(Asset asset:getCaseInformationByAssetResultList){
                Core_IPS_CaseInformation caseInfo = new Core_IPS_CaseInformation();
                CaseInfo.supportedProduct = asset.core_supported_product__c;
                CaseInfo.prodOrg = asset.core_product_organization__c;
                CaseInfo.prodName =asset.name;
                CaseInfo.productId=asset.product2Id;
                If(suppProdIdCodeNameMap <> null && suppProdIdCodeNameMap.size() > 0 && suppProdIdCodeNameMap.get(asset.core_supported_product__c) <> null){
                    CaseInfo.codeName = suppProdIdCodeNameMap.get(asset.core_supported_product__c);
                }
                If(vphSuppProdIdProdTypeMap <> null && vphSuppProdIdProdTypeMap.size() > 0 && vphSuppProdIdProdTypeMap.get(asset.core_supported_product__c) <> null){
                    String vphProdTypes = '';
                    for(String prodString : vphSuppProdIdProdTypeMap.get(asset.core_supported_product__c)){
                        if(vphProdTypes == ''){
                            vphProdTypes = prodString;           
                        }else{
                            vphProdTypes = vphProdTypes + ',' +' '+ prodString;  
                        }      
                    }
                    CaseInfo.productType = vphProdTypes;
                }
                If(vplhSuppProdIdProdTypeMap <> null && vplhSuppProdIdProdTypeMap.size() > 0 && vplhSuppProdIdProdTypeMap.get(asset.core_supported_product__c) <> null){
                    String vplhProdTypes = '';
                    for(String prodString : vplhSuppProdIdProdTypeMap.get(asset.core_supported_product__c)){
                        if(vplhProdTypes == ''){
                            vplhProdTypes = prodString;           
                        }else{
                            vplhProdTypes = vplhProdTypes + ',' +' '+ prodString;   
                        }     
                    }
                    CaseInfo.productType = vplhProdTypes;                    
                }                
                caseDetailsById.put(asset.Id,CaseInfo);
            }
        }
        if(getCaseInformationBySuppProdResultList <> null && getCaseInformationBySuppProdResultList.size() > 0){
            suppProdIdCodeNameMap = new Map<String,String>();
            vphSuppProdIdProdTypeMap = new Map<String,Set<String>>();
            vplhSuppProdIdProdTypeMap = new Map<String,Set<String>>();
            suppProdIdList = new List<Id>();
            for(core_IPS_supported_product__c suppProdObj:getCaseInformationBySuppProdResultList){
                suppProdIdList.add(suppProdObj.Id);
            }
            //Added logic as part of Code Refactor TWC745-6459
            querySupportedProduct(suppProdIdList);
            //END
            suppProdIdCodeNameMap = Core_IPS_CaseUtility.getCodeName(suppProdIdList);
            
            //Commented by JP for Data Migration
            if(isMigrationUser == false){
                vphSuppProdIdProdTypeMap = Core_IPS_CaseUtility.getVPHProductType(suppProdIdList);
                vplhSuppProdIdProdTypeMap = Core_IPS_CaseUtility.getVPLHProductType(suppProdIdList);
            }
            for(core_IPS_supported_product__c suppProdObj:getCaseInformationBySuppProdResultList){
                Core_IPS_CaseInformation caseInfo = new Core_IPS_CaseInformation();
                CaseInfo.supportedProduct = suppProdObj.Id;
                CaseInfo.prodOrg = suppProdObj.core_product_organization__c;
                CaseInfo.prodName = suppProdObj.Core_Supported_Product_Name__c;
                CaseInfo.productId= suppProdObj.core_product__c;
                If(suppProdIdCodeNameMap <> null && suppProdIdCodeNameMap.size() > 0 && suppProdIdCodeNameMap.get(suppProdObj.Id) <> null){
                    CaseInfo.codeName = suppProdIdCodeNameMap.get(suppProdObj.Id);
                }
                If(vphSuppProdIdProdTypeMap <> null && vphSuppProdIdProdTypeMap.size() > 0 && vphSuppProdIdProdTypeMap.get(suppProdObj.Id) <> null){
                    String vphProdTypes = '';
                    for(String prodString : vphSuppProdIdProdTypeMap.get(suppProdObj.Id)){
                        if(vphProdTypes == ''){
                            vphProdTypes = prodString;           
                        }else{
                            vphProdTypes = vphProdTypes + ',' +' '+ prodString;    
                        }        
                    }
                    CaseInfo.productType = vphProdTypes;
                }
                If(vplhSuppProdIdProdTypeMap <> null && vplhSuppProdIdProdTypeMap.size() > 0 && vplhSuppProdIdProdTypeMap.get(suppProdObj.Id) <> null){
                    String vplhProdTypes = '';
                    for(String prodString : vplhSuppProdIdProdTypeMap.get(suppProdObj.Id)){
                        if(vplhProdTypes == ''){
                            vplhProdTypes = prodString;           
                        }else{
                            vplhProdTypes = vplhProdTypes + ',' +' '+ prodString; 
                        }       
                    }
                    CaseInfo.productType = vplhProdTypes;                    
                }
                caseDetailsById.put(suppProdObj.Id,CaseInfo);
            }
        }    
        return caseDetailsById;
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 09 Oct 2015
Function    : This method is used to assign entitlement to case. 
Input Parameters: Case New List
Output Parameters: None
Transactions: Before Insert, Before Update
Description: This method is used to assign entitlement to case by retrieving it from account associated to the case:

Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 1 (one for insert and one for update transaction)
Number of Queries in Loop: 0
Number of Queries from Called methods:  0
Number of times called: once per trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/09/2015              Created
* Sumukh C M                 26/11/2018              Modified for US221512 Iteration - 21
****************************************************************************************************/          
    //public static List<Contact> contactResultList;
    
    public static List<String> oldContIdList = new List<String>();
    public static List<String> newContIdList = new List<String>();
    
    public static void assignEntitlementToCase(List<Case> newList){
    	List<Contact> contactResultList = new List<Contact>();
        //List<Case> newCaseList = new List<Case>(); //Commented as part of Code Refactor TWC745-6459
        if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('assignEntitlementToCase')){
            set<string> contactIds = new set<string>();
            List<Id> acctIds = new List<Id>();
            List<Id> contactIdsList = new List<Id>(); //Added as part of Code Refactor TWC745-6459
            //Map<id,id> mapAccountEntitlement =  new Map<id,Id>();//Commented as part of Code Refactor TWC745-6459
            
            for (Case c: newList){
                if (c.EntitlementId == null && c.Core_IPS_Supported_Contact__c!= null ){  /* c.ContactId !=null added by sumukh for US221512 && c.AccountId!= null*/
                    contactIds.add(c.Core_IPS_Supported_Contact__c); // {c.ContactId} added by sumukh for US221512
                    //acctIds.add(c.AccountId);
                    contactIdsList.add(c.Core_IPS_Supported_Contact__c); //Added as part of Code Refactor TWC745-6459
                }
            }
            
            if(contactIds <> null && contactIds.size() > 0){
                newContIdList.clear();
                newContIdList.addAll(contactIds);
                
                if(contactResultList == null || Core_Utility.executeQuery(newContIdList,oldContIdList))
                {   //FLS Check alredy added - Aditya
                    //Added as part of Code Refactor TWC745-6459
                    if (Core_IPS_CaseTriggerHandler.GlobalContactRecords != null && Core_IPS_CaseTriggerHandler.GlobalContactRecords.size()>0 && !isQueryRequired(contactIdsList,Core_IPS_CaseTriggerHandler.GlobalContactRecords,null)){
                       
                        contactResultList = Core_IPS_CaseTriggerHandler.GlobalContactRecords.values();
                    }
                    else if(Contact.SObjectType.getDescribe().isAccessible()){
                    	contactResultList = [select id,accountid from Contact where id in :contactIds];
                    }
                    oldContIdList.clear();
                    oldContIdList.addAll(contactIds);
                    
                }
                if(contactResultList <> null && contactResultList.size() > 0){
                    for(Contact con : contactResultList){
                        acctIds.add(Con.Accountid);
                    }
                }
            }
            if(contactIds.isEmpty()==false || acctIds.isEmpty()==false){
                
                /* Added check for active entitlement */
                /*    List <EntitlementContact> entlContacts = [Select e.EntitlementId,e.ContactId,e.Entitlement.AssetId From EntitlementContact e
Where e.ContactId in:contactIds
And e.Entitlement.EndDate >= Today And e.Entitlement.StartDate <= Today];
if(entlContacts.isEmpty()==false){
for(Case c: newList){
if(c.EntitlementId == null && c.ContactId!= null){
for(EntitlementContact ec:entlContacts){
if(ec.ContactId==c.ContactId){
c.EntitlementId = ec.EntitlementId;
if(c.AssetId==null && ec.Entitlement.AssetId!=null)
c.AssetId=ec.Entitlement.AssetId;
break;}} // end for}} // end for} else{     */
                
                Map<id,Contact> mapContact = new  Map<id,Contact>(contactResultList);
                if(Entitlement.SObjectType.getDescribe().isQueryable()){
                List <Entitlement> entls = [Select e.StartDate, e.Id, e.EndDate, e.AccountId, e.AssetId From Entitlement e Where e.AccountId in:acctIds And e.EndDate >= Today And e.StartDate <= Today];
                if(entls.isEmpty()==false){
                    for(Case c: newList){
                        if(c.EntitlementId == null && mapContact.containskey(c.Core_IPS_Supported_Contact__c)){ // c.EntitlementId == null && c.AccountId!= null -- Changes made by sumukh for US221512
                            for(Entitlement e:entls){
                                if(e.AccountId == mapContact.get(c.Core_IPS_Supported_Contact__c).AccountId){ //  (e.AccountId==c.AccountId) Changes made by sumukh for US221512
                                    c.EntitlementId = e.Id;
                                    if(c.AssetId==null && e.AssetId!=null){
                                        c.AssetId=e.AssetId;
                                    }    
                                    break;
                                }
                            } // end for
                        }
                    } // end for
                    }
                }
            }
            
            else{   
                //Any case without a contact or account is assigned to a default entitlement
                for(Case cs:newList){
                    if(cs.entitlementId==null){ cs.entitlementId=Core_IPS_Helper_Utility.getIPSLabel('SelfAssignedCaseEntitlementId'); }
                }
            }
        }
    }                            
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 09 Oct 2015
Function    : This method is used to provide case access to Created User. 
Input Parameters: Case New List
Output Parameters: None
Transactions: after Update (Assignment rule execution is done after insert which is updating the case and then access is provided accordingly)
Description: This method is used to provide case access to Created User:
This method is required as we are running case assignment rule after case is created which changes owner ship and when we try 
adding environment variable responses under case as the created user may not have access it will throw insufficient access exception
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:  0
Number of times called: once per trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/09/2015              Created
* Neeti Jain                 9/1/2018                Modified
****************************************************************************************************/ 
    public static void provideCaseAccessToCreatedFAE(List<Case> caseList){
        if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('provideCaseAccessToCreatedFAE')){
            set<Id> userIds;
            //List<Id> caseIds = new List<Id>(); //Commented as part of Code Refactor TWC745-6459
            //Set<Id> acctIdSet = new Set<Id>(); //Commented as part of Code Refactor TWC745-6459
            Map<Id,Set<Id>> createdByUsersByCase = new Map<id,set<id>>();
            for(case casRecord:caseList){
                userIds=new set<Id>();
                for(Case cs: caseList){
                    if(cs.id==casRecord.id){
                        userIds.add(cs.createdById);
                        break;
                    }
                }
                createdByUsersByCase.put(casRecord.Id,userIds);
            }
            
            //Core_SharingUtility.provideAccess('Case','CaseShare','Edit',createdByUsersByCase);// commented by becuase execute syncronusly
            
            /****** added by venki 06/05/17 to excute asynorously to provide case sharing********/
            string caserecords=JSON.serialize(createdByUsersByCase);
            /* Added By Neeti Jain on 9/1/2018, US91031*/
            /*Added for bypassing the future method for DM cases in batch mode*/
            if(!system.isBatch()){
                ProvideCaseAccessatFuture(caserecords);// end 
            }
        }
    }
    public static string userid;
    public static List<Profile> lstProfile {get;set;}
    public static Boolean isMigrationUser(string strUserId)
    {   
        //US304935 : Making use of existing label to avoid SOQL query 
        String loggedInUsrProfileId = String.valueOf(userInfo.getProfileId().substring(0, 15));
        String dMprofileId = Label.Core_IPS_Data_Migration_ProfileId;
        
        if(Userid==null || UserId !=strUserId )
        {
            //LstProfile =  new List<Profile>([select id,name from Profile where id = : Userinfo.getProfileId() and name =: 'IPS Data Migration']); 
            UserId = strUserId;
            //if( LstProfile.size() > 0 )
            
            if(Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(strUserId) == true) //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
            {   
                return true;
            }        
        }//else if(UserId == strUserId && LstProfile.size() > 0)
            
        else if(UserId == strUserId && Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(strUserId) == true) ////TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access    
        {
            return true;
        }
        else
        {
            return false;
        }
        return false;              
    }
    
    public static void assignMigratedCaseInformation(List<case> lstNewCase)
    {
        
        Map<String,Case> asstMap = new Map<String,Case>();         
        Set<Id> setContactID =  new Set<Id>();
        Map<Id,Contact> mapContact ;
        
        
        if(LstNewCase !=null)
        {
            for(Case c : LstNewCase)
            {
                if(c.contactid != null && c.AccountID == null)
                {               
                    SetContactID.add(c.contactid);
                }
            }
        }
        //FLS Check added - Aditya
        if(SetContactID.size() > 0 && Contact.SObjectType.getDescribe().isAccessible())
        {    
            //Added as part of Code Refactor TWC745-6459
            if (Core_IPS_CaseTriggerHandler.GlobalContactRecords != null && Core_IPS_CaseTriggerHandler.GlobalContactRecords.size()>0 && !isQueryRequired(new List<Id>(SetContactID),Core_IPS_CaseTriggerHandler.GlobalContactRecords,null)){
                MapContact = Core_IPS_CaseTriggerHandler.GlobalContactRecords;
              
            }
            else{
            MapContact =  new Map<Id,Contact>([Select id,AccountID from Contact where id in :SetContactID]);           
              
            }
            //END
        }
        
        if(LstNewCase !=null)
        {
            for(Case c : LstNewCase)
            {
                if(c.contactid !=null && MapContact!=null && MapContact.containsKey(c.contactid))
                {
                    c.AccountID =  MapContact.get(c.contactid).AccountID ;
                }
                
                if(c.Core_IPS_Project_Case__c != null && c.Core_IPS_Product_Org1__c !=null && c.Core_IPS_Supported_Product__c!= null) 
                {
                    AsstMap.put(String.valueof(c.Core_IPS_Project_Case__c) + String.valueof(c.Core_IPS_Product_Org1__c) + String.valueof(c.Core_IPS_Supported_Product__c) + String.valueof(c.Core_IPS_Legacy_IPS_ID__c),c);                               
                    
                }
                else if(c.AccountID != null && c.Core_IPS_Product_Org1__c !=null && c.Core_IPS_Supported_Product__c!= null) 
                {
                    AsstMap.put(String.valueof(c.AccountID) + String.valueof(c.Core_IPS_Product_Org1__c) + String.valueof(c.Core_IPS_Supported_Product__c) + String.valueof(c.Core_IPS_Legacy_IPS_ID__c),c);
                }
                
            }
            
        }
        if(AsstMap <> null && AsstMap.size()>0)
        {
            Map<string,Asset> mapAssetForCase =  new Map<string,Asset>();
            if(Asset.SObjectType.getDescribe().isAccessible()){ //Fls Read Fix- Gangadhar-22-08-2022
            for(Asset ass : [Select id,accountid,Core_Product_Organization__c,Core_Supported_Product__c,Core_IPS_Project__c from Asset where (Core_IPS_Project__c in : getIds(AsstMap.keyset(),0) OR accountid in :getIds(AsstMap.keyset(),0)) and Core_Supported_Product__c in : getIds(AsstMap.keyset(),36) and Core_Product_Organization__c in : getIds(AsstMap.keyset(),18)])
            {
                if(Ass.Core_IPS_Project__c != null)
                {
                    MapAssetForCase.put(string.valueof(Ass.Core_IPS_Project__c) + string.valueof(Ass.Core_Product_Organization__c)  +  string.valueof(Ass.Core_Supported_Product__c),Ass);
                }
                else if(Ass.Accountid != null)
                {
                    MapAssetForCase.put(string.valueof(Ass.Accountid) + string.valueof(Ass.Core_Product_Organization__c)  +  string.valueof(Ass.Core_Supported_Product__c),Ass);
                }
            }   
            }           //assetMap.putAll(assetMap1);
            for(Case c : LstNewCase)
            {
                if(c.Core_IPS_Project_Case__c != null && c.Core_IPS_Product_Org1__c !=null && c.Core_IPS_Supported_Product__c!= null)
                {
                    
                    string strKeyAsset = string.valueof(c.Core_IPS_Project_Case__c) + string.valueof(c.Core_IPS_Product_Org1__c)  +  string.valueof(c.Core_IPS_Supported_Product__c) ;
                    if(MapAssetForCase.containsKey(strKeyAsset) )
                    {
                        c.AssetId = MapAssetForCase.get(strKeyAsset).id;
                    }
                }
                else if(c.AccountID != null && c.Core_IPS_Product_Org1__c !=null && c.Core_IPS_Supported_Product__c!= null) 
                {
                    
                    string strKeyAsset = string.valueof(c.AccountID) + string.valueof(c.Core_IPS_Product_Org1__c)  +  string.valueof(c.Core_IPS_Supported_Product__c) ;
                    if(MapAssetForCase.containsKey(strKeyAsset))
                    {
                        c.AssetId = MapAssetForCase.get(strKeyAsset).id;
                    }
                }
            }
        }      
        
    }
    public static List<Id> getIds(Set<String> keys,integer pos)
    {
        List<Id> idList = new List<Id>();
        for(String s : keys){
            idList.add(s.mid(pos,18));
        }    
        return idList; 
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 10 Jan 2016
Function    : This method is used to revoke/grant access on Case only for Customers as well as
Intel Support Team members. 
Input Parameters : Old Map of Case, List of Case.
Output Parameters: None
Transactions: 
Description: This method is used to revoke/grant access to Customer on Case:                 
Used in     : 
Number of Queries Within this Method: 4
Number of Queries in Loop: 0
Number of Queries from Called methods: 1
Number of times called: once per trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya              01/10/2016              Created    
* EswaraRao                  06/11/2017              Modified
* Gourav Anand               06/01/2018              Modified
* Aayushi                    25/04/2018              Modified
****************************************************************************************************/
    public static void manageCaseAccessForCustomer(Map<Id,Case> oldMap,List<Case> newList){
        MAP<id,Set<id>> caseShareRecords = new Map<Id,Set<id>>();
        MAP<id,Id> projectCaseShareRecords = new Map<Id,Id>();
        MAP<id,Id> projectCaseShareRecordsInternal = new Map<Id,Id>();
        List<CaseShare> lstCaseShare = new List<CaseShare>(); 
        // code refactor merged to if conditions - 21/09
        if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('ProvideCaseAccess') && newList <> null){
            
                Set<Id> accountIdSet = new Set<Id>();
                Set<Id> projectIdSet = new Set<Id>();
                List<Case> revokableProjectRelatedCaseList = new List<Case>();
                List<Case> revokableAccountRelatedCaseList = new List<Case>();
                
                
                //[To get all RecordTypeIds on Case.]
                Map<ID,Schema.RecordTypeInfo> recordTypeMap = Case.sObjectType.getDescribe().getRecordTypeInfosById();
                Boolean isIPSRecordType;
                
                //Set of Case Contact Ids  -- Added by Eswar 0n 07-11-2017  (US72553 Iteration 2)
                Set<id> caseContactIdsCustomerVisibleFalseSet = new set<Id>();
                Set<id> caseContactIdsCustomerVisibleTrueSet = new set<Id>();
                Set<id> caseIdOfNonCustomerVisibleSet = new Set<Id>();
                
                //Map of Contact Id vs CaseIds  -- Added by Eswar 0n 07-11-2017  (US72553 Iteration 2)
                Map<Id,Id> contactIdCaseIdMap = new Map<Id,Id>();
                Map<Id,Id> conIdCaseIdCVTrueMap = new Map<Id,Id>();
                
                //[Processing All Cases and Segregating them to Account Based and Project Based Cases.]                
                for(Case recCase:newList){
                    
                    //Adding Cases which are customer visible unchecked to set by Eswar 07-11-2017 (US72553 Iteration 2)                
                    if(!recCase.Core_IPS_Customer_Visible__c  && !String.isBlank(recCase.ContactId) && recCase.ContactId!= Null){
                        caseContactIdsCustomerVisibleFalseSet.add(recCase.ContactId);
                        contactIdCaseIdMap.put(recCase.ContactId, recCase.Id); 
                        caseIdOfNonCustomerVisibleSet.add(recCase.Id);  
                    }
                    //Adding Cases which are customer visible checked to set by Eswar 07-11-2017 (US72553 Iteration 2)
                    if(recCase.Core_IPS_Customer_Visible__c &&  !String.isBlank(recCase.ContactId) && recCase.ContactId != Null){
                        caseContactIdsCustomerVisibleTrueSet.add(recCase.ContactId);  
                        conIdCaseIdCVTrueMap.put(recCase.ContactId, recCase.Id);
                    }
                    
                    
                    //[Initializing the Boolean variable.]
                    isIPSRecordType = false;
                    
                    //[To check the IPS Cases.]
                    for(String recTypeName:System.Label.Core_IPS_Case_RecordType_Name.split(';')){
                        if(recordTypeMap <> null && recordTypeMap.get(recCase.RecordTypeId).getName() == recTypeName){
                            isIPSRecordType = true;
                        } 
                    }
                    
                    //[Checking if the associated recordtype of Case is related to IPS.]
                    if(isIPSRecordType){                    
                        
                        //To revoke the Project based Case access by Eswar 07-11-2017 (US72553 Iteration 2)
                        if(recCase.Core_IPS_Project_Case__c!=null){
                            projectIdSet.add(recCase.Core_IPS_Project_Case__c);   
                            if(!recCase.Core_IPS_Customer_Visible__c){ 
                                revokableProjectRelatedCaseList.add(oldMap.get(recCase.Id));
                            }
                        }
                        //To revoke the Account based Case access by Eswar 07-11-2017 (US72553 Iteration 2)
                        else if (recCase.AccountId!=null){
                            accountIdSet.add(recCase.AccountId);       
                            if(!recCase.Core_IPS_Customer_Visible__c){ 
                                revokableAccountRelatedCaseList.add(oldMap.get(recCase.Id));
                            }
                        }
                        
                        if(recCase <> null && recCase.AccountId <> null && recCase.Core_IPS_Project_Case__c == null && oldmap!=null && oldMap.get(recCase.Id) <> null && oldMap.get(recCase.Id).Core_IPS_Project_Case__c <> null){
                            //[Adding Old Case in a list.]
                            revokableProjectRelatedCaseList.add(oldMap.get(recCase.Id));
                            
                        }//[Scenario A : Project Based Case is changing to Account Based.]
                        
                        
                        if(recCase <> null && recCase.Core_IPS_Project_Case__c <> null && oldmap!=null && oldMap.get(recCase.Id) <> null && oldMap.get(recCase.Id).Core_IPS_Project_Case__c <> null && oldMap.get(recCase.Id).Core_IPS_Project_Case__c <> recCase.Core_IPS_Project_Case__c){
                            //[Adding Old Case in a list.]
                            revokableProjectRelatedCaseList.add(oldMap.get(recCase.Id));
                            
                        }//[Scenario B : Project is changing]
                        
                        
                        else if(recCase <> null && recCase.Core_IPS_Project_Case__c <> null && oldmap!=null && oldMap.get(recCase.Id).Core_IPS_Project_Case__c == null){
                            //[Adding Old Case in a list.]
                            revokableAccountRelatedCaseList.add(oldMap.get(recCase.Id));
                            
                        }//[Scenario C : Account Based Case is changing to Project Based.]
                        
                        
                        else if(recCase <> null && recCase.AccountId <> null && recCase.Core_IPS_Project_Case__c == null && oldmap!=null && oldMap.get(recCase.Id).Core_IPS_Project_Case__c == null && oldMap.get(recCase.Id).AccountId <> null && recCase.AccountId <> oldMap.get(recCase.Id).AccountId){
                            revokableAccountRelatedCaseList.add(oldMap.get(recCase.Id));
                            
                        }//[Scenario D : Account is changing.]
                        /*Ashutosh- US106566 - we need to check the case where project is set to null for NAC case as above all check are based on
Account value when project is null but NAC will not have account so need to check independently
[check condition - case != null AND Project == null AND OLDCASE.Project != null AND Case.CustomerVisible = false(As NAC case)]*/
                        
                        else if(recCase <> null && recCase.Core_IPS_Project_Case__c == null && oldmap!=null && oldMap.get(recCase.Id).Core_IPS_Project_Case__c != null && !recCase.Core_IPS_Customer_Visible__c){
                            revokableProjectRelatedCaseList.add(oldMap.get(recCase.Id));
                            
                        }
                    }
                }
                
                if(revokableProjectRelatedCaseList <> null && revokableProjectRelatedCaseList.size() > 0){
                    Map<Id,Id> revokeProjectCaseSharing = new Map<Id,Id>(); 
                    Map<Id,Id> revokeProjectCaseSharingInternal = new Map<Id,Id>(); 
                    List<Core_IPS_Project__c> projList;
                    Map<Id,Id> projectIdbyCaseId = new Map<Id,Id>();
                    Map<Id,Id> groupIdbyProjectId = new Map<Id,Id>();
                    Map<Id,Id> internalGroupIdbyProjectId = new Map<Id,Id>();           //added by Aayushi US102841
                    for(Case csObj : revokableProjectRelatedCaseList){ 
                        
                        projectIdbyCaseId.put(csObj.Id,csObj.Core_IPS_Project_Case__c);                           
                        
                    }   
                    if(Core_IPS_Project__c.SObjectType.getDescribe().isQueryable()){
                    if(projectIdbyCaseId <> null && projectIdbyCaseId.size() > 0){
                        // Start : Code Refactor Changes to Reduce Project Query **********************************************************
                        List<String> ProjectIds = new List<String>(); // Code Refactor changes
                        for(Id value : projectIdbyCaseId.Values()){
                            ProjectIds.add(String.ValueOf(value));
                        }
                       
                        if( !ProjectIds.isEmpty() && Core_Utility.executeQuery(ProjectIds,OldprojectIdList) ) {
                          
                            // END
                        projList = [select Id,Core_IPS_GroupId__c,Core_IPS_InternalGroupId__c from Core_IPS_Project__c where Id in:projectIdbyCaseId.values()];
                            // Start
                          
                            if(!projList.isEmpty()){  GlobalProjectRecordsList = new List<Core_Ips_Project__c>(projList); }
                            OldprojectIdList = new List<String>(ProjectIds);
                        } else if(GlobalProjectRecordsList != null && GlobalProjectRecordsList.size()>0){
                          
                            projList = new List<Core_IPS_Project__c>(GlobalProjectRecordsList);
                          
                        }
                        //END *****************************************************************************************************************************
                    }
                    
                    if(projList <> null && projList.size() > 0){
                        for(Core_IPS_Project__c proj:projList){
                            groupIdbyProjectId.put(proj.Id,proj.Core_IPS_GroupId__c);
                            if(proj.Core_IPS_InternalGroupId__c!=null){
                                internalGroupIdbyProjectId.put(proj.Id,proj.Core_IPS_InternalGroupId__c);   //added by Aayushi US102841
                                }
                            }
                        }
                    }
                    for(Case caseObj:revokableProjectRelatedCaseList){
                        if(groupIdbyProjectId <> null && groupIdbyProjectId.size() > 0){
                            revokeProjectCaseSharing.put(caseObj.Id,groupIdbyProjectId.get(caseObj.Core_IPS_Project_Case__c));    
                        }
                        
                        //added by Aayushi US102841
                        if(internalGroupIdbyProjectId <> null && internalGroupIdbyProjectId.size() > 0){
                            revokeProjectCaseSharingInternal.put(caseObj.Id,internalGroupIdbyProjectId.get(caseObj.Core_IPS_Project_Case__c));    
                        } 
                    }
                    if(revokeProjectCaseSharing <> null && revokeProjectCaseSharing.size() > 0){
                        
                        Core_SharingUtility.RevokeAccess('Case','CaseShare',revokeProjectCaseSharing);
                    }  
                    
                    if(revokeProjectCaseSharingInternal <> null && revokeProjectCaseSharingInternal.size() > 0){
                        
                        Core_SharingUtility.RevokeAccess('Case','CaseShare',revokeProjectCaseSharingInternal);
                    } 
                }
                
                if(revokableAccountRelatedCaseList <> null && revokableAccountRelatedCaseList.size() > 0){
                    Set<Id> accIdSet = new Set<Id>();
                    Map<Id,Set<Id>> groupIdsbyRoleId = new Map<Id,Set<Id>>();
                    List<Id> userRoleIdList = new List<Id>();
                    Set<Id> groupIdSet = new Set<Id>();                     
                    Map<Id,Set<Id>> revokeAccountCaseSharing = new Map<Id,Set<Id>>();
                    for(Case csObj : revokableAccountRelatedCaseList){ 
                        
                        accIdSet.add(csObj.AccountId);                                                 
                        
                    }   
                    if(accIdSet <> null && accIdSet.size() > 0){                         
                        Map<Id,Set<Id>> custUserRoleIdsByAccId = Core_SharingUtility.getCustomerUserRoleIdsByAccountId(accIdSet);
                        for(Id accId: accIdSet){
                            if(custUserRoleIdsByAccId <> null && custUserRoleIdsByAccId.size() > 0 && custUserRoleIdsByAccId.get(accId) <> null && custUserRoleIdsByAccId.get(accId).size() > 0){
                                for(Id userRoleId:custUserRoleIdsByAccId.get(accId)){
                                    userRoleIdList.add(userRoleId);
                                }                             
                            }
                        }
                        if(userRoleIdList <> null && userRoleIdList.size() > 0){
                            groupIdsbyRoleId = Core_SharingUtility.getGroupIdsByRoleId(userRoleIdList);
                        }    
                        for(Case caseObj: revokableAccountRelatedCaseList){
                            if(custUserRoleIdsByAccId <> null && custUserRoleIdsByAccId.size() > 0 && custUserRoleIdsByAccId.get(caseObj.AccountId) <> null && custUserRoleIdsByAccId.get(caseObj.AccountId).size() > 0){
                                for(Id userRoleId:custUserRoleIdsByAccId.get(caseObj.AccountId)){
                                    if(groupIdsbyRoleId <> null && groupIdsbyRoleId.size() > 0 && groupIdsbyRoleId.get(userRoleId) <> null && groupIdsbyRoleId.get(userRoleId).size() > 0){
                                        for(Id groupId:groupIdsbyRoleId.get(userRoleId)){
                                            groupIdSet.add(groupId);
                                        }
                                    }
                                }                             
                            }
                            revokeAccountCaseSharing.put(caseObj.Id,groupIdSet);
                        }                         
                        if(revokeAccountCaseSharing <> null && revokeAccountCaseSharing.size() > 0){
                            
                            Core_SharingUtility.RevokeAccess('Case','CaseShare',revokeAccountCaseSharing);
                        }
                    }                                          
                }
                
                if(projectIdSet <> null && projectIdSet.size() > 0){
                    Map<Id,Id> groupIdbyProjectId = new Map<Id,Id>();
                    Map<Id,Id> internalGroupIdbyProjectId = new Map<Id,Id>();       //added by Aayushi US102841
                    if(Core_IPS_Project__c.SObjectType.getDescribe().isAccessible()){ // FLS Check already added - aditya
                    // Start : Code Refactor Changes to Reduce Project Query **********************************************************
                    List<String> ProjectIds = new List<String>( ); // Code Refactor changes
                    for(Id value : projectIdSet){
                        ProjectIds.add(String.ValueOf(value));
                    }
                    if( !ProjectIds.isEmpty() && Core_Utility.executeQuery(ProjectIds,OldprojectIds) ) {
                      
                        OldprojectIds = new List<String>(ProjectIds);
                       
                        // FLS FIX
                        // START
                        List<Core_IPS_Project__c> ProjectList = new List<Core_IPS_Project__c>();
                        if(Core_IPS_Project__c.SObjectType.getDescribe().isQueryable()){
                            ProjectList = [select Id,Core_IPS_GroupId__c,Core_IPS_InternalGroupId__c from Core_IPS_Project__c where Id in:projectIdSet];
                        }
                        // END
                        //for(Core_IPS_Project__c projObj:[select Id,Core_IPS_GroupId__c,Core_IPS_InternalGroupId__c from Core_IPS_Project__c where Id in:projectIdSet]){
                        for(Core_IPS_Project__c projObj : ProjectList){
                            GlobalProjectRecords = new List<Core_IPS_Project__c>();
                            GlobalProjectRecords.add(projObj);
                        groupIdbyProjectId.put(projObj.Id,projObj.Core_IPS_GroupId__c);
                        //added by Aayushi US102841
                        if(projObj.Core_IPS_InternalGroupId__c!=null){
                            internalGroupIdbyProjectId.put(projObj.Id,projObj.Core_IPS_InternalGroupId__c);
                        }
                        }
                        //Start
                    } 
                    else if(GlobalProjectRecords != null && GlobalProjectRecords.size()>0){
                       
                        for(Core_IPS_Project__c projObj: GlobalProjectRecords){
                            groupIdbyProjectId.put(projObj.Id,projObj.Core_IPS_GroupId__c);
                            //added by Aayushi US102841
                            if(projObj.Core_IPS_InternalGroupId__c!=null){
                                internalGroupIdbyProjectId.put(projObj.Id,projObj.Core_IPS_InternalGroupId__c);
                            }
                        }                            
                    }
                    //END
                }
                    for(Case caseObj:newList){
                        if(caseObj.Core_IPS_Customer_Visible__c){ // Added by Eswar 0n 08-11-2017  (US72553 Iteration 2)
                            projectCaseShareRecords.put(caseObj.Id,groupIdbyProjectId.get(caseObj.Core_IPS_Project_Case__c));        
                        }
                        if(internalGroupIdbyProjectId!=null && internalGroupIdbyProjectId.size()>0){
                            
                            projectCaseShareRecordsInternal.put(caseObj.Id,internalGroupIdbyProjectId.get(caseObj.Core_IPS_Project_Case__c));        
                        }
                    }
                    
                }
                if(accountIdSet <> null && accountIdSet.size() > 0){
                    Set<Id> groupIdSet;
                    List<Id> userRoleIdList = new List<Id>();
                    Map<Id,Set<Id>> groupIdsbyRoleId = new Map<Id,Set<Id>>();
                    Map<Id,Set<Id>> groupIdbyAccountId = new Map<Id,Set<Id>>();
                    
                    Map<Id,Set<Id>> custUserRoleIdsByAccId = Core_SharingUtility.getCustomerUserRoleIdsByAccountId(accountIdSet);
                    for(Id accId: accountIdSet){
                        if(custUserRoleIdsByAccId <> null && custUserRoleIdsByAccId.size() > 0 && custUserRoleIdsByAccId.get(accId) <> null && custUserRoleIdsByAccId.get(accId).size() > 0){
                            for(Id userRoleId:custUserRoleIdsByAccId.get(accId)){
                                userRoleIdList.add(userRoleId);
                            }                             
                        }
                    }
                    if(userRoleIdList <> null && userRoleIdList.size() > 0){
                        groupIdsbyRoleId = Core_SharingUtility.getGroupIdsByRoleId(userRoleIdList);
                    }    
                    
                    for(Id accId: accountIdSet){
                        if(custUserRoleIdsByAccId <> null && custUserRoleIdsByAccId.size() > 0 && custUserRoleIdsByAccId.get(accId) <> null && custUserRoleIdsByAccId.get(accId).size() > 0){
                            groupIdSet = new Set<Id>();
                            for(Id userRoleId:custUserRoleIdsByAccId.get(accId)){
                                if(groupIdsbyRoleId <> null && groupIdsbyRoleId.size() > 0 && groupIdsbyRoleId.get(userRoleId) <> null && groupIdsbyRoleId.get(userRoleId).size() > 0){
                                    for(Id groupId:groupIdsbyRoleId.get(userRoleId)){
                                        groupIdSet.add(groupId);
                                    }
                                }    
                            }                             
                            if(groupIdSet <> null && groupIdSet.size() > 0){
                                groupIdbyAccountId.put(accId,groupIdSet);
                            }    
                        }
                    }
                    for(Case caseObj:newList){                     
                        // Appended caseObj.Core_IPS_Customer_Visible__c by Eswar 0n 08-11-2017  (US72553 Iteration 2)
                        // Added by Gourav for US91294: caseObj.CORE_IPS_ISSUE_SOURCE__C != 'Legacy PSG' in IF condition to restrict visibility for Account Contacts for PSG migrated cases
                        if(caseObj.Core_IPS_Project_Case__c == null && groupIdbyAccountId <> null && groupIdbyAccountId.size() > 0 && groupIdbyAccountId.get(caseObj.AccountId) <> null && caseObj.Core_IPS_Customer_Visible__c  &&  caseObj.CORE_IPS_ISSUE_SOURCE__C != System.label.Core_IPS_Legacy_PSG){                                                        
                            caseShareRecords.put(caseObj.Id,groupIdbyAccountId.get(caseObj.AccountId));  
                            
                        }
                    }                    
                }
                try{
                    
                    if(caseShareRecords.size() > 0){
                        string caserecords=JSON.serialize(caseShareRecords);
                        
                        Core_SharingUtility.provideAccess('case', 'caseShare','Edit',caseShareRecords); // commented by venki
                        
                    }                                               
                    if(projectCaseShareRecords.size() > 0){
                        string caserecords=JSON.serialize(projectCaseShareRecords);
                        
                        Core_SharingUtility.provideAccess('case', 'caseShare','Edit',projectCaseShareRecords);// commented by venki
                    }
                    
                    //added by Aayushi US102841
                    if(projectCaseShareRecordsInternal.size() > 0){
                        string caserecords=JSON.serialize(projectCaseShareRecordsInternal);
                        
                        Core_SharingUtility.provideAccess('case', 'caseShare','Edit',projectCaseShareRecordsInternal);
                    }
                    
                    //Map of ContactId vs User id  -- Added by Eswar 0n 08-11-2017  (US72553 Iteration 2)
                    Map<Id,Set<Id>> caseContactUserCustomerVisibleFalseMap = new Map<Id,Set<Id>>();
                    Map<Id,Set<Id>> caseContactUserCustomerVisibleTrueMap = new Map<Id,Set<Id>>();
                    
                //added as part of Code Refactor 
                List<user> uList = new List<user>();
                List<ID> caseContactIds = new List<ID>();
                if(caseContactIdsCustomerVisibleFalseSet != null){ caseContactIds.addAll(caseContactIdsCustomerVisibleFalseSet); }
                if(caseContactIdsCustomerVisibleTrueSet != null){  caseContactIds.addAll(caseContactIdsCustomerVisibleTrueSet); }
                
                Map<Id,Id> contactUserIdsMap = Core_IPS_CaseTriggerHandler.GlobalContactUserIdMap;
                Map<Id,User> userRecordsMap = Core_IPS_CaseTriggerHandler.GlobalUserRecords;
                
                if(userRecordsMap != null && userRecordsMap.size()>0 && contactUserIdsMap!=null && contactUserIdsMap.size()>0 && !caseContactIds.isEmpty() && !isQueryRequired(caseContactIds,null,contactUserIdsMap) && !isQueryRequired(contactUserIdsMap.Values(),userRecordsMap,null)){     
                    for(Id value : caseContactIds){
                        if(contactUserIdsMap != null && contactUserIdsMap.size()>0 && contactUserIdsMap.containsKey(value) && userRecordsMap.containskey(contactUserIdsMap.get(value))){
                            uList.add(userRecordsMap.get(contactUserIdsMap.get(value)));
                        }
                    }
                 
                }
                else  {
                    uList = [Select ContactId,Id from User where ContactId IN : caseContactIdsCustomerVisibleFalseSet OR contactID in :caseContactIdsCustomerVisibleTrueSet]; /***/
                  
                }
                //end
                
                    //Retrieving the users of ContactId vs User id  -- Added by Eswar 0n 08-11-2017  (US72553 Iteration 2)
                //commmented for loop query - code Refactor
                //  for(User uObj: [Select ContactId,Id from User where ContactId IN : caseContactIdsCustomerVisibleFalseSet OR contactID in :caseContactIdsCustomerVisibleTrueSet]){
                for(User uObj: uList){
                        
                        if(caseContactIdsCustomerVisibleFalseSet.contains(uObj.contactid)){
                            caseContactUserCustomerVisibleFalseMap.put(ContactIdCaseIdMap.get(uObj.ContactId), new set<Id>{uObj.Id});
                        }else{
                            caseContactUserCustomerVisibleTrueMap.put(conIdCaseIdCVTrueMap.get(uObj.ContactId), new set<Id>{uObj.Id});
                        }    
                    }
                    if(CaseShare.SObjectType.getDescribe().isQueryable()){ //FLS check already added - Aditya
                    // Retrieving the caseShare records to provide read/edit access Added by Eswar 0n 08-11-2017  (US72553 Iteration 2)
                        lstCaseShare = [SELECT CaseAccessLevel,CaseId,Id,RowCause 
                                                    FROM CaseShare 
                                                    WHERE RowCause = 'RelatedPortalUser'
                                                    And (caseId IN:caseContactUserCustomerVisibleFalseMap.keySet() or 
                                                         caseId IN:caseContactUserCustomerVisibleTrueMap.keySet())];
                    /// create case share 
                    createCaseShare(lstCaseShare, caseContactUserCustomerVisibleFalseMap, caseContactUserCustomerVisibleTrueMap );
                    }
                    
                    
                    //Remove all external interested parties if customer visible checkbox is not checked for case. 
                    // Added by Eswar 0n 08-11-2017  (US72553 Iteration 2)
                    List<Core_IPS_Case_Interested_Party__c> lstIntParty = new List<Core_IPS_Case_Interested_Party__c>();
                    for( Core_IPS_Case_Interested_Party__c intParties : [SELECT Id, Case__r.Id FROM Core_IPS_Case_Interested_Party__c                                    WHERE  Case__r.Id  IN: caseIdOfNonCustomerVisibleSet AND Type__c = 'External']) {
                        lstIntParty.add(intParties);
                    }
                    if(lstIntParty.size()>0 ){  
                        if(Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isDeletable()){
                            delete lstIntParty;
                        } 
                    }
                    
                    
                }catch(Exception e){      }
            
        }
    }    
    
    public static void createCaseShare(list<CaseShare> lstCaseShare, Map<Id,Set<Id>> caseContactUserCustomerVisibleFalseMap,
                                       Map<Id,Set<Id>> caseContactUserCustomerVisibleTrueMap ){
                                           
                                           List<CaseShare> lstCaseShareToUpdate = new List<CaseShare>();        
                                           if(lstCaseShare.size() > 0){
                                               for(CaseShare cshObj: lstCaseShare){
                                                   //Provide Read Only access to associated contact if customer visible is unchecked
                                                   if(caseContactUserCustomerVisibleFalseMap.containskey(cshObj.CaseId)){
                                                       CaseShare csShareRec = new CaseShare();
                                                       csShareRec.CaseAccessLevel = 'Read';
                                                       csShareRec.Id = cshObj.Id;
                                                       lstCaseShareToUpdate.add(csShareRec);
                                                   }
                                                   //Provide Edit access to associated contact if customer visible is checked
                                                   else if(caseContactUserCustomerVisibleTrueMap.containskey(cshObj.CaseId)){
                                                       CaseShare csShareRec = new CaseShare();
                                                       csShareRec.CaseAccessLevel = 'Edit';
                                                       csShareRec.Id = cshObj.Id;
                                                       lstCaseShareToUpdate.add(csShareRec);
                                                   }
                                                   
                                               }
                                           }   
                                           if(lstCaseShareToUpdate.size()>0){
                                               update  lstCaseShareToUpdate;
                                           }
                                       }     
    
    public static Schema.DescribeSObjectResult descCase;  
    public static Map<id,Schema.RecordTypeInfo> mapCaseRecordTypeID ;
    public static Map<string,Schema.RecordTypeInfo> mapCaseRecordTypeName;    
    public static Id getCaseRecordtypeIDByName(string caseRecordtypeName)
    {
        Id  caseRecordtypeID = null;
        if(DescCase==null)
        {
            DescCase = Schema.SObjectType.Case; 
        }
        if(MapCaseRecordTypeName ==  null)
        {
            MapCaseRecordTypeName = DescCase.getRecordTypeInfosByName();
        }       
        CaseRecordtypeID = MapCaseRecordTypeName.get(caseRecordtypeName).getRecordTypeId();
        return CaseRecordtypeID;
        
    }
    public static string getCaseRecordtypeNameById(string caseRecordtypeId)
    {
        string  caseRecordtypeName ='';
        if(DescCase==null)
        {
            DescCase = Schema.SObjectType.Case; 
        }
        
        if(MapCaseRecordTypeID ==  null)
        {
            MapCaseRecordTypeID = DescCase.getRecordTypeInfosById();
        }
        
        CaseRecordtypeName = MapCaseRecordTypeID.get(caseRecordtypeId).getName();
        return CaseRecordtypeName;
        
    }
    
    
    public static Map<String, Group> loadGroupByName(list<Group>listwithgroup, Map<String,Group> mapGroupByName)
    {
        if (mapGroupByName == NULL){
            mapGroupByName = new Map<String,Group>();
        }else {
            
            for(Group g:listwithgroup){
                if (mapGroupByName.keySet().contains(g.developerName)){
                return mapGroupByName;
                }
            }
        }
        List<Group> lstGroup;
        //check here not null condition
        if(!listwithgroup.isEmpty()){
            lstGroup = listwithgroup;
        }
        
        if (lstGroup == NULL){
            return mapGroupByName;                
        }
        if (lstGroup <> null && lstGroup.size() > 0){
            for(Group objGroup : lstGroup){ 
                if (!mapGroupByName.keySet().contains(objGroup.DeveloperName)){
                    mapGroupByName.put(objGroup.DeveloperName, objGroup);
                }
            }
        }       
        return mapGroupByName;    
    }
    
    
    public static Map<Id, Group> loadGroupById(List<Case> lstCaseList)
    {
        Set<Id> groupIds = new Set<Id>(); 
        for (Case cs : lstCaseList) { 
            if (String.valueOf(cs.OwnerId).startsWith('00G')){
                groupIds.add(cs.OwnerId);
            }    
        }
        List<Group> lstGroup;
        if(Group.SObjectType.getDescribe().isQueryable())
        { 
            lstGroup = [SELECT Id, Name, DeveloperName 
                                FROM Group 
                                WHERE Id IN :groupIds];
        }
        
        if (lstGroup == NULL){
            return NULL;      
        }              
        
        return new Map<Id, Group>(lstGroup);    
    }
    
    /***************************************************************************************************       
Version     : 1.0       
Created Date: 16 May 2017       
Function    :  Method is added to default the value of priority to severity when a new case is being created.       
Output Parameters: None     
Transactions:       
Description: Method is added to default the value of priority to severity when a new case is being created.     
Modification Log :      
* Developer                   Date                   Description        
* ----------------------------------------------------------------------------                      
* Aparna                 05/16/2017                 Created 
* Ashutosh               05/17/2018                 Modified
* Aparna                 19/11/2018                 Modified for US221489
* Aparna                 22/02/2019                 Added logic for US253169
* Gourav                 27/02/2019                 US253168:Logic for new MINDS routing to GEC Queue
****************************************************************************************************/       
    public static void iPSCaseFieldsInit(List<Case>newCaseList)       
    {       
        //Ashutosh -US103890 - Added execution check
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('IPSCaseFieldsInit')){
            return;
        }    
        try{     
            List<String> mylbl= Label.Core_IPS_CaseRecordType_Priority_Defaulting.split(',');       
            List<RecordType> rt = [Select Id from RecordType where Name IN :Mylbl];     
            Set<Id> caseRTId = new Set<Id>(); 
            //Set<Id> accountIds = new Set<Id>();//Ashutosh - Us103890 //Commented as part of Code Refactor TWC745-6459
            Set<Id> supContIds = new set<Id>(); //Added by Aparna for US221489-I21;19/11/2018
            map<Id,Contact> contMap = new map<Id,Contact>();
            //Map<Id,Account> accountById; //Commented as part of Code Refactor TWC745-6459
            //added by ranjini
            Id recordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS No Assigned Contact Case'); 
            Id getUserID = System.UserInfo.getUserId();
            
            for(RecordType vRT:RT)      
            {       
                if(vRT.id!=null){       
                    caseRTId.add(vRT.Id);       
                }
            }       
            
            for(case cc : newCaseList)       
            {   
                /*if(cc.accountId != null){
accountIds.add(cc.accountId);
}*/ 
                /*added by ranjini for US404759*/
                //if(RecordTypeId == cc.RecordTypeId && trigger.Isinsert ){
                if(String.valueOf(recordTypeId).equalsIgnoreCase(String.valueOf(cc.RecordTypeId))){
                    cc.Core_Intel_Sup_Owner__c = getUserID;
                } 
                //Modified by Gourav  Core_IPS_Supported_Contact__c US221486
                if(cc.ContactId!=null) {
                    cc.Core_IPS_Supported_Contact__c = cc.ContactId;
                    
                } 
                supContIds.add(cc.Core_IPS_Supported_Contact__c);  //Added for US221489
                
                if((cc.Status!=null) && (cc.RecordTypeId!=null) && (caseRTId!=null))       
                {       
                    if((cc.Status=='New') && (cc.Core_Severity__c!=null) && (caseRTId.contains(cc.RecordTypeId))){      
                        cc.Priority=cc.Core_Severity__c;        
                    }       
                } 
                
                //US253168: Gourav - Logic for new MINDS routing to GEC Queue
                Id recordTypeIdGEC = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();
                String embargoedCountries = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_EmbargoedCountryList');
                List<String> countryList = embargoedCountries.split(',');
                if((cc.Core_IPS_Minds__c && cc.Core_IPS_Country_Region__c != Core_IPS_Helper_Utility.getIPSLabel('USA'))){
                    cc.Core_IPS_GEC_Flag__c = true;
                    cc.IsStopped = true;  
                    cc.Status = 'On Hold';
                    cc.Core_Sub_Status__c = 'GEC Hold';
                    cc.recordtypeID =  recordTypeIdGEC;                    
                }// End for US253168
                
                //Added for US253169 by Aparna;I-04;22/2/2019
                if(cc.Core_IPS_Minds__c && cc.Core_IPS_Country_Region__c ==Core_IPS_Helper_Utility.getIPSLabel('USA')){
                    cc.Core_IPS_GEC_Status__c = Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved_WithG');
                }
                //end for US253169            
            }
            //Start - Added as part of Code Refactor TWC745-6459
            if(supContIds !=null && supContIds.size()>0 && Core_IPS_CaseTriggerHandler.GlobalContactRecords!= null && Core_IPS_CaseTriggerHandler.GlobalContactRecords.size()>0 && !isQueryRequired(new List<Id>(supContIds),Core_IPS_CaseTriggerHandler.GlobalContactRecords,null)){
              
                contMap = Core_IPS_CaseTriggerHandler.GlobalContactRecords;
            }
            else if(supContIds !=null && supContIds.size()>0 && Contact.SObjectType.getDescribe().isAccessible()){ //FLS Check already added - Aditya
              
                contMap = new Map<Id,Contact>([Select Id,AccountId,Account.Core_CNDA_Number__c from Contact where Id in :supContIds AND Account.Core_CNDA_Number__c!=null]); //Added for US221489
            }
            //End 
            
            /*for(Contact objCon : contMap.values()) { //Added for US221489
accountIds.add(objCon.AccountId);
}*/
            
            //Ashutosh - Us103890
            if(contMap !=null && contMap.size()>0){
                //accountById = new Map<Id,Account>([Select Id, Core_CNDA_Number__c  From Account Where Core_CNDA_Number__c != null AND Id IN :accountIds]);
                //if(accountById != null && accountById.size()>0) {
                for(case csNew : newCaseList){
                    //Modified for US221489 - Included Supported Contact Check and its AccountId check below 
                    if(!csNew.isClone() && csNew.Core_IPS_Supported_Contact__c !=null && caseRTId.contains(csNew.RecordTypeId) &&
                       contMap.containsKey(csNew.Core_IPS_Supported_Contact__c) && contMap.get(csNew.Core_IPS_Supported_Contact__c).Account.Core_CNDA_Number__c!=null)  //Added as part of Code Refactor TWC745-6459
                    {
                        //if(accountById.keyset().contains(contMap.get(csNew.Core_IPS_Supported_Contact__c).accountId)){                                                        
                        csNew.Core_IPS_Classification__c = 'Intel Confidential';
                        //}
                    }
                    
                }
                //}
            }
            
            
            
        }catch(Exception ex){  Core_IPS_ExceptionHandling.logEntryWithException(ex,'Core_IPS_CaseTriggerHandler','case');}      
    }
    
    /************************************************************************************************************************************
Method Name:ProvideCaseAccessatFuture
paremeter string json
description: creating case sharing record on asycronously
created by: venki 18/5/17
*********************************************************************************************************************************/
    //@future
    public static void provideCaseAccessatFuture(String csShareList){
        
        try{MAP<id,Set<id>>createdByUsersByCase= (Map<Id,Set<Id>>)JSON.deserialize(csShareList, Map<Id,Set<Id>>.class);
            
            Core_SharingUtility.provideAccess('Case','CaseShare','Edit',createdByUsersByCase);
            
           } catch(Exception ex){  Core_IPS_ExceptionHandling.logEntryWithException(ex,'Core_IPS_CaseTriggerHandler.ProvideCaseAccessatFuture','case');
                                }   
    }  
    /****************************************************************************************************
Version     : 1.0 
Created Date: 09 Oct 2017
Trigger Name: Core_CaseTrigger
Function    : This method is use for update the support level Field value on Case From Support Level(For IPS Case Create) And Support Org(For No Assigned Contact Case).
Input Parameters: Case New List
Output Parameters: None
Transactions: Before Insert
Description: This method executes on Case Creation.  
Used in     : Core_CaseTrigger_Dispatcher
Feature     : F5346          
UserStory   : US72443,US80096  
Number of Queries Within this Method: 2
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Yogesh Sharma              09/10/17                 Created
* Gourav Anand               19/11/18                 US221486-Modified existing logic to fetch Support Level based on Supported Contact_Account
* Gourav Anand               20/12/18                 US237240 : To update Support Level for GEC cases  
****************************************************************************************************/  
    public static void updateSupportLevelOnCase(List<Case> triggerNew,Map<Id,Case> oldMap){
        Map<Id,Contact> suppContAccMap = new Map<Id,Contact>(); //Added as part of code refactor
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSupportLevelOnCase')){
            return;
        }    
        try{
            String iPSCaseCreateCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_Case_Create');
            String noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
            String supportLevelDefaultValue = Core_IPS_Helper_Utility.getIPSLabel('Support_Level_Default');
            String supportLevelDefaultValueNoAssignedContact = Core_IPS_Helper_Utility.getIPSLabel('Support_Level_Default_No_Assigned_Cont');
            Id accountID;
            
            Id iPSCaseCreateId = getCaseRecordtypeIDByName(iPSCaseCreateCaseRecordType);
            Id noAssignedContactCaseId = getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
            //US237240 : Gourav - To update Support Level for GEC cases
            Id gECRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();
            
            Set<Id> assetIds = new Set<Id>();
            Map<String,Id> accountAssetIdComboToAccountIdMap = new Map<String,Id>();
            Map<String,String> accountAssetIdComboToUniqueKey = new Map<String,String>();
            Map<Id,Asset> assetMap = new Map<Id,Asset>(); //Added as part of code refactor
            //Set<Id> projectId=new Set<Id>(); //Commented as part of Code Refactor TWC745-6459
            //Map<Id,Core_Ips_Project__C> projectMap= new Map<Id,Core_Ips_Project__C>(); //Commented as part of Code Refactor TWC745-6459
            
            Set<Id> supportedContId=new Set<Id>();
            for(case cs: triggerNew){
                supportedContId.add(cs.Core_IPS_Supported_Contact__c);
            }
            //Added as part of Code Refactor TWC745-6459
            if(!supportedContId.isEmpty() && Core_IPS_CaseTriggerHandler.GlobalContactRecords!= null && Core_IPS_CaseTriggerHandler.GlobalContactRecords.size()>0 && !isQueryRequired(new List<Id>(supportedContId),Core_IPS_CaseTriggerHandler.GlobalContactRecords,null)){
             
                suppContAccMap = Core_IPS_CaseTriggerHandler.GlobalContactRecords;
            }
            else if(!supportedContId.isEmpty() && Contact.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
            suppContAccMap = new Map<Id,Contact>([Select Id,AccountId from Contact where Id in :supportedContId]);
            }
            //End 
            for(Case c : triggerNew){
                
                if((Trigger.isInsert && String.isEmpty(c.Core_IPS_Support_Level__c)) || Trigger.isUpdate){ //added if Condition for US113466
                    
                    if(c.Core_Partner_Supported_Account__c != NULL){
                        accountID = c.Core_Partner_Supported_Account__c;
                    }else{ //US221486-Gourav: Account based on Supported Contact //Added containskey as part of Code Refactor TWC745-6459
                        if(suppContAccMap !=null && suppContAccMap.size()>0 && suppContAccMap.containskey(c.Core_IPS_Supported_Contact__c)){
                            accountID = suppContAccMap.get(c.Core_IPS_Supported_Contact__c).AccountId;
                        }      }
                    //US237240 : Gourav - To update Support Level for GEC cases
                    if(c.recordTypeId == iPSCaseCreateId || c.recordTypeId == GECRecordTypeId){
                        String key = String.valueOf(accountID) + String.valueOf(c.assetId);
                        accountAssetIdComboToAccountIdMap.put(key, accountID );
                        assetIds.add(c.assetId);
                        if(Trigger.isUpdate){
                            if(c.AssetId != oldmap.get(c.Id).AssetId){
                                assetIds.add(oldmap.get(c.Id).AssetId);        
                            }
                        }  
                    }
                }
            }
            
            //Start - Added as part of Code Refactor TWC745-6459
            if(!assetIds.isEmpty() && Core_IPS_CaseTriggerHandler.GlobalAssetRecords!= null && Core_IPS_CaseTriggerHandler.GlobalAssetRecords.size()>0 && !isQueryRequired(new List<Id>(assetIds),Core_IPS_CaseTriggerHandler.GlobalAssetRecords,null)){
              
                assetMap = Core_IPS_CaseTriggerHandler.GlobalAssetRecords;
            }
            else if(!assetIds.isEmpty()){
              
                assetMap = new Map<Id,Asset>([SELECT Id,Core_Product_Organization__c FROM Asset WHERE isDeleted = false AND  Id IN : assetIds]);
            }
            //End 
            for(Case c : triggerNew){
                //  if((Trigger.isInsert && projectMap==null &&  projectMap.get(c.Core_ips_project_Case__c).Core_IPS_Support_Level__c!=null)|| (Trigger.isUpdate)){
                if(assetMap != NULL && !assetMap.isEmpty()){
                    
                    //Continue when support org is not changed //US237240 : Gourav - To update Support Level for GEC cases
                    if(Trigger.isUpdate && (c.recordTypeId == iPSCaseCreateId || c.recordTypeId == GECRecordTypeId)){
                        if((assetMap.containskey(c.assetId) && assetMap.containskey(oldMap.get(c.Id).assetId) && assetMap.get(c.assetId).Core_Product_Organization__c == assetMap.get(oldMap.get(c.Id).assetId).Core_Product_Organization__c) && (c.Core_Partner_Supported_Account__c == oldmap.get(c.Id).Core_Partner_Supported_Account__c) ){
                            continue;
                        }
                    }
                    
                    //Check if PSA is updated //US237240 : Gourav - To update Support Level for GEC cases
                    if( Trigger.isUpdate  && (c.recordTypeId == iPSCaseCreateId || c.recordTypeId == GECRecordTypeId) && (c.Core_Partner_Supported_Account__c != oldmap.get(c.Id).Core_Partner_Supported_Account__c)){
                        if (c.Core_Partner_Supported_Account__c != null){
                            accountID = c.Core_Partner_Supported_Account__c;
                        }
                        else{
                            //US221486-Gourav: Account based on Supported Contact //Added containskey as part of Code Refactor TWC745-6459
                            if(suppContAccMap !=null && suppContAccMap.size()>0 && suppContAccMap.containskey(c.Core_IPS_Supported_Contact__c)){
                                accountID = suppContAccMap.get(c.Core_IPS_Supported_Contact__c).AccountId;
                            }
                        }
                        String key = String.valueOf(accountID) + String.valueOf(c.assetId);
                        if(assetMap.containskey(c.assetId) && assetMap.get(c.assetId).Core_Product_Organization__c != null && accountAssetIdComboToAccountIdMap.get(key) != null){
                            String keyCombo = String.valueOf(assetMap.get(c.assetId).Core_Product_Organization__c).left(15) + String.valueOf(accountAssetIdComboToAccountIdMap.get(key)).left(15);
                            accountAssetIdComboToUniqueKey.put(key,keyCombo);
                            
                        }  
                    }
                    //US237240 : Gourav - To update Support Level for GEC cases
                    if((Trigger.isInsert || Trigger.isUpdate ) && (c.recordTypeId == iPSCaseCreateId || c.recordTypeId == GECRecordTypeId)){
                        if (c.Core_Partner_Supported_Account__c != null){
                            accountID = c.Core_Partner_Supported_Account__c;
                        }
                        else  //US221486-Gourav: updated //Added containskey as part of Code Refactor TWC745-6459
                            if(suppContAccMap!=null && suppContAccMap.size()>0 && suppContAccMap.containskey(c.Core_IPS_Supported_Contact__c)){ //Added for RDC--do not deploy
                                accountID = suppContAccMap.get(c.Core_IPS_Supported_Contact__c).AccountId; 
                            }
                        
                        String key = String.valueOf(accountID) + String.valueOf(c.assetId);
                        if(assetMap.containskey(c.assetId) && assetMap.get(c.assetId).Core_Product_Organization__c != null && accountAssetIdComboToAccountIdMap.get(key) != null){
                            String keyCombo = String.valueOf(assetMap.get(c.assetId).Core_Product_Organization__c).left(15) + String.valueOf(accountAssetIdComboToAccountIdMap.get(key)).left(15);
                            accountAssetIdComboToUniqueKey.put(key,keyCombo);
                        }  
                    }
                }
                if(Trigger.isInsert && c.recordTypeId == noAssignedContactCaseId){
                    if(String.isNotBlank(supportLevelDefaultValueNoAssignedContact) && String.isBlank(c.Core_IPS_Support_Level__c)) {
                        c.Core_IPS_Support_Level__c = supportLevelDefaultValueNoAssignedContact; }
                }
                
            }
            
            if(!accountAssetIdComboToUniqueKey.isEmpty()){
                Map<String,String> uniqueKeyToSupportLevelMap = new Map<String,String>();
                for(Core_IPS_Support_Level__c objSuppLevel : [SELECT Id, Core_IPS_Support_Level__c, Core_IPS_Account__c, Core_IPS_Support_Org__c,Core_IPS_SupportOrgAndAccountKey__c FROM Core_IPS_Support_Level__c WHERE isDeleted = false AND Core_IPS_SupportOrgAndAccountKey__c IN :accountAssetIdComboToUniqueKey.values()]){
                    uniqueKeyToSupportLevelMap.put(objSuppLevel.Core_IPS_SupportOrgAndAccountKey__c, objSuppLevel.Core_IPS_Support_Level__c);
                }
                
                for(Case c : triggerNew){
                    if(c.Core_Partner_Supported_Account__c != NULL){
                        accountID = c.Core_Partner_Supported_Account__c;
                    }
                    else //US221486-Gourav: updated //Added containskey as part of Code Refactor TWC745-6459
                    {  if(suppContAccMap.containskey(c.Core_IPS_Supported_Contact__c)){ accountID = suppContAccMap.get(c.Core_IPS_Supported_Contact__c).AccountId;   }}
                    String key = String.valueOf(accountID) + String.valueOf(c.assetId);
                    if(accountAssetIdComboToUniqueKey.containsKey(key)){
                        if(uniqueKeyToSupportLevelMap.containsKey(accountAssetIdComboToUniqueKey.get(key)) && String.isNotBlank(uniqueKeyToSupportLevelMap.get(accountAssetIdComboToUniqueKey.get(key)))){
                            c.Core_IPS_Support_Level__c = uniqueKeyToSupportLevelMap.get(accountAssetIdComboToUniqueKey.get(key));                           
                        }
                        else if(String.isNotBlank(supportLevelDefaultValue)){
                            c.Core_IPS_Support_Level__c = supportLevelDefaultValue;
                        }
                    }
                }
                
            } 
        }
        catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');}
    } 
    
    
    /****************************************************************************************************
Version     : 1.0 
Created Date: 15 Nov 2017
Trigger Name: Core_CaseTrigger
Function    : This method is used for checking the validation for PSF orgs
Input Parameters: Case New List
Output Parameters: None
Transactions: Before Update
Description: This method executes on Case Update.  
Used in     : Core_CaseTrigger_Dispatcher
Feature     :     F5444      
UserStory   :   US84539 
Number of Queries Within this Method: 
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sughandha               09/10/17                 Created
* Sandeep Sankhla       15/11/17                    modified
* Sugandha               21/02/18                    modified
****************************************************************************************************/
    public static void checkCaseClosureParams(List<Case> triggerNew, Map<Id,Case> oldMap){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('checkCaseClosureParams')){
            return;
        }    
        try{
            Core_IPS_Labels__c lCS = Core_IPS_Labels__c.getInstance('Core_IPS_Bug/Fix_ErrMsg');
            Core_IPS_Labels__c lCSStatus = Core_IPS_Labels__c.getInstance('Core_IPS_Bug/Fix_StatusValue');
            if(LCS != NULL && LCSStatus != NULL){
                String strErrorMessage =  LCS.Value__c; 
                String strCaseStatus = LCSStatus.Value__c; 
                for(Case cs : triggerNew){
                    for(Core_IPS_Support_Org_Specification__c suppOrgRec :  Core_IPS_Support_Org_Specification__c.getall().values()){
                        if(String.isNotBlank(suppOrgRec.Core_IPS_Case_Closure__c)&& String.isNotBlank(suppOrgRec.Core_IPS_Field_Name__c)){
                            Set<String> setValues = new Set<String>(String.valueOf(suppOrgRec.Core_IPS_Case_Closure__c).split(';'));
                            //Added triggerFieldValue and setTriggerValues by Sugandh for DE36235 Iteration 7
                            String triggerFieldValue = String.ValueOf(cs.get(suppOrgRec.Core_IPS_Trigger_Field_API__c));
                            Set<String> setTriggerValues = new Set<String>(String.valueOf(suppOrgRec.Core_IPS_Trigger_Field_Value__c).split(';'));
                            // Replaced status with Sub Status by Sugandha for DE36235 Iteration 7
                            
                            if(suppOrgRec.Core_IPS_Is_Active__c && suppOrgRec.Core_IPS_Support_Org_Number__c.contains(cs.Core_IPS_Product_Org_Number__c)&& setTriggerValues.contains(triggerFieldValue) && triggerFieldValue != oldMap.get(cs.Id).get(suppOrgRec.Core_IPS_Field_Name__c)&& setValues.Contains(cs.Core_Case_Closure__c) && (cs.get(suppOrgRec.Core_IPS_Field_Name__c) == '' || cs.get(suppOrgRec.Core_IPS_Field_Name__c) == Null)){cs.addError(strErrorMessage);  
                                                                                                                                                                                                                                                                                                                                                                                                                                                 }
                        }
                    }  
                }
            }
        }catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');}
    }
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 29 May 2018
Input Parameters: 
Transactions: After Update
Description: This method is used to add the project members & Intel Support Team to Case interested parties from
the project (Whenever a porject under a case changed from one project to another project) and also deletes old project members& IST. 
Used in     : Core_CaseTrigger_Dispatcher

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rakesh Marka                   29/05/2018              User Story--US107411 
* Amritesh                       2/1/2018                DE28924
****************************************************************************************************/ 
    public static void caseEditprojectDetails(List<case> newList,Map<id,case> oldMap)  {   
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('case_Edit_projectDetails')){
            return;
        }
        
        Map<id,id> editCaseDetailsMap=new Map<id,id>(); 
        //Map<id,case> CaseDetailsMap=new Map<id,case>();
        List<Case> lstCaseScope = new List<Case>();
        Set<Id> projectIdSet=new Set<Id>();
        
        if(newList!= null && newList.size()>0){
            for(case caseProjectChange : newList) {
                
                if(oldMap.get(caseProjectChange.id).Core_IPS_Project_Case__c!=caseProjectChange.Core_IPS_Project_Case__c){          
                    editCaseDetailsMap.put(caseProjectChange.id, caseProjectChange.Core_IPS_Project_Case__c);
                    //caseDetailsMap.put(caseProjectChange.id,caseProjectChange); 
                    if(caseProjectChange.Core_IPS_Project_Case__c!=null){
                        lstCaseScope.add(caseProjectChange);
                        projectIdSet.add(caseProjectChange.Core_IPS_Project_Case__c); 
                    }            
                }      
            }
            
            if(editCaseDetailsMap.size()>0){               
                delete [SELECT Id FROM Core_IPS_Case_Interested_Party__c WHERE Case__c IN :editCaseDetailsMap.keySet() AND Core_IPS_Project_Interested_Party__c=true];
            }
            
            /*List<Core_IPS_Project_Member__c> premierSupportMembers_List=[select id,Core_IPS_Contact__c,Core_User__c,Core_IPS_Project__c,Core_IPS_Project__r.name,Core_IPS_Project__r.Core_IPS_EnableMemberasInterestedParties__c from Core_IPS_Project_Member__c where Core_IPS_Project__c IN:editCaseDetailsMap.Values()];      
List<Core_IPS_Intel_Support_Team__c> intelTeamMembers_List=[select id,Core_IPS_User__c,Core_IPS_Project__c,Core_IPS_Project__r.name,Core_IPS_Project__r.Core_IPS_Enable_ISTasInterested_Parties__c from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c IN:editCaseDetailsMap.Values()];

if(premierSupportMembers_List.size()>0 && caseDetailsMap.size()>0){          
create_IntrestedParties_ProjectMembers(premierSupportMembers_List,caseDetailsMap);
}
if(intelTeamMembers_List.size()>0 && caseDetailsMap.size()>0){
create_IntrestedParties_IntelSupportTeam(intelTeamMembers_List,caseDetailsMap);
}*/
            
            //added for DE28924
            //commented for DE32193
            /*  List<Core_IPS_Intel_Support_Team__c> ISTList = [select id,name,Core_IPS_Project__c,Add_as_Case_Interested_Party__c,Core_IPS_User__c,Status__c from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c In: editCaseDetailsMap.Values() and Add_as_Case_Interested_Party__c=true]; 
if(ISTList.size()>0) { 
Core_IPS_IntelSupportTeam_Handler.insertInterestedParty(ISTList, lstCaseScope);
}
List<Core_IPS_Project_Member__c> projectMembersList = [select id,name,Core_IPS_Project__c,Core_IPS_Contact__c,Core_Status__c,Add_as_Case_Interested_Party__c,Core_User__c from Core_IPS_Project_Member__c where Core_IPS_Project__c In : editCaseDetailsMap.Values() and Add_as_Case_Interested_Party__c=true];
if(projectMembersList.size()>0) {          
Core_IPS_Project_Member_Handler.insertInterestedParty(projectMembersList, lstCaseScope);
}
*/
            //start added for DE32193
            List<Core_IPS_Case_Interested_Party__c> externalIPList=new List<Core_IPS_Case_Interested_Party__c>();
            List<Core_IPS_Case_Interested_Party__c> internalIPList=new List<Core_IPS_Case_Interested_Party__c>();
            List<Core_IPS_Case_Interested_Party__c> iPList=new List<Core_IPS_Case_Interested_Party__c>();
            
            if(projectIdSet!=null && projectIdSet.size()>0){
                internalIPList=Core_IPS_IntelSupportTeam_Handler.createInterestedParty(projectIdSet);
                externalIPList=Core_IPS_Project_Member_Handler.createInterestedParty(projectIdSet);
                if(externalIPList!=null && externalIPList.size()>0){
                    IPList.addAll(externalIPList);
                }
                if(internalIPList!=null && internalIPList.size()>0){
                    IPList.addAll(internalIPList);
                }
                if(IPList.size()>0){
                    System.enqueueJob(new Core_IPS_insertInterestedPartyQueueable(IPList));
                }
            }
            //end
            
        }      
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 14 June 2018
Input Parameters: 
Transactions: After Update
Description: This method is used to add the project members to Case Interested parties from
the project Whenever the  'Add as Case Interested Party'checkbox on the Project member detail page is checked 
Used in     : Core_CaseTrigger_Dispatcher

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rakesh Marka                   14/06/2018              User Story--US107411 
****************************************************************************************************/ 
    /** commented for DE28924
public static void create_IntrestedParties_ProjectMembers(List<Core_IPS_Project_Member__c> premierSupportMembers_List,Map<id,case> editCaseDetailsMap){

//if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('create_IntrestedParties_ProjectMembers'))
//   return;

List<Core_IPS_Case_Interested_Party__c> InterestedParty_List=new List<Core_IPS_Case_Interested_Party__c>();
for(ID cs:editCaseDetailsMap.keySet()){ 
for(Core_IPS_Project_Member__c projectMembers:premierSupportMembers_List){
if(projectMembers.Core_IPS_Project__r.Core_IPS_EnableMemberasInterestedParties__c==true && editCaseDetailsMap.get(cs).Core_IPS_Project_Case__c==projectMembers.Core_IPS_Project__c){    
Core_IPS_Case_Interested_Party__c case_InterestedParty=new Core_IPS_Case_Interested_Party__c();
case_InterestedParty.Contact__c=projectMembers.Core_IPS_Contact__c;
case_InterestedParty.User__c=projectMembers.Core_User__c;
case_InterestedParty.Case__c=editCaseDetailsMap.get(cs).id;
case_InterestedParty.Type__c='External';
case_InterestedParty.Active__c=true;
case_InterestedParty.Core_IPS_Project_Interested_Party__c = true;
InterestedParty_List.add(case_InterestedParty); 
}         
}
} 
if(InterestedParty_List.size()>0){
insert InterestedParty_List;
}
}

public static void create_IntrestedParties_IntelSupportTeam(List<Core_IPS_Intel_Support_Team__c> intelTeamMembers_List,Map<id,case> editCaseDetailsMap){
List<Core_IPS_Case_Interested_Party__c> InterestedParty_List=new List<Core_IPS_Case_Interested_Party__c>();
for(ID cs:editCaseDetailsMap.keySet()){ 
for(Core_IPS_Intel_Support_Team__c intelMembers:intelTeamMembers_List){
if(intelMembers.Core_IPS_Project__r.Core_IPS_Enable_ISTasInterested_Parties__c==true && editCaseDetailsMap.get(cs).Core_IPS_Project_Case__c==intelMembers.Core_IPS_Project__c){     
Core_IPS_Case_Interested_Party__c case_InterestedParty=new Core_IPS_Case_Interested_Party__c();
case_InterestedParty.User__c=intelMembers.Core_IPS_User__c;
case_InterestedParty.Case__c=editCaseDetailsMap.get(cs).id;
case_InterestedParty.Type__c='Internal';
case_InterestedParty.Active__c=true;
case_InterestedParty.Core_IPS_Project_Interested_Party__c = true;
InterestedParty_List.add(case_InterestedParty); 
}         
}
} 
if(InterestedParty_List.size()>0){
insert InterestedParty_List;
}
}
*****************commeneted for DE28924 ***************/
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 15 June 2018
Input Parameters: 
Transactions: After Insert
Description: This method is used to add the project members & Intel Support Team to Case interested parties from
the project (Whenever a new case is created and interested parties of the Case will be added from the respective project) 
Used in     : Core_CaseTrigger_Dispatcher

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rakesh Marka                 15/06/2018             User Story--US107411 
* Amritesh                     02/01/2019             DE28924 
****************************************************************************************************/ 
    
    // Add Insterested Parties while creating a case
    public static void createInsterestedPartiesUsingCase(List<case> newcaselist) {
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('create_InsterestedParties_UsingCase')){
            return;
        }    
        
        set<Id> projectSet=new set<Id>();
        if(newcaselist!=null && newcaselist.size()>0){
            for(Case caseList:newcaselist){
                if(caseList.Core_IPS_Project_Case__c!=null && !caseList.isClone()) {
                    projectSet.add(caseList.Core_IPS_Project_Case__c); 
                }
            }
            
        }
        if(projectSet!=null && projectSet.size()>0){
            //start modified DE32193
            /*List<Core_IPS_Intel_Support_Team__c> ISTList=[select id,name,Core_IPS_Project__c,Add_as_Case_Interested_Party__c,Core_IPS_User__c,Status__c from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c In: projectSet and Add_as_Case_Interested_Party__c=true]; 
if(ISTList.size()>0 && ISTList!=null){
//Core_IPS_IntelSupportTeam_Handler.create_InterestedParty_using_checkBox(ISTList,null); //commented for DE28924
Core_IPS_IntelSupportTeam_Handler.insertInterestedParty(ISTList, newcaselist); //added for DE28924
}

List<Core_IPS_Project_Member__c> projectMembersList=[select id,name,Core_IPS_Project__c,Core_IPS_Contact__c,Core_Status__c,Add_as_Case_Interested_Party__c,Core_User__c from Core_IPS_Project_Member__c where Core_IPS_Project__c In : projectSet and Add_as_Case_Interested_Party__c=true];
if(projectMembersList.size()>0 && projectMembersList!=null){
Core_IPS_Project_Member_Handler.insertInterestedParty(projectMembersList,newcaselist);
}*/
            
            List<Core_IPS_Case_Interested_Party__c> externalIPList=new List<Core_IPS_Case_Interested_Party__c>();
            List<Core_IPS_Case_Interested_Party__c> internalIPList=new List<Core_IPS_Case_Interested_Party__c>();
            List<Core_IPS_Case_Interested_Party__c> iPList=new List<Core_IPS_Case_Interested_Party__c>();
            internalIPList=Core_IPS_IntelSupportTeam_Handler.createInterestedParty(projectSet);
            externalIPList=Core_IPS_Project_Member_Handler.createInterestedParty(projectSet);
            if(externalIPList!=null && externalIPList.size()>0){
                IPList.addAll(externalIPList);
            }
            if(internalIPList!=null && internalIPList.size()>0){
                IPList.addAll(internalIPList);
            }
            if(IPList.size()>0){
                System.enqueueJob(new Core_IPS_insertInterestedPartyQueueable(IPList));
            }
            //end
        }
    }  
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 22 June 2018
Function    : This method is to Display an Error Message when Case owner is set to Partner which are not project member.
Input Parameters: Case New List
Output Parameters: None
Transactions: Before Update
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 2
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                  22/06/2018               Created - DE40252
* Gourav                    14/01/2019               Logic to validate Case Owner/Co-owner for Project and Private cases
****************************************************************************************************/      
    public static void validateCaseOwner(Map<Id,Case> oldMap,List<Case> newList){
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('Core_IPS_Execute_CaseOwnerValidation')){
            return;
        }
        Set<Id> setProjIds = new Set<Id>();
        Set<Id> setPartCaseIds = new Set<Id>();
        Set<Id> setNewCsOwnerIds = new Set <Id>();
        Set<Id> setNewCsCoOwnerIds = new Set <Id>();
        Map<Id,Set<Id>> mapProjToPartnerMember = new Map<Id,Set<Id>>();
        //Set<Id> setPartUsers = new set<Id>(); 
        Map<Id,User> mapPartUsers = new Map<Id,User>(); 
        //US230032 Gourav : Owner changes for Pvt Cases
        Map<Id, Set<Id>> mapActiveISTs = new Map<Id, Set<Id>>();
        Set<Id> setPvtProjIds = new Set<Id>();
        Set<Id> setPvtCaseOwnerIds = new Set<Id>();
        Set<Id> setPvtCaseCoOwnerIds = new Set<Id>();
        //Map<Id,String> userMap = new Map<Id,String>();        
        for(Case cs : newList){
            if(oldMap.get(cs.Id).OwnerId != cs.OwnerId){setNewCsOwnerIds.add(cs.OwnerId);}    
            if(oldMap.get(cs.Id).Core_Case_Co_Owner__c != cs.Core_Case_Co_Owner__c){setNewCsCoOwnerIds.add(cs.Core_Case_Co_Owner__c);}
            //US230032 Gourav : Owner changes for Pvt Cases
            if(cs.Core_IPS_Private_Project__c && oldMap.get(cs.Id).OwnerId != cs.OwnerId){
                setPvtProjIds.add(cs.Core_IPS_Project_Case__c); 
                setPvtCaseOwnerIds.add(cs.OwnerId);}
            if(cs.Core_IPS_Private_Project__c && oldMap.get(cs.Id).Core_Case_Co_Owner__c != cs.Core_Case_Co_Owner__c){
                setPvtProjIds.add(cs.Core_IPS_Project_Case__c); 
                setPvtCaseCoOwnerIds.add(cs.Core_Case_Co_Owner__c); //US252217
            }
        }
        if(!setNewCsOwnerIds.isEmpty() || !setNewCsCoOwnerIds.isEmpty()){
            //Added as part of Code Refactor TWC745-6459
            if(Core_IPS_CaseTriggerHandler.GlobalUserRecords!= null && Core_IPS_CaseTriggerHandler.GlobalUserRecords.size()>0  && !isQueryRequired(new List<Id>(setNewCsOwnerIds),Core_IPS_CaseTriggerHandler.GlobalUserRecords,null)  && !isQueryRequired(new List<Id>(setNewCsCoOwnerIds),Core_IPS_CaseTriggerHandler.GlobalUserRecords,null)){
             
                mapPartUsers = Core_IPS_CaseTriggerHandler.GlobalUserRecords;
            }
            else{
            for(User usr: [Select id,ProfileId,Profile.Name,UserType from User where (Id IN :setNewCsOwnerIds OR Id IN :setNewCsCoOwnerIds) /* and ProfileId = : System.Label.Core_IPS_Agent_Partner_Profile_id */ ]){
                //setPartUsers.add(u.Id);
                mapPartUsers.put(usr.id,usr);
                }
            }
            //End
            for(Case cs : newList){   //Added containskey as part of Code Refactor TWC745-6459
                //if((setPartUsers.Contains(cs.OwnerId) || setPartUsers.Contains(cs.Core_Case_Co_Owner__c)) && Cs.Core_IPS_Project_Case__c != null){
                if(((mapPartUsers.containskey(cs.OwnerId) && mapPartUsers.get(cs.OwnerId) !=null && mapPartUsers.get(cs.OwnerId).ProfileId==System.Label.Core_IPS_Agent_Partner_Profile_id) ||
                    (!String.isBlank(cs.Core_Case_Co_Owner__c) && mapPartUsers.containskey(cs.Core_Case_Co_Owner__c) && mapPartUsers.get(cs.Core_Case_Co_Owner__c) !=null && mapPartUsers.get(cs.Core_Case_Co_Owner__c).ProfileId==System.Label.Core_IPS_Agent_Partner_Profile_id)) && Cs.Core_IPS_Project_Case__c != null){  
                        setProjIds.add(cs.Core_IPS_Project_Case__c);
                        setPartCaseIds.add(cs.id);
                        
                    }    
            }
            
            //All the Project with Partner member
            if(Core_IPS_Project__c.SObjectType.getDescribe().isAccessible()){
            for(Core_IPS_Project__c prj : [SELECT Id,(SELECT Core_User__c FROM Project_Members__r 
                                                      WHERE Core_User__r.ProfileId = :System.Label.Core_IPS_Agent_Partner_Profile_id and Core_Status__c='Active' and Core_User__r.isActive=true)
                                           FROM Core_IPS_Project__c 
                                           WHERE Id IN :setProjIds]){
                                               if(prj.Project_Members__r.size() > 0) { 
                                                   Set<Id> setMemIds = new Set<Id>();                           
                                                   for(Core_IPS_Project_Member__c prjMem : prj.Project_Members__r){
                                                       setMemIds.Add(prjMem.Core_User__c);
                                                       
                                                   } 
                                                   mapProjToPartnerMember.put(prj.Id,setMemIds);  
                                               }                                
                                           }}}
        //US230032 Gourav - To check for Private_Case_Internal_Owner
        if( !setPvtProjIds.isEmpty()){
            if(Core_IPS_Intel_Support_Team__c.SObjectType.getDescribe().isAccessible()){              
            for (Core_IPS_Intel_Support_Team__c istMem: [Select Id, Core_IPS_Project__c, status__c, Core_IPS_User__c,Core_IPS_User__r.UserType from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c in: setPvtProjIds AND (Core_IPS_User__c in: setPvtCaseOwnerIds OR Core_IPS_User__c in: setPvtCaseCoOwnerIds ) AND Status__c = 'Active' and Core_IPS_User__r.isActive=true]) {
                if (!mapActiveISTs.containsKey(istMem.Core_IPS_Project__c)) {
                    mapActiveISTs.put(istMem.Core_IPS_Project__c, new Set<Id>());
                }
                mapActiveISTs.get(istMem.Core_IPS_Project__c).add(istMem.Core_IPS_User__c);
                //userMap.put(istMem.Core_IPS_User__c,true);
                
            }
            }
        }
        if(!setProjIds.isEmpty() || !setPvtProjIds.isEmpty()){
            for(Case cs : newList){    //Added containskey as part of Code Refactor TWC745-6459
                
                //Partner-Agent check for Case Owner  //US252217 Co-owner
                if( !String.isBlank(cs.Core_IPS_Project_Case__c) && (mapPartUsers.containskey(cs.OwnerId) && mapPartUsers.get(cs.OwnerId)!=null && mapPartUsers.get(cs.OwnerId).ProfileId==System.Label.Core_IPS_Agent_Partner_Profile_id && (!mapProjToPartnerMember.containsKey(cs.Core_IPS_Project_Case__c) || !mapProjToPartnerMember.get(cs.Core_IPS_Project_Case__c).contains(cs.OwnerId))) ||(!String.isBlank(cs.Core_Case_Co_Owner__c) && mapPartUsers.containskey(cs.Core_Case_Co_Owner__c) && mapPartUsers.get(cs.Core_Case_Co_Owner__c)!=null && mapPartUsers.get(cs.Core_Case_Co_Owner__c).ProfileId==System.Label.Core_IPS_Agent_Partner_Profile_id && ( !mapProjToPartnerMember.containsKey(cs.Core_IPS_Project_Case__c) || !mapProjToPartnerMember.get(cs.Core_IPS_Project_Case__c).contains(cs.Core_Case_Co_Owner__c)))) {
                    cs.addError(Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_CaseOwner_Err_Msg'));
                } 
                
                
                //US230032 && US252217 Gourav - To check for Private_Case_Internal_Owner
                else if(cs.Core_IPS_Private_Project__c && ((mapPartUsers.containskey(cs.OwnerId) && mapPartUsers.get(cs.OwnerId) !=null && mapPartUsers.get(cs.OwnerId).UserType==System.Label.UserType_Standard && setPvtCaseOwnerIds.contains(cs.OwnerId) && (!mapActiveISTs.containsKey(cs.Core_IPS_Project_Case__c) || !mapActiveISTs.get(cs.Core_IPS_Project_Case__c).contains(cs.OwnerId) )) || (!String.isBlank(cs.Core_Case_Co_Owner__c) && mapPartUsers.containskey(cs.Core_Case_Co_Owner__c) && mapPartUsers.get(cs.Core_Case_Co_Owner__c)!=null && mapPartUsers.get(cs.Core_Case_Co_Owner__c).UserType==System.Label.UserType_Standard && setPvtCaseCoOwnerIds.contains(cs.Core_Case_Co_Owner__c) && (!mapActiveISTs.containsKey(cs.Core_IPS_Project_Case__c) || !mapActiveISTs.get(cs.Core_IPS_Project_Case__c).contains(cs.Core_Case_Co_Owner__c)) ))){
                    cs.addError(Core_IPS_Helper_Utility.getIPSLabel('Private_Case_Internal_Owner_ErrorMsg'));
                }
            }
            
        } 
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 16 Aug 2018
Function    : This method is to get Information from Project on Case
Input Parameters: Case New List
Output Parameters: None
Transactions: Before Insert
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi                  04/09/2018               Created - US113488
* Amritesh                 07/09/2018               Modified - US137508
* Ganapati                 09/08/2019               Modified for DE36247
****************************************************************************************************/ 
    public static void assignCaseInformationfromProject(List<case> newList, Map<Id,Case> oldMap)  { 
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('assignCaseInformationfromProject')){return;}
        try{ 
            // US240396 --04 Jan 2019 --- added isExternal by orion -- Vamsi
            Boolean  isExternal=checkExternalUser();
            Id iPSNACCaseRTId = getCaseRecordtypeIDByName(Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact'));
            Set<Id> projectId=new Set<Id>();
            for(Case cs: newList){
                if(oldMap==null || (oldMap!=null && cs.Core_IPS_Project_Case__c != oldMap.get(cs.Id).Core_IPS_Project_Case__c)) { //insert or project change
                    if(oldMap!=null && oldMap.get(cs.Id).Core_IPS_Project_Case__c!=null){
                        projectId.add(oldMap.get(cs.Id).Core_IPS_Project_Case__c);
                        
                        //US191343
                        if(cs.Core_IPS_Project_Case__c==null) {
                            cs.Core_IPS_Private_Project__c = false;
                        }                        
                    }
                    if(cs.Core_IPS_Project_Case__c!=null){
                        projectId.add(cs.Core_IPS_Project_Case__c);
                        
                    }                    
                }
            }
            // Project Id processing ---
            projectProcessing( projectId, newList, oldMap, IPSNACCaseRTId, isExternal);
            
            
        } catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');}
        
    }
    // Start -- US240396 --04 Jan 2019 --- added method to get profile and permissionset of External user --  by orion -- Vamsi
    private static Boolean checkExternalUser(){
        String fAEPermissionSetId = System.Label.Core_IPS_Partner_DFAE_Permission_Set;
        String agentPartnerProfileId=System.Label.Core_IPS_Partner_AE_Profile_Id;
        
        List<PermissionSetAssignment> userPerSet=[Select PermissionSetID From PermissionSetAssignment where AssigneeId=:UserInfo.getUserId()];
        for(PermissionSetAssignment pSA:userPerSet){
            if(Userinfo.getProfileId() ==agentPartnerProfileId || PSA.PermissionSetID == FAEPermissionSetId ){
                return true;
            }
        }
        return false;
    }
    
    public static void projectProcessing(set<Id> projectId, List<case> newList, Map<id,Case>oldMap, id IPSNACCaseRTId, boolean isExternal){
        if(projectId.isEmpty()) {
            return;
        }    
        Map<Id,Core_Ips_Project__C> projectMap=new Map<Id,Core_Ips_Project__C>(
            [Select Id,Core_IPS_Remove_Notification_Details__c,Core_IPS_Support_Level__c,Core_IPS_Partner_Support_Owner__c,
             Core_IPS_Intel_Support_Owner__c,Core_IPS_Private__c from Core_Ips_Project__C where Id In: projectId]);
        if(!projectMap.isEmpty()) { 
            for(Case cs: newList) {
                if(oldMap==null) { //insert trigger action only                        
                    if(!cs.isClone() && cs.Core_ips_project_Case__c!=null) {
                        cs.Core_IPS_Restricted_Secret_Content__c=projectMap.get(cs.Core_ips_project_Case__c).Core_IPS_Remove_Notification_Details__c;
                    }
                    if(projectMap.get(cs.Core_ips_project_Case__c).Core_IPS_Support_Level__c!=null){
                        cs.Core_IPS_Support_Level__c=projectMap.get(cs.Core_ips_project_Case__c).Core_IPS_Support_Level__c;
                    }
                    //Modified by Ganapati for DE36247 - Start
                    if(cs.Core_ips_project_Case__c!=null) {     
                        if(cs.RecordTypeId!=IPSNACCaseRTId) {   
                            cs.Core_IPS_Partner_Sup_Owner__c = projectMap.get(cs.Core_ips_project_Case__c).Core_IPS_Partner_Support_Owner__c;    
                        } 
                        if(String.isNotBlank(projectMap.get(cs.Core_ips_project_Case__c).Core_IPS_Intel_Support_Owner__c)) {
                            cs.Core_Intel_Sup_Owner__c = projectMap.get(cs.Core_ips_project_Case__c).Core_IPS_Intel_Support_Owner__c;   
                        }
                    }// end - DE36247
                    // Start -- US240396 --04 Jan 2019 --- added condition to assign loggedin user as PSO, works for external profiles(partner FAE & Agent partner)  by orion -- Vamsi
                    if(cs.Core_IPS_Partner_Sup_Owner__c==null && isExternal){
                        if(userinfo.getUserId() != null){
                            cs.Core_IPS_Partner_Sup_Owner__c=userinfo.getUserId();
                        }
                    }
                    // End --US240396 --04 Jan 2019 --- added condition to assign loggedin user as PSO, works for external profiles(partner FAE & Agent partner)  by orion -- Vamsi
                } //on update or change of Project on case 
                else if(oldMap!=null && cs.Core_IPS_Project_Case__c != oldMap.get(cs.Id).Core_IPS_Project_Case__c) { //Modified by Ganapati for DE36247
                    
                    //if((cs.Core_IPS_Partner_Sup_Owner__c==null))
                    //  (oldMap.get(cs.Id).Core_IPS_Project_Case__c!=null && cs.Core_IPS_Partner_Sup_Owner__c == projectMap.get(oldMap.get(cs.Id).Core_IPS_Project_Case__c).Core_IPS_Partner_Support_Owner__c)))
                    {
                        if(cs.Core_IPS_Project_Case__c!=null && cs.RecordTypeId!=IPSNACCaseRTId) {      //Modified by Ganapati for DE36247
                            cs.Core_IPS_Partner_Sup_Owner__c = projectMap.get(cs.Core_ips_project_Case__c).Core_IPS_Partner_Support_Owner__c;
                        } else {
                            cs.Core_IPS_Partner_Sup_Owner__c = null;
                        }
                    }
                    //if((cs.Core_Intel_Sup_Owner__c==null || 
                    //  (oldMap.get(cs.Id).Core_IPS_Project_Case__c!=null && cs.Core_Intel_Sup_Owner__c == projectMap.get(oldMap.get(cs.Id).Core_IPS_Project_Case__c).Core_IPS_Intel_Support_Owner__c)))
                    {
                        if(cs.Core_IPS_Project_Case__c!=null && projectMap.get(cs.Core_ips_project_Case__c).Core_IPS_Intel_Support_Owner__c!=null) {
                            cs.Core_Intel_Sup_Owner__c = projectMap.get(cs.Core_ips_project_Case__c).Core_IPS_Intel_Support_Owner__c;
                        } 
                        /*else if(cs.Core_IPS_Project_Case__c!=null && oldMap.get(cs.Id).Core_IPS_Project_Case__c!=null && cs.Core_Intel_Sup_Owner__c==projectMap.get(oldMap.get(cs.Id).Core_IPS_Project_Case__c).Core_IPS_Intel_Support_Owner__c){
cs.Core_Intel_Sup_Owner__c = null;
}*/                                
                    }
                    
                }  
                
                //US191343
                if(cs.Core_IPS_Project_Case__c!=null) {
                    cs.Core_IPS_Private_Project__c = projectMap.get(cs.Core_IPS_Project_Case__c).Core_IPS_Private__c; 
                    
                }
                if(cs.Core_IPS_Private_Project__c) {                    
                    cs.ContactId = null;
                    cs.AccountId = null;
                    
                }
            } 
        }
        
    }
    
    // End -- US240396 --04 Jan 2019 --- added method to get profile and permissionset of External user --  by orion -- Vamsi
    /***************************************************************************************************
Version     : 1.0 
Created Date: 16 Aug 2018
Function    : This method is to stamp managers from user Owner on Case
Input Parameters: Case New List
Output Parameters: None
Transactions: Before Insert
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh                 07/09/2018               Created - US176778
****************************************************************************************************/ 
    public static void assignUserManager(List<case> newList, Map<Id,Case> oldMap)  { 
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('assignUserManager')){return;}
        try{                 
            Map<Id,User> mapUser = new Map<Id,User>();//Added as part of Code Refactor TWC745-6459
            Map<Id,Id> mapOwnerId = new Map<Id,Id>();
            for(Case cs: newList) {
                if(cs.OwnerId!=null && String.valueOf(cs.OwnerId).startswith('005') && (oldMap==null || (oldMap!=null && cs.OwnerId != oldMap.get(cs.Id).OwnerId))) { 
                    mapOwnerId.put(cs.Id, cs.OwnerId);                    
                }
                //added by ranjini for US476474
                if(OldMap!=null && cs.OwnerId!=oldMap.get(cs.Id).OwnerId) {
                    cs.Core_IPS_Owner_Manager__c = null;
                    cs.Core_IPS_Owner_2nd_Manager__c = null;
                }
            }
            if(!mapOwnerId.isEmpty()) {
                //Added as part of Code Refactor TWC745-6459
                if(Core_IPS_CaseTriggerHandler.GlobalUserRecords!= null && Core_IPS_CaseTriggerHandler.GlobalUserRecords.size()>0 && !isQueryRequired(mapOwnerId.values(),Core_IPS_CaseTriggerHandler.GlobalUserRecords,null)){
                 
                    mapUser = Core_IPS_CaseTriggerHandler.GlobalUserRecords;
                }
                else{
                 
                    mapUser = new Map<Id,User>([SELECT Id,ManagerId,Manager.ManagerId FROM User WHERE Id IN: mapOwnerId.values()]);
                }
                if(!mapUser.isEmpty()) { 
                    //Map<Id,Case> newMap = new Map<Id,Case>(newList);
                    //for(Id caseId : mapOwnerId.keySet()) {
                    //Case cs = newMap.get(caseId);
                    for(Case cs : newList) {
                        //Added containskey as part of Code Refactor TWC745-6459
                        if(cs.OwnerId!=null && String.valueOf(cs.OwnerId).startswith('005') && (oldMap==null || (oldMap!=null && cs.OwnerId != oldMap.get(cs.Id).OwnerId))) { 
                            if(mapUser.containsKey(cs.OwnerId) && mapUser.get(cs.OwnerId).ManagerId!=null) {
                                cs.Core_IPS_Owner_Manager__c = mapUser.get(cs.OwnerId).ManagerId;
                            }
                            if(mapUser.containsKey(cs.OwnerId) && mapUser.get(cs.OwnerId).Manager.ManagerId!=null) {
                                cs.Core_IPS_Owner_2nd_Manager__c = mapUser.get(cs.OwnerId).Manager.ManagerId;
                            }
                            //added by ranjini for US476474
                        }else if(string.valueOf(cs.OwnerId).startsWith('00G')) {
                            cs.Core_IPS_Owner_Manager__c = '';
                            cs.Core_IPS_Owner_2nd_Manager__c = '';
                        }
                    }
                }
            }
            
            
            
            
        } catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');}        
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 16 Aug 2018
Function    : This method is to stamp supported contact
Input Parameters: Case New List
Output Parameters: None
Transactions: Before Insert
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh                 07/09/2018               Created - US191343 assignPrivateCasesOwner
****************************************************************************************************/ 
    public static void updateSupportedContact(List<case> newList)  { 
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSupportedContact')){return;}
        try{                 
            for(Case cs: newList) {
                
                if(cs.ContactId!=null) {
                    cs.Core_IPS_Supported_Contact__c = cs.ContactId;                       
                }
                if(cs.Core_IPS_Private_Project__c) {                    
                    cs.ContactId = null;
                    cs.AccountId = null;
                } 
            }
        }
        catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');}        
    }
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 02 Jan 2019
Function    : This method is to stamp Case Owner based on Product/Project Owner
Input Parameters: Case New List
Output Parameters: None
Transactions: Before Update
Used in     : Core_IPS_CaseTriggerHandler
Number of Queries Within this Method: 1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gourav Anand                29/11/2018             US225807 logic to route Private Cases
****************************************************************************************************/ 
    public static void assignCaseOwnerOnProdUpdate(Map<Id,Case> oldCaseMap,List<Case> newCaseList)  { 
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('assignCaseOwnerOnProdUpdate')){return;}
        try{
            assignProjectCasesOwner(newCaseList);
            String caseKey = '';
            for(Case cs: newCaseList){
                //US257271 added compliance Status check
                
                if(OldCaseMap.get(cs.id).productid != cs.productid|| OldCaseMap.get(cs.id).Core_IPS_Supported_Product__c != cs.Core_IPS_Supported_Product__c || OldCaseMap.get(cs.id).assetId != cs.AssetId  || (OldCaseMap.get(cs.id).Core_IPS_GEC_Status__c != cs.Core_IPS_GEC_Status__c && (cs.Core_IPS_GEC_Status__c == Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved')||cs.Core_IPS_GEC_Status__c == Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved_WithG')))){
                    caseKey = (mapCaseAssetSupProd.containskey(cs.AssetId)? String.valueOf(mapCaseAssetSupProd.get(cs.AssetId)):'') + String.valueOf(cs.Core_IPS_Project_Case__c);//changes done as part of code refactor
                    if(mapProjProdOwner !=null && mapProjProdOwner.containsKey(caseKey)){  cs.OwnerId=mapProjProdOwner.get(caseKey);
                                                                                         
                                                                                        } else if(mapProjProdOwner !=null && mapProjProdOwner.containsKey(cs.Core_IPS_Project_Case__c) && cs.Core_IPS_Private_Project__c){
                                                                                            cs.OwnerId = mapProjProdOwner.get(cs.Core_IPS_Project_Case__c);
                                                                                            
                                                                                        }
                }
            }
            
        }catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');}        
    }
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 16 Aug 2018
Function    : This method is to stamp supported contact
Input Parameters: Case New List
Output Parameters: None
Transactions: Before Insert
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gourav Anand                29/11/2018             US225807 logic to route Private Cases
* Sumukh                      12/12/2018             DE27348
* Sumukh                      30/01/2019             US261517 - Routing Cases when the Default Case Owner is Inactive
****************************************************************************************************/ 
    public static void assignProjectCasesOwner(List<case> newList)  { 
        
        try{  
            Set<Id> suppProdIDs = new Set<Id>()  ;
            Set<Id> caseAssetids = new Set<Id>()  ;
            List<Asset> AssetList = new List<Asset>();
            for(Case c : newList){
                //supportedProdIDs.add(c.Core_IPS_Supported_Product__c);
                projIDs.add(c.Core_IPS_Project_Case__c);
                if(c.AssetId!=null){
                    caseAssetids.add(c.AssetId);
                    // added as part of Code Refactor - 21/09/2024
                    // Start
                    if(GlobalAssetRecords != null && GlobalAssetRecords.size()>0 && GlobalAssetRecords.containsKey(c.AssetId)){
                        Asset record = GlobalAssetRecords.get(c.AssetId);
                        AssetList.add(record);
                        supportedProdIDs.add(record.Core_Supported_Product__c);
                        mapCaseAssetSupProd.put(record.Id,record.Core_Supported_Product__c);
                    }
                    //End
                }
            }
          
            // Code Refactor Changes - condition Added - 21/09/2024
            if(caseAssetids.size()>0 && projIDs!=null && projIDs.size()>0 && AssetList.isEmpty() && Asset.SObjectType.getDescribe().isAccessible()) { //FLS Already added - Aditya
                for(Asset objAst : [SELECT Id,Core_Supported_Product__c FROM Asset WHERE Id IN :caseAssetids]){
                    supportedProdIDs.add(objAst.Core_Supported_Product__c);
                    mapCaseAssetSupProd.put(objAst.Id,objAst.Core_Supported_Product__c);
                }    
                
            }
            
            if(supportedProdIDs!=null && supportedProdIDs.size()>0 && projIDs!=null && projIDs.size()>0)
            {                                       
                for(Core_IPS_Product__c projProd : [Select Id, Core_IPS_Prod_Def_Case_Owner_ID__c, Core_Supported_Product__c,Core_IPS_Project__c,Core_IPS_Project__r.Core_IPS_Private__c,Core_IPS_Project__r.OwnerId FROM Core_IPS_Product__c WHERE Core_Supported_Product__c IN :supportedProdIDs AND Core_IPS_Project__c in : projIDs]) 
                {  
                    String projKey = String.valueOf(projProd.Core_Supported_Product__c)+String.valueOf(projProd.Core_IPS_Project__c);
                    
                    if(!String.isBlank(projProd.Core_IPS_Prod_Def_Case_Owner_ID__c)) {   // added by sumukh for US261517 & US264004 AND [Removed by sumukh for US586420  && (projProd.Core_IPS_Product_Case_Owner__r.Isactive==True) )]                 
                        mapProjProdOwner.put(projKey,projProd.Core_IPS_Prod_Def_Case_Owner_ID__c);
                    }else {
                        mapProjProdOwner.put(projProd.Core_IPS_Project__c,projProd.Core_IPS_Project__r.OwnerId);
                    }
                }              
            }    
            //End by Gourav
        }
        catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');}        
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 3/12/2018
Function    : This method updates case owner group when case owner changes
Input Parameters: Case New List
Output Parameters: None
Transactions: Before Insert
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aparna                  3/12/2018                 US196940-Created
* Ganapati                06/12/2019                Modified for US431208 - Case records to now link to Case Owner Group (COG) records based on 'Case Owner Email' data
***********************************************************************************/
    // Commeted by chetan as part of COG fix for GEC cases

    // public static void updateCaseOwnerGroup(List<Case> newList,Map<Id,Case> oldMap){
    //     try{
            
    //         if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateCaseOwnerGroup')){
    //             return;
    //         }    
            
    //         //set<Id> caseOwnerSet = new set<Id>();             // Commented by Ganapati for - US431208
    //         Set<String> caseOwnerEmailSet = new Set<String>();      // Added by Ganapati for - US431208
    //         set<Id> supportOrgSet = new set<Id>();
    //         List<case> lstScope = new List<Case>();
            
    //         for(case cs : newList){
    //            if(Integer.valueOf(System.Label.Core_IPS_EnableDebug)>0){
    //             //	system.debug('COGUpdate Debug1 - '+cs.Core_IPS_Case_Owner_Email__c+'--' + cs.Core_IPS_Product_Org1__c);
    //             //	system.debug('COGUpdate Debug2 - '+oldMap);
    //             }
    //             system.debug('New mail '+cs.Core_IPS_Case_Owner_Email__c );
    //             system.debug(' old email '+oldMap.get(cs.id).Core_IPS_Case_Owner_Email__c );
    //             system.debug('New prod org '+cs.Core_IPS_Product_Org1__c);
    //             system.debug('old prod org '+oldMap.get(cs.id).Core_IPS_Product_Org1__c );

    //             //if(oldMap==null || (oldMap!=null && (cs.OwnerId!=oldMap.get(cs.id).OwnerId || cs.Core_IPS_Product_Org1__c != oldMap.get(cs.id).Core_IPS_Product_Org1__c))) // Commented by Ganapati for - US431208
    //            // if(oldMap==null || (oldMap!=null && (cs.Core_IPS_Case_Owner_Email__c!=oldMap.get(cs.id).Core_IPS_Case_Owner_Email__c || cs.Core_IPS_Product_Org1__c != oldMap.get(cs.id).Core_IPS_Product_Org1__c))) // Modified by Ganapati for - US431208
    //             if(oldMap==null || (oldMap!=null && ((cs.Core_IPS_Case_Owner_Email__c!=oldMap.get(cs.id).Core_IPS_Case_Owner_Email__c || cs.Core_IPS_Product_Org1__c != oldMap.get(cs.id).Core_IPS_Product_Org1__c) ||
    //                                                  (cs.Core_IPS_Case_Owner_Email__c!=null && cs.Core_IPS_Case_Owner_Groups__c == null && cs.Core_IPS_New_Backend_System__c!=null))))
    //             {
    //              if(Integer.valueOf(System.Label.Core_IPS_EnableDebug)>0){
    //             	//	system.debug('COGUpdate Debug3 - IF');
    //              }
    //                 cs.Core_IPS_Case_Owner_Groups__c = null;    
    //                 //caseOwnerSet.add(cs.OwnerId);
    //                 caseOwnerEmailSet.add(cs.Core_IPS_Case_Owner_Email__c);
    //                 supportOrgSet.add(cs.Core_IPS_Product_Org1__c);
    //                 //if(cs.OwnerId!=null && cs.Core_IPS_Product_Org1__c!=null)
    //                 if(cs.Core_IPS_Case_Owner_Email__c!=null && cs.Core_IPS_Product_Org1__c!=null) { // Modified by Ganapati for - US431208
    //                     lstScope.add(cs);   
    //                 }
    //             }    
    //         }
            
    //         //if(!caseOwnerSet.isEmpty() && !supportOrgSet.isEmpty()){
    //         if(!caseOwnerEmailSet.isEmpty() && !supportOrgSet.isEmpty()){ // Modified by Ganapati for - US431208
    //             Map<string,Id> mapCaseOwnerGroup = new Map<string,Id>();
    //             //for(Core_IPS_Case_Owner_Group__c obj : [select id,Core_IPS_Case_Owner__c,Core_IPS_Support_Org__c from Core_IPS_Case_Owner_Group__c where Core_IPS_Case_Owner__c in: caseOwnerSet AND Core_IPS_Support_Org__c in: supportOrgSet]) {
    //             for(Core_IPS_Case_Owner_Group__c obj : [select id,Core_IPS_Case_Owner_Email__c,Core_IPS_Support_Org__c from Core_IPS_Case_Owner_Group__c where Core_IPS_Case_Owner_Email__c in: caseOwnerEmailSet AND Core_IPS_Support_Org__c in: supportOrgSet ORDER BY CreatedDate asc]) {
    //                 mapCaseOwnerGroup.put(String.valueOf(obj.Core_IPS_Case_Owner_Email__c) + String.valueOf(obj.Core_IPS_Support_Org__c), obj.id);  // Modified by Ganapati for - US431208
    //             }
                
    //             if(!mapCaseOwnerGroup.isEmpty()) { 
    //                 for(case cs : lstScope){     
    //                     //String key = String.valueOf(cs.ownerId) + String.valueOf(cs.Core_IPS_Product_Org1__c);
    //                     String key = String.valueOf(cs.Core_IPS_Case_Owner_Email__c) + String.valueOf(cs.Core_IPS_Product_Org1__c); // Modified by Ganapati for - US431208
    //                     if(Integer.valueOf(System.Label.Core_IPS_EnableDebug)>0){
    //             		//	system.debug('COGUpdate Debug4 - '+mapCaseOwnerGroup);
    //                 	}
    //                     if(mapCaseOwnerGroup.containsKey(key)) {
    //                             if(Integer.valueOf(System.Label.Core_IPS_EnableDebug)>0){
    //             			//	system.debug('COGUpdate Debug5 - IF');
    //                 		}
    //                         cs.Core_IPS_Case_Owner_Groups__c = mapCaseOwnerGroup.get(key);
    //                     }
    //                 }
    //             }
    //         }        
    //     }catch(exception e){Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');} 
    // }


    

    // Created New method by chetan to fix  COG issue for GEC cases
    public static void updateCaseOwnerGroupnew(List<Case> newList,Map<Id,Case> oldMap){
        try{
            
            if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateCaseOwnerGroup')){
                return;
            }    
            
            //set<Id> caseOwnerSet = new set<Id>();             // Commented by Ganapati for - US431208
            Set<String> caseOwnerEmailSet = new Set<String>();      // Added by Ganapati for - US431208
            set<Id> supportOrgSet = new set<Id>();
            List<case> lstScope = new List<Case>();
            map<Id,case> caseIdmap = new map<id,case>(newList);
            list<case> caseListtoUpdate = new list<case>();
            // Added Core_IPS_Case_Owner_Groups__c field in below query by chetan to fix COG issue while updating the cases.
            list<case> newcasedatalist = [Select id ,Core_IPS_Case_Owner_Email__c ,Core_IPS_Product_Org1__c ,Core_IPS_New_Backend_System__c ,Core_IPS_Case_Owner_Groups__c from case WHERE Id In : caseIdmap.keyset() ];
            for(case cs : newcasedatalist){
              
                //if(oldMap==null || (oldMap!=null && (cs.OwnerId!=oldMap.get(cs.id).OwnerId || cs.Core_IPS_Product_Org1__c != oldMap.get(cs.id).Core_IPS_Product_Org1__c))) // Commented by Ganapati for - US431208
               // if(oldMap==null || (oldMap!=null && (cs.Core_IPS_Case_Owner_Email__c!=oldMap.get(cs.id).Core_IPS_Case_Owner_Email__c || cs.Core_IPS_Product_Org1__c != oldMap.get(cs.id).Core_IPS_Product_Org1__c))) // Modified by Ganapati for - US431208
                if(oldMap==null || (oldMap!=null && ((cs.Core_IPS_Case_Owner_Email__c!=oldMap.get(cs.id).Core_IPS_Case_Owner_Email__c || cs.Core_IPS_Product_Org1__c != oldMap.get(cs.id).Core_IPS_Product_Org1__c) ||
                                                     (cs.Core_IPS_Case_Owner_Email__c!=null && cs.Core_IPS_Case_Owner_Groups__c == null && cs.Core_IPS_New_Backend_System__c!=null))))
                {
                 
                    cs.Core_IPS_Case_Owner_Groups__c = null;    
                    //caseOwnerSet.add(cs.OwnerId);
                    caseOwnerEmailSet.add(cs.Core_IPS_Case_Owner_Email__c);
                    supportOrgSet.add(cs.Core_IPS_Product_Org1__c);
                    //if(cs.OwnerId!=null && cs.Core_IPS_Product_Org1__c!=null)
                    if(cs.Core_IPS_Case_Owner_Email__c!=null && cs.Core_IPS_Product_Org1__c!=null) { // Modified by Ganapati for - US431208
                        lstScope.add(cs);   
                    }
                }    
            }
            
            //if(!caseOwnerSet.isEmpty() && !supportOrgSet.isEmpty()){
            if(!caseOwnerEmailSet.isEmpty() && !supportOrgSet.isEmpty()){ // Modified by Ganapati for - US431208
                Map<string,Id> mapCaseOwnerGroup = new Map<string,Id>();
                //for(Core_IPS_Case_Owner_Group__c obj : [select id,Core_IPS_Case_Owner__c,Core_IPS_Support_Org__c from Core_IPS_Case_Owner_Group__c where Core_IPS_Case_Owner__c in: caseOwnerSet AND Core_IPS_Support_Org__c in: supportOrgSet]) {
                for(Core_IPS_Case_Owner_Group__c obj : [select id,Core_IPS_Case_Owner_Email__c,Core_IPS_Support_Org__c from Core_IPS_Case_Owner_Group__c where Core_IPS_Case_Owner_Email__c in: caseOwnerEmailSet AND Core_IPS_Support_Org__c in: supportOrgSet ORDER BY CreatedDate asc]) {
                    mapCaseOwnerGroup.put(String.valueOf(obj.Core_IPS_Case_Owner_Email__c) + String.valueOf(obj.Core_IPS_Support_Org__c), obj.id);  // Modified by Ganapati for - US431208
                }
                
                if(!mapCaseOwnerGroup.isEmpty()) { 
                    for(case cs : lstScope){     
                        //String key = String.valueOf(cs.ownerId) + String.valueOf(cs.Core_IPS_Product_Org1__c);
                        String key = String.valueOf(cs.Core_IPS_Case_Owner_Email__c) + String.valueOf(cs.Core_IPS_Product_Org1__c); // Modified by Ganapati for - US431208
                        
                        if(mapCaseOwnerGroup.containsKey(key)) {
                                
                            cs.Core_IPS_Case_Owner_Groups__c = mapCaseOwnerGroup.get(key);
                        }
                      caseListtoUpdate.add(cs);  
                    }
                    update caseListtoUpdate;
                }
            }        
        }catch(exception e){Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');} 
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 22/2/2019
Function    : This method adds a private to Intel Comment for a USA-Minds case where compliance
status is Approved  with GuardRails
Input Parameters: Case New List
Output Parameters: None
Transactions: After insert
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aparna                  22/2/2019                  US253169-Created
* Aparna                  23/5/2019                  Added for US340937
* Sneha                   26/11/2019                 US372697-Modified
***********************************************************************************/
    
    public static void  insertCommentUSAMinds(List<Case> newList){
        try{
            
            if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('insertCommentUSAMinds')){
                return;    
            }
            list<Core_IPS_Case_Comments__c> commentlist = new list<Core_IPS_Case_Comments__c>();
            Core_IPS_Case_Comments__c newComment ;       
            
            for(Case cc : newList){
                if(trigger.isInsert && cc.Core_IPS_Minds__c && cc.Core_IPS_Country_Region__c == Core_IPS_Helper_Utility.getIPSLabel('USA')&& cc.Core_IPS_GEC_Status__c== Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved_WithG')){
                    commentList.add(createCaseComment(cc.id));
                }
                          
            }          
            //FLS Added as Part of code refactor
            if(Schema.sObjectType.Core_IPS_Case_Comments__c.isCreateable() && commentList!=null && commentList.size()>0 && isCommentInserted == false){
                insert commentList;
                // Added by Chetan
                isCommentInserted = true;
            }
        }catch(Exception e){Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');}
    }
    
    //end for US253169
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 22/5/2019
Function    : This method adds a private to Intel Comment for a USA-Minds case where compliance
status is Approved  with GuardRails when a contact on case is updated
Input Parameters: Case old List
Output Parameters: None
Transactions: After update
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 0
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sumukh                    22/5/2019              US357190-Created
* Sneha                     26/11/2019             US372697-Modified
***********************************************************************************/
    public static void  updateCommentUSAMinds(Map<Id,Case> oldMap, Map<Id,case> newMap){
        try{
            
            
            if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('UpdateCommentUSAMinds')){
                return;    
            }    
            
            list<Core_IPS_Case_Comments__c> commentlist = new list<Core_IPS_Case_Comments__c>();
            Core_IPS_Case_Comments__c newComment ;         
            
            for(Case cc : newMap.values()){   
                
                if(oldMap!=null && oldMap.get(cc.id).Contactid != newMap.get(cc.id).Contactid  && (cc.Core_IPS_Minds__c && cc.Core_IPS_Country_Region__c == Core_IPS_Helper_Utility.getIPSLabel('USA')&& cc.Core_IPS_GEC_Status__c== Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved_WithG'))){             
                    commentList.add(createCaseComment(cc.id));     
                    
                }           
            }  
            // added by chetan
            if(Schema.sObjectType.Core_IPS_Case_Comments__c.isCreateable() && commentList!=null && commentList.size()>0 && isCommentInserted == false){
                insert commentList;
                // Added by Chetan 
                isCommentInserted = true;
            }
        }catch(Exception e){Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');}
    } 
    // end by sumukh for US357190 
    
    
    // method to create case comment 
    public static Core_IPS_Case_Comments__c createCaseComment(id caseId){
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
        newComment.Core_IPS_Case__c=caseId;
        newComment.Core_IPS_Case_Comment_Type__c = Core_IPS_Helper_Utility.getIPSLabel('PRIVATE_TO_INTEL');
        newComment.Core_IPS_Rich_Comment__c =   Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_USAMinds_Comment');     
        newComment.Core_IPS_Comment_Authored_By__c = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_USAMindsComment_Author');
        /* Sneha - US372697  -- START */
        //newComment.Core_IPS_Comment_Author_Type__c = Core_IPS_Helper_Utility.getIPSLabel('Agent');
        newComment.Core_IPS_Comment_Author_Type__c = Core_IPS_Helper_Utility.getIPSLabel('System');
        /* Sneha - US372697  -- END */
        newComment.LastModifiedById =  Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_USAMindsComment_Author');                
        return newComment;   
    }
    
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 02/07/2019
Function    : This method creates an Interal Interested Party if Case is created by an FAE and that FAE 
is not a Contact's ISO
Input Parameters: Case New List
Output Parameters: None
Transactions: After Insert
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sneha                    02/07/2019              US358368-Created
***********************************************************************************/
    public static void createFAEASInterestedParty(List<Case> ipsNewRecordList){
        if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('createFAEASInterestedParty')){
            return;
        }    
        Map<Id,User> userProfileMap = new Map<Id,User>(); //Added as part of Code Refactor TWC745-6459
        Set<Id> createByUserIds = new Set<Id>();
        Set<String> setValues = new Set<String>();
        List<Core_IPS_Case_Interested_Party__c> interestedPartyList = new List<Core_IPS_Case_Interested_Party__c>();
        String salesRepsId = Core_IPS_Helper_Utility.getIPSLabel('IPS_SalesRep_ProfilesId');
        if(String.isNotBlank(salesRepsId)) { 
            setValues = new Set<String>(salesRepsId.split(','));
        }
        for(Case cs : ipsNewRecordList){
            createByUserIds.add(cs.createdById);
        }
        if(!createByUserIds.isEmpty()){
            //Added as part of Code Refactor TWC745-6459
            if(Core_IPS_CaseTriggerHandler.GlobalUserRecords != null && Core_IPS_CaseTriggerHandler.GlobalUserRecords.size()>0 && !isQueryRequired(new List<Id>(createByUserIds),Core_IPS_CaseTriggerHandler.GlobalUserRecords,null)){
                userProfileMap = Core_IPS_CaseTriggerHandler.GlobalUserRecords;
              
            }    
            else{
            userProfileMap = new Map<Id,User>([SELECT ProfileID from User where ID IN:createByUserIds]);
            }
        }
        for(Case cs : ipsNewRecordList){
            String userProfileId;
            if(userProfileMap != null && !userProfileMap.isEmpty() && userProfileMap.containsKey(cs.createdbyID)){
                userProfileId = String.valueOf(userProfileMap.get(cs.createdbyID).profileID).left(15);
            }
            
            if(String.isNotBlank(userProfileId) && setValues.contains(userProfileId) && (cs.contactId != null && cs.contact.Core_IPS_Intel_Support_Owner__c != cs.createdByID)){
                Core_IPS_Case_Interested_Party__c newRecord = new Core_IPS_Case_Interested_Party__c();
                newRecord.User__c = cs.createdByID; 
                newRecord.Case__c = cs.ID;
                newRecord.Type__c = 'Internal';
                newRecord.Active__c = true;
                if(cs.Core_IPS_Project_Case__c != null){
                    newRecord.Core_IPS_Project_Interested_Party__c = true;   
                }
                interestedPartyList.add(newRecord);
            }
        }
        try{
             /*if(!interestedPartyList.isEmpty()){
                insert interestedPartyList;
            }*/
            // Added by Chetan 
             if(interestedPartyList.size()>0){
                System.enqueueJob(new Core_IPS_insertInterestedPartyQueueable(interestedPartyList));
            }
        }
        catch(Exception e){
        }           
    }
    /***************************************************************************************************
Version     : 1.0 
Created Date: 2020
Function    : 
Input Parameters: 
Output Parameters: 
Transactions: After Insert
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sriranjini                    06/11/2020            US688472
***********************************************************************************/
    public static void backendEndSystemProcessCase(Map<Id,Case> oldMap, Map<Id,Case> newMap){
        Set<Id> caseSentForBackend = new Set<Id>();
        Set<Id> newBackends = new Set<Id>();
        Set<Id> updatebackends = new Set<Id>();
        Map<String,String> caseOldBackendMap = new Map<String,String>();
        set<String> backendIds=new set<String>(); //Added as part of Code Refactor TWC745-6459
        //List<case> backendCaseList = new List<Case>(); //Commented as part of Code Refactor TWC745-6459
        Map<Id,Boolean> backendCaseMap = new Map<Id,Boolean>();
        try{
 //Ajith added this logic to restrict to create Outbound messages, when Backend system is deactivated
            //START - Added as part of Code Refactor TWC745-6459
            for(Case getCase:newMap.values()){
                if(oldMap.get(getCase.Id).Core_IPS_New_Backend_System__c!=null){
                    backendIds.add(oldMap.get(getCase.Id).Core_IPS_New_Backend_System__c);
                }
                if(newMap.get(getCase.Id).Core_IPS_New_Backend_System__c !=null){
                    backendIds.add(newMap.get(getCase.Id).Core_IPS_New_Backend_System__c);
                }
            }
         
            getNewBackendIdList.clear();
            getNewBackendIdList.addAll(backendIds);
       
            if(backendIds.size()>0 && Core_Utility.executeQuery(getNewBackendIdList,getOldBackendIdList)){
         
                backendRecMap = new Map<Id,Core_IPS_Backend_System2__c>([SELECT Id,Name,Core_IPS_Deactivated__c FROM Core_IPS_Backend_System2__c where ID IN:backendIds]);
                getOldBackendIdList.clear();
                getOldBackendIdList.addAll(backendIds);
                //backendCaseList =[select id,Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c,Core_IPS_BackendID__c, Core_IPS_BES_Promote_Status__c,Core_IPS_New_Backend_System__c from case where Id IN :caseIds]; 
            }
            for(Case getCase:newMap.values()){
                if(newMap.get(getCase.Id).Core_IPS_New_Backend_System__c!=null && backendRecMap.containskey(newMap.get(getCase.Id).Core_IPS_New_Backend_System__c)){
                    Core_IPS_Backend_System2__c backRecord = backendRecMap.get(newMap.get(getCase.Id).Core_IPS_New_Backend_System__c);
                    backendCaseMap.put(getCase.id, backRecord.Core_IPS_Deactivated__c);
                } else if(oldMap.get(getCase.Id).Core_IPS_New_Backend_System__c!=null && backendRecMap.containskey(oldMap.get(getCase.Id).Core_IPS_New_Backend_System__c)){
                    Core_IPS_Backend_System2__c backRecord = backendRecMap.get(oldMap.get(getCase.Id).Core_IPS_New_Backend_System__c);
                    backendCaseMap.put(getCase.id, backRecord.Core_IPS_Deactivated__c);
                }
            }
            // END - TWC745-6459
            list<Id>listofcaseids=new list<Id>();
            //Aj
            list<Id> csid=new list<Id>();
            for(Case cs: newMap.values()){
                //Minhaj
                if(oldMap.get(cs.ID).Core_IPS_BackendID__c == null  && newMap.get(cs.Id).Core_IPS_BackendID__c != null ){
                    continue;
        }           
                if(oldMap.get(cs.ID).Core_IPS_New_Backend_System__c == null && newMap.get(cs.Id).Core_IPS_New_Backend_System__c !=null && newMap.get(cs.Id).core_IPS_BES_promote_status__c != 'Not Yet Promoted'){
                    newBackends.add(cs.Id);
                }else if(newMap.get(cs.Id).core_IPS_BES_promote_status__c == 'Done' || newMap.get(cs.Id).core_IPS_BES_promote_status__c == 'In Progress'){
                    updatebackends.add(cs.Id);
                } 
                //Ajith added this logic to restrict to create Outbound messages, when Backend system is deactivated
                    if((oldMap.get(cs.ID).Core_IPS_New_Backend_System__c != null && oldMap.get(cs.ID).Core_IPS_New_Backend_System__c != newMap.get(cs.ID).Core_IPS_New_Backend_System__c && !String.isBlank(newMap.get(cs.ID).Core_IPS_BackendID__c)) && backendCaseMap.get(cs.ID) ==false || 
                      (String.isBlank(oldMap.get(cs.ID).Core_IPS_BackendID__c) != String.isBlank(newMap.get(cs.ID).Core_IPS_BackendID__c) && cs.Core_IPS_New_Backend_System__c != null && cs.Core_IPS_BES_Promote_Status__c!= 'In Progress' && cs.Core_IPS_BES_Promote_Status__c!= 'Not Yet Promoted'))
                      {
                        caseOldBackendMap.put(cs.ID, oldMap.get(cs.ID).Core_IPS_BackendID__c+';'+oldMap.get(cs.ID).Core_IPS_New_Backend_System__c); 
                    //  added by AJ name convetion csidlist
                    csid.add(cs.id);
                    //   prepareComment(cs.Id);
                      //  Core_IPS_BES_OutboundMessage.createPlatformEventHSD(prepareComment(cs.Id), true);
                        if(newMap.get(cs.ID).Core_IPS_New_Backend_System__c != null){
                            newMap.get(cs.ID).Core_IPS_BES_Promote_Status__c = 'Not Yet Promoted';
                        } else {
                            newMap.get(cs.ID).Core_IPS_BES_Promote_Status__c = ''; 
                        }
                        newMap.get(cs.ID).Core_IPS_BackendID__c = '';
                        newMap.get(cs.ID).Core_IPS_Backend_Rev__c = '';
                    }
                //Minhaj
                if(cs.Core_IPS_New_Backend_System__c != null && newMap.get(cs.Id).Core_IPS_BackendID__c != null && cs.Status != null && cs.Status == 'Closed'  && oldMap.get(cs.ID).Status != 'Closed'){
                    //Ajith added this logic to restrict to create Outbound messages, when Backend system is deactivated
                    //    makeCreatePlatformEventInFuture(cs.Id,backendCaseMap);
                    //added by AJ
                    listofcaseids.add(cs.Id);
                   // Core_IPS_BES_OutboundMessage.createPlatformEventHSD(addclosedCommentToFlowHSD(cs.Id), false);
                }  
                //minhaj end   
            }
            //added by AJ
            if(!csid.isEmpty() && csid!=null){
                prepareComment(csid);
            }
            if(!listofcaseids.isEmpty() && listofcaseids!=null){
                makeCreatePlatformEventInFuture(listofcaseids,backendCaseMap);
            }
            for(Id caseId: newBackends){
                //Ajith added this logic to restrict to create Outbound messages, when Backend system is deactivated
                if(backendCaseMap.containsKey(caseId) && backendCaseMap.get(caseId) == false) {
                caseSentForBackend.add(caseId);
            }   
            }   
            //for Support update logic taking values from custom setting and adding into customSettingMap with json field name an Salesforce API name.
            if(updatebackends.size() > 0){
                //List<IPS_Case_Fields__c> allCustomSettings = new List<IPS_Case_Fields__c>(); - //Commented as part of Code Refactor TWC745-6459 moved to global scope
                //Map<String, String> customSettingMap = new Map<String,String>(); //Commented as part of Code Refactor TWC745-6459 moved to global scope
                if(IPS_Case_Fields__c.SObjectType.getDescribe().isQueryable() && (customSettingMap.isEmpty() || allCustomSettings.isEmpty())){
                    /* allCustomSettings =[Select id, Object_Name__c, API_Name__c, JSON_Field_Name__c,Order__c,Additional_Info__c from IPS_Case_Fields__c where Object_Name__c = 'case' order by Order__c DESC Limit 100];
                    for(IPS_Case_Fields__c setting: allCustomSettings){
                        customSettingMap.put(setting.JSON_Field_Name__c, setting.API_Name__c);
}*/
                    for(IPS_Case_Fields__c setting: IPS_Case_Fields__c.getAll().values()){
                        if(setting.Object_Name__c == 'Case'){
                            customSettingMap.put(setting.JSON_Field_Name__c, setting.API_Name__c);
                        
                        }
                    }
                }
                String direction = 'Outbound';
                Boolean support = true;
                Set<Id> newKeys = updatebackends;
              //Quering field value mapping form backend system.
                List<Core_IPS_Backend_System2__c> backendMappings = new List<Core_IPS_Backend_System2__c>();
                String query = 'SELECT ID, (SELECT ID, Core_IPS_New_Backend_System__c, Core_Object_Name__c, Core_IPS_Source_Field__c, Core_IPS_Direction__c, Support_Update__c FROM Backend_Field_Mappings__r WHERE Support_Update__c = true and Core_IPS_Direction__c =\''+
                                String.escapesinglequotes(direction)+'\') from Core_IPS_Backend_System2__c WHERE Id IN (Select Core_IPS_New_Backend_System__c from case where ID IN:newKeys)';
             
                //Added as part of Code Refactor TWC745-6459
                if(Core_IPS_Backend_System2__c.SObjectType.getDescribe().isQueryable() && backendIds.size()>0 && Core_Utility.executeQuery(getNewBackendIdList,getOldCaseBackendIdList)){
                 
                    backendMappings = Database.query(query);
                 
                    getOldCaseBackendIdList.clear();
                    getOldCaseBackendIdList.addAll(backendIds);
                 
                } 
              
                Map<Id,List<String>> caseFieldMap = new Map<Id, List<String>>();
                Map<Id,List<String>> edqFieldMap = new Map<Id, List<String>>();
               //Logic to get API names from field value mapping of the backend system for both case fields and edq fields.
                for(Core_IPS_Backend_System2__c backendMapping : backendMappings){
                   List<String> caseField = new List<String>();
                   List<String> edqField = new List<String>();
                    for(Core_IPS_Backend_Field_Map__c backendMap: backendMapping.Backend_Field_Mappings__r){
                        if(customSettingMap.get(backendMap.Core_IPS_Source_Field__c) != null){
                            caseField.add(customSettingMap.get(backendMap.Core_IPS_Source_Field__c));
                        }else if(backendMap.Core_Object_Name__c == 'Core_IPS_Response__c'){
                            edqField.add(backendMap.Core_IPS_Source_Field__c);
                        }
                    }
                    caseFieldMap.put(backendMapping.Id, caseField);
                    edqFieldMap.put(backendMapping.Id, edqField);
                }
                //Filter the bulkified cases from different backed system such as key as case and value as fields.
                Map<Id, List<String>> caseBackendFieldMap = new Map<Id,List<String>>();
                Map<Id, List<String>> edqBackendFieldMap = new Map<Id,List<String>>();
                for(case caseRec :newMap.values()){
                    if(caseFieldMap.get(caseRec.Core_IPS_New_Backend_System__c) != null){
                        caseBackendFieldMap.put(caseRec.Id, caseFieldMap.get(caseRec.Core_IPS_New_Backend_System__c)); 
                        edqBackendFieldMap.put(caseRec.Id, edqFieldMap.get(caseRec.Core_IPS_New_Backend_System__c)); //{'500xxxxxx',['purly_cpu','','']}
                    }
                }
                Map<String, List<Map<String,Object>>> newEnvVarables = new Map<String, List<Map<String,Object>>>();
                List<Map<String,Object>> environmentDetails = new List<Map<String,Object>>();
                //Checking the exact field change which only support update, this will check for case fileds
                for(Id caseId: caseBackendFieldMap.keySet()){
                    for(String field :caseBackendFieldMap.get(caseId)){
                        if(newMap.get(caseId).get(field) != '' && Core_IPS_BES_RecursionHandler.isFirstTime){
                            if(oldMap.get(caseId).get(field) != newMap.get(caseId).get(field)){
                                //Ajith added this logic to restrict to create Outbound messages, when Backend system is deactivated
                                if(backendCaseMap.containsKey(caseId) && backendCaseMap.get(caseId) == false){
                                caseSentForBackend.add(caseId);
                                }
                                Core_IPS_BES_RecursionHandler.isFirstTime = false;
                                break;
                            }
                        }
                    }
                    //Checking the exact field change which only support update, this will check for EDQ fileds
                    if(oldMap.get(caseId).Core_IPS_EDQ_Filtering_Question__c != null && newMap.get(caseId).Core_IPS_EDQ_Filtering_Question__c != null &&
                       oldMap.get(caseId).Core_IPS_EDQ_Filtering_Question__c == newMap.get(caseId).Core_IPS_EDQ_Filtering_Question__c){
                          
                           Map<Id,Map<String,Object>> oldEdqMap = getEdqs(new Map<Id,String>{caseId => oldMap.get(caseId).Core_jsonfield__c}, oldMap.get(caseId).Core_IPS_EDQ_Filtering_Question__c.split('[|]'));
                           Map<Id,Map<String,Object>> newEdqMap = getEdqs(new Map<Id,String>{caseId => newMap.get(caseId).Core_jsonfield__c}, newMap.get(caseId).Core_IPS_EDQ_Filtering_Question__c.split('[|]'));
                           for(String edfield :edqBackendFieldMap.get(caseId)){ 
                               //if(oldEdqMap.get(caseId).keySet().size()==newEdqMap.get(caseId).keySet().size()){
                                   if(String.valueOf(oldEdqMap.get(caseId).get(edfield)) != null && String.valueOf(oldEdqMap.get(caseId).get(edfield)) != String.valueOf(newEdqMap.get(caseId).get(edfield)) && Core_IPS_BES_RecursionHandler.isFirstTime && Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(oldMap.get(caseId).RecordTypeId)!='IPS Closed Case' && Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(newMap.get(caseId).RecordTypeId)!='IPS Closed Case'){
                                       //Ajith added this logic to restrict to create Outbound messages, when Backend system is deactivated
                                       if(backendCaseMap.containsKey(caseId) && backendCaseMap.get(caseId) == false){
                                       caseSentForBackend.add(caseId);
                                       }
                                       Core_IPS_BES_RecursionHandler.isFirstTime = false;
                                       break;
                                   }
                              // }
                           }
                       }
                    //Manual Promotion code when we change the status from Failed to Promote.
                    if(oldMap.get(caseId).Core_IPS_BES_Promote_Status__c != 'In Progress' && newMap.get(caseId).Core_IPS_BES_Promote_Status__c == 'In Progress' && Core_IPS_BES_RecursionHandler.isFirstTime){
                        //Ajith added this logic to restrict to create Outbound messages, when Backend system is deactivated
                        if(backendCaseMap.containsKey(caseId) && backendCaseMap.get(caseId) == false){
                        caseSentForBackend.add(caseId);
                        }
                        Core_IPS_BES_RecursionHandler.isFirstTime = false;
                        break;                           
                    }
                }
            }
            if(caseSentForBackend.size() > 0){
                Core_IPS_BES_OutboundMessage.createPlatformEventHSD(caseSentForBackend);
            }  
            if(caseOldBackendMap.size() > 0){
                Core_IPS_BES_OutboundMessage.createPlatformEventHSD(caseOldBackendMap);
            }
        }catch(Exception e){
            if(Core_IPS_BES_RecursionHandler.stopRecursion == true && Core_CaseTrigger_Dispatcher.backendPromotionRecursive){
                Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join((Iterable<String>)newMap.keySet(),','));  
                Core_IPS_BES_RecursionHandler.stopRecursion = false;
            }
        }
    }
    public static void prepareComment(list<Id> caseId){
        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        for(id csid:caseId){
        Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();
        caseComment.Core_IPS_Case_Comment_Type__c=Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;  
        caseComment.Core_IPS_Rich_Comment__c= Label.Core_IPS_BES_Private_Comment; 
        caseComment.Core_IPS_Comment_Author_Type__c = 'System';
        caseComment.Core_IPS_Comment__c = 'Test Comment';  
        caseComment.Core_IPS_Case_Comment_Source__c ='';
            caseComment.Core_IPS_Case__c = csId; 
        commentList.add(caseComment);
        }
        //fls added as part of code refactor
        if(Schema.sObjectType.Core_IPS_Case_Comments__c.isCreateable() && !commentList.isEmpty()){
        insert commentList;
        }
        // return commentList;
    }
    @future(callOut = true)
    public static void makeCreatePlatformEventInFuture(List<Id> csIdList, Map<Id, Boolean> backendCaseMap) {
        //added by AJ
        // List to hold Ids that meet the condition
        List<Id> filteredIds = new List<Id>();
        // Iterate over the list of Case Ids
        for (Id caseId : csIdList) {
            // Check if the backendCaseMap contains the Case Id and if the value is false
            if (backendCaseMap.containsKey(caseId) && backendCaseMap.get(caseId) == false) {
                // Add the Case Id to the list
                filteredIds.add(caseId);
            }
        }
        // Check if there are any filtered Ids to process
        if (!filteredIds.isEmpty()) {
            // Assuming `addclosedCommentToFlowHSD` and `createPlatformEventHSD` are methods available in your context
            Core_IPS_BES_OutboundMessage.createPlatformEventHSD(addclosedCommentToFlowHSD(filteredIds), false);
    }
    }
    public static List<Core_IPS_Case_Comments__c> addclosedCommentToFlowHSD(list<Id> caseId){
        //  List<Case> listOfCases = (List<Case>) JSON.deserialize(listOfCasesstr, List<Case>.class);
        List<Core_IPS_Case_Comments__c> listOfCommentInsert = new List<Core_IPS_Case_Comments__c>();
        //added by AJ
        for(Id cs : caseId){
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
            newComment.Core_IPS_Case__c = cs; 
        newComment.Core_IPS_Rich_Comment__c = 'Customer Closed in IPS';
        newComment.Core_IPS_Case_Comment_Type__c = 'Private to Intel';                 
        newComment.Core_IPS_Comment_Authored_By_Name__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();             
        newComment.Core_IPS_Case_Comment_Source__c = 'Backend System';
        newComment.Core_IPS_Comment_Authored_By__c = UserInfo.getUserId();
        newComment.Core_IPS_Comment_Author_Type__c = 'Backend Integration';
        newComment.Core_IPS_Comment_Authored_By_Email__c = UserInfo.getUserEmail();
        listOfCommentInsert.add(newComment);
        }
        //FLS Added as Part of code refactor
        if((Schema.sObjectType.Core_IPS_Case_Comments__c.isCreateable() && listOfCommentInsert!=null  && !listOfCommentInsert.isEmpty()) || !Test.isRunningTest() ){
             insert listOfCommentInsert;
        }
        return listOfCommentInsert;
    }   
 /***************************************************************************************************
Version     : 1.0 
Created Date: 2021
Function    : 
Input Parameters: List<Case> newList, String operationMsg
Output Parameters: 
Transactions: 
Used in     : Core_CaseTrigger_Dispatcher
Number of Queries Within this Method: 1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Chandrashekar Pallikonda   11/05/2021              US1005666
***********************************************************************************/
    public static void myIntelIntegration(List<case> oldList, List<case> newList, String opertionType){
        try {
            if(!Core_Trigger_Executions__c.getValues('myIntelIntegration').Core_Active__c){
                return;
            }
            List<Id> projectIds = new List<Id>();
            List<Id> caseIds = new List<Id>();
            List<Core_IPS_Project_Member__c> projMemberList = new List<Core_IPS_Project_Member__c>();
            if(opertionType == 'Create'){
                for(integer i=0; i < newList.size(); i++) {
                    if(newList[i].Core_IPS_Customer_Visible__c == true) {
                        caseIds.add(newList[i].Id);
                        projectIds.add(newList[i].Core_IPS_Project_Case__c);
                    }
                }
            }
            if(opertionType == 'Update'){
                for(integer i=0; i < newList.size(); i++) {
                    if((newList[i].Core_IPS_Customer_Visible__c == true && oldList[i].Core_IPS_Customer_Visible__c == false) 
                       || (newList[i].ContactId != oldList[i].ContactId) 
                       || (newList[i].Subject != oldList[i].Subject)
                       || (newList[i].AccountId != oldList[i].AccountId)
                       || (oldList[i].ProductId != null && newList[i].ProductId != oldList[i].ProductId) 
                       || (newList[i].Status != oldList[i].Status)
                       || (newList[i].Core_IPS_Premier_Support_Project_ID__c != oldList[i].Core_IPS_Premier_Support_Project_ID__c)) {
                           caseIds.add(newList[i].Id);
                           projectIds.add(newList[i].Core_IPS_Project_Case__c);
                       }   
                }
                
            }
            if(!projectIds.isEmpty() && Core_IPS_Project_Member__c.SObjectType.getDescribe().isQueryable()){
                projMemberList = [SELECT Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE 
                                  Core_IPS_Project__c IN: projectIds and Core_Status__c ='Active'];
            }
            if( !caseIds.isEmpty() &&  Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
                System.enqueueJob(new Core_IPS_MyIntel_3_0(caseIds, opertionType, projMemberList));
            }
       }catch(Exception e){
           Core_IPS_ExceptionHandling.logEntryWithException(e,'Core_IPS_CaseTriggerHandler','case');
       }
    }
//=====================================================================================
    /* Author : Chandrashekar Pallikonda
     * Date : 21-12-21
     * Description: This method is used to send all comments and attachments which are added to case before it was routed to any backend system to the promoted backend system.
     * ********************************************************************************************************************************/
    public static void promoteMissedItems(List<Id> caseIds) {
         List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
         List<Core_IPS_Case_Attachments__c> attachmentRecord = new List<Core_IPS_Case_Attachments__c>();
        //FLS check already added - Aditya
        if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isAccessible()){
            commentList = [SELECT Id, Core_IPS_Case__c, Core_IPS_BES_Promote_Status__c,Core_IPS_Comment_Authored_By_Name__c,Core_IPS_Comment_Author_Type__c,Core_IPS_Case_Comment_Source__c,Core_IPS_Rich_Comment__c,Core_IPS_Comment_Attachment_Id__c FROM Core_IPS_Case_Comments__c WHERE Core_IPS_Case__c IN: caseIds ORDER BY CreatedDate ASC];
        }
            if(!commentList.isEmpty()){
            Core_IPS_Case_Comments_Handler.sendComment(commentList);     
        }
        if(Contact.SObjectType.getDescribe().isAccessible()){
            attachmentRecord = [SELECT Id, Core_Case__c, Core_IPS_BES_Promote_Status__c,Core_Upload_Status__c FROM Core_IPS_Case_Attachments__c WHERE Core_Case__c IN: caseIds AND Core_Upload_Status__c = 'Complete' ORDER BY CreatedDate DESC LIMIT 1];//AND (Core_IPS_BES_Promote_Status__c = '' OR Core_IPS_BES_Promote_Status__c != 'Done')
        }
            if(!attachmentRecord.isEmpty()){
            Core_IPS_Case_Attachments_Handler.sendCaseAttachment(attachmentRecord);
        }
    }
//====================================================================================
    public static Map<Id,Map<String,Object>> getEdqs(Map<Id,String> jsonMap, List<String> questionReportName){
        List<Map<String, Object>> allEdqs = new List<Map<String, Object>>();
        Map<String,Object> edqsJSON = new Map<String,Object>();
        Map<String, String> newDataMap = new Map<String, String>();
        Map<Id,Map<String,Object>> edqMap = new Map<Id,Map<String,Object>>();
        for(String jsonString : jsonMap.keySet()){
            if(jsonMap.containsKey(jsonString) && (jsonMap.get(jsonString)!=null)){
                edqsJSON = (Map<String,Object>)System.JSON.deserializeUntyped(jsonMap.get(jsonString));
                for(Object singleMap : (List<Object>)edqsJSON.get('Env Dtl Resp')){
                    allEdqs.add((Map<String, Object>)singleMap);   
                }
                Integer count =0;
                for(Map<string,Object> edq: allEdqs){
                    try{
                        if(questionReportName.size() > count){
                            newDataMap.put(questionReportName[count], (String)edq.get('Ansr'));
                        }
                    }catch(Exception e){
                        if(Core_IPS_BES_RecursionHandler.stopRecursion == true && Core_CaseTrigger_Dispatcher.backendPromotionRecursive){
                            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join((Iterable<String>)jsonMap.keySet(),','));
                            Core_IPS_BES_RecursionHandler.stopRecursion = false;
                        }
                    }
                    count++;
                }
                edqMap = new Map<Id,Map<String,Object>>{jsonString => newDataMap};
             }
        }
        return edqMap;
    }
    //Added as part of Code Refactor TWC745-6459
    public static void PrepareGlobalData(List<Case> newList, List<Case> oldList,Map<Id,Case> oldMap){
        try{
            Map<string,Boolean> queryDatamap = new Map<string,Boolean>();
            
            Set<String> ContactIds = new Set<String>();
            Set<String> AssetIds = new Set<String>();
            Set<String> UserIds = new Set<String>();
            
            
            UserIds.add(userInfo.getUserId());
            for(Case cs : newList){
                if(String.isNotBlank(cs.ContactId)){
                    ContactIds.add(cs.ContactId);
                }
                if(String.isNotBlank(cs.AssetId)){
                    AssetIds.add(cs.AssetId);
                    if(!Trigger.isInsert && cs.AssetId != oldMap.get(cs.Id).AssetId){
                        AssetIds.add(oldMap.get(cs.Id).AssetId);        
                    }
                }
                if(String.isNotBlank(cs.OwnerId) && String.valueOf(cs.OwnerId).startswith('005')){
                    UserIds.add(cs.OwnerId);
                }
                if(String.isNotBlank(cs.Core_Case_Co_Owner__c) && String.valueOf(cs.Core_Case_Co_Owner__c).startswith('005')){
                    UserIds.add(cs.Core_Case_Co_Owner__c);        
                }
                if(String.isNotBlank(cs.createdbyId) && String.valueOf(cs.createdbyId).startswith('005')){
                    UserIds.add(cs.createdbyId);
                }
            }
            
        
	
	 if(!contactIds.isEmpty() && Core_Utility.executeQuery(new List<String>(ContactIds),oldRecIds.get('ContactID')) && Contact.SObjectType.getDescribe().isAccessible() ){
        
                GlobalContactRecords = new Map<Id,Contact>([Select Id, Core_Country_Region__c, Core_IPS_Embargoed_State__c, AccountId,Account.Core_CNDA_Number__c, Core_IPS_Intel_Support_Owner__c, Core_IPS_Alternate_Support_Owner__c, Core_IPS_Alternate_Support_Org__c From Contact where Id In: contactIds]);
            }
            //FLS Added as Part of code refactor
            if(Asset.SObjectType.getDescribe().isQueryable() && !AssetIds.isEmpty() && Core_Utility.executeQuery(new List<String>(AssetIds),oldRecIds.get('AssetID'))){
          
                GlobalAssetRecords = new Map<Id,Asset>([select id, name, core_supported_product__c, Core_Product_Organization__c,product2Id From Asset where Id in: AssetIds]); /***/
            }
            if( (!UserIds.isEmpty() || !ContactIds.isEmpty()) && (Core_Utility.executeQuery(new List<String>(ContactIds),oldRecIds.get('ContactID')) || (Core_Utility.executeQuery(new List<String>(UserIds),oldRecIds.get('UserID')))  )  ){
         
                GlobalUserRecords = new  Map<Id,User>([Select Id, ManagerId, Manager.ManagerId,Profile.Name, IsPortalEnabled , Name, ContactId, ProfileID,UserType From User where id in : UserIds or ContactId in : ContactIds]);
            }
            if(GlobalUserRecords!=null && GlobalUserRecords.size()>0){
                for(Id u : GlobalUserRecords.keySet()){
                    if(GlobalUserRecords.get(u).ContactId!=null){
                        GlobalContactUserIdMap.put(GlobalUserRecords.get(u).ContactId,u);
                    }
                }
            }
            if(!ContactIds.isEmpty()){
                oldRecIds.put('ContactID',new List<String>(ContactIds));
            }
            if(!AssetIds.isEmpty()){
                oldRecIds.put('AssetID',new List<String>(AssetIds));
            }
            if(!UserIds.isEmpty()){
                oldRecIds.put('UserID',new List<String>(UserIds));
            }
        } Catch (Exception Ex){
            System.debug('Core_IPS_CaseTriggerHandler.PrepareGlobalData Method Has Exception : '+ ex.GetMessage());
        }
    }
    // code Refactor Logic : 21-09-2024
    public static Boolean isQueryRequired(List<Id> Ids, Map<Id,SObject> mapData, Map<Id,Id> MapIds){
        try{
            Boolean isQueryRequired = false;
            if(Ids != null && !Ids.isEmpty()){
                for(Id value : Ids){
                    if(value != null && mapData != null && mapData.size()>0 && !mapData.containsKey(value)){
                        isQueryRequired = true;
                        break;
                    } 
                    else if(value != null && MapIds != null && MapIds.size()>0 && !MapIds.containsKey(value)){
                        isQueryRequired = true;
                        break;
                    } 
                }
            }
            return isQueryRequired;
        } Catch (Exception Ex){
            System.debug('Core_IPS_CaseTriggerHandler.isQueryRequired Method Has Exception : '+ ex.GetMessage());
            return false;
        }
    }
     
    // Added as part of code refactor
    public static void querySupportedProduct(List<Id> suppProductIdList){
        try {
            List<String> productIds = new List<String>();
            if(!suppProductIdList.isEmpty()){
                for(Id value : suppProductIdList){
                    productIds.add(value);
                }
                if(Core_Utility.executeQuery(productIds,oldProductIds) && Core_IPS_Supported_Product__c.SObjectType.getDescribe().isQueryable()){
                 
                    Core_IPS_CaseUtility.GlobalProductRecords = new Map<Id,Core_IPS_Supported_Product__c>([Select Id,Core_Flag_Status__c,Core_Code_Name__c,Core_EOIS__c,Core_Prod_EPM_Id__c,Core_Product__r.Core_Unique_ID__c,Core_Product__r.Core_Sales_Visible_Flag__c,Core_Product__r.Core_Hierarchy_ID__c, Core_Product__r.Core_Code_Name__c FROM Core_IPS_Supported_Product__c where Id in: suppProductIdList]);
                    oldProductIds = new List<String>(productIds);
                }
            }
        } Catch (Exception Ex){
            System.debug('Core_IPS_CaseTriggerHandler.querySupportedProduct Method Has Exception : '+ ex.GetMessage());
        }
    }
    
    // END - Code Refactor changes
}