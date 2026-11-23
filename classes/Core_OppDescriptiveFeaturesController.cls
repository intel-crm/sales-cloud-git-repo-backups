/**************************************************************************************
Apex Class Name:  Core_OpportunityDescriptiveFeature
Version     : 1.0 
Created Date: 09 OCT 2014
Function    : 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/09/2014              Original Version
*************************************************************************************/
public with sharing class Core_OppDescriptiveFeaturesController{

    // Variable to hold Opportunity Record   
    private Opportunity sObjOpp;
    
    // Variable to hold Opportunity features Record
    private final Core_Opportunity_Features__c sObjOppFeature;
    
    // Variable to hold Opportunity Record Id
    public String sOppId;
    
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
        
        //Add the Parent field using the addfields. Escape this code for the test methods to avoid error
        if (!Test.isRunningTest())
            stdController.addFields(new list < String > {
                'Core_Opportunity__c'
            });
        
        try {
            
            //Get the Opportunity ID from the URL, this in case when the new list button is opened
            if (ApexPages.currentPage().getParameters().get(System.label.Core_Opportunity_ID) != NULL)
                sOppId = ApexPages.currentPage().getParameters().get(System.label.Core_Opportunity_ID);
                
            // Get the descriptive feature record from the standard controller
            this.sObjOppFeature = (Core_Opportunity_Features__c) stdController.getRecord();
            
            // Get the Opportunity record from the Opportunity ID obtained
            if (sOppId != NULL || sObjOppFeature.Core_Opportunity__c != NULL)
                sObjOpp = [select Id, Name, Core_Intel_Platform__c, (select   
                    Core_Feature_Set__r.Core_Feature__r.Core_Feature_Type__c, Core_Opportunity__c, 
                    Core_Feature_Name__c, Core_Feature_Type__c, Core_Feature_Set__r.Core_Feature__r.Core_Feature_Value__c,
                    Core_Feature_Set__r.Core_Feature__r.Core_Multi_Select__c,Core_Multi_Select__c from Opportunity_Features__r) from Opportunity 
                    where Id = : sOppId or Id = : sObjOppFeature.Core_Opportunity__c];
            
            //If the Opportunity record is not NULL get the platform and Opportunity name
            if (sObjOpp != NULL) {
                sPlatform = sObjOpp.Core_Intel_Platform__c;
                sOppName = sObjOpp.Name;
            }
                                
            //Get the Platfrom based on the records in Future header or the opportunity
            getItems();
            
            //Get the features based on the value of the platform
            Core_GetFeature();

        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.label.Core_Exception+e.getmessage()));
        }
    }

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
        
        //Get the features based on the value of the platform
        try {
            
            //Get the selected platform value
            for (SelectListWrapper sobjWrapper: lstPlatformSelectListWrapper) {
                lstPlatform.add(sobjWrapper.sSelectedValue);
            }
            
            //Get the platform value from opportunity
            if (sPlatform != NULL) {
                lstPlatform.add(sPlatform);
                sPlatform = NULL;
            }
     
            // If the Opportunity is present and so are its descriptive features any if saved
            if (sObjOpp != NULL && sObjOpp.Opportunity_Features__r != NULL) {
                // Get the feature Type and feature Values from the opportunity descriptive features
                for (Core_Opportunity_Features__c sobjOppFeature: sObjOpp.Opportunity_Features__r) {
                    
                    if (sobjOppFeature.Core_Feature_Set__r.Core_Feature__r.Core_Multi_Select__c != true) {
                        mapSelectedValueToFeatureType.put(sobjOppFeature.Core_Feature_Type__c, sobjOppFeature.Core_Feature_Name__c);
                        mapSelectedNameToFeatureType.put(sobjOppFeature.Core_Feature_Name__c + sobjOppFeature.Core_Feature_Type__c, 
                            sobjOppFeature.Core_Feature_Type__c);
                    }
                    
                    //If the feature is Multilselect, then since we use 2 lists to populate the feature, fill 
                    // the list of selected list with the feature values  
                    if(sobjOppFeature.Core_Multi_Select__c  == true){
                        
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
            }
            
            //Get the feature Type and feature values of the features through the feature set object
            // Fire a query with Header name of the feature set header name matching platform value selected by the user and active
            for (Core_Feature_Set__c sobjFeatureSet: [select Core_Feature__r.Core_Feature_Type__c, Core_Display_Order__c, Core_Feature__r.Core_Feature_Value__c, 
                Core_Feature__r.Core_Multi_Select__c, Core_Feature_Header__r.Core_Header_Type__c from Core_Feature_Set__c
                where Core_Feature_Header__r.Core_Header_Name__c in : lstPlatform and Core_Active__c = true ORDER BY Core_Feature_Value__c
                ]) {
                    
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
        catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.label.Core_Exception+e.getmessage()));
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
                        
                        if (sobjFeHeader.Core_Header_Type__c != System.Label.Core_IntelPlatform || sPlatform == '' || sPlatform == NULL)
                            mapPlatformStringToLstOption.put(sobjFeHeader.Core_Header_Type__c, new List < SelectOption > {
                                new SelectOption(System.label.Core_None_Value, System.label.Core_None_Value),
                                    new SelectOption(sobjFeHeader.Core_Header_Name__c, sobjFeHeader.Core_Header_Name__c)
                            });
                        else
                            mapPlatformStringToLstOption.put(sobjFeHeader.Core_Header_Type__c, new List < SelectOption > {
                                new SelectOption(sPlatform, sPlatform),
                                    new SelectOption(sobjFeHeader.Core_Header_Name__c, sobjFeHeader.Core_Header_Name__c)
                            });
                    }
                } else { //If the Header type is present in the map, add the platform values
                    mapPlatformStringToLstOption.get(sobjFeHeader.Core_Header_Type__c).add(new SelectOption(sobjFeHeader.Core_Header_Name__c, 
                    sobjFeHeader.Core_Header_Name__c));
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
            for (Core_Opportunity_Features__c sobjOpportFeature: [select Core_Feature_Set__r.Core_Feature__r.Core_Feature_Type__c, Core_Opportunity__c, 
                    Core_Feature_Name__c, Core_Feature_Type__c, Core_Feature_Set__r.Core_Feature__r.Core_Feature_Value__c,
                    Core_Feature_Set__r.Core_Feature__r.Core_Multi_Select__c from Core_Opportunity_Features__c where Core_Opportunity__c = : sObjOpp.Id]) {
                mapCheckIfRecordIsPresent.put(sobjOpportFeature.Core_Feature_Set__r.Core_Feature__r.Core_Feature_Type__c, sobjOpportFeature);
                mapMultiSelectTofeature.put(sobjOpportFeature.Core_Feature_Set__r.Core_Feature__r.Core_Feature_Type__c+
                    sobjOpportFeature.Core_Feature_Set__r.Core_Feature__r.Core_Feature_Value__c,sobjOpportFeature);
                if (setDelAttributeValue.contains(sobjOpportFeature.Core_Feature_Type__c) || 
                   (sobjOpportFeature.Core_Feature_Set__r.Core_Feature__r.Core_Multi_Select__c == true 
                    && setMultiDelAttributeValue.contains(sobjOpportFeature.Core_Feature_Set__r.Core_Feature__r.Core_Feature_Type__c+
                    sobjOpportFeature.Core_Feature_Set__r.Core_Feature__r.Core_Feature_Value__c)))
                    lstDeleteOppFeature.add(sobjOpportFeature); // Get all the Opp features to be deleted
            }
            
            // Get all the the feature set based on the values selected by the user
            for (Core_Feature_Set__c sobjFeature: [select Core_Active__c, Core_Feature__r.Core_Feature_Type__c, Core_Feature__r.Core_Feature_Value__c
                    from Core_Feature_Set__c where Core_Feature__r.Core_Feature_Value__c in : setAttributeValue]) {
                mapSTringTofeatureId.put(sobjFeature.Core_Feature__r.Core_Feature_Type__c + sobjFeature.Core_Feature__r.Core_Feature_Value__c, sobjFeature.Id);
            }

            Core_Opportunity_Features__c sobjOpportFeature = new Core_Opportunity_Features__c();  
            
            // Get all the the feature based on the values selected by the user to set up the feature set record
            for (Core_Feature__c sobjFeature: [select Id, Core_Feature_Type__c, Core_Feature_Value__c, Core_Multi_Select__c 
                from Core_Feature__c where Core_Feature_Value__c in : setAttributeValue]) {
                
                //run the code for the feature type and value selected by the user 
                if(setAttributeTypeValue.contains(sobjFeature.Core_Feature_Type__c+sobjFeature.Core_Feature_Value__c)) {
                    
                    // If the picklist is NOT a multi select picklist
                    if(sobjFeature.Core_Multi_Select__c == false){
                        
                        // If the Opp feature is already present
                        if (!mapCheckIfRecordIsPresent.containsKey(sobjFeature.Core_Feature_Type__c)) {                        
                            sobjOpportFeature = new Core_Opportunity_Features__c(Core_Opportunity__c = sObjOpp.Id, 
                            Core_Feature_Set__c = mapSTringTofeatureId.get(sobjFeature.Core_Feature_Type__c + sobjFeature.Core_Feature_Value__c));
                            lstOppFeature.add(sobjOpportFeature);
                        } else  {                 
                            sobjOpportFeature = new Core_Opportunity_Features__c(Id = mapCheckIfRecordIsPresent.get(sobjFeature.Core_Feature_Type__c).Id, 
                            Core_Feature_Set__c = mapSTringTofeatureId.get(sobjFeature.Core_Feature_Type__c + sobjFeature.Core_Feature_Value__c));
                            lstOppFeature.add(sobjOpportFeature);
                        }

                    }
                    else{//// If the picklist is a multi select picklist
                        if(!mapMultiSelectTofeature.containsKey(sobjFeature.Core_Feature_Type__c+sobjFeature.Core_Feature_Value__c)){
                            sobjOpportFeature = new Core_Opportunity_Features__c(Core_Opportunity__c = sObjOpp.Id, 
                            Core_Feature_Set__c = mapSTringTofeatureId.get(sobjFeature.Core_Feature_Type__c + sobjFeature.Core_Feature_Value__c));
                            lstOppFeature.add(sobjOpportFeature);
                        }
                    }
                }
            }
            
            // Carry out the addition & deletion of Opp feature and updation of opportunity
            upsert lstOppFeature;
            delete lstDeleteOppFeature;
            update sObjOpp;
            
        } catch (Exception e) {            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.label.Core_Exception+e.getmessage()));
            
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
        PageReference oppViewPage = new ApexPages.StandardController(sObjOpp).view();
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