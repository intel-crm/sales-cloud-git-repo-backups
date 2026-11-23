/****************************************************************************************************
*Class Name:  Core_IPS_Internal_Case_Controller
*Description:  Case Creation Page Controller
*Modification Log :
* Developer                   Date                        Description
* ----------------------------------------------------------------------------       
* Amritesh                    12/18/2017                  Modified US8534 I7          
* Sugandha                    24/01/2018                  Modified(UserStory US83594 Iteration 6)
* Sumukh                      18/01/2018                  Modifies US69871 I7
* Sugandha                    16/03/2018                  Modified (UserStory US85567 Iteration 8)  
* Amritesh                    16/03/2018                  Modified (US79768 - Iteration8)
* Sugandha                    02/04/2018                  Modified (Defect DE37699 Iteration 9)
* Karthick                    02/04/2018                  Modified- US101342 - R4.2
* Karthick                    09/04/2018                  Modified- DE38080 - R4
* Sugandha                    09/05/2018                  Modified (Defect DE38632 Iteration 11)
* Sumukh                      10/05/2018                  Modified (i-10 US-104278) 
* Karthick                    20/06/2018                  Modified (DE40206) 
* Sugandha                    20/06/2018                  Modified (DE40247)
* Ashutosh                    27/06/2018                  Modified(US106566)
* Sumukh                      25/06/2018                  Modified For US108868 - I-13 R4.3
* Sumukh                      26/06/2018                  Modified for US107484 - I-13 Independant Release
* Sugandha                    17/08/2018                  Modified for US135425 - I-15
* Amritesh                    08/20/2018                  Modified - US127333 - Copy Case functionality introduced
* Sumukh                      27/09/2018                  Modified for Defect DE20747
* Aparna                       9/10/2018                  US176535-Modified to restrict Cases from selecting PAR Hidden products
* Aayushi                     28/11/2018                  Modified by Aayushi for US217499
* Aparna                      28/12/2018                  Modified for US238527 - Iteration-24
* Aayushi                     26/02/2019                  Modified for US253172
* Aparna                      2/4/2019                    Modified for US298949
* Aparna                      2/5/2019                    Included logic for defect fix-DE40678
*Ganapati					  07/08/2019				  Modified for US267989 - Case Source Values and API Name need to be aligned
****************************************************************************************************/
public with sharing class Core_IPS_Internal_Case_Controller{
    //Need to remove unused variables - JP
    public String SelectedVariant{get;set;} // Added by sumukh for US69871
    //public Case caseObj{get;set;}           // Added by sumukh for US69871
    public  Boolean blnShowVariant{get;set;} // Added by sumukh for US69871
    public  Boolean blnShowVariant_NAC{get;set;} // Added by sumukh for US107484
    public  List<SelectOption> variants{get;set;} // Added by sumukh for US69871
    public  List<SelectOption> variants_NAC{get;set;} // Added by sumukh for US107484
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
    public List<Core_IPS_EnvironmentDetailQuestion> envDetails{set;get;}
    //public List<Core_IPS_EnvironmentDetailQuestion> envDetList{get;set;}
    public List<Core_IPS_EnvironmentDetailQuestion> subCatenvDetList{get;set;} //Added by Manoj 
    public Case cs{get;set;}
    public boolean isAgent{get;set;}
    public boolean isSalesAgent{get;set;}
    public boolean displayEnvDetails{get;set;}
    public boolean displayCategories{get;set;}
    public boolean displaySubCategories{get;set;}
    public boolean displayPlatform{get;set;}
    public boolean renderErrorFlag{get;set;}
    //public List<SelectOption> projectList{get;set;}
    //public string selectedProject{get;set;}
    public String selectedProduct{get;set;}
    public String selectedProductId{get;set;}
    public String selectedSupProduct_Old{get;set;} //added by amritesh US79768
    public Boolean isResetProductRelInfo{get;set;} //added by amritesh US79768
    public Boolean showProductRelInfoDialog{get;set;} //added by amritesh US79768
    public String projSelected_Old{get;set;} //added by amritesh US79768
    public String selectedProjId_Old{get;set;} //added by amritesh US79768
    
    public String selectedAccountId{get;set;}   // Added by sumukh for US69871
    //public String selectedAccount{get;set;}     // Added by sumukh for US69871
     
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
    public Set<Id> envQuestnIds;//Added By Manoj
    //public core_IPS_supported_product__c supProduct{get;set;}
    public ApexPages.standardController controller{get;set;}
    public string objectSelected{get;set;}
    public String subCategorySelected{get; set;}
    public boolean displayForCust{get;set;} // Not really needed. always set to false. In VF page, boolean is referred. - Syed
    public boolean caseInformationReadOnly{get;set;} // May be used for Edit Case which is not yet in corporated in this code. As of now this variable is not needed. - Syed
    public boolean displayProject{get;set;}
    public String accSelected{get;set;}     // Added by sumukh for US69871 
    public String selectedContact{get;set;}
    public List<List<SelectOption>> variantsList{get;set;}// added by sumukh for 108868
     public List<List<SelectOption>> variantsList_NAC{get;set;} // added by sumukh for defect DE20747
    
    public String projSelected{get;set;}
    //public boolean displayCaseType{get;set;}
    public boolean displayProdSection{get;set;}
    public String platformSelected{get;set;}
    public boolean DisplayPriorityReason {get;set;}
    //public core_IPS_supported_product__c supProd;
    public String csId;
    public boolean isClosed {get; set;}  //added a variable isClosed to indentify if case is closed by sugandha for UserStory US83594 Iteration 6
    //Added by sugandha for PSA PSO US85567
    public boolean displayPSO {get; set;} 
    public String selectedPSOId {get; set;} 
    public String selectedPSO {get; set;}
    public String selectedPSA {get; set;}
    public  List<SelectOption> lstPSA {get;set;} 
    //US185241 Gourav - To enable MAG and GEC cases to be copied
    public boolean isGECMarked=false;
    //Ends here
    public Boolean isPrivateProjectCase {get; set;}             //added by Aayushi for US217499
    public String mindsOption{get;set;}
    public String countrySelected{get;set;}
    public List<SelectOption> items{get;set;}
    
   public Core_IPS_Internal_Case_Controller(ApexPages.standardController controller){
        this.controller=controller;
        csId = controller.getId();
        blnShowVariant = false;
        blnShowVariant_NAC = false; // added by sumukh for US107484
        isAgent = Core_IPS_Helper_Utility.isIPSCustomerUser();
        isSalesAgent = Core_IPS_Helper_Utility.isIPSSalesUser();
        displayProject = true;
        displayProdSection=false;
        showGECFields =false;
        editCloseCase = false;
        isClosed = false; //added by sugandha for UserStory US83594 Iteration 6
        displayPSO = false; //added by sugandha for US85567
        isResetProductRelInfo = false; // added by amritesh US79768
        showProductRelInfoDialog = false; // added by amritesh US79768
        mode = apexpages.currentpage().getParameters().get('mode');
        envDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        LstCustomLabels = Core_IPS_Labels__c.getall().values();
        //[Dec/16/2015 - START - Checking the accessability.]
        
        if(csId !=null && csId != ''){
            isEditable = [SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfo.getuserId() AND RecordId = :csId].HasEditAccess;
        }
        //[Dec/16/2015 - END]
        items = new List<SelectOption>();
        items.add(new SelectOption('Yes','Yes')); 
        items.add(new SelectOption('No','No')); 
        
       /* US127333 */
       //Retrieve the record type id by name            
       String recordTypeId_NewCase = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
       String recordTypeId_SA = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
              
        if(csId==null ){
            cs = new Case();
            cs.Core_CaseType__c = '';
            //cs.Core_Intel_Sup_Owner__c = Core_IPS_CaseUtility.getIntelSupportOwner();
            caseInformationReadOnly=false;
            String recType = ApexPages.currentPage().getParameters().get('rType');
            //System.debug('*******'+recordTypeId_NewCase+'*****'+recordTypeId_SA+'******'+recType+'&&'+recordTypeId_NewCase.substring(0,15));
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
               //start added for US253173
               showGECFields = true;
               mindsOption='No';
               //end
               //contactClear(); 
               //selectedContactId =null;
               //selectedContact =null;
               if(ast!=null)
                  ast =null;                      
            }
           
           //Added for US238527 by Aparna  
           string externalUser = Network.getNetWorkid(); 
            if(string.isBlank(externalUser)){
                cs.Core_IPS_Issue_source__c =  Label.Core_IPS_Internal_Portal;  //Modified by Ganapati for US267989 - prev val - 'IPS Cloud'
            }
            //end for US238527
            
            if(mode=='asset'){
                caseInformationReadOnly=true;                
                String passedprojectId = ApexPages.currentPage().getParameters().get('projectId');               
                String passedproductId = ApexPages.currentPage().getParameters().get('productId');
                String passedaccountId = ApexPages.currentPage().getParameters().get('accountId'); // added by sumukh for US69871               
               
                               
                if(passedprojectId!=null && passedprojectId!=''){
                    projSelected = [select id, name from core_ips_project__c where id=:passedprojectId].Name;
                    selectedProjId = passedprojectId;
                }
                
                // added by sumukh for US69871
                if(passedaccountId!=null && passedaccountId!=''){ 
                    accSelected = [select id,name from Core_IPS_Account__c where id=:passedaccountId].Name; 
                    selectedAccountId = passedaccountId;                  
                }
                // End by sumukh for US69871
                
                if(passedproductId!=null && passedproductId!=''){
                    ast = [select id, name,core_supported_product__c from asset where id=:passedproductId limit 1];
                    selectedProduct = ast.Name;
                    //Added by Ayesha for DE32945
                    selectedSAProductId = ast.Id;
                    //End by Ayesha for DE32945
                    selectedProductId=passedproductId;                    
                }
                categoryOptions = new List<SelectOption>();
                if(ast!=null && null != ast.core_supported_product__c){ 
                   categoryOptions = getCategoryOptions(ast.core_supported_product__c);                   
                    // added for DE32940
                    /*** commented for DE32940
                    //categoryOptions.add(new SelectOption('', 'Select Category'));
                    for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility.getCategories(ast.core_supported_product__c) ){
                        categoryOptions.add(new SelectOption(a.id, a.Core_Issue_Category_Name__r.Name));
                    } 
                    if(categoryOptions.size()>1){
                        Core_Utility.doSort(categoryOptions, Core_Utility.FieldToSort.Label,'Select Category');
                        //categoryOptions.sort();
                        displayCategories=true;
                        subCategoryOptions=new List<SelectOption>();
                        subCategoryOptions.add(new SelectOption('', 'Select Category'));
                        displaySubCategories=true;
                    } */
                }                 
                envDetails=getEnvironmentDetailsOperationList(ast.core_supported_product__c,subCategorySelected,isAgent); 
            }
        }
       else if(mode=='edit' || mode=='copy') { // US127333
            displayProdSection=true;
            System.debug('===============================111====@@@@@@@@@'+csId+isAgent);            
            cs = Core_IPS_CaseUtility.getCase_DynamiCSOQL(csId,isAgent);
           //start added by Aayushi for US217499
           if(cs.Core_IPS_Private_Project__c){
            isPrivateProjectCase=true;   
           }//end
            if(cs.Recordtype.DeveloperName=='IPS_GEC_ReadOnly' )
            {
              showGECFields = true;
              
            }
           //Sneha
       /*    if(cs.Core_IPS_Self_Assigned__c){
               
               displaySelfAssigned = true;
           }*/
            /* US185241 Gourav - To enable MAG Account as well as GEC reviewed cases to be cloned alongwith 3 GEC Questionnaire */
           //Modified by Aayushi for US253172 so that whever Case is copied MINDS questions appear
            if(mode=='copy' /*&& cs.Core_IPS_Supported_Contact__r.AccountId  !=Null */) //US185241 -- To allow MAG Cases to be copied with GEC Questionaire
            {
                cs.Core_IPS_GEC_Status__c=''; 
                
               // if(cs.Core_IPS_Supported_Contact__r.Account.Core_Military_Aerospace_and_Government__c){  
                    showGECFields = true;
                 /*   AnswerOptions = Core_IPS_CaseUtility.getGECAnswerOptions(); 
                    
                }  */    
                // Added for US298949-Aparna
                countrySelected = cs.Core_IPS_Country_Region__c;
                if(string.valueOf(cs.Core_IPS_Minds__c) == 'true'){
                    mindsOption = 'Yes';
                }
                else {
                    mindsOption = 'No';
                }
                //end for US298949
            }
           
            if(cs.Recordtype.DeveloperName=='IPS_Closed_Case')
            {
              editCloseCase = checkcloseCaseEditPermission();
            }
            //added by sugandha for UserStory US83594 Iteration 6
            if(!String.isBlank(cs.Status) && cs.Status == 'Closed') {
              isClosed = True;
            }
            //end
            caseInformationReadOnly=true;
            if(cs <> null && cs.Core_Case_Issue_Category__c!=null)
                categorySelected=cs.Core_Case_Issue_Category__c;
                                
            if(cs <> null && cs.Core_IPS_Supported_Product__c <> null /*&& categorySelected <> null && categorySelected <> ''*/){    
                categoryOptions=new list<SelectOption>();
                categoryOptions=getCategoryOptions(cs.Core_IPS_Supported_Product__c);           
            }
            if(cs <> null && cs.Core_Case_Issue_Sub_Category__c!=null)
               subCategorySelected=cs.Core_Case_Issue_Sub_Category__c;
               subCategoryOptions=new list<SelectOption>();
               subCategoryOptions=getsubCategory_Options(categorySelected);
            
            if(cs <> null && cs.core_ips_project_case__c!=null){
               
                projSelected = cs.core_ips_project_case__r.Name;
                selectedProjId = cs.core_ips_project_case__c;
                projSelected_Old = projSelected;  //added by amritesh US79768
                selectedProjId_Old = selectedProjId; //added by amritesh US79768                
            }
            
             // Added by sumukh for US69871
             
            if(cs.assetId!=null){
            selectedProduct=cs.asset.name;
            selectedProductId = cs.assetId;
            blnShowVariant = true;
            selectedVariant=cs.Core_Product_Variant__c;
            displayProductVariant();
            }
             // End by sumukh for US69871
             
            if(cs <> null && cs.Core_Partner_Supported_Account__c!=null) {                                
                accSelected = cs.Core_Partner_Supported_Account__r.Name;
                selectedAccountId = cs.Core_Partner_Supported_Account__c;
            }            
            
              //added by sugandha for US85567
            if(cs <> null && cs.Core_Partner_Supported_Account__c <> null){
                selectedPSA = cs.Core_Partner_Supported_Account__c;
            }
            if(cs <> null && cs.Core_IPS_Partner_Sup_Owner__c <> null){
                selectedPSOId = cs.Core_IPS_Partner_Sup_Owner__c;
                selectedPSO = cs.Core_IPS_Partner_Sup_Owner__r.Name;
            }
            DisplayPSAPSO();//added by sugandha for US85567
            //end here
            
            
            if(cs <> null && cs.assetId!=null){
                selectedProduct=cs.asset.name;
                selectedProductId = cs.assetId;
                    platformSelected=cs.Core_Platform_Name__c;
                    List<Id> assetIdList = new List<Id>();
                    assetIdList.add(cs.assetId);
                    platformOptions=getplatformOptions(assetIdList);
                    system.debug('AssetIDLISt'+assetIdList);
                    System.debug('PlatformOptions'+platformOptions);
                
            }
            
            if(cs <> null && cs.ContactId <> null){
                selectedContact = cs.Contact.Name;
                selectedContactId = cs.ContactId;                 
            }
           
           //US191343
           if(cs.Core_IPS_Supported_Contact__c!=null) {
               selectedContact = cs.Core_IPS_Supported_Contact__r.Name;
               selectedContactId = cs.Core_IPS_Supported_Contact__c;
           }
            //added by amritesh US79768 - start
            if(cs<>null && cs.Core_IPS_Supported_Product__c!=null) {
                selectedSupProduct_Old = cs.Core_IPS_Supported_Product__c;     
            }
            //added by amritesh US79768 - end           
            /*Ashutosh_Us106566- Now we may have both asset id and supp product id on case so modifying the condition statement*/
            //if(cs <> null && cs.Core_IPS_Supported_Product__c <> null && cs.assetId == null){ 
            if(cs <> null && ((cs.Core_IPS_Supported_Product__c != null && cs.AssetId != null && cs.RecordType.DeveloperName == 'Core_IPS_Case_Create_Self_Assigned')|| (cs.Core_IPS_Supported_Product__c <> null && cs.assetId == null))){
                
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
                selectedProductId =null; //added for DE27016
            }
            if(cs <> null && cs.Core_Severity__c == 'Critical'){
                DisplayPriorityReason = true;
            }
               
            // Added by sumukh for US107484   
              
            if(cs <> null && cs.Core_IPS_Supported_Product__c <> null && cs.assetId == null){      
            blnShowVariant_NAC = true;
            selectedVariant=cs.Core_Product_Variant__c;
            displayProductVariant_NAC();
            } 
            // End By Sumukh for US107484 
                        
            envDetails=getEnvironmentDetailsOperationList(cs.Core_IPS_Supported_Product__c,subCategorySelected,isAgent); 
            setCurrentEnvironmentDetails(envDetails,csId);   
            //}
        }
       
       /* US127333 - start */
       if(mode=='copy') {           
           cs.Status = 'New';
           cs.Core_Sub_Status__c = null;
           editCloseCase = true;
           isClosed = false;
           caseInformationReadOnly = false;
           cs.Subject = '(Copy Of '+cs.CaseNumber+') ' + cs.Subject;
           cs.Core_Issue_Description__c = '**Copied From Case '+ cs.CaseNumber + '<br>' + cs.Core_Issue_Description__c;
           if(cs.Core_IPS_Issue_source__c == Label.Core_IPS_Legacy_PSG) {
               cs.Core_IPS_Issue_source__c = Label.Core_IPS_CaseSource_Val_for_Legacy_PSG;  
           }
          
           
       }
       /* Amritesh - end */
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
        Schema.Describefieldresult result = Schema.sObjectType.Contact.fields.Core_Country_Region__c;
        Schema.DescribeFieldResult fieldResult = result.getSObjectField().getDescribe();//Contact.BillingCountry.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
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
       PageReference pg;
        if(preURL.indexof('assetid') > -1)
           pg = new PageReference('/02i/o'); 
        else if(retURL !=null && retURL !='')
           pg = new PageReference(retURL);
        else
           pg = new PageReference('/500/o'); 
       
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
    * Amritesh                   12/18/2017              Modified - US8534
    ****************************************************************************************************/   
    public static void setCurrentEnvironmentDetails(List<Core_IPS_EnvironmentDetailQuestion> lstEnvDetails, String caseId) {
        // added  by amritesh 12/18/2017 - US8534 - start
        if(lstEnvDetails!=null) {
            List<Core_IPS_Response__c> lstCoreResponse = Core_IPS_Questions_Utility.getEnvDetailCoreResponse(caseId);
            Map<Id,List<Core_IPS_Response__c>> mapQuestionId2Responses = new Map<Id,List<Core_IPS_Response__c>>();
            Map<Id,List<Core_IPS_Answer__c>> mapParent2ChildAnswers = new Map<Id,List<Core_IPS_Answer__c>>();
            
            for(Core_IPS_Response__c objResponse : lstCoreResponse) {
                if(!mapQuestionId2Responses.containsKey(objResponse.Core_IPS_Question_Master__c) && objResponse.Core_IPS_Question_Master__c!=null) {
                    mapQuestionId2Responses.put(objResponse.Core_IPS_Question_Master__c, new List<Core_IPS_Response__c>());
                }
                mapQuestionId2Responses.get(objResponse.Core_IPS_Question_Master__c).add(objResponse);
                if(objResponse.Core_IPS_Answer_Master__c!=null)
                    mapParent2ChildAnswers.put(objResponse.Core_IPS_Answer_Master__c, new List<Core_IPS_Answer__c>());
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
                envDet.isVisible = true;  
                if(mapQuestionId2Responses.containsKey(envDet.questionId)) {                    
                    String answerText = mapQuestionId2Responses.get(envDet.questionId).get(0).Core_IPS_Answer__c;
                    Id masterAnswerId = mapQuestionId2Responses.get(envDet.questionId).get(0).Core_IPS_Answer_Master__c;
                    if(envDet.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c.trim()) {                        
                        envDet.sPlaceHolder = answerText;
                    } else if(envDet.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c) {
                        envDet.tplaceholder = answerText;
                    } else if(envDet.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ) {
                        if(masterAnswerId!=null)
                            envDet.selectedValue = masterAnswerId;
                        else if(mapQues2AnswerStrMap.containsKey(envDet.questionId)){
                            if(mapQues2AnswerStrMap.get(envDet.questionId).containsKey(answerText)) {
                                envDet.selectedValue = mapQues2AnswerStrMap.get(envDet.questionId).get(answerText);
                            }
                        }
                    }                     
                    else if(envDet.type == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c) {  
                        envDet.selectedMValue = new List<String>();
                        for(Core_IPS_Response__c objEnvResp : mapQuestionId2Responses.get(envDet.questionId)) {
                            if(objEnvResp.Core_IPS_Answer_Master__c!=null)
                                envDet.selectedMValue.add(objEnvResp.Core_IPS_Answer_Master__c);
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
                                objChildQues.pplaceholder.clear();
                                objChildQues.pplaceholder.add(new SelectOption('','Select Option'));                            
                                for(Core_IPS_Answer__c objAns : mapParent2ChildAnswers.get(envDet.selectedValue)) {
                                    if(objAns.Core_IPS_Question__c==objChildQues.questionId)
                                    objChildQues.pplaceholder.add(new SelectOption(objAns.Id, objAns.Core_IPS_Answer__c));                                
                                }
                                
                                if(objChildQues.pplaceholder==null) { objChildQues.isVisible=false; }
                                else if(objChildQues.pplaceholder.size()==1) { objChildQues.isVisible=false; }
                            } 
                        }
                    }
                }
            }
        }
        // added  by amritesh 12/18/2017 - US8534 - end
        
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
    * Manoj Kumar                06/20/2017              Modified
    * Amritesh                   16/03/2018             Modified (US79768 - Iteration8)
    * Ashutosh                   27/06/2018             Modified (US106566)
    * Aparna                      9/10/2018             Modified (US176535-Iteration18)
    ****************************************************************************************************/    
    public pagereference LookupChange(){
        //added by sugandha for US85567
        if(objectSelected <> null && objectSelected <> '' && objectSelected == 'Project' && selectedContact!=null && selectedContact!='' && projSelected <> null && projSelected <> ''){
            selectedPSO = '';
            selectedPSOId = '';
            selectedPSA = '';
            displayPSO = false;
         }   
        //end here
        
        //product change
        if(objectSelected <> null && objectSelected <> '' && objectSelected == 'Product' )
        {
            string passedParam1 = Apexpages.currentPage().getParameters().get('paramId');            
            system.debug('@@@@@@@@@@2' + passedParam1);
            if(passedParam1 <> null && passedParam1 <> '')
            selectedProductId = passedParam1;//Core_IPS_Helper_Utility.isGECAccount(passedParam1);
            isResetProductRelInfo = true;  //added by amritesh US79768
            PopulateAssetProj();// added by Sugandha for DE38632
        }
        
        //added by amritesh US79768 - start  
        if(selectedProductId!=null && selectedProductId!=''){
            system.debug('NAC PROJECT CLEARED');
            ast = [select id, Name,Core_Product_Organization__c,core_supported_product__c,Core_IPS_Project__c from asset where id=:selectedProductId  limit 1];    
        } else {
            ast = null;
        }
        
        //project change
        if(objectSelected <> null && objectSelected <> '' && objectSelected == 'Project' && selectedContact!=null && selectedContact!='' && selectedProduct!=null && selectedproduct!='' && ( String.isNotBlank(projSelected) || (String.isBlank(projSelected) && String.isNotBlank(projSelected_Old)) )) {            
            Boolean skipProductChange = false;
            //check if product present under project            
            if(ast!=null && ast.core_supported_product__c!=null) {
                Asset[] lstAsset;
                //project changed
                if(String.isNotBlank(projSelected)) {
                    lstAsset = [SELECT Id FROM Asset WHERE Core_IPS_Project__c=:selectedProjId AND Core_Supported_Product__c=: ast.core_supported_product__c AND Status='Active'];
                } 
                //project removed
                else {
                system.debug('$$$INSIDE PROJ REMOVED$$$');
                    Id accountId;
                    Contact[] lstCont = [SELECT AccountId FROM Contact WHERE Id=:selectedContactId LIMIT 1];
                    if(lstCont.size()>0) accountId = lstCont[0].AccountId;
                    if(accountId!=null) {
                    // Name:Aparna ; Date:9/10/2018 ; Description:Modified query below (US176535-Iteration18) for PAR Hidden products
                    //Added MAP in soql for DE24083
                        lstAsset = [SELECT Id FROM Asset WHERE Core_Supported_Product__c=:ast.core_supported_product__c AND Status='Active' AND (AccountId=:accountId OR RecordType.Developername=:Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Global_Asset_RT')) AND Id IN (SELECT Core_Intel_Product__c FROM Core_IPS_Map_Par_Line_Item__c WHERE (RecordType.DeveloperName='MAP' OR (RecordType.DeveloperName='PAR' AND Core_Intel_Product__r.Core_Supported_Product__r.Core_Flag_Status__c!='Par Hidden')) AND  Core_Status__c='ACTIVE' AND Core_Intel_Product__r.Core_Supported_Product__c=:ast.core_supported_product__c)];
                        system.debug('LST ASSET:::::::'+lstAsset);
                    }
                }
                if(lstAsset!=null && lstAsset.size()>0) {
                    selectedProductId = lstAsset[0].Id;
                    skipProductChange = true;
                }
            }

            if(String.isNotBlank(selectedProductId) && skipProductChange==false && isResetProductRelInfo==false) {              
                showProductRelInfoDialog = true;
            } else if(skipProductChange==false){
                projSelected_Old = projSelected;
                selectedProjId_Old = selectedProjId;
            }
            if(skipProductChange==false && isResetProductRelInfo==true) {                
                selectedProduct='';
                selectedProductId='';                
            }
                      
        }              
        //added by amritesh US79768 - end
        
        //contact change
        if(objectSelected <> null && objectSelected <> '' && objectSelected == 'Contact')
        {
            system.debug('inside contact changed method:::');
            string passedParam1 = Apexpages.currentPage().getParameters().get('paramId');            
            system.debug('@@@@@@@@@@2' + passedParam1);
            if(passedParam1 <> null && passedParam1 <> '')
            {
             selectedContactId = passedParam1;//Core_IPS_Helper_Utility.isGECAccount(passedParam1);
              //start modification for US253172
             //Pagereference  Pg1 =  showGECFieldsToIntUsrsForMAGAcc();
             System.debug('In lookupChange--->');
                mindsOption='No';
                countrySelected='';
                if(!String.IsBlank(selectedContactId)){
                 Contact con1=[select id,account.ownerId,accountid,Core_IPS_Intel_Support_Owner__c,Core_MINDS__c,Core_Country_Region__c from contact where id=:selectedContactId];                 
                    if(con1.Core_MINDS__c){
                    mindsOption='Yes';    
                    }
                    else{
                     mindsOption='No';    
                    }
               
                 if( con1.Core_Country_Region__c!=null ){                    
                    countrySelected=con1.Core_Country_Region__c;                                  
              }   
                                       
            }
                else{
                 mindsOption='No';   
                }
             showGECFields=true;
              //end
            }
            //added by sugandha US85567
            selectedPSO = '';
            selectedPSOId = '';
            selectedPSA = ''; 
            displayPSO = false; 
            //end here
        } 
        
        //added selectedobject check by Sugandha for US85567
        if(selectedProductId!=null && selectedProductId!='' && objectSelected != 'User'){
            cs.assetId = selectedProductId;
            //ast = [select id, Name,Core_Product_Organization__c,core_supported_product__c,Core_IPS_Project__c from asset where id=:selectedProductId limit 1];    
            List<Id> astIdList=new List<Id>();
            if(ast!=null && ast.core_supported_product__c!=null){
                astIdList.add(ast.Id);
                platformOptions=getplatformOptions(astIdList);
                if(platformOptions !=null && platformOptions.size()>1 && csId <> null && csId <> ''){
                    displayPlatform=true;
                }else{
                   displayPlatform=false;
                }
                if(selectedSupProduct_Old!=ast.core_supported_product__c && isResetProductRelInfo==true) {  //added by amritesh US79768,US104026                   
                    selectedSupProduct_Old = ast.core_supported_product__c;  //added by amritesh US79768
                    isResetProductRelInfo = false; //added by amritesh US79768
                    categoryOptions=getCategoryOptions(ast.core_supported_product__c);
                    categorySelected =''; 
                    //[24/Jan/2016 - Start]                
                    subCategoryOptions=getsubCategory_Options(categorySelected);
                    subCategorySelected =''; 
                    //[24/Jan/2016 - End]                
                    //displaySubCategories=true;
                    List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
                    //envVars = Core_IPS_CaseUtility.getEnvVariables(ast.core_supported_product__c,null,isAgent);
                    envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(ast.core_supported_product__c,null,isAgent);
                    // added  by amritesh 12/18/2017 - US8534
                    //Added By Manoj as part of as part of US60820 IPS Evolve
                    envQuestnIds = new Set<Id>();
                    subCatenvDetList = new List<Core_IPS_EnvironmentDetailQuestion>();
                    for(Core_IPS_Assigned_Environment_Variables__c envQuestn : envVars){
                        //envQuestnIds.add(envQuestn.Core_Environment_Variable__c);
                        envQuestnIds.add(envQuestn.Core_IPS_Question__c); // added  by amritesh 12/18/2017 - US8534
                    }
                    //Ended By Manoj
                    
                    if(envVars!=null && envVars.size()>0){
                        displayEnvDetails=true;
                        envDetails=constructWrapper(envVars);
                    }else{
                       envDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
                        //added by amritesh - DE38057
                       displayEnvDetails=false;
                    }
                }    
            }       
        }
        //
        if(selectedSAProductId!=null && selectedSAProductId!=''){
            System.debug('@@@@@@'+selectedSAProductId);  
            Boolean isAsset = String.valueOf(selectedSAProductId).substring(0,3) == '02i' ? true:false;
            
            /*Ashutosh - US106566 - Here we need to create a logic where we can distinguish between asset or supported product id is coming from
            SalectedSAProductId as we are populating only SAProductId from UI*/
            //supProd= [select id,Core_Supported_Product_Name__c, Name,Core_Product_Organization__c,Core_Product__c,Core_Product__r.name from core_IPS_supported_product__c where id=:selectedSAProductId];    
           
           // Name:Aparna ; Date:9/10/2018 ; Description:Handles when project is removed from NAC Cases for PAR Hidden products(US176535-Iteration18)
            if(String.isNotBlank(objectSelected) && objectSelected == 'Project' && String.isBlank(projSelected)) {
                system.debug('::Inside NAC project removed Loop:::');
                
                list<Core_IPS_Supported_Product__c>supportedProdList;
                           
                if(isAsset){
                    supportedProdList = [select Id FROM Core_IPS_Supported_Product__c WHERE Core_EOIS__c != True AND Core_Flag_Status__c != 'Par Hidden' AND Id IN (select Core_Supported_Product__c from Asset where id =:selectedSAProductId)]; 
                   }
                else{
                      supportedProdList = [select Id FROM Core_IPS_Supported_Product__c where Core_EOIS__c != True AND Core_Flag_Status__c != 'Par Hidden' AND id=:selectedSAProductId limit 1];
                    }
                 if(supportedProdList != null && supportedProdList.size()>0)
                    {
                       selectedSAProductId =  supportedProdList[0].ID;
                    }
                    else {
                        selectedSAProductId = null;  
                        selectedSAProduct= null;
                    }             
            }
            //end for Project Removal on NAC Cases
                                  
            if(selectedSAProductId !=null){       
                //cs.Core_IPS_Supported_Product__c = selectedSAProductId;- commented by karthick as part of US106566
               
                //Ashutosh-Us106566 - If we are getting asset Id then we will populate the asset id here and supported product will get from asset
                //and if only supported product is there then we will populate the supported product id here
                if(isAsset){
                system.debug('3:::' +isAsset);
                    cs.AssetId = selectedSAProductId;
                    Asset ast = [select id,Core_Supported_Product__c from Asset where id=:selectedSAProductId];    
                    cs.Core_IPS_Supported_Product__c = (ast != null  && ast.Core_Supported_Product__c != null) ? ast.Core_Supported_Product__c : null;
                    //Ashutosh-US106566-In case asset id is there in the SAproductid then we will get the supported product id and set is as SAProductId
                    selectedSAProductId = (cs.Core_IPS_Supported_Product__c != null) ? cs.Core_IPS_Supported_Product__c: null;  
                }
                else{ 
                
                    cs.Core_IPS_Supported_Product__c = selectedSAProductId;
                    cs.AssetId = null;//Ashutosh - US106566 - if selected product id is not asset thenasset on case is null
                    selectedProductId = null;
                }
                //Ashutosh - US106566 ends
                
                if(selectedSAProductId != selectedSupProduct_Old ) { //added by amritesh US79768,US104026
                    selectedSupProduct_Old = selectedSAProductId; //added by amritesh US79768
                    categoryOptions = getCategoryOptions(selectedSAProductId);
                    categorySelected =''; 
                    subCategoryOptions = getsubCategory_Options(categorySelected);
                    subCategorySelected = '';
                    List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
                    /************Added By Manoj as part of as part of US60820 IPS Evolve*********/
                    envQuestnIds = new Set<Id>();
                    //envVars = Core_IPS_CaseUtility.getEnvVariables(selectedSAProductId,null,isAgent);
                    envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(selectedSAProductId,null,isAgent);  // added  by amritesh 12/18/2017 - US8534
                    subCatenvDetList = new List<Core_IPS_EnvironmentDetailQuestion>();
                    for(Core_IPS_Assigned_Environment_Variables__c envQuestn : envVars){
                        //envQuestnIds.add(envQuestn.Core_Environment_Variable__c);
                        envQuestnIds.add(envQuestn.Core_IPS_Question__c); // added  by amritesh 12/18/2017 - US8534
                    }
                    /************Ended By Manoj *********/
                    
                    if(envVars!=null && envVars.size()>0){
                        displayEnvDetails=true;
                        envDetails=constructWrapper(envVars);
                    }else{
                       envDetails = new List<Core_IPS_EnvironmentDetailQuestion>(); //added by amritesh - DE38057
                       displayEnvDetails=false;
                    }
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
         displayProductVariant_NAC(); // Added by sumukh for US69871
         displayProductVariant(); // Added by sumukh for US107484
         displayPSAPSO(); //added by sugandha for US85567        
     return null;   
    }
    
    /***************************************************************************************************
    Method Name:  cancelProductRelInfo
    Method Type: Action helper Method
    Description:   cancel the project and product change
    Used in     : Case Creation VF
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                  03/16/2018               Created - R4
    ****************************************************************************************************/ 
    public void cancelProductRelInfo() {
        showProductRelInfoDialog = false;
        projSelected = projSelected_Old;
        selectedProjId = selectedProjId_Old;
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
            //added for DE32940
            List<Core_IPS_Product_Issue_Category__c> lstCatgories = Core_IPS_CaseUtility.getCategories(supportedProductId);
            if(supportedProductId <> null && lstCatgories <> null && lstCatgories.size() > 0){
                for(Core_IPS_Product_Issue_Category__c a : lstCatgories){
                    if(a <> null && a.Core_Issue_Category_Name__r <> null && a.Core_Issue_Category_Name__r.Name <> null)
                        categoryOptions.add(new SelectOption(a.id, a.Core_Issue_Category_Name__r.Name));
                }
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
         if(envDetails!=null){ envDetails.clear(); 
             //envDetList.clear(); // commented by amritesh 12/18/2017 - US85344 
         }
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
        if(categorySelected!=null && categorySelected!=''){
            //subCategoryOptions.add(new SelectOption('', 'Select SubCategory'));
            for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility.getSubCategories(categorySelected)){              
                if(a.Core_Issue_Sub_Category_Name__c!=null){
                subCategoryOptions.add(new SelectOption(a.id, a.Core_Issue_Sub_Category_Name__r.Name));                
                }
            }
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
    * Manoj Kumar                06/20/2017              Modified
    ****************************************************************************************************/    
   public PageReference getEnvDetails(){
       if(subcategorySelected!=null && subcategorySelected!=''){
            subcategorySelected='';
       }  
       subCategoryOptions=getsubCategory_Options(categorySelected); 
       //getsubCategory_Options(categorySelected);
      // [Nov/06/2015 - Start - Vaibhav Dubey - Defect# -8422 ]
       //getEnvironmentDets(); commented by Manoj
       //Added By Manoj as part of US60820 IPS Evolve
       //envDetails = getDetails(); //commented by amritesh DE37841
       subCatenvDetList = new List<Core_IPS_EnvironmentDetailQuestion>();
       //Ended By Manoj
    //   [Nov/06/2015 - END - Vaibhav Dubey - Defect# -8422 ]       
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
    * Manoj Kumar                06/20/2017              Modified
    ****************************************************************************************************/ 
    public PageReference getEnvironmentDets(){    
    //Added By Manoj as part of US60820 IPS Evolve
    if(subCategorySelected!=null){
        subCatenvDetList = getDetails();
        displayEnvDetails=true;        
    }
    else{
        //envDetails =getDetails(); //commented by amritesh DE37841
        subCatenvDetList = new List<Core_IPS_EnvironmentDetailQuestion>();
    } //Ended by Manoj
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
            //envVars = Core_IPS_CaseUtility.getEnvVariables(ast.core_supported_product__c,null,isAgent);
            envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(ast.core_supported_product__c,null,isAgent);  // added  by amritesh 12/18/2017 - US8534
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
    * Amritesh                   12/18/2017              Modified - US8534
    ****************************************************************************************************/     
   public List<Core_IPS_EnvironmentDetailQuestion> getDetails(){
       List<Core_IPS_Assigned_Environment_Variables__c> envVars;
       if(selectedProductId!=null && selectedProductId!=''){
        assetId= selectedProductId;
        ast = [select id, core_supported_product__c from asset where id=:assetId];
        productId=ast.core_supported_product__c;
        }
        if(selectedSAProductId!=null)
        productId = selectedSAProductId;
        //envVars = Core_IPS_CaseUtility.getEnvVariables(productId,null,isAgent); // commented by amritesh 12/18/2017 - US85344
        envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(productId,null,isAgent); // included by amritesh 12/18/2017 - US85344
       
       if(categorySelected==null || (categorySelected!=null && categorySelected.trim().length()==0) || subcategorySelected==null || (subcategorySelected!=null && subcategorySelected.trim().length()==0)){
            if(categorySelected==null || (categorySelected!=null && categorySelected.trim().length()==0)){
                subCategorySelected=' ';
            }
            //envVars = Core_IPS_CaseUtility.getEnvVariables(productId,null,isAgent); // commented by amritesh 12/18/2017 - US85344
            envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(productId,null,isAgent); // included by amritesh 12/18/2017 - US85344
            /******Added By Manoj*************/
            if(envVars!=null && !envVars.isEmpty()){
                envQuestnIds = new Set<Id>();
                for(Core_IPS_Assigned_Environment_Variables__c envQuestn : envVars){
                    //envQuestnIds.add(envQuestn.Core_Environment_Variable__c);
                    envQuestnIds.add(envQuestn.Core_IPS_Question__c); // added  by amritesh 12/18/2017 - US8534
                }
            }
            /********Ended By Manoj***********/
            
            if(envVars.size()>0) displayEnvDetails=true;
            //return constructWrapper(envVars);
        }
        else if(subcategorySelected!=null && subcategoryselected!=''){
            /******Added By Manoj as part of US60820 IPS Evolve****/
            envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
            //for(Core_IPS_Assigned_Environment_Variables__c subCatQtn : Core_IPS_CaseUtility.getEnvVariables(null,subCategorySelected,isAgent)){
            for(Core_IPS_Assigned_Environment_Variables__c subCatQtn : Core_IPS_Questions_Utility.getEnvDetailQuestions(null,subCategorySelected,isAgent)){  // added  by amritesh 12/18/2017 - US8534
                
                //system.debug('--------Sub Categry ----'+subCatQtn.Core_Environment_Variable__c+'--envqstns ---'+envQuestnIds+'--envqstns envDetails---'+envDetails);
                if(envQuestnIds!=null && !envQuestnIds.isEmpty()){
                    //if(!envQuestnIds.isEmpty() && !envQuestnIds.contains(subCatQtn.Core_Environment_Variable__c))
                    if(!envQuestnIds.isEmpty() && !envQuestnIds.contains(subCatQtn.Core_IPS_Question__c)) // added  by amritesh 12/18/2017 - US8534
                    envVars.add(subCatQtn);                
                }
                else {
                //system.debug('Inside Null envQuestnIds **');
                    envVars.add(subCatQtn);
                }
            }
            /******Ended By Manoj****/
        }
        /********* Commented By Manoj
       if(envVars!=null && envVars.size()==0){
           //envVars = Core_IPS_CaseUtility.getEnvVariables(productId,null,isAgent); 
       }****************************/
       if(envVars!=null && envVars.size()>0){
        displayEnvDetails=true;
        return constructWrapper(envVars);
       }else{
           displayEnvDetails=false;
           return null;
       }
       return null;
       
   }
    public List<Core_IPS_EnvironmentDetailQuestion> getEnvironmentDetailsOperationList(String productId, String subCategoryId, boolean isAgent){
        List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
        /******Added By Manoj as part of US60820 IPS Evolve****/
        List<Core_IPS_Assigned_Environment_Variables__c> subCatenvVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
        
        if(subCategoryId!=null && subCategoryId!='' && productId!=null){
            //envVars=Core_IPS_CaseUtility.getEnvVariables(productId,null,isAgent); 
            envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(productId,null,isAgent); // added by amritesh 12/18/2017 - US85344
            /******Added By Manoj*************/
            if(envVars!=null && !envVars.isEmpty()){
                envQuestnIds = new Set<Id>();
                for(Core_IPS_Assigned_Environment_Variables__c envQuestn : envVars){
                    //envQuestnIds.add(envQuestn.Core_Environment_Variable__c);
                    envQuestnIds.add(envQuestn.Core_IPS_Question__c); // added by amritesh 12/18/2017 - US85344
                }
            }

            for(Core_IPS_Assigned_Environment_Variables__c subCatQtn : Core_IPS_Questions_Utility.getEnvDetailQuestions(null,subCategorySelected,isAgent)) {
            //Core_IPS_CaseUtility.getEnvVariables(null,subCategorySelected,isAgent)){
                
               // system.debug('--------Sub Categry ----'+subCatQtn.Core_Environment_Variable__c+'--envqstns ---'+envQuestnIds+'--envqstns envDetails---'+envDetails);
                if(envQuestnIds!=null && !envQuestnIds.isEmpty()){
                    //if(!envQuestnIds.isEmpty() && !envQuestnIds.contains(subCatQtn.Core_Environment_Variable__c))
                    if(!envQuestnIds.isEmpty() && !envQuestnIds.contains(subCatQtn.Core_IPS_Question__c))  //added by amritesh 12/18/2017 - US85344
                    subCatenvVars.add(subCatQtn);  
                    system.debug('in other loop'+subCatQtn);
                }
                else {
                    //system.debug('Inside Null envQuestnIds');
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
            //system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + subCategoryId);
            //envVars=Core_IPS_CaseUtility.getEnvVariables(null,subCategoryId,isAgent);
            envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(null,subCategoryId,isAgent);
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + envVars.size());
            if(envVars.size() == 0 && productId!=null)
            {
               //envVars=Core_IPS_CaseUtility.getEnvVariables(productId,null,isAgent);
               envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(productId,null,isAgent);    //added by amritesh 12/18/2017 - US85344
            }
        }else if(productId!=null){
            //envVars=Core_IPS_CaseUtility.getEnvVariables(productId,null,isAgent);
            envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(productId,null,isAgent);    //added by amritesh 12/18/2017 - US85344
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
    * Amritesh                   12/18/2017              Modified - US8534
    ****************************************************************************************************/    
    public List<Core_IPS_EnvironmentDetailQuestion> constructWrapper(List<Core_IPS_Assigned_Environment_Variables__c> envVars){
        Map<Id,Core_IPS_Assigned_Environment_Variables__c> MapAssigned_EnvironmentVariables = new Map<Id,Core_IPS_Assigned_Environment_Variables__c>();
        Map<Id,Set<Id>> mapQuesParentId2DependentId = new Map<Id,Set<Id>>(); // added by amritesh 12/18/2017 - US85344 
        boolean IsOptionsChanges =  false;
        for(Core_IPS_Assigned_Environment_Variables__c Ev : envVars)
        {
            /****** added by amritesh 12/18/2017 - US85344 - start *******/
            //if(Ev.Core_Environment_Variable__c !=null && Ev.Core_Environment_Variable__r.Name !=null && Ev.Core_Environment_Variable__r.Name !='')
            if(Ev.Core_IPS_Question__c!=null && String.isNotBlank(Ev.Core_IPS_Question__r.Core_IPS_Question__c)) 
            {
                //MapAssigned_EnvironmentVariables.Put(Ev.Core_Environment_Variable__r.Name,ev);
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
            //for(Core_IPS_EnvironmentDetailQuestion En :envDetails)
            for(Core_IPS_EnvironmentDetailQuestion En : Core_IPS_Questions_Utility.getAllWithChildEnvDetails(envDetails))
            {
                //system.debug(en.Label);
                //system.debug(en.type);
                //system.debug(en.questionId);
                //system.debug(en.selectedValue);
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
        //system.debug('>>>>>>>>>>>>>>>>>>>>>>>' + IsOptionsChanges);
        if(IsOptionsChanges==false)
        {
            return envDetails;
        }
        
        // added  by amritesh 12/18/2017 - US8534 -start
        Map<Id,Map<Id,String>> mapQues2AnswerMap = new Map<Id,Map<Id,String>>();
        mapQues2AnswerMap = Core_IPS_Questions_Utility.getQues2AnswerMapId(new List<Id>(MapAssigned_EnvironmentVariables.keySet()));
        // added  by amritesh 12/18/2017 - US8534 - end
            
        //List<Core_IPS_EnvironmentDetailQuestion> envDetList = new List<Core_IPS_EnvironmentDetailQuestion>(); // commented by amritesh 12/18/2017 - US85344 
        Map<Id,Core_IPS_EnvironmentDetailQuestion> mapEnvDetail = new Map<Id,Core_IPS_EnvironmentDetailQuestion>(); // added by amritesh 12/18/2017 - US85344 
        
        Map<Id,Core_IPS_EnvironmentDetailQuestion> mapEnvDetail_AgentOnly = new Map<Id,Core_IPS_EnvironmentDetailQuestion>(); // added by Karthick 10/09/2018 - US113683 
        
        for(Core_IPS_Assigned_Environment_Variables__c en : envVars){
            Core_IPS_EnvironmentDetailQuestion det = new Core_IPS_EnvironmentDetailQuestion();
            //det.label=en.Core_Environment_Variable__r.name;            
            det.label = en.Core_IPS_Question__r.Core_IPS_Question__c; // added by amritesh 12/18/2017 - US85344 
            det.questionId = en.Core_IPS_Question__c; // added by amritesh 12/18/2017 - US85344 
            det.required = en.Core_required__c;
            det.IsAgentOnly = en.Core_Agent_Only__c;
            
            //if(en.Core_Environment_Variable__r.Core_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c.trim()){
            if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c.trim()) { //added by amritesh 12/18/2017 - US85344                
                System.debug('----- splaceholder Core_IPS_Datatype_Text');
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c;
                det.splaceHolder  = '';
                /*if(en.Core_Environment_Variable__r.Core_Answers__C!=null)
                det.splaceHolder=en.Core_Environment_Variable__r.Core_Answers__C;
                else
                det.splaceHolder = '';
                */  // commented by amritesh 12/18/2017 - US85344 
                // added by amritesh 12/18/2017 - US85344 
                if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                    Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                    if(mapAns.values().size()>0) {
                        det.splaceHolder  = mapAns.values().get(0);
                    }
                } 
                
            }else if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim() || en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim()){
                //List<String> answersList = en.Core_Environment_Variable__r.Core_Answers__C.split('\n');
                //added  by amritesh 12/18/2017 - US8534 - start
                List<SelectOption> selectOptionsList = new List<SelectOption>();
                SelectOptionsList.add(new SelectOption('','Select Option'));
                if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                    Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                    for(Id ansId : mapAns.keySet()) {
                        selectOptionsList.add(new SelectOption(ansId, mapAns.get(ansId)));
                    }
                } 
                //if(en.Core_Environment_Variable__r.Core_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim())
                if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim()){ // added  by amritesh 12/18/2017 - US8534
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim();
                } else{
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim();
                }
                det.pplaceholder=selectOptionsList;
                det.selectedValue=selectOptionsList.get(0).getValue();
            //}else if(en.Core_Environment_Variable__r.Core_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c.trim()){
            } else if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim() == Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c.trim()){   // added  by amritesh 12/18/2017 - US85344          
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c.trim();
                det.tplaceHolder= '';
                /*if(en.Core_Environment_Variable__r.Core_Answers__c!=null)
                det.tplaceHolder=en.Core_Environment_Variable__r.Core_Answers__C.trim();
                else
                det.tplaceHolder= '';
                */ // commented by amritesh 12/18/2017 - US85344 
                // added by amritesh 12/18/2017 - US85344 
                if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                    Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                    det.tplaceHolder = String.join(mapAns.values(), '\r\n');
                } 
            }
                /*else if(en.Core_Environment_Variable__r.Core_Datatype__c == 'boolean'){
                det.type=Core_IPS_Labels__c.getValues('Core_IPS_check').value__c;
                det.cplaceholder=false;
                }*/
            //envDetList.add(det);
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
                mapEnvDetail_AgentOnly.put(en.Core_IPS_Question__c, det);            
            }
            
            
            
        }
        //Modified by karthick - US113683
        if(mapEnvDetail_AgentOnly!=null && mapEnvDetail_AgentOnly.size()>0){
            mapEnvDetail.putAll(mapEnvDetail_AgentOnly);
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
        return lstEnvDetail;
    }
    
    private static void createQuestionHierachy(Id quesId, Map<Id,Core_IPS_EnvironmentDetailQuestion> mapEnvDetail, Map<Id,Set<Id>> mapQuesParentId2DependentId) {
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
    * Eswararao U                22/12/2017              Added lines to handle validation DML Exception US72553 Iteration-2
    * Karthick                   13/03/2018              Modified - Handled ISO Assignment US92632 - Release 4 - Iteration-8
    * Karthick                   10/05/2018              Modified - Default value assignment on Origin Field US104565 - Release 4.3 - Iteration-11
    *Ashutosh                    27/06/2018              Modified -Us106566 - added comment log below with name
    ****************************************************************************************************/    
    public PageReference saveCaseDetails(){
        if(validateGecDetails()) return null;
        if(validateInternalCase()) return null;        
        if(validateCaseRelatedInformation()) return null;
        if(validateEnvironmentDetails()) return null;       
        try{    
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
           if(selectedProductId!=null && selectedProductId!=''){
                cs.assetId = selectedProductId;
            }
             system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>' + selectedSAProductId);
            if(selectedSAProductId!=null && selectedSAProductId!=''){
                //Ashutosh-Us106566 - commenting here the code as we are already finding out that the selected id is asset or supported product
                //if it is asset then we are getting supp product from asset and adding that on case supp product and if it is just selected product then we 
                //are just adding them to case
                //instead code is written in onLookupChange method to poplulate supported product for NAC
                
                
                //cs.Core_IPS_Supported_Product__c = selectedSAProductId;               
            }
                        
            //private project check - US191343
            Boolean isPrivateProject = false;
            if(selectedProjId!=null &&  selectedProjId!='' && selectedProjId!='NA'){
                cs.Core_IPS_Project_Case__c = selectedProjId;
                isPrivateProject = [SELECT Core_IPS_Private__c FROM Core_IPS_Project__c WHERE Id=:selectedProjId LIMIT 1].Core_IPS_Private__c;
            }
            else
            {
               cs.Core_IPS_Project_Case__c =null;               
            }
            //system.debug(cs.Core_IPS_Project_Case__c + 'vaibhav---' +selectedProjId);
            system.debug('((((((((((((((((((' + selectedContactId);
            //String contactId =selectedContactId;                  
            if(selectedContactId!=null && selectedContactId!=''){
                //Added Core_IPS_Intel_Support_Owner__c in soql by Karthick - US92632 - Release 4 - I8
                Contact con = [select id,account.ownerId,accountid,Core_IPS_Intel_Support_Owner__c,Core_MINDS__c,Core_Country_Region__c from contact where id=:selectedContactId]; 
                //Private project check - US191343
                if(isPrivateProject) {
                    cs.contactId = null;
                    cs.accountid = null;
                    cs.Core_IPS_Supported_Contact__c = selectedContactId;
                } else {
                    cs.contactId = selectedContactId;
                    cs.accountid = con.accountid ;
                }
                //Added by Karthick - US92632 - Release 4 - I8 - ISO Assignment.
                if(con.account.ownerId!=null && string.isBlank(con.Core_IPS_Intel_Support_Owner__c)){
                    cs.Core_Intel_Sup_Owner__c = con.account.ownerId;
                }  
                
                
                if(!String.isBlank(countrySelected)){
                    if(con.Core_Country_Region__c==null || con.Core_Country_Region__c==''){
                     con.Core_Country_Region__c= countrySelected;
                        Core_IPS_AdminUtility.updateContact(con);
                    }
                }
            }   
            // start added for US253173
                if(mindsOption=='Yes'){
                   cs.Core_IPS_Minds__c= true;
                }
            if(!String.isBlank(countrySelected)){
                cs.Core_IPS_Country_Region__c= countrySelected;
            }
            //end
            //Added for DE40678
            if(mindsOption=='No'){
                cs.Core_IPS_Minds__c= false;
            }
            //end for DE40678
            //User u = [select Id, username,userType,contactId from User where Id = :UserInfo.getUserId()];
            //cs.contactId = u.contactId;
            System.debug('@@@@##@@@@---------------------'+showGECFields);
            //commented for US253172
          /*  system.debug('@@@@@@-----------------------'+GECAnswer1+GECAnswer2+GECAnswer3);
            if(showGECFields!=null && showGECFields)
             {
                if(GECAnswer1 == 'Yes' || GECAnswer2 == 'Yes')
                {
                    
                    cs.Core_IPS_GEC_Flag__c = true;
                    //cs.Core_IPS_GEC_Case__c = true;
                    cs.IsStopped = true;  
                    cs.Status = 'On Hold';
                    //cs.Core_IPS_GEC_Request_Status__c = 'MAG Questionnaire Required'; //Commented for US253171
                    cs.Core_Sub_Status__c = 'GEC Hold';
                    String recordTypeId_GEC = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();
                    cs.recordtypeID =  recordTypeId_GEC;
                    isGECMarked = true;
                   
                   System.debug('---------------setting GEC answer boolean:'+isGECMarked); 
                }
              
                
             } */            
            
            if(cs.Core_Issue_Description__c != null)
            {                   
                string  strDescValue =  Core_Utility.replaceSpecialChar(cs.Core_Issue_Description__c);
                
                cs.Description = Core_Utility.replaceHtmlTags(strDescValue);
            }   
            if(showGECFields==false && Mode!='edit' && mode!='copy') { // US127333
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
            
            // Added by sumukh for US69871
            
            if(cs.id==null && (GECAnswer1 == 'No' && GECAnswer2 == 'NO') && cs.ContactId!=null  ){
                String recordTypeId_NewCase = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
               // String recordTypeId_SA = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
                cs.recordtypeid=recordTypeId_NewCase;
            }
            cs.Core_Product_Variant__c=SelectedVariant;            
            if(selectedAccountId!= ''){
                cs.Core_Partner_Supported_Account__c=selectedAccountId;
            }
            
            // End by sumukh for US69871
            //Added by sugandha for US85567
            if(String.isBlank(selectedPSOId)){
                selectedPSOId = null;
            }
            if(String.isBlank(selectedPSA)){
                selectedPSA = null;
            }
            cs.Core_IPS_Partner_Sup_Owner__c = selectedPSOId;
            cs.Core_Partner_Supported_Account__c = selectedPSA;
            //End here
            
            //added by amritesh - DE38937 - start
            Integer countEnvDetails = 0;
            List<Core_IPS_EnvironmentDetailQuestion> lstAllenvDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
            if(subCatenvDetList!=null && subCatenvDetList.size()>0){
                lstAllenvDetails.addAll(Core_IPS_Questions_Utility.getAllWithChildEnvDetails(subCatenvDetList));
            }
            if(envDetails!=null && envDetails.size()>0){
                lstAllenvDetails.addAll(Core_IPS_Questions_Utility.getAllWithChildEnvDetails(envDetails));
            }
            if(lstAllenvDetails!=null && lstAllenvDetails.size()>0){
                for(Core_IPS_EnvironmentDetailQuestion det : lstAllenvDetails){     
                    if(det.isVisible) countEnvDetails++;
                }
            }
            if(countEnvDetails==0) cs.Core_Environment_Details__c = null;
            //added by amritesh - DE38937 - end
            
            //Added by Karthick - US104565 - 10-05-2018 - I11
            if(String.isBlank(cs.Origin)){
                cs.Origin = 'Web';
            }
            // US127333 - Start
            if(mode=='copy') { 
                String recordTypeId_NewCase = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
                String recordTypeId_SA = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
        
                cs = cs.clone(false,true,false,false);
                cs.Id = null;
                cs.ParentId = csId;
                //US185241 Gourav - To restrict IPS CAse Create Record Type when GEC questions are answered Yes while cloning GEC Case 
                if(!isGECMarked){
                 cs.Status = 'New';
                 cs.Core_Sub_Status__c = null;
                 if(cs.Core_IPS_Self_Assigned__c==true) {
                    cs.RecordTypeId = recordTypeId_SA;
                 } else {
                    cs.RecordTypeId = recordTypeId_NewCase;
                 }
                }
            }
            // US127333 - end  
            
            upsert cs;
            //addGECRecords();  //Commented for US253172
            
            //addEnvDetails();
            captureEnvDetails(); // added  by amritesh 12/18/2017 - US85344
            
            if(mode=='copy') { // US127333                
                copyInterestedParties();
            }
            
        } catch(DMLException e){
            Core_Exceptionclass Exce =  new Core_Exceptionclass();
            string  Str = Exce.InsertException('','Core_IPS_Internal_Case_Controller','Case','','saveCaseDetails',e);
            renderErrorFlag=true;
            //Added by Eswar US72553 Iteration-2 22-12-2017
            ApexPages.Message msg;
            if(string.valueOf(e).contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){ msg = new ApexPages.Message(Apexpages.Severity.Warning, + e.getdmlMessage(0));    }
            else {msg = new ApexPages.Message(Apexpages.Severity.Warning, 'DML Exception '+e );          }
            //end - Eswar
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
    * Aayushi                    27/02/2019              Commented the method US253172
    ****************************************************************************************************/    
  /*  public void addGECRecords(){
        if(showGECFields!=null && showGECFields)
             {
                 //Modified by Sugandha for US135425
                //if(GECAnswer1 == 'Yes' || GECAnswer2 == 'Yes' )
                if(GECAnswer1 == 'Yes' || GECAnswer2 == 'Yes' || GECAnswer1 == 'No' || GECAnswer2 == 'No')
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
    } */
    
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
    * Manoj Kumar                06/20/2017              Modified
    * Amritesh                   12/18/2017              Modified - US8534
    ****************************************************************************************************/
    public boolean validateEnvironmentDetails(){
        // added by amritesh 12/18/2017 - US8534 - start
        List<Core_IPS_EnvironmentDetailQuestion> lstAllenvDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        if(subCatenvDetList!=null && subCatenvDetList.size()>0){
            lstAllenvDetails.addAll(Core_IPS_Questions_Utility.getAllWithChildEnvDetails(subCatenvDetList));
        }
        if(envDetails!=null && envDetails.size()>0){
            lstAllenvDetails.addAll(Core_IPS_Questions_Utility.getAllWithChildEnvDetails(envDetails));
        }
    
        // commented by Amritesh 12/18/2017 - US8534
        /******Added By Manoj as part of US60820 IPS Evolve****
        if(subCatenvDetList!=null && subCatenvDetList.size()>0){
            for(Core_IPS_EnvironmentDetailQuestion envdet : subCatenvDetList){                
                //if(envdet.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c &&(envdet.sPlaceHolder==null || envdet.sPlaceHolder=='') &&envdet.required){
                if(envdet.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c &&(envdet.sPlaceHolder==null || envdet.sPlaceHolder=='') &&envdet.required){ // added  by amritesh 12/18/2017 - US85344
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+envdet.label);
                ApexPages.addMessage(myMsg);
                return true;    
                //}else if(envdet.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c&&(envdet.sPlaceHolder !=null || envdet.sPlaceHolder !='') && envdet.sPlaceHolder.length()>255){
                }else if(envdet.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c&&(envdet.sPlaceHolder !=null || envdet.sPlaceHolder !='') && envdet.sPlaceHolder.length()>255){ // added  by amritesh 12/18/2017 - US85344
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G111')+':'+envdet.label);
                ApexPages.addMessage(myMsg);
                return true;                
                //}else if(envdet.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c &&(envdet.tPlaceHolder==null ||envdet.tPlaceHolder=='')&&envdet.required){
                }else if(envdet.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c &&(envdet.tPlaceHolder==null ||envdet.tPlaceHolder=='')&&envdet.required){ // added  by amritesh 12/18/2017 - US85344
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+envdet.label);
                ApexPages.addMessage(myMsg);
                return true;
                //}else if(envdet.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c && (envdet.tPlaceHolder != null ||envdet.tPlaceHolder!='') && envdet.tPlaceHolder.length()>5000){
                }else if(envdet.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c && (envdet.tPlaceHolder != null ||envdet.tPlaceHolder!='') && envdet.tPlaceHolder.length()>5000){ // added  by amritesh 12/18/2017 - US85344
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G110')+':'+envdet.label);
                ApexPages.addMessage(myMsg);
                return true;
                }else if((envdet.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c) &&(envdet.selectedValue==null || envdet.selectedValue=='' || envdet.selectedValue=='[]') && envdet.required){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G106')+':'+envdet.label);
                ApexPages.addMessage(myMsg);
                return true;
                }
                else if((envdet.type==Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c) &&(envdet.selectedMValue==null || envdet.selectedMValue.size() == 0 ||(envdet.selectedMValue.size()==1 && envdet.selectedMValue[0]=='')) && envdet.required){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G106')+':'+envdet.label);
                ApexPages.addMessage(myMsg);
                return true;
                }
            }
            //return false;
        }/***Ended By Manoj***/
        
        //if(envDetails!=null && envDetails.size()>0){
            //for(Core_IPS_EnvironmentDetailQuestion det : envDetails){ 
        // added by amritesh 12/18/2017 - US8534
        if(lstAllenvDetails!=null && lstAllenvDetails.size()>0){
            for(Core_IPS_EnvironmentDetailQuestion det : lstAllenvDetails){     
                if(!det.isVisible) continue; // added by amritesh 12/18/2017 - US8534
                //if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c &&(det.sPlaceHolder==null || det.sPlaceHolder=='') &&det.required){
                if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c &&(det.sPlaceHolder==null || det.sPlaceHolder=='') &&det.required){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+det.label);
                ApexPages.addMessage(myMsg);
                return true;    
                //}else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c&&(det.sPlaceHolder !=null || det.sPlaceHolder !='') && det.sPlaceHolder.length()>255){
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c&&(det.sPlaceHolder !=null || det.sPlaceHolder !='') && det.sPlaceHolder.length()>255){ // added  by amritesh 12/18/2017 - US8534
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G111')+':'+det.label);
                ApexPages.addMessage(myMsg);
                return true;    
                //}else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c &&(det.tPlaceHolder==null ||det.tPlaceHolder=='')&&det.required){
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c &&(det.tPlaceHolder==null ||det.tPlaceHolder=='')&&det.required){ // added  by amritesh 12/18/2017 - US8534
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G105')+':'+det.label);
                ApexPages.addMessage(myMsg);
                return true;
                //}else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c && (det.tPlaceHolder != null ||det.tPlaceHolder!='') && det.tPlaceHolder.length()>5000){
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
            //return false;
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
                system.debug('@@@@@@'+mindsOption+countrySelected);
                if(String.isBlank(mindsOption)  || String.isBlank(countrySelected))
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
    * Sugandha                   06/20/2015              Modified
    ****************************************************************************************************/ 
    public boolean validateCaseRelatedInformation(){
        
        system.debug('@@@@@@'+categorySelected);
        system.debug('@@@@@@'+displayCategories);    
        // Added check for closed cases by Sugandha for DE40247    
        //string  strdesc  = cs.Core_Issue_Description__c.replaceAll('<p>','').replaceAll('</p>','').replaceAll('&shy;','');
        //if((displayCategories==null || displayCategories) && (categorySelected==null || (categorySelected!=null && categorySelected.trim().length()==0))){
        if((categoryOptions!=null && categoryOptions.size()>1) && (categorySelected==null || (categorySelected!=null && categorySelected.trim().length()==0)) && !isClosed){
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
        //Added by karthick - defect fix : DE40206 - 20/06/2018
        if(cs.Core_IPS_Issue_source__c==null || cs.Core_IPS_Issue_source__c==''){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G120'));
                ApexPages.addMessage(myMsg);
                return true;
        }
        if(cs.Core_CaseType__c==null || cs.Core_CaseType__c==''){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G109'));
                ApexPages.addMessage(myMsg);
                return true;
        }
        
        
        //Commented by Sugandha for DE37699
        /*if(csId <> null && csId <> '' && platformOptions != null && platformOptions.size() > 1 && (platformSelected==null || (platformSelected!=null && platformSelected.trim().length()==0))){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errormessage('G107'));
                ApexPages.addMessage(myMsg);
                return true;
        }*/
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
    * Manoj Kumar                06/20/2017              Modified
    * Amritesh                   12/18/2017              Modified - US8534
    ****************************************************************************************************/     
    /*** commented by amritesh 12/18/2017 - US8534
    public void addEnvDetails(){
    List<Core_IPS_Environment_Details__c> existingDetails = new List<Core_IPS_Environment_Details__c>();
        existingDetails = [select id from Core_IPS_Environment_Details__c where Core_case__c=:cs.id];
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + existingDetails);
        if(existingDetails <> null && existingDetails.size()>0){
           // delete ExistingDetails;
           Core_IPS_AdminUtility.DeleteEnvDetails(ExistingDetails);
        }
        List<Core_IPS_Environment_Details__c> envDetailsToCreate = new List<Core_IPS_Environment_Details__c>();
        if(envDetails!=null && envDetails.size()>0){
            for(Core_IPS_EnvironmentDetailQuestion det:envDetails){
                Core_IPS_Environment_Details__c detail = new Core_IPS_Environment_Details__c();
                detail.Core_Question__c= det.label;
                detail.Core_case__c= cs.id;
                detail.Name = det.label;
                detail.Core_Agent_Only__c = det.IsAgentOnly;
                //if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c.trim()){
                if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c.trim()){ // added  by amritesh 12/18/2017 - US8534
                    detail.Core_Answer__c = det.sPlaceHolder;
                //}else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c){
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c){ // added  by amritesh 12/18/2017 - US8534
                    detail.Core_Answer__c= det.tPlaceHolder;
                }else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ){
                    detail.Core_Answer__c= det.selectedValue;
                }else if(det.type == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c){
                    string  strSelectedValue  = '';
                    for(string  str  : det.selectedMValue)
                        { 
                         if(str!='')
                          strSelectedValue = strSelectedValue + str + ';' ;
                        }
                    detail.Core_Answer__c = strSelectedValue;//det.selectedValue;
                }//else if(det.type==Core_IPS_Labels__c.getValues('Core_IPS_check').value__c){
                 //   if( det.cPlaceHolder)
                 //       detail.Core_Answer__c= 'True';
                 //   else
                 //       detail.Core_Answer__c= 'False'; 
                //}
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>' + detail);
                envDetailsToCreate.add(detail);
            }
            }
            
            //Added By Manoj as part of US60820 IPS Evolve
            if(subCatenvDetList!=null && subCatenvDetList.size()>0){
                for(Core_IPS_EnvironmentDetailQuestion scatdet:subCatenvDetList){
                    Core_IPS_Environment_Details__c detail = new Core_IPS_Environment_Details__c();
                    detail.Core_Question__c= scatdet.label;
                    detail.Core_case__c= cs.id;
                    detail.Name = scatdet.label;
                    detail.Core_Agent_Only__c = scatdet.IsAgentOnly;
                    //if(scatdet.type==Core_IPS_Labels__c.getValues('Core_IPS_text_255').value__c.trim()){ 
                    if(scatdet.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_Text').value__c.trim()){ // added  by amritesh 12/18/2017 - US8534
                        detail.Core_Answer__c = scatdet.sPlaceHolder;
                    //}else if(scatdet.type==Core_IPS_Labels__c.getValues('Core_IPS_textarea_5000').value__c){
                    }else if(scatdet.type==Core_IPS_Labels__c.getValues('Core_IPS_Datatype_TextArea').value__c){ // added  by amritesh 12/18/2017 - US8534
                        detail.Core_Answer__c= scatdet.tPlaceHolder;
                    }else if(scatdet.type==Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c ){
                        detail.Core_Answer__c= scatdet.selectedValue;
                    }else if(scatdet.type == Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c){
                        string  strSelectedValue  = '';
                        for(string  str  : scatdet.selectedMValue)
                            { 
                             if(str!='')
                              strSelectedValue = strSelectedValue + str + ';' ;
                            }
                        detail.Core_Answer__c = strSelectedValue;//det.selectedValue;
                    }
                    system.debug('>>>>>>>>>>>>>>>>>>>>>>>' + detail);
                    envDetailsToCreate.add(detail);
                }
            }// ENDED By Manoj
            if(envDetailsToCreate.size()>0){
                 //insert envDetailsToCreate;
                Core_IPS_AdminUtility.insertEnvDetailsToCreate(envDetailsToCreate);
            }
    }
    */
    
    // added  by amritesh 12/18/2017 - US8534
    public void captureEnvDetails() {   
        if(cs.Id!=null && mode!='copy') { // US127333
            List<Core_IPS_Response__c> lstExistingCoreResponse = Core_IPS_Questions_Utility.getEnvDetailCoreResponse(cs.Id);
            if(lstExistingCoreResponse!=null && lstExistingCoreResponse.size()>0) {
                Core_IPS_AdminUtility.DeleteEnvDetails(lstExistingCoreResponse);
            }
        }
        List<Core_IPS_Response__c> lstEnvDetailsResponse = new List<Core_IPS_Response__c>();
        List<Core_IPS_EnvironmentDetailQuestion> lstEnvDetails = new List<Core_IPS_EnvironmentDetailQuestion>();
        //Modified the order of EDQs by karthick as part of US113683
        if(subCatenvDetList!=null) lstEnvDetails.addAll(subCatenvDetList);
        if(envDetails!=null) lstEnvDetails.addAll(envDetails);       
        
        if(lstEnvDetails!=null && lstEnvDetails.size()>0) {
            for(Core_IPS_EnvironmentDetailQuestion envdet : lstEnvDetails) {
                lstEnvDetailsResponse.addAll(Core_IPS_Questions_Utility.constructResponse(envdet, cs));
                if(envdet.childQuestions.size()>0) {
                    for(Core_IPS_EnvironmentDetailQuestion childEnvDetail : envdet.childQuestions) {
                        if(childEnvDetail.isVisible)
                        lstEnvDetailsResponse.addAll(Core_IPS_Questions_Utility.constructResponse(childEnvDetail, cs));
                    }
                }
             }
            if(lstEnvDetailsResponse.size()>0){
                Core_IPS_AdminUtility.insertEnvDetailsToCreate(lstEnvDetailsResponse);
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
    * Amritesh                   12/18/2017              Modified - US8534
    ****************************************************************************************************/   
    // commented  by amritesh 12/18/2017 - US8534
    /*private class EnvironmentDetail{
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
        
        public Id questionId; // added by amritesh 12/18/2017 - US85344 
    }*/    
     //[Oct/09/2015 - Abhishek Arya - START - Method to show GEC fields for internal users based on Contact's Account is MAG Only.]
     //Commented method for US253172 as part of GEC process changes
   /* public pagereference showGECFieldsToIntUsrsForMAGAcc(){
            system.debug('********start*******');
            AnswerOptions = new list<SelectOption>();            
            //AnswerOptions.add(new SelectOption('', '--Select--'));
            //AnswerOptions.add(new SelectOption('Yes', 'Yes'));
            //AnswerOptions.add(new SelectOption('No', 'No'));
            AnswerOptions = Core_IPS_CaseUtility.getGECAnswerOptions();
            //List<Contact> conList=new List<Contact>();
            //string passedParam1 = Apexpages.currentPage().getParameters().get('myParam');            
            //If(passedParam1 <> null && passedParam1 <> '' && Id.valueOf(passedParam1).getSObjectType().getDescribe().getName() == 'Contact')
            showGECFields = Core_IPS_Helper_Utility.isGECAccount(selectedContactId);          
            //system.debug('****passedparam****'+passedParam1+'*******'+showGECFields+'********'+Id.valueOf(passedParam1).getSObjectType().getDescribe().getName());
            return null;                        
    }   */         
    //[Oct/09/2015 - Abhishek Arya - END]
    
    //[Oct/09/2015 - Abhishek Arya - START - Method to show GEC fields for internal users based on Contact's Account is MAG Only.]
   /* public void rerenderGECFieldsToIntUsrsForMAGAcc(){
        system.debug('@@@render gec@@@@'+selectedContactid+(cs.Id==null));
        if(selectedContactid <> null && selectedContactid <> '' && cs.Id == null){
           showGECFields = Core_IPS_Helper_Utility.isGECAccount(selectedContactid);            
        }else{ 
            showGECFields=false;   
        }                           
    } */           
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
        System.debug('Before'+idList);
        platformOptions = Core_IPS_CaseUtility.getplatform_Options(idList);
        if(platformOptions.size()>1) displayPlatform=true;
        else displayPlatform=false;
        return platformOptions;      
   }         
   
    
    public void resetProduct()
    {
        this.selectedProduct = '';        
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
    }
    
    public void BindEvent(){}
    //Added by Geetha
    // Added by sumukh for US69871
    //US80347:To get values of product variant 
    
   Public void displayProductVariant(){ 
      blnShowVariant = false;
       variants = Product_Variant_Utility.displayProductVariant(selectedProductId);   
       
    // Added by sumukh for 108868 / Defect DE40396 Iteration 13 , Release 4.3  
    
        List<SelectOption> so=null;
        variantsList=new List<list<SelectOption>>();
        for(Integer i=0;variants!=null && i<(variants.size()/999)+1;i++){
           so=new List<SelectOption>();
          for(Integer j=(i*999);(j<(i*999)+999) && j<variants.size() ;j++){
              so.add(variants.get(j));
           }
        variantsList.add(so);
      } 
    // end For US 108868 By Sumukh
                
       blnShowVariant = Product_Variant_Utility.blnShowVariant;      
    }
     
    // End by sumukh for US69871
    
    // Added by sumukh for US107484 / Defect DE40396 & DE20747  Iteration 13 , Release 4.3
    
    Public void displayProductVariant_NAC(){ 
        blnShowVariant_NAC = false;       
        variants_NAC = Product_Variant_Utility.displayProductVariant_NAC(selectedSAProductId);
      
        List<SelectOption> so=null;
        variantsList_NAC=new List<list<SelectOption>>(); // Made change by sumukh for defect DE20747
       
        for(Integer i=0;variants_NAC!=null && i<(variants_NAC.size()/999)+1;i++){  // Made change by sumukh for defect DE20747
           so=new List<SelectOption>();
            for(Integer j=(i*999);(j<(i*999)+999) && j<variants_NAC.size() ;j++){   // Made change by sumukh for defect DE20747      
              so.add(variants_NAC.get(j));                                           // Made change by sumukh for defect DE20747
            }          
          variantsList_NAC.add(so);                                                  // Made change by sumukh for defect DE20747
        }     
        blnShowVariant_NAC = Product_Variant_Utility.blnShowVariant_NAC;
    }
    
    // End by sumukh for US107484
    
/***************************************************************************************************
Method Name:  DisplayPSAPSO
Method Type: Action Method 
Version     : 1.0 
Created Date: 16-03-2018
Function    : This method displays PSA and PSO based on Project and Contact selection.
Input Parameters: None
Output Parameters: None 
Used in     : Case Edit Screen
Modification Log :
               
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                   16/03/2018                 Created(UserStory US85567 Iteration 8)
****************************************************************************************************/ 
    Public void DisplayPSAPSO(){
        //set of all users assigned to  IPS FAE Partner Permission set     
        Set<Id> userIds = new Set<Id>();
        for(PermissionSetAssignment uId: [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :System.Label.Core_IPS_Partner_DFAE_Permission_Set AND Assignee.ProfileId = :System.Label.Core_IPS_Partner_Profile_Id]){
            userIds.add(uId.AssigneeId);
        }
        
        //Senario 1:Project Based Cases - When editing the Partner Supported Account field, the picklist will only show accounts associated to project on the case      
        if((selectedProjId <> '' && selectedProjId != null) || cs.Core_IPS_Project_Case__c != null){
            system.debug(selectedProjId );
            String projtId = '';
            if(selectedProjId == null){
                projtId = cs.Core_IPS_Project_Case__c;
            }
            else{
                projtId = selectedProjId;
            }
            system.debug('projtId ::'+projtId);
            //List of all Active project members whose profile is Agent Partner profile or FAE Partner permission set
            List<Core_IPS_Project_Member__c> projMem =[SELECT id 
                                               FROM Core_IPS_Project_Member__c
                                               WHERE (Core_User__c IN :userIds OR
                                               Core_User__r.ProfileId = :system.Label.Core_IPS_Agent_Partner_Profile_id) AND
                                               Core_IPS_Project__c =: projtId AND
                                               Core_Status__c = 'Active']; 
            //Render PSO PSA only if there are atleast a project member in above list                                    
            if(projMem != null && !projMem.isEmpty()){
                displayPSO = true;
            }
            //Query PSA only if there a PSO available under selected Project
            if(displayPSO == true){
                //List of Partner Support Account
                lstPSA = new List<SelectOption>();
                lstPSA.add(new SelectOption('','--None--'));
                //List of all active Accounts under selected project
                List<Account> lstAcc = [SELECT id,Name FROM account
                                        WHERE Id IN (SELECT Core_Account__c FROM Core_IPS_Account__c 
                                        WHERE Core_IPS_Project__c =:projtId AND 
                                        Core_Status__c = 'Active')];
                for(Account acc : lstAcc){
                    lstPSA.add(new SelectOption(acc.id,acc.Name));
                }  
            }
        }
        //Senario 2: When editing the Partner Supported Account field, the picklist should display all Accounts associated with all projects in which the PSO is a member.
        else if((selectedContactId != '' && SelectedContactId != null) || cs.AccountId <> null){
            system.debug('selectedContactId '+selectedContactId );
            String ConId = '';
            if(selectedContactId == null )
                ConId= cs.ContactId;
            else
                ConId= selectedContactId;
             system.debug('selectedContactId '+ConId );
            //AccountId of Contact Case 
            Id AcctId;
            for(Contact c: [SELECT AccountId FROM Contact WHERE Id =: ConId and Core_IPS_Active__c = True]){
                AcctId = c.AccountId;
            }
            //List of all active user under Account of the case
            if(AcctId != null){
                List<User> lstAcctUser= [SELECT id FROM User WHERE isActive=True AND 
                                        (Id IN :userIds OR ProfileId = :system.Label.Core_IPS_Agent_Partner_Profile_id) AND 
                                        Contact.AccountId =: AcctId];
                
                //Render PSO PSA if there is atleast one user in above list 
                if(lstAcctUser != null && !lstAcctUser.isEmpty()){
                    displayPSO = true;
                }
            }
            //Query for PSA only if there is a eligible PSO available under Account 
            if(displayPSO == true){
                //list of Partner Support Account
                lstPSA = new List<SelectOption>();
                lstPSA.add(new SelectOption('','--None--'));
                String psoId = '';
                if(selectedPSOId == null)
                    psoId = cs.Core_IPS_Partner_Sup_Owner__c;
                else
                    psoId = selectedPSOId;
                System.debug('selectedPSOId::'+selectedPSOId);    
                if(selectedPSOId != null && selectedPSOId != ''){ 
                    //set of project ids where PSO is a member
                    set<Id> allProjIds = new set<Id>();     
                    for(Core_IPS_Project__c project: [SELECT id FROM Core_IPS_Project__c WHERE id IN (SELECT Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_User__c = :selectedPSOId AND Core_Status__c = 'Active')]){
                        allProjIds.add(project.Id);
                    } 
                    //List of all Active Accounts which are part of above project list
                    List<Account> lstAcc = [SELECT id,Name FROM account
                                            WHERE id IN (SELECT Core_Account__c FROM Core_IPS_Account__c 
                                            WHERE Core_IPS_Project__c IN :allProjIds AND Core_Status__c = 'Active')];
                    for(Account acc : lstAcc){
                        lstPSA.add(new SelectOption(acc.id,acc.Name));
                    }
                }                  
            }
        }
        
    }
/***************************************************************************************************
Method Name:  PopulateAssetProj
Method Type: Action Method 
Version     : 1.0 
Created Date: 09-05-2018
Function    : This method populate Project automatically on Project Asset selection.
Input Parameters: None
Output Parameters: None 
Used in     : Case Edit Screen
Modification Log :
               
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                   09/05/2018                 Created(Defect DE38632 Iteration 11)
****************************************************************************************************/     
     public void PopulateAssetProj(){
        List<Asset> lstProject = new List<Asset>();
        lstProject = [select Core_IPS_Project__c,Core_IPS_Project__r.Name from Asset where Id=:selectedProductId];
        if(lstProject!= null && lstProject.Size()>0)
        {
            selectedProjId = lstProject[0].Core_IPS_Project__c;
            cs.Core_IPS_Project_Case__c = selectedProjId;
            projSelected = lstProject[0].Core_IPS_Project__r.Name;
        }
    }

  //added by amritesh - 08/20/2018
    public void copyInterestedParties() {
        List<Core_IPS_Case_Interested_Party__c> newPartyList = new List<Core_IPS_Case_Interested_Party__c>();
        for(Core_IPS_Case_Interested_Party__c party : [SELECT User__c,Active__c,Contact__c,Type__c FROM Core_IPS_Case_Interested_Party__c WHERE Case__c=:csId]){
            Core_IPS_Case_Interested_Party__c newParty =  new Core_IPS_Case_Interested_Party__c();
            newParty.Case__c = cs.Id;
            newParty.User__c = party.User__c;
            newParty.Active__c = party.Active__c;
            newParty.Contact__c = party.Contact__c;
            newParty.Type__c = party.Type__c;
            newPartyList.add(newParty);
        }
        if(newPartyList.size()>0)
            Core_IPS_AdminUtility.insertInterestedParties(newPartyList);//This method insert the parties now
    }     

}