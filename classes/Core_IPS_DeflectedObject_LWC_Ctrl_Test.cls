@isTest
public class Core_IPS_DeflectedObject_LWC_Ctrl_Test {
    
    @isTest 
    static void getAccounts_Method(){
        Core_IPS_Project__c Project=new Core_IPS_Project__c();
        Project.Name='test project';
        Project.Core_Project_Description__c='test description';
        Project.Core_Status__c='Draft';
        insert Project;
        
        Core_IPS_Product__c projectProduct = new Core_IPS_Product__c();
        projectProduct.Core_IPS_Project__c = Project.Id;
        projectProduct.Core_IPS_IsAutoApprove__c=true;
        projectProduct.Status__c='Submitted Pending';
        projectProduct.Core_IsSubmitted_Header__c=true;
        
        Product2 pdtObj = new Product2();
        pdtObj.Core_Product_Name_EPM_ID__c='750235';
        pdtObj.IsActive = true;
        pdtObj.Core_Code_Name_EPM_ID__c ='750235';
        pdtObj.Core_Sales_Visible_Flag__c = false;
        pdtObj.IsActive = true;
        pdtObj.Core_Product_Status__c= 'Active';
        pdtObj.Core_IPS_Visible_Flag_External__c = true;
        pdtObj.Core_IPS_Visible_Flag_Internal__c = 'Yes';
        pdtObj.Core_Product_Org__c = 'IPS';
        pdtObj.Core_Hierarchy_ID__c = '43';
        pdtObj.Core_Unique_ID__c = pdtObj.Name; 
        pdtObj.Name = 'testProd5';   
        insert pdtObj;
        System.AssertEquals(pdtObj.id != null, true);
        List<Core_IPS_Product_Organization__c> prodOrgList = new List<Core_IPS_Product_Organization__c>();
        prodOrgList = TestUtilities.getListOfSupportOrg(3);
        insert prodOrgList;
         
        Case CaseRec=new Case();
        CaseRec.Subject='Test Demo';
        CaseRec.Status='';
        CaseRec.Core_Sub_Status__c='Core_Sub_Status__c';
        CaseRec.Core_Severity__c='Low';
        CaseRec.Core_Severity_Reason__c='Testing case';
        CaseRec.Core_CaseType__c='Question';
        CaseRec.Core_IPS_Legacy_IPS_ID__c='Testing';
        CaseRec.Core_Customer_Reference_ID__c='customer test';
        CaseRec.Core_End_Customer__c='End customer test';
        CaseRec.Description='case test description';
        CaseRec.Core_IPS_Restricted_Secret_Content__c=True;
        CaseRec.Core_IPS_Knowledge_Base_Link__c='Case knowledge test';
        CaseRec.Core_IPS_Product_name__c='Test product';
        CaseRec.Core_IPS_Project_Case__c=Project.Id;
        insert CaseRec;
        
        Core_IPS_Supported_Product__c SupportedProductRecord = new Core_IPS_Supported_Product__c();
        SupportedProductRecord.Core_Product__c = pdtObj.id;
        SupportedProductRecord.Core_Product_Organization__c = prodOrgList.get(0).id;
        SupportedProductRecord.Core_Product_EPM_ID__c=pdtObj.core_code_name_EPM_ID__c;
        SupportedProductRecord.core_EOIS__C=false; 
        SupportedProductRecord.Core_Flag_Status__c = 'Approval Required';
        insert SupportedProductRecord;
        
        asset assetProduct=new asset();
        assetProduct.Name='TestAsset';
        assetProduct.Core_IPS_Project__c=Project.Id;
        assetProduct.Core_Supported_Product__c=SupportedProductRecord.Id;
        insert assetProduct;
        
        
        account Acc=new account();
        Acc.Name='test';
        Acc.BillingCity='new york';
        Acc.BillingCountry='united states';
        Acc.BillingCountryCode='';
        Acc.BillingStreet='st 124563 louis street';
        insert Acc;
        
        Contact con=new Contact();
        con.Firstname='test';
        con.lastname='test contact';
        con.Email='test@gmail.com';
        con.AccountId=Acc.Id;
        insert con;
        Core_IPS_Deflected_Object__c deflectedObj = new Core_IPS_Deflected_Object__c();
        deflectedObj.Core_IPS_Status__c = 'Deflected';
        deflectedObj.Core_IPS_Contact_Id__c = con.Id;
        deflectedObj.Core_IPS_Search_JSON__c = '';
        deflectedObj.Core_IPS_Description__c = 'Test';
        deflectedObj.Core_IPS_Description_on_Coveo__c = 'Test';
        deflectedObj.Core_IPS_Contact_Email__c = con.Email;
        deflectedObj.Core_IPS_Product__c = assetProduct.Id;
        insert deflectedObj;
        Core_IPS_DeflectedObject_LWC_Ctrl.updateDeflectedRecord(deflectedObj.Id,'Testing');
        Core_IPS_DeflectedObject_LWC_Ctrl.updateDeflectedRecord('DeflectedID','Testing');
 
        String caseData = '{"project":"'+Project.id+'","projectName":"test","Product":"'+assetProduct.id+'","ProductName":"5th Generation Intel® Core™ M Processors","productvariantName":"Intel 5th gen","CategoryId":"'+assetProduct.id+'","CategoryName":"Hardware","Subject":"test","Language":"test","prodEdqRecs":[{"hasChild":false,"id":"'+assetProduct.id+'","label":"What is your nick name?","palceholderText":"mahii","required":true,"type":"Text","value":"mahii"},{"hasChild":false,"id":"'+assetProduct.id+'","label":"Test Question for Owner Copy","lovs":[{"label":"test 2","value":"'+assetProduct.id+'"},{"label":"test 1","value":"'+assetProduct.id+'"}],"required":false,"type":"Picklist"}],"showProdEdqs":true,"showEdqSection":true,"contactId":"'+con.id+'","accountId":"'+Acc.id+'"}';    
        String defId =  Core_IPS_DeflectedObject_LWC_Ctrl.createDeflectedObject(caseData,deflectedObj.Id); 
        Core_IPS_DeflectedObject_LWC_Ctrl.updateDeflectedObject(defId, CaseRec.id);
        Core_IPS_DeflectedObject_LWC_Ctrl.updateDeflectedInfo(defId, caseData);

    }  
    
}