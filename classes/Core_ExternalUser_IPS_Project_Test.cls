@isTest
    public  class Core_ExternalUser_IPS_Project_Test {
        
        public static testMethod void CheckCoreExternalUserIPSProject() {
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS External Customer' LIMIT 1];
            String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Core_IPS_Product__c' and DeveloperName = 'Core_IPS_Project_Product'].Id;
            
            Account acc = TestUtilities.getAccount();
            acc.Core_IPS_Active__c=True;
            insert acc;
            
            Contact con = TestUtilities.getContact();
            con.AccountId=acc.id;
            con.Core_IPS_Active__c=True;
            insert con;
            
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
            ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
            insert ListOfProducts;
            System.assert(ListOfProducts[0].id != null,'Product2 Record not created');
            
            List<Product2> ListOfProducts1 = TestUtilities.getListOfProduct(1);
            ListOfProducts1.get(0).Core_Product_Name_EPM_ID__c='3456';
            insert ListOfProducts1;
            Account acc1 = new account();
            acc1.recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
                acc1.Name = 'Dell Products123';
                acc1.Core_Account_Type__c = 'Distributor';
                acc1.Core_Sales_Segment__c = 'Compute';
                acc1.Industry = 'Banking';
                acc1.BillingCity = 'Delhi';
                acc1.BillingCountry = 'USA';
                acc1.billingState = 'AK';
                acc1.billingStreet = 'Bratislava 1';
                acc1.Core_IPS_Active__c = true;
                //insert acc1;
            
          /* Contact contactRecord = new Contact(
                FirstName = 'Ding Dong123',
                Lastname = 'Dell123',
                Email = 'Contact1Dell123@gmail.com',
                recordTypeId = schema.sobjecttype.Contact.getrecordtypeinfosbyname().get('Outlook contact').getRecordTypeId(),
                Core_IPS_Active__c = false,AccountId=acc1.id,
                Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId()
            );
            insert contactRecord;*/
            
            //User usr = TestUtilities.getCustomerUser('IPS External Customer');  
            User usr = new User(LastName = 'LIVESTON',
                                FirstName='JASON',
                                ContactId = con.id,
                                Alias = 'jliv',
                                Email = 'jason.liveston@asdf.com',
                                Username = 'jason.liveston@asdf.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
            
            System.runAs(usr) {
                Core_IPS_Project__c cip=new Core_IPS_Project__c();
                //cip.RecordTypeId=strRecordTypeId;
                cip.Name ='value12';
                cip.Core_MPNDA__c='4567';
                insert cip;
                
                Asset asset=new Asset();
                asset.Name='test';
                asset.Core_IPS_Project__c=cip.Id;
                asset.Product2Id=ListOfProducts[0].id;
                asset.Core_Project_Asset_Status__c='Active';
                asset.status='Active';
                insert asset;

                Asset asset1=new Asset();
                asset1.Name='test1';
                asset1.Core_IPS_Project__c=CIP.Id;
                asset1.Product2Id=ListOfProducts[0].id;
                asset1.Core_Project_Asset_Status__c='Active';
                asset1.status='Active';            
                insert asset1; 
                    
                Core_IPS_Project__c ipsProject1 = new Core_IPS_Project__c(); 
                ipsProject1.Name ='value1';
                ipsProject1.Core_MPNDA__c='4567';
                insert ipsProject1;
                
                Core_IPS_Product__c prod = new Core_IPS_Product__c();
                prod.Core_IPS_Project__c = ipsProject1.Id;
                //prod.Core_Supported_Product__c = assetObj.Core_Supported_Product__c;
                prod.Core_IPS_Product_Status__c ='Active';
                prod.Status__c = 'Approved';
                prod.Core_IPS_IsAutoApprove__c = true;
                //prod.Status__c = 'Auto Approve';
                //prod.Core_Intel_Product__c  = assetObj.Id;
                prod.Core_IsSubmitted_Header__c = true;
                insert prod;
                
                
                Core_IPS_Project_Member__c projectMemberRecord = new Core_IPS_Project_Member__c();
                projectMemberRecord.Core_IPS_Project__c=cip.id;
                projectMemberRecord.Core_IPS_Contact__c=con.id;
                projectMemberRecord.Core_User__c=usr.id;
                projectMemberRecord.Core_Status__c = 'Active';
                insert projectMemberRecord;
                
                test.starttest();
                
                List<String> colNames = new List<String>{'FirstName','LastName','Email','Account.Name'};
                String query = 'Select LastName, FirstName, Email, Account.Name, Core_IPS_Active__c From Contact Where AccountId = \''+acc.id+'\' AND ID != \''+con.id+'\'  AND Core_IPS_Active__c  = true  ';
                query += ' AND ID NOT IN ( Select Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where  Core_Status__c = \'ACTIVE\' AND Core_IPS_Project__c = \''+ipsProject1.id+'\' ) ';
                
                Core_CustomSetController wr1234 = new Core_CustomSetController(query,colNames,false,true,'Name, email');
                 Core_CustomSetController.Wrapper ww = new Core_CustomSetController.Wrapper(con);
                
                 Map<Id, Core_CustomSetController.Wrapper> wrapperSelectedRecords = new Map<Id, Core_CustomSetController.Wrapper>();
                 //wrapperSelectedRecords.put(con.id,wr1234);
                 //wr1234.selectedRecords = wrapperSelectedRecords;
                 wr1234.getAllSelectedRecords();
                 List<Core_CustomSetController.Wrapper> wwList = new List<Core_CustomSetController.Wrapper>();
                wwList.add(ww);
                 wr1234.sobjectRecords = wwList;
                 Map<String, Core_CustomSetController>  subMaoClass = new Map<String, Core_CustomSetController>();
                 subMaoClass.put('AvailableRecords',wr1234);
                 Map<String, Map<String, Core_CustomSetController>> mainMapClass = new Map<String, Map<String, Core_CustomSetController>>();
                 mainMapClass.put('AvailableRecords',subMaoClass);
                
                
                ApexPages.StandardController sc = new ApexPages.standardController(cip);
                Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);
                
                cep.ipsProject = ipsProject1;
                
                
                
                System.debug('values ---------'+cep.mStep_SetCntlr);
                system.debug('cep.IPSProductBasicRecordType==='+cep.IPSProductBasicRecordType);
                
                cep.ipsProject.Name ='value';
                cep.ipsProject.Core_MPNDA__c='4567';
                
               
                
                PageReference pageRef = Page.Core_ExternalUser_IPS_Project;
                PageReference resPg = cep.previousStep();
                
                cep.getLoggerInUser();
                cep.createIPSProject();
                cep.nextStep();
                cep.btnActionSource='AvailableRecords';
                cep.firstPage();
                cep.previousPage();
                cep.nextPage();
                cep.lastPage();
                cep.reset();
                cep.updateExisting();
                cep.saveAll();
                cep.upsertAsserts();
                cep.upsertProjectMembers();
                cep.upsertIPSProducts();
                
                
                
                cep.mStep_SetCntlr = mainMapClass;
                System.debug('from test class====>'+cep.mStep_SetCntlr);
                test.stoptest();
            }
        }
        
       /* public static testMethod void loggerInUser() {
            
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS External Customer' LIMIT 1];
            String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Core_IPS_Product__c' and DeveloperName = 'Core_IPS_Project_Product'].Id;
            
            Account acc = TestUtilities.getAccount();
            acc.Core_IPS_Active__c=True;
            insert acc;
            
            Contact con = TestUtilities.getContact();
            con.AccountId=acc.id;
            insert con;
            
            Core_IPS_Project__c cip=new Core_IPS_Project__c();
            //cip.RecordTypeId=strRecordTypeId;
            cip.Name = 'Test 1';
            insert cip;
            
            User usr = new User(LastName = 'LIVESTON',
                                FirstName='JASON',
                                Alias = 'jliv',
                                Email = 'jason.liveston@asdf.com',
                                Username = 'jason.liveston@asdf.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
            ApexPages.StandardController sc = new ApexPages.standardController(cip);
            Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);
            //Core_ExternalUser_IPS_Project_Controller.IPSProductBasicRecordType();
            system.debug(cep.IPSProductBasicRecordType);
            cep.ipsProject.Name ='value';
            cep.ipsProject.Core_MPNDA__c=''; 
            //PageReference resPg1 = cep.saveAll();
            cep.stepIndex = 1;
            cep.nextStep();
            
        }
        

       public static testMethod void CheckCoreExternalUserIPSProject1() {
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS External Customer' LIMIT 1];
            String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Core_IPS_Product__c' and DeveloperName = 'Core_IPS_Project_Product'].Id;
            
            Account acc = TestUtilities.getAccount();
            acc.Core_IPS_Active__c=True;
            insert acc;
            
            Contact con = TestUtilities.getContact();
            con.AccountId=acc.id;
            con.Core_IPS_Active__c=True;
            insert con;
            
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
            ListOfProducts.get(0).Core_Product_Name_EPM_ID__c='5678';
            insert ListOfProducts;
            System.assert(ListOfProducts[0].id != null,'Product2 Record not created');
            
            List<Product2> ListOfProducts1 = TestUtilities.getListOfProduct(1);
            ListOfProducts1.get(0).Core_Product_Name_EPM_ID__c='3456';
            insert ListOfProducts1;
            Account acc1 = new account();
            acc1.recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
                acc1.Name = 'Dell Products123';
                acc1.Core_Account_Type__c = 'Distributor';
                acc1.Core_Sales_Segment__c = 'Compute';
                acc1.Industry = 'Banking';
                acc1.BillingCity = 'Delhi';
                acc1.BillingCountry = 'USA';
                acc1.billingState = 'AK';
                acc1.billingStreet = 'Bratislava 1';
                acc1.Core_IPS_Active__c = true;
                insert acc1;
            
           Contact contactRecord = new Contact(
                FirstName = 'Ding Dong123',
                Lastname = 'Dell123',
                Email = 'Contact1Dell123@gmail.com',
                recordTypeId = schema.sobjecttype.Contact.getrecordtypeinfosbyname().get('Outlook contact').getRecordTypeId(),
                Core_IPS_Active__c = false,AccountId=acc1.id,
                Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId()
            );
            insert contactRecord;
            
            //User usr = TestUtilities.getCustomerUser('IPS External Customer');  
            User usr = new User(LastName = 'LIVESTON',
                                FirstName='JASON',
                                ContactId = con.id,
                                Alias = 'jliv',
                                Email = 'jason.liveston@asdf.com',
                                Username = 'jason.liveston@asdf.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
            
            System.runAs(usr) {
                Core_IPS_Project__c cip=new Core_IPS_Project__c();
                //cip.RecordTypeId=strRecordTypeId;
                cip.Name ='value12';
                cip.Core_MPNDA__c='4567';
                insert cip;
                
                Asset asset=new Asset();
                asset.Name='test';
                asset.Core_IPS_Project__c=cip.Id;
                asset.Product2Id=ListOfProducts[0].id;
                asset.Core_Project_Asset_Status__c='Active';
                asset.status='Active';
                insert asset;

                Asset asset1=new Asset();
                asset1.Name='test1';
                asset1.Core_IPS_Project__c=CIP.Id;
                asset1.Product2Id=ListOfProducts[0].id;
                asset1.Core_Project_Asset_Status__c='Active';
                asset1.status='Active';            
                insert asset1; 
                    
                Core_IPS_Project__c ipsProject1 = new Core_IPS_Project__c(); 
                ipsProject1.Name ='value1';
                ipsProject1.Core_MPNDA__c='4567';
                insert ipsProject1;
                
                Core_IPS_Product__c prod = new Core_IPS_Product__c();
                prod.Core_IPS_Project__c = ipsProject1.Id;
                //prod.Core_Supported_Product__c = assetObj.Core_Supported_Product__c;
                prod.Core_IPS_Product_Status__c ='Active';
                prod.Status__c = 'Approved';
                prod.Core_IPS_IsAutoApprove__c = true;
                //prod.Status__c = 'Auto Approve';
                //prod.Core_Intel_Product__c  = assetObj.Id;
                prod.Core_IsSubmitted_Header__c = true;
                insert prod;
               
                test.starttest();
                List<String> str = new List<String>();
                str = new List<String>{'Core_IPS_Contact__r.FirstName', 'Core_IPS_Contact__r.LastName','Core_IPS_Contact__r.Email','Core_IPS_Contact__r.Account.Name' };
                String query = 'Select LastName, FirstName, Email, Account.Name, Core_IPS_Active__c From Contact';
                Core_CustomSetController wr = new Core_CustomSetController(query,str,true,false,'Name');
                wr.getRecords();
                wr.getSelectedSobjectRecords();
                
                ApexPages.StandardController sc = new ApexPages.standardController(cip);
                Core_ExternalUser_IPS_Project_Controller cep = new Core_ExternalUser_IPS_Project_Controller(sc);
                
                cep.ipsProject = ipsProject1;
                
                Core_CustomSetController.Wrapper wr1 = new Core_CustomSetController.Wrapper(asset,true);
               // wr1.Wrapper strWrap = new wr1.Wrapper(asset,true);
            
                 //Map<String, Core_CustomSetController> mTable_SetCntrlr = new Map<String, Core_CustomSetController>();
                 //mTable_SetCntrlr.put('AvailableRecords',wr);
                 //cep.mStep_SetCntlr.put('Premier Support Project',mTable_SetCntrlr);
                cep.mStep_SetCntlr = cep.mStep_SetCntlr;
                
                System.debug('values ---------'+cep.mStep_SetCntlr);
                system.debug(cep.stepIndex);
                cep.ipsProject.Name ='value';
                cep.ipsProject.Core_MPNDA__c='4567';
                
                cep.ipsProject.id=cip.id;
                //insert cep.ipsProject;
                cep.ipsProject.Core_MPNDA__c='';
                update cep.ipsProject;
                
                PageReference pageRef = Page.Core_ExternalUser_IPS_Project;
                PageReference resPg = cep.previousStep();
               
                cep.getLoggerInUser();
                cep.createIPSProject();
                cep.nextStep();
                cep.updateExisting();
                cep.saveAll();
                cep.upsertAsserts();
                cep.upsertProjectMembers();
                cep.upsertIPSProducts();
                cep.btnActionSource='AvailableRecords';
                cep.firstPage();
                //cep.previousPage();
                //cep.nextPage();
                //cep.lastPage();
                //cep.reset();
                
                test.stoptest();
            }
        }*/
    }