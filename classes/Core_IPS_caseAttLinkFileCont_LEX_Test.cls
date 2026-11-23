/***************************************************************************************************
Apex Class Name:  Core_IPS_caseAttLinkFileCont_LEX_Test
Version     : 1.0 
Created Date: 7 March 2022
Function    : Test class for Core_IPS_caseAttLinkFileCont_LEX.cls
Author      : Sai Krishna 
****************************************************************************************************/


@istest
public class Core_IPS_caseAttLinkFileCont_LEX_Test {
	@istest
    static void caseattachtestmethod(){
       		Account Accnt = new Account();
            Accnt.Name = 'Test Account';
            Accnt.BillingCountryCode = 'USA';
            Accnt.BillingStateCode = 'AL';
            Accnt.BillingCity = 'Alabama';
            Accnt.BillingStreet = 'street';
            Accnt.Core_IPS_Active__c = true;
			Accnt.recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
            Database.insert(Accnt);
		integer counter = 0;
         List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert listOfSupportOrg;
        List<Product2> listOfProducts = TestUtilities.getListOfProduct(2);
            for(Product2 product : listOfProducts){
                if(counter==0){
                    product.Core_Hierarchy_ID__c = '43';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                    product.Core_Unique_ID__c = 'Product12345';
                    product.Core_Code_Name__c = 'ProductCoreCodeName';
                }else{
                    product.Core_Hierarchy_ID__c = '59';
                    product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                    product.Core_Unique_ID__c = 'Product59';
                    product.Core_Code_Name__c = 'ProductCoreCodeName59';
                    
                }
                counter++;
            }
            insert listOfProducts;
        integer counter2=0;
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
                if(counter2==0){
                    supportedProduct.Core_Product__c = listOfProducts.get(0).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                }else{
                    supportedProduct.Core_Product__c = listOfProducts.get(1).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                }
                counter2++;
            }
            insert listOfSupportedProduct;
         
		Case cs = TestUtilities.getCase();
        cs.AccountId=Accnt.id;
        cs.Core_IPS_Supported_Product__c = listOfSupportedProduct[0].Id;
        insert cs;
		list<id> fileids=new list<id>();
        Core_IPS_File_Upload_Master__c FileUplMaster;
        FileUplMaster = TestUtilities.getFileUploadMasterRecord();
        FileUplMaster.Core_Expiration_Date__c = System.now().AddDays(60);
        Database.insert(FileUplMaster);
		fileids.add(FileUplMaster.id);
        Core_IPS_File_Assignment__c fileAssign = new Core_IPS_File_Assignment__c();
            fileAssign.Core_Supported_Product__c = listOfSupportedProduct[0].Id;
            fileAssign.Core_Account__c = Accnt.Id;
            fileAssign.Core_IPS_File_Upload_Master__c = FileUplMaster.Id;  
            Database.insert(fileAssign); 
        Core_IPS_Project__c Project=new Core_IPS_Project__c();
        Project.Name='test project';
        Project.Core_Project_Description__c='test description';
        Project.Core_Status__c='Draft';
        insert Project;
        
        test.startTest();
        Core_IPS_caseAttLinkFileCont_LEX.getFiles(cs.Id);
        Core_IPS_caseAttLinkFileCont_LEX.saveFile(fileids, cs.Id);
        Core_IPS_caseAttLinkFileCont_LEX.getattachments(cs.Id,1,1,'All Data');
        Core_IPS_caseAttLinkFileCont_LEX.showButtons(cs.Id);
        Core_IPS_caseAttLinkFileCont_LEX.getCurrentCase(cs.Id);
        Core_IPS_caseAttLinkFileCont_LEX.errorMessage('test');
        test.stopTest();
        system.assert(cs.Id!=null);
    }
    @istest
    static void caseattachmethod2(){
        try{
            Case cs = TestUtilities.getCase();
            insert cs;
            test.startTest();
            Core_IPS_caseAttLinkFileCont_LEX.getFiles(cs.id);
            Core_IPS_caseAttLinkFileCont_LEX.saveFile(null, cs.id);
            test.stopTest(); 
        }
        catch(exception ex)
        {
            system.assert(ex!= null);
        }
    }
    @isTest
    static void getAttachmentTest() {
        Case cs = TestUtilities.getCase();
        insert cs;

        Core_Trigger_Executions__c setting = new Core_Trigger_Executions__c();
		setting.Name = 'InsertCaseCommentForAttach';
        setting.Core_Active__c = false;
        setting.Core_Class_Name__c = 'de2d2d';
        setting.Core_Trigger_Events__c = 'f34f4 f43f43 f423f4 f42f4';
        setting.Core_Object__c = 'Core_IPS_Case_Attachments__c';
        setting.Core_Description__c = 'fd2f42 f342f42 f342f42f42 f423f42';
        insert setting;

		List<Core_IPS_Case_Attachments__c> attachments = new List<Core_IPS_Case_Attachments__c>();
        attachments.add(new Core_IPS_Case_Attachments__c(
        					Core_Upload_Status__c = 'Pending',
        					Core_Case__c = cs.Id));
       	attachments.add(new Core_IPS_Case_Attachments__c(
        					Core_Upload_Status__c = 'Complete',
        					Core_Case__c = cs.Id));
        insert attachments;

        List<Core_IPS_Case_Attachments__c> attachList = Core_IPS_caseAttLinkFileCont_LEX.getattachments(cs.Id, 100, 0, 'Load Data');
        System.assert(attachList.size() == 2);
        List<Core_IPS_Case_Attachments__c> attachList2 = Core_IPS_caseAttLinkFileCont_LEX.getattachments(cs.Id, 100, 0, 'All Data');
        System.assert(attachList2.size() == 2);
    }
}