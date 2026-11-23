/********************************************************************************************************************
Apex Class Name:  Core_OpportunityLineItemHandler
Version      : 1.0 
Created Date : 11/21/14
Function     : Utility methods to handle OpportunityLineItem functions
Modification Log :
* Developer                   Date                   Description
* -----------------------------------------------------------------------------------------------------------------
* Laxmana Lenka               02/18/2019            US176770 SMG 2019: CMSSN- Only Send Data for Certain Combinations.
* Ashwin Dash                 02/07/2019            US282592: SMG 2019: Data Flow fix between IAH to SFDC
* Mahesh                      01/07/2019            US176771:SMG 2019: CMSSN- Stamp Opportunity Product Segment at Approval & Send to Commissions
* Ashwin Dash                 07/03/2018            US106973: CMSSN: Send Additional Fields to Commissions "Approved BU Product Segment" & "Approved Sales Group"
* Laxmana Lenka               05/23/2018            US102130: CMSSN: Send Product Segment to Commissions
* Ashwin Dash                 05/17/2018            DE39467 : Oppty: System.NullPointerException for Class Core_OpportunityLineItemHandler addCommissionableTransactions
* Ashwin Dash                 05/03/2018            US102130: CMSSN: Send Account Prime and KPI Product Group to Commissions and Only Design Opportunities are to be sent for commissions.
* Rajesh Kumar                04/04/2018            US102413:INC007049454 - Oppty: BU Product Segment "IoT-Unknown" have opportunities that should not be in that bucket.
* Ashwin Dash                 20/03/2018            US98608 : 6QPS : Add field BU SHORT NAME and BU Product Segment 
* Ashwin Dash                 17/01/2018            US91359 : 6 Qtr Product Scheduler Enhancement -- adding Approval and Revenue.
* Rajesh Kumar                16/1/2018             US90478-Stamp the Opporuntiy Prodcuts on OpportunityApprovalHistory object ,When product status is changed to Win Approved.
* Ashwin Dash                 12/05/2017            US89448, US88961 - Stamp "Approved Sales Group" and "Approved Opportunity Coverage" field on Opportunity
Product on Approval and remove it on rejection or recall.
* Ashwin Dash                 10/01/2017            US83104 - Added insertForecastRecords updateForecastRecords and deleteForecastRecords methods for Forecasting
* Ashwin Dash                 08/29/2017            DE30417 - Adding null pointer checks on the if condition 
* Rajesh kumar                08/01/2017            Added for code BU information has not been calculated since crietria has not match with BU mapping table.
* Ajay Doddangadi             06/27/2017            Added code for BU_Shortname calculation logic
* Sampath Bokam               04/03/2017            Updated addCommissionableTransactions() to remove Design Product Category from Integration
* Venu Karumuru               03/23/2017            Updated addCommissionableTransactions() to ignore team members with invalid team member role
* Sampath Bokam               03/17/2017            Updated addCommissionableTransactions() to account for new Line item Status values
* Sampath Bokam               11/09/2016            Stamping of Approved BU Short Name, Send to Commissions only if the Opportunity is Commissionable 
* Dave Hood                   07/25/16              Added code for tracking field history (updates and deletes)
* David Wong                  11/4/2015             Added Commissionable Transaction
* Nick Krisa                  07/28/15              Added product vendor    
* Nick Krisa                  07/01/15              Added populateGroup
* Brian Matthews              11/21/14              Original Version.
*******************************************************************************************************************/
public without sharing class Core_OpportunityLineItemHandler { //TWC3123-5359 Added without sharing keyword to fix code scan issue
    
    // Make sure we only execute functionality once
    public static Boolean alreadyAddedCommissionableTransactions = false;
    public static Boolean alreadyTrackedHistory = false;
    public static Boolean RiskemailRecCheck = true;
    public static Boolean insertpartnersRecCheck = false;//added by Monisha for recursive check
    public static Boolean deletepartnersRecCheck = false;//added by Monisha for recursive check
    public static Boolean updateOppoRiskReasonOnOppLineItemRecCheck = false;//added by Monisha for recursive check
    public static Boolean updateForecastRecordsRecCheck = false;//added by Monisha for recursive check
    public static Boolean opportunityProductConcatenationRecCheck = false;//added by Monisha for recursive check
    public static Boolean updateEOLonUpdateRecCheck = false;//added by Monisha for recursive check
    public static Boolean updateRevenue = false;//added for recursive check
    public static Integer nextChk=0000;
    public static Integer tempxtChk = 0000;     
	public static Boolean oliDeleteRecCheck=false;//TWC3123-6134    
    //Added few more static variables for Forecast checks - Ashwin
    public static final Set<String> Core_Status = new Set<String>{'Lost','Cancelled','Deleted','On Hold','Production Lost','Production Cancelled'};
        public static boolean checkOLIExists = false;   
    //Added a static variable for checing the status as Pending - US89448, US88961 - Stamp "Approved Sales Group" and "Approved Opportunity Coverage" -- Ashwin
    public static final String CORE_PENDING = 'Pending';
    //START - Created new Static varaible to store the Win Approved value.
    public static final String CORE_APPROVED = 'Win Approved';
    public static final String CORE_PROD_APPROVED = 'Production Win Approved';
    //Added a static variable for opportunity ApprovalHistory
    public static boolean oppapprovalHistoryDelete = false;
    public static Boolean alreadyInsertedApprovalHisotry = false;
    //"US90478Implement new Custom object called "Opportunity Product Approval History"--Rajesh 
    public static final Set<String> CORE_OTHERS = new Set<String>{'Lost','Cancelled','Deleted','On Hold'};
        public static final Set<String> CORE_PRODUCTION_STATUS = new Set<String>{'Production Cancelled','Production Lost','Production Win Approved'};
            public static final String CORE_WIN_APPROVED = 'Win Approved';
    public static boolean donotCreate = false;
    public static List<Integer> approvedList = new List<Integer>();
    //Setup from email address
    public static String fromEmailAddress = System.Label.Core_SetFromEmailAddress;
    public static boolean KPIJSONCheckInsert = true;
    public static boolean changeToRiskSupply = false;
    public static Boolean swInsertCheck = false;
    public static Boolean swUpdateCheck = false;
    //public static boolean KPIJSONCheckUpdate = true;
    
    public static void trackHistory(List<OpportunityLineItem> oldList, Map<Id,OpportunityLineItem> oldMap,
                                    List<OpportunityLineItem> newList, Map<Id,OpportunityLineItem> newMap)
    {
        if (alreadyTrackedHistory)
            return;
        else {
            alreadyTrackedHistory = true;
            
            if ((Label.Core_Opportunity_Product_Fields_To_Track == null) || (Label.Core_Opportunity_Product_Fields_To_Track.length() == 0))
                return;
            
            List<String> customSettingFields = Label.Core_Opportunity_Product_Fields_To_Track.split(',');
            List<String> fieldsBeingTracked = new List<String>();
            for (String field : customSettingFields)
                fieldsBeingTracked.add(field.trim());
            
            Schema.DescribeSObjectResult oppLineItemDescribe = OpportunityLineItem.sObjectType.getDescribe();
            
            List<Core_Opportunity_Product_History__c> historyToInsert = new List<Core_Opportunity_Product_History__c>();
            
            // For a delete, add entries for all of the fields being tracked
            if (newList == null) {
                
                for (OpportunityLineItem lineItem : oldList) {
                    
                    for (String fieldBeingTracked : fieldsBeingTracked) {
                        if (oppLineItemDescribe.fields.getMap().containsKey(fieldBeingTracked)) {
                            
                            if (lineItem.get(fieldBeingTracked) != null) {
                                
                                String oldValue = String.valueOf(lineItem.get(fieldBeingTracked));
                                if (oldValue.length() > 255)
                                    oldValue = oldValue.left(255);
                                
                                historyToInsert.add(
                                    new Core_Opportunity_Product_History__c(
                                        Core_Opportunity__c = lineItem.OpportunityId,
                                        Core_Opportunity_Product_ID__c = lineItem.Id,
                                        Core_Field__c = fieldBeingTracked,
                                        Core_Old_Value__c = oldValue,
                                        Core_New_Value__c = ''
                                    ));
                            }
                        }
                    }
                }
            }
            // For an update, add entries for all of the fields being tracked that have been updated
            else if ((oldList != null) && (newList != null)) {
                
                for (OpportunityLineItem lineItem : oldList) {
                    
                    for (String fieldBeingTracked : fieldsBeingTracked) {
                        if (oppLineItemDescribe.fields.getMap().containsKey(fieldBeingTracked)) {
                            
                            // Check to see if the field actually changed
                            if (lineItem.get(fieldBeingTracked) != newMap.get(lineItem.Id).get(fieldBeingTracked)) {
                                
                                String oldValue = '';
                                if (lineItem.get(fieldBeingTracked) != null) {
                                    oldValue = String.valueOf(lineItem.get(fieldBeingTracked));
                                    if (oldValue.length() > 255)
                                        oldValue = oldValue.left(255);
                                }
                                
                                String newValue = '';
                                if (newMap.get(lineItem.Id).get(fieldBeingTracked) != null) {
                                    newValue = String.valueOf(newMap.get(lineItem.Id).get(fieldBeingTracked));
                                    if (newValue.length() > 255)
                                        newValue = newValue.left(255);
                                }
                                
                                historyToInsert.add(
                                    new Core_Opportunity_Product_History__c(
                                        Core_Opportunity__c = lineItem.OpportunityId,
                                        Core_Opportunity_Product_ID__c = lineItem.Id,
                                        Core_Field__c = fieldBeingTracked,
                                        Core_Old_Value__c = oldValue,
                                        Core_New_Value__c = newValue
                                    ));
                            }
                        }
                    }
                }
            }
            
            insert historyToInsert;
        }
    }
    
    public static void populateGroup(List<OpportunityLineItem> newList) {
        // The set to store the Ids of all Products
        Set<Id> productIds = new Set<Id>();
        
        // Go through the OpportunityLineItems adding their related Product Id 
        for (OpportunityLineItem oppli : newList)
        {
            productIds.add(oppli.Product2Id);
        }
        
        // The map to store the Group, Group Code, Division & Division Code from Products
        Map<Id, Product2> products = new Map<Id, Product2>([SELECT Id, Core_Group_Code__c, Core_Group_Code_Short_Name__c, Core_Division_Code__c, Core_Division_Code_Short_Name__c FROM Product2 WHERE Id in: productIds]);
        
        for (OpportunityLineItem oppli : newList)
        {   
            String grpCode;
            String divCode;
            String grp;
            String div;
            
            // Set related product's fields to variables
            if (products.get(oppli.Product2Id).Core_Group_Code__c != null) {
                grpCode = products.get(oppli.Product2Id).Core_Group_Code__c;
            }
            else {
                grpCode = '';
            }
            
            if (products.get(oppli.Product2Id).Core_Division_Code__c != null) {
                divCode = products.get(oppli.Product2Id).Core_Division_Code__c;
            }
            else {
                divCode = '';
            }
            
            if (products.get(oppli.Product2Id).Core_Group_Code_Short_Name__c != null) {
                grp = products.get(oppli.Product2Id).Core_Group_Code_Short_Name__c;
            }
            else {
                grp = '';
            }
            
            if (products.get(oppli.Product2Id).Core_Division_Code_Short_Name__c != null) {
                div = products.get(oppli.Product2Id).Core_Division_Code_Short_Name__c;   
            }
            else {
                div = '';
            }
            
            // Execute if Product field is not null & does not contain a ;
            if (!grpCode.contains(';'))
            {
                oppli.Core_Group_Code__c = grpCode;
            }
            if (!divCode.contains(';'))
            {
                oppli.Core_Division_Code__c = divCode;
            }
            if (!grp.contains(';'))
            {
                oppli.Core_Group__c = grp;
            }
            if (!div.contains(';'))
            {
                oppli.Core_Division__c = div;
            }
            
        }
    }
    public static void opportunityLineItemErrorHandler(List<OpportunityLineItem> newList, Map<Id,OpportunityLineItem> newMap,
                                                       List<OpportunityLineItem> oldList, Map<Id,OpportunityLineItem> oldMap,
                                                       Boolean isInsert, Boolean isUpdate, Boolean isDelete){
                                                           if (isInsert &&  !swInsertCheck ){
                                                               opportunityLineItemErrorUpdateDelete(newList,null,null, isInsert, isUpdate, isDelete);
                                                               swInsertCheck = true;
                                                           }
                                                           else if( isUpdate && !swUpdateCheck){
                                                               opportunityLineItemErrorUpdateDelete(newList,newMap,oldMap, isInsert, isUpdate, isDelete);
                                                               swUpdateCheck = true;
                                                           }
                                                       }
    public static void opportunityLineItemErrorUpdateDelete(List<OpportunityLineItem> OppList, 
                                                            Map<Id,OpportunityLineItem> newMap, Map<Id,OpportunityLineItem> oldMap,
                                                            Boolean isInsert, Boolean isUpdate, Boolean isDelete){
                                                               Set<String> prodStatusCheck = new Set<String>{'Lost', 'Cancelled','Production Lost','Production Cancelled'};
                                                               set<Id> oppId = new set<Id>();
                                                               Set<String> statusCheck = new Set<String>{'Accepted', 'Rejected', 'Denied', 'Approved'};
                                                               map<id,SBQQ__QuoteLine__c> quoteLineMap = new map<id,SBQQ__QuoteLine__c>();
                                                               map<id,Boolean> swFlagPrimCheck = new map<id,Boolean>();
                                                               for(OpportunityLineItem oli : OppList){
                                                                           oppId.add(oli.OpportunityId);
                                                                       }
                                                                If(!oppId.isEmpty())
                                                                {
                                                                    for(SBQQ__QuoteLine__c quoteLine : [ SELECT Id,SBQQ__Product__c,SBQQ__Quantity__c,SBQQ__NetPrice__c,SBQQ__ListPrice__c,SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.CRM_SW_Flag_Ind__c,SBQQ__Quote__r.SBQQ__Primary__c
                                                                                                                                                                              FROM SBQQ__QuoteLine__c where SBQQ__Quote__r.SBQQ__Opportunity2__c IN: oppId 
                                                                                                                                                                                                            and SBQQ__Quote__r.SBQQ__Primary__c = true 
                                                                                                                                                                                                            and SBQQ__Quote__r.Pricing_Quote_Program_Nm__c = 'Software & Services'
                                                                                                                                                                                                            and SBQQ__Quote__r.SBQQ__Opportunity2__r.CRM_SW_Flag_Ind__c=true])
                                                                    {
                                                                       quoteLineMap.put(quoteLine.Id,quoteLine) ;
                                                                  
                                                                    }
                                                                    for(SBQQ__Quote__c quote : [select Id,SBQQ__Opportunity2__c,SBQQ__Primary__c from SBQQ__Quote__c where SBQQ__Opportunity2__c IN: oppId and SBQQ__Opportunity2__r.CRM_SW_Flag_Ind__c =true and SBQQ__Primary__c = true and Pricing_Quote_Program_Nm__c = 'Software & Services'  ]){
                                                                            swFlagPrimCheck.put(quote.SBQQ__Opportunity2__c,quote.SBQQ__Primary__c);
                                                                    }
                                                                     
                                                                }
                                                              
                                                               for(OpportunityLineItem oli : OppList){
                                                                           if(isInsert && swFlagPrimCheck.containsKey(oli.OpportunityId) 
                                                                              && swFlagPrimCheck.get(oli.OpportunityId) == true && oli.SBQQ__QuoteLine__c==null ){
                                                                                      oli.addError(Core_CRM_Utility.getCRMLabel('CRM_SW_Error_Product_Update'));
                                                                                  }
                                                                   
                                                                           if(quoteLineMap.containsKey(oli.SBQQ__QuoteLine__c)){
                                                                                  if(statusCheck.contains(quoteLineMap.get(oli.SBQQ__QuoteLine__c).SBQQ__Quote__r.SBQQ__Status__c)){
                                                                                      if(isUpdate && oldMap.containsKey(oli.id) && newMap.containsKey(oli.id) && oli.SBQQ__QuoteLine__c == quoteLineMap.get(oli.SBQQ__QuoteLine__c).Id
                                                                                         && !prodStatusCheck.contains(newMap.get(oli.id).Core_Status__c) 
                                                                                         &&(newMap.get(oli.id).Product2Id != quoteLineMap.get(oli.SBQQ__QuoteLine__c).SBQQ__Product__c
                                                                                              || newMap.get(oli.id).UnitPrice != quoteLineMap.get(oli.SBQQ__QuoteLine__c).SBQQ__NetPrice__c
                                                                                              || newMap.get(oli.id).Quantity != quoteLineMap.get(oli.SBQQ__QuoteLine__c).SBQQ__Quantity__c
                                                                                              ||((newMap.get(oli.id).Core_Status__c != oldMap.get(oli.id).Core_Status__c) && newMap.get(oli.id).Core_Status__c == Label.Core_LineItem_Status)))
                                                                                      {
                                                                                          
                                                                                          oli.addError(Core_CRM_Utility.getCRMLabel('CRM_SW_Error_Product_Update'));
                                                                                      }
                                                                                  }
                                                                                  else{
                                                                                         if(isUpdate && oldMap.containsKey(oli.id) && newMap.containsKey(oli.id) && oli.SBQQ__QuoteLine__c == quoteLineMap.get(oli.SBQQ__QuoteLine__c).Id 
                                                                                              &&(newMap.get(oli.id).Product2Id != quoteLineMap.get(oli.SBQQ__QuoteLine__c).SBQQ__Product__c
                                                                                              || newMap.get(oli.id).UnitPrice != quoteLineMap.get(oli.SBQQ__QuoteLine__c).SBQQ__NetPrice__c
                                                                                              || newMap.get(oli.id).Quantity != quoteLineMap.get(oli.SBQQ__QuoteLine__c).SBQQ__Quantity__c
                                                                                              || newMap.get(oli.id).Core_Status__c != oldMap.get(oli.id).Core_Status__c ))
                                                                                         {
                                                                                            
                                                                                             oli.addError(Core_CRM_Utility.getCRMLabel('CRM_SW_Error_Product_Update'));
                                                                                         }
                                                                                     }
                                                                                
                                                                              }
                                                                    }
                                      }
    public static void opportunityLineItemAfterHandler(List<OpportunityLineItem> newList, Map<Id,OpportunityLineItem> newMap,
                                                       List<OpportunityLineItem> oldList, Map<Id,OpportunityLineItem> oldMap,
                                                       Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
                                                           
                                                           Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll(); 
                                                           
                                                           if (isInsert || isUpdate || isDelete)
                                                               opportunityProductConcatenation(newList, oldList, isDelete);
                                                           
                                                                                                                
                                                       }
    
    //START - US89448, US88961 - Remove "Approved Sales Group" and "Approved Opportunity Coverage" field on Opportunity Product on Approval on rejection or recall.  -- Ashwin  
    public static void opptyLineItemUpdateSalesGroupandUserCovg(List<OpportunityLineItem> oldList, Map<Id,OpportunityLineItem> oldMap,
                                                                List<OpportunityLineItem> newList, Map<Id,OpportunityLineItem> newMap,
                                                                Boolean isUpdate){         
                                                                    //START - Added condition to update the Approval Status in Opportunity back to Recalled when Approved Opportunity is recalled by Manager
                                                                    Set<Id> opptyIdUpdateSet = new Set<Id>();
                                                                    Set<Id> opptyIdSet =new Set<Id>();
                                                                    if(isUpdate){                                                                          
                                                                        for(OpportunityLineItem oli : newList){
                                                                            if(oldMap.get(oli.Id).Core_Status__c != CORE_PENDING && oli.Core_Status__c == CORE_PENDING){
                                                                                oli.Core_Opp_Approved_Sales_Group__c = '';
                                                                                oli.Core_Opp_Approved_Oppty_Coverage__c = '';
                                                                                //START - US102130: CMSSN: Send Account Prime and KPI Product Group to Commissions
                                                                                oli.Core_Approved_KPI_Product_Group__c = '';
                                                                                oli.Core_Approved_Prime_Account_Name__c = '';
                                                                                oli.CRM_DW_App_UCD_Customer_Name__c = '';
                                                                                //US176771:SMG 2019: CMSSN- Stamp Opportunity Product Segment at Approval & Send to Commissions
                                                                                oli.Core_Approved_Opp_Product_Segment__c= '';
                                                                                oli.Core_Approved_Opportunity_Product_App__c = '';
                                                                                
                                                                            }else if(!CORE_OTHERS.contains(oldMap.get(oli.Id).Core_Status__c) && CORE_OTHERS.contains(oli.Core_Status__c)){
                                                                                oli.Core_Opp_Approved_Sales_Group__c = '';
                                                                                oli.Core_Opp_Approved_Oppty_Coverage__c = '';
                                                                                oli.Core_Approved_KPI_Product_Group__c = '';
                                                                                oli.Core_Approved_Prime_Account_Name__c = '';
                                                                                oli.CRM_DW_App_UCD_Customer_Name__c= '';   
                                                                                //END - US102130: CMSSN: Send Account Prime and KPI Product Group to Commissions   
                                                                                //US176771:SMG 2019: CMSSN- Stamp Opportunity Product Segment at Approval & Send to Commissions
                                                                                oli.Core_Approved_Opp_Product_Segment__c= '';
                                                                                oli.Core_Approved_Opportunity_Product_App__c = '';
                                                                            }
                                                                          
                                                                        }
                                                                        
                                                                      
                                                                        //END - Added condition to update the Approval Status in Opportunity back to Recalled when Approved Opportunity is recalled by Manager
                                                                    }
                                                                }
    //END - US89448, US88961 - Remove "Approved Sales Group" and "Approved Opportunity Coverage" field on Opportunity Product on Approval on rejection or recall.  -- Ashwin
    
    public static void opportunityProductConcatenation(List<OpportunityLineItem> newList, 
                                                       List<OpportunityLineItem> oldList,
                                                       Boolean isDelete) {
                                                           if(!opportunityProductConcatenationRecCheck){
                                                               
                                                               
                                                               
                                                               
                                                               try
                                                               {
                                                                   String debugPrefix = 'II: opportunityLineItemAfterHandler - ';            
                                                                   
                                                                   
                                                                   // Create UNIQUE list of Opportunities to be updated
                                                                   Set<String> oppIds = new Set<String>(); 
                                                                   
                                                                   
                                                                   if (isDelete)
                                                                   {
                                                                       for (OpportunityLineItem oppLineItem : oldList) // Delete trigger
                                                                           oppIds.add(oppLineItem.opportunityId);
                                                                   }
                                                                   else 
                                                                   {
                                                                       for (OpportunityLineItem oppLineItem : newList) // Insert, Update trigger
                                                                           oppIds.add(oppLineItem.opportunityId);                            
                                                                   }
                                                                   
                                                                   // Get associated Opportunity records for updating    
                                                                   List<Opportunity> oppList = [SELECT Id, Core_Opportunity_Products__c 
                                                                                                FROM Opportunity 
                                                                                                WHERE Id = :oppIds];   
                                                                   
                                                                   
                                                                   // Get product names.
                                                                   List<OpportunityLineItem> oppLineItems = [SELECT OpportunityId, Product2.Name
                                                                                                             FROM OpportunityLineItem
                                                                                                             WHERE OpportunityId IN :oppIds
                                                                                                             AND Core_Status__c != :Label.Core_LineItem_Status
                                                                                                             ORDER BY OpportunityId];                          
                                                                   
                                                                   
                                                                   List<String> names;  
                                                                   Set<String>  nameSet = new Set<String>();
                                                                   
                                                                   String result = '';
                                                                   
                                                                   for (Opportunity opp : oppList)
                                                                   {
                                                                       // Using a Set for uniqueness.
                                                                       nameSet.clear();            
                                                                       
                                                                       for (OpportunityLineItem oppLineItem : oppLineItems)
                                                                           if (oppLineItem.opportunityId == opp.Id)
                                                                           nameSet.add(oppLineItem.Product2.Name);
                                                                       
                                                                       // Convert to List for array indexing. 
                                                                       names = new List<String> (nameSet);  
                                                                       
                                                                       // Make comma separated list of product names         
                                                                       result = '';
                                                                       for (Integer i=0; i < names.size() - 1; i++)
                                                                           result = result + names[i] + ', ';      
                                                                       
                                                                       if (names.size() > 0) 
                                                                           result = result + names[names.size() - 1];      
                                                                       
                                                                       opp.Core_Opportunity_Products__c = result;                                                 
                                                                       
                                                                   }        
                                                                   
                                                                   update oppList;                        
                                                                   
                                                                   
                                                                   
                                                                   
                                                               }                                                               
                                                               catch(Exception e){   
							       PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler.opportunityProductConcatenation');
                                                               }
                                                               opportunityProductConcatenationRecCheck = true;
                                                           }
                                                           
                                                       }       
    
    /*
* Method name  : insertPartners
* Description  : If Partner does not already exist, insert 
* Return Type  : None
* Parameter    : List of OpportunityLineItems 
*/
    public static void insertPartners(List<OpportunityLineItem> newList) {
        if(!insertpartnersRecCheck){
            List<Core_Opportunity_Partner__c> partnersToInsert = new List<Core_Opportunity_Partner__c>();
            Set<String> partnersBeingInserted = new Set<String>();
            
            // Getting the Ids of related Opportunity records
            Set<Id> relatedOppIds = new Set<Id>();
            for (OpportunityLineItem oppLine : newList) {
                relatedOppIds.add(oppLine.OpportunityId);
            }
            
            List<Core_Opportunity_Partner__c> relatedPartners = [SELECT Id, Core_Opportunity__c, Core_Partner__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c In :relatedOppIds AND Core_Partner_Role__c = 'Vendor'];
            
            // Set of OpportunityId and Partner for each realted Opportunity Partner
            Set<String> existingPartners = new Set<String>();
            for (Core_Opportunity_Partner__c oppPartner : relatedPartners) {
                existingPartners.add(String.valueof(oppPartner.Core_Opportunity__c) + oppPartner.Core_Partner__c);
            }
            
            // If Opportunity Partner does not already exist, create it
            for(OpportunityLineItem oppLine : newList) {
                if (isDupe(existingPartners, oppLine) == false && oppLine.Core_Vendor__c != null && !partnersBeingInserted.contains(String.valueOf(oppLine.OpportunityId) + oppLine.Core_Vendor__c)) {
                    // Creating new Opportunity Partner to insert
                    Core_Opportunity_Partner__c oppPartner = new Core_Opportunity_Partner__c();
                    
                    // Set the values
                    oppPartner.Core_Opportunity__c = oppLine.OpportunityId;
                    oppPartner.Core_Partner__c = oppline.Core_Vendor__c;
                    oppPartner.Core_Partner_Type__c = '';
                    oppPartner.Core_Partner_Role__c = 'Vendor';
                    
                    // Add new Opportunity Partner to insert list and set
                    partnersToInsert.add(oppPartner);
                    partnersBeingInserted.add(String.valueOf(oppPartner.Core_Opportunity__c) + oppPartner.Core_Partner__c);
                }
            }
            
            // Inserting new Opportunity Partners
            insert partnersToInsert;
            insertpartnersRecCheck = true;
        }
    }
    
    /*
* Method name  : deletePartners
* Description  : If the LineItem is not a dupe, delete 
* Return Type  : None
* Parameter    : List of OpportunityLineItems 
*/
    public static void deletePartners(List<OpportunityLineItem> oldList) {
        
        if(!deletepartnersRecCheck){
            
            // Map to hold Opportunity Partners that will be deleted (using a Map to ensure no duplicates in the list)
            Map<Id, Core_Opportunity_Partner__c> mapPartnersToDelete = new Map<Id, Core_Opportunity_Partner__c>();
            
            // Getting the Ids of related Opportunity records
            Set<Id> relatedOppIds = new Set<Id>();
            for (OpportunityLineItem oppLine : oldList) {
                relatedOppIds.add(oppLine.OpportunityId);
            }
            
            // List for related OpportunityLineItems
            List<OpportunityLineItem> relatedLineItems = [SELECT Id, OpportunityId, Core_Vendor__c FROM OpportunityLineItem WHERE OpportunityId In :relatedOppIds AND Core_Status__c != 'Lost' AND Core_Status__c != 'Cancelled' AND Core_Status__c != 'Deleted'];
            
            // List for related Opportunity Partners
            List<Core_Opportunity_Partner__c> relatedOpportunityPartners = [SELECT Id, Core_Opportunity__c, Core_Partner__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c In :relatedOppIds AND Core_Partner_Role__c = 'Vendor'];
            
            // Map containing with key of OpportunityId and value of Opportunity Partner
            Map<String, Core_Opportunity_Partner__c> partnerMap = new Map<String, Core_Opportunity_Partner__c>();
            for (Core_Opportunity_Partner__c oppPartner : relatedOpportunityPartners) {
                String productString = String.valueOf(oppPartner.Core_Opportunity__c) + oppPartner.Core_Partner__c;
                partnerMap.put(productString, oppPartner);
            }
            
            // If record is not a duplicate, delete it
            for (OpportunityLineItem oppLine : oldList) {
                if (oppLine.Core_Vendor__c != null && multipleVendors(relatedLineItems, oppLine) == 0) {
                    String productString = String.valueOf(oppLine.OpportunityID) + oppLine.Core_Vendor__c;
                    if (partnerMap.containsKey(productString)) {
                        Core_Opportunity_Partner__c partner = partnerMap.get(productString);
                        mapPartnersToDelete.put(partner.Id, partner);
                    }
                }
            }
            delete mapPartnersToDelete.values();
            deletepartnersRecCheck = true;
        }
    } 
    
    /*
* Method name  : updatePartners
* Description  : Insert new LineItem, delete the old 
* Return Type  : None
* Parameter    : List of OpportunityLineItems, Map of old Trigger
*/
    public static void updatePartners(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> oldMap) {
        
        List<OpportunityLineItem> partnersToInsert = new List<OpportunityLineItem>();
        List<OpportunityLineItem> partnersToDelete = new List<OpportunityLineItem>();
        
        // If the Vendor has been changed, insert the new & delete the old
        for (OpportunityLineItem oppLine : newList) {
            OpportunityLineItem oldProduct = oldMap.get(oppLine.Id);
            if (oppLine.Core_Vendor__c != oldProduct.Core_Vendor__c) {
                partnersToInsert.add(oppLine);
                partnersToDelete.add(oldProduct);
            }
            if ((oppLine.Core_Status__c != oldProduct.Core_Status__c) && (oppLine.Core_Status__c == 'Lost' || oppLine.Core_Status__c == 'Cancelled' || oppLine.Core_Status__c == 'Deleted')) {
                partnersToDelete.add(oppLine);
            }
            if ((oppLine.Core_Status__c != oldProduct.Core_Status__c) && oppLine.Core_Status__c == 'Pending') {
                partnersToInsert.add(oppLine);
            }
        }
        insertPartners(partnersToInsert);
        deletePartners(partnersToDelete);
    }
    
    /*
* Method name  : isDupe
* Description  : True if Opp Partner already exists   
* Return Type  : boolean
* Parameter    : OpportunityLineItem being tested
*/
    public static boolean isDupe(Set<String> existingPartners, OpportunityLineItem oppLine) {
        
        if (existingPartners.contains(String.valueOf(oppLine.OpportunityId) + oppLine.Core_Vendor__c)) {
            return true;
        }
        return false;
    }
    
    /*
* Method name  : multipleVendors
* Description  : Gives number of LineItems with same Vendor 
* Return Type  : Integer
* Parameter    : OpportunityLineItem to test 
*/
    public static Integer multipleVendors(List<OpportunityLineItem> relatedLineItems, OpportunityLineItem oppProduct) {
        Integer duplicateCounter = 0;
        if (!relatedLineItems.isEmpty() && oppProduct.Core_Vendor__c != null) {
            String string1 = String.valueOf(oppProduct.OpportunityId) + oppProduct.Core_Vendor__c;
            for (OpportunityLineItem oppLine : relatedLineItems) {
                String string2 = String.valueOf(oppLine.OpportunityID) + oppLine.Core_Vendor__c;
                if (string1 == string2) {
                    duplicateCounter++;
                }
            }
        }
        return duplicateCounter;
    }
    
    /*
* Method name  : addCommissionableTransactions
* Description  : Adds new Commissionable Transaction entries for each Opportunity Team Member associated with
*                an newly approved, qualifying OpportunityLineItem.  For OpportunityLineItems that go from  
*                approved to not approved, inserts new Commissionable Transaction entries corresponding to the 
*                previous approved entries, whose status is marked as not approved.
* Return Type  : VOID
* Parameters   : Trigger.Old, Trigger.oldMap, Trigger.New, Trigger.newMap, Trigger.isInsert, Trigger.isUpdate
*/
    
    /*public static void addCommissionableTransactions(List<OpportunityLineItem> oldOPList, Map<Id,OpportunityLineItem> oldOPMap,
                                                     List<OpportunityLineItem> newOPList, Map<Id,OpportunityLineItem> newOPMap,
                                                     Boolean isInsert, Boolean isUpdate)
    {
        
        if(!alreadyAddedCommissionableTransactions) {
            alreadyAddedCommissionableTransactions = true;
            // START: US176770 SMG 2019: CMSSN- Only Send Data for Certain Combinations Dt:2/18/2019
            Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
            List<Core_Commissionable_Transaction__c> newTxns = new List<Core_Commissionable_Transaction__c>();
            
            //Set of all new approved opportunity products that are changing to "approved"
            Set<OpportunityLineItem> approvedOPs = new Set<OpportunityLineItem>();
            // Map of all rejected opportunity productts
            Map<ID,OpportunityLineItem> rejectedOPs = new Map<ID,OpportunityLineItem>();
            
            String approvedBUShortName;
            String approvedSalesGroup;
            String approvedPrimeAccountNm;
            String approvedOppProdSeg;
            String approvedBUProdSeg ; 
            List<Core_Commission_Account_BU_SG_Setting__c> commCustSList;
            commCustSList = Core_Commission_Account_BU_SG_Setting__c.getall().values();
            Map<String, Core_Commission_Account_BU_SG_Setting__c> CustSettingsMap = new Map<String, Core_Commission_Account_BU_SG_Setting__c>();
            
            for(Core_Commission_Account_BU_SG_Setting__c cs : commCustSList)
            {
                if(cs.Core_IsActive__c){
                    
                    if(cs.Core_Approved_BU_Short_Name__c == null || cs.Core_Approved_BU_Short_Name__c == 'null' || cs.Core_Approved_BU_Short_Name__c == 'Null' || cs.Core_Approved_BU_Short_Name__c == 'NULL' || (cs.Core_Approved_BU_Short_Name__c).equalsIgnoreCase ('any') ){
                        approvedBUShortName = '<any>';
                    }else{
                        approvedBUShortName = (cs.Core_Approved_BU_Short_Name__c).toLowerCase();
                    }
                    
                    if(cs.Core_Approved_Sales_Group__c ==null || cs.Core_Approved_Sales_Group__c== 'null' || cs.Core_Approved_Sales_Group__c=='Null' || cs.Core_Approved_Sales_Group__c=='Null' || (cs.Core_Approved_Sales_Group__c).equalsIgnoreCase ('any')){
                        approvedSalesGroup = '<any>';
                    }else{
                        approvedSalesGroup = (cs.Core_Approved_Sales_Group__c).toLowerCase() ; 
                    }
                    
                    if(cs.Core_Approved_Prime_Account_Name__c ==null || cs.Core_Approved_Prime_Account_Name__c== 'null' || cs.Core_Approved_Prime_Account_Name__c=='Null' || cs.Core_Approved_Prime_Account_Name__c=='NULL' || (cs.Core_Approved_Prime_Account_Name__c).equalsIgnoreCase('any')){
                        approvedPrimeAccountNm = '<any>';
                    }else{
                        approvedPrimeAccountNm = (cs.Core_Approved_Prime_Account_Name__c).toLowerCase() ; 
                    }
                    if(cs.Core_Approved_Opp_Product_Segment__c ==null || cs.Core_Approved_Opp_Product_Segment__c== 'null' || cs.Core_Approved_Opp_Product_Segment__c=='Null' || cs.Core_Approved_Opp_Product_Segment__c=='NULL' || (cs.Core_Approved_Opp_Product_Segment__c).equalsIgnoreCase('any') ){
                        approvedOppProdSeg = '<any>';
                    }else{
                        approvedOppProdSeg = (cs.Core_Approved_Opp_Product_Segment__c).toLowerCase() ; 
                    }
                    if(cs.Core_Approved_BU_Product_Segment__c ==null || cs.Core_Approved_BU_Product_Segment__c== 'null' || cs.Core_Approved_BU_Product_Segment__c=='Null' || cs.Core_Approved_BU_Product_Segment__c=='NULL' || (cs.Core_Approved_BU_Product_Segment__c).equalsIgnoreCase('any') ){
                        approvedBUProdSeg = '<any>';
                    }else{
                        approvedBUProdSeg = (cs.Core_Approved_BU_Product_Segment__c).toLowerCase() ; 
                    }
                    
                    CustSettingsMap.put(approvedBUShortName.trim()+'_'+approvedSalesGroup.trim()+'_'+approvedPrimeAccountNm.trim()+'_'+approvedOppProdSeg.trim()+'_'+approvedBUProdSeg.trim(), cs); 
                    
                }
            }
            // END : US176770SMG 2019: CMSSN- Only Send Data for Certain Combinations Dt:2/18/2019
            
            for (OpportunityLineItem op : newOPList) {                
                // If (this is an update trigger, new status is approved and prior status was not approved)
                //DE30417 - Adding null pointer checks on the if condition -- Ashwin
                if((isInsert && op.Core_System_Commissionable__c == null || op.Core_Status__c == null) || (isUpdate && op.Core_Status__c == null && oldOPMap.get(op.Id).Core_Status__c == null)){
                    continue;
                }
                //START - US102130: CMSSN: Send Account Prime and KPI Product Group to Commissions and Only Design Opportunities are to be sent for commissions.
                //DE39467 - Added Null pointer check for Core_Opp_OpportunityType__c -- Ashwin
                
                if (
                    (isInsert && (op.Core_System_Commissionable__c).equalsIgnoreCase('Yes') && (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Approved_Status) && op.Core_Opp_OpportunityType__c != null && op.Core_Opp_OpportunityType__c.contains('Design')) ||
                    ((isUpdate && (op.Core_System_Commissionable__c).equalsIgnoreCase('Yes') && (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Approved_Status) && op.Core_Opp_OpportunityType__c != null && op.Core_Opp_OpportunityType__c.contains('Design')) 
                     && !((oldOPMap.get(op.Id).Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Approved_Status)))) {
                         
                         //Add this opportunity product to set of all newly approved, commissionable opportunity products
                         // START: US176770 SMG 2019: CMSSN- Only Send Data for Certain Combinations Dt:2/18/2019
                         if(mapFunctionalityNameTriggerExecution.containsKey('oppLineCommissionTxnNewLogic') && 
                            mapFunctionalityNameTriggerExecution.get('oppLineCommissionTxnNewLogic').Core_Active__c){
                                if(oppLineCommissionTxnNewLogic (CustSettingsMap,op)){
                                    
                                    // add line items newly approved as per new commission logic.
                                    approvedOPs.add(op);     
                                }
                            }else{
                                // add line items newly approved as per old commission logic.
                                approvedOPs.add(op);
                            }
                         // END: US176770 SMG 2019: CMSSN- Only Send Data for Certain Combinations Dt:2/18/2019                     
                     }
                
                //Else if this is an update trigger, new status is not approved, and prior status was approved
                else if (isUpdate 
                         && (!((op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Approved_Status) || 
                               (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Opportunity_Product_Production_Win_Status) ||
                               (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Opportunity_Product_Production_Lost_Status) ||
                               (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Opportunity_Product_Production_Cancelled_Status)) 
                             && ((oldOPMap.get(op.Id).Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Approved_Status)) 
                             && ((op.Core_System_Commissionable__c).equalsIgnoreCase('Yes') && op.Core_Opp_OpportunityType__c != null && op.Core_Opp_OpportunityType__c.contains('Design')))
                         ||((op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Pending_Status)||
                            (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Lost_Status)||
                            (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Cancelled_Status)||
                            (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_OnHold_Status)||
                            (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Deleted_Status))
                         && ((oldOPMap.get(op.Id).Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Opportunity_Product_Production_Win_Status)
                             ||(oldOPMap.get(op.Id).Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Opportunity_Product_Production_Lost_Status)
                             ||(oldOPMap.get(op.Id).Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Opportunity_Product_Production_Cancelled_Status))
                         && ((op.Core_System_Commissionable__c).equalsIgnoreCase('Yes') && op.Core_Opp_OpportunityType__c != null && op.Core_Opp_OpportunityType__c.contains('Design'))
                        ) //DE39467 - Added Null pointer check for Core_Opp_OpportunityType__c -- Ashwin
                {
                    //Add this opportunity product to map of rejected opportunity products
                    rejectedOPs.put(op.ID, op);                             
                }    
                //END - US102130: CMSSN: Send Account Prime and KPI Product Group to Commissions and Only Design Opportunities are to be sent for commissions.              
            }
            
            //Handle rejections ---------------------------------------------
            //Get a list of commissionableTxns associated with every rejected opportunity product
            //START - US106358: CMSSN: Send Product Segment to Commissions, added the field product segment commission transaction query
            //US106973: CMSSN: Send Additional Fields to Commissions Added - Core_Approved_BU_Product_Segment__c & Core_Approved_Sales_Group__c
            List<Core_Commissionable_Transaction__c> txnList = [
                SELECT Core_Account_ID__c,Core_Account_Name__c,Core_Approved_Total_Price__c,Core_Claim_Date__c,
                Core_Employee_ID__c,Core_Employee_Name__c,Core_Last_Approved_Date__c,
                Core_Milestone_Area__c,Core_Milestone_Focus__c,Core_Milestone_ID__c,Core_Milestone__c,Core_Opportunity_Name__c,
                Core_Opportunity_Team_Member_Role__c,Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,
                Core_Product2_ID__c,Core_Product_Type__c,Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,
                Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c,Core_Approved_KPI_Prod_Grp__c ,Core_Product_Segment__c, Core_Approved_BU_Product_Segment__c, Core_Approved_Sales_Group__c
                FROM Core_Commissionable_Transaction__c
                WHERE Core_Source_ID__c in :rejectedOPs.keySet()
            ];//US102130: CMSSN: Send Account Prime and KPI Product Group to Commissions and Only Design Opportunities are to be sent for commissions Modified the query to inclide the Prime Account and KPI product group -- Ashwin.
            //END - US106358: CMSSN: Send Product Segment to Commissions, added the field product segment commission transaction query
            Map<ID,DateTime> rejectedOPMostRecentTimestamp = new Map<ID,DateTime>();
            List<Core_Commissionable_Transaction__c> rejectedTransactions = new List<Core_Commissionable_Transaction__c>();
            
            for (ID rejectedOP : rejectedOPs.keySet()) {
                //Find the most recent timestamp in the list of transactions for this OP
                DateTime mostRecentTimestamp = DateTime.newInstanceGMT(2000, 1, 1, 12, 0, 0);
                for (Core_Commissionable_Transaction__c ct : txnList) {
                    if (ct.Core_Source_ID__c == rejectedOP && ct.Core_Transaction_Timestamp__c > mostRecentTimestamp)
                        mostRecentTimestamp = ct.Core_Transaction_Timestamp__c;
                }                
                //Iterate again through the list of transactions to get all transactions matching this OP and timestamp, 
                // and add to list of rejected transactions
                for (Core_Commissionable_Transaction__c ct : txnList) {
                    if (ct.Core_Source_ID__c == rejectedOP && ct.Core_Transaction_Timestamp__c == mostRecentTimestamp && ct.Core_Status__c == 'Approved')
                        rejectedTransactions.add(ct);
                }
            }
            
            //Iterate through the set, replacing the Transaction Timestamp with current time, and set status to current status.
            //(If no match was found, do nothing)
            for (Core_Commissionable_Transaction__c rejectedTransaction : rejectedTransactions) {
                rejectedTransaction.Core_Transaction_Timestamp__c = System.now();
                rejectedTransaction.Core_Status__c = rejectedOPs.get(rejectedTransaction.Core_Source_ID__c).Core_Status__c;
                rejectedTransaction.Id = null;
                //Add the modified transaction to newTxn
                newTxns.add(rejectedTransaction);
            }
            //Handle approvals ---------------------------------------------
            //Iterate through set of OPs changing to "approved", generate a set of Opportunity IDs
            Set<ID> opportunityIDs = new Set<ID>();
            Set<ID> productIDs = new Set<ID>();
            for (OpportunityLineItem approvedOP : approvedOPs) {
                opportunityIDs.add(approvedOP.OpportunityId);
                
            }
            
            //Generate an Opportunity map based on the set, keyed by Opportunity ID (Name, Type)
            //Also generate a set of account IDs
            Map<ID, Opportunity> opportunities = new Map<ID, Opportunity>();    
            Set<ID> accountIDs = new Set<ID>();
            for (Opportunity o : [SELECT o.ID, o.Name, o.Core_Opportunity_Type__c, o.AccountId FROM Opportunity o WHERE o.ID in :opportunityIDs]) {
                opportunities.put(o.ID, o);
                accountIDs.add(o.AccountId);
            }       
            
            //Generate an Account map (CIM ID, Name)
            Map<ID, Account> accounts = new Map<ID, Account>();
            for (Account account: [SELECT a.ID, a.Core_CIM_ID__c, a.Name FROM Account a WHERE a.ID in :accountIDs] )
                accounts.put(account.ID, account);    
            
            //Generate an Opportunity Team Member map based on keys of the Opportunity map  (Team Role) 
            Map<ID, OpportunityTeamMember> opportunityTeamMembers = new Map<ID, OpportunityTeamMember>();
            Set<ID> userIDs = new Set<ID>();
            for (OpportunityTeamMember otm : [SELECT o.ID, o.TeamMemberRole, o.UserId, o.OpportunityId FROM OpportunityTeamMember o WHERE o.OpportunityId in :opportunities.keySet()]) {
                opportunityTeamMembers.put(otm.ID, otm);
                userIDs.add(otm.UserId);
            }
            
            //Generate a User map (Name, WWID)
            Map<ID, User> users = new Map<ID, User>();
            for (User user: [SELECT u.ID, u.Name, u.Core_WWID__c, u.Core_Employee_Type_Code__c FROM User u WHERE u.ID in :userIDs] )
                users.put(user.ID, user);
            
            Core_Commissionable_Transaction__c txn;
            Core_Commissionable_Transaction__c opTxn;
            
            //Iterate through the approvedOP set
            for (OpportunityLineItem approvedOP : approvedOPs) {        
                opTxn = new Core_Commissionable_Transaction__c();
                
                //Use maps to collate transaction attributes above the user level        
                opTxn.Core_Source_ID__c = approvedOP.Id;
                opTxn.Core_Transaction_Timestamp__c = System.now();
                opTxn.Core_Account_ID__c = opportunities.get(approvedOP.OpportunityId).AccountId;
                opTxn.Core_Account_Name__c = accounts.get(opportunities.get(approvedOP.OpportunityId).AccountId).Name;
                opTxn.Core_CIM_ID__c = accounts.get(opportunities.get(approvedOP.OpportunityId).AccountId).Core_CIM_ID__c;
                if(approvedOP.Core_Claim_Date__c != null)
                    opTxn.Core_Claim_Date__c = approvedOP.Core_Claim_Date__c.date();
                //opTxn.Core_Last_Approved_Date__c = System.now().date();
                if(approvedOP.Core_Approved_Date__c == null)
                {
                    //in production, we always expect this code to run -- when a product is newly approved, the approved date usually gets populated after this
                    opTxn.Core_Last_Approved_Date__c = System.now().date();
                }
                else
                {
                    //in case of manual data updates, this code may need to run instead
                    opTxn.Core_Last_Approved_Date__c = date.newinstance(approvedOP.Core_Approved_Date__c.year(), approvedOP.Core_Approved_Date__c.month(), approvedOP.Core_Approved_Date__c.day());
                }
                //START - US102130: CMSSN: Send Account Prime and KPI Product Group to Commissions
                if(approvedOP.Core_Approved_KPI_Product_Group__c != null){
                    opTxn.Core_Approved_KPI_Prod_Grp__c = approvedOP.Core_Approved_KPI_Product_Group__c;
                }
                if(approvedOP.Core_Approved_Prime_Account_Name__c != null){
                    opTxn.Core_Approved_Prime_AccountName__c = approvedOP.Core_Approved_Prime_Account_Name__c;
                }
                //END - US102130: CMSSN: Send Account Prime and KPI Product Group to Commissions
                //Approved_Total_Price gets updated post-approval after this trigger runs, so we need to rely on total price
                //START - US106358: CMSSN: Send Product Segment to Commissions
                if(approvedOP.Core_Product_Segment__c != null){
                    opTxn.Core_Product_Segment__c = approvedOP.Core_Product_Segment__c;
                }
                //END - US106358: CMSSN: Send Product Segment to Commissions
                //START - US106973: CMSSN: Send Additional Fields to Commissions Added - Core_Approved_BU_Product_Segment__c & Core_Approved_Sales_Group__c
                if(approvedOP.Core_BU_Product_Segment__c != null){
                    opTxn.Core_Approved_BU_Product_Segment__c = approvedOP.Core_BU_Product_Segment__c;
                }
                if(approvedOP.Core_Opp_Approved_Sales_Group__c != null){
                    opTxn.Core_Approved_Sales_Group__c = approvedOP.Core_Opp_Approved_Sales_Group__c;
                }
                //END - US106973: CMSSN: Send Additional Fields to Commissions Added - Core_Approved_BU_Product_Segment__c & Core_Approved_Sales_Group__c
                opTxn.Core_Approved_Total_Price__c = approvedOP.TotalPrice;
                
                opTxn.Core_Product2_ID__c = approvedOP.Product2Id;
                opTxn.Core_Product_Type__c = approvedOP.Core_Product_Type__c;
                
                
                //This will always be approved
                opTxn.Core_Status__c = Label.Core_Commissionable_Transaction_Approved_Status;
                opTxn.Core_Opportunity__c = approvedOP.OpportunityId;
                opTxn.Core_Opportunity_Name__c = opportunities.get(approvedOP.OpportunityId).Name;
                opTxn.Core_Opportunity_Type__c = opportunities.get(approvedOP.OpportunityId).Core_Opportunity_Type__c;
                
                //Get Transaction Type via custom setting
                opTxn.Core_Transaction_Type__c = Core_Commissionable_Transaction_Type__c.getInstance('Any Opportunity Product').Core_Commissionable_Transaction_Type__c;
                
                //Get BU Short Name 
                opTxn.Core_Approved_BU_Short_Name__c = approvedOP.Core_BU_Short_Name__c;
                
                //Map team-member level attributes for each team member matching this opportunity
                for (ID otmID : opportunityTeamMembers.keySet()) {  
                    OpportunityTeamMember otm = opportunityTeamMembers.get(otmId);
                    
                    // Add to commissions only if the team member is Employee AND if the team member role is valid (listed in Core_Commissions_Percent_Contribution__c)
                    if (otm.OpportunityId == approvedOP.OpportunityId &&
                        users.get(otm.UserId).Core_Employee_Type_Code__c == 'EMP' && Core_Commissions_Percent_Contribution__c.getInstance(otm.TeamMemberRole) != null) {
                            txn = new Core_Commissionable_Transaction__c();
                            txn.Core_Employee_ID__c = otm.UserId;
                            txn.Core_Employee_Name__c = users.get(otm.UserId).Name;
                            txn.Core_WWID__c = users.get(otm.UserId).Core_WWID__c;
                            txn.Core_Opportunity_Team_Member_Role__c = otm.TeamMemberRole;
                            txn.Core_Percent_Contribution__c = Core_Commissions_Percent_Contribution__c.getInstance(otm.TeamMemberRole).Core_Percent_Contribution__c;
                            
                            
                            //Gather transaction attributes above the user level, add to newTxn        
                            txn.Core_Source_ID__c = opTxn.Core_Source_ID__c;
                            txn.Core_Transaction_Timestamp__c = opTxn.Core_Transaction_Timestamp__c;
                            txn.Core_Account_ID__c = opTxn.Core_Account_ID__c;
                            txn.Core_Account_Name__c = opTxn.Core_Account_Name__c;
                            txn.Core_CIM_ID__c = opTxn.Core_CIM_ID__c;
                            txn.Core_Claim_Date__c = opTxn.Core_Claim_Date__c;
                            txn.Core_Last_Approved_Date__c = opTxn.Core_Last_Approved_Date__c;
                            txn.Core_Approved_Total_Price__c = opTxn.Core_Approved_Total_Price__c;
                            
                            txn.Core_Product2_ID__c = opTxn.Core_Product2_ID__c;
                            txn.Core_Product_Type__c = opTxn.Core_Product_Type__c;
                            
                            txn.Core_Status__c = opTxn.Core_Status__c;
                            txn.Core_Opportunity__c = opTxn.Core_Opportunity__c;
                            txn.Core_Opportunity_Name__c = opTxn.Core_Opportunity_Name__c;
                            txn.Core_Opportunity_Type__c = opTxn.Core_Opportunity_Type__c;
                            txn.Core_Transaction_Type__c = opTxn.Core_Transaction_Type__c;
                            txn.Core_Approved_BU_Short_Name__c = opTxn.Core_Approved_BU_Short_Name__c;
                            //START - US102130: CMSSN: Send Account Prime and KPI Product Group to Commissions
                            txn.Core_Approved_KPI_Prod_Grp__c = opTxn.Core_Approved_KPI_Prod_Grp__c;
                            txn.Core_Approved_Prime_AccountName__c = opTxn.Core_Approved_Prime_AccountName__c;
                            //END - US102130: CMSSN: Send Account Prime and KPI Product Group to Commissions
                            //START - US106358: CMSSN: Send Product Segment to Commissions
                            txn.Core_Product_Segment__c = opTxn.Core_Product_Segment__c;
                            //END - US106358: CMSSN: Send Product Segment to Commissions
                            
                            //START - US106973: CMSSN: Send Additional Fields to Commissions Added - Core_Approved_BU_Product_Segment__c & Core_Approved_Sales_Group__c
                            txn.Core_Approved_Sales_Group__c = opTxn.Core_Approved_Sales_Group__c; 
                            txn.Core_Approved_BU_Product_Segment__c = opTxn.Core_Approved_BU_Product_Segment__c;
                            //END - US106973: CMSSN: Send Additional Fields to Commissions Added - Core_Approved_BU_Product_Segment__c & Core_Approved_Sales_Group__c
                            newTxns.add(txn);
                        }
                    
                }
            }
            
            insert newTxns;
        }
    }*/
    
    /*
* Method name  : oppLineCommissionTxnNewLogic()
* Description  : Check the combinition of 'BU short Name, Sales group, Prime account name , Opp product segment and BU product segment.
*                US176770 - SMG 2019: CMSSN- Only Send Data for Certain Combinations
* Return Type  : Boolean
* Parameter    : List of Opportunity Line items
*/ 
   /* public static Boolean oppLineCommissionTxnNewLogic ( Map<String, Core_Commission_Account_BU_SG_Setting__c> CustSettingsMap, OpportunityLineItem op) {
        
        // START: US176770SMG 2019: CMSSN- Only Send Data for Certain Combinations Dt:2/18/2019
        Boolean isCommissionTxn = false;
        String approvedBUShortName;
        String approvedSalesGroup;
        String approvedPrimeAccountNm;
        String approvedOppProdSeg;
        String approvedBUProdSeg;
        
        
        String finalCommissionKey, commisionKey1, commisionKey2, commisionKey3,commisionKey4,commisionKey5,commisionKey6,commisionKey7,commisionKey8,commisionKey9,commisionKey10;
        String commisionKey11, commisionKey12, commisionKey13,commisionKey14,commisionKey15,commisionKey16,commisionKey17 ;
        
        
        if(op.Core_BU_Short_Name__c ==null || op.Core_BU_Short_Name__c== 'null' || op.Core_BU_Short_Name__c=='Null' || op.Core_BU_Short_Name__c=='NULL'  ){
            approvedBUShortName = '<any>';
        }else{
            approvedBUShortName = (op.Core_BU_Short_Name__c).toLowerCase() ; 
        }
        
        if(op.Core_Opp_Approved_Sales_Group__c ==null || op.Core_Opp_Approved_Sales_Group__c== 'null' || op.Core_Opp_Approved_Sales_Group__c=='Null' || op.Core_Opp_Approved_Sales_Group__c=='NULL'  ){
            approvedSalesGroup = '<any>';
        }else{
            approvedSalesGroup = (op.Core_Opp_Approved_Sales_Group__c).toLowerCase() ; 
        }
        if(op.Core_Approved_Prime_Account_Name__c ==null || op.Core_Approved_Prime_Account_Name__c== 'null' || op.Core_Approved_Prime_Account_Name__c=='Null' || op.Core_Approved_Prime_Account_Name__c=='NULL'  ){
            approvedPrimeAccountNm = '<any>';
        }else{
            approvedPrimeAccountNm = (op.Core_Approved_Prime_Account_Name__c).toLowerCase() ; 
        }
        if(op.Core_Approved_Opp_Product_Segment__c ==null || op.Core_Approved_Opp_Product_Segment__c== 'null' || op.Core_Approved_Opp_Product_Segment__c=='Null' || op.Core_Approved_Opp_Product_Segment__c=='NULL'  ){
            approvedOppProdSeg = '<any>';
        }else{
            approvedOppProdSeg = (op.Core_Approved_Opp_Product_Segment__c).toLowerCase() ; 
        }
        if(op.Core_BU_Product_Segment__c ==null || op.Core_BU_Product_Segment__c== 'null' || op.Core_BU_Product_Segment__c=='Null' || op.Core_BU_Product_Segment__c=='NULL'  ){
            approvedBUProdSeg = '<any>';
        }else{
            approvedBUProdSeg = (op.Core_BU_Product_Segment__c).toLowerCase() ; 
        }
        
        
        
        commisionKey1  ='<any>'+'_'+'<any>'+'_'+'<any>'+'_'+'<any>'; // all product will be allowed for commision 
        commisionKey2  =approvedBUShortName.trim()+'_'+'<any>'+'_'+'<any>'+'_'+'<any>'+'_'+'<any>'; // if BU short name PSG , 
        commisionKey3  =approvedBUShortName.trim()+'_'+approvedSalesGroup.trim()+'_'+'<Any>'+'_'+'<any>'+'_'+'<any>'; 
        commisionKey4  =approvedBUShortName.trim()+'_'+approvedSalesGroup.trim()+'_'+approvedPrimeAccountNm.trim()+'_'+'<any>'+'_'+'<any>'; 
        commisionKey5  =approvedBUShortName.trim()+'_'+approvedSalesGroup.trim()+'_'+approvedPrimeAccountNm.trim()+'_'+approvedOppProdSeg.trim()+'_'+'<any>';
        commisionKey6  =approvedBUShortName.trim()+'_'+approvedSalesGroup.trim()+'_'+approvedPrimeAccountNm.trim()+'_'+'<any>'+'_'+approvedBUProdSeg.trim();
        commisionKey7  =approvedBUShortName.trim()+'_'+approvedSalesGroup.trim()+'_'+approvedPrimeAccountNm.trim()+'_'+approvedOppProdSeg.trim() +'_'+approvedBUProdSeg.trim();
        commisionKey8  =approvedBUShortName.trim()+'_'+approvedSalesGroup.trim()+'_'+'<any>'+'_'+approvedOppProdSeg.trim()+'_'+approvedBUProdSeg.trim();
        commisionKey9  =approvedBUShortName.trim()+'_'+approvedSalesGroup.trim()+'_'+'<any>'+'_'+approvedOppProdSeg.trim()+'_'+'<any>';
        commisionKey10 =approvedBUShortName.trim()+'_'+approvedSalesGroup.trim()+'_'+'<any>'+'_'+'<any>'+'_'+approvedBUProdSeg.trim();
        commisionKey11 =approvedBUShortName.trim()+'_'+'<any>'+'_'+'<any>'+'_'+approvedOppProdSeg.trim()+'_'+approvedBUProdSeg.trim();
        commisionKey12 =approvedBUShortName.trim()+'_'+'<any>'+'_'+'<any>'+'_'+approvedOppProdSeg.trim()+'_'+'<any>';
        commisionKey13 =approvedBUShortName.trim()+'_'+'<any>'+'_'+'<any>'+'_'+'<any>'+'_'+approvedBUProdSeg.trim();
        commisionKey14 =approvedBUShortName.trim()+'_'+'<any>'+'_'+approvedPrimeAccountNm.trim()+'_'+approvedOppProdSeg.trim()+'_'+approvedBUProdSeg.trim();
        commisionKey15 =approvedBUShortName.trim()+'_'+'<any>'+'_'+approvedPrimeAccountNm.trim()+'_'+'<any>'+'_'+'<any>';
        commisionKey16 =approvedBUShortName.trim()+'_'+'<any>'+'_'+approvedPrimeAccountNm.trim()+'_'+approvedOppProdSeg.trim()+'_'+'<any>';
        commisionKey17 =approvedBUShortName.trim()+'_'+'<any>'+'_'+approvedPrimeAccountNm.trim()+'_'+'<any>'+'_'+approvedBUProdSeg.trim();
        
        finalCommissionKey = '';        
        if(CustSettingsMap.containsKey(commisionKey1)){
            finalCommissionKey = commisionKey1;
        }else if(CustSettingsMap.containsKey(commisionKey2)){
            finalCommissionKey = commisionKey2;
        }else if(CustSettingsMap.containsKey(commisionKey3)){
            finalCommissionKey = commisionKey3;
        }else if(CustSettingsMap.containsKey(commisionKey4)){
            finalCommissionKey = commisionKey4;
        }else if(CustSettingsMap.containsKey(commisionKey5)){
            finalCommissionKey = commisionKey5;
        }else if(CustSettingsMap.containsKey(commisionKey6)){
            finalCommissionKey = commisionKey6;
        }else if(CustSettingsMap.containsKey(commisionKey7)){
            finalCommissionKey = commisionKey7;
        }else if(CustSettingsMap.containsKey(commisionKey8)){
            finalCommissionKey = commisionKey8;
        }else if(CustSettingsMap.containsKey(commisionKey9)){
            finalCommissionKey = commisionKey9;
        }else if(CustSettingsMap.containsKey(commisionKey10)){
            finalCommissionKey = commisionKey10;
        }else if(CustSettingsMap.containsKey(commisionKey11)){
            finalCommissionKey = commisionKey11;
        }else if(CustSettingsMap.containsKey(commisionKey12)){
            finalCommissionKey = commisionKey12;
        }else if(CustSettingsMap.containsKey(commisionKey13)){
            finalCommissionKey = commisionKey13;
        }else if(CustSettingsMap.containsKey(commisionKey14)){
            finalCommissionKey = commisionKey14;
        }else if(CustSettingsMap.containsKey(commisionKey15)){
            finalCommissionKey = commisionKey15;
        }else if(CustSettingsMap.containsKey(commisionKey16)){
            finalCommissionKey = commisionKey16;
        }else if(CustSettingsMap.containsKey(commisionKey17)){
            finalCommissionKey = commisionKey17;
        }
        
        if(finalCommissionKey <> '' && op.Core_Claim_Date__c >= CustSettingsMap.get(finalCommissionKey).Core_Claim_Date_From__c && op.Core_Claim_Date__c <= CustSettingsMap.get(finalCommissionKey).Core_Claim_Date_To__c){
            isCommissionTxn = true;
        }
        return isCommissionTxn;
        // END : US176770SMG 2019: CMSSN- Only Send Data for Certain Combinations Dt:2/18/2019
    }*/
    /*
* Method name  : setBUShortName()
* Description  : Query and Process the records to update BU Shortname on Opty line items
* Return Type  : VOID
* Parameter    : List of Opportunity Line items
*/ 
    /*public static void setBUShortName(List<OpportunityLineItem> newItems){
Map<OpportunityLineItem,List<Core_BU_Mapping_Table__c>> lineItemBUTableMap= new Map<OpportunityLineItem,List<Core_BU_Mapping_Table__c>>();        
List<Core_BU_Mapping_Table__c> listOfBUShortName = new List<Core_BU_Mapping_Table__c>();
Map<String,Id> mapOfBUShrotNames = new Map<String,Id>();       
List<OpportunityLineItem> failedList = new List<OpportunityLineItem>();        
listOfBUShortName = [SELECT Core_BU_Segment__c,Core_BU_Shortname__c,Core_LOB_Code__c,Core_Product_Application__c,Core_Product_Segment__c,Core_Weightage__c,isDeleted,Name,Core_Product_Type__c FROM Core_BU_Mapping_Table__c where isDeleted=false];    

//DE30417 - Adding null pointer check for listOfBUShortName on the if condition -- Ashwin
if(newItems != null && listOfBUShortName != null && newItems.size()>0 && listOfBUShortName.size()>0){
for(OpportunityLineItem lineItemObj: newItems){                                                        
//   if(!lineItemObj.Core_Product2_LOB_Code__c.EqualsIgnoreCase('Write In Product')){ //US102413-Removed if block condition 'Write In Product--Rajesh                                         
for(Core_BU_Mapping_Table__c mappingTableObj:listOfBUShortName){                        
//0001
if(mappingTableObj.Core_Product_Type__c==null && 
(mappingTableObj.Core_LOB_Code__c==null) &&
mappingTableObj.Core_Product_Segment__c==null && 
lineItemObj.Core_Product_Application__c!=null && 
mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c){
nextChk=0001;
lineItemBUTableMap =  alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}
//0011
else if(mappingTableObj.Core_Product_Type__c==null && 
(mappingTableObj.Core_LOB_Code__c==null ) &&
lineItemObj.Core_Product_Segment__c!=null && 
mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c &&
mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
lineItemObj.Core_Product_Application__c!=null){
nextChk=0011;
lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}
//0010
else if(mappingTableObj.Core_Product_Type__c==null && 
(mappingTableObj.Core_LOB_Code__c==null ) &&
mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
lineItemObj.Core_Product_Segment__c!=null && 
mappingTableObj.Core_Product_Application__c== null){
nextChk=0010;
lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}
//0100
else if(mappingTableObj.Core_Product_Type__c==null && 
(mappingTableObj.Core_LOB_Code__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_LOB_Code__c!=null &&
lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_LOB_Code__c)) || ((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c))) &&                            
mappingTableObj.Core_Product_Segment__c==null && 
mappingTableObj.Core_Product_Application__c== null){
nextChk=0100;
lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}
//0101
else if(mappingTableObj.Core_Product_Type__c==null && 
(mappingTableObj.Core_LOB_Code__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_LOB_Code__c!=null &&
lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_LOB_Code__c)) || (lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c) && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
mappingTableObj.Core_Product_Segment__c==null && 
mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
lineItemObj.Core_Product_Application__c!=null){
nextChk=0101;
lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);


}
//0111
else if(mappingTableObj.Core_Product_Type__c==null && 
mappingTableObj.Core_LOB_Code__c!=null &&
(mappingTableObj.Core_LOB_Code__c==lineItemObj.Core_Division__c  ||(lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_LOB_Code__c) && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric())) || (lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c) && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                     
mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
lineItemObj.Core_Product_Application__c!=null){
nextChk=0111;
lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}
//0110
else if(mappingTableObj.Core_Product_Type__c==null && 
(mappingTableObj.Core_LOB_Code__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_LOB_Code__c!=null && lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_LOB_Code__c))|| (lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c)  && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
lineItemObj.Core_Product_Segment__c !=null &&
mappingTableObj.Core_Product_Application__c== null){
nextChk=0110;
lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}
//1000
else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
lineItemObj.Core_Product_Type__c!=null && 
(mappingTableObj.Core_LOB_Code__c==null ) &&
mappingTableObj.Core_Product_Segment__c==null && 
mappingTableObj.Core_Product_Application__c== null){
nextChk=1000;
lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}
//1010
else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
lineItemObj.Core_Product_Type__c !=null && 
(mappingTableObj.Core_LOB_Code__c==null ) &&
mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
lineItemObj.Core_Product_Segment__c!=null && 
mappingTableObj.Core_Product_Application__c== null){
nextChk=1010;
lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}
//1001
else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
lineItemObj.Core_Product_Type__c!=null &&                             
mappingTableObj.Core_LOB_Code__c==null  &&
mappingTableObj.Core_Product_Segment__c==null && 
mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
lineItemObj.Core_Product_Application__c!=null){
nextChk=1001;
lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}
//1011
else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
lineItemObj.Core_Product_Type__c !=null && 
(mappingTableObj.Core_LOB_Code__c==null ) &&               
mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
lineItemObj.Core_Product_Segment__c!=null && 
mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
lineItemObj.Core_Product_Application__c!=null){
nextChk=1011;
lineItemBUTableMap =  alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}

//1100
else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
lineItemObj.Core_Product_Type__c !=null && 
(mappingTableObj.Core_LOB_Code__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_LOB_Code__c!=null && lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_LOB_Code__c)) || (lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c)  && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                                        
mappingTableObj.Core_Product_Segment__c== null && 
mappingTableObj.Core_Product_Application__c== null){
nextChk=1100;
lineItemBUTableMap =  alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}
//1101
else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
lineItemObj.Core_Product_Type__c!=null && 
(mappingTableObj.Core_LOB_Code__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_LOB_Code__c!=null && lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_LOB_Code__c)) || (lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c) && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
mappingTableObj.Core_Product_Segment__c== null && 
mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
lineItemObj.Core_Product_Application__c!=null){
nextChk=1101;
lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}
//1110
else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
lineItemObj.Core_Product_Type__c !=null && 
(mappingTableObj.Core_LOB_Code__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_LOB_Code__c!=null && lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_LOB_Code__c)) || (lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c)  && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
lineItemObj.Core_Product_Segment__c!=null &&
mappingTableObj.Core_Product_Application__c== null){
nextChk=1110;
lineItemBUTableMap =  alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}
//1111
else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
lineItemObj.Core_Product_Type__c!=null && 
(mappingTableObj.Core_LOB_Code__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_LOB_Code__c!=null && lineItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingTableObj.Core_LOB_Code__c)) || (lineItemObj.Core_Product2_LOB_Code__c.contains(mappingTableObj.Core_BU_Shortname__c)  && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
lineItemObj.Core_Product_Segment__c !=null && 
mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
lineItemObj.Core_Product_Application__c!=null){
nextChk=1111;
lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);

}
}
// } // US102413-End of block condition 'Write In Product--Rajesh  
if(lineItemBUTableMap.get(lineItemObj)!=null && lineItemBUTableMap.get(lineItemObj).size()==1){                 
lineItemObj.Core_BU_Mapping_record__c = lineItemBUTableMap.get(lineItemObj)[0].Id;                      

}else if(lineItemBUTableMap.get(lineItemObj)==null || lineItemBUTableMap.get(lineItemObj).size()>1 || lineItemBUTableMap.get(lineItemObj).size()==0){

failedList.add(lineItemObj);                    
}                                                
} //end of for loop//
if(failedList.size()>0){
Insert_logexception(failedList,label.Core_BU_ExceptionMsg);
}

} 

}*/
    
    
    
    /*
* Method name  : alignMapValues()
* Description  : Creates a Map of maultiple matching records and removes existing if it doesnt match with OLI record while checking fornother fields.
* Return Type  : Map<OpportunityLineItem,list<Core_BU_Mapping_Table__c>>
* Parameter    : (Core_BU_Mapping_Table__c mappingObj,OpportunityLineItem lItemObj, Map<OpportunityLineItem,list<Core_BU_Mapping_Table__c>> buMap
*/ 
    private static  Map<OpportunityLineItem,list<Core_BU_Mapping_Table__c>> alignMapValues(Core_BU_Mapping_Table__c mappingObj,OpportunityLineItem lItemObj, Map<OpportunityLineItem,list<Core_BU_Mapping_Table__c>> buMap){
        List<Core_BU_Mapping_Table__c> buMappingList = new List<Core_BU_Mapping_Table__c>();        
        List<Core_BU_Mapping_Table__c> tempBUMappingList = new List<Core_BU_Mapping_Table__c>();            
        if(!buMap.containsKey(lItemObj)){
            buMappingList.add(mappingObj);
            buMap.put(lItemObj,buMappingList);  
            
            tempxtChk=nextChk;
        }else {                  
            buMappingList = buMap.get(lItemObj);
            
            for(Core_BU_Mapping_Table__c mapTable:buMappingList){                   
                if((lItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mapTable.Core_BU_Shortname__c) || lItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingObj.Core_BU_Shortname__c) || (mapTable.Core_LOB_Code__c!=null && lItemObj.Core_Division__c==null && lItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mapTable.Core_LOB_Code__c)) || (mappingObj.Core_LOB_Code__c!=null && lItemObj.Core_Division__c==null && lItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mappingObj.Core_LOB_Code__c))||(String.isBlank(mappingObj.Core_Product_Segment__c) &&  !String.isBlank(mappingObj.Core_Product_Application__c)))&& mapTable.Core_Weightage__c <= mappingObj.Core_Weightage__c ){ 
                    tempBUMappingList.add(mappingObj); 
                    
                }else if(mapTable.Core_Weightage__c < mappingObj.Core_Weightage__c){
                    tempBUMappingList.add(mappingObj); 
                    
                }else if(mapTable.Core_Weightage__c > mappingObj.Core_Weightage__c){
                    tempBUMappingList.add(mapTable); 
                    
                }else if(tempxtChk>nextChk && mappingObj.Core_LOB_Code__c==null && lItemObj.Core_Division__c==null && mapTable.Core_Weightage__c <= mappingObj.Core_Weightage__c && !lItemObj.Core_Product2_LOB_Code__c.containsIgnoreCase(mapTable.Core_BU_Shortname__c) || (mapTable.Core_Weightage__c <= mappingObj.Core_Weightage__c && String.isBlank(mappingObj.Core_Product_Segment__c) && !String.isBlank( mappingObj.Core_Product_Application__c))){
                    tempBUMappingList.add(mapTable); 
                }
                tempxtChk=nextChk;
            } 
            buMap.put(lItemObj,tempBUMappingList);                  
        }       
        
        return buMap;
    }
    
    /*
* Method name  : Insert_logexception
* Description  : This Method used to create a BU Mapping  calculation failed records in Exception object.
* Return Type  : Map<OpportunityLineItem,list<Core_BU_Mapping_Table__c>>
* Parameter    : (OpportunityLineItem opplineitem,ExceptionMsg).
*/ 
    Public static void Insert_logexception(list<OpportunityLineItem> opplineitem,String ExceptionMsg){
        if(ExceptionMsg != null){
            list<Core_Exceptions__c> exceplist=new list<Core_Exceptions__c>();
            for(OpportunityLineItem opp: opplineitem){
                Core_Exceptions__c excep=new Core_Exceptions__c();
                if(Trigger.isExecuting){
                    excep.Core_Class_Name__c='Core_OpportunityLineItemHandler';
                    excep.Core_Method_Name__c='setBUShortName';
                    excep.Core_Record_Id__c=opp.OpportunityId; 
                }
                /*if(system.isBatch()){
                    excep.Core_Class_Name__c='Core_OpportunityLineItem_BatchClass';
                    excep.Core_Method_Name__c=' Execute method ';
                    excep.Core_Record_Id__c=opp.Id;
                    excep.Core_Status__c='Failed';
                    excep.Core_Retry_Counter__c=1;
                    excep.Core_Next_Scheduled_Run__c=System.now();
                    
                }*/
                excep.Core_Exception__c=ExceptionMsg;
                excep.Core_IPS_Object_Name__c='OpportunityLineItem';                                                   
                excep.Core_Login_User_Id__c=userInfo.getUserId();
                exceplist.add(excep);
            } //End of for loop//
            if(exceplist != null && !(exceplist.isEmpty())){
                Database.insert(exceplist);
            }             
        }
    }
    
    //US83104 - Added beforeInsertForecastRecords updateForecastRecords and deleteForecastRecords methods for Forecasting -- Ashwin    
    /*
* Method name  : beforeInsertForecastRecords
* Description  : This Method used to create records for Forecast on creation of an Opportunity Line Item.
* Return Type  : void
* Parameter    : (list<OpportunityLineItem> opplineitem).
*/ 
    
    public static void beforeInsertForecastRecords(list<OpportunityLineItem> newopplineitem){
        boolean oliPresentFlag = false;
        Map<Id, Boolean> opptyContainsFCMap = new Map<Id, Boolean>();
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> opptyLineItemVsFCMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
        Set<Id> opptyIdSet = new Set<Id>();
        List<OpportunityLineItem> tempList;
        
        for(OpportunityLineItem oli : newopplineitem){
            opptyIdSet.add(oli.OpportunityId);
        }
        
        List<Core_Opp_FC_Prod_Schedule__c> tempList1;
        Map<Id, OpportunityLineItem> oliPresentMap = new Map<Id, OpportunityLineItem>([SELECT id, Quantity, OpportunityId, Core_Vendor__c, Core_Status__c,Core_PW_Sales_Price__c,Core_PW_Quantity__c FROM OpportunityLineItem WHERE OpportunityId IN :opptyIdSet]);
        
        if(oliPresentMap != null && !oliPresentMap.isEmpty()){
            for(Core_Opp_FC_Prod_Schedule__c fc : [SELECT id, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Opportunity__c, Core_Opp_FC_Product__r.Name, Core_Opp_FC_Quarter_Date__c, Core_Opp_Line_Item_RecordID__c FROM Core_Opp_FC_Prod_Schedule__c WHERE (Core_Opp_Line_Item_RecordID__c IN :oliPresentMap.keySet() OR (Core_Opp_FC_Opportunity__c = :opptyIdSet AND Core_Is_Post_Win__c = true)) AND Core_Opp_FC_isdeleted__c = false ORDER BY Core_Opp_FC_Product__r.Name,Core_Opp_FC_Quarter_Date__c]){
                tempList1 = new List<Core_Opp_FC_Prod_Schedule__c>();
                if(opptyLineItemVsFCMap.get(fc.Core_Opp_Line_Item_RecordID__c) != null){
                    tempList1 = opptyLineItemVsFCMap.get(fc.Core_Opp_Line_Item_RecordID__c);
                    tempList1.add(fc); 
                    opptyLineItemVsFCMap.put(fc.Core_Opp_Line_Item_RecordID__c, tempList1);
                }else{
                    tempList1.add(fc);
                    opptyLineItemVsFCMap.put(fc.Core_Opp_Line_Item_RecordID__c, tempList1);
                }      
            }
            
            //if Forecast Map is not empty then check which opportunities have forecast and insert new forecast only for those oppty having existing forecast
            if(opptyLineItemVsFCMap.isEmpty()){
                checkOLIExists = true;
            }else {
                for(Id item : opptyLineItemVsFCMap.keySet()){
                    for(Core_Opp_FC_Prod_Schedule__c fc : opptyLineItemVsFCMap.get(item)){
                        if(fc.Core_Opp_FC_Approval_Status__c == 'Approved'){
                            approvedList.add(1);
                        }else if(fc.Core_Opp_FC_Approval_Status__c == 'Submitted'){
                            approvedList.add(2);
                        }else{
                            approvedList.add(0);
                        }
                    }
                    if(!approvedList.isEmpty())
                        break;
                }
            }
            
        }   
        
        
    }
    
    //US83104 - Added insertForecastRecords updateForecastRecords and deleteForecastRecords methods for Forecasting -- Ashwin    
    /*
* Method name  : insertForecastRecords
* Description  : This Method used to create records for Forecast on creation of an Opportunity Line Item.
* Return Type  : void
* Parameter    : (list<OpportunityLineItem> opplineitem).
*/ 
    
    public static void insertForecastRecords(list<OpportunityLineItem> newopplineitem,List<Core_Opp_FC_Prod_Schedule__c> oldFCRecs, Boolean migrateFlag){
        List<Core_Opp_FC_Prod_Schedule__c> forecastRecList = new List<Core_Opp_FC_Prod_Schedule__c>();
        List<String> divisionLogic = (Label.Core_FC_ForecastDivision).split(';');
        Integer numOfForecast = Integer.valueOf(Label.Core_FC_NumberOfQuarter); // Change to custom settings US852627:6QPS : Pending Items fixes-Sanket
        boolean oliPresentFlag = false;
        Map<Id, Boolean> opptyContainsFCMap = new Map<Id, Boolean>();
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> opptyLineItemVsFCMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> oliIdSet = new Set<Id>();
        String approvalStatus = '';
        List<Core_Opp_FC_Prod_Schedule__c> tempList;
        for(OpportunityLineItem oli : newopplineitem){
            
            opptyIdSet.add(oli.OpportunityId);
            oliIdSet.add(oli.Id);
        }
        
        
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> prodSortForecastMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
        Map<Id, OpportunityLineItem> oliMap = new Map<Id, OpportunityLineItem>([SELECT id, UnitPrice, Core_BU_Short_Name__c, Core_BU_Product_Segment__c,Core_PW_Sales_Price__c,Core_PW_Quantity__c FROM OpportunityLineItem WHERE id IN :oliIdSet]);
        
        List<Core_Opp_FC_Prod_Schedule__c> FCRecsList=[SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_FC_Product__r.Name, Core_Opp_FC_Quarter_Date__c,
                                                       Core_Opp_FC_Quarter__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c IN :opptyIdSet AND Core_Opp_FC_isdeleted__c = false ORDER BY Core_Opp_FC_Product__r.Name,Core_Opp_FC_Quarter_Date__c];
        if(!oldFCRecs.isEmpty() && FCRecsList.isEmpty()){
            FCRecsList=oldFCRecs;
        }
        
        for(Core_Opp_FC_Prod_Schedule__c fc :FCRecsList){
            tempList = new List<Core_Opp_FC_Prod_Schedule__c>();
            
            if(prodSortForecastMap.get(fc.Core_Opp_FC_Opportunity__c) != null){
                tempList = prodSortForecastMap.get(fc.Core_Opp_FC_Opportunity__c);
                tempList.add(fc); 
                prodSortForecastMap.put(fc.Core_Opp_FC_Opportunity__c, tempList);
            }else{
                tempList.add(fc);
                prodSortForecastMap.put(fc.Core_Opp_FC_Opportunity__c, tempList);
            }      
        }
        
        
        if(!newopplineitem.isEmpty() && !checkOLIExists && !donotCreate){
            //US852627:6QPS : Pending Items fixes, added CloseDate,Core_Quarter_Start_Date__c, Core_Number_of_Quarters__c in the query-Sanket
            Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>([SELECT id, CloseDate,Core_Quarter_Start_Date__c, Core_Number_of_Quarters__c, Core_First_Customer_Ship_Date__c, Core_Opportunity_Type__c, StageName FROM Opportunity WHERE Id IN :opptyIdSet]);
            for(OpportunityLineItem oli : newopplineitem){ 
                Decimal qtr = 0.00;
                Date considerDate = System.today();
                Decimal considerSalesPrice;
                if((opptyMap.get(oli.OpportunityId).StageName == 'Production Win' || opptyMap.get(oli.OpportunityId).StageName == 'Design Win') && oli.Core_Status__c!='Post-Win' 
                   && (opptyMap.get(oli.OpportunityId).Core_Opportunity_Type__c != null &&
                       opptyMap.get(oli.OpportunityId).Core_Opportunity_Type__c.containsIgnoreCase('Design'))
                  ){//TWC3123-4884 added StageName=Design Win 
                      //TWC3123-4884 If Opp stage is 'Design Win/Production Win or Post-Win Product it will consider PW_Sales_Price else UnitPrice field
                      considerSalesPrice = oliMap.get(oli.Id).Core_PW_Sales_Price__c;
                  }
                else{
                    considerSalesPrice = oliMap.get(oli.Id).UnitPrice;
                } 
                
                //If Opportunity Type is Deal then consider Decision Date else consider First Customer Ship Date
                if(opptyMap.get(oli.OpportunityId).Core_Opportunity_Type__c != null && opptyMap.get(oli.OpportunityId).Core_Opportunity_Type__c != ''){
                    if(prodSortForecastMap.get(oli.OpportunityId) != null){
                        considerDate = prodSortForecastMap.get(oli.OpportunityId)[0].Core_Opp_FC_Quarter_Date__c;
                        
                    }else{
                        if((opptyMap.get(oli.OpportunityId).Core_Opportunity_Type__c).containsIgnoreCase('Deal')){                      
                            considerDate = opptyMap.get(oli.OpportunityId).CloseDate;
                        }else if((opptyMap.get(oli.OpportunityId).Core_Opportunity_Type__c).containsIgnoreCase('Design')){
                            considerDate = opptyMap.get(oli.OpportunityId).Core_First_Customer_Ship_Date__c;
                        }
                        //Added change to start Quarter with 1 month less than that of the seleted date.
                        if(considerDate != null && String.valueOf(considerDate) != ''){
                            considerDate = considerDate.addMonths(-3);
                        }
                        
                    }
                    if(considerDate != null && String.valueOf(considerDate) != ''){
                        qtr = (Decimal)(considerDate.month())/3;
                        date newDate = considerDate.toStartOfMonth();
                        date fc_Qtr_date = System.today();
                        if(qtr >= 0 && qtr <= 1){
                            fc_Qtr_date = Date.newInstance(newDate.year(),1,newDate.day());
                            fc_Qtr_date = fc_Qtr_date.addMonths(3);
                        }   
                        else if(qtr > 1 && qtr <=2){
                            fc_Qtr_date = Date.newInstance(newDate.year(),4,newDate.day());
                            fc_Qtr_date = fc_Qtr_date.addMonths(3);
                        }               
                        else if(qtr > 2 && qtr <=3){
                            fc_Qtr_date = Date.newInstance(newDate.year(),7,newDate.day());
                            fc_Qtr_date = fc_Qtr_date.addMonths(3);
                        }               
                        else{
                            newDate = newDate.addYears(1);
                            fc_Qtr_date = Date.newInstance(newDate.year(),1,newDate.day());
                            //fc_Qtr_date = fc_Qtr_date.addMonths(3);
                        }
                        //US852627:6QPS : Pending Items fixes-Sanket
                        if(opptyMap.get(oli.OpportunityId).Core_Number_of_Quarters__c != null){
                            numOfForecast = integer.valueof(opptyMap.get(oli.OpportunityId).Core_Number_of_Quarters__c);
                        }
                        
                        for(Integer i=0; i<numOfForecast; i++){
                            Decimal qty = 0;
                            if(Core_Status.contains(oli.Core_Status__c)){
                                qty = 0;
                            }else{
                                //US617507 --6QPS : Oppty : Restrict the logic implemented in US605877 to only Deal Oppty--Starts
                                if((opptyMap.get(oli.OpportunityId).Core_Opportunity_Type__c).containsIgnoreCase('Deal')){                      
                                    qty = 0;
                                }else if((opptyMap.get(oli.OpportunityId).Core_Opportunity_Type__c).containsIgnoreCase('Design')){
                                    if((opptyMap.get(oli.OpportunityId).StageName == 'Production Win' || opptyMap.get(oli.OpportunityId).StageName == 'Design Win')&& oli.Core_Status__c !='Post-Win')  {//TWC3123-4884 added StageName=Design Win
                                        //TWC3123-4884 If Opp stage is 'Design Win/Production Win it will consider Core_PW_Quantity__c else Quantity field
                                        if(oli.Core_PW_Quantity__c!=null){
                                            qty =((oli.Core_PW_Quantity__c)/(Integer.valueOf(divisionLogic[i]))).round(System.RoundingMode.HALF_UP);
                                        }
                                        
                                    }else{//TWC3123-4884 else Quantity field will be considered for calculation
                                        if(oli.Quantity!=null){
                                            qty = ((oli.Quantity)/(Integer.valueOf(divisionLogic[i]))).round(System.RoundingMode.HALF_UP);
                                        }
                                        
                                    }  
                                  
                                }
                                
                                //US617507 --6QPS : Oppty : Restrict the logic implemented in US605877 to only Deal Oppty--Ends  
                                
                                
                            }
                            if(approvedList != null && !approvedList.isEmpty() && approvedList[i] == 1){
                                qty = 0;
                                
                                approvalStatus = 'Approved';
                            }else if(approvedList != null && !approvedList.isEmpty() && approvedList[i] == 2){
                                
                                qty = 0;
                                
                                
                                approvalStatus = 'Submitted';
                            }else {
                                approvalStatus = '';
                            }
                            //US98608 - Added BU ShortName and BU Product segment change  -- Ashwin
                            String LineItemId = null;
                            boolean isPostwin = true;
                            if(oli.core_status__c!='Post-Win'){
                                LineItemId = oli.Id;
                                isPostwin = false;
                            }
                            
                            if(i==0){      
                                forecastRecList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Is_Post_Win__c = isPostwin,Core_FC_Opportunity_Product__c=LineItemId,Core_Opp_FC_Opportunity__c = oli.OpportunityId,Core_Opp_Line_Item_RecordID__c = oli.Id, Core_Opp_FC_Product__c = oli.Product2Id, Core_Opp_FC_Quarter_Date__c = considerDate, Core_Opp_FC_Quantity__c = qty, Core_Opp_FC_isdeleted__c = false, Core_FC_Vendor__c = oli.Core_Vendor__c, Core_Opp_FC_Prod_Sales_Price__c = considerSalesPrice, Core_Opp_FC_Approval_Status__c = approvalStatus, Core_FC_BU_Product_Segment__c = oliMap.get(oli.id).Core_BU_Product_Segment__c,Core_FC_BU_Short_Name__c = oliMap.get(oli.id).Core_BU_Short_Name__c));
                            }else{
                                forecastRecList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Is_Post_Win__c = isPostwin,Core_FC_Opportunity_Product__c=LineItemId,Core_Opp_FC_Opportunity__c = oli.OpportunityId,Core_Opp_Line_Item_RecordID__c = oli.Id, Core_Opp_FC_Product__c = oli.Product2Id, Core_Opp_FC_Quarter_Date__c = fc_Qtr_date, Core_Opp_FC_Quantity__c = qty, Core_Opp_FC_isdeleted__c = false, Core_FC_Vendor__c = oli.Core_Vendor__c, Core_Opp_FC_Prod_Sales_Price__c = considerSalesPrice, Core_Opp_FC_Approval_Status__c = approvalStatus, Core_FC_BU_Product_Segment__c = oliMap.get(oli.Id).Core_BU_Product_Segment__c,Core_FC_BU_Short_Name__c = oliMap.get(oli.Id).Core_BU_Short_Name__c));
                                fc_Qtr_date = fc_Qtr_date.addMonths(3);
                            }
                        } 
                    }                   
                }
            }
            
            Set<Id> fcIdSet = new Set<Id>();
            List<Core_Opp_FC_Prod_Schedule__c> toLockRecords = new List<Core_Opp_FC_Prod_Schedule__c>();
            try{
                List<Core_Log_Entry__c> listFailedProdLineItems = new List<Core_Log_Entry__c>();
                Database.SaveResult[] srList = Database.insert(forecastRecList); //insert forecastRecList; // database.saveresult exception 
                for (Database.SaveResult sr : srList){
                    if(!sr.isSuccess()){
                        for(Database.Error error : sr.getErrors()) {
                         
                            
                            listFailedProdLineItems.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = error.getMessage(),Core_Origin__c='insertForcasts', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
                            
                        }
                       
                       
                    }else 
                        fcIdSet.add(sr.getId());
                }
                if(!fcIdSet.isEmpty()){
                    for(Core_Opp_FC_Prod_Schedule__c fc1 : [SELECT id, Name, Core_Opp_FC_Approval_Status__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Id IN : fcIdSet]){
                        if(fc1.Core_Opp_FC_Approval_Status__c == 'Approved' || fc1.Core_Opp_FC_Approval_Status__c == 'Submitted'){
                            toLockRecords.add(fc1);
                        }
                    }
                    Approval.LockResult[] lrList = Approval.lock(toLockRecords,false);
                }
                //TWC3123-5267 
                if(!listFailedProdLineItems.isEmpty()){
                    Database.insert(listFailedProdLineItems);
                }
                
            }catch(Exception e){
                PMP_Utility.logError(e, 'insertForcasts');
                
            }
        }
    }
    
    /*
* Method name  : deleteForecastRecords
* Description  : This Method used to delete records for Forecast on deletion of an Opportunity Line Item. Called from before delete
* Return Type  : void
* Parameter    : (list<OpportunityLineItem> opplineitem, Map<Id, OpportunityLineItem> oldOliMap).
*/ 
    
    public static void deleteForecastRecords(Map<Id, OpportunityLineItem> oldOliMap ){
        Set<Id> oliSet = oldOliMap.keySet();
        List<Core_Opp_FC_Prod_Schedule__c> fcRecListToBeUpdated = new List<Core_Opp_FC_Prod_Schedule__c>();
        List<Core_Opp_FC_Prod_Schedule__c> fcRecListToBeDeleted = new List<Core_Opp_FC_Prod_Schedule__c>();
        String opptyLineItemId = '';
        List<Core_Opp_FC_Prod_Schedule__c> forecastRecList = [SELECT id, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Quarter_Date__c, 
                                                              Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_Prod_Sales_Price__c, Core_FC_Vendor__c 
                                                              FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_Line_Item_RecordID__c IN : oliSet 
                                                              ORDER BY Core_Opp_Line_Item_RecordID__c,Core_FC_Vendor__c,Core_Opp_FC_Quarter_Date__c];
        
        //TWC3123-5267 Code scan issue start
        List<Id> foreCastIdList = new List<Id>();
        Map<Id,Boolean> isLockedMap = new Map<Id,Boolean>();
        for(Core_Opp_FC_Prod_Schedule__c fc : forecastRecList){
            foreCastIdList.add(fc.Id);
        }
        isLockedMap=Approval.isLocked(foreCastIdList);
        //TWC3123-5267 code scan issue end
        for(Core_Opp_FC_Prod_Schedule__c fc : forecastRecList){
            
            if(fc.Core_Opp_FC_Approval_Status__c == 'Approved' || fc.Core_Opp_FC_Approval_Status__c == 'Submitted' || fc.Core_Opp_FC_Approval_Status__c == 'Invalid'){
                
                opptyLineItemId = fc.Core_Opp_Line_Item_RecordID__c;
                fcRecListToBeUpdated.add(fc);
            }else if(fc.Core_Opp_Line_Item_RecordID__c == opptyLineItemId && (String.valueOf(fc.Core_Opp_FC_Approval_Status__c) == '' || fc.Core_Opp_FC_Approval_Status__c == null) && isLockedMap.get(fc.Id)==false){ //TWC3123-5267 replaced !Approval.isLocked(fc) with isLockedMap.get(fc.Id)==false to avoid isLocked() inside for loop
                
                if(oldOliMap.get(fc.Core_Opp_Line_Item_RecordID__c).core_status__c != 'Post-Win'){
                    fc.Core_Opp_FC_Quantity__c = 0;
                    fc.Core_Opp_FC_Prod_Sales_Price__c = 0.00;
                    fc.Core_Opp_FC_Approval_Status__c = 'Pending';
                    fcRecListToBeUpdated.add(fc);
                }
            }else{
                
                if(oldOliMap.get(fc.Core_Opp_Line_Item_RecordID__c).core_status__c != 'Post-Win'){
                    fcRecListToBeDeleted.add(fc);
                }
            }
            
        }
        if(!fcRecListToBeUpdated.isEmpty()){
            update fcRecListToBeUpdated;
            Approval.LockResult[] lrList = Approval.lock(fcRecListToBeUpdated,false);           
        }
        if(!fcRecListToBeDeleted.isEmpty()){
            try{
                delete fcRecListToBeDeleted;
            }catch(Exception e){
                PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler.deleteForecastRecords');
            }
        }
       
    }
    
    /*
* Method name  : updateForecastRecords
* Description  : This Method used to update records for Forecast on updation of an Opportunity Line Item. Called from before update
* Return Type  : void
* Parameter    : (list<OpportunityLineItem> opplineitem, Map<Id, OpportunityLineItem> oldOliMap).
*/ 
    
    public static void updateForecastRecords(List<OpportunityLineItem> newOppLineItem, Map<Id, OpportunityLineItem> oldOliMap){
        if(!updateForecastRecordsRecCheck){
            Set<Id> oliSet = oldOliMap.keySet();
            boolean counter = false;
            Integer count1 = 0;
            Integer numOfForecast = Integer.valueOf(Label.Core_FC_NumberOfQuarter);
            Set<Id> oliApprovedSet = new Set<Id>();
            Set<Id> fcApprovedSet = new Set<Id>();
            Map<Id, OpportunityLineItem> oliDeleteMap = new Map<Id, OpportunityLineItem>();
            List<String> divisionLogic = (Label.Core_FC_ForecastDivision).split(';');
            List<Core_Opp_FC_Prod_Schedule__c> updateFCList = new List<Core_Opp_FC_Prod_Schedule__c>();
            List<Core_Opp_FC_Prod_Schedule__c> updateFCList1 = new List<Core_Opp_FC_Prod_Schedule__c>();
            List<Core_Opp_FC_Prod_Schedule__c> tempList;
            
            Set<Id> OppIds= new Set<Id>();
            Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> prodSortForecastMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
            for(OpportunityLineItem oli1 : newOppLineItem){
                if(oli1.Core_Vendor__c != oldOliMap.get(oli1.Id).Core_Vendor__c || oli1.Core_Status__c != oldOliMap.get(oli1.Id).Core_Status__c 
                   || oli1.Quantity != oldOliMap.get(oli1.Id).Quantity || oli1.UnitPrice != oldOliMap.get(oli1.Id).UnitPrice 
                   || oli1.Core_BU_Product_Segment__c != oldOliMap.get(oli1.Id).Core_BU_Product_Segment__c 
                   || oli1.Core_BU_Short_Name__c != oldOliMap.get(oli1.Id).Core_BU_Short_Name__c 
                   || (oli1.Core_PW_Quantity__c !=oldOliMap.get(oli1.Id).Core_PW_Quantity__c /*&& oli1.Core_PW_Quantity__c !=null*/ && !(oli1.Quantity==oli1.Core_PW_Quantity__c && (oldOliMap.get(oli1.Id).Core_PW_Quantity__c==null)))
                   || (oli1.Core_PW_Sales_Price__c !=oldOliMap.get(oli1.Id).Core_PW_Sales_Price__c && oli1.Core_PW_Sales_Price__c!=null && !(oli1.UnitPrice==oli1.Core_PW_Sales_Price__c && (oldOliMap.get(oli1.Id).Core_PW_Sales_Price__c==null))
                      )){//US98608 - Added BU ShortName and BU Product segment change  -- Ashwin
                          count1++;
                      }
                OppIds.add(oli1.OpportunityId);
            }
            
            Map<Id,Opportunity> newOppMap = new Map<Id,Opportunity>([Select id,Name,Core_Opportunity_Type__c,StageName from Opportunity where Id IN :OppIds]);
            
            
            if(count1 > 0){
                List<Core_Opp_FC_Prod_Schedule__c> forecastRecList = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c,  
                                                                      Core_Opp_FC_Product__r.Name, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_FC_Last_Modified_Date__c, Core_FC_Vendor__c, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Approved_Date__c, Core_Core_FC_Appvd_SalesPrice__c, Core_Opp_FC_Prod_Sales_Price__c, Core_Opp_FC_Sched_Revenue__c, Core_FC_BU_Product_Segment__c, Core_FC_BU_Short_Name__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_Line_Item_RecordID__c IN : oliSet AND Core_Opp_FC_isdeleted__c = false ORDER BY Core_Opp_FC_Product__r.Name,Core_Opp_FC_Quarter_Date__c];
                //TWC3123-5267 code scan issue start
                List<Id> foreCastIdList = new List<Id>();
                Map<Id,Boolean> isLockedMap = new Map<Id,Boolean>();
                //TWC3123-5267 code scan issue end
                for(Core_Opp_FC_Prod_Schedule__c fc : forecastRecList){
                    foreCastIdList.add(fc.Id);//TWC3123-5267
                    tempList = new List<Core_Opp_FC_Prod_Schedule__c>();
                    if(prodSortForecastMap.get(fc.Core_Opp_Line_Item_RecordID__c) != null){
                        tempList = prodSortForecastMap.get(fc.Core_Opp_Line_Item_RecordID__c);
                        tempList.add(fc); 
                        prodSortForecastMap.put(fc.Core_Opp_Line_Item_RecordID__c, tempList);
                    }else{
                        tempList.add(fc);
                        prodSortForecastMap.put(fc.Core_Opp_Line_Item_RecordID__c, tempList);
                    }      
                }
                //TWC3123-5267code scan issue start
                isLockedMap=Approval.isLocked(foreCastIdList);
                
                //TWC3123-5267 code scan issue end
                List<Core_Opp_FC_Prod_Schedule__c> oldFCRecs=new List<Core_Opp_FC_Prod_Schedule__c>();
                for(OpportunityLineItem oli : newOppLineItem){ 
                    Integer i = 0;
                    if(prodSortForecastMap.get(oli.Id) != null){
                        for(Core_Opp_FC_Prod_Schedule__c fc : prodSortForecastMap.get(oli.Id)){
                            
                            Integer count = 0;  

                            if(oli.Core_Vendor__c != oldOliMap.get(oli.Id).Core_Vendor__c){
                                fc.Core_FC_Vendor__c = oli.Core_Vendor__c;
                                count++;
                            }
                            if(Core_Status.contains(oli.Core_Status__c)){ //PL->lost, will never come here
                                if(fc.Core_Opp_FC_Approval_Status__c != 'Submitted' && fc.Core_Opp_FC_Approval_Status__c != 'Approved'){
                                    fc.Core_Opp_FC_Quantity__c = 0;
                                    fc.Core_FC_Last_Modified_Date__c = System.today();
                                    count++;
                                } 
                               
                            }   
                            
                            if((Core_Status.contains(oldOliMap.get(oli.Id).Core_Status__c) && !Core_Status.contains(oli.Core_Status__c)) || (oli.Quantity != oldOliMap.get(oli.Id).Quantity && !Core_Status.contains(oli.Core_Status__c)) &&
                               newOppMap.get(oli.OpportunityId).Core_Opportunity_Type__c.containsIgnoreCase('Design')){
                                   //Re-calculation to be done and LMD will be removed when quantity changes and when status changes to pending/winApproved/Submitted from lost/cancelled etc.
                                   if(fc.Core_Opp_FC_Approval_Status__c == 'Submitted' || fc.Core_Opp_FC_Approval_Status__c == 'Approved'){
                                       oliApprovedSet.add(oli.Id);
                                     
                                   }else{
                                       oliDeleteMap.put(oli.Id, oli);
                                       oldFCRecs.add(fc);
                                       counter = true;
                                   }
                                  
                               }   
                            if(oli.UnitPrice != oldOliMap.get(oli.Id).UnitPrice && isLockedMap.get(fc.Id)==false){//TWC3123-5267 replaced !Approval.isLocked(fc) with  isLockedMap.get(fc.Id)==false to avoid isLocked() inside for loop
                                fc.Core_Opp_FC_Prod_Sales_Price__c = oli.UnitPrice;
                                
                                count++;
                            }
                            
                            //--> Start --Added By Hira as part of TWC3123-5561
                            if(oli.Core_PW_Sales_Price__c != oldOliMap.get(oli.Id).Core_PW_Sales_Price__c && isLockedMap.get(fc.Id)==false && !(oli.UnitPrice==oli.Core_PW_Sales_Price__c && oldOliMap.get(oli.Id).Core_PW_Sales_Price__c==null) && oli.Core_PW_Sales_Price__c!=null){//TWC3123-5267 replaced !Approval.isLocked(fc) with  isLockedMap.get(fc.Id)==false to avoid isLocked() inside for loop
                                fc.Core_Opp_FC_Prod_Sales_Price__c = oli.Core_PW_Sales_Price__c;
                                
                                count++;
                            }
                            
                            
                            
                            if(oli.Core_PW_Quantity__c != oldOliMap.get(oli.Id).Core_PW_Quantity__c && /*oli.Core_PW_Quantity__c!=null &&*/ !(oli.Quantity==oli.Core_PW_Quantity__c && oldOliMap.get(oli.Id).Core_PW_Quantity__c==null) &&
                               (newOppMap.get(oli.OpportunityId).StageName=='Design Win' || newOppMap.get(oli.OpportunityId).StageName=='Production Win')
                               && newOppMap.get(oli.OpportunityId).Core_Opportunity_Type__c.containsIgnoreCase('Design')){//TWC3123-5267 replaced !Approval.isLocked(fc) with  isLockedMap.get(fc.Id)==false to avoid isLocked() inside for loop
                                  
                                   if(fc.Core_Opp_FC_Approval_Status__c == 'Submitted' || fc.Core_Opp_FC_Approval_Status__c == 'Approved'){
                                       oliApprovedSet.add(oli.Id);
                                  
                                   }else{
                                       oliDeleteMap.put(oli.Id, oli);
                                       oldFCRecs.add(fc);
                                       counter = true;
                                   }
                                
                               }
                            //--> End --TWC3123-5561
                            
                            if(oli.Core_BU_Product_Segment__c != oldOliMap.get(oli.Id).Core_BU_Product_Segment__c && fc.Core_FC_BU_Product_Segment__c != oli.Core_BU_Product_Segment__c){
                                fc.Core_FC_BU_Product_Segment__c = oli.Core_BU_Product_Segment__c;
                                count++;
                            }
                            if(oli.Core_BU_Short_Name__c != oldOliMap.get(oli.Id).Core_BU_Short_Name__c && fc.Core_FC_BU_Short_Name__c != oli.Core_BU_Short_Name__c){
                                fc.Core_FC_BU_Short_Name__c = oli.Core_BU_Short_Name__c;
                                count++; 
                            }
                            
                            if(count>0){   
                                fcApprovedSet.add(fc.Id);
                                updateFCList.add(fc); 
                            }
                            //}
                        }
                    }
                }
                //Checking if multiple operation on OLI and getting added for recalculation.
                for(Id ids : oliApprovedSet){
                    if(oliDeleteMap.keySet().contains(ids)){
                        oliDeleteMap.remove(ids);
                    }
                }
                if(!oliDeleteMap.isEmpty()){
                    
                    deleteForecastRecords(oliDeleteMap);
                    insertForecastRecords(oliDeleteMap.values(),oldFCRecs,true);
                }   
                          
                if(!updateFCList.isEmpty() && !counter){                
                    
                    try{
                        update updateFCList;
                    }catch(Exception e){
                        PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler.updateForecastRecords');
                    }               
                } 
                if(!oliApprovedSet.isEmpty()){
                    for(OpportunityLineItem oli : newOppLineItem){
                        for(Integer i=0; i<prodSortForecastMap.get(oli.Id).size(); i++){
                            if(oliApprovedSet.contains(prodSortForecastMap.get(oli.Id)[i].Core_Opp_Line_Item_RecordID__c) && newOppMap.get(oli.OpportunityId).Core_Opportunity_Type__c.containsIgnoreCase('Design')){ 
                                if(prodSortForecastMap.get(oli.Id)[i].Core_Opp_FC_Approval_Status__c != 'Approved' && prodSortForecastMap.get(oli.Id)[i].Core_Opp_FC_Approval_Status__c != 'Submitted'){
                                   if(!(Core_Status.contains(oli.Core_Status__c))){  
                                    
                                    //-->Added if else logic as part of TWC3123-5561 for PW Qty & PW SalesPrice 
                                    if(!(newOppMap.get(oli.OpportunityId).StageName=='Design Win' || newOppMap.get(oli.OpportunityId).StageName == 'Production Win') && newOppMap.get(oli.OpportunityId).Core_Opportunity_Type__c.containsIgnoreCase('Design')){
                                        prodSortForecastMap.get(oli.Id)[i].Core_Opp_FC_Quantity__c = ((oli.Quantity)/(Integer.valueOf(divisionLogic[i]))).round(System.RoundingMode.HALF_UP);
                                    }else{
                                        
                                        if(!(oli.Quantity==oli.Core_PW_Quantity__c && oldOliMap.get(oli.Id).Core_PW_Quantity__c==null)){
                                            
                                            if(oli.Core_PW_Quantity__c!=null){
                                                prodSortForecastMap.get(oli.Id)[i].Core_Opp_FC_Quantity__c = ((oli.Core_PW_Quantity__c)/(Integer.valueOf(divisionLogic[i]))).round(System.RoundingMode.HALF_UP);
                                            }else{
                                                prodSortForecastMap.get(oli.Id)[i].Core_Opp_FC_Quantity__c = ((oli.Quantity)/(Integer.valueOf(divisionLogic[i]))).round(System.RoundingMode.HALF_UP);
						}
                                            }
                                        }
                                    }
                                    updateFCList1.add(prodSortForecastMap.get(oli.Id)[i]);
                                }
                            }
                        }
                    }
                       
                    try{
                        update updateFCList1;
                    }catch(Exception e){
                        PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler.updateForecastRecords');
                    }  
                }
            }
            updateForecastRecordsRecCheck = true;
        }
    }
    
    
    /*
* Method name  : OpportunityApprovalHistoryInsert
* Description  : This Method used to Create or Delete the OpportunityApprovalHistory records when the product status back to Pending, Lost, Cancelled, On Hold or Deleted) OR WIN APPROVED.
* Return Type  : void
* Parameter    : (List<OpportunityLineItem> newList, Map<Id,OpportunityLineItem> oldMap,Boolean isUpdate)
*/
    public static void opportunityApprovalHistoryInsert(List<OpportunityLineItem> newList, Map<Id,OpportunityLineItem> oldMap,Boolean isUpdate){
        Map<Id, OpportunityLineItem> opplineIdMap= new Map<Id,OpportunityLineItem>();
        list<Core_Opportunity_Approval_History__c> oppAHList=new list<Core_Opportunity_Approval_History__c>();  
        list<Core_Opportunity_Approval_History__c> oppAHInsertList=new list<Core_Opportunity_Approval_History__c>();
        list<Core_Opportunity_Approval_History__c> oppAHUpdateORDELList=new list<Core_Opportunity_Approval_History__c>();
        //START- US264584-DEFECT : Opportunity: Product Approval History getting deleted
        list<Core_Opportunity_Approval_History__c> oppAHDeleteList=new list<Core_Opportunity_Approval_History__c>();
        Map<Id, OpportunityLineItem> opplineIdMapDel= new Map<Id,OpportunityLineItem>();   
        //END- US264584-DEFECT : Opportunity: Product Approval History getting deleted             
        if(isUpdate){                                             
            for(OpportunityLineItem opline:newList){ 
                // if opportunity product has Win Approved then create the OpportunityApprovalHistory records //                 
                if(oldMap.get(opline.Id).Core_Status__c != opline.Core_Status__c&&  oldMap.get(opline.Id).Core_Approved_By__c !=opline.Core_Approved_By__c && opline.core_status__c==CORE_WIN_APPROVED && opline.Core_Approved_By__c != null && !alreadyInsertedApprovalHisotry){
                    Core_Opportunity_Approval_History__c objAH=New Core_Opportunity_Approval_History__c();
                    objAH.Core_Opp_Hist_OpportunityLineItemID__c  =opline.Id;
                    objAH.Core_Opp_Hist_Product__c                =opline.Product2Id;
                    objAH.Core_Opp_Hist_Core_Opportunity__c       =opline.OpportunityId; 
                    objAH.Core_Opp_Hist_Approved_By__c            =opline.Core_Approved_By__c;
                    objAH.Core_Opp_Hist_Manager_Approved_Date__c  =opline.Core_Approved_Date__c;
                    objAH.Core_Opp_Hist_Claim_Date__c             =opline.Core_Claim_Date__c;
                    objAH.Core_Opp_Hist_BU_Product_Segment__c     =opline.Core_Approved_BU_Product_Segment__c;
                    objAH.Core_Opp_Hist_Approved_BU_Short_Name__c =opline.Core_Approved_BU_Short_Name__c;
                    objAH.Core_Opp_Hist_Approved_Quantity__c      =opline.Core_Approved_Quantity__c;
                    objAH.Core_Opp_Hist_Approved_Sales_Price__c   =opline.Core_Approved_Sales_Price__c;
                    objAH.Core_Opp_Hist_Approved_Total_Price__c   =opline.Core_Approved_Total_Price__c;
                    objAH.Core_Opp_Hist_Commissionable__c         =opline.Core_Approved_Commissionable__c;
                    objAH.Core_Opp_Hist_Approved_Sales_Group__c   =opline.Core_Opp_Approved_Sales_Group__c;
                    objAH.Core_Opp_Hist_Production_Claim_Date__c  =opline.Core_Production_Claim_Date__c;
                    objAH.Core_Opp_Hist_Opportunity_Coverage__c   =opline.Core_Opp_Approved_Oppty_Coverage__c;
                    objAH.Core_Opp_Hist_Status__c                 =opline.Core_Status__c;                        
                    oppAHInsertList.add(objAH);  
                }                 
                //If the product status is Production Win,Production lost,Production Cancelled ,update the production claim date in OppApprovalHistory//                             
                if(opline.Core_Production_Claim_Date__c != null && oldMap.get(opline.Id).Core_Status__c != opline.Core_Status__c &&  CORE_PRODUCTION_STATUS.contains(opline.Core_Status__c)){               
                    opplineIdMap.put(opline.Id,opline);                       
                }  
                //The product status back to Pending, Lost, Cancelled, On Hold or Deleted. then delete the OpportunityApprovalHistory Records)  //                   
                if((oldMap.get(opline.Id).Core_Status__c != CORE_PENDING && opline.Core_Status__c == CORE_PENDING)|| 
                   (!CORE_OTHERS.contains(oldMap.get(opline.Id).Core_Status__c) && CORE_OTHERS.contains(opline.Core_Status__c))){
                       opplineIdMapDel.put(opline.Id,opline);
                       oppapprovalHistoryDelete=true;
                   }
            }     
            // To query the OpportunityApprovalHistoryRecords to delete or udpate based on opportunityLimeItemId //                 
            Set<Id> oppLineIdSet=opplineIdMap.keyset(); 
            if(oppLineIdSet!=null && !oppLineIdSet.isEmpty()){
                for(Core_Opportunity_Approval_History__c oppAH:oppAHList=[select id,Core_Opp_Hist_OpportunityLineItemID__c,Core_Opp_Hist_Production_Claim_Date__c from Core_Opportunity_Approval_History__c where Core_Opp_Hist_OpportunityLineItemID__c IN :oppLineIdSet]){
                    if(oppAH.Core_Opp_Hist_OpportunityLineItemID__c !=null && opplineIdMap.containskey(oppAH.Core_Opp_Hist_OpportunityLineItemID__c)){                                    
                        oppAH.Core_Opp_Hist_Production_Claim_Date__c=opplineIdMap.get(oppAH.Core_Opp_Hist_OpportunityLineItemID__c).Core_Production_Claim_Date__c;                       
                        oppAHUpdateORDELList.add(oppAH);
                    }                       
                }                                                  
            } 
            //START- US264584-DEFECT : Opportunity: Product Approval History getting deleted
            Set<Id> oppLineIdSetDel=opplineIdMapDel.keyset(); 
            if(oppLineIdSetDel!=null && !oppLineIdSetDel.isEmpty()){
                for(Core_Opportunity_Approval_History__c oppAHDel:oppAHList=[select id,Core_Opp_Hist_OpportunityLineItemID__c,Core_Opp_Hist_Production_Claim_Date__c from Core_Opportunity_Approval_History__c where Core_Opp_Hist_OpportunityLineItemID__c IN :oppLineIdSetDel]){
                    oppAHDeleteList.add(oppAHDel);                       
                }                                                  
            } 
            //END-US264584-DEFECT : Opportunity: Product Approval History getting deleted                           
            try{
                if(oppAHInsertList != null && !(oppAHInsertList.isEmpty())){
                    alreadyInsertedApprovalHisotry=true;
                    Database.insert(oppAHInsertList);                    
                }    
                if(oppAHUpdateORDELList!= null && !(oppAHUpdateORDELList.isEmpty())){ 
                    Database.update(oppAHUpdateORDELList); 
                } 
                if(oppAHDeleteList!= null && !(oppAHDeleteList.isEmpty()) && oppapprovalHistoryDelete){
                    Database.Delete(oppAHDeleteList); 
                }     
            }catch(Exception e){
                PMP_Utility.logError(e, 'Core_OpportunityLineItemHandler.opportunityApprovalHistoryInsert');
            }
        }         
    }     
    
    //START - US282592: SMG 2019: Data Flow fix between IAH to SFDC -- Ashwin
    /*
* Method name  : deleteKPI
* Description  : This Method is used to delete the associated KPI Product and is called on DELETE of OpportunityLineItem. 
*                It will also check if the KPI is having only 1 product if true then will delete the entire KPI else will delete the particular KPI Product
* Return Type  : void
* Parameter    : (Map<Id, OpportunityLineItem> oldProdMap).
*/ 
     //Areefa: 15 Nov 2024, commented this method as part of TWC4767-3203
    /*public static void deleteKPI(Map<Id, OpportunityLineItem> oldProdMap){
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        Map<Id, Core_Opp_KPI_Product__c> kpiProductMap = 
            new Map<Id, Core_Opp_KPI_Product__c>([SELECT id,Core_Opp_KPI__c,
                                                  Core_Opp_KPI_Product__c,Core_Opp_KPI_Oppty_Product_Id__c 
                                                  FROM Core_Opp_KPI_Product__c WHERE Core_Opp_KPI_Oppty_Product_Id__c IN : oldProdMap.keySet()]);
        Set<Id> kpiIdSet = new Set<Id>();
        for(Core_Opp_KPI_Product__c kpiProd : kpiProductMap.values()){
            kpiIdSet.add(kpiProd.Core_Opp_KPI__c);
        }
        Map<Id, Set<Id>> kpiVsKPIProdMap = new Map<Id, Set<Id>>();
        Set<Id> deleteKPISet = new Set<Id>();
        Set<Id> deleteKPIProdSet = new Set<Id>();
        if(!kpiProductMap.isEmpty()){
            for(Core_Opportunity_KPI__c kpi : [SELECT id, (SELECT id, core_Opp_KPI__c, Core_Opp_KPI_Oppty_Product_Id__c FROM Opportunity_KPI_Products__r) FROM Core_Opportunity_KPI__c WHERE id IN : kpiIdSet]){
                List<Core_Opp_KPI_Product__c> kpiProdList = new List<Core_Opp_KPI_Product__c>();
                Set<Id> kpiProdSet = new Set<Id>();
                kpiProdList = kpi.Opportunity_KPI_Products__r;  
                for(Core_Opp_KPI_Product__c prod : kpiProdList){
                    kpiProdSet.add(prod.Id);
                }
                if(!kpiProdSet.isEmpty()){
                    kpiVsKPIProdMap.put(kpi.Id, kpiProdSet);
                }                
            }
            ///TO DO
            for(Id kpiProd : kpiProductMap.keySet()){
                if(kpiVsKPIProdMap.get(kpiProductMap.get(kpiProd).Core_Opp_KPI__c).size() == 1 
                   && kpiVsKPIProdMap.get(kpiProductMap.get(kpiProd).Core_Opp_KPI__c).contains(kpiProd)){
                       deleteKPISet.add(kpiProductMap.get(kpiProd).Core_Opp_KPI__c);
                   }else if(kpiVsKPIProdMap.get(kpiProductMap.get(kpiProd).Core_Opp_KPI__c).size() > 1 
                            && kpiVsKPIProdMap.get(kpiProductMap.get(kpiProd).Core_Opp_KPI__c).contains(kpiProd)){
                                deleteKPIProdSet.add(kpiProd);
                            }
            }
            if(!deleteKPISet.isEmpty()){
                List<Id> deleteKPIList = new List<Id>();
                deleteKPIList.addAll(deleteKPISet);
                Database.DeleteResult[] drList = Database.delete(deleteKPIList, false);
                for(Database.DeleteResult dr : drList) {
                    if(!dr.isSuccess() || Test.isRunningTest()){
                        String errorMsg = '';
                        for(Database.Error err : dr.getErrors()) {
                            errorMsg = errorMsg + err.getMessage();
                        }
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'KPI_Delete_Error', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_KPIProcessing_Full_Batch', Core_When__c = System.now()));
                    }
                }
            }
            if(!deleteKPIProdSet.isEmpty()){
                List<Id> deleteKPIProdList = new List<Id>();
                deleteKPIProdList.addAll(deleteKPIProdSet);
                Database.DeleteResult[] drList = Database.delete(deleteKPIProdList, false);
                for(Database.DeleteResult dr : drList) {
                    if(!dr.isSuccess() || Test.isRunningTest()){
                        String errorMsg = '';
                        for(Database.Error err : dr.getErrors()) {
                            errorMsg = errorMsg + err.getMessage();
                        }
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'KPI_Delete_Error', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_KPIProcessing_Full_Batch', Core_When__c = System.now()));
                    }
                }
            }
        }
    }
*/
    //END - US282592: SMG 2019: Data Flow fix between IAH to SFDC  -- Ashwin
    
    /*
* Method name  : deleteNewKPI
* Description  : This Method is used to delete the associated new KPI object record on DELETE of OpportunityLineItem. 
* Return Type  : void
* Parameter    : List<OpportunityLineItem> oldProdList.
*/ 
    /*public static void deleteNewKPI(List<OpportunityLineItem> oldProdList){
List<Core_Oppty_KPI_New__c> newKpiList = [select Id, Core_Opportunity_Product__c from Core_Oppty_KPI_New__c where Core_Opportunity_Product__c IN: oldProdList];
if(!newKpiList.isEmpty()){
delete newKpiList;
}
}*/
    public static void deleteNewKPI(List<OpportunityLineItem> oldProdList){
        List<Id> CoreOppProdId = new List<Id>();
          for(OpportunityLineItem oppli :oldProdList){
          CoreOppProdId.add(oppli.Id);
        }
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        try{
            
            List<Core_Oppty_KPI_New__c> newKpiList = [select Id, Core_Opportunity_Product__c from Core_Oppty_KPI_New__c where Core_Opportunity_Product__c IN: CoreOppProdId];
            
            if(!newKpiList.isEmpty()){
                delete newKpiList;
            }
        }
        catch(exception e){
            
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = e.getMessage(), Core_Message__c = 'deleteNewKPI', Core_Severity__c = 'High', Core_Origin__c='core_OpportunityLineItemHandler', Core_When__c = System.now()));
            insert captureQueryErr;
        }
    }
    
    /*
* Method name  : restrictClsedAtRiskProdToDeletedUpdate
* Description  : This Method is used to restrict delete an at risk closed product. 
* Return Type  : void
* Parameter    : List<OpportunityLineItem> oppProductList.
*/
    public static void restrictClsedAtRiskProdToDeletedUpdate(List<OpportunityLineItem> oppProductList, Map<Id, OpportunityLineItem> oldOppMap){
        for(OpportunityLineItem oppProd : oppProductList){
            if(oppProd.Core_At_Risk__c && oppProd.Core_Status__c <> oldOppMap.get(oppProd.Id).Core_Status__c && oppProd.Core_Status__c==System.Label.Core_LineItem_Status  && oppProd.Core_At_Risk_Status__c.containsIgnoreCase('Closed')){
                oppProd.addError(System.Label.Core_ClosedAtRisk_DeleteMsg);
            }
        }
    }
    
    /*
* Method name  : restrictDeleteWhileKPIFullRefresh
* Description  : This Method is used to restrict delete a product while KPI full refesh is going on. 
* Return Type  : void
* Parameter    : List<OpportunityLineItem> oppProductList.
*/
    public static void preventDeleteWhileKPIFullRefresh(List<OpportunityLineItem> oppProductList , Map<Id, OpportunityLineItem> oldOppMap){
        Core_KPI_FullRefresh_Check__c fullRefreshSetting = Core_KPI_FullRefresh_Check__c.getInstance();
        if(fullRefreshSetting.IsFullRefresh__c == true){
            for(OpportunityLineItem oppProd : oppProductList){
                if(oppProd.Core_Status__c <> oldOppMap.get(oppProd.Id).Core_Status__c && oppProd.Core_Status__c == System.Label.Core_LineItem_Status){
                    oppProd.addError(System.Label.Core_RestrictDeleteOnKPIFullRefresh);
                }
            }
        }
    }
    
    /*
* Method name  : restrictClosedAtRiskProductToBeDeleted
* Description  : This Method is used to restrict delete an at risk closed product. 
* Return Type  : void
* Parameter    : List<OpportunityLineItem> oppProductList.
*/
    public static void restrictClosedAtRiskProductToBeDeleted(List<OpportunityLineItem> oppProductList){
        for(OpportunityLineItem oppProd : oppProductList){
            if(oppProd.Core_At_Risk__c && oppProd.Core_At_Risk_Status__c.containsIgnoreCase('Closed')){
                oppProd.addError(System.Label.Core_ClosedAtRisk_DeleteMsg);
            }
        }
    }
    
    /*
* Method name  : restrictDeleteWhileKPIFullRefresh
* Description  : This Method is used to restrict delete a product while KPI full refesh is going on. 
* Return Type  : void
* Parameter    : List<OpportunityLineItem> oppProductList.
*/
    public static void restrictDeleteWhileKPIFullRefresh(List<OpportunityLineItem> oppProductList){
        Core_KPI_FullRefresh_Check__c fullRefreshSetting = Core_KPI_FullRefresh_Check__c.getInstance();
        if(fullRefreshSetting.IsFullRefresh__c == true){
            for(OpportunityLineItem oppProd : oppProductList){
                if(oppProd.Core_Status__c != 'Post-Win')
                    oppProd.addError(System.Label.Core_RestrictDeleteOnKPIFullRefresh);
            }
        }
    }
    
    public static void RiskEmailNotification(List<OpportunityLineItem> NewOppLineItem,Map<Id, OpportunityLineItem> oldProdMap){
        Set<String> OppIds= new Set<String>();
        Set<String> OppLstModIds= new Set<String>();
        //new change
        set<String> BUOwnerIds ;
        String Shortname;
        set<string> shortnameSet = new set<string>(); 
        set<id> oppregion =new set<id>();          //opp id  opp geo region
        Map<id,String> oppreg = new Map<id,String>();        
        for(opportunitylineitem opl : NewOppLineItem){
           
            oppregion.add(opl.OpportunityId);
        }     
        List<Opportunity> opp=[Select Id,Name,Core_Opportunity_Owner_Geo__c from Opportunity where Id IN:oppregion];  // opp list        
        for(Opportunity oppl : opp){
          
            shortnameSet.add(oppl.Core_Opportunity_Owner_Geo__c); 
            if(!oppreg.containsKey(oppl.id) && (oppl.Core_Opportunity_Owner_Geo__c == 'AMR') || (oppl.Core_Opportunity_Owner_Geo__c == 'APJ') || (oppl.Core_Opportunity_Owner_Geo__c == 'EMEA') || (oppl.Core_Opportunity_Owner_Geo__c == 'PRC') || (oppl.Core_Opportunity_Owner_Geo__c == 'ASMO') /*|| (oppl.Core_Opportunity_Owner_Geo__c =='INDIA')*/ ){                        //key in side the map   opp id for opp reg in map      
                oppreg.put(oppl.id,oppl.Core_Opportunity_Owner_Geo__c);
            }            
        }        
        
        List<Core_BU_Owner_Table__c> buOwnerlist= [Select Id, Core_BU_Shortname__c,ownerid,Core_BU_Owner__c,Core_BU_Owner__r.Id FROM Core_BU_Owner_Table__c where Core_BU_Shortname__c=:shortnameSet];       
        
        map<string,set<string>> buOwnerMap = new map<string,set<string>>();
        for(Core_BU_Owner_Table__c bu : buOwnerlist){
            if(!buOwnerMap.containsKey(bu.Core_BU_Shortname__c)){
                buOwnerMap.put(bu.Core_BU_Shortname__c, new Set<String>{bu.Core_BU_Owner__c});
                
            }else{
                buOwnerMap.get(bu.Core_BU_Shortname__c).add(bu.Core_BU_Owner__c);
            }
        }        
        //end change
        
        for(OpportunityLineItem OppProd: NewOppLineItem){
            
            
            if(OppProd.Core_At_Risk__c && (OppProd.Core_At_Risk__c <> oldProdMap.get(OppProd.id).Core_At_Risk__c ||(OppProd.Core_Risk_Reason1__c <> oldProdMap.get(OppProd.id).Core_Risk_Reason1__c && OppProd.Core_Risk_Reason1__c=='Risk - Supply'))  && RiskemailRecCheck){
                RiskemailRecCheck=false;
                
                OppIds.add(OppProd.OpportunityId);
                OppLstModIds.add(OppProd.LastModifiedById);
                /* BU OwnerId Changes */
               
                if(oppreg.containsKey(OppProd.OpportunityId)){   //opp map
                    Shortname=oppreg.get(OppProd.OpportunityId);
                }
                if(!buOwnerMap.isEmpty() && OppProd.Core_Risk_Reason1__c == 'Risk - Supply'){
                    BUOwnerIds= buOwnerMap.get(Shortname);
                }
                
                /* BU OwnerId Changes Ended */
                if(oldProdMap.get(OppProd.id).Core_Risk_Reason1__c!=null && OppProd.Core_Risk_Reason1__c <> oldProdMap.get(OppProd.id).Core_Risk_Reason1__c && OppProd.Core_Risk_Reason1__c=='Risk - Supply')
                {
                    changeToRiskSupply =true;
                }
            }
        }
        
        if(OppIds.size() > 0){
            List<Opportunity> OppsAtRisk=[select id,OwnerId,Owner.Email,Name,Owner.ManagerId,Core_Technical_Owner__c,Core_Technical_Owner__r.ManagerId from Opportunity where Id In:OppIds];
            
            //Adding BUOwnerId as a parameter to the below Method
            SendRiskEmailNotification(OppsAtRisk,OppLstModIds,BUOwnerIds,changeToRiskSupply);
        }       
        
    }
    
    public static void SendRiskEmailNotification(List<Opportunity> OppList,Set<String> techOwnerIds,set<String> BUOwnerIds,boolean changeRiskSupply){
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        if(OppList.size() >0){
            //TWC3123-5267 Including BU Owner User Email Id in the EmailList. Removed and placed outside for loop by Hira to fix soql query inside loop
            List<contact> conList = [select id from contact limit 1];
            
            List<string> emaillist=new List<String>();
            
            String userType = Schema.SObjectType.User.getKeyPrefix();
            if(BUOwnerIds != NULL){ if(userType !='005'){
                
                List<User> userinfo = [SELECT Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId  = : BUOwnerIds)]; 
                for(user u : userinfo){ 
                    emaillist.add(u.Email);
                }
                
            }
                                   else{
                                       //As part of TWC4767-3572 - Removed and placed soql query outside for loop to fix Soql queries inside loops 
                                       List<User> userinfo = [select id,email from user where Id IN :BUOwnerIds];
                                       for(user u : userinfo)
                                       {  
                                           emaillist.add(u.email);
                                       }
                                   }
                                   
                                  }
            ID EmailTemplate;
            EmailTemplate = [Select Id, Name,Subject, HtmlValue, Body From EmailTemplate Where Name ='Core_Risk_Opportunity_Notification'][0].id;   
            for(Opportunity Opp: OppList){
                
                if (!changeRiskSupply)
                {
                    emaillist.add(Opp.OwnerId);
                    if(Opp.Owner.ManagerId != null){
                        emaillist.add(Opp.Owner.ManagerId);
                    }
                    if(techOwnerIds.contains(Opp.Core_Technical_Owner__c) && Opp.Core_Technical_Owner__r.ManagerId!=null){
                        emaillist.add(Opp.Core_Technical_Owner__r.ManagerId);
                    }
                }
                
                                 
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(emaillist);
                mail.setTemplateId(EmailTemplate);
                mail.setTargetObjectId(conList[0].Id);
                mail.setWhatId(Opp.Id);
                mail.setSaveAsActivity(false); 
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setOrgWideEmailAddressId(fromEmailAddress);
                mails.add(mail);
            }
        }
        if(mails.size() > 0){
            
            Messaging.sendEmail(mails);
        }
    }
    
