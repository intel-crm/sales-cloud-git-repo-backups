/****************************************************************************************************************************************
* Class Name  : PMP_CategoryController 
* Version     : 1.0 
* Created Date: 11-22-2018
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Gireesh                   11/29/2018                    Method 'getOfferingCategoryList' to build tree hierarchy and return offering category list
* Intel - Gireesh                   01/02/2019                    Method 'getOfferingCaregories' to return offering categories for the given offering id
****************************************************************************************************************************************************************/
public with sharing class PMP_CategoryController {
    
    
    @AuraEnabled(cacheable = true)
    /*Get offering Categories based on offeringId */
    public static List<PMP_Partner_Offering_Category__c> getOfferingCaregories(Id offeringId){
        return[Select id,Name,PMP_Category_Id__c,PMP_Ancestor_Category_Cd__c, PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name,
               PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Chinese_Nm__c,
               PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Japanese_Nm__c,
               PMP_Offering_Id__c  ,PMP_Localized_Category_Nm__c,PMP_Offering_Category_External_Key__c,PMP_Category_Id__r.PMP_Active_Ind__c,
               PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c,PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c,
               PMP_Category_Id__r.PMP_Tool_Tip_English_Txt__c,PMP_Category_Id__r.PMP_Tool_Tip_Chinese_Txt__c,
               PMP_Category_Id__r.PMP_Tool_Tip_Japanese_Txt__c,PMP_Category_Id__r.Name,
               PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,PMP_Category_Id__r.PMP_Category_Japanese_Nm__c
               from PMP_Partner_Offering_Category__c
               where PMP_Offering_Id__c = : offeringId];
    }  
    //Added By Sandeep to get Categories for Multiple Offerings
    @AuraEnabled(cacheable = true)
    public static Map<id,List<PMP_Partner_Offering_Category__c>> getOfferingCaregoriesMap(List<Id> offeringIds){
        Map<Id, List<PMP_Partner_Offering_Category__c>> CategoryMap = new Map<Id, List<PMP_Partner_Offering_Category__c>>();
         for(PMP_Partner_Offering__c off : [Select id, name, (Select id,Name,PMP_Category_Id__c,PMP_Ancestor_Category_Cd__c,
               PMP_Offering_Id__c  ,PMP_Localized_Category_Nm__c,PMP_Offering_Category_External_Key__c,PMP_Category_Id__r.PMP_Active_Ind__c
               from Offering_Categories__r) from PMP_Partner_Offering__c 
               where id in : offeringIds])
          {
              if(off.Offering_Categories__r.size()>0)
                 CategoryMap.put(off.id,off.Offering_Categories__r);
          }
          return CategoryMap;
    }
    
   @AuraEnabled(cacheable = true)
    public static List<Core_PMP_OfferingCategory> getOfferingCategoryList(Id offeringId){
        List<PMP_Partner_Offering_Category__c> delOffCat=new List<PMP_Partner_Offering_Category__c>();
        List<Core_PMP_OfferingCategory> offeringCategoryList = new List<Core_PMP_OfferingCategory>();
        Map<String,Core_PMP_OfferingCategory> offeringCategoryMap= new Map<String,Core_PMP_OfferingCategory>();
        Set<Id> offeringIdSet = new Set<Id>();
        List<String> offeringPimCategoryList = new List<String>();
        List<String> offeringPimParentCategoryList = new List<String>();
        
        
        User user = [SELECT LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId()];        
        
        
        List<PMP_Category__c>  offeringCategories=[SELECT Id, Name, PMP_Parent_Category_Id__c,PMP_Partner_Product_Category_Cd__c, 
                                                   PMP_Partner_Product_Parent_Category_Cd__c,
                                                   PMP_Display_Type_Nm__c, PMP_Active_Ind__c, 
                                                   //PMP_Partner_Offering_Category_Dsc__c, 
                                                   PMP_Ancestor_Category_Cd__c, PMP_Ancestor_Category_Nm__c,
                                                   PMP_Business_Segment_Nm__c,
                                                   PMP_Category_Japanese_Nm__c, PMP_Category_Chinese_Nm__c                                                        
                                                   FROM PMP_Category__c where PMP_Active_Ind__c=true
                                                   order by PMP_Category_Display_Sequence_Nbr__c
                                                   
                                                  ]; 
        
        string localeName;
        string localizedNames;
        
        
        if(offeringId!=null){
            PMP_Partner_Offering__c offering = [Select id from PMP_Partner_Offering__c where id =:offeringId Limit 1];
            if(offering!=null){ 
                offeringIdSet.add(offering.Id);
                system.debug('offeringIdSet'+offeringIdSet);
            }
 
            for(PMP_Partner_Offering_Category__c offeringCategory : [Select id,Name,PMP_Category_Id__r.PMP_Active_Ind__c,PMP_Ancestor_Category_Cd__c,PMP_Offering_Id__c,PMP_Offering_Category_External_Key__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c     IN: offeringIdSet]){
                    if(offeringCategory.PMP_Category_Id__c!=null){
                        offeringPimCategoryList.add(offeringCategory.PMP_Offering_Category_External_Key__c);
                    }
                    if(offeringCategory.PMP_Ancestor_Category_Cd__c!=null){
                        string tempStr = offeringCategory.PMP_Ancestor_Category_Cd__c.replace('|',':');
                        List<String> tempList = tempStr.split(':');
                        if(!tempList.isEmpty() && tempList!=null){
                            for(string splitStr:tempList){
                                offeringPimCategoryList.add(splitStr); 
                            }
                        }
                    }
            }

        }
        
        system.debug('offeringPimCategoryList'+offeringPimCategoryList);
        if(!offeringCategories.isEmpty() && offeringCategories!=null){
            for(PMP_Category__c offeringCategory : offeringCategories) 
            {
                
                Core_PMP_OfferingCategory tempOfferingCategory;
                if(user.LocaleSidKey==PMP_StaticConstants_Offering.EN_US)
                {
                    localeName=offeringCategory.Name;
                    
                }
                else if(user.LocaleSidKey==PMP_StaticConstants_Offering.ZH_CN)
                {
                    localeName=offeringCategory.PMP_Category_Chinese_Nm__c;
                    
                }
                else if(user.LocaleSidKey==PMP_StaticConstants_Offering.JA_JP)
                {
                    localeName=offeringCategory.PMP_Category_Japanese_Nm__c;
                    
                }
                
                List<String> localeList = new List<String>();
                if(!String.isEmpty(offeringCategory.Name))
                    localeList.add(offeringCategory.Name);
                if(!String.isEmpty(offeringCategory.PMP_Category_Chinese_Nm__c))
                    localeList.add(offeringCategory.PMP_Category_Chinese_Nm__c);
                
                if(!String.isEmpty(offeringCategory.PMP_Category_Japanese_Nm__c))
                    localeList.add(offeringCategory.PMP_Category_Japanese_Nm__c );
                localizedNames=String.join(localeList, '|');
                
                if(offeringId!=null && offeringPimCategoryList.contains(offeringCategory.PMP_Partner_Product_Category_Cd__c)){
                    tempOfferingCategory=new Core_PMP_OfferingCategory(
                        localeName, offeringCategory.PMP_Partner_Product_Category_Cd__c, offeringCategory.PMP_Partner_Product_Parent_Category_Cd__c, 
                        offeringCategory.PMP_Display_Type_Nm__c, offeringCategory.PMP_Ancestor_Category_Cd__c, offeringCategory.PMP_Ancestor_Category_Nm__c,
                        offeringCategory.PMP_Business_Segment_Nm__c,true,true,offeringCategory.Id,localizedNames,false);
                    system.debug('*****Second Loop******'+tempOfferingCategory);

                    
                }
                else{
                    tempOfferingCategory=new Core_PMP_OfferingCategory(
                        localeName, offeringCategory.PMP_Partner_Product_Category_Cd__c, offeringCategory.PMP_Partner_Product_Parent_Category_Cd__c, 
                        offeringCategory.PMP_Display_Type_Nm__c, offeringCategory.PMP_Ancestor_Category_Cd__c, offeringCategory.PMP_Ancestor_Category_Nm__c,
                        offeringCategory.PMP_Business_Segment_Nm__c,false,false,offeringCategory.Id,localizedNames,false);
                }
                offeringCategoryMap.put(tempOfferingCategory.PIMCategoryId,tempOfferingCategory); 
                
                
            }
            system.debug('*****offeringCategoryMap******'+offeringCategoryMap);
        }
        
        if(!offeringCategoryMap.isEmpty()){
            for(String PIMCategoryId : offeringCategoryMap.keySet()){
                
                //get the parent of the current node and attach the current node to the parent node            
                Core_PMP_OfferingCategory tempChildOffering=offeringCategoryMap.get(PIMCategoryId);
                if(offeringCategoryMap.containsKey(tempChildOffering.PIMParentCategoryId)){
                    Core_PMP_OfferingCategory tempParentOffering=offeringCategoryMap.get(tempChildOffering.PIMParentCategoryId);
                    tempParentOffering.childOfferingCategory.add(tempChildOffering);                
                }
                
                //assign all parent nodes to list
                if(tempChildOffering.PIMParentCategoryId.equals(PMP_StaticConstants_Offering.ROOT_NODE)){
                    
                    offeringCategoryList.add(tempChildOffering);
                    system.debug('*****offeringCategoryList******'+offeringCategoryList);
                    
                }
            }
        }   
        return offeringCategoryList;
    }
    /*************************************************************************** 
* Method Name : getHomePageCategories
* Description : Method to fetch categories on home page
******************************************************************************/
    
    @AuraEnabled(cacheable = true)
    public static PMP_LightningServerResponse getHomePageCategories(string selectedCategory){
        system.debug('*****selectedCategory*****:'+selectedCategory);
        
        Boolean BSUCCESSFUL = true;
        Map < String, Object > uiData = new Map < String, Object > ();
        Map < String, Object > mapErrorInfo = new Map < String, Object > ();
        try{
            final string pimCategory = 'NPP_01_TYPE';
            
            User user = [SELECT LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId()];
            
            List<PMP_Category__c> categoryList = new List<PMP_Category__c>();
            
            if(string.isEmpty(selectedCategory)){
                categoryList=[select Id,PMP_Parent_Category_Id__c,Name,PMP_Category_Chinese_Nm__c,PMP_Partner_Product_Parent_Category_Cd__c,PMP_Category_Japanese_Nm__c,
                              PMP_Category_Image_URL_Txt__c,PMP_Category_Display_Sequence_Nbr__c,
                              PMP_Partner_Offering_Category_Dsc__c,
                              PMP_Category_Chinese_Dsc__c,
                              PMP_Category_Japanese_Dsc__c from PMP_Category__c where PMP_Partner_Product_Parent_Category_Cd__c=:pimCategory ORDER BY PMP_Category_Display_Sequence_Nbr__c];
                system.debug('*****categoryList1*****:'+categoryList);                                  
            }else{
                categoryList = [select Id,PMP_Parent_Category_Id__c,PMP_Parent_Category_Id__r.Name,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,
                                PMP_Category_Image_URL_Txt__c,PMP_Category_Display_Sequence_Nbr__c,
                                PMP_Partner_Offering_Category_Dsc__c,
                                PMP_Category_Chinese_Dsc__c,
                                PMP_Category_Japanese_Dsc__c from PMP_Category__c where PMP_Parent_Category_Id__r.Name=:selectedCategory ORDER BY PMP_Category_Display_Sequence_Nbr__c];
                system.debug('*****categoryList2*****:'+categoryList);
            }
            
            if(user!=null)
                uiData.put('userLocal',user.LocaleSidKey);
            
            uiData.put('categoryList',categoryList);
            
            
            
        }catch(exception ex){
            BSUCCESSFUL = false;
            String sErrorMsg = ex.getMessage();
            mapErrorInfo = PMP_BaseErrorHandler.formatException('Core_PMP_CategoryHomePageController', 'Medium', ex);
        }
        return new PMP_LightningServerResponse(BSUCCESSFUL, mapErrorInfo, uiData);
    }
    
    public class Core_PMP_OfferingCategory {
        
        
        public Core_PMP_OfferingCategory(string categoryName,string PIMCategoryId,string PIMParentCategoryId, string displayType,string ancestorCategoryId,string ancestorCategoryName, string businessSegments,boolean nodeSelected,boolean nodeExpanded,
                                         string recordId, string localizedNames, boolean childMandatoryFlag)
        {           
            this.categoryName = categoryName;
            this.PIMCategoryId = PIMCategoryId;
            this.PIMParentCategoryId = PIMParentCategoryId;
            this.displayType = displayType;
            this.ancestorCategoryId = ancestorCategoryId==null?'':ancestorCategoryId;
            this.ancestorCategoryName=ancestorCategoryName==null?'':ancestorCategoryName;
            this.businessSegments=businessSegments;
            this.recordId=recordId;
            this.localizedNames=localizedNames==null?'':localizedNames;
            
            this.nodeSelected=nodeSelected;
            this.nodeExpanded=nodeExpanded;
            this.highlightClass=false;
            this.childMandatoryFlag = childMandatoryFlag;
            this.childOfferingCategory = new List<Core_PMP_OfferingCategory>();
        }
        
        @AuraEnabled
        @TestVisible public string categoryName {get;set;}
        
        @AuraEnabled
        @TestVisible public string recordId {get;set;}
        
        @AuraEnabled
        @TestVisible public string localizedNames {get;set;}
        
        @AuraEnabled
        @TestVisible public string PIMCategoryId {get;set;}
        
        @AuraEnabled
        @TestVisible public string PIMParentCategoryId {get;set;}
        
        @AuraEnabled
        @TestVisible public string displayType {get;set;}
        
        @AuraEnabled
        @TestVisible public string ancestorCategoryId {get;set;}
        
        @AuraEnabled
        @TestVisible public string ancestorCategoryName {get;set;}
        
        @AuraEnabled
        @TestVisible public boolean nodeExpanded {get;set;}
        
        @AuraEnabled
        @TestVisible public boolean nodeSelected {get;set;}
        
        @AuraEnabled
        @TestVisible public string businessSegments{get;set;}
        
        @AuraEnabled
        @TestVisible public boolean highlightClass{get;set;}
        
        @AuraEnabled
        @TestVisible public boolean childMandatoryFlag{get;set;}//added by raj as part of US621683
        
        @AuraEnabled
        @TestVisible public List<Core_PMP_OfferingCategory> childOfferingCategory {get;set;}
        
    }
    
}