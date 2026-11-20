public with sharing class PMP_SearchSpecialistGroupListController extends PMP_SearchWrapperStore{
    
    public PMP_SearchSpecialistGroupListController(){
        
    }
    
  /*  public static List<Listing> getSpecialtyList(){
       //Created by Kartik
        Map<String,Id> valueIdMap = new Map<String,Id>();
        //Schema.DescribeFieldResult fieldOutput = PMP_Company__c.PMP_Account_Specialty__c.getDescribe(); 
        List<PMP_Specialty__mdt> spec = [Select id, MasterLabel from PMP_Specialty__mdt];
        for(PMP_Specialty__mdt specData: spec){
            valueIdMap.put(specData.MasterLabel, specData.Id); 
        }
        
         Map<String,String> labelValueMap = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();      
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            labelValueMap.put(pickListVal.getLabel(),pickListVal.getValue());
        }
       
        return null;
    }  */
    
    // @AuraEnabled(cacheable=true)
    // public static List<Listing> getSpecialistGroupListData (String pageType, String langCode){
    //     List<PMP_Company__C> partners = new  List<PMP_Company__C>();
    //     List<PMP_Specialty_Images__mdt> metaDataList = new List<PMP_Specialty_Images__mdt>();
        
    //     Map<String,Id> valueIdMap = new Map<String,Id>();
        
    //     List<PMP_Partner_Specialty__c> specialtyList = [SELECT id, Name, PMP_Is_Active_Ind__c from PMP_Partner_Specialty__c WHERE PMP_Is_Active_Ind__c = TRUE];
    //     for(PMP_Partner_Specialty__c specData: specialtyList){
    //         valueIdMap.put(specData.Name, specData.Id); 
    //     }   
        
    //     Map<String,String> labelValueMap = new Map<String,String>();
    //     Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();      
    //     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    //     for( Schema.PicklistEntry pickListVal : ple){
    //         labelValueMap.put(pickListVal.getLabel(),pickListVal.getValue());
    //     }  
        
    //     /*Boolean contains = labelValueMap.containsKey(valueIdMap);

    //     if(contains){
    //         SearchParams.Specialty = valueIdMap.specData.Id;
    //     }
        
    //     if(valueIdMap.specData.MasterLabel == labelValueMap.pickListVal.getLabel()){
    //         SearchParams.Specialty = valueIdMap.specData.Id
    //     }  */
        
    //     for(String keyId: valueIdMap.Keyset()){

          
    //        if(!labelValueMap.keyset().contains(keyId)){
    //           SearchParams valId = new SearchParams();
    //            valId.cat = keyId;  
    //        }

    // }
        
    //     try{
    //         if (pageType == 'partner' || pageType == 'all')
    //         {
    //             Map<String,Listing> specMap = new Map<String,Listing>();
                
                
    //             partners = [select toLabel(PMP_Account_Specialty__c) from PMP_Company__c where PMP_Account_Specialty__c != null AND PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published];
                
    //             metaDataList = [select PMP_Account_Specialty_Name__c,	PMP_Specialty_Name_Chinese__c,PMP_Specialty_Name_Japanese__c, URL__c from PMP_Specialty_Images__mdt where PMP_Account_Specialty_Name__c != null];
              
                
    //             Map<String,String> metadataMap = new Map<String,String>();
                
    //             for(PMP_Specialty_Images__mdt md : metaDataList){
    //                 if (langCode == PMP_StaticConstants_Partner.ZH_CN && String.isNotEmpty(md.PMP_Specialty_Name_Chinese__c)){
    //                     metadataMap.put(md.PMP_Specialty_Name_Chinese__c,md.URL__c);
    //                 }
    //                 else if (langCode == PMP_StaticConstants_Partner.JA && String.isNotEmpty(md.PMP_Specialty_Name_Japanese__c)){
    //                     metadataMap.put(md.PMP_Specialty_Name_Japanese__c,md.URL__c);
    //                 }
    //                 else if(String.isNotEmpty(md.PMP_Account_Specialty_Name__c)){
    //                     metadataMap.put(md.PMP_Account_Specialty_Name__c,md.URL__c);
    //                 }
                    
    //             }
                
    //             List<String> specList = new List<String>();
    //             for(PMP_Company__c partner: partners){
    //                 specList.addAll(partner.PMP_Account_Specialty__c.split(';'));
    //             }
    //             for (String spec: specList)
    //             {
    //                 if (labelValueMap.containsKey(spec) && !specMap.containsKey(spec) && !labelValueMap.get(spec).equals(PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program))
    //                 {
    //                     Listing listing = new Listing();
    //                     listing.label = spec;
                       
    //                     //listing.imgUrl = [select URL__c from PMP_Specialty_Images__mdt where Label =:spec.PMP_Account_Specialty__c].URL__c;
    //                     // system.debug('Specialty :'+ spec);
    //                     if(metadataMap.containsKey(spec)){
    //                         listing.imgUrl = metadataMap.get(spec);
    //                         // system.debug('Specialty :'+ spec);
    //                     }
                            
    //                     listing.page = 'search';
    //                      listing.isIcon=true;
    //                     SearchParams params = new SearchParams();
    //                     params.type = 'partner';
    //                     params.selectedFilters = new Map<String,List<String>>();
    //                     List<String> filterList = new List<String>();
    //                     //filterList.add(labelValueMap.get(spec).replace(' ','_'));   //Added by Nikhil to resolve url issue
    //                     filterList.add(valueIdMap.get(spec));   //Added by Kartik  //Adding specialty id to selectedFilters
    //                     // System.debug('Value Id map for spec : '+valueIdMap.get(spec));
    //                     params.selectedFilters.put('Specialty_Partner', filterList);
    //                     System.debug('params.selectedFilters : '+params.selectedFilters);
    //                     params.specialty = valueIdMap.get(labelValueMap.get(spec));   //Added by Kartik
    //                     params.cat = valueIdMap.get(labelValueMap.get(spec));
    //                     System.debug('params.specialty : '+params.specialty);
    //                     //params.specialty = valueIdMap.get(spec);  //Added by Kartik
    //                     // System.debug('Specilty list: '+params);
    //                     listing.searchParams = params;
    //                     specMap.put(spec , listing);
    //                 }
    //             }
    //             return specMap.values();
    //         }
    //     }catch(Exception e){
    //         System.debug(e.getMessage()+' '+e.getStackTraceString());
    //         throw new AuraHandledException(e.getMessage()+' '+e.getStackTraceString());
    //     }
    //     return null;
    // }
    
    
}