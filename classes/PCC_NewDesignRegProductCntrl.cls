/****************************************************************************************************************************************
* Class Name  : PCC_NewDesignRegProductCntrl 
* Version     : 1.0 
* Created Date:  01-08-2024
* Modification Log :
* Developer            		  Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Aravind                       01-08-2024         This is a controller class to PccNewDesignRegProductLwc LWC component
*****************************************************************************************************************************************/
public with sharing class PCC_NewDesignRegProductCntrl {
    static final String EMBEDDED_IOT = 'Embedded/IOT';
    static final String EMBEDDED_IOT_BS = 'Embedded/IOT Boards & Systems';
    static final String ODM = 'ODM';

    /**
     * This method is used to return price data details for the selected product or product mm attrbute record.
     */
    @AuraEnabled
    public static PriceDataResponse getPriceForProduct(String productId, String productMappingRecId, String designRegId) {
        try {
            PriceDataResponse res = new PriceDataResponse();
            String query;
            List<PCC_ParnterLed_Price__c> prices;
            Core_Design_Registration__c dr = new Core_Design_Registration__c();
            if (Core_Design_Registration__c.SObjectType.getDescribe().isAccessible()) {
                List<Core_Design_Registration__c> drs = [
                    SELECT Id, Core_Product_Group_Nm__c, Core_DDR_Partner_Type_Txt__c, Core_Partner_Account_Region_Cd__c
                    FROM Core_Design_Registration__c
                    WHERE Id = :designRegId
                ];

                dr = drs[0];
                if (String.isBlank(dr.Core_Product_Group_Nm__c) && dr.Core_DDR_Partner_Type_Txt__c != ODM) {
                    dr.Core_Product_Group_Nm__c = getProductType(productId, productMappingRecId);
                }
                if (dr.Core_Product_Group_Nm__c.contains(EMBEDDED_IOT)) {
                    query = getQuery(productId, productMappingRecId);
                    prices = Database.query(String.escapeSingleQuotes(query));
                    if (prices != null && !prices.isEmpty()) {
                        res = getResponse(dr, prices);
                    }
                    // Method to set payment eligibility info
                    setPaymentEligibleResponse(res, dr, productMappingRecId);
                }
            }

            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * This method is used to set payment eligibility details to the response for the selected product or product mm attrbute record.
     */
    private static void setPaymentEligibleResponse(PriceDataResponse res, Core_Design_Registration__c dr, String productMappingRecId) {
        if (
            String.isNotBlank(productMappingRecId) &&
            dr.Core_Product_Group_Nm__c == EMBEDDED_IOT &&
            Product_MM_Attribute_Mapping__c.SObjectType.getDescribe().isAccessible()
        ) {
            List<Product_MM_Attribute_Mapping__c> mmattribute = [
                SELECT Id, Eligible_for_DDI_Payment__c, Payment_Expiration_Date__c, DDI_focused__c,PCC_DDI_Program_Pay_Rate_APJ_PRC__c
                FROM Product_MM_Attribute_Mapping__c
                WHERE Id = :productMappingRecId
            ];
            if (String.isNotBlank(dr.Core_Partner_Account_Region_Cd__c) ) {
                res.ddiEligible = mmattribute[0].Eligible_for_DDI_Payment__c;
                res.expDate = mmattribute[0].Payment_Expiration_Date__c;
                if (dr.Core_Partner_Account_Region_Cd__c == 'ASMO' || dr.Core_Partner_Account_Region_Cd__c == 'EMEA') {
                    res.ddiFocused = mmattribute[0].DDI_focused__c;
                }
                else if (dr.Core_Partner_Account_Region_Cd__c == 'APJ' || dr.Core_Partner_Account_Region_Cd__c == 'PRC') {
                    res.ddiFocused = mmattribute[0].PCC_DDI_Program_Pay_Rate_APJ_PRC__c;
                }
            }
        }
    }

    /**
     * This method is used to get the product type of the selected product/
     */
    private static String getProductType(String productId, String productMappingRecId) {
        String productType = '';
        String prodId = getProductId(productId, productMappingRecId);

        if (String.isNotBlank(prodId) && Product2.SObjectType.getDescribe().isAccessible()) {
            List<Product2> prd = [SELECT Id, Core_Product_Type__c FROM Product2 WHERE Id = :prodId];

            if (!prd.isEmpty() && String.isNotBlank(prd[0].Core_Product_Type__c)){ //&& !(prd[0].Core_Product_Type__c).contains('FPGA')) {
                productType = LabelConfiguration__mdt.getInstance('PCC_Product_Group_Embedded').Value__c;
            }
        }

        return productType;
    }

    /**
     * This method is used to get product id for a selected product mm attribute record
     */
    private static String getProductId(String productId, String productMappingRecId) {
        String prodId;
        if (String.isNotBlank(productMappingRecId) && Product_MM_Attribute_Mapping__c.SObjectType.getDescribe().isAccessible()) {
            List<Product_MM_Attribute_Mapping__c> mmRecs = [
                SELECT Id, L4_Product__c, L5_Product__c
                FROM Product_MM_Attribute_Mapping__c
                WHERE Id = :productMappingRecId
            ];
            prodId = mmRecs[0].L4_Product__c != null ? mmRecs[0].L4_Product__c : mmRecs[0].L5_Product__c;
        } else {
            prodId = productId;
        }

        return prodId;
    }

    /**
     * This method is used set price data response wrapper
     */
    private static PriceDataResponse getResponse(Core_Design_Registration__c dr, List<PCC_ParnterLed_Price__c> prices) {
        PriceDataResponse res = new PriceDataResponse();
        res.priceType = dr.Core_Product_Group_Nm__c == EMBEDDED_IOT ? 'SDP' : (dr.Core_Product_Group_Nm__c == EMBEDDED_IOT_BS ? 'RCP' : null);

        for (PCC_ParnterLed_Price__c pp : prices) {
            if (res.sdp == null || res.sdp > pp.PCC_Standard_Disti_Price__c) {
                res.sdp = pp.PCC_Standard_Disti_Price__c;
            }
            if (res.rcp == null || res.rcp > pp.PCC_Recommended_Customer_Price__c) {
                res.rcp = pp.PCC_Recommended_Customer_Price__c;
            }
        }

        return res;
    }

    /**
     * This method is used to return price query string based on whether user selected L4 product or product mm attribute record
     */
    private static String getQuery(String productId, String productMappingRecId) {
        String query;
        if (String.isNotBlank(productMappingRecId)) {
            query = 'Select Id,PCC_Standard_Disti_Price__c,PCC_Recommended_Customer_Price__c FROM PCC_ParnterLed_Price__c WHERE PCC_Product_MM_Attribute_Mapping__c= :productMappingRecId';
        } else if (String.isNotBlank(productId) && Product2.SObjectType.getDescribe().isAccessible()) {
            List<Product2> prod = [
                SELECT Id, Core_Item_Id__c, Core_Product_Name_EPM_ID__c, Core_Unique_ID__c
                FROM Product2
                WHERE Id = :productId AND Core_Unique_ID__c != NULL
            ];

            if (!prod.isEmpty()) {
                Integer semicolonCount = (prod[0].Core_Unique_ID__c.split(';')).size();
                query =
                    'Select Id,PCC_Standard_Disti_Price__c,PCC_Recommended_Customer_Price__c FROM PCC_ParnterLed_Price__c WHERE PCC_L' +
                    semicolonCount +
                    '_Product__c= :productId';
            }
        }

        return query;
    }

    /**
     * This is a wrapper class for price data response.
     */
    public class PriceDataResponse {
        @AuraEnabled
        public String priceType { get; set; }

        @AuraEnabled
        public Decimal sdp { get; set; }

        @AuraEnabled
        public Decimal rcp { get; set; }

        @AuraEnabled
        public String ddiEligible { get; set; }

        @AuraEnabled
        public Date expDate { get; set; }

        @AuraEnabled
        public String ddiFocused { get; set; }

    }
}