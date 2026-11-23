@isTest
public class Core_IPS_OpportunityPAR_Controller_Test {
    static List<Account> accountList;
    static Opportunity opp;
    public static TestMethod void testMethod1(){
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Id customRecTypeId = recordTypes.get('Intel Account').getRecordTypeId();
        accountList = Core_Test_Utility.createAccount(6);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = 'PRC Sales Group';
        accountList[0].Industry ='Software and Services';
        accountList[0].Core_Sub_Industry__c ='IT Services';
        accountList[0].RecordTypeId = customRecTypeId;
        insert accountList;
        System.assert(accountList.size()>0);
        // Create and Insert a test Opportunity
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(1); 
        opp = listOpportunity[0];    
        opp.AccountId = accountList[0].Id;
        //opp.Opportunity_Focus__c = '';
        System.runAs(Core_Test_Utility.systemAdminUser){          
            insert opp;
        }
        
        Core_IPS_Project__c project = new Core_IPS_Project__c();
            project.Core_IPS_Group_Name__c='test';
            project.Core_MPNDA__c='test';
            insert project;
        
        List<Product2> prodlist = new List<Product2>();
        Product2 prod=Core_IPS_Backend_TestClass_Utility.getProduct();
        prod.Core_Product_Org__c='IPS';       
        prodList.add(prod);
        insert prodList;
        Core_IPS_Product_Organization__c suppOrg=Core_IPS_Backend_TestClass_Utility.getSupportOrg();
        insert suppOrg;
        List<id>supportedOrgAdminId = new List<id>();
        List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
        Core_IPS_Supported_Product__c suppProd = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
        suppProd.Core_Product__c=prod.id;
        suppProd.Core_Product_Organization__c=suppOrg.id;
        suppProd.Core_Supported_Product_Name__c = 'Intel® Modular Test Architecture Diagnostics';  
        suppProdList.add(suppProd);
        
        //Hassan Khan 
        Core_IPS_Opportunity_PAR__c oppParr = new Core_IPS_Opportunity_PAR__c(Core_IPS_Approval_Status__c ='In Progress');
        oppParr.Core_IPS_Premier_Support_Project__c =null;
        oppParr.Core_IPS_AddNewProject__c = true;

        insert oppParr;
        System.assert(oppParr.Id != null, 'Record not created');

        Core_IPS_Opportunity_PAR__c oppParr2 = new Core_IPS_Opportunity_PAR__c(Core_IPS_Approval_Status__c ='In Progress');
        oppParr2.Core_IPS_Premier_Support_Project__c =null;
        oppParr2.Core_IPS_AddNewProject__c = true;

        insert oppParr2;
        System.assert(oppParr2.Id != null, 'Record not created');

        // END
        List<Core_IPS_Product_Organization_Admin__c> orgAdmin = new List<Core_IPS_Product_Organization_Admin__c>();
        Core_IPS_Product_Organization_Admin__c suppadmin = TestUtilities.getSupportOrgAdmin();
        suppadmin.Core_Admin__c=userinfo.getUserId();
        suppadmin.Core_Product_Organization__c =suppOrg.id;
        suppadmin.Core_Primary_Admin__c = true;
        suppadmin.Core_IPS_Supported_Org_Admin__c = oppParr.id;
        insert suppadmin;
		System.assert(suppadmin.Id != null, 'Record not created');
        
        suppadmin.Core_IPS_Supported_Org_Admin__c = oppParr2.id;
        Update suppadmin; 
        
        insert suppProdList;
        System.assert(suppProdList[0].Id != null, 'Record not created');

        orgAdmin.add(suppadmin);
        Core_IPS_CreateOpportunityPAR_Controller.WrapOpportunityPAR oppParWrapper = new Core_IPS_CreateOpportunityPAR_Controller.WrapOpportunityPAR();
        oppParWrapper.createProjCheckbox= true;
        oppParWrapper.requestJust = 'Test Request Justification';
        oppParWrapper.oppId = opp.Id;
        oppParWrapper.productList = suppProdList;
        oppParWrapper.orgAdminList =orgAdmin;
        //oppParWrapper.ipsPrjct=project.Id;
        
        Core_IPS_CreateOpportunityPAR_Controller.submitRecord(JSON.serialize(oppParWrapper));
        Map<Id,Core_IPS_Opportunity_PAR__c> oppPar = new Map<Id,Core_IPS_Opportunity_PAR__c>([SELECT Id, Name, Core_IPS_Premier_Support_Project__c, Core_IPS_Request_Justification__c, Email_Template_Approved_By__c, Core_IPS_Approval_Status__c, Core_IPS_Supported_ProductsName__c, Approved_By__c, Opportunity__c, Core_IPS_Account_Name__c, Core_IPS_Account_Region__c, Core_IPS_Account_Sub_Region__c, Core_IPS_AddNewProject__c,ownerid FROM Core_IPS_Opportunity_PAR__c]);
          oppPar.values()[0].Core_IPS_Approval_Status__c = 'In progress';
          oppPar.values()[0].Core_IPS_AddNewProject__c = true;
          oppPar.values()[0].Core_IPS_Premier_Support_Project__c =null;
     
          Map<Id,Core_IPS_Opportunity_PAR__c> oppPar1 = new Map<Id,Core_IPS_Opportunity_PAR__c>([SELECT Id, Name, Core_IPS_Premier_Support_Project__c, Core_IPS_Request_Justification__c, Email_Template_Approved_By__c, Core_IPS_Approval_Status__c, Core_IPS_Supported_ProductsName__c, Approved_By__c, Opportunity__c, Core_IPS_Account_Name__c, Core_IPS_Account_Region__c, Core_IPS_Account_Sub_Region__c, Core_IPS_AddNewProject__c,ownerid FROM Core_IPS_Opportunity_PAR__c]);
          oppPar1.values()[0].Core_IPS_Approval_Status__c = 'Approved';
          oppPar1.values()[0].Core_IPS_AddNewProject__c = true;
          oppPar1.values()[0].Core_IPS_Premier_Support_Project__c =null;
          
          Core_IPS_Opportunity_PAR_Handler.mappingProject(oppPar,oppPar1);
    }
    public static TestMethod void testMethod2(){
        Core_IPS_Opportunity_PAR__c oppPar;
        System.runAs(new User(Id=UserInfo.getUserId())){
            oppPar = new Core_IPS_Opportunity_PAR__c(Core_IPS_Approval_Status__c ='In Progress');
            oppPar.Core_IPS_Premier_Support_Project__c =null;
          	oppPar.Core_IPS_AddNewProject__c = true;

            insert oppPar;
           
        } 
        system.assert(oppPar.Id!=null,'Opportunity PAR is not created');
        Test.startTest();
        List<user> user = [SELECT Id from User where IsActive =true Limit 1]; //ATHR fix Gangadhar
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(oppPar.Id);
        req1.setNextApproverIds(new List<Id>{user[0].Id});
        Approval.ProcessResult result = Approval.process(req1);
        System.runAs(new User(Id=user[0].Id)){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Approving request.');
            req.setAction('Approve');
            ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem];
            req.setWorkitemId(pItem.Id);
            Approval.ProcessResult result1 = Approval.process(req);
        }
        Test.stopTest();
    }
    
     public static TestMethod void testMethod3(){
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Id customRecTypeId = recordTypes.get('Intel Account').getRecordTypeId();
        accountList = Core_Test_Utility.createAccount(6);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = 'PRC Sales Group';
        accountList[0].Industry ='Software and Services';
        accountList[0].Core_Sub_Industry__c ='IT Services';
        accountList[0].RecordTypeId = customRecTypeId;
        insert accountList;
        System.assert(accountList.size()>0);
        // Create and Insert a test Opportunity
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(1); 
        opp = listOpportunity[0];    
        opp.AccountId = accountList[0].Id;
        //opp.Opportunity_Focus__c = '';
        System.runAs(Core_Test_Utility.systemAdminUser){          
            insert opp;
        }
        
        Core_IPS_Project__c project = new Core_IPS_Project__c();
            project.Core_IPS_Group_Name__c='test';
            project.Core_MPNDA__c='test';
        //project.Core_Status__c = 'Draft';
            insert project;
        
        
        List<Product2> prodlist = new List<Product2>();
        Product2 prod=Core_IPS_Backend_TestClass_Utility.getProduct();
        prod.Core_Product_Org__c='IPS';       
        prodList.add(prod);
        insert prodList;
        Core_IPS_Product_Organization__c suppOrg=Core_IPS_Backend_TestClass_Utility.getSupportOrg();
        insert suppOrg;
        List<id>supportedOrgAdminId = new List<id>();
        List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
        Core_IPS_Supported_Product__c suppProd = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
        suppProd.Core_Product__c=prod.id;
        suppProd.Core_Product_Organization__c=suppOrg.id;
        suppProd.Core_Supported_Product_Name__c = 'Intel® Modular Test Architecture Diagnostics';  
        suppProdList.add(suppProd);
        
        List<Core_IPS_Product_Organization_Admin__c> orgAdmin = new List<Core_IPS_Product_Organization_Admin__c>();
        Core_IPS_Product_Organization_Admin__c suppadmin = TestUtilities.getSupportOrgAdmin();
        suppadmin.Core_Admin__c=userinfo.getUserId();
        suppadmin.Core_Product_Organization__c =suppOrg.id;
        suppadmin.Core_Primary_Admin__c = true;
        insert suppadmin;
        System.assert(suppadmin.Id != null, 'Record not created');

        insert suppProdList;
        System.assert(suppProdList[0].Id != null, 'Record not created');

        orgAdmin.add(suppadmin);
        Core_IPS_CreateOpportunityPAR_Controller.WrapOpportunityPAR oppParWrapper = new Core_IPS_CreateOpportunityPAR_Controller.WrapOpportunityPAR();
        oppParWrapper.createProjCheckbox= false;
        oppParWrapper.requestJust = 'Test Request Justification';
        oppParWrapper.oppId = opp.Id;
        oppParWrapper.productList = suppProdList;
        oppParWrapper.orgAdminList =orgAdmin;
        oppParWrapper.ipsPrjct=project.Id;
         Core_IPS_CreateOpportunityPAR_Controller.submitRecord(JSON.serialize(oppParWrapper));
        Map<Id,Core_IPS_Opportunity_PAR__c> oppPar = new Map<Id,Core_IPS_Opportunity_PAR__c>([SELECT Id, Name, Core_IPS_Premier_Support_Project__c, Core_IPS_Request_Justification__c, Email_Template_Approved_By__c, Core_IPS_Approval_Status__c, Core_IPS_Supported_ProductsName__c, Approved_By__c, Opportunity__c, Core_IPS_Account_Name__c, Core_IPS_Account_Region__c, Core_IPS_Account_Sub_Region__c, Core_IPS_AddNewProject__c,ownerid FROM Core_IPS_Opportunity_PAR__c ]);
          oppPar.values()[0].Core_IPS_Approval_Status__c = 'In progress';
          
          Map<Id,Core_IPS_Opportunity_PAR__c> oppPar1 = new Map<Id,Core_IPS_Opportunity_PAR__c>([SELECT Id, Name, Core_IPS_Premier_Support_Project__c, Core_IPS_Request_Justification__c, Email_Template_Approved_By__c, Core_IPS_Approval_Status__c, Core_IPS_Supported_ProductsName__c, Approved_By__c, Opportunity__c, Core_IPS_Account_Name__c, Core_IPS_Account_Region__c, Core_IPS_Account_Sub_Region__c, Core_IPS_AddNewProject__c,ownerid FROM Core_IPS_Opportunity_PAR__c]);
          oppPar1.values()[0].Core_IPS_Approval_Status__c = 'Approved';
          
        Core_IPS_Project__c projHeader = TestUtilities.getIpsProjectRecord();
        projHeader.Core_Status__c = 'Draft';
        insert projHeader;
        System.assert(projHeader.Id != null, 'Record not created');

        // Inserting IPS accounts
        Core_IPS_Account__c ipsAcc = new Core_IPS_Account__c();
        ipsAcc.Core_Status__c = 'Active';
        ipsAcc.Core_Members__c='All';
        ipsAcc.Core_Account__c = accountList[0].Id;
        ipsAcc.Core_IPS_Project__c = projHeader.Id;
        insert ipsAcc;
        System.assert(ipsAcc.Id != null, 'Record not created');

        //inserting Opportunity Junc object
        Core_IPS_Opportunity__c opptJunc = new Core_IPS_Opportunity__c();
        opptJunc.Core_IPS_Project__c = projHeader.id;
        opptJunc.Core_Opportunity__c = oppParWrapper.oppId;
        
        Test.startTest();
        //Inserting Opportunity Junc object
        insert opptJunc;
        System.assert(opptJunc <> null, 'Record not created'); 
          Core_IPS_Opportunity_PAR_Handler.mappingProject(oppPar,oppPar1);
        Test.stopTest();
    }
}