public class Core_IPS_CaseTriggerHandler{
    /************************************************************************************************
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
****************************************************************************************************/  
            
    public static String newListStr;  
    public static String oldMapStr;
    public static Map<String,Id> mapProjProdOwner=new Map<String,Id>() ;
    public static Map<Id,Id> mapProjOwner = new Map<Id,Id>() ;
    public static Map<Id,Id> mapCaseAssetSupProd = new Map<Id,Id>() ;
    public static Set<Id> supportedProdIDs= new Set<Id>()  ;
    public static Set<Id> projIDs= new Set<Id>()  ;
    
    
    public static void executeCaseAssignmentRule(Map<Id,Case> oldMap,List<Case> newList){
        
        String isUpdate;
        String isInsert;
        newListStr = JSON.serialize(newList);
        oldMapStr= JSON.serialize(oldMap);
        //need to add a check for GEC and Backend Cases 09-24-2015
        if(Trigger.isInsert) {                                                   
            if(!String.isBlank(newListStr))           
                isInsert='insert';         
            //triggerAssignmentRuleAndProvideAccess(newListStr ,oldMapStr,isInsert) ; 
            if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('executeCaseAssignmentRule')){
                string ruleId = ((AssignmentRule)Database.query(System.Label.SOQL_Case_Assignment_Rule)).Id;
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.AssignmentRuleHeader.assignmentRuleId = ruleId;
                dmo.EmailHeader.triggerUserEmail = false;
                
                List<Case> cases = new List<Case>();
                
                assignProjectCasesOwner(newList);
                
                List<Case> caselist = [SELECT Id,RecordTypeId,OwnerId,Core_IPS_GEC_Status__c,ProductId,Asset.Core_Supported_Product__c,Core_IPS_Supported_Product__c,Core_IPS_Project_Case__c,Core_IPS_Project_Case__r.OwnerId,Core_IPS_Project_Case__r.Core_IPS_Private__c,Core_IPS_Private_Project__c,Core_Partner_Supported_Account__c from Case where Id in :newList];  
                //US257271 - added GEC recordtype to fix GEC routing
                Id GECRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();               
                for(Case cs : caselist) {
                    String caseKey = (cs.Core_IPS_Supported_Product__c==null ? String.valueOf(cs.Asset.Core_Supported_Product__c) : String.valueOf(cs.Core_IPS_Supported_Product__c)) + 
                                     String.valueOf(cs.Core_IPS_Project_Case__c);
                    
                    //US257271 - added GEC recordtype to fix GEC routing
                    System.debug('Inside executeCaseAssignmentRule ***********'+mapProjProdOwner+'<-cs.Core_IPS_Project_Case__r.Core_IPS_Private__c->'+cs.Core_IPS_Project_Case__r.Core_IPS_Private__c+'<--cs.RecordTypeId-->'+cs.RecordTypeId);
                    if(mapProjProdOwner !=null && mapProjProdOwner.containsKey(caseKey) && cs.RecordTypeId!=GECRecordTypeId){  
                        cs.OwnerId=mapProjProdOwner.get(caseKey);
                    } else if(mapProjProdOwner !=null && mapProjProdOwner.containsKey(cs.Core_IPS_Project_Case__c) && cs.Core_IPS_Project_Case__r.Core_IPS_Private__c && cs.RecordTypeId!=GECRecordTypeId ) {                           
                        cs.OwnerId = cs.Core_IPS_Project_Case__r.OwnerId;
                    } else { 
                        cs.setOptions(dmo);
                    }
                    cases.add(cs);
                }
                
                if(!cases.isempty())
                Database.update(cases);
                
             }
            
             triggerAssignmentRuleAndProvideAccess(newListStr ,oldMapStr,isInsert) ;
            
        }else if(trigger.isUpdate){   
            isUpdate='update';
            if(!String.isBlank(newListStr)){
                triggerAssignmentRuleAndProvideAccess(newListStr ,oldMapStr,isUpdate);
            }
        }
    }
    
    @future
    public static void triggerAssignmentRuleAndProvideAccess(String strcaseList,String oldMap,String triggerAction){   
        List<Case> newCaseList = (List<Case>)JSON.deserialize(strcaseList, List<Case>.class);
        Map<id,Case> OldCaseMap = (Map<id,Case>)JSON.deserialize(oldMap, Map<id,Case>.class);
        List<case> cases; 
        if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('executeCaseAssignmentRule')){ 
            string ruleId = ((AssignmentRule)Database.query(System.Label.SOQL_Case_Assignment_Rule)).Id;
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.AssignmentRuleHeader.assignmentRuleId = ruleId;
            dmo.EmailHeader.triggerUserEmail = false;
            if(triggerAction=='update'){
                assignProjectCasesOwner(newCaseList);
                
                cases = new List<Case>();  
                List<Case> caseList= [select id,OwnerId,Core_IPS_GEC_Status__c,ProductId,Core_IPS_Supported_Product__c,Asset.Core_Supported_Product__c,Core_IPS_Project_Case__c,Core_IPS_Project_Case__r.OwnerId,Core_IPS_Private_Project__c,Core_Partner_Supported_Account__c from Case where Id in : newCaseList];
                for(case cs: caseList){
                    String caseKey = (cs.Core_IPS_Supported_Product__c==null ? String.valueOf(cs.Asset.Core_Supported_Product__c) : String.valueOf(cs.Core_IPS_Supported_Product__c)) + 
                                     String.valueOf(cs.Core_IPS_Project_Case__c);
                    //added to future for email issue US257271
                    if(OldCaseMap.get(cs.id).productid != cs.productid|| OldCaseMap.get(cs.id).Core_IPS_Supported_Product__c != cs.Core_IPS_Supported_Product__c || OldCaseMap.get(cs.id).assetId != cs.AssetId  || (OldCaseMap.get(cs.id).Core_IPS_GEC_Status__c != cs.Core_IPS_GEC_Status__c && (cs.Core_IPS_GEC_Status__c == Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved')||cs.Core_IPS_GEC_Status__c == Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved_WithG')))){
                        if(mapProjProdOwner !=null && mapProjProdOwner.containsKey(caseKey)){  cs.OwnerId=mapProjProdOwner.get(caseKey); cases.add(cs);
                            
                        } else if(mapProjProdOwner !=null && mapProjProdOwner.containsKey(cs.Core_IPS_Project_Case__c) && cs.Core_IPS_Private_Project__c){
                            cs.OwnerId = mapProjProdOwner.get(cs.Core_IPS_Project_Case__c); cases.add(cs);
                            
                        }
                }
                    //DE31600 - Defect fix by Ajay - Added 'Approved with Guardials' condition.
                    if(!cs.Core_IPS_Private_Project__c && (mapProjProdOwner ==null || !mapProjProdOwner.containsKey(caseKey) ) && (OldCaseMap.get(cs.id).productid != cs.productid|| OldCaseMap.get(cs.id).Core_Partner_Supported_Account__c != cs.Core_Partner_Supported_Account__c ||(OldCaseMap.get(cs.id).Core_IPS_GEC_Status__c!=cs.Core_IPS_GEC_Status__c && (cs.Core_IPS_GEC_Status__c == Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved')||cs.Core_IPS_GEC_Status__c == Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved_WithG') )) || cs.Core_IPS_Supported_Product__c != OldCaseMap.get(cs.id).Core_IPS_Supported_Product__c )){
                        cs.setOptions(dmo);
                        cases.add(cs);
                    }
                }
                if (cases.size() > 0) {
                    Database.update(cases);
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
*Karthick                    07-02-2018             Modified - STOP SLA for customer actions,close pedning and deferred state
****************************************************************************************************/  
    public static User caseSLAManagement_userResult;
    public static void caseSLAManagement(Map<Id,Case> oldMap, List<case> newList)
    {
        if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('caseSLAManagement'))
            return;
        
        System.debug('#81 Starting caseSLAManagement, trigger.isUpdate: ' + trigger.isUpdate + '  trigger.isInsert: ' + trigger.isInsert);
        
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
                        //cs.Core_Next_Response_Due_Date__c = milestoneutils.getSetNextResponseDueDate(cs);
                    }
                }
            }
            
            
            milestoneUtils.AddCaseBizHoursOnOwnerUpdate(oldMap, newList);
            
            System.debug('-------caseSLAManagement_userResult ::'+caseSLAManagement_userResult);
            System.debug('-------userInfo.getUserId() ::'+userInfo.getUserId());
            
            if(caseSLAManagement_userResult == null)
                caseSLAManagement_userResult = [SELECT Id, IsPortalEnabled 
                                                FROM user 
                                                WHERE id = :userInfo.getUserId() 
                                                LIMIT 1];
            
            Set<Id> caseIds = new Set<Id>();
            for (Case cs : newList) {
                if (!caseIds.contains(cs.Id))
                    caseIds.add(cs.Id);            
            }
            
            List<AggregateResult> lstAggregateResult = [SELECT caseId, MAX(startDate) maxStartDate
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
            
            List<CaseMilestone> lstCaseMilestone = [SELECT Id, caseId, startDate, completionDate
                                                    FROM CaseMilestone 
                                                    WHERE caseId IN :caseIds 
                                                    AND completionDate = null];
            
            Map<Id, CaseMilestone> mapCaseMilestone = new Map<Id, CaseMilestone>();
            for (CaseMilestone cm : lstCaseMilestone) {
                if (!mapCaseMilestone.keyset().contains(cm.caseId))    mapCaseMilestone.put(cm.caseId, cm);        
            }                
            
            CaseMilestone objCaseMilestone;
            List<CaseMileStone> lstUpdateCaseMilestone = new List<CaseMilestone>();
            
            for (Case cs:newList)
            {            
                // BM 7/31
                objCaseMilestone = mapCaseMilestone.get(cs.Id);
                maxStartDate     = mapMaxStartDate.get(cs.Id);
                
                Boolean changedNRDD  = (oldMap.get(cs.Id).Core_Next_Response_Due_Date__c != cs.Core_Next_Response_Due_Date__c);
                if (maxStartDate != NULL && changedNRDD) 
                {                
                    try {                
                        System.debug('#70 oldMap.get(cs.Id).Core_Next_Response_Due_Date__c: ' + oldMap.get(cs.Id).Core_Next_Response_Due_Date__c +  
                                     '    cs.Core_Next_Response_Due_Date__c: ' + cs.Core_Next_Response_Due_Date__c + 
                                     '    maxStartDate: ' + maxStartDate + 
                                     '    cs.Core_Sub_Status__c: ' + cs.Core_Sub_Status__c);
                    } catch (Exception e) {   System.debug('#70.1 Exception e.getMessage(): ' + e.getMessage());     }
                    
                    if (cs.Core_Next_Response_Due_Date__c < maxStartDate) {
                        String strStartDate = maxStartDate.format('MM-dd-YY HH:mm:ss z');
                        cs.addError('The Next Response Due Date must be after the most recent Milestone Start Date: ' + strStartDate);
                        System.debug('#71 NRDD ERROR ' + 
                                     '    oldMap.get(cs.Id).Core_Next_Response_Due_Date__c: ' + oldMap.get(cs.Id).Core_Next_Response_Due_Date__c +  
                                     '    cs.Core_Next_Response_Due_Date__c: ' + cs.Core_Next_Response_Due_Date__c + 
                                     '    maxStartDate: ' + maxStartDate + 
                                     '    strStartDate: ' + strStartDate + 
                                     '    cs.Core_Sub_Status__c: ' + cs.Core_Sub_Status__c);
                    }
                }
                
                if (cs.Core_Sub_Status__c == NULL)
                    continue;
                
                // DEFECT DE10222 IPS case milestones no longer need to be stopped
                // Complete milestone
                
                //Added by Karthick - US92741 -Release 4
                //Set<string> subStatusSet = new Set<String>();        
                //subStatusSet.addAll(Label.Core_IPS_Case_Stop_SLA.split(','));                
                
                if( String.isNotBlank(cs.Core_Sub_Status__c) && subStatusSet.contains(cs.Core_Sub_Status__c)){
                    
                    if(!caseSLAManagement_userResult.isPortalEnabled)
                    {
                        objCaseMilestone = mapCaseMilestone.get(cs.Id);
                        if (objCaseMilestone <> null) {
                            objCaseMilestone.completionDate = System.now();                            
                            
                            System.debug('Complete DATE : ' + System.now());
                            lstUpdateCaseMilestone.add(objCaseMilestone);
                        }
                    }
                }
                
                if(!cs.isStopped)
                {
                    if(cs.recordTypeId==Core_IPS_Helper_Utility.getIPSLabel('GEC Record Type Id'))
                        milestoneUtils.stopMilestoneClockWhenAwaitingCustomerResponse(cs);
                }
                else if((oldMap.get(cs.Id).recordTypeId==Core_IPS_Helper_Utility.getIPSLabel('GEC Record Type Id'))) 
                {  milestoneUtils.reStartMilestoneClockWhenCustomerresponded(cs); }
                
            }            
            
            if (lstUpdateCaseMilestone.size() > 0) { update lstUpdateCaseMilestone;   }            
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
****************************************************************************************************/      
    public static void assignCaseInformation(List<case> newList, Map<Id,Case> oldMap, Boolean isMigrationUser){
        //system.debug('assignCaseInformation ===newList==>'+newList);
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('assignCaseInformation'))
            return;
        List<Case> refCaseList = new List<Case>();//US225807
        system.debug('#51 Starting assignCaseInformation');
        Set<String> contIdSet = new Set<String>();
        Set<String> assetIdSet = new Set<String>();
        Set<String> suppProdIdSet = new Set<String>();
        Set<Id> setProjectId = new Set<Id>(); //added for US137508
        
        Map<Id,Id> intelSupportOwnersByContact = new Map<Id,Id>();
        
        Map<Id, Group> mapGroupById;        // Leave this NULL!  Don't make this static or global.
        Map<String, Group> mapGroupByName;  // Leave this NULL!  Don't make this static or global.
        
        for(Case cs:newList){
            
            //Updating Supported Contact for all the cases 
            if(cs.ContactId!=null) {
                    cs.Core_IPS_Supported_Contact__c = cs.ContactId;                       
            }
            contIdSet.add(cs.Core_IPS_Supported_Contact__c); //US221486-Gourav: Updated Core_IPS_Supported_Contact__c
            assetIdSet.add(cs.assetId);
            
            //system.debug('#52 cs.Core_IPS_Supported_Product__c: ' + cs.Core_IPS_Supported_Product__c);
            suppProdIdSet.add(cs.Core_IPS_Supported_Product__c);
            if(cs.Core_IPS_Project_Case__c!=null) setProjectId.add(cs.Core_IPS_Project_Case__c); // added for US137508 
            if(oldMap!=null && oldMap.get(cs.Id).Core_IPS_Project_Case__c!=null) setProjectId.add(oldMap.get(cs.Id).Core_IPS_Project_Case__c); // added for US137508 
        }
        
        intelSupportOwnersByContact=Core_IPS_Helper_Utility.getIntelSupportOwnerByContact(contIdSet);
        Map<Id,Core_IPS_CaseInformation> caseInfoByAsset     = getCaseInformationByAssetOrSuppProd(assetIdSet,isMigrationUser);
        Map<Id,Core_IPS_CaseInformation> caseInfoBySuppProd  = getCaseInformationByAssetOrSuppProd(suppProdIdSet,isMigrationUser);
        Map<Id,Core_IPS_CaseInformation> caseInfoByCatSubCat = getCaseInfoByCatSubCat(newList);             
        
        boolean isLoggeInUserMigrationUser   = Core_IPS_CaseTriggerHandler.isMigrationUser(string.valueof(userinfo.getuserId()));
        boolean isLoggeInUserIntegrationUser = Core_IPS_Case_Comments_Handler.isIntegrationUser(string.valueof(userinfo.getuserId())); 
        
        //Modified byUS221486 Gourav-for Supported Contact
        Map<Id,Contact> mapIdToContact = new Map<Id,Contact>(Core_IPS_Helper_Utility.getIntelSupportOwnerByContact_ResultList); // added by Sugandha
        
        //added for US137508
        Map<Id,Core_Ips_Project__c> projectMap = new Map<Id,Core_Ips_Project__c>();
        if(setProjectId.size()>0)
            projectMap = new Map<Id,Core_Ips_Project__c>([Select Id,Core_IPS_Intel_Support_Owner__c from Core_Ips_Project__c where Id IN :setProjectId]);
                
        for(Case cs:newList){
            //system.debug('comes here 1>>>>>>>>');            
                        
            if(caseInfoByAsset.get(cs.assetId)!=null){
                cs.Core_IPS_Supported_Product__c = caseInfoByAsset.get(cs.assetId).supportedProduct;
                cs.Core_IPS_Product_Org1__c = caseInfoByAsset.get(cs.assetId).prodOrg;
                cs.Core_IPS_product_name__c =caseInfoByAsset.get(cs.assetId).prodName;
                cs.productId = caseInfoByAsset.get(cs.assetId).productId;
                
                If(cs <> null && cs.assetId <> null && caseInfoByAsset <> null && caseInfoByAsset.size() > 0 && caseInfoByAsset.get(cs.assetId) <> null && caseInfoByAsset.get(cs.assetId).codeName <> null && caseInfoByAsset.get(cs.assetId).codeName <> '')
                    cs.Core_Code_Name__c = caseInfoByAsset.get(cs.assetId).codeName;
                else
                    cs.Core_Code_Name__c = '';
                
                If(cs <> null && cs.assetId <> null && caseInfoByAsset <> null && caseInfoByAsset.size() > 0 && caseInfoByAsset.get(cs.assetId) <> null && caseInfoByAsset.get(cs.assetId).productType <> null && caseInfoByAsset.get(cs.assetId).productType <> '')
                    cs.Core_Product_Type__c = caseInfoByAsset.get(cs.assetId).productType;
            }
            
            if(caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c)!=null){
                cs.Core_IPS_Supported_Product__c = caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).supportedProduct;
                cs.Core_IPS_Product_Org1__c = caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).prodOrg;
                cs.Core_IPS_product_name__c = caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).prodName;
                cs.productId = caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).productId;
                If(cs <> null && cs.Core_IPS_Supported_Product__c <> null && caseInfoBySuppProd <> null && caseInfoBySuppProd.size() > 0 && caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c) <> null && caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).codeName <> null && caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).codeName <> '')                    
                    cs.Core_Code_Name__c = caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).codeName;
                else
                    cs.Core_Code_Name__c = '';
                If(cs <> null && cs.Core_IPS_Supported_Product__c <> null && caseInfoBySuppProd <> null && caseInfoBySuppProd.size() > 0 && caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c) <> null && caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).productType <> null && caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).productType <> '')                    
                    cs.Core_Product_Type__c = caseInfoBySuppProd.get(cs.Core_IPS_Supported_Product__c).productType;                    
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
            
            //System.debug('----cs.Core_External_Issue_Category__c ::'+cs.Core_External_Issue_Category__c);
            //System.debug('----cs.Core_External_Issue_Subcategory__c ::'+cs.Core_External_Issue_Subcategory__c );
            
            //cs.Core_Issue_Description__c = Core_Utility.addBreaktags(cs.Core_Issue_Description__c);
            if((trigger.isinsert && cs.Core_Issue_Description__c <> null) ||( trigger.isupdate && oldMap.get(cs.Id).Core_Issue_Description__c <> null && cs.Core_Issue_Description__c <> null && oldMap.get(cs.Id).Core_Issue_Description__c <> cs.Core_Issue_Description__c )){
                //system.debug('comes here 1>>>>>>>>');
                //system.debug('Rich Text Input&&&&&&&&&&&&&&&&&'+cs.Core_Issue_Description__c);
                
                string  strDescValue = Core_Utility.substituteHTMLTags(cs.Core_Issue_Description__c);//replaceHtmlTagsCase
                //system.debug('custom setting change&&&&&&&&&&&&&&&&&'+strDescValue);
                
                cs.Description =  Core_Utility.stripandunescapeHtmlTags(strDescValue);//replaceSpecialChar  
                //system.debug('Final op&&&&&&&&&&&&'+cs.Description);
                
                //Updated by 11765018 ( Sourabh) : Added custom setting check here For DM and Integ users. Date : 9 feb 2018 
                /*if(Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for DM') != null && Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for DM').Core_Feature_Enabled__c && isLoggeInUserMigrationUser )
                    cs.Core_Issue_Description__c = Core_Utility.addBreaktags(cs.Core_Issue_Description__c);
                    if(Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for Integ User') != null && Core_IPS_Feature_Toggle__c.getValues('SkyHighEOL- RTF update for Integ User').Core_Feature_Enabled__c && isLoggeInUserIntegrationUser) */
                if(isLoggeInUserMigrationUser || isLoggeInUserIntegrationUser)  
                    cs.Core_Issue_Description__c = Core_Utility.addBreaktags(cs.Core_Issue_Description__c);
                
                //if(isLoggeInUserMigrationUser || isLoggeInUserIntegrationUser)
                //cs.Core_Issue_Description__c = Core_Utility.addBreaktags(cs.Core_Issue_Description__c);
            }
            system.debug('#61 Rich Text>>>>>>>>>>' + cs.Core_Issue_Description__c );         
            //[START : 02/03/2016 : Assigning the Field Updates.]
            
            // Core IPS Case Non-SA Assigned
            // **For a case re-open, cs.Core_IPS_Self_Assigned__c will be set back to true, in another conditional.
            // Commented condition for US235077
           /* if(cs.RecordTypeId != Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS No Assigned Contact Case') && cs.Core_IPS_Self_Assigned__c == true && !isLoggeInUserMigrationUser){
                cs.Core_IPS_Self_Assigned__c = false;
                //system.debug('#62 cs.Core_IPS_Self_Assigned__c: ' + cs.Core_IPS_Self_Assigned__c);
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
                //system.debug('#63 cs.Core_IPS_Self_Assigned__c: ' + cs.Core_IPS_Self_Assigned__c);
            }
            //Core IPS GEC Flow Changes
            system.debug('>>>>>>>>>>>>>>>>>Core IPS GEC Flow Changes');
           
            
            if((oldMap == null && cs.Core_IPS_GEC_Case__c) || (oldMap <> null && oldMap.get(cs.Id).Core_IPS_GEC_Case__c <> cs.Core_IPS_GEC_Case__c && cs.Core_IPS_GEC_Case__c)){
                
                system.debug('#########'+Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS GEC ReadOnly'));
                cs.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS GEC ReadOnly');
                
                // Add to map IF it isn't already in the map  
                mapGroupByName = loadGroupByName(System.Label.Core_IPS_GEC_Queue_DeveloperName, mapGroupByName);
                Group objGroup = mapGroupByName.get(System.Label.Core_IPS_GEC_Queue_DeveloperName);
                if (objGroup != NULL)        
                    //cs.OwnerId = objGroup.Id;   //'00G21000000MQ54';   //'GEC Case Queue';
                    
                cs.Status = 'On Hold';
                cs.Core_IPS_GEC_Request_Status__c = 'MAG Questionnaire Required';
                cs.Core_Sub_Status__c = 'GEC Hold';
              
            }
            
            //Added the below condition for resetting Compliance Status for GEC Cases-US185521(Iteration:19)
            if(oldMap!=null && oldMap.get(cs.id).RecordTypeId != cs.RecordTypeId && cs.RecordTypeId == Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS GEC ReadOnly'))
            {
               system.debug('<><><><><>' +oldMap.get(cs.id).RecordType.Name +cs.RecordType.Name);
               cs.Core_IPS_GEC_Status__c = '';
               
             }
           //end

          
                       
            //Core IPS GEC Flow Changes
            //(Case: Military, Aerospace, or Gov’mt End UseequalsTrue) and (Case: Is Notification ActiveequalsTrue) and (Case: Case Record TypeequalsIPS No Assigned Contact Case,IPS Case Create,IPS Closed Case,IPS GEC ReadOnly)                 
            
            //Core IPS GEC Status For Approved
            //added by Abhishek Rajput for "Approved with Guardrails" condition on 28/07/2016 -- US37717 
            //Modified By: Neeti Jain(DE33336) to bypass this condition for migration user
            if((!isLoggeInUserMigrationUser &&(oldMap == null && (cs.Core_IPS_GEC_Status__c == 'Approved' || cs.Core_IPS_GEC_Status__c == 'Approved with Guardrails') && (cs.Core_IPS_GEC_Flag__c || cs.Core_IPS_GEC_Case__c)) || (oldMap!=null && (oldMap.get(cs.Id).Core_IPS_GEC_Status__c  <> cs.Core_IPS_GEC_Status__c || oldMap.get(cs.Id).Core_IPS_GEC_Flag__c  <> cs.Core_IPS_GEC_Flag__c || oldMap.get(cs.Id).Core_IPS_GEC_Case__c <> cs.Core_IPS_GEC_Case__c) && (cs.Core_IPS_GEC_Status__c == 'Approved' || cs.Core_IPS_GEC_Status__c == 'Approved with Guardrails') &&  (cs.Core_IPS_GEC_Flag__c || cs.Core_IPS_GEC_Case__c)))){
                
                cs.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS Case Create');
                cs.IsStopped = false;
                cs.Core_Sub_Status__c = '';
                cs.Status = 'New';
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
                cs.Core_IPS_GEC_Request_Status__c = 'MAG Questionnaire Required';
                cs.Core_Sub_Status__c = 'GEC Hold';
            }
            system.debug('>>>>>>>>>>>>>>>>>>>> Core IPS Update case Origin for Customers OUT');
            //Core_IPS_CaseClose_RecTypeChange
            //(Case: StatusequalsClosed) and (Case: Case Record TypeequalsIPS No Assigned Contact Case,IPS Case Create,IPS GEC ReadOnly,IPS Case Read Only) 
            if((Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId)=='IPS No Assigned Contact Case' || Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId)=='IPS Case Create' || Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId)=='IPS Case Read Only') && ((oldMap == null && Cs.status=='Closed') ||(oldMap != null && oldMap.get(cs.Id).status <> Cs.status && Cs.status=='Closed'))){              
                //system.debug('>>>>>>>>>>>>>>>>>>>> Inside 455');
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
                cs.Core_Sub_Status__c = 'Customer Requesting Close*'; cs.Status = 'Open';
            }
            //Core_IPS_UpdateCloseCaseRecordtype
            //AND(RecordType.DeveloperName = 'IPS_Closed_Case',ISPICKVAL(PRIORVALUE(Status), 'Closed'),NOT(ISPICKVAL(Status,'Closed')) ,OR(ContactId=null,ContactId=''))
            //modified by Gourav Core_IPS_Supported_Contact__c  US221486
            if(oldMap !=null && cs.Core_IPS_Supported_Contact__c == null && oldMap.get(cs.id).status == 'Closed' && cs.status <> 'Closed'  && Core_IPS_CaseTriggerHandler.getCaseRecordtypeNameById(cs.RecordTypeId)=='IPS Closed Case'){
                cs.recordtypeID = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName('IPS No Assigned Contact Case');
                
                // ***BM 6/20 - A change to No Assigned Contact recordType should also set the flag.
                //  
                cs.Core_IPS_Self_Assigned__c = true;  
                //system.debug('#64 cs.Core_IPS_Self_Assigned__c: ' + cs.Core_IPS_Self_Assigned__c);
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
        //System.debug('---getCaseInfoByCatSubCat ===>'+caseList);
        //Added by Geetha as per  DE33659
        Set<Id> setCaseCategoryId= new Set<Id>();        
        for(Case cs:caseList){
            if(cs.Core_Case_Issue_Category__c!=null){
                setCaseCategoryId.add(cs.Core_Case_Issue_Category__c); 
                setCaseCategoryId.add(cs.Core_Case_Issue_Sub_Category__c); 
            }
        }
        System.debug('---setCaseCategoryId===>'+setCaseCategoryId);
        Map<id,Core_IPS_Product_Issue_Category__c> mapCaseCategory = new map<Id,Core_IPS_Product_Issue_Category__c>(
            [Select Id,name,Core_Issue_Sub_Category_Name__c,Core_Issue_Sub_Category_Name__r.name,Core_Issue_Category_Name__c,Core_Issue_Category_Name__r.Name FROM Core_IPS_Product_Issue_Category__c WHERE Id in:setCaseCategoryId ]);
        Map<Id,Core_IPS_CaseInformation> caseDetailsByCatSubCat = new Map<Id,Core_IPS_CaseInformation>();
        //System.debug('---mapCaseCategory ===>'+mapCaseCategory );
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
        System.debug('---caseDetailsByCatSubCat ===>'+caseDetailsByCatSubCat );
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
    public static List<Asset> getCaseInformationByAsset_ResultList;
    public static List<Core_IPS_Supported_Product__c> getCaseInformationBySuppProd_ResultList;    
    public static List<String> getCaseInformationByAsset_oldContIdList = new List<String>();
    public static List<String> getCaseInformationBySuppProd_oldContIdList = new List<String>();
    public static List<String> getCaseInformationByAssetOrSuppProd_newContIdList = new List<String>();
    private static Map<Id,Core_IPS_CaseInformation> getCaseInformationByAssetOrSuppProd(Set<String> idSet,Boolean isMigrationUser){
        Map<Id,Core_IPS_CaseInformation> caseDetailsById = new Map<Id,Core_IPS_CaseInformation>();
        //List<Asset> assetList = new List<Asset>();
        //List<core_IPS_supported_product__c> suppProdList = new List<core_IPS_supported_product__c>();
        if(idSet <> null && idSet.size() > 0){
            getCaseInformationByAssetOrSuppProd_newContIdList.clear();
            getCaseInformationByAssetOrSuppProd_newContIdList.addAll(idSet);
            system.debug(getCaseInformationByAssetOrSuppProd_newContIdList);
            if(getCaseInformationByAsset_ResultList == null || Core_Utility.executeQuery(getCaseInformationByAssetOrSuppProd_newContIdList,getCaseInformationByAsset_oldContIdList))
            {
                system.debug(getCaseInformationByAssetOrSuppProd_newContIdList);
                getCaseInformationByAsset_ResultList = [select id, name,core_supported_product__c,product2Id, Core_Product_Organization__c from asset where id in:idSet];
                getCaseInformationByAsset_oldContIdList.clear();
                getCaseInformationByAsset_oldContIdList.addAll(idSet);
                system.debug(getCaseInformationByAsset_oldContIdList);                    
            }
            if(getCaseInformationBySuppProd_ResultList == null || Core_Utility.executeQuery(getCaseInformationByAssetOrSuppProd_newContIdList,getCaseInformationBySuppProd_oldContIdList))
            {
                system.debug(getCaseInformationByAssetOrSuppProd_newContIdList);
                getCaseInformationBySuppProd_ResultList = [select id,Core_Supported_Product_Name__c, Name,Core_Product_Organization__c,Core_Product__c,Core_Product__r.name from core_IPS_supported_product__c where id in:idSet];
                getCaseInformationBySuppProd_oldContIdList.clear();
                getCaseInformationBySuppProd_oldContIdList.addAll(idSet);
                system.debug(getCaseInformationBySuppProd_oldContIdList);                    
            }
        }
        
        //assetList = [select id, name,core_supported_product__c,product2Id, Core_Product_Organization__c from asset where id in:idSet];
        //suppProdList = [select id,Core_Supported_Product_Name__c, Name,Core_Product_Organization__c,Core_Product__c,Core_Product__r.name from core_IPS_supported_product__c where id in:idSet];        
        List<Id> suppProdIdList;
        Map<String,String> suppProdIdCodeNameMap;
        Map<String,Set<String>> vphSuppProdIdProdTypeMap;
        Map<String,Set<String>> vplhSuppProdIdProdTypeMap;
        if(getCaseInformationByAsset_ResultList <> null && getCaseInformationByAsset_ResultList.size() > 0){
            suppProdIdCodeNameMap = new Map<String,String>();
            vphSuppProdIdProdTypeMap = new Map<String,Set<String>>();
            vplhSuppProdIdProdTypeMap = new Map<String,Set<String>>();
            suppProdIdList = new List<Id>();            
            for(Asset asset:getCaseInformationByAsset_ResultList){
                suppProdIdList.add(asset.core_supported_product__c);
            }
            suppProdIdCodeNameMap = Core_IPS_CaseUtility.getCodeName(suppProdIdList);
            //Commented by JP for data migration
            if(isMigrationUser == false){
                vphSuppProdIdProdTypeMap = Core_IPS_CaseUtility.getVPHProductType(suppProdIdList);
                vplhSuppProdIdProdTypeMap = Core_IPS_CaseUtility.getVPLHProductType(suppProdIdList);
            }
            for(Asset asset:getCaseInformationByAsset_ResultList){
                Core_IPS_CaseInformation CaseInfo = new Core_IPS_CaseInformation();
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
                        if(vphProdTypes == '')
                            vphProdTypes = prodString;           
                        else
                            vphProdTypes = vphProdTypes + ',' +' '+ prodString;    
                    }
                    CaseInfo.productType = vphProdTypes;
                }
                If(vplhSuppProdIdProdTypeMap <> null && vplhSuppProdIdProdTypeMap.size() > 0 && vplhSuppProdIdProdTypeMap.get(asset.core_supported_product__c) <> null){
                    String vplhProdTypes = '';
                    for(String prodString : vplhSuppProdIdProdTypeMap.get(asset.core_supported_product__c)){
                        if(vplhProdTypes == '')
                            vplhProdTypes = prodString;           
                        else
                            vplhProdTypes = vplhProdTypes + ',' +' '+ prodString;    
                    }
                    CaseInfo.productType = vplhProdTypes;                    
                }                
                caseDetailsById.put(asset.Id,CaseInfo);
            }
        }
        if(getCaseInformationBySuppProd_ResultList <> null && getCaseInformationBySuppProd_ResultList.size() > 0){
            suppProdIdCodeNameMap = new Map<String,String>();
            vphSuppProdIdProdTypeMap = new Map<String,Set<String>>();
            vplhSuppProdIdProdTypeMap = new Map<String,Set<String>>();
            suppProdIdList = new List<Id>();
            for(core_IPS_supported_product__c suppProdObj:getCaseInformationBySuppProd_ResultList){
                suppProdIdList.add(suppProdObj.Id);
            }
            suppProdIdCodeNameMap = Core_IPS_CaseUtility.getCodeName(suppProdIdList);
            
            //Commented by JP for Data Migration
            if(isMigrationUser == false){
                vphSuppProdIdProdTypeMap = Core_IPS_CaseUtility.getVPHProductType(suppProdIdList);
                vplhSuppProdIdProdTypeMap = Core_IPS_CaseUtility.getVPLHProductType(suppProdIdList);
            }
            for(core_IPS_supported_product__c suppProdObj:getCaseInformationBySuppProd_ResultList){
                Core_IPS_CaseInformation CaseInfo = new Core_IPS_CaseInformation();
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
                        if(vphProdTypes == '')
                            vphProdTypes = prodString;           
                        else
                            vphProdTypes = vphProdTypes + ',' +' '+ prodString;    
                    }
                    CaseInfo.productType = vphProdTypes;
                }
                If(vplhSuppProdIdProdTypeMap <> null && vplhSuppProdIdProdTypeMap.size() > 0 && vplhSuppProdIdProdTypeMap.get(suppProdObj.Id) <> null){
                    String vplhProdTypes = '';
                    for(String prodString : vplhSuppProdIdProdTypeMap.get(suppProdObj.Id)){
                        if(vplhProdTypes == '')
                            vplhProdTypes = prodString;           
                        else
                            vplhProdTypes = vplhProdTypes + ',' +' '+ prodString;    
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
    public static List<Contact> contactResultList;
    
    public static List<String> oldContIdList = new List<String>();
    public static List<String> newContIdList = new List<String>();
    
    public static void assignEntitlementToCase(List<Case> newList){
       
        if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('assignEntitlementToCase')){
            set<string> contactIds = new set<string>();
            List<Id> acctIds = new List<Id>();
            Map<id,id> MapAccountEntitlement =  new Map<id,Id>();
           
            for (Case c: newList){
                if (c.EntitlementId == null && c.Core_IPS_Supported_Contact__c!= null ){  /* c.ContactId !=null added by sumukh for US221512 && c.AccountId!= null*/
                    contactIds.add(c.Core_IPS_Supported_Contact__c); // {c.ContactId} added by sumukh for US221512
                    //acctIds.add(c.AccountId);
                   }
              }
            
            if(contactIds <> null && contactIds.size() > 0){
                newContIdList.clear();
                newContIdList.addAll(contactIds);
                system.debug('@@@@@@@'+newContIdList);
                if(contactResultList == null || Core_Utility.executeQuery(newContIdList,oldContIdList))
                  {
                    system.debug('@@@@######@@@'+newContIdList);
                    contactResultList = [select id,accountid from Contact where id in :contactIds];
                    oldContIdList.clear();
                    oldContIdList.addAll(contactIds);
                    system.debug(oldContIdList);                    
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
                List <Entitlement> entls = [Select e.StartDate, e.Id, e.EndDate, e.AccountId, e.AssetId From Entitlement e Where e.AccountId in:acctIds And e.EndDate >= Today And e.StartDate <= Today];
                if(entls.isEmpty()==false){
                    for(Case c: newList){
                        if(c.EntitlementId == null && mapContact.containskey(c.Core_IPS_Supported_Contact__c)){ // c.EntitlementId == null && c.AccountId!= null -- Changes made by sumukh for US221512
                            for(Entitlement e:entls){
                                if(e.AccountId == mapContact.get(c.Core_IPS_Supported_Contact__c).AccountId){ //  (e.AccountId==c.AccountId) Changes made by sumukh for US221512
                                    c.EntitlementId = e.Id;
                                    if(c.AssetId==null && e.AssetId!=null)
                                        c.AssetId=e.AssetId;
                                    break;}
                            } // end for
                        }
                    } // end for
                }
            }
            
            else{   
                //Any case without a contact or account is assigned to a default entitlement
                for(Case cs:newList){
                    if(cs.entitlementId==null){ cs.entitlementId=Core_IPS_Helper_Utility.getIPSLabel('SelfAssignedCaseEntitlementId'); }
                }
            }
        }else{     }
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
            List<Id> caseIds = new List<Id>();
            Set<Id> acctIdSet = new Set<Id>();
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
            system.debug('+++++++++++++++++++++++++++++++++++++++provideCaseAccessToCreatedFAE');
            //Core_SharingUtility.provideAccess('Case','CaseShare','Edit',createdByUsersByCase);// commented by becuase execute syncronusly
            
            /****** added by venki 06/05/17 to excute asynorously to provide case sharing********/
            string caserecords=JSON.serialize(createdByUsersByCase);
            /* Added By Neeti Jain on 9/1/2018, US91031*/
            /*Added for bypassing the future method for DM cases in batch mode*/
            if(!system.isBatch())
                ProvideCaseAccessatFuture(caserecords);// end 
            
            //System.debug('Tuesday Testing2:'+caseList+'UserIds:'+userIds);
        }else{  }
    }
    public static string Userid;
    public static List<Profile> LstProfile {get;set;}
    public static Boolean isMigrationUser(string strUserId)
    {        
        
        system.debug(Userid+'==null || ' + UserId +'!=' + strUserId);
        if(Userid==null || UserId !=strUserId )
        {
            LstProfile =  new List<Profile>([select id,name from Profile where id = : Userinfo.getProfileId() and name =: 'IPS Data Migration']); 
            UserId = strUserId;
            if( LstProfile.size() > 0 )
            {
                
                return true;
                
            }        
        }
        else if(UserId == strUserId && LstProfile.size() > 0)
        {
            return true;
        }
        else
        {
            return false;
        }
        return false;              
    }
    
    public static void assignMigratedCaseInformation(List<case> LstNewCase)
    {
        
        Map<String,Case> AsstMap = new Map<String,Case>();         
        Set<Id> SetContactID =  new Set<Id>();
        Map<Id,Contact> MapContact ;
        
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>' + LstNewCase);
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
        if(SetContactID.size() > 0)
        {    
            MapContact =  new Map<Id,Contact>([Select id,AccountID from Contact where id in :SetContactID]);           
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
            Map<string,Asset> MapAssetForCase =  new Map<string,Asset>();
            for(Asset Ass : [Select id,accountid,Core_Product_Organization__c,Core_Supported_Product__c,Core_IPS_Project__c from Asset where (Core_IPS_Project__c in : getIds(AsstMap.keyset(),0) OR accountid in :getIds(AsstMap.keyset(),0)) and Core_Supported_Product__c in : getIds(AsstMap.keyset(),36) and Core_Product_Organization__c in : getIds(AsstMap.keyset(),18)])
            {
                if(Ass.Core_IPS_Project__c != null)
                {
                    MapAssetForCase.put(string.valueof(Ass.Core_IPS_Project__c) + string.valueof(Ass.Core_Product_Organization__c)  +  string.valueof(Ass.Core_Supported_Product__c),Ass);
                }
                else if(Ass.Accountid != null)
                {
                    MapAssetForCase.put(string.valueof(Ass.Accountid) + string.valueof(Ass.Core_Product_Organization__c)  +  string.valueof(Ass.Core_Supported_Product__c),Ass);
                }
            }           //assetMap.putAll(assetMap1);
            for(Case c : LstNewCase)
            {
                if(c.Core_IPS_Project_Case__c != null && c.Core_IPS_Product_Org1__c !=null && c.Core_IPS_Supported_Product__c!= null)
                {
                    
                    string strKey_Asset = string.valueof(c.Core_IPS_Project_Case__c) + string.valueof(c.Core_IPS_Product_Org1__c)  +  string.valueof(c.Core_IPS_Supported_Product__c) ;
                    if(MapAssetForCase.containsKey(strKey_Asset) )
                    {
                        c.AssetId = MapAssetForCase.get(strKey_Asset).id;
                    }
                }
                else if(c.AccountID != null && c.Core_IPS_Product_Org1__c !=null && c.Core_IPS_Supported_Product__c!= null) 
                {
                    
                    string strKey_Asset = string.valueof(c.AccountID) + string.valueof(c.Core_IPS_Product_Org1__c)  +  string.valueof(c.Core_IPS_Supported_Product__c) ;
                    if(MapAssetForCase.containsKey(strKey_Asset))
                    {
                        c.AssetId = MapAssetForCase.get(strKey_Asset).id;
                    }
                }
            }
        }      
        
    }
    public static List<Id> getIds(Set<String> keys,integer pos)
    {
        List<Id> idList = new List<Id>();
        for(String s : keys)
            idList.add(s.mid(pos,18));
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

        if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('ProvideCaseAccess')){
            if(newList <> null){
                Set<Id> accountIdSet = new Set<Id>();
                Set<Id> projectIdSet = new Set<Id>();
                List<Case> revokableProjectRelatedCaseList = new List<Case>();
                List<Case> revokableAccountRelatedCaseList = new List<Case>();
                System.debug('#######!!#######');                
                
                //[To get all RecordTypeIds on Case.]
                Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
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
                        caseContactIdsCustomerVisibleTrueSet.add(recCase.ContactId);  conIdCaseIdCVTrueMap.put(recCase.ContactId, recCase.Id);
                    }
                    
                    
                    //[Initializing the Boolean variable.]
                    isIPSRecordType = false;
                    
                    //[To check the IPS Cases.]
                    for(String recTypeName:System.Label.Core_IPS_Case_RecordType_Name.split(';')){
                        if(rt_Map <> null && rt_Map.get(recCase.RecordTypeId).getName() == recTypeName){
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
                            system.debug('#####1####');
                        }//[Scenario A : Project Based Case is changing to Account Based.]
                        
                        
                        if(recCase <> null && recCase.Core_IPS_Project_Case__c <> null && oldmap!=null && oldMap.get(recCase.Id) <> null && oldMap.get(recCase.Id).Core_IPS_Project_Case__c <> null && oldMap.get(recCase.Id).Core_IPS_Project_Case__c <> recCase.Core_IPS_Project_Case__c){
                            //[Adding Old Case in a list.]
                            revokableProjectRelatedCaseList.add(oldMap.get(recCase.Id));
                            system.debug('#####2####');
                        }//[Scenario B : Project is changing]
                        
                        
                        else if(recCase <> null && recCase.Core_IPS_Project_Case__c <> null && oldmap!=null && oldMap.get(recCase.Id).Core_IPS_Project_Case__c == null){
                            //[Adding Old Case in a list.]
                            revokableAccountRelatedCaseList.add(oldMap.get(recCase.Id));
                            system.debug('#####3####');
                        }//[Scenario C : Account Based Case is changing to Project Based.]
                        
                        
                        else if(recCase <> null && recCase.AccountId <> null && recCase.Core_IPS_Project_Case__c == null && oldmap!=null && oldMap.get(recCase.Id).Core_IPS_Project_Case__c == null && oldMap.get(recCase.Id).AccountId <> null && recCase.AccountId <> oldMap.get(recCase.Id).AccountId){
                            revokableAccountRelatedCaseList.add(oldMap.get(recCase.Id));
                            system.debug('#####4####');
                        }//[Scenario D : Account is changing.]
                        /*Ashutosh- US106566 - we need to check the case where project is set to null for NAC case as above all check are based on
                        Account value when project is null but NAC will not have account so need to check independently
                        [check condition - case != null AND Project == null AND OLDCASE.Project != null AND Case.CustomerVisible = false(As NAC case)]*/
                        
                        else if(recCase <> null && recCase.Core_IPS_Project_Case__c == null && oldmap!=null && oldMap.get(recCase.Id).Core_IPS_Project_Case__c != null && !recCase.Core_IPS_Customer_Visible__c){
                            revokableProjectRelatedCaseList.add(oldMap.get(recCase.Id));
                            System.debug('>>>>> NAC Project not present condition');
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
                        system.debug('coming here#############'+csObj.Core_IPS_Project_Case__c);
                        projectIdbyCaseId.put(csObj.Id,csObj.Core_IPS_Project_Case__c);                           
                        
                    }   
                    
                    if(projectIdbyCaseId <> null && projectIdbyCaseId.size() > 0){
                        projList = [select Id,Core_IPS_GroupId__c,Core_IPS_InternalGroupId__c from Core_IPS_Project__c where Id in:projectIdbyCaseId.values()];
                    }
                    
                    if(projList <> null && projList.size() > 0){
                        for(Core_IPS_Project__c proj:projList){
                            groupIdbyProjectId.put(proj.Id,proj.Core_IPS_GroupId__c);
                            if(proj.Core_IPS_InternalGroupId__c!=null){
                                internalGroupIdbyProjectId.put(proj.Id,proj.Core_IPS_InternalGroupId__c);   //added by Aayushi US102841
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
                        system.debug('##############revokeProjectCaseSharing'+revokeProjectCaseSharing);
                        Core_SharingUtility.RevokeAccess('Case','CaseShare',revokeProjectCaseSharing);
                    }  
                    
                    if(revokeProjectCaseSharingInternal <> null && revokeProjectCaseSharingInternal.size() > 0){
                        system.debug('##############revokeProjectCaseSharingInternal'+revokeProjectCaseSharingInternal);
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
                        system.debug('coming to account related Case List#############');
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
                        if(userRoleIdList <> null && userRoleIdList.size() > 0)
                            groupIdsbyRoleId = Core_SharingUtility.getGroupIdsByRoleId(userRoleIdList);
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
                    for(Core_IPS_Project__c projObj:[select Id,Core_IPS_GroupId__c,Core_IPS_InternalGroupId__c from Core_IPS_Project__c where Id in:projectIdSet]){
                        groupIdbyProjectId.put(projObj.Id,projObj.Core_IPS_GroupId__c);
                        //added by Aayushi US102841
                        if(projObj.Core_IPS_InternalGroupId__c!=null){
                        internalGroupIdbyProjectId.put(projObj.Id,projObj.Core_IPS_InternalGroupId__c);
                        }
                    } 
                    system.debug('###########'+groupIdbyProjectId);  
                    for(Case caseObj:newList){
                        if(caseObj.Core_IPS_Customer_Visible__c){ // Added by Eswar 0n 08-11-2017  (US72553 Iteration 2)
                            projectCaseShareRecords.put(caseObj.Id,groupIdbyProjectId.get(caseObj.Core_IPS_Project_Case__c));        
                        }
                        if(internalGroupIdbyProjectId!=null && internalGroupIdbyProjectId.size()>0){
                            system.debug('###########'+internalGroupIdbyProjectId);                       
                            projectCaseShareRecordsInternal.put(caseObj.Id,internalGroupIdbyProjectId.get(caseObj.Core_IPS_Project_Case__c));        
                        }
                    }
                    system.debug('###########'+projectCaseShareRecords+projectCaseShareRecordsInternal);                    
                }
                if(accountIdSet <> null && accountIdSet.size() > 0){
                    Set<Id> groupIdSet;
                    List<Id> userRoleIdList = new List<Id>();
                    Map<Id,Set<Id>> groupIdsbyRoleId = new Map<Id,Set<Id>>();
                    Map<Id,Set<Id>> groupIdbyAccountId = new Map<Id,Set<Id>>();
                    System.debug('#######inside Account Based Case#####');
                    Map<Id,Set<Id>> custUserRoleIdsByAccId = Core_SharingUtility.getCustomerUserRoleIdsByAccountId(accountIdSet);
                    for(Id accId: accountIdSet){
                        if(custUserRoleIdsByAccId <> null && custUserRoleIdsByAccId.size() > 0 && custUserRoleIdsByAccId.get(accId) <> null && custUserRoleIdsByAccId.get(accId).size() > 0){
                            for(Id userRoleId:custUserRoleIdsByAccId.get(accId)){
                                userRoleIdList.add(userRoleId);
                            }                             
                        }
                    }
                    if(userRoleIdList <> null && userRoleIdList.size() > 0)
                        groupIdsbyRoleId = Core_SharingUtility.getGroupIdsByRoleId(userRoleIdList);
                    system.debug('####groupIdsbyRoleId###'+groupIdsbyRoleId.size());
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
                            if(groupIdSet <> null && groupIdSet.size() > 0)
                                groupIdbyAccountId.put(accId,groupIdSet);
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
                    system.debug('#####caseShareRecords size#####'+caseShareRecords.size());
                    system.debug('#####projectCaseShareRecords size#####'+projectCaseShareRecords.size());
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
                    
                    //Retrieving the users of ContactId vs User id  -- Added by Eswar 0n 08-11-2017  (US72553 Iteration 2)
                    for(User uObj: [Select ContactId,Id from User where ContactId IN : caseContactIdsCustomerVisibleFalseSet OR contactID in :caseContactIdsCustomerVisibleTrueSet]){
                        system.debug('++'+uObj);
                        if(caseContactIdsCustomerVisibleFalseSet.contains(uObj.contactid))
                            caseContactUserCustomerVisibleFalseMap.put(ContactIdCaseIdMap.get(uObj.ContactId), new set<Id>{uObj.Id});
                        else
                            caseContactUserCustomerVisibleTrueMap.put(conIdCaseIdCVTrueMap.get(uObj.ContactId), new set<Id>{uObj.Id});
                    }
                    
                    // Retrieving the caseShare records to provide read/edit access Added by Eswar 0n 08-11-2017  (US72553 Iteration 2)
                    List<CaseShare> lstCaseShare = [SELECT CaseAccessLevel,CaseId,Id,RowCause 
                                                    FROM CaseShare 
                                                    WHERE RowCause = 'RelatedPortalUser'
                                                    And (caseId IN:caseContactUserCustomerVisibleFalseMap.keySet() or 
                                                         caseId IN:caseContactUserCustomerVisibleTrueMap.keySet())];
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
                    if(lstCaseShareToUpdate.size()>0)
                        update  lstCaseShareToUpdate;
                    
                    //Remove all external interested parties if customer visible checkbox is not checked for case. 
                    // Added by Eswar 0n 08-11-2017  (US72553 Iteration 2)
                    List<Core_IPS_Case_Interested_Party__c> lstIntParty = new List<Core_IPS_Case_Interested_Party__c>();
                    for( Core_IPS_Case_Interested_Party__c intParties : [SELECT Id, Case__r.Id FROM Core_IPS_Case_Interested_Party__c                                    WHERE  Case__r.Id  IN: caseIdOfNonCustomerVisibleSet AND Type__c = 'External']) {
                        lstIntParty.add(intParties);
                    }
                    if(lstIntParty.size()>0 ){  delete lstIntParty;   }
                    
                    
                }catch(Exception e){   system.debug('exception==>'+e);   }
            }
        }
    }    
    
    public static Schema.DescribeSObjectResult DescCase;  
    public static Map<id,Schema.RecordTypeInfo> MapCaseRecordTypeID ;
    public static Map<string,Schema.RecordTypeInfo> MapCaseRecordTypeName;    
    public static Id getCaseRecordtypeIDByName(string caseRecordtypeName)
    {
        Id  CaseRecordtypeID = null;
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
        string  CaseRecordtypeName ='';
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
    
    
    public static Map<String, Group> loadGroupByName(string groupName, Map<String,Group> mapGroupByName)
    {
        if (mapGroupByName == NULL)
            mapGroupByName = new Map<String,Group>();
        else
            if (mapGroupByName.keySet().contains(groupName))
            return mapGroupByName;
        
        List<Group> lstGroup = [SELECT Id, Name, DeveloperName 
                                FROM Group 
                                WHERE developerName = :groupName];
        
        if (lstGroup == NULL)
            return mapGroupByName;                
        
        if (lstGroup <> null && lstGroup.size() > 0)
            for(Group objGroup : lstGroup)
            if (!mapGroupByName.keySet().contains(objGroup.DeveloperName))
            mapGroupByName.put(objGroup.DeveloperName, objGroup);
        
        return mapGroupByName;    
    }
    
    
    public static Map<Id, Group> loadGroupById(List<Case> lstCaseList)
    {
        Set<Id> groupIds = new Set<Id>(); 
        for (Case cs : lstCaseList) { 
            if (String.valueOf(cs.OwnerId).startsWith('00G'))
                groupIds.add(cs.OwnerId);
        }
        
        List<Group> lstGroup = [SELECT Id, Name, DeveloperName 
                                FROM Group 
                                WHERE Id IN :groupIds];
        
        if (lstGroup == NULL)
            return NULL;                
        
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
* Ashutosh                05/17/2018                 Modified
* Aparna                 19/11/2018                 Modified for US221489
****************************************************************************************************/       
    public static void IPSCaseFieldsInit(List<Case>newCaseList)       
    {       
        //Ashutosh -US103890 - Added execution check
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('IPSCaseFieldsInit'))
            return;
        try{        
            List<String> Mylbl= Label.Core_IPS_CaseRecordType_Priority_Defaulting.split(',');       
            system.debug('label is :' +Mylbl);      
            List<RecordType> RT = [Select Id from RecordType where Name IN :Mylbl];     
            system.debug('Record type is :' +RT);       
            Set<Id> caseRTId = new Set<Id>(); 
            Set<Id> accountIds = new Set<Id>();//Ashutosh - Us103890
            Set<Id> supContIds = new set<Id>(); //Added by Aparna for US221489-I21;19/11/2018
            map<Id,Contact> contMap = new map<Id,Contact>();
            Map<Id,Account> accountById;
            
            for(RecordType vRT:RT)      
            {       
                system.debug('---Recordtype Id--'+vRT.Id);      
                if(vRT.id!=null){       
                    caseRTId.add(vRT.Id);       
                }       
                
            }       
            
            for(case cc : newCaseList)       
            {   
                /*if(cc.accountId != null){
                    accountIds.add(cc.accountId);
                    system.debug('&&&&&' +accountIds);
                 
                }*/
                
                //Modified by Gourav  Core_IPS_Supported_Contact__c US221486
                if(cc.ContactId!=null) {
                    cc.Core_IPS_Supported_Contact__c = cc.ContactId;
                    
                } 
                supContIds.add(cc.Core_IPS_Supported_Contact__c);  //Added for US221489
                
                if((cc.Status!=null) && (cc.RecordTypeId!=null) && (caseRTId!=null))       
                {       
                    if((cc.Status=='New') && (cc.Core_Severity__c!=null) && (caseRTId.contains(cc.RecordTypeId))){      
                        cc.Priority=cc.Core_Severity__c;        
                        //system.debug('!!!!!!!!!!! Priority :' +cc.Priority);        
                    }       
                }                
            }
            if(supContIds !=null && supContIds.size()>0){
                contMap = new Map<Id,Contact>([Select Id,AccountId from Contact where Id in :supContIds AND Account.Core_CNDA_Number__c!=null]); //Added for US221489
            }
                //system.debug('%%%%%%' +contMap);
                
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
                        contMap.containsKey(csNew.Core_IPS_Supported_Contact__c))
                        {
                            //if(accountById.keyset().contains(contMap.get(csNew.Core_IPS_Supported_Contact__c).accountId)){                                                        
                                //System.debug('---Setting value------');
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
    public static void ProvideCaseAccessatFuture(String csShareList){
        
        try{MAP<id,Set<id>>createdByUsersByCase= (Map<Id,Set<Id>>)JSON.deserialize(csShareList, Map<Id,Set<Id>>.class);
            Core_SharingUtility.provideAccess('Case','CaseShare','Edit',createdByUsersByCase);
            system.debug('@@@@@testing'+createdByUsersByCase);
           } catch(Exception ex){  Core_IPS_ExceptionHandling.logEntryWithException(ex,'Core_IPS_CaseTriggerHandler.ProvideCaseAccessatFuture','case');
                                 system.debug('@@@@message='+ ex.getmessage());
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
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSupportLevelOnCase'))
            return;
        try{
            String iPSCaseCreateCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_Case_Create');
            String noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
            String supportLevelDefaultValue = Core_IPS_Helper_Utility.getIPSLabel('Support_Level_Default');
            String supportLevelDefaultValue_NoAssignedContact = Core_IPS_Helper_Utility.getIPSLabel('Support_Level_Default_No_Assigned_Cont');
            Id accountID;
            
            Id iPSCaseCreateId = getCaseRecordtypeIDByName(iPSCaseCreateCaseRecordType);
            Id noAssignedContactCaseId = getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
            //US237240 : Gourav - To update Support Level for GEC cases
            Id GECRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();
            
            Set<Id> assetIds = new Set<Id>();
            Map<String,Id> accountAssetIdComboToAccountIdMap = new Map<String,Id>();
            Map<String,String> accountAssetIdComboToUniqueKey = new Map<String,String>();
            Map<Id,Asset> assetMap;
            Set<Id> projectId=new Set<Id>();
            Map<Id,Core_Ips_Project__C> projectMap= new Map<Id,Core_Ips_Project__C>();
            
            Set<Id> supportedContId=new Set<Id>();
            for(case cs: triggerNew){
                supportedContId.add(cs.Core_IPS_Supported_Contact__c);
            }
            Map<Id,Contact> suppContAccMap = new Map<Id,Contact>([Select Id,AccountId from Contact where Id in :supportedContId]);
            System.debug('-------------------------------->>>>Supported Contact-Account'+supportedContId+'|'+suppContAccMap);
            for(Case c : triggerNew){
                System.debug('c.Core_IPS_Support_Level__c-->'+c.Core_IPS_Support_Level__c);
                if((Trigger.isInsert && String.isEmpty(c.Core_IPS_Support_Level__c)) || Trigger.isUpdate){ //added if Condition for US113466
               system.debug('Partner Support Account ID if existing  '+c.Core_Partner_Supported_Account__C);
                if(c.Core_Partner_Supported_Account__c != NULL){
                    accountID = c.Core_Partner_Supported_Account__c;
                }else{ //US221486-Gourav: Account based on Supported Contact
                 if(suppContAccMap !=null && suppContAccMap.size()>0){
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

                  
            if(!assetIds.isEmpty()){
                assetMap = new Map<Id,Asset>([SELECT Id,Core_Product_Organization__c FROM Asset WHERE isDeleted = false AND  Id IN : assetIds]);
            }
            
            for(Case c : triggerNew){
              //  if((Trigger.isInsert && projectMap==null &&  projectMap.get(c.Core_ips_project_Case__c).Core_IPS_Support_Level__c!=null)|| (Trigger.isUpdate)){
                if(assetMap != NULL && !assetMap.isEmpty()){
                    System.debug('------------------------------->>7 accountID'+accountID);
                    //Continue when support org is not changed //US237240 : Gourav - To update Support Level for GEC cases
                    if(Trigger.isUpdate && (c.recordTypeId == iPSCaseCreateId || c.recordTypeId == GECRecordTypeId)){
                        if((assetMap.get(c.assetId).Core_Product_Organization__c == assetMap.get(oldMap.get(c.Id).assetId).Core_Product_Organization__c) && (c.Core_Partner_Supported_Account__c == oldmap.get(c.Id).Core_Partner_Supported_Account__c) ){
                            continue;
                        }
                    }
                    
                    //Check if PSA is updated //US237240 : Gourav - To update Support Level for GEC cases
                    if( Trigger.isUpdate  && (c.recordTypeId == iPSCaseCreateId || c.recordTypeId == GECRecordTypeId) && (c.Core_Partner_Supported_Account__c != oldmap.get(c.Id).Core_Partner_Supported_Account__c)){
                        if (c.Core_Partner_Supported_Account__c != null){
                            accountID = c.Core_Partner_Supported_Account__c;
                        }
                        else{
                            //US221486-Gourav: Account based on Supported Contact
                            if(suppContAccMap !=null && suppContAccMap.size()>0){
                                    accountID = suppContAccMap.get(c.Core_IPS_Supported_Contact__c).AccountId;
                            }
                        }
                        String key = String.valueOf(accountID) + String.valueOf(c.assetId);
                        if(assetMap.get(c.assetId).Core_Product_Organization__c != null && accountAssetIdComboToAccountIdMap.get(key) != null){
                            String keyCombo = String.valueOf(assetMap.get(c.assetId).Core_Product_Organization__c).left(15) + String.valueOf(accountAssetIdComboToAccountIdMap.get(key)).left(15);
                            accountAssetIdComboToUniqueKey.put(key,keyCombo);
                            
                        }  
                    }
                    //US237240 : Gourav - To update Support Level for GEC cases
                     if((Trigger.isInsert || Trigger.isUpdate ) && (c.recordTypeId == iPSCaseCreateId || c.recordTypeId == GECRecordTypeId)){
                        if (c.Core_Partner_Supported_Account__c != null){
                            accountID = c.Core_Partner_Supported_Account__c;
                        }
                        else  //US221486-Gourav: updated
                        {   accountID = suppContAccMap.get(c.Core_IPS_Supported_Contact__c).AccountId; }
                        String key = String.valueOf(accountID) + String.valueOf(c.assetId);
                        if(assetMap.get(c.assetId).Core_Product_Organization__c != null && accountAssetIdComboToAccountIdMap.get(key) != null){
                            String keyCombo = String.valueOf(assetMap.get(c.assetId).Core_Product_Organization__c).left(15) + String.valueOf(accountAssetIdComboToAccountIdMap.get(key)).left(15);
                            accountAssetIdComboToUniqueKey.put(key,keyCombo);
                        }  
                    }
                }
             if(Trigger.isInsert && c.recordTypeId == noAssignedContactCaseId){
               if(String.isNotBlank(supportLevelDefaultValue_NoAssignedContact) && String.isBlank(c.Core_IPS_Support_Level__c)) {
                        c.Core_IPS_Support_Level__c = supportLevelDefaultValue_NoAssignedContact; }
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
                    else //US221486-Gourav: updated
                    { accountID = suppContAccMap.get(c.Core_IPS_Supported_Contact__c).AccountId;   }
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
        catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');System.debug('Core_IPS_CaseTriggerHandler-->updateSupportLevelOnCase-->Exception--->'+e.getMessage()+'At Line Number-->'+e.getLineNumber()); }
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
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('checkCaseClosureParams'))
            return;
        try{
            Core_IPS_Labels__c LCS = Core_IPS_Labels__c.getInstance('Core_IPS_Bug/Fix_ErrMsg');
            Core_IPS_Labels__c LCSStatus = Core_IPS_Labels__c.getInstance('Core_IPS_Bug/Fix_StatusValue');
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
                            system.debug('triggerFieldValue...'+triggerFieldValue );
                            system.debug('setTriggerValues....'+setTriggerValues);
                            system.debug('old val....'+oldMap.get(cs.Id).get(suppOrgRec.Core_IPS_Field_Name__c) );
                            if(suppOrgRec.Core_IPS_Is_Active__c && suppOrgRec.Core_IPS_Support_Org_Number__c.contains(cs.Core_IPS_Product_Org_Number__c)&& setTriggerValues.contains(triggerFieldValue) && triggerFieldValue != oldMap.get(cs.Id).get(suppOrgRec.Core_IPS_Field_Name__c)&& setValues.Contains(cs.Core_Case_Closure__c) && (cs.get(suppOrgRec.Core_IPS_Field_Name__c) == '' || cs.get(suppOrgRec.Core_IPS_Field_Name__c) == Null)){cs.addError(strErrorMessage);  
                                                                                                                                                                                                                                                                                                                                                                                                                                                 }
                        }
                    }  
                }
            }
        }catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');System.debug('Core_IPS_CaseTriggerHandler-->checkCaseClosureParams-->Exception--->'+e.getMessage()+'At Line Number-->'+e.getLineNumber());}
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
    public static void case_Edit_projectDetails(List<case> newList,Map<id,case> oldMap)  {  
    if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('case_Edit_projectDetails'))
       return;
         
        
    Map<id,id> editCaseDetailsMap=new Map<id,id>(); 
    //Map<id,case> CaseDetailsMap=new Map<id,case>();
    List<Case> lstCaseScope = new List<Case>();
    
    if(newList!= null && newList.size()>0){
     for(case caseProjectChange : newList) {
         
      if(oldMap.get(caseProjectChange.id).Core_IPS_Project_Case__c!=caseProjectChange.Core_IPS_Project_Case__c){          
         editCaseDetailsMap.put(caseProjectChange.id, caseProjectChange.Core_IPS_Project_Case__c);
         //caseDetailsMap.put(caseProjectChange.id,caseProjectChange); 
         if(caseProjectChange.Core_IPS_Project_Case__c!=null) lstCaseScope.add(caseProjectChange);           
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
      List<Core_IPS_Intel_Support_Team__c> ISTList = [select id,name,Core_IPS_Project__c,Add_as_Case_Interested_Party__c,Core_IPS_User__c,Status__c from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c In: editCaseDetailsMap.Values() and Add_as_Case_Interested_Party__c=true]; 
      if(ISTList.size()>0) { 
        //Core_IPS_IntelSupportTeam_Handler.insertInterestedParty(ISTList, lstCaseScope);
      }
      List<Core_IPS_Project_Member__c> projectMembersList = [select id,name,Core_IPS_Project__c,Core_IPS_Contact__c,Core_Status__c,Add_as_Case_Interested_Party__c,Core_User__c from Core_IPS_Project_Member__c where Core_IPS_Project__c In : editCaseDetailsMap.Values() and Add_as_Case_Interested_Party__c=true];
      if(projectMembersList.size()>0) {          
        Core_IPS_Project_Member_Handler.insertInterestedParty(projectMembersList, lstCaseScope);
      }
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
    System.debug('In method');  
    for(ID cs:editCaseDetailsMap.keySet()){ 
     for(Core_IPS_Project_Member__c projectMembers:premierSupportMembers_List){
         System.debug('in for 2');
       if(projectMembers.Core_IPS_Project__r.Core_IPS_EnableMemberasInterestedParties__c==true && editCaseDetailsMap.get(cs).Core_IPS_Project_Case__c==projectMembers.Core_IPS_Project__c){    
           System.debug('before insert');
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
    System.debug('check size');  
    if(InterestedParty_List.size()>0){
        System.debug('pass');  
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
    public static void create_InsterestedParties_UsingCase(List<case> newcaselist) {
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('create_InsterestedParties_UsingCase'))
            return;
        
        set<Id> projectSet=new set<Id>();
        if(newcaselist!=null && newcaselist.size()>0){
            for(Case caseList:newcaselist){
                //system.debug('entered in case');
                if(!caseList.isClone()) {
                    projectSet.add(caseList.Core_IPS_Project_Case__c); 
                }
            }
            
        }
        if(projectSet!=null && projectSet.size()>0){
            List<Core_IPS_Intel_Support_Team__c> ISTList=[select id,name,Core_IPS_Project__c,Add_as_Case_Interested_Party__c,Core_IPS_User__c,Status__c from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c In: projectSet and Add_as_Case_Interested_Party__c=true]; 
            if(ISTList.size()>0 && ISTList!=null){
                //system.debug('entered in IST-->'+ISTList);  
                //Core_IPS_IntelSupportTeam_Handler.create_InterestedParty_using_checkBox(ISTList,null); //commented for DE28924
                //Core_IPS_IntelSupportTeam_Handler.insertInterestedParty(ISTList, newcaselist); //added for DE28924
            }
            List<Core_IPS_Project_Member__c> projectMembersList=[select id,name,Core_IPS_Project__c,Core_IPS_Contact__c,Core_Status__c,Add_as_Case_Interested_Party__c,Core_User__c from Core_IPS_Project_Member__c where Core_IPS_Project__c In : projectSet and Add_as_Case_Interested_Party__c=true];
            if(projectMembersList.size()>0 && projectMembersList!=null){
                //system.debug('entered in project Members');
                Core_IPS_Project_Member_Handler.insertInterestedParty(projectMembersList,newcaselist);
            }
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
    public static void validate_CaseOwner(Map<Id,Case> oldMap,List<Case> newList){
    
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('Core_IPS_Execute_CaseOwnerValidation'))return;
            
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
                setPvtProjIds.add(cs.Core_IPS_Project_Case__c); setPvtCaseOwnerIds.add(cs.OwnerId);}
            if(cs.Core_IPS_Private_Project__c && oldMap.get(cs.Id).Core_Case_Co_Owner__c != cs.Core_Case_Co_Owner__c){
                setPvtProjIds.add(cs.Core_IPS_Project_Case__c); setPvtCaseCoOwnerIds.add(cs.Core_Case_Co_Owner__c); //US252217
            }
          }
        if(!setNewCsOwnerIds.isEmpty() || !setNewCsCoOwnerIds.isEmpty()){
         for(User usr: [Select id,ProfileId,Profile.Name,UserType from User where (Id IN :setNewCsOwnerIds OR Id IN :setNewCsCoOwnerIds) /* and ProfileId = : System.Label.Core_IPS_Agent_Partner_Profile_id */ ]){
            //setPartUsers.add(u.Id);
            mapPartUsers.put(usr.id,usr);
         }
        for(Case cs : newList){
            //if((setPartUsers.Contains(cs.OwnerId) || setPartUsers.Contains(cs.Core_Case_Co_Owner__c)) && Cs.Core_IPS_Project_Case__c != null){
              if(((mapPartUsers.get(cs.OwnerId) !=null && mapPartUsers.get(cs.OwnerId).ProfileId==System.Label.Core_IPS_Agent_Partner_Profile_id) ||
                  (!String.isBlank(cs.Core_Case_Co_Owner__c) && mapPartUsers.get(cs.Core_Case_Co_Owner__c) !=null && mapPartUsers.get(cs.Core_Case_Co_Owner__c).ProfileId==System.Label.Core_IPS_Agent_Partner_Profile_id)) && Cs.Core_IPS_Project_Case__c != null){  
                setProjIds.add(cs.Core_IPS_Project_Case__c);
                setPartCaseIds.add(cs.id);
                
            }    
        }
        
        //All the Project with Partner member
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
         }}
        //US230032 Gourav - To check for Private_Case_Internal_Owner
        if( !setPvtProjIds.isEmpty()){
          for (Core_IPS_Intel_Support_Team__c istMem: [Select Id, Core_IPS_Project__c, status__c, Core_IPS_User__c,Core_IPS_User__r.UserType from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c in: setPvtProjIds AND (Core_IPS_User__c in: setPvtCaseOwnerIds OR Core_IPS_User__c in: setPvtCaseCoOwnerIds ) AND Status__c = 'Active' and Core_IPS_User__r.isActive=true]) {
                        if (!mapActiveISTs.containsKey(istMem.Core_IPS_Project__c)) {
                            mapActiveISTs.put(istMem.Core_IPS_Project__c, new Set<Id>());
                        }
                        mapActiveISTs.get(istMem.Core_IPS_Project__c).add(istMem.Core_IPS_User__c);
                        //userMap.put(istMem.Core_IPS_User__c,true);
                        
          }
        }
        if(!setProjIds.isEmpty() || !setPvtProjIds.isEmpty()){
         for(Case cs : newList){
            
            //Partner-Agent check for Case Owner  //US252217 Co-owner
            if( !String.isBlank(cs.Core_IPS_Project_Case__c) && (mapPartUsers.get(cs.OwnerId)!=null && mapPartUsers.get(cs.OwnerId).ProfileId==System.Label.Core_IPS_Agent_Partner_Profile_id && (!mapProjToPartnerMember.containsKey(cs.Core_IPS_Project_Case__c) || !mapProjToPartnerMember.get(cs.Core_IPS_Project_Case__c).contains(cs.OwnerId))) ||(!String.isBlank(cs.Core_Case_Co_Owner__c) && mapPartUsers.get(cs.Core_Case_Co_Owner__c)!=null && mapPartUsers.get(cs.Core_Case_Co_Owner__c).ProfileId==System.Label.Core_IPS_Agent_Partner_Profile_id && ( !mapProjToPartnerMember.containsKey(cs.Core_IPS_Project_Case__c) || !mapProjToPartnerMember.get(cs.Core_IPS_Project_Case__c).contains(cs.Core_Case_Co_Owner__c)))) {
                cs.addError(Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_CaseOwner_Err_Msg'));
            } 
            
            
            //US230032 && US252217 Gourav - To check for Private_Case_Internal_Owner
            else if(cs.Core_IPS_Private_Project__c && ((mapPartUsers.get(cs.OwnerId) !=null && mapPartUsers.get(cs.OwnerId).UserType==System.Label.UserType_Standard && setPvtCaseOwnerIds.contains(cs.OwnerId) && (!mapActiveISTs.containsKey(cs.Core_IPS_Project_Case__c) || !mapActiveISTs.get(cs.Core_IPS_Project_Case__c).contains(cs.OwnerId) )) || (!String.isBlank(cs.Core_Case_Co_Owner__c) && mapPartUsers.get(cs.Core_Case_Co_Owner__c)!=null && mapPartUsers.get(cs.Core_Case_Co_Owner__c).UserType==System.Label.UserType_Standard && setPvtCaseCoOwnerIds.contains(cs.Core_Case_Co_Owner__c) && (!mapActiveISTs.containsKey(cs.Core_IPS_Project_Case__c) || !mapActiveISTs.get(cs.Core_IPS_Project_Case__c).contains(cs.Core_Case_Co_Owner__c)) ))){
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
    ****************************************************************************************************/ 
    public static void assignCaseInformationfromProject(List<case> newList, Map<Id,Case> oldMap)  { 
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('assignCaseInformationfromProject')){return;}
        try{ 
            // US240396 --04 Jan 2019 --- added isExternal by orion -- Vamsi
            Boolean  isExternal=checkExternalUser();
            Id IPSNACCaseRTId = getCaseRecordtypeIDByName(Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact'));
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
            if(!projectId.isEmpty()) {
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
                            if(cs.Core_ips_project_Case__c!=null && cs.RecordTypeId!=IPSNACCaseRTId) {
                               cs.Core_IPS_Partner_Sup_Owner__c = projectMap.get(cs.Core_ips_project_Case__c).Core_IPS_Partner_Support_Owner__c;
                               cs.Core_Intel_Sup_Owner__c = projectMap.get(cs.Core_ips_project_Case__c).Core_IPS_Intel_Support_Owner__c;
                               }
                            // Start -- US240396 --04 Jan 2019 --- added condition to assign loggedin user as PSO, works for external profiles(partner FAE & Agent partner)  by orion -- Vamsi
                            if(cs.Core_IPS_Partner_Sup_Owner__c==null && isExternal){
                                if(userinfo.getUserId() != null){
                                    cs.Core_IPS_Partner_Sup_Owner__c=userinfo.getUserId();
                                }
                            }
                            // End --US240396 --04 Jan 2019 --- added condition to assign loggedin user as PSO, works for external profiles(partner FAE & Agent partner)  by orion -- Vamsi
                        } //on update or change of Project on case 
                        else if(oldMap!=null && cs.Core_IPS_Project_Case__c != oldMap.get(cs.Id).Core_IPS_Project_Case__c && cs.RecordTypeId!=IPSNACCaseRTId) {
                            
                            //if((cs.Core_IPS_Partner_Sup_Owner__c==null))
                            //  (oldMap.get(cs.Id).Core_IPS_Project_Case__c!=null && cs.Core_IPS_Partner_Sup_Owner__c == projectMap.get(oldMap.get(cs.Id).Core_IPS_Project_Case__c).Core_IPS_Partner_Support_Owner__c)))
                            {
                                if(cs.Core_IPS_Project_Case__c!=null) {
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
        } catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');System.debug('Core_IPS_CaseTriggerHandler-->assignCaseInformationfromProject-->Exception--->'+e.getMessage()+'At Line Number-->'+e.getLineNumber());}
        
    }
  // Start -- US240396 --04 Jan 2019 --- added method to get profile and permissionset of External user --  by orion -- Vamsi
    private static Boolean checkExternalUser(){
        String FAEPermissionSetId = System.Label.Core_IPS_Partner_DFAE_Permission_Set;
        String agentPartnerProfileId=System.Label.Core_IPS_Partner_AE_Profile_Id;
        
        List<PermissionSetAssignment> userPerSet=[Select PermissionSetID From PermissionSetAssignment where AssigneeId=:UserInfo.getUserId()];
        for(PermissionSetAssignment PSA:userPerSet){
            if(Userinfo.getProfileId() ==agentPartnerProfileId || PSA.PermissionSetID == FAEPermissionSetId ){
                return true;
            }
        }
        return false;
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
                        
            Map<Id,Id> mapOwnerId = new Map<Id,Id>();
            for(Case cs: newList) {
                if(cs.OwnerId!=null && String.valueOf(cs.OwnerId).startswith('005') && (oldMap==null || (oldMap!=null && cs.OwnerId != oldMap.get(cs.Id).OwnerId))) { 
                    mapOwnerId.put(cs.Id, cs.OwnerId);                    
                }
                if(OldMap!=null && cs.OwnerId!=oldMap.get(cs.Id).OwnerId) {
                    cs.Core_IPS_Owner_Manager__c = null;
                    cs.Core_IPS_Owner_2nd_Manager__c = null;
                }
            }
            if(!mapOwnerId.isEmpty()) {
                Map<Id,User> mapUser = new Map<Id,User>([SELECT Id,ManagerId,Manager.ManagerId FROM User WHERE Id IN: mapOwnerId.values()]);
                
                if(!mapUser.isEmpty()) { 
                    //Map<Id,Case> newMap = new Map<Id,Case>(newList);
                    //for(Id caseId : mapOwnerId.keySet()) {
                        //Case cs = newMap.get(caseId);
                    for(Case cs : newList) {
                        if(cs.OwnerId!=null && String.valueOf(cs.OwnerId).startswith('005') && (oldMap==null || (oldMap!=null && cs.OwnerId != oldMap.get(cs.Id).OwnerId))) { 
                            if(mapUser.get(cs.OwnerId).ManagerId!=null) {
                                cs.Core_IPS_Owner_Manager__c = mapUser.get(cs.OwnerId).ManagerId;
                            }
                            if(mapUser.get(cs.OwnerId).Manager.ManagerId!=null) {
                                cs.Core_IPS_Owner_2nd_Manager__c = mapUser.get(cs.OwnerId).Manager.ManagerId;
                            }
                        }
                    }
                }
            }
        } catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');System.debug('Core_IPS_CaseTriggerHandler-->assignManager-->Exception--->'+e.getMessage()+'At Line Number-->'+e.getLineNumber());}        
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
                System.debug('cs.Core_IPS_GEC_Status__c-->'+cs.Core_IPS_GEC_Status__c);
                if(cs.ContactId!=null) {
                    cs.Core_IPS_Supported_Contact__c = cs.ContactId;                       
                }
                if(cs.Core_IPS_Private_Project__c) {                    
                    cs.ContactId = null;
                    cs.AccountId = null;
                } 
            }
        }
        catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');System.debug('Core_IPS_CaseTriggerHandler-->updateSupportedContact-->Exception--->'+e.getMessage()+'At Line Number-->'+e.getLineNumber());}        
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
                System.debug('OldCaseMap.get(cs.id).productid-->'+OldCaseMap.get(cs.id).productid+'<--cs.productid-->'+cs.productid);
                if(OldCaseMap.get(cs.id).productid != cs.productid|| OldCaseMap.get(cs.id).Core_IPS_Supported_Product__c != cs.Core_IPS_Supported_Product__c || OldCaseMap.get(cs.id).assetId != cs.AssetId  || (OldCaseMap.get(cs.id).Core_IPS_GEC_Status__c != cs.Core_IPS_GEC_Status__c && (cs.Core_IPS_GEC_Status__c == Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved')||cs.Core_IPS_GEC_Status__c == Core_IPS_Helper_Utility.getIPSLabel('GEC_Status_Approved_WithG')))){
                        caseKey = String.valueOf(mapCaseAssetSupProd.get(cs.AssetId)) + String.valueOf(cs.Core_IPS_Project_Case__c);
                        if(mapProjProdOwner !=null && mapProjProdOwner.containsKey(caseKey)){  cs.OwnerId=mapProjProdOwner.get(caseKey);
                            
                        } else if(mapProjProdOwner !=null && mapProjProdOwner.containsKey(cs.Core_IPS_Project_Case__c) && cs.Core_IPS_Private_Project__c){
                            cs.OwnerId = mapProjProdOwner.get(cs.Core_IPS_Project_Case__c);
                            
                        }
                }
            }
           
        }catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');System.debug('Core_IPS_CaseTriggerHandler-->assignProjectCasesOwner-->Exception--->'+e.getMessage()+'At Line Number-->'+e.getLineNumber()); }        
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
    * Sumukh                     30/01/2019              US261517 - Routing Cases when the Default Case Owner is Inactive
    ****************************************************************************************************/ 
    public static void assignProjectCasesOwner(List<case> newList)  { 
         
        try{  
            //System.debug('------------------->>>>>assignProjectCasesOwner1');
            Set<Id> suppProdIDs = new Set<Id>()  ;
            Set<Id> caseAssetids = new Set<Id>()  ;
            for(Case c : newList){
                //supportedProdIDs.add(c.Core_IPS_Supported_Product__c);
                projIDs.add(c.Core_IPS_Project_Case__c);
                if(c.AssetId!=null)
                    caseAssetids.add(c.AssetId);
                
            }
            
            if(caseAssetids.size()>0 && projIDs!=null && projIDs.size()>0) {
                for(Asset objAst : [SELECT Id,Core_Supported_Product__c FROM Asset WHERE Id IN :caseAssetids]){
                    supportedProdIDs.add(objAst.Core_Supported_Product__c);
                    mapCaseAssetSupProd.put(objAst.Id,objAst.Core_Supported_Product__c);
                }    
                
            }
            
            if(supportedProdIDs!=null && supportedProdIDs.size()>0 && projIDs!=null && projIDs.size()>0)
            {                                       
                for(Core_IPS_Product__c projProd : [Select Id, Core_IPS_Product_Case_Owner__c, Core_Supported_Product__c,Core_IPS_Project__c,Core_IPS_Project__r.Core_IPS_Private__c,Core_IPS_Product_Case_Owner__r.Isactive,Core_IPS_Project__r.OwnerId FROM Core_IPS_Product__c WHERE Core_Supported_Product__c IN :supportedProdIDs AND Core_IPS_Project__c in : projIDs]) 
                  {  
                    String projKey = String.valueOf(projProd.Core_Supported_Product__c)+String.valueOf(projProd.Core_IPS_Project__c);
                    
                    if(!String.isBlank(projProd.Core_IPS_Product_Case_Owner__c) && (projProd.Core_IPS_Product_Case_Owner__r.Isactive==True) ){   // added by sumukh for US261517 & US264004                    
                        mapProjProdOwner.put(projKey,projProd.Core_IPS_Product_Case_Owner__c);
                    }else {
                        mapProjProdOwner.put(projProd.Core_IPS_Project__c,projProd.Core_IPS_Project__r.OwnerId);
                    }
                }              
             }    
            //End by Gourav
        }
        catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');System.debug('Core_IPS_CaseTriggerHandler-->assignProjectCasesOwner-->Exception--->'+e.getMessage()+'At Line Number-->'+e.getLineNumber());}        
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
    ***********************************************************************************/
    public static void updateCaseOwnerGroup(List<Case> newList,Map<Id,Case> oldMap){
        try{
        set<Id> caseOwnerSet = new set<Id>();
        set<Id> supportOrgSet = new set<Id>();
        List<case> lstScope = new List<Case>();
        
        for(case cs : newList){
            if(oldMap==null || (oldMap!=null && (cs.OwnerId!=oldMap.get(cs.id).OwnerId || cs.Core_IPS_Product_Org1__c != oldMap.get(cs.id).Core_IPS_Product_Org1__c)))
            {
                cs.Core_IPS_Case_Owner_Groups__c = null;    
                caseOwnerSet.add(cs.OwnerId);
                supportOrgSet.add(cs.Core_IPS_Product_Org1__c);
                if(cs.OwnerId!=null && cs.Core_IPS_Product_Org1__c!=null)
                lstScope.add(cs);
            }    
        }
        
        if(!caseOwnerSet.isEmpty() && !supportOrgSet.isEmpty()){
            Map<string,Id> mapCaseOwnerGroup = new Map<string,Id>();
            for(Core_IPS_Case_Owner_Group__c obj : [select id,Core_IPS_Case_Owner__c,Core_IPS_Support_Org__c from Core_IPS_Case_Owner_Group__c where Core_IPS_Case_Owner__c in: caseOwnerSet AND Core_IPS_Support_Org__c in: supportOrgSet]) {
                mapCaseOwnerGroup.put(String.valueOf(obj.Core_IPS_Case_Owner__c) + String.valueOf(obj.Core_IPS_Support_Org__c), obj.id);
            }
                        
            if(!mapCaseOwnerGroup.isEmpty()) { 
                for(case cs : lstScope){     
                    String key = String.valueOf(cs.ownerId) + String.valueOf(cs.Core_IPS_Product_Org1__c);
                    if(mapCaseOwnerGroup.containsKey(key)) {
                        cs.Core_IPS_Case_Owner_Groups__c = mapCaseOwnerGroup.get(key);
                    }
                }
            }
        }        
    }catch(exception e){Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');System.debug('Core_IPS_CaseTriggerHandler-->updateCaseOwnerGroup-->Exception--->'+e.getMessage()+'At Line Number-->'+e.getLineNumber());} 
    }
    
}  
    
    //end