/* Method name  : updateOppoRiskReasonOnOppLineItemUpdate
* Description  : This Method used to update opportunity risk reason when the product risk reason changes.
* Return Type  : void
* Parameter    : Map<Id, OpportunityLineItem> newMap , Map<Id, OpportunityLineItem> oldMap
*/
    public static void updateOppoRiskReasonOnOppLineItem(Map<Id, OpportunityLineItem> newMap , Map<Id, OpportunityLineItem> oldMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete){  
        if(!updateOppoRiskReasonOnOppLineItemRecCheck){
            Map<Id, Set<String>> mapOfOppIdAndSetRiskReason = new Map<Id, Set<String>>();
            Map<Id, String> mapOfOppIdAndStrRiskReason = new Map<Id, String>();
            List<Opportunity> oppList = new List<Opportunity>();   
            List<OpportunityLineItem> OppLineItemList = new List<OpportunityLineItem>();
            Set<Id> setOppId = new Set<Id>();   
            String newRR1;
            String oldRR1;
            String newRR2;
            String oldRR2;      
            //Adding the Opportunity Id of updated OpportunityLineItem to the setOppId after Update  and checking if the update is only for Risk Reason1 or Risk Reason2             
            if(isUpdate == true){
                for(OpportunityLineItem oppLineItem : newMap.values()){
                    if(oppLineItem.Core_Risk_Reason1__c <> oldMap.get(oppLineItem.Id).Core_Risk_Reason1__c){
                        newRR1 ='';
                        oldRR1 ='';
                        newRR2 ='';
                        oldRR2 ='';
                        newRR1 = oppLineItem.Core_Risk_Reason1__c;
                        if(oldMap.get(oppLineItem.Id).Core_Risk_Reason1__c != null){
                            oldRR1 = oldMap.get(oppLineItem.Id).Core_Risk_Reason1__c;
                        }               
                        newRR2 = oppLineItem.Core_Risk_Reason2__c;
                        if(oldMap.get(oppLineItem.Id).Core_Risk_Reason2__c != null){
                            oldRR2 = oldMap.get(oppLineItem.Id).Core_Risk_Reason2__c;
                        }                               
                        if(newRR1!= oldRR1 || newRR2!= oldRR2 || (oppLineItem.Core_Status__c== Label.Core_Deleted_Product_Status && oldMap.get(oppLineItem.Id).Core_Status__c != Label.Core_Deleted_Product_Status)||(oppLineItem.Core_Status__c!= Label.Core_Deleted_Product_Status && oldMap.get(oppLineItem.Id).Core_Status__c == Label.Core_Deleted_Product_Status)){
                            setOppId.add(oppLineItem.OpportunityId);                
                        }
                    }
                }  
            }
            //Adding the Opportunity Id of newly inserted OpportunityLineItem or deleted to the setOppId 
            if(isInsert){
                for(OpportunityLineItem oppLineItem : newMap.values()){            
                    if(oppLineItem.Core_Risk_Reason1__c!= null || oppLineItem.Core_Risk_Reason2__c!= null){
                        setOppId.add(oppLineItem.OpportunityId);                
                    }
                }
            }
            
            //Adding the Opportunity Id of the deleted OpportunityLineItem to the setOppId 
            if(isDelete){              
                for(OpportunityLineItem oppLineItem : oldMap.values()){            
                    setOppId.add(oppLineItem.OpportunityId);                
                }
            }
            
            //Preparing the map of Oppid and String of risk reasons to update the opportunity's Risk Reason accordingly
            if(!setOppId.isEmpty() && setOppId.size()>0){  
                OppLineItemList = [SELECT Id, Core_Status__c, Core_Risk_Reason1__c, Core_Risk_Reason2__c,OpportunityId,Core_PW_Sales_Price__c,Core_PW_Quantity__c FROM OpportunityLineItem WHERE OpportunityId =:setOppId AND Core_Status__c != :Label.Core_Deleted_Product_Status LIMIT 50000] ;     
            } 
            for(OpportunityLineItem oppLineItem : OppLineItemList){         
                if(mapOfOppIdAndSetRiskReason.containsKey(oppLineItem.OpportunityId)){
                    if(mapOfOppIdAndStrRiskReason.containsKey(oppLineItem.OpportunityId)){               
                        Set<String> setRiskReason = mapOfOppIdAndSetRiskReason.get(oppLineItem.OpportunityId);
                        String riskString = mapOfOppIdAndStrRiskReason.get(oppLineItem.OpportunityId); 
                        if(oppLineItem.Core_Risk_Reason1__c!= null){
                            if(!setRiskReason.contains(oppLineItem.Core_Risk_Reason1__c)){
                                setRiskReason.add(oppLineItem.Core_Risk_Reason1__c);
                                riskString = riskString + oppLineItem.Core_Risk_Reason1__c +';';
                            }
                        }
                        if(oppLineItem.Core_Risk_Reason2__c!= null){
                            if(!setRiskReason.contains(oppLineItem.Core_Risk_Reason2__c)){
                                setRiskReason.add(oppLineItem.Core_Risk_Reason2__c);
                                riskString = riskString + oppLineItem.Core_Risk_Reason2__c +';';
                            }  
                        } 
                        mapOfOppIdAndSetRiskReason.put(oppLineItem.OpportunityId, setRiskReason);
                        mapOfOppIdAndStrRiskReason.put(oppLineItem.OpportunityId, riskString);
                    }
                }
                else{
                    Set<String> setRiskReason = new Set<String>();
                    String riskString = '';
                    if(oppLineItem.Core_Risk_Reason1__c!= null){
                        setRiskReason.add(oppLineItem.Core_Risk_Reason1__c);
                        riskString = riskString + oppLineItem.Core_Risk_Reason1__c +';';
                    }
                    if(oppLineItem.Core_Risk_Reason2__c!= null){                    
                        if(!setRiskReason.contains(oppLineItem.Core_Risk_Reason2__c)){
                            setRiskReason.add(oppLineItem.Core_Risk_Reason2__c);
                            riskString = riskString + oppLineItem.Core_Risk_Reason2__c +';';
                        }  
                    }   
                    mapOfOppIdAndSetRiskReason.put(oppLineItem.OpportunityId, setRiskReason);
                    mapOfOppIdAndStrRiskReason.put(oppLineItem.OpportunityId, riskString);
                }
            }                         
            
            //Populate the Opportunity's Risk reason with '' if all the child opp Line Items are deleted or the status of OppLineItem is changed to delete.        
            if(isDelete || isUpdate){
                Opportunity oppUpdateDel;
                for(String oppId: setOppId){
                    if(!mapOfOppIdAndStrRiskReason.containsKey(oppId)){
                        oppUpdateDel = new Opportunity(); 
                        oppUpdateDel.Id = oppId;
                        oppUpdateDel.Core_Risk_Reason__c = ''; 
                        oppList.add(oppUpdateDel); 
                    }
                }
            }
            
            //Populate the Core_Risk_Reason__c field of Opportunity with the child OppLineItem's Risk Reason1 and Risk Reason2 fields
            if(!mapOfOppIdAndStrRiskReason.isEmpty() && mapOfOppIdAndStrRiskReason != null){
                Opportunity oppUpdate;
                for(String oppId : mapOfOppIdAndStrRiskReason.keySet()){                
                    oppUpdate = new Opportunity();
                    oppUpdate.Id = oppId;
                    oppUpdate.Core_Risk_Reason__c = mapOfOppIdAndStrRiskReason.get(oppId); 
                    oppList.add(oppUpdate);                
                }            
            }
            //Update the Opportunity list
            if(!oppList.isEmpty() && oppList.size()!=0){
                Database.update(oppList);        
            }
            updateOppoRiskReasonOnOppLineItemRecCheck = true;
        }
    }
    
    /*
* Method name  : createOppJSONInsert
* Description  : This Method sends the JSON on insert of OpportunityLine item
* Return Type  : void
* Parameter    : List<OpportunityLineItem> opportunityLineItemList
*/
    public static void createOppJSONInsert(List<OpportunityLineItem> opportunityLineItemList){ //US661969
        List<String> oppId = new List<String>();
        List<opportunity> oppList = new List<opportunity>();
        for(OpportunityLineItem OppLineItemList: opportunityLineItemList){
            //Areefa: Exclude PCC Deal Reg
            if( OppLineItemList.Core_Status__c != 'Post-Win' && OppLineItemList.Core_IsPCCOpportunity_cb__c == false){
                oppId.add(OppLineItemList.opportunityid);   
            }       
        }
        if(oppId.size()>0){
            if(!System.isBatch()){
                if(KPIJSONCheckInsert){
                    KPIJSONCheckInsert = false;
                    oppKPIJSON(oppId);
                }
            }
        }
    }
    
    /*
* Method name  : createOppJSONUpdate
* Description  : This Method sends the JSON on update of OpportunityLine item
* Return Type  : void
* Parameter    : List<OpportunityLineItem> opportunityItemList, Map<Id, OpportunityLineItem> oldOppMap
*/
    public static void createOppJSONUpdate(List<OpportunityLineItem> opportunityItemList, Map<Id, OpportunityLineItem> oldOppMap){ //US661969
        List<String> oppId = new List<String>();
        for(OpportunityLineItem OppLine: opportunityItemList){
            if(( OppLine.Core_Status__c != 'Post-Win' &&
                OppLine.Core_Status__c <> oldOppMap.get(OppLine.Id).Core_Status__c || 
                OppLine.Core_KPI_Date__c <> oldOppMap.get(OppLine.Id).Core_KPI_Date__c || 
                OppLine.core_approved_quantity__c <> oldOppMap.get(OppLine.Id).core_approved_quantity__c || 
                OppLine.core_approved_total_price__c <> oldOppMap.get(OppLine.Id).core_approved_total_price__c || 
                OppLine.core_approved_bu_product_segment__c <> oldOppMap.get(OppLine.Id).core_approved_bu_product_segment__c ||
               	// Commenting as part of TWC4767-4412
	        /*OppLine.CORE_ADVANCED_TECHNOLOGY__C<> oldOppMap.get(OppLine.Id).CORE_ADVANCED_TECHNOLOGY__C||*/
                OppLine.Core_Approved_BU_Short_Name__c <> oldOppMap.get(OppLine.Id).Core_Approved_BU_Short_Name__c ||
                OppLine.quantity <> oldOppMap.get(OppLine.Id).quantity ||
                OppLine.totalprice <> oldOppMap.get(OppLine.Id).totalprice ||
                OppLine.Product2.name <> oldOppMap.get(OppLine.Id).Product2.name ||
                OppLine.Product2.core_inf_kpi_prodgroup__c <> oldOppMap.get(OppLine.Id).Product2.core_inf_kpi_prodgroup__c ||
                OppLine.product2.CORE_CODE_NAME__C <> oldOppMap.get(OppLine.Id).Product2.CORE_CODE_NAME__C) &&
               //Areefa: Exclude PCC Deal Reg
               (OppLine.Core_IsPCCOpportunity_cb__c == false)){
                   
                   oppId.add(OppLine.opportunityid);
               }
            
        }
        if(oppId.size()>0){
            if(!System.isBatch()){
                if(KPIJSONCheckInsert){
                    KPIJSONCheckInsert = false;
                    
                    oppKPIJSON(oppId);
                }
            }
        }
    } 
    
    Public static void oppKPIJSON(List<String> rid){
        Core_OpportunityJSON updateJob = new Core_OpportunityJSON(rid); // changing rid to opptIdWithoutPCCDealReg
        ID jobID=System.enqueueJob(updateJob);
    }
    
    /*
* Method name  : setBuShortNameOnInsert
* Description  : This Method is used to update bu short on line item on insert
* Return Type  : void
* Parameter    : List<OpportunityLineItem> , Map<Id, OpportunityLineItem>.
*/
    public static void setBuShortNameOnInsert(List<OpportunityLineItem> newOppLineList){
        
        Core_OppLineItem_Batch_Helper.WrapperHelper wrap = Core_OppLineItem_Batch_Helper.prepareBuMappingTable();
        Core_BU_Mapping_Table__c finalBuMap;
        List<OpportunityLineItem> failedList= new List<OpportunityLineItem>();
        if(!wrap.extKeyWithBuMap.isEmpty()){
            for(OpportunityLineItem oppLineItem : newOppLineList){
                //TWC4767-465
                if (oppLineItem.Core_Product_Application__c <> null || oppLineItem.Core_Product_Segment__c <> null)
                {
                    finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppLineItem, wrap);
                    if(finalBuMap == null){
                        failedList.add(oppLineItem);
                    }else{
                        oppLineItem.Core_BU_Mapping_record__c = finalBuMap.Id;
                    }
                }
            }
        }
    }
    /*
* Method name  : updateEOLonInsert
* Description  : This Method is used to update EOL Flag on insert of line item.
* Return Type  : void
* Parameter    : List<OpportunityLineItem> newOppLineList
*/
    public static void updateEOLonInsert(List<OpportunityLineItem> newOppLineList){
        Set<id> prdIdSet = new Set<id>();
        List<OpportunityLineItem> OppFinalList = new List<OpportunityLineItem>();
        Map<id,List<OpportunityLineItem>> mapOppLineItem = new Map<id,List<OpportunityLineItem>>();
        for(OpportunityLineItem oppLineRec : newOppLineList){
            if(mapOppLineItem.containsKey(oppLineRec.product2id)) {
                mapOppLineItem.get(oppLineRec.product2id).add(oppLineRec);
            }
            else {
                mapOppLineItem.put(oppLineRec.product2id,new List<OpportunityLineItem>{oppLineRec});
            }
        }
        
        
        if(!mapOppLineItem.isEmpty()){
            List<Product2> prdList = [select id, Core_SA_Is_EOL__c from product2 where id in:mapOppLineItem.keySet()];
            if(prdList.size()>0){
                for(product2 prdl : prdList){
                    List<Opportunitylineitem> oppLineList = mapOppLineItem.get(prdl.id);
                    for(Opportunitylineitem opp : oppLineList){
                        opp.Core_Is_Product_EOL__c = prdl.Core_SA_Is_EOL__c;
                        OppFinalList.add(opp);
                    }
                }
            }
        }
    }
    /*
* Method name  : updateEOLonUpdate
* Description  : This Method is used to update EOL Flag on update of line item status.
* Return Type  : void
* Parameter    : List<OpportunityLineItem> newOppLineList
*/
    public static void updateEOLonUpdate(List<OpportunityLineItem> newOppLineList,Map<Id,OpportunityLineItem> newMap,Map<Id,OpportunityLineItem> oldMap){
        if(/*!updateEOLonUpdateRecCheck*/ updateEOLonUpdateRecCheck != true){
            Map<id,List<OpportunityLineItem>> mapOppLineItem = new Map<id,List<OpportunityLineItem>>();
            
            List<OpportunityLineItem> OppFinalList = new List<OpportunityLineItem>();
            for(OpportunityLineItem oppLineRec : newOppLineList){
                if(oppLineRec.Core_Status__c <> oldMap.get(oppLineRec.Id).Core_Status__c && system.label.Core_SA_Pending_Status.contains(newMap.get(oppLineRec.Id).Core_Status__c)){
                    
                    if(mapOppLineItem.containsKey(oppLineRec.product2id)) {
                        mapOppLineItem.get(oppLineRec.product2id).add(oppLineRec);
                    }
                    else {
                        mapOppLineItem.put(oppLineRec.product2id,new List<OpportunityLineItem>{oppLineRec});
                    }
                }
            }
            
            if(!mapOppLineItem.isEmpty()){
                List<Product2> prdList = [select id, Core_SA_Is_EOL__c from product2 where id in:mapOppLineItem.keySet()];
                if(prdList.size()>0){
                    for(product2 prdl : prdList){
                        List<Opportunitylineitem> oppLineList = mapOppLineItem.get(prdl.id);
                        for(Opportunitylineitem opp : oppLineList){
                            opp.Core_Is_Product_EOL__c = prdl.Core_SA_Is_EOL__c;
                            OppFinalList.add(opp);
                        }
                    }
                }
            }
            updateEOLonUpdateRecCheck = true;
        }
    }
    
    /*
* Method name  : validateQtyDecimal
* Description  : This Method is used to update EOL Flag on update of line item status.(TCW3123-2150 )
* Return Type  : void
* Parameter    : List<OpportunityLineItem> newOppLineList
*/
    public static void validateQtyDecimal(List<OpportunityLineItem> newOppLineList){
        Set<id> oliSet = new Set<id>();
        for(OpportunityLineItem ol : newOppLineList){
            oliSet.add(ol.id);
        }
        List<OpportunityLineItem> oliList = [select id,quantity,Core_Design_Registration_Product_Id__c,createddate, opportunityid,core_status__c,opportunity.createddate, opportunity.Core_Design_Registration_Id__c from OpportunityLineItem where id in:oliSet];
        map<id,opportunitylineitem> olimap= new map<id,opportunitylineitem>();
        for(OpportunityLineItem ol: oliList){
            olimap.put(ol.id,ol);
        }
        if(!olimap.isEmpty()){
            for(opportunitylineitem oli: newOppLineList){
                
                if(string.valueof(olimap.get(oli.id).quantity).contains('.') && !string.valueof(olimap.get(oli.id).quantity).contains('.00') && olimap.get(oli.id).core_status__c <> 'Win Submitted'){
                    String drId = olimap.get(oli.id).opportunity.Core_Design_Registration_Id__c;
                    
                    if(drId != null && olimap.get(oli.id).Core_Design_Registration_Product_Id__c == null){
                        
                        oli.addError(Label.Core_Decimal_Validation);
                        
                    }
                }
            }
        }
    }
    
    public static void deletePostWinProducts(List<OpportunityLineItem> listOppLineItems){
        List<OpportunityLineItem> postWinProducts = new List<OpportunityLineItem>();
        for(OpportunityLineItem oli : listOppLineItems){
            if(oli.core_status__c == 'Post-Win'){
                OpportunityLineItem postWinProduct = new OpportunityLineItem();
                postWinProduct.Id = oli.Id;
                postWinProducts.add(postWinProduct);
                
            }
        }
        if(!postWinProducts.isEmpty()){
            delete postWinProducts;
        }
        
        
    }
   
    
