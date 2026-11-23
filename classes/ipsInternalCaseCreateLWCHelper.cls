public with sharing class ipsInternalCaseCreateLWCHelper {
    public ipsInternalCaseCreateLWCHelper() {

    }
     @AuraEnabled public static Boolean blnShowVariant{get;set;}
    @AuraEnabled public static Boolean blnShowVariant_NAC{get;set;}
    @AuraEnabled public static String isProductId{get;set;}
   @AuraEnabled Public static List<Asset> assetList{get;set;}
    //@AuraEnabled public static List<SelectOption> variants{get;set;}
    @AuraEnabled public static List<CustomSelectOptions> variants{get;set;}
    
    @AuraEnabled Public static List<Core_Flat_Product_Hierarchy__c > flatIdsList{get;set;}
    @AuraEnabled Public static List<Core_IPS_Supported_Product__c> supportedProdList{get;set;}
    @AuraEnabled public static List<CustomSelectOptions> subCategoryOptions{get;set;}

    //edq
    @AuraEnabled Public static  List<Core_IPS_EnvironmentDetailQuestion> envDetails{set;get;}
    @AuraEnabled public static List<Core_IPS_EnvironmentDetailQuestion> addchild{set;get;}
    
    //public List<Core_IPS_EnvironmentDetailQuestion> envDetList{get;set;}
    @AuraEnabled Public static List<Core_IPS_EnvironmentDetailQuestion> subCatenvDetList{get;set;}
  //  @AuraEnabled public   List<Id> envQuestnIds;
    @AuraEnabled public static  boolean isAgent{get;set;}
    @AuraEnabled public Static Case cs{get;set;}
    @AuraEnabled public static boolean renderErrorFlag{get;set;}
    @AuraEnabled public static String countrySelected{get;set;}
    @AuraEnabled public static List<LWCResponseEDQ> classTwoWrap{get;set;}
   // @AuraEnabled public List<CustomSelectOptions> lwcplaceholder{get;set;}

   //interested party
   //@AuraEnabled  public static  IPWrapper IPRecordSet{get;set;}

    @AuraEnabled(cacheable=true)
    public static boolean getAgent(){
       return isAgent = Core_IPS_Helper_Utility.isIPSCustomerUser();
    }
    @AuraEnabled
    public static List<CustomSelectOptions> getPlaform(Id productsId){
        List<Id> astIdList=new List<Id>();
       astIdList.add(productsId);
                //platformOptions=getplatformOptions(astIdList);
        return getplatform_Options(astIdList);
    }
    @AuraEnabled
    public static List<CustomSelectOptions> displayProductVariant(String selectedProductId){ 
        blnShowVariant = false;
        isProductId = selectedProductId;
        if(selectedProductId!=null && selectedProductId!=''){
            //Query on Asset
            assetList = database.Query('select id, Name,Core_Product_Organization__c,core_supported_product__c,core_supported_product__r.Core_IPS_Is_Show_Variant__c,Core_IPS_Project__c,Core_Product_EPM_ID__c from asset where id=:selectedProductId'); 
            System.debug('List of asset records====='+assetList);
            
            if(!assetList.isEmpty() && assetList.size()>0){
                if(assetList[0].core_supported_product__r.Core_IPS_Is_Show_Variant__c== true){
                    //Query on FlatProductHierarchy
                    String strQuery = 'select id,Core_EPM_Hierarchy_Name__c, Core_L1_EPM_ID__c,Core_L1_EPM_Name__c,Core_L2_EPM_ID__c,Core_L2_EPM_Name__c,Core_Unique_ID__c from Core_Flat_Product_Hierarchy__c where Core_Unique_ID__c like \'%;'+assetList[0].Core_Product_EPM_ID__c+';%\'' +'OR Core_Unique_ID__c like'+ '\'%;'+assetList[0].Core_Product_EPM_ID__c+'\'';
                    
                    flatIdsList= database.Query(strQuery);
                    set<String> ids=new set<String>();
                    System.debug('FLATProd Data'+ flatIdsList);
                    if(!flatIdsList.isEmpty() && flatIdsList.size()>0){
                        
                        for(Core_Flat_Product_Hierarchy__c fph :flatIdsList){
                            String data=fph.Core_Unique_ID__c;
                            System.debug('data===='+data);
                            List<String> recorddata=data.split(';');
                            System.debug('recorddata==='+recorddata);
                            System.debug('recorddata===Actual'+assetList[0].Core_Product_EPM_ID__c);
                            for(integer i=0;i<recorddata.size();i++){
                                System.debug(' Thsi belongs to this org-->'+(assetList[0].Core_Product_Organization__c));
                                if(recorddata[i]==assetList[0].Core_Product_EPM_ID__c){
                                    //added by ranjini
                                    if(System.label.Core_IPS_MAG_Support_Org.Contains((assetList[0].Core_Product_Organization__c+'').substring(0,15))){
                                        System.debug(' Entering PSG-->'+(assetList[0].Core_Product_Organization__c));
                                        if(i>0 && i==1){
                                        ids.add(recorddata.get(i-1));
                                       System.debug(' ids1-->'+ids);
                                    }else if(i>0 && i==2){
                                        //third level
                                       System.debug(' ids3data-->'+recorddata.get(i-2));
                                        ids.add(recorddata.get(i-2));
                                        System.debug(' ids3-->'+ids);
                                    }else if(i>0 && i==3){
                                        //second level
                                        ids.add(recorddata.get(i-1));
                                        System.debug(' ids2-->'+ids);
                                    }
                                    System.debug(' ids-->'+ids);
                                    }else{
                                        if(i>0)
                                        ids.add(recorddata.get(i-1));
                                    }
                                    System.debug('i value-->'+i);
                                    /*if(i>0)
                                        ids.add(recorddata.get(i-1));*/
                                }
                            }  
                        }
                    }          
                    ids.remove(assetList[0].Core_Product_EPM_ID__c);
                    
                    List<Product2> Productlist = new List<Product2>();
                    String strIPS = 'IPS';
                    
                    //Query on Product for showing the product variant names based on EPM ID 
                    if(ids!=null && ids.size()>0){
                        Productlist = database.Query('select id, Name FROM Product2 where Core_Product_Org__c = :strIPS  and Core_Product_Name_EPM_ID__c IN  :ids order by Name');     
                        System.debug(' Productlist-->'+Productlist);
                        
                    }
                    
                    variants = new List<CustomSelectOptions>();
                   // variants.add(new CustomSelectOptions('Select Option','--Select--'));//Geetha
                    for(Product2 prod:Productlist)
                    {
                        variants.add(new CustomSelectOptions(prod.name,prod.name));
                    }
                    if(variants.size()>1){
                        blnShowVariant = true;
                    }
                    System.debug(' variants-->'+variants);
                    
                    return variants;
                }
            }
        }
        return null;
    }
    
    //This method is written for displaying product varints for NAC (No assigned contact cases) 
    //Added by sumukh for US107484 for Iteration - 13 , Release - 4.3
     @AuraEnabled
    Public static List<CustomSelectOptions> displayProductVariant_NAC(String selectedProductId){ 
        blnShowVariant_NAC = false;   
        isProductId = selectedProductId;
        system.debug('Inside NAC Block');   
        system.debug('selectedProductId' + selectedProductId);
        if(selectedProductId!=null && selectedProductId!=''){ 
            
            system.debug('Inside NAC Prod block');        
            supportedProdList=database.Query('select id, Name,Core_IPS_Is_Show_Variant__c,Core_Product__c,Core_Product_EPM_ID__c from Core_IPS_Supported_Product__c where id=:selectedProductId');         
            system.debug('supportedProdList' + supportedProdList);
            if(!supportedProdList.isEmpty() && supportedProdList.size()>0){
                
                if(supportedProdList[0].Core_IPS_Is_Show_Variant__c== true){
                    
                    //Query on FlatProductHierarchy
                    String strQuery = 'select id,Core_EPM_Hierarchy_Name__c, Core_L1_EPM_ID__c,Core_L1_EPM_Name__c,Core_L2_EPM_ID__c,Core_L2_EPM_Name__c,Core_Unique_ID__c from Core_Flat_Product_Hierarchy__c where Core_Unique_ID__c like \'%;'+supportedProdList[0].Core_Product_EPM_ID__c+';%\'' +'OR Core_Unique_ID__c like'+ '\'%;'+supportedProdList[0].Core_Product_EPM_ID__c+'\'';
                    System.debug(' strQuery-->'+strQuery);
                    flatIdsList= database.Query(strQuery);
                    System.debug(' flatIdsList-->'+flatIdsList);
                    System.debug(' flatIdsList size-->'+flatIdsList.size());
                    set<String> ids=new set<String>();                   
                    if(!flatIdsList.isEmpty() && flatIdsList.size()>0){
                        
                        for(Core_Flat_Product_Hierarchy__c fph :flatIdsList){
                            String data=fph.Core_Unique_ID__c;
                            
                            List<String> recorddata=data.split(';');
                            for(integer i=0;i<recorddata.size();i++){
                                if(recorddata[i]==supportedProdList[0].Core_Product_EPM_ID__c){
                                    if(i>0)
                                        System.debug('-->1Ading twice');
									ids.add(recorddata.get(i-1));
                                }
                            }  
                        }
                    }
                    ids.remove(supportedProdList[0].Core_Product_EPM_ID__c);
                    
                    List<Product2> Productlist = new List<Product2>();
                    String strIPS = 'IPS';
                    
                    //Query on Product for showing the product variant names based on EPM ID 
                    if(ids!=null && ids.size()>0){
                        Productlist = database.Query('select id, Name FROM Product2 where Core_Product_Org__c = :strIPS  and Core_Product_Name_EPM_ID__c IN  :ids order by Name');     
                    }
                    
                    variants = new List<CustomSelectOptions>();
                   // variants.add(new CustomSelectOptions('Select Options','--Select--'));
                    for(Product2 prod:Productlist)
                    {
                        variants.add(new CustomSelectOptions(prod.name,prod.name));
                    }
                    if(variants.size()>1){
                        blnShowVariant_NAC = true;
                    }
                    System.debug('variants Size-->'+variants.size());
                    System.debug('variants'+variants);
                    return variants; 
                    
                }
            }         
        }return null; 
    }          

     @AuraEnabled
    Public static List<CustomSelectOptions> getCategoryOptions(String supportedProductId){        
            List<CustomSelectOptions> categoryOptions=new List<CustomSelectOptions>();
            //categoryOptions.add(new SelectOption('','Select One'));
            //added for DE32940
            List<Core_IPS_Product_Issue_Category__c> lstCatgories = Core_IPS_CaseUtility.getCategories(supportedProductId);
            if(supportedProductId <> null && lstCatgories <> null && lstCatgories.size() > 0){
                for(Core_IPS_Product_Issue_Category__c a : lstCatgories){
                    if(a <> null && a.Core_Issue_Category_Name__r <> null && a.Core_Issue_Category_Name__r.Name <> null)
                        categoryOptions.add(new CustomSelectOptions(a.Core_Issue_Category_Name__r.Name,a.id));
                }
                //Core_Utility.doSort(categoryOptions, Core_Utility.FieldToSort.Label); 
                        
            }
        if(categoryOptions.size()>0){
         //   doSort(categoryOptions, Core_Utility.FieldToSort.Label,'Select Category');
            //categoryOptions.sort();
         //   displayCategories=true;
            subCategoryOptions=new List<CustomSelectOptions>();
            subCategoryOptions.add(new CustomSelectOptions('Select Category','Select Option'));
           // displaySubCategories=true;
        }else{
            //displayCategories=false;
        } 
        return categoryOptions;
   }
     @AuraEnabled
    public static List<CustomSelectOptions> getsubCategory_Options(String categorySelected){ 
        //List<SelectOption> subCategoryOptions = new List<SelectOption>();
        subCategoryOptions = new List<CustomSelectOptions>();
        if(categorySelected!=null && categorySelected!=''){
            //subCategoryOptions.add(new SelectOption('', 'Select SubCategory'));
            for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility.getSubCategories(categorySelected)){              
                if(a.Core_Issue_Sub_Category_Name__c!=null){
                subCategoryOptions.add(new CustomSelectOptions(a.Core_Issue_Sub_Category_Name__r.Name,a.id));                
                }
            }
           // doSort(subCategoryOptions,Core_Utility.FieldToSort.Label,'Select SubCategory');
            if(subCategoryOptions.size()>0){
                /*Core_Utility.doSort(subCategoryOptions, Core_Utility.FieldToSort.Value,'Select SubCategory');*/
                //displaySubCategories=true;
                }
            //else 
            //displaySubCategories=false;
        }
        return subCategoryOptions;
    }
      /***************************************************************************************************
    Method Name:  doSort
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 06 Jan 2016
    Function    : Returns None.
    Input Parameters: List of SelectOptions and Enum Variable
    Output Parameters: None
    Description: Sort the SelectOption List.
    Used in     : Anywhere we want to sort the SelectOption.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya            Jan/06/2015                Created
    ****************************************************************************************************/
  /*  public enum FieldToSort {
        Label, Value
    }
    @AuraEnabled
    public static void doSort(List<CustomSelectOptions> opts, FieldToSort sortField, String option) {
        
        Map<String, CustomSelectOptions> mapping = new Map<String, CustomSelectOptions>();
        // Suffix to avoid duplicate values like same labels or values are in inbound list 
        Integer suffix = 1;
        for (CustomSelectOptions opt : opts) {
            if (sortField!=null && sortField == FieldToSort.Label) {
                mapping.put(    // Done this cryptic to save scriptlines, if this loop executes 10000 times
                                // it would every script statement would add 1, so 3 would lead to 30000.
                             (opt.getLabel() + suffix++), // Key using Label + Suffix Counter  
                             opt);   
            } else {
                mapping.put(    
                             (opt.getValue() + suffix++), // Key using Label + Suffix Counter  
                             opt);   
            }
        }
        
        List<String> sortKeys = new List<String>();
        sortKeys.addAll(mapping.keySet());
        sortKeys.sort();
        // clear the original collection to rebuilt it
        opts.clear();
        if(option <> null && option.length() > 0)
            opts.add(new CustomSelectOptions('',option));
        for (String key : sortKeys) {
            opts.add(mapping.get(key));
        }
    } */

    //EDQ
