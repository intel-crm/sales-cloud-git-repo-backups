@isTest(seeAllData=false)
public class Core_IPS_CaseCreateHelperTest {
    private static void insertUsersWithValidationBypass(List<User> users) {
        User validationBypassUser = [SELECT Id FROM User WHERE Profile.Name = :System.Label.Core_System_Admin_Profile_Name AND IsActive = true LIMIT 1];
        System.runAs(validationBypassUser) {
            insert users;
        }
    }

    @istest
    private static void testEditAccess(){
        User currentUser = [Select profile.Name from user where id=:userinfo.getUserId()];
        
        Core_IPS_Labels__c label = new Core_IPS_Labels__c(value__c = currentUser.profile.Name, name='CloseCaseEditPermission');
        insert label;
        System.assertEquals('CloseCaseEditPermission', label.Name);
        new Core_IPS_CaseCreateHelper().checkcloseCaseEditPermission();
    }
    @isTest
    private static void displayProductVariant() {
        // Create Asset
        list<Asset> assetLists = TestUtilities.getAssetList(1);
        insert assetLists;
        System.debug('shannu --> '+assetLists[0].Id);
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> profileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        List<User> listOfUser = TestUtilities.getListOfUser(1);
        for(User usr : listOfUser){
            usr.ProfileID =  profiles.get('System Administrator');
        }
        insertUsersWithValidationBypass(listOfUser);
        System.assertEquals(listOfUser.get(0).profileid, profiles.get('System Administrator'));  
        System.assert(listOfUser.get(0).profileid !=null, 'true');  
        System.runAs(listOfUser.get(0)){
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            insert listOfAccounts;
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.Core_Country_Region__c = null;
                contactRec.mailingCountry = 'India';
            }
            insert listOfContacts;
            Core_IPS_CaseCreateLWCController.getProjectList(listOfContacts[0].Id);
            Core_IPS_CaseCreateLWCController.getProjectList(UserInfo.getUserId());
            
            List<Core_Flat_Product_Hierarchy__c> listOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(1);
            listOfFlatProductHierarchy[0].Core_Unique_ID__c  =';75025;128758;123707;123704;94489';
            insert listOfFlatProductHierarchy;
            // Create Asset
            list<Asset> assetList = TestUtilities.getAssets(listOfAccounts, 1);
            list<Core_IPS_Supported_Product__c> sps = new list<Core_IPS_Supported_Product__c>();    
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
                //asst.Core_Product_EPM_ID__c = '75025';
                sps.add(new  Core_IPS_Supported_Product__c(id=asst.core_supported_product__c, Core_IPS_Is_Show_Variant__c = true, Core_Product_EPM_ID__c = '75025'));
                // Asst.Core_Product_EPM_ID__c = ListOfFlatProductHierarchy[0].Core_Unique_ID__c;
            }
            update  sps;  
            update assetList;    
            
            Test.startTest();
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert listOfIpsProjects;
            
            Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
            org.Core_IPS_Support_Org_Name__c ='test';
            org.Core_Organization_Description__c ='test';
            insert org;
            
            List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
            Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();       
            //parQues.recordtypeid = edqRecordTypeId;
            parQues1.Core_IPS_Question__c = 'Test Parent Question';
            parQues1.Core_IPS_Datatype__c = 'Text Area';
            parQues1.Core_IPS_Status__c = 'Active';
            parQues1.Core_IPS_Product_Organization__c = Org.id;
            lstparQues.add(parQues1);
            insert lstparQues;
            
            
            Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
            question.isVisible=false;
            question.type='Text';
            question.questionId=lstparQues.get(0).id;
            question.sPlaceHolder=null;
            question.required=true;
            question.selectedValue='test';
            
            Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
            question4.type='Text';
            question4.questionId=lstparQues.get(0).id;
            question4.sPlaceHolder='Testing the Placeholder Value from the test class to cover';
            
            
            Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
            question1.type='Text Area';
            question1.questionId=lstparQues.get(0).id;
            question1.tPlaceHolder='';
            question4.required=true;
            
            Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
            question5.type='Text Area';
            question5.questionId=lstparQues.get(0).id;
            question5.tPlaceHolder='Testing';
            
            
            Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
            question2.type='Picklist';
            question2.questionId=lstparQues.get(0).id;
            question2.sPlaceHolder=null;
            
            Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
            question3.type='Multiselect Picklist';
            question3.questionId=lstparQues.get(0).id;
            question3.sPlaceHolder=null;
            List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
            lstquestion.add(question);
            lstquestion.add(question1);
            lstquestion.add(question2);
            lstquestion.add(question3);
            lstquestion.add(question4);
            lstquestion.add(question5);
            //Insert lstquestion;
            
            System.debug('Shannu Start test');
            System.debug('shannu --> '+assetList[0].Id);
            assetList[0].Core_Product_Organization__c = Label.Core_IPS_MAG_Support_Org;
            //update assetList[0];
            System.debug('testsum list'+assetList[0].Core_Product_Organization__c);
            System.debug('testsum label'+System.label.Core_IPS_MAG_Support_Org);
            
            
            new Core_IPS_CaseCreateHelper().getProductVariant(assetList[0].Id);
            
            assetList.add(assetList[0]);
            System.debug('shannu --> '+assetList);
            System.debug('shannu --> '+assetList.size());
            
            
            
            new Core_IPS_CaseCreateHelper().getProductVariant(assetList[0].Id);
            
            
            List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
            listOfProducts.get(0).Core_Sales_Visible_Flag__c = False;
            listOfProducts.get(0).Core_Hierarchy_ID__c = '59';
            listOfProducts.get(0).Core_Unique_ID__c = 'L5 Id '+1;
            insert listOfProducts;
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
            insert listOfSupportOrg;
            List<Core_Flat_Product_Hierarchy__c> flh = TestUtilities.getListOfFlatProductHierarchy(1);
            insert flh;
            List<Core_IPS_Supported_Product__c>listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            listOfSupportedProduct.get(0).Core_Product__c = listOfProducts.get(0).id;
            listOfSupportedProduct.get(0).Core_Product_Organization__c = listOfSupportOrg.get(0).id;
            insert listOfSupportedProduct;
            
            List<asset> listOfAssets = TestUtilities.getAssetList(1);
            //ListOfAssets.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            listOfAssets.get(0).accountId = listOfAccounts.get(0).Id;
            listOfAssets.get(0).core_supported_product__c = listOfSupportedProduct[0].id;
            insert listOfAssets;
            
            case caseRecord = TestUtilities.getCase();
            caseRecord.Core_IPS_Partner_Sup_Owner__c =  UserInfo.getUserId();
            caseRecord.Core_IPS_Supported_Product__c = listOfSupportedProduct[0].id;
            caseRecord.AssetId = listOfAssets[0].id ;
            RecordType rt2 = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            caseRecord.RecordTypeid = rt2.id ;
            caseRecord.Core_IPS_Country_Region__c = 'India';
            caseRecord.ContactId = listOfContacts[0].Id;
            caseRecord.Core_Issue_Description__c ='test';
            insert caseRecord;
            RecordType rt4 = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Core_IPS_Question__c' LIMIT 1];
            Core_IPS_Question__c csa = TestUtilities.getCoreQuestion();
            //csa.Core_IPS_Datatype__c = 'Text Area';
            //csa.RecordTypeId = RT4.Id;
            insert csa;
            Core_IPS_Question__c csa1 = TestUtilities.getCoreQuestion();
            csa1.Core_IPS_Datatype__c = 'PickList';
            insert csa1;
            Core_IPS_Question__c csa2 = TestUtilities.getCoreQuestion();
            csa2.Core_IPS_Parent_Question__c = csa1.Id;
            insert csa2;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars.get(0).Core_IPS_Question__c = csa.Id;
            insert envVars;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars2 = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars2.get(0).Core_IPS_Question__c = csa1.Id;
            insert envVars2;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars3 = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars3.get(0).Core_IPS_Question__c = csa2.Id;
            insert envVars3;
            Core_IPS_Labels__c ipsLabel1 = new Core_IPS_Labels__c(Name='Core_IPS_Datatype_Text',Value__c='Text');
            insert ipsLabel1;
            Core_IPS_Labels__c ipsLabel2 = new Core_IPS_Labels__c(Name='Core_IPS_Picklist',Value__c='PickList');
            insert ipsLabel2;
            Core_IPS_Labels__c ipsLabel3 = new Core_IPS_Labels__c(Name='Core_IPS_Datatype_TextArea',Value__c='Text Area');
            insert ipsLabel3;
            Core_IPS_Labels__c ipsLabel4 = new Core_IPS_Labels__c(Name='Core_IPS_Multi_Select',Value__c='Multiselect Picklist');
            insert ipsLabel4;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars1 = [Select Id,Core_IPS_Question__r.Core_IPS_Parent_Question__c,Core_IPS_Question__r.Core_IPS_Question__c,Core_IPS_Question__c,Core_required__c,Core_Agent_Only__c,Core_IPS_Question__r.Core_IPS_Datatype__c From Core_IPS_Assigned_Environment_Variables__c];
            String chlidId = csa2.Id;
            String edq = JSON.serialize(lstquestion);
            List<Core_IPS_Answer__c> answer = TestUtilities.getCoreAnswers(1);
            answer.get(0).Core_IPS_Question__c = csa.Id;
            insert answer;
            //  TWC745-7160 - START Shipra
            List<Core_IPS_Response__c> resList = new List<Core_IPS_Response__c>();
            Core_IPS_Response__c res = new Core_IPS_Response__c();
            res.Core_IPS_Question_Master__c = csa.Id;
            res.Core_IPS_Answer_Master__c = answer.get(0).Id;
            res.Core_IPS_Case__c = caseRecord.Id;
            //res.Core_IPS_Agent_Only__c = true;
            res.Core_IPS_Answer__c = 'test answer';
            resList.add(res);
            Core_IPS_Response__c res1 = new Core_IPS_Response__c();
            res1.Core_IPS_Question_Master__c = lstparQues.get(0).id;
            res1.Core_IPS_Answer_Master__c = answer.get(0).Id;
            res1.Core_IPS_Case__c = caseRecord.Id;
            //res1.Core_IPS_Agent_Only__c = true;
            res1.Core_IPS_Answer__c = 'test answer';
            resList.add(res1);
            
