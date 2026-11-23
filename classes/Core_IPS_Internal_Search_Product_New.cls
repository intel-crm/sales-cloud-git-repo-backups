public with sharing class Core_IPS_Internal_Search_Product_New {
    public String subject{get;set;}
    public String SelectedVariant{get;set;} //req
    public Map<String,String> mapLang_EnvironmentVariables{get;set;}
    public Map<String,Boolean> EnvironmentVariablesvisible {get;set;}
    
    public Case caseObj{get;set;} 
    public String productUrl{get;set;} 
    public Id product{get;set;}
    public String lang{get;set;}
    public boolean Iframe{get;set;}
    public boolean back{get;set;}
    public boolean isCreate{get;set;}
    public  List<SelectOption> variants{get;set;}
    public  Boolean blnShowVariant{get;set;} //req
    Public List<Asset> assList{get;set;}
    Public List<Core_Flat_Product_Hierarchy__c > flatidsList{get;set;}
    
    public void caseCustom(){
    system.debug('caseCustom');
        caseObj=new Case();
        caseObj.subject=ApexPages.currentPage().getParameters().get('subject');
        caseObj.assetId=ApexPages.currentPage().getParameters().get('productId');
       if(ApexPages.currentPage().getParameters().get('projectId')=='')
            caseObj.Core_IPS_Project_Case__c =null;
         else
            caseObj.Core_IPS_Project_Case__c=ApexPages.currentPage().getParameters().get('projectId');
      //  caseObj.Core_IPS_Project_Case__c =ApexPages.currentPage().getParameters().get('projectId');
        system.debug('===caseObj.Core_IPS_Project_Case__c==='+caseObj.Core_IPS_Project_Case__c);
        
        caseObj.Core_Case_Issue_Category__c=ApexPages.currentPage().getParameters().get('CaseCategory');
     //   if(ApexPages.currentPage().getParameters().get('CaseSubCategory')!='')
            caseObj.Core_Case_Issue_Sub_Category__c=ApexPages.currentPage().getParameters().get('CaseSubCategory');
     //   else
     //       caseObj.Core_Case_Issue_Sub_Category__c=null;
        caseObj.Core_Environment_Details__c=ApexPages.currentPage().getParameters().get('EnvironmentDetails');
        if(ApexPages.currentPage().getParameters().get('rType')!=null || ApexPages.currentPage().getParameters().get('rType')!='')
            caseObj.recordtypeId=ApexPages.currentPage().getParameters().get('rType');
        if(ApexPages.currentPage().getParameters().get('back')!=null){
          back=!Boolean.valueof(ApexPages.currentPage().getParameters().get('back'));
       
        }else{
         back=!true;
        }
         if(ApexPages.currentPage().getParameters().get('isCreate')!=null){
          isCreate=Boolean.valueof(ApexPages.currentPage().getParameters().get('isCreate'));
       
        }else{
         isCreate=true;
        }
       system.debug('TTTTTTTTTTTTTTTTT:: '+back);
        subject=caseObj.subject;
        lang=ApexPages.currentPage().getParameters().get('language');
        /*SR#
        SR Title
        Language Code
        Contact Id
        */
        productUrl='https://www.altera.com/bin/search?site=www_sbs&q='+subject+'&btnG=Search+Again&num=10&entqr=3&apps=sbs&output=xml_no_dtd&sort=date%3AD%3AL%3Ad1&ie=UTF-8&client=sbs_www&oe=UTF-8&proxystylesheet=sbs_www&entqrm=0&ud=1&inlang=&ulang=&wc=200&wc_mc=1&entsp=a&SRNo=11321402&SRTitle='+subject+'&AppLang=ENU&ContactId=1-7JYTCP&language='+lang;
         if(ApexPages.currentPage().getParameters().get('Iframe')!=null){
          Iframe=!Boolean.valueof(ApexPages.currentPage().getParameters().get('Iframe'));
       
        }else{
         Iframe=!true;
        }
        If( isCreate==true){}
                
    }
    public PageReference createCasePage() {
    	//Added By Yogesh Sharma
        PageReference pr = new PageReference('/apex/Core_IPS_Internal_Search_Product_New');
        //PageReference pr = new PageReference('/apex/Core_IPS_Internal_Search_Product'); 
        caseObj=new Case();
        caseObj.subject=ApexPages.currentPage().getParameters().get('subject');
        caseObj.id=ApexPages.currentPage().getParameters().get('id');
        caseObj.assetId=ApexPages.currentPage().getParameters().get('productId');
         caseObj.Core_IPS_Project_Case__c =ApexPages.currentPage().getParameters().get('projectId');
       
         caseObj.Core_Case_Issue_Category__c=ApexPages.currentPage().getParameters().get('CaseCategory');
        caseObj.Core_Case_Issue_Sub_Category__c=ApexPages.currentPage().getParameters().get('CaseSubCategory');
        pr.getParameters().put('subject',caseObj.subject);
        pr.getParameters().put('productId',caseObj.assetId);
        pr.getParameters().put('projectId',selectedProjId);
        pr.getParameters().put('id',caseObj.id);
        recordtype rec=[SELECT DeveloperName,Id,Name,SobjectType FROM RecordType where SobjectType ='case' and DeveloperName='IPS_Case_Create' LIMIT 1];//IPS_Closed_Case
        pr.getParameters().put('rType',rec.id);
        pr.getParameters().put('mode','edit');
        pr.getParameters().put('back','false');
        pr.getParameters().put('isCreate','false'); 
        pr.getParameters().put('Iframe','true');
        pr.getParameters().put('CaseCategory',caseObj.Core_Case_Issue_Category__c);
        pr.getParameters().put('CaseSubCategory',caseObj.Core_Case_Issue_Sub_Category__c);
        pr.getParameters().put('EnvironmentDetails',caseObj.Core_Environment_Details__c);
        
        
        pr.setRedirect(true); // If you want a redirect. Do not set anything if you want a forward.        
        return pr;

    }
    public PageReference NextPage() {
        caseObj=new case();
        caseObj.subject=subject;
         caseObj.status='Closed';
        if(selectedProductId=='')
            selectedProductId=null;
         if(selectedProjId=='')
             selectedProjId=null;
         if(categorySelected=='')
             categorySelected=null; 
         if(subCategorySelected=='')
             subCategorySelected=null;
         system.debug('Selected Product id :::'+selectedProductId);
         
        caseObj.Core_Case_Issue_Category__c=categorySelected;
        caseObj.Core_Case_Issue_Sub_Category__c=subCategorySelected;
        caseObj.assetId=selectedProductId;
        caseObj.Core_IPS_Project_Case__c = selectedProjId;
        
        //Added By Yogesh Sharma
        PageReference pr = new PageReference('/apex/Core_IPS_Internal_Search_Product_New');
        //PageReference pr = new PageReference('/apex/Core_IPS_Internal_Search_Product'); 
        
        pr.getParameters().put('subject',subject);
        pr.getParameters().put('productId',caseObj.assetId);
        pr.getParameters().put('projectId',selectedProjId);
        pr.getParameters().put('CaseCategory',categorySelected);
        pr.getParameters().put('back','false');
        pr.getParameters().put('isCreate','false');
        pr.getParameters().put('Iframe','false');
        pr.getParameters().put('CaseSubCategory',subCategorySelected);
        pr.getParameters().put('mode','edit');
        pr.getParameters().put('language',lang);
        recordtype rec=[SELECT DeveloperName,Id,Name,SobjectType FROM RecordType where SobjectType ='case' and DeveloperName='IPS_Closed_Case' LIMIT 1];//IPS_Case_Create
        caseObj.recordtypeId=rec.Id;
       // User u = [select Id, username,userType,contactId,AccountId from User where Id = :UserInfo.getUserId()];
        User u = [select Id, username,userType,contactId,AccountId from User where Id = '0053F000000Hu0b' limit 1];
        system.debug(' User Info:::'+userinfo.getuserid());
        String caseId=ApexPages.currentPage().getParameters().get('id');
        if(!String.isEmpty(caseId))
            caseObj.id=caseId;
        caseObj.contactId=u.contactId;
        caseObj.Accountid = u.AccountId; 
        caseObj.status='closed';
        caseObj.Core_Sub_Status__c='Deflected';
        caseObj.Core_CaseType__c='Question';
        caseObj.Core_Severity__c='Low';
        caseObj.Core_Product_Variant__c=SelectedVariant;
          system.debug('csid::'+cs);
        String jsondata=json.serialize(caseObj);
        Map<String, Object> m =  (Map<String, Object>)JSON.deserializeUntyped(jsondata);
        m.remove('attributes');
        caseObj.Core_Issue_Description__c=json.serialize(m);
        upsert caseObj;
        cs=new Case(id=caseObj.id);
        //cs.id=caseObj.id;
        addFilteredEnvDetails();
        pr.getParameters().put('id',caseObj.id);
        pr.setRedirect(true); // If you want a redirect. Do not set anything if you want a forward.        
        return pr;
    }
    public void addFilteredEnvDetails(){
        system.debug('Debug:::  addEnvDetails'+envDetails);
        //Added By Yogesh Sharma
        List<Core_IPS_Response__c> existingDetails = new List<Core_IPS_Response__c>();
        //List<Core_IPS_Environment_Details__c> existingDetails = new List<Core_IPS_Environment_Details__c>();
        
        //Added By Yogesh Sharma
        existingDetails = [select id from Core_IPS_Response__c where Core_IPS_Case__c =: cs.id];
        //existingDetails = [select id from Core_IPS_Environment_Details__c where Core_case__c=:cs.id];
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + existingDetails);
        if(existingDetails <> null && existingDetails.size()>0){
           // delete ExistingDetails;
           Core_IPS_AdminUtility.DeleteEnvDetails(ExistingDetails);
        }
        //Added By Yogesh Sharma
        List<Core_IPS_Response__c> envDetailsToCreate = new List<Core_IPS_Response__c>();
        //List<Core_IPS_Environment_Details__c> envDetailsToCreate = new List<Core_IPS_Environment_Details__c>();
        
        if(envDetails!=null && envDetails.size()>0){
            for(EnvironmentDetail det:envDetails){
            	
            	//Added By Yogesh Sharma
            	Core_IPS_Response__c detail = new Core_IPS_Response__c();
                //Core_IPS_Environment_Details__c detail = new Core_IPS_Environment_Details__c();
                
                //Added By Yogesh Sharma
                //Not Writable Field
                //detail.Core_IPS_Question__c= det.label;
                detail.Core_IPS_Case__c= cs.id;
                //Not Writable Field
                //detail.Name = det.label;
                detail.Core_IPS_Agent_Only__c = det.IsAgentOnly;
                
                
                //detail.Core_Question__c= det.label;
                //detail.Core_case__c= cs.id;
                //detail.Name = det.label;
                //detail.Core_Agent_Only__c = det.IsAgentOnly;
                
                if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c.trim()){
                    //Added By Yogesh Sharma
                    detail.Core_IPS_Answer__c = det.sPlaceHolder;
                    //detail.Core_Answer__c = det.sPlaceHolder;
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c){
                    
                    //Added By Yogesh Sharma
                    detail.Core_IPS_Answer__c= det.tPlaceHolder;
                    //detail.Core_Answer__c= det.tPlaceHolder;
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ){
                    //Added By Yogesh Sharma
                    detail.Core_IPS_Answer__c= det.selectedValue;
                    //detail.Core_Answer__c= det.selectedValue;
                }else if(det.type == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c){
                    string  strSelectedValue  = '';
                    if(det.selectedMValue!=null){
                        for(string  str  : det.selectedMValue)
                            { 
                             if(str!='')
                              strSelectedValue = strSelectedValue + str + ';' ;
                            }
                    }
                    //Added By Yogesh Sharma
                    detail.Core_IPS_Answer__c = strSelectedValue;//det.selectedValue;
                    //detail.Core_Answer__c = strSelectedValue;//det.selectedValue;
                }/*else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_check').value__c){
                    if( det.cPlaceHolder)
                        detail.Core_Answer__c= 'True';
                    else
                        detail.Core_Answer__c= 'False'; 
                }*/
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>' + detail);
                //Added By Yogesh Sharma
                if(detail.Core_IPS_Answer__c != '')
                //if(detail.Core_Answer__c!='' )
                    envDetailsToCreate.add(detail);
            }
            if(envDetailsToCreate.size()>0){
                 //insert envDetailsToCreate;
                Core_IPS_AdminUtility.insertEnvDetailsToCreate(envDetailsToCreate);
            }
        }   
    }
    public PageReference backButton() {
      system.debug('backButton');
      
        //Added By Yogesh Sharma
        PageReference pr = new PageReference('/apex/Core_IPS_Internal_Search_Product_New');
        //PageReference pr = new PageReference('/apex/Core_IPS_Internal_Search_Product'); 
        
        pr.getParameters().put('subject',caseObj.subject);
        pr.getParameters().put('productId',caseObj.assetId);
        pr.getParameters().put('projectId',selectedProjId);
        pr.getParameters().put('CaseCategory',categorySelected);
        pr.getParameters().put('CaseSubCategory',subCategorySelected);
        pr.getParameters().put('mode','edit');
        pr.getParameters().put('language',lang);
        caseObj=new Case();  
        caseObj.subject=ApexPages.currentPage().getParameters().get('subject');
        caseObj.id=ApexPages.currentPage().getParameters().get('id');
        pr.getParameters().put('id', caseObj.id);
        caseObj.assetId=ApexPages.currentPage().getParameters().get('productId');
        if(ApexPages.currentPage().getParameters().get('projectId')=='')
            caseObj.Core_IPS_Project_Case__c =null;
         else
            caseObj.Core_IPS_Project_Case__c=ApexPages.currentPage().getParameters().get('projectId');
         //caseObj.Core_IPS_Project_Case__c =ApexPages.currentPage().getParameters().get('projectId');
       
        caseObj.Core_Case_Issue_Category__c=ApexPages.currentPage().getParameters().get('CaseCategory');
        caseObj.Core_Case_Issue_Sub_Category__c=ApexPages.currentPage().getParameters().get('CaseSubCategory');
       
        pr.setRedirect(true); // If you want a redirect. Do not set anything if you want a forward.        
        return pr;
    }

    //Need to remove unused variables - JP
    public Id productId{get;set;}
    public Asset ast{get;set;}
    public String GECAnswer1{get;set;}
    public String GECAnswer2{get;set;}
    public String GECAnswer3{get;set;}
    public boolean isEditable{get;set;}
    public List<SelectOption> AnswerOptions{get;set;}
    public List<SelectOption> countryOptions{get;set;}
    public boolean showGECFields{get;set;}
    public boolean editCloseCase{get;set;}
    public String categorySelected{get; set;}
    public List<SelectOption> categoryOptions{get;set;} 
    public List<SelectOption> subCategoryOptions{get;set;}
    public List<SelectOption> platformOptions{get;set;}
    public List<EnvironmentDetail> envDetails{set;get;}
    public List<EnvironmentDetail> envDetList{get;set;}
    public Case cs{get;set;}
    public boolean isAgent{get;set;}
    public boolean isSalesAgent{get;set;}
    public boolean displayEnvDetails{get;set;}
    public boolean displayCategories{get;set;}
    public boolean displaySubCategories{get;set;}
    public boolean displayPlatform{get;set;}
    public boolean renderErrorFlag{get;set;}
    public List<SelectOption> projectList{get;set;}
    public string selectedProject{get;set;}
    public String selectedProduct{get;set;}
    public String selectedProductId{get;set;}
    public String selectedSAProductId{get;set;}
    public String selectedContactId{get;set;} 
    public String selectedProjId{get;set;}
    public boolean displaySelfAssigned{get;set;}
    public boolean displayIPSCase{get;set;}
    public string mode{get;set;} 
    public String caseTypeSelected{get;set;}
    private List<Core_IPS_Labels__c> LstCustomLabels ;

   // public String selectedSAProductId{get;set;}
    public String selectedSAProduct{get;set;}
    public id assetId;
    public List<core_IPS_supported_product__c> supProduct{get;set;}
    public ApexPages.standardController controller{get;set;}
    public string objectSelected{get;set;}
    public String subCategorySelected{get; set;}
    public boolean displayForCust{get;set;} // Not really needed. always set to false. In VF page, boolean is referred. - Syed
    public boolean caseInformationReadOnly{get;set;} // May be used for Edit Case which is not yet in corporated in this code. As of now this variable is not needed. - Syed
    public boolean displayProject{get;set;}
    public String selectedContact{get;set;}
    public String projSelected{get;set;}
    //public boolean displayCaseType{get;set;}
    public boolean displayProdSection{get;set;}
    public String platformSelected{get;set;}
    public boolean DisplayPriorityReason {get;set;}
    //public core_IPS_supported_product__c supProd;
    public String csId;
    
    //Added By Yogesh Sharma
    public Core_IPS_Internal_Search_Product_New(ApexPages.standardController controller){
    //public Core_IPS_Internal_Search_Product(ApexPages.standardController controller){
    
        this.controller=controller;
        csId = controller.getId();
        blnShowVariant = false;
        isAgent = Core_IPS_Helper_Utility.isIPSCustomerUser();
        isSalesAgent = Core_IPS_Helper_Utility.isIPSSalesUser();
        displayProject = true;
        displayProdSection=false;
        showGECFields =false;
        editCloseCase = false;
        mode = apexpages.currentpage().getParameters().get('mode');
        envDetails = new List<EnvironmentDetail>();
        LstCustomLabels = Core_IPS_Labels__c.getall().values();
        //[Dec/16/2015 - START - Checking the accessability.]
     
        if(csId !=null && csId != ''){
            isEditable = [SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfo.getuserId() AND RecordId = :csId].HasEditAccess;
        }
        //[Dec/16/2015 - END]
        caseCustom();
       
        if(csId==null ){
            cs = new Case();
            
            cs.Core_CaseType__c = '';
            //cs.Core_Intel_Sup_Owner__c = Core_IPS_CaseUtility_dup.getIntelSupportOwner();
            caseInformationReadOnly=false;
            
            
            String sub= ApexPages.currentPage().getParameters().get('subject');
            cs.subject=sub;
            
            String recType = ApexPages.currentPage().getParameters().get('rType');
            String subcategory=ApexPages.currentPage().getParameters().get('CaseSubCategory');
            cs.Core_Case_Issue_Sub_Category__c=subcategory;
            subCategorySelected=cs.Core_Case_Issue_Sub_Category__c;
            
            String category=ApexPages.currentPage().getParameters().get('CaseCategory');
            cs.Core_Case_Issue_Category__c=category;
            categorySelected=cs.Core_Case_Issue_Category__c;
           
            //Retrieve the record type id by name            
            String recordTypeId_NewCase = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
            String recordTypeId_SA = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
            System.debug('*******'+recordTypeId_NewCase+'*****'+recordTypeId_SA+'******'+recType+'&&'+recordTypeId_NewCase.substring(0,15));
            If(recType == recordTypeId_NewCase.substring(0,15)){
                displayIPSCase=true;
                displaySelfAssigned = false;
                selectedSAProductId =null;
                selectedSAProduct =null;
                caseTypeSelected='newCase';
                cs.RecordTypeId = recType;
            }
            If(recType == recordTypeId_SA.substring(0,15)){
               displayProject=false;
               displayIPSCase=false; 
               displaySelfAssigned = true;
               caseTypeSelected='selfAssigned';
               cs.RecordTypeId = recType;
               //contactClear(); 
               //selectedContactId =null;
               //selectedContact =null;
               if(ast!=null)
                  ast =null;                      
            }                        
            //showGECFields = Core_IPS_Helper_Utility.isGECAccount();
            //if(mode=='new')
                //projectList = Core_IPS_CaseUtility_dup.getIPSProjectList();
            if(mode=='asset'){
                caseInformationReadOnly=true;                
                String passedprojectId = ApexPages.currentPage().getParameters().get('projectId');               
                String passedproductId = ApexPages.currentPage().getParameters().get('productId');
               //selectedProject=passedprojectId;
                //selectedProductId = passedproductId;
                if(passedprojectId!=null && passedprojectId!=''){
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + passedprojectId);
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + [select id, name from core_ips_project__c where id=:passedprojectId].size());
                    projSelected = [select id, name from core_ips_project__c where id=:passedprojectId].Name;
                    //selectedProject=passedprojectId;
                    selectedProjId = passedprojectId;
                }
                if(passedproductId!=null && passedproductId!=''){
                    ast = [select id, name,core_supported_product__c from asset where id=:passedproductId limit 1];
                    selectedProduct = ast.Name;
                    selectedProductId=passedproductId;
                   
                }
                
                categoryOptions = new List<SelectOption>();
                       subCategoryOptions=new list<SelectOption>();
                       subCategoryOptions=getsubCategory_Options(categorySelected);
             
                if(ast!=null && null != ast.core_supported_product__c){ 
                    //categoryOptions.add(new SelectOption('', 'Select Category'));
                    for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility_dup.getCategories(ast.core_supported_product__c) ){
                        categoryOptions.add(new SelectOption(a.id, a.Core_Issue_Category_Name__r.Name));
                    } 
                    if(categoryOptions.size()>1){
                        Core_Utility.doSort(categoryOptions, Core_Utility.FieldToSort.Label,'Select Category');
                        //categoryOptions.sort();
                        displayCategories=true;
                        subCategoryOptions=new List<SelectOption>();
                        subCategoryOptions.add(new SelectOption('', 'Select Category'));
                        displaySubCategories=true;
                    } 
                     if(cs <> null && cs.Core_Case_Issue_Sub_Category__c!=null){
                       subCategorySelected=cs.Core_Case_Issue_Sub_Category__c;
                       subCategoryOptions=new list<SelectOption>();
                       subCategoryOptions=getsubCategory_Options(categorySelected);
                    //System.debug('###################'+cs.core_ips_project_case__c+subCategorySelected);
                    }
                }
                envDetails=getEnvironmentDetailsOperationList(ast.core_supported_product__c,subCategorySelected,isAgent); 
            }
        }else if(mode=='edit'){
            displayProdSection=true;
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You will lose existing environment Details!'));
            //mode = apexpages.currentpage().getParameters().get('mode');
            System.debug('@@@@@@@@@'+csId+isAgent);            
            cs = Core_IPS_CaseUtility_dup.getCase_DynamiCSOQL(csId,isAgent);
            if(cs.Recordtype.DeveloperName=='IPS_GEC_ReadOnly')
            {
              showGECFields = true;
            }
            if(cs.Recordtype.DeveloperName=='IPS_Closed_Case')
            {
              editCloseCase = checkcloseCaseEditPermission();
            }
            //showGECFields = Core_IPS_Helper_Utility.isGECAccount(cs.contactID);
            //cs.Core_CaseType__c = 'Issue';
            caseInformationReadOnly=true;
            System.debug('case:'+cs);
            if(cs <> null && cs.Core_Case_Issue_Category__c!=null)
                categorySelected=cs.Core_Case_Issue_Category__c;                
            if(cs <> null && cs.Core_IPS_Supported_Product__c <> null /*&& categorySelected <> null && categorySelected <> ''*/){    
                categoryOptions=new list<SelectOption>();
                categoryOptions=getCategoryOptions(cs.Core_IPS_Supported_Product__c);           
            }
            if(cs <> null && cs.Core_Case_Issue_Sub_Category__c!=null){
               subCategorySelected=cs.Core_Case_Issue_Sub_Category__c;
               subCategoryOptions=new list<SelectOption>();
               subCategoryOptions=getsubCategory_Options(categorySelected);
            //System.debug('###################'+cs.core_ips_project_case__c+subCategorySelected);
            }
            if(cs <> null && cs.core_ips_project_case__c!=null){
                //selectedProject = cs.core_ips_project_case__r.name;
                //selectedProject = cs.core_ips_project_case__r.name;
                //selectedProject = cs.core_ips_project_case__c;
                system.debug('******selectedProjId******'+selectedProjId+cs.core_ips_project_case__c);
                projSelected = cs.core_ips_project_case__r.Name;
                selectedProjId = cs.core_ips_project_case__c;
            }
            //if(mode=='edit'){     
            
            if(cs <> null && cs.assetId!=null){
            system.debug('**********************' + selectedProductId);
                //selectedProduct = cs.Supported_Product__r.name;
                selectedProduct=cs.asset.name;
                selectedProductId = cs.assetId;
                //if(cs.Platform_Name__c != null){
                    platformSelected=cs.Core_Platform_Name__c;
                    List<Id> assetIdList = new List<Id>();
                    assetIdList.add(cs.assetId);
                    platformOptions=getplatformOptions(assetIdList);
                //}
            }
            system.debug('>>>>>>>>>>>>>>>' + cs.ContactId);
            if(cs <> null && cs.ContactId <> null){
                //Contact con = [select id,account.ownerId from contact where id=:selectedContactId];
                selectedContact = cs.Contact.Name;
                selectedContactId = cs.ContactId;                
            }
            if(cs <> null && cs.Core_IPS_Supported_Product__c <> null && cs.assetId == null){
                selectedSAProductId = cs.Core_IPS_Supported_Product__c;
                displayProject=false;                                                                               
                //LookupChange(); 
                if(cs.productId <> null && cs.product.name!=null)
                selectedSAProduct = cs.product.name;
                //selectedSAProduct = supProd.core_product__r.name;                                       
                displaySelfAssigned = true;
                platformSelected=cs.Core_Platform_Name__c;
                List<Id> idList = new List<Id>();
                idList.add(selectedSAProductId);
                platformOptions=getplatformOptions(idList);
                 caseTypeSelected='selfAssigned';
                
            }
            if(cs <> null && cs.Core_Severity__c == 'Critical'){
                DisplayPriorityReason = true;
            }
            system.debug('cs.Core_IPS_Supported_Product__c>>>>>>>>>>>>>>>>>>>' + cs.Core_IPS_Supported_Product__c);
            system.debug('cs.subCategorySelected>>>>>>>>>>>>>>>>>>>' + subCategorySelected);
            
            envDetails=getEnvironmentDetailsOperationList(cs.Core_IPS_Supported_Product__c,subCategorySelected,isAgent); 
            setCurrentEnvironmentDetails(envDetails,csId);   
            //}
        }
        //subCategoryOptions = new List<SelectOption>();
    }
    
    public boolean checkcloseCaseEditPermission()
    {
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
    public pagereference clearProject(){
        if(selectedProduct!=null && selectedproduct!=''){
            selectedProduct=null;
        }
        return null;
    }
    
    public List<SelectOption> getCountriesOptions() {
        
        countryOptions = new List<SelectOption>();
        //countryOptions.add(new SelectOption('','-None-'));        
        Schema.Describefieldresult result = Schema.sObjectType.Account.fields.Core_Account_Country__c;
        Schema.DescribeFieldResult fieldResult = result.getSObjectField().getDescribe();//Contact.BillingCountry.getDescribe();
        System.debug('$$$$$$$$$$$$$$$'+fieldResult);
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        System.debug('$$$$$$$picklist$$$$$$$$'+ple);
        for( Schema.PicklistEntry f : ple)
        {
           countryOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        Core_Utility.doSort(countryOptions, Core_Utility.FieldToSort.Label,'-None-');
        return countryOptions;
    }
    
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
       String preURL = ApexPages.CurrentPage().getHeaders().get('referer');
       String retURL = ApexPages.CurrentPage().getParameters().get('retURL');
       System.debug('URL *************' + preURL);
       PageReference pg;
        if(preURL.indexof('assetid') > -1)
           pg = new PageReference('/02i/o'); 
        else if(retURL !=null && retURL !='')
           pg = new PageReference(retURL);
        else
           //Added By Yogesh Sharma
           pg = new PageReference('/apex/Core_IPS_Internal_Search_Product_New'); 
           //pg = new PageReference('/apex/Core_IPS_Internal_Search_Product');
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
    ****************************************************************************************************/   
    public void setCurrentEnvironmentDetails(List<EnvironmentDetail> envDetails, String caseId){
    	//Added By Yogesh Sharma
    	List<Core_IPS_Response__c> caseEnvDetails = [select id,name,Core_IPS_Question__c,Core_IPS_Answer__c from Core_IPS_Response__c where Core_IPS_Case__c =: caseId];
        //List<Core_IPS_Environment_Details__c> caseEnvDetails = [select id,name,Core_Question__c,Core_Answer__c from Core_IPS_Environment_Details__c where Core_Case__c=:caseId];
        
        if(envDetails!=null){
            for(EnvironmentDetail ed: envDetails){
            	//Added By Yogesh Sharma
            	for(Core_IPS_Response__c ced:caseEnvDetails){  
                //for(Core_IPS_Environment_Details__c ced:caseEnvDetails){
                    System.debug('CED Name:'+ced.name+'ED Label:'+ed.label);
                    if(ced.name==ed.label){
                        if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c || ed.type==Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').Value__c)
                        {
                          //Added By Yogesh Sharma
                          if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c && ced.Core_IPS_Answer__c!=null)	
                          //if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c && ced.Core_Answer__c!=null)
                          {
                          	//Added By Yogesh Sharma
                          	List<string> LstSelectOptions = ced.Core_IPS_Answer__c.split(';');
                            //List<string> LstSelectOptions = ced.Core_Answer__c.split(';');
                           
                           // LstSelectOptions.remove(LstSelectOptions.size()-1);
                            ed.selectedMValue=LstSelectOptions;
                          }
                          else
                          {
                          	//Added By Yogesh Sharma
                          	ed.selectedValue=ced.Core_IPS_Answer__c;
                            //ed.selectedValue=ced.Core_Answer__c;
                          }
                        }
                        else if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c)
                            
                            //Added By Yogesh Sharma
                            ed.sPlaceholder=ced.Core_IPS_Answer__c;
                            //ed.sPlaceholder=ced.Core_Answer__c;
                        else if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c)
                            //Added By Yogesh Sharma
                            ed.tPlaceholder=ced.Core_IPS_Answer__c;
                            //ed.tPlaceholder=ced.Core_Answer__c;
                        /*else if(ed.type==Core_IPS_Labels__c.getValues('Core_IPS_check').value__c){
                            if(ced.core_answer__c=='True')
                            ed.cPlaceholder= true;
                            else
                            ed.cPlaceholder = false
                        }
                        */
                        break;
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
    public pagereference LookupChange(){
        system.debug('@@@@@@@@@@objectSelected@@@@@@@'+objectSelected);
        if(objectSelected <> null && objectSelected <> '' && objectSelected == 'Project' && selectedContact!=null && selectedContact!='' && projSelected <> null && projSelected <> '' && selectedProduct!=null && selectedproduct!=''){            
            selectedProduct='';
            selectedProductId='';
            //system.debug('@@@@@@@@@@@@@@proj@@@@@'+cs.core_ips_project_case__c+'*******'+selectedProjId+projSelected);
            //cs.core_ips_project_case__c = selectedProjId;            
        }
         if(objectSelected <> null && objectSelected <> '' && objectSelected == 'Product')
        {
            string passedParam1 = Apexpages.currentPage().getParameters().get('paramId');            
            system.debug('@@@@@@@@@@2' + passedParam1);
            if(passedParam1 <> null && passedParam1 <> '')
            selectedProductId = passedParam1;//Core_IPS_Helper_Utility.isGECAccount(passedParam1);
          
        } 
        if(objectSelected <> null && objectSelected <> '' && objectSelected == 'Contact')
        {
            string passedParam1 = Apexpages.currentPage().getParameters().get('paramId');            
            system.debug('@@@@@@@@@@2' + passedParam1);
            if(passedParam1 <> null && passedParam1 <> '')
            {
             selectedContactId = passedParam1;//Core_IPS_Helper_Utility.isGECAccount(passedParam1);
             Pagereference  Pg1 =  showGECFieldsToIntUsrsForMAGAcc();
            }
          
        } 
        if(selectedProductId!=null && selectedProductId!=''){
            cs.assetId = selectedProductId;
            ast = [select id, Name,Core_Product_Organization__c,core_supported_product__c,core_supported_product__r.Core_Product_Type__c,Core_IPS_Project__c from asset where id=:selectedProductId limit 1];  
            system.debug('Selected supProduct record :::'+ast);
        
            if(ast!=null&&ast.core_supported_product__r.Core_Product_Type__c != 'PSG Org'){
                system.debug('Not PSG Org');
                
                //Added By Yogesh Sharma
                PageReference pr = new PageReference('/apex/Core_IPS_Internal_Search_Product_New');
                //PageReference pr = new PageReference('/apex/Core_IPS_Internal_Search_Product'); 
                pr.getParameters().put('subject',subject);
                pr.getParameters().put('productId',cs.assetId);
                pr.getParameters().put('language',lang);
                pr.getParameters().put('back','false');
                pr.getParameters().put('mode','asset');
                recordtype rec=[SELECT DeveloperName,Id,Name,SobjectType FROM RecordType where SobjectType ='case' and DeveloperName='IPS_Case_Create' LIMIT 1];//
                pr.getParameters().put('rType',rec.id);
                pr.getParameters().put('isCreate','false'); 
                pr.getParameters().put('Iframe','true');
                pr.setRedirect(true);
                system.debug('LoggingLevel logLevel'+ pr);
                return pr;
             
            }
            if(ast!=null&&ast.core_supported_product__r.Core_Product_Type__c == 'PSG Org'){
                    system.debug('PSG Org');
            }
            List<Id> astIdList=new List<Id>();
            if(ast.core_supported_product__c!=null){
                astIdList.add(ast.Id);
                platformOptions=getplatformOptions(astIdList);
                if(platformOptions !=null && platformOptions.size()>1 && csId <> null && csId <> ''){
                    displayPlatform=true;
                }else{
                   displayPlatform=false;
                }
                categoryOptions=getCategoryOptions(ast.core_supported_product__c);
                categorySelected =''; 
                //[24/Jan/2016 - Start]
                system.debug('categorySelected**************'+categorySelected+getsubCategory_Options(categorySelected));
                subCategoryOptions=getsubCategory_Options(categorySelected);
                subCategorySelected =''; 
                //[24/Jan/2016 - End]                
                //displaySubCategories=true;
                List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
                envVars = Core_IPS_CaseUtility_dup.getEnvVariables(ast.core_supported_product__c,null,isAgent);
                if(envVars!=null && envVars.size()>0){
                    displayEnvDetails=true;
                    envDetails=constructWrapper(envVars);
                }else{
                   displayEnvDetails=false;
                }
            }           
        }
        if(selectedSAProductId!=null && selectedSAProductId!=''){
            System.debug('@@@@@@'+selectedSAProductId);           
            //supProd= [select id,Core_Supported_Product_Name__c, Name,Core_Product_Organization__c,Core_Product__c,Core_Product__r.name from core_IPS_supported_product__c where id=:selectedSAProductId];    
            if(selectedSAProductId !=null){       
                cs.Core_IPS_Supported_Product__c = selectedSAProductId;
                categoryOptions=getCategoryOptions(selectedSAProductId);
                categorySelected =''; 
                subCategoryOptions=getsubCategory_Options(categorySelected);
                subCategorySelected ='';
                List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
                envVars = Core_IPS_CaseUtility_dup.getEnvVariables(selectedSAProductId,null,isAgent);
                if(envVars!=null && envVars.size()>0){
                    displayEnvDetails=true;
                    envDetails=constructWrapper(envVars);
                }else{
                   displayEnvDetails=false;
                }
                List<Id> suppProdList=new List<Id>();
                suppProdList.add(selectedSAProductId);
                platformOptions=getplatformOptions(suppProdList);
                if(platformOptions !=null && platformOptions.size()>1 && csId <> null && csId <> ''){
                    displayPlatform=true;
                }else{
                   displayPlatform=false;
                }
            }                                       
        }
        
        //Product_Variant_Utility.DisplayProductVariant(selectedProductId);
        DisplayProductVariant();
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
            if(supportedProductId <> null && Core_IPS_CaseUtility_dup.getCategories(supportedProductId) <> null && Core_IPS_CaseUtility_dup.getCategories(supportedProductId).size() > 0){
                for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility_dup.getCategories(supportedProductId)){
                    if(a <> null && a.Core_Issue_Category_Name__r <> null && a.Core_Issue_Category_Name__r.Name <> null)
                        categoryOptions.add(new SelectOption(a.id, a.Core_Issue_Category_Name__r.Name));
                }
                system.debug('categoryOptions' + categoryOptions);
                //Core_Utility.doSort(categoryOptions, Core_Utility.FieldToSort.Label); 
                        
            }
        if(categoryOptions.size()>0){
            Core_Utility.doSort(categoryOptions, Core_Utility.FieldToSort.Label,'Select Category');
            //categoryOptions.sort();
            displayCategories=true;
            subCategoryOptions=new List<SelectOption>();
            subCategoryOptions.add(new SelectOption('','Select Option'));
            displaySubCategories=true;
        }else{
            displayCategories=false;
        } 
        system.debug('categoryOptions' + categoryOptions);      
        return categoryOptions;
   }
   
    /***************************************************************************************************
    Method Name:  contactClear
    Method Type: helper Method 
    Version     : 1.0 
    Created Date: 14 Oct 2015
    Function    : Clears the selected product and project
    Input Parameters: None 
    Output Parameters: None
    Description:   Clears the selected product and project
    Used in     : Case Creation
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              10/14/2015              Created
    ****************************************************************************************************/     
    public void contactClear(){

        selectedProduct = null;
        selectedProductId =null;
        //projSelected = null;
        selectedProjId = null;
        subCategorySelected=null;
        categorySelected=null;
        
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
         if(envDetails!=null){ envDetails.clear();envDetList.clear();}
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
        //List<SelectOption> subCategoryOptions = new List<SelectOption>();
        subCategoryOptions = new List<SelectOption>();
        System.debug('Category Selected:'+categorySelected);
        if(categorySelected!=null && categorySelected!=''){
            //subCategoryOptions.add(new SelectOption('', 'Select SubCategory'));
            for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility_dup.getSubCategories(categorySelected)){
              system.debug('inside for '+a.Core_Issue_Sub_Category_Name__r.Name+' '+Core_IPS_CaseUtility_dup.getSubCategories(categorySelected));
                if(a.Core_Issue_Sub_Category_Name__c!=null){
                subCategoryOptions.add(new SelectOption(a.id, a.Core_Issue_Sub_Category_Name__r.Name));
                system.debug('inside for and if'+subCategoryOptions);
                }
            }
            system.debug('>>>>>>>>>>>>' + subCategoryOptions);
            Core_Utility.doSort(subCategoryOptions,Core_Utility.FieldToSort.Label,'Select SubCategory');
            if(subCategoryOptions.size()>0){/*Core_Utility.doSort(subCategoryOptions, Core_Utility.FieldToSort.Value,'Select SubCategory');*/displaySubCategories=true;}
            else displaySubCategories=false;
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
    ****************************************************************************************************/    
   public Pagereference getEnvDetails(){
     system.debug(subcategorySelected);
       if(subcategorySelected!=null && subcategorySelected!=''){
            subcategorySelected='';
       }    
       subCategoryOptions=getsubCategory_Options(categorySelected); 
       system.debug('subCategoryOptions*********'+subCategoryOptions);
       getsubCategory_Options(categorySelected);
      // [Nov/06/2015 - Start - Vaibhav Dubey - Defect# -8422 ]
       getEnvironmentDets();
    //   [Nov/06/2015 - END - Vaibhav Dubey - Defect# -8422 ]  
   // getDetails();
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
    ****************************************************************************************************/ 
   public Pagereference getEnvironmentDets(){
  
    envDetails =getDetails();
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
            envVars = Core_IPS_CaseUtility_dup.getEnvVariables(ast.core_supported_product__c,null,isAgent);
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
    ****************************************************************************************************/     
   public List<EnvironmentDetail> getDetails(){
       List<Core_IPS_Assigned_Environment_Variables__c> envVars;
       System.debug('Is Agent:'+isAgent);
       if(selectedProductId!=null && selectedProductId!=''){
        assetId= selectedProductId;
        ast = [select id, core_supported_product__c from asset where id=:assetId];
        productId=ast.core_supported_product__c;
        }
        if(selectedSAProductId!=null)
        productId = selectedSAProductId;
        envVars = Core_IPS_CaseUtility_dup.getEnvVariables(productId,null,isAgent);
       if(categorySelected==null || (categorySelected!=null && categorySelected.trim().length()==0) || subcategorySelected==null || (subcategorySelected!=null && subcategorySelected.trim().length()==0)){
            if(categorySelected==null || (categorySelected!=null && categorySelected.trim().length()==0)){
                subCategorySelected=' ';
            }
            envVars = Core_IPS_CaseUtility_dup.getEnvVariables(productId,null,isAgent);
            if(envVars.size()>0) displayEnvDetails=true;
            return constructWrapper(envVars);
        }else if(subcategorySelected!=null && subcategoryselected!='')
          envVars = Core_IPS_CaseUtility_dup.getEnvVariables(null,subCategorySelected,isAgent);
       if(envVars!=null && envVars.size()==0){
           envVars = Core_IPS_CaseUtility_dup.getEnvVariables(productId,null,isAgent);
       }
       if(envVars!=null && envVars.size()>0){
        displayEnvDetails=true;
        return constructWrapper(envVars);
       }else{
           displayEnvDetails=false;
           return null;
       }
       return null;
       
   }

    private List<EnvironmentDetail> getEnvironmentDetailsOperationList(String productId, String subCategoryId, boolean isAgent){
        List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
        if(subCategoryId!=null && subCategoryId!=''){
           system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + subCategoryId);
            envVars=Core_IPS_CaseUtility_dup.getEnvVariables(null,subCategoryId,isAgent);
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + envVars.size());
            if(envVars.size() == 0 && productId!=null)
            {
               envVars=Core_IPS_CaseUtility_dup.getEnvVariables(productId,null,isAgent);
            }
        }else if(productId!=null){
            envVars=Core_IPS_CaseUtility_dup.getEnvVariables(productId,null,isAgent);
        }
        if(envVars <> null && envVars.size()>0){
            displayEnvDetails=true;
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
   public List<EnvironmentDetail> constructWrapper(List<Core_IPS_Assigned_Environment_Variables__c> envVars){
        Map<string,Core_IPS_Assigned_Environment_Variables__c> MapAssigned_EnvironmentVariables = new Map<string,Core_IPS_Assigned_Environment_Variables__c>();
        
        boolean IsOptionsChanges =  false;
        //code added for language
        mapLang_EnvironmentVariables = new Map<string,String>();
        Set<String> setLang_EnvironmentVariablesId=new Set<String>(); 
        for(Core_IPS_Assigned_Environment_Variables__c Ev:envVars){
         setLang_EnvironmentVariablesId.add(Ev.Core_Environment_Variable__c);
        }
        
        //Added By Yogesh Sharma 
        map<String , Core_IPS_Question__c> evmaster=new map<String , Core_IPS_Question__c>([select id,name from Core_IPS_Question__c where id in:setLang_EnvironmentVariablesId]);
        //map<String , Core_IPS_Environment_Variables__c> evmaster=new map<String , Core_IPS_Environment_Variables__c>([select id,name,Language__c from Core_IPS_Environment_Variables__c where (parent_language__c in:setLang_EnvironmentVariablesId or id in:setLang_EnvironmentVariablesId) and  Language__c =:Label.Core_IPS_Languages]);
        
        system.debug('setLang_EnvironmentVariablesId ::'+setLang_EnvironmentVariablesId);
        system.debug('evmaster::'+evmaster);
        // end here
        
        for(Core_IPS_Assigned_Environment_Variables__c Ev:envVars)
        {
        if(Ev.Core_Environment_Variable__c !=null && Ev.Core_Environment_Variable__r.Name !=null && Ev.Core_Environment_Variable__r.Name !='')
        {
        system.debug('Ev.Core_Environment_Variable__c:::'+Ev.Core_Environment_Variable__c);
         MapAssigned_EnvironmentVariables.Put(Ev.Core_Environment_Variable__r.Name,ev);
         }
        }
        if(envDetails !=null && envVars !=null && envDetails.size() == envVars.size())
        {
         for(EnvironmentDetail En :envDetails)
         {
           system.debug(en.Label);
           system.debug(en.type);
            //system.debug(en.splaceholder);
           system.debug(en.selectedValue);
           if(MapAssigned_EnvironmentVariables.containsKey(en.Label)==false)
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
       system.debug('>>>>>>>>>>>>>>>>>>>>>>>' + IsOptionsChanges);
       if(IsOptionsChanges==false)
       {
         return envDetails;
       }
       EnvironmentVariablesvisible = new Map<string,Boolean>();
       envDetList = new List<EnvironmentDetail>();
        for(Core_IPS_Assigned_Environment_Variables__c en:envVars){
            EnvironmentDetail det = new EnvironmentDetail();
            det.label=en.Core_Environment_Variable__r.name;
            EnvironmentVariablesvisible.put((det.Label).toUpperCase(),false); 
            det.required = en.Core_required__c;
            det.IsAgentOnly = en.Core_Agent_Only__c;
            system.debug('>>>>>>>>>>>>>' + en.Core_Environment_Variable__r.Core_Datatype__c); 
            system.debug('<<<<<<<<<<<<<<<<<' + Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c);
            
            if(en.Core_Environment_Variable__r.Core_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c.trim()){
            system.debug('LLLLLLLLLLLLL' + (en.Core_Environment_Variable__r.Core_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c.trim()));
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c;
                if(en.Core_Environment_Variable__r.Core_Answers__C!=null)
                    det.splaceHolder=en.Core_Environment_Variable__r.Core_Answers__C;
                else
                    det.splaceHolder = '';
                
            }else if(en.Core_Environment_Variable__r.Core_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim() || en.Core_Environment_Variable__r.Core_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim()){
                List<String> answersList = en.Core_Environment_Variable__r.Core_Answers__C.split('\n');
                List<SelectOption> selectOptionsList = new List<SelectOption>();
                SelectOptionsList.add(new SelectOption('','Select Option'));
                for(String ans:answersList){
                    ans=ans.trim();
                    selectOptionsList.add(new SelectOption(ans,ans));
                }
                if(en.Core_Environment_Variable__r.Core_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim())
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim();
                else{
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim();
                }
                det.pplaceholder=selectOptionsList;
                det.selectedValue=selectOptionsList.get(0).getValue();
            }else if(en.Core_Environment_Variable__r.Core_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c.trim()){
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c.trim();
                if(en.Core_Environment_Variable__r.Core_Answers__c!=null)
                    det.tplaceHolder=en.Core_Environment_Variable__r.Core_Answers__C.trim();
                else
                    det.tplaceHolder= '';
            }/*else if(en.Core_Environment_Variable__r.Core_Datatype__c == 'boolean'){
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_check').value__c;
                det.cplaceholder=false;
            }*/
            envDetList.add(det);
        }
        for(Core_IPS_EV_Filters__c evfilter:[select id,name from Core_IPS_EV_Filters__c]){
             EnvironmentVariablesvisible.put((evfilter.name).toUpperCase(),true); 
        }
        system.debug('EnvironmentVariablesvisible ::'+EnvironmentVariablesvisible);
        return envDetList;
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
    ****************************************************************************************************/    
    public PageReference saveCaseDetails(){
        //showGECFieldsToIntUsrsForMAGAcc();
        //rerenderGECFieldsToIntUsrsForMAGAcc();
         user u=[select id,contactId,name from user where id='0053F000000Hu0b' limit 1];
        system.debug(' User Info:::'+userinfo.getuserid());
        
        cs.contactId=u.contactId;
        selectedContactId=u.contactId;
        if(validateGecDetails()) return null;
        if(validateInternalCase()) return null;
        if(validateCaseRelatedInformation()) return null;
        if(validateEnvironmentDetails()) return null;       
        try{    
            //rerenderGECFieldsToIntUsrsForMAGAcc();
            if(categorySelected!=null && categorySelected!=''){
                cs.Core_Case_Issue_Category__c=categorySelected;
            }
            else
            {
             cs.Core_Case_Issue_Category__c =null;
            }
            
            if(subCategorySelected!=null && subCategorySelected!=''){
                cs.Core_Case_Issue_Sub_Category__c=subCategorySelected;
            }
            else
            {
               cs.Core_Case_Issue_Sub_Category__c =null;
            }
            
            cs.Core_Platform_Name__c = platformSelected;
           system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>' + selectedProductId);
           if(selectedProductId!=null && selectedProductId!=''){
                cs.assetId = selectedProductId;
            }
             system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>' + selectedSAProductId);
            if(selectedSAProductId!=null && selectedSAProductId!=''){
            
                cs.Core_IPS_Supported_Product__c = selectedSAProductId;                
            }
            
            /*if(selectedProject!=null &&  selectedProject!='' && selectedProject!='NA'){
                cs.Core_IPS_Project_Case__c= selectedProject;         
            }*/
            
            if(selectedProjId!=null &&  selectedProjId!='' && selectedProjId!='NA'){
                cs.Core_IPS_Project_Case__c = selectedProjId;
            }
            else
            {
               cs.Core_IPS_Project_Case__c =null;
            }
            system.debug(cs.Core_IPS_Project_Case__c + 'vaibhav---' +selectedProjId);
            system.debug('((((((((((((((((((' + selectedContactId);
            //String contactId =selectedContactId;                  
            if(selectedContactId!=null && selectedContactId!=''){
               Contact con = [select id,account.ownerId,accountid from contact where id=:selectedContactId]; 
                cs.contactId = selectedContactId;
                cs.accountid = con.accountid ;
                if(con.account.ownerId!=null){
                    cs.Core_Intel_Sup_Owner__c = con.account.ownerId;
                }         
            }           
            //User u = [select Id, username,userType,contactId from User where Id = :UserInfo.getUserId()];
            //cs.contactId = u.contactId;
            System.debug('@@@@##@@@@'+showGECFields);
            if(showGECFields!=null && showGECFields)
             {
                if(GECAnswer1 == 'Yes' || GECAnswer2 == 'Yes')
                {
                    cs.Core_IPS_GEC_Flag__c = true;
                    //cs.Core_IPS_GEC_Case__c = true;
                    cs.IsStopped = true;  
                    cs.Status = 'On Hold';
                    cs.Core_IPS_GEC_Request_Status__c = 'MAG Questionnaire Required';
                    cs.Core_Sub_Status__c = 'GEC Hold';
                    String recordTypeId_GEC = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();
                   cs.recordtypeID =  recordTypeId_GEC;
                    
                }
                // system.debug('@@@@@@'+GECAnswer1+GECAnswer2+GECAnswer3);
                // if(GECAnswer1 == ''|| GECAnswer2 == '' || GECAnswer3 == '' || GECAnswer1 == null|| GECAnswer2 == null || GECAnswer3 == null)
                // {
                    // APexPages.Message Msg = new ApexPages.Message(ApexPages.Severity.Error, 'Please Fill the Required Fields');
                    // ApexPages.addMessage(Msg);
                    // System.debug('inside error');
                    // return null;
            
                // }
             
             }
             
            
             if(cs.Core_Issue_Description__c != null)
                {
                
                
                system.debug(cs.Core_Issue_Description__c);
                   string  strDescValue =  Core_Utility.replaceSpecialChar(cs.Core_Issue_Description__c);
                  
                   cs.Description = Core_Utility.replaceHtmlTags(strDescValue);
                }   
            if(Mode!='edit' && showGECFields==false)                
            {
                cs.status='New';
                
                if(ApexPages.currentPage().getParameters().get('rType') !=null && ApexPages.currentPage().getParameters().get('rType') == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId())
                    {
                        cs.Core_IPS_Self_Assigned__c =true;
                    }
                    else
                    {
                      cs.Core_IPS_Self_Assigned__c = false;
                    }
           }
           String rType=ApexPages.currentPage().getParameters().get('rType');
           String Iframe=ApexPages.currentPage().getParameters().get('Iframe');
           system.debug('Save case rtype::::'+rtype +'::'+Iframe);
           
            if(Iframe =='true' && (rType!=null && rType !='')){
                cs.recordtypeID=rType;
                cs.status='new';
                cs.Core_Sub_Status__c='';
            }
            upsert cs;
            addGECRecords();
            system.debug('KKKKKKKKKKKKKKKKKKKKKKKKKK');
            addEnvDetails();
            system.debug('KKKKKKKKKKKKKKKKKKKKKKKKKK');
        }catch(DMLException e){
            Core_Exceptionclass Exce =  new Core_Exceptionclass();
           string  Str = Exce.InsertException('','Core_IPS_Internal_Case_Controller','Case','','saveCaseDetails',e);
           system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + Str);
           renderErrorFlag=true;
           ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.Warning, 'DML Exception'+e );
            ApexPages.addMessage(msg);
            System.debug('Error:In Catch:'+e);
            return null;
         }         
        return new pageReference('/'+cs.id);
    }

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
    public void addGECRecords(){
        if(showGECFields!=null && showGECFields)
             {
                if(GECAnswer1 == 'Yes' || GECAnswer2 == 'Yes')
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
    }
    
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
    public boolean validateEnvironmentDetails(){
        if(envDetails!=null && envDetails.size()>0){
            for(EnvironmentDetail det : envDetails){                
                if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c &&(det.sPlaceHolder==null || det.sPlaceHolder=='') &&det.required){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+det.label);
                ApexPages.addMessage(myMsg);
                return true;    
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c&&(det.sPlaceHolder !=null || det.sPlaceHolder !='') && det.sPlaceHolder.length()>255){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G111')+':'+det.label);
                ApexPages.addMessage(myMsg);
                return true;    
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c &&(det.tPlaceHolder==null ||det.tPlaceHolder=='')&&det.required){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+det.label);
                ApexPages.addMessage(myMsg);
                return true;
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c && (det.tPlaceHolder != null ||det.tPlaceHolder!='') && det.tPlaceHolder.length()>5000){
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
            return false;
        }
        return false;
    }
    /***************************************************************************************************
    Method Name:  validateGecDetails
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 15 Jul 2015
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
    public boolean validateGecDetails(){
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
    public boolean validateCaseRelatedInformation(){
        
        system.debug('@@@@@@'+categorySelected);
        system.debug('@@@@@@'+displayCategories);
         system.debug('@@@@@@'+cs.Core_Issue_Description__c);
        //string  strdesc  = cs.Core_Issue_Description__c.replaceAll('<p>','').replaceAll('</p>','').replaceAll('&shy;','');
        //if((displayCategories==null || displayCategories) && (categorySelected==null || (categorySelected!=null && categorySelected.trim().length()==0))){
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
        if(cs.Subject==null || cs.Subject==''){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G102'));
                ApexPages.addMessage(myMsg);
                return true;
        }
      
        if(cs.Core_Issue_Description__c==null || cs.Core_Issue_Description__c.trim()==''){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G103'));
                ApexPages.addMessage(myMsg);
                return true;
        }
        if(cs.Core_Severity__c == null || cs.Core_Severity__c ==''){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G104'));
                ApexPages.addMessage(myMsg);
                return true;
        }
         if(cs.Core_CaseType__c==null || cs.Core_CaseType__c==''){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G109'));
                ApexPages.addMessage(myMsg);
                return true;
        }
        if(csId <> null && csId <> '' && platformOptions != null && platformOptions.size() > 1 && (platformSelected==null || (platformSelected!=null && platformSelected.trim().length()==0))){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G107'));
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
    public boolean validateInternalCase(){
         if(caseTypeSelected=='selfAssigned'){
                if(selectedSAProductId!=null && selectedSAProductId.trim().length()==0){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('I100'));// 
                    ApexPages.addMessage(myMsg);
                    return true;
                }
                else if(DisplayPriorityReason == true && (cs.Core_Severity_Reason__c==null || cs.Core_Severity_Reason__c=='')){
                     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('I111'));
                     ApexPages.addMessage(myMsg);
                     return true;
                }
            }else{
                if((selectedContactId!=null && selectedContactId.trim().length()==0) && (selectedProductId!=null && selectedProductId.trim().length()==0)){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('I101'));//Same old drama -I101
                    ApexPages.addMessage(myMsg);
                    return true;
                }
                else{
                 if(selectedProductId!=null && selectedProductId.trim().length()==0){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('I102'));
                    ApexPages.addMessage(myMsg);
                    return true;
                 }else if(selectedContactId!=null && selectedContactId.trim().length()==0){
                     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('I103'));//Same old drama -I103
                     ApexPages.addMessage(myMsg);
                     return true;
                 }else if(DisplayPriorityReason == true && (cs.Core_Severity_Reason__c==null || cs.Core_Severity_Reason__c=='')){
                     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('I111'));
                     ApexPages.addMessage(myMsg);
                     return true;
                 }
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
    public string errormessage(string errorCode){
        string defaultmessage ='please fill the Mandatory fields';
        if(Core_IPS_Error_Code__c.getinstance(errorCode)!=null){
            if(Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c!=null){
                defaultmessage = Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c; 
            }
        }
        return defaultmessage;
    }

    /***************************************************************************************************
    Method Name:  addEnvDetails
    Method Type: Action method 
    Version     : 1.0 
    Created Date: 01 Jul 2015
    Function    : This method saves environment details as related list to case.
    Input Parameters: None
    Output Parameters: None
    Description:This method is used to save environment details under case as related list. Each question and answer is saved as a record under case
    Used in     : Case Creation
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              07/01/2015              Created
    ****************************************************************************************************/     
    public void addEnvDetails(){
        system.debug('Debug:::  addEnvDetails');
        //Added By Yogesh Sharma
        List<Core_IPS_Response__c> existingDetails = new List<Core_IPS_Response__c>();
        //List<Core_IPS_Environment_Details__c> existingDetails = new List<Core_IPS_Environment_Details__c>();
        
        system.debug('Debug:::  addEnvDetails'+json.serialize(cs));
        //Added By Yogesh Sharma
        existingDetails = [select id from Core_IPS_Response__c where Core_IPS_Case__c =: cs.id];
        //existingDetails = [select id from Core_IPS_Environment_Details__c where Core_case__c=:cs.id];
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + existingDetails);
        if(existingDetails <> null && existingDetails.size()>0){
           // delete ExistingDetails;
           Core_IPS_AdminUtility.DeleteEnvDetails(ExistingDetails);
        }
        //Added By Yogesh Sharma
        List<Core_IPS_Response__c> envDetailsToCreate = new List<Core_IPS_Response__c>();
        //List<Core_IPS_Environment_Details__c> envDetailsToCreate = new List<Core_IPS_Environment_Details__c>();
        
        if(envDetails!=null && envDetails.size()>0){
            for(EnvironmentDetail det:envDetails){
            	//Added By Yogesh Sharma
            	Core_IPS_Response__c detail = new Core_IPS_Response__c();
                //Core_IPS_Environment_Details__c detail = new Core_IPS_Environment_Details__c();
                
                //Added By Yogesh Sharma
                //Not Writable Field
                //detail.Core_IPS_Question__c= det.label;
                detail.Core_IPS_Case__c= cs.id;
                //Not Writable Field
                //detail.Name = det.label;
                detail.Core_IPS_Agent_Only__c = det.IsAgentOnly;
                
                
                
                //detail.Core_Question__c= det.label;
                //detail.Core_case__c= cs.id;
                //detail.Name = det.label;
                //detail.Core_Agent_Only__c = det.IsAgentOnly;
                if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c.trim()){
                    //Added By Yogesh Sharma
                    detail.Core_IPS_Answer__c = det.sPlaceHolder;
                    //detail.Core_Answer__c = det.sPlaceHolder;
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c){
                    //Added By Yogesh Sharma
                    detail.Core_IPS_Answer__c= det.tPlaceHolder;
                    //detail.Core_Answer__c= det.tPlaceHolder;
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ){
                    //Added By Yogesh Sharma
                    detail.Core_IPS_Answer__c= det.selectedValue;
                    //detail.Core_Answer__c= det.selectedValue;
                }else if(det.type == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c){
                    string  strSelectedValue  = '';
                    for(string  str  : det.selectedMValue)
                        { 
                         if(str!='')
                          strSelectedValue = strSelectedValue + str + ';' ;
                        }
                    //Added By Yogesh Sharma    
                    detail.Core_IPS_Answer__c = strSelectedValue;//det.selectedValue;    
                    //detail.Core_Answer__c = strSelectedValue;//det.selectedValue;
                
                }/*else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_check').value__c){
                    if( det.cPlaceHolder)
                        detail.Core_Answer__c= 'True';
                    else
                        detail.Core_Answer__c= 'False'; 
                }*/
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>' + detail);
                envDetailsToCreate.add(detail);
            }
            if(envDetailsToCreate.size()>0){
                 //insert envDetailsToCreate;
                Core_IPS_AdminUtility.insertEnvDetailsToCreate(envDetailsToCreate);
            }
        }
        
        
        
    }
   
    
    /***************************************************************************************************
    Wrapper Class Name: EnvironmentDetail 
    Version     : 1.0 
    Created Date: 01 Jul 2015
    Function    : This wrapper class is used for constructing components for environment details in Case Creation visualforce page.
    Input Parameters: None
    Output Parameters: None
    Description: Constructs wrapper that is used in case creation visualforce page for displaying specific components.
    Used in     : Case create visualforce pages
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              07/01/2015              Created
    ****************************************************************************************************/   
private class EnvironmentDetail{
        public String type{get;set;}
        public String label{get;set;}
        public String splaceholder{get;set;}
        public List<SelectOption> pplaceholder{get;set;}
        public String selectedValue{get;set;}
        public boolean cplaceholder{get;set;}
        public String tplaceholder{get;set;}
        public boolean required{get;set;}
        public boolean IsAgentOnly{get;set;}
        public List<string> selectedMValue{get;set;}
    }    
     //[Oct/09/2015 - Abhishek Arya - START - Method to show GEC fields for internal users based on Contact's Account is MAG Only.]
    public pagereference showGECFieldsToIntUsrsForMAGAcc(){
            system.debug('********start*******');
            AnswerOptions = new list<SelectOption>();            
            //AnswerOptions.add(new SelectOption('', '--Select--'));
            //AnswerOptions.add(new SelectOption('Yes', 'Yes'));
            //AnswerOptions.add(new SelectOption('No', 'No'));
            AnswerOptions = Core_IPS_CaseUtility_dup.getGECAnswerOptions();
            //List<Contact> conList=new List<Contact>();
            //string passedParam1 = Apexpages.currentPage().getParameters().get('myParam');            
            //If(passedParam1 <> null && passedParam1 <> '' && Id.valueOf(passedParam1).getSObjectType().getDescribe().getName() == 'Contact')
            showGECFields = Core_IPS_Helper_Utility.isGECAccount(selectedContactId);          
            //system.debug('****passedparam****'+passedParam1+'*******'+showGECFields+'********'+Id.valueOf(passedParam1).getSObjectType().getDescribe().getName());
            return null;                        
    }            
    //[Oct/09/2015 - Abhishek Arya - END]
    
    //[Oct/09/2015 - Abhishek Arya - START - Method to show GEC fields for internal users based on Contact's Account is MAG Only.]
    public void rerenderGECFieldsToIntUsrsForMAGAcc(){
        system.debug('@@@render gec@@@@'+selectedContactid+(cs.Id==null));
        if(selectedContactid <> null && selectedContactid <> '' && cs.Id == null){
           showGECFields = Core_IPS_Helper_Utility.isGECAccount(selectedContactid);            
        }else{ 
            showGECFields=false;   
        }                           
    }            
    //[Oct/09/2015 - Abhishek Arya - END]
    
    
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
        platformOptions = Core_IPS_CaseUtility_dup.getplatform_Options(idList);
        if(platformOptions.size()>1) displayPlatform=true;
        else displayPlatform=false;
        return platformOptions;      
   }         
   
    
    public void resetProduct()
    {
        this.selectedProduct = '';
        system.debug('value of selected product *************' + this.selectedProduct);
        //return null;
    }
    
   public Pagereference  PageInit()
    {
      Pagereference Pg =  null;
      String retURL = ApexPages.CurrentPage().getParameters().get('retURL');
      if(Mode=='edit' && showGECFields){
       pg =  new Pagereference('/apex/Core_IPS_EoisError?ErrCode=G114&retURL='+retURL);
     }
     
     if(Mode=='edit' && editCloseCase)
     {
       pg =  new Pagereference('/apex/Core_IPS_EoisError?ErrCode=C113&retURL='+retURL);
     }
    
     return Pg;
    }
    /***************************************************************************************************
    Method Name:  DisplayPriorityReason
    Method Type: Action Method 
    Version     : 1.0 
    Created Date: 11-03-2015
    Function    : This method set the "DisplayPriorityReason" boolean variable set to True if User selects "Core_Severity__c" as 'Critical'. If boolean variable is True then, "Priority Reason" picklist is displayed in the UI.
    Input Parameters: None
    Output Parameters: None
    Description: This method is called when user changes the Priority Picklist in the UI. If Priority Picklist is Very High, Priority Reason picklist is displayed in the UI 
    Used in     : Case Creation
    Modification Log :
                   
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya       11/03/2015                 Created
    ****************************************************************************************************/    
    public void DisplayPriorityReason(){
        if(cs.Core_Severity__c == 'Critical'){
            DisplayPriorityReason = true;
        }
        else {
            DisplayPriorityReason = false;
            cs.Core_Severity_Reason__c='';
        }
        system.debug('method invoked. DisplayPriorityReason=    '+DisplayPriorityReason);
    }
    
    public void BindEvent(){}
    //Added by Geetha
    //US80347:To get values of product variant 
    Public void DisplayProductVariant(){ 
    blnShowVariant = false;
       variants = Product_Variant_Utility.DisplayProductVariant(selectedProductId); 
       blnShowVariant = Product_Variant_Utility.blnShowVariant;
    }

}