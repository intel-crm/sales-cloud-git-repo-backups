@isTest public class Core_RestAPI_Case_UpdateV1_Handler_Test{
    
    private static User adminUser= [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true AND UserRole.Name != null Limit 1];
    private static Core_RestAPI_Case_UpdateV1_Wrapper objWrapper = new Core_RestAPI_Case_UpdateV1_Wrapper();
    private static Map<String,Core_IPS_Answer__c> envAnsAndAnsId = new Map<String,Core_IPS_Answer__c>();
    @testSetup public static void setupData(){
        Test.startTest();
        System.runAs(adminUser){
          Core_RestAPI_TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
            Core_IPS_Project__c proj = new Core_IPS_Project__c();
            proj.Core_Status__c = 'Draft';
            proj.Name = 'testProj';
            insert proj;
            
            Account accObj = Core_RestAPI_TestUtilities.getAccountRecord();
            accObj.Ownerid = adminUser.id;
            accObj.Core_IPS_Active__c = true;
            insert accObj;
            
            Contact conObj = Core_RestAPI_TestUtilities.getContact();
            conObj.AccountId= accObj.id;
            insert conObj;
            
            Contact conObj1 = Core_RestAPI_TestUtilities.getContact();
            conObj1.AccountId= accObj.id;
            conObj1.Email = 'Contact123Dell@gmail.com';
            insert conObj1;
            
            Core_IPS_Product_Organization__c  org =new Core_IPS_Product_Organization__c ( 
                Core_IPS_Support_Org_Name__c = 'TestName',
                Core_Organization_Description__c = 'TestDescription'        
            );
            insert org;
            
            Core_IPS_Product_Organization__c  org1 =new Core_IPS_Product_Organization__c ( 
                Core_IPS_Support_Org_Name__c = 'TestName',
                Core_Organization_Description__c = 'TestDescription'        
            );
            insert org1;
            
            Product2 prod = new Product2(
                Name = 'Haswell EP',
                Core_Sales_Visible_Flag__c = false,
                Core_IPS_Visible_Flag_External__c = true,
                Core_IPS_Visible_Flag_Internal__c = 'Yes',
                IsActive = true,
                Core_Product_Org__c = 'IPS'
            ); 
            insert prod;
            
            Product2 prod1 = new Product2(
                Name = 'Haswell EP',
                Core_Sales_Visible_Flag__c = false,
                Core_IPS_Visible_Flag_External__c = true,
                Core_IPS_Visible_Flag_Internal__c = 'Yes',
                IsActive = true,
                Core_Product_Org__c = 'IPS'//@@New Validation Rule!!!
            ); 
            insert prod1;
            
            Core_IPS_Supported_Product__c sp= new Core_IPS_Supported_Product__c(
                Core_Product_Organization__c = org.Id,
                Core_EOIS__c = true,
                Core_Supported_Product_Name__c = 'Haswell EP',
                Core_Product__c=prod.id
            );
            insert sp;
            
            Core_IPS_Supported_Product__c sp1= new Core_IPS_Supported_Product__c(
                Core_Product_Organization__c = org1.Id,
                Core_EOIS__c = false,
                Core_Supported_Product_Name__c = 'Haswell EP1',
                Core_Product__c=prod1.id
            );
            
            insert sp1;
            
            List<Asset> AssetList = Core_RestAPI_TestUtilities.getAssetList(5); 
            for(Integer i=0;i<=(AssetList.size()-1);i++){
                Asset objAsset = AssetList[i];
                objAsset.OwnerId = adminUser.Id;
                objAsset.Core_IPS_Project__c= proj.Id;
                objAsset.Core_Supported_Product__c=sp.Id;
            }
            insert AssetList;
            
            Core_RestAPI_Response_Codes__c lstResponceCode = new Core_RestAPI_Response_Codes__c(name ='InvalidInputField', Core_Message__c= 'Invalid Input' , Core_Code__c ='9011');
            insert lstResponceCode;
            Core_RestAPI_Response_Codes__c lstResponceCode1 = new Core_RestAPI_Response_Codes__c(name ='InActiveProduct', Core_Message__c= 'Intel Product is inactive' , Core_Code__c ='9015');
            insert lstResponceCode1;
            
            Case csObj = Core_RestAPI_TestUtilities.getCase();
            conObj.AccountId= accObj.id;
            csObj.ContactId = conObj.Id;
            csObj.assetId = AssetList[0].id;
            csObj.Core_IPS_Customer_Visible__c = true;
            insert csObj;
            
            Case csObj1 = Core_RestAPI_TestUtilities.getCase();
            csObj1.AccountId= accObj.id;
            csObj1.ContactId = conObj.Id;
            csObj1.assetId = AssetList[0].id;
            csObj1.Core_IPS_Customer_Visible__c = false;
            csObj1.status = 'Closed';
            insert csObj1;
            
            Case csObj2 = Core_RestAPI_TestUtilities.getCase();
            csObj2.AccountId= accObj.id;
            csObj2.ContactId = conObj.Id;
            csObj2.assetId = AssetList[1].id;
            csObj2.Core_IPS_Customer_Visible__c = false;
            csObj2.status = 'Closed';
            insert csObj2;
            
            Case csObj3 = Core_RestAPI_TestUtilities.getCase();
            csObj3.AccountId= accObj.id;
            csObj3.ContactId = conObj.Id;
            csObj3.assetId = AssetList[2].id;
            csObj3.Core_IPS_Customer_Visible__c = false;
            csObj3.status = 'Closed';
            insert csObj3;
            
            Case csObj4 = Core_RestAPI_TestUtilities.getCase();
            csObj4.AccountId= accObj.id;
            csObj4.ContactId = conObj.Id;
            csObj4.assetId = null;
            csObj4.Core_IPS_Customer_Visible__c = false;
            csObj4.status = 'Open';
            insert csObj4;
            
            List<Core_IPS_Product_Issue_Category__c> CategoriesList = Core_RestAPI_TestUtilities.getListOfCoreProdIssCategory(10);
            for(Integer i=0;i<CategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objAPI = CategoriesList[i]; 
                objAPI.Core_Type__c = 'Case Category';
                objAPI.Core_Supported_Product__c = sp.id;
                objAPI.OwnerId=adminuser.id; 
            }
            Insert CategoriesList;
            
            List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList = Core_RestAPI_TestUtilities.getListOfCoreProdIssCategory(10);
            for(Integer i=0;i<CategoriesandSubCategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objAPI = CategoriesandSubCategoriesList[i]; 
                objAPI.Core_Type__c = 'Case SubCategory';
                objAPI.Core_Product_Issue_Category__c= CategoriesList[0].id;
                objAPI.Core_Issue_Sub_Category_Name__c = CategoriesList[0].Name;
                objAPI.Core_Supported_Product__c=sp.id;
                
            }
            insert CategoriesandSubCategoriesList;//inserting records for Admin user and community user
           
            List<Core_IPS_Product_Issue_Category__c> CategoriesList1 = Core_RestAPI_TestUtilities.getListOfCoreProdIssCategory(10);
            for(Integer i=0;i<CategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objAPI = CategoriesList1[i]; 
                objAPI.Core_Type__c = 'Case Category';
                objAPI.OwnerId=adminuser.id; 
            }
            
            Insert CategoriesList1;
            
            List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList1 = Core_RestAPI_TestUtilities.getListOfCoreProdIssCategory(10);
            for(Integer i=0;i<CategoriesandSubCategoriesList.size()/2;i++){
                Core_IPS_Product_Issue_Category__c objAPI = CategoriesandSubCategoriesList1[i]; 
                objAPI.Core_Type__c = 'Case SubCategory';
                objAPI.Core_Product_Issue_Category__c= CategoriesList[0].id;
                objAPI.Core_Issue_Sub_Category_Name__c = CategoriesList[0].Name;
                
            }
            insert CategoriesandSubCategoriesList1;
// =======================================================================================================================
            // text question
            Core_IPS_Question__c quest1 = Core_RestAPI_TestUtilities.getCoreQuestion();
            quest1.Core_IPS_Product_Organization__c=org.id;
            insert quest1;
            
            // text Area question
            Core_IPS_Question__c quest2 = Core_RestAPI_TestUtilities.getCoreQuestion();
            quest2.Core_IPS_Datatype__c = 'Text Area';
            quest2.Core_IPS_Product_Organization__c=org.id;
            insert quest2;
            
            // picklist question
            Core_IPS_Question__c quest3 = Core_RestAPI_TestUtilities.getCoreQuestion();
            quest3.Core_IPS_Datatype__c = 'Picklist';
            quest3.Core_IPS_Product_Organization__c=org.id;
            insert quest3;
            
            // multi- picklist question
            Core_IPS_Question__c quest4 = Core_RestAPI_TestUtilities.getCoreQuestion();
            quest4.Core_IPS_Datatype__c = 'Multiselect Picklist';
            quest4.Core_IPS_Product_Organization__c=org.id;
            insert quest4;
            
            // answers for picklist question           
            Core_IPS_Answer__c picklist1Ans1= Core_RestAPI_TestUtilities.getCoreAnswer();
            picklist1Ans1.Core_IPS_Question__c = quest3.id ;
            insert picklist1Ans1;
            
            Core_IPS_Answer__c picklist1Ans2= Core_RestAPI_TestUtilities.getCoreAnswer();
            picklist1Ans2.Core_IPS_Question__c = quest3.id ;
            insert picklist1Ans2;
            
            Core_IPS_Answer__c picklist1Ans3= Core_RestAPI_TestUtilities.getCoreAnswer();
            picklist1Ans3.Core_IPS_Question__c = quest3.id ;
            insert picklist1Ans3;
            
            // answers for multiselect  picklist question  
            
             Core_IPS_Answer__c multPicklist1Ans1= Core_RestAPI_TestUtilities.getCoreAnswer();
            multPicklist1Ans1.Core_IPS_Question__c = quest4.id ;
            insert multPicklist1Ans1;
            
            Core_IPS_Answer__c multPicklist1Ans2= Core_RestAPI_TestUtilities.getCoreAnswer();
            multPicklist1Ans2.Core_IPS_Question__c = quest4.id ;
            insert multPicklist1Ans2;
            
            Core_IPS_Answer__c multPicklist1Ans3= Core_RestAPI_TestUtilities.getCoreAnswer();
            multPicklist1Ans3.Core_IPS_Question__c = quest4.id ;
            insert multPicklist1Ans3;
            
      
            // creating env operational for each type of question 

            Core_IPS_Assigned_Environment_Variables__c ObjEnvVar1= Core_RestAPI_TestUtilities.getEnvironmentalDetailsOperational();
            ObjEnvVar1.Core_Product_Issue_Sub_Category__c= CategoriesandSubCategoriesList[0].id;
            ObjEnvVar1.Core_IPS_Question__c =quest1.id;
            ObjEnvVar1.Core_Supported_Product__c=sp.id;
            insert ObjEnvVar1;//inserting record for admin user
            
            Core_IPS_Assigned_Environment_Variables__c ObjEnvVar2= Core_RestAPI_TestUtilities.getEnvironmentalDetailsOperational();
            ObjEnvVar2.Core_Product_Issue_Sub_Category__c= CategoriesandSubCategoriesList[0].id;
            ObjEnvVar2.Core_IPS_Question__c =quest2.id;
            ObjEnvVar2.Core_Supported_Product__c=sp.id;
            insert ObjEnvVar2;
            
            Core_IPS_Assigned_Environment_Variables__c ObjEnvVar3= Core_RestAPI_TestUtilities.getEnvironmentalDetailsOperational();
            ObjEnvVar3.Core_Product_Issue_Sub_Category__c= CategoriesandSubCategoriesList[0].id;
            ObjEnvVar3.Core_IPS_Question__c =quest3.id;
            ObjEnvVar3.Core_Supported_Product__c=sp.id;
            insert ObjEnvVar3;
            
            Core_IPS_Assigned_Environment_Variables__c ObjEnvVar4= Core_RestAPI_TestUtilities.getEnvironmentalDetailsOperational();
            ObjEnvVar4.Core_Product_Issue_Sub_Category__c= CategoriesandSubCategoriesList[0].id;
            ObjEnvVar4.Core_IPS_Question__c =quest4.id;
            ObjEnvVar4.Core_Supported_Product__c=sp.id;
            insert ObjEnvVar4;
    
            List<Core_IPS_Assigned_Environment_Variables__c> lstAssEnvVar=[SELECT Core_IPS_Question__r.name, Core_IPS_Question__r.id, Core_IPS_Question__r.Core_IPS_Parent_Question__r.name,Core_IPS_Question__r.Core_IPS_Datatype__c, Core_IPS_Question__r.Core_IPS_Question__c,  Core_Required__c
                         FROM Core_IPS_Assigned_Environment_Variables__c 
                         WHERE Core_Agent_Only__c = false AND Core_Status__c='Active' ];
    
            
            System.debug('lstAssEnvVar  ==>> '+lstAssEnvVar);
            System.debug('lstAssEnvVar  ==>> '+lstAssEnvVar[0].Core_IPS_Question__r.Core_IPS_Question__c);
            System.debug('lstAssEnvVar  ==>> '+lstAssEnvVar[0].Core_IPS_Question__r.name);
            
            
            
            List<Core_IPS_Answer__c> lstAns = [select id from Core_IPS_Answer__c]; 
            List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper> lstansWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper>();
            Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
            ansWrpr1.answer= 'answer 1';
           ansWrpr1.answerId=lstAns[0].id ;
            lstansWrpr.add(ansWrpr1);
            
            List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper> lstquestWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper>();
            
            Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper questWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper();
            questWrpr1.envDetQuestion ='env detail question 1 ';
            List<Core_IPS_Assigned_Environment_Variables__c> lstenvDetQuestionId = [select Id,name,Core_IPS_Question__r.Name from Core_IPS_Assigned_Environment_Variables__c Limit 1];
            questWrpr1.envDetQuestionId =lstenvDetQuestionId[0].Core_IPS_Question__r.Name;
            questWrpr1.answers = lstansWrpr;     
            lstquestWrpr.add(questWrpr1);         
            objWrapper.caseSeverity='Low';
            objWrapper.SeverityReason='High';
            objWrapper.endCustomer='Popcornapps test';
            objWrapper.customerReferenceId='1234567890';
            objWrapper.caseType='Question';
            objWrapper.subject ='Case create api testing 1234567890';
            objWrapper.caseDescription ='Case create api testing new';
            objWrapper.status ='Closed';
            List<Core_IPS_Product_Issue_Category__c> CategoriesList2=[select id,name from Core_IPS_Product_Issue_Category__c where Core_Type__c ='Case Category'];
            objWrapper.caseCategoryId =CategoriesList2[0].Name;
            List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList2=[select id, name,Core_Product_Issue_Category__c from Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case SubCategory' AND Core_Product_Issue_Category__r.id=: CategoriesList2[0].Id];
            objWrapper.subCategoryId =CategoriesandSubCategoriesList2[0].Name;
            objWrapper.envDetails= lstquestWrpr;
            
            case cs1 = [select id,CaseNumber from case limit 1];
            System.debug('CaseNumber--->'+ cs1);
            System.debug('CaseNumber--->'+ cs1.CaseNumber);
            String csNumber = cs1.CaseNumber;
            
            RestRequest  request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
            request.httpMethod = 'PATCH';
            RestContext.request = request; 
            request.resourcePath ='/services/apexrest/v1.0/cases/'+csNumber; 
            request.requestURI='/v1.0/cases/'+csNumber;
            Core_RestAPI_CaseDetailV1.doPatch(objWrapper);
            Core_RestAPI_Case_UpdateV1_Handler handler = new Core_RestAPI_Case_UpdateV1_Handler('UpdateCase', System.now(), objWrapper);
            Core_RestAPI_Response response= handler.updateCase();
            
            handler.updateCaseDetails();
            handler.isProductOrProjectValid();
            handler.doAllEnvDetailValidations();
            handler.updateEnvironmentDetails();
            
            Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper questWrpr2 = new Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper();
            questWrpr2.envDetQuestion ='env detail question 1 ';
            List<Core_IPS_Assigned_Environment_Variables__c> lstenvDetQuestionId1 = [select id,name,Core_IPS_Question__r.Name from Core_IPS_Assigned_Environment_Variables__c Limit 1];
            questWrpr2.envDetQuestionId =lstenvDetQuestionId1[0].Core_IPS_Question__r.Name;
            questWrpr2.answers = lstansWrpr;     
            lstquestWrpr.add(questWrpr2);         
            objWrapper.caseSeverity='Low';
            objWrapper.SeverityReason='High';
            objWrapper.endCustomer='Popcornapps test';
            objWrapper.customerReferenceId='1234567890';
            objWrapper.caseType='Question';
            objWrapper.subject ='Case create api testing 1234567890';
            objWrapper.caseDescription ='Case create api testing new';
            handler.isProductOrProjectValid();
            handler.doAllEnvDetailValidations();
            handler.validateCaseCategoryFields();
            handler.validateEnvDetailMatch();
        }
        Test.stopTest();
    } 
    
    
    @isTest public static void test_validateCaseInputs_Positive(){
        List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper> lstansWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper>();
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr1.answer= 'answer 1';
        lstansWrpr.add(ansWrpr1);
        List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper> lstquestWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper>();
        
        Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper questWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper();
        questWrpr1.envDetQuestion ='env detail question 1 ';
        List<Core_IPS_Assigned_Environment_Variables__c> lstenvDetQuestionId = [select id,name,Core_IPS_Question__r.Name from Core_IPS_Assigned_Environment_Variables__c Limit 1];
        questWrpr1.envDetQuestionId =lstenvDetQuestionId[0].Core_IPS_Question__r.Name;
        questWrpr1.answers = lstansWrpr;     
        lstquestWrpr.add(questWrpr1);         
        objWrapper.caseSeverity='Low';
        objWrapper.SeverityReason='High';
        List<Asset> AssetList =[Select Id, core_supported_product__c, core_supported_product__r.Name, product2Id, Status, Core_IPS_Project__c, Core_IPS_Project__r.Name, Core_IPS_Project__r.Core_Status__c 
                                FROM Asset ];
        objWrapper.endCustomer='Popcornapps test';
        objWrapper.customerReferenceId='1234567890';
        objWrapper.caseType='Question';
        objWrapper.subject ='Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890';
        objWrapper.caseDescription ='Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibuimperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor. Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut non enim eleifend felis pretium feugiat. Vivamus quis mi. Phasellus a est. Phasellus magna. In hac habitasse platea dictumst. Curabitur at lacus ac velit ornare lobortis. Curabitur a felis in nunc fringilla tristique. Morbi mattis ullamcorper velit. Phasellus gravida semper nisi. Nullam vel sem. Pellentesque libero tortor, tincidunt et, tincidunt eget, semper nec, quam. Sed hendrerit. Morbi ac felis. Nunc egestas, augue at pellentesque laoreet, felis eros vehicula leo, at malesuada velit leo quis pede. Donec interdum, metus et hendrerit aliquet, dolor diam sagittis ligula, eget egestas libero turpis vel mi. Nunc nulla. Fusce risus nisl, viverra et, tempor et, pretium in, sapien. Donec venenatis vulputate lorem. Morbi nec metus. Phasellus blandit leo ut odio. Maecenas ullamcorper, dui et placerat feugiat, eros pede varius nisi, condimentum viverra felis nunc et lorem. Sed magna purus, fermentum eu, tincidunt eu, varius ut, felis. In auctor lobortis lacus. Quisque libero metus, condimentum nec, tempor a, commodo mollis, magna. Vestibulum ullamcorper mauris atimperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor. Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut non enim eleifend felis pretium feugiat. Vivamus quis mi. Phasellus a est. Phasellus magna. In hac habitasse platea dictumst. Curabitur at lacus ac velit ornare lobortis. Curabitur a felis in nunc fringilla tristique. Morbi mattis ullamcorper velit. Phasellus gravida semper nisi. Nullam vel sem. Pellentesque libero tortor, tincidunt et, tincidunt eget, semper nec, quam. Sed hendrerit. Morbi ac felis. Nunc egestas, augue at pellentesque laoreet, felis eros vehicula leo, at malesuada velit leo quis pede. Donec interdum, metus et hendrerit aliquet, dolor diam sagittis ligula, eget egestas libero turpis vel mi. Nunc nulla. Fusce risus nisl, viverra et, tempor et, pretium in, sapien. Donec venenatis vulputate lorem. Morbi nec metus. Phasellus blandit leo ut odio. Maecenas ullamcorper, dui et placerat feugiat, eros pede varius nisi, condimentum viverra felis nunc et lorem. Sed magna purus, fermentum eu, tincidunt eu, varius ut, felis. In auctor lobortis lacus. Quisque libero metus, condimentum nec, tempor a, commodo mollis, magna. Vestibulum ullamcorper mauris atimperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor. Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut non enim eleifend felis pretium feugiat. Vivamus quis mi. Phasellus a est. Phasellus magna. In hac habitasse platea dictumst. Curabitur at lacus ac velit ornare lobortis. Curabitur a felis in nunc fringilla tristique. Morbi mattis ullamcorper velit. Phasellus gravida semper nisi. Nullam vel sem. Pellentesque libero tortor, tincidunt et, tincidunt eget, semper nec, quam. Sed hendrerit. Morbi ac felis. Nunc egestas, augue at pellentesque laoreet, felis eros vehicula leo, at malesuada velit leo quis pede. Donec interdum, metus et hendrerit aliquet, dolor diam sagittis ligula, eget egestas libero turpis vel mi. Nunc nulla. Fusce risus nisl, viverra et, tempor et, pretium in, sapien. Donec venenatis vulputate lorem. Morbi nec metus. Phasellus blandit leo ut odio. Maecenas ullamcorper, dui et placerat feugiat, eros pede varius nisi, condimentum viverra felis nunc et lorem. Sed magna purus, fermentum eu, tincidunt eu, varius ut, felis. In auctor lobortis lacus. Quisque libero metus, condimentum nec, tempor a, commodo mollis, magna. Vestibulum ullamcorper mauris atimperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor. Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut non enim eleifend felis pretium feugiat. Vivamus quis mi. Phasellus a est. Phasellus magna. In hac habitasse platea dictumst. Curabitur at lacus ac velit ornare lobortis. Curabitur a felis in nunc fringillimperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor. Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut non enim eleifend felis pretium feugiat. Vivamus quis mi. Phasellus a est. Phasellus magna. In hac habitasse platea dictumst. Curabitur at lacus ac velit ornare lobortis. Curabitur a felis in nunc fringilla tristique. Morbi mattis ullamcorper velit. Phasellus gravida semper nisi. Nullam vel sem. Pellentesque libero tortor, tincidunt et, tincidunt eget, semper nec, quam. Sed hendrerit. Morbi ac felis. Nunc egestas, augue at pellentesque laoreet, felis eros vehicula leo, at malesuada velit leo quis pede. Donec interdum, metus et hendrerit aliquet, dolor diam sagittis ligula, eget egestas libero turpis vel mi. Nunc nulla. Fusce risus nisl, viverra et, tempor et, pretium in, sapien. Donec venenatis vulputate lorem. Morbi nec metus. Phasellus blandit leo ut odio. Maecenas ullamcorper, dui et placerat feugiat, eros pede varius nisi, condimentum viverra felis nunc et lorem. Sed magna purus, fermentum eu, tincidunt eu, varius ut, felis. In auctor lobortis lacus. Quisque libero metus, condimentum nec, tempor a, commodo mollis, magna. Vestibulum ullamcorper mauris atimperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor. Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut non enim eleifend felis pretium feugiat. Vivamus quis mi. Phasellus a est. Phasellus magna. In hac habitasse platea dictumst. Curabitur at lacus ac velit ornare lobortis. Curabitur a felis in nunc fringilla tristique. Morbi mattis ullamcorper velit. Phasellus gravida semper nisi. Nullam vel sem. Pellentesque libero tortor, tincidunt et, tincidunt eget, semper nec, quam. Sed hendrerit. Morbi ac felis. Nunc egestas, augue at pellentesque laoreet, felis eros vehicula leo, at malesuada velit leo quis pede. Donec interdum, metus et hendrerit aliquet, dolor diam sagittis ligula, eget egestas libero turpis vel mi. Nunc nulla. Fusce risus nisl, viverra et, tempor et, pretium in, sapien. Donec venenatis vulputate lorem. Morbi nec metus. Phasellus blandit leo ut odio. Maecenas ullamcorper, dui et placerat feugiat, eros pede varius nisi, condimentum viverra felis nunc et lorem. Sed magna purus, fermentum eu, tincidunt eu, varius ut, felis. In auctor lobortis lacus. Quisque libero metus, condimentum nec, tempor a, commodo mollis, magna. Vestibulum ullamcorper mauris ata tristique. Morbi mattis ullamcorper velit. Phasellus gravida semper nisi. Nullam vel sem. Pellentesque libero tortor, tincidunt et, tincidunt eget, semper nec, quam. Sed hendrerit. Morbi ac felis. Nunc egestas, augue at pellentesque laoreet, felis eros vehicula leo, at malesuada velit leo quis pede. Donec interdum, metus et hendrerit aliquet, dolor diam sagittis ligula, eget egestas libero turpis vel mi. Nunc nulla. Fusce risus nisl, viverra et, tempor et, pretium in, sapien. Donec venenatis vulputate lorem. Morbi nec metus. Phasellus blandit leo ut odio. Maecenas ullamcorper, dui et placerat feugiat, eros pede varius nisi, condimentum viverra felis nunc et lorem. Sed magna purus, fermentum eu, tincidunt eu, varius ut, felis. In auctor lobortis lacus. Quisque libero metus, condimentum nec, tempor a, commodo mollis, magna. Vestibulum ullamcorper mauris atlum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor. Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut non enim eleifend felis pretium feugiat. Vivamus quis mi. Phasellus a est. Phasellus magna. In hac habitasse platea dictumst. Curabitur at lacus ac velit ornare lobortis. Curabitur a felis in nunc fringilla tristique. Morbi mattis ullamcorper velit. Phasellus gravida semper nisi. Nullam vel sem. Pellentesque libero tortor, tincidunt et, tincidunt eget, semper nec, quam. Sed hendrerit. Morbi ac felis. Nunc egestas, augue at pellentesque laoreet, felis eros vehicula leo, at malesuada velit leo quis pede. Donec interdum, metus et hendrerit aliquet, dolor diam sagittis ligula, eget egestas libero turpis vel mi. Nunc nulla. Fusce risus nisl, viverra et, tempor et, pretium in, sapien. Donec venenatis vulputate lorem. Morbi nec metus. Phasellus blandit leo ut odio. Maecenas ullamcorper, dui et placerat feugiat, eros pede varius nisi, condimentum viverra felis nunc et lorem. Sed magna purus, fermentum eu, tincidunt eu, varius ut, felis. In auctor lobortis lacus. Quisque libero metus, condimentum nec, tempor a, commodo mollis, magna. Vestibulum ullamcorper mauris at';
            List<Core_IPS_Product_Issue_Category__c> CategoriesList=[select id,name from Core_IPS_Product_Issue_Category__c];
        objWrapper.caseCategoryId =CategoriesList[0].name;
        List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList=[select id, name from Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case SubCategory'];
        objWrapper.subCategoryId =CategoriesandSubCategoriesList[0].name;
        objWrapper.envDetails= lstquestWrpr;
        
        case cs1 = [select id,CaseNumber from case limit 1];
        String csNumber = cs1.CaseNumber;
        
        RestRequest  request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'PATCH';
        RestContext.request = request; 
        request.resourcePath ='/services/apexrest/v1.0/cases/'+csNumber; 
        request.requestURI='/v1.0/cases/'+csNumber;
        Core_RestAPI_CaseDetailV1.doPatch(objWrapper);
        
        Core_RestAPI_Case_UpdateV1_Handler handler1 = new Core_RestAPI_Case_UpdateV1_Handler('CreateCase', System.now(), objWrapper);
        
        // to cover condition-- subject length is more than 255 && caseDescription length is more than 32000
        handler1.validateCaseInputs();
        System.assertEquals(handler1.validateCaseInputs(),false);
        
        // to cover condition-- customerReferenceId length is more than 40
        objWrapper.customerReferenceId='12345678901234567890123456789012345678901';
        objWrapper.subject ='Case create api testing 1234567890';
        handler1.validateCaseInputs();
        System.assertEquals(handler1.validateCaseInputs(),false);
        
        // to cover condition-- endCustomer length is more than 120
        objWrapper.endCustomer='Popcornapps testPopcornapps testPopcornapps testPopcornapps testPopcornapps testPopcornapps testPopcornapps testPopcornapps testPopcornapps testPopcornapps testPopcornapps testPopcornapps testPopcornapps test';
        objWrapper.caseDescription ='Lorem ipsum dolor sit amet, consectetuer adipiscing elit.';
        handler1.validateCaseInputs();
        System.assertEquals(handler1.validateCaseInputs(),false);
        
        // to cover condition-- SeverityReason length is more than 255
        objWrapper.endCustomer='Popcornapps test';
        objWrapper.SeverityReason='HighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHighHigh';
        handler1.validateCaseInputs();
        System.assertEquals(handler1.validateCaseInputs(),false);
        
        objWrapper.SeverityReason='High';
        handler1.validateCaseInputs();
        System.assertEquals(handler1.validateCaseInputs(),false);
        
        // to cover condition-- String.isNotBlank(requestWrpr.caseType)
        objWrapper.caseType='testing';
        handler1.validateCaseInputs();
        System.assertEquals(handler1.validateCaseInputs(),false);
        
        // to cover condition--String.isNotBlank(requestWrpr.caseSeverity) && !picklistSeverity.contains(requestWrpr.caseSeverity)
        objWrapper.caseType='Question';
        objWrapper.caseSeverity='test';
        handler1.validateCaseInputs();
        
        // to cover isProductOrProjectValid() else if block                 
        AssetList[0].Status = 'abc';
        update AssetList[0];
        handler1.doAllUpdateCaseValidations();
        handler1.isProductOrProjectValid();
        System.assertEquals(handler1.validateCaseInputs(),false);
        
        // to cover isProductOrProjectValid() else if block for core_supported_product__r.Core_EOIS__c and assetObj.Core_IPS_Project__c  condition
        AssetList[0].Status = 'new';
        AssetList[0].Core_IPS_Project__r.Core_Status__c  = 'Active';
        AssetList[0].core_supported_product__r.Core_EOIS__c = true;
        update AssetList[0];
        handler1.isProductOrProjectValid();
        
        List<Core_IPS_Supported_Product__c> sp= [select id,Core_EOIS__c from Core_IPS_Supported_Product__c ];
        AssetList[0].Core_Supported_Product__c = sp[1].id;
        update AssetList[0];
        handler1.isProductOrProjectValid();
        handler1.validateCaseCategoryFields();
        
        
        handler1.validateEnvDetailRequiredFields();
    }
    @isTest public static void test_updateCase_Negative(){
        List<Core_IPS_Assigned_Environment_Variables__c> lstAssEnvVar=[Select Name,Core_Product_Issue_Sub_Category__r.Name ,Core_Product_Issue_Sub_Category__r.id ,Core_Environment_Variable__r.Name,Core_Required__c ,Core_Environment_Variable__r.Core_Datatype__c, Core_Environment_Variable__r.Core_Answers__c from Core_IPS_Assigned_Environment_Variables__c where Core_Agent_Only__c= false ];
        
        List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper> lstansWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper>();
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr1.answer= 'answer 1';
        lstansWrpr.add(ansWrpr1);
        
        List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper> lstquestWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper>();
        
        Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper questWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper();
        questWrpr1.envDetQuestion ='env detail question 1 ';
        List<Core_IPS_Assigned_Environment_Variables__c> lstenvDetQuestionId = [select id,name,Core_IPS_Question__r.Name from Core_IPS_Assigned_Environment_Variables__c Limit 1];
        questWrpr1.envDetQuestionId =lstenvDetQuestionId[0].Core_IPS_Question__r.Name;
        questWrpr1.answers = lstansWrpr;     
        lstquestWrpr.add(questWrpr1);         
        objWrapper.caseSeverity='Low';
        objWrapper.SeverityReason='High';
        objWrapper.endCustomer='Popcornapps test';
        objWrapper.customerReferenceId='1234567890';
        objWrapper.caseType='Question';
        objWrapper.subject ='Case create api testing 1234567890';
        objWrapper.caseDescription ='Case create api testing new';
        List<Core_IPS_Product_Issue_Category__c> CategoriesList2=[select id,name from Core_IPS_Product_Issue_Category__c where Core_Type__c ='Case Category'];
        objWrapper.caseCategoryId =CategoriesList2[0].Name;
        
        List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList2=[select id, name,Core_Product_Issue_Category__c from Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case SubCategory' AND Core_Product_Issue_Category__r.id=: CategoriesList2[0].Id];
        objWrapper.subCategoryId =CategoriesandSubCategoriesList2[0].Name;
        objWrapper.envDetails= lstquestWrpr;
        
        case cs1 = [select id,CaseNumber from case limit 1];
        String csNumber = cs1.CaseNumber;
        
        RestRequest  request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'PATCH';
        RestContext.request = request; 
        csNumber ='abc';
        request.resourcePath ='/services/apexrest/v1.0/cases/'+csNumber; 
        request.requestURI='/v1.0/cases/'+csNumber;
        Core_RestAPI_CaseDetailV1.doPatch(objWrapper);
        Core_RestAPI_Case_UpdateV1_Handler handler = new Core_RestAPI_Case_UpdateV1_Handler('CreateCase', System.now(), objWrapper);
        Core_RestAPI_Response response= handler.updateCase();
        handler.doAllUpdateCaseValidations();
    }
    
    @isTest public static void test_validateCaseRequiredFields_Positive(){
        List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper> lstansWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper>();
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr1.answer= 'answer 1';
        lstansWrpr.add(ansWrpr1);
        List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper> lstquestWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper>();
        
        Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper questWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper();
        questWrpr1.envDetQuestion ='env detail question 1 ';
        List<Core_IPS_Assigned_Environment_Variables__c> lstenvDetQuestionId = [select id,name,Core_IPS_Question__r.Name from Core_IPS_Assigned_Environment_Variables__c Limit 1];
        questWrpr1.envDetQuestionId =lstenvDetQuestionId[0].Core_IPS_Question__r.Name;
        questWrpr1.answers = lstansWrpr;     
        lstquestWrpr.add(questWrpr1);         
        objWrapper.caseSeverity='Low';
        objWrapper.SeverityReason='High';
        List<Asset> AssetList =[select id from Asset ];
        objWrapper.endCustomer='Popcornapps test';
        objWrapper.customerReferenceId='1234567890';
        objWrapper.caseType='Question';
        objWrapper.subject ='Case create api testing 1234567890';
        objWrapper.caseDescription ='';
        List<Core_IPS_Product_Issue_Category__c> CategoriesList=[select id,name from Core_IPS_Product_Issue_Category__c where Core_Type__c ='Case Category'];
        Id str= CategoriesList[0].id;
        objWrapper.caseCategoryId =CategoriesList[0].name;
        List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList = [select id,name from Core_IPS_Product_Issue_Category__c where Core_Product_Issue_Category__c =: str];
        
        objWrapper.subCategoryId =CategoriesandSubCategoriesList[0].name;
        objWrapper.envDetails= lstquestWrpr;
        
        case cs1 = [select id,CaseNumber from case limit 1];
        String csNumber = cs1.CaseNumber;
        
        RestRequest  request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'PATCH';
        RestContext.request = request; 
        request.resourcePath ='/services/apexrest/v1.0/cases/'+csNumber; 
        request.requestURI='/v1.0/cases/'+csNumber;
        Core_RestAPI_CaseDetailV1.doPatch(objWrapper);
        
        Core_RestAPI_Case_UpdateV1_Handler handler1 = new Core_RestAPI_Case_UpdateV1_Handler('CreateCase', System.now(), objWrapper);
        
        //  condition for --String.isBlank(requestWrpr.caseDescription)
        handler1.validateCaseRequiredFields();
        
        //  condition for --String.isBlank(requestWrpr.caseType)
        objWrapper.caseDescription ='Case create api testing new';
        objWrapper.caseType='';
        handler1.validateCaseRequiredFields();
        System.assertEquals(handler1.validateCaseRequiredFields(),false);
        
        //  condition for --String.isBlank(requestWrpr.caseSeverity)
        objWrapper.caseType='Question';
        objWrapper.caseSeverity='';
        handler1.validateCaseRequiredFields();
        System.assertEquals(handler1.validateCaseRequiredFields(),false);
        
        //  condition for --String.isBlank(requestWrpr.contactId)
        objWrapper.caseSeverity='Low';
        objWrapper.subject='';
        handler1.validateCaseRequiredFields();
        
        //  condition for --String.isBlank(requestWrpr.SeverityReason)
        objWrapper.subject ='Case create api testing 1234567890';
        objWrapper.SeverityReason='';
        objWrapper.caseSeverity='Critical';
        handler1.validateCaseRequiredFields();
        System.assertEquals(handler1.validateCaseRequiredFields(),false);
        
        List<Core_IPS_Supported_Product__c> sp=[select id from Core_IPS_Supported_Product__c];
        AssetList[0].core_supported_product__c = sp[0].id;
        update AssetList[0];
        handler1.doAllUpdateCaseValidations();
        handler1.isProductOrProjectValid();
        handler1.validateCaseCategoryFields();
        
        // for invalid subCategoryId && caseCategoryId
        objWrapper.subCategoryId ='IC-00000000';
        handler1.validateCaseCategoryFields();
        objWrapper.caseCategoryId ='IC-00000000';
        handler1.validateCaseCategoryFields();
        System.assertEquals(handler1.validateCaseCategoryFields(),false);
        
        // for blank subCategoryId && caseCategoryId
        objWrapper.subCategoryId ='';
        handler1.validateCaseCategoryFields();
        objWrapper.caseCategoryId ='';
        handler1.validateCaseCategoryFields();
        System.assertEquals(handler1.validateCaseCategoryFields(),false);
        
        List<Core_IPS_Assigned_Environment_Variables__c>  lstSubCatEnvDetails =[SELECT Name,Core_Environment_Variable__r.Name,Core_Environment_Variable__r.Core_Datatype__c, Core_Required__c, Core_Environment_Variable__r.Core_Answers__c 
                                                                                FROM Core_IPS_Assigned_Environment_Variables__c where  Core_Supported_Product__c =: AssetList[0].core_supported_product__c];
        for(Core_IPS_Assigned_Environment_Variables__c AssEnvVar : lstSubCatEnvDetails){
            AssEnvVar.Core_Required__c = false;
        }
        update  lstSubCatEnvDetails;    
        handler1.isProductOrProjectValid();
        handler1.doAllEnvDetailValidations();
    }
    @isTest public static void test_isAnsValidate_Positive(){
        
        List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper> lstansWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper>();
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr1.answer= 'answer 1';
        lstansWrpr.add(ansWrpr1);
        
        List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper> lstquestWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper>();
        
        Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper questWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper();
        questWrpr1.envDetQuestion ='env detail question 1 ';
        List<Core_IPS_Assigned_Environment_Variables__c> lstenvDetQuestionId = [select id, name,Core_IPS_Question__r.Name from Core_IPS_Assigned_Environment_Variables__c Limit 1];
        questWrpr1.envDetQuestionId =lstenvDetQuestionId[0].Core_IPS_Question__r.Name;
        questWrpr1.answers = lstansWrpr;     
        lstquestWrpr.add(questWrpr1);         
        objWrapper.caseSeverity='Low';
        objWrapper.SeverityReason='High';
        List<contact> con = [select id from contact limit 1];
        objWrapper.endCustomer='Popcornapps test';
        objWrapper.customerReferenceId='1234567890';
        objWrapper.caseType='Question';
        objWrapper.subject ='Case create api testing 1234567890';
        objWrapper.caseDescription ='Case create api testing new';
        List<Core_IPS_Product_Issue_Category__c> CategoriesList1=[select id,name from Core_IPS_Product_Issue_Category__c where Core_Type__c ='Case Category'];
        objWrapper.caseCategoryId =CategoriesList1[0].Name;
        
        List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList1=[select id, name,Core_Product_Issue_Category__c from Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case SubCategory' AND Core_Product_Issue_Category__r.id=: CategoriesList1[0].Id];
        objWrapper.subCategoryId =CategoriesandSubCategoriesList1[0].Name;
        objWrapper.envDetails= lstquestWrpr;
        
        List<Core_IPS_Assigned_Environment_Variables__c> lstAssEnvVar=[Select Core_IPS_Question__r.name,Core_IPS_Question__r.id,Core_IPS_Question__r.Core_IPS_Parent_Question__r.name,Core_IPS_Question__r.Core_IPS_Datatype__c,Core_IPS_Question__r.Core_IPS_Question__c,Name,Core_Product_Issue_Sub_Category__r.Name ,Core_Product_Issue_Sub_Category__r.id ,Core_Environment_Variable__r.Name,Core_Required__c ,Core_Environment_Variable__r.Core_Datatype__c, Core_Environment_Variable__r.Core_Answers__c from Core_IPS_Assigned_Environment_Variables__c where Core_Agent_Only__c= false ];
        Core_RestAPI_Case_UpdateV1_Handler handler1 = new Core_RestAPI_Case_UpdateV1_Handler('CreateCase', System.now(), objWrapper);
        handler1.isAnsValidate(questWrpr1 ,lstAssEnvVar[0],envAnsAndAnsId);
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr2 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr2.answer= 'answer 2';
        lstansWrpr.add(ansWrpr2);
        handler1.isAnsValidate(questWrpr1 ,lstAssEnvVar[0],envAnsAndAnsId);
        
        lstansWrpr.clear();
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr21 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr21.answer= 'answer 2 sting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Casting 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Ca';
        lstansWrpr.add(ansWrpr21);
        handler1.isAnsValidate(questWrpr1 ,lstAssEnvVar[0],envAnsAndAnsId);
        
        lstansWrpr.clear();
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr3 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr3.answer= 'answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answeanswer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2answer 2r 2answer 2answer 2answer 2answer 2answer 2';
        lstansWrpr.add(ansWrpr3);
        handler1.isAnsValidate(questWrpr1 ,lstAssEnvVar[1],envAnsAndAnsId);
        
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr4 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr2.answer= 'answer 4';
        lstansWrpr.add(ansWrpr4);
        handler1.isAnsValidate(questWrpr1 ,lstAssEnvVar[1],envAnsAndAnsId);
        
        lstansWrpr.clear();
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr5 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr5.answer= 'Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create';
        lstansWrpr.add(ansWrpr5);
        handler1.isAnsValidate(questWrpr1 ,lstAssEnvVar[2],envAnsAndAnsId);
        
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr6 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr6.answer= 'answer 4';
        lstansWrpr.add(ansWrpr6);
        handler1.isAnsValidate(questWrpr1 ,lstAssEnvVar[2],envAnsAndAnsId);
        
        lstansWrpr.clear();
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr7 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr7.answer= 'Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case createCase create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create api testing 1234567890Case create';
        lstansWrpr.add(ansWrpr7);
        handler1.isAnsValidate(questWrpr1 ,lstAssEnvVar[3],envAnsAndAnsId);
        
        //handler1.isAnsValidate(questWrpr1 ,lstAssEnvVar[4],envAnsAndAnsId);
        
    } 
    @isTest public static void test_doAllCaseValidations_positive(){
        try{
            List<Core_IPS_Assigned_Environment_Variables__c> lstAssEnvVar=[Select Name,Core_Product_Issue_Sub_Category__r.Name ,Core_Product_Issue_Sub_Category__r.id ,Core_Environment_Variable__r.Name,Core_Required__c ,Core_Environment_Variable__r.Core_Datatype__c, Core_Environment_Variable__r.Core_Answers__c from Core_IPS_Assigned_Environment_Variables__c where Core_Agent_Only__c= false ];
            
            List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper> lstansWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper>();
            Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
            ansWrpr1.answer= 'answer 1';
            lstansWrpr.add(ansWrpr1);
            
            List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper> lstquestWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper>();
            
            Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper questWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper();
            questWrpr1.envDetQuestion ='env detail question 1 ';
            List<Core_IPS_Assigned_Environment_Variables__c> lstenvDetQuestionId = [select id,name,Core_IPS_Question__r.Name from Core_IPS_Assigned_Environment_Variables__c Limit 1];
            questWrpr1.envDetQuestionId =lstenvDetQuestionId[0].Core_IPS_Question__r.Name;
            questWrpr1.answers = lstansWrpr;     
            lstquestWrpr.add(questWrpr1);         
            objWrapper.caseSeverity='Low';
            objWrapper.SeverityReason='High';
            objWrapper.endCustomer='Popcornapps test';
            objWrapper.customerReferenceId='1234567890';
            objWrapper.caseType='Question';
            objWrapper.subject ='Case create api testing 1234567890';
            objWrapper.caseDescription ='Case create api testing new';
            List<Core_IPS_Product_Issue_Category__c> CategoriesList2=[select id,name from Core_IPS_Product_Issue_Category__c where Core_Type__c ='Case Category'];
            objWrapper.caseCategoryId =CategoriesList2[0].Name;
            
            List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList2=[select id, name,Core_Product_Issue_Category__c from Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case SubCategory' AND Core_Product_Issue_Category__r.id=: CategoriesList2[0].Id];
            objWrapper.subCategoryId =CategoriesandSubCategoriesList2[0].Name;
            objWrapper.envDetails= lstquestWrpr;
            
            case cs1 = [select id,CaseNumber from case limit 1];
            String csNumber = cs1.CaseNumber;
            
            RestRequest  request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
            request.httpMethod = 'PATCH';
            RestContext.request = request; 
            csNumber ='12345678';
            request.resourcePath ='/services/apexrest/v1.0/cases/'+csNumber; 
            request.requestURI='/v1.0/cases/'+csNumber;
            Core_RestAPI_CaseDetailV1.doPatch(objWrapper);
            Core_RestAPI_Case_UpdateV1_Handler handler = new Core_RestAPI_Case_UpdateV1_Handler('CreateCase', System.now(), objWrapper);
            Core_RestAPI_Response response= handler.updateCase();
            handler.isProductOrProjectValid();
            handler.doAllEnvDetailValidations();
            
        }catch(Exception e){
            system.debug('e ==>> '+e);
            
        } 
    }
    @isTest public static void test_isCaseCustomerVisible_positive(){
        List<Core_IPS_Assigned_Environment_Variables__c> lstAssEnvVar=[Select Name,Core_Product_Issue_Sub_Category__r.Name ,Core_Product_Issue_Sub_Category__r.id ,Core_Environment_Variable__r.Name,Core_Required__c ,Core_Environment_Variable__r.Core_Datatype__c, Core_Environment_Variable__r.Core_Answers__c from Core_IPS_Assigned_Environment_Variables__c where Core_Agent_Only__c= false ];
        
        List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper> lstansWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper>();
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr1.answer= 'answer 1';
        lstansWrpr.add(ansWrpr1);
        
        List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper> lstquestWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper>();
        
        Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper questWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper();
        questWrpr1.envDetQuestion ='env detail question 1 ';
        List<Core_IPS_Assigned_Environment_Variables__c> lstenvDetQuestionId = [select id,name,Core_IPS_Question__r.Name from Core_IPS_Assigned_Environment_Variables__c Limit 1];
        questWrpr1.envDetQuestionId =lstenvDetQuestionId[0].Core_IPS_Question__r.Name;
        questWrpr1.answers = lstansWrpr;     
        lstquestWrpr.add(questWrpr1);         
        objWrapper.caseSeverity='Low';
        objWrapper.SeverityReason='High';
        objWrapper.endCustomer='Popcornapps test';
        objWrapper.customerReferenceId='1234567890';
        objWrapper.caseType='Question';
        objWrapper.subject ='Case create api testing 1234567890';
        objWrapper.caseDescription ='Case create api testing new';
        List<Core_IPS_Product_Issue_Category__c> CategoriesList2=[select id,name from Core_IPS_Product_Issue_Category__c where Core_Type__c ='Case Category'];
        objWrapper.caseCategoryId =CategoriesList2[0].Name;
        
        List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList2=[select id, name,Core_Product_Issue_Category__c from Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case SubCategory' AND Core_Product_Issue_Category__r.id=: CategoriesList2[0].Id];
        objWrapper.subCategoryId =CategoriesandSubCategoriesList2[0].Name;
        objWrapper.envDetails= lstquestWrpr;
        
        List<case> cs1 = [select id,CaseNumber,Core_IPS_Customer_Visible__c from case ];
        String csNumber = cs1[1].CaseNumber;
        
        RestRequest  request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'PATCH';
        RestContext.request = request; 
        request.resourcePath ='/services/apexrest/v1.0/cases/'+csNumber; 
        request.requestURI='/v1.0/cases/'+csNumber;
        Core_RestAPI_CaseDetailV1.doPatch(objWrapper);
        Core_RestAPI_Case_UpdateV1_Handler handler = new Core_RestAPI_Case_UpdateV1_Handler('CreateCase', System.now(), objWrapper);
        Core_RestAPI_Response response= handler.updateCase();
        
        handler.isProductOrProjectValid();
        handler.doAllEnvDetailValidations();
        handler.isCaseStatusValid();
        
        handler.isProductOrProjectValid();
    }
    @isTest public static void test_doAllCaseValidations_negative(){
        List<Core_IPS_Assigned_Environment_Variables__c> lstAssEnvVar=[Select Name,Core_Product_Issue_Sub_Category__r.Name ,Core_Product_Issue_Sub_Category__r.id ,Core_Environment_Variable__r.Name,Core_Required__c ,Core_Environment_Variable__r.Core_Datatype__c, Core_Environment_Variable__r.Core_Answers__c from Core_IPS_Assigned_Environment_Variables__c where Core_Agent_Only__c= false ];
        
        List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper> lstansWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper>();
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr1.answer= 'answer 1';
        lstansWrpr.add(ansWrpr1);
        
        List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper> lstquestWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper>();
        
        Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper questWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper();
        questWrpr1.envDetQuestion ='env detail question 1 ';
        List<Core_IPS_Assigned_Environment_Variables__c> lstenvDetQuestionId = [select id,name,Core_IPS_Question__r.Name from Core_IPS_Assigned_Environment_Variables__c Limit 1];
        questWrpr1.envDetQuestionId =lstenvDetQuestionId[0].Core_IPS_Question__r.Name;
        questWrpr1.answers = lstansWrpr;     
        lstquestWrpr.add(questWrpr1);         
        objWrapper.caseSeverity='Low';
        objWrapper.SeverityReason='High';
        objWrapper.endCustomer='Popcornapps test';
        objWrapper.customerReferenceId='1234567890';
        objWrapper.caseType='Question';
        objWrapper.subject ='Case create api testing 1234567890';
        objWrapper.caseDescription ='Case create api testing new';
        List<Core_IPS_Product_Issue_Category__c> CategoriesList2=[select id,name from Core_IPS_Product_Issue_Category__c where Core_Type__c ='Case Category'];
        objWrapper.caseCategoryId =CategoriesList2[0].Name;
        
        List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList2=[select id, name,Core_Product_Issue_Category__c from Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case SubCategory' AND Core_Product_Issue_Category__r.id=: CategoriesList2[0].Id];
        objWrapper.subCategoryId =CategoriesandSubCategoriesList2[0].Name;
        objWrapper.envDetails= lstquestWrpr;
        
        case cs1 = [select id,CaseNumber from case limit 1];
        String csNumber = cs1.CaseNumber;
        
        RestRequest  request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'PATCH';
        RestContext.request = request; 
        request.resourcePath ='/services/apexrest/v1.0/cases/'+csNumber; 
        request.requestURI='/v1.0/cases/'+csNumber;
        Core_RestAPI_CaseDetailV1.doPatch(objWrapper);
        Core_RestAPI_Case_UpdateV1_Handler handler = new Core_RestAPI_Case_UpdateV1_Handler('CreateCase', System.now(), objWrapper);
        Core_RestAPI_Response response= handler.updateCase();
        
        handler.isProductOrProjectValid();
        handler.doAllEnvDetailValidations();
        handler.validateCaseCategoryFields();
        
        objWrapper.caseCategoryId='';
        handler.validateCaseCategoryFields();
        
        objWrapper.caseCategoryId=CategoriesList2[0].Name;
        objWrapper.subCategoryId ='';
        handler.validateCaseCategoryFields();
        
        objWrapper.subCategoryId =CategoriesandSubCategoriesList2[0].Name;
        objWrapper.caseCategoryId='IC-00121234';
        handler.validateCaseCategoryFields();
        
        objWrapper.caseCategoryId=CategoriesList2[0].Name;
        objWrapper.subCategoryId ='IC-00121234';
        handler.validateCaseCategoryFields();
   
        objWrapper.status='Closed';
        objWrapper.caseSeverity=null;
        objWrapper.SeverityReason=null;
        objWrapper.endCustomer=null;
        objWrapper.customerReferenceId=null;
        objWrapper.caseType=null;
        objWrapper.subject =null;
        objWrapper.caseDescription =null;
        objWrapper.caseCategoryId =null;
        objWrapper.subCategoryId =null;
        objWrapper.envDetails=null;
        handler.doAllCloseCaseValidations();
        
    }
    @isTest public static void test_isCaseCustomerVisible_negative(){
        
        List<Core_IPS_Assigned_Environment_Variables__c> lstAssEnvVar=[Select Name,Core_Product_Issue_Sub_Category__r.Name ,Core_Product_Issue_Sub_Category__r.id ,Core_Environment_Variable__r.Name,Core_Required__c ,Core_Environment_Variable__r.Core_Datatype__c, Core_Environment_Variable__r.Core_Answers__c from Core_IPS_Assigned_Environment_Variables__c where Core_Agent_Only__c= false ];
        
        List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper> lstansWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper>();
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr1.answer= 'answer 1';
        lstansWrpr.add(ansWrpr1);
        
        List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper> lstquestWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper>();
        
        Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper questWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper();
        questWrpr1.envDetQuestion ='env detail question 1 ';
        List<Core_IPS_Assigned_Environment_Variables__c> lstenvDetQuestionId = [select id,name,Core_IPS_Question__r.Name from Core_IPS_Assigned_Environment_Variables__c Limit 1];
        questWrpr1.envDetQuestionId =lstenvDetQuestionId[0].Core_IPS_Question__r.Name;
        questWrpr1.answers = lstansWrpr;     
        lstquestWrpr.add(questWrpr1);         
        objWrapper.caseSeverity='Low';
        objWrapper.SeverityReason='High';
        objWrapper.endCustomer='Popcornapps test';
        objWrapper.customerReferenceId='1234567890';
        objWrapper.caseType='Question';
        objWrapper.subject ='Case create api testing 1234567890';
        objWrapper.caseDescription ='Case create api testing new';
        List<Core_IPS_Product_Issue_Category__c> CategoriesList2=[select id,name from Core_IPS_Product_Issue_Category__c where Core_Type__c ='Case Category'];
        objWrapper.caseCategoryId =CategoriesList2[0].Name;
        
        List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList2=[select id, name,Core_Product_Issue_Category__c from Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case SubCategory' AND Core_Product_Issue_Category__r.id=: CategoriesList2[0].Id];
        objWrapper.subCategoryId =CategoriesandSubCategoriesList2[0].Name;
        objWrapper.envDetails= lstquestWrpr;
        
        List<case> cs1 = [select id,CaseNumber,Core_IPS_Customer_Visible__c from case ];
        String csNumber = cs1[3].CaseNumber;
        RestRequest  request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'PATCH';
        RestContext.request = request; 
        request.resourcePath ='/services/apexrest/v1.0/cases/'+csNumber; 
        request.requestURI='/v1.0/cases/'+csNumber;
        Core_RestAPI_CaseDetailV1.doPatch(objWrapper);
        Core_RestAPI_Case_UpdateV1_Handler handler = new Core_RestAPI_Case_UpdateV1_Handler('CreateCase', System.now(), objWrapper);
        Core_RestAPI_Response response= handler.updateCase();
        handler.isProductOrProjectValid();
    }
    
    @isTest public static void test_isCaseCustomerVisible_negative1(){
        
        List<Core_IPS_Assigned_Environment_Variables__c> lstAssEnvVar=[Select Name,Core_Product_Issue_Sub_Category__r.Name ,Core_Product_Issue_Sub_Category__r.id ,Core_Environment_Variable__r.Name,Core_Required__c ,Core_Environment_Variable__r.Core_Datatype__c, Core_Environment_Variable__r.Core_Answers__c from Core_IPS_Assigned_Environment_Variables__c where Core_Agent_Only__c= false ];
        
        List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper> lstansWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper>();
        Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper ansWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.AnsWrapper();
        ansWrpr1.answer= 'answer 1';
        lstansWrpr.add(ansWrpr1);
        
        List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper> lstquestWrpr = new List<Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper>();
        
        Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper questWrpr1 = new Core_RestAPI_Case_UpdateV1_Wrapper.EnvQuestionWrapper();
        questWrpr1.envDetQuestion ='env detail question 1 ';
        List<Core_IPS_Assigned_Environment_Variables__c> lstenvDetQuestionId = [select id,name,Core_IPS_Question__r.Name from Core_IPS_Assigned_Environment_Variables__c Limit 1];
        questWrpr1.envDetQuestionId =lstenvDetQuestionId[0].Core_IPS_Question__r.Name;
        questWrpr1.answers = lstansWrpr;     
        lstquestWrpr.add(questWrpr1);         
        objWrapper.caseSeverity='Low';
        objWrapper.SeverityReason='High';
        objWrapper.endCustomer='Popcornapps test';
        objWrapper.customerReferenceId='1234567890';
        objWrapper.caseType='Question';
        objWrapper.subject ='Case create api testing 1234567890';
        objWrapper.caseDescription ='Case create api testing new';
        List<Core_IPS_Product_Issue_Category__c> CategoriesList2=[select id,name from Core_IPS_Product_Issue_Category__c where Core_Type__c ='Case Category'];
        objWrapper.caseCategoryId =CategoriesList2[0].Name;
        
        List<Core_IPS_Product_Issue_Category__c> CategoriesandSubCategoriesList2=[select id, name,Core_Product_Issue_Category__c from Core_IPS_Product_Issue_Category__c where Core_Type__c = 'Case SubCategory' AND Core_Product_Issue_Category__r.id=: CategoriesList2[0].Id];
        objWrapper.subCategoryId =CategoriesandSubCategoriesList2[0].Name;
        objWrapper.envDetails= lstquestWrpr;
        objWrapper.status='New';
        List<case> cs1 = [select id,CaseNumber,Core_IPS_Customer_Visible__c from case ];
        String csNumber = cs1[3].CaseNumber;
        
        RestRequest  request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'PATCH';
        RestContext.request = request; 
        request.resourcePath ='/services/apexrest/v1.0/cases/'+csNumber; 
        request.requestURI='/v1.0/cases/'+csNumber;
        Core_RestAPI_CaseDetailV1.doPatch(objWrapper);
        Core_RestAPI_Case_UpdateV1_Handler handler = new Core_RestAPI_Case_UpdateV1_Handler('CreateCase', System.now(), objWrapper);
        Core_RestAPI_Response response= handler.updateCase();
        handler.isProductOrProjectValid();
        handler.validateCaseCategoryFields();
        handler.closeCase();
        handler.doAllUpdateCaseValidations();
    }
    
    
    
}