@isTest
public class RKTest{
    static List<User> ListOfUser = new List<User> ();
    static Group grp = new Group();  
    
/***************************************************************************************************
Method Name:  getRecords()
Method Type: void
Version     : 1.0 
Created Date: 05 Nov 2015
Description:  Common Test data used for all test methods
Scenario Type:  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/05/2015              Created
****************************************************************************************************/
    static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(2);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.runAs(ListOfUser.get(0)){
            //Create Group
            grp = TestUtilities.getQueue();
            grp.Type='Regular';
            insert grp;
            //Create Group Members
            List<GroupMember> ListGM = new List<GroupMember>();
            for(User usr:ListOfUser){
                GroupMember GM = new GroupMember();
                GM.GroupId = grp.Id;
                GM.UserOrGroupId = usr.Id;
                ListGM.add(GM);
            }
            //insert Group Memebers
            if(!ListGM.isEmpty()){
                insert ListGM;
            }
            List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
            insert ListofIpsLables;
            System.assert(ListofIpsLables[0].Id != null, 'Records not created');
            //Custom Setting - Ips Error Codes
            List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
            insert ListofIpsErrorCodes;
            System.assert(ListofIpsErrorCodes[0].Id != null, 'Records not created');
            //Custom Setting - Trigger Executions
            List<Core_Trigger_Executions__c> ListOfTriggerExecutions = TestUtilities.getListOfTriggerExecutions();
            insert ListOfTriggerExecutions;
            System.assert(ListOfTriggerExecutions[0].Id != null, 'Records not created');
        }
    }
