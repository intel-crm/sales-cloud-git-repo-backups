/****************************************************************************************************
Apex Class Name : PSG_CreateQuoteController
Version         : 1.0 
Created Date    : 12/7/2020
Function        : This class creates quote and quotelines from opportunity.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Raju                  12/7/2020              Created
*****************************************************************************************************/
public without sharing class PSG_CreateQuoteController {
    /****************************************************************************************************************
    * Method Name:createQuote
    * Date: 12/7/2020  
    * Description: Method to create quote from opportunity.
    ***************************************************************************************************************************/
    @AuraEnabled
    public static String createQuote(Id opportunityId1) {
        String opportunityId=(String) opportunityId1;
        opportunityId=String.escapeSingleQuotes(opportunityId);
        String quoteNumber = null;
        Map < Id, String > userIdToRoleMap = new Map < Id, String > ();
        try {
            Id recId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('PSG Quote - Submitted').getRecordTypeId();
            if (userIdToRoleMap.isEmpty()) {
                for (PermissionSetAssignment psa: [SELECT Id, AssigneeId, PermissionSet.Name, PermissionSet.Profile.Name, Assignee.Contact.AccountId
                        FROM PermissionSetAssignment WHERE AssigneeId =: userInfo.getUserId() AND(PermissionSet.Name =: Label.PSG_PermissionSets_PSG_Distributor OR PermissionSet.Name =: Label.PSG_Quote_SOS_PermissionSet)
                    ]) {
                    if (psa.PermissionSet.Name == Label.PSG_PermissionSets_PSG_Distributor) {
                        userIdToRoleMap.put(psa.AssigneeId, 'Disty');
                    }
                        if (psa.PermissionSet.Name == Label.PSG_Quote_SOS_PermissionSet) {
                            userIdToRoleMap.put(psa.AssigneeId, 'SOS');
                        }
                }
            }
            Map<String, Id> quotePricebookMap = new Map<String, Id>();
            for(Pricebook2 pbRec: [SELECT Id, Name FROM Pricebook2]){
                quotePricebookMap.put(pbRec.Name, pbRec.Id);
            }
            if (opportunityId != null) {
                Opportunity opportunityRecord = [SELECT Id, AccountId, CloseDate, Core_First_Customer_Ship_Date__c, Core_Production_End_Date__c, Core_Volume__c,
                    Core_Product_Segment__c, Core_Product_Application__c, Core_Consumption_Market__c, Core_Design_Registration_Id__c, Core_Technical_Owner__c, Account.Core_Geo__c, Account.Core_Sub_Geo__c,
                    Account.Name ,tolabel(Account.BillingStateCode),tolabel(Account.BillingCountryCode),Account.BillingCity                             
                    FROM Opportunity where ID =: opportunityId
                ];

                List < core_cpq_product_details__c > prodDetails = new List < core_cpq_product_details__c > ();
                List < SBQQ__Quote__c > quoteDetails = new List < SBQQ__Quote__c > ();

                SBQQ__Quote__c quoteToInsert = new SBQQ__Quote__c();
                quoteToInsert.SBQQ__Account__c = opportunityRecord.AccountId;
                quoteToInsert.core_cpq_end_customer_nm__c = opportunityRecord.AccountId; 
                quoteToInsert.SBQQ__Opportunity2__c = opportunityId;
                quoteToInsert.core_cpq_quote_type_nm__c = 'Budgetary';
                quoteToInsert.core_cpq_decision_date_dt__c = opportunityRecord.CloseDate; 
                quoteToInsert.core_cpq_first_ship_date_dt__c = opportunityRecord.Core_First_Customer_Ship_Date__c; 
                quoteToInsert.core_cpq_production_end_date_dt__c = opportunityRecord.Core_Production_End_Date__c; 
                quoteToInsert.core_cpq_volume_nbr__c = opportunityRecord.Core_Volume__c; 
                quoteToInsert.core_cpq_product_segment_nm__c = opportunityRecord.Core_Product_Segment__c; 
                quoteToInsert.core_cpq_product_application_nm__c = opportunityRecord.Core_Product_Application__c; 
                quoteToInsert.core_cpq_assigned_to_nm__c = opportunityRecord.Core_Technical_Owner__c;
                quoteToInsert.core_cpq_date_submitted_dt__c = null;
                quoteToInsert.RecordTypeId = recId;
                //quoteToInsert.SBQQ__PricebookId__c = null; 
                quoteToInsert.SBQQ__Status__c = 'New';
                quoteToInsert.core_cpq_status_txt__c = 'New'; 
                quoteToInsert.core_cpq_origin_txt__c = 'Oppty';
                
                quoteToInsert.core_cpq_end_customer_disty_nm__c = opportunityRecord.Account.Name; 
                quoteToInsert.core_cpq_end_customer_country_disty_nm__c = opportunityRecord.Account.BillingCountryCode;
                if(opportunityRecord.Account.BillingCountryCode == 'United States' || opportunityRecord.Account.BillingCountryCode == 'Canada')
                    quoteToInsert.core_cpq_end_customer_state_disty_txt__c = opportunityRecord.Account.BillingStateCode; 
                quoteToInsert.core_cpq_end_customer_city_disty_nm__c = opportunityRecord.Account.BillingCity; 
                
                if(UserInfo.getUserType() != 'PowerPartner'){
                    quoteToInsert.core_cpq_quote_owner_disty_txt__c=userInfo.getName();
                }
                

                if (UserInfo.getUserType() == 'PowerPartner') {
                    User usr = [SELECT accountId, id, email FROM user WHERE Id =: UserInfo.getUserId()];
                    quoteToInsert.SBQQ__Distributor__c = usr.accountId; 
                    quoteToInsert.core_cpq_requestor_nm__c = UserInfo.getUserId(); 
                }
                if (userIdToRoleMap.containsKey(userInfo.getUserId()) && userIdToRoleMap.get(userInfo.getUserId()) == 'Disty') {
                    quoteToInsert.core_cpq_date_submitted_dt__c = system.today();
                }
                if (userIdToRoleMap.containsKey(userInfo.getUserId()) && userIdToRoleMap.get(userInfo.getUserId()) == 'SOS' && (!quotePricebookMap.isEmpty())){
                    //TWC3133-5964 Geo Change
                    if(opportunityRecord.Account.Core_Geo__c == 'INDIA'){
                        quoteToInsert.SBQQ__PricebookId__c       =   quotePricebookMap.get('APJ');
                        quoteToInsert.SBQQ__PriceBook__c         =   quotePricebookMap.get('APJ');
                        quoteToInsert.core_cpq_price_book_nm__c  =   quotePricebookMap.get('APJ');
                    }
                    else{
                        quoteToInsert.SBQQ__PricebookId__c       =   (opportunityRecord.Account.Core_Geo__c == 'APJ' && opportunityRecord.Account.Core_Sub_Geo__c == 'IJKK') ? quotePricebookMap.get('JAPAN') : quotePricebookMap.get(opportunityRecord.Account.Core_Geo__c);
                        quoteToInsert.SBQQ__PriceBook__c         =   (opportunityRecord.Account.Core_Geo__c == 'APJ' && opportunityRecord.Account.Core_Sub_Geo__c == 'IJKK') ? quotePricebookMap.get('JAPAN') : quotePricebookMap.get(opportunityRecord.Account.Core_Geo__c);
                        quoteToInsert.core_cpq_price_book_nm__c  =   (opportunityRecord.Account.Core_Geo__c == 'APJ' && opportunityRecord.Account.Core_Sub_Geo__c == 'IJKK') ? quotePricebookMap.get('JAPAN') : quotePricebookMap.get(opportunityRecord.Account.Core_Geo__c);

                    }   
                    
                }
                if (opportunityRecord.Core_Product_Segment__c != null && opportunityRecord.Core_Product_Application__c != null) {
                    string verticalmarket=(string.isblank(opportunityRecord.Core_Consumption_Market__c) || opportunityRecord.Core_Consumption_Market__c=='Undefined')?null:opportunityRecord.Core_Consumption_Market__c;
                    prodDetails = [SELECT core_cpq_segment_nm__c, core_cpq_business_unit_nm__c from core_cpq_product_details__c
                        where(core_cpq_active_cb__c = true and core_cpq_product_segment_nm__c =: opportunityRecord.Core_Product_Segment__c AND core_cpq_product_application_nm__c =: opportunityRecord.Core_Product_Application__c AND core_cpq_vertical_market_nm__c =: verticalmarket)
                    ];
                    if (!prodDetails.isEmpty()) {
                        quoteToInsert.core_cpq_business_unit_nm__c = prodDetails[0].core_cpq_business_unit_nm__c;
                        quoteToInsert.core_cpq_segment_nm__c = prodDetails[0].core_cpq_segment_nm__c;
                    }
                }
                    if (quoteToInsert != null) {
                        Profile p=[Select Id,Name from Profile where Id =: UserInfo.getProfileId() LIMIT 1];
                        if(p.Name=='Partner'){
                            SBQQ.TriggerControl.disable();
                            insert quoteToInsert;
                            SBQQ.TriggerControl.enable();
                        }else{
                            insert quoteToInsert;
                        }                        
                        List < SBQQ__QuoteLine__c > quotelinesTodelete = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteToInsert.Id];
                        if (!quotelinesTodelete.isEmpty()) {
                            delete quotelinesTodelete;
                        }
                        createQuoteLine(opportunityId, quoteToInsert.Id, opportunityRecord.Core_First_Customer_Ship_Date__c);
                        quoteDetails = [SELECT NAME, core_cpq_quote_ref__c FROM SBQQ__Quote__c WHERE ID =: quoteToInsert.Id];
                        quoteNumber = quoteDetails[0].NAME;
                        quoteNumber = quoteNumber + ':' + quoteDetails[0].Id;
                    }
                }
            }
        catch (Exception ex) {
            throw ex;
        }finally{
            SBQQ.TriggerControl.enable();
        }
        return quoteNumber;
    }
    /****************************************************************************************************************
    * Method Name:createQuoteLine
    * Date: 12/7/2020  
    * Description: Method to create quotelines when quote is created from opportunity.
    ***************************************************************************************************************************/
    public static void createQuoteLine(Id oppId, Id quoteId, Date priceEligibleDate) {
        try {

            Set < String > invalidOPNSet = new Set < String > ();
            Id recId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('PSG Quote Line - Submitted').getRecordTypeId();

            List < OpportunityLineItem > opportunityProduct = new List < OpportunityLineItem > ([SELECT id, product2id, Product2.Name, Product2.Core_OPN__c, Product2.IsActive,
                Product2.Core_Item_Quotable_Ind__c,
                UnitPrice, Quantity, Core_Design_Registration_Product_Id__c
                FROM OpportunityLineItem WHERE OpportunityId =: oppId
            ]);
            List < SBQQ__QuoteLine__c > quoteLineList = new List < SBQQ__QuoteLine__c > ();
            if (!opportunityProduct.isEmpty()) {
                Map < Id, SBQQ__QuoteLine__c > designRegistrationProdMap = new Map < Id, SBQQ__QuoteLine__c > ();
                Set < Id > designRegistrationProdIdSet = new Set < Id > ();
                Set<String> inactiveOPNs=new Set<String>();
                Map<String,Product2> recentActiveProducts=new Map<String,Product2>();
                for (OpportunityLineItem lineItem: opportunityProduct) {
                    if (!lineItem.Product2.IsActive || !lineItem.Product2.Core_Item_Quotable_Ind__c) {
                        inactiveOPNs.add(lineItem.Product2.Core_OPN__c);
                    }
                }
                
                for (Product2 prod: [Select Id,Core_OPN__c from Product2 where Core_Product_Org__c='Sales' and IsActive=true and Core_Item_Quotable_Ind__c=true and Core_OPN__c in :inactiveOPNs]) {
                    recentActiveProducts.put(prod.Core_OPN__c,prod);
                }
                
                for (OpportunityLineItem lineItem: opportunityProduct) {
                    if ((lineItem.Product2.IsActive && lineItem.Product2.Core_Item_Quotable_Ind__c) || recentActiveProducts.containsKey(lineItem.Product2.Core_OPN__c) ) {
                        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                        quoteLine.SBQQ__Quote__c = quoteId;
                        if(lineItem.Product2.IsActive && lineItem.Product2.Core_Item_Quotable_Ind__c){
                        quoteLine.SBQQ__Product__c = lineItem.product2Id;
                        quoteLine.core_cpq_opn__c = lineItem.Product2.Core_OPN__c;
                        }else{
                            quoteLine.SBQQ__Product__c = recentActiveProducts.get(lineItem.Product2.Core_OPN__c).Id;
                        	quoteLine.core_cpq_opn__c = recentActiveProducts.get(lineItem.Product2.Core_OPN__c).Core_OPN__c;
                        }
                        
                        quoteline.core_cpq_years_nbr__c = 1;
                        quoteline.core_cpq_production_dt__c = System.Today();
                        quoteLine.RecordTypeId = recId;
                        quoteLine.price_requested_resale_amt__c = lineItem.UnitPrice;
                        quoteLine.SBQQ__Quantity__c = lineItem.Quantity;
                        quoteLine.core_cpq_upper_bound_qty_nbr__c = lineItem.Quantity;
                        quoteLine.core_cpq_price_eligibility_date_dt__c = priceEligibleDate;
                        quoteLine.core_cpq_production_dt__c = priceEligibleDate;
                        quoteLine.core_cpq_origin_txt__c = 'Oppty'; 
                        if (lineItem.Core_Design_Registration_Product_Id__c != null) {
                            designRegistrationProdMap.put(lineItem.Core_Design_Registration_Product_Id__c, quoteLine);
                            designRegistrationProdIdSet.add(lineItem.Core_Design_Registration_Product_Id__c);

                        } else {
                            quoteLine.core_cpq_design_registration_product__c = null;
                            quoteline.core_cpq_lower_bound_qty_qty__c = 1;
                            quoteLineList.add(quoteLine);
                        }
                    } else {
                        invalidOPNSet.add(lineItem.Product2.Core_OPN__c);
                    }
                }
                if (!designRegistrationProdIdSet.isEmpty()) {
                    for (Core_Design_Registration_Product__c designRegProd: [SELECT Id, Core_Full_Year_Qty__c FROM Core_Design_Registration_Product__c
                            WHERE Id IN: designRegistrationProdIdSet
                        ]) {
                        SBQQ__QuoteLine__c ql = designRegistrationProdMap.get(designRegProd.Id);
                        ql.core_cpq_design_registration_product__c = designRegProd.Id;
                        ql.core_cpq_lower_bound_qty_qty__c = 1;
                        quoteLineList.add(ql);
                    }
                }
            }
            

            if (!quoteLineList.isEmpty()) {
                Database.SaveResult[] result = Database.insert(quoteLineList,false);
                for(Integer i=0;i<result.size();i++){
                    if(!result[i].isSuccess()){
                        invalidOPNSet.add(quoteLineList[i].core_cpq_opn__c);
                    }
                }
               
            }
            
            if (!invalidOPNSet.isEmpty()) {
                SBQQ__Quote__c quote = new SBQQ__Quote__c();
                quote.Id = quoteId;
                List<String> opnList = new List<String>(invalidOPNSet);
                quote.core_cpq_invalid_opns_dup__c=(opnList.size() >1 ?  opnList[0]+'...': opnList[0]);
                quote.core_cpq_invalid_opn_ta__c = String.join(new List < String > (invalidOPNSet), ',');
                update quote;
            }
        } catch (Exception e) {
            PSG_Utility.logError(e);
        }

    }
    /****************************************************************************************************************
    * Method Name:getLoginUserType
    * Date: 12/7/2020  
    * Description: Method to get the currently logged in user.
    ***************************************************************************************************************************/
    @AuraEnabled
    public static String getLoginUserType() {
        String userType = PSG_Utility.getLoginUserType(userInfo.getUserId());
        return userType;
    }
}