public class PMP_OfferingCategoryTaxonomy extends PMP_SearchWrapperStore{
    
    // public static Map<String,Taxonomy> getOfferingTaxonomy(String langcode, String section) {
        
    //      Map<string,Taxonomy> response= new Map<string,Taxonomy>();
        
    //     Taxonomy taxanomy = new Taxonomy();
    //     taxanomy.name = PMP_StaticConstants_Partner.taxonomyLabelMapNew.get(section);
    //     taxanomy.apiName ='PMP_Category__c';
    //     taxanomy.label = PMP_StaticConstants_Partner.taxonomyLabelMap.get(section);
    //     taxanomy.englishLabel = PMP_StaticConstants_Partner.taxonomyLabelEnglishMap.get(section); // Added as part of TWC1824-3754
    //     taxanomy.viewAllLabel = PMP_StaticConstants_Partner.taxonomyCtaLabelMap.get(section);
    //     taxanomy.svgIconUrl = null;
    //     taxanomy.topLevelIds = new List<String>();
    //     taxanomy.records=new Map<String,TaxonomyRecord>();
    //     if(section=='offeringCategories'){
    //         taxanomy.filterDisplayType='large-data'; }
        
    //     // taxanomy.records=new Map<id,TaxonomyRecord>();
    //     //Learn More URL Logic
    //     String learnMoreUrlAPI = PMP_SearchUtilityController.getFieldApiName('PMP_Learn_More_URL__mdt', 'URL', langCode);
    //     if(String.isEmpty(learnMoreUrlAPI)){
    //         learnMoreUrlAPI = 'PMP_Learn_More_English_Url__c';
    //     }
    //     Map<String,String> learnMoreUrlMap = new Map<String,String>();        
    //     // To get all featured category Pim Ids
    //     for (PMP_Learn_More_URL__mdt learnMoreUrls:[select PMP_PIM_Category_Id__c,PMP_Learn_More_English_Url__c,PMP_Learn_More_Chinese_Url__c,PMP_Learn_More_Japanese_Url__c from PMP_Learn_More_URL__mdt where PMP_Learn_More_English_Url__c != null]){
    //         learnMoreUrlMap.put(learnMoreUrls.PMP_PIM_Category_Id__c, (String)learnMoreUrls.get(learnMoreUrlAPI));
    //     }
        
    //     Map<String, Taxonomy> specTaxonomyMap = new Map<String, Taxonomy>();
    //     specTaxonomyMap.put(section, taxanomy);
    //     List<PMP_Category__c> productCategories = new List<PMP_Category__c>();
    //     List<PMP_Product_Categories_Images__mdt> metaDataList = new List<PMP_Product_Categories_Images__mdt>();
    //     Map<String,String> metadataMap = new Map<String,String>();
        
    //     String pimId = PMP_StaticConstants_Partner.taxonomyPimIdMap.get(section);
    //     pimId = '%' + pimId + '%';
    //     System.debug('pimId - Prod Issue: '+pimId);
        
    //     Map<String, TaxonomyRecord> specTaxRecordMap = new Map<String, TaxonomyRecord>();
    //     Map<String, TaxonomyRecord> finalMap = new Map<String, TaxonomyRecord>();
        
    //     try{
    //         // if(PMP_Category__c.SObjectType.getDescribe().isAccessible()){
            
    //         productCategories = [SELECT id, Name, PMP_Partner_Product_Category_Cd__c,
    //                              PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Product_Parent_Category_Cd__c,
    //                              PMP_Parent_Category_Id__c,PMP_Partner_Offering_Category_Dsc__c,PMP_Category_Chinese_Dsc__c,PMP_Category_Japanese_Dsc__c,
    //                              (SELECT id from Offering_Categories__r
    //                               where PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published AND PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = FALSE
    //                               AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY AND PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY AND
    //                               PMP_Offering_Id__r.PMP_Company_Id__r.PMP_Benefit_Update_Ind__c=False limit 1)
    //                              from PMP_Category__c
    //                              where PMP_Active_Ind__c = true AND PMP_Ancestor_Category_Cd__c like :pimId 
    //                              ORDER BY Name];
    //         // }
            
