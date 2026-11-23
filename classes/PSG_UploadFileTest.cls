/****************************************************************************************************
Apex Class Name : PSG_UploadFileTest
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_UploadFile.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay                    08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_UploadFileTest{
   @testSetup
    public static void setUpData(){
        List<User> lstUsers2 = PSG_Test_Utility.createAdminUser();
        if(!lstUsers2.isEmpty()){
            system.runAs(lstUsers2[0]){                
                Account acc = PSG_Test_Utility.createAccount();
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
                pricebook2 pb1=PSG_Test_Utility.CreatePriceBook('PSG Price Book');
                pricebook2 pb2=PSG_Test_Utility.CreatePriceBook('OEM');
                pricebook2 pb3=PSG_Test_Utility.CreatePriceBook('APJ');
                PSG_Test_Utility.CreateProduct(3);
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 1);
                PSG_UploadFile.getQLData(lstquote[0].Id);
                if(lstquote[0] != null){
                    pricebook2 pb = [Select id from pricebook2 limit 1];
                    lstquote[0].core_cpq_price_book_nm__c = pb.Id;
                    Update lstquote[0];
                    System.assert(lstquote[0].Id!=null,'Quote created');
                    Test.startTest();
                    PSG_Test_Utility.createQuoteLines(lstquote[0].Id, 3);
                    Test.stopTest();
                }
            }
        }
    }
    
    static testmethod void testSaveFile(){
        PSG_UploadFile.getFieldReferenceFieldObjectName('SBQQ__QuoteLine__c','price_goal_price_amt__c');
        PSG_UploadFile.getFieldType('SBQQ__QuoteLine__c','price_goal_price_amt__c');
        PSG_UploadFile.getNewSobject('SBQQ__QuoteLine__c');        List<SBQQ__QuoteLine__c> lstquoteLines = [select id from SBQQ__QuoteLine__c];
        System.assert(lstquoteLines[0].Id!=null,'Quote  Line created');
        List<PSG_Upload_File_Mapping__mdt> metaList=PSG_UploadFile.getUploadData();
        if(!lstquoteLines.isEmpty()){
            String csvData = 'GroupId,Object,Product Segment,Product Application,Business Unit, Segment,Active';
            csvData = csvData + '\\r\\n1'+',Product Details,Client Computing ,Business Desktop,Application,Application-Other,TRUE';
            csvData = csvData + '\\r\\n1'+',Product Details,Client Computing ,Business Desktop,Application,Application-Other,TRUE';
            Test.startTest();
            String newString = '\"'+ csvData + '\"';
            PSG_UploadFile.saveFile(newString,'Product Details',null,'All');
            String csvData1 = 'GroupId,Object,Product,End Customer,Quantity';
            csvData1 = csvData1 + '\\r\\n1' + ',Quote,,Dell,\\r\\n1,Quote Line,Test Processor Number1,,1'+'\\r\\n'+'1,Quote Line,Test Processor Number1,,2'+'\\r\\n';
            String newString1 = '\"'+ csvData1 + '\"';
            PSG_UploadFile.validatingAccess();
            Test.stopTest();
        }    
    }
    static testmethod void testSaveFile1(){
        pricebook2 pb=[Select Id from pricebook2 where Name='APJ'];
        System.assert(pb!=null,'PriceBook not empty');
        Map<String,List<String>> objectRowConsiderationMap = new Map<String,List<String>>();
        objectRowConsiderationMap.put('price_forward_cost__c',new List<String>{'core_cpq_forward_cost_period_name_nm__c','core_cpq_product_nm__c'});
        objectRowConsiderationMap.put('price_msvp__c',new List<String>{'core_cpq_product_nm__c','core_cpq_effective_date_dt__c'});
        objectRowConsiderationMap.put('core_cpq_distributor_margin__c',new List<String>{'core_cpq_Margin_GEO_Txt__c','core_cpq_Account_Tier_Txt__c','core_cpq_Approved_Registration_Txt__c','core_cpq_Partner_Program_Txt__c','core_cpq_Registered_Product_Txt__c','core_cpq_Effective_Date_Dt__c','core_cpq_Price_Book__c','core_cpq_dm_type__c','core_cpq_end_date__c'});
        objectRowConsiderationMap.put('core_cpq_list_price__c',new List<String>{'core_cpq_lowerbound_qty__c','core_cpq_upperbound_qty__c','core_cpq_product_name__c','Pricebookentry__c'});
        objectRowConsiderationMap.put('pricebookentry',new List<String>{'Product2Id','Pricebook2Id'});
        objectRowConsiderationMap.put('SBQQ__QuoteLine__c',new List<String>{'SBQQ__Quote__c','recordtypeid','core_cpq_product_nm__c',
                                                                            'core_cpq_quote_line_type_txt__c',
                                                                            'core_cpq_lower_bound_qty_qty__c',
                                                                            'core_cpq_upper_bound_qty_nbr__c'});
        Test.startTest();
        PSG_UploadFile.dataAssignment(new List<sObject>{new SBQQ__QuoteLine__c()},new Set<String>(),'SBQQ__QuoteLine__c',
                                      null,new List<String>(),objectRowConsiderationMap,'Quote Line');
        PSG_UploadFile.dataAssignment(new List<sObject>{new PriceBookEntry()},new Set<String>(),'PriceBookEntry',
                                      null,new List<String>{pb.Id},objectRowConsiderationMap,'PriceBookEntry');
        PSG_UploadFile.dataAssignment(new List<sObject>{new price_forward_cost__c()},new Set<String>(),'price_forward_cost__c',
                                      null,new List<String>{pb.Id},objectRowConsiderationMap,'Forward Cost');
        PSG_UploadFile.dataAssignment(new List<sObject>{new price_msvp__c()},new Set<String>(),'price_msvp__c',
                                      null,new List<String>{pb.Id},objectRowConsiderationMap,'MSVP');
        PSG_UploadFile.dataAssignment(new List<sObject>{new core_cpq_list_price__c()},new Set<String>(),'core_cpq_list_price__c',
                                      null,new List<String>{pb.Id},objectRowConsiderationMap,'List Price');
        PSG_UploadFile.dataAssignment(new List<sObject>{new core_cpq_distributor_margin__c()},new Set<String>(),'core_cpq_distributor_margin__c',
                                      null,new List<String>{pb.Id},objectRowConsiderationMap,'Distributor Margin');
        Test.stopTest();
    }
    
    @isTest
    static  void qlUploadTest(){
        SBQQ__Quote__c q=[SELECT Id from SBQQ__Quote__c LIMIT 1];
        System.assert(q!=null,'Quote not empty');
        String base64Data='Product,Quote Line Type,Lower Bound Qty,Upper Bound Qty,Quantity,Years,Goal Price,Price Eligibility Date,Requested Qty,Requested Resale $,Internal Comments\\r\\n5M80ZT100C5N,Qty Limited,1,100,100,10,500,8/15/2021,50,140.88,Test\\r\\n5M80ZT100C5N,AVP,1,100,100,10,500,8/15/2021,50,140.88,Test\\r\\n';
        String newString='\"'+base64Data+'\"';
        PSG_UploadFile.saveFile(newString,'Quote Line',q.Id,'All'); 
        Product2 p=new Product2(Name = 'Test Product123',IsActive = true,Core_OPN__c = '5M80ZT100C5N',Core_Sales_Visible_Flag__c = true, Core_Item_Orderable_Ind__c = true,Core_Item_Quotable_Ind__c = true);
        insert p;
        Test.startTest();
        PSG_UploadFile.saveFile(newString,'Quote Line',q.Id,'All'); 
        String pdData='Segment,\"Product Application\",Business Unit,Product Segment,Active\\r\\nTest,\"Test\",Test,Test,TRUE\\r\\n';
        String newString1='\"'+pdData+'\"';
        PSG_UploadFile.saveFile(newString1,'Product Details',null,'All');
        String pdData1='Part Number,Unit Price,Unit Cost\\r\\n5M80ZT100C5N,15,250\\r\\n5M80ZT100C5NG,45,450\\r\\n';
        String newString2='\"'+pdData1+'\"';
        PSG_UploadFile.saveFile(newString2,'Tools IP/Devkit Price Book',null,'APJ');
        Test.stopTest();
    }
    @isTest
    static  void compUploadTest(){
        String pdData1='Intel Part Number,Min Order Qty.,Mult Order Qty.,(1-24),(25-99),(100-499),(500-999),(1K-4999),(5K-9999),Unit Cost\\r\\n105,10,20,450,500,550,600,650,700,30\\r\\n106,10,20,250,300,350,400,450,500,40\\r\\n107,10,20,150,200,250,300,350,400,50\\r\\n';
        String newString2='\"'+pdData1+'\"';
        PSG_UploadFile.saveFile(newString2,'Components Price Book',null,'APJ');
        SBQQ__Quote__c q=[SELECT Id from SBQQ__Quote__c LIMIT 1];
        System.assert(q!=null,'Quote not empty');
        String base64Data='Product,Quote Line Type,Lower Bound Qty,Upper Bound Qty,Quantity,Years,Goal Price,Price Eligibility Date,Requested Qty,Requested Resale $,Internal Comments\\r\\n5M80ZT100C5N,Qty Limited,1,100,100,10,500,8/15/2021,50,140.88,Test\\r\\n5M80ZT100C5N,AVP,1,100,100,10,500,8/15/2021,50,140.88,Test\\r\\n';
        String newString='\"'+base64Data+'\"';
        PSG_UploadFile.saveFile(newString,'Quote Line CP',q.Id,'All');
        String base64Data1='Product,Quote Line Type,Lower Bound Qty,Upper Bound Qty,Quantity,Years,Goal Price,Price Eligibility Date,Requested Qty,Requested Resale $,Internal Comments\\r\\n5M80ZT100C5N,\"Qty Limited\",1,100,100,10,500,8/15/2021,50,140.88,Test\\r\\n5M80ZT100C5N,\"AVP\",1,100,100,10,500,8/15/2021,50,140.88,Test\\r\\n';
        String newString1='\"'+base64Data1+'\"';
        PSG_UploadFile.saveFile(newString1,'Quote Line CP',q.Id,'All'); 
        PSG_UploadFile.sendCSVEmail(new List<String>{'\"STandard\",20','\"STandard\",20','\"STandard\",20'},new Map<Integer,String>{1 => 'Custom Error'},new List<String>{'Name','Amount'}, 
                                                        'Quote',new core_cpq_bulk_upload_batch__c(),null,
                     new Set<Integer>{1,2,3},3,'Quote');
        Test.startTest();
        PSG_UploadFile.getQuoteType(q.Id);
        /*String base64Data3='OPN,FORWARDCOSTNAME,STARTDATE,ENDDATE,FORWARDCOST\\r\\n5M80ZT100C5N,Forward Cost 1,10/2/2021,10/10/2021,150\\r\\n5M80ZT100C5N,Forward Cost 2,10/6/2021,10/10/2021,150\\r\\n';
        String newString3='\"'+base64Data3+'\"';
        PSG_UploadFile.saveFile(newString1,'Forward Cost',null,'All');*/ 
        String pdData4='Intel Part Number,Min Order Qty.,Mult Order Qty.,(1-24),(25-99),(100-499),(500-999),(1K-4999),(5K-9999),Unit Cost\\r\\n105,10,20,450,500,550,600,650,700,30\\r\\n106,10,20,250,300,350,400,450,500,40\\r\\n107,10,20,150,200,250,300,350,400,50\\r\\n';
        String newString4='\"'+pdData4+'\"';
        PSG_UploadFile.saveFile(newString4,'Price Book Entry -- Components Price Book',null,'APJ');
        PSG_UploadFile.sendMail(1,2,'Quote Line',null,'',new List<String>{'\"STandard\",20','\"STandard\",20','\"STandard\",20'},
                                         new Map<Integer,String>{1 => 'Custom Error'},new List<String>{'Name','Amount'},new core_cpq_bulk_upload_batch__c(),
                                new Set<Integer>{1} ,2,'Quote Line',
                                         new List<Map<String,String>>(),new List<PSG_UploadFile.columnsWrapper>());
        PSG_UploadFile.getObjectList(new List<String>{'\"STandard\",20','\"STandard\",20','\"STandard\",20'},true,false, 'Quote Line',null,
                                              new List<String>(),new Map<String,String>(),'Quote Line',
                                              new Map<String,Set<String>>());
        
        /*list<BulkUploadDescription__mdt> bulkdes = new list<BulkUploadDescription__mdt>();
        bulkdes=PSG_UploadFile.getObjectDescriptions();
        system.assert(bulkdes.size()!=0);*/
        Test.stopTest();
    }
    
  
}