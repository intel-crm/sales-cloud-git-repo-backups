/***************************************************************************************************** 
Class Name :    CRM_VBS_SOAR_Controller
Test Class :    CRM_VBS_SOAR_Controller_Test
Description:    Server side controller for Crm_VBS_SOAR_AddProducts LWC
Created By :    Aashna Anand(Accenture Unicorn)
******************************************************************************************************/
public with sharing class CRM_VBS_SOAR_Controller {
/**************************************************************************************************************************************************************** 
    Method Name : This method is used for creating SOAR product data. If any Validation is there it will return list of errors with error row number wrapped in 
                  checklistWrapper else it will create SOAR products
*****************************************************************************************************************************************************************/     
    @AuraEnabled
    public static checklistWrapper insertSoarProdsData(String soarProdDataString, List<Id> soarProdIds, Id soarId){
        List<CRM_VBS_Product__c> soarProdList = (List<CRM_VBS_Product__c>)System.JSON.deserializeStrict(soarProdDataString, List<CRM_VBS_Product__c>.Class);
        
        Map<ID, Product2> soarProdIdMap = new Map<ID, Product2>([select id,Name,Core_Sales_Visible_Flag__c,Core_Avail_for_New_Designs__c from Product2 where id in :soarProdIds]);
        String oppType = [select id, CRM_VBS_SOAR_Opportunity__r.Core_Opportunity_Type__c from CRM_VBS_SOAR__c where id =: soarId limit 1]?.CRM_VBS_SOAR_Opportunity__r.Core_Opportunity_Type__c;
//-------------------------------------------------------------------------ERROR CHECKING---------------------------------------------------------------------------------------------
        checklistWrapper wrpr = new checklistWrapper();
        boolean hardstop = false; 
        List<Integer> prodNum = new List<Integer>();
        Integer rowNumber=0;
        List<String> VRErrorMsgs= new List<String>();
        map<String,List<Integer>> fieldNameRowNumberMap = new map<String,List<Integer>>();
        
        for(CRM_VBS_Product__c sp : soarProdList) {
            rowNumber++;
            if(sp.CRM_VBS_Quantity__c < 0 || Integer.valueOf(string.valueof(sp.CRM_VBS_Quantity__c).substringAfter('.'))<> 0) {
                prodnum.add(rowNumber);
                if(fieldNameRowNumberMap.containsKey('Quantity')) {
                    fieldNameRowNumberMap.get('Quantity').add(rowNumber);
                }
                else {
                    fieldNameRowNumberMap.put('Quantity', new List<Integer> { rowNumber });
                }
            }
            if(sp.CRM_VBS_UnitPrice__c < 0) {
                prodNum.add(rowNumber);
                if(fieldNameRowNumberMap.containsKey('UnitPrice')){
                    fieldNameRowNumberMap.get('UnitPrice').add(rowNumber);
                }
                else {
                    fieldNameRowNumberMap.put('UnitPrice', new List<Integer> { rowNumber });
                }
            }
            if(soarProdIdMap.containsKey(sp.CRM_VBS_Product__c) && soarProdIdMap.get(sp.CRM_VBS_Product__c).Name == 'Write In Product' && String.Isblank(sp.CRM_VBS_Write_In_Product_Name__c )) {
                prodNum.add(rowNumber);
                if(fieldNameRowNumberMap.containsKey('WIP')){
                    fieldNameRowNumberMap.get('WIP').add(rowNumber);
                }
                else {
                    fieldNameRowNumberMap.put('WIP', new List<Integer> { rowNumber });
                }
            }
            if(soarProdIdMap.containsKey(sp.CRM_VBS_Product__c) && soarProdIdMap.get(sp.CRM_VBS_Product__c).Core_Sales_Visible_Flag__c == false) {
                prodNum.add(rowNumber);
                if(fieldNameRowNumberMap.containsKey('SVF')){
                    fieldNameRowNumberMap.get('SVF').add(rowNumber);
                }
                else {
                    fieldNameRowNumberMap.put('SVF', new List<Integer> { rowNumber });
                }
            }
            if(oppType<>null && oppType.contains('Design') && soarProdIdMap.containsKey(sp.CRM_VBS_Product__c) && soarProdIdMap.get(sp.CRM_VBS_Product__c).Core_Avail_for_New_Designs__c == false) {
                prodNum.add(rowNumber);
                if(fieldNameRowNumberMap.containsKey('AND')){
                    fieldNameRowNumberMap.get('AND').add(rowNumber);
                }
                else {
                    fieldNameRowNumberMap.put('AND', new List<Integer> { rowNumber });
                }
            }
        }
        if(fieldNameRowNumberMap.size()>0)  {      
            hardstop = true;
            if(fieldNameRowNumberMap.containsKey('Quantity')) {
                VRErrorMsgs.add(Core_CRM_Utility.getCRMLabel('CRM_VBS_Quantity_errorMsg')+' : Item '+ String.join(fieldNameRowNumberMap.get('Quantity'),', ') + '.');
            }
            if(fieldNameRowNumberMap.containsKey('UnitPrice')) {
                VRErrorMsgs.add(Core_CRM_Utility.getCRMLabel('CRM_VBS_UnitPrice_errorMsg')+' : Item '+ String.join(fieldNameRowNumberMap.get('UnitPrice'),', ') + '.');
            }
            if(fieldNameRowNumberMap.containsKey('WIP')) {
                VRErrorMsgs.add(Core_CRM_Utility.getCRMLabel('CRM_VBS_WriteInProductName_errorMsg')+' : Item '+ String.join(fieldNameRowNumberMap.get('WIP'),', ') + '.');
            }
            if(fieldNameRowNumberMap.containsKey('SVF')) {
                VRErrorMsgs.add(Core_CRM_Utility.getCRMLabel('CRM_VBS_SalesVisibleFlag_errorMsg')+' : Item '+ String.join(fieldNameRowNumberMap.get('SVF'),', ') + '.');
            }
            if(fieldNameRowNumberMap.containsKey('AND')) {
                VRErrorMsgs.add(Core_CRM_Utility.getCRMLabel('CRM_VBS_AvailforNewDesigns_errorMsg')+' : Item '+ String.join(fieldNameRowNumberMap.get('AND'),', ') + '.');
            }
        }
////------------------------------------------------------------------------INSERTION OF RECORDS-------------------------------------------------------------------------------------
        if(VRErrorMsgs.size() == 0) {
            Database.insert(soarProdList,true);
        }
        wrpr.hardStopList = VRErrorMsgs;
        wrpr.rowNumbers = prodNum;
        return wrpr;
    }
/********************************************************************************************************************* 
    Method Name :   the method is returning data wrapped in pricebookEntryWrap to populate datatable
**********************************************************************************************************************/     
    @AuraEnabled
    public static pricebookEntryWrap fetchRecords(Integer limitSize, String recId) {
        String query = 'select Id, Name, UnitPrice, Product2.Name, Product2.Id, Product2.Core_Avail_for_New_Designs__c, Product2.Core_Intel_vPro_Platform_Eligibility__c, Product2.Core_OPN__c, Product2.IsActive,Product2.Core_Sales_Visible_Flag__c,Product2.Core_Product_Family__c from PricebookEntry where Pricebook2.Name =\'Standard Price Book\' and IsActive =true and product2.IsActive = true';
        if(String.isNotBlank(recId)) {
            recId = String.valueOf(recId);
            query += ' and Name >: recId ';
        }
        
        query += ' ORDER BY Name ASC';
        
        if(limitSize != null && Integer.valueOf(LimitSize) > 0) {
            LimitSize = Integer.valueOf(LimitSize);
            query += ' Limit '+LimitSize;
        }
        return new pricebookEntryWrap([SELECT COUNT() FROM PricebookEntry where Pricebook2.Name ='Standard Price Book' and IsActive =true and product2.IsActive = true],Database.query(query));
    }
/************************************************************************************************************************ 
    Method Name :   the method is returning List of records by checking Name and Product Family
*************************************************************************************************************************/ 
   @AuraEnabled(cacheable=true)
   public static pricebookEntryWrap searchProducts(Integer limitSize, String recId, String searchKey, boolean sameSearch ) {
       String query = 'select Id, Name, UnitPrice, Product2.Name, Product2.Id, Product2.Core_Avail_for_New_Designs__c, Product2.Core_Intel_vPro_Platform_Eligibility__c, Product2.Core_OPN__c, Product2.IsActive,Product2.Core_Sales_Visible_Flag__c,Product2.Core_Product_Family__c from PricebookEntry where Pricebook2.Name =\'Standard Price Book\' and IsActive =true and product2.IsActive = true';
       String query2 = 'select count() from PricebookEntry where Pricebook2.Name =\'Standard Price Book\' and IsActive =true and product2.IsActive = true';
       if ( searchKey != null && searchKey != '' ) {
           String key = '%' + searchKey + '%';
           query += ' and (Name LIKE :key or Product2.Core_Product_Family__c LIKE :key)';
           query2 += ' and (Name LIKE :key or Product2.Core_Product_Family__c LIKE :key)';
       }
       if(String.isNotBlank(recId) && sameSearch) {
            recId = String.valueOf(recId);
            query += ' and Name >: recId ';
        }
       query = query + ' ORDER BY Name ASC';
       if(limitSize != null && Integer.valueOf(LimitSize) > 0) {
            LimitSize = Integer.valueOf(LimitSize);
            query += ' Limit '+LimitSize;
       }
       return new pricebookEntryWrap(Database.countQuery( query2 ), Database.query( query ));
   }

/************************************************************************************************************************** 
    Method Name :   pricebookEntryWrap(will return total pricebookentry records count and List of pricebookentry Records )
***************************************************************************************************************************/
    public class pricebookEntryWrap {
        @AuraEnabled
        public Integer totalRecords{get;set;}
        @AuraEnabled
        public List<PricebookEntry> entrys{get;set;}
        
        public pricebookEntryWrap(Integer totalRecords, List<PricebookEntry> entrys) {
            this.totalRecords=totalRecords;
            this.entrys=entrys;
        }
    }
/************************************************************************************************************************** 
    Method Name :   checklistWrapper(will return errors List and row numbers on which error ocurred)
***************************************************************************************************************************/
    public class checklistWrapper {
        @AuraEnabled
        public List<String> hardStopList = new List<String>();
        @AuraEnabled
        public List<Integer> rowNumbers = new List<Integer>();
    }
}