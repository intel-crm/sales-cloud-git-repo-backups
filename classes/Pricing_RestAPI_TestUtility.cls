/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_TestUtility 
* Version     : 1.0 
* Created Date: 08 October 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         10/08/2020              Utility class for specific error codes
*****************************************************************************************************************************************/
@isTest
public class Pricing_RestAPI_TestUtility {
    public static final String REQUEST_TEMPLATE = '{"resourcePath":"/services/apexrest/v1.0/unitTest","requestURI":"/v1.0/unitTest","requestBody":"","remoteAddress":"170.178.140.170","params":{},"httpMethod":"GET","headers":{"X-Salesforce-SIP":"170.178.140.170","Accept-Language":"en-US,en;q=0.9","Accept-Encoding":"gzip, deflate, br","Postman-Token":"09c84838-c53c-e33a-34ed-1717086d6c9e","Host":"intel--crmdevcase.cs92.my.salesforce.com","User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36","Connection":"keep-alive","CipherSuite":"ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 256-bits","Accept":"*/*","Cache-Control":"no-cache"}}';
    public static void createRestAPIErrorCodesConfig(){
        List<Core_RestAPI_Response_Codes__c> respCodes = new List<Core_RestAPI_Response_Codes__c>();
        respCodes.add(new Core_RestAPI_Response_Codes__c(Name = 'ApexException', Core_Code__c = '500', Core_Http_Status_Code__c = '500',
                                          Core_RestAPI_Error_Severity__c = 'Error', Core_Log_Entry__c = True,
                                          Core_Message__c='Technical error, please contact Intel support with the traceId'));
        
        respCodes.add(new Core_RestAPI_Response_Codes__c(Name = 'Default', Core_Code__c = '555', Core_Http_Status_Code__c = '500',
                                          Core_RestAPI_Error_Severity__c = 'Error', Core_Log_Entry__c = True,
                                          Core_Message__c='Technical error, please contact Intel support with the traceId'));
        
        respCodes.add(new Core_RestAPI_Response_Codes__c(Name = 'InvalidInputField', Core_Code__c = '9011', Core_Http_Status_Code__c = '400',
                                          Core_RestAPI_Error_Severity__c = 'Error', Core_Log_Entry__c = True,
                                          Core_Message__c='Invalid Input'));
        
        respCodes.add(new Core_RestAPI_Response_Codes__c(Name = 'NoDataException', Core_Code__c = '9001', Core_Http_Status_Code__c = '404',
                                          Core_RestAPI_Error_Severity__c = 'Info', Core_Log_Entry__c = True,
                                          Core_Message__c='Requested data is not available.'));
        
        insert respCodes;
        
    }
    public static void createCompetitorProducts(Integer numberOfRecs){
        Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true; 
        List<Pricing_Competitor_Product__c> compProdlist = new List<Pricing_Competitor_Product__c>();
		for(integer i=1; i<=numberOfRecs; i++)
			{
               	Pricing_Competitor_Product__c compprod=new Pricing_Competitor_Product__c();
              //  compprod.Name='CompProd'+i+'S AMD EPYC 400'+i+'E (16M Cache, 4C, 2.1GHz/2.9GHz), 3'+i+'W';
                compprod.Name='Write In Product'; //CH
        		compprod.Pricing_Competitor_Product_Provider_Nm__c='AMD';
                compprod.Pricing_Active_cb__c = true; 
        		compProdlist.add(compprod);			
                
            }
			    
        database.insert(compProdlist,dml);
    }
    public static void createProducts(Integer numberOfRecs){
        Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true; 
        List<Product2> productlist = new List<Product2>();
		for(integer i=1; i<=numberOfRecs; i++)
			{
               	Product2 product =new Product2();
                product.Name='Knights00'+i+'Bay00'+i;
        		product.Core_Product_Type__c='Processors';
                product.Core_Processor_Number_Nm__c = 'Processor00'+i+'Number-000'+i;
                //(Core_Product_Org__c='Sales' AND Core_Product_Type__c='Processors' AND 
                //Core_Sales_Visible_Flag__c = True AND IsActive=True AND Core_Hierarchy_ID__c='43' 
                //AND (Core_Group_Code_Short_Name__c LIKE '%CCG%' OR Core_Group_Code_Short_Name__c LIKE '%DCG%'))
                product.Core_Product_Org__c = 'Sales';
                product.Core_Sales_Visible_Flag__c = True;
                product.IsActive = True;
                product.Core_Hierarchy_ID__c = '43';
                product.Core_Group_Code_Short_Name__c = 'CCG P&L';
                product.Core_Avail_for_New_Designs__c=true;
        		productlist.add(product);			
                
            }
			    
        database.insert(productlist,dml);
    }
    
}