//List<Core_IPS_EnvironmentDetailQuestion> envDetails

  


        @AuraEnabled
    public static List<Core_IPS_EnvironmentDetailQuestion> displayedqQuestions(String supportedProductId, String subCategoryid,Boolean isAgent){ 
     List<Core_IPS_Assigned_Environment_Variables__c> envVars = new List<Core_IPS_Assigned_Environment_Variables__c>();
                    //envVars = Core_IPS_CaseUtility.getEnvVariables(ast.core_supported_product__c,null,isAgent);
                    envVars = Core_IPS_Questions_Utility.getEnvDetailQuestions(supportedProductId,subCategoryid,isAgent);
                    // added  by amritesh 12/18/2017 - US8534
                    //Added By Manoj as part of as part of US60820 IPS Evolve
                     List<Id> envQuestnIds = new List<Id>();
                    subCatenvDetList = new List<Core_IPS_EnvironmentDetailQuestion>();
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
                 System.debug('anish--envDetails'+envDetails);
                    
                    return envDetails;
}

public static List<Core_IPS_EnvironmentDetailQuestion> constructWrapper(List<Core_IPS_Assigned_Environment_Variables__c> envVars){
      System.debug('inside constructwrapper');
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
                List<CustomSelectOptions> selectOptionsList = new List<CustomSelectOptions>();
                //SelectOptionsList.add(new CustomSelectOptions('Select Option',''));
                if(mapQues2AnswerMap.containsKey(en.Core_IPS_Question__c)) {
                    Map<Id,String> mapAns = mapQues2AnswerMap.get(en.Core_IPS_Question__c);
                    for(Id ansId : mapAns.keySet()) {
                        selectOptionsList.add(new CustomSelectOptions(mapAns.get(ansId),ansId));
                    }
                } 
                //if(en.Core_Environment_Variable__r.Core_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim())
                if(en.Core_IPS_Question__r.Core_IPS_Datatype__c.trim()== Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim()){ // added  by amritesh 12/18/2017 - US8534
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Picklist').value__c.trim();
                } else{
                    det.type=Core_IPS_Labels__c.getValues('Core_IPS_Multi_Select').value__c.trim();
                }
                det.lwcplaceholder = selectOptionsList;
               // det.pplaceholder=selectOptionsList;
              //  det.selectedValue=selectOptionsList.get(0).getValue();
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
    
    public static void createQuestionHierachy(Id quesId, Map<Id,Core_IPS_EnvironmentDetailQuestion> mapEnvDetail, Map<Id,Set<Id>> mapQuesParentId2DependentId) {
            System.debug('inside questionhirerachy');

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

    public static List<CustomSelectOptions> getplatform_Options(List<Id> idList){ 
      List<CustomSelectOptions> platformOptions = new List<CustomSelectOptions>();  
     // platformOptions.add(new CustomSelectOptions('--Select--', ''));//Geetha
      List<Asset> astList = new List<Asset>();
      List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
      astList = [select Id,core_supported_product__c from Asset where Id in:idList];  
      suppProdList = [select Id from Core_IPS_Supported_Product__c where Id in:idList];      
      List<Id> supportedProductIdList = new List<Id>();
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
            Map<String,Set<String>> platformByProduct=Core_IPS_Caseutility.getPlatform(supportedProductIdList);
            if(platformByProduct!=null && platformByProduct.size()>0){
                  if(astList <> null && astList.size() > 0){
                      for(Asset asset:astList){
                          if(asset <> null && asset.core_supported_product__c <> null && platformByProduct.get(asset.core_supported_product__c) <> null){
                              for(String pltfrmString:platformByProduct.get(asset.core_supported_product__c)){
                                  system.debug('inside for '+pltfrmString);
                                  if(pltfrmString != null && pltfrmString != ''){
                                      platformOptions.add(new CustomSelectOptions(pltfrmString, pltfrmString));
                                      system.debug('inside for and if'+platformOptions);
                                  }
                               }
                            }
                        }        
                   }
                   if(suppProdList <> null && suppProdList.size() > 0){
                      for(Core_IPS_Supported_Product__c suppProdObj:suppProdList){
                          if(platformByProduct.get(suppProdObj.Id) <> null){
                              for(String pltfrmString:platformByProduct.get(suppProdObj.Id)){
                                  system.debug('inside for '+pltfrmString);
                                  if(pltfrmString != null && pltfrmString != ''){
                                      platformOptions.add(new CustomSelectOptions(pltfrmString, pltfrmString));
                                      system.debug('inside for and if'+platformOptions);
                                  }
                               }
                            }
                      }        
                   }
                   system.debug('#####platformOptions before sorting#####'+platformOptions);
                   if(platformOptions <> null && platformOptions.size() > 0){
                       platformOptions.sort();
                   }
                   system.debug('#####platformOptions after sorting#####'+platformOptions); 
            }          
        }    
        return platformOptions;
    }  

   
     public static List<Core_IPS_EnvironmentDetailQuestion> renderDependentQuestionsLWC(String selectedProductId, List<Core_IPS_EnvironmentDetailQuestion> childquestionsrecords ) {
      //  if(childQuestions==null || childQuestions.size()==0) return;
        System.debug('childquestionsrecords>>'+childquestionsrecords);
        System.debug('envDetails>>>'+isProductId);
         System.debug('selectedproductId>>'+selectedProductId);
         List<Core_IPS_EnvironmentDetailQuestion> childdata = new List<Core_IPS_EnvironmentDetailQuestion>();
            //showDependentSection = true;            
           // if(childquestionsrecords==null || childquestionsrecords.size()==0){

           // }
        if(String.isBlank(selectedProductId)) {
            //showDependentSection = false;
            for(Core_IPS_EnvironmentDetailQuestion objChildQues : childquestionsrecords) {
                objChildQues.isVisible = false;
            }
           } else {
          
                //List<Id> lstQuesId = new List<Id>();
                //for(Core_IPS_EnvironmentDetailQuestion objChildQues : childQuestions) {
                    //lstQuesId.add(objChildQues.questionId);
                //}
                
                Map<Id,Map<Id,Core_IPS_Answer__c>> mapQues2AnswerMap = new Map<Id,Map<Id,Core_IPS_Answer__c>>();
                for(Core_IPS_Answer__c objAns : Core_IPS_Questions_Utility.getCoreAnswersByParentAnswer(selectedProductId)) {
                    if(!mapQues2AnswerMap.containsKey(objAns.Core_IPS_Question__c)) {
                        mapQues2AnswerMap.put(objAns.Core_IPS_Question__c, new Map<Id,Core_IPS_Answer__c>());
                    }
                    mapQues2AnswerMap.get(objAns.Core_IPS_Question__c).put(objAns.Id, objAns);
                }
                for(Core_IPS_EnvironmentDetailQuestion objChildQues : childquestionsrecords) {
                    System.debug('objChildQues88'+childquestionsrecords);
                    if(objChildQues.type==Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Picklist') || objChildQues.type==Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Multi_Select'))
                    {
                        //Modified By Karthick - US101342 - R4.2
                       // objChildQues.pplaceholder.clear();
                      // objChildQues.lwcplaceholder.clear();
                        objChildQues.lwcplaceholder.add(new CustomSelectOptions('Select Option',''));
                         System.debug('mapAns>>');
                           System.debug('mapmapQues2AnswerMapAns>>'+mapQues2AnswerMap);
                             System.debug('mapAns>>0'+objChildQues.questionId);
                        if(mapQues2AnswerMap.containsKey(objChildQues.questionId)) {
                              System.debug('mapAns>>2');
                            Map<Id,Core_IPS_Answer__c> mapAns = mapQues2AnswerMap.get(objChildQues.questionId);
                             System.debug('mapAns>>'+mapAns);
                            for(Id ansId : mapAns.keySet()) {
                                System.debug('ansId>>'+ansId);
                                String strPAnsId = String.valueOf(mapAns.get(ansId).Core_IPS_Parent_Answer__c).left(15);
                                if(strPAnsId==selectedProductId.left(15)) {
                                    System.debug('inside>>'+strPAnsId);
                                    System.debug('inside>>2'+selectedProductId);
                                    
                                
                                
                                    objChildQues.lwcplaceholder.add(new CustomSelectOptions( mapAns.get(ansId).Core_IPS_Answer__c,ansId));
                                }
                            }
                        }
                        objChildQues.isVisible=true;
                        
                        if(objChildQues.lwcplaceholder==null) { objChildQues.isVisible=false; }
                        else if(objChildQues.lwcplaceholder.size()==1) { objChildQues.isVisible=false; }
                    } else{
                        objChildQues.isVisible=true;
                    }
                  
                    System.debug(objChildQues.label + ' - IsVisible : ' + objChildQues.isVisible);
                      childdata.add(objChildQues);
                }
            }
        
       // old_selectedValue = selectedValue;
        return childdata;
    }
    