    //         metaDataList = [select URL__c,label,PIM_Category_Id__c from PMP_Product_Categories_Images__mdt where PIM_Category_Id__c != null]; 
            
    //         List<PMP_Category__c> finalList = new List<PMP_Category__c>();
            
    //         for(PMP_Category__c cat: productCategories){
    //             if(cat.Offering_Categories__r.size() > 0){
    //                 finalList.add(cat);
    //             }
    //         }
    //         for(PMP_Product_Categories_Images__mdt md : metaDataList){
    //             metadataMap.put(md.PIM_Category_Id__c,md.URL__c);
    //         }
    //         system.debug('catlist size : ' + finalList.size());
    //         for(PMP_Category__c cat : finalList){
    //             System.debug('cat.PMP_Partner_Product_Parent_Category_Cd__c --> PROD Issue'+cat.PMP_Partner_Product_Parent_Category_Cd__c);
    //             TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
    //             if(cat.PMP_Partner_Product_Parent_Category_Cd__c == PMP_StaticConstants_Partner.taxonomyPimIdMap.get(section)){
    //                 taxanomy.topLevelIds.add(cat.Id);
    //             }else{
    //                 taxonomyRecord.parentId= cat.PMP_Parent_Category_Id__c;
    //             }
                
                
    //             taxonomyRecord.label = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
    //             taxonomyRecord.englishLabel = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, PMP_StaticConstants_Partner.EN_US); // Added as part of TWC1824-3754
    //             //Add getLoacalized logic for aggregate results;
    //             taxonomyRecord.viewAllLabel = System.Label.PMP_ViewAll + ' ' + (taxonomyRecord.label).toLowercase();
    //             taxonomyRecord.id=cat.id;
                
    //             //copy deck changes                
    //             if(section == 'offeringCategories'){
    //                 taxonomyRecord.description = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_DESC_FIELD, langCode);                    
    //             }               
    //             else{
    //                 taxonomyRecord.description =System.Label.PMP_L2_Offering_Marquee_Subtitle +' '+ PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
    //             }
                
    //             if(String.isBlank(taxonomyRecord.description)) {
    //                 String des = System.Label.PMP_L2_Offering_Marquee_Subtitle +' '+ PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode); 
    //                 taxonomyRecord.description = des + ' ' + (section == 'offeringCategories' ? (System.Label.PMP_CreateOffering_Solutions).toLowercase() : '');
    //             }
                
    //             taxonomyRecord.children= new List<String>();
    //             taxonomyRecord.svgIconUrl = metadataMap.get(cat.PMP_Partner_Product_Category_Cd__c);
                
    //             taxonomyRecord.taxonomy = taxanomy.name;
                
    //             if(PMP_StaticConstants_Partner.taxonomyTopLevelListMap.get(section).contains(cat.PMP_Partner_Product_Category_Cd__c)){
    //                 taxonomyRecord.featured = true;
    //             }else{
    //                 taxonomyRecord.featured = false;
    //             }
                
    //             specTaxRecordMap.put(cat.id,taxonomyRecord);
                
    //             if(learnMoreUrlMap.containsKey(cat.PMP_Partner_Product_Category_Cd__c)){
    //                 taxonomyRecord.learnMoreUrl = learnMoreUrlMap.get(cat.PMP_Partner_Product_Category_Cd__c);
    //             }
                
                
    //         }
    //          for(TaxonomyRecord tax : specTaxRecordMap.values()){
    //             if(specTaxRecordMap.containsKey(tax.parentId) && tax.parentId!=null){
    //                 specTaxRecordMap.get(tax.parentId).children.add(tax.Id);
                    
    //             }
                
    //         }
    //         system.debug('map sepc tac 2 : ' + specTaxRecordMap.values());
    //         taxanomy.records = specTaxRecordMap;
            
