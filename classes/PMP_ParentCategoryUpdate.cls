/****************************************************************************************************************************************
* Class Name  : PMP_ParentCategoryUpdate  
* Version     : 1.0 
* Created Date: 09-11-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Sangeetha Ganta     09/11/2018                    Created for extending Trigger framework to process category business logic methods.
* Infosys - Sangeetha Ganta     02/26/2019                    US247100. Update the Parent Category based on Active Flag values.
*****************************************************************************************************************************************/

public with sharing class PMP_ParentCategoryUpdate 
{
    //Method to update Parent Category with Salesforce Id for the Categories inserted or updated    
    public static void updateParentOnInsert(List<PMP_Category__c> categories)
    {
        //Variable Declaration
        
        List<PMP_Category__c> updateCatList = new List<PMP_Category__c>();
        Map<String,Id> mapParentCategory = new Map<String,Id>();
        
        Set<Id> catIds = new Set<Id>();
        for(PMP_Category__c cat: categories){
            catIds.add(cat.id);
        }
        
            for(PMP_Category__c cat : [Select PMP_Partner_Product_Category_Cd__c,Id,PMP_Partner_Product_Category_Key__c from PMP_Category__c where PMP_Partner_Product_Category_Key__c != null])
            {  
                mapParentCategory.put(cat.PMP_Partner_Product_Category_Key__c,cat.Id);
            }
           
            for(PMP_Category__c cat:[Select PMP_Partner_Product_Category_Cd__c,Id,PMP_Parent_Category_Id__c,PMP_Active_Ind__c,PMP_Partner_Product_Parent_Category_Cd__c from PMP_Category__c where id in :catIds])
            {
               
                //Setting the Parent Category only to active categories
                if(cat.PMP_Partner_Product_Parent_Category_Cd__c!= null && cat.PMP_Partner_Product_Parent_Category_Cd__c!='' )
                {
                    if(cat.PMP_Active_Ind__c == true)
                    {
                        String key = (cat.PMP_Partner_Product_Parent_Category_Cd__c).toLowerCase();
                        cat.PMP_Parent_Category_Id__c= mapParentCategory.get(key);
                        updateCatList.add(cat);
                        // System.debug(updateCatList);
                    }
                    else
                    {
                        cat.PMP_Parent_Category_Id__c = null;
                        updateCatList.add(cat); //Setting the parent category to null for all the inactive categories 
                        }
                    
          
                }
                
            }   
            
            if(updateCatList.size()>0){
                    PMP_CategoryTriggerHandler.triggerSwitch = false;
                    if (Schema.sObjectType.PMP_Category__c.isUpdateable()) {
                        update updateCatList;
                    }
                  	PMP_CategoryTriggerHandler.triggerSwitch = true;
            }
            
        
    }
    
}