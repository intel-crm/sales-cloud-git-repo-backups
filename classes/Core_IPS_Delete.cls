@isTest
public class Core_IPS_Delete {
   //Instance variables that are commonly used in multiple test methods
    static List<User> listOfUser = new List<User> ();
    static Group grp = new Group();
    static Core_IPS_Product_Issue_Category__c caseCat = new Core_IPS_Product_Issue_Category__c();
    static  Core_IPS_Product_Issue_Category__c subCategory = new Core_IPS_Product_Issue_Category__c();
    public static Id slaprocessId = [Select Id, Name, NameNorm, IsActive, VersionNumber from SlaProcess Where Name = 'IPS Standard SLA Entitlement' and IsActive=true].Id;
    
     static testmethod void updateSupportLevelOnCaseIntegrationTest3(){
        Test.startTest();
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('Integration');  
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];        
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        } 
  
        //Create Users
        List<User> listOfUser = new List<User>();
        listOfUser = TestUtilities.getListOfUser(1); 
        listOfUser.get(0).ProfileId =  profiles.get('Integration');
        insert listOfUser.get(0);
        List<Core_Trigger_Executions__c> triggerExecutionList= new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'IPSCaseFieldsInit';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution.Core_Description__c = 'To update Case fields.';
        triggerExecution.Core_Object__c = 'Case';
        triggerExecution.Core_Trigger_Events__c = 'before insert';
        Core_Trigger_Executions__c  triggerExecution1 = new Core_Trigger_Executions__c();
        triggerExecution1.Name = 'checkCaseClosureParams';
        triggerExecution1.Core_Active__c = true;
        triggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution1.Core_Description__c = 'Check If Org number is same and Case closure is equal to custom setting closure and bugfix id is not empty.';
        triggerExecution1.Core_Object__c = 'Case';
        triggerExecution1.Core_Trigger_Events__c = 'before insert';
        triggerExecutionList.add(triggerExecution1); 
        insert triggerExecutionList;
        System.assert(triggerExecutionList[0].id != null, 'triggerExecution inserted');
       
        //Custom Setting Record inserted by Sandeep US84539: I2
        Core_IPS_Support_Org_Specification__c supportOrgCustomSetting = new Core_IPS_Support_Org_Specification__c();
        supportOrgCustomSetting.Core_IPS_Is_Active__c = true;
        supportOrgCustomSetting.Core_IPS_Case_Closure__c = 'Fix in Intel Documentation';
        supportOrgCustomSetting.Core_IPS_Field_Name__c = 'Core_IPS_Bug_Doc_Fix_ID__c';
        supportOrgCustomSetting.Core_IPS_Support_Org_Number__c = 'Org-027';
        supportOrgCustomSetting.Name = 'PSG';
        insert supportOrgCustomSetting;
        //start added by Aayushi US89551
        Core_Trigger_Executions__c  triggerExecutionRec = new Core_Trigger_Executions__c();
        triggerExecutionRec.Name = 'provideProjCaseAccessToFAE';
        triggerExecutionRec.Core_Active__c = true;
        triggerExecutionRec.Core_Class_Name__c ='Core_IPS_Account_Handler';
        triggerExecutionRec.Core_Description__c = 'Activate Or Deactivate Project Members';
        triggerExecutionRec.Core_Object__c = 'Core_IPS_Account__c';
        triggerExecutionRec.Core_Trigger_Events__c = 'after update';
        insert triggerExecutionRec;
        //end
        System.assert(supportOrgCustomSetting.id != NULL,'Custom setting is not Null');
        
        Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSupportLevelOnCase');
        
        //Custom Setting - Core IPS Labels
        List<Core_IPS_Labels__c> listofIpsLables = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_Case_Create',Value__c = 'IPS Case Create');
        Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
        Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Support_Level_Default',Value__c = 'ROW');
        Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Support_Level_Default_No_Assigned_Cont',Value__c = 'Tier 3');
        listofIpsLables.add(ipsLables1);
        listofIpsLables.add(ipsLables2);
        listofIpsLables.add(ipsLables3);  
        List<Core_IPS_Labels__c> ipsLabelsForGlobalAsset = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c ipl : ipsLabelsForGlobalAsset){
            if(ipl.Name == 'Core_IPS_Global_Asset_RT'){
                ipl.value__c = 'Core_Public_Product';
            }
        }
        listofIpsLables.addAll(ipsLabelsForGlobalAsset);   
        insert listofIpsLables;
        
       Case Cs =  TestUtilities.getCase(); 
        insert cs;
        
        Core_Trigger_Executions__c settings = new Core_Trigger_Executions__c();
        settings.Name = 'InsertCaseCommentForAttach';
        settings.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
        settings.Core_Description__c = 'ABC';
        settings.Core_Object__c = 'Core_IPS_Case_Comments__c';
        settings.Core_Trigger_Events__c = 'After Insert, After update';
        settings.Core_Active__c = True;
        insert settings;
        
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
        labels.name= 'COMPLETE';
        labels.value__c='COMPLETE';
        insert labels;
        
        Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c ();
        labels1.name= 'PUBLIC_TO_CUSTOMERS';
        labels1.value__c='Public to Customers';
        insert labels1;
        
        Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
        labels2.name= 'Data Migration Profile Id';
        labels2.value__c='00eo0000000f7Gd';
        insert labels2;             
        
        Core_IPS_Labels__c labels3 = new Core_IPS_Labels__c ();
        labels3.name= 'PRIVATE_TO_INTEL';
        labels3.value__c='Private to Intel';
        insert labels3;
        
        Core_IPS_Labels__c labels4 = new Core_IPS_Labels__c ();
        labels4.name= 'PRIVATE_TO_AGENTS';
        labels4.value__c='Private to Agents';
        insert labels4;
        
        Core_IPS_Labels__c labels5 = new Core_IPS_Labels__c ();
        labels5.name= 'FAE';
        labels5.value__c='FAE';
        insert labels5;
        
        Core_IPS_Labels__c labels6 = new Core_IPS_Labels__c ();
        labels6.name= 'Agent';
        labels6.value__c='Agent';
        insert labels6;
        
        Core_IPS_Labels__c labels7 = new Core_IPS_Labels__c ();
        labels7.name= 'Customer';
        labels7.value__c='Customer';
        insert labels7;
         Core_IPS_Labels__c ipsLables_3 = new Core_IPS_Labels__c(Name = 'Core_IPS_USAMindsComment_Author',Value__c = '005o0000001g5FC');
       insert ipsLables_3;
        Core_IPS_Labels__c labels8 = new Core_IPS_Labels__c ();
        labels8.name= 'Backend Integration';
        labels8.value__c='Backend Integration';
        insert labels8;
        
        Core_IPS_Labels__c labels9 = new Core_IPS_Labels__c ();
        labels9.name= 'Data Migration';
        labels9.value__c='Data Migration';
        insert labels9;
        
        Core_IPS_Labels__c Label10 = new Core_IPS_Labels__c ();
        Label10.name= 'PRIVATE_TO_PARTNERS';
        label10.value__c= 'Private to Partner';
        insert label10;
        
        Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
        label11.name='Partner - DFAE';
        label11.value__c='Partner - DFAE';
        insert label11;
        
        Core_IPS_Labels__c label12 = new Core_IPS_Labels__c();
        label12.name='Partner - Agent';
        label12.value__c='Partner - Agent';
        insert label12;
        
        Core_IPS_Labels__c label13= new Core_IPS_Labels__c();
        label13.name='Comment Source - Customer';
        label13.value__c='Customer Portal';
        insert label13; 
        
        Core_IPS_Labels__c label14= new Core_IPS_Labels__c();
        label14.name='Partner';
        label14.value__c='Partner';
        insert label14; 
        
        Core_IPS_Labels__c label15= new Core_IPS_Labels__c();
        label15.name='N/A';
        label15.value__c='N/A';
        insert label15;
        
        Core_IPS_Labels__c label16= new Core_IPS_Labels__c();
        label16.name='Comment Source - N/A';
        label16.value__c='N/A';
        insert label16;
        
        Core_IPS_Labels__c labels17= new Core_IPS_Labels__c();
        labels17.name= 'Comment Source - Email';
        labels17.value__c='Email';
        insert labels17;
        
                 
        //Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(0)){
            
            //Create Support Org
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert listOfSupportOrg;
            
            System.assert(listOfSupportOrg != null, 'Record not created');
            
            //Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(2);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            
            //Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.core_ips_Active__c=true;
                contactRec.Accountid = listOfAccounts.get(0).Id;
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');  
            //Create Product
            Integer counter = 0;            
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
            System.assert(listOfProducts[0].id != null,'Record not created');      
            //Create Supported product
            counter = 0;
            List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
                if(counter==0){
                    supportedProduct.Core_Product__c = listOfProducts.get(0).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                }else{
                    supportedProduct.Core_Product__c = listOfProducts.get(1).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                }
                counter++;
            }
            insert listOfSupportedProduct;
            System.assert(listOfSupportedProduct[0].id != null,'Record not created');
            
            //Create Asset
            counter = 0;
            list<Asset> assetList = TestUtilities.getAssetList(2);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
                if(counter==0){
                    asst.core_product_organization__c = listOfSupportOrg.get(0).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(0).id;
                    asst.product2Id = listOfProducts.get(0).id;
                }else{
                    asst.core_product_organization__c = listOfSupportOrg.get(1).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(1).id;
                    asst.product2Id = listOfProducts.get(1).id;
                }
                counter++;
            }
            insert assetList;
            System.assert(assetList[0].Id != null, 'Record not created');  
            //Create Ips Project
            counter = 0;
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
            insert listOfIpsProjects;
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            //insert fae added by Aayushi 20/03/2018 US89551
            List<user> userList = TestUtilities.getListofuser(1);
            profile prof = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
            userlist[0].profileid=prof.id;
            userlist[0].username='salesrep0202.abc@user.com';
            System.runAs(listOfUser.get(0)){
                insert userlist;
            }
            //start added by Aayushi 20/03/2018 US89551
            String teamMemberRole = 'Team Member (100%)';
            String accountAccessLevel = 'Edit';
            String opportunityAccessLevel = 'Edit';
            String caseAccessLevel = 'None';
            List<AccountTeamMember> members = new list<AccountTeamMember>();
            List<AccountShare> sharingRules = new list<AccountShare>();
            //end
            // Create Ips Account
            Counter=0;
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                if(counter<1){
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                    //start added by Aayushi 20/03/2018 US89551
                    members.add(New AccountTeamMember(AccountId = listOfAccounts.get(0).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                    sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = listOfAccounts.get(0).Id));
                    
                } else {
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(1).Id;
                    members.add(New AccountTeamMember(AccountId = listOfAccounts.get(1).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                    sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = listOfAccounts.get(1).Id));
                    //end
                }
                counter++;
            }
            counter = 0;
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            
            //Get Suport Level Picklist Values
            Schema.DescribeFieldResult fieldResult = Core_IPS_Support_Level__c.Core_IPS_Support_Level__c.getDescribe();
            List<SelectOption> options = new List<SelectOption>(); 
            for(Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }   
            
            //Created Support Level
            Core_IPS_Support_Level__c supLevel = new Core_IPS_Support_Level__c();
            supLevel.Core_IPS_Account__c = listOfAccounts.get(0).Id;
            supLevel.Core_IPS_Support_Org__c = listOfSupportOrg.get(0).Id;
            supLevel.Core_IPS_Support_Level__c = options.get(0).getValue();
            insert supLevel;
            
            // Create Case
            counter=0;
            List<Case> listOfCases = TestUtilities.getListOfCases(10);
            
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                caseRec.Core_IPS_GEC_Case__c=false;
                if(counter < 2){
                    caseRec.assetId = assetList.get(0).Id;
                    // caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id; 
                      
                }
                else if(counter>=2 && counter <5){
                    caseRec.assetId = assetList.get(1).Id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                }
                else{
                    caseRec.assetId = assetList.get(1).Id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id; 
                    
                }
                counter++;
            }
           insert listOfCases;
           System.assert(listOfCases[0].Id != null, 'Record not created');
            
            String noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
            Case c1 = TestUtilities.getListOfCases(10).get(0);
            c1.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
            c1.assetId = assetList.get(1).Id;
            c1.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            c1.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id;  
             c1.Core_IPS_BES_Promote_Status__c='Done';
            insert c1;
            
         list<Core_IPS_Case_Comments__c> commentlist = new list<Core_IPS_Case_Comments__c>();
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
       //newComment.Core_IPS_Case__c = att1.Core_Case__c;
       // newComment.Core_IPS_Case_Comment_Type__c = att1.Core_IPS_Attachment_Visibility__c; 
       // newComment.CreatedById = att1.Core_FileUploadedby__c; 
       // newComment.Core_IPS_Comment_Attachment_Id__c = att1.id;
        newComment.Core_IPS_Case__c = c1.id;                       
        newComment.Core_IPS_Rich_Comment__c = ' New Case Attachment uploaded';             
        commentlist.add(newComment);                        
        insert newComment; 
             Core_IPS_Case_Attachments__c att1=new Core_IPS_Case_Attachments__c();
        att1.Core_Case__c=c1.Id;
        att1.Core_File_Name__c='test';
        att1.Core_File_Size__c='75.5 MB';
        att1.Core_File_GUID__c='1a6d234d-9747-4822-812a-739f20906229';
        //att1.Core_IPS_BackendId__c=backendSystem.id;
        //att1.Core_IPS_BES_BackendType__c='HSDES_SFT';
     	att1.Core_IPS_BES_Promote_Status__c='';
        att1.Core_IPS_Security_Compliance__c=false;
        att1.Core_IPS_Uploaded_By_Email__c='chandrax.shekar.pallikonda@intel.com';
        att1.Core_IPS_Uploaded_By_FirstName__c='Chandrashekhar';
        att1.Core_IPS_Uploaded_By_Name__c='Chandrashekhar Pallikonda';
        att1.Core_Is_Migrated__c=false;
        //att1.IsDeleted=false;
        att1.Core_Upload_Status__c='Complete';
        //att1.Core_IPS_Attachment_Source__c='Internal Portal';
        //att1.Core_IPS_Attachment_Visibility__c='Public to Customers';
        att1.Core_File_Description__c='test';
        att1.Core_File_URL__c='https://esft.intel.com/sftservices/download/HSDES_SFT?FileName=16015-1A.0221WZS1542.zip&AppFileID=1a6d234d-9747-4822-812a-739f20906229&AppData=1605952214';
        insert att1;
     
            c1.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id;           
            c1.Core_IPS_BackendID__c='234324';
            update c1;             
            Core_IPS_CaseTriggerHandler.prepareComment(c1.id);
             Core_IPS_CaseTriggerHandler.createCaseComment(c1.id);
           //Core_IPS_CaseTriggerHandler.backendEndSystemProcessCase();
            insert ipsLables4;
            Case c2 = TestUtilities.getListOfCases(10).get(0);
            c2.RecordTypeId = [SELECT id from RecordType where Name ='IPS Case Create'].Id;
            c2.assetId = assetList.get(1).Id;
            c2.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            c2.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;  
            c2.Core_Partner_Supported_Account__c = listOfAccounts.get(0).id;
            c2.Core_IPS_Self_Assigned__c = true;
            
            insert  c2; 
            c2.Core_Partner_Supported_Account__c = listOfAccounts.get(1).id;
            
          update c2;
        }   
        Test.stopTest();
    }  
   
     static testmethod void updateSupportLevelOnCaseTest4(){
        Test.startTest();
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS Data Migration');
        strProf.add('Integration');
         
        
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];        
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }    
          
        //Create Users
        List<User> listOfUser = new List<User>();
        listOfUser = TestUtilities.getListOfUser(1); 
        listOfUser.get(0).ProfileId =  profiles.get('System Administrator');
        insert listOfUser.get(0);
     
        List<Core_Trigger_Executions__c> triggerExecutionList= new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'IPSCaseFieldsInit';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution.Core_Description__c = 'To update Case fields.';
        triggerExecution.Core_Object__c = 'Case';
        triggerExecution.Core_Trigger_Events__c = 'before insert';
        Core_Trigger_Executions__c  triggerExecution1 = new Core_Trigger_Executions__c();
        triggerExecution1.Name = 'checkCaseClosureParams';
        triggerExecution1.Core_Active__c = true;
        triggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution1.Core_Description__c = 'Check If Org number is same and Case closure is equal to custom setting closure and bugfix id is not empty.';
        triggerExecution1.Core_Object__c = 'Case';
        triggerExecution1.Core_Trigger_Events__c = 'before insert';
        triggerExecutionList.add(triggerExecution1); 
        insert triggerExecutionList;
        System.assert(triggerExecutionList[0].id != null, 'triggerExecution inserted');
        
      
        
        //Custom Setting Record inserted by Sandeep US84539: I2
        Core_IPS_Support_Org_Specification__c supportOrgCustomSetting = new Core_IPS_Support_Org_Specification__c();
        supportOrgCustomSetting.Core_IPS_Is_Active__c = true;
        supportOrgCustomSetting.Core_IPS_Case_Closure__c = 'Fix in Intel Documentation';
        supportOrgCustomSetting.Core_IPS_Field_Name__c = 'Core_IPS_Bug_Doc_Fix_ID__c';
        supportOrgCustomSetting.Core_IPS_Support_Org_Number__c = 'Org-027';
        supportOrgCustomSetting.Name = 'PSG';
        insert supportOrgCustomSetting;
        //start added by Aayushi US89551
        Core_Trigger_Executions__c  triggerExecutionRec = new Core_Trigger_Executions__c();
        triggerExecutionRec.Name = 'provideProjCaseAccessToFAE';
        triggerExecutionRec.Core_Active__c = true;
        triggerExecutionRec.Core_Class_Name__c ='Core_IPS_Account_Handler';
        triggerExecutionRec.Core_Description__c = 'Activate Or Deactivate Project Members';
        triggerExecutionRec.Core_Object__c = 'Core_IPS_Account__c';
        triggerExecutionRec.Core_Trigger_Events__c = 'after update';
        insert triggerExecutionRec;
        //end
        System.assert(supportOrgCustomSetting.id != NULL,'Custom setting is not Null');
        
        Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSupportLevelOnCase');
        
        //Custom Setting - Core IPS Labels
        List<Core_IPS_Labels__c> listofIpsLables = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_Case_Create',Value__c = 'IPS Case Create');
        Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
        Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Support_Level_Default',Value__c = 'ROW');
        Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Support_Level_Default_No_Assigned_Cont',Value__c = 'Tier 3');
        listofIpsLables.add(ipsLables1);
        listofIpsLables.add(ipsLables2);
        listofIpsLables.add(ipsLables3);  
        List<Core_IPS_Labels__c> ipsLabelsForGlobalAsset = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c ipl : ipsLabelsForGlobalAsset){
            if(ipl.Name == 'Core_IPS_Global_Asset_RT'){
                ipl.value__c = 'Core_Public_Product';
            }
        }
        listofIpsLables.addAll(ipsLabelsForGlobalAsset);  
        
        insert listofIpsLables;
        
        //Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(0)){
            
            //Create Support Org
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert listOfSupportOrg;
            
            //System.assert(listOfSupportOrg != null, 'Record not created');
            
            //Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(2);
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            
            //Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.core_ips_Active__c=true;
                contactRec.Accountid = listOfAccounts.get(0).Id;
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            
            
            //Create Product
            Integer counter = 0;
            
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
            System.assert(listOfProducts[0].id != null,'Record not created');
            
            
            //Create Supported product
            counter = 0;
            List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
                if(counter==0){
                    supportedProduct.Core_Product__c = listOfProducts.get(0).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                }else{
                    supportedProduct.Core_Product__c = listOfProducts.get(1).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                }
                counter++;
            }
            insert listOfSupportedProduct;
            System.assert(listOfSupportedProduct[0].id != null,'Record not created');
            
            //Create Asset
            counter = 0;
            list<Asset> assetList = TestUtilities.getAssetList(2);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
                if(counter==0){
                    asst.core_product_organization__c = listOfSupportOrg.get(0).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(0).id;
                    asst.product2Id = listOfProducts.get(0).id;
                }else{
                    asst.core_product_organization__c = listOfSupportOrg.get(1).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(1).id;
                    asst.product2Id = listOfProducts.get(1).id;
                }
                counter++;
            }
            insert assetList;
            System.assert(assetList[0].Id != null, 'Record not created');
            
            
            //Create Ips Project
            counter = 0;
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
            insert listOfIpsProjects;
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            //insert fae added by Aayushi 20/03/2018 US89551
            List<user> userList = TestUtilities.getListofuser(1);
            profile prof = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
            userlist[0].profileid=prof.id;
            userlist[0].username='salesrep0202.abc@user.com';
            System.runAs(listOfUser.get(0)){
                insert userlist;
            }
            //start added by Aayushi 20/03/2018 US89551
            String teamMemberRole = 'Team Member (100%)';
            String accountAccessLevel = 'Edit';
            String opportunityAccessLevel = 'Edit';
            String caseAccessLevel = 'None';
            List<AccountTeamMember> members = new list<AccountTeamMember>();
            List<AccountShare> sharingRules = new list<AccountShare>();
            //end
            // Create Ips Account
            Counter=0;
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                if(counter<1){
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                    //start added by Aayushi 20/03/2018 US89551
                    members.add(New AccountTeamMember(AccountId = listOfAccounts.get(0).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                    sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = listOfAccounts.get(0).Id));
                    
                } else {
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(1).Id;
                    members.add(New AccountTeamMember(AccountId = listOfAccounts.get(1).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                    sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = listOfAccounts.get(1).Id));
                    //end
                }
                counter++;
            }
            counter = 0;
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            
            //Get Suport Level Picklist Values
            Schema.DescribeFieldResult fieldResult = Core_IPS_Support_Level__c.Core_IPS_Support_Level__c.getDescribe();
            List<SelectOption> options = new List<SelectOption>(); 
            for(Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }   
            
            //Created Support Level
            Core_IPS_Support_Level__c supLevel = new Core_IPS_Support_Level__c();
            supLevel.Core_IPS_Account__c = listOfAccounts.get(0).Id;
            supLevel.Core_IPS_Support_Org__c = listOfSupportOrg.get(0).Id;
            supLevel.Core_IPS_Support_Level__c = options.get(0).getValue();
            insert supLevel;
            
            // Create Case
            counter=0;
            List<Case> listOfCases = TestUtilities.getListOfCases(10);
            
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                caseRec.Core_IPS_GEC_Case__c=false;
               
                if(counter < 2){
                    caseRec.assetId = assetList.get(0).Id;
                    // caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id; 
                }
                else if(counter>=2 && counter <5){
                    caseRec.assetId = assetList.get(1).Id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                }
                else{
                    caseRec.assetId = assetList.get(1).Id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id; 
                }
                counter++;
            }
            insert listOfCases;
            System.assert(listOfCases[0].Id != null, 'Record not created');
            
            String noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
            Case c1 = TestUtilities.getListOfCases(10).get(0);
            c1.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
            c1.assetId = assetList.get(1).Id;
            c1.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            c1.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id; 
          
            insert c1;
           
            c1.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;
             
            update c1; 
          
            insert ipsLables4;
            Case c2 = TestUtilities.getListOfCases(10).get(0);
            c2.RecordTypeId = [SELECT id from RecordType where Name ='IPS Case Create'].Id;
            c2.assetId = assetList.get(1).Id;
            c2.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            c2.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;  
            c2.Core_Partner_Supported_Account__c = listOfAccounts.get(0).id;
            c2.Core_IPS_Self_Assigned__c = true;
            
            insert  c2; 
            c2.Core_Partner_Supported_Account__c = listOfAccounts.get(1).id;
            
            update c2;
        }   
        Test.stopTest();
    } 
    
      static testmethod void updateSupportLevelOnCaseMigrationUserTest5(){
        Test.startTest();
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();      
        strProf.add('IPS Data Migration');                
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];        
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }    
          
        //Create Users
        List<User> listOfUser = new List<User>();
        listOfUser = TestUtilities.getListOfUser(1); 
        listOfUser.get(0).ProfileId =  profiles.get('IPS Data Migration');
        insert listOfUser.get(0);
       
        //Custom Setting - Trigger Executions
        List<Core_Trigger_Executions__c> triggerExecutionList= new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name = 'IPSCaseFieldsInit';
        triggerExecution.Core_Active__c = true;
        triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution.Core_Description__c = 'To update Case fields.';
        triggerExecution.Core_Object__c = 'Case';
        triggerExecution.Core_Trigger_Events__c = 'before insert';
        Core_Trigger_Executions__c  triggerExecution1 = new Core_Trigger_Executions__c();
        triggerExecution1.Name = 'checkCaseClosureParams';
        triggerExecution1.Core_Active__c = true;
        triggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
        triggerExecution1.Core_Description__c = 'Check If Org number is same and Case closure is equal to custom setting closure and bugfix id is not empty.';
        triggerExecution1.Core_Object__c = 'Case';
        triggerExecution1.Core_Trigger_Events__c = 'before insert';
        triggerExecutionList.add(triggerExecution1); 
        insert triggerExecutionList;
        System.assert(triggerExecutionList[0].id != null, 'triggerExecution inserted');      
        //Custom Setting Record inserted by Sandeep US84539: I2
        Core_IPS_Support_Org_Specification__c supportOrgCustomSetting = new Core_IPS_Support_Org_Specification__c();
        supportOrgCustomSetting.Core_IPS_Is_Active__c = true;
        supportOrgCustomSetting.Core_IPS_Case_Closure__c = 'Fix in Intel Documentation';
        supportOrgCustomSetting.Core_IPS_Field_Name__c = 'Core_IPS_Bug_Doc_Fix_ID__c';
        supportOrgCustomSetting.Core_IPS_Support_Org_Number__c = 'Org-027';
        supportOrgCustomSetting.Name = 'PSG';
        insert supportOrgCustomSetting;
        //start added by Aayushi US89551
        Core_Trigger_Executions__c  triggerExecutionRec = new Core_Trigger_Executions__c();
        triggerExecutionRec.Name = 'provideProjCaseAccessToFAE';
        triggerExecutionRec.Core_Active__c = true;
        triggerExecutionRec.Core_Class_Name__c ='Core_IPS_Account_Handler';
        triggerExecutionRec.Core_Description__c = 'Activate Or Deactivate Project Members';
        triggerExecutionRec.Core_Object__c = 'Core_IPS_Account__c';
        triggerExecutionRec.Core_Trigger_Events__c = 'after update';
        insert triggerExecutionRec;
        //end
        System.assert(supportOrgCustomSetting.id != NULL,'Custom setting is not Null');
        
        Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSupportLevelOnCase');
        
        //Custom Setting - Core IPS Labels
        List<Core_IPS_Labels__c> listofIpsLables = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_Case_Create',Value__c = 'IPS Case Create');
        Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
        Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Support_Level_Default',Value__c = 'ROW');
        Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Support_Level_Default_No_Assigned_Cont',Value__c = 'Tier 3');
        listofIpsLables.add(ipsLables1);
        listofIpsLables.add(ipsLables2);
        listofIpsLables.add(ipsLables3);  
        List<Core_IPS_Labels__c> ipsLabelsForGlobalAsset = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c ipl : ipsLabelsForGlobalAsset){
            if(ipl.Name == 'Core_IPS_Global_Asset_RT'){
                ipl.value__c = 'Core_Public_Product';
            }
        }
        listofIpsLables.addAll(ipsLabelsForGlobalAsset);  
        
        insert listofIpsLables;
        
        //Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(listOfUser.get(0)){
            
            //Create Support Org
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert listOfSupportOrg;
            
            //System.assert(listOfSupportOrg != null, 'Record not created');
            
            //Create Accounts
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);            
            
            insert listOfAccounts;
            System.assert(listOfAccounts[0].Id != null, 'Record not created');
            
            //Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                contactRec.core_ips_Active__c=true;
                contactRec.Accountid = listOfAccounts.get(0).Id;
            }
            insert listOfContacts;
            System.assert(listOfContacts[0].Id != null, 'Record not created');
            
            
            //Create Product
            Integer counter = 0;
            
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
            System.assert(listOfProducts[0].id != null,'Record not created');
            
            
            //Create Supported product
            counter = 0;
            List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c supportedProduct : listOfSupportedProduct){
                if(counter==0){
                    supportedProduct.Core_Product__c = listOfProducts.get(0).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(0).id;
                }else{
                    supportedProduct.Core_Product__c = listOfProducts.get(1).id;
                    supportedProduct.Core_Product_Organization__c = listOfSupportOrg.get(1).id;
                }
                counter++;
            }
            insert listOfSupportedProduct;
            System.assert(listOfSupportedProduct[0].id != null,'Record not created');
            
            //Create Asset
            counter = 0;
            list<Asset> assetList = TestUtilities.getAssetList(2);
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
                if(counter==0){
                    asst.core_product_organization__c = listOfSupportOrg.get(0).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(0).id;
                    asst.product2Id = listOfProducts.get(0).id;
                }else{
                    asst.core_product_organization__c = listOfSupportOrg.get(1).id;
                    asst.core_supported_product__c = listOfSupportedProduct.get(1).id;
                    asst.product2Id = listOfProducts.get(1).id;
                }
                counter++;
            }
            insert assetList;
            System.assert(assetList[0].Id != null, 'Record not created');
            
            
            //Create Ips Project
            counter = 0;
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
            insert listOfIpsProjects;
            System.assert(listOfIpsProjects[0].Id != null, 'Record not created');
            //insert fae added by Aayushi 20/03/2018 US89551
            List<user> userList = TestUtilities.getListofuser(1);
            profile prof = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
            userlist[0].profileid=prof.id;
            userlist[0].username='salesrep0202.abc@user.com';
            System.runAs(listOfUser.get(0)){
                insert userlist;
            }
            //start added by Aayushi 20/03/2018 US89551
            String teamMemberRole = 'Team Member (100%)';
            String accountAccessLevel = 'Edit';
            String opportunityAccessLevel = 'Edit';
            String caseAccessLevel = 'None';
            List<AccountTeamMember> members = new list<AccountTeamMember>();
            List<AccountShare> sharingRules = new list<AccountShare>();
            //end
            // Create Ips Account
            Counter=0;
            List<Core_IPS_Account__c> listOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
            for(Core_IPS_Account__c ipsAcc : listOfIpsAccounts){
                if(counter<1){
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
                    //start added by Aayushi 20/03/2018 US89551
                    members.add(New AccountTeamMember(AccountId = listOfAccounts.get(0).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                    sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = listOfAccounts.get(0).Id));
                    
                } else {
                    ipsAcc.Core_Account__c = listOfAccounts.get(0).Id;
                    ipsAcc.Core_IPS_Project__c = listOfIpsProjects.get(1).Id;
                    members.add(New AccountTeamMember(AccountId = listOfAccounts.get(1).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                    sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = listOfAccounts.get(1).Id));
                    //end
                }
                counter++;
            }
            counter = 0;
            insert listOfIpsAccounts;
            System.assert(listOfIpsAccounts[0].Id != null, 'Record not created');
            
            //Get Suport Level Picklist Values
            Schema.DescribeFieldResult fieldResult = Core_IPS_Support_Level__c.Core_IPS_Support_Level__c.getDescribe();
            List<SelectOption> options = new List<SelectOption>(); 
            for(Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }   
            
            //Created Support Level
            Core_IPS_Support_Level__c supLevel = new Core_IPS_Support_Level__c();
            supLevel.Core_IPS_Account__c = listOfAccounts.get(0).Id;
            supLevel.Core_IPS_Support_Org__c = listOfSupportOrg.get(0).Id;
            supLevel.Core_IPS_Support_Level__c = options.get(0).getValue();
            insert supLevel;
            
            // Create Case
            counter=0;
            List<Case> listOfCases = TestUtilities.getListOfCases(10);
            
            for(Case caseRec : listOfCases){
                caseRec.ContactId = listOfContacts.get(0).id;
                caseRec.accountId = listOfAccounts.get(0).Id;
                caseRec.Core_IPS_GEC_Case__c=false;
                if(counter < 2){
                    caseRec.assetId = assetList.get(0).Id;
                    // caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id; 
                }
                else if(counter>=2 && counter <5){
                    caseRec.assetId = assetList.get(1).Id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                }
                else{
                    caseRec.assetId = assetList.get(1).Id;
                    caseRec.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
                    caseRec.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id; 
                }
                counter++;
            }
            insert listOfCases;
            System.assert(listOfCases[0].Id != null, 'Record not created');
            
            String noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
            Case c1 = TestUtilities.getListOfCases(10).get(0);
            c1.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
            c1.assetId = assetList.get(1).Id;
            c1.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            c1.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(0).id;  
            
            insert c1;
           
            c1.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;
            
            update c1; 
          
            insert ipsLables4;
            Case c2 = TestUtilities.getListOfCases(10).get(0);
            c2.RecordTypeId = [SELECT id from RecordType where Name ='IPS Case Create'].Id;
            c2.assetId = assetList.get(1).Id;
            c2.Core_IPS_Project_Case__c = listOfIpsProjects.get(0).id;
            c2.Core_IPS_Supported_Product__c = listOfSupportedProduct.get(1).id;  
            c2.Core_Partner_Supported_Account__c = listOfAccounts.get(0).id;
            c2.Core_IPS_Self_Assigned__c = true;
            
            insert  c2; 
            c2.Core_Partner_Supported_Account__c = listOfAccounts.get(1).id;
            
            update c2;
        }   
        Test.stopTest();
    } 

}