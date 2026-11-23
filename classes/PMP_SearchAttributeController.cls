public with sharing class PMP_SearchAttributeController extends PMP_SearchWrapperStore {
    
    public static Map<String , List<Attribute>> getOfferingAttributes (List<String> offeringIds, String langCode){
        
        Map<String,List<Types>> offCatMap = new Map<String , List<Types>>();
        Map<String,PMP_Category__c> catMap = new Map<String,PMP_Category__c>();
        
            
        List<PMP_Category__c> topLevelCat = [SELECT Id,Name,PMP_Category_Japanese_Nm__c,PMP_Category_Chinese_Nm__c,PMP_Partner_Product_Category_Cd__c FROM PMP_Category__c 
                                             WHERE PMP_Partner_Product_Parent_Category_Cd__c =:PMP_StaticConstants_Partner.SOLUTION_MARKETPLACE_HIERARCHY AND PMP_Active_Ind__c=true];
        
        for(PMP_Category__c cat:topLevelCat){
            catMap.put(cat.PMP_Partner_Product_Category_Cd__c, cat);
        }
        
        List<PMP_Partner_Offering_Category__c> offCatList = [SELECT PMP_Offering_Id__c, PMP_Category_Id__c, PMP_Category_Id__r.Name,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,
                                                             PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.Type__c, PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c, 
                                                             PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c,PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c ,PMP_Category_Id__r.PMP_Parent_Category_Id__c
                                                             FROM PMP_Partner_Offering_Category__c WHERE PMP_Offering_Id__c in :offeringIds AND PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c !=null
                                                             AND PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c !=null AND PMP_Category_Id__r.PMP_Active_Ind__c = true 
                                                             ORDER BY PMP_Category_Id__r.PMP_Category_Display_Sequence_Nbr__c NULLS LAST];
        
        Map<String,Types> catTypeMap = new Map<String,Types>();
        for (PMP_Partner_Offering_Category__c offCat : offCatList){
            
            Types type = new Types();
            type.id = offCat.PMP_Category_Id__c;
            type.parentId = offCat.PMP_Category_Id__r.PMP_Parent_Category_Id__c;
            type.name = PMP_SearchUtilityController.getLocalisedName(offCat, '', langCode);
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
            }
            else
            {
                offCatMap.get(offCat.PMP_Offering_Id__c).add(type); 
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
                        type.name = catTypeMap.get(type.parentId).name+' – '+type.name;
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
                    
                    if (!attMap.containsKey(type.ancestor))
                    {
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
    }
    
    public static Map<String, List<Attribute>> getPartnerAttributes(List<String> partnerIds, String langCode){
        
        Map<String,PMP_Category__c> catMap = new Map<String,PMP_Category__c>();
        List<PMP_Category__c> topLevelCat = [SELECT Id,Name,PMP_Category_Japanese_Nm__c,PMP_Category_Chinese_Nm__c,PMP_Partner_Product_Category_Cd__c FROM PMP_Category__c 
                                             WHERE PMP_Partner_Product_Parent_Category_Cd__c =:PMP_StaticConstants_Partner.SOLUTION_MARKETPLACE_HIERARCHY AND PMP_Active_Ind__c=true];
        
        for(PMP_Category__c cat:topLevelCat){
            catMap.put(cat.PMP_Partner_Product_Category_Cd__c, cat);
        }
        
        Map<String,List<Attribute>> partnerCatMap = new Map<String , List<Attribute>>();
        Map<String, List<Types>> partnerTypeMap = new Map<String, List<Types>>();
        
        List<PMP_Partner_Category__c> partnerCatList = [SELECT PMP_Category_Id__c, PMP_Partner_Id__c,PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,
                                                        PMP_Category_Id__r.PMP_Category_Japanese_Nm__c,PMP_Category_Id__r.Name,PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c 
                                                        FROM PMP_Partner_Category__c WHERE PMP_Partner_Id__c in:partnerIds AND PMP_Category_Id__r.PMP_Active_Ind__c =true 
                                                        ORDER BY PMP_Category_Id__r.PMP_Category_Display_Sequence_Nbr__c NULLS LAST];
        if(!partnerCatList.isEmpty()){
            //Modified on 31-Oct-2019
            for(PMP_Partner_Category__c cat : partnerCatList){
                
                Types type = new Types();
                type.id = cat.PMP_Category_Id__c;
                type.name = PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);
                type.ancestor = cat.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c.split('\\|')[0];
                
                if(!partnerTypeMap.containsKey(cat.PMP_Partner_Id__c)){
                    List<Types> types = new List<Types>();
                    types.add(type);
                    partnerTypeMap.put(cat.PMP_Partner_Id__c, types);
                }else{
                    partnerTypeMap.get(cat.PMP_Partner_Id__c).add(type);
                }                    	
            }
            
            for(String partnerId : partnerTypeMap.keySet()){
                Map<String , Attribute> attMap = new Map<String ,Attribute>();
                
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
                partnerCatMap.put(partnerId, catAttributes);
            }
            
        }
        
        return partnerCatMap;
    }
    
    
}