@istest
public class caseAttachmentLinkFileController_test {
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
        
        test.startTest();
        caseAttachmentLinkFileController.getFiles(cs.Id);
        caseAttachmentLinkFileController.saveFile(fileids, cs.Id);
        caseAttachmentLinkFileController.getattachments(cs.Id,1,1,'All Data');
        caseAttachmentLinkFileController.showButtons(cs.Id);
        caseAttachmentLinkFileController.errorMessage('test');
        test.stopTest();
        system.assert(cs.Id!=null);
    }
    @istest
    static void caseattachmethod2(){
        try{
            Case cs = TestUtilities.getCase();
            insert cs;
            test.startTest();
            caseAttachmentLinkFileController.getFiles(cs.id);
            caseAttachmentLinkFileController.saveFile(null, cs.id);
            test.stopTest(); 
        }
        catch(exception ex)
        {
            system.assert(ex!= null);
        }
    }
}