static testmethod void updateSupportLevelOnCase_Test3(){
        Test.startTest();
            Map<String,ID> profiles = new Map<String,ID>();
            List<String> strProf = new List<String>();
            strProf.add('System Administrator');
            strProf.add('IPS Data Migration');
            List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
            
            for(Profile prf : ProfileList){
                profiles.put(prf.name, prf.id);
            }
            
            //Create Users
            List<User> ListOfUser = new List<User>();
            ListOfUser = TestUtilities.getListOfUser(1); 
            ListOfUser.get(0).ProfileId =  profiles.get('System Administrator');
            insert ListOfUser.get(0);
            
            //Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'updateSupportLevelOnCase';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution.Core_Description__c = 'To update Support Level On Case.';
            TriggerExecution.Core_Object__c = 'Case';
            TriggerExecution.Core_Trigger_Events__c = 'before insert';
            insert TriggerExecution; 
            System.assert(TriggerExecution.id != null);
            
            //Custom Setting - Trigger Executions Sandeeep US84539: I2
            Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
            TriggerExecution1.Name = 'checkCaseClosureParams';
            TriggerExecution1.Core_Active__c = true;
            TriggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution1.Core_Description__c = 'Check If Org number is same and Case closure is equal to custom setting closure and bugfix id is not empty.';
            TriggerExecution1.Core_Object__c = 'Case';
            TriggerExecution1.Core_Trigger_Events__c = 'before update';
            insert TriggerExecution1; 
            System.assert(TriggerExecution1.id != null);
            
          //Custom Setting Record inserted by Sandeep US84539: I2
          Core_IPS_Support_Org_Specification__c supportOrgCustomSetting = new Core_IPS_Support_Org_Specification__c();
          supportOrgCustomSetting.Core_IPS_Is_Active__c = true;
          supportOrgCustomSetting.Core_IPS_Case_Closure__c = 'Fix in Intel Documentation';
          supportOrgCustomSetting.Core_IPS_Field_Name__c = 'Core_IPS_Bug_Doc_Fix_ID__c';
          supportOrgCustomSetting.Core_IPS_Support_Org_Number__c = 'Org-027';
          supportOrgCustomSetting.Name = 'PSG';
          insert supportOrgCustomSetting;
           //start added by Aayushi US89551
        Core_Trigger_Executions__c  TriggerExecutionRec = new Core_Trigger_Executions__c();
        TriggerExecutionRec.Name = 'provideProjCaseAccessToFAE';
        TriggerExecutionRec.Core_Active__c = true;
        TriggerExecutionRec.Core_Class_Name__c ='Core_IPS_Account_Handler';
        TriggerExecutionRec.Core_Description__c = 'Activate Or Deactivate Project Members';
        TriggerExecutionRec.Core_Object__c = 'Core_IPS_Account__c';
        TriggerExecutionRec.Core_Trigger_Events__c = 'after update';
        insert TriggerExecutionRec;
        //end
            System.assert(supportOrgCustomSetting.id != NULL,'Custom setting is not Null');
        
            Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSupportLevelOnCase');
            
            //Custom Setting - Core IPS Labels
            List<Core_IPS_Labels__c> ListofIpsLables = new List<Core_IPS_Labels__c>();
            Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_Case_Create',Value__c = 'IPS Case Create');
            Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
            Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Support_Level_Default',Value__c = 'ROW');
            Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Support_Level_Default_No_Assigned_Cont',Value__c = 'Tier 3');
            ListofIpsLables.add(ipsLables1);
            ListofIpsLables.add(ipsLables2);
            ListofIpsLables.add(ipsLables3);  
          List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();
            for(Core_IPS_Labels__c ipl : IPSLabelsForGlobalAsset){
                if(ipl.Name == 'Core_IPS_Global_Asset_RT'){
                    ipl.value__c = 'Core_Public_Product';
                }
            }
            ListofIpsLables.addAll(IPSLabelsForGlobalAsset);  

            insert ListofIpsLables;
            
            //Get intelSupportOwner Id (User Id)
            Id intelSupportOwner = ListOfUser.get(0).id;
            System.runAs(ListOfUser.get(0)){
            
                //Create Support Org
                List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
                insert ListOfSupportOrg;
                
                //System.assert(ListOfSupportOrg != null, 'Record not created');
                
                //Create Accounts
                List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
                insert ListOfAccounts;
                System.assert(ListOfAccounts[0].Id != null, 'Record not created');
                
                //Create Contact
                List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
                for(Contact ContactRec : ListOfContacts){
                    ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                    ContactRec.core_ips_Active__c=true;
                    ContactRec.Accountid = ListOfAccounts.get(0).Id;
                }
                insert ListOfContacts;
                System.assert(ListOfContacts[0].Id != null, 'Record not created');
                
                
                //Create Product
                Integer counter = 0;
                
                List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
                for(Product2 Product : ListOfProducts){
                    if(counter==0){
                        Product.Core_Hierarchy_ID__c = '43';
                        Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                        Product.Core_Unique_ID__c = 'Product12345';
                        Product.Core_Code_Name__c = 'ProductCoreCodeName';
                    }else{
                        Product.Core_Hierarchy_ID__c = '59';
                        Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                        Product.Core_Unique_ID__c = 'Product59';
                        Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                        
                    }
                    counter++;
                }
                insert ListOfProducts;
                System.assert(ListOfProducts[0].id != null,'Record not created');
                
                
                //Create Supported product
                counter = 0;
                List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
                for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
                    if(counter==0){
                        SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                        SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                    }else{
                        SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                        SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
                    }
                    counter++;
                }
                insert ListOfSupportedProduct;
                System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
                
                //Create Asset
                counter = 0;
                list<Asset> AssetList = TestUtilities.getAssetList(2);
                for(Asset Asst : AssetList){
                    Asst.accountId = ListOfAccounts.get(0).Id;
                    Asst.Contactid = ListOfContacts.get(0).id;
                    if(counter==0){
                        Asst.core_product_organization__c = ListOfSupportOrg.get(0).id;
                        Asst.core_supported_product__c = ListOfSupportedProduct.get(0).id;
                        Asst.product2Id = ListOfProducts.get(0).id;
                    }else{
                        Asst.core_product_organization__c = ListOfSupportOrg.get(1).id;
                        Asst.core_supported_product__c = ListOfSupportedProduct.get(1).id;
                        Asst.product2Id = ListOfProducts.get(1).id;
                    }
                    counter++;
                }
                insert AssetList;
                System.assert(AssetList[0].Id != null, 'Record not created');
                
                
                //Create Ips Project
                counter = 0;
                List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
                insert ListOfIpsProjects;
                System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
                //insert fae added by Aayushi 20/03/2018 US89551
            List<user> userList = TestUtilities.getListofuser(1);
            profile prof = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
            userlist[0].profileid=prof.id;
            userlist[0].username='salesrep0202.abc@user.com';
            System.runAs(ListOfUser.get(0)){
            insert userlist;
            }
            //start added by Aayushi 20/03/2018 US89551
            String teamMemberRole = 'Team Member (100%)';
		    String accountAccessLevel = 'Edit', opportunityAccessLevel = 'Edit', caseAccessLevel = 'None';
            List<AccountTeamMember> members = new list<AccountTeamMember>();
       	    List<AccountShare> sharingRules = new list<AccountShare>();
            //end
                // Create Ips Account
                Counter=0;
                List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
                for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                    if(counter<1){
                        IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                        IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                        //start added by Aayushi 20/03/2018 US89551
                        members.add(New AccountTeamMember(AccountId = ListOfAccounts.get(0).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                       sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = ListOfAccounts.get(0).Id));

                    } else {
                        IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                        IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
                        members.add(New AccountTeamMember(AccountId = ListOfAccounts.get(1).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = ListOfAccounts.get(1).Id));
            //end
                    }
                    counter++;
                }
                counter = 0;
                insert ListOfIpsAccounts;
                System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
                
                //Get Suport Level Picklist Values
                Schema.DescribeFieldResult fieldResult = Core_IPS_Support_Level__c.Core_IPS_Support_Level__c.getDescribe();
                List<SelectOption> options = new List<SelectOption>(); 
                for(Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }   
                    
                //Created Support Level
                Core_IPS_Support_Level__c supLevel = new Core_IPS_Support_Level__c();
                supLevel.Core_IPS_Account__c = ListOfAccounts.get(0).Id;
                supLevel.Core_IPS_Support_Org__c = ListOfSupportOrg.get(0).Id;
                supLevel.Core_IPS_Support_Level__c = options.get(0).getValue();
                insert supLevel;
                
                // Create Case
                counter=0;
                List<Case> ListOfCases = TestUtilities.getListOfCases(10);
                
                for(Case CaseRec : ListOfCases){
                    CaseRec.ContactId = ListOfContacts.get(0).id;
                    CaseRec.accountId = ListOfAccounts.get(0).Id;
                    CaseRec.Core_IPS_GEC_Case__c=false;
                    if(counter < 2){
                        CaseRec.assetId = AssetList.get(0).Id;
                        // CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id; 
                    }
                    else if(counter>=2 && counter <5){
                        CaseRec.assetId = AssetList.get(1).Id;
                        CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                    }
                    else{
                        CaseRec.assetId = AssetList.get(1).Id;
                        CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id; 
                    }
                    counter++;
                }
                insert ListOfCases;
                System.assert(ListOfCases[0].Id != null, 'Record not created');
                
                String noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
                Case c1 = TestUtilities.getListOfCases(10).get(0);
                c1.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
                c1.assetId = AssetList.get(1).Id;
                c1.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                c1.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;  
                            
                insert c1;
                /*start added by Yogesh US72443*/
                c1.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                
                update c1; 
                /*end */
                insert ipsLables4;
                Case c2 = TestUtilities.getListOfCases(10).get(0);
                c2.RecordTypeId = [SELECT id from RecordType where Name ='IPS Case Create'].Id;
                c2.assetId = AssetList.get(1).Id;
                c2.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                c2.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id;  
                c2.Core_Partner_Supported_Account__c = ListOfAccounts.get(0).id;
                insert  c2; 
                System.debug('Accc1'+c2.Core_Partner_Supported_Account__c );

               c2.Core_Partner_Supported_Account__c = ListOfAccounts.get(1).id;
               update c2;
                System.debug('Accc2'+c2.Core_Partner_Supported_Account__c );
            }   
        Test.stopTest();
    }   
    


    
    
}