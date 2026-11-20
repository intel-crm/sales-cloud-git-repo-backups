public class Product_Staging_StaticConstants {    
        public static final String vphId = '43';
        public static final String vplchId = '59';
        public static final String ips= 'IPS';
        public static final String five = '5';
        public static final String sales = 'Sales';
        public static final String yes = 'Yes'; 
        public static final String FPH = 'FPH';
        public static final String FPGA_EPMId = '98836';
        public static final String OPN_FieldName = 'Core_Product_Name__c';
        public static final list<string> Product_EpmIdsSet = System.Label.Product_EpmIds.split(';') ; 
        public static final list<string> Product_EpmNamesSet = System.Label.Product_EpmNames.split(';') ; 
        public static final List<string> vplchIpsFilter =  system.label.IPS_VPLCH.split(';');
        public static final List<string> vplchSalesFilter =  system.label.Sales_VPLCH.split(';');
    	public static final String OPN_Deactivation = 'OPN_Deactivation';
    	public static final String Status_Deactivation = 'Status_Deactivation';
    	public static final Integer Product_UpsertProduct2BatchSize = integer.Valueof(System.Label.Product_UpsertProduct2BatchSize);
        public static final Boolean isLevel5 = true ;
        public static final list<String> Product_StatusFilter = System.Label.Product_Status_Code_Filter.split(';'); 
        public static final String SourceName = 'PIM';
        public static final Decimal StandardCost = 0.0;
        public static final List<String> retainOldValues = System.Label.Product_Non_Filtered_Fields.split(';');
        public static final List<String> charLimit255Fields = System.Label.Product_Character_limit_255_Fields.split(';');
        public static final List<String> charLimit255SalesFields = System.Label.Product_Character_limit_255_Sales_Fields.split(';');
        public static final List<String> SOFTWARE_EPMID = System.Label.Product_Software_Epmid.split(';');

    


}