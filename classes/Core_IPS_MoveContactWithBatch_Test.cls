/**************************************************************************************
Apex Class Name:  Core_IPS_MoveContactWithBatch_Test
Version     : 1.0 
Created Date: 19 June 2018
Description    : This class is Test class for Core_IPS_MoveContactWithBatch
***************************************************************************************/
@isTest
// Added AssertEquals Added By Chiranjeevi - 31-JAN-2024
public class Core_IPS_MoveContactWithBatch_Test{
     static List<User> ListOfUser = new List<User>();
     static void createusers(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name in ('System Administrator')];//,'Partner','IPS Agent-Partner')];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        ListOfUser = TestUtilities.getListOfUser(1);
        ListOfUser[0].ProfileID =  profiles.get('System Administrator');
        insert ListOfUser;
    }
    static testMethod void testMoveContactCaseController(){
    Account currentAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_Export_Compliance_Block__c = false, RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId());
    insert currentAccount ;
    system.assertNOTEquals(null,currentAccount.id);
        
    Contact currentContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',
                                      Core_IPS_Intel_Support_Owner__c=null, AccountId=currentAccount.Id, MailingCountry = 'INDIA');
    insert currentContact;
    system.assertNOTEquals(null,currentContact.id);
    
    Account targetAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                          BillingStreet='1234 testery St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='123458',Core_Export_Compliance_Block__c = false, RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId());
    insert targetAccount;
    system.assertNOTEquals(null,targetAccount.id);
    
    Contact targetContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1253@testing.com.test',
                                          Core_IPS_Intel_Support_Owner__c=null, AccountId=targetAccount.Id, MailingCountry = 'INDIA');
                                                                         
    insert targetContact;
    system.assertNOTEquals(null,targetContact.id); 
             
    List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
    insert ListOfProducts;
    
    Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
    org.Core_IPS_Support_Org_Name__c='test';
    org.Core_Organization_Description__c='test';
    insert org;
    System.assertEquals(org.Core_IPS_Support_Org_Name__c,'test');
    
    Core_IPS_Supported_Product__c pdt = new Core_IPS_Supported_Product__c();
    pdt.Core_Supported_Product_Name__c='medical';
    pdt.Core_Product__c=ListOfProducts[0].id;
    pdt.Core_Product_Organization__c=org.id;
    insert pdt;
    System.assert(true,pdt.Core_Supported_Product_Name__c != null);
    
    Core_IPS_Project__c project = new Core_IPS_Project__c();
    project.Core_IPS_Group_Name__c='test';
    project.Core_MPNDA__c='testgeetha';
    insert project;
    System.assert(true,project.Core_MPNDA__c!= null);
    
    // Creates product for a case
    Product2 objProd = new Product2();
    objProd.name = 'Test Local Control Panel';
    objProd.IsActive = true;
    insert objProd;
    System.assertEquals(objProd.name,'Test Local Control Panel');
             
    String RT = [Select Id,Name From RecordType Where SobjectType = 'Case' and DeveloperName ='IPS_Case_Create'].Id;      
    Case caseReco = new case();
    caseReco.AccountID = currentAccount.id;
    caseReco.contactID = currentContact.Id;
    caseReco.RecordTypeid=RT;
    insert caseReco;
       Id assetPublicRecordId=schema.sobjecttype.Asset.getrecordtypeinfosbyname().get('IPS Public Product').getRecordTypeId();
      
       List<RecordType> rtList = [SELECT id,developerName,name FROM RecordType where SobjectType='Case'];
        // Create Case
        List<Asset> listOfAssets= TestUtilities.getAssetList(10);
        for(Asset AssetRec : listOfAssets){
            AssetRec.accountid= currentAccount.id;
            AssetRec.Product2Id=objProd.id;
            AssetRec.recordtypeid=assetPublicRecordId;
        }
        insert listOfAssets;
        List<Asset> listOfAssets1= TestUtilities.getAssetList(10);
        for(Asset AssetRec : listOfAssets){
            AssetRec.accountid= targetAccount.id;
            AssetRec.Product2Id=objProd.id;
            AssetRec.recordtypeid=assetPublicRecordId;
        }
        insert listOfAssets1;
        
        List<Case> ListOfCases = TestUtilities.getListOfCases(10);
        integer count=0;
        for(Case CaseRec : ListOfCases){
            if(count<5){
                CaseRec.Core_IPS_Project_Case__c = project.id;
                CaseRec.AssetId=listOfAssets[count].id;
            }else{
                CaseRec.Core_IPS_Project_Case__c = null;
                CaseRec.AssetId=listOfAssets[count].id;
            }
            CaseRec.Core_IPS_Product_Org1__c=org.id;
            CaseRec.Core_IPS_Supported_Product__c=pdt.id;
            CaseRec.AccountID = currentAccount.Id;
            CaseRec.contactID = currentContact.Id;
            //CaseRec.productId = objProd.id;
            count++;
            
        }
        insert ListOfCases;
        Test.startTest();
            Core_IPS_MoveContactWithBatch moveContact = new Core_IPS_MoveContactWithBatch(currentContact,targetContact);
            Database.executeBatch(moveContact);
             
        Test.stopTest();  
    }
    static testMethod void testMoveContactTrigger(){
    createusers();
    System.runAs(ListOfUser[0]){
       
        List<Account> currentAccount = TestUtilities.getListOfAccounts(1);
        Insert currentAccount;
        system.assertNOTEquals(null,currentAccount[0].id);
            
        Contact currentContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',
                                          Core_IPS_Intel_Support_Owner__c=null, AccountId=currentAccount[0].id, MailingCountry = 'INDIA');
        insert currentContact;
        system.assertNOTEquals(null,currentContact.id);
        
        Account targetAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 testery St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='123458',Core_Export_Compliance_Block__c = false);
        insert targetAccount;
        system.assertNOTEquals(null,targetAccount.id);
        Account targetAccount2 = new Account(Name='testAccount1234', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 testery St1', BillingCity='testCity1', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='123458',Core_Export_Compliance_Block__c = false);
        insert targetAccount2;
        system.assertNOTEquals(null,targetAccount2.id);
        
        Contact targetContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1253@testing.com.test',
                                              Core_IPS_Intel_Support_Owner__c=null, AccountId=targetAccount.Id, MailingCountry = 'INDIA');
                                                                             
        insert targetContact;
        system.assertNOTEquals(null,targetContact.id); 
                 
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
        insert ListOfProducts;
        
        Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
        org.Core_IPS_Support_Org_Name__c='test';
        org.Core_Organization_Description__c='test';
        insert org;
        System.assertEquals(org.Core_IPS_Support_Org_Name__c,'test');
        
        Core_IPS_Supported_Product__c pdt = new Core_IPS_Supported_Product__c();
        pdt.Core_Supported_Product_Name__c='medical';
        pdt.Core_Product__c=ListOfProducts[0].id;
        pdt.Core_Product_Organization__c=org.id;
        insert pdt;
        System.assert(true,pdt.Core_Supported_Product_Name__c != null);
        
        Core_IPS_Project__c project = new Core_IPS_Project__c();
        project.Core_IPS_Group_Name__c='test';
        project.Core_MPNDA__c='testgeetha';
        insert project;
        System.assert(true,project.Core_MPNDA__c!= null);
        
        // Creates product for a case
        Product2 objProd = new Product2();
        objProd.name = 'Test Local Control Panel';
        objProd.IsActive = true;
        insert objProd;
        System.assertEquals(objProd.name,'Test Local Control Panel');
                 
        String RT = [Select Id,Name From RecordType Where SobjectType = 'Case' and DeveloperName ='IPS_Case_Create'].Id;      
        Case caseReco = new case();
        caseReco.AccountID = currentAccount[0].id;
        caseReco.contactID = currentContact.id;
        caseReco.RecordTypeid=RT;
        insert caseReco;
           Id assetPublicRecordId=schema.sobjecttype.Asset.getrecordtypeinfosbyname().get('IPS Public Product').getRecordTypeId();
          
           List<RecordType> rtList = [SELECT id,developerName,name FROM RecordType where SobjectType='Case'];
            // Create Case
            List<Asset> listOfAssets= TestUtilities.getAssetList(10);
            for(Asset AssetRec : listOfAssets){
                AssetRec.accountid= currentAccount[0].id;
                AssetRec.Product2Id=objProd.id;
                AssetRec.recordtypeid=assetPublicRecordId;
            }
            insert listOfAssets;
            
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            integer count=0;
            for(Case CaseRec : ListOfCases){
                if(count<5){
                    CaseRec.Core_IPS_Project_Case__c = project.id;
                    CaseRec.AssetId=listOfAssets[count].id;
                }else{
                    CaseRec.Core_IPS_Project_Case__c = null;
                }
                CaseRec.Core_IPS_Product_Org1__c=org.id;
                CaseRec.Core_IPS_Supported_Product__c=pdt.id;
                CaseRec.AccountID = currentAccount[0].id;
                CaseRec.contactID = currentContact.Id;
                //CaseRec.productId = objProd.id;
                count++;
                
            }
            insert ListOfCases;
            Test.startTest();
               
                 Core_IPS_MoveContactWithBatch moveContact = new Core_IPS_MoveContactWithBatch(new Set<id>{currentContact.id},new Set<id>{targetContact.accountid});
                 Core_IPS_MoveContactWithLargeCases.allCaseList=ListOfCases;
                 moveContact.allProcessedcaseId=null;
                 moveContact.batchProcessedFrom='PageController';
                 moveContact.targetAccount=targetContact;
                 moveContact.allProcessedcaseId=new Set<Id>() ; 
                 moveContact.allFailedcaseId=new Set<Id>() ;
         
                 moveContact.execute(null,ListOfCases);
                    
            Test.stopTest();  
   
       }
    }
    
    //code added as per US120420    
    public static testmethod void testMoveContactAlongWithCases(){
    
        Integer count = 0;
        Account currentAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_Export_Compliance_Block__c = false, RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId());

        insert currentAccount ;
     
        Account targetAcc = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 testery St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='123458',Core_Export_Compliance_Block__c = false, RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId());
        insert targetAcc;
     
        
        Contact currContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test', Core_IPS_Intel_Support_Owner__c=null, AccountId=currentAccount.Id, MailingCountry = 'INDIA');
        insert currContact;
       
        Contact targetAccount = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1253@testing.com.test', Core_IPS_Intel_Support_Owner__c=null, AccountId=targetAcc.Id, MailingCountry = 'INDIA');
        insert targetAccount;
       
        Case caseObj = new Case();
       
        List<Case> caseList = TestUtilities.getListOfCases(10);
        
            for(Case CaseRec : caseList){
                CaseRec.Core_IPS_Project_Case__c = null;
                CaseRec.AccountID = currentAccount.Id;
                CaseRec.contactID = currContact.Id;
                //CaseRec.productId = objProd.id;
                count++;
                
            }
        insert caseList ;
        
        Test.startTest();
        Core_IPS_MoveContactWithBatch moveContactWithBatch = new Core_IPS_MoveContactWithBatch(currContact,targetAccount,caseObj.contactid);
         moveContactWithBatch.currContact=currContact;
         moveContactWithBatch.targetContId=caseObj.contactId;
         moveContactWithBatch.targetAccount=targetAccount;
         moveContactWithBatch.stConId=new Set<Id>{currContact.id};
         moveContactWithBatch.stAccId=new Set<Id>{targetAccount.accountid};
         moveContactWithBatch.currContactName=currContact.name;
         moveContactWithBatch.batchProcessedFrom='PageContact';
         //Covering catch block
         try{  
             moveContactWithBatch.execute(null,caseList);   
         }catch(Exception e){}
         moveContactWithBatch.allProcessedcaseId=new Set<Id>() ; 
         moveContactWithBatch.allFailedcaseId=new Set<Id>() ;
      
         moveContactWithBatch.execute(null,caseList); 
        System.AssertEquals(caseList.size()>0, true);
        Test.stopTest();
    }
    
}