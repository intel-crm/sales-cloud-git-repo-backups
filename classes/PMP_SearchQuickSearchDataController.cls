/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SearchQuickSearchDataController
* Description : Stores all the wrapper classes used throught the Marketplace.
* Version     : 1.0 
* Created Date: 07-May-2019
* Modification Log :
* Created By  : Tanzanite Team (Infosys)
********************************************************************************************************************************************************************************************************/

public with sharing class PMP_SearchQuickSearchDataController extends PMP_SearchWrapperStore{
    public PMP_SearchQuickSearchDataController(){
        
    }
    
    //Method to get all filters
    
    // public static List<Option> getSearchFilterData(String searchType, String langCode){
    //     List<Option> filters=null; 
    //     try{
    //         filters = new List<Option>();
            
    //         //filters.add(getPartnerOptions());
            
    //         if(searchType == 'Product' || searchType == 'home'){
    //             filters.add(getCategoryOptions(PMP_StaticConstants_Partner.PIM_CATEGORY_ID, langCode));
    //             filters.add(getCategoryOptions(PMP_StaticConstants_Partner.PIM_INDUSTRY_ID, langCode));
    //             filters.add(getCategoryOptions(PMP_StaticConstants_Partner.PIM_APPLICATION_ID, langCode));
    //             filters.add(getRegionOptions(PMP_StaticConstants_Partner.REGION_PIM_ID,'Product', langCode));
    //         }
    //         else if(searchType == 'Partner'){
    //             filters.add(getPartnerOptions(langCode));
    //             filters.add(getCategoryOptions(PMP_StaticConstants_Partner.PIM_INDUSTRY_ID, langCode));
    //             filters.add(getCategoryOptions(PMP_StaticConstants_Partner.PIM_APPLICATION_ID, langCode));
    //             filters.add(getRegionOptions(PMP_StaticConstants_Partner.REGION_PIM_ID,'Partner', langCode));   
    //         }
            
    //     }catch(Exception e){
    //         System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
    //     }
    //     return filters;
    // }
    // /********************************************************************************************/
    
    // //Getting partner program dropddown values.
    
    // public static Option getPartnerOptions(String langCode){  
    //     Option ppResult = null; 
    //     try{
    //         ppResult = new Option(); 
            
    //         List<PMP_SearchPartnerProgram_Config__mdt> ppList = [SELECT Label,PMP_Partner_Program_Name__c,Active__c,  PMP_Partner_Program_value__c,
    //                                                              PMP_Partner_Program_Name_Chinese__c, PMP_Partner_Program_Name_Japanese__c
    //                                                              FROM PMP_SearchPartnerProgram_Config__mdt
    //                                                              WHERE Active__c = true ORDER BY Label ];
            
    //         String partnerProgName = PMP_SearchUtilityController.getFieldApiName('PMP_SearchPartnerProgram_Config__mdt', 'Partner_Program_Name', langCode);
    //         if(String.isEmpty(partnerProgName)){
    //             partnerProgName = 'PMP_Partner_Program_Name__c';
    //         }
    //         ppResult.label = System.Label.PMP_Partner_Programs;
    //         ppResult.value = ppList[0].Label + '_Partner';
    //         ppResult.options = new List<Option>();
            
    //         List<PMP_Partner_Program__c> seoPpList = [SELECT id, PMP_Is_Active_Ind__c,PMP_Partner_Program_Value_Txt__c from PMP_Partner_Program__c WHERE PMP_Is_Active_Ind__c=TRUE];
            
    //         Map<String,String> ppIdValueMap = new Map<String, String>();
    //         Map<String,String> ppValueIdMap = new Map<String,String>();
    //         for(PMP_Partner_Program__c pp : seoPpList){
    //             ppIdValueMap.put(pp.Id, pp.PMP_Partner_Program_Value_Txt__c);
    //             ppValueIdMap.put(pp.PMP_Partner_Program_Value_Txt__c, pp.Id);
    //         }
            
    //         for(PMP_SearchPartnerProgram_Config__mdt pp : ppList){  	
    //             Option ppM = new Option();
    //             ppM.label = (String)pp.get(partnerProgName);
    //             if(String.isEmpty(ppM.label)){
    //                 ppM.label = pp.PMP_Partner_Program_Name__c;
    //             }
    //             //ppM.value = pp.PMP_Partner_Program_Value__c;
    //             ppM.value = ppValueIdMap.get(pp.PMP_Partner_Program_Value__c);
    //             ppResult.options.add(ppM);
    //         }
    //         //Adding ODM-LOEM as partner program
    //         Option odm = new Option();
    //         odm.label = System.Label.PMP_Partner_Directory_title3;
    //         odm.value = ppValueIdMap.get('ODM-LOEM');//PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program.replace(' ','_');
    //         ppResult.options.add(odm);
    //         //Changes End
    //         ppResult.isPartnerProgram=true;
            
    //     }catch(Exception e){
    //         System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
    //     }
    //     return ppResult;
    // }
    
    // /*************************************************************************/
    
    // public static Option getCategoryOptions(String pimId, String langCode){
    //     Option filter=new Option();
    //     PMP_Category__c category = new PMP_Category__c();
    //     try{
    //         if(Schema.sObjectType.PMP_Category__c.isAccessible()){
    //             category = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c =:pimId LIMIT 1];
                
    //         }
            
    //         filter.label = PMP_SearchUtilityController.getLocalisedName(category, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
    //         filter.value=category.Id;
            
    //         filter.options = PMP_SearchUtilityController.getCategoryTree(pimId,false,langCode);
            
    //         if(pimId == PMP_StaticConstants_Partner.PIM_CATEGORY_ID){
    //             filter.isCategory=true;
    //         }  
            
            
    //     }catch(Exception e){
    //         System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
    //         //throw new AuraHandledException(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
    //     }
    //     return filter;
    // }
    
    // /************************************************************************/
    
    
    // //Update By Nikhil 25-Jul-2019
    
    // public static Option getRegionOptions(String pimId,String searchType, String langCode){
    //     Option filter=new Option();
    //     try{
    //         filter.options= new List<Option>();
            
    //         for (PMP_Specification__c spec : [SELECT Id, Name, PMP_Specification_Chinese_Nm__c,PMP_Specification_Japanese_Nm__c,PMP_Partner_Product_Specification_Id__c FROM PMP_Specification__c WHERE (PMP_Product_Parent_Specification_Id__c  = :pimId OR PMP_Partner_Product_Specification_Id__c =: pimId) AND PMP_Active_Ind__c = TRUE ORDER BY Name])
    //         {
    //             if(spec.PMP_Partner_Product_Specification_Id__c == pimId){
    //                 filter.value = spec.Id;
    //                 filter.label = PMP_SearchUtilityController.getLocalisedName(spec, '', langCode);
    //             }
    //             else{
    //                 Option opt = new Option();
    //                 opt.label = PMP_SearchUtilityController.getLocalisedName(spec, '', langCode);
    //                 opt.value = spec.id;
                    
    //                 filter.options.add(opt);
    //             }
    //         }
            
            
    //     }catch(Exception e){
    //         System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
            
    //     }
    //     return filter;
    // }
    
    /**********************************************************************************************/
    
    
}