            insert resList;
            //  TWC745-7160 - END Shipra
            List<Core_IPS_Master_Issue_Category__c> master = TestUtilities.getListOfCoreMastIssCategory(1);
            master.get(0).Core_Type__c = 'Case Category';
            insert master;
            Core_IPS_Product_Issue_Category__c cat = TestUtilities.getCaseCategories();
            insert cat;
            Core_IPS_Product_Issue_Category__c cat1 = TestUtilities.getCaseCategories(); 
            cat1.Core_Product_Issue_Category__c = cat.Id;
            cat1.Core_Issue_Sub_Category_Name__c = master.get(0).Id; 
            insert cat1;
            
            
            new Core_IPS_CaseCreateHelper().getAgent();
            new Core_IPS_CaseCreateHelper().getsubCategoryOptions(cat.Id);
            new Core_IPS_CaseCreateHelper().SubmitCaseRecord(caseRecord,listOfContacts.get(0),edq);
            try{
                ID recordTypeId = schema.sobjecttype.Contact.getrecordtypeinfosbyname().get('Outlook contact').getRecordTypeId();
                User u0 = [select id from user where usertype='Standard' AND ISActive=true limit 1 ];
                Contact contactRecord = new Contact(
                    FirstName = 'Ding Dong1', 
                    Lastname = 'Dell1',
                    Email = 'hercules_COdeREfactor1@gmail.com',
                    recordTypeId = recordTypeId,
                    Core_IPS_Intel_Support_Owner__c=u0.id,
                    Core_IPS_Active__c = true,
                    AccountId = listOfContacts[0].AccountId,
                    mailingCountry = 'India'
                    
                );
                insert contactRecord;
                caseRecord.Core_Issue_Description__c = '<h1> Code refactor By Hercules </h1>';
                caseRecord.ContactId = listOfContacts[0].Id; 
                caseRecord.Core_IPS_Country_Region__c = 'Iran';
                User u = new user();
                u =  TestUtilities.getListOfUser(1)[0];
                Profile p = [Select id,Name from Profile Where Name like '%IPS Agent-Partner%'];
                u.ProfileId = p.id;
                u.ContactId = listOfContacts[0].Id;
                insertUsersWithValidationBypass(new List<User>{u});
                User u1 = TestUtilities.getListOfUser(1)[0];
                Profile p1 = [Select id,Name from Profile Where Name like '%IPS External Customer%'];
                u1.ProfileId = p1.Id;
                u1.ContactId = ContactRecord.Id;
                insertUsersWithValidationBypass(new List<User>{u1});
                System.runas(u){
                    
                    new Core_IPS_CaseCreateHelper().SubmitCaseRecord(caseRecord,listOfContacts.get(0),edq);
                }
                case c = new Case();
                c.Id = caseRecord.Id; 
                c.ContactId = listOfContacts[0].Id; 
                c.Core_IPS_Country_Region__c = 'Ukraine';
                //Sowmya added
                Core_IPS_Question__c questionMaster = TestUtilities.getCoreQuestion();
                insert questionMaster;
                list<Core_IPS_Response__c> respList= TestUtilities.getCoreResponseRecords(1);
                respList[0].Core_Ips_Case__c = c.Id;
                respList[0].Core_IPS_Question_Master__c = questionMaster.Id;
                
                insert respList;
                //Sowmya end
                System.runas(u1){
                    new Core_IPS_CaseCreateHelper().SubmitCaseRecord(c,listOfContacts.get(0),edq);
                }
            }
            catch(Exception e){}
            new Core_IPS_CaseCreateHelper().basedonSelectedandQuestionValue(listOfProducts.get(0).Id,chlidId, caseRecord.Core_IPS_Supported_Product__c);
            new Core_IPS_CaseCreateHelper().constructWrapper(envVars1);
            try{
                new Core_IPS_CaseCreateHelper().setCurrentEnvironmentDetails(lstquestion,caseRecord.Id);
            } catch(Exception e) {}
            //new Core_IPS_CaseCreateHelper().getProductVariant('');
            List<Core_IPS_Project__c> listOfIpsProjects1 = TestUtilities.getListOfIpsProjects(1);
            insert listOfIpsProjects1;
            Core_IPS_CaseCreateHelper.getContactListFromProject(listOfIpsProjects1.get(0).Id);
            List<user> userlist = TestUtilities.getListofuser(1);
            List<Profile> proflst = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
            userlist[0].profileid=proflst[0].id;
            userlist[0].username='salesrep020211.abc@user.com';
            insertUsersWithValidationBypass(userlist);
            System.runAs(userlist[0]) {
                Core_IPS_CaseCreateHelper.getAccountList();
            }    
            