    //     }catch(Exception e){
    //         System.debug('Error in fetching Offering by Category records :' + e);
    //         throw e;//error handling 
            
    //     }
    //     System.debug('response :' + response);
        
    //     //added to populate filter groupings
    //     // taxanomy.searchFiltersGroupings=new List<SearchFiltersGrouping>();
    //     //taxanomy.searchFiltersGroupings=fetchSearchFilterGroupings('offeringApplications');
        
    //     //added to populate filter groupings
    //     taxanomy.searchFiltersGroupings=new List<SearchFiltersGrouping>();
    //     taxanomy.searchFiltersGroupings=fetchSearchFilterGroupings(taxanomy.name);
        
    //     response.put(taxanomy.name, taxanomy);
    //     System.debug('response from method'+response);
        
    //     return response;
    // }
    
    // //for code updation created the duplicate method
    // public static  List<SearchFiltersGrouping> fetchSearchFilterGroupings(String section){
    //     List<PMP_Specifications_Tab_Mapping__mdt> filterList = new List<PMP_Specifications_Tab_Mapping__mdt>();
    //     filterList = [select PMP_Field_Label__c, PMP_Search_Filter_Group_Txt__c, PMP_Search_Filter_Label_Txt__c, 
    //                   PMP_Is_Search_Ind__c, PMP_Is_Create_Offering_Ind__c ,PMP_Filter_Sequence__c 
    //                   from PMP_Specifications_Tab_Mapping__mdt where PMP_Search_Filter_Label_Txt__c != NULL order by PMP_Filter_Sequence__c];
        
    //     System.debug('filterList:'+filterList);        
    //     List<String> techSpecificationList = new List<String>();
    //     List<SearchFiltersGrouping> searchFilterGroup = new List<SearchFiltersGrouping>();
    //     Map<String,List<String>> filtermap = new Map<String,List<String>>(); 
    //     List<String> PIFilters= new List<String>();
    //     PIFilters= PMP_StaticConstants_Partner.PIGroupFilters;
    //     String partnerPIGroup=PMP_StaticConstants_Partner.PIGroup;
        
    //     for(PMP_Specifications_Tab_Mapping__mdt filter : filterList)
    //     {
    //         System.debug('filter.........'+filter.PMP_Search_Filter_Label_Txt__c+'section:'+section);
    //         if(filtermap.get(filter.PMP_Search_Filter_Group_Txt__c) == NULL) {
    //             filtermap.put(filter.PMP_Search_Filter_Group_Txt__c, new List<String>());
    //         }
    //         //Offering Applications
    //         if(section == 'OfferingApplications' && filter.PMP_Search_Filter_Label_Txt__c != 'OfferingApplications' &&
    //            filter.PMP_Search_Filter_Label_Txt__c != 'PartnerIndustries' && filter.PMP_Search_Filter_Label_Txt__c !='PartnerApplications' && 
    //            filter.PMP_Search_Filter_Label_Txt__c !='PartnerSegments' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup)
    //         {
    //             /*if(filtermap.get('Business Filters')!=null && !filtermap.get('Business Filters').contains('OfferingCategories')){
    //                 filtermap.get('Business Filters').add('OfferingCategories');
    //             }   */
                
    //             filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);   
    //         }
    //         if( section == 'OfferingIndustries' && filter.PMP_Search_Filter_Label_Txt__c != 'PartnerIndustries' && 
    //            filter.PMP_Search_Filter_Label_Txt__c !='PartnerSegments' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup && 
    //            filter.PMP_Search_Filter_Label_Txt__c!='OfferingIndustries' && filter.PMP_Search_Filter_Label_Txt__c !='PartnerApplications')
    //         {
    //             /* if(filtermap.get('Business Filters')!=null && !filtermap.get('Business Filters').contains('OfferingCategories')){
    //                 filtermap.get('Business Filters').add('OfferingCategories');
    //                 } */
    //             filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);   
    //         }
    //         if(section == 'PartnerIndustries' && filter.PMP_Search_Filter_Label_Txt__c != 'PartnerIndustries' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup 
    //            && filter.PMP_Search_Filter_Label_Txt__c!='OfferingIndustries' && filter.PMP_Search_Filter_Label_Txt__c != 'OfferingApplications'
    //            && filter.PMP_Search_Filter_Label_Txt__c!='OfferingSegments' && filter.PMP_Search_Filter_Label_Txt__c !='OfferingCategories')
    //         {
    //             filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);   
    //         }
            
