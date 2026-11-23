/*********************************************
* Name : core_IPS_caseCreate_formController 
* Author : Chandrashekar Pallikonda
* Date Created : 30/09/21
* Description : This class is the controller for new portal case creation.
* Test Class :  
*   
************************************************/
public without sharing class core_IPS_caseCreate_formController {
    private static final String PARTITION_NAME = system.label.Core_IPS_Platform_Cache_Name;
    @AuraEnabled
    public Boolean isAgent;
    @AuraEnabled
    public Boolean blnShowVariant;
    @AuraEnabled
    public Boolean showGECFields;
    @AuraEnabled
    public Boolean displayPopup;
    @AuraEnabled
    public Boolean displayEnvDetails;
    @AuraEnabled
    public Boolean displayCategories;
    @AuraEnabled
    public Boolean displaySubCategories;
    @AuraEnabled
    public Boolean renderErrorFlag;
    @AuraEnabled
    public Boolean displaySelfAssigned;
    @AuraEnabled
    public Boolean caseInformationReadOnly;
    @AuraEnabled
    public Boolean displayPriorityReason;
    @AuraEnabled
    public Boolean hasProject;
    @AuraEnabled
    public Boolean isEditable;
    @AuraEnabled
    public Boolean isclosed;
    @AuraEnabled
    public Boolean isMigratedSource;
    @AuraEnabled
    public Boolean isPartnerFAE;
    @AuraEnabled
    public Boolean isPartnerAgent;
    @AuraEnabled
    public Boolean hideSubCat;
    @AuraEnabled
    public Boolean displayPlatform;
    @AuraEnabled
    public Boolean showProductRelInfoDialog;
    @AuraEnabled
    public String categorySelected;
    @AuraEnabled
    public String selectedVariant;
    @AuraEnabled
    public String GECAnswer1;
    @AuraEnabled
    public String GECAnswer2;
    @AuraEnabled
    public String GECAnswer3;
    @AuraEnabled
    public String subject;
    @AuraEnabled
    public String sbs;
    public String retURL=null;
    @AuraEnabled
    public String productSearchIframeUrl;
    @AuraEnabled
    public String accSelected;
    @AuraEnabled
    public String selectedAccountId;
    @AuraEnabled
    public String selectedProject;
    @AuraEnabled
    public String selectedProduct;
    @AuraEnabled
    public String selectedProductId;
    @AuraEnabled
    public String selectedSAProductId;
    @AuraEnabled
    public String selectedContactId;
    @AuraEnabled
    public String selectedProjId;
    @AuraEnabled
    public String selectedProjectName;
    @AuraEnabled
    public String mode;
    @AuraEnabled
    public String csId;
    @AuraEnabled
    public String objectSelected;
    @AuraEnabled
    public String subCategorySelected;
    @AuraEnabled
    public String subCategorySelected_old;
    @AuraEnabled
    public String platformSelected;
    @AuraEnabled
    public String selectedSAProduct;
    public String deflectedId;
    @AuraEnabled
    public String selectedLanguage;
    public Id assetId;
    public static String AssetIdModified=null;
    @AuraEnabled
    public Id productId;
    @AuraEnabled
    public Asset ast;
    @AuraEnabled
    public Case cs;
    public ApexPages.standardController controller{get;set;}
    public Cache.Partition partition = Cache.Session.getPartition(PARTITION_NAME);
    @AuraEnabled
    public List<Core_IPS_EnvironmentDetailQuestion> envDetails;
    @AuraEnabled
    public List<Core_IPS_EnvironmentDetailQuestion> subCatenvDetList;
    @AuraEnabled
    public List<Core_IPS_EnvironmentDetailQuestion> filteredEnvDetails;
    @AuraEnabled
    public List<Core_IPS_EnvironmentDetailQuestion> filteredSubCatenvDetList;
    public static list<Contact> con;
    public List<Asset> astlist;
    public list<SelectOption> answerOptions;
    public List<SelectOption> categoryOptions;
    public List<SelectOption> subCategoryOptions;
    public List<SelectOption> projectList;
    public List<SelectOption> IPSParentAccountList;
    public List<SelectOption> platformOptions;
    public List<SelectOption> variants;
    public List<List<SelectOption>> variantsList;
    public List<SelectOption> languageList;
    public Set<Id> envQuestnIds;
    public String SearchJSONString;
    public Boolean isMindsFlag;
    List<Contact> contactInContext = new List<Contact>();
    public User Usr;
    public String selectedCountry;
    public List<SelectOption> countryOptions;
    
    public void core_IPS_caseCreate_formController(String caseId){
        isMindsFlag = false;
        Usr = [Select id, Name, ContactId, Contact.Name, TimeZoneSidKey from User where id=:UserInfo.getUserId()];
        contactInContext = [Select id, Name,Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c  from Contact where id=: Usr.Contactid limit 1];
        if (contactInContext!=null && !contactInContext.isEmpty()) {
        	if(isMindsFlag!=NULL){              
            	isMindsFlag = contactInContext[0].Core_MINDS__c;
          	 }
          	if(contactInContext[0].Core_Country_Region__c!=NULL || contactInContext[0].Core_Country_Region__c!=''){
            	selectedCountry = contactInContext[0].Core_Country_Region__c ;
          	}
        }
        /*End--US253124--MINDS Case Creation*/
        showProductRelInfoDialog = false;
        this.controller=controller;
        csId = caseId;
        isAgent = Core_IPS_Helper_Utility.isIPSCustomerUser();
        isPartnerAgent = isPartnerAgentUser();
        String deflectedIdEscape = ApexPages.currentPage().getParameters().get('deflectedid');
        deflectedId = (deflectedIdEscape != null)?deflectedIdEscape.escapeHtml4():null; 
        ScreenVisible();
        if(mode=='sNew' && !partition.contains('caseJson'+deflectedId)){
            sbs='pss';
            mode='new';
        }
        Core_IPS_CaseUtility.mode=mode;
        if(apexpages.currentpage().getParameters().get('subject')!=null){
            String subjectEscape = ApexPages.currentPage().getParameters().get('subject');
            subject = (subjectEscape != null)?subjectEscape.escapeHtml4():null;
        }
        //  old iframe url
        // productSearchIframeUrl='https://www.altera.com/bin/search?site=www_sbs&q='+subject+'&btnG=Search+Again&num=10&entqr=3&apps=sbs&output=xml_no_dtd&sort=date%3AD%3AL%3Ad1&ie=UTF-8&client=sbs_www&oe=UTF-8&proxystylesheet=sbs_www&entqrm=0&ud=1&inlang=&ulang=&wc=200&wc_mc=1&entsp=a&SRNo=11321402&SRTitle='+subject+'&AppLang=ENU&ContactId=1-7JYTCP&language=';
        // New Iframe Url
        productSearchIframeUrl=System.Label.Core_IPS_SBS_Iframe_Url;
        //Search Before Submit End Added By Prem  
        envDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        filteredEnvDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        showGECFields = false;
        blnShowVariant =false;
        isMigratedSource=false;
        isPartnerFAE=(Core_Utility.getPartnerUserType(userinfo.getuserId())).contains('Partner - DFAE');
        if(!String.isBlank(csId)){
            isEditable = [SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfo.getuserId() AND RecordId = :csId].HasEditAccess;
        }
        isclosed =false;
        if(csId==null){
            cs = new Case();
            caseInformationReadOnly=false;
            subCategorySelected_old ='';
            if(!isAgent){
                answerOptions = Core_IPS_CaseUtility.getGECanswerOptions();
                showGECFields = Core_IPS_Helper_Utility.isGECAccount();
            }
            if(mode=='new')                
            {
                projectList = Core_IPS_CaseUtility.getIPSProjectList();
                if(projectList <> null && projectList.size() > 2)
                {
                    hasProject = true;
                    selectedProject='NA';
                }
                else
                {
                    hasProject = false;
                }
                IPSParentAccountList=Core_IPS_CaseUtility.getIPSParentAccountList(selectedProject,userinfo.getUserId()); // PRCR_Check
            }else if(mode=='asset'){
                getAssetModeRequiredData();
            }else if(mode=='sslc'){
                setSSLCDefaultdata();
            }
            else if(mode=='iframe'){
                productSearchIframeUrl=String.valueOf(partition.get('iframeURL'+deflectedId));
            }else if(mode=='sNew' && !String.isBlank(deflectedId)){
                getSnewModeRequiredData();
            }
            
        }else if(mode=='edit'){
            getEditModeRequiredData();
        }
    }
    
    @AuraEnabled
    public static void constructorMethod(String caseId){
       	core_IPS_caseCreate_formController obj = new core_IPS_caseCreate_formController();
    }
    //==============================================================================================
    public void ScreenVisible(){
        Boolean isPSGProduct=false;
        Set<String> modeList=new Set<String>{'edit','asset','new','sNew','iframe','sslc'};
            //Deafult 
            sbs='pss';
        mode='new';
        retURL='/IPS/500/o';
        if(apexpages.currentpage().getParameters().get('mode')!=null){
            String modeEscape = ApexPages.currentPage().getParameters().get('mode');
            mode = (modeEscape != null)?modeEscape.escapeHtml4():null;
        }   
        if(apexpages.currentpage().getParameters().get('sbs')!=null){
            sbs=apexpages.currentpage().getParameters().get('sbs');
        }
        if(apexpages.currentpage().getParameters().get('retURL')!=null){
            String retURLEscape = ApexPages.currentPage().getParameters().get('retURL');
            String retURL = (retURLEscape != null)?retURLEscape.escapeHtml4():null;
        }
        // Handling Screen to default when Some trying to change URL Manually
        astlist = [select id, Name,Core_Product_Organization__c,core_supported_product__c,Core_IPS_Project__c,Core_Support_Org_Name__c from asset where id=:apexpages.currentpage().getParameters().get('productId')];    
        if(astlist.size()>0 && System.label.Core_IPS_MAG_Support_Org.Contains((astlist[0].Core_Product_Organization__c+'').substring(0,15))){
            isPSGProduct=true;
        }
        if(mode=='edit'){
            sbs='ccs';
        }
        if(((mode=='asset' && ((sbs !='scs' && sbs !='ccs') || (sbs =='scs' && !isPSGProduct))) || 
            (mode=='new' && sbs !='pss') || 
            (mode=='iframe' && sbs !='ss') ||
            (mode=='sNew' && sbs!='ccs')) || !modeList.contains(mode)){
                sbs='pss';
                mode='new';
         }
    }
    //===========================================================================================================
    public static Boolean isPartnerAgentUser(){
        Boolean isPartnerAgent = false;
        User u = [select Id, username,contactid,Profile.Name from User where Id = :UserInfo.getUserId()];
        if((u.contactid != Null) && (u.Profile.Name ==Label.Core_IPS_Partner_AE_ProfileName)){ // Added by PartnerProfile doc   
            isPartnerAgent=true;
        }else{
            isPartnerAgent=false;
        }
        return isPartnerAgent;
    }
    //==================================================================================================================
    public void getAssetmodeRequiredData(){
        
        caseInformationReadOnly=true;
        String passedprojectIdEscape = ApexPages.currentPage().getParameters().get('projectId');
        String passedprojectId = (passedprojectIdEscape != null)?passedprojectIdEscape.escapeHtml4():null;
        String passedproductIdEscape = ApexPages.currentPage().getParameters().get('productId');
        String passedproductId = (passedproductIdEscape != null)?passedproductIdEscape.escapeHtml4():null;
        //String passedaccountId = String.valueOf(ApexPages.currentPage().getParameters().get('accountId')); //PRCR_Check with Geetha/Raj
        String passedaccountIdEscape = ApexPages.currentPage().getParameters().get('accountId');
        String passedaccountId = (passedaccountIdEscape != null)?passedaccountIdEscape.escapeHtml4():null;
        if(passedprojectId!=null && passedprojectId!=''){
         //US158228 & US240396(26-Dec-18) --22 Nov 2018- add field Core_IPS_Partner_Support_Owner__c--by Orion vamsi
            List<core_ips_project__c> project=[select id,name,Core_IPS_Partner_Support_Owner__c from core_ips_project__c where id=:passedprojectId];
             //Added by Geetha as per US98246
         //Start US158228 & US240396(26-Dec-18) --22 Nov 2018- add by Orion vamsi --to assign PSO as FAE/Agent-Partner values on case at the time of creation
        if(isPartnerAgent || isPartnerFAE){
            if(project[0].Core_IPS_Partner_Support_Owner__c !=null ){ 
                /*US1021248 - 05/26/2021 - Vishal - FLS Check for security vulnerability --*/
             //   if (Schema.sObjectType.Case.fields.Core_IPS_Partner_Sup_Owner__c.isCreateable() || Schema.sObjectType.Case.fields.Core_IPS_Partner_Sup_Owner__c.isUpdateable()) {
                    cs.Core_IPS_Partner_Sup_Owner__c =project[0].Core_IPS_Partner_Support_Owner__c; //PRCR_Change Moving Outside line no. 137  
              //  }
            }
            else{ 
                /*US1021248 - 05/26/2021 - Vishal - FLS Check for security vulnerability --*/
             //   if (Schema.sObjectType.Case.fields.Core_IPS_Partner_Sup_Owner__c.isCreateable() || Schema.sObjectType.Case.fields.Core_IPS_Partner_Sup_Owner__c.isUpdateable()) {
                    cs.Core_IPS_Partner_Sup_Owner__c =userinfo.getuserId();
             //   }
            }
        }
     //End--US158228  & US240396(26-Dec-18) --22 Nov 2018- add by Orion vamsi
            selectedProjectName = project.size()>0?project[0].name:'';
            selectedProject=passedprojectId;
            selectedProjId = passedprojectId;
        }
        IPSParentAccountList=Core_IPS_CaseUtility.getIPSParentAccountList(selectedProject,userinfo.getUserId());
        if(passedproductId!=null && passedproductId!=''){
            ast = [select id, name,core_supported_product__c from asset where id=:passedproductId limit 1];
            selectedProduct = ast.Name;
            selectedProductId=passedproductId;
            selectedVariant=String.valueOf(ApexPages.currentPage().getParameters().get('pv'));
            //displayProductVariant(); 
        }
        if(passedaccountId!=null && passedaccountId!=''){
            accSelected = [select id,name from Core_IPS_Account__c where id=:passedaccountId].Name;
            selectedAccountId = passedaccountId;
        }
        categoryOptions = new List<SelectOption>();
        if(ast!=null && null != ast.core_supported_product__c){ 
            cs.Core_IPS_Supported_Product__c = ast.core_supported_product__c;
            //categoryOptions.add(new SelectOption('', 'Select Category'));
            for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility.getCategories(ast.core_supported_product__c) ){
                categoryOptions.add(new SelectOption(a.id, a.Core_Issue_Category_Name__r.Name));
            } 
            if(categoryOptions.size()>=1){
                Core_Utility.doSort(categoryOptions, Core_Utility.FieldToSort.Label,'Select Category');
                displayCategories=true;
                subCategoryOptions=new List<SelectOption>();
                subCategoryOptions.add(new SelectOption('', '--Select--'));//Geetha
                displaySubCategories=true;
            } 
        }
        // Language picklist added on search criteria screen US106492 Prem
        languageList=new List<SelectOption>();
        /* languageList.add(new SelectOption('en_us', 'English'));
        languageList.add(new SelectOption('zh_cn', 'Simplified Chinese'));
        languageList.add(new SelectOption('ja_jp', 'Japanese'));*/
        
        List<Core_IPS_Language_Picker__c> csLanguageList = Core_IPS_Language_Picker__c.getall().values();
        for(Core_IPS_Language_Picker__c language : csLanguageList) {
        languageList.add(new SelectOption(language.Core_IPS_Language_Code__c, language.name));
        }

        //End
        // Modified By Prem
        //envDetails=getEnvironmentDetailsOperationList(ast.core_supported_product__c,subCategorySelected,isPartnerAgent); 
    }
    //============================================================================================================
    public void setSSLCDefaultdata(){
        sbs='ccs';
        cs=new Case();
        
        caseInformationReadOnly=true;
        Core_IPS_SSLCCase_DefaultData__c ProductData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Supported_Product');
            cs.Core_IPS_Product_name__c=ProductData.Core_IPS_Default_Data__c;


            cs.Core_IPS_Supported_Product__c =ProductData.Core_IPS_Default_data_Id__c;

        //Selected Product
        selectedProduct = cs.Core_IPS_Product_name__c;
        Core_IPS_SSLCCase_DefaultData__c assetData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Asset');
        selectedProductId=assetData.Core_IPS_Default_data_Id__c;
        // Case Description
        Core_IPS_SSLCCase_DefaultData__c caseDescData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Case Description');


            cs.Core_Issue_Description__c=caseDescData.Core_IPS_Default_Data__c;

        // Project 
        Core_IPS_SSLCCase_DefaultData__c ProjectData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Project');


            cs.Core_IPS_Project_Case__c=ProjectData.Core_IPS_Default_data_Id__c;

        if(isPartnerAgent || isPartnerFAE){

                cs.Core_IPS_Partner_Sup_Owner__c =userinfo.getuserId();

        }
        selectedProject=cs.Core_IPS_Project_Case__c;
        IPSParentAccountList=Core_IPS_CaseUtility.getIPSParentAccountList(selectedProject,userinfo.getUserId());
        // Case Type
        Core_IPS_SSLCCase_DefaultData__c CaseTypeData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Case Type');


            cs.Core_CaseType__c=CaseTypeData.Core_IPS_Default_Data__c;

        //Case Issue Source
        Core_IPS_SSLCCase_DefaultData__c IssueSourceData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Issue Source');


            cs.Core_IPS_Issue_source__c=IssueSourceData.Core_IPS_Default_Data__c;

        //Case Category        
        Core_IPS_SSLCCase_DefaultData__c CaseCategoryData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Case Category');


            cs.Core_External_Issue_Category__c=CaseCategoryData.Core_IPS_Default_Data__c;


            cs.Core_Case_Issue_Category__c=CaseCategoryData.Core_IPS_Default_data_Id__c;

        //Case SubCategory
        Core_IPS_SSLCCase_DefaultData__c CaseSubCategoryData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Case Subcategory');


            cs.Core_External_Issue_Subcategory__c=CaseSubCategoryData.Core_IPS_Default_Data__c;


            cs.Core_Case_Issue_Sub_Category__c=CaseSubCategoryData.Core_IPS_Default_data_Id__c;

        if(!String.isBlank(cs.Core_Case_Issue_Category__c)){
            categorySelected=cs.Core_Case_Issue_Category__c;
        }
        if(!String.isBlank(cs.Core_IPS_Supported_Product__c)){    
            categoryOptions=new list<SelectOption>();
            //categoryOptions=getCategoryOptions(cs.Core_IPS_Supported_Product__c);
        }
        if(!String.isBlank(cs.Core_Case_Issue_Sub_Category__c)){
            subCategorySelected=cs.Core_Case_Issue_Sub_Category__c;
            subCategorySelected_old = cs.Core_Case_Issue_Sub_Category__c;
            subCategoryOptions=new list<SelectOption>();
            //subCategoryOptions=getsubCategory_Options(categorySelected);
        }
        // Modified By Prem
        //envDetails=getEnvironmentDetailsOperationList(cs.Core_IPS_Supported_Product__c,subCategorySelected,isPartnerAgent);
        
        Core_IPS_SSLCCase_DefaultData__c EnvDetailsData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Case Subcategory Detail');
        Core_IPS_Response__c lstCoreResponse = new Core_IPS_Response__c();
        lstCoreResponse.Core_IPS_Case__c =null;
        lstCoreResponse.Core_IPS_Answer__c= EnvDetailsData.Core_IPS_Default_Data__c;
        lstCoreResponse.Core_IPS_Question_Master__c= EnvDetailsData.Core_IPS_Default_data_Id__c;
        //setSearchedEnvironmentDetails(envDetails, Json.serialize(new List<Core_IPS_Response__c>{lstCoreResponse})); // Setting Supported Product level Env Details
        //setSearchedEnvironmentDetails(subCatenvDetList, Json.serialize(new List<Core_IPS_Response__c>{lstCoreResponse}));  // Setting Subcategory level Env Details
    }
    //===============================================================================================================
    public void getSnewModeRequiredData(){
        //   Core_IPS_Deflected_Object__c deflectedObj=[select Core_IPS_JSON_Format__c,core_ips_EnvResponse__c from Core_IPS_Deflected_Object__c where id=: deflectedId];
        //cs=(Case)JSON.deserialize((String)partition.get('caseJson'+deflectedId),Case.class);
        cs=(Case)JSON.deserialize(String.valueOf(partition.get('caseJson'+deflectedId)),Case.class);
        ast = [select id, name,core_supported_product__c from asset where id=:cs.assetId limit 1];
        cs.Core_IPS_Supported_Product__c=ast.core_supported_product__c; 
        if(isPartnerAgent || isPartnerFAE){
            cs.Core_IPS_Partner_Sup_Owner__c =userinfo.getuserId();
        }
        caseInformationReadOnly=true;
        showGECFields=false;
        if(!isAgent)//Deflected
        {
            answerOptions = Core_IPS_CaseUtility.getGECanswerOptions();
            showGECFields = Core_IPS_Helper_Utility.isGECAccount();
        }
        if(cs.Core_Case_Issue_Category__c!=null){
            categorySelected=cs.Core_Case_Issue_Category__c;
        }
        if(cs.Core_IPS_Supported_Product__c <> null  /*&& categorySelected <> null && categorySelected <> ''*/){    
            categoryOptions=new list<SelectOption>();
            //categoryOptions=getCategoryOptions(String.valueOf(cs.Core_IPS_Supported_Product__c));
        }
        if(cs.Core_Case_Issue_Sub_Category__c!=null){
            subCategorySelected=String.valueOf(cs.Core_Case_Issue_Sub_Category__c);
            subCategorySelected_old = cs.Core_Case_Issue_Sub_Category__c;
            subCategoryOptions=new list<SelectOption>();
            //subCategoryOptions=getsubCategory_Options(categorySelected);
        }
        if(cs.core_ips_project_case__c!=null ){
            
            selectedProject = String.valueOf(cs.core_ips_project_case__c);
            Core_IPS_Project__c  projObj=[select name from Core_IPS_Project__c where id=:selectedProject];
            selectedProjectName = projObj.name;
        }else{
            selectedProject = '';
        }
        IPSParentAccountList=Core_IPS_CaseUtility.getIPSParentAccountList(selectedProject,userinfo.getUserId());
        if(cs.assetId!=null){
            selectedProduct = ast.name;
            selectedProductId = cs.assetId;
            blnShowVariant = true;
            selectedVariant=cs.Core_Product_Variant__c;
            //displayProductVariant();
        }
        //P1 Changes by Raj END
        //envDetails = getEnvironmentDetailsOperationList(String.valueOf(cs.Core_IPS_Supported_Product__c),subCategorySelected,isPartnerAgent); 
        //setSearchedEnvironmentDetails(envDetails,String.valueOf(partition.get('EnvResponse'+deflectedId))); 
        //setSearchedEnvironmentDetails(subCatenvDetList,String.valueOf(partition.get('EnvResponse'+deflectedId)));
    }
    //==============================================================================================================
    public void getEditModeRequiredData(){
        cs = Core_IPS_CaseUtility.getCase_DynamiCSOQL(csId,isAgent);
        /*Start--US253124--MINDS Case Creation*/
        if(cs.Core_IPS_Minds__c!=null )
            { isMindsFlag = cs.Core_IPS_Minds__c; }
        if(cs.Core_IPS_Country_Region__c!=null)
            { selectedCountry = cs.Core_IPS_Country_Region__c; }
        /*End--US253124--MINDS Case Creation*/
        //Added by Geetha as per US96836
        if(!String.isBlank(cs.Core_IPS_Issue_source__c) && cs.Core_IPS_Issue_source__c=='Legacy PSG'){
            isMigratedSource=true;  
        }
        //Changes by Raj for Project/Product Edit for IPS Agent Partner 
        If(isPartnerAgent == true ){
            caseInformationReadOnly = false;
            projectList = Core_IPS_CaseUtility.getIPSProjectList();
            //Fix tchauhan
            if(projectList <> null && projectList.size() > 1 )
            {
                hasProject = true;
            }
            else
            {
                hasProject = false;                    
            }
            //Following block added by RK as part of DE38004
            if (cs.Core_IPS_Project_Case__c != null && cs.Core_IPS_Project_Case__r.Core_Status__c == 'Inactive'){
                caseInformationReadOnly = true;
            }
        }else{
            caseInformationReadOnly=true;
        }
        showGECFields=false;
        //[Oct/23/2015 : (Abhishek Arya) - END]
        if(cs.Recordtype.DeveloperName=='IPS_GEC_ReadOnly')  //GEC and close case check
        {
            showGECFields = true;
        }
        if(!String.isBlank(cs.Status) && cs.status=='closed')//Added by Geetha EDQ
        {
            isclosed = true;
        }
        if(cs.Core_Case_Issue_Category__c!=null){
            categorySelected=cs.Core_Case_Issue_Category__c;
        }
        if(cs <> null && cs.Core_IPS_Supported_Product__c <> null ){    
            categoryOptions=new list<SelectOption>();
            //categoryOptions=getCategoryOptions(cs.Core_IPS_Supported_Product__c);
        }
        if(cs.Core_Case_Issue_Sub_Category__c!=null){
            subCategorySelected=cs.Core_Case_Issue_Sub_Category__c;
            subCategorySelected_old = cs.Core_Case_Issue_Sub_Category__c;
            subCategoryOptions=new list<SelectOption>();
            //subCategoryOptions=getsubCategory_Options(categorySelected);
        }
        if(cs.core_ips_project_case__c!=null){
            selectedProjectName = cs.core_ips_project_case__r.name;
            selectedProject = cs.core_ips_project_case__c;
            selectedProjId = cs.core_ips_project_case__c;
        }
        else if(cs.core_ips_project_case__c == null && isPartnerAgent == true ){// RK added this block to set project picklist value" Not Applicable" as default value when project is null
            selectedProject = '';
        }
        //Added Core_IPS_Partner_Sup_Owner__r.isActive by Geetha as per US104757
        if(cs<> null && cs.Core_IPS_Partner_Sup_Owner__c !=null && cs.Core_IPS_Partner_Sup_Owner__r.isActive==true){
            IPSParentAccountList=Core_IPS_CaseUtility.getIPSParentAccountList(selectedProject,cs.Core_IPS_Partner_Sup_Owner__c);
        }else{         
            IPSParentAccountList=Core_IPS_CaseUtility.getIPSParentAccountList(selectedProject,userinfo.getUserId());
        }
        if(cs <> null && cs.Core_Partner_Supported_Account__c!=null){
            IPSParentAccountList.add(new SelectOption(cs.Core_Partner_Supported_Account__c,cs.Core_Partner_Supported_Account__r.Name));
            Set<Selectoption> containInactiveAccountSet=new Set<Selectoption>();
            containInactiveAccountSet.addAll(IPSParentAccountList);
            IPSParentAccountList.clear();
            IPSParentAccountList.addAll(containInactiveAccountSet);
            accSelected = cs.Core_Partner_Supported_Account__r.Name;
            selectedAccountId = cs.Core_Partner_Supported_Account__c;
            
        }
        if(cs <> null && cs.Core_Severity__c == 'Critical'){
            displayPriorityReason = true;
        }
        platformOptions=new List<SelectOption>();
        
        if(cs.assetId!=null){
            selectedProduct=cs.asset.name;
            selectedProductId = cs.assetId;
            blnShowVariant = true;
            selectedVariant=cs.Core_Product_Variant__c;
            //displayProductVariant();
            // Raj Changes
            platformSelected=cs.Core_Platform_Name__c;
            List<Id> assetIdList = new List<Id>();
            assetIdList.add(cs.assetId);
            //platformOptions=getplatformOptions(assetIdList);
        }
        if(cs <> null && cs.Core_IPS_Supported_Product__c <> null && cs.assetId == null){
            selectedSAProductId = cs.Core_IPS_Supported_Product__c;
            if(cs.productId <> null && cs.product.name!=null){
                selectedSAProduct = cs.product.name;
            }
            displaySelfAssigned = true;
            platformSelected=cs.Core_Platform_Name__c;
            List<Id> idList = new List<Id>();
            idList.add(selectedSAProductId);
            //platformOptions=getplatformOptions(idList);                
        }
        //P1 Changes by Raj END
        //envDetails = getEnvironmentDetailsOperationList(cs.Core_IPS_Supported_Product__c,subCategorySelected,isPartnerAgent); 
        //setCurrentEnvironmentDetails(envDetails,csId);   
    } 
    //===================================================================================================================
}