// PCC Deal -Sync opportunity and Opportunity line item status with Quote and Quote line.
    public static void syncStatus_OppProduct_QuoteLine(List<OpportunityLineItem> newOppLineList,Map<Id,OpportunityLineItem> oldMap) {
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        try {
            List<Id> OppLineIds = new List<Id>();
            for (OpportunityLineItem oppLine : newOppLineList) {
                if (oppLine.Core_IsPCCOpportunity_cb__c  && oppLine.Core_Status__c <> oldMap.get(oppLine.Id).Core_Status__c && (oppLine.core_status__c == 'Win approved' || oppLine.core_status__c == 'Cancelled' || oppLine.core_status__c == 'Lost' )  ) {         
                    OppLineIds.add(oppLine.Id);
                }
            }
            if (!OppLineIds.IsEmpty() && OppLineIds.size() > 0) {
                List<OpportunityLineItem> OppLineUpdate = new List<OpportunityLineItem>([
                    select id ,SBQQ__QuoteLine__c, Core_Status__c,Core_Loss_Cancel_Reason__c, Core_Loss_Cancel_Details__c  from OpportunityLineItem  where Id IN: OppLineIds and SBQQ__QuoteLine__c != null]);

                if (!OppLineUpdate.IsEmpty() && OppLineUpdate.size() > 0) {
                    Pricing_FinancialIncentive_BusinessLogic.updateQuoteLineStatus(OppLineUpdate);
                }
            }
        } catch (exception e) {
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = e.getMessage(),Core_Message__c = 'syncStatus_OppProduct_QuoteLine',Core_Severity__c = 'Low',Core_Origin__c = 'core_OpportunityLineItemHandler',Core_When__c = System.now()));
            insert captureQueryErr;
        }
    }

    
    //TWC4767-1596 :  Do not allow deletion of Oppty product if OPTY is PCC Deal Reg
    public static void deleteValidation_PCCDealReg(List<OpportunityLineItem> oldOppLineList){ 
        for(OpportunityLineItem oppLineRec : oldOppLineList){
            if(oppLineRec.Core_IsPCCOpportunity_cb__c){                 
                oppLineRec.addError(System.Label.Core_PCC_PreventProductDeletion);
            }
        }
    }
    
    //TWC4767-10 : NP : Prod issue- Do not allow deletion of Oppty product when there is already approved 6QPS record
    public static void deleteOLI(List<OpportunityLineItem> newOppLineList,Map<Id,OpportunityLineItem> oldMap){
        Map<id,boolean> oliDelete = new Map<id,boolean>();
        oliDelete = canDelete(oldMap.keyset());
        for(OpportunityLineItem oppLineRec : newOppLineList){
            if(oppLineRec.Core_Status__c <> oldMap.get(oppLineRec.Id).Core_Status__c && oppLineRec.Core_Status__c == System.Label.Core_LineItem_Status){
                if(oliDelete.containsKey(oppLineRec.id)) {
                    oppLineRec.addError('You cannot delete this product since there is already an approved 6QPS Quarter');
                }
            }
        }
    }  
    
    
    //TWC4767-10 : NP : Prod issue- Do not allow deletion of Oppty product when there is already approved 6QPS record
    public static Map<id,boolean> canDelete (Set<id> oppLineItems){
        Map<id,boolean> result = new Map<id,boolean>();
        for(Core_Opp_FC_Prod_Schedule__c oppo:[select id, Core_Opp_FC_Approval_Status__c, Core_FC_Opportunity_Product__c
                                               from Core_Opp_FC_Prod_Schedule__c  where Core_FC_Opportunity_Product__c in :oppLineItems]){
                                                   if(oppo.Core_Opp_FC_Approval_Status__c=='Approved'||oppo.Core_Opp_FC_Approval_Status__c=='Submitted'){
                                                       result.put(oppo.Core_FC_Opportunity_Product__c,false);
                                                   }
                                               }
        
        return result;
    }    
    
    //Lock OLI update if any of QL associated to Oppty is in PFIR - TWC3123-5659 - Devashish
    public static void CheckLockOnPCCOppty(List<OpportunityLineItem> newOpptyLineItems, Map<Id,OpportunityLineItem> oldMap){
        Set<String> oppIds = new Set<String>();
        Set<String> QLIDs = new Set<String>();
        List<String> Olifield = new List<String>();
        Boolean olifieldbypass = false;
        
            String OlifieldString = System.Label.Core_PCC_OpptyLineItemLock;
            Schema.DescribeSObjectResult oppDescribe = OpportunityLineItem.SObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = oppDescribe.fields.getMap();
        Core_Opp_Bypass_Validation_Rule__c mapBypassValidation = Core_Opp_Bypass_Validation_Rule__c.getInstance();
            for(OpportunityLineItem oli:newOpptyLineItems)
            {
                if(oli.Core_IsPCCOpportunity_cb__c)
                {
                    for(String fieldName : fieldMap.keySet()) {
                        
                        if (oli.get(fieldName) != oldMap.get(oli.Id).get(fieldName) && !OlifieldString.containsIgnoreCase(fieldName)) {
                            olifieldbypass = true;
                            break;
                        }
                    }
                    
                    if(mapBypassValidation.Bypass__c == false && olifieldbypass == true) 
                    {
                        oppIds.add(oli.OpportunityId);
                        if(oli.SBQQ__QuoteLine__c !=null)
                        {
                            QLIDs.add(oli.SBQQ__QuoteLine__c);
                        }
                    }
                }
            }
            if(QLIDs.size() > 0){
                List<SBQQ__QuoteLine__c> QLList = [Select id,name, Pricing_Status_Nm__c, Pricing_Change_Request_cb__c from SBQQ__QuoteLine__c where Id IN:QLIDs];
                for(OpportunityLineItem oli:newOpptyLineItems){
                    for(SBQQ__QuoteLine__c QL:QLList){
                        if(QL.Pricing_Status_Nm__c =='Pending Further Intel Review' && QL.Pricing_Change_Request_cb__c == true){
                            oli.adderror(System.Label.Core_LockPCCOppty);
                        }
                    }
                }            
            }          
            if(oppIds.size() > 0){
                List<Opportunity> OpptyList = [SELECT Id,SBQQ__PrimaryQuote__c, name, Core_Coverage_Type_Nm__c, Core_Opportunity_Coverage_Nm__c FROM Opportunity WHERE Id IN:oppIds]; 
                Boolean lock = Core_CRM_Utility.lockOpportunity(OpptyList);
                if(lock){
                    for(OpportunityLineItem oli:newOpptyLineItems){
                        oli.adderror(System.Label.Core_LockPCCOppty);
                    }
                }
            }
            if(mapBypassValidation.Bypass__c == true){
                mapBypassValidation.Bypass__c = false;
                upsert mapBypassValidation; 
        }
    }
    
        
        
        
            
                        
                        
                
    
    // Opportunity Revenue Calculation
    public static void opportunityRevenueCalculation (List<OpportunityLineItem> opportunityItemList, Map<Id, OpportunityLineItem> oldOppMap, String operation){
        Set<Id> opportuntiyIds = null ;
        
        if(operation == 'Update'){            
            opportuntiyIds = new Set<Id>();
            for(OpportunityLineItem oppLine :opportunityItemList){                   
                if(oppLine.Core_Status__c != oldOppMap.get(oppLine.Id).Core_Status__c || 
                   oppLine.Quantity != oldOppMap.get(oppLine.Id).Quantity || 
                   oppLine.Core_PW_Quantity__c != oldOppMap.get(oppLine.Id).Core_PW_Quantity__c ||
                   oppLine.UnitPrice != oldOppMap.get(oppLine.Id).UnitPrice || 
                   oppLine.Core_PW_Sales_Price__c != oldOppMap.get(oppLine.Id).Core_PW_Sales_Price__c ||
                   oppLine.Core_Lost_Total_Price__c != oldOppMap.get(oppLine.Id).Core_Lost_Total_Price__c ){
                       
                       opportuntiyIds.add(oppLine.OpportunityId);
                       updateRevenue = false;
                       
                   }
            }
        }
        else if (operation == 'Delete' ){ // when delete trigger we get data from old map

            opportuntiyIds = new Set<Id>();
            for(OpportunityLineItem oli :oldOppMap.Values()){
                opportuntiyIds.add(oli.OpportunityId);
            }

        } else if(operation == 'Insert'){
            
            opportuntiyIds = new Set<Id>();
            for(OpportunityLineItem oli :opportunityItemList){
                
                opportuntiyIds.add(oli.OpportunityId);
                
            }
        }
        
        
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        
        Map<Id,List<OpportunityLineItem>> opportunityWithLines = null;
        Map<Id,Opportunity> opportunityForUpdate = null;
        List<Opportunity> opportunitiesWithZeroLines = new List<Opportunity>();
        
        if(opportuntiyIds != null && !updateRevenue){
            opportunityWithLines = new Map<Id,List<OpportunityLineItem>>();
            
            for(OpportunityLineItem  oppLines : [Select Id, OpportunityId,Core_Total_Amount__c from OpportunityLineItem where OpportunityId in: opportuntiyIds ]){
              
                if(!opportunityWithLines.containsKey(oppLines.OpportunityId)){
                    opportunityWithLines.put(oppLines.OpportunityId, new List<OpportunityLineItem>());
                    opportunityWithLines.get(oppLines.OpportunityId).add(oppLines);
                }else if(opportunityWithLines.containsKey(oppLines.OpportunityId)){
                    opportunityWithLines.get(oppLines.OpportunityId).add(oppLines);
                }               
            }
            
            
                   
            List<Opportunity> finalUpdateList = new  List<Opportunity>();            
            
            // WW17.4 If condition to check scneaio - when opportunities are there without lines
            if(opportunityWithLines.isEmpty()){
                for(ID opptyID :opportuntiyIds){
                    opportunitiesWithZeroLines.add(new Opportunity(Id=opptyID,CRM_Opportunity_Revenue__c = 0 ));
                }
            }else if(!opportunityWithLines.isEmpty()){  // WW17.4 If condition to check scneaio - when opportunities are there without lines for partial records.
                
                for(Id opptyID : opportuntiyIds ){ // WW17.4 loop to seperate opportunities which dont have lines in a bulk  scenario                    
                    if(!opportunityWithLines.KeySet().contains(opptyID)  ){
                        opportunitiesWithZeroLines.add(new Opportunity(Id=opptyID,CRM_Opportunity_Revenue__c = 0 ));
                    }
                    
                }
                
                opportunityForUpdate = new Map<Id,Opportunity>([Select id,CRM_Opportunity_Revenue__c from Opportunity where id in: opportuntiyIds]);
                
                for(ID opptyId : opportunityWithLines.KeySet()){
                    Decimal totalCount = 0;
                    for(OpportunityLineItem oppLines : opportunityWithLines.get(opptyId)){
                        totalCount += oppLines.Core_Total_Amount__c;
                    }
                    opportunityForUpdate.get(opptyId).CRM_Opportunity_Revenue__c = totalCount ;
                    finalUpdateList.add(opportunityForUpdate.get(opptyId));
                }
            }
            //WW17.4 Adding Opportunities with 0 Line items to the final update list
            if(!opportunitiesWithZeroLines.isEmpty()) { finalUpdateList.addAll(opportunitiesWithZeroLines); }

            
            //WW17.4 Added a null check on finalUpdateList 
            Database.SaveResult[] myResult = null;    
            if(!finalUpdateList.isEmpty()) { myResult =Database.update(finalUpdateList,false); 
            for(Database.SaveResult sr : myResult) {
                if(!sr.isSuccess()){
                    String errorMsg = '';
                    for(Database.Error err : sr.getErrors()) {
                        errorMsg = errorMsg + err.getMessage();
                    }
                    logEntries.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'Opportunity Revenue Error', Core_Severity__c = 'High', Core_Origin__c='Core_OpportunityLineItemHandler', Core_When__c = System.now()));   
                }
            }
            
            if(!logEntries.isEmpty()){
                insert logEntries;
            }else{
                updateRevenue = true; // set to true after the method is processed
            }
        }
          
      }
        
        
        
    }
    /*
* Method name  : updatefcRecordOLIdelete
* Description  : TWC3123-6134 This Method is used to delete product schedule records when oppLineItem is deleted
			     Invoke Core_Batch_Update_FC_Product_Schedule batch class.
* Return Type  : void
* Parameter    : List<OpportunityLineItem> oldList
 */
    public static void updatefcRecordOLIdelete(List<OpportunityLineItem> oldList){
        if(!oliDeleteRecCheck){
            list<Id> oppProdIdList = new list<Id>();
            for(OpportunityLineItem oppProduct: oldList){
                oppProdIdList.add(oppProduct.Id);
            }
           list<Core_Opp_FC_Prod_Schedule__c> FcProdList = [select id ,name,Core_Opp_Line_Item_RecordID__c,Core_FC_Opportunity_Product__c from Core_Opp_FC_Prod_Schedule__c where Core_FC_Opportunity_Product__c = null and Core_Opp_Line_Item_RecordID__c IN:oppProdIdList and Core_Opp_Line_Item_RecordID__c != null  and Core_Is_Post_Win__c = false  ];
               if(!FcProdList.isempty()){
                   Core_Batch_Update_FC_Product_Schedule batchJob = new Core_Batch_Update_FC_Product_Schedule(oppProdIdList);
                   Id batchJobId = Database.executeBatch(batchJob);
               }
            oliDeleteRecCheck=true;
        }
             
    }
    //TWC4767-4569 KIIT: Disable Salesreps from instant deletion of products
    public static Void stopInstantDeletion(List<OpportunityLineItem> oldList){
        List<OpportunityLineItem> OppList = new List<OpportunityLineItem>();
        List<ID> oppId = new List<ID>();
        map<ID,Boolean> swMap = new map<ID,Boolean>();
        for(OpportunityLineItem oppProduct: oldList){
            oppId.add(oppProduct.OpportunityId);
        }
        for(Opportunity opp : [select ID, CRM_SW_Flag_Ind__c from Opportunity where Id IN: oppId ]){
            swMap.put(opp.ID,opp.CRM_SW_Flag_Ind__c);
        }
        for(OpportunityLineItem oppProduct: oldList){
            if(oppProduct.Core_Status__c != Label.Core_LineItem_Status && !oppProduct.Core_Status__c.equalsIgnoreCase(Core_CRM_Utility.getCRMLabel('CRM_PostWinProductStatus')) && !(swMap.get(oppProduct.OpportunityId))){
                oppProduct.addError(Core_CRM_Utility.getCRMLabel('CRM_stopOliInstantDeleteErrorMessage'));
            }
        }
    }    
}