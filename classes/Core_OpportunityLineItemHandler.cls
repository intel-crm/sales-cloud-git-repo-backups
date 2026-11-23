/********************************************************************************************************************
Apex Class Name:  Core_OpportunityLineItemHandler
Version      : 1.0 
Created Date : 11/21/14
Function     : Utility methods to handle OpportunityLineItem functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
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
public class Core_OpportunityLineItemHandler {
    
    // Make sure we only execute functionality once
    public static Boolean alreadyAddedCommissionableTransactions = false;
    public static Boolean alreadyTrackedHistory = false;
    public static Integer nextChk=0000;
    public static Integer tempxtChk = 0000;     
    //Added few more static variables for Forecast checks - Ashwin
    public static final Set<String> Core_Status = new Set<String>{'Lost','Cancelled','Deleted','On Hold','Production Lost','Production Cancelled'};
    public static boolean checkOLIExists = false;

    //Added a static variable for checing the status as Pending - US89448, US88961 - Stamp "Approved Sales Group" and "Approved Opportunity Coverage" -- Ashwin
    public static final String CORE_PENDING = 'Pending';
    public static final Set<String> CORE_OTHERS = new Set<String>{'Lost','Cancelled','Deleted','On Hold'};
    
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
    
    public static void opportunityLineItemAfterHandler(List<OpportunityLineItem> newList, Map<Id,OpportunityLineItem> newMap,
                                                       List<OpportunityLineItem> oldList, Map<Id,OpportunityLineItem> oldMap,
                                                       Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
                                                           
                                                           Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll(); 
                                                           
                                                           if (isInsert || isUpdate || isDelete)
                                                                opportunityProductConcatenation(newList, oldList, isDelete);
                                                           
                                                           if(isUpdate) {
                                                                if(mapFunctionalityNameTriggerExecution.containsKey('opportunityLineItemAddCommTxns') && 
                                                                  mapFunctionalityNameTriggerExecution.get('opportunityLineItemAddCommTxns').Core_Active__c)
                                                                   addCommissionableTransactions(oldList, oldMap, newList, newMap, isInsert, isUpdate);
                                                           }                                                           
                                                       }
    
    //START - US89448, US88961 - Remove "Approved Sales Group" and "Approved Opportunity Coverage" field on Opportunity Product on Approval on rejection or recall.  -- Ashwin
    public static void opptyLineItemUpdateSalesGroupandUserCovg(List<OpportunityLineItem> oldList, Map<Id,OpportunityLineItem> oldMap,
                                                                List<OpportunityLineItem> newList, Map<Id,OpportunityLineItem> newMap,
                                                                Boolean isUpdate){
        if(isUpdate){                                                           
            for(OpportunityLineItem oli : newList){
                if(oldMap.get(oli.Id).Core_Status__c != CORE_PENDING && oli.Core_Status__c == CORE_PENDING){
                    oli.Core_Opp_Approved_Sales_Group__c = '';
                    oli.Core_Opp_Approved_Oppty_Coverage__c = '';
                }else if(!CORE_OTHERS.contains(oldMap.get(oli.Id).Core_Status__c) && CORE_OTHERS.contains(oli.Core_Status__c)){
                    oli.Core_Opp_Approved_Sales_Group__c = '';
                    oli.Core_Opp_Approved_Oppty_Coverage__c = '';
                }
            }
        }
    }
    //END - US89448, US88961 - Remove "Approved Sales Group" and "Approved Opportunity Coverage" field on Opportunity Product on Approval on rejection or recall.  -- Ashwin
    
    public static void opportunityProductConcatenation(List<OpportunityLineItem> newList, 
                                                       List<OpportunityLineItem> oldList,
                                                       Boolean isDelete) {
                                                           
                                                           try
                                                           {
                                                               String debugPrefix = 'II: opportunityLineItemAfterHandler - ';            
                                                               System.debug(debugPrefix + ' - START');        
                                                               
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
                                                                                                         AND Core_Status__c != :Label.Core_Deleted_Product_Status
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
                                                               
                                                               System.debug(debugPrefix + ' - Update for ' + oppList.size() + ' records');        
                                                               System.debug(debugPrefix + ' - END');                                                                   
                                                           }
                                                           catch(Exception e){
                                                           }             
                                                       }       
    
    /*
* Method name  : insertPartners
* Description  : If Partner does not already exist, insert 
* Return Type  : None
* Parameter    : List of OpportunityLineItems 
*/
    public static void insertPartners(List<OpportunityLineItem> newList) {
        
        List<Core_Opportunity_Partner__c> partnersToInsert = new List<Core_Opportunity_Partner__c>();
        //List<Core_Opportunity_Partner__c> relatedOpportunityPartners;
        Set<String> partnersBeingInserted = new Set<String>();
        
        // Getting the Ids of related Opportunity records
        Set<Id> relatedOppIds = new Set<Id>();
        for (OpportunityLineItem oppLine : newList) {
            relatedOppIds.add(oppLine.OpportunityId);
        }
        List<Core_Opportunity_Partner__c> relatedPartners = new List<Core_Opportunity_Partner__c>();
        if(Core_Opportunity_Partner__c.SObjectType.getDescribe().isAccessible()){ //FLS check added - Aditya
        relatedPartners = [SELECT Id, Core_Opportunity__c, Core_Partner__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c In :relatedOppIds AND Core_Partner_Role__c = 'Vendor'];
        }
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
    }
    
    /*
* Method name  : deletePartners
* Description  : If the LineItem is not a dupe, delete 
* Return Type  : None
* Parameter    : List of OpportunityLineItems 
*/
    public static void deletePartners(List<OpportunityLineItem> oldList) {
        
        // Map to hold Opportunity Partners that will be deleted (using a Map to ensure no duplicates in the list)
        Map<Id, Core_Opportunity_Partner__c> mapPartnersToDelete = new Map<Id, Core_Opportunity_Partner__c>();
        List<OpportunityLineItem> relatedLineItems = new List<OpportunityLineItem>();
        
        // Getting the Ids of related Opportunity records
        Set<Id> relatedOppIds = new Set<Id>();
        for (OpportunityLineItem oppLine : oldList) {
            relatedOppIds.add(oppLine.OpportunityId);
        }
        
        // List for related OpportunityLineItems
        if(OpportunityLineItem.SObjectType.getDescribe().isAccessible()){ //FLS check added - Aditya
        relatedLineItems = [SELECT Id, OpportunityId, Core_Vendor__c FROM OpportunityLineItem WHERE OpportunityId In :relatedOppIds AND Core_Status__c != 'Lost' AND Core_Status__c != 'Cancelled' AND Core_Status__c != 'Deleted'];
        }
         List<Core_Opportunity_Partner__c> relatedOpportunityPartners = new List<Core_Opportunity_Partner__c>();
        // List for related Opportunity Partners
         if(Core_Opportunity_Partner__c.SObjectType.getDescribe().isAccessible()){ //FLS check added - Aditya
           relatedOpportunityPartners = [SELECT Id, Core_Opportunity__c, Core_Partner__c FROM Core_Opportunity_Partner__c WHERE Core_Opportunity__c In :relatedOppIds AND Core_Partner_Role__c = 'Vendor'];
         }
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
    
    public static void addCommissionableTransactions(List<OpportunityLineItem> oldOPList, Map<Id,OpportunityLineItem> oldOPMap,
                                                     List<OpportunityLineItem> newOPList, Map<Id,OpportunityLineItem> newOPMap,
                                                     Boolean isInsert, Boolean isUpdate)
    {
        //System.debug('Entering ACT... ' + alreadyAddedCommissionableTransactions);
        if(!alreadyAddedCommissionableTransactions) {
            alreadyAddedCommissionableTransactions = true;
            
            List<Core_Commissionable_Transaction__c> newTxns = new List<Core_Commissionable_Transaction__c>();
            
            //Set of all new approved opportunity products that are changing to "approved"
            Set<OpportunityLineItem> approvedOPs = new Set<OpportunityLineItem>();
            // Map of all rejected opportunity productts
            Map<ID,OpportunityLineItem> rejectedOPs = new Map<ID,OpportunityLineItem>();
            
            for (OpportunityLineItem op : newOPList) {                
                // If (this is an update trigger, new status is approved and prior status was not approved)
                //DE30417 - Adding null pointer checks on the if condition -- Ashwin
                if((isInsert && op.Core_System_Commissionable__c == null || op.Core_Status__c == null) || (isUpdate && op.Core_Status__c == null && oldOPMap.get(op.Id).Core_Status__c == null)){
                    continue;
                }
                if (
                    (isInsert && (op.Core_System_Commissionable__c).equalsIgnoreCase('Yes') && (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Approved_Status)) ||
                    ((isUpdate && (op.Core_System_Commissionable__c).equalsIgnoreCase('Yes') && (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Approved_Status)) 
                     && !((oldOPMap.get(op.Id).Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Approved_Status)))) {
                         
                         //Add this opportunity product to set of all newly approved, commissionable opportunity products
                         approvedOPs.add(op);                       
                     }
                
                //Else if this is an update trigger, new status is not approved, and prior status was approved
                else if (isUpdate 
                         && (!((op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Approved_Status) || 
                               (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Opportunity_Product_Production_Win_Status) ||
                               (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Opportunity_Product_Production_Lost_Status) ||
                               (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Opportunity_Product_Production_Cancelled_Status)) 
                             && ((oldOPMap.get(op.Id).Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Approved_Status)) 
                             && ((op.Core_System_Commissionable__c).equalsIgnoreCase('Yes')))
                         ||((op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Pending_Status)||
                            (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Lost_Status)||
                            (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Cancelled_Status)||
                           (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_OnHold_Status)||
                           (op.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_OP_Deleted_Status))
                         && ((oldOPMap.get(op.Id).Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Opportunity_Product_Production_Win_Status)
                             ||(oldOPMap.get(op.Id).Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Opportunity_Product_Production_Lost_Status)
                             ||(oldOPMap.get(op.Id).Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Opportunity_Product_Production_Cancelled_Status))
                         && ((op.Core_System_Commissionable__c).equalsIgnoreCase('Yes'))
                        )
                {
                    //Add this opportunity product to map of rejected opportunity products
                    rejectedOPs.put(op.ID, op);                             
                }        
            }
            
            //Handle rejections ---------------------------------------------
            //Get a list of commissionableTxns associated with every rejected opportunity product
            List<Core_Commissionable_Transaction__c> txnList = new List<Core_Commissionable_Transaction__c>();
            if(Core_Commissionable_Transaction__c.SObjectType.getDescribe().isAccessible()){ //FLS check added - Aditya 
            txnList = [
                SELECT Core_Account_ID__c,Core_Account_Name__c,Core_Approved_Total_Price__c,Core_CIM_ID__c,Core_Claim_Date__c,
                Core_Employee_ID__c,Core_Employee_Name__c,Core_Last_Approved_Date__c,
                Core_Milestone_Area__c,Core_Milestone_Focus__c,Core_Milestone_ID__c,Core_Milestone__c,Core_Opportunity_Name__c,
                Core_Opportunity_Team_Member_Role__c,Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,
                Core_Product2_ID__c,Core_Product_Type__c,Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,
                Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
                FROM Core_Commissionable_Transaction__c
                WHERE Core_Source_ID__c in :rejectedOPs.keySet()
            ];
            }
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
                    if (ct.Core_Source_ID__c == rejectedOP && ct.Core_Transaction_Timestamp__c == mostRecentTimestamp)
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
                //System.debug('opID:' + approvedOP.OpportunityId);
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
                //Approved_Total_Price gets updated post-approval after this trigger runs, so we need to rely on total price
                opTxn.Core_Approved_Total_Price__c = approvedOP.TotalPrice;
                System.debug('Approved Price:' + approvedOP.Core_Approved_Total_Price__c + ' Total Price:' + approvedOP.TotalPrice );
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
                            //System.debug(txn.Core_Employee_Name__c + '|' + txn.Core_WWID__c + '|' + txn.Core_Opportunity_Team_Member_Role__c + '|' + txn.Core_Percent_Contribution__c) ;
                            
                            //Gather transaction attributes above the user level, add to newTxn        
                            txn.Core_Source_ID__c = opTxn.Core_Source_ID__c;
                            txn.Core_Transaction_Timestamp__c = opTxn.Core_Transaction_Timestamp__c;
                            txn.Core_Account_ID__c = opTxn.Core_Account_ID__c;
                            txn.Core_Account_Name__c = opTxn.Core_Account_Name__c;
                            txn.Core_CIM_ID__c = opTxn.Core_CIM_ID__c;
                            txn.Core_Claim_Date__c = opTxn.Core_Claim_Date__c;
                            txn.Core_Last_Approved_Date__c = opTxn.Core_Last_Approved_Date__c;
                            txn.Core_Approved_Total_Price__c = opTxn.Core_Approved_Total_Price__c;
                            System.debug('Price2:' + opTxn.Core_Approved_Total_Price__c);
                            txn.Core_Product2_ID__c = opTxn.Core_Product2_ID__c;
                            txn.Core_Product_Type__c = opTxn.Core_Product_Type__c;
                           
                            txn.Core_Status__c = opTxn.Core_Status__c;
                            txn.Core_Opportunity__c = opTxn.Core_Opportunity__c;
                            txn.Core_Opportunity_Name__c = opTxn.Core_Opportunity_Name__c;
                            txn.Core_Opportunity_Type__c = opTxn.Core_Opportunity_Type__c;
                            txn.Core_Transaction_Type__c = opTxn.Core_Transaction_Type__c;
                            txn.Core_Approved_BU_Short_Name__c = opTxn.Core_Approved_BU_Short_Name__c;
                            
                            //System.debug(txn.Core_Claim_Date__c + '|' + txn.Core_Opportunity_Name__c + '|' + txn.Core_Milestone_Area__c + '|' + txn.Core_CIM_ID__c) ;
                            newTxns.add(txn);
                        }
                    
                }
            }
            
            insert newTxns;
        }
    }
    
    
     /*
    * Method name  : setBUShortName()
    * Description  : Query and Process the records to update BU Shortname on Opty line items
    * Return Type  : VOID
    * Parameter    : List of Opportunity Line items
    */ 
    public static void setBUShortName(List<OpportunityLineItem> newItems){
         Map<OpportunityLineItem,List<Core_BU_Mapping_Table__c>> lineItemBUTableMap= new Map<OpportunityLineItem,List<Core_BU_Mapping_Table__c>>();        
         List<Core_BU_Mapping_Table__c> listOfBUShortName = new List<Core_BU_Mapping_Table__c>();
         Map<String,Id> mapOfBUShrotNames = new Map<String,Id>();       
         List<OpportunityLineItem> failedList = new List<OpportunityLineItem>();  
        if(Core_BU_Mapping_Table__c.SObjectType.getDescribe().isAccessible()){ //FLS check added - Aditya
        listOfBUShortName = [SELECT Core_BU_Segment__c,Core_BU_Shortname__c,Core_Division_Shortname__c,Core_Product_Application__c,Core_Product_Segment__c,Core_Weightage__c,isDeleted,Name,Core_Product_Type__c FROM Core_BU_Mapping_Table__c where isDeleted=false];    
        }
        //DE30417 - Adding null pointer check for listOfBUShortName on the if condition -- Ashwin
        if(newItems != null && listOfBUShortName != null && newItems.size()>0 && listOfBUShortName.size()>0){
            for(OpportunityLineItem lineItemObj: newItems){                                                        
                    if(!lineItemObj.Core_product2_division__c.EqualsIgnoreCase('Write In Product')){
                                            
                        for(Core_BU_Mapping_Table__c mappingTableObj:listOfBUShortName){                        
                            //0001
                            if(mappingTableObj.Core_Product_Type__c==null && 
                            (mappingTableObj.Core_Division_Shortname__c==null) &&
                            mappingTableObj.Core_Product_Segment__c==null && 
                            lineItemObj.Core_Product_Application__c!=null && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c){
                                nextChk=0001;
                                lineItemBUTableMap =  alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('1'+lineItemBUTableMap.get(lineItemObj).size());                           
                            }
                            //0011
                            else if(mappingTableObj.Core_Product_Type__c==null && 
                            (mappingTableObj.Core_Division_Shortname__c==null ) &&
                             lineItemObj.Core_Product_Segment__c!=null && 
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c &&
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=0011;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('2'+lineItemBUTableMap.get(lineItemObj).size());                           
                            }
                            //0010
                            else if(mappingTableObj.Core_Product_Type__c==null && 
                            (mappingTableObj.Core_Division_Shortname__c==null ) &&
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            lineItemObj.Core_Product_Segment__c!=null && 
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=0010;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('3'+lineItemBUTableMap.get(lineItemObj).size());                           
                            }
                            //0100
                            else if(mappingTableObj.Core_Product_Type__c==null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null &&
                            lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c)) || ((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c))) &&                            
                            mappingTableObj.Core_Product_Segment__c==null && 
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=0100;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('4'+lineItemBUTableMap.get(lineItemObj).size());                           
                            }
                            //0101
                            else if(mappingTableObj.Core_Product_Type__c==null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null &&
                            lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c)) || (lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c) && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
                            mappingTableObj.Core_Product_Segment__c==null && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=0101;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('5'+lineItemBUTableMap.get(lineItemObj).size());
                                
                            }
                            //0111
                            else if(mappingTableObj.Core_Product_Type__c==null && 
                             mappingTableObj.Core_Division_Shortname__c!=null &&
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||(lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c) && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric())) || (lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c) && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                     
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=0111;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('6'+lineItemBUTableMap.get(lineItemObj).size());
                            }
                            //0110
                            else if(mappingTableObj.Core_Product_Type__c==null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null && lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c))|| (lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c)  && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            lineItemObj.Core_Product_Segment__c !=null &&
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=0110;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('7'+lineItemBUTableMap.get(lineItemObj).size());
                            }
                            //1000
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c!=null && 
                            (mappingTableObj.Core_Division_Shortname__c==null ) &&
                            mappingTableObj.Core_Product_Segment__c==null && 
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=1000;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('8'+lineItemBUTableMap.get(lineItemObj).size());
                            }
                            //1010
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c !=null && 
                            (mappingTableObj.Core_Division_Shortname__c==null ) &&
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            lineItemObj.Core_Product_Segment__c!=null && 
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=1010;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('9'+lineItemBUTableMap.get(lineItemObj).size());
                            }
                            //1001
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c!=null &&                             
                            mappingTableObj.Core_Division_Shortname__c==null  &&
                            mappingTableObj.Core_Product_Segment__c==null && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=1001;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('10'+lineItemBUTableMap.get(lineItemObj).size());
                            }
                            //1011
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c !=null && 
                            (mappingTableObj.Core_Division_Shortname__c==null ) &&               
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            lineItemObj.Core_Product_Segment__c!=null && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=1011;
                                lineItemBUTableMap =  alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('11'+lineItemBUTableMap.get(lineItemObj).size());
                            }
                            
                            //1100
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c !=null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null && lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c)) || (lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c)  && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                                        
                            mappingTableObj.Core_Product_Segment__c== null && 
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=1100;
                                lineItemBUTableMap =  alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('12'+lineItemBUTableMap.get(lineItemObj).size());
                            }
                            //1101
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c!=null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null && lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c)) || (lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c) && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
                            mappingTableObj.Core_Product_Segment__c== null && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=1101;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('13'+lineItemBUTableMap.get(lineItemObj).size());
                            }
                            //1110
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c !=null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null && lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c)) || (lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c)  && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            lineItemObj.Core_Product_Segment__c!=null &&
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=1110;
                                lineItemBUTableMap =  alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('14'+lineItemBUTableMap.get(lineItemObj).size());
                            }
                            //1111
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c!=null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null && lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c)) || (lineItemObj.Core_product2_division__c.contains(mappingTableObj.Core_BU_Shortname__c)  && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            lineItemObj.Core_Product_Segment__c !=null && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=1111;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('15'+lineItemBUTableMap.get(lineItemObj).size());
                            }
                        }
                    }
                if(lineItemBUTableMap.get(lineItemObj)!=null && lineItemBUTableMap.get(lineItemObj).size()==1){                 
                    lineItemObj.Core_BU_Mapping_record__c = lineItemBUTableMap.get(lineItemObj)[0].Id;                      
                    
                }else if(lineItemBUTableMap.get(lineItemObj)==null || lineItemBUTableMap.get(lineItemObj).size()>1 || lineItemBUTableMap.get(lineItemObj).size()==0){
                //************************** to create a BU mapping calculation failed log in exception object****************************************//
                    failedList.add(lineItemObj);                    
                } 
                                                
            } //end of for loop//
            if(failedList.size()>0){
                Insert_logexception(failedList,label.Core_BU_ExceptionMsg);
            }
                   
        } 
        
    }
    
 
    
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
                System.debug(tempxtChk+'1st value--'+nextChk);
                tempxtChk=nextChk;
        }else {                  
                buMappingList = buMap.get(lItemObj);
                
                for(Core_BU_Mapping_Table__c mapTable:buMappingList){                   
                    if((lItemObj.Core_product2_division__c.containsIgnoreCase(mapTable.Core_BU_Shortname__c) || lItemObj.Core_product2_division__c.containsIgnoreCase(mappingObj.Core_BU_Shortname__c) || (mapTable.Core_Division_Shortname__c!=null && lItemObj.Core_Division__c==null && lItemObj.Core_product2_division__c.containsIgnoreCase(mapTable.Core_Division_Shortname__c)) || (mappingObj.Core_Division_Shortname__c!=null && lItemObj.Core_Division__c==null && lItemObj.Core_product2_division__c.containsIgnoreCase(mappingObj.Core_Division_Shortname__c))||(String.isBlank(mappingObj.Core_Product_Segment__c) &&  !String.isBlank(mappingObj.Core_Product_Application__c)))&& mapTable.Core_Weightage__c <= mappingObj.Core_Weightage__c ){ 
                        tempBUMappingList.add(mappingObj); 
                        System.debug('1equals--');
                    }else if(mapTable.Core_Weightage__c < mappingObj.Core_Weightage__c){
                        tempBUMappingList.add(mappingObj); 
                        System.debug('less than--');
                    }else if(mapTable.Core_Weightage__c > mappingObj.Core_Weightage__c){
                        tempBUMappingList.add(mapTable); 
                        System.debug('greater than--');
                    }else if(tempxtChk>nextChk && mappingObj.Core_Division_Shortname__c==null && lItemObj.Core_Division__c==null && mapTable.Core_Weightage__c <= mappingObj.Core_Weightage__c && !lItemObj.Core_product2_division__c.containsIgnoreCase(mapTable.Core_BU_Shortname__c) || (mapTable.Core_Weightage__c <= mappingObj.Core_Weightage__c && String.isBlank(mappingObj.Core_Product_Segment__c) && !String.isBlank( mappingObj.Core_Product_Application__c))){
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
                if(system.isBatch()){
                    excep.Core_Class_Name__c='Core_OpportunityLineItem_BatchClass';
                    excep.Core_Method_Name__c=' Execute method ';
                    excep.Core_Record_Id__c=opp.Id;
                }
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
        System.debug('Initial Value of boolean - '+checkOLIExists);
        List<Core_Opp_FC_Prod_Schedule__c> tempList1;
         Map<Id, OpportunityLineItem> oliPresentMap = new Map<Id, OpportunityLineItem>();
        if(OpportunityLineItem.SObjectType.getDescribe().isAccessible()){ //FLS check added - Aditya
        oliPresentMap = new Map<Id, OpportunityLineItem>([SELECT id, Quantity, OpportunityId, Core_Vendor__c, Core_Status__c FROM OpportunityLineItem WHERE OpportunityId IN :opptyIdSet]);
        }
        System.debug('***OLI Present Map = '+oliPresentMap);
        if(oliPresentMap != null && !oliPresentMap.isEmpty()){
            for(Core_Opp_FC_Prod_Schedule__c fc : [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_Line_Item_RecordID__c IN :oliPresentMap.keySet() AND Core_Opp_FC_isdeleted__c = false]){
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
            System.debug('***FC Records - '+opptyLineItemVsFCMap);
            //if Forecast Map is not empty then check which opportunities have forecast and insert new forecast only for those oppty having existing forecast
            if(opptyLineItemVsFCMap.isEmpty()){
                checkOLIExists = true;
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
    
    public static void insertForecastRecords(list<OpportunityLineItem> newopplineitem, Boolean migrateFlag){
        List<Core_Opp_FC_Prod_Schedule__c> forecastRecList = new List<Core_Opp_FC_Prod_Schedule__c>();
        List<String> divisionLogic = (Label.Core_FC_ForecastDivision).split(';');
        Integer numOfForecast = Integer.valueOf(Label.Core_FC_NumberOfQuarter); // Change to custom settings
        boolean oliPresentFlag = false;
        Map<Id, Boolean> opptyContainsFCMap = new Map<Id, Boolean>();
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> opptyLineItemVsFCMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> oliIdSet = new Set<Id>();
        List<Core_Opp_FC_Prod_Schedule__c> tempList;
        for(OpportunityLineItem oli : newopplineitem){
            opptyIdSet.add(oli.OpportunityId);
            oliIdSet.add(oli.Id);
        }
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> prodSortForecastMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
        
        for(Core_Opp_FC_Prod_Schedule__c fc : [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Product__r.Name, 
                                                Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quarter__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, lastModifiedDate, createdDate, Core_FC_4Q_Shed_Quantity__c, Core_FC_Last_Modified_Date__c, Core_FC_Vendor__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c IN :opptyIdSet AND Core_Opp_FC_isdeleted__c = false ORDER BY Core_Opp_FC_Product__r.Name,Core_Opp_FC_Quarter_Date__c]){
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
        
        if(!newopplineitem.isEmpty() && !checkOLIExists){
            Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>([SELECT id, CloseDate, Core_First_Customer_Ship_Date__c, Core_Opportunity_Type__c, StageName FROM Opportunity WHERE Id IN :opptyIdSet]);
            for(OpportunityLineItem oli : newopplineitem){ 
                Decimal qtr = 0.00;
                Date considerDate = System.today();
                //If Opportunity Type is Deal then consider Decision Date else consider First Customer Ship Date
                if(opptyMap.get(oli.OpportunityId).Core_Opportunity_Type__c != null || opptyMap.get(oli.OpportunityId).Core_Opportunity_Type__c != ''){
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
                        System.debug('***Date Selected - '+considerDate);
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
                        for(Integer i=0; i<numOfForecast; i++){
                            Decimal qty = 0;
                            if(Core_Status.contains(oli.Core_Status__c)){
                                qty = 0;
                            }else{
                                qty = ((oli.Quantity)/(Integer.valueOf(divisionLogic[i]))).round(System.RoundingMode.HALF_UP);
                            }
                            if(i==0){
                                forecastRecList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = oli.OpportunityId, Core_Opp_Line_Item_RecordID__c = oli.Id, Core_Opp_FC_Product__c = oli.Product2Id, Core_Opp_FC_Quarter_Date__c = considerDate, Core_Opp_FC_Quantity__c = qty, Core_Opp_FC_isdeleted__c = false, Core_FC_Vendor__c = oli.Core_Vendor__c));
                            }else{
                                forecastRecList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = oli.OpportunityId, Core_Opp_Line_Item_RecordID__c = oli.Id, Core_Opp_FC_Product__c = oli.Product2Id, Core_Opp_FC_Quarter_Date__c = fc_Qtr_date, Core_Opp_FC_Quantity__c = qty, Core_Opp_FC_isdeleted__c = false, Core_FC_Vendor__c = oli.Core_Vendor__c));
                                fc_Qtr_date = fc_Qtr_date.addMonths(3);
                            }
                        } 
                    }                   
                }
            }
            System.debug('### Forecast Records - '+forecastRecList);
            try{
                insert forecastRecList; // database.saveresult exception
            }catch(Exception e){
                System.debug('Insert Exception - '+e.getMessage());
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
        List<Core_Opp_FC_Prod_Schedule__c> forecastRecList = [SELECT id FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_Line_Item_RecordID__c IN : oliSet] ;
        System.debug('### Forecast to be deleted - '+forecastRecList);
        if(forecastRecList != null && !forecastRecList.isEmpty()){
            try{
                if (Schema.sObjectType.Core_Opp_FC_Prod_Schedule__c.isDeletable()) {
                delete forecastRecList;
                }
            }catch(Exception e){
                System.debug('Delete Exception - '+e.getMessage());
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
        Set<Id> oliSet = oldOliMap.keySet();
        boolean counter = false;
        Integer count1 = 0;
        Integer numOfForecast = Integer.valueOf(Label.Core_FC_NumberOfQuarter);
        Map<Id, OpportunityLineItem> oliDeleteMap = new Map<Id, OpportunityLineItem>();
        List<String> divisionLogic = (Label.Core_FC_ForecastDivision).split(';');
        List<Core_Opp_FC_Prod_Schedule__c> updateFCList = new List<Core_Opp_FC_Prod_Schedule__c>();
        for(OpportunityLineItem oli1 : newOppLineItem){
            if(oli1.Core_Vendor__c != oldOliMap.get(oli1.Id).Core_Vendor__c || oli1.Core_Status__c != oldOliMap.get(oli1.Id).Core_Status__c || oli1.Quantity != oldOliMap.get(oli1.Id).Quantity){
                count1++;
            }
        }
        if(count1 > 0){
            List<Core_Opp_FC_Prod_Schedule__c> forecastRecList = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, 
                                                                        Core_Opp_FC_Product__r.Name, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quarter__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, lastModifiedDate, createdDate, Core_FC_4Q_Shed_Quantity__c, Core_FC_Last_Modified_Date__c, Core_FC_Vendor__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_Line_Item_RecordID__c IN : oliSet AND Core_Opp_FC_isdeleted__c = false ORDER BY Core_Opp_FC_Product__r.Name,Core_Opp_FC_Quarter_Date__c];
            for(OpportunityLineItem oli : newOppLineItem){
                Integer i = 0;
                for(Core_Opp_FC_Prod_Schedule__c fc : forecastRecList){
                    Integer count = 0;              
                    if(fc.Core_Opp_Line_Item_RecordID__c == String.valueOf(oli.Id)){
                        if(oli.Core_Vendor__c != oldOliMap.get(oli.Id).Core_Vendor__c){
                            fc.Core_FC_Vendor__c = oli.Core_Vendor__c;
                            count++;
                        }
                        if(Core_Status.contains(oli.Core_Status__c) && !Core_Status.contains(oldOliMap.get(oli.Id).Core_Status__c)){
                            fc.Core_Opp_FC_Quantity__c = 0;
                            fc.Core_FC_Last_Modified_Date__c = System.today();
                            count++;
                        }   
                        if((Core_Status.contains(oldOliMap.get(oli.Id).Core_Status__c) && !Core_Status.contains(oli.Core_Status__c)) || (oli.Quantity != oldOliMap.get(oli.Id).Quantity && !Core_Status.contains(oli.Core_Status__c))){
                            //Re-calculation to be done and LMD will be removed when quantity changes and when status changes to pending/winApproved/Submitted from lost/cancelled etc.
                            oliDeleteMap.put(oli.Id, oli);
                            counter = true;
                        }
                        if(count>0){
                            updateFCList.add(fc);
                        }
                    }
                }
            }
            if(!oliDeleteMap.isEmpty()){
                System.debug('***Inside OLI Delete Insert ***');
                deleteForecastRecords(oliDeleteMap);
                insertForecastRecords(oliDeleteMap.values(),true);
            }
            if(!updateFCList.isEmpty() && !counter){
                System.debug('***Inside OLI Update ***');
                try{
                    update updateFCList;
                }catch(Exception e){
                    System.debug('Update Exception - '+e.getMessage());
                }               
            }   
        }       
    }
}