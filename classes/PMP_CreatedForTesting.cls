public class PMP_CreatedForTesting extends PMP_SearchWrapperStore{
    
    
    public static void meth(){
        Map<String,TaxonomyRecord> specTaxRecordMap=getTechnicalSpecs('en_US');
        specTaxRecordMap.putAll(specAssList());
        
    }
    
    
    public static Map<string,TaxonomyRecord> getSpecVal(List<PMP_Specification_Value_Association__c> specValueAssocList ){
          Map<String,TaxonomyRecord> specTaxRecordMap = new Map<String, TaxonomyRecord>();
         for(PMP_Specification_Value_Association__c specAss : specValueAssocList){
            TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
            
            //taxonomyRecord.label = PMP_SearchUtilityController.getLocalisedName(specAss, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);//specAss.PMP_Specification_Value_Id__r.Name;
			taxonomyRecord.label=specAss.PMP_Specification_Value_Id__r.Name;
            taxonomyRecord.id=specAss.PMP_Specification_Value_Id__c;
            taxonomyRecord.description = '';
            taxonomyRecord.children= new List<String>();
            //taxonomyRecord.svgIconUrl = metadataMap.get(cat.PMP_Partner_Product_Category_Cd__c);
            taxonomyRecord.parentId=specAss.PMP_Specification_Id__c;
            specTaxRecordMap.put(specAss.PMP_Specification_Value_Id__c, taxonomyRecord);
        }
        return specTaxRecordMap;
       
    }
    
    
    
    
    
    
    
    
 
    
public static Map<string,TaxonomyRecord> getTechnicalSpecs(String langCode){
List<PMP_Specification_Value_Association__c> specValueAssocList = new List<PMP_Specification_Value_Association__c>(); 
        Map<String,TaxonomyRecord> specTaxRecordMap = new Map<String, TaxonomyRecord>();
        Map<String,TaxonomyRecord> specValueTaxRecordMap = new Map<String, TaxonomyRecord>();
        Map<String, Taxonomy> specTaxonomyMap = new Map<String, Taxonomy>();
        Map<string,Taxonomy> response= new Map<string,Taxonomy>();
        List<PMP_Specification__c> specList= new List<PMP_Specification__c>();
        //if(PMP_Specification__c.SObjectType.getDescribe().isAccessible()){
       /*specList = [SELECT id, Name, PMP_Specification_Chinese_Nm__c, PMP_Specification_Japanese_Nm__c,
                                               PMP_Partner_Product_Specification_Id__c, PMP_Product_Parent_Specification_Id__c
                                               , PMP_Ancestor_Specification_Cd__c,PMP_Parent_Specification_Id__c ,
                                               (SELECT id, PMP_Specification_Id__c, PMP_Specification_Value_Id__c,PMP_Specification_Value_Id__r.Name,
                                                PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c
                                                from Specification_SpecValue_Associations__r where PMP_Active_Ind__c = true )
                                               FROM PMP_Specification__c
                                               WHERE PMP_Active_Ind__c = TRUE ];*/
       // }
                
        for(PMP_Specification__c spec : [SELECT id, Name, PMP_Specification_Chinese_Nm__c, PMP_Specification_Japanese_Nm__c,
                                               PMP_Partner_Product_Specification_Id__c, PMP_Product_Parent_Specification_Id__c
                                               , PMP_Ancestor_Specification_Cd__c,PMP_Parent_Specification_Id__c ,
                                               (SELECT id, PMP_Specification_Id__c, PMP_Specification_Value_Id__c,PMP_Specification_Value_Id__r.Name,
                                                PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c
                                                from Specification_SpecValue_Associations__r where PMP_Active_Ind__c = true)
                                               FROM PMP_Specification__c
                                               WHERE PMP_Active_Ind__c = TRUE]){
            if(spec.PMP_Product_Parent_Specification_Id__c == null){
                Taxonomy taxanomy = new Taxonomy();
                taxanomy.name = spec.Name.deleteWhitespace();// added to remove space
                taxanomy.apiName =spec.Id;
                //taxanomy.label = PMP_SearchUtilityController.getLocalisedName(spec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);//spec.Name;
				taxanomy.label=spec.Name;
                //taxanomy.viewAllLabel = PMP_StaticConstants_Partner.taxonomyCtaLabelMap.get(section);
                taxanomy.svgIconUrl = null;
                taxanomy.topLevelIds = new List<Id>();
                taxanomy.records = new Map<String,TaxonomyRecord>();
                if(spec.PMP_Partner_Product_Specification_Id__c=='NPP_Processors'){
                    taxanomy.filterDisplayType='large-data'; 
                }
                specTaxonomyMap.put(spec.Id, taxanomy);
            }
            else{                
                TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
                //taxonomyRecord.label = PMP_SearchUtilityController.getLocalisedName(spec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);//spec.Name;
				taxonomyRecord.label=spec.Name;
                taxonomyRecord.id=spec.Id;
                taxonomyRecord.description = '';
                taxonomyRecord.children= new List<String>();
                //taxonomyRecord.svgIconUrl = metadataMap.get(cat.PMP_Partner_Product_Category_Cd__c);
                taxonomyRecord.parentId=spec.PMP_Parent_Specification_Id__c;
                specTaxRecordMap.put(spec.Id, taxonomyRecord);
            }
            
            /*if(spec.Specification_SpecValue_Associations__r.size() > 0){
                specValueAssocList.addAll(spec.Specification_SpecValue_Associations__r);
            }*/
        }
        
        return specTaxRecordMap;
        
    }
 
    
    
    
    
    public static Map<string,TaxonomyRecord> specAssList(){
                Map<String,TaxonomyRecord> specTaxRecordMap = new Map<String, TaxonomyRecord>();

       List<PMP_Specification_Value_Association__c> specValueAssocList = new List<PMP_Specification_Value_Association__c>(); 
       for(PMP_Specification__c spec : [SELECT id, Name, PMP_Specification_Chinese_Nm__c, PMP_Specification_Japanese_Nm__c,
                                               PMP_Partner_Product_Specification_Id__c, PMP_Product_Parent_Specification_Id__c
                                               , PMP_Ancestor_Specification_Cd__c,PMP_Parent_Specification_Id__c ,
                                               (SELECT id, PMP_Specification_Id__c, PMP_Specification_Value_Id__c,PMP_Specification_Value_Id__r.Name,
                                                PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c
                                                from Specification_SpecValue_Associations__r where PMP_Active_Ind__c = true)
                                               FROM PMP_Specification__c
                                               WHERE PMP_Active_Ind__c = TRUE]){
            
            if(spec.Specification_SpecValue_Associations__r.size() > 0){
                specValueAssocList.addAll(spec.Specification_SpecValue_Associations__r);
            }
        }
        specTaxRecordMap=getSpecVal(specValueAssocList);
    return specTaxRecordMap;       
  }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
public static Map<string,Taxonomy> getTechnicalSpecsTaxonomy(String langCode){


List<PMP_Specification_Value_Association__c> specValueAssocList = new List<PMP_Specification_Value_Association__c>(); 
        Map<String,TaxonomyRecord> specTaxRecordMap = new Map<String, TaxonomyRecord>();
        Map<String,TaxonomyRecord> specValueTaxRecordMap = new Map<String, TaxonomyRecord>();
        Map<String, Taxonomy> specTaxonomyMap = new Map<String, Taxonomy>();
        Map<string,Taxonomy> response= new Map<string,Taxonomy>();
        List<PMP_Specification__c> specList= new List<PMP_Specification__c>();
        //if(PMP_Specification__c.SObjectType.getDescribe().isAccessible()){
       /*specList = [SELECT id, Name, PMP_Specification_Chinese_Nm__c, PMP_Specification_Japanese_Nm__c,
                                               PMP_Partner_Product_Specification_Id__c, PMP_Product_Parent_Specification_Id__c
                                               , PMP_Ancestor_Specification_Cd__c,PMP_Parent_Specification_Id__c ,
                                               (SELECT id, PMP_Specification_Id__c, PMP_Specification_Value_Id__c,PMP_Specification_Value_Id__r.Name,
                                                PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c
                                                from Specification_SpecValue_Associations__r where PMP_Active_Ind__c = true )
                                               FROM PMP_Specification__c
                                               WHERE PMP_Active_Ind__c = TRUE ];*/
       // }
                
        for(PMP_Specification__c spec : [SELECT id, Name, PMP_Specification_Chinese_Nm__c, PMP_Specification_Japanese_Nm__c,
                                               PMP_Partner_Product_Specification_Id__c, PMP_Product_Parent_Specification_Id__c
                                               , PMP_Ancestor_Specification_Cd__c,PMP_Parent_Specification_Id__c ,
                                               (SELECT id, PMP_Specification_Id__c, PMP_Specification_Value_Id__c,PMP_Specification_Value_Id__r.Name,
                                                PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c
                                                from Specification_SpecValue_Associations__r where PMP_Active_Ind__c = true)
                                               FROM PMP_Specification__c
                                               WHERE PMP_Active_Ind__c = TRUE]){
            if(spec.PMP_Product_Parent_Specification_Id__c == null){
                Taxonomy taxanomy = new Taxonomy();
                taxanomy.name = spec.Name.deleteWhitespace();// added to remove space
                taxanomy.apiName =spec.Id;
                //taxanomy.label = PMP_SearchUtilityController.getLocalisedName(spec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);//spec.Name;
				taxanomy.label=spec.Name;
                //taxanomy.viewAllLabel = PMP_StaticConstants_Partner.taxonomyCtaLabelMap.get(section);
                taxanomy.svgIconUrl = null;
                taxanomy.topLevelIds = new List<Id>();
                taxanomy.records = new Map<String,TaxonomyRecord>();
                if(spec.PMP_Partner_Product_Specification_Id__c=='NPP_Processors'){
                    taxanomy.filterDisplayType='large-data'; 
                }
                specTaxonomyMap.put(spec.Id, taxanomy);
            }
            else{                
                TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
                //taxonomyRecord.label = PMP_SearchUtilityController.getLocalisedName(spec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);//spec.Name;
				taxonomyRecord.label=spec.Name;
                taxonomyRecord.id=spec.Id;
                taxonomyRecord.description = '';
                taxonomyRecord.children= new List<String>();
                //taxonomyRecord.svgIconUrl = metadataMap.get(cat.PMP_Partner_Product_Category_Cd__c);
                taxonomyRecord.parentId=spec.PMP_Parent_Specification_Id__c;
                specTaxRecordMap.put(spec.Id, taxonomyRecord);
            }
            
            if(spec.Specification_SpecValue_Associations__r.size() > 0){
                specValueAssocList.addAll(spec.Specification_SpecValue_Associations__r);
            }
        }
        
     
        for(PMP_Specification_Value_Association__c specAss : specValueAssocList){
            TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
            
            //taxonomyRecord.label = PMP_SearchUtilityController.getLocalisedName(specAss, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);//specAss.PMP_Specification_Value_Id__r.Name;
			taxonomyRecord.label=specAss.PMP_Specification_Value_Id__r.Name;
            taxonomyRecord.id=specAss.PMP_Specification_Value_Id__c;
            taxonomyRecord.description = '';
            taxonomyRecord.children= new List<String>();
            //taxonomyRecord.svgIconUrl = metadataMap.get(cat.PMP_Partner_Product_Category_Cd__c);
            taxonomyRecord.parentId=specAss.PMP_Specification_Id__c;
            specTaxRecordMap.put(specAss.PMP_Specification_Value_Id__c, taxonomyRecord);
        }
     //specTaxRecordMap.putAll(getSpecVal(specValueAssocList));
        //Map<String, List<TaxonomyRecords>> taxRecordGrandParentMap = new Map<String, List<TaxonomyRecords>>();
       /* for(TaxonomyRecord tag : specTaxRecordMap.values()){
            
            if(specTaxRecordMap.containsKey(tag.parentId)){
                specTaxRecordMap.get(tag.parentId).children.add(tag.Id);
            }
            
            if(specTaxonomyMap.containsKey(tag.parentId) && tag.parentId!=null){
                specTaxonomyMap.get(tag.parentId).records.put(tag.Id, tag);
                tag.taxonomy = specTaxonomyMap.get(tag.parentId).name;
            }
            else{
                if(specTaxRecordMap.containsKey(tag.parentId) && tag.parentId != null){
                    if(specTaxonomyMap.containsKey(specTaxRecordMap.get(tag.parentId).parentId) ){
                        specTaxonomyMap.get(specTaxRecordMap.get(tag.parentId).parentId).records.put(tag.Id, tag);
                        tag.taxonomy = specTaxonomyMap.get(specTaxRecordMap.get(tag.parentId).parentId).name;
                    }
                }
                //System.debug('specTaxRecordMap.get(tag.parentId).parentId'+specTaxRecordMap.get(tag.parentId).parentId);
                //System.debug('tag.parentId'+tag.parentId);

                if(specTaxRecordMap.containsKey(specTaxRecordMap.get(tag.parentId).parentId) && tag.parentId != null){
                    if(specTaxonomyMap.containsKey(specTaxRecordMap.get(specTaxRecordMap.get(tag.parentId).parentId).parentId)){
                        specTaxonomyMap.get((specTaxRecordMap.get(specTaxRecordMap.get(tag.parentId).parentId).parentId)).records.put(tag.Id, tag);
                        tag.taxonomy = specTaxonomyMap.get((specTaxRecordMap.get(specTaxRecordMap.get(tag.parentId).parentId)).parentId).name;
                    }
                }
            }
            
             
          
        }
        
        for(TaxonomyRecord tag: specTaxRecordMap.values()){
            if(specTaxonomyMap.containsKey(tag.parentId)){
               if(!response.containsKey(tag.parentId)){
                    response.put(specTaxonomyMap.get(tag.parentId).name,specTaxonomyMap.get(tag.parentId));
             } 
            }
            
        }
        
        
        for(PMP_Specification__c spec : specList){
            if(spec.PMP_Ancestor_Specification_Cd__c != null){
               if(spec.PMP_Ancestor_Specification_Cd__c.split('\\|').size() == 1){
                specTaxRecordMap.get(spec.Id).parentId = null;
                }
 
            }
            
            if(spec.PMP_Ancestor_Specification_Cd__c == spec.PMP_Product_Parent_Specification_Id__c){
                if(specTaxonomyMap.containsKey(spec.PMP_Parent_Specification_Id__c)){
                    specTaxonomyMap.get(spec.PMP_Parent_Specification_Id__c).topLevelIds.add(spec.Id);
                }
                
            }
        }
        
        /*for(PMP_Specification_Value_Association__c specVal : specValueAssocList){
            if(specVal.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c == null){
                specTaxRecordMap.get(specVal.PMP_Specification_Value_Id__c).parentId = null;
            }
        }*/
          System.debug('response'+response);

        return response;
		}
    
     public static Map<string,Taxonomy> getTechnicalSpecsTaxonomy1(String langCode){


List<PMP_Specification_Value_Association__c> specValueAssocList = new List<PMP_Specification_Value_Association__c>(); 
        Map<String,TaxonomyRecord> specTaxRecordMap = new Map<String, TaxonomyRecord>();
        Map<String,TaxonomyRecord> specValueTaxRecordMap = new Map<String, TaxonomyRecord>();
        Map<String, Taxonomy> specTaxonomyMap = new Map<String, Taxonomy>();
        Map<string,Taxonomy> response= new Map<string,Taxonomy>();
        List<PMP_Specification__c> specList= new List<PMP_Specification__c>();
        //if(PMP_Specification__c.SObjectType.getDescribe().isAccessible()){
       /*specList = [SELECT id, Name, PMP_Specification_Chinese_Nm__c, PMP_Specification_Japanese_Nm__c,
                                               PMP_Partner_Product_Specification_Id__c, PMP_Product_Parent_Specification_Id__c
                                               , PMP_Ancestor_Specification_Cd__c,PMP_Parent_Specification_Id__c ,
                                               (SELECT id, PMP_Specification_Id__c, PMP_Specification_Value_Id__c,PMP_Specification_Value_Id__r.Name,
                                                PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c
                                                from Specification_SpecValue_Associations__r where PMP_Active_Ind__c = true )
                                               FROM PMP_Specification__c
                                               WHERE PMP_Active_Ind__c = TRUE ];*/
       // }
                
        for(PMP_Specification__c spec : [SELECT id, Name, PMP_Specification_Chinese_Nm__c, PMP_Specification_Japanese_Nm__c,
                                               PMP_Partner_Product_Specification_Id__c, PMP_Product_Parent_Specification_Id__c
                                               , PMP_Ancestor_Specification_Cd__c,PMP_Parent_Specification_Id__c ,
                                               (SELECT id, PMP_Specification_Id__c, PMP_Specification_Value_Id__c,PMP_Specification_Value_Id__r.Name,
                                                PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c,
                                                PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c
                                                from Specification_SpecValue_Associations__r where PMP_Active_Ind__c = true)
                                               FROM PMP_Specification__c
                                               WHERE PMP_Active_Ind__c = TRUE]){
            if(spec.PMP_Product_Parent_Specification_Id__c == null){
                Taxonomy taxanomy = new Taxonomy();
                taxanomy.name = spec.Name.deleteWhitespace();// added to remove space
                taxanomy.apiName =spec.Id;
                //taxanomy.label = PMP_SearchUtilityController.getLocalisedName(spec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);//spec.Name;
				taxanomy.label=spec.Name;
                //taxanomy.viewAllLabel = PMP_StaticConstants_Partner.taxonomyCtaLabelMap.get(section);
                taxanomy.svgIconUrl = null;
                taxanomy.topLevelIds = new List<Id>();
                taxanomy.records = new Map<String,TaxonomyRecord>();
                if(spec.PMP_Partner_Product_Specification_Id__c=='NPP_Processors'){
                    taxanomy.filterDisplayType='large-data'; 
                }
                specTaxonomyMap.put(spec.Id, taxanomy);
            }
            else{                
                TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
                //taxonomyRecord.label = PMP_SearchUtilityController.getLocalisedName(spec, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);//spec.Name;
				taxonomyRecord.label=spec.Name;
                taxonomyRecord.id=spec.Id;
                taxonomyRecord.description = '';
                taxonomyRecord.children= new List<String>();
                //taxonomyRecord.svgIconUrl = metadataMap.get(cat.PMP_Partner_Product_Category_Cd__c);
                taxonomyRecord.parentId=spec.PMP_Parent_Specification_Id__c;
                specTaxRecordMap.put(spec.Id, taxonomyRecord);
            }
            
            if(spec.Specification_SpecValue_Associations__r.size() > 0){
                specValueAssocList.addAll(spec.Specification_SpecValue_Associations__r);
            }
        }
        
     
        for(PMP_Specification_Value_Association__c specAss : specValueAssocList){
            TaxonomyRecord taxonomyRecord= new TaxonomyRecord();
            
            //taxonomyRecord.label = PMP_SearchUtilityController.getLocalisedName(specAss, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);//specAss.PMP_Specification_Value_Id__r.Name;
			taxonomyRecord.label=specAss.PMP_Specification_Value_Id__r.Name;
            taxonomyRecord.id=specAss.PMP_Specification_Value_Id__c;
            taxonomyRecord.description = '';
            taxonomyRecord.children= new List<String>();
            //taxonomyRecord.svgIconUrl = metadataMap.get(cat.PMP_Partner_Product_Category_Cd__c);
            taxonomyRecord.parentId=specAss.PMP_Specification_Id__c;
            specTaxRecordMap.put(specAss.PMP_Specification_Value_Id__c, taxonomyRecord);
        }
    // specTaxRecordMap.putAll(getSpecVal(specValueAssocList));
        //Map<String, List<TaxonomyRecords>> taxRecordGrandParentMap = new Map<String, List<TaxonomyRecords>>();
        for(TaxonomyRecord tag : specTaxRecordMap.values()){
            
            if(specTaxRecordMap.containsKey(tag.parentId)){
                specTaxRecordMap.get(tag.parentId).children.add(tag.Id);
            }
            
            if(specTaxonomyMap.containsKey(tag.parentId) && tag.parentId!=null){
                specTaxonomyMap.get(tag.parentId).records.put(tag.Id, tag);
                tag.taxonomy = specTaxonomyMap.get(tag.parentId).name;
            }
            else{
                if(specTaxRecordMap.containsKey(tag.parentId) && tag.parentId != null){
                    if(specTaxonomyMap.containsKey(specTaxRecordMap.get(tag.parentId).parentId) ){
                        specTaxonomyMap.get(specTaxRecordMap.get(tag.parentId).parentId).records.put(tag.Id, tag);
                        tag.taxonomy = specTaxonomyMap.get(specTaxRecordMap.get(tag.parentId).parentId).name;
                    }
                }
                //System.debug('specTaxRecordMap.get(tag.parentId).parentId'+specTaxRecordMap.get(tag.parentId).parentId);
                //System.debug('tag.parentId'+tag.parentId);

                if(specTaxRecordMap.containsKey(specTaxRecordMap.get(tag.parentId).parentId) && tag.parentId != null){
                    if(specTaxonomyMap.containsKey(specTaxRecordMap.get(specTaxRecordMap.get(tag.parentId).parentId).parentId)){
                        specTaxonomyMap.get((specTaxRecordMap.get(specTaxRecordMap.get(tag.parentId).parentId).parentId)).records.put(tag.Id, tag);
                        tag.taxonomy = specTaxonomyMap.get((specTaxRecordMap.get(specTaxRecordMap.get(tag.parentId).parentId)).parentId).name;
                    }
                }
            }
            
             
          
        }
        
        for(TaxonomyRecord tag: specTaxRecordMap.values()){
            if(specTaxonomyMap.containsKey(tag.parentId)){
               if(!response.containsKey(tag.parentId)){
                    response.put(specTaxonomyMap.get(tag.parentId).name,specTaxonomyMap.get(tag.parentId));
             } 
            }
            
        }
        
        
        for(PMP_Specification__c spec : specList){
            if(spec.PMP_Ancestor_Specification_Cd__c != null){
               if(spec.PMP_Ancestor_Specification_Cd__c.split('\\|').size() == 1){
                specTaxRecordMap.get(spec.Id).parentId = null;
                }
 
            }
            
            if(spec.PMP_Ancestor_Specification_Cd__c == spec.PMP_Product_Parent_Specification_Id__c){
                if(specTaxonomyMap.containsKey(spec.PMP_Parent_Specification_Id__c)){
                    specTaxonomyMap.get(spec.PMP_Parent_Specification_Id__c).topLevelIds.add(spec.Id);
                }
                
            }
        }
        
        for(PMP_Specification_Value_Association__c specVal : specValueAssocList){
            if(specVal.PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c == null){
                specTaxRecordMap.get(specVal.PMP_Specification_Value_Id__c).parentId = null;
            }
        }
          System.debug('response'+response);

        return response;
		}   
    
    
    
    
    
    
    
    
    
    
		  
}