    //         if(section == 'PartnerSpecialties' && filter.PMP_Search_Filter_Label_Txt__c != 'PartnerSpecialties' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup && filter.PMP_Search_Filter_Label_Txt__c!='OfferingIndustries' && filter.PMP_Search_Filter_Label_Txt__c !='OfferingCategories')
    //         {
    //             //filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);   
    //             if(PIFilters.Contains(filter.PMP_Search_Filter_Label_Txt__c)){
    //                 if(filtermap.containsKey(partnerPIGroup)){
    //                     filtermap.get(partnerPIGroup).add(filter.PMP_Search_Filter_Label_Txt__c); 
    //                 }
    //                 else{
    //                     filtermap.put(partnerPIGroup,new List<String> {filter.PMP_Search_Filter_Label_Txt__c}); 
    //                 }
    //             }
    //             else
    //             {
    //                 filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c); 
    //             }
                
    //             /*if(filter.PMP_Search_Filter_Label_Txt__c == 'PartnerTier'||filter.PMP_Search_Filter_Label_Txt__c == 'IntelPartnerEvents'){
    //                 filtermap.get('Business Filters').add(filter.PMP_Search_Filter_Label_Txt__c);
    //                 }*/
                
    //         }
    //         if(section == 'PartnerDirectory' && filter.PMP_Search_Filter_Label_Txt__c != 'PartnerDirectory' && 
    //            filter.PMP_Search_Filter_Label_Txt__c!='OfferingIndustries' && filter.PMP_Search_Filter_Label_Txt__c!='OfferingApplications'
    //            && filter.PMP_Search_Filter_Label_Txt__c!='OfferingSegments' && filter.PMP_Search_Filter_Label_Txt__c !='OfferingCategories')//&& filter.PMP_Search_Filter_Label_Txt__c != 'Partner Directory'
    //         {
    //             if(PIFilters.Contains(filter.PMP_Search_Filter_Label_Txt__c)){
    //                 if(filtermap.containsKey(partnerPIGroup)){
    //                     filtermap.get(partnerPIGroup).add(filter.PMP_Search_Filter_Label_Txt__c); 
    //                 }
    //                 else{
    //                     filtermap.put(partnerPIGroup,new List<String> {filter.PMP_Search_Filter_Label_Txt__c}); 
    //                 }
    //             }
    //             else
    //             {
    //                 filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c); 
    //             }
    //             // filtermap.put('DistiBizOrgType',getDistiBizOrg('DistiBizOrgType','').get('DistiBizOrgType').Label);
    //             /* if(filter.PMP_Search_Filter_Label_Txt__c == 'PartnerTier'||filter.PMP_Search_Filter_Label_Txt__c == 'IntelPartnerEvents' || filter.PMP_Search_Filter_Label_Txt__c == 'PartnerSpecialties' ){
    //             filtermap.get('Business Filters').add(filter.PMP_Search_Filter_Label_Txt__c);
    //             }*/
                
