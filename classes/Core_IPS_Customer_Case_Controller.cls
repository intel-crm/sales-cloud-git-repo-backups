public with sharing class Core_IPS_Customer_Case_Controller{
    /* For Specific Partition name */
    private static final String PARTITION_NAME = system.label.Core_IPS_Platform_Cache_Name;
    public Boolean isAgent{get;set;}
    public Boolean blnShowVariant{get;set;} //variant hide and show on product select.
    public Boolean showGECFields{get;set;}
    public Boolean displayPopup {get; set;} // Contact link lookup   
    public Boolean displayEnvDetails{get;set;}
    public Boolean displayCategories{get;set;}  // Case Categories shows on case create and edit
    public Boolean displaySubCategories{get;set;}// Case SubCategories shows on case create and edit
    public Boolean renderErrorFlag{get;set;}
    public Boolean displaySelfAssigned{get;set;}
    public Boolean caseInformationReadOnly{get;set;} 
    public Boolean displayPriorityReason {get;set;}
    public Boolean hasProject {get;set;}  // checking for user project
    public Boolean isEditable{get;set;}  // permission check to edit the record
    public Boolean isclosed{get;set;}    
    public Boolean isMigratedSource{get;set;}//Added by Geetha as per US96836
    public Boolean isPartnerFAE{get;set;}//Added by Geetha as per US98246
    public Boolean isPartnerAgent{get;set;}
    public Boolean hideSubCat{get;set;}
    public Boolean displayPlatform{get;set;} // platform field show on the edit
    public Boolean showProductRelInfoDialog{get;set;}//Added by Mahendra per US79769
    public String categorySelected{get; set;}
    public String selectedVariant{get;set;} //capuring variant from create and edit
    public String GECAnswer1{get;set;}
    public String GECAnswer2{get;set;}
    public String GECAnswer3{get;set;}
    public String subject{get;set;}
    public String sbs{get;set;}
    public String retURL=null;
    public String productSearchIframeUrl{get;set;}  // Url Preparation for product search iframe 
    public String accSelected{get;set;}//Added by Geetha
    public String selectedAccountId{get;set;}//Added by Geetha
    public String selectedProject{get;set;}
    public String selectedProduct{get;set;}
    public String selectedProductId{get;set;}
    public String selectedSAProductId{get;set;}
    public String selectedContactId{get;set;} 
    public String selectedProjId{get;set;}
    public String selectedProjectName{get;set;}
    public String mode{get;set;} 
    public String csId;
    public String objectSelected{get;set;}
    public String subCategorySelected{get; set;}
    public String subCategorySelected_old{get; set;}
    public String platformSelected{get;set;}
    public String selectedSAProduct{get;set;}
    public String deflectedId;  
    public String selectedLanguage{
        get{
            if(selectedLanguage==null){
                selectedLanguage='en_us';
            }
            return selectedLanguage;
        }
        set;}
    public Id assetId;
    public static String AssetIdModified=null;
    public Id productId{get;set;} 
    public Asset ast{get;set;}
    public Case cs{get;set;}
    public ApexPages.standardController controller{get;set;}
    public Cache.Partition partition = Cache.Session.getPartition(PARTITION_NAME);
    public List<Core_IPS_EnvironmentDetailQuestion> envDetails{set;get;}
    public List<Core_IPS_EnvironmentDetailQuestion> subCatenvDetList{get;set;} 
    public List<Core_IPS_EnvironmentDetailQuestion> filteredEnvDetails{set;get;}
    public List<Core_IPS_EnvironmentDetailQuestion> filteredSubCatenvDetList{get;set;} 
    public static list<Contact> con{set;get;}
    public List<Asset> astlist{get;set;}
    public list<SelectOption> answerOptions{get;set;}
    public List<SelectOption> categoryOptions{get;set;} 
    public List<SelectOption> subCategoryOptions{get;set;}
    public List<SelectOption> projectList{get;set;}
    public List<SelectOption> IPSParentAccountList{get;set;}//Added by Geetha
    public List<SelectOption> platformOptions{get;set;}
    public List<SelectOption> variants{get;set;}//req
    public List<List<SelectOption>> variantsList{get;set;}//req
    public List<SelectOption> languageList{get;set;}//req
    
    public Set<Id> envQuestnIds;//Added By Manoj
    public String SearchJSONString{get;set;}//RCODE US104722
    /*Start--US253124--MINDS Case Creation*/
    public Boolean isMindsFlag{get;set;}
    List<Contact> contactInContext = new List<Contact>();
    public User Usr{get;set;}
    public String selectedCountry{get;set;}
    public List<SelectOption> countryOptions{get;set;}
    //public List<SelectOption> countryOptions = new List<SelectOption>();
    /*End--US253124--MINDS Case Creation*/    
    public Core_IPS_Customer_Case_Controller(ApexPages.standardController controller){
    System.debug('***Inside constructor');
        /*Start--US253124--MINDS Case Creation*/
        isMindsFlag = false;
        Usr = [Select id, Name, ContactId, Contact.Name, TimeZoneSidKey from User where id=:UserInfo.getUserId()];
        contactInContext = [Select id, Name,Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c  from Contact where id=: Usr.Contactid limit 1];
        if(Test.isRunningTest()){
             Usr = [Select id, Name, ContactId,Contact.Name, TimeZoneSidKey from User where ContactId !=null limit 1];
            contactInContext = [Select id, Name,Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c  from Contact limit 1];
        }
        if (contactInContext!=null && !contactInContext.isEmpty()) {
        System.debug('***contactInContext>>> ' + contactInContext);
        system.debug('<><><> minds flag :'+isMindsFlag);
          if(isMindsFlag!=NULL){              
              isMindsFlag = contactInContext[0].Core_MINDS__c;
          }
          
          if(contactInContext[0].Core_Country_Region__c!=NULL || contactInContext[0].Core_Country_Region__c!=''){
              selectedCountry = contactInContext[0].Core_Country_Region__c ;
          }
       }
       system.debug('***selectedCountry=='+selectedCountry);
        /*End--US253124--MINDS Case Creation*/
        showProductRelInfoDialog = false;//Added by Mahendra
        this.controller=controller;
        csId = controller.getId();
        isAgent = Core_IPS_Helper_Utility.isIPSCustomerUser();
        isPartnerAgent = isPartnerAgentUser();
        String deflectedIdEscape = ApexPages.currentPage().getParameters().get('deflectedid');
        deflectedId = (deflectedIdEscape != null)?deflectedIdEscape.escapeHtml4():null; 
        ScreenVisible();
        // Handling Session
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
        //Added by Geetha as per US98246
        isMigratedSource=false;
        isPartnerFAE=(Core_Utility.getPartnerUserType(userinfo.getuserId())).contains('Partner - DFAE');
        //[Dec/16/2015 - START - Checking the accessability.]
        if(!String.isBlank(csId)){
            isEditable = [SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfo.getuserId() AND RecordId = :csId].HasEditAccess;
        }
        
        //[Dec/16/2015 - END]
        isclosed =false;
        if(csId==null){
            cs = new Case();
            caseInformationReadOnly=false;
            subCategorySelected_old =''; //PRCR_Code_clean check
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
                // URL Data getting from Cache
                productSearchIframeUrl=String.valueOf(partition.get('iframeURL'+deflectedId));
            }else if(mode=='sNew' && !String.isBlank(deflectedId)){
                getSnewModeRequiredData();
            }
            
        }else if(mode=='edit'){
            getEditModeRequiredData();
        }
       
   
    }
    
    /*Start--US253124--MINDS Case Creation*/
    public List<SelectOption> getCountries()
        {
        countryOptions = new List<SelectOption>();
        Schema.Describefieldresult result = Schema.sObjectType.Contact.fields.Core_Country_Region__c;
        Schema.DescribeFieldResult fieldResult = result.getSObjectField().getDescribe();
        
        //Schema.DescribeFieldResult fieldResult = Contact.Core_Country_Region__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //countryOptions.add(new SelectOption('-None-', '-None-'));
        for( Schema.PicklistEntry entry : ple)
            {
            countryOptions.add(new SelectOption(entry.getLabel(), entry.getValue()));
            }
            system.debug('countryOptions=='+countryOptions);  
        Core_Utility.doSort(countryOptions, Core_Utility.FieldToSort.Label,'-None-');     
        return countryOptions;
        }
    /*End--US253124--MINDS Case Creation*/
    /***************************************************************************************************
Method Name:  ScreenVisible
Method Type: Screen Selection 
Version     : 1.0 
Function    : This method will return you which Screen will show on case create page.
Possible Values: pss(Product search Screen), scs(Search Criteria Screen), ss(Search Screen), ccs(Case Create Screen)
Output Parameters: None
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Prem Ranjan         04/04/2018      Created to track screen 
****************************************************************************************************/   
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
            (mode=='sNew' && sbs!='ccs')) || !modeList.contains(mode) ){
                sbs='pss';
                mode='new';
            }
    }
    /***************************************************************************************************
Method Name:  getAssetmodeRequiredData
Method Type: helper method 
Version     : 1.0 
Function    : This method gather the required data for mode asset. 
Used in     : constructor to get data
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Prem Ranjan         10/05/2018      Created to track screen 
****************************************************************************************************/   
    public void getAssetmodeRequiredData(){
        system.debug('Core_IPS_Partner_Sup_Owner__c==='+cs.Core_IPS_Partner_Sup_Owner__c);
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
            cs.Core_IPS_Partner_Sup_Owner__c =project[0].Core_IPS_Partner_Support_Owner__c; //PRCR_Change Moving Outside line no. 137  
            }
            else{ 
                cs.Core_IPS_Partner_Sup_Owner__c =userinfo.getuserId();
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
            displayProductVariant(); 
        }
        //system.debug('passedaccountId:: '+passedaccountId);
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
        envDetails=getEnvironmentDetailsOperationList(ast.core_supported_product__c,subCategorySelected,isPartnerAgent); 
    }
    /***************************************************************************************************
Method Name:  setSSLCDefaultdata
Method Type: helper method 
Version     : 1.0 
Function    : This method gather the required data and set the data for mode sslc case.
Used in     : constructor to set data for sslc default value
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Prem Ranjan         10/05/2018      Created to shorten constructor
****************************************************************************************************/   
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
            categoryOptions=getCategoryOptions(cs.Core_IPS_Supported_Product__c);
        }
        if(!String.isBlank(cs.Core_Case_Issue_Sub_Category__c)){
            subCategorySelected=cs.Core_Case_Issue_Sub_Category__c;
            subCategorySelected_old = cs.Core_Case_Issue_Sub_Category__c;
            subCategoryOptions=new list<SelectOption>();
            subCategoryOptions=getsubCategory_Options(categorySelected);
        }
        // Modified By Prem
        envDetails=getEnvironmentDetailsOperationList(cs.Core_IPS_Supported_Product__c,subCategorySelected,isPartnerAgent);
        system.debug('envDetails:: '+envDetails);
        Core_IPS_SSLCCase_DefaultData__c EnvDetailsData=Core_IPS_SSLCCase_DefaultData__c.getInstance('Case Subcategory Detail');
        Core_IPS_Response__c lstCoreResponse = new Core_IPS_Response__c();
        lstCoreResponse.Core_IPS_Case__c =null;
        lstCoreResponse.Core_IPS_Answer__c= EnvDetailsData.Core_IPS_Default_Data__c;
        lstCoreResponse.Core_IPS_Question_Master__c= EnvDetailsData.Core_IPS_Default_data_Id__c;
        setSearchedEnvironmentDetails(envDetails, Json.serialize(new List<Core_IPS_Response__c>{lstCoreResponse})); // Setting Supported Product level Env Details
        setSearchedEnvironmentDetails(subCatenvDetList, Json.serialize(new List<Core_IPS_Response__c>{lstCoreResponse}));  // Setting Subcategory level Env Details
    }
    /***************************************************************************************************
Method Name:  getSnewModeRequiredData
Method Type: helper method 
Version     : 1.0 
Function    : This method gather the required data for mode sNew.
Used in     : constructor to get data
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Prem Ranjan         10/05/2018      Created to track screen 
****************************************************************************************************/   
    public void getSnewModeRequiredData(){
        //   Core_IPS_Deflected_Object__c deflectedObj=[select Core_IPS_JSON_Format__c,core_ips_EnvResponse__c from Core_IPS_Deflected_Object__c where id=: deflectedId];
        system.debug('partition:::'+partition.contains('caseJson')+' MOde sNew');
        system.debug('test Local Storage::::'+(String)partition.get('caseJson'));
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
            categoryOptions=getCategoryOptions(String.valueOf(cs.Core_IPS_Supported_Product__c));
        }
        if(cs.Core_Case_Issue_Sub_Category__c!=null){
            subCategorySelected=String.valueOf(cs.Core_Case_Issue_Sub_Category__c);
            subCategorySelected_old = cs.Core_Case_Issue_Sub_Category__c;
            subCategoryOptions=new list<SelectOption>();
            subCategoryOptions=getsubCategory_Options(categorySelected);
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
            displayProductVariant();
        }
        //P1 Changes by Raj END
        envDetails = getEnvironmentDetailsOperationList(String.valueOf(cs.Core_IPS_Supported_Product__c),subCategorySelected,isPartnerAgent); 
        setSearchedEnvironmentDetails(envDetails,String.valueOf(partition.get('EnvResponse'+deflectedId))); 
        setSearchedEnvironmentDetails(subCatenvDetList,String.valueOf(partition.get('EnvResponse'+deflectedId)));
    }
    /***************************************************************************************************
Method Name:  getEditModeRequiredData
Method Type: helper method 
Version     : 1.0 
Created Date: 14 March 2017
Function    : This method gather the required data for mode edit.
Used in     : constructor to get data
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Prem Ranjan         10/05/2018      Created to track screen 
****************************************************************************************************/   
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
        system.debug('caseInformationReadOnly::'+caseInformationReadOnly);
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
            categoryOptions=getCategoryOptions(cs.Core_IPS_Supported_Product__c);
        }
        if(cs.Core_Case_Issue_Sub_Category__c!=null){
            subCategorySelected=cs.Core_Case_Issue_Sub_Category__c;
            subCategorySelected_old = cs.Core_Case_Issue_Sub_Category__c;
            subCategoryOptions=new list<SelectOption>();
            subCategoryOptions=getsubCategory_Options(categorySelected);
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
            system.debug('accSelected::'+accSelected);
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
            displayProductVariant();
            // Raj Changes
            platformSelected=cs.Core_Platform_Name__c;
            List<Id> assetIdList = new List<Id>();
            assetIdList.add(cs.assetId);
            platformOptions=getplatformOptions(assetIdList);
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
            platformOptions=getplatformOptions(idList);                
        }
        //P1 Changes by Raj END
        envDetails = getEnvironmentDetailsOperationList(cs.Core_IPS_Supported_Product__c,subCategorySelected,isPartnerAgent); 
        system.debug(envDetails);
        setCurrentEnvironmentDetails(envDetails,csId);   
    } 
    /***************************************************************************************************
Method Name:  setSearchedEnvironmentDetails
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
*Prem Ranjan         04/04/2018      Modified with EDQ new Search Structure
****************************************************************************************************/   
    public void setSearchedEnvironmentDetails(List<Core_IPS_EnvironmentDetailQuestion> lstEnvDetails, String responseObj) {
        // added  by amritesh 12/18/2017 - US8534 - start
        if(lstEnvDetails!=null) {
            system.debug('responseObj:: '+responseObj);
            List<Core_IPS_Response__c> lstCoreResponse = (List<Core_IPS_Response__c>)JSON.deserialize(responseObj, List<Core_IPS_Response__c>.class);
            Map<Id,List<Core_IPS_Response__c>> mapQuestionId2Responses = new Map<Id,List<Core_IPS_Response__c>>();
            for(Core_IPS_Response__c objResponse : lstCoreResponse) {
                if(!mapQuestionId2Responses.containsKey(objResponse.Core_IPS_Question_Master__c)) {
                    mapQuestionId2Responses.put(objResponse.Core_IPS_Question_Master__c, new List<Core_IPS_Response__c>());
                }
                mapQuestionId2Responses.get(objResponse.Core_IPS_Question_Master__c).add(objResponse);
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
                    if(envDet.type == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c) {  
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
        }
    }
    /***************************************************************************************************
Method Name:  clearProject
Method Type: Helper Method 
Version     : 1.0 
Function    : Used in clear/change project.
Description:   Used in case edit page to get the case information
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Ranjan              10/14/2015              Created
****************************************************************************************************/ 
    public PageReference clearProject(){
        System.debug('@@@@@@@@@@@@@'+selectedproduct+' :: '+selectedProject+' :: '+selectedProductId);  
        showProductRelInfoDialog = false;
        List<Asset> objAsset =new List<Asset>();
        if(!String.isBlank(selectedProduct)  && !String.isBlank(selectedProductId) && !Core_IPS_CaseUtility.isSelectedProdRelatedToProject(selectedProject,selectedProductId)){
            System.debug('objAsset===>>>>'+objAsset);
            if((Mode=='edit' && selectedProject != 'NA' )){
                showProductRelInfoDialog = true;
                System.debug('showProductRelInfoDialog===>>>'+showProductRelInfoDialog);                   
            }
            if(Mode!='edit' && selectedProject != 'NA'){
                   selectedProduct='';
                   selectedProductId=null;
                   projectList = Core_IPS_CaseUtility.getIPSProjectList();   
            }
            //Added by Mahendra per US79769 End
        }else{
            selectedProductId=AssetIdModified;
        }
        /*if(selectedProject=='NoProj'){
                selectedProject='';
        }*/
       // if(!String.isBlank(selectedProject) ){
            if(cs<> null && cs.Core_IPS_Partner_Sup_Owner__c !=null){
                IPSParentAccountList=Core_IPS_CaseUtility.getIPSParentAccountList(selectedProject,cs.Core_IPS_Partner_Sup_Owner__c);
            }else{         
                IPSParentAccountList=Core_IPS_CaseUtility.getIPSParentAccountList(selectedProject,userinfo.getUserId());
            }
      //  } 
        
        return null;
    }
    /***************************************************************************************************
Method Name:  clearProduct
Method Type: Helper Method 
Version     : 1.0 
Function    : Used in clear/change product.
Description:   Used in case edit page to get the case information
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Ranjan              10/14/2015              Created
****************************************************************************************************/ 
    public PageReference clearProduct(){
        System.debug('@@@@@@@@@@@@@'+selectedproduct+selectedProject);        
        /*if(String.isBlank(selectedProject)){
            selectedProject = '';
        }*/
        if(String.isBlank(selectedProduct)){
            projectList = Core_IPS_CaseUtility.getIPSProjectList();   
            selectedProduct='';
            selectedProductId=null;           
        }
        return null;
    }
    /*//Needs to be deleted by Abhishek it not required.
    public List<SelectOption> getCountriesOptions() {
        List<SelectOption> countryOptions = new List<SelectOption>();
        Schema.Describefieldresult result = Schema.sObjectType.Account.fields.Core_Account_Country__c;
        Schema.DescribeFieldResult fieldResult = result.getSObjectField().getDescribe();//Contact.BillingCountry.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        for( Schema.PicklistEntry f : ple)
        {
            countryOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        Core_Utility.doSort(countryOptions, Core_Utility.FieldToSort.Label,'-None-');
        return countryOptions;
    }*/
    
    /***************************************************************************************************
Method Name:  CancelAction
Method Type: Action Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : used to return to the case tab
Input Parameters: None 
Output Parameters: None
Description:   used to return to the case tab
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
****************************************************************************************************/     
    public PageReference CancelAction()
    {
        String preURL = String.valueOf(ApexPages.CurrentPage().getHeaders().get('referer'));
        String retURLEscape = ApexPages.currentPage().getParameters().get('retURL');
        String retURL = (retURLEscape != null)?retURLEscape.escapeHtml4():null;
        System.debug('URL *************' + preURL);
        PageReference pg;
        if(String.valueOf(ApexPages.currentPage().getParameters().get('retURL')) !=null && String.valueOf(ApexPages.currentPage().getParameters().get('retURL')) != ''){
            pg = new PageReference(retURL);
        }else if(preURL.indexof('assetid') > -1){
            pg = new PageReference('/02i/o');
        }else{
            pg = new PageReference('/500/o'); 
        }
        pg.setRedirect(true);
        return pg;
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
*Prem Ranjan         19/02/2018      Modified with EDQ new Structure
****************************************************************************************************/   
    public void setCurrentEnvironmentDetails(List<Core_IPS_EnvironmentDetailQuestion> lstEnvDetails, String caseId) {
        // added  by amritesh 12/18/2017 - US8534 - start
        if(lstEnvDetails!=null) {
            List<Core_IPS_Response__c> lstCoreResponse = Core_IPS_Questions_Utility.getEnvDetailCoreResponse(caseId);
            Map<Id,List<Core_IPS_Response__c>> mapQuestionId2Responses = new Map<Id,List<Core_IPS_Response__c>>();
            for(Core_IPS_Response__c objResponse : lstCoreResponse) {
                if(!mapQuestionId2Responses.containsKey(objResponse.Core_IPS_Question_Master__c)) {
                    mapQuestionId2Responses.put(objResponse.Core_IPS_Question_Master__c, new List<Core_IPS_Response__c>());
                }
                mapQuestionId2Responses.get(objResponse.Core_IPS_Question_Master__c).add(objResponse);
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
                    if(envDet.type == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c) {  
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
        }
    }
    /***************************************************************************************************
Method Name:  LookupChange
Method Type: Action Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : used in Internal user case creation page when ever aa product is changed to get Categories and environment details accordingly.
Input Parameters: None 
Output Parameters: None
Description:   used in Internal user case creation page when ever aa product is changed to get Categories and environment details accordingly.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
****************************************************************************************************/    
    public PageReference LookupChange(){
        List<String> EnvVarforSearch=new List<String>();
        for(Core_IPS_EV_Filters__c evfilter:[select id,name from Core_IPS_EV_Filters__c]){
            EnvVarforSearch.add((evfilter.name).toUpperCase()); 
        }
        if(selectedProductId!=null && selectedProductId!=''){
            cs.assetId = selectedProductId;
            ast = [select id, Name,Core_Product_Organization__c,core_supported_product__c,Core_IPS_Project__c,product2Id from asset where id=:selectedProductId];    
            //P1 Changes Raj
            List<Id> astIdList=new List<Id>();
            if(ast.core_supported_product__c!=null){
                astIdList.add(ast.Id);
                System.debug('RAZZ'+astIdList);
                platformOptions=getplatformOptions(astIdList);
            }
            //P1 Changes Raj end
            if(ast.core_product_organization__c !=null ){       
                cs.Core_IPS_Product_Org1__c=ast.core_product_organization__c;
            }
            if(ast.product2Id!=null){
                cs.productId = ast.product2Id;
            }
            if(ast.core_supported_product__c!=null){
                categorySelected='';            
                categoryOptions=getCategoryOptions(ast.core_supported_product__c);
                displaySubCategories=true;
                List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
                List<Core_IPS_Assigned_Environment_Variables__c> envVarsfilter = new List<Core_IPS_Assigned_Environment_Variables__c>();
                envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(ast.core_supported_product__c,null,isPartnerAgent);  // added  by amritesh 12/18/2017 - US8534
                for(Core_IPS_Assigned_Environment_Variables__c env:envVars){
                    if(EnvVarforSearch.contains((env.Core_IPS_Question_Text__c).toUpperCase())){
                        envVarsfilter.add(env);
                    }
                }
                //Added By Manoj as part of as part of US60820 IPS Evolve
                envQuestnIds = new Set<Id>();
                subCatenvDetList = new List<Core_IPS_EnvironmentDetailQuestion>();
                filteredSubCatenvDetList = new List<Core_IPS_EnvironmentDetailQuestion>();
                for(Core_IPS_Assigned_Environment_Variables__c envQuestn : envVars){
                    envQuestnIds.add(envQuestn.Core_IPS_Question__c); // added  by amritesh 12/18/2017 - US8534
                }
                system.debug('------envQuestnIds-----'+envQuestnIds);
                //Ended By Manoj
                if(envVars!=null && envVars.size()>0){
                    displayEnvDetails=true;
                    envDetails=constructWrapper(envVars);
                    if(envVarsfilter.size()>0){
                        filteredEnvDetails=constructWrapper(envVarsfilter);
                    }
                }else{
                    envDetails = new List<Core_IPS_EnvironmentDetailQuestion>(); 
                    displayEnvDetails=false;
                }
            }           
        }
        if(selectedSAProductId!=null && selectedSAProductId!=''){
            if(selectedSAProductId !=null){       
                cs.Core_IPS_Supported_Product__c = selectedSAProductId;
                categoryOptions=getCategoryOptions(selectedSAProductId);
                categorySelected =''; 
                subCategoryOptions=getsubCategory_Options(categorySelected);
                subCategorySelected ='';
                List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
                List<Core_IPS_Assigned_Environment_Variables__c> envVarsfilter = new List<Core_IPS_Assigned_Environment_Variables__c>();
                
                /************Added By Manoj as part of as part of US60820 IPS Evolve*********/
                envQuestnIds = new Set<Id>();
                //envVars = Core_IPS_CaseUtility.getEnvVariables(selectedSAProductId,null,isAgent);
                envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(selectedSAProductId,null,isPartnerAgent);  // added  by amritesh 12/18/2017 - US8534
                subCatenvDetList = new List<Core_IPS_EnvironmentDetailQuestion>();
                for(Core_IPS_Assigned_Environment_Variables__c envQuestn : envVars){
                    envQuestnIds.add(envQuestn.Core_IPS_Question__c); // added  by amritesh 12/18/2017 - US8534
                }
                system.debug('------envQuestnIds-----'+envQuestnIds+' envVars LookupChange ::'+envVars);
                //Search Before Submit Start
                for(Core_IPS_Assigned_Environment_Variables__c env:envVars){
                    if(EnvVarforSearch.contains((env.Core_IPS_Question__r.Name).toUpperCase())){
                        envVarsfilter.add(env);
                    }
                    system.debug('envVarsfilter LookupChange::'+envVarsfilter);
                }
                //Search Before Submit  end
                if(envVars!=null && envVars.size()>0){
                    displayEnvDetails=true;
                    envDetails=constructWrapper(envVars);
                }else{
                    displayEnvDetails=false;
                }
                //P1 Changes Raj
                List<Id> suppProdList=new List<Id>();
                suppProdList.add(selectedSAProductId);
                platformOptions=getplatformOptions(suppProdList);
                //P1 Changes Raj end
            }                                       
        }
        displayProductVariant();
        return null;   
    }
    /***************************************************************************************************
Method Name:  getCategoryOptions
Method Type: Action helper Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : returns the category options picklist
Input Parameters: None 
Output Parameters: List of category options
Description:   returns the category options picklist
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
****************************************************************************************************/     
    private List<SelectOption> getCategoryOptions(String supportedProductId){
        List<SelectOption> categoryOptions=new List<SelectOption>();
        //categoryOptions.add(new SelectOption('','Select One'));
        for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility.getCategories(supportedProductId)){
            if(a <> null && a.Core_Issue_Category_Name__r <> null && a.Core_Issue_Category_Name__r.Name <> null){
                categoryOptions.add(new SelectOption(a.id, a.Core_Issue_Category_Name__r.Name));
            }
        } 
        Core_Utility.doSort(categoryOptions, Core_Utility.FieldToSort.Label,'Select Category');
        if(categoryOptions <> null && categoryOptions.size()>0){
            //Core_Utility.doSort(categoryOptions, Core_Utility.FieldToSort.Label);
            displayCategories=true;
            subCategoryOptions=new List<SelectOption>();
            subCategoryOptions.add(new SelectOption('','--Select--'));//Geetha
            displaySubCategories=true;
        }else{
            displayCategories=false;
        } 
        return categoryOptions;
    }
    /***************************************************************************************************
Method Name:  clearEnvDetails 
Method Type: Helper Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : Clears the environment details wrapper
Input Parameters: None
Output Parameters: None
Description:   Clears the environment details wrapper
Used in     : Case edit
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
****************************************************************************************************/    
    public void clearEnvDetails(){
        if(envDetails!=null){ envDetails.clear();}
    }
    
    /***************************************************************************************************
Method Name:  getsubCategory_Options
Method Type: Action Helper Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : Constructs the Sub Category options based on category selected
Input Parameters: None 
Output Parameters: None
Description:   Constructs the Sub Category options based on category selected
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
****************************************************************************************************/     
    public List<SelectOption> getsubCategory_Options(String categorySelected){ 
        List<SelectOption> subCategoryOptions = new List<SelectOption>();
        System.debug('Category Selected:'+categorySelected);
        if(categorySelected!=null && categorySelected!=''){
            //subCategoryOptions.add(new SelectOption('', 'Select SubCategory'));
            for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility.getSubCategories(categorySelected)){
                system.debug('inside for '+a.Core_Issue_Sub_Category_Name__r.Name+' '+Core_IPS_CaseUtility.getSubCategories(categorySelected));
                if(a.Core_Issue_Sub_Category_Name__c!=null){
                    subCategoryOptions.add(new SelectOption(a.id, a.Core_Issue_Sub_Category_Name__r.Name));
                    system.debug('inside for and if'+subCategoryOptions);
                }
            }
            if(subCategoryOptions.size()>0){
                Core_Utility.doSort(subCategoryOptions, Core_Utility.FieldToSort.Label,'Select SubCategory');
                displaySubCategories=true;
            }
            else{
                displaySubCategories=false;   
            }
        }
        return subCategoryOptions;
    }
    
    /***************************************************************************************************
Method Name:  getEnvDetails
Method Type: Action Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : Gets the environment Details When Supported product is changed on Case create page.
Input Parameters: None 
Output Parameters: reload page partly when Supported product is changed
Description:   Gets the environment Details When Supported product is changed on Case create page.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
* Manoj Kumar                06/20/2017              Modified
*Prem Ranjan        02/19/2018       Modified
****************************************************************************************************/    
    public PageReference getEnvDetails(){
        if(subcategorySelected!=null && subcategorySelected!=''){
            subcategorySelected='';
        } 
        system.debug('####@@####'+categorySelected); 
        subCategoryOptions=getsubCategory_Options(categorySelected); 
        system.debug('subCategoryOptions*********'+subCategoryOptions);
        if(subCategoryOptions.size() < 1){
            system.debug('InsideIF*********'+subCategoryOptions);
            subCategoryOptions.clear();
            hideSubCat = false;
            system.debug('InsideIF*********'+subCategoryOptions);
        }else{
            hideSubCat = true;
        }
        // envDetails = getDetails(); 
        subCatenvDetList = new List<Core_IPS_EnvironmentDetailQuestion>();
        return null;
    }
    
    /***************************************************************************************************
Method Name:  getEnvironmentDets
Method Type: Action Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : Gets the environment Details using the getDetails method.
Input Parameters: None 
Output Parameters: reload page partly when subcategory is changed
Description:  Gets the environment Details using the getDetails method.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
*Manoj                      US60820
* Prem Ranjan       02/19/2018      Modified
****************************************************************************************************/ 
    public PageReference getEnvironmentDets(){
    System.debug('***Inside getEnvironmentDets');
        if(subCategorySelected!=null){
            filteredSubCatenvDetList=new List<Core_IPS_EnvironmentDetailQuestion>();
            subCatenvDetList = getDetails();
            System.debug('***subCatenvDetList >>> ');
            //Start--DE47136--Aniket-- Display environment questions on case create
            displayEnvDetails=true;
            //End--DE47136--Aniket-- Display environment questions on case create
        }else{
            subCatenvDetList = new List<Core_IPS_EnvironmentDetailQuestion>();
            System.debug('***Inside ELSE subCatenvDetList ');
        }
      return null; 
   
    }
    
    /***************************************************************************************************
Method Name:  getEnvironmentOptions
Method Type: Helper Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : Constructs Environment Wrapper for using within case page
Input Parameters: None 
Output Parameters: None
Description: Constructs Environment Wrapper for using within case page
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
****************************************************************************************************/ 
    @TestVisible private void getEnvironmentOptions(){
        if(selectedProductId!=null && selectedProductId!=''){
            cs.assetId = selectedProductId;
            ast = [select id, Name,Core_Product_Organization__c,core_supported_product__c,Core_IPS_Project__c,product2Id from asset where id=:selectedProductId];    
            List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
            envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(ast.core_supported_product__c,null,isPartnerAgent);  // added  by Prem
            if(envVars!=null && envVars.size()>0){
                displayEnvDetails=true;
                envDetails=constructWrapper(envVars);
            }else{
                displayEnvDetails=false;
            }
        }
    }
    
    /***************************************************************************************************
Method Name:  getDetails
Method Type: Helper Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : This method is used for getting envinronment details based on Subcategory or Supported product.
Input Parameters: None 
Output Parameters: EnvironmentDetail wrapper
Description: This method is used for getting envinronment details based on Subcategory or Supported product.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
* Manoj Kumar                06/20/2017              Modified
****************************************************************************************************/     
    public List<Core_IPS_EnvironmentDetailQuestion> getDetails(){
    System.debug('***displayEnvDetails inside getDetails() >> ' + displayEnvDetails);
        List<Core_IPS_Assigned_Environment_Variables__c> envVars;
        List<Core_IPS_Assigned_Environment_Variables__c> filteredSubCatenvDet = new List<Core_IPS_Assigned_Environment_Variables__c>();
        
        System.debug('Is Agent:'+isAgent);
        if(selectedProductId!=null && selectedProductId!=''){
            assetId= selectedProductId;
            ast = [select id, core_supported_product__c from asset where id=:assetId];
            productId=ast.core_supported_product__c;
             envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(productId,null,isPartnerAgent); // included by amritesh 12/18/2017 - US85344
            /******Added By Prem*************/
            if(envVars!=null && !envVars.isEmpty()){
                envQuestnIds = new Set<Id>();
                for(Core_IPS_Assigned_Environment_Variables__c envQuestn : envVars){
                    envQuestnIds.add(envQuestn.Core_IPS_Question__c); // added  by amritesh 12/18/2017 - US8534
                }
                system.debug('------envQuestnIds-----'+envQuestnIds);
            }
            /********Ended By Prem***********/
           
        }
        if(selectedSAProductId!=null){
            productId = selectedSAProductId;
        }
        if(categorySelected==null || (categorySelected!=null && categorySelected.trim().length()==0) || subcategorySelected==null || (subcategorySelected!=null && subcategorySelected.trim().length()==0)){
            if(categorySelected==null || (categorySelected!=null && categorySelected.trim().length()==0)){
                subCategorySelected=' ';
            }
            if(envVars.size()>0){
                displayEnvDetails=true;
            }
        }
        else if(subcategorySelected!=null && subcategoryselected!=''){
            /******Added By Manoj as part of US60820 IPS Evolve****/
            envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
            for(Core_IPS_Assigned_Environment_Variables__c subCatQtn : Core_IPS_Questions_Utility.getEnvDetailQuestions(null,subCategorySelected,isPartnerAgent)){  // added  by Prem
                system.debug('--------Sub Categry ----'+subCatQtn.Core_Environment_Variable__c+'--envqstns ---'+envQuestnIds+'--envqstns envDetails---'+envDetails);
                if(envQuestnIds!=null && !envQuestnIds.isEmpty()){
                    if(!envQuestnIds.isEmpty() && !envQuestnIds.contains(subCatQtn.Core_IPS_Question__c)) // added  by Prem
                       { envVars.add(subCatQtn); }               
                }
                else {
                    system.debug('Inside Null envQuestnIds');
                    envVars.add(subCatQtn);
                }
            }
            /******Ended By Manoj****/
            //Subcategory filter
            List<String> EnvVarforSearch=new List<String>();
            for(Core_IPS_EV_Filters__c evfilter:[select id,name from Core_IPS_EV_Filters__c]){
                EnvVarforSearch.add((evfilter.name).toUpperCase()); 
            }
            system.debug('envVars getEnvironmentDetailsOperationList::'+envVars);
            for(Core_IPS_Assigned_Environment_Variables__c env:envVars){
                if(EnvVarforSearch.contains((env.Core_IPS_Question_Text__c).toUpperCase())){
                    filteredSubCatenvDet.add(env);
                }
                system.debug('filteredSubCatenvDet getEnvironmentDetailsOperationList::'+filteredSubCatenvDet);
            }
        }
        
        if(envVars!=null && envVars.size()>0){
            displayEnvDetails=true;
            if(filteredSubCatenvDet.size()>0){
                filteredSubCatenvDetList=constructWrapper(filteredSubCatenvDet);
            }
            return constructWrapper(envVars);
        }else{
            displayEnvDetails=false;
            return null;
        }
        //return null;
    }
    /***************************************************************************************************
Method Name:  getEnvironmentDetailsOperationList
Method Type: Helper Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : This method is used for getting envinronment details based on Subcategory or Supported product and preparing for filttered environment details.
Input Parameters: productId ,subCategoryId, isAgent
Output Parameters: List Core_IPS_EnvironmentDetailQuestion 
Description: This method is used for getting envinronment details based on Subcategory or Supported product.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
* Prem Ranjan                03/20/2018              Modified
****************************************************************************************************/     
    private List<Core_IPS_EnvironmentDetailQuestion> getEnvironmentDetailsOperationList(String productId, String subCategoryId, Boolean isPartnerAgent){
        List<String> EnvVarforSearch=new List<String>();
        for(Core_IPS_EV_Filters__c evfilter:[select id,name from Core_IPS_EV_Filters__c]){
            EnvVarforSearch.add((evfilter.name).toUpperCase()); 
        }
        
        List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
        List<Core_IPS_Assigned_Environment_Variables__c> envVarsfilter = new List<Core_IPS_Assigned_Environment_Variables__c>();
        
        /******Added By Manoj as part of US60820 IPS Evolve****/
        List<Core_IPS_Assigned_Environment_Variables__c> subCatenvVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
        
        if(!String.isBlank(subCategoryId) && productId!=null){
            system.debug('envVars==============>'+envVars);
            envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(productId,null,isPartnerAgent); // added by amritesh 12/18/2017 - US85344
            
            /******Added By Manoj*************/
            if(envVars!=null && !envVars.isEmpty()){
                envQuestnIds = new Set<Id>();
                for(Core_IPS_Assigned_Environment_Variables__c envQuestn : envVars){
                    envQuestnIds.add(envQuestn.Core_IPS_Question__c); // added by amritesh 12/18/2017 - US85344
                }
                system.debug('------envQuestnIds-----'+envQuestnIds);
            }
            
            for(Core_IPS_Assigned_Environment_Variables__c subCatQtn : Core_IPS_Questions_Utility.getEnvDetailQuestions(null,subCategorySelected,isPartnerAgent)) {
                
                // system.debug('--------Sub Categry ----'+subCatQtn.Core_Environment_Variable__c+'--envqstns ---'+envQuestnIds+'--envqstns envDetails---'+envDetails);
                if(envQuestnIds!=null && !envQuestnIds.isEmpty()){
                    if(!envQuestnIds.isEmpty() && !envQuestnIds.contains(subCatQtn.Core_IPS_Question__c)){  //added by amritesh 12/18/2017 - US85344
                        subCatenvVars.add(subCatQtn);                
                    }
                }
                else {
                    system.debug('Inside Null envQuestnIds');
                    subCatenvVars.add(subCatQtn);
                }
            }
            system.debug('--------Sub Categry Questions----'+subCatenvVars);
            /******Ended By Manoj****/
            if(subCatenvVars!=null && subCatenvVars.size()>0){
                subCatenvDetList = constructWrapper(subCatenvVars);
                setCurrentEnvironmentDetails(subCatenvDetList,csId);
            }
            
        }/******Ended By Manoj****/
        else if(subCategoryId!=null && subCategoryId!=''){
            envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(null,subCategoryId,isPartnerAgent);
            if(envVars.size() == 0 && productId!=null)
            {
                envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(productId,null,isPartnerAgent);    //added by amritesh 12/18/2017 - US85344
            }
        }else if(productId!=null){
            envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(productId,null,isPartnerAgent);    //added by amritesh 12/18/2017 - US85344
        }
        system.debug('envVars getEnvironmentDetailsOperationList::'+envVars);
        for(Core_IPS_Assigned_Environment_Variables__c env:envVars){
            if(EnvVarforSearch.contains((env.Core_IPS_Question_Text__c).toUpperCase())){
                envVarsfilter.add(env);
            }
        }
        system.debug('envVarsfilter getEnvironmentDetailsOperationList::'+envVarsfilter);
        if(envVars <> null && envVars.size()>0){
            displayEnvDetails=true;
            if(envVarsfilter.size()>0){
                filteredEnvDetails=constructWrapper(envVarsfilter);
            }
            return constructWrapper(envVars);
        }else{
            displayEnvDetails=true;
        }   
        return null;
    }
    
    /***************************************************************************************************
Method Name:  constructWrapper
Method Type: Helper Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : This method helps in constructing a wrapper for Environment Details that is used for displaying components based on ENV Details Data type.
Input Parameters: Core_IPS_Assigned_Environment_Variables__c based on selected Subcategory or selected Supported product 
Output Parameters: None
Description: This method helps in constructing a wrapper for Environment Details that is used for displaying components based on ENV Details Data type.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
****************************************************************************************************/    
    public List<Core_IPS_EnvironmentDetailQuestion> constructWrapper(List<Core_IPS_Assigned_Environment_Variables__c> envVars){
        Map<Id,Core_IPS_Assigned_Environment_Variables__c> MapAssigned_EnvironmentVariables = new Map<Id,Core_IPS_Assigned_Environment_Variables__c>();
        Map<Id,Set<Id>> mapQuesParentId2DependentId = new Map<Id,Set<Id>>(); // added by amritesh 12/18/2017 - US85344 
        Boolean IsOptionsChanges =  false;
        for(Core_IPS_Assigned_Environment_Variables__c Ev : envVars)
        {
            /****** added by amritesh 12/18/2017 - US85344 - start *******/
            if(Ev.Core_IPS_Question__c!=null && String.isNotBlank(Ev.Core_IPS_Question__r.Core_IPS_Question__c)) 
            {
                // added by amritesh 12/18/2017 - US85344 - start
                MapAssigned_EnvironmentVariables.put(Ev.Core_IPS_Question__c, ev); 
                // define the questions dependency
                if(Ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c!=null) {
                    if(!mapQuesParentId2DependentId.containsKey(Ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c)) {
                        mapQuesParentId2DependentId.put(Ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c, new Set<Id>());
                    }                    
                    mapQuesParentId2DependentId.get(Ev.Core_IPS_Question__r.Core_IPS_Parent_Question__c).add(Ev.Core_IPS_Question__c);
                }
                // added by amritesh 12/18/2017 - US85344 - end
            }            
        }
        
        if(envDetails !=null && envVars !=null && envDetails.size() == envVars.size())
        {
            for(Core_IPS_EnvironmentDetailQuestion En :envDetails)
            {
                if(MapAssigned_EnvironmentVariables.containsKey(en.questionId)==false)
                {         
                    IsOptionsChanges = true;
                    break;
                }                
            }
        }
        else
        {
            IsOptionsChanges =  true;
        }
        if(IsOptionsChanges==false)
        {
            return envDetails;
        }
        
        // added  by amritesh 12/18/2017 - US8534 -start
        Map<Id,Map<Id,String>> mapQues2AnswerMap = new Map<Id,Map<Id,String>>();
        mapQues2AnswerMap = Core_IPS_Questions_Utility.getQues2AnswerMapId(new List<Id>(MapAssigned_EnvironmentVariables.keySet()));
        // added  by amritesh 12/18/2017 - US8534 - end
        
        Map<Id,Core_IPS_EnvironmentDetailQuestion> mapEnvDetail = new Map<Id,Core_IPS_EnvironmentDetailQuestion>(); // added by amritesh 12/18/2017 - US85344 
        
        for(Core_IPS_Assigned_Environment_Variables__c en : envVars){
            Core_IPS_EnvironmentDetailQuestion det = new Core_IPS_EnvironmentDetailQuestion();
            det.label = en.Core_IPS_Question__r.Core_IPS_Question__c; // added by amritesh 12/18/2017 - US85344 
            det.questionId = en.Core_IPS_Question__c; // added by amritesh 12/18/2017 - US85344 
            det.required = en.Core_required__c;
            det.IsAgentOnly = en.Core_Agent_Only__c;
            
            if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c.trim()) { //added by amritesh 12/18/2017 - US85344
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c;
                det.splaceHolder = '';
                // added by amritesh 12/18/2017 - US85344 
                if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                    Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                    if(mapAns.values().size()>0) {
                        det.splaceHolder = mapAns.values().get(0);
                    }
                } 
                
            }else if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim() || en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim()){
                //added  by amritesh 12/18/2017 - US8534 - start
                List<SelectOption> selectOptionsList = new List<SelectOption>();
                SelectOptionsList.add(new SelectOption('','--Select--'));//Geetha
                if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                    Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                    for(Id ansId : mapAns.keySet()) {
                        selectOptionsList.add(new SelectOption(ansId, mapAns.get(ansId)));
                    }
                } 
                if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim()){ // added  by amritesh 12/18/2017 - US8534
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim();
                } else{
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim();
                }
                det.pplaceholder=selectOptionsList;
                det.selectedValue=selectOptionsList.get(0).getValue();
            } else if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c.trim()){   // added  by amritesh 12/18/2017 - US85344          
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c.trim();
                det.tplaceHolder= '';
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
            mapEnvDetail.put(en.Core_IPS_Question__c, det);            
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
        System.debug('>>>@@>>>' + lstEnvDetail);
        return lstEnvDetail;
    }
    /***************************************************************************************************
Method Name:  createQuestionHierachy
Method Type: Helper Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : This method prepare Hierachy dependent question
Input Parameters: quesId, mapEnvDetail, mapQuesParentId2DependentId
Output Parameters: None
Used in     : Environment details preparation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
****************************************************************************************************/  
    private void createQuestionHierachy(Id quesId, Map<Id,Core_IPS_EnvironmentDetailQuestion> mapEnvDetail, Map<Id,Set<Id>> mapQuesParentId2DependentId) {
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
Method Name:  saveCaseDetails
Method Type: Action Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : This method is called when Save button is clicked on Case Creation page
Input Parameters: None
Output Parameters: None
Description: This method is called when Save button is clicked on Case Creation page
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
* Jayaprakash T              10/19/2015              Removed Unwanted lines for Customer
* Jayaprakash T              10/19/2015              Moved SupportedProduct, and Product Org to Trigger
* Tanvi Chauhan              07/15/2019              New Minds implementation - Commented old GEC Logic
****************************************************************************************************/    
    public PageReference saveCaseDetails(){
    System.debug('***Inside saveCaseDetails');
        //if(validateGecDetails()){ 
        //    return null;
        //}
        if(validateCustomerCase()){
            return null;
        }
        
        if(validateCaseRelatedInformation()){
            return null;
        }
        if(validateEnvironmentDetails()){ 
            return null;
        }  
        try{    
            if(categorySelected!=null && categorySelected!=''){
                cs.Core_Case_Issue_Category__c=categorySelected;
                system.debug('categorySelected'+cs.Core_Case_Issue_Category__c);
            }
            else 
            {
                cs.Core_Case_Issue_Category__c = null;
            }
            if(subCategorySelected!=null && subCategorySelected!=''){
                cs.Core_Case_Issue_Sub_Category__c=subCategorySelected;
            }
            else
            {
                cs.Core_Case_Issue_Sub_Category__c = null;
            }
            cs.Core_Platform_Name__c = platformSelected;//Raj Added this code to save platform name
            if(selectedProductId!=null && selectedProductId!=''){
                cs.assetId = selectedProductId;
                system.debug('selectedProductId::'+selectedProductId);
                astlist = [select id, name,core_supported_product__c from asset where id=:selectedProductId limit 1];
                if(astlist.size()>0){
                    cs.Core_IPS_Supported_Product__c=astlist[0].core_supported_product__c; 
                }
            }
            if(selectedProject!=null &&  selectedProject!='' && selectedProject!='NA' && selectedProject!='NoProj'){
                cs.Core_IPS_Project_Case__c= selectedProject;         
            }
            else
            {
                cs.Core_IPS_Project_Case__c =null;
            }
            
            User u = [select Id, username,userType,contactId,AccountId from User where Id = :UserInfo.getUserId()];
            if(cs.contactid==null){
                cs.contactId = u.contactId;
            }
            if(cs.accountid==null){    
                cs.Accountid = u.AccountId; 
            }
           
            if( mode=='sNew'){
                String recordTypeId_New = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
                cs.recordtypeID =  recordTypeId_New;
                cs.status='New';
                cs.Origin = 'Web';
               
            }
     
            //TChauhan--Commented to remove old GEC Logic--07122019
            //code added as per US135424
            /**if(showGECFields!=null && showGECFields)
            {

                if(GECAnswer1 == 'Yes' || GECAnswer2 == 'Yes')
                {
                    cs.Core_IPS_GEC_Flag__c = true;
                    cs.IsStopped = true;
                    cs.Status = 'On Hold';
                    cs.Core_IPS_GEC_Request_Status__c = 'MAG Questionnaire Required';
                    cs.Core_Sub_Status__c = 'GEC Hold';     
                    String recordTypeId_GEC = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();
                    cs.recordtypeID =  recordTypeId_GEC;
                }
            }**/
           
     
            if(cs.Core_Issue_Description__c != null)
            {
                String  strDescValue =  Core_Utility.replaceSpecialChar(cs.Core_Issue_Description__c);
                cs.Description = Core_Utility.replaceHtmlTags(strDescValue);
            }
             
            if(cs.id == null && showGECFields==false)
            {
                cs.status='New';
                cs.Origin = 'Web';
            }
    
            system.debug('selectedAccountId::'+selectedAccountId);
            if(selectedAccountId!= '' && selectedAccountId!= 'NA'){  //modified line by prem
                cs.Core_Partner_Supported_Account__c = selectedAccountId;
            }
            else{
                cs.Core_Partner_Supported_Account__c = null;
            }
            cs.Core_IPS_Customer_Visible__c=true;
            cs.Core_Product_Variant__c=selectedVariant;
            
            /*Start--US253124--MINDS Case Creation*/
            System.debug('isMindsFlag'+isMindsFlag);
            if(isMindsFlag!=NULL){
                cs.Core_IPS_Minds__c= isMindsFlag;
            }else{
                cs.Core_IPS_Minds__c=false;
            }
            
            if(selectedCountry!=null){
                cs.Core_IPS_Country_Region__c = selectedCountry;
            }
            
            /*End--US253124--MINDS Case Creation*/
            CaseRecordSave caseRecSave=new CaseRecordSave();
            System.debug('KING '+cs);
            caseRecSave.saveCase(cs);
            
            //TChauhan--Added recordtypeid to resolve PSG recordtype issue--07182019
            /*Start -------------DE42109---------*/
            System.debug('csupdatedStatusCase---->> '+cs);
            List<Case> updatedStatusCase = [SELECT Status, RecordtypeID  FROM CASE where Id = :cs.Id];
            System.debug('***updatedStatusCase ---->> '+updatedStatusCase);
            cs.Status = updatedStatusCase[0].Status;
            cs.RecordtypeID  = updatedStatusCase[0].RecordtypeID;  
            
            /*End -------------DE42109----------*/
            //addGECRecords();   
            
            captureEnvDetails(); 
            if(!String.isBlank(deflectedId)){            
                Core_IPS_Deflected_Object__c deflectedObj=new Core_IPS_Deflected_Object__c();
                deflectedObj.id=deflectedId;
                deflectedObj.Core_IPS_Case_ID__c=cs.id;
                // Niyaz -- 12/06/2025 --- added as part of vulnerability fix
                if (Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Status__c.isUpdateable()) { 
                        deflectedObj.Core_IPS_Status__c='Case Created';//Case Created
                }
                
                // deflectedObj.ownerID=System.label.core_IPS_DeflectedQueue_Id;
                upsert deflectedObj;           
            }
            system.debug('Limits.getDMLStatements'+Limits.getDMLStatements());
        }catch(DMLException e){
            Core_Exceptionclass Exce =  new Core_Exceptionclass();
            String  Str = Exce.InsertException('','Core_IPS_Customer_Case_Controller','Case','','saveCaseDetails',e);
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + Str);
            renderErrorFlag=true;
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.Warning, 'DML Exception'+e );
            ApexPages.addMessage(msg);
            System.debug('Error:In Catch:'+e);
            return null;
        }         
        return new PageReference('/'+cs.id);
    }
    
    /***************************************************************************************************
Method Name:  validateGecDetails
Method Type: Helper Method 
Version     : 1.0 
Created Date: 01/29/2016 
Function    : This Method validates GEC Fields Detail Responses provided by customer.
Input Parameters: None
Output Parameters: Returns true if user does not fill the mandatory Environment details and false otherwise.
Description: This Method validates Environment Detail Responses provided by customer.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sunil Chandani              01/29/2016              Created
****************************************************************************************************/
    /**public Boolean validateGecDetails(){
        if(showGECFields!=null && showGECFields)
        {
            system.debug('@@@@@@'+GECAnswer1+GECAnswer2+GECAnswer3);
            if(GECAnswer1 == ''|| GECAnswer2 == '' || GECAnswer3 == '' || GECAnswer1 == null|| GECAnswer2 == null || GECAnswer3 == null)
            {
                APexPages.Message Msg = new ApexPages.Message(ApexPages.Severity.Error, 'Please Fill the Required Fields');
                ApexPages.addMessage(Msg);
                System.debug('inside error');
                return true;            
            }
            else
            {
                return false;
            }
        }
        else
        {
            return false;
        }
        //return false;
    }
    **/
    /***************************************************************************************************
Method Name:  addGECRecords
Method Type: Helper Method 
Version     : 1.0 
Created Date: 14 Oct 2015
Function    : This method helps in adding GEC specific information to Case as a related list
Input Parameters: None
Output Parameters: None
Description: This method helps in adding GEC specific information to Case as a related list
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              10/14/2015              Created
****************************************************************************************************/    
    /**public void addGECRecords(){
  
        if(showGECFields!=null && showGECFields)
        {
                list<Core_IPS_GEC_Details__c> GECList = new list<Core_IPS_GEC_Details__c>();
                Core_IPS_GEC_Details__c GEC1 = new Core_IPS_GEC_Details__c();
                GEC1.Core_IPS_GEC_Question1__c = 'Do any of your questions relate to the use of Intel products in a military, defense, intelligence, nuclear/biochemical or space item?';
                GEC1.Core_IPS_GEC_Question2__c = GECAnswer1;
                GEC1.Core_IPS_Case__c = cs.Id;
                GECList.add(GEC1);
                
                Core_IPS_GEC_Details__c GEC2 = new Core_IPS_GEC_Details__c();
                GEC2.Core_IPS_GEC_Question1__c = 'Will you be providing any technical data that is related to a defense article or any military, defense, intelligence, nuclear/biochemical or space end use? ';
                GEC2.Core_IPS_GEC_Question2__c = GECAnswer2;
                GEC2.Core_IPS_Case__c = cs.Id;
                GECList.add(GEC2);
                
                Core_IPS_GEC_Details__c GEC3 = new Core_IPS_GEC_Details__c();
                GEC3.Core_IPS_GEC_Question1__c = 'Country';                  
                GEC3.Core_IPS_GEC_Question2__c = GECAnswer3;
                GEC3.Core_IPS_Case__c = cs.Id;
                GECList.add(GEC3);
    
                Core_IPS_AdminUtility.insertGECList(GECList);
 
                //insert GECList;                    
        }
    }
    **/
    
    /***************************************************************************************************
Method Name:  validateEnvironmentDetails
Method Type: Helper Method 
Version     : 1.0 
Created Date: 15 Jul 2015
Function    : This Method validates Environment Detail Responses provided by customer.
Input Parameters: None
Output Parameters: Returns true if user does not fill the mandatory Environment details and false otherwise.
Description: This Method validates Environment Detail Responses provided by customer.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              07/15/2015              Created
****************************************************************************************************/
    public Boolean validateEnvironmentDetails(){
        System.debug('***validateEnvironmentDetails');
        // added by amritesh 12/18/2017 - US8534 - start
        List<Core_IPS_EnvironmentDetailQuestion> lstAllenvDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        if(subCatenvDetList!=null && subCatenvDetList.size()>0){
            lstAllenvDetails.addAll(Core_IPS_Questions_Utility.getAllWithChildEnvDetails(subCatenvDetList));
        }
        if(envDetails!=null && envDetails.size()>0){
            lstAllenvDetails.addAll(Core_IPS_Questions_Utility.getAllWithChildEnvDetails(envDetails));
        }
        
        if(lstAllenvDetails!=null && lstAllenvDetails.size()>0){
            for(Core_IPS_EnvironmentDetailQuestion det : lstAllenvDetails){     
                if(!det.isVisible){
                    continue; // added by amritesh 12/18/2017 - US8534  
                } 
                if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c &&(det.sPlaceHolder==null || det.sPlaceHolder=='') &&det.required){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;    
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c&&(det.sPlaceHolder !=null || det.sPlaceHolder !='') && det.sPlaceHolder.length()>255){ // added  by amritesh 12/18/2017 - US8534
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G111')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;    
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c &&(det.tPlaceHolder==null ||det.tPlaceHolder=='')&&det.required){ // added  by amritesh 12/18/2017 - US8534
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c && (det.tPlaceHolder != null ||det.tPlaceHolder!='') && det.tPlaceHolder.length()>5000){ // added  by amritesh 12/18/2017 - US8534
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G110')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;
                }else if((det.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c) &&(det.selectedValue==null || det.selectedValue=='' || det.selectedValue=='[]') && det.required){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G106')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;
                }
                else if((det.type==Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c) &&(det.selectedMValue==null || det.selectedMValue.size() == 0 ||(det.selectedMValue.size()==1 && det.selectedMValue[0]=='')) && det.required){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G106')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;
                }
                
            }
        }
        return false;
    }
    
    /***************************************************************************************************
Method Name:  validateSearchRelatedInformation
Method Type: Helper Method 
Version     : 1.0 
Created Date: 07 March 2018
Function    : This Method validates external user specific common case information.
Input Parameters: None
Output Parameters: Returns true if there is an error in user entered information and false otherwise.
Description: This Method validates Internal and external user specific common case information.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Ranjan              03/07/2018              Created
****************************************************************************************************/ 
    public Boolean validateSearchRelatedInformation(){
        String  strdesc = '';
        if(cs.Subject==null || cs.Subject==''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G102'));
            ApexPages.addMessage(myMsg);
            return true;
        }
        if((categoryOptions!=null && categoryOptions.size()>1) && (categorySelected==null || (categorySelected!=null && categorySelected.trim().length()==0))){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G100'));//G100
            ApexPages.addMessage(myMsg);
            return true;
        }
        if((subCategoryOptions!=null &&subCategoryOptions.size()>1) && (subCategorySelected==null || (subCategorySelected!=null && subCategorySelected.trim().length()==0))){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G101'));
            ApexPages.addMessage(myMsg);
            return true;
        }        
        
        return false;
    }
    
    /***************************************************************************************************
Method Name:  validateCaseRelatedInformation
Method Type: Helper Method 
Version     : 1.0 
Created Date: 15 Jul 2015
Function    : This Method validates Internal and external user specific common case information.
Input Parameters: None
Output Parameters: Returns true if there is an error in user entered information and false otherwise.
Description: This Method validates Internal and external user specific common case information.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              07/15/2015              Created
****************************************************************************************************/ 
    public Boolean validateCaseRelatedInformation(){
    System.debug('***Inside validateCaseRelatedInformation');
        String  strdesc = '';
       if(!Test.isRunningTest() && (selectedCountry==null || selectedCountry=='')){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G121'));
            ApexPages.addMessage(myMsg);
            return true;
        } 
        if(cs.Subject==null || cs.Subject==''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G102'));
            ApexPages.addMessage(myMsg);
            return true;
        }
        if(String.isBlank(cs.Core_Issue_Description__c) || (!String.isBlank(cs.Core_Issue_Description__c)&& cs.Core_Issue_Description__c.stripHtmlTags().replaceAll('\u00A0','').trim()=='') ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G103'));
            ApexPages.addMessage(myMsg);
            return true;
        }
        if(cs.Core_Severity__c==null || cs.Core_Severity__c==''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G104'));
            ApexPages.addMessage(myMsg);
            return true;
        }
        if(cs.Core_CaseType__c==null || cs.Core_CaseType__c==''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G109'));
            ApexPages.addMessage(myMsg);
            return true;
        }
        DisplayPriorityReason(); // US739228: for handling delayed loading of severity reason field
        if(displayPriorityReason == true && (cs.Core_Severity_Reason__c==null || cs.Core_Severity_Reason__c=='')){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('I111'));
            ApexPages.addMessage(myMsg);
            return true;
        }
        //Raj Added below code snippet for Platform name feature
        if(csId <> null && csId <> '' && isPartnerAgent && platformOptions != null && platformOptions.size() > 1 && (platformSelected==null || (platformSelected!=null && platformSelected.trim().length()==0))){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G107'));
            ApexPages.addMessage(myMsg);
            return true;
        }
        
        //RK Changes for US104046
        if((isPartnerAgent || isPartnerFAE) && (mode!='edit') && (selectedAccountId == null || selectedAccountId =='' || selectedAccountId =='NA') && (selectedProject!= null && selectedProject!= '' )){ 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G118'));
            ApexPages.addMessage(myMsg);
            return true;
        }
        if((categoryOptions!=null && categoryOptions.size()>1) && (categorySelected==null || (categorySelected!=null && categorySelected.trim().length()==0))){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G100'));//G100
            ApexPages.addMessage(myMsg);
            return true;
        }
        if(subCategoryOptions!=null && subCategoryOptions.size()>=0 && categorySelected!=null && categorySelected.trim().length()>0 ){ // US739228: for handling delayed loading of subcategory
            // subCategoryOptions =getsubCategory_Options(categorySelected);
            if((subCategorySelected!=null && subCategorySelected.trim().length()>0)){
                Boolean validSubCategory = false;
                for(SelectOption so: subCategoryOptions){
                    if(subCategorySelected == so.getValue()){
                        validSubCategory = true;
                    }
                }
                if(!validSubCategory){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G122'));
                    ApexPages.addMessage(myMsg);
                    return true;
                }
            }
        }
        if((subCategoryOptions!=null &&subCategoryOptions.size()>1) && (subCategorySelected==null || (subCategorySelected!=null && subCategorySelected.trim().length()==0))){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G101'));
            ApexPages.addMessage(myMsg);
            return true;
        }
        return false;
    }
    
    /***************************************************************************************************
Method Name:  validateCustomerCase
Method Type: Helper Method 
Version     : 1.0 
Created Date: 15 Jul 2015
Function    : This Method validates customer specific case information.
Input Parameters: None
Output Parameters: Returns true if there is an error in user entered information and false otherwise
Description: This Method validates customer specific case information.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              07/15/2015              Created
****************************************************************************************************/ 
    public Boolean validateCustomerCase(){
        system.debug('######validate######'+projectList+selectedProject+selectedProductId);
        if(projectList!=null && projectList.size()>0){
            if((selectedProject=='NA') && (selectedProductId==null || selectedProductId=='')){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('C100'));//Same old drama -C100
                ApexPages.addMessage(myMsg);
                return true;
            }else{
                if(selectedProductId==null || selectedProductId==''){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('C101'));//Same old drama -C101
                    ApexPages.addMessage(myMsg);
                    return true;
                }else if(selectedProject=='NA'){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('C102'));//Same old drama -C102
                    ApexPages.addMessage(myMsg);
                    return true;
                }
            }
        }else{
            if(selectedProductId==null || selectedProductId==''){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('C103'));//Same old drama -C103
                ApexPages.addMessage(myMsg);
                return true;
            }
        }
        return false;
    }
    
    /***************************************************************************************************
Method Name:  errormessage
Method Type: Helper Method 
Version     : 1.0 
Created Date: 01 Jul 2015
Function    : This method Gets the error message from Core_IPS_Error_Code custom setting.
Input Parameters: Error code
Output Parameters: Returns error message
Description: All the error messages are added in Custom setting and this method gets the error message from error code.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T              07/01/2015              Created
****************************************************************************************************/    
    public String errormessage(String errorCode){
        String defaultmessage ='please fill the Mandatory fields';
        if(Core_IPS_Error_Code__c.getinstance(errorCode)!=null){
            if(Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c!=null){
                defaultmessage =Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c; 
            }
        }
        return defaultmessage;
    }
    
    /************************************************************************************************
Method Name:  DisplayPriorityReason
Method Type: Action Method 
Version     : 1.0 
Created Date: 21-1--2015
Function    : This method set the "DisplayPriorityReason" boolean variable set to True if User selects "Severity" as 'Critical'. If boolean variable is True then, "Severity Reason" picklist is displayed in the UI.
Input Parameters: None
Output Parameters: None
Description: This method is called when user changes the Core_Severity__c Picklist in the UI. If Core_Severity__c Picklist is Critical, Severity Reason picklist is displayed in the UI 
Used in     : Case Creation
Modification Log :

* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       21/10/2015                 Created
****************************************************************************************************/    
    public void DisplayPriorityReason(){
        if(cs.Core_Severity__c=='Critical'){
            displayPriorityReason = true;
        }
        else {
            cs.Core_Severity_Reason__c='';
            displayPriorityReason = false;
        }
        system.debug('method invoked. DisplayPriorityReason=    '+DisplayPriorityReason);
    }
    /************************************************************************************************
Method Name:  showProjListBasedOnSelectedProd
Method Type: Action Method 
Version     : 1.0 
Created Date: 21-1--2015
Function    : This method will fetch the product list based on the selected project .
Input Parameters: None
Output Parameters: None
Used in     : Case Creation
Modification Log :

* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Ranjan       21/10/2015                 Modified
****************************************************************************************************/    
    public PageReference showProjListBasedOnSelectedProd(){
        system.debug('********start*******'+selectedProject);
        String passedParamIdEscape = ApexPages.currentPage().getParameters().get('paramId');
        String passedParamId = (passedParamIdEscape != null)?passedParamIdEscape.escapeHtml4():null;
        If((passedParamId <> null && passedParamId <> '' && Id.valueOf(passedParamId).getSObjectType().getDescribe().getName() == 'Asset') && (selectedProject == 'NA')){
            projectList = Core_IPS_CaseUtility.getIPSProjListBasedOnSelectedProd(passedParamId);                          
        }else if(selectedProject == null){
            selectedProject='';
        }
        return null;                        
    }     
    /************************************************************************************************
Method Name:  PageInit
Method Type: Action Method 
Version     : 1.0 
Function    : This method will validate the type of case and redirect to the error page or edit page.
Input Parameters: None
Output Parameters: None
Used in     : Case Edit
Modification Log :

* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Geetha Arkadu     21/3/2018                 Modified
****************************************************************************************************/    
    public PageReference  PageInit(){
        String profileName = [Select Name from Profile where Id =: UserInfo.getProfileId()].name; //Added by Geetha EDQ
        PageReference Pg =  null;
        if(Mode=='edit' && showGECFields){
            pg =  new PageReference('/apex/Core_IPS_EoisError?ErrCode=G114&retURL='+cs.Id);
        }
        if(Mode=='edit' && isclosed && (profileName != Label.Core_IPS_Partner_AE_ProfileName)) //Added by Geetha EDQ
        {
            pg =  new PageReference('/apex/Core_IPS_EoisError?ErrCode=C113&retURL='+cs.Id);
        }
        return Pg;
    }
    /************************************************************************************************
Method Name:  captureEnvDetails
Method Type: Helper Method 
Version     : 1.0 
Function    : This method will Capture environment details and delete the previous environment detail.
Input Parameters: None
Output Parameters: None
Used in     : Case Create/Edit
Modification Log :

* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* amritesh                    12/18/2017                 Modified
****************************************************************************************************/ 
    // added  by amritesh 12/18/2017 - US8534
        public void captureEnvDetails() {   
        if(cs.Id!=null) {       
            List<Core_IPS_Response__c> lstExistingCoreResponse = Core_IPS_Questions_Utility.getEnvDetailCoreResponse(cs.Id);
            List<Core_IPS_Response__c> lstFilteredCoreResponse = new List<Core_IPS_Response__c>();
            for(Core_IPS_Response__c response:lstExistingCoreResponse){
                if(!isPartnerAgent && response.Core_IPS_Agent_Only__c==false){
                    lstFilteredCoreResponse.add(response);
                }
            }
            if(lstExistingCoreResponse!=null && lstExistingCoreResponse.size()>0) {
                if(!isPartnerAgent && lstFilteredCoreResponse.size()>0 ){
                    Core_IPS_AdminUtility.DeleteEnvDetails(lstFilteredCoreResponse);
                }else{
                    Core_IPS_AdminUtility.DeleteEnvDetails(lstExistingCoreResponse);
                }
            }
      
        }
        List<Core_IPS_Response__c> lstEnvDetailsResponse = new List<Core_IPS_Response__c>();
        List<Core_IPS_EnvironmentDetailQuestion> lstEnvDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        if(envDetails!=null){
            lstEnvDetails.addAll(envDetails);
        } 
        if(subCatenvDetList!=null){
            lstEnvDetails.addAll(subCatenvDetList);
        } 
        if(lstEnvDetails!=null && lstEnvDetails.size()>0) {
            for(Core_IPS_EnvironmentDetailQuestion envdet : lstEnvDetails) {
                lstEnvDetailsResponse.addAll(constructResponse(envdet));
                if(envdet.childQuestions.size()>0) {
                    for(Core_IPS_EnvironmentDetailQuestion childEnvDetail : envdet.childQuestions) {
                        if(childEnvDetail.isVisible){
                            lstEnvDetailsResponse.addAll(constructResponse(childEnvDetail));
                        }
                    }
                }
            }
    
            if(lstEnvDetailsResponse.size()>0){
                Core_IPS_AdminUtility.insertEnvDetailsToCreate(lstEnvDetailsResponse);
            
            }
        }else{
           
            if(cs.Id!=null){
                //cs.Core_jsonfield__c='';
                //cs.Core_Environment_Details__c='';
                cs.Core_IPS_External_Environment_Details__c='<table border="1" width="100%" style=""><tr><th colspan="1" rowspan="1">Question</th><th colspan="1" rowspan="1">Response</th></tr></table>';
                CaseRecordSave caseRecSave=new CaseRecordSave();
       
                caseRecSave.saveCase(cs);
                       
            }
        }
    }

    /************************************************************************************************
Method Name:  constructResponse
Method Type: Helper Method 
Version     : 1.0 
Function    : This method will construct response(Environment Details) and saved while edit and create case .
Input Parameters: Core_IPS_EnvironmentDetailQuestion
Output Parameters: None
Used in     : Case Create/Edit
Modification Log :

* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* amritesh                    12/18/2017                 Modified
****************************************************************************************************/ 
    // added  by amritesh 12/18/2017 - US8534
    @TestVisible private List<Core_IPS_Response__c> constructResponse(Core_IPS_EnvironmentDetailQuestion det) {
        List<Core_IPS_Response__c> lstEnvResponse = new List<Core_IPS_Response__c>();
        Core_IPS_Response__c envResponse = new Core_IPS_Response__c();
        envResponse.Core_IPS_Question_Master__c = det.questionId;
        envResponse.Core_IPS_Case__c = cs.Id;
        envResponse.Core_IPS_Agent_Only__c = det.IsAgentOnly;
        
        if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c.trim()) {
            envResponse.Core_IPS_Answer__c = det.sPlaceHolder;                    
        } else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c) {
            envResponse.Core_IPS_Answer__c = det.tPlaceHolder;
        } else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ) {
            if(String.isNotBlank(det.selectedValue)){
                envResponse.Core_IPS_Answer_Master__c = det.selectedValue;
            }else{
                envResponse.Core_IPS_Answer_Master__c = null;
            }
        }  
        if(det.type == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c) {
            if(det.selectedMValue!=null && det.selectedMValue.size()>0) {
                for(String strSelected : det.selectedMValue) { 
                    if(String.isNotBlank(strSelected)) {
                        Core_IPS_Response__c newEnvResponse = new Core_IPS_Response__c(
                            Core_IPS_Question_Master__c = det.questionId,
                            Core_IPS_Case__c = cs.Id,
                            Core_IPS_Agent_Only__c = det.IsAgentOnly,
                            Core_IPS_Answer_Master__c = strSelected
                        );
                        lstEnvResponse.add(newEnvResponse);
                    } else if(det.selectedMValue.size()==1) {
                        Core_IPS_Response__c newEnvResponse = new Core_IPS_Response__c(
                            Core_IPS_Question_Master__c = det.questionId,
                            Core_IPS_Case__c = cs.Id,
                            Core_IPS_Agent_Only__c = det.IsAgentOnly,
                            Core_IPS_Answer_Master__c = null
                        );
                        lstEnvResponse.add(newEnvResponse);
                    }                
                }
            } else {
                Core_IPS_Response__c newEnvResponse = new Core_IPS_Response__c(
                    Core_IPS_Question_Master__c = det.questionId,
                    Core_IPS_Case__c = cs.Id,
                    Core_IPS_Agent_Only__c = det.IsAgentOnly,
                    Core_IPS_Answer_Master__c = null
                );
                lstEnvResponse.add(newEnvResponse);
            }
            
        } else {
            lstEnvResponse.add(envResponse);
        }
        return lstEnvResponse;
    }
    
    /************************************************************************************************
Method Name:  productChanges
Method Type: action Method 
Version     : 1.0 
Function    : This method will reset the category, subcategory and environment details based on the product  .
Input Parameters: Core_IPS_EnvironmentDetailQuestion
Output Parameters: None
Used in     : Case Create/Edit
Modification Log :

* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Ranjan                    12/18/2017                 Modified
****************************************************************************************************/ 
    public PageReference productChanges(){
        String passedParamId1 = Apexpages.currentPage().getParameters().get('firstparameter');
        String passedParamId2 = Apexpages.currentPage().getParameters().get('secparameter');
        Core_IPS_CaseUtility.mode=  Apexpages.currentPage().getParameters().get('mode');
        //system.debug('Product Change'+passedParamId1+'##### '+passedParamId2);
        If((!String.isBlank(passedParamId1)) || (!String.isBlank(passedParamId2))){
            selectedProductId = passedParamId1.trim();
            selectedProduct = passedParamId2.trim();
            if(String.isBlank(selectedProductId) ){
                projectList = Core_IPS_CaseUtility.getIPSProjectList();
            }else{
                projectList = Core_IPS_CaseUtility.getIPSProjListBasedOnSelectedProd(selectedProductId);
            }
            System.debug('@@@@@@@@@@@@@'+selectedproduct+selectedProject);        
            if(selectedProject == null){
                selectedProject = '';
            }
            if(selectedProduct == null || selectedproduct ==''){
                projectList = Core_IPS_CaseUtility.getIPSProjectList();            
                selectedProductId=null;           
            }
        }
        objectSelected = 'Asset';
        PageReference pg = LookupChange();
        return null;                        
    }
    
    /************************************************************************************************
Method Name:  closePopup
Method Type: action Method 
Version     : 1.0 
Function    : This method will closed contact popup  .
Input Parameters: None
Output Parameters: None
Used in     : Case Create/Edit
Modification Log :

* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Geetha Arkadu                   12/18/2017                 Created
****************************************************************************************************/ 
    //Added by Geetha as per user story US78568
    public void closePopup()
    {       
        displayPopup = false;   
    }    
    
    /************************************************************************************************
Method Name:  showPopup
Method Type: action Method 
Version     : 1.0 
Function    : This method will Open contact popup of logged in user for user story US78568.
Input Parameters: None
Output Parameters: None
Used in     : Case Create/Edit
Modification Log :

* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Geetha Arkadu                   12/18/2017                 Created
****************************************************************************************************/ 
    public void showPopup()
    {       
        displayPopup = true; 
        con=[SELECT Id,FirstName,LastName,Email FROM Contact WHERE ( AccountID In (SELECT AccountID FROM User WHERE id=:userinfo.getuserid()) and (Core_IPS_Active__c=true)) ];
    }   
    // Below Method is for make a blank call to controller to update fields from the vfpage
    public void BindEvent(){}
    
    /************************************************************************************************
Inner Class Name:  CaseRecordSave
Class Type: without sharing
Version     : 1.0 
Function    : This Inner Class bypass The case creation sharing issue.
Method      :saveCase Get case Object 
Used in     : Case Create/Edit
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Ranjan                  12/03/2018                 Created
****************************************************************************************************/ 
    public without sharing class CaseRecordSave{
        public void saveCase(Case cs){
             upsert cs;
        }  
    } 
    /***************************************************************************************************
Method Name:  displayProductVariant
Method Type:  Helper Method 
Version     : 1.0 
Created Date: 08 November 2017
Function    : US80347:To get values of product variant 
Input Parameters: None
Output Parameters: None
Description:   To get values of product variant 
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Popcorn Apps               03/07/2018              Created
****************************************************************************************************/  
    Public void displayProductVariant(){ 
        variants = Product_Variant_Utility.displayProductVariant(selectedProductId); 
        List<SelectOption> so=null;
        variantsList=new List<list<SelectOption>>();
        for(Integer i=0;variants!=null && i<(variants.size()/999)+1;i++){
            so=new List<SelectOption>();
            for(Integer j=(i*999);(j<(i*999)+999) && j<variants.size() ;j++){
                so.add(variants.get(j));
            }
            variantsList.add(so);
        }
        blnShowVariant = Product_Variant_Utility.blnShowVariant;
        system.debug('selectedProductId========'+selectedProductId+'variants========'+variants+'blnShowVariant::'+blnShowVariant);
    }
    
    /***************************************************************************************************
Method Name:  isPartnerAgentUser
Method Type:  Helper Method 
Version     : 1.0 
Created Date: 08 March 2018
Function    : Checked loggedin user is agentpartner or not.
Input Parameters: List of Supported Product Ids 
Output Parameters: List of select options
Description:   This method checks if logged in user is IPS Agent Partner or not , Todo: Move this to Util Class.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Popcorn Apps               03/07/2018              Created
****************************************************************************************************/     
    public static Boolean isPartnerAgentUser(){
        Boolean isPartnerAgent = false;
        User u = [select Id, username,contactid,Profile.Name from User where Id = :UserInfo.getUserId()];
        System.debug('Logged in User Profile: '+ u.Profile.Name);
        if((u.contactid != Null) && (u.Profile.Name ==Label.Core_IPS_Partner_AE_ProfileName)){ // Added by PartnerProfile doc   
            isPartnerAgent=true;
        }else{
            isPartnerAgent=false;
        }
        system.debug('Partner Agent = '+isPartnerAgent);
        return isPartnerAgent;
    }
    
    /***************************************************************************************************
Method Name:  getplatform_Options
Method Type:  Helper Method 
Version     : 1.0 
Created Date: 08 March 2018
Function    : Constructs the Platform options based on supported Product selected
Input Parameters: List of Supported Product Ids 
Output Parameters: List of select options
Description:   Constructs the Platform options based on supp prod
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Popcorn Apps               03/07/2018              Created
****************************************************************************************************/     
    public List<SelectOption> getplatformOptions(List<Id> idList){  
        System.debug('Before'+idList);
        platformOptions = Product_Variant_Utility.getplatform_Options(idList);
        System.debug('After'+platformOptions);
        if(platformOptions.size()>1){ 
            displayPlatform=true;
        }else{ 
            displayPlatform=false;
        }
        return platformOptions;      
    }   
    
    /***************************************************************************************************
Method Name:  NextCaseDetails
Method Type: Action Method 
Version     : 1.0 
Created Date: 06 March 2018
Function    : This method will redirect to the case creation page or Search criteria pagge with parameters.
Input Parameters: None
Output Parameters: PageReference.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahendra Reddy             03/06/2018              Created
****************************************************************************************************/
    public PageReference NextCaseDetails(){
        PageReference pr = new PageReference('/apex/Core_IPS_Customer_Case_Creation'); 
        if(retURL!=null && retURL!=''){
            pr.getParameters().put('retURL', retURL);
        }else{
            pr.getParameters().put('retURL', '/IPS/500');
        }
        if(validateCustomerCase()){
            return null;  
        } 
        ast = [select id, Name,Core_Product_Organization__c,core_supported_product__c,Core_IPS_Project__c,Core_Support_Org_Name__c from asset where id=:selectedProductId];    
        if(System.label.Core_IPS_MAG_Support_Org.Contains((ast.Core_Product_Organization__c+'').substring(0,15))){
            pr.getParameters().put('sbs', 'scs');
            pr.getParameters().put('mode','asset');
        }else{  
            pr.getParameters().put('sbs', 'ccs');
            pr.getParameters().put('mode','asset');
        }
        if(selectedProjId=='NA'){
            selectedProjId=null;
        }
        if(selectedProject=='NoProj')
           { selectedProject=null; }
        pr.getParameters().put('productId',selectedProductId);
        pr.getParameters().put('projectId',selectedProject);
        pr.getParameters().put('pv',selectedVariant);
        pr.setRedirect(true);
        return pr;
    }
    /***************************************************************************************************
Method Name:  CaseCreation
Method Type: Action Method 
Version     : 1.0 
Created Date: 06 March 2018
Function    : This method will redirect to the case creation page with parameters
Input Parameters: None
Output Parameters: PageReference.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Geetha Arkadu             03/06/2018              Created
****************************************************************************************************/
    public PageReference CaseCreation(){
        cs=new case();
        PageReference pr = new PageReference('/apex/Core_IPS_Customer_Case_Creation'); 
        pr.getParameters().put('productId',cs.assetId);
        pr.getParameters().put('projectId',selectedProjId);
        pr.getParameters().put('mode','sNew');
        cs.id=String.valueOf(ApexPages.currentPage().getParameters().get('id'));
        pr.getParameters().put('deflectedid', ApexPages.currentPage().getParameters().get('deflectedid'));
        pr.getParameters().put('retURL', retURL);
        pr.getParameters().put('sbs', 'ccs');
        pr.setRedirect(true); 
        return pr;
    }
    /***************************************************************************************************
Method Name:  SearchBeforeSubmit
Method Type: Action Method 
Version     : 1.0 
Created Date: 06 March 2018
Function    : This Method will create deflected object, prepare iframe url,filtered environment variable, case creation json and store into platform session cache.
Input Parameters: None
Output Parameters: PageReference.
Used in     : PSG product Search / Case create
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Ranjan             03/06/2018              Created
****************************************************************************************************/
    public PageReference SearchBeforeSubmit(){
        cs=new case();
        cs.subject=subject;
        String categoryName='';
        String subCategoryName='';
        Core_IPS_Deflected_Object__c deflectedObj=new Core_IPS_Deflected_Object__c();
        if(validateSearchRelatedInformation()){
            return null;  
        } 
        if(validateFilteredEnvironmentDetails()){
            return null;
        }
        if(!String.isBlank(categorySelected)){
            categoryName=[select id,Core_Issue_Category_Name__r.name,Core_Issue_Sub_Category_Name__r.name from Core_IPS_Product_Issue_Category__c where id=:categorySelected].Core_Issue_Category_Name__r.name;
        }
        if(!String.isBlank(subCategorySelected)){
            subCategoryName=[select id,Core_Issue_Category_Name__r.name,Core_Issue_Sub_Category_Name__r.name from Core_IPS_Product_Issue_Category__c where id=:subCategorySelected].Core_Issue_Sub_Category_Name__r.name;
        }
        cs.Core_Case_Issue_Category__c=categorySelected;
        cs.Core_Case_Issue_Sub_Category__c=subCategorySelected;
        cs.assetId=selectedProductId;
        if(selectedProject=='NoProj'){
            selectedProject=null;
        }
        cs.Core_IPS_Project_Case__c= selectedProject;   
        PageReference pr = new PageReference('/apex/Core_IPS_Customer_Case_Creation'); 
        pr.getParameters().put('subject',subject);
        pr.getParameters().put('productId',cs.assetId);
        pr.getParameters().put('projectId',selectedProjId);
        pr.getParameters().put('mode','iframe');
        User u = [select Id, username,userType,contactId,AccountId from User where Id =:userinfo.getuserid()  limit 1];
        system.debug(' User Info:::'+userinfo.getuserid());
        String caseId=ApexPages.currentPage().getParameters().get('id');
        cs.Core_Severity__c='Low';
        cs.Core_Product_Variant__c=selectedVariant;
        deflectedObj.Core_IPS_Contact_Id__c=u.contactId;
        deflectedObj.Core_IPS_Status__c='Deflected';
        Map<String,id> selectedEnv=new Map<String,id>();
        // Adding Environment Detail for Search cateria
        List<Core_IPS_Response__c> lstEnvDetailsResponse = new List<Core_IPS_Response__c>();
        List<Core_IPS_EnvironmentDetailQuestion> lstEnvDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        if(filteredEnvDetails!=null){
            lstEnvDetails.addAll(filteredEnvDetails);
        }
        if(filteredSubCatenvDetList!=null) {
            lstEnvDetails.addAll(filteredSubCatenvDetList);
        }
        system.debug('lstEnvDetails===>>>'+lstEnvDetails);
        Map<Id,String> masterQns = new Map<ID,String>();
        if(lstEnvDetails!=null && lstEnvDetails.size()>0) {
            for(Core_IPS_EnvironmentDetailQuestion envdet : lstEnvDetails) {
                lstEnvDetailsResponse.addAll(constructResponse(envdet));
                selectedEnv.put(envdet.label,envdet.selectedValue);
                masterQns.put(envdet.questionId,envdet.label);
                system.debug('envdet.label::'+envdet.label);
                system.debug('envdet.selectedValue ::'+envdet.selectedValue);
                if(envdet.childQuestions.size()>0) {
                    for(Core_IPS_EnvironmentDetailQuestion childEnvDetail : envdet.childQuestions) {
                        if(childEnvDetail.isVisible){
                            lstEnvDetailsResponse.addAll(constructResponse(childEnvDetail));
                            selectedEnv.put(childEnvDetail.label,childEnvDetail.selectedValue);
                            masterQns.put(childEnvDetail.questionId,childEnvDetail.label);
                        }
                    }
                }
            }
        }
        // Add environment varibale data to productSearchIframeUrl
        
        List<ID> ansList = selectedEnv.values();
        List<Core_IPS_Answer__c> ansObjList=[select id,Core_IPS_Answer__c  from Core_IPS_Answer__c  where id in:ansList];
        Map<ID,String> masterAns=new Map<ID,String>();
        for(Core_IPS_Answer__c ansObj:ansObjList){
            masterAns.put(ansObj.id,ansObj.Core_IPS_Answer__c);
        }
        
        
        //RCODE US104722
        //create a map from the list lstEnvDetails where Value = label, Key = questionId
       /* Map<Id,String> masterQns = new Map<ID,String>();
        for(Core_IPS_EnvironmentDetailQuestion qsnObj:lstEnvDetails){
                masterQns.put(qsnObj.questionId,qsnObj.label);
        }*/
        system.debug('masterQns ::'+masterQns );
        //Creating a List for Env Details Wrapper
        List<envDetails> eList =  New List <envDetails>();
        for(Integer i = 0; lstEnvDetailsResponse!= null && i < lstEnvDetailsResponse.size(); i++){
            envDetails wrap = new envDetails();
            wrap.Question_ID = lstEnvDetailsResponse[i].Core_IPS_Question_Master__c;
            wrap.Question_Name = masterQns.get(lstEnvDetailsResponse[i].Core_IPS_Question_Master__c) ;
            wrap.Answer_ID = lstEnvDetailsResponse[i].Core_IPS_Answer_Master__C;//Core_IPS_Question_Text__c;
            wrap.Answer_Name = masterAns.get(lstEnvDetailsResponse[i].Core_IPS_Answer_Master__c);
            eList.add(wrap);
        }
        
        //Create a list of strings with Category name , sub category name ,Product name, Project Name 
        List<String> infoList = new List<String>();
        infoList.add(categoryName);
        infoList.add(subCategoryName);
        infoList.add(selectedProduct);
        infoList.add(SelectedProjectName);
        //Pass a list of strings,Env Details list and cs object to class that creates JSON.
        generateJSONContent(infoList,eList,CS);
        deflectedObj.Core_IPS_Search_JSON__c = SearchJSONString;
        // RCODE  US104722 END
        
        upsert deflectedObj;
        String dfoName='';
        List<Core_IPS_Deflected_Object__c> dfoList=[select id,name from Core_IPS_Deflected_Object__c where id=:deflectedObj.id];
        if(dfoList.size()>0){
            dfoName=dfoList[0].Name;
        }
        productSearchIframeUrl=productSearchIframeUrl+'sub='+String.valueOf(cs.subject)+'&lang='+String.valueOf(selectedLanguage)+'&prod='+String.valueOf(selectedProduct)+'&srno='+String.valueOf(dfoName)+'&cat='+String.valueOf(categoryName)+'&area='+String.valueOf(subCategoryName);
        // Environment Variable url preparation
        for(String urlparam:selectedEnv.keySet()){
            Core_IPS_EV_Filters__c myCS = Core_IPS_EV_Filters__c.getValues(urlparam);
            productSearchIframeUrl=productSearchIframeUrl+'&'+myCS.Core_IPS_Param_Name__c+'='+masterAns.get(selectedEnv.get(myCS.name));
        }
        productSearchIframeUrl=productSearchIframeUrl.replaceAll(' ','%20');
        partition.put('iframeURL'+deflectedObj.id, String.valueOf(productSearchIframeUrl),1800);
        System.debug('Case JSON::'+  JSON.serialize(cs));
        partition.put('caseJson'+deflectedObj.id, JSON.serialize(cs),1800);
        System.debug('EnvResponse::'+  JSON.serialize(lstEnvDetailsResponse));
        partition.put('EnvResponse'+deflectedObj.id, JSON.serialize(lstEnvDetailsResponse),1800);
        
        pr.getParameters().put('deflectedid', deflectedObj.id);
        pr.getParameters().put('retURL', retURL);
        pr.getParameters().put('sbs', 'ss');
        pr.setRedirect(true);
        return pr;
    }
    
    /***************************************************************************************************
Method Name:  validateFilteredEnvironmentDetails
Method Type: Helper Method 
Version     : 1.0 
Created Date: 06 March 2018
Function    : This Method validates Filtered Environment Detail Responses provided by customer.
Input Parameters: None
Output Parameters: Returns true if user does not fill the mandatory Environment details and false otherwise.
Description: This Method validates Environment Detail Responses provided by customer.
Used in     : Case Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Ranjan             03/06/2018              Created
****************************************************************************************************/
    public Boolean validateFilteredEnvironmentDetails(){
        // added by amritesh 12/18/2017 - US8534 - start
        List<Core_IPS_EnvironmentDetailQuestion> lstAllenvDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        if(filteredSubCatenvDetList!=null && filteredSubCatenvDetList.size()>0){
            lstAllenvDetails.addAll(Core_IPS_Questions_Utility.getAllWithChildEnvDetails(filteredSubCatenvDetList));
        }
        if(filteredEnvDetails!=null && filteredEnvDetails.size()>0){
            lstAllenvDetails.addAll(Core_IPS_Questions_Utility.getAllWithChildEnvDetails(filteredEnvDetails));
        }
        if(lstAllenvDetails!=null && lstAllenvDetails.size()>0){
            for(Core_IPS_EnvironmentDetailQuestion det : lstAllenvDetails){     
                if(!det.isVisible){
                    continue; // added by amritesh 12/18/2017 - US8534  
                } 
                if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c &&(det.sPlaceHolder==null || det.sPlaceHolder=='') &&det.required){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;    
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c&&(det.sPlaceHolder !=null || det.sPlaceHolder !='') && det.sPlaceHolder.length()>255){ // added  by amritesh 12/18/2017 - US8534
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G111')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;    
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c &&(det.tPlaceHolder==null ||det.tPlaceHolder=='')&&det.required){ // added  by amritesh 12/18/2017 - US8534
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c && (det.tPlaceHolder != null ||det.tPlaceHolder!='') && det.tPlaceHolder.length()>5000){ // added  by amritesh 12/18/2017 - US8534
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G110')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;
                }else if((det.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c) &&(det.selectedValue==null || det.selectedValue=='' || det.selectedValue=='[]') && det.required){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G106')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;
                }
                else if((det.type==Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c) &&(det.selectedMValue==null || det.selectedMValue.size() == 0 ||(det.selectedMValue.size()==1 && det.selectedMValue[0]=='')) && det.required){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G106')+':'+det.label);
                    ApexPages.addMessage(myMsg);
                    return true;
                }
            }
        }
        return false;
    }
    
    //Added by Mahendra per US79769
    public void clearAlldetails(){
        platformOptions=new List<SelectOption>();
        categoryOptions = new List<SelectOption>();
        subCategoryOptions=new List<SelectOption>();
        //selectedProduct='';
        selectedProductId=null;
        showProductRelInfoDialog = false;
    }
    
    //RCODE US104722 START
    //Wrapper Class for Environment Details
    public class envDetails{
        String Question_ID;
        String Question_Name;
        String Answer_ID;
        String Answer_Name;
    }
    
    //Wrapper Class for Search JSON
    Public class searchJSONWrapper{
        String Subject;
        String Category_ID;
        String Category_Name;
        String Sub_Category_ID;
        String Sub_Category_Name;
        String IntelProduct_ID;
        String IntelProduct_Name;
        String Project_ID;
        String Project_Name;
        String Product_Variant_Name;
        List<envDetails> EnvironmentDetails =  New List<envDetails>();
    }
    
    //Create JSON for  Core_IPS_Search_JSON__c field in Deflected object 
    public void generateJSONContent(List<String> infoList, List<envDetails> eList, Case CS) {
        searchJSONWrapper cWrap = New searchJSONWrapper();
        cWrap.Subject = CS.Subject;
        cWrap.Category_ID = CS.Core_Case_Issue_Category__c;
        cWrap.Category_Name = infoList[0];//categoryName
        cWrap.Sub_Category_ID = CS.Core_Case_Issue_Sub_Category__c;
        cWrap.Sub_Category_Name = infoList[1];//subCategoryName
        cWrap.IntelProduct_ID = CS.AssetId;
        cWrap.IntelProduct_Name = infoList[2];//selectedProduct
        cWrap.Project_ID = CS.Core_IPS_Project_Case__c;
        cWrap.Project_Name = infoList[3];//SelectedProjectName
        cWrap.Product_Variant_Name = CS.Core_Product_Variant__c;
        cWrap.EnvironmentDetails = eList;
        SearchJSONString = json.serialize(cWrap);
    }
    //RCODE  US104722 END
}