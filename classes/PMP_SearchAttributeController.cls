public with sharing class PMP_SearchAttributeController extends PMP_SearchWrapperStore {
    //IPA2.0:US-4497-1631_OfferingEOL
    /*public static Map<String , List<Attribute>> getOfferingAttributes (List<String> offeringIds, String langCode){
        
        Map<String,List<Types>> offCatMap = new Map<String , List<Types>>();
        Map<String,PMP_Category__c> catMap = new Map<String,PMP_Category__c>();
        List<PMP_Category__c> topLevelCat = new List<PMP_Category__c>(); 
        if(Schema.sObjectType.PMP_Category__c.isAccessible()){ //ApexCRUDViolation Fix
        topLevelCat = [SELECT Id,Name,PMP_Category_Japanese_Nm__c,PMP_Category_Chinese_Nm__c,PMP_Partner_Product_Category_Cd__c FROM PMP_Category__c 
                                             WHERE PMP_Partner_Product_Parent_Category_Cd__c =:PMP_StaticConstants_Partner.SOLUTION_MARKETPLACE_HIERARCHY AND PMP_Active_Ind__c=true];
        }
        for(PMP_Category__c cat:topLevelCat){
            catMap.put(cat.PMP_Partner_Product_Category_Cd__c, cat);
        }
        List<PMP_Partner_Offering_Category__c> offCatList = new List<PMP_Partner_Offering_Category__c> ();
        if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){ //ApexCRUDViolation Fix
        offCatList = [SELECT PMP_Offering_Id__c, PMP_Category_Id__c, PMP_Category_Id__r.Name,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,
                                                             PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.Type__c, PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c, 
                                                             PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c,PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c ,PMP_Category_Id__r.PMP_Parent_Category_Id__c
                                                             FROM PMP_Partner_Offering_Category__c WHERE PMP_Offering_Id__c in :offeringIds AND PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c !=null
                                                             AND PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c !=null AND PMP_Category_Id__r.PMP_Active_Ind__c = true 
                                                             ORDER BY PMP_Category_Id__r.PMP_Category_Display_Sequence_Nbr__c NULLS LAST];
        }
        
        Map<String,Types> catTypeMap = new Map<String,Types>();
        for (PMP_Partner_Offering_Category__c offCat : offCatList){
            
            Types type = new Types();
            type.id = offCat.PMP_Category_Id__c;
            type.parentId = offCat.PMP_Category_Id__r.PMP_Parent_Category_Id__c;
            type.name = PMP_SearchUtilityController.getLocalisedName(offCat, '', langCode);
            type.englishName = PMP_SearchUtilityController.getLocalisedName(offCat, '', 'en_US');
            type.ancestor = offcat.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c.split('\\|')[0];
            type.ancestorId = offcat.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c;
            //Used in Compare Products
            type.secondTierCat = false;
            if(offCat.PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c!=null){
                List<String> ancestors = offCat.PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c.split('\\|');
                if(offCat.PMP_Category_Id__r.Type__c == 'Category' && ancestors.size()==2){
                    type.secondTierCat=true;
                    type.searchParams = new SearchParams();
                    type.searchParams.cat = type.Id;
                    type.searchParams.type = PMP_StaticConstants_Partner.product;
                }
            }
            catTypeMap.put(offCat.PMP_Category_Id__c,type);
            //Changes End
            //
            if (!offCatMap.containsKey(offCat.PMP_Offering_Id__c))
            {
                List<Types> typeList= new List<Types>();
                typeList.add(type);
                offCatMap.put(offCat.PMP_Offering_Id__c, typeList);
                offCatMap.get(offCat.PMP_Offering_Id__c).sort();
            }
            else
            {
                offCatMap.get(offCat.PMP_Offering_Id__c).add(type); 
                offCatMap.get(offCat.PMP_Offering_Id__c).sort();
            }
        }
        
        Map<String , List<Attribute>> offAttMap = new Map<String ,List<Attribute>>();
        for (String off : offCatMap.keySet())
        {
            Map<String , Attribute> attMap = new Map<String ,Attribute>();
            for (Types type : offCatMap.get(off))
            {
                
                if(type.ancestor==PMP_StaticConstants_Partner.PIM_CATEGORY_ID){
                    if(type.ancestorId.split('\\|').size()==2 && catTypeMap.containsKey(type.parentId)){
                       
                        type.parentName = catTypeMap.get(type.parentId).name; // US759365  
                          
                        if (!attMap.containsKey(type.ancestor))
                        {
                            Attribute att= new Attribute();
                            if(catMap.containsKey(type.ancestor)){
                                att.name = PMP_SearchUtilityController.getLocalisedName(catMap.get(type.ancestor), PMP_StaticConstants_Partner.CAT_NAME_FIELD,langCode);
                            }
                            att.types = new List<Types>();
                            att.types.add(type);
                            attMap.put(type.ancestor , att);
                        }
                        else
                        {
                            attMap.get(type.ancestor).types.add(type);
                        }
                    }
                }else{
                    
                    if(!attMap.containsKey(type.ancestor)) {
                        
                        Attribute att= new Attribute();
                        if(catMap.containsKey(type.ancestor)){
                            att.name = PMP_SearchUtilityController.getLocalisedName(catMap.get(type.ancestor), PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                        }
                        att.types = new List<Types>();
                        att.types.add(type);
                        attMap.put(type.ancestor , att);
                    }
                    else
                    {
                        attMap.get(type.ancestor).types.add(type);
                    }
                }
            }
            //Code to sequence the offering card Attributes
            List<Attribute> catAttributes = new List<Attribute>();
            List<String> catOrder = PMP_StaticConstants_Partner.catOrder;
            for(String cat: catOrder){
                if(attMap.containsKey(cat)){
                    catAttributes.add(attMap.get(cat));
                }
            }
            //Changes End
            offAttMap.put(off , catAttributes);
        }
      
        return offAttMap;
    }*/
    
    public static Map<String, List<Attribute>> getPartnerAttributes(List<String> partnerIds, String langCode){
        
        Map<String,PMP_Category__c> catMap = new Map<String,PMP_Category__c>();
        List<PMP_Category__c> topLevelCat = [SELECT Id,Name,PMP_Category_Japanese_Nm__c,PMP_Category_Chinese_Nm__c,PMP_Partner_Product_Category_Cd__c FROM PMP_Category__c 
                                             WHERE PMP_Partner_Product_Parent_Category_Cd__c =:PMP_StaticConstants_Partner.SOLUTION_MARKETPLACE_HIERARCHY AND PMP_Active_Ind__c=true];
        
        for(PMP_Category__c cat:topLevelCat){
            catMap.put(cat.PMP_Partner_Product_Category_Cd__c, cat);
        }
        
        Map<String,List<Attribute>> partnerCatMap = new Map<String , List<Attribute>>();
        Map<String, List<Types>> partnerTypeMap = new Map<String, List<Types>>();
        List<PMP_Partner_Category__c> partnerCatList = new List<PMP_Partner_Category__c>();
        if(Schema.sObjectType.PMP_Partner_Category__c.isAccessible()){ //ApexCRUDViolation Fix

        partnerCatList = [SELECT PMP_Category_Id__c, PMP_Partner_Id__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,
                                                        PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,PMP_Category_Id__r.Name,PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c 
                                                        FROM PMP_Partner_Category__c WHERE PMP_Partner_Id__c in:partnerIds AND PMP_Category_Id__r.PMP_Active_Ind__c=true 
                                                        ORDER BY PMP_Category_Id__r.PMP_Category_Display_Sequence_Nbr__c NULLS LAST];
        }
        //Market place 2.0 Changes for Disti Quick Card Requirement Start
        //Modified as part of OPID Restructure : Removing PMP_Account_Id__r.Core_IPA_Partner_Role__c from query
        for(PMP_Company__c comp : [SELECT Id, PMP_Is_Distributor_Ind__c,/*PMP_Disti_Country_Coverage_Txt__c,*/PMP_Disti_Sys_Solutions_Nm__c,PMP_Disti_Components_Nm__c,
                                (SELECT PMP_Category_Id__c, PMP_Partner_Id__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,
                                PMP_Category_Id__r.Name,PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c FROM Partner_Industry_Applications__r WHERE PMP_Category_Id__r.PMP_Active_Ind__c =true 
                                ORDER BY PMP_Category_Id__r.PMP_Category_Display_Sequence_Nbr__c NULLS LAST),
                                   //PMP_Account_Id__r.Core_IPA_Partner_Role__c,-- not refered anywhere and has no impact in removong it
                                (SELECT PMP_Company_Id__c,PMP_Specification_Id__c, PMP_Specification_Id__r.Name,PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,
                                PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c, PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c, 
                                PMP_Specification_Id__r.PMP_Parent_Specification_Id__c FROM Company_Regions__r WHERE PMP_Specification_Id__r.PMP_Active_Ind__c = true ORDER BY PMP_Specification_Id__r.Name)
                                FROM PMP_Company__c WHERE Id IN:partnerIds]
        ){
            partnerCatMap.put(comp.Id, new List<Attribute>());
               
               if(comp.PMP_Is_Distributor_Ind__c){
                    
                   if(comp.PMP_Disti_Components_Nm__c != NULL) { //For Disti components 
                       Attribute att = new Attribute();
                       att.name = System.Label.PMP_Distributor_Components;
                       Types ty = new Types();
                       String compo='';
                       if(comp.PMP_Disti_Components_Nm__c !=null){
                            List<String> str=comp.PMP_Disti_Components_Nm__c.split(';');
                            compo = String.join(str, ', ' );
                       }
                       ty.name = compo;
                   //    ty.name = comp.PMP_Disti_Components_Nm__c;
                       att.types = new List<Types> { ty };
                       partnerCatMap.get(comp.Id).add(att);
                   }
                   
                   if(comp.PMP_Disti_Sys_Solutions_Nm__c != NULL) { //For Disti solutions & systems 
                       Attribute att = new Attribute();
                       att.name = System.Label.PMP_Distributor_System_and_Solutions;
                       Types ty = new Types();
                       String compo='';
                       if(comp.PMP_Disti_Sys_Solutions_Nm__c !=null){
                            List<String> str=comp.PMP_Disti_Sys_Solutions_Nm__c.split(';');
                            compo = String.join(str, ', ' );
                       }
                       ty.name = compo;
                //       ty.name = comp.PMP_Disti_Sys_Solutions_Nm__c;
                       att.types = new List<Types> { ty };
                       partnerCatMap.get(comp.Id).add(att);
                   }
                   
                   
                   /*if(comp.PMP_Disti_Country_Coverage_Txt__c != NULL) { //For Country Coverage
                       Attribute att = new Attribute();
                       att.name = System.Label.PMP_Country_Coverage;
                       Types ty = new Types();
                       String compo='';
                       if(comp.PMP_Disti_Country_Coverage_Txt__c !=null){
                            List<String> str=comp.PMP_Disti_Country_Coverage_Txt__c.split(';');
                            compo = String.join(str, ', ' );
                       }
                       ty.name = compo;
                       ty.name = comp.PMP_Disti_Country_Coverage_Txt__c;
                       att.types = new List<Types> { ty };
                       partnerCatMap.get(comp.Id).add(att);
                   }*/
               }
               else {
                   
                   Attribute attribute = new Attribute();
                   attribute.name = 'Regional Coverage';
                   attribute.types = new List<Types>();
                   
                   for(PMP_Company_Region__c region : comp.Company_Regions__r) {
                       
                       Types ty = new Types();
                       ty.name = PMP_SearchUtilityController.getLocalisedName(region, '', langCode);
                       attribute.types.add(ty);
                   }
                   partnerCatMap.get(comp.Id).add(attribute);
                   
                   for(PMP_Partner_Category__c cat : comp.Partner_Industry_Applications__r){
                       
                       Types type = new Types();
                       type.id = cat.PMP_Category_Id__c;
                       type.name = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                       type.englishName = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, 'en_US');
                       if(cat.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c!=null){                      
                       type.ancestor = cat.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c.split('\\|')[0];
                       }
                       if(!partnerTypeMap.containsKey(cat.PMP_Partner_Id__c)){
                           List<Types> types = new List<Types>();
                           types.add(type);
                           partnerTypeMap.put(cat.PMP_Partner_Id__c, types);
                           partnerTypeMap.get(cat.PMP_Partner_Id__c).sort();
                       }else{
                           partnerTypeMap.get(cat.PMP_Partner_Id__c).add(type);
                           partnerTypeMap.get(cat.PMP_Partner_Id__c).sort();
                       }                        
                   }
                   
                   for(String partnerId : partnerTypeMap.keySet()){
                       Map<String, Attribute> attMap = new Map<String ,Attribute>();
                       
                       for(Types type  : partnerTypeMap.get(partnerId)){
                           if (!attMap.containsKey(type.ancestor))
                           {
                               Attribute att= new Attribute();
                               if(catMap.containsKey(type.ancestor)){
                                   att.name = PMP_SearchUtilityController.getLocalisedName(catMap.get(type.ancestor), PMP_StaticConstants_Partner.CAT_NAME_FIELD,langCode);
                               }
                               att.types = new List<Types>();
                               att.types.add(type);
                               attMap.put(type.ancestor , att);
                           }
                           else
                           {
                               attMap.get(type.ancestor).types.add(type);
                           }
                       }
                       //Code to sequence the offering card Attributes
                       List<Attribute> catAttributes = new List<Attribute>();
                       List<String> catOrder = PMP_StaticConstants_Partner.catOrder;
                       for(String cat :catOrder){
                           if(attMap.containsKey(cat)){
                               catAttributes.add(attMap.get(cat));
                           }
                       }
                       //Changes End
                       
                       partnerCatMap.get(comp.Id).addAll(catAttributes);
                   }
               }
               
               
               //Market place 2.0 Changes for Disti Quick Card Requirement End
           } 
        return partnerCatMap;
    }
    
    
    
   
}