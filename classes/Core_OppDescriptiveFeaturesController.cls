/************************************************************************************************************************
Apex Class Name:  Core_OpportunityDescriptiveFeature
Version     : 1.0 
Created Date: 09 OCT 2014
Function    : 
Modification Log :

* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/09/2014              Original Version
* Laxmana Lenka             05/04/2018              US103701: Introduced BU filter logic to filter the feature based on BU
***********************************************************************************************************************/
public with sharing class Core_OppDescriptiveFeaturesController{

    // Variable to hold Opportunity Record   
    @TestVisible private Opportunity sObjOpp;
    
    // Variable to hold Opportunity features Record
    private final Core_Opportunity_Features__c sObjOppFeature;
    
    // Variable to hold Opportunity Record Id
    public String sOppId;    

     //TWC3123-4019 Redesign Descriptive FeatureVariable to hold Opportunity Product Id
     public String sOppProdId;

    // Variable to hold Opportunity Product Record  ////TWC3123-4019 Redesign Descriptive Feature 
    private OpportunityLineItem sObjOppProd;

    private String Type ;  ////TWC3123-4019 Redesign Descriptive Feature
    
    //Added for Consumer Sales System
    public Core_Opportunity_Features__c cSale {get; set;}
    public String consumerSales;
    public String consumerSales1{get;set;}
    public String projectCodeName{get;set;}
    public String processNode{get;set;}
    public String execSponsorContact{get;set;}
    public String nreUSD{get;set;}
    public String projectScheduleRFx{get;set;}
    public String projectScheduleTRKickOff{get;set;}
    public String projectScheduleTapeInOut{get;set;}
    public String projectScheduleEngSample{get;set;}
    public String projectSchedulePRQ{get;set;}
    public String customSiliconSegment{get;set;}
    public String customSiliconApplication{get;set;}
    public String CEGContact{get;set;}
    public String CEGComments{get;set;}
    public List<String> allTextFeatureTypes = new List<String> {
        'Consumer Sales system',
        'Project Code Name',
        'Process Node',
        'Exec Sponsor Contact',
        'NRE $',
        'Project Schedule: RFx',
        'Project Schedule: TR Kick off',
        'Project Schedule: Tape In/Out',
        'Project Schedule: Engineering Sample',
        'Project Schedule: PRQ',
        'Custom Silicon Segment',
        'Custom Silicon Application',
        'CEG Contact','CEG Comments'
    };
    // Variable to Map String to List of SelectOption 
    public Map < String, List < SelectOption >> mapStringToLstOption = new Map < String, List < SelectOption >> {};
    
    // Variable to Map String to List of SelectOption
    public Map < String, List < SelectOption >> mapSelectStringToLstOption = new Map < String, List < SelectOption >> {};
    
    // Variable to Map String to List of SelectOption
    public Map < String, List < SelectOption >> mapPlatformStringToLstOption = new Map < String, List < SelectOption >> {};
    
    // Variable to hold List of SelectOption
    public List < SelectOption > lstString = new List < SelectOption > {};
    
    // Variable to String to Feature Type
    public Map < String, String > mapStringType = new Map < String, String > {};
    
    // Variables with Feature Type
    public List < String > lstStringType = new List < String > {};
    
    // Variable to hold List of Header Type
    public List < String > lstFeHeaderType = new List < String > {};
        
    public Boolean showPage {get; set;} //6183
        
    //START -US103701 Map and select option declared for BU 
    public String PreSelectedBU;
    public Map < String, String> mapPlatformBUString = new Map < String, String> {};
    public Map<String, String> mapfeatureBULabelValue = new Map<String, String>();
    public Map<String, String> mapfeatureBUValueLabel = new Map<String, String>();
    public List<SelectOption> platformBULst {get;set;}
    public String selectedPlatformBU{get;set;}
    public String selectedPlatformBULabel{get;set;}
    
    public List < SelectListWrapper > lstPlatformBUSelectListWrapper {
            get;
            set;
    }
    //END -US103701 Map and selectoption declared for BU 
    // Variable to Map String to Boolean
    public Map < String, Boolean > mapStringToBool {
        get;
        set;
    }
    
    // String to hold the platform value
    public String sPlatform {
        get;
        set;
    }
    
    // String to hold the opportunity Name
    public String sOppName {
        get;
        set;
    }

    public string ProdPlatform;
    
    // Map the selected value to the feature Type
    public Map < String, String > mapSelectedValueToFeatureType {
        get;
        set;
    }
    
    // Map the selected name to the feature Type
    public Map < String, String > mapSelectedNameToFeatureType {
        get;
        set;
    }
    
    // Variable to hold the list of Wrapper records
    public List < SelectListWrapper > lstSelectListWrapper {
        get;
        set;
    }
    
    // // Variable to hold the list of filtered Wrapper records
    public List < SelectListWrapper > lstPlatformSelectListWrapper {
        get;
        set;
    }
    
    // Getter Setter methods for sPlatform String
    public String getsPlatform() {
        return sPlatform;
    }
    public void setsPlatform(String sPlatform) {
        this.sPlatform = sPlatform;
    }


    /*
     * Method name  : Core_OpportunityDescriptiveFeature
     * Description  : The extension constructor initializes the private member variable sObjOppFeature by using the getRecord method from the standard controller
     * Return Type  : NA
     * Parameter    : ApexPages.StandardController
     */
    public Core_OppDescriptiveFeaturesController(ApexPages.StandardController stdController) {
      
        //Initialize the variables for usage        
        lstSelectListWrapper = new List < SelectListWrapper > ();        
        lstPlatformSelectListWrapper = new List < SelectListWrapper > ();
        lstPlatformBUSelectListWrapper = new List < SelectListWrapper > ();    
        Core_Opportunity_Features__c OppFeature ;
        Core_Opportunity_Features__c OppFeatureOnOpp ;
        List<Core_Opportunity_Features__c> Oppfeaturelst= new List<Core_Opportunity_Features__c>();
        List<Opportunity> Opplst= new List<Opportunity>();
        showPage = !isBuExeOrProdMgr();//6183 
        //Add the Parent field using the addfields. Escape this code for the test methods to avoid error
        if (!Test.isRunningTest())
            stdController.addFields(new list < String > {
                'Core_Opportunity__c','Opportunity_Product__c'
            });
        
        //try {
            
            //Get the Opportunity ID from the URL, this in case when the new list button is opened
        
           if (ApexPages.currentPage().getParameters().get('sOppProdid') != NULL)////TWC3123-4019 Redesign Descriptive Feature
            {
                sOppProdId = ApexPages.currentPage().getParameters().get('sOppProdid'); 
            	
            	sOppId = [select OpportunityId from OpportunityLineItem where Id =:sOppProdId limit 1].OpportunityId;
                
                this.Type='Product';
            }
            else{
                if (ApexPages.currentPage().getParameters().get(System.label.Core_Opportunity_ID) != NULL)////TWC3123-4019 Redesign Descriptive Feature
                sOppId = ApexPages.currentPage().getParameters().get(System.label.Core_Opportunity_ID);
                this.Type='Opportunity';
           }


            // Get the descriptive feature record from the standard controller
            this.sObjOppFeature = (Core_Opportunity_Features__c) stdController.getRecord();
            
            //START - US103701, BU field is added to below query  
            // Get the Opportunity record from the Opportunity ID obtained
            if (sOppId != NULL || sObjOppFeature.Core_Opportunity__c != NULL)
                sObjOpp = [select Id, Name, Core_Intel_Platform__c, (select   
                    Core_Feature_Set__r.Core_Feature__r.Core_Feature_Type__c, Core_Opportunity__c,Opportunity_Product__c,  ////TWC3123-4019 Redesign Descriptive Feature
                    Core_Feature_Name__c, Core_Feature_Type__c, Core_Feature_Set__r.Core_Feature__r.Core_Feature_Value__c,Core_Platform_BU__c,
                    Core_Feature_Set__r.Core_Feature__r.Core_Multi_Select__c,Core_Multi_Select__c from Opportunity_Features__r),Core_Channel_Opportunity_Ind__c  from Opportunity  //TWC3123-4780
                    where Id = : sOppId or Id = : sObjOppFeature.Core_Opportunity__c];
            
            if (sOppProdid != NULL)
                    sObjOppProd = [select id,Product2Id from OpportunityLineItem where Id = : sOppProdid ];   //////TWC3123-4019 Redesign Descriptive Feature
                   
                   if(sObjOppProd!=NULL)
                    ProdPlatform=[select Core_Platform_Name__c from product2 where Id = : sObjOppProd.Product2Id].Core_Platform_Name__c;   //ProdPlatform
                    
			List<Schema.PicklistEntry> picklistEntries = Schema.SObjectType.Core_Feature__c.fields.Core_Feature_BU__c.getPicklistValues();
        	for(Schema.PicklistEntry ple :picklistEntries){
            	mapfeatureBULabelValue.put(ple.getLabel(), ple.getValue());
                mapfeatureBUValueLabel.put(ple.getValue(),ple.getLabel());
            } 
            //Set the BU value  default to Opportunity feature record while edited.
            if(this.sObjOppFeature.Id != null){
                	
                	
                    OppFeature = [SELECT Id,Core_Platform_BU__c FROM Core_Opportunity_Features__c where Id=:sObjOppFeature.Id];
                    selectedPlatformBU=mapfeatureBULabelValue.get(OppFeature.Core_Platform_BU__c);
                	selectedPlatformBULabel = OppFeature.Core_Platform_BU__c;
                	
                    //Added for Consumer Sales System
                    //this.cSale =  [Select id,Core_Platform_BU__c, Core_Consumer_Sales_system__c from Core_Opportunity_Features__c where id=:this.sObjOppFeature.Id AND Core_Platform_BU__c =:selectedPlatformBU];
                    
                    //consumerSales = this.cSale.Core_Consumer_Sales_system__c;
            }
            
            //END - US103701
            
             if(sOppId !=null){
                /*
                 Oppfeaturelst = [SELECT Id,Core_Platform_BU__c,Core_Consumer_Sales_system__c,Core_Feature_Name__c,Core_Feature_Type__c FROM Core_Opportunity_Features__c where Core_Opportunity__c =: sOppId AND Core_Feature_Type__c='Consumer Sales system' order by createddate desc limit 1];
                  
                 if(Oppfeaturelst.size() >0){ 
                     this.consumerSales1=Oppfeaturelst[0].Core_Feature_Name__c;
                 }*/
                 Opplst=[Select id,Core_Consumer_Sales_System__c,Core_Project_Code_Name__c,Core_Process_Node__c,Core_Exec_Sponsor_Contact__c,Core_NRE__c,Core_Project_Schedule_RFx__c,Core_Project_Schedule_TR_Kick_off__c,Core_Project_Schedule_Tape_In_Out__c,Core_Project_Schedule_Engineering_Sample__c,Core_Project_Schedule_PRQ__c,Core_Custom_Silicon_Segment__c,Core_Custom_Silicon_Application__c,Core_CEG_Contact__c,Core_CEG_Comments__c from Opportunity Where Id =: sOppId];
                 if(Opplst.size() >0){ 
                    this.consumerSales1=Opplst[0].Core_Consumer_Sales_System__c;
                    this.projectCodeName=Opplst[0].Core_Project_Code_Name__c;
                    this.processNode=Opplst[0].Core_Process_Node__c;
                    this.execSponsorContact = Opplst[0].Core_Exec_Sponsor_Contact__c;
                    this.nreUSD = Opplst[0].Core_NRE__c;
                    this.projectScheduleRFx = Opplst[0].Core_Project_Schedule_RFx__c;
                    this.projectScheduleTRKickOff = Opplst[0].Core_Project_Schedule_TR_Kick_off__c;
                    this.projectScheduleTapeInOut = Opplst[0].Core_Project_Schedule_Tape_In_Out__c;
                    this.projectScheduleEngSample = Opplst[0].Core_Project_Schedule_Engineering_Sample__c;
                    this.projectSchedulePRQ = Opplst[0].Core_Project_Schedule_PRQ__c;
                    this.customSiliconSegment = Opplst[0].Core_Custom_Silicon_Segment__c;
                    this.customSiliconApplication = Opplst[0].Core_Custom_Silicon_Application__c;
                    this.CEGContact = Opplst[0].Core_CEG_Contact__c;
                    this.CEGComments = Opplst[0].Core_CEG_Comments__c;
                 }
               
                 
            }
            
              if(this.sObjOppFeature.Id != null){
                     
                   Oppfeaturelst = [SELECT Id,Core_Platform_BU__c,Core_Consumer_Sales_system__c,Core_Feature_Name__c,Core_Feature_Type__c FROM Core_Opportunity_Features__c where id =: sObjOppFeature.Id AND Core_Feature_Type__c='Consumer Sales system' order by createddate desc limit 1];
                    if(Oppfeaturelst.size() >0){ 
                     this.consumerSales1=Oppfeaturelst[0].Core_Feature_Name__c;
                 }
                 }
            
              if(this.sObjOppFeature.Id != null){
                  Id descid=this.sObjOppFeature.Id;
                   Id OpptyId=this.sObjOppFeature.Core_Opportunity__c;
                  
                     
                 Opplst=[Select id,Core_Consumer_Sales_System__c,Core_Project_Code_Name__c,Core_Process_Node__c,Core_Exec_Sponsor_Contact__c,Core_NRE__c,Core_Project_Schedule_RFx__c,Core_Project_Schedule_TR_Kick_off__c,Core_Project_Schedule_Tape_In_Out__c,Core_Project_Schedule_Engineering_Sample__c,Core_Project_Schedule_PRQ__c,Core_Custom_Silicon_Segment__c,Core_Custom_Silicon_Application__c,Core_CEG_Contact__c,Core_CEG_Comments__c from Opportunity Where Id =: OpptyId];
                 
                 if(Opplst.size() >0){ 
                     this.consumerSales1=Opplst[0].Core_Consumer_Sales_System__c;
                    this.projectCodeName=Opplst[0].Core_Project_Code_Name__c;
                    this.processNode=Opplst[0].Core_Process_Node__c;
                    this.execSponsorContact=Opplst[0].Core_Exec_Sponsor_Contact__c;
                    this.nreUSD=Opplst[0].Core_NRE__c;
                    this.projectScheduleRFx=Opplst[0].Core_Project_Schedule_RFx__c;
                    this.projectScheduleTRKickOff=Opplst[0].Core_Project_Schedule_TR_Kick_off__c;
                    this.projectScheduleTapeInOut=Opplst[0].Core_Project_Schedule_Tape_In_Out__c;
                    this.projectScheduleEngSample=Opplst[0].Core_Project_Schedule_Engineering_Sample__c;
                    this.projectSchedulePRQ=Opplst[0].Core_Project_Schedule_PRQ__c;
                    this.customSiliconSegment = Opplst[0].Core_Custom_Silicon_Segment__c;
                    this.customSiliconApplication = Opplst[0].Core_Custom_Silicon_Application__c;
                    this.CEGContact = Opplst[0].Core_CEG_Contact__c;
                    this.CEGComments = Opplst[0].Core_CEG_Comments__c;
                 }
            }
            
            //If the Opportunity record is not NULL get the platform and Opportunity name
            if (sObjOpp != NULL) {
                sPlatform='';
                 
                if (this.Type=='Product' && sObjOpp.Core_Channel_Opportunity_Ind__c ==true ){//Commented as per Vani && sObjOpp.Core_Channel_Opportunity_Ind__c ==true){   //TWC3123-4780
                   
                sPlatform = ProdPlatform;  ///TWC3123-4528
                sOppName = sObjOpp.Name;
                }
                else{
                   
                    sPlatform = sObjOpp.Core_Intel_Platform__c;
                sOppName = sObjOpp.Name;

                }
            }
       
        
                                
            //Get the Platfrom based on opportunity header
            getItems();
            //START - US103701 Get all the BU's and Features based on platform selected and preselect the BU if only one BU present for the platform.
            getPlatformBU();
            if(PreSelectedBU !=''&& sObjOppFeature.Id==null){
                 selectedPlatformBU=PreSelectedBU;
                 Core_GetFeature();
            }
            if(this.sObjOppFeature.Id != null){
                Core_GetFeature();
            }
            //END - US103701 Get all the BU's and Features based on platform selected and preselect the BU if only one BU present for the platform.
            
            

        //} catch (Exception e) {
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.label.Core_Exception+e.getmessage()));
        //}
    }
    
    /*
     * Method name  : isBuExeOrProdMgr
     * Description  : Checks whether current user is BU Executive or BU Product Manager, writtens error message on vf page and returns true.
     * Return Type  : Boolean
     * Parameter    : NONE
     */
    public boolean isBuExeOrProdMgr(){
        if([select id from permissionSetAssignment where assigneeId =: UserInfo.getUserId() and (permissionset.name = 'Core_BU_Executive' or permissionset.name ='Core_BU_Product_Manager') and (Assignee.Profile.Name = 'CRM - Core Access') limit 1].size() > 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,' You do not have access to add or edit descriptive features'));
            return true;
        }
        else {
            return false;
        }
        //return [select id from permissionSetAssignment where assigneeId =: UserInfo.getUserId() and (permissionset.name = 'Core_BU_Executive' or permissionset.name ='Core_BU_Product_Manager' )limit 1].size() > 0;
    }//6183
    
    /*
     * Method name  : getFeature
     * Description  : Get the features based on the value of the platform
     * Return Type  : void
     * Parameter    : NONE
     */
    public void Core_GetFeature() {
       
        //Declare the variables
        mapStringToLstOption = new map < string, List < SelectOption >> {};
        mapSelectStringToLstOption = new map < string, List < SelectOption >> {};
        lstSelectListWrapper = new List < SelectListWrapper > ();
        List < Id > lstCoreOppoFeatureSet = new List < Id > {};
        mapSelectedValueToFeatureType = new Map < String, String > {};
        mapSelectedNameToFeatureType = new Map < String, String > {};
        mapStringToBool = new Map < String, Boolean > {};
        List < String > lstPlatform = new List < String > {};
        mapStringType = new Map < String, String > {};
        lstStringType = new List < String > {};
        Map < String, String > mapFeatureSetValue = new Map < String, String > {};
        
        //Get the features based on the value of the platform
        try {
            
            //Get the selected platform value
            for (SelectListWrapper sobjWrapper: lstPlatformSelectListWrapper) {
               // lstPlatform.add(sobjWrapper.sSelectedValue);
            }           
            
            //Get the platform value from opportunity
            if (sPlatform != NULL) {
                lstPlatform.add(sPlatform);
                //START - US103701, User can not change the value as the platform value is disabled, this has been used further , so commented
                //sPlatform = NULL; 
                //END - US103701, User can not change the value as the platform value is disabled, this has been used further , so commented
            }
            selectedPlatformBULabel=mapfeatureBUValueLabel.get(selectedPlatformBU);
            //START - US103701, Query on Feature set to filter the opportunity feature existing on opportunity.
            for (Core_Feature_Set__c objFutSet: [select Core_Feature__r.Core_Feature_Type__c,Core_Feature_BU__c,Core_Display_Order__c, Core_Feature__r.Core_Feature_Value__c, 
                        Core_Feature__r.Core_Multi_Select__c, Core_Feature_Header__r.Core_Header_Type__c from Core_Feature_Set__c
                        where Core_Feature_Header__r.Core_Header_Name__c =: sPlatform and Core_Feature_BU__c =:selectedPlatformBU and Core_Active__c = true ]) {                                                                                                                          
                        mapFeatureSetValue.put(objFutSet.Core_Feature__r.Core_Feature_Value__c+objFutSet.Core_Feature__r.Core_Feature_Type__c,objFutSet.Core_Feature__r.Core_Feature_Value__c);
                                             
             }
             
            //END - US103701, Query on Feature set to filter the opportunity feature existing on opportunity. 
            // If the Opportunity is present and so are its descriptive features any if saved
            if (sObjOpp != NULL && sObjOpp.Opportunity_Features__r != NULL) {
                // Get the feature Type and feature Values from the opportunity descriptive features
                for (Core_Opportunity_Features__c sobjOppFeature: sObjOpp.Opportunity_Features__r) {
                 //START - US103701, BU filter added 
                  if (mapFeatureSetValue.Keyset().contains(sobjOppFeature.Core_Feature_Name__c + sobjOppFeature.Core_Feature_Type__c)){
                    if (sobjOppFeature.Core_Feature_Set__r.Core_Feature__r.Core_Multi_Select__c != true && sobjOppFeature.Core_Platform_BU__c == selectedPlatformBULabel) {
                        mapSelectedValueToFeatureType.put(sobjOppFeature.Core_Feature_Type__c, sobjOppFeature.Core_Feature_Name__c);
                        mapSelectedNameToFeatureType.put(sobjOppFeature.Core_Feature_Name__c + sobjOppFeature.Core_Feature_Type__c, 
                            sobjOppFeature.Core_Feature_Type__c);
                    }
                   
                    //If the feature is Multilselect, then since we use 2 lists to populate the feature, fill 
                    // the list of selected list with the feature values  
                    if(sobjOppFeature.Core_Multi_Select__c == true && sobjOppFeature.Core_Platform_BU__c == selectedPlatformBULabel){
                        
                        // If the selected list doesn't contain the feature type, add a feature type with the value added to value list 
                        if (!mapSelectStringToLstOption.containskey(sobjOppFeature.Core_Feature_Type__c)) {
                            mapSelectStringToLstOption.put(sobjOppFeature.Core_Feature_Type__c, new List < SelectOption > {
                                new SelectOption(sobjOppFeature.Core_Feature_Name__c, sobjOppFeature.Core_Feature_Name__c)
                            });
                        }
                        else{ // If the selected list contains the feature type, add the value to value list
                            mapSelectStringToLstOption.get(sobjOppFeature.Core_Feature_Type__c)
                            .add(new SelectOption(sobjOppFeature.Core_Feature_Name__c, sobjOppFeature.Core_Feature_Name__c));
                        }
                    }
                  }
                 
                 
                //END - US103701, BU filter added  
                }
            }
            
            //Get the feature Type and feature values of the features through the feature set object
            // Fire a query with Header name of the feature set header name matching platform value selected by the user and active
            //START - US103701 : added BU filter in feature set query 
            for (Core_Feature_Set__c sobjFeatureSet: [select Core_Feature__r.Core_Feature_Type__c, Core_Display_Order__c, Core_Feature__r.Core_Feature_Value__c, 
                Core_Feature__r.Core_Multi_Select__c, Core_Feature_Header__r.Core_Header_Type__c from Core_Feature_Set__c
                where Core_Feature_Header__r.Core_Header_Name__c in : lstPlatform  and Core_Feature_BU__c =:selectedPlatformBU and Core_Active__c = true and  Core_Feature__r.Core_Feature_Type__c NOT IN :allTextFeatureTypes ORDER BY Core_Feature_Value__c
                ]) {
            //END - US103701 : added BU filter in feature set query      
                Set<System.SelectOption> setFeatureValue = new Set<System.SelectOption>{};
                
                // If the particular feature type has values against it in the opportunity, add them first
                if(mapSelectStringToLstOption.get(sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c) != NULL)
                    setFeatureValue.addAll(mapSelectStringToLstOption.get(sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c));
                
                // If the particular feature type doesn't have values against it in the opportunity    
                if(setFeatureValue == NULL || !setFeatureValue.contains(new SelectOption(sobjFeatureSet.Core_Feature__r.Core_Feature_Value__c,
                    sobjFeatureSet.Core_Feature__r.Core_Feature_Value__c))){
                    
                    // If the Feature type is NOT multiselect and   
                    if (mapSelectedValueToFeatureType.keyset().contains(sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c) 
                        && mapStringToLstOption.get(sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c) == NULL 
                        && sobjFeatureSet.Core_Feature__r.Core_Multi_Select__c != True)
                        // then add the --NONE-- value to the list of values
                        mapStringToLstOption.put(sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c, new List < SelectOption > {
                            new SelectOption(mapSelectedValueToFeatureType.get(sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c),
                                mapSelectedValueToFeatureType.get(sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c)),
                                new SelectOption(System.label.Core_None_Value, System.label.Core_None_Value)
                        });
                        
                    //If the feature type is NOT present opportunity, then add the feature values to it      
                    if (mapStringToLstOption.get(sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c) == NULL) {
                        if (!mapStringToLstOption.containsKey(sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c)) {
                            if (sobjFeatureSet.Core_Feature__r.Core_Multi_Select__c != true)
                                // If the feature is not multiselect add --NONE-- to the feature value and then the actual feature value
                                mapStringToLstOption.put(sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c, new List < SelectOption > {
                                    new SelectOption(System.label.Core_None_Value, System.label.Core_None_Value),
                                        new SelectOption(sobjFeatureSet.Core_Feature__r.Core_Feature_Value__c, 
                                       sobjFeatureSet.Core_Feature__r.Core_Feature_Value__c)
                                });
                            else // If the feature is multiselect add actual feature value
                                mapStringToLstOption.put(sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c, new List < SelectOption > {
                                    new SelectOption(sobjFeatureSet.Core_Feature__r.Core_Feature_Value__c, sobjFeatureSet.Core_Feature__r.Core_Feature_Value__c)
                                });
                        }
                    } else { //If the feature type is present opportunity, then add the feature values to it
                        if (!mapSelectedNameToFeatureType.Keyset().contains(sobjFeatureSet.Core_Feature__r.Core_Feature_Value__c 
                            + sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c)) {
                            mapStringToLstOption.get(sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c).add(
                            new SelectOption(sobjFeatureSet.Core_Feature__r.Core_Feature_Value__c, sobjFeatureSet.Core_Feature__r.Core_Feature_Value__c));
                        }     
                    }                   
                }
                
                //Use this map to check in the VF page if the feature type is a multi select
                mapStringToBool.put(sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c, sobjFeatureSet.Core_Feature__r.Core_Multi_Select__c);
                
                //this is the map used to sort the list of feature type, use the Display Order in the map as well
                mapStringType.put(String.Valueof(sobjFeatureSet.Core_Display_Order__c + sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c),
                    sobjFeatureSet.Core_Feature__r.Core_Feature_Type__c);   
            }
            
            //get the set of values of the display order + feature type  & sort the values
            lstStringType.addAll(mapStringType.keyset());
            lstStringType.Sort();
            

            
            //iterate the loop for the display order + feature type key
            for (String sobjString: lstStringType) {
                lstSelectListWrapper.add(new SelectListWrapper(mapStringToLstOption.get(mapStringType.get(sobjString)),
                    mapSelectStringToLstOption.get(mapStringType.get(sobjString)), mapStringType.get(sobjString), 
                        mapStringToBool.get(mapStringType.get(sobjString))));
            }
            
            // Set the value of the opportunity field using the selected value from the VF page
            for (SelectListWrapper sobjWrapper: lstPlatformSelectListWrapper) {
                if (sobjWrapper.sSelectedOriginalValue == System.Label.Core_IntelPlatform && sobjWrapper.sSelectedValue != System.Label.Core_IntelPlatform)
                    sObjOpp.Core_Intel_Platform__c = sobjWrapper.sSelectedValue;
            }
        }
        catch (Exception e) { ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.label.Core_Exception+e.getmessage()));
        }
    }

    /*
     * Method name  : getFeature
     * Description  : Get the Platform based on the records in Futre header or the opportunity
     * Return Type  : List<SelectOption>
     * Parameter    : NONE
     */
    public void getItems() {
        // Get the Platfrom based on the records in Future header or the opportunity
        try {
            mapPlatformStringToLstOption = new Map < String, List < SelectOption >> {};
           
            //Get the values of the feature header type through the feature header object
            //based on the platform name present on the opporunity record
            for (Core_Feature_Header__c sobjFeHeader: [select Core_Header_Type__c, name, Core_Header_Name__c from Core_Feature_Header__c 
                where Core_Header_Name__c!= :sPlatform ORDER BY Core_Header_Name__c]) {
                //If the Header type is still not present in the map
                if (mapPlatformStringToLstOption.get(sobjFeHeader.Core_Header_Type__c) == NULL) {
                    
                    ////If the Header type is still not present in the map
                    if (!mapPlatformStringToLstOption.containsKey(sobjFeHeader.Core_Header_Type__c)) {
                        

                        if (sobjFeHeader.Core_Header_Type__c != System.Label.Core_IntelPlatform || sPlatform == '' || sPlatform == NULL )
                        {
                        if (this.Type!='Product'){ //TWC3123-4780
                           mapPlatformStringToLstOption.put(sobjFeHeader.Core_Header_Type__c, new List < SelectOption > {
                                new SelectOption(System.label.Core_None_Value, System.label.Core_None_Value),
                                    new SelectOption(sobjFeHeader.Core_Header_Name__c, sobjFeHeader.Core_Header_Name__c)
                            });
                        }
                        }
                        else{
                            

                            mapPlatformStringToLstOption.put(sobjFeHeader.Core_Header_Type__c, new List < SelectOption > {
                                new SelectOption(sPlatform, sPlatform),
                                    new SelectOption(sobjFeHeader.Core_Header_Name__c, sobjFeHeader.Core_Header_Name__c)
                            });}
                    }
                } else { //If the Header type is present in the map, add the platform values
                    mapPlatformStringToLstOption.get(sobjFeHeader.Core_Header_Type__c).add(new SelectOption(sobjFeHeader.Core_Header_Name__c,sobjFeHeader.Core_Header_Name__c));
                }
            }
            //get the set of values of the header type  & sort the values
            lstStringType.addAll(mapPlatformStringToLstOption.keyset());
            lstStringType.Sort();
            
            //After the sort add the sorted values to the list used to diplay the header  
            for (String sobjString: lstStringType)
                lstPlatformSelectListWrapper.add(new SelectListWrapper(mapPlatformStringToLstOption.get(sobjString), NULL, sobjString, False));
        }
        catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.label.Core_Exception+e.getmessage()));
        }
            
    }
    //START - US103701 Get all the Platform BU name  based on the  Intel Plaform selected and puplate the BU picklist on UI.
    /*
    * Method name  : get Platoform BU
    * Description  : US10370 : Get all the Platform BU name  based on the  Intel Plaform selected 
    * Return Type  : Void
    * Parameter    : NONE
    */
    public void getPlatformBU() {
            // Get the Platfrom based on the records in Future header or the opportunity
        lstStringType = new List < String > {};
        platformBULst = new List<SelectOption>();
            
        try 
        {
            mapPlatformBUString = new Map < String, String> {};
            Map<String, String> mapfeatureBULabels = new Map<String, String>();
            List<Schema.PicklistEntry> picklistEntries = Schema.SObjectType.Core_Feature__c.fields.Core_Feature_BU__c.getPicklistValues();

            for(Schema.PicklistEntry ple :picklistEntries){
                mapfeatureBULabels.put(ple.getValue(),ple.getLabel());
            }      
                //Get the values of the feature header type through the feature header object
                //based on the platform name present on the opporunity record                
                for (Core_Feature_Set__c sobjFutSet: [select Core_Feature__r.Core_Feature_Type__c,Core_Feature_BU__c,Core_Display_Order__c, Core_Feature__r.Core_Feature_Value__c, 
                    Core_Feature__r.Core_Multi_Select__c, Core_Feature_Header__r.Core_Header_Type__c from Core_Feature_Set__c
                    where Core_Feature_Header__r.Core_Header_Name__c =: sPlatform and Core_Active__c = true and Core_Feature__r.Core_Feature_Type__c NOT IN :allTextFeatureTypes]) {                                          
                        if (!mapPlatformBUString.containsKey(mapfeatureBULabels.get(sobjFutSet.Core_Feature_BU__c))) {
                            if(sobjFutSet.Core_Feature_BU__c != null){                                                        
                                mapPlatformBUString.put(mapfeatureBULabels.get(sobjFutSet.Core_Feature_BU__c), sobjFutSet.Core_Feature_BU__c);
                            }                               
                        }                   
                }
                //get the set of values of the header type  & sort the values
                lstStringType.addAll(mapPlatformBUString.values());
                lstStringType.Sort();
                if(lstStringType.Size() == 1){
                     PreSelectedBU=lstStringType[0];                       
                 }
               //After the sort add the sorted values to the list used to diplay the header  
                platformBULst.add(new SelectOption(System.label.Core_None_Value, System.label.Core_None_Value));
                for (String sobjString: mapPlatformBUString.keyset()){
                        platformBULst.add(new SelectOption(mapPlatformBUString.get(sobjString),sobjString));
                    }                
        }
        catch (Exception e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.label.Core_Exception+e.getmessage()));
        }
                
    }
    //END - US103701 Get all the Platform BU name  based on the  Intel Plaform selected and puplate the BU picklist on UI.
   /*
     * Method name  : Save
     * Description  : Function to insert the opportunity feature
     * Return Type  : pagereference
     * Parameter    : NONE
     */
    public pagereference saveUpdatedRecord() {
        //Declare the variables
        List < Core_Opportunity_Features__c > lstOppFeature = new List < Core_Opportunity_Features__c > {};
        List < Core_Opportunity_Features__c > lstUpdateOppFeature = new List < Core_Opportunity_Features__c > {};
        Map < String, Core_Opportunity_Features__c > mapCheckIfRecordIsPresent = new Map < String, Core_Opportunity_Features__c > {};
        Map < String, Core_Opportunity_Features__c > mapMultiSelectTofeature = new Map < String, Core_Opportunity_Features__c > {};
        Map < String, String > mapSTringTofeatureId = new Map < String, String > {};
        Set < String > setAttributeValue = new Set < String > {};
        Set < String > setDelAttributeValue = new Set < String > {};
        Set < String > setMultiDelAttributeValue = new Set < String > {};
        Set < String > setDupliIds = new Set < String > {};
        Set < String > setAttributeTypeValue = new Set < String > {};
        List < Core_Opportunity_Features__c > lstDeleteOppFeature = new List < Core_Opportunity_Features__c > {};
        
        //Use the lstSelectListWrapper value containing the values selected from the user 
        for (SelectListWrapper sobjWrapper: lstSelectListWrapper) {
            
            if (sobjWrapper.sSelectedValue != sobjWrapper.sSelectedOriginalValue || Test.isRunningTest())
            
                // Get the features for which --none-- values is selected
                if (sobjWrapper.sSelectedValue.contains(System.Label.Core_None_Value))      
                    setDelAttributeValue.add(sobjWrapper.sSelectedOriginalValue);
                else
                    setAttributeTypeValue.add(sobjWrapper.sSelectedOriginalValue+sobjWrapper.sSelectedValue);
               
            //Add the values of the multi picklist values to be deleted               
            if (sobjWrapper.lstPlatformOptions != NULL && !sobjWrapper.lstPlatformOptions.isEmpty()) {
                for (SelectOption sSelectOption: sobjWrapper.lstPlatformOptions) {
                    setMultiDelAttributeValue.add(sobjWrapper.sSelectedOriginalValue+sSelectOption.getlabel());
                }
            } 
            
            //Add the values of the multi picklist values to be inserted
            if (sobjWrapper.lstSelectPlatformOptions != NULL && !sobjWrapper.lstSelectPlatformOptions.isEmpty()) {
                for (SelectOption sSelectOption: sobjWrapper.lstSelectPlatformOptions) {
                    setAttributeValue.add(sSelectOption.getlabel());
                    setAttributeTypeValue.add(sobjWrapper.sSelectedOriginalValue+sSelectOption.getlabel());
                }
            } 
            else
                setAttributeValue.add(sobjWrapper.sSelectedValue);
        }
       
        try {
            
            // Set up the values from the already present Opp features for the opportunity
            for (Core_Opportunity_Features__c sobjOpportFeature: [select Core_Feature_Set__r.Core_Feature__r.Core_Feature_Type__c, Core_Opportunity__c, Opportunity_Product__c,
                    Core_Feature_Name__c, Core_Feature_Type__c, Core_Feature_Set__r.Core_Feature__r.Core_Feature_Value__c, Core_Consumer_Sales_system__c,
                    Core_Project_Code_Name__c,Core_Process_Node__c,Core_Exec_Sponsor_Contact__c,Core_NRE__c,Core_Project_Schedule_RFx__c,Core_Project_Schedule_TR_Kick_off__c,
                    Core_Project_Schedule_Tape_In_Out__c,Core_Project_Schedule_Engineering_Sample__c,Core_Project_Schedule_PRQ__c,Core_Custom_Silicon_Segment__c,
                    Core_Custom_Silicon_Application__c,Core_CEG_Contact__c,Core_CEG_Comments__c,
                    Core_Feature_Set__r.Core_Feature__r.Core_Multi_Select__c from Core_Opportunity_Features__c where Core_Opportunity__c = : sObjOpp.Id AND Opportunity_Product__c=:sOppProdId     ////TWC3123-4019 Redesign Descriptive Feature
                    And Core_Feature_Set__r.Core_Feature_BU__c=:selectedPlatformBU And Type__C=:  this.Type]) {
                mapCheckIfRecordIsPresent.put(sobjOpportFeature.Core_Feature_Set__r.Core_Feature__r.Core_Feature_Type__c, sobjOpportFeature);
                mapMultiSelectTofeature.put(sobjOpportFeature.Core_Feature_Set__r.Core_Feature__r.Core_Feature_Type__c+
                    sobjOpportFeature.Core_Feature_Set__r.Core_Feature__r.Core_Feature_Value__c,sobjOpportFeature);
                if (setDelAttributeValue.contains(sobjOpportFeature.Core_Feature_Type__c) || 
                   (sobjOpportFeature.Core_Feature_Set__r.Core_Feature__r.Core_Multi_Select__c == true 
                    && setMultiDelAttributeValue.contains(sobjOpportFeature.Core_Feature_Set__r.Core_Feature__r.Core_Feature_Type__c+
                    sobjOpportFeature.Core_Feature_Set__r.Core_Feature__r.Core_Feature_Value__c)))
                    lstDeleteOppFeature.add(sobjOpportFeature); // Get all the Opp features to be deleted
            }
            
            // Get all the the feature set based on the values selected by the user. 
            //START - US103701 :Added BU filter and platform filter in feature set and feature query.
            for (Core_Feature_Set__c sobjFeature: [select Core_Active__c, Core_Feature__r.Core_Feature_Type__c, Core_Feature__r.Core_Feature_Value__c
                    from Core_Feature_Set__c where Core_Feature__r.Core_Feature_Value__c in : setAttributeValue and Core_Feature_Header__r.Core_Header_Name__c=:sPlatform
                    and Core_Feature_BU__c=:selectedPlatformBU]) {
                mapSTringTofeatureId.put(sobjFeature.Core_Feature__r.Core_Feature_Type__c + sobjFeature.Core_Feature__r.Core_Feature_Value__c, sobjFeature.Id);
            }
            
            Core_Opportunity_Features__c sobjOpportFeature = new Core_Opportunity_Features__c();  
            
            // Get all the the feature based on the values selected by the user to set up the feature set record
            for (Core_Feature__c sobjFeature: [select Id, Core_Feature_Type__c, Core_Feature_Value__c, Core_Multi_Select__c 
                from Core_Feature__c where Core_Feature_Value__c in : setAttributeValue And Core_Feature_BU__c=:selectedPlatformBU]) {
            //END - US103701 :Added BU filter and platform filter in feature set query.   
                //run the code for the feature type and value selected by the user 
                if(setAttributeTypeValue.contains(sobjFeature.Core_Feature_Type__c+sobjFeature.Core_Feature_Value__c)) {
                    
                    // If the picklist is NOT a multi select picklist //cSale:: Change for Consumer Sales System in Querries
                    if(sobjFeature.Core_Multi_Select__c == false){
                       
                        // If the Opp feature is already present
                        if (!mapCheckIfRecordIsPresent.containsKey(sobjFeature.Core_Feature_Type__c)) { 
                            
                            sobjOpportFeature = new Core_Opportunity_Features__c(Core_Opportunity__c = sObjOpp.Id,Opportunity_Product__c = sOppProdId, Core_Consumer_Sales_system__c=consumerSales1,   ////TWC3123-4019 Redesign Descriptive Feature
                                Core_Project_Code_Name__c=this.projectCodeName,
                                Core_Process_Node__c=this.processNode,
                                Core_Exec_Sponsor_Contact__c = this.execSponsorContact,
                                Core_NRE__c = this.nreUSD,
                                Core_Project_Schedule_RFx__c = this.projectScheduleRFx,
                                Core_Project_Schedule_TR_Kick_off__c = this.projectScheduleTRKickOff,
                                Core_Project_Schedule_Tape_In_Out__c = this.projectScheduleTapeInOut,
                                Core_Project_Schedule_Engineering_Sample__c = this.projectScheduleEngSample,
                                Core_Project_Schedule_PRQ__c = this.projectSchedulePRQ,
                                Core_Custom_Silicon_Segment__c = this.customSiliconSegment,
                                Core_Custom_Silicon_Application__c = this.customSiliconApplication,
                                Core_CEG_Contact__c = this.CEGContact,
                                Core_CEG_Comments__c = this.CEGComments,
                            Core_Feature_Set__c = mapSTringTofeatureId.get(sobjFeature.Core_Feature_Type__c + sobjFeature.Core_Feature_Value__c));
                            lstOppFeature.add(sobjOpportFeature);
                        } else  {  
                            sobjOpportFeature = new Core_Opportunity_Features__c(Id = mapCheckIfRecordIsPresent.get(sobjFeature.Core_Feature_Type__c).Id,
                                                                                Core_Consumer_Sales_system__c = this.consumerSales1,
                                                                                Core_Project_Code_Name__c = this.projectCodeName,
                                                                                Core_Process_Node__c = this.processNode,
                                                                                Core_Exec_Sponsor_Contact__c = this.execSponsorContact,
                                                                                Core_NRE__c = this.nreUSD,
                                                                                Core_Project_Schedule_RFx__c = this.projectScheduleRFx,
                                                                                Core_Project_Schedule_TR_Kick_off__c = this.projectScheduleTRKickOff,
                                                                                Core_Project_Schedule_Tape_In_Out__c = this.projectScheduleTapeInOut,
                                                                                Core_Project_Schedule_Engineering_Sample__c = this.projectScheduleEngSample,
                                                                                Core_Project_Schedule_PRQ__c = this.projectSchedulePRQ,
                                                                                Core_Custom_Silicon_Segment__c = this.customSiliconSegment,
                                                                                Core_Custom_Silicon_Application__c = this.customSiliconApplication,
                                                                                Core_CEG_Contact__c = this.CEGContact,
                                                                                Core_CEG_Comments__c = this.CEGComments,
                                                                                Core_Feature_Set__c = mapSTringTofeatureId.get(sobjFeature.Core_Feature_Type__c + sobjFeature.Core_Feature_Value__c));
                            lstOppFeature.add(sobjOpportFeature);
                            
                        }

                    }
                    else{//// If the picklist is a multi select picklist
                        if(!mapMultiSelectTofeature.containsKey(sobjFeature.Core_Feature_Type__c+sobjFeature.Core_Feature_Value__c)){
                            sobjOpportFeature = new Core_Opportunity_Features__c(Core_Opportunity__c = sObjOpp.Id,Opportunity_Product__c = sOppProdId,Core_Consumer_Sales_system__c=consumerSales1,   ////TWC3123-4019 Redesign Descriptive Feature
                                                                                Core_Project_Code_Name__c = this.projectCodeName,
                                                                                Core_Process_Node__c = this.processNode,
                                                                                Core_Exec_Sponsor_Contact__c = this.execSponsorContact,
                                                                                Core_NRE__c = this.nreUSD,
                                                                                Core_Project_Schedule_RFx__c = this.projectScheduleRFx,
                                                                                Core_Project_Schedule_TR_Kick_off__c = this.projectScheduleTRKickOff,
                                                                                Core_Project_Schedule_Tape_In_Out__c = this.projectScheduleTapeInOut,
                                                                                Core_Project_Schedule_Engineering_Sample__c = this.projectScheduleEngSample,
                                                                                Core_Project_Schedule_PRQ__c = this.projectSchedulePRQ,
                                                                                Core_Custom_Silicon_Segment__c = this.customSiliconSegment,
                                                                                Core_Custom_Silicon_Application__c = this.customSiliconApplication,
                                                                                Core_CEG_Contact__c = this.CEGContact,
                                                                                Core_CEG_Comments__c = this.CEGComments,
                            Core_Feature_Set__c = mapSTringTofeatureId.get(sobjFeature.Core_Feature_Type__c + sobjFeature.Core_Feature_Value__c));
                            lstOppFeature.add(sobjOpportFeature);
                        }

                    }
                }
            }
            for(Core_Opportunity_Features__c oft: lstOppFeature){
                oft.Core_Consumer_Sales_system__c = this.consumerSales1;
                oft.Core_Project_Code_Name__c = this.projectCodeName;
                oft.Core_Process_Node__c = this.processNode;
                oft.Core_Exec_Sponsor_Contact__c = this.execSponsorContact;
                oft.Core_NRE__c = this.nreUSD;
                oft.Core_Project_Schedule_RFx__c = this.projectScheduleRFx;
                oft.Core_Project_Schedule_TR_Kick_off__c = this.projectScheduleTRKickOff;
                oft.Core_Project_Schedule_Tape_In_Out__c = this.projectScheduleTapeInOut;
                oft.Core_Project_Schedule_Engineering_Sample__c = this.projectScheduleEngSample;
                oft.Core_Project_Schedule_PRQ__c = this.projectSchedulePRQ;
                oft.Core_Custom_Silicon_Segment__c = this.customSiliconSegment;
                oft.Core_Custom_Silicon_Application__c = this.customSiliconApplication;
                oft.Core_CEG_Contact__c = this.CEGContact;
                oft.Core_CEG_Comments__c = this.CEGComments;
            } 
           
            // Carry out the addition & deletion of Opp feature and updation of opportunity
            
            upsert lstOppFeature;
            
            delete lstDeleteOppFeature;
            
            update sObjOpp; 
            
            // Consumer Sales System
            /*if(!String.isBlank(consumerSales1)){
                
                List<Core_Feature__c> flist = [select id from Core_Feature__c where Core_Feature_Type__c = 'Consumer Sales system' and Core_Feature_Value__c =:consumerSales1];
                Core_Feature__c  feature = new Core_Feature__c();
                List<Core_Feature_Header__c> Fh = new List<Core_Feature_Header__c>();
                if(flist.size() == 0){
                    feature = new Core_Feature__c (Core_Feature_Type__c='Consumer Sales system',Core_Feature_Value__c=consumerSales1,Core_Feature_BU__c='CCG');
                    insert feature;
                
                    Fh=[Select Id, OwnerId,Core_Header_Name__c, Core_Header_Type__c from Core_Feature_Header__c where Core_Header_Type__c ='Intel Platform' AND Core_Header_Name__c =: sPlatform limit 1];
                    Core_Feature_Set__c fs = new Core_Feature_Set__c(Core_Feature__c=feature.id,Core_Feature_Header__c= Fh[0].id,Core_Active__c=true);
                    insert fs;
                
                    List <Core_Opportunity_Features__c> Oppfeatdel=[Select id from Core_Opportunity_Features__c where Core_Opportunity__c =:sObjOpp.id AND Opportunity_Product__c =: sOppProdId AND Core_Feature_Type__c='Consumer Sales system' And Type__c=:  this.Type];  ////TWC3123-4019 Redesign Descriptive Feature
              
                    delete Oppfeatdel;
               
                    Core_Opportunity_Features__c  Oppfeature = new Core_Opportunity_Features__c (Core_Feature_Set__c=fs.id,Core_Opportunity__c=sObjOpp.Id,Opportunity_Product__c = sOppProdId);  ////TWC3123-4019 Redesign Descriptive Feature
                    insert Oppfeature;
                }
                else{
                    Fh=[Select Id, OwnerId,Core_Header_Name__c, Core_Header_Type__c from Core_Feature_Header__c where Core_Header_Type__c ='Intel Platform' AND Core_Header_Name__c =: sPlatform limit 1];
                    Core_Feature_Set__c fs = new Core_Feature_Set__c(Core_Feature__c=flist[0].id,Core_Feature_Header__c= Fh[0].id,Core_Active__c=true);
                    insert fs;
                
                    List <Core_Opportunity_Features__c> Oppfeatdel=[Select id from Core_Opportunity_Features__c where Core_Opportunity__c =:sObjOpp.id AND Opportunity_Product__c =: sOppProdId AND Core_Feature_Type__c='Consumer Sales system' And Type__c=:  this.Type];  ////TWC3123-4019 Redesign Descriptive Feature
              
                    delete Oppfeatdel;
               
                    Core_Opportunity_Features__c  Oppfeature = new Core_Opportunity_Features__c (Core_Feature_Set__c=fs.id,Core_Opportunity__c=sObjOpp.Id,Opportunity_Product__c = sOppProdId);  ////TWC3123-4019 Redesign Descriptive Feature
                    insert Oppfeature;
                }
                // Core_Feature_Set__c fs = new Core_Feature_Set__c(Core_Feature__c=feature.id,Core_Feature_Header__c= Fh[0].id,Core_Active__c=true);
                // insert fs;
                // Core_Opportunity_Features__c  Oppfeature = new Core_Opportunity_Features__c (Core_Feature_Set__c=fs.id,Core_Opportunity__c=sObjOpp.Id);
                // insert Oppfeature;
            }
            else{
                
                List <Core_Opportunity_Features__c> Oppfeatdel=[Select id from Core_Opportunity_Features__c where Core_Opportunity__c =:sObjOpp.id AND  Opportunity_Product__c =: sOppProdId AND Core_Feature_Type__c='Consumer Sales system'  And Type__c=:  this.Type];  ////TWC3123-4019 Redesign Descriptive Feature
                delete Oppfeatdel;
            }*/ 
	    
	    //Start: Added Save logic for all the text fields 
            Map<String, String> featureTypeAndValueMap = new Map<String, String>{
            'Consumer Sales system'                     => this.consumersales1,
            'Project Code Name'                         => this.projectCodeName,
            'Process Node'                              => this.processNode,
            'Exec Sponsor Contact'                      => this.execSponsorContact,
            'NRE $'                                     => this.nreUSD,
            'Project Schedule: RFx'                     => this.projectScheduleRFx,
            'Project Schedule: TR Kick off'             => this.projectScheduleTRKickOff,
            'Project Schedule: Tape In/Out'             => this.projectScheduleTapeInOut,
            'Project Schedule: Engineering Sample'      => this.projectScheduleEngSample,
            'Project Schedule: PRQ'                     => this.projectSchedulePRQ,
            'Custom Silicon Segment'                    => this.customSiliconSegment,
            'Custom Silicon Application'                => this.customSiliconApplication,
            'CEG Contact'                               => this.CEGContact,
            'CEG Comments'                              => this.CEGComments
            };

            List<String> activeTypes = new List<String>();
            List<String> activeValues = new List<String>();
            Set<String> allFeatureTypes = featureTypeAndValueMap.keySet();

            for (String fType : allFeatureTypes) {
                String fVal = featureTypeAndValueMap.get(fType);
                if (String.isNotBlank(fVal)) {
                    activeTypes.add(fType);
                    activeValues.add(fVal);
                }
            }
            // 1. ALWAYS clean up existing Opportunity Features for ALL managed text types first!
            // This guarantees that any field cleared to blank will have its record deleted.
            List<Core_Opportunity_Features__c> oppFeatDel = [SELECT Id FROM Core_Opportunity_Features__c WHERE Core_Opportunity__c = :sObjOpp.Id AND Core_Feature_Type__c IN :allFeatureTypes];
            if (!oppFeatDel.isEmpty()) {
                delete oppFeatDel;
            }

            // 2. Only proceed with creating/linking if there are active (non-blank) values
            if (!activeValues.isEmpty()) {
                // Query existing Features matching both Type and Value
                List<Core_Feature__c> existingFeatures = [
                    SELECT Id, Core_Feature_Type__c, Core_Feature_Value__c FROM Core_Feature__c WHERE Core_Feature_Type__c IN :activeTypes AND Core_Feature_Value__c IN :activeValues ORDER BY CreatedDate DESC
                ];
                Map<String, Core_Feature__c> existingFeatureMap = new Map<String, Core_Feature__c>();
                for (Core_Feature__c f : existingFeatures) {
                    if(f.Core_Feature_Value__c == featureTypeAndValueMap.get(f.Core_Feature_Type__c)){
                        String featKey = f.Core_Feature_Type__c.trim().toLowerCase() + '::' + f.Core_Feature_Value__c.trim().toLowerCase();
                        if (!existingFeatureMap.containsKey(featKey)) {
                            existingFeatureMap.put(featKey, f);
                        }
                    }
                }

                // Insert any missing features
                List<Core_Feature__c> featuresToInsert = new List<Core_Feature__c>();
                for (String actType : activeTypes) {
                    String actVal = featureTypeAndValueMap.get(actType);
                    String featKey = actType.trim().toLowerCase() + '::' + actVal.trim().toLowerCase();

                    if (!existingFeatureMap.containsKey(featKey)) {
                        String bu = (actType == 'Consumer Sales system') ? 'CCG' : 'PBS';
                        featuresToInsert.add(new Core_Feature__c(
                            Core_Feature_Type__c  = actType,
                            Core_Feature_Value__c = actVal,
                            Core_Feature_BU__c    = bu
                        ));
                    }
                }

                if (!featuresToInsert.isEmpty()) {
                    insert featuresToInsert;
                    for (Core_Feature__c f : featuresToInsert) {
                        String featKey = f.Core_Feature_Type__c.trim().toLowerCase() + '::' + f.Core_Feature_Value__c.trim().toLowerCase();
                        existingFeatureMap.put(featKey, f);
                    }
                }
                List<Core_Feature__c> allActiveFeatures = existingFeatureMap.values();

                // Query Header
                List<Core_Feature_Header__c> Fh = [
                    SELECT Id, OwnerId, Core_Header_Name__c, Core_Header_Type__c 
                    FROM Core_Feature_Header__c 
                    WHERE Core_Header_Type__c = 'Intel Platform' 
                    AND Core_Header_Name__c = :sPlatform 
                    LIMIT 1
                ];

                if (!Fh.isEmpty() && !allActiveFeatures.isEmpty()) {
                    Id headerId = Fh[0].Id;

                    // Query existing Feature Sets
                    List<Core_Feature_Set__c> existingFsList = [
                        SELECT Id, Core_Feature__c, Core_Feature_Header__c 
                        FROM Core_Feature_Set__c 
                        WHERE Core_Feature_Header__c = :headerId 
                        AND Core_Feature__c IN :allActiveFeatures 
                        AND Core_Active__c = true
                        ORDER BY CreatedDate DESC
                    ];
                    Map<String, Core_Feature_Set__c> uniqueFeatureHeaderSetMap = new Map<String, Core_Feature_Set__c>();
                    for (Core_Feature_Set__c fs : existingFsList) {
                        String compositeKey = fs.Core_Feature__c + '::' + fs.Core_Feature_Header__c;
                        if (!uniqueFeatureHeaderSetMap.containsKey(compositeKey)) {
                            uniqueFeatureHeaderSetMap.put(compositeKey, fs);
                        }
                    }
                    // Insert missing Feature Sets
                    List<Core_Feature_Set__c> fsToInsert = new List<Core_Feature_Set__c>();
                    for (Core_Feature__c feat : allActiveFeatures) {
                        String compositeKey = feat.Id + '::' + headerId;
                        if (!uniqueFeatureHeaderSetMap.containsKey(compositeKey)) {
                            fsToInsert.add(new Core_Feature_Set__c(
                                Core_Feature__c        = feat.Id,
                                Core_Feature_Header__c = headerId,
                                Core_Active__c         = true
                            ));
                        }
                    }

                    if (!fsToInsert.isEmpty()) {
                        insert fsToInsert;
                        for (Core_Feature_Set__c fs : fsToInsert) {
                            String compositeKey = fs.Core_Feature__c + '::' + fs.Core_Feature_Header__c;
                            uniqueFeatureHeaderSetMap.put(compositeKey, fs);
                        }
                    }


                    // insert only the currently active Opportunity Features
                    List<Core_Opportunity_Features__c> oppFeatureList = new List<Core_Opportunity_Features__c>();
                    for (Core_Feature_Set__c fs : uniqueFeatureHeaderSetMap.values()) {
                        oppFeatureList.add(new Core_Opportunity_Features__c(
                            Core_Feature_Set__c = fs.Id,
                            Core_Opportunity__c = sObjOpp.Id
                        ));
                    }
                    System.debug('new Descriptive features: '+oppFeatureList);
                    if (!oppFeatureList.isEmpty()) {
                        insert oppFeatureList;
                    }
                }
            }

        //End: Added Save logic for all the text fields        
        } catch (Exception e) {  
           
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.label.Core_Exception+e.getmessage()));
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Descriptive features insertion failed',Core_Details__c = e.getMessage(), Core_Origin__c='Core_OppDescriptiveFeaturesController', Core_Severity__c='info', Core_When__c=System.Now(), Core_Project__c = 'Unicorn');
            Database.insert(logEntry, false);
            //Call the method to return the earlier values of the feature & header
            Core_getFeature();
            return NULL;
        }
             
        PageReference oppViewPage = ReturntoOpp();
        return oppViewPage;
    }

    /*
     * Method name  : Cancel
     * Description  : Function to insert the opportunity feature
     * Return Type  : pagereference
     * Parameter    : NONE
     */
    public pagereference ReturntoOpp() {
        PageReference oppViewPage;
        if (ApexPages.currentPage().getParameters().get('sOppProdid') != NULL)////TWC3123-4019 Redesign Descriptive Feature
        {
            oppViewPage= new ApexPages.StandardController(sObjOppProd).view();
            
        }
        else{

         oppViewPage = new ApexPages.StandardController(sObjOpp).view();
        }
        oppViewPage.setRedirect(true);
        return oppViewPage;
    }

    /*
     * Apex Class   : SelectListWrapper
     * Description  : Get the Platfrom based on the records in Future header/Future Set or the opportunity
     */
    public class SelectListWrapper {
                
        // List of feature values to be selected users
        public List < SelectOption > lstPlatformOptions {
            get;
            set;
        }
        
        // List of feature values selected by users
        public List < SelectOption > lstSelectPlatformOptions {
            get;
            set;
        }
        
        // Feature Type Value
        public String sSelectedValue {
            get;
            set;
        }
        
        // Selected Feature Type Value
        public String sSelectedOriginalValue {
            get;
            set;
        }
        
        //Flag to check if the select option needs to be multi select
        public Boolean bIsMultiSelect {
            get;
            set;
        }
        
        public SelectListWrapper(List < SelectOption > lstPlatformOptions, List < SelectOption > lstSelectPlatformOptions, String sSelectedValue, Boolean bIsMultiSelect) {
            if(lstSelectPlatformOptions == NULL)
                lstSelectPlatformOptions = new List<SelectOption>();
            if(lstPlatformOptions == NULL)
                lstPlatformOptions = new List<SelectOption>{new SelectOption(System.Label.Core_None_Value, System.Label.Core_None_Value)};
            this.lstPlatformOptions = lstPlatformOptions;
            this.lstSelectPlatformOptions = lstSelectPlatformOptions;
            this.sSelectedValue = sSelectedValue;
            this.sSelectedOriginalValue = sSelectedValue; 
            this.bIsMultiSelect = bIsMultiSelect;
        }
    }
}