public with sharing class OptionProductController {
    
   /*
 @AuraEnabled(cacheable=true)
        public static Map<String,List<String>> getProductOptions(Id prodId) {
           List<SBQQ__ProductOption__c> productOptions =[Select Id, SBQQ__Type__c, SBQQ__ConfiguredSKU__c,SBQQ__ConfiguredSKU__r.Name,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__c, SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c from SBQQ__ProductOption__c where SBQQ__Type__c='Related Product'and SBQQ__ConfiguredSKU__c=:prodId and SBQQ__OptionalSKU__r.Name!=null and SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__c != NULL];
        
                    //List<SBQQ__ProductOption__c> productOptions =[Select SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__c from SBQQ__ProductOption__c where SBQQ__Type__c='Related Product'and SBQQ__ConfiguredSKU__c=:prodId and SBQQ__OptionalSKU__r.Name!=null and SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__c != NULL];
           system.debug(productOptions);
            List<String> pids=new List<string>();
            Map<String,Id> oids=new Map<String,Id>();
            for(SBQQ__ProductOption__c c :productOptions){
              pids.add(c.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c);
                oids.put(c.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c,c.Id);
                
            }
          
         pids.sort();
            

  
        
           
            system.debug(pids);
         system.debug(oids);
            for (Integer i = 0; i < pids.size(); i++) {
                if(pids[i]!=null){
    String pid = pids[i];
                   pid=pid+'%'+oids.get(pid); 
    pid = pid.replaceAll('^\\d+', '');
                 
    pids[i] = pid;
                }
}


system.debug(pids);
           
           
            Map<String,List<String>> mapValues = new Map<String,List<String>>();
            mapValues.put('productOptions',pids);
    return mapValues;
        }*/
    
    
    @AuraEnabled(cacheable=true)
public static Map<String, List<String>> getProductOptions(Id prodId) {
    List<SBQQ__ProductOption__c> productOptions = [SELECT Id, SBQQ__Type__c, SBQQ__ConfiguredSKU__c, SBQQ__ConfiguredSKU__r.Name, SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c FROM SBQQ__ProductOption__c WHERE SBQQ__Type__c='Related Product' AND SBQQ__ConfiguredSKU__c=:prodId AND SBQQ__OptionalSKU__r.Name != null AND SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__c != NULL];

    List<String> pids = new List<String>();
    List<Id> oids = new List<Id>();

    for (SBQQ__ProductOption__c c : productOptions) {
        pids.add(c.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c);
        oids.add(c.Id);
    }
    for (Integer i = 0; i < pids.size(); i++) {
        if(pids[i]!=null){
    String pid = pids[i];
                   pid=pid+'%'+oids[i];
            pids[i]=pid;
        }
        
    }

    // Custom sorting logic
    pids.sort();
    pids.sort(new CustomComparator());

    // Now pids will be sorted as desired
    System.debug(pids);
     for (Integer i = 0; i < pids.size(); i++) {
         if(pids[i]!=null){
    String pid = pids[i];
                
    pid = pid.replaceAll('^\\d+', '');
                 
    pids[i] = pid;
                }
}


system.debug(pids);
           
           
            Map<String,List<String>> mapValues = new Map<String,List<String>>();
            mapValues.put('productOptions',pids);
    return mapValues;

    
}

public class CustomComparator implements Comparator<String> {
    public Integer compare(String s1, String s2) {
        List<String> parts1 = s1.split(' ', 2);
        List<String> parts2 = s2.split(' ', 2);
        system.debug(parts1);
        system.debug(parts2);

        if (parts1.size() == 2 && parts2.size() == 2) {
            String numericPart1 = parts1[0].trim();
            String numericPart2 = parts2[0].trim();
            Integer numericValue1 = numericPart1.isNumeric() ? Integer.valueOf(numericPart1) :numericPart1=='Discontinued'? 9999999:999999;
            Integer numericValue2 = numericPart2.isNumeric() ? Integer.valueOf(numericPart2) :numericPart2 =='Discontinued'? 9999999:999999;

            if (numericValue1 != numericValue2) {
                return numericValue1 - numericValue2;
            } else {
                return parts1[1].compareTo(parts2[1]);
            }
        } else {
            return s1.compareTo(s2);
        }
   


    
}
}
}