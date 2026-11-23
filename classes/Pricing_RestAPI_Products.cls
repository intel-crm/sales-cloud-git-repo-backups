/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_Products 
* Version     : 1.0 
* Created Date: 12 Oct 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         10/12/2020              Rest API to send product/competitor product values as response to the calling system

Sample API call:- /services/apexrest/v1.0/quoterequest/products?type=products&id=&searchText=&limit=100&offset=100
The above call sends the records of Product2 object as response

Sample API call:- /services/apexrest/v1.0/quoterequest/products?type=competitorproducts&id=&searchText=&limit=100&offset=100
The above call sends the records of Competitor Products(Pricing_Competitor_Product__c) object as response
*****************************************************************************************************************************************/

@RestResource(urlMapping='/*/quoterequest/products')
global without sharing class Pricing_RestAPI_Products {
    public static String reqType;
    public static String rowsLimit;
    public static String rowsOffset;
    public static String srchStr;
    public static String recId;
    public static String productType;
    public static Boolean isDPG = false;
    public static Integer intRowsLimit=0;
    public static Integer intRowsOffset=-1;
    public static String PRODUCTS = Label.Pricing_RestAPI_Products_Type; //'products';
    public static String COMPETITOR_PRODUCTS = Label.Pricing_RestAPI_Competitor_Prodcuts_Type; //'competitorproducts';
    public static Integer DEFAULT_ROWS_LIMIT = Integer.valueOf(Label.Pricing_RestAPI_DefaultRows_Limit);//10000;
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_Products.class.getName();
    
    @HttpGet
    global static Pricing_RestAPI_Response doGet(){        
        if(validateRequest()){
            processRequest();
        }else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    
    private static void processRequest(){
        user currentUser = [Select Id, ContactId,AccountId from User where Id = :UserInfo.getUserId()];
        if(reqType == PRODUCTS){
            getProducts(currentUser);
        }else if(reqType == COMPETITOR_PRODUCTS){
            getCompetitorProducts(currentUser); 
        }
    }
    
    /**
* @description 
* @author Subhanku | 06-16-2021
**/
    private static void getCompetitorProducts(user currentUser){
        try{ 
            String whereCaluse = getWhereClause();  
            String query = Label.Pricing_RestAPI_Competitor_Prodcuts_Query;
            query = String.escapeSingleQuotes(query);
            query = String.isEmpty(whereCaluse) ? query : query + whereCaluse;
            query = (intRowsLimit==0) ? query+' LIMIT :DEFAULT_ROWS_LIMIT' : query ;
            List<Pricing_Competitor_Product__c> compProducts = database.query(query);
            if(compProducts.size()>0){
                response.totalRecords = compProducts.size();
                response.successContent = getFinalCompProductsList(compProducts);                             
            }else{  
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.NO_DATA_EXCEPTION_9001, response, RESTAPI_NAME, ENTRY_TIME);
            }           
            
        }catch(Exception exp){ 
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }                
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,currentUser);            
        } 
    }
    
    /**
    * @description: Fetch the product based on the input parameters
    * @author Subhanku/Bharath | 03-24-2022 
    **/
    private static void getProducts(user currentUser){ 
        try{
            isDPG = (!String.isEmpty(productType))?(productType == Label.Pricing_RestAPI_Products_SSD_Param || 
                                                    productType == Label.Pricing_RestAPI_Products_NIC_Param)?true:false:false;
            String whereCaluse = getWhereClause();  //get the whereClause for the Products query
            String query = Label.Pricing_RestAPI_Prodcuts_Query; //retrieves the fields that needs to be fetched from the query
            query = String.escapeSingleQuotes(query);
            query = String.isEmpty(whereCaluse) ? query : query + whereCaluse;            
            query = (intRowsLimit==0) ? query+' LIMIT :DEFAULT_ROWS_LIMIT' : query ;  //if there is no limit value passed in input, default the limit to 10,000
            List<Product2> products = database.query(query);           
            if(products.size()>0){
                response.totalRecords = products.size();
                response.successContent = getFinalProductsList(products) ; //set the response successContent with the list of Products returned from the above query                          
            }else{
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.NO_DATA_EXCEPTION_9001, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }catch(Exception exp){  
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }                
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,currentUser);            
        }        
    }
    
    /**
    * @description: Get the list of products based on keyword/limit/offset
    * @author Bharath | 03-24-2022 
    * @param products
    * @return List<ProductWrapper> 
    **/
    private static List<ProductWrapper> getFinalProductsList(List<Product2> products){
        String prodType;
        List<ProductWrapper> finalProducts = new List<ProductWrapper>();
        if(intRowsOffset >= products.size()){            
            intRowsOffset = 0;   //if offset is greater than no. of products, default the offset to 0(zero)
        }
        if(intRowsLimit > 0 && intRowsOffset >= 0){     //if offset is valid
            Integer counter = 0;
            
            //fetches the records from offset till the limit
            for(Integer start=intRowsOffset; counter < intRowsLimit && start < products.size()  ; start++){
                Product2 prodct = products.get(start);
                prodType =  (prodct.Core_Product_Type__c == 'Memory and Storage')?
                    (Label.Pricing_Tender_SSD_BU_OpCode.split(',').contains(prodct.Core_BU_Operation_Code__c)?Label.Pricing_RestAPI_Products_SSD_Param:
                     Label.Pricing_Tender_PMem_BU_OpCode.split(',').contains(prodct.Core_BU_Operation_Code__c)?Label.Pricing_RestAPI_Products_PMem_Param:''):
                (prodct.Core_Product_Type__c == 'Ethernet Products' && (Label.Pricing_Tender_Ethernet_BU_OpCode.split(',').contains(prodct.Core_BU_Operation_Code__c)))? Label.Pricing_Tender_NIC_Quote: 
                //productType != Label.Pricing_Tender_Processor_Product && (Label.Pricing_Tender_CCG_ProdType.split(',').contains(prodct.Core_VerticalSegment__c)) ? Label.Pricing_Tender_CCG_Quote :
                //(prodct.Core_Product_Type__c == Label.Pricing_Tender_Processor_Product && (!String.isEmpty(prodct.Core_Group_Code_Short_Name__c)?prodct.Core_Group_Code_Short_Name__c.contains('CCG'):false) && productType!=Label.Pricing_Tender_Processor_Product)?Label.Pricing_Tender_CCG_Quote: //CH - Added logic to check the 'Client' productType 
                (prodct.Core_Product_Type__c == Label.Pricing_Tender_Processor_Product)?Label.Pricing_Tender_Processor_Product:
                (prodct.Core_Product_Type__c == Label.Pricing_Tender_Graphics_Product)?Label.Pricing_Tender_Graphics_Product:
                (prodct.Name == Label.Pricing_Write_In_Product)?'':Label.Pricing_Tender_Processor_Product;
                finalProducts.add(new ProductWrapper(String.valueOf(prodct.Id), prodct.Name,prodct.Core_Processor_Number_Nm__c,prodType,prodct.Core_Mem_Amt__c,prodct.Core_Code_Name__c,prodct.Core_Family_Nm__c,prodct.Core_Forecast_Product_Name__c,prodct.Core_Item_Id__c,prodct.Core_VerticalSegment__c,prodct.Core_CoreCount__c));
                ++counter;
            }
        }else{
            
            //if there is no limit and offset, return complete products list
            for(Product2 prodct: products){
                prodType = (prodct.Core_Product_Type__c == 'Memory and Storage')?
                    (Label.Pricing_Tender_SSD_BU_OpCode.split(',').contains(prodct.Core_BU_Operation_Code__c)?Label.Pricing_RestAPI_Products_SSD_Param:
                     Label.Pricing_Tender_PMem_BU_OpCode.split(',').contains(prodct.Core_BU_Operation_Code__c)?Label.Pricing_RestAPI_Products_PMem_Param:''):
                (prodct.Core_Product_Type__c == 'Ethernet Products' && (Label.Pricing_Tender_Ethernet_BU_OpCode.split(',').contains(prodct.Core_BU_Operation_Code__c)))? Label.Pricing_Tender_NIC_Quote: 
                //productType != Label.Pricing_Tender_Processor_Product && (Label.Pricing_Tender_CCG_ProdType.split(',').contains(prodct.Core_VerticalSegment__c)) ? Label.Pricing_Tender_CCG_Quote :
                //(prodct.Core_Product_Type__c == Label.Pricing_Tender_Processor_Product && (!String.isEmpty(prodct.Core_Group_Code_Short_Name__c)?prodct.Core_Group_Code_Short_Name__c.contains('CCG'):false) && productType!=Label.Pricing_Tender_Processor_Product)?Label.Pricing_Tender_CCG_Quote: //CH - Added logic to check the 'Client' productType
                (prodct.Core_Product_Type__c == Label.Pricing_Tender_Processor_Product)?Label.Pricing_Tender_Processor_Product :
                (prodct.Core_Product_Type__c == Label.Pricing_Tender_Graphics_Product)?Label.Pricing_Tender_Graphics_Product:
                (prodct.Name == Label.Pricing_Write_In_Product)?'':Label.Pricing_Tender_Processor_Product;
                finalProducts.add(new ProductWrapper(String.valueOf(prodct.Id), prodct.Name,prodct.Core_Processor_Number_Nm__c,prodType,prodct.Core_Mem_Amt__c,prodct.Core_Code_Name__c,prodct.Core_Family_Nm__c,prodct.Core_Forecast_Product_Name__c,prodct.Core_Item_Id__c,prodct.Core_VerticalSegment__c,prodct.Core_CoreCount__c));
            }
        }        
        return finalProducts;
    }
    
    /**
    * @description: Get the list of competitor products based on keyword/limit/offset
    * @author Subhanku | 06-16-2021 
    * @param compProducts 
    * @return List<CompetitorProduct> 
    **/
    private static List<CompetitorProduct> getFinalCompProductsList(List<Pricing_Competitor_Product__c> compProducts){
        List<CompetitorProduct> finalCompProducts = new List<CompetitorProduct>();
        if(intRowsOffset >= compProducts.size()){            
            intRowsOffset = 0;      //if offset is greater than no. of products, default the offset to 0(zero)
        }
        if(intRowsLimit > 0 && intRowsOffset >= 0){
            Integer counter = 0;
            
            //fetches the records from offset till the limit
            for(Integer start=intRowsOffset; counter < intRowsLimit && start < compProducts.size()  ; start++){
                Pricing_Competitor_Product__c prodct = compProducts.get(start);
                finalCompProducts.add(new CompetitorProduct(String.valueOf(prodct.Id), prodct.Name,prodct.Pricing_Competitor_Product_Provider_Nm__c,prodct.RecordType.Name,prodct.Pricing_Active_cb__c)); //CH - New parameter productType is added in response
                ++counter;
            }
        }else{
            
            //if there is no limit and offset, return complete products list
            for(Pricing_Competitor_Product__c compProdct: compProducts){
                finalCompProducts.add(new CompetitorProduct(String.valueOf(compProdct.Id), compProdct.Name, compProdct.Pricing_Competitor_Product_Provider_Nm__c,compProdct.RecordType.Name,compProdct.Pricing_Active_cb__c)); //CH - New parameter productType is added in response
            }
        }        
        return finalCompProducts;
    }  
    
    /**
    * @description: Method that returns the whereClause to be used in the Products query in the getProducts() method
    * @author Subhanku/Bharath | 03-24-2022 
    * @return String 
    **/
    private static String getWhereClause(){
        String whereClause = '';
        if(reqType == PRODUCTS) {
            whereClause = (!String.isEmpty(productType))?(productType == Label.Pricing_RestAPI_Products_SSD_Param?(getMetadataWhereClause(productType))[0]:
                                                          productType == Label.Pricing_RestAPI_Products_PMem_Param?(getMetadataWhereClause(productType))[0]:
                                                          productType == Label.Pricing_RestAPI_Products_NIC_Param?(getMetadataWhereClause(productType))[0]:
                                                          productType == Label.Pricing_Tender_Graphics_Product?(getMetadataWhereClause(productType))[0]:
                                                          productType == Label.Pricing_Tender_CCG_Quote?(getMetadataWhereClause(productType))[0]: //CH - Added condition to get Where clause for 'Client' productType from Custom Metadata
                                                          productType == Label.Pricing_Tender_Processor_Product?' WHERE '+ Label.Pricing_RestAPI_Products_CommonFilter:
                                                          productType == 'All'?' WHERE ('+ (Label.Pricing_RestAPI_Products_CommonFilter + 
                                                                                            ' ' + (getMetadataWhereClause(productType))[0]) + ')':
                                                          ' WHERE '+ Label.Pricing_RestAPI_Products_CommonFilter):' WHERE '+ Label.Pricing_RestAPI_Products_CommonFilter;
            whereClause = ' ' + whereClause;
            if(!String.isEmpty(srchStr)){
                whereClause += (!String.isEmpty(productType) && productType == 'All')?
                    (' AND (Name LIKE ' + '\'%'+srchStr+'%\'' + ' OR Core_Processor_Number_Nm__c LIKE ' + '\'%'+srchStr+'%\'' + ')'):
                (productType == Label.Pricing_RestAPI_Products_PMem_Param)?
                    (getMetadataWhereClause(productType))[1].replace('{{searchString}}','%'+srchStr+'%'):
                (isDPG != false)?(getMetadataWhereClause(productType))[1].replace('{{searchString}}','%'+srchStr+'%'):
                (productType == Label.Pricing_Tender_CCG_Quote)?  //CH - Added condition for 'Client' search text 
                    (getMetadataWhereClause(productType))[1].replace('{{searchString}}','%'+srchStr+'%'):
                    ' AND (Name LIKE ' + '\'%'+srchStr+'%\'' + ' OR Core_Processor_Number_Nm__c LIKE ' + '\'%'+srchStr+'%\'' + ')'; // Ch-vru-TWC1972-5311
            }
            if(!String.isEmpty(recId)){
                whereClause += ' AND id=\''+ String.escapeSingleQuotes(recId)+'\'';
            }           
        }else if(reqType == COMPETITOR_PRODUCTS) {
            String strWhrClause = '';
            if(!String.isEmpty(recId)){
                strWhrClause = ' id=\''+ String.escapeSingleQuotes(recId)+'\'';
            }
            if(!String.isEmpty(srchStr)){
                strWhrClause = (String.isEmpty(strWhrClause)) ? ' Name LIKE \'%'+ String.escapeSingleQuotes(srchStr)+'%\'' :  strWhrClause+' AND Name LIKE \'%'+ String.escapeSingleQuotes(srchStr)+'%\'';
            }
            //CH.Start - Added logic to filter COMPETITOR PRODUCTS records on the basis of productType (Client/DataCenter/All)
            String recordTypeFilter = productType==Label.Pricing_Tender_CCG_Quote ? Label.Pricing_Tender_CCG_Quote : productType.toLowerCase()=='datacenter' ? 'Data Center' :productType.toLowerCase()=='graphics' ? 'Graphics' : 'All';
            if(recordTypeFilter != 'All'){
                strWhrClause =(String.isEmpty(strWhrClause)) ? ' (RecordType.Name=\''+ String.escapeSingleQuotes(recordTypeFilter)+'\' OR Name = \''+Label.Pricing_Tender_Write_In_Product+'\')' :  strWhrClause+' AND  (RecordType.Name=\''+ String.escapeSingleQuotes(recordTypeFilter)+'\' OR Name = \''+Label.Pricing_Tender_Write_In_Product+'\')';   
            }
            //CH.End
            whereClause = (String.isEmpty(strWhrClause) ? ' WHERE Pricing_Active_cb__c=true' : ' WHERE '+strWhrClause + ' AND Pricing_Active_cb__c=true');
        }
        return whereClause;
    }
    
    /**
    * @description: Validate the input parameters specified in the endpoint URL
    * @author Subhanku/Bharath | 03-24-2022 
    * @return boolean 
    **/
    private static boolean validateRequest(){
        boolean isValid = true;
        RestRequest restReq = RestContext.request;
        reqType = String.isEmpty(restReq.params.get('type')) ? null : restReq.params.get('type').toLowerCase();
        srchStr = restReq.params.get('searchText');
        recId = restReq.params.get('id');
        productType = restReq.params.get('productType');
        rowsLimit = restReq.params.get('limit');
        rowsOffset = restReq.params.get('offset'); 
        /*code block to verify if reqType/rowsLimit/rowsOffset are valid, 
        check if its a valid productType and to check if rowsLimit/rowsOffset are invalid numbers*/
        isValid = (String.isEmpty(reqType) || (reqType!=PRODUCTS && reqType!=COMPETITOR_PRODUCTS ) || 
                   (!String.isEmpty(rowsLimit) && !rowsLimit.isNumeric()) || (!String.isEmpty(rowsOffset) && !rowsOffset.isNumeric()) || 
                   (!String.isEmpty(recId) && recId.length()!=15 && recId.length()!=18))?false:((!String.isEmpty(rowsLimit) && rowsLimit.isNumeric() 
                                                                                                 && Integer.valueOf(rowsLimit)<=0) || 
                                                                                                (!String.isEmpty(rowsOffset) && 
                                                                                                 rowsOffset.isNumeric() && 
                                                                                                 Integer.valueOf(rowsOffset)<0))?false:
        (!String.isEmpty(productType) && !(productType == Label.Pricing_RestAPI_Products_SSD_Param || 
                                           productType == Label.Pricing_RestAPI_Products_PMem_Param || 
                                           productType == Label.Pricing_RestAPI_Products_NIC_Param || 
                                           productType == Label.Pricing_Tender_Graphics_Product ||
                                           productType == Label.Pricing_Tender_Processor_Product || 
                                           productType == Label.Pricing_Tender_CCG_Quote ||   //CH - Added check for 'Client' productType
                                           (reqType==COMPETITOR_PRODUCTS && productType.toLowerCase()=='datacenter') || //CH - Added check for 'DataCenter' productType for type 'COMPETITOR_PRODUCTS'
                                           (reqType==COMPETITOR_PRODUCTS && productType.toLowerCase()=='graphics') ||
                                           productType == 'All'))?false:true;
        
        if(isValid){
            productType = (String.isEmpty(productType) && reqType==PRODUCTS)?Label.Pricing_Tender_Processor_Product:(String.isEmpty(productType) && reqType==COMPETITOR_PRODUCTS)?'datacenter':productType; //CH - Added new parameter 'Data Center' for COMPETITOR_PRODUCTS API
            intRowsLimit = String.isEmpty(rowsLimit) ? 0 : Integer.valueOf(rowsLimit);
            intRowsOffset = String.isEmpty(rowsOffset) ? 0 : Integer.valueOf(rowsOffset);
        }
        return isValid;
    }
    
    /**
    * @description: Method written to retrieve the custom metadata record Where Clause column value based on the Product Type parameter
    * @author Bharath Chandrashekar | 03-24-2022
    * @param productType 
    * @return List<String> 
    **/
    public static List<String> getMetadataWhereClause(String productType){
        String whereClause;
        String searchColumn;
        List<String> whereClauseWithSearchCol = new List<String>();
        // NIC is Same as Ethernet
        //String dpgProdTypes = Label.Pricing_AllProducts_Param;
        List<Pricing_Dynamic_Data_Table__mdt> productTypeMetadataList = new List<Pricing_Dynamic_Data_Table__mdt>();
        List<String> whereClauseList = new List<String>();
        if(productType == 'All'){
            productTypeMetadataList = [SELECT Id, Pricing_Query__c, Pricing_Record_Type__c, Pricing_Where_Clause__c 
                                       FROM Pricing_Dynamic_Data_Table__mdt WHERE DeveloperName IN: (Label.Pricing_AllProducts_Param.split(','))];
            if(productTypeMetadataList.size() > 0) {
                for(Pricing_Dynamic_Data_Table__mdt mdt : productTypeMetadataList ) {
                    if(String.isNotBlank(mdt.Pricing_Where_Clause__c)) {
                        whereClause =  mdt.Pricing_Where_Clause__c.replace('where','WHERE');
                        whereClause = whereClause.replace('WHERE', 'OR');
                        whereClauseList.add(whereClause);
                    }
                }
            }
            whereClause = whereClauseList[0]+ ' ' + whereClauseList[1]+ ' ' + whereClauseList[2] + whereClauseList[3];
            whereClauseWithSearchCol.add(whereClause);
        }
        else{
            // NIC is Same as Ethernet
            String prodType = productType == Label.Pricing_RestAPI_Products_NIC_Param ? Label.Pricing_AllProducts_Param.split(',')[2] 
                : productType == Label.Pricing_RestAPI_Products_SSD_Param ? Label.Pricing_AllProducts_Param.split(',')[0]
                    : productType == Label.Pricing_RestAPI_Products_PMem_Param ? Label.Pricing_AllProducts_Param.split(',')[1]
                        : productType == Label.Pricing_Tender_Graphics_Product ? Label.Pricing_AllProducts_Param.split(',')[4]
                            : productType == Label.Pricing_Tender_CCG_Quote ? Label.Pricing_AllProducts_Param.split(',')[3] //CH - Added condition for 'Client' productType
                                : productType;
            productTypeMetadataList = [SELECT Id, Pricing_Query__c, Pricing_Record_Type__c, Pricing_Where_Clause__c, 
                                       Pricing_SearchColumn_Field__c FROM Pricing_Dynamic_Data_Table__mdt 
                                       WHERE DeveloperName =: prodType];
            if(productTypeMetadataList.size() > 0) {
                for(Pricing_Dynamic_Data_Table__mdt mdt : productTypeMetadataList ) {
                    if(String.isNotBlank(mdt.Pricing_Where_Clause__c)) {
                        whereClause =  mdt.Pricing_Where_Clause__c;
                        searchColumn = mdt.Pricing_SearchColumn_Field__c;
                        whereClauseWithSearchCol.add(whereClause);
                        whereClauseWithSearchCol.add(searchColumn);
                    }
                }
            }
        }
        return whereClauseWithSearchCol;
    }
    
    //Wrapper that is used for the Response of the Product GET API containing the product fields
    public class ProductWrapper implements Pricing_RestAPI_SuccessContent {
        public String id {set;get;}
        public String name {set;get;}
        public String processorNumber {set;get;}
        public String productType {set;get;}
        public String density {set;get;}
        public String codeName {set;get;}
        public String familyName {set;get;}
        public String forecastProductName {set;get;}
        public String materialId {set;get;}
        public String subProductType {set;get;}
        public String coreCount {set;get;}
        public ProductWrapper(String recId, String prodName, String procNum, String prodType, String dnsty, String cdName, String fmName, String fPrdName, String mtrlId, String subProduct, String crCount){
            id = recId;
            name = prodName;
            processorNumber = procNum;
            productType = prodType;
            density = dnsty;
            codeName = cdName;
            familyName = fmName;
            forecastProductName = fPrdName;
            materialId = mtrlId;
            subProductType = subProduct;
            coreCount = crCount;
        }
    }
    
    //Wrapper that is used for the Response of the Product GET API containing the competitor product fields    
    public class CompetitorProduct implements Pricing_RestAPI_SuccessContent {
        public String id {set;get;}
        public String name {set;get;}
        public String provider {set;get;}
        public String productType {set;get;} //CH - Added new field in response
        public Boolean active {set;get;}
        public CompetitorProduct(String recId, String prodName, String prodProvider, String prodType,Boolean prodActive){ //CH Added new paramter 'prodType' 
            id = recId;
            name = prodName;    
            provider = prodProvider;
            productType = prodType;
            active = prodActive;
        }
    }
}