/*********************************************************************************************************************
Class Name    : Sales_ContractTriggerUtility
Version       : 1.0
Created Date  : March 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Mitesh Dedhia             April 2021              US949934 - Delete Renewal Opportunity
* Mitesh Dedhia             June 2021               US1034569 | Inactivate Original Quote
* Nilesh Mithapelli         July 2021               US1047228 | Update Contract RecordType - Activated
***********************************************************************************************************/
public without sharing class Sales_ContractTriggerUtility{
    private static final String LICENSE_TYPE_RENEWAL = 'Renewal';
    //private static final String LICENSE_TYPE_AMEND = 'Amend';--Unused variable
    private static final String LICENSE_TYPE_ORIGINAL = 'Original';
    private static final String PRODUCT_TOOLTYPE_ADDSEAT = 'ADD SEAT';
    private static final String PRODUCT_TOOLTYPE_RENEWAL = 'RENEWAL';
    private static final String CONTRACT_STATUS_AMENDMENT_INPROGRESS = 'Amendment Inprogress';
    public static boolean byPassQuoteTriggersOnContractRenewal=false;
    public static void updateStartDateOnLicenses(Map<Id,Contract> conMap,Map<Id,Contract> oldContractMap){
        date licfirstdate ;
        Integer prodExpiryDurationInDays;
        List<Sales_License__c> licList = new List<Sales_License__c>();
        List<Sales_License_Order_Product__c> licOrdProdList = new List<Sales_License_Order_Product__c>();
        Set<id> licIdsProcessed = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        Map<Id, Contract> orderIdContractMap = new Map<Id, Contract>();
        for(Contract cont: conMap.values()){
            orderIdContractMap.put(cont.SBQQ__Order__c, cont);
            if(cont.EndDate != null && oldContractMap.get(cont.id).EndDate != cont.EndDate){
                contractIds.add(cont.Id);
            } 
        }
        for(OrderItem ordItm: [Select id, SBQQ__Contract__c, orderId, order.Status, order.Type, Order.SBQQ__Quote__r.SBQQ__Type__c, order.Sales_Order_Sub_Type__c from OrderItem where SBQQ__Contract__c IN: conMap.values() and Order.Type = 'Non Commercial Order' and Order.SBQQ__Quote__r.SBQQ__Type__c IN ('Quote','RENEWAL') and Order.Sales_Order_Sub_Type__c= 'Corporate Order']){
            if(ordItm.order.Status == 'Activated'  && !orderIdContractMap.keyset().contains(ordItm.OrderId)){
                orderIdContractMap.put(ordItm.OrderId, conMap.get(ordItm.SBQQ__Contract__c));
            }    
        }
        for(Sales_License_Order_Product__c licOrdProd: [Select Id,Sales_License_Order_Prod_Maint_Exp_Dt__c, Sales_License__c,Sales_License__r.Sales_License_Order__c,Sales_Order_Product__r.Quantity, Sales_License__r.Sales_License_Renewed_Date__c, Sales_License__r.Sales_License_Renewal_Status__c ,Sales_License__r.Sales_License_Status__c,Sales_License__r.Sales_License_Order__r.SBQQ__Quote__r.SBQQ__Type__c,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,Sales_License__r.Sales_License_Type__c,
                                                        Sales_Order_Product__c, Sales_Order_Product__r.OrderId,Sales_Order_Product__r.Order.Sales_Order_Sub_Type__c,Sales_License__r.Sales_License_Quantity__c, Sales_License__r.Sales_License_Start_Date_Dt__c,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c, Sales_Order_Product__r.SBQQ__Contract__c,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,
                                                        Sales_Order_Product__r.SBQQ__Contract__r.StartDate, Sales_Order_Product__r.SBQQ__Contract__r.EndDate,Sales_License__r.Sales_License_Contract__c from Sales_License_Order_Product__c  where (Sales_License__r.Sales_License_Type__c =: LICENSE_TYPE_ORIGINAL or (Sales_License__r.Sales_License_Type__c =:(System.Label.Sales_Licencse_Add_Seat_record_type) and Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c =: PRODUCT_TOOLTYPE_ADDSEAT) or (Sales_License__r.Sales_License_Type__c =:LICENSE_TYPE_RENEWAL and Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c =: PRODUCT_TOOLTYPE_RENEWAL)) and
                                                        ((Sales_Order_Product__r.SBQQ__Contract__c IN:conMap.keySet() and Sales_Order_Product__r.Order.Sales_Order_Sub_Type__c= 'Corporate Order' and Sales_Order_Product__r.Order.Sales_status__c = 'SAP Order Shipped') or 
                                                         (Sales_Order_Product__r.OrderId IN :orderIdContractMap.keyset() and Sales_Order_Product__r.Order.Status = 'Activated' and Sales_Order_Product__r.Order.Type = 'Non Commercial Order' and Sales_Order_Product__r.Order.SBQQ__Quote__r.SBQQ__Type__c IN ('Quote','RENEWAL') and Sales_Order_Product__r.Order.Sales_Order_Sub_Type__c= 'Corporate Order') or (Sales_License__r.Sales_License_Contract__c IN:contractIds and Sales_License__r.Sales_License_Status__c !='Cancelled'   ))]){
                                                             if(!licIdsProcessed.contains(licOrdProd.Sales_License__c)){
                                                                 prodExpiryDurationInDays = null;
                                                                 prodExpiryDurationInDays = (Integer)licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r?.Core_SW_Prod_Expiration_Duration_Nbr__c;
                                                                 licfirstdate = null;
                                                                 Sales_License__c lic = new Sales_License__c();
                                                                 lic.id = licOrdProd.Sales_License__c;
                                                                 lic.Sales_License_Start_Date_Dt__c =licOrdProd.Sales_Order_Product__r.SBQQ__Contract__r.StartDate;
                                                                 if(lic.Sales_License_Start_Date_Dt__c == null){
                                                                     lic.Sales_License_Start_Date_Dt__c = orderIdContractMap.get(licOrdProd.Sales_Order_Product__r.OrderId).StartDate;
                                                                 }
                                                                 Date contractEndDt = licOrdProd.Sales_Order_Product__r.SBQQ__Contract__r.EndDate;
                                                                 if(contractEndDt == null){
                                                                     contractEndDt = orderIdContractMap.get(licOrdProd.Sales_Order_Product__r.OrderId).EndDate;    
                                                                 }
                                                                 if(lic.Sales_License_Start_Date_Dt__c != null && prodExpiryDurationInDays!= null){
                                                                     licfirstdate = lic.Sales_License_Start_Date_Dt__c.addDays(prodExpiryDurationInDays);
                                                                 }
                                                                 if(prodExpiryDurationInDays != null){
                                                                     if  (licfirstdate!= null && licfirstdate.day() == 1) {                            
                                                                         lic.Sales_License_Expiration_Date_Dt__c = licfirstdate;                                     
                                                                     }
                                                                     else{
                                                                         lic.Sales_License_Expiration_Date_Dt__c =  Sales_LicenseTriggerUtility.getLastDateOfMonth(lic?.Sales_License_Start_Date_Dt__c?.addDays(prodExpiryDurationInDays)).addDays(1);                  
                                                                     }
                                                                     if(lic.Sales_License_Expiration_Date_Dt__c < contractEndDt){
                                                                         lic.Sales_License_Expiration_Date_Dt__c = contractEndDt;
                                                                     }
                                                                 }
                                                                 lic.Sales_License_Maintenance_Exp_Dt__c =  contractEndDt;                                                                                
                                                                 lic.Sales_License_Order_Product__c = licOrdProd.Sales_Order_Product__c;                                                            
                                                                 if(licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c == true){
                                                                     lic.Sales_License_Available_Temp_Licenses__c = licOrdProd.Sales_License__r.Sales_License_Quantity__c;
                                                                 }
                                                                 if(licOrdProd.Sales_License__r.Sales_License_Status__c!='Cancelled'){
                                                                 }
                                                                 lic.Sales_License_Contract__c = licOrdProd.Sales_Order_Product__r.SBQQ__Contract__c;
                                                                 if(lic.Sales_License_Contract__c == null){
                                                                     lic.Sales_License_Contract__c =  orderIdContractMap.containsKey(licOrdProd.Sales_Order_Product__r.OrderId) ? orderIdContractMap.get(licOrdProd.Sales_Order_Product__r.OrderId).Id : null;
                                                                 }
                                                                 if(licOrdProd.Sales_License__r.Sales_License_Status__c == 'Licensed' && licOrdProd.Sales_License__r.Sales_License_Order__r.SBQQ__Quote__r.SBQQ__Type__c == 'Renewal'){
                                                                     lic.Sales_License_Renewal_Status__c = 'License Renewed';
                                                                     lic.Sales_License_Renewed_Date__c = Date.today();
                                                                 }
                                                                 licList.add(lic);
                                                                 licIdsProcessed.add(lic.id);
                                                                 licOrdProd.Sales_License_ContractId__c = licOrdProd.Sales_Order_Product__r.SBQQ__Contract__c;
                                                                 if(licOrdProd.Sales_License_ContractId__c==null){
                                                                     licOrdProd.Sales_License_ContractId__c = orderIdContractMap.containsKey(licOrdProd.Sales_Order_Product__r.OrderId) ? orderIdContractMap.get(licOrdProd.Sales_Order_Product__r.OrderId).Id : null;
                                                                 }
                                                                 licOrdProd.Sales_License_Expiration_Date_Dt__c = lic.Sales_License_Expiration_Date_Dt__c;
                                                                 licOrdProd.Sales_License_Order_Prod_Maint_Exp_Dt__c = lic.Sales_License_Maintenance_Exp_Dt__c;
                                                                 licOrdProdList.add(licOrdProd);
                                                             }
                                                         }
        update licOrdProdList;
        
        //update licList;
        if(!licList.isempty()){
           Database.executeBatch(new Sales_ProcessDML_Batch(licList,'Sales_ContractTriggerUtility','updateStartDateOnLicenses','Failed Licenses on date update'),100); 
        }
    } 
    /****************************************************
    Name: Mitesh Dedhia
    Date: April 2021
    Parameters: List<Contract>
    High Level Description: US949934 - Delete Renewal Opportunity
    ****************************************************/
    public static void deleteRenewalOpportunity(List<Contract> contractList)
    {
        byPassQuoteTriggersOnContractRenewal=true;
        List<Id> renewalOpportunityIDSet = new List<Id>(); 
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>(); 
        Map<String,Contract> mapOfOppIdAndContract = new Map<String,Contract>();  
        Set<Id> originalQuoteId = new Set<Id>();
        Id newOppRecTypeId = [Select Id from RecordType where DeveloperName = 'PSG_Quote_Submitted' limit 1][0].Id;   
        for(Contract contractRecord: contractList)
        {
            if(contractRecord.SBQQ__RenewalOpportunity__c != null && contractRecord.SBQQ__RenewalForecast__c)
            {
                renewalOpportunityIDSet.add(contractRecord.SBQQ__RenewalOpportunity__c);  
                mapOfOppIdAndContract.put(contractRecord.SBQQ__RenewalOpportunity__c,contractRecord);
                originalQuoteId.add(contractRecord.SBQQ__Quote__c);
            }
            if(contractRecord.SBQQ__Quote__c!= null){
                SBQQ__Quote__c originalQuoteRecord = new SBQQ__Quote__c();
                originalQuoteRecord.id =  contractRecord.SBQQ__Quote__c ;
                originalQuoteRecord.core_cpq_active_cb__c = false;
                quoteList.add(originalQuoteRecord);
            }
        }
        List<SBQQ__Quote__c> originalQuoteDetails = [Select id,SBQQ__Type__c,SBQQ__Distributor__c,core_cpq_business_unit_nm__c, core_cpq_price_book_nm__c,SBQQ__PriceBook__c,SBQQ__PricebookId__c from SBQQ__Quote__c where id IN : originalQuoteId ];
        if(renewalOpportunityIDSet!= null)
        {
            for(SBQQ__Quote__c quoteRecord : [Select id,SBQQ__Opportunity2__c,Sales_Renewed_from_Contract_Id__c,SBQQ__Distributor__c,core_cpq_business_unit_nm__c, core_cpq_price_book_nm__c,SBQQ__PriceBook__c,SBQQ__PricebookId__c from  SBQQ__Quote__c where SBQQ__Type__c = 'Renewal' AND SBQQ__Opportunity2__c In : renewalOpportunityIDSet]){
                quoteRecord.Sales_Renewed_from_Contract_Id__c = mapOfOppIdAndContract.get(quoteRecord.SBQQ__Opportunity2__c).id;
                quoteRecord.RecordTypeId = newOppRecTypeId;
                quoteRecord.SBQQ__Opportunity2__c = null;
                if(originalQuoteDetails!=null && !originalQuoteDetails.isEmpty()){
                    quoteRecord.SBQQ__Distributor__c = originalQuoteDetails[0].SBQQ__Distributor__c;
                    quoteRecord.core_cpq_business_unit_nm__c = originalQuoteDetails[0].core_cpq_business_unit_nm__c;
                    quoteRecord.core_cpq_price_book_nm__c = originalQuoteDetails[0].core_cpq_price_book_nm__c;
                    quoteRecord.SBQQ__PriceBook__c= originalQuoteDetails[0].SBQQ__PriceBook__c;
                    quoteRecord.SBQQ__PricebookId__c= originalQuoteDetails[0].SBQQ__PricebookId__c;
                }
                quoteList.add(quoteRecord);
            }
            if(quoteList != null && !quoteList.isEmpty() )
            {
                update quoteList;
            }
        }
        if(renewalOpportunityIDSet!=null)
        {
            database.delete(renewalOpportunityIDSet);
        }
    }
    /****************************************************
    Name: Nilesh Mithapelli
    Date: July 2021
    Parameters: List<Contract>,Map<Id, Contract>
    High Level Description: US1047228 - updateContractRecordType
    ****************************************************/
    public static void updateRecordTypeForContract(List<Contract> contractList , Map<Id, Contract> oldContractMap){
        Set<Id> contractId = new Set<Id>();
        Map<Id,Order> ordMap = new Map<Id,Order>();
        Id contractActivtatedRTId = [Select Id from RecordType where SobjectType='Contract' and DeveloperName = 'Sales_Contract_Activated' limit 1][0]?.Id; 
        if(contractActivtatedRTId!=null){
            for(Contract contList : contractList){
                if(contList.Status=='Activated' && contList.RecordType.DeveloperName != 'Sales_Contract_Activated'){ 
                    contractId.add(contList.Id);
                }    
            }
            if(contractId.size()>0){
                for(Order ord :[Select Id,Type,Status,Sales_Contract_Id__c from Order where Sales_Contract_Id__c IN:contractId AND Type =: 'Non Commercial Order']){
                    ordMap.put(ord.Id,ord);
                }
            }
            if(ordMap.size()>0 && contractActivtatedRTId!=null){
                for(Contract contList :contractList ){
                    contList.RecordTypeId = contractActivtatedRTId;
                }
            }
        }    
    }
    /****************************************************
    Name: Nilesh Mithapelli
    Date: Dec 2021
    Parameters: Set<Id>
    High Level Description: TWC3144-40 - updateContractStatusForAmend
    ****************************************************/
    public static void updateContractStatusForAmend(List<Contract> contList){
        for(Contract cont: contList){
            cont.Status = CONTRACT_STATUS_AMENDMENT_INPROGRESS;
            cont.Sales_Is_Amendment_Completed__c = true;
        }
    }
}