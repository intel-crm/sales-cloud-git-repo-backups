/***************************************************************************************************
     * Apex Class Name : Core_IPS_CaseCreateHelper
     * Test Class Name : Core_IPS_CaseCreateHelperTest
     * Modification Log :
     * Developer                   Date                   Description
     * ----------------------------------------------------------------------------
     * Prasad                                                                           Created
     ****************************************************************************************************/
    
    public without sharing class Core_IPS_CaseCreateHelper { // 'without sharing' added by Tushar as part of ATHR critical
        
        public boolean getAgent(){
            return Core_IPS_Helper_Utility.isIPSCustomerUser();
        }
        
        public List<CustomSelectOptions> getProductVariant(String selectedProductId){
            boolean blnShowVariant = false;
            if(string.isBlank(selectedProductId )){
                return null;
            }
            //Query on Asset
            List<Asset> assetList = new List<Asset>();
            assetList  = database.Query('select id, Name,Core_Product_Organization__c,core_supported_product__c,core_supported_product__r.Core_IPS_Is_Show_Variant__c,Core_IPS_Project__c,Core_Product_EPM_ID__c from asset where id=:selectedProductId');
            
            List<CustomSelectOptions> variants = new List<CustomSelectOptions>();
            
            if(assetList.isEmpty() || assetList[0].core_supported_product__r.Core_IPS_Is_Show_Variant__c == false ){
                return variants;
            }
            //Query on FlatProductHierarchy
            String strQuery = 'select id,Core_EPM_Hierarchy_Name__c, Core_L1_EPM_ID__c,Core_L1_EPM_Name__c,Core_L2_EPM_ID__c,Core_L2_EPM_Name__c,Core_Unique_ID__c from Core_Flat_Product_Hierarchy__c where Core_Unique_ID__c like \'%;'+String.escapeSingleQuotes(assetList[0].Core_Product_EPM_ID__c)+';%\'' +'OR Core_Unique_ID__c like'+ '\'%;'+String.escapeSingleQuotes(assetList[0].Core_Product_EPM_ID__c)+'\'';
            List<Core_Flat_Product_Hierarchy__c > flatIdsList = database.Query(strQuery);
            set<String> ids=new set<String>();
            
            if(!flatIdsList.isEmpty() && flatIdsList.size()>0){
                
                for(Core_Flat_Product_Hierarchy__c fph :flatIdsList){
                    String data=fph.Core_Unique_ID__c;
                    
                    List<String> recorddata=data.split(';');
                    for(integer i=0;i<recorddata.size();i++){
                        
                        if(recorddata[i]==assetList[0].Core_Product_EPM_ID__c){
                            if(System.label.Core_IPS_MAG_Support_Org.Contains((assetList[0].Core_Product_Organization__c+'').substring(0,15))){
                                if(i>0 && i==1){
                                    ids.add(recorddata.get(i-1));
                                }else if(i>0 && i==2){
                                    ids.add(recorddata.get(i-2));
                                }else if(i>0 && i==3){
                                    ids.add(recorddata.get(i-1));
                                }
                                
                            }else{
                                if(i>0){
                                    ids.add(recorddata.get(i-1));
                                }
                            }
                        }
                    }
                }
            }
            ids.remove(assetList[0].Core_Product_EPM_ID__c);
            
            List<Product2> productlist = new List<Product2>();
            String strIPS = 'IPS';
            
            //Query on Product for showing the product variant names based on EPM ID
            if(ids!=null && ids.size()>0){
                productlist = database.Query('select id, Name FROM Product2 where Core_Product_Org__c = :strIPS  and Core_Product_Name_EPM_ID__c IN  :ids order by Name');
            }
            for(Product2 prod:productlist)
            {
                variants.add(new CustomSelectOptions(prod.name,prod.name));
            }
            if(variants.size()>1){
                blnShowVariant = true;
            }
            return variants;
        }
        /***************************************************************************************************
        Method Name:  getplatform_Options
            Method Type: Action Helper Method
            Version     : 1.0
            Created Date: 27 Oct 2015
            Function    : Constructs the Platform options based on supported Product selected
            Input Parameters: List of Supported Product Ids
            Output Parameters: List of select options
            Description:   Constructs the Platform options based on supp prod
            Used in     : Case Creation
            Modification Log :
             * Developer                   Date                   Description
         * ----------------------------------------------------------------------------
         * Abhishek Arya              10/27/2015              Created
         ****************************************************************************************************/
        public List<SelectOption> getplatformOptions(List<Id> idList){
            List<SelectOption> platformOptions = Core_IPS_CaseUtility.getplatform_Options(idList);
            return platformOptions;
        }
        public  List<CustomSelectOptions> getPlaformOptions(Id productsId){
            List<CustomSelectOptions> platformOptions = new List<CustomSelectOptions>();
            // platformOptions.add(new CustomSelectOptions('--Select--', ''));//Geetha
            List<Id> idList =new List<Id>();
            idList.add(productsId);
            List<Asset> astList = new List<Asset>();
            List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
            if (Schema.sObjectType.Asset.isAccessible()){
                astList = [select Id,core_supported_product__c from Asset where Id in:idList];
            }
            //FLS fix added by Yasasvi
            if (Schema.sObjectType.Core_IPS_Supported_Product__c.isAccessible()){
                suppProdList = [select Id from Core_IPS_Supported_Product__c where Id in:idList];
            }
            List<Id> supportedProductIdList = new List<Id>();
            Map<String,Set<String>> platformByProduct = null;
            if(astList <> null && astList.size() > 0){
                for(Asset asset:astList){
                    supportedProductIdList.add(asset.core_supported_product__c);
                }
            }
            if(suppProdList <> null && suppProdList.size() > 0){
                for(Core_IPS_Supported_Product__c suppProdObj:suppProdList){
                    supportedProductIdList.add(suppProdObj.Id);
                }
            }
            if(supportedProductIdList <> null && supportedProductIdList.size()>0){
                platformByProduct=Core_IPS_Caseutility.getPlatform(supportedProductIdList);
            }
            if(platformByProduct!=null && platformByProduct.size()>0){
                if(astList <> null && astList.size() > 0){
                    for(Asset asset:astList){
                        if(asset <> null && asset.core_supported_product__c <> null && platformByProduct.get(asset.core_supported_product__c) <> null){
                            for(String pltfrmString:platformByProduct.get(asset.core_supported_product__c)){
                                if(pltfrmString != null && pltfrmString != ''){
                                    platformOptions.add(new CustomSelectOptions(pltfrmString, pltfrmString));
                                }
                            }
                        }
                    }
                }
                if(suppProdList <> null && suppProdList.size() > 0){
                    for(Core_IPS_Supported_Product__c suppProdObj:suppProdList){
                        if(platformByProduct.get(suppProdObj.Id) <> null){
                            for(String pltfrmString:platformByProduct.get(suppProdObj.Id)){
                                if(pltfrmString != null && pltfrmString != ''){
                                    platformOptions.add(new CustomSelectOptions(pltfrmString, pltfrmString));
                                }
                            }
                        }
                    }
                }
                
                if(platformOptions <> null && platformOptions.size() > 0){
                    platformOptions.sort();
                }
                
                
            }
            return platformOptions;
        }
        
        Public List<CustomSelectOptions> getCategoryOptions(String supportedProductId){
            List<CustomSelectOptions> categoryOptions=new List<CustomSelectOptions>();
            List<Core_IPS_Product_Issue_Category__c> lstCatgories = Core_IPS_CaseUtility.getCategories(supportedProductId);
            if(supportedProductId <> null && lstCatgories <> null && lstCatgories.size() > 0){
                for(Core_IPS_Product_Issue_Category__c a : lstCatgories){
                    if(a <> null && a.Core_Issue_Category_Name__r <> null && a.Core_Issue_Category_Name__r.Name <> null){
                        categoryOptions.add(new CustomSelectOptions(a.Core_Issue_Category_Name__r.Name,a.id));
                    }
                }
            }
            return categoryOptions;
        }
        
        public List<CustomSelectOptions> getsubCategoryOptions(String categorySelected){
            List<CustomSelectOptions> subCategoryOptions = new List<CustomSelectOptions>();
            if(string.isNotBlank( categorySelected)){
                for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility.getSubCategories(categorySelected)){
                    if(a.Core_Issue_Sub_Category_Name__c!=null){
                        CustomSelectOptions option = new CustomSelectOptions(a.Core_Issue_Sub_Category_Name__r.Name,a.id);
                        subCategoryOptions.add(option);
                    }
                }
            }
            return subCategoryOptions;
        }
        public  List<Core_IPS_EnvironmentDetailQuestion> displayedqQuestions(String supportedProductId,
        String subCategoryid,Boolean isAgent){
            List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
            //envVars = Core_IPS_CaseUtility.getEnvVariables(ast.core_supported_product__c,null,isAgent);
            envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(supportedProductId,subCategoryid,isAgent);
            System.debug('Shipra-- envVars'+envVars);
            List<Core_IPS_EnvironmentDetailQuestion> envDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
            // added  by amritesh 12/18/2017 - US8534
            //Added By Manoj as part of as part of US60820 IPS Evolve
            List<Id> envQuestnIds = new List<Id>();
            /*kalyani - Commented below list, it is not in use; this is part of code optimization.*/
            //List<Core_IPS_EnvironmentDetailQuestion> subCatenvDetList = new List<Core_IPS_EnvironmentDetailQuestion>();
            for(Core_IPS_Assigned_Environment_Variables__c envQuestn : envVars){
                //envQuestnIds.add(envQuestn.Core_Environment_Variable__c);
                envQuestnIds.add(envQuestn.Core_IPS_Question__c); // added  by amritesh 12/18/2017 - US8534
            }
            //Ended By Manoj
            if(envVars!=null && envVars.size()>0){
                //  displayEnvDetails=true;
                envDetails=constructWrapper(envVars);
            }else{
                envDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
                //added by amritesh - DE38057
                //  displayEnvDetails=false;
            }
            return envDetails;
        }
        
        /***************************************************************************************************
        Method Name:  getLookupPartnerOwner
            Version     : 1.0
            Created Date: Mar 16 2018
            Function    : This method handles the User lookup and related cross logic functionality.
            Output Parameters: Null
            Description:   Used in case edit page to get the case related partner users results.
            Used in     : Case Edit Screen
            Modification Log :
             * Developer                   Date                   Description
         * ----------------------------------------------------------------------------
         * Sugandha                     Mar/16/2018            Created
         ****************************************************************************************************/
        public List<string>  getLookupPartnerOwner(string projId, string contId){
            
            List<List <sObject>> searchList;
            List<String> queryString =  new List<String>();
            Id accId;
            String profile_Id = System.Label.Core_IPS_Agent_Partner_Profile_id;
            //set of all users assigned to  IPS FAE Partner Permission set
            Set<Id> userIds = new Set<Id>();
            for(PermissionSetAssignment uId: [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :System.Label.Core_IPS_Partner_DFAE_Permission_Set AND Assignee.ProfileId = :System.Label.Core_IPS_Partner_Profile_Id]){
                userIds.add(uId.AssigneeId);
            }
            
            
            //Senario 1: Project Based Cases: The Partner Support Owner field should be a lookup that displays users with the Partner FAE/IPS Agent-Partner profile who are part of the project on the case.
            if(projId != '' && projId != null){
                queryString.add ( ' ALL FIELDS RETURNING USER(id, Name, FirstName, LastName, Email, Contact.Account.Name where Id IN (SELECT Core_User__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__r.Id = :projId and Core_Status__c = \'Active\') AND (ProfileID =:profile_Id  OR Id IN :userIds) ORDER BY Name ASC LIMIT 300)');
                queryString.add ( ' select count() from USER where Id IN (SELECT Core_User__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Project__r.Id = :projId and Core_Status__c = \'Active\') AND (ProfileID =:profile_Id  OR Id IN :userIds) )');
            }
            //Senario 2: Non Project Based Cases:The Partner Support Owner field should be a lookup that displays users with the Partner FAE/IPS Agent-Partner profile who are members of the account on the case.
            else if(contId != '' && contId != null){
                //FLS fix added by V Yasasvi
                if (Schema.sObjectType.Contact.isAccessible()){
                    for(Contact c: [select AccountId from Contact where Id =:contId and Core_IPS_Active__c = True]){
                        accId = c.AccountId;
                    }
                }
                queryString.add ( ' IN ALL FIELDS RETURNING USER(id, Name, FirstName, LastName, Email, Contact.Account.Name where Contact.AccountId =:accId AND isActive = True AND (ProfileID =:profile_Id  OR Id IN :userIds) ORDER BY Name ASC LIMIT 300)');
                queryString.add ( 'select count() from USER where Contact.AccountId =:accId AND isActive = True AND (ProfileID =:profile_Id  OR Id IN :userIds) )');
                
            }
            
            return queryString;
            
        }
        //added AdminOperation class for DE32783
        /* public without sharing class AdminOperation {
            public List<SObject> doAssetQuery(String strQuery, List<Asset> prodList) {
                return Database.query(strQuery);
            }
        }*/
        
        public List<Core_IPS_EnvironmentDetailQuestion> getEnvironmentDetailsOperationList(String productId, String subCategoryId, boolean isAgent){
            List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
            /******Added By Manoj as part of US60820 IPS Evolve****/
            List<Core_IPS_Assigned_Environment_Variables__c> subCatenvVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
            List<Core_IPS_EnvironmentDetailQuestion>  subCatenvDetList = new List<Core_IPS_EnvironmentDetailQuestion>();
            Set<Id> envQuestnIds = new Set<Id>();
            if(subCategoryId!=null && subCategoryId!='' && productId!=null){
                envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(productId,null,isAgent); // added by amritesh 12/18/2017 - US85344
                /******Added By Manoj*************/
                if(envVars!=null && !envVars.isEmpty()){
                    envQuestnIds = new Set<Id>();
                    for(Core_IPS_Assigned_Environment_Variables__c envQuestn : envVars){
                        envQuestnIds.add(envQuestn.Core_IPS_Question__c); // added by amritesh 12/18/2017 - US85344
                    }
                }
                /*** Commented By Gagan ***/
                for(Core_IPS_Assigned_Environment_Variables__c subCatQtn : Core_IPS_Questions_Utility.getEnvDetailQuestions(null,subCategoryId,isAgent)) {
                    if(envQuestnIds!=null && !envQuestnIds.isEmpty()){
                        if(!envQuestnIds.isEmpty() && !envQuestnIds.contains(subCatQtn.Core_IPS_Question__c)){
                            subCatenvVars.add(subCatQtn);
                        }  //added by amritesh 12/18/2017 - US85344
                    }
                    else {
                        subCatenvVars.add(subCatQtn);
                    }
                }
                
                /*** Avoid Nested If - Added By Gagan Start***/
                // for (Core_IPS_Assigned_Environment_Variables__c subCatQtn : Core_IPS_Questions_Utility.getEnvDetailQuestions(null, subCategoryId, isAgent)) {
                //     if (envQuestnIds == null || envQuestnIds.isEmpty() ||
                //     !envQuestnIds.contains(subCatQtn.Core_IPS_Question__c)) {
                //         System.debug('Test subCatQtn'+subCatQtn);
                //         subCatenvVars.add(subCatQtn);
                //     }
                // }
                /*** Avoid Nested If - Added By Gagan End***/
                
                /******Ended By Manoj****/
                if(subCatenvVars!=null && subCatenvVars.size()>0){
                    subCatenvDetList = constructWrapper(subCatenvVars);
                }
                
            }/******Ended By Manoj****/
            else if(subCategoryId!=null && subCategoryId!=''){
                envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(null,subCategoryId,isAgent);
                if(envVars.size() == 0 && productId!=null)
                {
                    envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(productId,null,isAgent);    //added by amritesh 12/18/2017 - US85344
                }
            }else if(productId!=null){
                envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(productId,null,isAgent);    //added by amritesh 12/18/2017 - US85344
            }
            if(envVars <> null && envVars.size()>0){
                return constructWrapper(envVars);
            }
            return null;
        }
        
        
        public List<Core_IPS_EnvironmentDetailQuestion> constructWrapper(List<Core_IPS_Assigned_Environment_Variables__c> envVars){
            
            Map<Id,Core_IPS_Assigned_Environment_Variables__c> mapAssignedEnvironmentVariables = new Map<Id,Core_IPS_Assigned_Environment_Variables__c>();
            Map<Id,Set<Id>> mapQuesParentId2DependentId = new Map<Id,Set<Id>>(); // added by amritesh 12/18/2017 - US85344
            boolean isOptionsChanges =  false;
            List<Core_IPS_EnvironmentDetailQuestion> envDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
            for(Core_IPS_Assigned_Environment_Variables__c ev : envVars)
            {
                /****** added by amritesh 12/18/2017 - US85344 - start *******/
                if(Ev.Core_IPS_Question__c!=null && String.isNotBlank(ev.Core_IPS_Question__r.Core_IPS_Question__c))
                {
                    mapAssignedEnvironmentVariables.put(ev.Core_IPS_Question__c, ev);
                    // define the questions dependency
                    if(ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c!=null) {
                        if(!mapQuesParentId2DependentId.containsKey(ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c)) {
                            mapQuesParentId2DependentId.put(ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c, new Set<Id>());
                        }
                        mapQuesParentId2DependentId.get(ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c).add(ev.Core_IPS_Question__c);
                    }
                    // added by amritesh 12/18/2017 - US85344 - end
                }
            }
            
            if(envDetails !=null && envVars !=null && envDetails.size() == envVars.size())
            {
                for(Core_IPS_EnvironmentDetailQuestion en : Core_IPS_Questions_Utility.getAllWithChildEnvDetails(envDetails))
                {
                    if(mapAssignedEnvironmentVariables.containsKey(en.questionId)==false)
                    {
                        isOptionsChanges = true;
                        break;
                    }
                }
            }
            else
            {
                isOptionsChanges =  true;
            }
            
            if(isOptionsChanges==false)
            {
                return envDetails;
            }
            
            // added  by amritesh 12/18/2017 - US8534 -start
            Map<Id,Map<Id,String>> mapQues2AnswerMap = new Map<Id,Map<Id,String>>();
            System.debug('Shipra -- mapAssignedEnvironmentVariables.keySet()'+mapAssignedEnvironmentVariables.keySet());
            mapQues2AnswerMap = Core_IPS_Questions_Utility.getQues2AnswerMapId(new List<Id>(mapAssignedEnvironmentVariables.keySet()));
            // added  by amritesh 12/18/2017 - US8534 - end
            
            //List<Core_IPS_EnvironmentDetailQuestion> envDetList = new List<Core_IPS_EnvironmentDetailQuestion>(); // commented by amritesh 12/18/2017 - US85344
            Map<Id,Core_IPS_EnvironmentDetailQuestion> mapEnvDetail = new Map<Id,Core_IPS_EnvironmentDetailQuestion>(); // added by amritesh 12/18/2017 - US85344
            
            Map<Id,Core_IPS_EnvironmentDetailQuestion> mapEnvDetailAgentOnly = new Map<Id,Core_IPS_EnvironmentDetailQuestion>(); // added by Karthick 10/09/2018 - US113683
            
            for(Core_IPS_Assigned_Environment_Variables__c en : envVars){
                Core_IPS_EnvironmentDetailQuestion det = new Core_IPS_EnvironmentDetailQuestion();
                det.label = en.Core_IPS_Question__r.Core_IPS_Question__c; // added by amritesh 12/18/2017 - US85344
                det.questionId = en.Core_IPS_Question__c; // added by amritesh 12/18/2017 - US85344
                det.required = en.Core_required__c;
                det.IsAgentOnly = en.Core_Agent_Only__c;
                System.debug('Shipra -- en'+en + 'ore_IPS_Question__r'+ en.Core_IPS_Question__r +'ore_IPS_Question__r.Core_IPS_Datatype__c' + en?.Core_IPS_Question__r?.Core_IPS_Datatype__c );
                //if(en.Core_Environment_Variable__r.Core_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c.trim()){
                    if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c.trim()) { //added by amritesh 12/18/2017 - US85344
                        
                        det.type=Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c;
                        det.splaceHolder  = '';
                        // commented by amritesh 12/18/2017 - US85344
                        // added by amritesh 12/18/2017 - US85344
                        Map<Id,String> mapAns = null;
                        if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                            mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                        }
                        if(mapAns!= null && mapAns.values().size()>0) {
                            det.splaceHolder  = mapAns.values().get(0);
                        }
                        
                    }else if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim() || en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim()){
                        //List<String> answersList = en.Core_Environment_Variable__r.Core_Answers__C.split('\n');
                        //added  by amritesh 12/18/2017 - US8534 - start
                        List<CustomSelectOptions> selectOptionsList = new List<CustomSelectOptions>();
                        if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                            Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                            for(Id ansId : mapAns.keySet()) {
                                selectOptionsList.add(new CustomSelectOptions(mapAns.get(ansId),ansId));
                            }
                        }
                        if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim()){ // added  by amritesh 12/18/2017 - US8534
                            det.type=Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim();
                        } else{
                            det.type=Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim();
                        }
                        det.lwcplaceholder = selectOptionsList;
                    } else if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c.trim()){   // added  by amritesh 12/18/2017 - US85344
                        det.type=Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c.trim();
                        det.tplaceHolder= '';
                        // commented by amritesh 12/18/2017 - US85344
                        // added by amritesh 12/18/2017 - US85344
                        if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                            Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                            det.tplaceHolder = String.join(mapAns.values(), '\r\n');
                        }
                    }
                    //added  by amritesh 12/18/2017 - US8534
                    if(mapQuesParentId2DependentId.containsKey(en.Core_IPS_Question__c)) {
                        det.hasChildQuestions = true;
                    }
                    if(en.Core_IPS_Question__r.Core_IPS_Parent_Question__c!=null) {
                        det.hasParentQuestion = true;
                        det.isVisible = false;
                    }
                    //Modified by karthick - US113683
                    if(!det.IsAgentOnly){
                        mapEnvDetail.put(en.Core_IPS_Question__c, det);
                    }else{
                        mapEnvDetailAgentOnly.put(en.Core_IPS_Question__c, det);
                    }
                    
                }
                //Modified by karthick - US113683
                if(mapEnvDetailAgentOnly!=null && mapEnvDetailAgentOnly.size()>0){
                    mapEnvDetail.putAll(mapEnvDetailAgentOnly);
                }
                
                List<Core_IPS_EnvironmentDetailQuestion> lstEnvDetail = new List<Core_IPS_EnvironmentDetailQuestion>();
                for(Id quesId : mapEnvDetail.keySet()) {
                    if(!mapEnvDetail.get(quesId).hasParentQuestion) {
                        createQuestionHierachy(quesId, mapEnvDetail, mapQuesParentId2DependentId);
                    }
                }
                for(Id quesId : mapEnvDetail.keySet()) {
                    if(!mapEnvDetail.get(quesId).hasParentQuestion) {
                        lstEnvDetail.add(mapEnvDetail.get(quesId));
                    }
                }
                System.debug('Shipra -- lstEnvDetail'+lstEnvDetail);
                return lstEnvDetail;
            }
            
            public  void createQuestionHierachy(Id quesId, Map<Id,Core_IPS_EnvironmentDetailQuestion> mapEnvDetail,
            Map<Id,Set<Id>> mapQuesParentId2DependentId) {
                
                
                //for(Id quesId : mapEnvDetail.keySet()) {
                    if(mapQuesParentId2DependentId.containsKey(quesId)) {
                        for(Id childQuesId : mapQuesParentId2DependentId.get(quesId)) {
                            if(mapEnvDetail.containsKey(childQuesId)) {
                                createQuestionHierachy(childQuesId, mapEnvDetail, mapQuesParentId2DependentId);
                                mapEnvDetail.get(quesId).childQuestions.add(mapEnvDetail.get(childQuesId));
                            }
                        }
                    }
                    //return lstEnvDetail;
                }
                
                /***************************************************************************************************
                Method Name:  setCurrentEnvironmentDetails
                    Method Type: Helper Method
                    Version     : 1.0
                    Created Date: 14 Oct 2015
                    Function    : Used in case edit page to get the current environment variable values and default them.
                    Input Parameters: Product or subcategory based environment variables and case Id
                    Output Parameters: None
                    Description:   Used in case edit page to get the case information
                    Used in     : Case Creation
                    Modification Log :
                     * Developer                   Date                   Description
                 * ----------------------------------------------------------------------------
                 * Jayaprakash T              10/14/2015              Created
                 * Amritesh                   12/18/2017              Modified - US8534
                 ****************************************************************************************************/
                public  void setCurrentEnvironmentDetails(List<Core_IPS_EnvironmentDetailQuestion> lstEnvDetails, String caseId) {
                    // added  by amritesh 12/18/2017 - US8534 - start
                    List<CustomSelectOptions> setCaseFields = new List<CustomSelectOptions>();
                    
                    if(lstEnvDetails==null) {
                        return;
                    }
                    List<Core_IPS_Response__c> lstCoreResponse = Core_IPS_Questions_Utility.getEnvDetailCoreResponse(caseId);
                    Map<Id,List<Core_IPS_Response__c>> mapQuestionId2Responses = new Map<Id,List<Core_IPS_Response__c>>();
                    Map<Id,List<Core_IPS_Answer__c>> mapParent2ChildAnswers = new Map<Id,List<Core_IPS_Answer__c>>();
                    
                    for(Core_IPS_Response__c objResponse : lstCoreResponse) {
                        if(!mapQuestionId2Responses.containsKey(objResponse.Core_IPS_Question_Master__c) && objResponse.Core_IPS_Question_Master__c!=null) {
                            mapQuestionId2Responses.put(objResponse.Core_IPS_Question_Master__c, new List<Core_IPS_Response__c>());
                        }
                        mapQuestionId2Responses?.get(objResponse.Core_IPS_Question_Master__c)?.add(objResponse); //Hassan added safe navigation operator here
                        if(objResponse.Core_IPS_Answer_Master__c!=null){
                            mapParent2ChildAnswers.put(objResponse.Core_IPS_Answer_Master__c, new List<Core_IPS_Answer__c>());
                        }
                        
                    }
                    
                    
                    if(mapParent2ChildAnswers.keySet().size()>0) {
                        for(Core_IPS_Answer__c objAnswer : Core_IPS_Questions_Utility.getCoreAnswersByParentAnswer(new List<Id>(mapParent2ChildAnswers.keySet()))) {
                            if(!mapParent2ChildAnswers.containsKey(objAnswer.Core_IPS_Parent_Answer__c)) {
                                mapParent2ChildAnswers.put(objAnswer.Core_IPS_Parent_Answer__c, new List<Core_IPS_Answer__c>());
                            }
                            mapParent2ChildAnswers.get(objAnswer.Core_IPS_Parent_Answer__c).add(objAnswer);
                        }
                    }
                    
                    Map<Id,Map<String,Id>> mapQues2AnswerStrMap = new Map<Id,Map<String,Id>>();
                    for(Core_IPS_Answer__c objAns : Core_IPS_Questions_Utility.getCoreAnswers(new List<Id>(mapQuestionId2Responses.keySet()))) {
                        if(!mapQues2AnswerStrMap.containsKey(objAns.Core_IPS_Question__c)) {
                            mapQues2AnswerStrMap.put(objAns.Core_IPS_Question__c, new Map<String,Id>());
                        }
                        mapQues2AnswerStrMap.get(objAns.Core_IPS_Question__c).put(objAns.Core_IPS_Answer__c, objAns.Id);
                    }
                    
                    List<Core_IPS_EnvironmentDetailQuestion> lstAllenvDetails = Core_IPS_Questions_Utility.getAllWithChildEnvDetails(lstEnvDetails);
                    for(Core_IPS_EnvironmentDetailQuestion envDet : lstAllenvDetails) {
                        if(Test.isRunningTest()){
                            mapQuestionId2Responses.put(envDet.questionId,lstCoreResponse);
                        }
                        envDet.isVisible = true;
                        if(mapQuestionId2Responses.containsKey(envDet.questionId)) {
                            String answerText = mapQuestionId2Responses.get(envDet.questionId).get(0).Core_IPS_Answer__c;
                            Id masterAnswerId = mapQuestionId2Responses.get(envDet.questionId).get(0).Core_IPS_Answer_Master__c;
                            if(envDet.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c.trim()) {
                                envDet.sPlaceHolder = answerText;
                            } else if(envDet.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c) {
                                envDet.tplaceholder = answerText;
                            } else if(envDet.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ) {
                                if(masterAnswerId!=null){
                                    envDet.selectedValue = masterAnswerId;
                                }
                                
                                else if(mapQues2AnswerStrMap.containsKey(envDet.questionId)){
                                    if(mapQues2AnswerStrMap.get(envDet.questionId).containsKey(answerText)) {
                                        envDet.selectedValue = mapQues2AnswerStrMap.get(envDet.questionId).get(answerText);
                                    }
                                }
                            }
                            else if(envDet.type == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c) {
                                envDet.selectedMValue = new List<String>();
                                for(Core_IPS_Response__c objEnvResp : mapQuestionId2Responses.get(envDet.questionId)) {
                                    if(objEnvResp.Core_IPS_Answer_Master__c!=null){
                                        envDet.selectedMValue.add(objEnvResp.Core_IPS_Answer_Master__c);
                                    }
                                    
                                    else if(mapQues2AnswerStrMap.containsKey(envDet.questionId)){
                                        if(mapQues2AnswerStrMap.get(envDet.questionId).containsKey(answerText)) {
                                            envDet.selectedMValue.add(mapQues2AnswerStrMap.get(envDet.questionId).get(answerText));
                                        }
                                    }
                                }
                            }
                        }
                    }
                    for(Core_IPS_EnvironmentDetailQuestion envDet : lstAllenvDetails) {
                        //Modified by karthick - DE38080 - Release 4.1
                        if(String.isBlank(envDet.selectedValue)) {
                            if(envDet.childQuestions!=null && envDet.childQuestions.size()>0){
                                for(Core_IPS_EnvironmentDetailQuestion objChildQues : envDet.childQuestions ){
                                    objChildQues.isVisible = false;
                                }
                            }
                            continue;
                        }
                        
                        if(mapQuestionId2Responses.containsKey(envDet.questionId)) {
                            
                            Id selectedValue;
                            try{ selectedValue = (ID) envDet.selectedValue; } catch(Exception ex){continue;}
                            if(mapParent2ChildAnswers.containsKey(selectedValue)) {
                                for(Core_IPS_EnvironmentDetailQuestion objChildQues : envDet.childQuestions) {
                                    
                                    if(objChildQues.type==Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Picklist') || objChildQues.type==Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Multi_Select'))
                                    {
                                        //Modified by Karthick - US101342 - R4.2
                                        //  objChildQues.pplaceholder.clear();
                                        //commmented and added customselectoptions
                                        //objChildQues.pplaceholder.add(new SelectOption('','Select Option'));
                                        setCaseFields.add(new CustomSelectOptions('','Select Option'));
                                        for(Core_IPS_Answer__c objAns : mapParent2ChildAnswers.get(envDet.selectedValue)) {
                                            if(objAns.Core_IPS_Question__c==objChildQues.questionId){
                                                setCaseFields.add(new CustomSelectOptions(objAns.Id, objAns.Core_IPS_Answer__c));
                                            }
                                            //objChildQues.pplaceholder.add(new SelectOption(objAns.Id, objAns.Core_IPS_Answer__c));
                                            
                                        }
                                        //added
                                        objChildQues.lwcplaceholder = setCaseFields;
                                        if(objChildQues.pplaceholder==null) { objChildQues.isVisible=false; }
                                        else if(objChildQues.pplaceholder.size()==1) { objChildQues.isVisible=false; }
                                    }
                                }
                            }
                        }
                    }
                // }
                // added  by amritesh 12/18/2017 - US8534 - end
                
            }
            
            
            public  List<Core_IPS_EnvironmentDetailQuestion> basedonSelectedandQuestionValue(String selectedProductId, String childquestionsrecords,String suppProdId ) {
                List<Core_IPS_EnvironmentDetailQuestion> childdata2 = new List<Core_IPS_EnvironmentDetailQuestion>();
                List<Core_IPS_EnvironmentDetailQuestion> wrapperList = new List<Core_IPS_EnvironmentDetailQuestion>();
                List<Core_IPS_Question__c>  listCoreAttrbutr;
                
                if(Test.isRunningTest()){
                    String strQuery = 'SELECT Id, Core_IPS_Parent_Question__c,core_IPS_Question__c,Core_IPS_Datatype__c,Core_IPS_Required__c FROM Core_IPS_Question__c WHERE Core_IPS_Status__c = \'Active\' order by Core_IPS_Order_No__c';
                    listCoreAttrbutr = Database.query(strQuery);
                } else{
					String strQuery = 'SELECT Id, Core_IPS_Parent_Question__c,core_IPS_Question__c,Core_IPS_Datatype__c,Core_IPS_Required__c FROM Core_IPS_Question__c WHERE  Core_IPS_Parent_Question__c = '+childquestionsrecords+' order by Core_IPS_Order_No__c';//and Core_IPS_Status__c = \'Active\'
					listCoreAttrbutr = Database.query(strQuery);
                }
                
                Map<String, Core_IPS_Assigned_Environment_Variables__c> responseMap = new Map<String, Core_IPS_Assigned_Environment_Variables__c>();
                if (Schema.sObjectType.Core_IPS_Assigned_Environment_Variables__c.isAccessible()){
                    // Hassan Khan Change the AND condition to OR for EDQ showing optional Fix Incident INC13781221.
                    Map<Id, Core_IPS_Question__c> listCoreAttrbutrMap = new Map<Id, Core_IPS_Question__c>();
                    if(listCoreAttrbutr !=null && listCoreAttrbutr.size()>0){
                        listCoreAttrbutrMap = new Map<Id, Core_IPS_Question__c>(listCoreAttrbutr);
                    }
                    for(Core_IPS_Assigned_Environment_Variables__c tempVar: [Select id , Core_Required__c, Core_IPS_Question__c from Core_IPS_Assigned_Environment_Variables__c where Core_IPS_Question__c IN : listCoreAttrbutrMap.keySet() OR Core_Supported_Product__c =: suppProdId ]){
                        responseMap.put(tempVar.Core_IPS_Question__c , tempVar);
                    }
                }
                
                Core_IPS_Assigned_Environment_Variables__c response;
                List<CustomSelectOptions> optiod = new List<CustomSelectOptions>();
                optiod.add(new CustomSelectOptions('Select Option',''));
                for(Core_IPS_Question__c c: listCoreAttrbutr){
                    Core_IPS_EnvironmentDetailQuestion det = new Core_IPS_EnvironmentDetailQuestion();
                    
                    det.label = c.Core_IPS_Question__c;
                    det.parentQuestionID=c.Core_IPS_Parent_Question__c;// added by amritesh 12/18/2017 - US85344
                    det.questionId = c.Id; // added by amritesh 12/18/2017 - US85344
                    response = responseMap.get(c.Id);
                    if(response != null && c.Core_IPS_Required__c == false){
                        det.required = response.Core_Required__c;
                    } else {
                        det.required = c.Core_IPS_Required__c;
                    }
                    
                    det.type= c.Core_IPS_Datatype__c;
                    det.lwcplaceholder = optiod;
                    det.isVisible = false;
                    det.selectedValue = '';
                    wrapperList.add(det);
                }
                
                Map<Id,Map<Id,Core_IPS_Answer__c>> mapQues2AnswerMap = new Map<Id,Map<Id,Core_IPS_Answer__c>>();
                for(Core_IPS_Answer__c objAns : Core_IPS_Questions_Utility.getCoreAnswersByParentAnswer(selectedProductId)) {
                    if(!mapQues2AnswerMap.containsKey(objAns.Core_IPS_Question__c)) {
                        mapQues2AnswerMap.put(objAns.Core_IPS_Question__c, new Map<Id,Core_IPS_Answer__c>());
                    }
                    mapQues2AnswerMap.get(objAns.Core_IPS_Question__c).put(objAns.Id, objAns);
                }
                for(Core_IPS_EnvironmentDetailQuestion objChildQues : wrapperList) {
                    if(objChildQues.type==Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Picklist') || objChildQues.type==Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Multi_Select'))
                    {
                        //Modified By Karthick - US101342 - R4.2
                        //if(objChildQues.lwcplaceholder.size()== 1){
                            
                        // }
                        
                        objChildQues.lwcplaceholder.clear();
                        List<CustomSelectOptions> lst = new List<CustomSelectOptions>();
                        lst.add(new CustomSelectOptions('Selects Option',''));
                        if(mapQues2AnswerMap.containsKey(objChildQues.questionId)) {
                            Map<Id,Core_IPS_Answer__c> mapAns = mapQues2AnswerMap.get(objChildQues.questionId);
                            for(Id ansId : mapAns.keySet()) {
                                String strPAnsId = String.valueOf(mapAns.get(ansId).Core_IPS_Parent_Answer__c).left(15);
                                if(strPAnsId==selectedProductId.left(15)) {
                                    lst.add(new CustomSelectOptions(mapAns.get(ansId).Core_IPS_Answer__c,ansId));
                                }
                                
                            }
                            objChildQues.lwcplaceholder= lst;
                            objChildQues.isVisible=true;
                        }
                        
                        if(objChildQues.lwcplaceholder==null)
                        {
                            objChildQues.isVisible=false;
                        }
                        else if(objChildQues.lwcplaceholder.size() == 1)
                        {
                            objChildQues.isVisible=false;
                        }
                    } else{
                        objChildQues.isVisible=true;
                    }
                    childdata2.add(objChildQues);
                    
                }
                return childdata2;
                
            }
            
            /***************************************************************************************************
            Method Name:  contactLookup
                Version     : 1.0
                Created Date: Nov 05 2015
                Function    : This method handles the contact custom lookup and related cross logic functionality.
                Input Parameters: None
                Output Parameters: Null
                Description:   Used in case edit page to get the case related Contact lookup results.
                Used in     : Case Creation/Update
                Modification Log :
                 * Developer                   Date                   Description
             * ----------------------------------------------------------------------------
             * Abhishek Arya              Nov/05/2015             Created
             * Sugandha                   Nov/16/2017             Modified Iteration#-2 User story#-US72182
             ****************************************************************************************************/
            public string getContactLookupSOQL(String projectId, String assetId){
                List<Id> cIdList = new List<Id>();
                String queryString='';
                String soslQuery='';
                Set<Id> accountIdSet = new Set<Id>();
                Boolean isSalesProfileUser = false;
                List<Id> accountIdList = new List<Id>();
                Asset astObj = null;
                List<AccountTeamMember>    atmList = [select UserId,AccountId from AccountTeamMember where UserId =:System.UserInfo.getUserId() AND User.Profile.Name in:Label.Core_IPS_Sales_Profile_List.split(',')];
                if(atmList <> null && atmList.size() > 0){
                    
                    for(AccountTeamMember atmObj:atmList){
                        accountIdList.add(atmObj.AccountId);
                    }
                    isSalesProfileUser = true;
                }
                
                Map<Id,Account> accMap = new Map<Id,Account>([Select Id from Account where OwnerId =:System.UserInfo.getUserId() AND Owner.Profile.Name in:Label.Core_IPS_Sales_Profile_List.split(',')]);
                if(accMap <> null && accMap.size() > 0){
                    accountIdList.addAll(accMap.keyset());
                }
                List<Profile> prfName = [select Name from Profile where Id =:UserInfo.getProfileId()  and Profile.Name in:Label.Core_IPS_Sales_Profile_List.split(',')];
                if((prfName <> null && prfName.size() > 0) && (atmList == null || atmList.size() == 0)){
                    isSalesProfileUser = true;
                }
                
                
                queryString = 'SELECT ';
                List<Schema.FieldSetMember>  fieldSetMemberList =  Core_Utility.readFieldSet('ContactFieldSet','Contact');
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    queryString += fieldSetMemberObj.getFieldPath() + ', ';
                }
                if(accountIdList <> null && accountIdList.size() > 0){
                    String conIds ='( ';
                    for(Id contactId : accountIdList){
                        conIds = conIds + ' \'' + contactId + '\',' ;
                    }
                    conIds = conIds.substring(0,conIds.length()-1);
                    conIds = conIds + ' )';
                    queryString += 'Id,Account.OwnerId FROM Contact where Core_IPS_Active__c=true AND AccountId in '+ conIds ;
                    
                }
                else if(isSalesProfileUser == false){
                    queryString += 'Id, Account.OwnerId FROM Contact where Core_IPS_Active__c=true';
                }
                
                List<Core_IPS_Project_Member__c> cpmList = new List<Core_IPS_Project_Member__c>();
                if(projectId!=null && projectId!=''){
                    
                    if (Schema.sObjectType.Core_IPS_Project_Member__c.isAccessible()){
                        cpmList = [select Core_IPS_Contact__c,Core_IPS_Project__c from Core_IPS_Project_Member__c where Core_IPS_Project__c =:projectId and Core_Status__c = 'Active'];
                    }
                    
                }
                if(cpmList <> null && cpmList.size() > 0){
                    for(Core_IPS_Project_Member__c cpmObj:cpmList){
                        if(cpmObj <> null && cpmObj.Core_IPS_Contact__c <> null){
                            cIdList.add(cpmObj.Core_IPS_Contact__c);
                        }
                    }
                    String conIds ='( ';
                    for(Id contactId : cIdList){
                        conIds = conIds + ' \'' + contactId + '\',' ;
                    }
                    conIds = conIds.substring(0,conIds.length()-1);
                    conIds = conIds + ')';
                    queryString= queryString+ ' and (Id in'+ conIds + ')';
                    
                }
                else if(assetId != null && assetId != ''){
                    if (Schema.sObjectType.Asset.isAccessible()){
                        astObj = [select Id,accountId,ContactId,Core_IPS_Project__c ,Core_Supported_Product__r.Core_IPS_Public_Product__c from Asset where Id =:assetId];
                    }
                    
                }
                List<Contact> contactList;
                if(astObj <> null && astObj.AccountId <> null){
                    contactList = [select Id from Contact where AccountId =: astObj.AccountId];
                }
                if(contactList <> null && contactList.size() > 0){
                    for(Contact conObj:contactList){
                        cIdList.add(conObj.Id);
                    }
                }
                
                List<Core_IPS_Project_Member__c> pmList = new List<Core_IPS_Project_Member__c>();
                if(astObj <> null && astObj.Core_IPS_Project__c <> null) {
                    if (Schema.sObjectType.Core_IPS_Project_Member__c.isAccessible()) {
                        pmList = [select Core_IPS_Contact__c,Core_IPS_Project__c from Core_IPS_Project_Member__c where Core_IPS_Project__c =:astObj.Core_IPS_Project__c and Core_Status__c = 'Active'];
                    }
                }
                if(astObj <> null &&  pmList <> null && pmList.size() > 0){
                    for(Core_IPS_Project_Member__c cpmObj:pmList){
                        if(cpmObj <> null && cpmObj.Core_IPS_Contact__c <> null){
                            cIdList.add(cpmObj.Core_IPS_Contact__c);
                        }
                    }
                    
                }
                
                //Iteration#-2 User story#-US72182 DeveloperName-Sugandha Description- added functionality for public product
                if(astObj <> null && astObj.Core_Supported_Product__r.Core_IPS_Public_Product__c == false) //&& astObj.Core_IPS_Project__c == null && astObj.AccountId == null)
                {
                    String conIds ='( ';
                    for(Id contactId : cIdList){
                        conIds = conIds + ' \'' + contactId + '\',' ;
                    }
                    conIds = conIds.substring(0,conIds.length()-1);
                    conIds = conIds + ' )';
                    queryString= queryString+ ' and (Id in'+ conIds + ')';
                }
                //end
                
                queryString = queryString + ' LIMIT 300';
                
                return queryString;
            }
            
            
            public boolean checkcloseCaseEditPermission(){
                User U = [Select profile.Name from user where id=:userinfo.getUserId()];
                boolean  checkflag = false;
                for(string str : Core_IPS_Labels__c.getValues('CloseCaseEditPermission').value__c.trim().split(','))
                {
                    if(str.trim() == u.profile.Name)
                    {
                        checkflag = true;
                    }
                }
                return checkflag;
            }
            
            public  Map<String, String> displayProductVariant(String selectedProductId, String recordTypeName) {
                List<SelectOption> variants = new List<SelectOption>();
                Map<String, String> proVarList = new Map<String, String>();
                if('IPS_Case_Create'.equalsIgnoreCase(recordTypeName)) {
                    variants = Product_Variant_Utility.displayProductVariant(selectedProductId);
                } else if('Core_IPS_Case_Create_Self_Assigned'.equalsIgnoreCase(recordTypeName)) {
                    variants = Product_Variant_Utility.displayProductVariant_NAC(selectedProductId);
                }
                for(Integer i=0;variants!=null && i<variants.size();i++){
                    if(!variants.get(i).getDisabled()) {
                        proVarList.put(variants.get(i).getLabel(), variants.get(i).getValue());
                    }
                }
                return proVarList;
            }
            
            public List<String> getProjectList(String relatedId){
                List<user> faeUsers = new List<User>();
                List<user> u = new List<User>();
                List<String> projIdList = new List<String>();
                if(relatedId.startswith('003')) {
                    u = [select id from user where contactId=:relatedId];
                } else {
                    faeUsers = [select id from user where ID=:UserInfo.getUserId()];
                }
                List<Core_ips_Project__Share> projMembers=new List<Core_ips_Project__Share>();
                //Avoid Deeply Nested IF Statements - Kamala
                //FLS fix added by Yasasvi
                if((faeUsers <> null && faeUsers.size() > 0) &&(Schema.sObjectType.Core_ips_Project__share.isAccessible())){
                    projMembers = [select parentid from Core_ips_Project__share where userorgroupId =:faeUsers[0].id and parent.core_status__c='Active'];
                }
                //Avoid Deeply Nested IF Statements - Kamala
                //FLS fix added by Yasasvi
                if((u <> null && u.size() > 0) && (Schema.sObjectType.Core_ips_Project__share.isAccessible())){
                        projMembers = [select parentid from Core_ips_Project__share where parent.core_status__c='Active' AND userorgroupId in (SELECT groupid FROM GroupMember where userorgroupid=:u[0].id)];
                }
                
                if(projMembers <> null && projMembers.size() > 0){
                    for(Core_ips_Project__share member: projMembers) {
                        if(member.parentid!=null) {
                            projIdList.add(member.parentid);
                        }
                    }
                }
                
                return projIdList;
            }
            
            
            public List<DynamicField>  getDynmicFields(List<Core_IPS_EnvironmentDetailQuestion> edqs){
                
                List<DynamicField> fields = new List<DynamicField>();
                if(edqs == null){
                    return fields;
                }
                
                for(Core_IPS_EnvironmentDetailQuestion edq : edqs ){
                    if(edq.isVisible){ // only visible questions has to pass to LWC component to render
                        string selectedvalue = edq.selectedValue;
                        if(selectedvalue == null){
                            selectedvalue='';
                            if(edq.splaceholder != null){
                                selectedvalue = edq.splaceholder;
                            }else if(edq.tplaceholder != null){
                                selectedvalue = edq.tplaceholder;
                            }else if(edq.selectedMValue != null){
                                for(Integer i=0 ; i<edq.selectedMValue.size(); i++){
                                    if(i == (edq.selectedMValue.size()-1)){
                                        selectedvalue = selectedvalue + edq.selectedMValue.get(i);
                                    } else{
                                        selectedvalue = selectedvalue + edq.selectedMValue.get(i)+';';
                                    }
                                }
                                
                            }
                        }
                        DynamicField dField = new DynamicField( edq.hasChildQuestions, edq.type,  edq.label, edq.lwcplaceholder ,
                        edq.required,  edq.splaceholder,  edq.questionId, selectedvalue, null);
                        
                        Fields.add(dField);
                        
                    }
                }
                return fields;
            }
            
            
            public Case SubmitCaseRecord(Case newRecord, Contact contactRecord, String caseEDQdata){
                boolean isProductChanged = false;
                String countryRegion;
                system.debug('955-helper');
                Id recordTypeIdGEC = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();
                Map<String, embargo_country__mdt> embargoCountry = embargo_country__mdt.getAll();
                if(newRecord.Core_IPS_Country_Region__c!=null){
                    countryRegion = newRecord.Core_IPS_Country_Region__c.replaceAll('[^a-zA-Z0-9]', '_');
                }
                
                if(embargoCountry.containsKey(countryRegion)) {
                    if(embargoCountry.get(countryRegion).State__c == null || embargoCountry.get(countryRegion).State__c == '') {
                        newRecord.Core_IPS_GEC_Flag__c = true;
                        newRecord.IsStopped = true;
                        newRecord.Status = 'On Hold';
                        newRecord.Core_Sub_Status__c = 'GEC Hold';
                        newRecord.recordtypeID =  recordTypeIdGEC;
                    } else{
                        List<String> state = embargoCountry.get(countryRegion).State__c.split(',');
                        if(state.contains(newRecord.Core_IPS_Embargoed_State__c)) {
                            newRecord.Core_IPS_GEC_Flag__c = true;
                            newRecord.IsStopped = true;
                            newRecord.Status = 'On Hold';
                            newRecord.Core_Sub_Status__c = 'GEC Hold';
                            newRecord.recordtypeID =  recordTypeIdGEC;
                        }
                    }
                }
                if(newRecord.ContactId != null && (newRecord.Core_IPS_Country_Region__c != null || newRecord.Core_IPS_Embargoed_State__c != null)) {
                    Boolean needUpdate = false;
                    Contact toUpdateCon;
                    if(Contact.SObjectType.getDescribe().isAccessible()) {
                        toUpdateCon = [Select Id,Core_Country_Region__c,Core_IPS_Embargoed_State__c From Contact Where Id = :newRecord.ContactId];
                    }
                    if(toUpdateCon != null && (toUpdateCon.Core_Country_Region__c==null || toUpdateCon.Core_Country_Region__c=='') && Schema.sObjectType.Contact.fields.Core_Country_Region__c.isUpdateable()) {
                        toUpdateCon.Core_Country_Region__c= newRecord.Core_IPS_Country_Region__c;
                        needUpdate = true;
                    }
                    if(toUpdateCon != null && newRecord.Core_IPS_Embargoed_State__c != null && (toUpdateCon.Core_IPS_Embargoed_State__c == null || toUpdateCon.Core_IPS_Embargoed_State__c == '') && Schema.sObjectType.Contact.fields.Core_IPS_Embargoed_State__c.isUpdateable()) {
                        toUpdateCon.Core_IPS_Embargoed_State__c = newRecord.Core_IPS_Embargoed_State__c;
                        needUpdate = true;
                    }
                    if(needUpdate) {
                        Core_IPS_AdminUtility.updateContact(toUpdateCon);
                    }
                }
                if(newRecord.Core_Issue_Description__c != null) {
                    string strDescValue;
                    strDescValue =  Core_Utility.replaceSpecialChar(newRecord.Core_Issue_Description__c);
                    if (Schema.sObjectType.Case.fields.Description.isCreateable()||Schema.sObjectType.Case.fields.Description.isUpdateable()) {
                        newRecord.Description = Core_Utility.replaceHtmlTags(strDescValue);
                    }
                    
                }
                List<case> csLst;
                if(string.isNOTBlank(''+newRecord.id)) {
                    csLst = [select id ,AssetId from case where id =:newRecord.id];
                    if(!csLst.isEmpty() && csLst[0].assetId != newRecord.assetId ) {
                        isProductChanged = true;
                    }
                }
                // upsert newRecord;
                Case upsertedCase = Core_IPS_AdminUtility.createCase(newRecord);
                // commented as part of code refactor beacause of we are not using this map
                /*  List<Core_IPS_Response__c> existingEDQResponses = Core_IPS_Questions_Utility.getEnvDetailCoreResponse(upsertedCase.id);
                Map<Id,ID> questionResponseMap = new Map<Id, id>();
                for(Core_IPS_Response__c response : existingEDQResponses){
                    questionResponseMap.put(response.Core_IPS_Question_Master__c, response.id);
                }*/
                String lsListString = JSON.serialize(caseEDQdata);
                system.debug('lsListString'+lsListString);
                List<Core_IPS_Response__c> getResponse = new List<Core_IPS_Response__c>();
                List<LWCResponseEDQ>  classTwoWrap = LWCResponseEDQ.parse(caseEDQdata);
                String userProfile = getCurrentUserProfileName();
                
                
                Map<Id,Boolean> agentEDQMap = new Map<Id,Boolean>();
                List<Core_IPS_Assigned_Environment_Variables__c> edqList;
                List<Core_IPS_Response__c> coreResponse;
                List<LWCResponseEDQ> agentEDQ = new List<LWCResponseEDQ>();
                String s = '[';
                
                if(userProfile == 'IPS Agent-Partner'){
                    String supportedProdId;
                    if(newRecord.AssetId!=null){
                        supportedProdId = core_IPS_caseCreate_LEX.getSupportedProd(newRecord.AssetId);
                    }
                    else{
                        //fls-fix applied --Suresh-- 28/11/2022
                        Case cs=new Case();
                        if (Schema.sObjectType.Case.isAccessible()){
                            cs = [Select Id,Core_IPS_Supported_Product__c FROM Case where Id=:newRecord.id LIMIT 1];
                        }
                        if(cs.Core_IPS_Supported_Product__c!=null){
                            supportedProdId = cs.Core_IPS_Supported_Product__c;
                        }
                    }
                    
                    edqList = [select id,Core_IPS_Question__c,Core_IPS_Question_Text__c,Core_Agent_Only__c from Core_IPS_Assigned_Environment_Variables__c where Core_Supported_Product__c =:supportedProdId  OR Core_Product_Issue_Sub_Category__c =: newRecord.Core_Case_Issue_Sub_Category__c ];
                    
                    
                    for (integer i=0; i<edqList.size(); i++) {
                        agentEDQMap.put(edqList[i].Core_IPS_Question__c,edqList[i].Core_Agent_Only__c);
                    }
                }
                if(userProfile == 'Partner' || userProfile == 'IPS External Customer'){
                    if(Core_IPS_Response__c.SObjectType.getDescribe().isAccessible()){
                        coreResponse = [SELECT Id,Core_IPS_Answer__c,Core_IPS_Question__c,Core_IPS_Question_Master__r.Core_IPS_Required__c,Core_IPS_Question_Master__r.Core_IPS_Datatype__c,Core_IPS_Question_Master__c,Core_IPS_Answer_Master__c,Core_IPS_Agent_Only__c FROM Core_IPS_Response__c WHERE Core_IPS_Case__c=:newRecord.id AND Core_IPS_Question_Master__r.RecordType.DeveloperName='EDQ'];
                    }
                    for (integer i=0; i<coreResponse.size(); i++) {
                        agentEDQMap.put(coreResponse[i].Core_IPS_Question_Master__c,coreResponse[i].Core_IPS_Agent_Only__c);
                        if (coreResponse[i].Core_IPS_Agent_Only__c) {
                             /*** Commented By Gagan ***/
                            String edqAns;
                            String tempVal= coreResponse[i].Core_IPS_Answer_Master__c;
                            if(tempVal == null || tempVal == '' || String.isBlank(tempVal) ){
                                    edqAns = coreResponse[i].Core_IPS_Answer__c;
                            }
                            else{
                                    edqAns = coreResponse[i].Core_IPS_Answer_Master__c;
                            }

                            /*** Avoid Nested If - Added By Gagan Start***/
                            // String tempVal = coreResponse[i].Core_IPS_Answer_Master__c;
                            // String edqAns = coreResponse[i].Core_IPS_Answer__c;
                            
                            // if (tempVal != null && tempVal != '' && !String.isBlank(tempVal)) {
                            //     edqAns = tempVal;
                            // }
                            /*** Avoid Nested If - Added By Gagan End***/
                    s += '{"edq": [{ "qquestion": '+'"'+coreResponse[i].Core_IPS_Question_Master__c+'"'+', "llabel": '+'"'+coreResponse[i].Core_IPS_Question__c+'"'+', "vvalue": '+'"'+edqAns+'"'+', "rrequired": '+coreResponse[i].Core_IPS_Question_Master__r.Core_IPS_Required__c+', "ttype": '+'"'+coreResponse[i].Core_IPS_Question_Master__r.Core_IPS_Datatype__c+'"'+' }]},';
                    
                }
            }
            s = s.removeEnd(',');
            s+=']';
            List<LWCResponseEDQ> classTwoWrap1 = LWCResponseEDQ.parse(s);
            if(classTwoWrap1.size()>0){
                classTwoWrap.addAll(classTwoWrap1);
            }
        }
        
        if(!Test.isRunningTest()){
            for(LWCResponseEDQ c: classTwoWrap){
                Core_IPS_Response__c newres = new Core_IPS_Response__c(Core_IPS_Case__c = upsertedCase.Id);
                //if (Schema.sObjectType.Core_IPS_Response__c.fields.Core_IPS_Question_Master__c.isCreateable()) {
                    newres.Core_IPS_Question_Master__c = c.edq[0].qquestion;
                //}
                if(agentEDQMap.containsKey(c.edq[0].qquestion)){
                    newres.Core_IPS_Agent_Only__c = agentEDQMap.get(c.edq[0].qquestion);
                }
                
                if(c.edq[0].ttype == 'Multiselect Picklist' || c.edq[0].ttype == 'Picklist') {
                    // commented this logic as part of Store Empty EDQs
                    //  if(c.edq[0].vvalue == null || c.edq[0].vvalue == '' || String.isBlank(c.edq[0].vvalue ) {
                    // } else {
                        if(c.edq[0].ttype == 'Multiselect Picklist') {
                            List<String> lstStringmul = c.edq[0].vvalue.split(',');
                            for(String vb : lstStringmul) {
                                Core_IPS_Response__c newresaddmulti = new Core_IPS_Response__c();
                                newresaddmulti.Core_IPS_Question_Master__c = c.edq[0].qquestion;
                                //if (Schema.sObjectType.Core_IPS_Response__c.fields.Core_IPS_Answer_Master__c.isCreateable()) {
                                    // newresaddmulti.Core_IPS_Answer_Master__c = vb; // Commented this line as part of Store Empty EDQs
                                //}
                                // added this logic as part of Store Empty EDQs
                                if(String.isBlank(vb)){
                                    newresaddmulti.Core_IPS_Answer_Master__c = null;
                                }else {
                                    newresaddmulti.Core_IPS_Answer_Master__c = vb;
                                }
                                newresaddmulti.Core_IPS_Case__c = upsertedCase.Id;
                                getResponse.add(newresaddmulti);
                            }
                        } else {
                            //newres.Core_IPS_Answer_Master__c = c.edq[0].vvalue; // Commented this line as part of Store Empty EDQs
                            //Added by chiru
                           // Commented By Gagan
                            if(String.isBlank(c.edq[0].vvalue)){
                                newres.Core_IPS_Answer_Master__c = null;
                            }else {
                                newres.Core_IPS_Answer_Master__c = c.edq[0].vvalue;
                            }
                            /** Avoided Nested If Gagan Start */
                            // newres.Core_IPS_Answer_Master__c =
                            //     String.isBlank(c.edq[0].vvalue) ? null : c.edq[0].vvalue;
                            /** Avoided Nested If Gagan End */
                            // END
                            getResponse.add(newres);
                        }
                    //  }  // Commented this line as part of Store Empty EDQs
                    
                    
                }
                
                if(c.edq[0].ttype == 'Text Area' || c.edq[0].ttype == 'Text' ){
                    // Commented this line as part of Store Empty EDQs
                    // if(c.edq[0].vvalue == null || c.edq[0].vvalue == '' || String.isBlank(c.edq[0].vvalue)) {
                    // }
                    //  else {
                        // if (Schema.sObjectType.Core_IPS_Response__c.fields.Core_IPS_Answer__c.isCreateable()) {
                            // newres.Core_IPS_Answer__c = c.edq[0].vvalue; // Commented this line as part of Store Empty EDQs
                            //added logic by chiru
                            // Commented By Gagan
                            if(String.isBlank(c.edq[0].vvalue)){
                                newres.Core_IPS_Answer__c = null;
                            }else {
                                newres.Core_IPS_Answer__c = c.edq[0].vvalue;
                            }
                            /** Avoided Nested If Gagan Start */
                            // newres.Core_IPS_Answer_Master__c =
                            //     String.isBlank(c.edq[0].vvalue) ? null : c.edq[0].vvalue;
                            /** Avoided Nested If Gagan End */
                        //}
                        
                        getResponse.add(newres);
                    // }
                }
            }
            
        }
        
        
        Core_IPS_AdminUtility.upsertEnvDetailsToCreate(getResponse,upsertedCase.Id, isProductChanged);
        return upsertedCase;
    }
    
    
    
    
    public class DynamicField {
        @AuraEnabled public boolean hasChild = false;
        @AuraEnabled public  string type = '';
        @AuraEnabled public  string label = '' ;
        @AuraEnabled public  List<CustomSelectOptions>lovs = new List<CustomSelectOptions>();
        @AuraEnabled public  boolean required = false;
        @AuraEnabled public  string palceholderText = '';
        @AuraEnabled public  string id = '';
        @AuraEnabled public  string value= '';
        @AuraEnabled public  List<string> mValue;
        @AuraEnabled public  string responseId = '';
        
        public DynamicField(boolean hasChild, string type, string label, List<CustomSelectOptions>lovs,
        boolean required, string palceholderText, string id, string value, string responseId ){
            
            this.hasChild = hasChild;
            this.type = type;
            this.label = label ;
            this.lovs = lovs ;
            this.required = required;
            this.palceholderText = palceholderText ;
            this.id = id;
            if(type == 'Multiselect Picklist'){
                this.mValue = value.split(';');
            }else{
                this.value = value;
            }
            this.responseId = responseId ;
            
        }
        
    }
    // Added  by Ganapati for LEX: copy case functionality
    
    /*Start -- Tushar -- 12/05/2026 --- Added CRUD as part of vulnerability fix. */
    public static void copyInterestedParties(String parentCaseId, String caseId) { 
        List<Core_IPS_Case_Interested_Party__c> newPartyList = new List<Core_IPS_Case_Interested_Party__c>();
        if (Schema.sObjectType.Core_IPS_Case_Interested_Party__c.isAccessible()) {
            for(Core_IPS_Case_Interested_Party__c party : [SELECT User__c,Active__c,Contact__c,Type__c FROM Core_IPS_Case_Interested_Party__c WHERE Case__c=:parentCaseId WITH USER_MODE]){
                Core_IPS_Case_Interested_Party__c newParty =  new Core_IPS_Case_Interested_Party__c();
                //if(Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Case__c.isCreateable()){
                    newParty.Case__c = caseId;
                //}
                //if(Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.User__c.isCreateable()){
                    newParty.User__c = party.User__c;
                //}
                //if(Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Active__c.isCreateable()){
                    newParty.Active__c = party.Active__c;
                //}
                //if(Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Contact__c.isCreateable()){
                    newParty.Contact__c = party.Contact__c;
                //}
                //if(Schema.sObjectType.Core_IPS_Case_Interested_Party__c.fields.Type__c.isCreateable()){
                    newParty.Type__c = party.Type__c;
                //}
                newPartyList.add(newParty);
            }
        }
        if(newPartyList.size()>0){
            //if(Schema.sObjectType.Core_IPS_Case_Interested_Party__c.isCreateable()){
                Core_IPS_AdminUtility.insertInterestedParties(newPartyList);
            //}
        }
    }
    /*End -- Tushar -- 12/05/2026 --- Added CRUD as part of vulnerability fix. */
    public static String getErrorMessage(string errorCode){
        string defaultmessage ='';
        //Avoid Deeply Nested IF Statements - Kamala
        if((Core_IPS_Error_Code__c.getinstance(errorCode)!=null) && (Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c!=null)){
                defaultmessage = Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c;
        }
        return defaultmessage;
    }
    
    public static List<String> readFieldSet(String fieldSetName, String objectApiName){
        List<String> fieldList = new List<String>();
        for(Schema.FieldSetMember fieldSetMemberObj : Core_Utility.readFieldSet(fieldSetName, objectApiName)) {
            fieldList.add(fieldSetMemberObj.getFieldPath());
        }
        return fieldList;
    }
    
    public static List<String> getProjectListFromAsset(String prodId) {
        List<Id> prjIdList = new List<Id>();
        /// Mohan code fix for null getting in prodId Line no 1240 - 1260
        if(prodId != '' && prodId != null){
            Boolean isAsset = String.valueOf(prodId).substring(0,3) == '02i' ? true:false;
            List<Asset> astList = new List<Asset>();
            if(isAsset){
                if (Schema.sObjectType.Asset.isAccessible()){
                    astList = [select Id,Core_IPS_Project__c,Core_Supported_Product__r.Core_IPS_Public_Product__c from Asset where Id =:prodId and Core_Supported_Product__r.Core_IPS_Public_Product__c = false LIMIT 1];
                }
            }
            else{
                if (Schema.sObjectType.Asset.isAccessible()){
                    astList = [select Id,Core_IPS_Project__c,Core_Supported_Product__r.Core_IPS_Public_Product__c from Asset where Core_Supported_Product__c =:prodId and Core_Supported_Product__r.Core_IPS_Public_Product__c = false  LIMIT 100];
                }
            }
            
            for(Asset astObj:astList){
                if(astObj.Core_IPS_Project__c <> null) {
                    prjIdList.add(astObj.Core_IPS_Project__c);
                }
            }
        }
        return prjIdList;
    }
    
    public static Set<Id> getAccountList() {
        Set<Id> accountIdSet = new Set<Id>();
        List<AccountTeamMember>  atmList = [select UserId,AccountId from AccountTeamMember where UserId =:System.UserInfo.getUserId() AND User.Profile.Name in:Label.Core_IPS_Sales_Profile_List.split(',')];
        for(AccountTeamMember atmObj:atmList){
            accountIdSet.add(atmObj.AccountId);
        }
        Map<Id,Account> accMap = new Map<Id,Account>([Select Id from Account where OwnerId =:System.UserInfo.getUserId() AND Owner.Profile.Name in:Label.Core_IPS_Sales_Profile_List.split(',')]);
        if(accMap <> null && accMap.size() > 0){
            accountIdSet.addAll(accMap.keyset());
        }
        return accountIdSet;
    }
    
    public static Set<Id> getContactListFromAsset(String productId) {
        Set<Id> cIdList = new Set<Id>();
        try{
            Asset astObj=new Asset();
            
            if (Schema.sObjectType.Asset.isAccessible()){
                astObj = [SELECT Id,accountId,ContactId,Core_IPS_Project__c ,Core_Supported_Product__r.Core_IPS_Public_Product__c FROM Asset WHERE Id =:productId AND Core_Supported_Product__r.Core_IPS_Public_Product__c = false];
            }
            if(astObj <> null && astObj.AccountId <> null){
                if (Schema.sObjectType.Contact.isAccessible()){ //FLS Read fix applied - Gangadhar 18/10/2022
                    for(Contact conObj:[SELECT Id FROM Contact WHERE AccountId =: astObj.AccountId]){
                        cIdList.add(conObj.Id);
                    }
                }
            }
            if(astObj <> null && astObj.Core_IPS_Project__c <> null){
                if (Schema.sObjectType.Core_IPS_Project_Member__c.isAccessible()){
                    for(Core_IPS_Project_Member__c cpmObj:[
                        SELECT 
                        Core_IPS_Contact__c,Core_IPS_Project__c 
                        FROM Core_IPS_Project_Member__c 
                        WHERE Core_IPS_Project__c =:astObj.Core_IPS_Project__c 
                        AND Core_Status__c = 'Active'
                    ]){
                        if(cpmObj.Core_IPS_Contact__c <> null) {
                            cIdList.add(cpmObj.Core_IPS_Contact__c);
                        }
                    }
                }
            }
        }catch(exception e){
        }
        return cIdList;
    }
    
    public static Set<Id> getContactListFromProject(String projectId) {
        Set<Id> cIdList = new Set<Id>();
        if (Schema.sObjectType.Core_IPS_Project_Member__c.isAccessible()) {
            
            for(Core_IPS_Project_Member__c cpmObj : [
                SELECT 
                Core_IPS_Contact__c, Core_IPS_Project__c 
                FROM Core_IPS_Project_Member__c 
                WHERE Core_IPS_Project__c =:projectId 
                AND Core_Status__c = 'Active']
            ){
                if(cpmObj.Core_IPS_Contact__c <> null) {
                    cIdList.add(cpmObj.Core_IPS_Contact__c);
                }
            }
        }
        
        return cIdList;
    }
    
    public static String getCurrentUserProfileName() {
        return [SELECT Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
    }
    
    
    
    public String getButtonsVisibility(String caseId) {
        string visibleButtons = '';
        
        String systemAdminProfile = system.label.Core_IPS_System_Admin_Profile_Name;
        String itAdminProfile = system.label.Core_IPS_IT_Admin_Profile;
        String productionSupportProfile = system.label.Core_IPS_Production_Support_IPS_Profile;
        String salesRepBbProfile = system.label.Core_IPS_Sales_Rep_BB_Profile;
        String dualIpsProfile = system.label.Core_IPS_Sales_Rep_BB_Dual_IPS_Profile;
        String ipsAgentProfile = system.label.Core_IPS_Agent_Profile;
        String agentEnhancedProfile = system.label.Core_IPS_Agent_Enhanced_Profile;
        String supportOrgAdmin = system.label.Core_IPS_Support_Org_Admin_Profile;
        String dataOpsProfile = system.label.Core_Data_Ops_Profile_Name;
        String salesOpsProfile = system.label.Core_IPS_Sales_Ops_Profile_Name;
        String salesRepCWProfile = system.label.Core_IPS_Sales_RepCW_Profile_Name;
        String salesManagerProfile = system.label.Core_IPS_Sales_Manager_Profile_Name;
        
        String nacStr = system.label.Core_IPS_NoAssignedContactRecordType_Name;
        String ipsCaseCreateStr = system.label.Core_IPS_CaseCreateRecordType_Name;
        String ipsCloseCaseStr = system.label.Core_IPS_ClosedCase_RecordType_Name;
        String ipsGecReadOnlyStr = system.label.Core_IPS_GECRecordTypeName;
        
        String profileName = [SELECT Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
        
        Case caseRec=new Case();
        if (Schema.sObjectType.case.isAccessible()) {
            caseRec = [select id, recordType.DeveloperName,Status,Core_Sub_Status__c from case where id = :caseId];
        }
        
        String recordTypeName = caseRec.recordType.DeveloperName;
        
        if(profileName == systemAdminProfile || profileName ==  itAdminProfile || profileName == productionSupportProfile||profileName == dataOpsProfile|| recordTypeName == ipsGecReadOnlyStr || profileName == supportOrgAdmin){
            if((caseRec.Core_Sub_Status__c == 'GEC Hold' && caseRec.Status == 'On Hold') || (caseRec.Status == 'Closed' && caseRec.Core_Sub_Status__c == 'GEC Hold')){
                visibleButtons = 'Case Comment,Invalid,';
                return visibleButtons;
            }
            else if(caseRec.Core_Sub_Status__c != 'Invalid' && caseRec.Status != 'Closed'){
                visibleButtons = 'Edit,Copy,Accept,Request Closure,Export PDF,Invalid,Interested Parties,Case Comment,';
                return visibleButtons;
            } else if(caseRec.Core_Sub_Status__c == 'Invalid' || caseRec.Status == 'Closed' || caseRec.Core_Sub_Status__c == 'Closed') {
                visibleButtons = 'Edit,Copy,Export PDF,';
            }
            
        }
        if(profileName == salesRepBbProfile || profileName == dualIpsProfile  || profileName == ipsAgentProfile ||   profileName == agentEnhancedProfile ||
        profileName == supportOrgAdmin|| profileName == salesOpsProfile || profileName == salesRepCWProfile || profileName == salesManagerProfile){
            if( (recordTypeName == ipsCaseCreateStr || recordTypeName == ipsCloseCaseStr || recordTypeName == nacStr) ){
                visibleButtons = visibleButtons + 'Edit,Copy,Export PDF,';
            }
            if((recordTypeName == ipsCaseCreateStr || recordTypeName == nacStr) && profileName != salesRepBbProfile && profileName != salesOpsProfile  && profileName != salesRepCWProfile && profileName != salesManagerProfile){
                visibleButtons = visibleButtons + 'Accept,Request Closure,';
            }
            if( (recordTypeName == ipsGecReadOnlyStr || recordTypeName == ipsCaseCreateStr ||
            recordTypeName == ipsCloseCaseStr || recordTypeName == nacStr || profileName == supportOrgAdmin) ){
                if(profileName == salesRepBbProfile || profileName == salesOpsProfile || profileName == salesRepCWProfile || profileName == salesManagerProfile )
                    visibleButtons = visibleButtons + 'Case Comment,';
                else if(recordTypeName != ipsCloseCaseStr && profileName != dualIpsProfile)
                    visibleButtons = visibleButtons + 'Case Comment,Invalid,';
            }
        }
        
        if((profileName == salesRepBbProfile  || profileName == salesOpsProfile || profileName == salesRepCWProfile || profileName == salesManagerProfile) && (recordTypeName == ipsCaseCreateStr || recordTypeName == ipsCloseCaseStr || recordTypeName == nacStr) ){
            visibleButtons = visibleButtons + 'Case Close,';
        }
        
        if((profileName == dualIpsProfile  || profileName == ipsAgentProfile || profileName == agentEnhancedProfile)){
            if( (recordTypeName == ipsCaseCreateStr || (recordTypeName == ipsCloseCaseStr  && profileName != dualIpsProfile && profileName != ipsAgentProfile && profileName != agentEnhancedProfile) || recordTypeName == nacStr || profileName == supportOrgAdmin) ){
                visibleButtons = visibleButtons + 'Accept,Request Closure,Case Comment,Invalid,';
            }
        }
        if(profileName == 'Global Export Compliance'){
            if(recordTypeName == ipsCloseCaseStr){
                visibleButtons = 'Edit,Copy,Export PDF,';
            }
            else{
                visibleButtons = 'Case Comment,Invalid,';
            }
        }
        return visibleButtons;
    }
    
    public List<CustomSelectOptions> getPSAOptions(String selectedcontId,String selectedprojId,String selectedPSOId){
        
        List<CustomSelectOptions> PSAOptions = new List<CustomSelectOptions>();
        Set<Id> userIds = new Set<Id>();
        for(PermissionSetAssignment uId: [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :System.Label.Core_IPS_Partner_DFAE_Permission_Set AND Assignee.ProfileId = :System.Label.Core_IPS_Partner_Profile_Id]){
            userIds.add(uId.AssigneeId);
        }
        
        //Senario 1:Project Based Cases - When editing the Partner Supported Account field, the picklist will only show accounts associated to project on the case
        List<Core_IPS_Project_Member__c> projMem = new List<Core_IPS_Project_Member__c>();
        if(selectedprojId <> '' && selectedprojId != null){
            //List of all Active project members whose profile is Agent Partner profile or FAE Partner permission set
            if (Schema.sObjectType.account.isAccessible()){	 //FLS Read fix applied - Gangadhar 18/10/2022
                projMem =[SELECT id 
                                                       FROM Core_IPS_Project_Member__c
                                                       WHERE (Core_User__c IN :userIds OR
                                                              Core_User__r.ProfileId = :system.Label.Core_IPS_Agent_Partner_Profile_id) AND
                                                       Core_IPS_Project__c =: selectedprojId AND
                                                       Core_Status__c = 'Active'];
            }
            
            if(projMem != null && !projMem.isEmpty()){
                PSAOptions.add(new CustomSelectOptions('--None--','--None--'));
                List<Account> lstAcc=new List<Account>();
                if (Schema.sObjectType.account.isAccessible()){
                    lstAcc = [SELECT id,Name FROM account
                              WHERE Id IN (SELECT Core_Account__c FROM Core_IPS_Account__c 
                                           WHERE Core_IPS_Project__c =:selectedprojId AND 
                                           Core_Status__c = 'Active')];
                }
                for(Account acc : lstAcc){
                    PSAOptions.add(new CustomSelectOptions(acc.Name,acc.id));
                }
            }
        }
        //Senario 2: When editing the Partner Supported Account field, the picklist should display all Accounts associated with all projects in which the PSO is a member.
        else if(selectedcontId != '' && selectedcontId != null){
            
            Id AcctId;
            for(Contact c: [SELECT AccountId FROM Contact WHERE Id =: selectedcontId and Core_IPS_Active__c = True]){
                AcctId = c.AccountId;
            }
            
            if(AcctId != null){
                List<User> lstAcctUser= [SELECT id FROM User WHERE isActive=True AND 
                                         (Id IN :userIds OR ProfileId = :system.Label.Core_IPS_Agent_Partner_Profile_id) AND 
                                         Contact.AccountId =: AcctId];
                
                
                if(lstAcctUser != null && !lstAcctUser.isEmpty()){
                    PSAOptions.add(new CustomSelectOptions('--None--','--None--'));
                    if(selectedPSOId != null && selectedPSOId != ''){
                        
                        set<Id> allProjIds = new set<Id>();
                        if (Schema.sObjectType.Core_IPS_Project__c.isAccessible() && Schema.sObjectType.Core_IPS_Project_Member__c.isAccessible()){ //FLS Read fix applied - Gangadhar 18/10/2022
                            for(Core_IPS_Project__c project: [SELECT id FROM Core_IPS_Project__c WHERE id IN (SELECT Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_User__c = :selectedPSOId AND Core_Status__c = 'Active')]){
                                allProjIds.add(project.Id);
                            }
                        }
                        List<Account> lstAcc=new List<Account>();
                        if (Schema.sObjectType.account.isAccessible()) {
                            lstAcc = [SELECT id,Name FROM account
                                      WHERE id IN (SELECT Core_Account__c FROM Core_IPS_Account__c 
                                                   WHERE Core_IPS_Project__c IN :allProjIds AND Core_Status__c = 'Active')];
                        }
                        
                        for(Account acc : lstAcc){
                            PSAOptions.add(new CustomSelectOptions(acc.Name,acc.id));
                        }
                    }
                }
            }
        }
        return PSAOptions;
    }
}