public static List<Core_IPS_EnvironmentDetailQuestion> basedonSelectedandQuestionValue(String selectedProductId, String childquestionsrecords ) {
      List<Core_IPS_EnvironmentDetailQuestion> childdata2 = new List<Core_IPS_EnvironmentDetailQuestion>();
      List<Core_IPS_EnvironmentDetailQuestion> wrapperList = new List<Core_IPS_EnvironmentDetailQuestion>();
        System.debug('envDetails>>>'+childquestionsrecords);

      String strQuery = 'SELECT Id, Core_IPS_Parent_Question__c,core_IPS_Question__c,Core_IPS_Datatype__c,Core_IPS_Required__c FROM Core_IPS_Question__c WHERE  Core_IPS_Parent_Question__c =  '+childquestionsrecords+' and Core_IPS_Status__c = \'Active\' order by Core_IPS_Order_No__c';
                          System.debug('strQuery'+strQuery);
        List<Core_IPS_Question__c>  listCoreAttrbutr = Database.query(strQuery);
        System.debug('strQuery'+listCoreAttrbutr);
    List<CustomSelectOptions> optiod = new List<CustomSelectOptions>();
     optiod.add(new CustomSelectOptions('Select Option',''));
        for(Core_IPS_Question__c c: listCoreAttrbutr){
            
         Core_IPS_EnvironmentDetailQuestion det = new Core_IPS_EnvironmentDetailQuestion();
            //det.label=en.Core_Environment_Variable__r.name;            
            det.label = c.Core_IPS_Question__c;
            det.parentQuestionID=c.Core_IPS_Parent_Question__c;// added by amritesh 12/18/2017 - US85344 
           det.questionId = c.Id; // added by amritesh 12/18/2017 - US85344 
           det.required = c.Core_IPS_Required__c;
            det.type= c.Core_IPS_Datatype__c;
           //det.IsAgentOnly = en.Core_Agent_Only__c;
           det.lwcplaceholder = optiod;
           det.isVisible = false;
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
                        System.debug('objChildQues.lwcplaceholder>'+objChildQues.lwcplaceholder);
                        lst.add(new CustomSelectOptions('Selects Option',''));
                       // objChildQues.lwcplaceholder.add(new CustomSelectOptions('Select Option','2'));
                        if(mapQues2AnswerMap.containsKey(objChildQues.questionId)) {
                            System.debug('objChildQues.questionId'+objChildQues.questionId);
                            Map<Id,Core_IPS_Answer__c> mapAns = mapQues2AnswerMap.get(objChildQues.questionId);
                            for(Id ansId : mapAns.keySet()) {
                                String strPAnsId = String.valueOf(mapAns.get(ansId).Core_IPS_Parent_Answer__c).left(15);
                                 System.debug('strPAnsId'+strPAnsId);
                                  System.debug('selectedProductId.left(15)'+selectedProductId.left(15));
                                if(strPAnsId==selectedProductId.left(15)) {
                                    System.debug('Add ansert');
                                    lst.add(new CustomSelectOptions(mapAns.get(ansId).Core_IPS_Answer__c,ansId));
                                  
                                    //objChildQues.lwcplaceholder.add(new CustomSelectOptions(mapAns.get(ansId).Core_IPS_Answer__c,ansId));
                                 System.debug('objChildQues.lwcplaceholder2'+lst);
                                }
                                
                            }
                             objChildQues.lwcplaceholder= lst;
                             System.debug('size>>>'+objChildQues.lwcplaceholder.size());
                            
                        objChildQues.isVisible=true;
                        }
                         System.debug('out of mapping');
                         
                        if(objChildQues.lwcplaceholder==null) 
                        { 
                            objChildQues.isVisible=false; 
                        }
                        else if(objChildQues.lwcplaceholder.size() == 1)
                         { 
                             System.debug('an');
                            objChildQues.isVisible=false; 
                             }
                    } else{
                        objChildQues.isVisible=true;
                    }
                  
                    System.debug(objChildQues.label + ' - IsVisible : ' + objChildQues.isVisible);
                      childdata2.add(objChildQues);
                }

         return childdata2;
       
    }
    @AuraEnabled
    public static String saveCaseDetails(Boolean customerVisible, String caseType, String contactId, String caseProject, String productId,String caseSource,String caseSeverity,String caseSubject,String caseDesc,String caseCategory,String caseSubCategory, String caseSupportProject,String caseEDQdata){
   		System.debug('caseEDQdata>>>'+caseEDQdata);
        //List<String>   lsListString = JSON.serialize(caseEDQdata);
    //List<String> ani =JSON.deserialize(caseEDQdata,  List<String>.class);
          //List<String> gh = JSON.serialize(caseEDQdata);
        //  List<String> lstAlpha = caseEDQdata.split('},');
           // LWCResponseEDQ.parse(caseEDQdata);
          String lsListString = JSON.serialize(caseEDQdata);
           //System.debug('ani'+LWCResponseEDQ.parse(caseEDQdata));
             
             
               
           List<Core_IPS_Response__c> getResponse = new List<Core_IPS_Response__c>();
            classTwoWrap = LWCResponseEDQ.parse(caseEDQdata);
            System.debug('wrrr'+classTwoWrap);
          // for(String r :lstAlpha){
           //    System.debug('r>>>'+r);
               //System.debug('r>>>'+r.edq.vvalue);
         //  }
           cs = new Case();
        try{    
            if(caseCategory!=null && caseCategory!=''){
                cs.Core_Case_Issue_Category__c=caseCategory;
                System.debug('dsfdfs'+caseCategory);
            }
            else
            {
                cs.Core_Case_Issue_Category__c =null;
            }
            
            if(caseSubCategory!=null && caseSubCategory!=''){
                cs.Core_Case_Issue_Sub_Category__c=caseSubCategory;
            }
            else
            {
               cs.Core_Case_Issue_Sub_Category__c =null;
            }
            
            cs.Core_Platform_Name__c = null;
           if(productId!=null && productId!=''){
                cs.assetId = productId;
            }
             system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>' + caseSupportProject);
            if(caseSupportProject!=null && caseSupportProject!=''){
                //Ashutosh-Us106566 - commenting here the code as we are already finding out that the selected id is asset or supported product
                //if it is asset then we are getting supp product from asset and adding that on case supp product and if it is just selected product then we 
                //are just adding them to case
                //instead code is written in onLookupChange method to poplulate supported product for NAC
                
                
                //cs.Core_IPS_Supported_Product__c = selectedSAProductId;               
            }
                        
            //private project check - US191343
            Boolean isPrivateProject = false;
            if(caseProject!=null &&  caseProject!='' && caseProject!='NA'){
                cs.Core_IPS_Project_Case__c = caseProject;
               isPrivateProject = [SELECT Core_IPS_Private__c FROM Core_IPS_Project__c WHERE Id=:caseProject LIMIT 1].Core_IPS_Private__c;
            }
            else
            {
               cs.Core_IPS_Project_Case__c =null;               
            }
            //system.debug(cs.Core_IPS_Project_Case__c + 'vaibhav---' +selectedProjId);
            system.debug('((((((((((((((((((' + contactId);
            //String contactId =selectedContactId;                  
            if(contactId!=null && contactId!=''){
                //Added Core_IPS_Intel_Support_Owner__c in soql by Karthick - US92632 - Release 4 - I8
                Contact con = [select id,account.ownerId,accountid,Core_IPS_Intel_Support_Owner__c,Core_MINDS__c,Core_Country_Region__c from contact where id ='0033F000002T9khQAC']; 
                //Private project check - US191343
                if(isPrivateProject) {
                    cs.contactId = null;
                    cs.accountid = null;
                    cs.Core_IPS_Supported_Contact__c = '0033F000002T9khQAC';
                } else {
                    cs.contactId = '0033F000002T9khQAC';
                    cs.accountid = con.accountid ;
                }
                //Added by Karthick - US92632 - Release 4 - I8 - ISO Assignment.
                if(con.account.ownerId!=null && string.isBlank(con.Core_IPS_Intel_Support_Owner__c)){
                    cs.Core_Intel_Sup_Owner__c = con.account.ownerId;
                }  
                
                countrySelected = 'Iran';
                if(!String.isBlank(countrySelected)){
                    if(con.Core_Country_Region__c==null || con.Core_Country_Region__c==''){
                     con.Core_Country_Region__c= countrySelected;
                        Core_IPS_AdminUtility.updateContact(con);
                    }
                }
            }   
            // start added for US253173
               /* if(mindsOption=='Yes'){
                   cs.Core_IPS_Minds__c= true;
                }*/
            if(!String.isBlank(countrySelected)){
                cs.Core_IPS_Country_Region__c= 'Iran';
            }
            //end
            /*Added for DE40678
            if(mindsOption=='No'){
                cs.Core_IPS_Minds__c= false;
            }*/
            //end for DE40678
            //User u = [select Id, username,userType,contactId from User where Id = :UserInfo.getUserId()];
            //cs.contactId = u.contactId;
            //System.debug('@@@@##@@@@---------------------'+showGECFields);
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
            cs.Core_Issue_Description__c = caseDesc;
            if(cs.Core_Issue_Description__c != null)
            {                   
                string  strDescValue =  Core_Utility.replaceSpecialChar(cs.Core_Issue_Description__c);
                
                cs.Description = Core_Utility.replaceHtmlTags(strDescValue);
            }   
            /*if(showGECFields==false && Mode!='edit' && mode!='copy') { // US127333
                cs.status='New';                
                if(ApexPages.currentPage().getParameters().get('rType') !=null && ApexPages.currentPage().getParameters().get('rType') == Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId())
                {
                    cs.Core_IPS_Self_Assigned__c =true; 
                }
                else
                {
                    cs.Core_IPS_Self_Assigned__c = false;
                }
            }*/
            
            // Added by sumukh for US69871
            
            /*if(cs.id==null && (GECAnswer1 == 'No' && GECAnswer2 == 'NO') && cs.ContactId!=null  ){
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
            }*/
           // cs.Core_IPS_Partner_Sup_Owner__c = selectedPSOId;
           // cs.Core_Partner_Supported_Account__c = selectedPSA;
            //End here
            
            //added by amritesh - DE38937 - start
            /*Integer countEnvDetails = 0;
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
            
            //Added by Karthick - US104565 - 10-05-2018 - I11*/
            if(String.isBlank(cs.Origin)){
                cs.Origin = 'Web';
            }
            // US127333 - Start
           /* if(mode=='copy') { 
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
            }*/
            // US127333 - end 
            cs.Status = 'New';
            cs.Core_Sub_Status__c = null; 
            cs.Subject = caseSubject;
            cs.Core_Severity__c = caseSeverity;
            cs.Core_IPS_Issue_source__c =caseSource;
            cs.Core_CaseType__c = caseType;
            cs.RecordTypeId = '012o0000000TPVhAAO';
            
            cs.Core_IPS_Customer_Visible__c = customerVisible;
           insert cs;
            //addGECRecords();  //Commented for US253172
            
            //addEnvDetails();
          /*  captureEnvDetails(); // added  by amritesh 12/18/2017 - US85344
            
            if(mode=='copy') { // US127333                
                copyInterestedParties();
            }*/
             //Core_IPS_Case__c
              //classTwoWrap = LWCResponseEDQ.parse(caseEDQdata);
             //  System.debug('ani2'+classTwoWrap);
            // List<LWCResponseEDQ> lsd = new  List<LWCResponseEDQ>();
            // System.debug('nolist'+LWCResponseEDQ.parse(caseEDQdata));
          for(LWCResponseEDQ c: classTwoWrap){
               Core_IPS_Response__c newres = new Core_IPS_Response__c();
                //System.debug('ani2'+c.edq);
                //System.debug('ani2'+c.edq[0].ttype);
               
          
               newres.Core_IPS_Question_Master__c = c.edq[0].qquestion;
             
               if(c.edq[0].ttype == 'Multiselect Picklist' || c.edq[0].ttype == 'Picklist'){
                   if(c.edq[0].vvalue == null || c.edq[0].vvalue == '' || String.isBlank(c.edq[0].vvalue) ) {
                       System.debug('oppp'+c.edq[0].vvalue);
                       
                   }else{
                       if(c.edq[0].ttype == 'Multiselect Picklist'){
                         //  for(Integer i = 0; i<c.edq[0].vvalue.length();i++){
                               //String fg =''+c.edq[0].vvalue+',';
                               System.debug('fg'+ c.edq[0].vvalue);
                               List<String> lstStringmul = c.edq[0].vvalue.split(',');
                               System.debug('fg1'+ lstStringmul);
                                for(String vb : lstStringmul){
                                    Core_IPS_Response__c newresaddmulti = new Core_IPS_Response__c();
                                    newresaddmulti.Core_IPS_Question_Master__c = c.edq[0].qquestion;
                                    newresaddmulti.Core_IPS_Answer_Master__c = vb;
                                    newresaddmulti.Core_IPS_Case__c = cs.Id;
                                    getResponse.add(newresaddmulti);
                                    System.debug('fg3'+ getResponse);
                                }
                                 
                              // newres.Core_IPS_Answer_Master__c = c.edq[0].vvalue;
                          // }
                       }else{
                           newres.Core_IPS_Answer_Master__c = c.edq[0].vvalue;
                       }
                        
                   }
                  
               }
              
               if(c.edq[0].ttype == 'Text Area' || c.edq[0].ttype == 'Text' ){
                     if(c.edq[0].vvalue == null || c.edq[0].vvalue == '' || String.isBlank(c.edq[0].vvalue)) {
                      System.debug('oppp1'+c.edq[0].vvalue);
                      }else{
                          newres.Core_IPS_Answer__c = c.edq[0].vvalue;
                  
                     }
               }
               newres.Core_IPS_Case__c = cs.Id;
              getResponse.add(newres);

           }
           
           System.debug('anish'+getResponse);
           insert getResponse;
           //List<String> vb = ( List<String>) JSON.deserialize(caseEDQdata, List<String>.class);
             System.debug('vb>>');
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
        return cs.id;
    }
    

//for interestedparty
 @AuraEnabled
    public static List<User> getUserDetailsBasedOnSearch(String searchValueUser){
   		System.debug('searchValueUser>>>'+searchValueUser);
     List<Profile> ProfileLst = new List<Profile>();
      Set<String> ProfileID = new Set<String>();
   List<String> interestedPartiesList = new List<String>();
   SET<ID> relatedUserIDs = new SET<ID>();
      interestedPartiesList = System.Label.Interested_Parties_Internal_Agent.split(';');
            
            //Check if Loggedin User is IPS Agent and allow to search all Sales Reps irrespective of Case Account Team  -- 4/18/2017 Manoj Kumar
            for(String str : Label.Interested_Parties_Internal_Agent_ProfileIds.split(',')){
                if(str == string.valueof(UserInfo.getProfileId())){
                    System.debug('--IPS Agent User --');
                    interestedPartiesList.addall(new List<String>(Label.Core_IPS_FAE_ProfileName.split(';')));
                    break;
                }
            }
           ProfileLst = [Select ID, Name from Profile Where (Name =: System.Label.Interested_Parties_Internal_Admin OR Name in: interestedPartiesList) AND (NOT(ID IN : relatedUserIDs))];
            
            for(Profile P : ProfileLst){
                ProfileID.add(P.id);
            }
        List<User> UserList = new List<User>();

         List<Id> atmid = new List<Id>();
    
            case CaseObj = [Select id, AccountID,account.ownerid,ownerid, Core_IPS_Project_Case__c from Case where ID =: '5003F000000fg8I'];
     Set<Id> SetAccountID = new Set<Id>();            
            SetAccountID.add(CaseObj.accountid);
            System.debug('--SetAccountID--'+SetAccountID);
            for(Set<id> SetID : Core_IPS_Helper_Utility.getFAEsByAccount(SetAccountID).values())
            {
                atmid.addall(SetID);
                
                //Checking if Loggedin User is SalesRep and part of Case Account Team or not-- 4/18/2017 Manoj
                if(SetID.contains(UserInfo.getUserId())){
                    System.debug('--Loggedin User is part of Case Account Team --');
                    for(String profId : label.Core_IPS_Sales_Rep_ProfileIds.split(',')){
                        /*
                         * qualifying profiles
                            Sales Manager
                            Sales Ops
                            Sales Rep-BB
                            Sales Rep-CW

                        */
                    if(UserInfo.getProfileId() == profId ){
                        System.debug('--Loggedin User is SalesRep and part of Case Account Team --');
                           ProfileID.addall(new List<String>(label.Core_IPS_Sales_Rep_ProfileIds.split(',')));
                           break;
                        }
                    }
                } // END  -- Manoj Kumar
            }
            System.debug('--ProfileID --'+ProfileID);
            atmid.add(CaseObj.account.ownerid); 
            atmid.add(CaseObj.ownerid); 
            
             String searchableString = searchValueUser + '%';
            
            String sQuery;
            sQuery = 'SELECT Id, Name, FirstName, LastName, Email ' + 
                     'FROM User ' + 
                     'WHERE (ProfileID IN :ProfileID AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN :relatedUserIDs)) AND (IsActive = true)) OR (ID in :atmid AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN : relatedUserIDs)) AND (IsActive = true)) ' + 
                     'ORDER BY Id desc Limit '+System.Label.Core_IPS_Interested_Party_Limit;
                     System.debug('sQuery'+sQuery);
            UserList = Database.query(sQuery);
            return UserList;
    }
    @AuraEnabled
    public static String saveInternalInterestedParty(String userID, String caseId, String contactID ){
         List<Core_IPS_Case_Interested_Party__c> interestedPartiesToBeCreated = new List<Core_IPS_Case_Interested_Party__c>();
            String existcheck = '';
          
                if(userID == null || userID == ''  ){
                     Core_IPS_Case_Interested_Party__c newRecord = new Core_IPS_Case_Interested_Party__c();
                        newRecord.Contact__c = contactID; 
                        newRecord.Case__c = caseId;
                        newRecord.Type__c = 'External';
                        newRecord.Active__c = true;
                        interestedPartiesToBeCreated.add(newRecord);

                  List<Core_IPS_Case_Interested_Party__c>     checkexistingsingle   = [Select Id, Contact__c from Core_IPS_Case_Interested_Party__c where Contact__c = :contactID and Case__c =: caseId ];
                 System.debug('checkexistingsingle'+checkexistingsingle);
                 if(checkexistingsingle.size() > 0 ){
                    existcheck = 'existingcontact';
                 }else{
                     if(interestedPartiesToBeCreated.size() > 0){
                             insert interestedPartiesToBeCreated;
                        existcheck = 'newcontact';
                         }
                  
                 }
                }
                if(contactID == null || contactID == ''){
                
                 Core_IPS_Case_Interested_Party__c newRecord = new Core_IPS_Case_Interested_Party__c();
                        newRecord.User__c = userID; 
                        newRecord.Case__c = caseId;
                        newRecord.Type__c = 'Internal';
                        newRecord.Active__c = true;
                        interestedPartiesToBeCreated.add(newRecord);

                  List<Core_IPS_Case_Interested_Party__c>     checkexistingsingle   = [Select Id, User__c from Core_IPS_Case_Interested_Party__c where User__c = :userID and Case__c =: caseId ];
                 System.debug('checkexistingsingle'+checkexistingsingle);
                 if(checkexistingsingle.size() > 0 ){
                    existcheck = 'existinguser';
                 }else{
                     if(interestedPartiesToBeCreated.size() > 0){
                             insert interestedPartiesToBeCreated;
                        existcheck = 'newuser';
                         }
                  
                 }
                 }
                    
                      

        Return existcheck;
     }
     

     

}