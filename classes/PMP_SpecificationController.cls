/****************************************************************************************************************************************
* Class Name  : PMP_SpecificationController 
* Version     : 1.0 
* Created Date: 12-07-2018
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Gireesh                   12/07/2018                    Method 'getOfferingSpecificationList' to build tree hierarchy and return offering specification list
* Intel - Gireesh                   01/02/2019                    Method 'getOfferingSpecifications' to return offering specification for the given offering id
* Infosys - Abhishek                04/02/2019                    Method 'getOfferingValuesAndSpecificationMap' to return map of Category and Values for given offering
****************************************************************************************************************************************************************/


public without sharing class PMP_SpecificationController {
    
    @AuraEnabled
    public string locale{get;set;}
    
   @AuraEnabled(cacheable = true)
    /*Get offering Specifications based on   */ 
    
    public static List<PMP_Partner_Offering_Specification__c> getOfferingSpecifications(Id offeringId){
        //CustomField for Spec Name and Spec value Name - added my Manasa US439814
        return [select id,Name,PMP_Ancestor_Specification_Cd__c,
                PMP_Display_Type_Nm__c,PMP_Localized_Specification_Value_Nm__c, PMP_Specification_Value_Nm__c,
                PMP_Localized_Specification_Nm__c,PMP_Offering_Id__c,PMP_Specification_Id__c, PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c,
                PMP_Product_Specification_Cd__c,PMP_Specification_Value_Cd__c,PMP_Specification_Nm__c,PMP_Specification_Id__r.PMP_Parent_Specification_Id__c,PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name, 
                PMP_Specification_Value_Id__c,PMP_Specification_Value_Id__r.PMP_Partner_Off_Roadmap_Ind__c,PMP_Specification_Id__r.PMP_Mandatory_Offering_Category_Nm__c,PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,
                PMP_Specification_Id__r.PMP_Partner_Product_Display_Sequence_Nbr__c,PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,
				PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Japanese_Nm__c,
				PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Chinese_Nm__c,
                PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Name__c,
                PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c,PMP_Specification_Id__r.Name,PMP_Specification_Id__r.PMP_Specification_Name__c,
                PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c,
                PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,PMP_Specification_Value_Id__r.PMP_Image_URL__c,
                PMP_Specification_Id__r.PMP_Image_URL__c,PMP_Specification_Id__r.PMP_Product_URL__c,PMP_Specification_Id__r.PMP_Specification_Type_Nm__c,
                PMP_Specification_Value_Id__r.PMP_Product_URL__c,PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c,
                PMP_Specification_Value_Id__r.Name,PMP_Specification_Value_Id__r.PMP_Specification_Value_Nm__c, PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c,
                PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c
                from PMP_Partner_Offering_Specification__c where 
                PMP_Offering_Id__c = : offeringId AND PMP_Specification_Id__r.PMP_Active_Ind__c = true 
                ORDER BY PMP_Specification_Id__r.PMP_Partner_Product_Display_Sequence_Nbr__c]; // Added by Manasa - US359436 (Added Image, Product URL fields)
                //Parent Chinese Japnese Names added by Deepanshu for DE77627
    }
    //Added by sandeep to fetch specs for multiple offerings
    public static Map<id,List<PMP_Partner_Offering_Specification__c>> getOfferingSpecificationsMap(List<id> Offeringids)
    {
        Map<Id, List<PMP_Partner_Offering_Specification__c>> SpecMap = new Map<Id, List<PMP_Partner_Offering_Specification__c>>();
        for(PMP_Partner_Offering__c off : [select id, name, (select id,Name,PMP_Ancestor_Specification_Cd__c,
                                                             PMP_Display_Type_Nm__c,PMP_Localized_Specification_Value_Nm__c,
                                                             PMP_Localized_Specification_Nm__c,PMP_Offering_Id__c,PMP_Specification_Id__c, PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c,
                                                             PMP_Specification_Id__r.PMP_Parent_Specification_Id__c,                                    
                                                             PMP_Product_Specification_Cd__c,PMP_Specification_Value_Cd__c,PMP_Specification_Nm__c,
                                                             PMP_Specification_Value_Id__c,PMP_Specification_Value_Id__r.PMP_Partner_Off_Roadmap_Ind__c
                                                             from Offering_Specifications__r
                                                             ORDER BY PMP_Specification_Id__r.PMP_Partner_Product_Display_Sequence_Nbr__c) 
                                           from PMP_Partner_Offering__c where id in:Offeringids])
        {
            if(off.Offering_Specifications__r.size() > 0)
                SpecMap.put(off.id,off.Offering_Specifications__r);
        }
        return SpecMap; 
    }
    
    public PMP_SpecificationController(){
        //Get user locale
        //User user = [SELECT LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId()];
        //this.locale=user.LocaleSidKey;
        this.locale='en_US';
        
    }
    
    
    /*Gireesh:US378991:
* check if any pre-release items are selected
*/
    @AuraEnabled(cacheable = true)
    public static Boolean getOffSetValues(String offeringId){
        Boolean containsOffsetValues=False;
        //CustomField for Spec Name and Spec value Name - added my Manasa US439814
        List<PMP_Partner_Offering_Specification__c> offSetValues= [SELECT Id,PMP_Specification_Value_Id__r.Name,PMP_Specification_Value_Id__r.PMP_Specification_Value_Nm__c,PMP_Specification_Value_Id__r.PMP_Partner_Off_Roadmap_Ind__c from PMP_Partner_Offering_Specification__c
                                                                   where PMP_Offering_Id__c=:offeringId and PMP_Specification_Value_Id__c<>Null and PMP_Specification_Value_Id__r.PMP_Spec_Pre_Release_Ind__c=True];
        if(offSetValues.size()>0){
            containsOffsetValues=True;
        }
        return containsOffsetValues;
    }
    
    @AuraEnabled(cacheable = true)
    /*Gets Specification data for the selected Category list*/
    public static List<PMP_Category_Specification_Association__c> getOfferingSpecs(string[] selectedCategoryIds){
        List<PMP_Category_Specification_Association__c>  offeringSpecs=new List<PMP_Category_Specification_Association__c>();        
        List<Id> specids = new List<Id>();
        //CustomField for Spec Name and Spec value Name - added my Manasa US439814
        offeringSpecs=[SELECT Id, Name, PMP_Category_Id__c, PMP_Category_Specification_External_Key__c,PMP_Specification_Id__c,
                       PMP_Specification_Id__r.PMP_Display_Type_Nm__c,
                       PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,
                       PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,
                       PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c,
                       PMP_Active_Ind__c,
                       PMP_Specification_Id__r.Name,PMP_Specification_Id__r.PMP_Specification_Name__c,
                       PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c, 
                       PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c,
                       PMP_Specification_Id__r.PMP_Mandatory_Offering_Category_Nm__c,PMP_Specification_Id__r.PMP_Partner_Product_Display_Sequence_Nbr__c,
                       PMP_Specification_Id__r.PMP_Mandatory_Specification_Ind__c,PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c                       
                       FROM PMP_Category_Specification_Association__c 
                       where PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c in :selectedCategoryIds AND PMP_Active_Ind__c = true                     
                       ORDER BY PMP_Specification_Id__r.PMP_Partner_Product_Display_Sequence_Nbr__c,PMP_Specification_Id__r.Name ASC];
        for(PMP_Category_Specification_Association__c specs:offeringSpecs){
            if(specs.PMP_Specification_Id__r.PMP_Partner_Product_Display_Sequence_Nbr__c == null){
                specids.add(specs.PMP_Specification_Id__r.id);
            }            
        }
        //CustomField for Spec Name and Spec value Name - added my Manasa US439814
        List<PMP_Specification__c> parentSpec = [select id, name,PMP_Specification_Name__c,(select id, name,PMP_Specification_Name__c,PMP_Partner_Product_Display_Sequence_Nbr__c from Specifications__r order by PMP_Partner_Product_Display_Sequence_Nbr__c ASC limit 1), PMP_Partner_Product_Display_Sequence_Nbr__c from PMP_Specification__c where id in :specids];
        
        for(PMP_Specification__c spc : parentSpec){
            for(PMP_Specification__c childSpec : spc.Specifications__r){
                spc.PMP_Partner_Product_Display_Sequence_Nbr__c = childSpec.PMP_Partner_Product_Display_Sequence_Nbr__c;  
            }
        }
        for(PMP_Category_Specification_Association__c specAsso:offeringSpecs){
            for(PMP_Specification__c spc : parentSpec){
                if(specAsso.PMP_Specification_Id__r.PMP_Partner_Product_Display_Sequence_Nbr__c == null){
                    //CustomField for Spec Name and Spec value Name - added my Manasa US439814
                    if(specAsso.PMP_Specification_Id__r.PMP_Specification_Name__c == spc.PMP_Specification_Name__c){
                        specAsso.PMP_Specification_Id__r.PMP_Partner_Product_Display_Sequence_Nbr__c=spc.PMP_Partner_Product_Display_Sequence_Nbr__c;
                    }
                }
            }
        }
        
        /*for (integer i = 0; i < offeringSpecs.size(); i++) {
for (integer j = i + 1; j < offeringSpecs.size(); j++) {
PMP_Category_Specification_Association__c tmp = new PMP_Category_Specification_Association__c();
if (offeringSpecs[i].PMP_Specification_Id__r.PMP_Partner_Product_Display_Sequence_Nbr__c > offeringSpecs[j].PMP_Specification_Id__r.PMP_Partner_Product_Display_Sequence_Nbr__c) {
tmp = offeringSpecs[i];
offeringSpecs[i] = offeringSpecs[j];
offeringSpecs[j] = tmp;
}
}
}*/ //commenting to resolve CPU time out error - Abhishek
        
        
        
        
        return offeringSpecs;
    }
    
    
    @AuraEnabled(cacheable = true)
    /*Gets Specification Value data for the selected Category list*/
    public static List<PMP_Specification_Value_Association__c> getOfferingSpecValues(string[] selectedCategoryIds){
        List<PMP_Specification_Value_Association__c>  offeringSpecificationValues=new List<PMP_Specification_Value_Association__c>();
        //CustomField for Spec Name and Spec value Name - added my Manasa US439814
        offeringSpecificationValues=[SELECT Id, Name,                                      
                                     PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c,
                                     PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,     
                                     PMP_Specification_Value_Id__r.PMP_Specification_Value_Cd__c,
                                     PMP_Specification_Value_Id__r.Name,PMP_Specification_Value_Id__r.PMP_Specification_Value_Nm__c,
                                     PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c,
                                     PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c,
                                     PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,
                                     PMP_Specification_Value_Id__r.PMP_Display_Type_Nm__c,
                                     PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c,
                                     PMP_Specification_Id__r.Name,PMP_Specification_Id__r.PMP_Specification_Name__c,
                                     PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,
                                     PMP_Specification_Value_Id__r.PMP_Partner_Off_Roadmap_Ind__c,
                                     PMP_Specification_Value_Id__r.PMP_Spec_Pre_Release_Ind__c,
                                     PMP_Specification_Value_Id__r.PMP_Active_Ind__c,
                                     PMP_Active_Ind__c
                                     FROM PMP_Specification_Value_Association__c 
                                     where PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c in :selectedCategoryIds 
                                     AND PMP_Active_Ind__c = true
                                     ORDER BY PMP_Specification_Value_Id__r.PMP_Specification_Value_Sequence_Nbr__c];  
        
        
        return offeringSpecificationValues;
    }
    
    
    @AuraEnabled(cacheable = true)
    /*Gets all the Specification Value data*/
    public static List<PMP_Specification_Value__c> getAllSpecValues(){
        //CustomField for Spec Name and Spec value Name - added my Manasa US439814
        return [select id, Name,PMP_Specification_Value_Nm__c, PMP_Product_Specification_Value_Cd__c, PMP_Display_Type_Nm__c from 
                PMP_Specification_Value__c ORDER BY PMP_Specification_Value_Sequence_Nbr__c ASC
               ];
    }
    @AuraEnabled(cacheable = true)
    /*Gets Specification and Specific value data for the selected category list*/
    public static List<Core_PMP_OfferingSpecs> getOfferingSpecificationList(string[] selectedCategoryIds,Id offeringId){
        return getOfferingSpecificationList(selectedCategoryIds, offeringId, null);
    }
    
    @AuraEnabled(cacheable = true)
    /*Gets Specification and Specific value data for the selected category list*/
    public static List<Core_PMP_OfferingSpecs> getOfferingSpecificationList(string[] selectedCategoryIds,Id offeringId,string language){
        //Gets all the Specification Value records
        
        List<PMP_Partner_Offering_Specification__c> delOffSpec=new List<PMP_Partner_Offering_Specification__c>();      
        List<PMP_Specification_Value__c> allSpecValues=getAllSpecValues();      
        Map<String, PMP_Specification_Value__c> allSpecValuesMap=new Map<String, PMP_Specification_Value__c>();        
        
        //Gets Specification data for the selected Category list
        //system.debug('***categories-->'+selectedCategoryIds);
        List<PMP_Category_Specification_Association__c>  offeringSpecs = getOfferingSpecs(selectedCategoryIds);
        List<Core_PMP_OfferingSpecs> offeringSpecification = new List<Core_PMP_OfferingSpecs>();        
        Map<String, Core_PMP_OfferingSpecs> offeringSpecificationMap=new Map<String,Core_PMP_OfferingSpecs>();
        String specNameInLocale;
        String specValNameInLocale;
        
        /*Added by raj to display specificaton as per the user locale*/
        Map<String, String> specApiNameByLabel = PMP_Utility.getLocaleFields('Specification',language);//calling getLocaleFields method of utility class to get api field names as per the user locale for Specification object
        /*----------------------------------End---------------------------------------------------------------------------------------------*/
        
        
        Set<Id> offeringSet = new Set<Id>();
        Map<String,PMP_Partner_Offering_Specification__c> offSpecMap = new Map<String,PMP_Partner_Offering_Specification__c>();
        
        List<String> catSpecList = new List<String>();
        Boolean mandatoryForCategory;
        
        /*Map all spec offering values*/
        
        
        for(PMP_Specification_Value__c allSpecValue: allSpecValues){
            allSpecValuesMap.put(allSpecValue.PMP_Product_Specification_Value_Cd__c, allSpecValue);
        }
        
        if(offeringId!=null){
            for(PMP_Partner_Offering__c offering : [Select id from PMP_Partner_Offering__c where id = :offeringId limit 1]){
                offeringSet.add(offering.Id);
            }
            //CustomField for Spec Name and Spec value Name - added my Manasa US439814
            for(PMP_Partner_Offering_Specification__c offSpec : [Select id,Name,PMP_Specification_Id__c,PMP_Specification_Value_Id__c,PMP_Ancestor_Specification_Cd__c,PMP_Specification_Value_Nm__c,PMP_Specification_Value_Cd__c,PMP_Product_Specification_Cd__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c IN: offeringSet]){
                if(offSpec.PMP_Product_Specification_Cd__c!=null && offSpec.PMP_Product_Specification_Cd__c!='')
                    offSpecMap.put(offSpec.PMP_Product_Specification_Cd__c,offSpec);
                //CustomField for Spec Name and Spec value Name - added my Manasa US439814
                if(offSpec.PMP_Specification_Value_Nm__c!=null && offSpec.PMP_Specification_Value_Nm__c!='') 
                    offSpecMap.put(offSpec.PMP_Specification_Value_Nm__c,offSpec);
                if(offSpec.PMP_Ancestor_Specification_Cd__c!=null && offSpec.PMP_Ancestor_Specification_Cd__c!=''){
                    if(offSpec.PMP_Ancestor_Specification_Cd__c.contains('|')){
                        string tempStr = offSpec.PMP_Ancestor_Specification_Cd__c.replace('|',':');
                        List<String> tempList = tempStr.split(':');
                        if(!tempList.isEmpty() && tempList!=null){
                            for(string splitStr:tempList){
                                offSpecMap.put(splitStr,offSpec); 
                            }
                        }
                    }else{
                        offSpecMap.put(offSpec.PMP_Ancestor_Specification_Cd__c,offSpec);  
                    }    
                }
            }
        }
        
        
        for(PMP_Category_Specification_Association__c offeringSpec : offeringSpecs){
            
            //Mark as mandatory if the selected Category list contains in Core_PMP_Mandatory_For_Category__c list
            mandatoryForCategory=false;
            String mandatoryCategories=offeringSpec.PMP_Specification_Id__r.PMP_Mandatory_Offering_Category_Nm__c;
            
            if(mandatoryCategories!=null && mandatoryCategories=='All'){
                mandatoryForCategory=true;
                if(offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c!='' && offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c!=null){
                    if(offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c.contains('|')){
                        string tempSpecVal = offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c;
                        string tempCatSpecKey = tempSpecVal.replace('|',':'); 
                        List<String> tempCatSpecList = tempCatSpecKey.split(':');
                        if(!tempCatSpecList.isEmpty() && tempCatSpecList!=null){
                            for(string splitString:tempCatSpecList){
                                catSpecList.add(splitString);
                            }
                        }
                    }else{
                        catSpecList.add(offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c);
                    }
                }
            }
            else if(mandatoryCategories!=null && mandatoryCategories.contains('Not minimum requirement')){
                // mandatoryForCategory=true;
                if(offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c!='' && offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c!=null){
                    if(offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c.contains('|')){
                        string tempSpecVal = offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c;
                        string tempCatSpecKey = tempSpecVal.replace('|',':'); 
                        List<String> tempCatSpecList = tempCatSpecKey.split(':');
                        if(!tempCatSpecList.isEmpty() && tempCatSpecList!=null){
                            for(string splitString:tempCatSpecList){
                                catSpecList.add(splitString);
                            }
                        }
                    }else{
                        catSpecList.add(offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c);
                    }
                }
            }
            else if(mandatoryCategories!=null){
                string [] mandatoryCategoryIds=mandatoryCategories.split(',');
                for(string categoryId:selectedCategoryIds ){
                    if(mandatoryCategoryIds.contains(categoryId)){
                        mandatoryForCategory=true;
                        if(offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c!='' && offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c!=null){
                            if(offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c.contains('|')){
                                string tempSpecVal = offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c;
                                string tempCatSpecKey = tempSpecVal.replace('|',':'); 
                                List<String> tempCatSpecList = tempCatSpecKey.split(':');
                                if(!tempCatSpecList.isEmpty() && tempCatSpecList!=null){
                                    for(string splitString:tempCatSpecList){
                                        catSpecList.add(splitString);
                                    }
                                }
                            }else{
                                catSpecList.add(offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c);
                            }
                        }
                        break;
                        
                    }
                }
            }
            
            
            //Get SpecificationValue details(Name,SpecId and SpecRecordId)
            string specValueName;
            string specValueId;
            string specValueRecordId;
            if(allSpecValuesMap.containsKey(offeringSpec.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c)){
                PMP_Specification_Value__c specVal=allSpecValuesMap.get(offeringSpec.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c);
                //specValueName =specVal.Name; // Commented by Manasa
                //CustomField for Spec Name and Spec value Name - added my Manasa US439814
                specValueName =specVal.PMP_Specification_Value_Nm__c;
                specValueId=specVal.PMP_Product_Specification_Value_Cd__c;
                specValueRecordId=specVal.Id;
            }
            
            
            
            Boolean nodeExpanded=false;
            Boolean nodeSelected=false;
            Boolean leafMandatory=false;
            
            
            
            
            if(offSpecMap.containskey(offeringSpec.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c)){
                nodeExpanded = true;
                nodeSelected = true;
                specValueName=offSpecMap.get(offeringSpec.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c).PMP_Specification_Value_Cd__c ==null?'':offSpecMap.get(offeringSpec.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c).PMP_Specification_Value_Cd__c;
            }
            
            /*added by raj to display specification according to the user locale*/
            
            /*fetch the locale specification name from specification object for the user locale using metadata field*/
            //Added by Manasa - replace standard field with custom 'Name' field
            if(String.valueOf(offeringSpec.PMP_Specification_Id__r.get(specApiNameByLabel.get('Name'))) != null && !specApiNameByLabel.isEmpty()){
                specNameInLocale = String.valueOf(offeringSpec.PMP_Specification_Id__r.get(specApiNameByLabel.get('Name')));
            }
            else{//if the translated value for spec not available,store english value
            //CustomField for Spec Name and Spec value Name - added my Manasa US439814
                specNameInLocale = offeringSpec.PMP_Specification_Id__r.PMP_Specification_Name__c;
            }
            /*---------------------End-------------------------------------*/
            
            
            //Create an object with Specification and Spec Value(Name,SpecId and SpecRecordId) details
            Core_PMP_OfferingSpecs currOfferingSpec = new 
                Core_PMP_OfferingSpecs(specNameInLocale,
                                       offeringSpec.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,
                                       offeringSpec.PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c,
                                       offeringSpec.PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,
                                       offeringSpec.PMP_Specification_Id__r.PMP_Display_Type_Nm__c,
                                       offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c,
                                       mandatoryForCategory,
                                       offeringSpec.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,nodeExpanded,nodeSelected,
                                       offeringSpec.PMP_Specification_Id__r.Id, 
                                       specValueName, 
                                       specValueId, specValueRecordId,false
                                      );    
            //Create Specification mapping
            offeringSpecificationMap.put(currOfferingSpec.specId, currOfferingSpec); 
            
        }
        
        
   /*     for(string TempSpecId:offeringSpecificationMap.Keyset()){
            if(catSpecList.contains(TempSpecId)){
                Core_PMP_OfferingSpecs tempCurrOfferingSpec;
                Core_PMP_OfferingSpecs currOfferingSpec;
                tempCurrOfferingSpec = offeringSpecificationMap.get(TempSpecId);
                currOfferingSpec = new 
                    Core_PMP_OfferingSpecs(tempCurrOfferingSpec.specName,
                                           tempCurrOfferingSpec.specId,
                                           tempCurrOfferingSpec.parentId,
                                           tempCurrOfferingSpec.categoryId,
                                           tempCurrOfferingSpec.displayType,
                                           tempCurrOfferingSpec.ancestorSpecName,
                                           false,
                                           tempCurrOfferingSpec.ancestorSpecID,tempCurrOfferingSpec.nodeExpanded,tempCurrOfferingSpec.nodeSelected,
                                           tempCurrOfferingSpec.specRecordId,tempCurrOfferingSpec.specValue,tempCurrOfferingSpec.specValueId,tempCurrOfferingSpec.specValueRecordId,true
                                          );
                
                offeringSpecificationMap.put(TempSpecId,currOfferingSpec);
            }
        } */
        
        //ErrorAdded;
        //List<String>asdasd=allSpecValues[0].PMP_Specification_Value__c.split('|');
        
        /*Get Specification Values for the Category and Specification*/
        Map<String,List<Core_PMP_OfferingSpecsValues>> offeringSpecValuesMap=new Map<String,List<Core_PMP_OfferingSpecsValues>>();        
        List<Core_PMP_OfferingSpecsValues> offeringSpecValuesList=new List<Core_PMP_OfferingSpecsValues>();
        List<PMP_Specification_Value_Association__c> offeringSpecificationValues = getOfferingSpecValues(selectedCategoryIds);
        
        Map<String, String> specValApiNameByLabel = PMP_Utility.getLocaleFields('Specification Value',language);//calling getLocaleFields method of utility class to get api field names as per the user locale for Specification object
        
        for(PMP_Specification_Value_Association__c offeringSpecValue : offeringSpecificationValues){
            
            Core_PMP_OfferingSpecsValues currOfferingSpecValues;
            string dateValue='';
            string intValue='';
            Boolean nodeExpanded=false;
            Boolean nodeSelected=false;
            if(offSpecMap.containskey(offeringSpecValue.PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c)){
                nodeExpanded=true;
                nodeSelected=true; 
            }
            /*fetch the locale specificationValue name from specificationValue object for the user locale using metadata field*/
            //Added by Manasa - replace standard field with custom 'Name' field
            if(String.valueOf(offeringSpecValue.PMP_Specification_Value_Id__r.get(specValApiNameByLabel.get('Name'))) != null && !specValApiNameByLabel.isEmpty()){
                specValNameInLocale = String.valueOf(offeringSpecValue.PMP_Specification_Value_Id__r.get(specValApiNameByLabel.get('Name')));
            }
            else{//if translated value for the speVal is not available,store english value
            //CustomField for Spec Name and Spec value Name - added my Manasa US439814
                specValNameInLocale = offeringSpecValue.PMP_Specification_Value_Id__r.PMP_Specification_Value_Nm__c;
            }
            /*---------------------End-------------------------------------*/
            //CustomField for Spec Name and Spec value Name - added my Manasa US439814
            currOfferingSpecValues = new Core_PMP_OfferingSpecsValues
                (offeringSpecValue.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,
                 offeringSpecValue.PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,
                 offeringSpecValue.PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c,
                 specValNameInLocale,
                 offeringSpecValue.PMP_Specification_Value_Id__r.PMP_Display_Type_Nm__c,
                 offeringSpecValue.PMP_Specification_Id__r.PMP_Specification_Name__c,
                 offeringSpecValue.PMP_Specification_Id__r.PMP_Ancestor_Specification_Nm__c,
                 offeringSpecValue.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,nodeExpanded,nodeSelected,
                 offeringSpecValue.PMP_Specification_Value_Id__r.Id,
                 offeringSpecValue.PMP_Specification_Id__c,
                 offeringSpecValue.PMP_Specification_Value_Id__r.PMP_Spec_Pre_Release_Ind__c
                );  
            
            
            if(!offeringSpecificationMap.isEmpty()){      
                
                if(offeringSpecificationMap.get(currOfferingSpecValues.specValueId) == null)
                {
                    
                    /*Create Specification Values mapping */
                    
                    if(offeringSpecValuesMap.get(offeringSpecValue.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c)!=null){
                        
                        offeringSpecValuesMap.get(offeringSpecValue.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c).add(currOfferingSpecValues);
                    }
                    else{
                        offeringSpecValuesMap.put(offeringSpecValue.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,new List<Core_PMP_OfferingSpecsValues>{currOfferingSpecValues});          
                        
                    }
                }
            }else{
                
                if(!offeringSpecValuesMap.isEmpty()){
                    if(offeringSpecValuesMap.get(offeringSpecValue.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c)!=null){
                        offeringSpecValuesMap.get(offeringSpecValue.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c).add(currOfferingSpecValues);
                        
                    }
                    
                    else{
                        offeringSpecValuesMap.put(offeringSpecValue.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,new List<Core_PMP_OfferingSpecsValues>{currOfferingSpecValues});  
                        
                    }
                    
                }else{
                    offeringSpecValuesMap.put(offeringSpecValue.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,new List<Core_PMP_OfferingSpecsValues>{currOfferingSpecValues});
                    
                }
            } 
        }
        
        
        /*Attaching Specification Value to spec*/
        for(String specId: offeringSpecificationMap.keySet()){    
            if(offeringSpecValuesMap.containsKey(specId) ){                
                Core_PMP_OfferingSpecs tempOfferingSpec=offeringSpecificationMap.get(specId);
                tempOfferingSpec.specValues=offeringSpecValuesMap.get(specId);   
                
                offeringSpecificationMap.put(specId,tempOfferingSpec);
            }
        }
        
        /*Attach child to parent node*/        
        for(String catSpecId : offeringSpecificationMap.keySet()){            
            //get the parent of the current node and attach the current node to the parent node
            Core_PMP_OfferingSpecs tempChildOffering=offeringSpecificationMap.get(catSpecId);
            
            if(offeringSpecificationMap.containsKey(tempChildOffering.parentId)){  
                Core_PMP_OfferingSpecs tempParentOffering;
                tempParentOffering=offeringSpecificationMap.get(tempChildOffering.parentId);                
                tempParentOffering.childOfferingSpecification.add(tempChildOffering); 
            }         
        }
        
        for(String catSpecId : offeringSpecificationMap.keySet()){            
            //get the parent of the current node and attach the current node to the parent node
            Core_PMP_OfferingSpecs tempChildOffering=offeringSpecificationMap.get(catSpecId);
            Core_PMP_OfferingSpecs tempParentOffering;
            tempParentOffering=offeringSpecificationMap.get(tempChildOffering.parentId);   
            
            //Mark current Specification's display as Label if the current Specification doesn't exist as SpecificationValue
            
            //String tempAncestorSpecIds=tempChildOffering.ancestorSpecID.replace('|',':');
            //List<String> ancestorSpecIds = tempAncestorSpecIds.split(':');
            
            //if(ancestorSpecIds.contains(PROCESSOR) || ancestorSpecIds.contains(CHIPSET)) 
            //tempChildOffering.displayType = tempChildOffering.displayType;
            //system.debug(PROCESSOR+'::'+CHIPSET);
            //if(  (!ancestorSpecIds.contains(PROCESSOR) && !ancestorSpecIds.contains(CHIPSET)) &&
            if((!tempChildOffering.ancestorSpecID.contains(PMP_StaticConstants_Offering.PROCESSOR) && !tempChildOffering.ancestorSpecID.contains(PMP_StaticConstants_Offering.CHIPSET)) && (!tempChildOffering.ancestorSpecID.contains(PMP_StaticConstants_Offering.NUC)) &&
               (!tempChildOffering.ancestorSpecID.contains(PMP_StaticConstants_Offering.FPGA)) && (!tempChildOffering.ancestorSpecID.contains(PMP_StaticConstants_Offering.GEOREGION)) && (!tempChildOffering.ancestorSpecID.contains(PMP_StaticConstants_Offering.INTELTECH)) &&
               !allSpecValuesMap.containsKey(tempChildOffering.specId) 
               &&(tempChildOffering.displayType == 'Checkbox' || tempChildOffering.displayType == 'RadioButton') 
               && (!tempChildOffering.specValues.isEmpty() || !tempChildOffering.childOfferingSpecification.isEmpty()))                
                tempChildOffering.displayType = 'Label';   
        }
        
        //Add all the Specifications to List
        for(String catSpecId : offeringSpecificationMap.keySet()){
            if(offeringSpecificationMap.get(catSpecId).parentId == ''){
                offeringSpecification.add(offeringSpecificationMap.get(catSpecId));
            }
        }	
        return offeringSpecification;
    }
    
    @AuraEnabled(cacheable = true)
    public static Map<string, List<string>> getOfferingValuesAndSpecificationMap(List<PMP_Partner_Offering_Specification__c> listOfferSpec,String language){
        
        Map<string,string> parentChildMap = New Map<string,string>(); //Map to identify the lower most node
        Map<string, List<string>> masterAndValueMap = New Map<string, List<string>>(); // main map that will hold the Category value and List of its values
        
        for (PMP_Partner_Offering_Specification__c itr : listOfferSpec){
            //CustomField for Spec Name and Spec value Name - added my Manasa US439814
            parentChildMap.put(itr.PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c, itr.PMP_Specification_Id__r.PMP_Specification_Name__c);
            
        }
        
        for(PMP_Partner_Offering_Specification__c itr : listOfferSpec){
            
            //if the specification is not present as a key in the parentChildMap, it means it is the lowest node. We pick these records
            //for processing further.
            if(!parentChildMap.containsKey(itr.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c)
               || itr.name != itr.PMP_Specification_Value_Cd__c){
                   string masterParent;
                   string value;
                   
                   if(itr.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c == null){
                       masterParent = itr.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c;
                       value = itr.PMP_Specification_Value_Cd__c;
                      
                   }
                   else if((itr.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c).countMatches('|') == 0 ){
                   /***US460366 - Start : Added by Manasa****/
                       if(itr.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c == PMP_StaticConstants_Offering.noOFProcessors){                      
                               masterAndValueMap.put(itr.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c, New List<string>{itr.PMP_Specification_Value_cd__c});                               
                           }
                       else if (itr.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c == PMP_StaticConstants_Offering.processorsSocketed){
                                masterAndValueMap.put(itr.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c, New List<string>{System.label.PMP_Yes});                      
                       }
                    /***US460366 - End : Added by Manasa****/
                       else{
                           masterParent = itr.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c;
                           
                           value = (itr.name == itr.PMP_Specification_Value_cd__c) || itr.PMP_Specification_Value_cd__c==null   ? itr.name : itr.name + ' : ' + itr.PMP_Specification_Value_cd__c;
                       }
                   /*    masterParent = itr.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c;
                       
                       value = (itr.name == itr.PMP_Specification_Value_cd__c) || itr.PMP_Specification_Value_cd__c==null   ? itr.name : itr.name + ' : ' + itr.PMP_Specification_Value_cd__c; */
                   }
                   else if((itr.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c).countMatches('|') > 0 ){
                       masterParent = (itr.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c).substringBefore('|');
                       string TempSpecValStr = (itr.PMP_Specification_Id__r.PMP_Ancestor_Specification_nm__c).substringAfter('|');
                       TempSpecValStr = TempSpecValStr.replaceAll('[|]', ' : ');
                       
                       value = itr.name == itr.PMP_Specification_Value_cd__c || itr.PMP_Specification_Value_cd__c ==null ? TempSpecValStr + ' : ' + itr.name : TempSpecValStr + ' : ' + itr.name + ' : ' + itr.PMP_Specification_Value_cd__c;
                       
                   }
                   if(masterParent != null){
                       //populating masterAndValueMap 
                       
                       if(masterAndValueMap.containsKey(masterParent)){
                           
                           List<string> tempSpecValList = New list<string>();
                           tempSpecValList.addAll(masterAndValueMap.get(masterParent));
                           
                           tempSpecValList.add(value);
                           masterAndValueMap.put(masterParent,tempSpecValList);
                       }
                       else{
                           List<string> tempSpecValList = New List<string>();
                           
                           tempSpecValList.add(value);
                           masterAndValueMap.put(masterParent, tempSpecValList);
                       }
                   }   
               }
            
        }   
        
        List<string> technicalExcemptedList = New List<string>();
        List<string> technicalList = New List<string>();
        List<string> technicalListOthers = New List<string>();
        List <PMP_Specification__c> sortedTechSpecList = New List <PMP_Specification__c>();
        Map<string, List<string>> techSpecMap = New Map<string, List<string>>();
        Map<string , List<string>> geoCoverageMap = New Map<string , List<string>>();
        Map<string , List<string>> availabilityAndPricingMap = New Map<string , List<string>>();
        List <Map<string , List<string>>> valuesMapList = New List<Map<string , List<string>>>();
        
        //fethch a list of excempted List from metadata and add it to excempted list.
        for( Non_Technical_specification_list__mdt metaSettings : [Select label from Non_Technical_specification_list__mdt]){
            technicalExcemptedList.add(metaSettings.label);          
        }
        for(string key : masterAndValueMap.keyset()){
            
            if(!technicalExcemptedList.contains(key)) {
                technicalList.add(key); 
            }
            else if(key == 'NPP_GeographicCoverage'){ 
                geoCoverageMap.put(key, masterAndValueMap.get(key));
            }
            else if(key == 'AvailabilityandPricingLevel1'){
                availabilityAndPricingMap.put(key, masterAndValueMap.get(key));
            }  
            
        }
        if(technicalList.size() > 0){
            //query specification to find out if the particualr specification is mandatory and sort
            // based on PMP_Mandatory_Specification_Ind__c
            //CustomField for Spec Name and Spec value Name - added my Manasa US439814
            sortedTechSpecList = [Select Name,PMP_Specification_Name__c, PMP_Mandatory_Specification_Ind__c ,PMP_Partner_Product_Specification_Id__c,PMP_Specification_Type_Nm__c,
                                  PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c
                                  from PMP_Specification__c
                                  Where PMP_Partner_Product_Specification_Id__c IN : technicalList
                                  Order By PMP_Mandatory_Specification_Ind__c Desc];
            
            
        }
        //Added by raj to accomodate user preferred language
        List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localNameField = PMP_Utility.getLocaleToFieldMdtRecordsByObject(language,'Specification');
        String localSpecNameField = localNameField[0].PMP_Field_APINm__c;
        /*continued below*/
        //techSpecMap = masterAndValueMap - excempted key and corresponding values.
        if(sortedTechSpecList.size() > 0){
            for(PMP_Specification__c spec : sortedTechSpecList){
                //CustomField for Spec Name and Spec value Name - added my Manasa US439814 /*Modified by raj to accomodate user preferred language*/
                if(String.isNotBlank(String.valueOf(spec.get(localSpecNameField)))){
                   techSpecMap.put(String.valueOf(spec.get(localSpecNameField)), masterAndValueMap.get(spec.PMP_Partner_Product_Specification_Id__c) ); 
                }
                else{
                    techSpecMap.put(spec.PMP_Specification_Name__c, masterAndValueMap.get(spec.PMP_Partner_Product_Specification_Id__c) );
                }
            }
        }
        for(string key : techSpecMap.keyset() ){
            List<string> valueList = techSpecMap.get(key);
            integer valueListSize = valueList.size();
            
            List<string> modifiedList = new list <string>();
            valueList.sort();
            for(integer i=0 ; i< valueListSize -1; i++){
                string value1 = valueList[i];
                string value2 = valueList[i+1];
                if((!value2.contains(value1) && !value2.contains(':')) || (value2.contains(value1) && !value2.contains(':')) || (!value2.contains(value1))){
                    modifiedList.add(value1);
                }
                
            }
            modifiedList.add(valueList[valueListSize-1]);
            
            techSpecMap.put(key,modifiedList );
        }
        if(!techSpecMap.isEmpty()){
            valuesMapList.add(techSpecMap);
        }
        if(!geoCoverageMap.isEmpty()){
            valuesMapList.add(geoCoverageMap);
        }
        if(!availabilityAndPricingMap.isEmpty()){
            valuesMapList.add(availabilityAndPricingMap);
        }
        
        return techSpecMap;
    }
    
    
    public class Core_PMP_OfferingSpecs{
        public  Core_PMP_OfferingSpecs(String specName,String specId,String parentId,String categoryId, String displayType, String ancestorSpecName, Boolean mandatoryCheck, String ancestorSpecID,Boolean nodeExpanded,Boolean nodeSelected, string specRecordId, String specValue, String specValueId, String specValueRecordId,Boolean leafMandatory){
            this.specName = specName;
            this.specId = specId;
            this.parentId = parentId==null?'':parentId;
            this.categoryId = categoryId;       
            this.displayType = displayType;
            this.selectableType = '';
            this.ancestorSpecName = ancestorSpecName;
            this.ancestorSpecID = ancestorSpecID==null?'':ancestorSpecID; 
            this.mandatoryCheck = mandatoryCheck;
            this.specRecordId=specRecordId;
            this.nodeSelected=nodeSelected;
            this.nodeExpanded=nodeExpanded; 
            this.highlightClass=false;
            this.specValue=specValue;
            this.specValueId=specValueId;
            this.specValueRecordId=specValueRecordId;
            this.preReleased='';
            this.childOfferingSpecification=new List<Core_PMP_OfferingSpecs>();
            this.specValues = new List<Core_PMP_OfferingSpecsValues>();
            this.leafMandatory = leafMandatory;
        }
        @AuraEnabled
        @TestVisible public string specName {get;set;}
        
        @AuraEnabled
        @TestVisible public Boolean mandatoryCheck {get;set;}
        
        @AuraEnabled
        @TestVisible public string ancestorSpecName {get;set;}
        
        @AuraEnabled
        @TestVisible public string specId {get;set;}
        
        @AuraEnabled
        @TestVisible public string specValueId {get;set;}
        
        @AuraEnabled
        @TestVisible public string specValue {get;set;}
        
        @AuraEnabled
        @TestVisible public string specValueRecordId {get;set;}
        
        @AuraEnabled
        @TestVisible public string parentId {get;set;}
        
        @AuraEnabled
        @TestVisible public string specRecordId {get;set;}
        
        @AuraEnabled
        @TestVisible public string categoryId {get;set;}  
        
        @AuraEnabled
        @TestVisible public string displayType {get;set;}  
        
        @AuraEnabled
        @TestVisible public string selectableType {get;set;}
        
        @AuraEnabled
        @TestVisible public boolean nodeSelected {get;set;}
        
        @AuraEnabled
        @TestVisible public boolean nodeExpanded {get;set;}
        
        @AuraEnabled
        @TestVisible public boolean highlightClass {get;set;}
        
        @AuraEnabled
        @TestVisible public string ancestorSpecID {get;set;}
        
        @AuraEnabled
        @TestVisible public String preReleased {get;set;}
        
        @AuraEnabled
        @TestVisible public List<Core_PMP_OfferingSpecs> childOfferingSpecification {get;set;}
        
        @AuraEnabled
        @TestVisible public List<Core_PMP_OfferingSpecsValues> specValues {get;set;}
        
        @AuraEnabled
        @TestVisible public boolean leafMandatory {get;set;}
        
    } 
    
    public class Core_PMP_OfferingSpecsValues{
        public Core_PMP_OfferingSpecsValues(){}
        
        public Core_PMP_OfferingSpecsValues(string specId,string categoryId, string specValueId, string specValue, string displayType, string specName, string ancestorSpecName, string ancestorSpecID,Boolean nodeExpanded,Boolean nodeSelected,string specValueRecordId, string specRecordId, boolean preReleased){
            this.specId = specId;
            this.categoryId = categoryId;
            this.specValueId = specValueId;
            this.specValue = specValue;
            this.displayType = displayType;
            this.nodeSelected=nodeSelected;
            this.nodeExpanded=nodeExpanded; 
            this.parentId='';
            this.specRecordId=specRecordId;
            this.specValueRecordId=specValueRecordId;
            this.specName = specName;
            this.ancestorSpecName = ancestorSpecName==null?'':ancestorSpecName;
            this.ancestorSpecID = ancestorSpecID==null?'':ancestorSpecID;
            this.highlightClass=false;
            this.preReleased=preReleased;
        }
        
        @AuraEnabled
        @TestVisible public string specId {get;set;}
        
        @AuraEnabled
        @TestVisible public string ancestorSpecID {get;set;}
        
        @AuraEnabled
        @TestVisible public string specRecordId {get;set;}
        
        @AuraEnabled
        @TestVisible public string specValueRecordId {get;set;}
        
        @AuraEnabled
        @TestVisible public string specName {get;set;}
        
        @AuraEnabled
        @TestVisible public Boolean preReleased {get;set;}
        
        @AuraEnabled
        @TestVisible public string parentId {get;set;}
        
        @AuraEnabled
        @TestVisible public string ancestorSpecName {get;set;}
        
        @AuraEnabled
        @TestVisible public string displayType {get;set;}
        
        @AuraEnabled
        @TestVisible public string categoryId {get;set;}
        
        @AuraEnabled
        @TestVisible public string specValueId {get;set;}
        
        @AuraEnabled
        @TestVisible public string specValue {get;set;}
        
        @AuraEnabled
        @TestVisible public String dateValue {get;set;}
        
        @AuraEnabled
        @TestVisible public String intValue {get;set;}
        
        
        @AuraEnabled
        @TestVisible public boolean nodeExpanded {get;set;}
        
        @AuraEnabled
        @TestVisible public boolean nodeSelected {get;set;}
        
        @AuraEnabled
        @TestVisible public boolean highlightClass {get;set;}
        
        
        
    }
}