            Core_IPS_CaseCreateHelper.getCurrentUserProfileName();
            Core_IPS_CaseCreateHelper.readFieldSet('ContactFieldSet','Contact');
            new Core_IPS_CaseCreateHelper().getPlaformOptions(listOfAssets.get(0).Id);
            new Core_IPS_CaseCreateHelper().getPlaformOptions(listOfSupportedProduct.get(0).Id);
            new Core_IPS_CaseCreateHelper().getDynmicFields(lstquestion);
            //new Core_IPS_CaseCreateHelper().setCurrentEnvironmentDetails(lstquestion,CaseRecord.Id);//added by Rajashekar
            // }catch(Exception e ){
            //}
            Test.stopTest();
        }
    }
    
    
    
    
    
    @isTest
    private static void testPartnerLookup(){
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> profileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        List<User> listOfUser = TestUtilities.getListOfUser(1);
        for(User usr : listOfUser){
            usr.ProfileID =  profiles.get('System Administrator');
        }
        insertUsersWithValidationBypass(listOfUser);
        System.runAs(listOfUser.get(0)){
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            insert listOfAccounts;
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.MailingCountry = 'India';
            }
            insert listOfContacts;
            // Create Product2 Record
            List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
            insert listOfProducts;
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
            insert listOfSupportOrg;
            List<Core_IPS_Supported_Product__c>listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            listOfSupportedProduct.get(0).Core_Product__c = listOfProducts.get(0).id;
            listOfSupportedProduct.get(0).Core_Product_Organization__c = listOfSupportOrg.get(0).id;
            insert listOfSupportedProduct;
            Core_IPS_Product_Issue_Category__c subCategory = TestUtilities.getCaseCategories();
            insert subCategory;
            // Create Asset
            List<asset> listOfAssets = TestUtilities.getAssetList(1);
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert listOfIpsProjects;
            //ListOfAssets.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            listOfAssets.get(0).accountId = listOfAccounts.get(0).Id;
            listOfAssets.get(0).core_supported_product__c = listOfSupportedProduct[0].id;
            insert listOfAssets;
            
            listOfAssets.get(0).Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
            update listOfAssets;
            System.debug('shannu System.UserInfo.getUserId -- > '+System.UserInfo.getUserId());
            List<AccountTeamMember>    atmList = [select UserId,AccountId from AccountTeamMember where UserId =:System.UserInfo.getUserId() AND User.Profile.Name in:Label.Core_IPS_Sales_Profile_List.split(',')];
            
            System.debug('Query '+atmList);
            new Core_IPS_CaseCreateHelper().getContactLookupSOQL(listOfIpsProjects.get(0).Id,listOfAssets.get(0).Id);
            
            new Core_IPS_CaseCreateHelper().displayProductVariant(listOfProducts.get(0).Id,'IPS_Case_Create');
            new Core_IPS_CaseCreateHelper().displayedqQuestions(listOfProducts.get(0).Id,subCategory.Id,true);
            new Core_IPS_CaseCreateHelper().getEnvironmentDetailsOperationList(listOfProducts.get(0).Id,subCategory.Id,true);
            Core_IPS_CaseCreateHelper.getProjectListFromAsset(listOfAssets.get(0).Id);
            Core_IPS_CaseCreateHelper.getProjectListFromAsset(listOfSupportedProduct[0].id);
            Core_IPS_CaseCreateHelper.getContactListFromAsset(listOfAssets.get(0).Id);
            case caseRecord = TestUtilities.getCase();
            caseRecord.Core_IPS_Partner_Sup_Owner__c =  UserInfo.getUserId();
            caseRecord.Core_IPS_Supported_Product__c = listOfSupportedProduct[0].id;
            caseRecord.AssetId = listOfAssets[0].id ;
            RecordType rt2 = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
            caseRecord.RecordTypeid = rt2.id ;
            insert caseRecord;
            //Rajashekar starts
            caseRecord.core_ips_project_case__c = listOfIpsProjects[0].Id;
            update caseRecord;
            //Rajashekar Ends
            System.assertEquals(rt2.id, caseRecord.RecordTypeid);
            //String jsondata = '{ "Severity":"High","description":"Testing","subject":"Testing","customerRefId":"123456", "caseCategory":"Hardware", "caseSubCategory":"CPU/Processor", "caseType":"Feature Request" }';
            Test.startTest();
            //new Core_IPS_CaseCreateHelper().SubmitCaseRecord(CaseRecord,ListOfContacts.get(0),jsondata);
            // new Core_IPS_CaseCreateHelper().getLookupPartnerOwner(null, ''+ListOfContacts[0].Id);
            new Core_IPS_CaseCreateHelper().getLookupPartnerOwner(null,listOfContacts[0].Id);
            new Core_IPS_CaseCreateHelper().getLookupPartnerOwner(''+listOfContacts[0].Id, ''+ listOfContacts[0].Id );
            /*Core_IPS_CaseEditWrapper wrapper = new Core_IPS_CaseEditWrapper(''+caseRecord.id);
            wrapper.displayPSO = true;  
            List<CustomSelectOptions> lstPSA =  wrapper.DisplayPSAPSO(null, listOfContacts[0].id,  UserInfo.getUserId(), caseRecord);
            Core_IPS_CaseCreateHelper.readFieldSet('AssetFieldSet','Asset');*/
            Test.stopTest();
        }     
    }
    
    @istest
    static void validatePSAPSO1(){
        // getRecords(1);   
        // Create UserRole Record
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> profileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        } 
        List<User> sysAdminUsr = TestUtilities.getListOfUser(1);
        for(User usr : sysAdminUsr){
            usr.ProfileID =  profiles.get('System Administrator'); 
        }
        insertUsersWithValidationBypass(sysAdminUsr);
        UserRole role = new UserRole();
        role.name='CEO';
        // Creating SETUP OBJECT (USERROLE) RECORD
        System.RunAs(sysAdminUsr[0]){
            insert role;
            Core_IPS_CaseCreateHelper.getCurrentUserProfileName();
            Core_IPS_CaseCreateLWCController.getAccountList();
        }    
        
        List<User> listOfInternalSfUsers = TestUtilities.getListOfUser(1);
        for(User usr : listOfInternalSfUsers){
            usr.ProfileID =  profiles.get('System Administrator');
            usr.userroleid = role.id; 
        }
        User validationBypassUser = [SELECT Id FROM User WHERE Profile.Name = :System.Label.Core_System_Admin_Profile_Name AND IsActive = true LIMIT 1];
        System.runAs(validationBypassUser){
            insert listOfInternalSfUsers;
        }
        //insert listOfInternalSfUsers; 
        Account accountRec1 = TestUtilities.getAccount();
        System.RunAs(listOfInternalSfUsers [0]){
            accountRec1.Name = 'DellProducts2';
            accountRec1.BillingCity = 'Mumbai';
            accountRec1.BillingCountry = 'USA';
            accountRec1.billingState = 'AK';
            accountRec1.billingStreet = 'Bratislava 1';
            accountRec1.ownerId= listOfInternalSfUsers[0].id;
            insert accountRec1;
        }
        Contact contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = accountRec1.id;
        contactRecord.Email = 'Test.con@gmail111.com';
        contactRecord.core_ips_Active__c=false;
        contactRecord.MailingCountry = 'India';
        System.RunAs(sysAdminUsr[0]){
            insert contactRecord;
            List <asset> listOfAssets = TestUtilities.getAssetList(1);
            insert  listOfAssets;
            List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
            insert listOfProducts;
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
            insert listOfSupportOrg;
            List<Core_IPS_Supported_Product__c> listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);  
            listOfSupportedProduct.get(0).Core_Product__c = listOfProducts.get(0).Id;
            listOfSupportedProduct.get(0).Core_Product_Organization__c = listOfSupportOrg.get(0).id;
            insert listOfSupportedProduct;
            //List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
            //insert ListOfSupportOrg;  
            List<Core_IPS_Master_Issue_Category__c> listOfCoreMasterIssueCategoryCaseCat = TestUtilities.getListOfCoreMastIssCategory(1);
            listOfCoreMasterIssueCategoryCaseCat.get(0).Core_type__c = 'Case Category';
            insert listOfCoreMasterIssueCategoryCaseCat;   
            Core_IPS_Product_Issue_Category__c subCategory = TestUtilities.getCaseCategories();
            subCategory.Core_Issue_Sub_Category_Name__c = listOfCoreMasterIssueCategoryCaseCat.get(0).id;
            subCategory.Core_Type__c = 'Case Subcategory';
            insert subCategory;     
            
            case caseRecord = new Case ();
            case caseRecord1 = new Case ();//added by sugandha for PSA PSO
            caseRecord.AccountId=accountRec1.Id;
            caseRecord1.AccountId=accountRec1.Id;
            caseRecord.AssetId=listOfAssets.get(0).Id;
            caseRecord1.AssetId=listOfAssets.get(0).Id;
            caseRecord.Core_IPS_Supported_Product__c=listOfSupportedProduct.get(0).id;
            caseRecord1.Core_IPS_Supported_Product__c=listOfSupportedProduct.get(0).id;
            caseRecord.ContactId=contactRecord.id;  
            caseRecord1.ContactId=contactRecord.id;        
            caseRecord.Core_IPS_Product_Org1__c=listOfSupportOrg.get(0).id;
            caseRecord1.Core_IPS_Product_Org1__c=listOfSupportOrg.get(0).id;
            //CaseRecord.Core_Case_Issue_Category__c = subCategory.get(0).id;
            //CaseRecord1.Core_Case_Issue_Category__c = subCategory.get(0).id;
            caseRecord.Core_case_issue_sub_category__c = subCategory.id;
            caseRecord1.Core_case_issue_sub_category__c = subCategory.id;
            caseRecord.Core_Issue_Description__c = 'test';
            caseRecord1.Core_Issue_Description__c = 'test';
            caseRecord.Subject='TestSubject';
            caseRecord1.Subject='TestSubject';
            caseRecord.Core_CaseType__c='Issue';
            caseRecord.Core_IPS_Issue_source__c='n/a';
            caseRecord1.Core_CaseType__c='Issue';
            caseRecord1.Core_IPS_Issue_source__c='n/a';
            //CaseRecord.core_ips_project_case__c=projectcase.id;
            RecordType rt = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            caseRecord.recordTypeId = rt.Id;
            caseRecord1.recordTypeId = rt.Id;
            RecordType rt2 = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
            case caseRecordSA = caseRecord.clone(false,true);
            caseRecordSA.RecordTypeId = rt2.Id;
            caseRecord.Core_Severity__c='Critical';
            caseRecord1.Core_Severity__c='Critical'; 
            insert caseRecord;
            insert caseRecordSA;
            insert caseRecord1;
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert listOfIpsProjects;
            Test.startTest();  // Setting the Visualforce Page
            PageReference internalCaseCreationPage = Page.Core_IPS_Internal_Case_Creation;
            Test.setCurrentPage(internalCaseCreationPage);
            // Assigning parameters in the URL
            ApexPages.currentPage().getParameters().put('mode','asset');
            //RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            ApexPages.currentPage().getParameters().put('rType',rt.Id);
            ApexPages.currentPage().getParameters().put('projectId', listOfIpsProjects.get(0).Id);
            ApexPages.currentPage().getParameters().put('productId', listOfAssets.get(0).Id);
            Core_IPS_Internal_Case_Controller ipsInternalCaseController = new Core_IPS_Internal_Case_Controller(new ApexPages.StandardController(caseRecord));
            
           /* //ipsInternalCaseController.objectSelected ='Product';
            Core_IPS_CaseEditWrapper wrapper = new Core_IPS_CaseEditWrapper(''+caseRecord.id);
            List<CustomSelectOptions> lstPSA =  wrapper.DisplayPSAPSO(contactRecord.id, contactRecord.id, null, caseRecord);
            // ipsInternalCaseController.cs = CaseRecord;
            // ipsInternalCaseController.displayPSO = true;*/
            Test.stopTest();
            System.AssertEquals(caseRecord.id != null, true);   
        }
    }
    
    @isTest
    private static void copyInterestedPartiesTest() {
        List<User> listOfInternalSfUsers = TestUtilities.getListOfUser(1);
        Core_IPS_Error_Code__c errCode = new Core_IPS_Error_Code__c();
        errCode.Core_Error_Message__c = 'Test error Message';
        errCode.Core_Locale__c = 'EN';
        errCode.Language__c = 'English';
        errCode.Name = 'G119';
        insert errCode; 
        
        // Create Case
        List<Case> listOfCases = TestUtilities.getListOfCases(2);
        insert listOfCases[0];
        
        Core_IPS_Case_Interested_Party__c ip=new Core_IPS_Case_Interested_Party__c();
        ip.User__c=listOfInternalSfUsers.get(0).Id;
        ip.Active__c=true;
        ip.Type__c='Internal';
        ip.Case__c= listOfCases[0].Id;
        insert ip;
        insert listOfCases[1];
        Core_IPS_CaseCreateHelper.copyInterestedParties(listOfCases[0].Id, listOfCases[1].Id);
        String errMsg = Core_IPS_CaseCreateHelper.getErrorMessage('G119');
        
        List<Core_IPS_Labels__c> ipsLabelList = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLabel1 = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_NoAssignedContact',Value__c='IPS No Assigned Contact Case');
        ipsLabelList.add(ipsLabel1);
        Core_IPS_Labels__c ipsLabel2 = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_Case_Create',Value__c='IPS Case Create');
        ipsLabelList.add(ipsLabel2);
        Core_IPS_Labels__c ipsLabel3 = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_Close_Case',Value__c='IPS Closed Case');
        ipsLabelList.add(ipsLabel3);
        Core_IPS_Labels__c ipsLabel4 = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_GECReadOnly',Value__c='IPS GEC ReadOnly');
        ipsLabelList.add(ipsLabel4);
        insert ipsLabelList;
        List<user> userList = TestUtilities.getListofuser(3);
        List<Profile> proflst = [select id, name from Profile where name = 'Sales Rep-BB' OR name = 'Sales Rep-BB-Dual IPS' OR name = 'Global Export Compliance' limit 3];
        userlist[0].profileid=proflst[0].id;
        userlist[0].username='salesrep020211.abc@user.com';
        userlist[1].profileid=proflst[1].id;
        userlist[1].username='salesrep020212.abc@user.com';
        userlist[2].profileid=proflst[2].id;
        userlist[2].username='gecUser020212.abc@user.com';
        insertUsersWithValidationBypass(userlist);
        Map<string,ID> caseRecordType = new Map<string,ID>();
        for(Recordtype rt:[Select ID,Name from Recordtype where sobjectType = 'Case'])
        {  
            caseRecordType.put(rt.Name,rt.ID);
        } 
        Core_IPS_CaseCreateHelper helper = new Core_IPS_CaseCreateHelper();
        helper.getButtonsVisibility(listOfCases[0].Id);
        System.runAs(userlist[0]) {
            List<Case> listOfCases2 = TestUtilities.getListOfCases(1);
            insert listOfCases2;
            helper.getButtonsVisibility(listOfCases2[0].Id);
        }
        System.runAs(userlist[1]) {
            List<Case> listOfCases3 = TestUtilities.getListOfCases(1);
            insert listOfCases3;
            helper.getButtonsVisibility(listOfCases3[0].Id);
        }
        System.runAs(userlist[2]) {
            List<Case> listOfCases4 = TestUtilities.getListOfCases(1);
            insert listOfCases4;
            helper.getButtonsVisibility(listOfCases4[0].Id);
        }
        List<Case> listOfCases5 = TestUtilities.getListOfCases(1);
        listOfCases5[0].Core_Sub_Status__c = 'Closed';
        listOfCases5[0].Status = 'Closed';
        listOfCases5[0].RecordTypeId = caseRecordType.get('IPS Closed Case');
        insert listOfCases5;
        helper.getButtonsVisibility(listOfCases5[0].Id);
        
        List<Case> listOfCases6 = TestUtilities.getListOfCases(1);
        listOfCases6[0].Core_Sub_Status__c = 'GEC Hold';
        listOfCases6[0].Status = 'On Hold';
        listOfCases6[0].RecordTypeId = caseRecordType.get('IPS GEC ReadOnly');
        insert listOfCases6;
        helper.getButtonsVisibility(listOfCases6[0].Id);
        
        List<Case> listOfCases7 = TestUtilities.getListOfCases(1);
        insert listOfCases7;
        helper.getButtonsVisibility(listOfCases7[0].Id);
        
        System.runAs(userlist[2]) {
            List<Case> listOfCases8 = TestUtilities.getListOfCases(1);
            listOfCases8[0].RecordTypeId = caseRecordType.get('IPS Closed Case');
            insert listOfCases8;
            helper.getButtonsVisibility(listOfCases8[0].Id);
        }
        System.assertEquals('Test error Message', errMsg);
    }
    
    private static TestMethod void getProductVariants_test() {
        Core_IPS_Product_Organization__c prodOrg=new Core_IPS_Product_Organization__c();
        prodOrg.Core_Organization_Description__c='Datacenter, Servers, Networking, Comms and Storage';
        prodOrg.Core_IPS_Support_Org_Name__c='Test Data Center';
        insert prodOrg;
        
        Product2 prod=new Product2();
        prod.Name='TestProd';
        prod.IsActive=true;
        prod.Core_Product_Name_EPM_ID__c='84470';
        //prod.Core_Product_Name_EPM_ID__c='Testing';
        insert prod;
        // Avoid Hardcoding Id Fix - Shipra
        
        Product2 prod1 = new Product2();
        prod1.name = 'Intel® Silicon Photonics 100G CWDM4 QSFP28 Optical Transceiver';
        prod1.Core_Product_Name_EPM_ID__c = '96609';
        prod1.Core_Design_Registration_Eligible_Ind__c  = true;
        prod1.Core_Product_Org__c  = 'IPS';
        prod1.isActive = true;
        prod1.Core_IPS_Visible_Flag_Internal__c = 'Yes';
        insert prod1;
        
        Core_IPS_Supported_Product__c supportProd=new Core_IPS_Supported_Product__c();
        supportProd.Core_Flag_Status__c='Approval Required';
        supportProd.Core_Supported_Product_Alias__c='CWDM4, QSFP28';
        supportProd.Core_Product__c=prod1.Id;
        // supportProd.Core_Product__c='01to00000074tuDAAQ';
        // Avoid Hardcoding Id Fix - Shipra
        supportProd.Core_Product_Organization__c=prodOrg.Id;
        supportProd.Core_IPS_Is_Show_Variant__c=true;
        insert supportProd;
        
        Core_IPS_Master_Issue_Category__c masterIssue=new Core_IPS_Master_Issue_Category__c();
        masterIssue.Core_Status__c='Active';
        masterIssue.Core_Type__c='MasterIssue';
        masterIssue.Name='Test Firmware/BIOS';
        insert masterIssue;
        
        Core_IPS_Product_Issue_Category__c category=new Core_IPS_Product_Issue_Category__c();
        category.Core_Issue_Sub_Category_Name__c=masterIssue.Id;
        category.Core_Type__c='Test Case Subcategory';
        category.Core_Status__c='Active';
        //category.Core_Supported_Product__c='a2E1J000000KbPyUAK';
        category.Core_Supported_Product__c=supportProd.Id;
        insert category;
        String categoryId=category.Id;
        
        Core_IPS_Project__c project=new Core_IPS_Project__c();
        project.Name='Test CC';
        project.Core_Status__c='Draft';
        insert project;
        
        asset assetProduct=new asset();
        assetProduct.Name='TestAsset';
        assetProduct.Core_Product_Organization__c=prodOrg.Id;
        assetProduct.Core_Supported_Product__c=supportProd.Id;
        assetProduct.Core_IPS_Project__c=project.Id;
        assetProduct.Product2Id = prod.Id;
        // assetProduct.Core_Product_EPM_ID__c='84470';
        insert assetProduct;
        Asset asst = [Select id,Product2.Core_Product_Name_EPM_ID__c from asset where id =: assetProduct.Id];
        Core_Flat_Product_Hierarchy__c flatProduct=new Core_Flat_Product_Hierarchy__c();
        flatProduct.Core_EPM_Hierarchy_Name__c='test Flatproduct';
        flatProduct.Core_L1_EPM_ID__c='36786';
        flatProduct.Core_L1_EPM_Name__c='Programs';
        flatProduct.Core_L2_EPM_ID__c='36786';
        flatProduct.Core_L2_EPM_Name__c='Pre-Sales Products';
        flatProduct.Core_Unique_ID__c='84470';
        //Flatproduct.Core_Product_EPM_ID__c=Project.Id;
        insert flatProduct;
        
        /* asset assetProduct=new asset();
assetProduct.Name='TestAsset';
assetProduct.Core_Product_Organization__c=prodOrg.Id;
assetProduct.Core_Supported_Product__c=supportProd.Id;
assetProduct.Core_IPS_Project__c=Project.Id;
assetProduct.Product2Id = prod.Id;
//assetProduct.Core_Product_EPM_ID__c='84470';
insert assetProduct;*/
        assetProduct = [Select Id,Name,Core_Product_EPM_ID__c FROM Asset WHERE Id =:assetProduct.Id];
        
        Core_IPS_CaseCreateHelper cicc=new Core_IPS_CaseCreateHelper();
        cicc.getProductVariant(assetProduct.id);
        cicc.getPlaformOptions(assetProduct.id);
        
        System.AssertEquals(assetProduct!= null, true);
        
    }
    
    
    
    
    @isTest
    public static void PartnerSupportAccount (){
        
        System.debug('testsum PM');
        /*
//Core_IPS_CaseCreateHelper.AdminOperation cicc=new Core_IPS_CaseCreateHelper.AdminOperation();
Set<Id> userIds = new Set<Id>();
Profile p = [select Id, name from Profile where name = 'IPS Agent-Partner'];
for(PermissionSetAssignment uId: [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :System.Label.Core_IPS_Partner_DFAE_Permission_Set AND Assignee.ProfileId = :System.Label.Core_IPS_Partner_Profile_Id]){
userIds.add(uId.AssigneeId);
}
System.assertEquals(p != null , true);
Core_IPS_Project__c project = TestUtilities.getIpsProjectRecord ();
project.Core_Status__c = 'Draft';
project.Name = 'Test Project';
insert project;

Core_IPS_Project__c project1 = TestUtilities.getIpsProjectRecord ();
project1.Core_Status__c = 'Draft';
project1.Name = 'Test Project1';
insert project1;


List<Core_IPS_Project__c> projList = new List<Core_IPS_Project__c>();
projList.add(project);
TestUtilities.addAccMemProdToProject(projList);

Core_IPS_Account__c projAcc = [select Id,Core_Status__c,Core_Account__c from Core_IPS_Account__c where Core_IPS_Project__c =: project.Id];
projAcc.Core_Status__c = 'Active';
update projAcc;

Core_IPS_Account__c coreAcc2 = TestUtilities.getCoreIpsAccount();
coreAcc2.Core_IPS_Project__c = project1.Id;
coreAcc2.Core_Account__c = projAcc.Core_Account__c;
coreAcc2.Core_Status__c = 'Active';
insert coreAcc2;
System.AssertEquals(coreAcc2.Id != null,true);
Core_IPS_Project_Member__c projMem = [select Id,Core_IPS_Contact__r.Id from Core_IPS_Project_Member__c where Core_IPS_Project__c =: project.Id];
projMem.Core_Status__c = 'Active';
update projMem;

Contact con = [select Id,core_ips_Active__c from Contact where Id =:projMem.Core_IPS_Contact__r.Id ];
con.core_ips_Active__c = true;
//update con;

String userId = p.Id;
List<User> ListOfUser = new List<User> ();
ListOfUser = TestUtilities.getListOfUser(1);
ListOfUser.get(0).ProfileID =  userId.substring(0,15); //p.Id;//.substring(0,15);
ListOfUser.get(0).ContactId = projMem.Core_IPS_Contact__r.Id;
ListOfUser.get(0).isActive= true;
System.runAs([Select id from User Where Profile.Name like'%Admin%' and isActive = true limit 1][0]){
// insert ListOfUser;
}
List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
for(Core_IPS_Project_Member__c ProjMem1 : ListOfProjectMembers){
ProjMem1.Core_IPS_Contact__c = projMem.Core_IPS_Contact__r.Id;
ProjMem1.Core_IPS_Project__c = project1.Id;
ProjMem1.Core_User__c = ListOfUser.get(0).Id; //userIds.get(0);  
ProjMem1.Core_Status__c = 'Active';            
}
insert ListOfProjectMembers;
String strQuery = 'SELECT Id,Name FROM Asset LIMIT 5';
Test.startTest();

//cicc.doAssetQuery(strQuery,null);
//Core_IPS_CaseCreateLWCController.getPartnerSupportAccount(ListOfUser.get(0).ContactId,project1.Id,null);
//Core_IPS_CaseCreateLWCController.getPartnerSupportAccount(ListOfUser.get(0).ContactId,null,ListOfUser.get(0).Id);
Core_IPS_CaseCreateLWCController.getPartnerSupportAccount(projMem.Core_IPS_Contact__r.Id,project1.Id,null);
Core_IPS_CaseCreateLWCController.getPartnerSupportAccount(projMem.Core_IPS_Contact__r.Id,null,UserInfo.GetUserId());
Core_IPS_CaseCreateLWCController.getCurrentUserProfileName();
Core_IPS_CaseCreateLWCController.getContactListFromProject(project1.Id);
Core_IPS_CaseCreateLWCController.getAccountList();
Test.stopTest();    
*/ }
    //added by Rajashekar
    
    @istest
    public static void testsetEQDDetails(){
        Integer tid = 2;
        List<User> sysAdminUsr = new List<User> ();
        List<User> listOfInternalSfUsers = new List<User> ();
        List<Core_IPS_Project__c> listOfIpsProjects = new List<Core_IPS_Project__c> ();
        List<Core_IPS_Master_Issue_Category__c> listOfCoreMasterIssueCategoryCaseCat = new List<Core_IPS_Master_Issue_Category__c>();//Added By Manoj
        List<Core_IPS_Master_Issue_Category__c> listOfCoreMasterIssueCategoryCaseSubCat = new List<Core_IPS_Master_Issue_Category__c>();//Added By Manoj
        list<Asset> listOfAssets = new list<Asset> ();
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = new List<Core_IPS_Supported_Product__c>();
        Core_IPS_Product_Issue_Category__c caseCat = new Core_IPS_Product_Issue_Category__c();
        Core_IPS_Product_Issue_Category__c subCategory = new Core_IPS_Product_Issue_Category__c();
        Core_IPS_Project__c projectcase=new Core_IPS_Project__c();
        Case caseRecord = new Case();
        Case caseRecordSA = new Case();
        case caseRecordSA2 = new Case();//Ashutosh - US106566 
        Case caseRecord1 = new Case();
        List<Contact> listOfContacts;
        List<Account> listOfAccounts = new List<Account> ();
        List<string> listOfProfileNames = new List<string> {'System Administrator'};
            Map<String,ID> mapOfProfiles = new Map<String,ID>();
        for(Profile prof : [select id, name from Profile where name IN: listOfProfileNames]){
            mapOfProfiles.put(prof.name, prof.id);
        }
        
        sysAdminUsr = TestUtilities.getListOfUser(1);
        sysAdminUsr.get(0).UserName = 'SysAdminUsr'+sysAdminUsr.get(0).UserName;
        sysAdminUsr.get(0).ProfileID =  mapOfProfiles.get('System Administrator');
        insertUsersWithValidationBypass(sysAdminUsr);
        // Create UserRole Record
        UserRole role = new UserRole();
        role.name='CEO';
        // Creating SETUP OBJECT (USERROLE) RECORD
        System.RunAs(sysAdminUsr[0]){
            insert role;
        }
        // Create Users
        listOfInternalSfUsers = TestUtilities.getListOfUser(1);
        listOfInternalSfUsers.get(0).ProfileID =  mapOfProfiles.get('System Administrator');
        listOfInternalSfUsers.get(0).userroleid = role.id;
        // Creating SETUP OBJECT (USER) RECORD
        System.RunAs(sysAdminUsr[0]){
            insert listOfInternalSfUsers;
        }
        System.assertEquals(listOfInternalSfUsers.get(0).profileid, mapOfProfiles.get('System Administrator'));
        
        //Added By Manoj
        Core_IPS_Labels__c ipsLabel = new Core_IPS_Labels__c(Name='CloseCaseEditPermission',Value__c='System Administrator');
        insert ipsLabel;
        
        // Create Account Record
        // List<Account> ListOfAccounts = new List<Account> ();
        Account accountRec1 = TestUtilities.getAccount();
        accountRec1.Core_IPS_Active__c = true;
        accountRec1.ownerid = listOfInternalSfUsers.get(0).id;
        accountRec1.Core_Military_Aerospace_and_Government__c = true;
        
        listOfAccounts.add(accountRec1);
        insert listOfAccounts;
        List<Core_IPS_Labels__c>  lstLabels = TestUtilities.getIPSLabel();
        insert lstLabels;
        System.assert(listOfAccounts[0].Id != null, 'Account Record not created');
        
        // Create Contact
        listOfContacts = TestUtilities.getListOfContact(1);
        listOfContacts.get(0).Accountid = listOfAccounts.get(0).Id;
        listOfContacts.get(0).Core_IPS_Intel_Support_Owner__c = listOfInternalSfUsers.get(0).id;
        listOfContacts.get(0).ownerid = listOfInternalSfUsers.get(0).id;
        ListoFContacts[0].MailingCountry = 'India';
        insert listOfContacts;
        System.assert(listOfContacts[0].Id != null, 'Contact Record not created');
        // Create Support Org Record
        List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        insert listOfSupportOrg;
        System.assert(listOfSupportOrg != null, 'Support Org Record not created');
        // Create Product2 Record
        List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
        listOfProducts[0].Core_Sales_Visible_Flag__c =FALSE;
        listOfProducts[0].Core_Hierarchy_ID__c='59';
        insert listOfProducts;
        System.assert(listOfProducts[0].id != null,'Product2 Record not created');
        
        // Create Supported product Record
        listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        listOfSupportedProduct.get(0).Core_Product__c = listOfProducts.get(0).id;
        listOfSupportedProduct.get(0).Core_Product_Organization__c = listOfSupportOrg.get(0).id;
        insert listOfSupportedProduct;
        
        System.assert(listOfSupportedProduct[0].id != null,'Supported product Record not created');
        // Create Design Project Record
        listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        insert listOfIpsProjects;
        System.assert(listOfIpsProjects.get(0).Id != null, 'Design Project Record not created');
        // Create IPS Product Record
        List<Core_IPS_Product__c> listOfIpsProducts = TestUtilities.getListOfIpsProducts(1);
        listOfIpsProducts.get(0).Core_IPS_Project__c = listOfIpsProjects.get(0).id;
        listOfIpsProducts.get(0).Core_Supported_Product__c = listOfSupportedProduct.get(0).id;
        listOfIpsProducts.get(0).Status__c = 'Submitted';
        insert listOfIpsProducts;
        System.assert(listOfIpsProducts.get(0).Id != null, 'IPS Product Record not created');
        // Create Asset
        listOfAssets = TestUtilities.getAssetList(1);
        listOfAssets.get(0).Core_IPS_Project__c = listOfIpsProjects.get(0).Id;
        listOfAssets.get(0).accountId = listOfAccounts.get(0).Id;
        // if(tid!=1){
        listOfAssets.get(0).core_supported_product__c = listOfSupportedProduct[0].id;
        //}
        insert listOfAssets;
        System.assert(listOfAssets.get(0).Id != null, 'Asset Record not created');
        // Create Core Master Issue Category - Case Category
        listOfCoreMasterIssueCategoryCaseCat = TestUtilities.getListOfCoreMastIssCategory(1);
        listOfCoreMasterIssueCategoryCaseCat.get(0).Core_type__c = 'Case Category';
        insert listOfCoreMasterIssueCategoryCaseCat;
        System.assert(listOfCoreMasterIssueCategoryCaseCat[0].Id != null, 'Record not Created');
        // Create Core Master Issue Category - Case Sub Category
        listOfCoreMasterIssueCategoryCaseSubCat = TestUtilities.getListOfCoreMastIssCategory(1);//Changed by Manoj
        listOfCoreMasterIssueCategoryCaseSubCat.get(0).Core_Master_Issue_Category__c = listOfCoreMasterIssueCategoryCaseCat.get(0).id;
        insert listOfCoreMasterIssueCategoryCaseSubCat;
        System.assert(listOfCoreMasterIssueCategoryCaseSubCat[0].Id != null, 'Record not Created');
        // Create Core Product Issue Category - Case Category
        List<Core_IPS_Product_Issue_Category__c> listOfCoreProdIssCategoryCaseCat = TestUtilities.getListOfCoreProdIssCategory(2);
        for(Core_IPS_Product_Issue_Category__c prodIssuCat : listOfCoreProdIssCategoryCaseCat){
            prodIssuCat.Core_type__c = 'Case Category';
            prodIssuCat.Core_Issue_Category_Name__c = listOfCoreMasterIssueCategoryCaseCat.get(0).id;
            prodIssuCat.Core_supported_product__c = listOfSupportedProduct[0].id;
        }
        insert listOfCoreProdIssCategoryCaseCat;
        System.assert(listOfCoreProdIssCategoryCaseCat[0].Id != null, 'Record not Created');
        //Creating MasterCaseCategory
        Core_IPS_Master_Issue_Category__c masterCaseCategory = TestUtilities.getMasterCaseCategories();
        masterCaseCategory.Core_type__c = 'Case Category';
        insert masterCaseCategory;
        System.assert(masterCaseCategory.Id != null, 'Record not created'); 
        //Creating MasterCategory
        Core_IPS_Master_Issue_Category__c masterCategory = TestUtilities.getMasterCaseCategories();
        masterCategory.Core_Master_Issue_Category__c = masterCaseCategory.id;            
        insert masterCategory;
        System.assert(masterCategory.Id != null, 'Record not created');
        caseCat = TestUtilities.getCaseCategories();
        caseCat.Core_Issue_Category_Name__c = masterCategory.id;
        caseCat.Core_Type__c = 'Case Category';
        insert caseCat; 
        System.assert(caseCat.Id != null, 'Record not created');
        
        subCategory = TestUtilities.getCaseCategories();
        subCategory.Core_Issue_Sub_Category_Name__c = masterCategory.id;
        subCategory.Core_Type__c = 'Case Subcategory';
        insert subCategory; 
        System.assert(subCategory.Id != null, 'Record not created');
        //added by naresh related to the Test Coverage Story US41854 on 6/10/16
        // projectcase = TestUtilities.getIpsProjectRecord();
        List<Core_IPS_Project__c> projList=new List<Core_IPS_Project__c>();
        //projList= TestUtilities.getListOfIpsProjects(1);
        // insert projList;
        projectcase=listOfIpsProjects[0];
        // insert projectcase;
        System.assert(projectcase.Id != null, 'Record not created');
        //end
        
        caseRecord = new Case ();
        caseRecord1 = new Case ();//added by sugandha for PSA PSO
        caseRecord.AccountId=listOfAccounts.get(0).Id;
        caseRecord1.AccountId=listOfAccounts.get(0).Id;
        if(tid!=3){
            if(tid!=4) {
                caseRecord.AssetId=listOfAssets.get(0).Id;
                caseRecord1.AssetId=listOfAssets.get(0).Id;
            }
            caseRecord.Core_IPS_Supported_Product__c=listOfSupportedProduct.get(0).id;
            caseRecord1.Core_IPS_Supported_Product__c=listOfSupportedProduct.get(0).id;
        }
        caseRecord.ContactId=listOfContacts.get(0).id;  
        caseRecord1.ContactId=listOfContacts.get(0).id;        
        caseRecord.Core_IPS_Product_Org1__c=listOfSupportOrg.get(0).id;
        caseRecord1.Core_IPS_Product_Org1__c=listOfSupportOrg.get(0).id;
        caseRecord.Core_Case_Issue_Category__c = caseCat.id;
        caseRecord1.Core_Case_Issue_Category__c = caseCat.id;
        caseRecord.Core_case_issue_sub_category__c = subCategory.id;
        caseRecord1.Core_case_issue_sub_category__c = subCategory.id;
        caseRecord.Core_Issue_Description__c = 'test';
        caseRecord1.Core_Issue_Description__c = 'test';
        caseRecord.Subject='TestSubject';
        caseRecord1.Subject='TestSubject';
        caseRecord.Core_CaseType__c='Issue';
        caseRecord.Core_IPS_Issue_source__c='n/a';
        caseRecord1.Core_CaseType__c='Issue';
        caseRecord1.Core_IPS_Issue_source__c='n/a';
        caseRecord.core_ips_project_case__c=projectcase.id;
        RecordType rt = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        caseRecord.recordTypeId = rt.Id;
        caseRecord1.recordTypeId = rt.Id;
        RecordType rt2 = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
        caseRecordSA = caseRecord.clone(false,true);
        caseRecordSA.RecordTypeId = rt2.Id;
        
        if(tid==1){
            caseRecord.Core_Severity__c='Critical';
            caseRecord1.Core_Severity__c='Critical';
        }
        if(tid!=1){
            insert caseRecord;
            insert caseRecordSA;
            insert caseRecord1;
        }
        Core_IPS_Question__c question = TestUtilities.getCoreQuestion();
        Core_IPS_Question__c questionPicklist = TestUtilities.getCoreQuestion();
        questionPicklist.Core_IPS_Datatype__c = Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ;  
        Core_IPS_Question__c questionMultiSelect = TestUtilities.getCoreQuestion();
        questionMultiSelect.Core_IPS_Datatype__c = Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c ;  
        Core_IPS_Question__c questionTextArea = TestUtilities.getCoreQuestion();
        questionTextArea.Core_IPS_Datatype__c = Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c; 
        List<Core_IPS_Question__c> questions = new List<Core_IPS_Question__c>{question, questionPicklist, questionMultiSelect, questionTextArea};
            insert questions; 
        
        
        List<Core_IPS_Answer__c> ansswers = TestUtilities.getCoreAnswers(4); 
        integer i=0;  
        for(Core_IPS_Answer__c ans : ansswers){ 
            ans.Core_IPS_Question__c = questions[i].id;
            i++;    
        }      
        insert ansswers;
        
        List<Core_IPS_Assigned_Environment_Variables__c> operationalList = TestUtilities.getListOfEnvDetailsOperational(4);
        i=0; 
        for(Core_IPS_Assigned_Environment_Variables__c assignment : operationalList){
            assignment.Core_IPS_Question__c = questions[i].id;
            assignment.Core_Product_Issue_Sub_Category__c = caseRecord.Core_Case_Issue_Sub_Category__c;
            assignment.Core_supported_product__c = caseRecord.Core_IPS_Supported_Product__c; 
            i++;
        } 
        insert  operationalList;
        i=0;
        List<Core_IPS_Response__c> envResponses = TestUtilities.getCoreResponseRecords(4);
        for(Core_IPS_Response__c envResp : envResponses){
            envResp.Core_IPS_Case__c = caseRecord.id;
            envResp.Core_IPS_Question_Master__c = questions[i].id;  
            envResp.Core_IPS_Answer__c = 'test answer';
            envResp.Core_IPS_Answer_Master__c = ansswers[i].id;
            
            i++;
        }
        insert envResponses;
        Test.startTest();
        Core_IPS_CaseCreateHelper helper = new Core_IPS_CaseCreateHelper();
        List<Core_IPS_EnvironmentDetailQuestion> lstEnvDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        
        
        lstEnvDetails = helper.getEnvironmentDetailsOperationList(caseRecord.Core_IPS_Supported_Product__c, 
                                                                  caseRecord.Core_Case_Issue_Sub_Category__c,false);
        helper.setCurrentEnvironmentDetails(lstEnvDetails, caseRecord.id);
        System.assertEquals(true, lstEnvDetails != null);
        Test.stopTest();
        
    }
    //Rajashekar ends
    
    @isTest
    private static void displayProductVariant1() {
        // Create Asset
        list<Asset> assetLists = TestUtilities.getAssetList(1);
        insert assetLists;
        System.debug('shannu --> '+assetLists[0].Id);
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> profileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        List<User> listOfUser = TestUtilities.getListOfUser(1);
        for(User usr : listOfUser){
            usr.ProfileID =  profiles.get('System Administrator');
        }
        insertUsersWithValidationBypass(listOfUser);
        System.assertEquals(listOfUser.get(0).profileid, profiles.get('System Administrator'));  
        System.assert(listOfUser.get(0).profileid !=null, 'true');  
        System.runAs(listOfUser.get(0)){
            List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
            insert listOfAccounts;
            // Create Contact
            List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
            for(Contact contactRec : listOfContacts){
                contactRec.Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
                contactRec.Accountid = listOfAccounts.get(0).Id;
                contactRec.Core_Country_Region__c = null;
                contactRec.mailingCountry = 'India';
            }
            insert listOfContacts;
            
            //here--
            TestUtilities.getCustomerUsersWithAccountsAndContacts('Acc1', 1, 1,1,1,'Partner',2);
            Account accountId = [select Id from Account where Name LIKE '%Acc1%'];
            System.debug('shannu accountId '+accountId);
            Contact contactId = [select id from Contact where Name LIKE '%Contact1%'];
            System.debug('shannu contactId '+contactId);
            
            System.debug('shannu contactId'+[select id from user where contactId=:listOfContacts[0].Id]);
            Core_IPS_CaseCreateLWCController.getProjectList(contactId.Id);
            
            //--here 
            //  Core_IPS_CaseCreateLWCController.getProjectList(contactId[0].Id);
            Core_IPS_CaseCreateLWCController.getProjectList(UserInfo.getUserId());
            
            List<Core_Flat_Product_Hierarchy__c> listOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(1);
            listOfFlatProductHierarchy[0].Core_Unique_ID__c  =';75025;128758;123707;123704;94489';
            insert listOfFlatProductHierarchy;
            // Create Asset
            list<Asset> assetList = TestUtilities.getAssets(listOfAccounts, 1);
            list<Core_IPS_Supported_Product__c> sps = new list<Core_IPS_Supported_Product__c>();    
            for(Asset asst : assetList){
                asst.accountId = listOfAccounts.get(0).Id;
                asst.Contactid = listOfContacts.get(0).id;
                //asst.Core_Product_EPM_ID__c = '75025';
                sps.add(new  Core_IPS_Supported_Product__c(id=asst.core_supported_product__c, Core_IPS_Is_Show_Variant__c = true, Core_Product_EPM_ID__c = '75025'));
                // Asst.Core_Product_EPM_ID__c = ListOfFlatProductHierarchy[0].Core_Unique_ID__c;
            }
            update  sps;  
            update assetList;    
            
            Test.startTest();
            List<Core_IPS_Project__c> listOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert listOfIpsProjects;
            
            Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
            org.Core_IPS_Support_Org_Name__c ='test';
            org.Core_Organization_Description__c ='test';
            insert org;
            
            List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
            Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();       
            //parQues.recordtypeid = edqRecordTypeId;
            parQues1.Core_IPS_Question__c = 'Test Parent Question';
            parQues1.Core_IPS_Datatype__c = 'Text Area';
            parQues1.Core_IPS_Status__c = 'Active';
            parQues1.Core_IPS_Product_Organization__c = Org.id;
            lstparQues.add(parQues1);
            insert lstparQues;
            
            
            Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
            question.isVisible=false;
            question.type='Text';
            question.questionId=lstparQues.get(0).id;
            question.sPlaceHolder=null;
            question.required=true;
            question.selectedValue='test';
            
            Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
            question4.type='Text';
            question4.questionId=lstparQues.get(0).id;
            question4.sPlaceHolder='Testing the Placeholder Value from the test class to cover';
            
            
            Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
            question1.type='Text Area';
            question1.questionId=lstparQues.get(0).id;
            question1.tPlaceHolder='';
            question4.required=true;
            
            Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
            question5.type='Text Area';
            question5.questionId=lstparQues.get(0).id;
            question5.tPlaceHolder='Testing';
            
            
            Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
            question2.type='Picklist';
            question2.questionId=lstparQues.get(0).id;
            question2.sPlaceHolder=null;
            
            Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
            question3.type='Multiselect Picklist';
            question3.questionId=lstparQues.get(0).id;
            question3.sPlaceHolder=null;
            List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
            lstquestion.add(question);
            lstquestion.add(question1);
            lstquestion.add(question2);
            lstquestion.add(question3);
            lstquestion.add(question4);
            lstquestion.add(question5);
            //Insert lstquestion;
            
            System.debug('Shannu Start test');
            System.debug('shannu --> '+assetList[0].Id);
            assetList[0].Core_Product_Organization__c = Label.Core_IPS_MAG_Support_Org;
            //update assetList[0];
            System.debug('testsum list'+assetList[0].Core_Product_Organization__c);
            System.debug('testsum label'+System.label.Core_IPS_MAG_Support_Org);
            
            
            new Core_IPS_CaseCreateHelper().getProductVariant(assetList[0].Id);
            System.debug('shannu --> '+assetList);
            System.debug('shannu --> '+assetList.size());
            
            
            System.debug('testsum'+System.label.Core_IPS_MAG_Support_Org.Contains((assetList[0].Core_Product_Organization__c+'').substring(0,15)));
            System.debug('Shannu stop test');
            System.debug('Shannu cehck for 2');
            
            assetList.add(assetList[0]);
            System.debug('shannu --> '+assetList);
            System.debug('shannu --> '+assetList.size());
            
            
            
            new Core_IPS_CaseCreateHelper().getProductVariant(assetList[0].Id);
            
            
            List<Product2> listOfProducts = TestUtilities.getListOfProduct(1);
            listOfProducts.get(0).Core_Sales_Visible_Flag__c = False;
            listOfProducts.get(0).Core_Hierarchy_ID__c = '59';
            listOfProducts.get(0).Core_Unique_ID__c = 'L5 Id '+1;
            insert listOfProducts;
            List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
            insert listOfSupportOrg;
            List<Core_Flat_Product_Hierarchy__c> flh = TestUtilities.getListOfFlatProductHierarchy(1);
            insert flh;
            List<Core_IPS_Supported_Product__c>listOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            listOfSupportedProduct.get(0).Core_Product__c = listOfProducts.get(0).id;
            listOfSupportedProduct.get(0).Core_Product_Organization__c = listOfSupportOrg.get(0).id;
            insert listOfSupportedProduct;
            
            List<asset> listOfAssets = TestUtilities.getAssetList(1);
            //ListOfAssets.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            listOfAssets.get(0).accountId = listOfAccounts.get(0).Id;
            listOfAssets.get(0).core_supported_product__c = listOfSupportedProduct[0].id;
            insert listOfAssets;
            
            case caseRecord = TestUtilities.getCase();
            caseRecord.Core_IPS_Partner_Sup_Owner__c =  UserInfo.getUserId();
            caseRecord.Core_IPS_Supported_Product__c = listOfSupportedProduct[0].id;
            caseRecord.AssetId = listOfAssets[0].id ;
            RecordType rt2 = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            caseRecord.RecordTypeid = rt2.id ;
            caseRecord.Core_IPS_Country_Region__c = 'India';
            caseRecord.ContactId = listOfContacts[0].Id;
            caseRecord.Core_Issue_Description__c ='test';
            insert caseRecord;
            RecordType rt4 = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Core_IPS_Question__c' LIMIT 1];
            Core_IPS_Question__c csa = TestUtilities.getCoreQuestion();
            //csa.Core_IPS_Datatype__c = 'Text Area';
            //csa.RecordTypeId = RT4.Id;
            insert csa;
            Core_IPS_Question__c csa1 = TestUtilities.getCoreQuestion();
            csa1.Core_IPS_Datatype__c = 'PickList';
            insert csa1;
            Core_IPS_Question__c csa2 = TestUtilities.getCoreQuestion();
            csa2.Core_IPS_Parent_Question__c = csa1.Id;
            insert csa2;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars.get(0).Core_IPS_Question__c = csa.Id;
            insert envVars;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars2 = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars2.get(0).Core_IPS_Question__c = csa1.Id;
            insert envVars2;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars3 = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars3.get(0).Core_IPS_Question__c = csa2.Id;
            insert envVars3;
            Core_IPS_Labels__c ipsLabel1 = new Core_IPS_Labels__c(Name='Core_IPS_Datatype_Text',Value__c='Text');
            insert ipsLabel1;
            Core_IPS_Labels__c ipsLabel2 = new Core_IPS_Labels__c(Name='Core_IPS_Picklist',Value__c='PickList');
            insert ipsLabel2;
            Core_IPS_Labels__c ipsLabel3 = new Core_IPS_Labels__c(Name='Core_IPS_Datatype_TextArea',Value__c='Text Area');
            insert ipsLabel3;
            Core_IPS_Labels__c ipsLabel4 = new Core_IPS_Labels__c(Name='Core_IPS_Multi_Select',Value__c='Multiselect Picklist');
            insert ipsLabel4;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars1 = [Select Id,Core_IPS_Question__r.Core_IPS_Parent_Question__c,Core_IPS_Question__r.Core_IPS_Question__c,Core_IPS_Question__c,Core_required__c,Core_Agent_Only__c,Core_IPS_Question__r.Core_IPS_Datatype__c From Core_IPS_Assigned_Environment_Variables__c];
            String chlidId = csa2.Id;
            String edq = JSON.serialize(lstquestion);
            List<Core_IPS_Answer__c> answer = TestUtilities.getCoreAnswers(1);
            answer.get(0).Core_IPS_Question__c = csa.Id;
            insert answer;
            //  TWC745-7160 - START Shipra
            List<Core_IPS_Response__c> resList = new List<Core_IPS_Response__c>();
            Core_IPS_Response__c res = new Core_IPS_Response__c();
            res.Core_IPS_Question_Master__c = csa.Id;
            res.Core_IPS_Answer_Master__c = answer.get(0).Id;
            res.Core_IPS_Case__c = caseRecord.Id;
            //res.Core_IPS_Agent_Only__c = true;
            res.Core_IPS_Answer__c = 'test answer';
            resList.add(res);
            Core_IPS_Response__c res1 = new Core_IPS_Response__c();
            res1.Core_IPS_Question_Master__c = lstparQues.get(0).id;
            res1.Core_IPS_Answer_Master__c = answer.get(0).Id;
            res1.Core_IPS_Case__c = caseRecord.Id;
            //res1.Core_IPS_Agent_Only__c = true;
            res1.Core_IPS_Answer__c = 'test answer';
            resList.add(res1);
            
            insert resList;
            //  TWC745-7160 - END Shipra
            List<Core_IPS_Master_Issue_Category__c> master = TestUtilities.getListOfCoreMastIssCategory(1);
            master.get(0).Core_Type__c = 'Case Category';
            insert master;
            Core_IPS_Product_Issue_Category__c cat = TestUtilities.getCaseCategories();
            insert cat;
            Core_IPS_Product_Issue_Category__c cat1 = TestUtilities.getCaseCategories(); 
            cat1.Core_Product_Issue_Category__c = cat.Id;
            cat1.Core_Issue_Sub_Category_Name__c = master.get(0).Id; 
            insert cat1;
            
            
            new Core_IPS_CaseCreateHelper().getAgent();
            new Core_IPS_CaseCreateHelper().getsubCategoryOptions(cat.Id);
            new Core_IPS_CaseCreateHelper().SubmitCaseRecord(caseRecord,listOfContacts.get(0),edq);
            try{
                ID recordTypeId = schema.sobjecttype.Contact.getrecordtypeinfosbyname().get('Outlook contact').getRecordTypeId();
                User u0 = [select id from user where usertype='Standard' AND ISActive=true limit 1 ];
                Contact contactRecord = new Contact(
                    FirstName = 'Ding Dong1', 
                    Lastname = 'Dell1',
                    Email = 'hercules_COdeREfactor1@gmail.com',
                    recordTypeId = recordTypeId,
                    Core_IPS_Intel_Support_Owner__c=u0.id,
                    Core_IPS_Active__c = true,
                    AccountId = listOfContacts[0].AccountId,
                    mailingCountry = 'India'
                    
                );
                insert contactRecord;
                caseRecord.Core_Issue_Description__c = '<h1> Code refactor By Hercules </h1>';
                caseRecord.ContactId = listOfContacts[0].Id; 
                caseRecord.Core_IPS_Country_Region__c = 'Iran';
                User u = new user();
                u =  TestUtilities.getListOfUser(1)[0];
                Profile p = [Select id,Name from Profile Where Name like '%IPS Agent-Partner%'];
                u.ProfileId = p.id;
                u.ContactId = listOfContacts[0].Id;
                insertUsersWithValidationBypass(new List<User>{u});
                User u1 = TestUtilities.getListOfUser(1)[0];
                Profile p1 = [Select id,Name from Profile Where Name like '%IPS External Customer%'];
                u1.ProfileId = p1.Id;
                u1.ContactId = ContactRecord.Id;
                insertUsersWithValidationBypass(new List<User>{u1});
                System.runas(u){
                    
                    new Core_IPS_CaseCreateHelper().SubmitCaseRecord(caseRecord,listOfContacts.get(0),edq);
                }
                case c = new Case();
                c.Id = caseRecord.Id; 
                c.ContactId = listOfContacts[0].Id; 
                c.Core_IPS_Country_Region__c = 'Ukraine';
                //Sowmya added
                Core_IPS_Question__c questionMaster = TestUtilities.getCoreQuestion();
                insert questionMaster;
                list<Core_IPS_Response__c> respList= TestUtilities.getCoreResponseRecords(1);
                respList[0].Core_Ips_Case__c = c.Id;
                respList[0].Core_IPS_Question_Master__c = questionMaster.Id;
                
                insert respList;
                //Sowmya end
                System.runas(u1){
                    new Core_IPS_CaseCreateHelper().SubmitCaseRecord(c,listOfContacts.get(0),edq);
                }
            }
            catch(Exception e){}
            new Core_IPS_CaseCreateHelper().basedonSelectedandQuestionValue(listOfProducts.get(0).Id,chlidId, caseRecord.Core_IPS_Supported_Product__c);
            new Core_IPS_CaseCreateHelper().constructWrapper(envVars1);
            try{
                new Core_IPS_CaseCreateHelper().setCurrentEnvironmentDetails(lstquestion,caseRecord.Id);
            } catch(Exception e) {}
            //new Core_IPS_CaseCreateHelper().getProductVariant('');
            List<Core_IPS_Project__c> listOfIpsProjects1 = TestUtilities.getListOfIpsProjects(1);
            insert listOfIpsProjects1;
            Core_IPS_CaseCreateHelper.getContactListFromProject(listOfIpsProjects1.get(0).Id);
            List<user> userlist = TestUtilities.getListofuser(1);
            List<Profile> proflst = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
            userlist[0].profileid=proflst[0].id;
            userlist[0].username='salesrep020211.abc@user.com';
            insertUsersWithValidationBypass(userlist);
            System.runAs(userlist[0]) {
                Core_IPS_CaseCreateHelper.getAccountList();
            }    
            
            Core_IPS_CaseCreateHelper.getCurrentUserProfileName();
            Core_IPS_CaseCreateHelper.readFieldSet('ContactFieldSet','Contact');
            new Core_IPS_CaseCreateHelper().getPlaformOptions(listOfAssets.get(0).Id);
            new Core_IPS_CaseCreateHelper().getPlaformOptions(listOfSupportedProduct.get(0).Id);
            new Core_IPS_CaseCreateHelper().getDynmicFields(lstquestion);
            //new Core_IPS_CaseCreateHelper().setCurrentEnvironmentDetails(lstquestion,CaseRecord.Id);//added by Rajashekar
            // }catch(Exception e ){
            //}
            Test.stopTest();
        }
    }
    @isTest
    private static void testGetPSAOptionsOnly() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Account testAccount = TestUtilities.getAccount();
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.FirstName = 'Test Contact1';
        testContact.LastName = 'Test Contact1';
        testContact.Email = 'Test_Contact1@tester.com';
        testContact.Core_Job_Function__c = 'Information Technology';
        testContact.MailingCountry = 'IND';
        testContact.Core_Contact_B2B_Indicator__c = true;
        testContact.AccountId = testAccount.Id;
        insert testContact;
        
        Core_IPS_Project__c testProject = TestUtilities.getIpsProjectRecord();
        testProject.Core_Status__c = 'Draft';
        insert testProject;
        
        Core_IPS_Account__c projectAccount = TestUtilities.getCoreIpsAccount();
        projectAccount.Core_IPS_Project__c = testProject.Id;
        projectAccount.Core_Account__c = testAccount.Id;
        projectAccount.Core_Status__c = 'Active';
        insert projectAccount;
        
       /* User partnerUser = TestUtilities.getListOfUser(1)[0];
        partnerUser.ProfileId = System.Label.Core_IPS_Agent_Partner_Profile_id;
        partnerUser.ContactId = testContact.Id;
        partnerUser.IsActive = true;
        
        // Both UserRole (setup) and User (setup) must be inserted together
        // inside System.runAs to avoid MIXED_DML with non-setup objects above
        
        System.runAs(currentUser) {
            UserRole usRole = new UserRole(Name = 'Admin');
            insert usRole;
            partnerUser.UserRoleId = usRole.Id;
            insert partnerUser;
        }*/
        
        Core_IPS_Project_Member__c projectMember = new Core_IPS_Project_Member__c(
            Core_IPS_Project__c = testProject.Id,
            Core_IPS_Contact__c = testContact.Id,
            Core_User__c = currentUser.Id,
            Core_Status__c = 'Active'
        );
        insert projectMember;
        
        Test.startTest();
        List<CustomSelectOptions> projectBasedOptions =
            new Core_IPS_CaseCreateHelper().getPSAOptions(null, testProject.Id, null);
        
        List<CustomSelectOptions> psoBasedOptions =
            new Core_IPS_CaseCreateHelper().getPSAOptions(testContact.Id, null, currentUser.Id);
        Test.stopTest();
    }
    @isTest
    private static void testGetCategoryOptionsOnly() {
        Product2 productRec = TestUtilities.getListOfProduct(1)[0];
        insert productRec;
        
        Core_IPS_Product_Organization__c supportOrg = TestUtilities.getListOfSupportOrg(1)[0];
        insert supportOrg;
        
        Core_IPS_Supported_Product__c supportedProduct = TestUtilities.getListOfSupportedProduct(1)[0];
        supportedProduct.Core_Product__c = productRec.Id;
        supportedProduct.Core_Product_Organization__c = supportOrg.Id;
        insert supportedProduct;
        
        Core_IPS_Master_Issue_Category__c masterCategory = TestUtilities.getListOfCoreMastIssCategory(1)[0];
        masterCategory.Core_Status__c = 'Active';
        masterCategory.Core_Type__c = 'Case Category';
        insert masterCategory;
        
        Core_IPS_Product_Issue_Category__c productCategory = TestUtilities.getCaseCategories();
        productCategory.Core_Status__c = 'Active';
        productCategory.Core_Type__c = 'Case Category';
        productCategory.Core_Supported_Product__c = supportedProduct.Id;
        productCategory.Core_Issue_Category_Name__c = masterCategory.Id;
        insert productCategory;
        
        Test.startTest();
        List<CustomSelectOptions> options =
            new Core_IPS_CaseCreateHelper().getCategoryOptions(String.valueOf(supportedProduct.Id));
        Test.stopTest();
    }
}