    //         }
    //         if(section == 'PartnerSegments' && filter.PMP_Search_Filter_Label_Txt__c != 'OfferingSegments' && 
    //            filter.PMP_Search_Filter_Label_Txt__c !='PartnerSegments' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup 
    //            && filter.PMP_Search_Filter_Label_Txt__c!='OfferingIndustries' && filter.PMP_Search_Filter_Label_Txt__c!='OfferingApplications' && filter.PMP_Search_Filter_Label_Txt__c !='OfferingCategories')
    //         {
    //             //filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);  
    //             if(PIFilters.Contains(filter.PMP_Search_Filter_Label_Txt__c)){
    //                 if(filtermap.containsKey(partnerPIGroup)){
    //                     filtermap.get(partnerPIGroup).add(filter.PMP_Search_Filter_Label_Txt__c); 
    //                 }
    //                 else{
    //                     filtermap.put(partnerPIGroup,new List<String> {filter.PMP_Search_Filter_Label_Txt__c}); 
    //                 }
    //             }
    //             else
    //             {
    //                 filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c); 
    //             }
    //             /* if(filter.PMP_Search_Filter_Label_Txt__c == 'PartnerTier'||filter.PMP_Search_Filter_Label_Txt__c == 'IntelPartnerEvents' || filter.PMP_Search_Filter_Label_Txt__c == 'PartnerSpecialties' ){
    //                 filtermap.get('Business Filters').add(filter.PMP_Search_Filter_Label_Txt__c);
    //             }*/
    //         }
    //         if(section == 'OfferingSegments' && filter.PMP_Search_Filter_Label_Txt__c != 'OfferingSegments' &&
    //            filter.PMP_Search_Filter_Label_Txt__c != 'PartnerIndustries' && filter.PMP_Search_Filter_Label_Txt__c !='PartnerApplications' && 
    //            filter.PMP_Search_Filter_Label_Txt__c !='PartnerSegments' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup && filter.PMP_Search_Filter_Label_Txt__c !='OfferingCategories')
                
    //         {
    //             filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);   
    //         }
            
    //         if(section == 'OfferingCategories' && filter.PMP_Search_Filter_Label_Txt__c != 'PartnerIndustries' 
    //            && filter.PMP_Search_Filter_Label_Txt__c !='PartnerApplications' && filter.PMP_Search_Filter_Label_Txt__c !='PartnerSegments' && filter.PMP_Search_Filter_Group_Txt__c !=partnerPIGroup && filter.PMP_Search_Filter_Label_Txt__c !='OfferingCategories')
    //         {
    //             filtermap.get(filter.PMP_Search_Filter_Group_Txt__c).add(filter.PMP_Search_Filter_Label_Txt__c);   
    //         }
    //     }
        
    //     if(section=='PartnerDirectory') {
        
    //     filtermap.get(partnerPIGroup).add('Country'); 
    //         filtermap.get(partnerPIGroup).add('Distributor');
    //         Integer index=filtermap.get(partnerPIGroup).indexOf('IntelPartnerEvents');
    //         filtermap.get(partnerPIGroup).remove(index);
    //         filtermap.get(partnerPIGroup).add('IntelPartnerEvents'); 
    //         //filtermap.get('Business Filters').add('PartnerTier');
    //         //filtermap.get('Business Filters').add('IntelPartnerEvents');
            
            
    //         //grouplist[index1]=partnerPIGroup;
    //         //grouplist[index2]='Business Filters';
            
            
    //         //filtermap.containsKey('Distributor Product'){
    //         // filtermap.get('Distributor Product').add('Distributor Components');              
    //         // filtermap.get('Distributor Product').add('Distributor Systems & Solutions');  //Partner Segments
    //         // }
    //         //else{
    //         filtermap.put('Distributor Product',new List<String>{'DistributorComponents','DistributorSystems&Solutions'});
    //         // }
            
    //         /*filtermap.get('Business Filters').add('PartnerSegments');  //Partner Segments
    //         filtermap.get('Business Filters').add('PartnerApplications');
    //         filtermap.get(partnerPIGroup).add('Solutions_Software_And_Services_Provider_Type');*/
            
    //         //filtermap.put('Solutions, Software and Services Provider Type',new List<String>{'Solutions, Software and Services Provider Type'});
            
            
            
    //     }
        
    //     /*  if(section == 'PartnerSegments' || section == 'PartnerDirectory' || section=='PartnerSpecialties' || section=='PartnerIndustries'){
    //     filtermap.get('Business Filters').add('PartnerTier');
    //     filtermap.get('Business Filters').add('IntelPartnerEvents');
    //     if(section!='PartnerSpecialties')
    //     filtermap.get('Business Filters').add('PartnerSpecialties');
    //     }*/
                
    //             /* if(section == 'PartnerSegments'){
    //     filtermap.get('Business Filters').add('PartnerApplications'); 
    //     }
        
    //     if(section=='PartnerIndustries' || section=='PartnerSpecialties') {
    //     filtermap.get('Business Filters').add('PartnerSegments');  //Partner Segments
    //     filtermap.get('Business Filters').add('PartnerApplications');
    //     }
    //     if(section=='OfferingApplications' || section=='OfferingIndustries'){
    //     filtermap.get('Business Filters').add('OfferingCategories');  //Partner Segments
    //     }*/
        
        
    //     system.debug('..filtermap Updated..'+filtermap);
    //     List<String> filterSections= new List<String>();
    //     filterSections = PMP_StaticConstants_Partner.groupsByPageMap.get(section);
    //     system.debug('filterSections...'+filterSections);
    //     /* List<String> grouplist= new List<String>();
    //     grouplist.addAll(filtermap.keySet());
    //     Integer BFIndex=-1;
    //     Integer PIIndex=-1;
    //     if(grouplist.contains('Business Filters')){
    //     BFIndex=grouplist.indexOf('Business Filters');
    //     }
    //     if(grouplist.contains(partnerPIGroup)){
    //     PIIndex=grouplist.indexOf(partnerPIGroup);
    //     }
    //     if(BFIndex>PIIndex && BFIndex!=-1 && PIIndex!=-1){
    //     grouplist[BFIndex]=partnerPIGroup;
    //     grouplist[PIIndex]='Business Filters';
    //     }*/
    //     for(String filter : filtermap.keySet())
    //     {
    //         if(filterSections!=null){
    //             for(String sec :filterSections )
    //             {
    //                 if(filter==sec)
    //                 {
    //                     SearchFiltersGrouping wrapper = new SearchFiltersGrouping();
    //                     wrapper.label = filter;
    //                     if(filter=='Business Filters'){
    //                         wrapper.label=System.Label.PMP_L2_Business_Filters;
    //                         wrapper.englishLabel = System.Label.PMP_L2_Business_Filters_English; // Added as part of TWC1824-3754
    //                     }
    //                     if(filter=='Technical Specifications'){
    //                         wrapper.label=System.Label.PMP_L2_Filter_Technical_Specifications;
    //                         wrapper.englishLabel = System.Label.PMP_L2_Filter_Technical_Specifications_English; // Added as part of TWC1824-3754

    //                     }
    //                     if(filter=='Partner Information'){
    //                         wrapper.label=System.Label.PMP_L2_Filter_Partner_Information;
    //                         wrapper.englishLabel = System.Label.PMP_L2_Filter_Partner_Information_English; // Added as part of TWC1824-3754
    //                     }
                        
    //                     if(filter=='Distributor Product'){
    //                         wrapper.label=System.label.PMP_L2_Filter_Distributor_Product;
    //                         wrapper.englishLabel = System.label.PMP_L2_Filter_Distributor_Product_English;// Added as part of TWC1824-3754
    //                     }
    //                     wrapper.filters = filtermap.get(filter);
    //                     searchFilterGroup.add(wrapper);
                        
    //                 }
                    
                    
    //             }
    //         }
            
    //     }
    //     system.debug('..searchFilterGroup....'+searchFilterGroup);
    //     return searchFilterGroup;
        
        
    //     //public static final Map<String, String[]> groupsByPageMap = new Map<String, String[]>{'Offering Categories' => offFilterGroups,'Offering Segments' =>partnerFilterGroups, 'Offering Industries' => offFilterGroups, 'Offering Applications' => offFilterGroups, 'Partner Industries' => partnerFilterGroups,'Partner Directory' => partnerFilterGroups,'Partner Specialties' => partnerFilterGroups,'Partner Segments' =>partnerFilterGroups};        
        
    // }
    

}