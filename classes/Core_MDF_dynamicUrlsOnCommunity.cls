/********************************************************************
* Clas Name 		: Core_MDF_dynamicUrlsOnCommunity
* Test Class Name  : Core_MDF_dynamicUrlsOnCommunity_Test
* Description		: Configure content for community 
********************************************************************/
Public without sharing class Core_MDF_dynamicUrlsOnCommunity {
    
    Public static List<string> appSupportedLang = Core_MDF_CCP_ConstantClass.CCP_SUPPORTED_LOCALE.split(','); 
    /*This Method is used to fetch content configuration records based on section code passed*/
    @AuraEnabled
    public static List<ContentWrapperObj> getHomeContent(string sectionCode) { // e.g., sectionCode = 'Home_KeyResources_IPA'
        
        List<Core_MDF_Content_Configuration__c> contentConfigsList = new List<Core_MDF_Content_Configuration__c>();
        Core_MDF_DynamicContentGenerator.ContentInputWrapper ContentResultWrap = new Core_MDF_DynamicContentGenerator.ContentInputWrapper();
        List<ContentWrapperObj> resultList = new List<ContentWrapperObj>();
        String loggedinUserLang =''; //Get LoggedIn users language
        try{
            loggedinUserLang = appSupportedLang.contains(UserInfo.getLanguage()) ? UserInfo.getLanguage() : 'en_US' ;
            if(string.isNotBlank(sectionCode) && string.isNotBlank(loggedinUserLang)){
                ContentResultWrap = Core_MDF_DynamicContentGenerator.getData(sectionCode,loggedinUserLang );
            }
            if(ContentResultWrap != null && ContentResultWrap.ContentConfigList != null && !ContentResultWrap.ContentConfigList.isEmpty()){
                for (Core_MDF_Content_Configuration__c  content : ContentResultWrap.ContentConfigList ) {
                    if(string.isNotBlank(ContentResultWrap.labelfieldAPIName) && string.isNotBlank(ContentResultWrap.URLfieldAPIName)){
                        ContentWrapperObj wrapper = new ContentWrapperObj(); 
                        wrapper.contentLabel =  content.get(ContentResultWrap.labelfieldAPIName)!= null ? string.valueOf(content.get(ContentResultWrap.labelfieldAPIName)) : '';
                        wrapper.contentUrl = content.get(ContentResultWrap.URLfieldAPIName)!=null ? string.valueOf(content.get(ContentResultWrap.URLfieldAPIName)) : '' ;
                        wrapper.contentHelpText = content.get(ContentResultWrap.helpTextFieldAPIName)!=null ? string.valueOf(content.get(ContentResultWrap.helpTextFieldAPIName)) : '' ;
                        wrapper.isIconRequired = content.Core_MDF_Is_Icon_Required_ind__c != null && content.Core_MDF_Is_Icon_Required_ind__c == true ? content.Core_MDF_Is_Icon_Required_ind__c : false;
                        wrapper.iconUrl = content.Core_MDF_Icon_URL__c != null ? content.Core_MDF_Icon_URL__c : '';
                        
                        resultList.add(wrapper);
                    }
                }  
            }
        }
        catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return resultList;
    }
    
    
    /***************************************************************************************************** 
Method Name :   getResourceContent
@return     :   list of wrapper
@parameters :   Section Code passed from community 
Description :   This Method is used to fetch content configuration records for resources page based on section code passed 

******************************************************************************************************/
    
    @AuraEnabled
    public static List<sectionWrapper> getResourceContent(string sectionCode) { // e.g., sectionCode = 'Resources_CoMarketingAlignment'
        Map<Id, Set<Id>> headerIdToSubIdSetMap = new Map<Id, Set<Id>>();     
        Map<string,List<Core_MDF_Content_Configuration__c>> subHeaderToContentMap = new Map<string,List<Core_MDF_Content_Configuration__c>>(); 
        Core_MDF_DynamicContentGenerator.ContentInputWrapper ContentResultWrap = new Core_MDF_DynamicContentGenerator.ContentInputWrapper(); 
        List<Core_MDF_Content_Configuration__c> contentConfigsList = new List<Core_MDF_Content_Configuration__c>(); 
        Map<Id, Core_MDF_Content_Configuration__c> idToContentRecMap = new Map<Id, Core_MDF_Content_Configuration__c>(); 
        List<sectionWrapper> sectionWrapList = new List<sectionWrapper>(); // final wrapper list
        
        string SORT_ORDER = 'Core_MDF_Sort_Order_nbr__c';
        string ICON_REQUIRED = 'Core_MDF_Is_Icon_Required_ind__c';
        string ICON_URL = 'Core_MDF_Icon_URL__c';
        string SECTION_LINE_ITEM = 'Section Line Item';
        string SECTION_SUB_HEADER = 'Section SubHeader';
        string loggedinUserLang = '';
        
        loggedinUserLang = appSupportedLang.contains(UserInfo.getLanguage()) ? UserInfo.getLanguage() : 'en_US';  //get loggedIn users langauge
        if(string.isNotBlank(sectionCode) && string.isNotBlank(loggedinUserLang)){
            ContentResultWrap = Core_MDF_DynamicContentGenerator.getData(sectionCode,loggedinUserLang ); 
        }
        string labelfieldAPIName    =  ContentResultWrap.labelfieldAPIName;     //e.g lang->zh_CN , labelfieldAPIName = Core_MDF_Label_zh_CN_txt__c
        string URLfieldAPIName      =  ContentResultWrap.URLfieldAPIName;       //e.g lang->zh_CN , URLfieldAPIName = Core_MDF_Label_zh_CN_URL__c
        string helpTextFieldAPIName =  ContentResultWrap.helpTextFieldAPIName;  //e.g lang->zh_CN , helpTextFieldAPIName = Core_MDF_HelpText_zh_CN_txt__c
        
        try{
            if(ContentResultWrap != null && ContentResultWrap.ContentConfigList != null && !ContentResultWrap.ContentConfigList.isEmpty()){  
                for (Core_MDF_Content_Configuration__c  content : ContentResultWrap.ContentConfigList ) {
                    idToContentRecMap.put(content.Id,content);                 //Key: Content Id Value: Content rec
                    if(content.Core_MDF_Category_nm__c == SECTION_LINE_ITEM){
                        string subHeaderId = content.Core_MDF_Parent_Content_Config_Id__c;
                        if(!subHeaderToContentMap.containsKey(subHeaderId)){//Sub Header
                            subHeaderToContentMap.put(subHeaderId, new List<Core_MDF_Content_Configuration__c>());
                        }
                        subHeaderToContentMap.get(subHeaderId).add(content);  //Key:SubHeader Id Value:Content Line item records
                    }
                    if(content.Core_MDF_Category_nm__c == SECTION_SUB_HEADER){
                        string headerId = content.Core_MDF_Parent_Content_Config_Id__c;
                        string subHeaderId = content.Id;
                        if(!headerIdToSubIdSetMap.containsKey(headerId)){//Header
                            headerIdToSubIdSetMap.put(headerId, new Set<Id>());
                        }
                        headerIdToSubIdSetMap.get(headerId).add(subHeaderId);   //Key:Header Id (ParentId of subHeaderId) Value:set of subHeader Ids
                    }
                }
                
                
                if(!headerIdToSubIdSetMap.isEmpty()){
                    for(string headerId : headerIdToSubIdSetMap.KeySet()){
                        sectionWrapper resultWrapper = new sectionWrapper();
                        list<subSectionWrapper> subSectionWrapList = new list<subSectionWrapper>();
                        resultWrapper.contentHeader = idToContentRecMap.get(headerId).get(labelfieldAPIName) != null ? (string)idToContentRecMap.get(headerId).get(labelfieldAPIName) : '';
                        resultWrapper.sortOrder = idToContentRecMap.get(headerId).get(SORT_ORDER) != null ? Integer.valueOf(idToContentRecMap.get(headerId).get(SORT_ORDER)) : 0;
                        if(!headerIdToSubIdSetMap.get(headerId).isEmpty()){
                            for(string subId : headerIdToSubIdSetMap.get(headerId)){
                                subSectionWrapper subSecWrap = new subSectionWrapper();
                                List<contentLineItemWrapper> contentWrapList = new List<contentLineItemWrapper>();
                                subSecWrap.contentSubHeader = idToContentRecMap.get(subId).get(labelfieldAPIName) != null ? (string)idToContentRecMap.get(subId).get(labelfieldAPIName) : '';
                                subSecWrap.sortOrder = idToContentRecMap.get(subId).get(SORT_ORDER) != null ? Integer.valueOf(idToContentRecMap.get(subId).get(SORT_ORDER)) : 0;
                                subSecWrap.style = (string)idToContentRecMap.get(subId).get('Core_MDF_Style_txt__c');
                                if(subHeaderToContentMap != null && !subHeaderToContentMap.keySet().isEmpty()){
                                    for(Core_MDF_Content_Configuration__c content: subHeaderToContentMap.get(subId)){
                                        contentLineItemWrapper contentWrap = new contentLineItemWrapper();
                                            contentWrap.contentLabel =content.get(labelfieldAPIName) != null ? (string)content.get(labelfieldAPIName) : '';
                                            contentWrap.contentUrl = content.get(URLfieldAPIName) != null ? (string)content.get(URLfieldAPIName) : '';
                                            contentWrap.contentHelpText = content.get(helpTextFieldAPIName) != null ? (string)content.get(helpTextFieldAPIName) : '';
                                            contentWrap.isIconRequired = content.get(ICON_REQUIRED) != null && content.get(ICON_REQUIRED) == true ? (Boolean)content.get(ICON_REQUIRED) : false;
                                            contentWrap.iconUrl = content.get(ICON_URL) != null ? (string)content.get(ICON_URL) : '';
                                            contentWrap.sortOrder = content.get(SORT_ORDER) != null ? Integer.valueOf(content.get(SORT_ORDER)) : 0;
                                            contentWrap.style = (string)content.get('Core_MDF_Style_txt__c');
                                            contentWrapList.add(contentWrap);
                                    }
                                }
                                subSecWrap.lineItemWrapList = contentWrapList;
                                subSectionWrapList.add(subSecWrap);
                            }
                            resultWrapper.subSectionList = subSectionWrapList;
                            
                        }
                        
                        sectionWrapList.add(resultWrapper);
                    }          
                }
                
                
            }
        }catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return sectionWrapList;
    }
    
    
     
    /***************************************************************************************************** 
Method Name :   getBrandContent
@return     :   list of wrapper
@parameters :   Section Code passed from community 
Description :   This Method is used to fetch content configuration records for branding page based on section code passed 

******************************************************************************************************/
    @AuraEnabled
    public static List<tableRowHeaderWrapper> getBrandContent(string sectionCode) { // e.g., sectionCode = 'Branding_Table'
        Map<Id, Set<Id>> headerIdToSubIdSetMap = new Map<Id, Set<Id>>();     
        Map<string,List<Core_MDF_Content_Configuration__c>> subHeaderToContentMap = new Map<string,List<Core_MDF_Content_Configuration__c>>(); 
        Core_MDF_DynamicContentGenerator.ContentInputWrapper ContentResultWrap = new Core_MDF_DynamicContentGenerator.ContentInputWrapper(); 
        List<Core_MDF_Content_Configuration__c> contentConfigsList = new List<Core_MDF_Content_Configuration__c>(); 
        Map<Id, Core_MDF_Content_Configuration__c> idToContentRecMap = new Map<Id, Core_MDF_Content_Configuration__c>(); 
        List<tableRowHeaderWrapper> sectionWrapList = new List<tableRowHeaderWrapper>(); 
        
        string SORT_ORDER = 'Core_MDF_Sort_Order_nbr__c';
        string ROWSPAN = 'Core_MDF_rowspan_nbr__c';
        string SECTION_LINE_ITEM = 'Section Line Item';
        string SECTION_SUB_HEADER = 'Section SubHeader';
        string loggedinUserLang = '';
        
        loggedinUserLang = appSupportedLang.contains(UserInfo.getLanguage()) ? UserInfo.getLanguage() : 'en_US';  //get loggedIn users langauge
        if(string.isNotBlank(sectionCode) && string.isNotBlank(loggedinUserLang)){
            ContentResultWrap = Core_MDF_DynamicContentGenerator.getData(sectionCode,loggedinUserLang ); 
        }
        string labelfieldAPIName    =  ContentResultWrap.labelfieldAPIName;     //e.g lang->zh_CN , labelfieldAPIName = Core_MDF_Label_zh_CN_txt__c
        
        try{
            if(ContentResultWrap != null && ContentResultWrap.ContentConfigList != null && !ContentResultWrap.ContentConfigList.isEmpty()){  
                for (Core_MDF_Content_Configuration__c  content : ContentResultWrap.ContentConfigList ) {
                    idToContentRecMap.put(content.Id,content);                 //Key: Content Id Value: Content rec
                    if(content.Core_MDF_Category_nm__c == SECTION_LINE_ITEM){
                        string subHeaderId = content.Core_MDF_Parent_Content_Config_Id__c;
                        if(!subHeaderToContentMap.containsKey(subHeaderId)){//Sub Header
                            subHeaderToContentMap.put(subHeaderId, new List<Core_MDF_Content_Configuration__c>());
                        }
                        subHeaderToContentMap.get(subHeaderId).add(content);  //Key:SubHeader Id Value:Content Line item records
                    }
                    if(content.Core_MDF_Category_nm__c == SECTION_SUB_HEADER){
                        string headerId = content.Core_MDF_Parent_Content_Config_Id__c;
                        string subHeaderId = content.Id;
                        if(!headerIdToSubIdSetMap.containsKey(headerId)){//Header
                            headerIdToSubIdSetMap.put(headerId, new Set<Id>());
                        }
                        headerIdToSubIdSetMap.get(headerId).add(subHeaderId);   //Key:Header Id (ParentId of subHeaderId) Value:set of subHeader Ids
                    }
                }                
                if(!headerIdToSubIdSetMap.isEmpty()){
                    for(string headerId : headerIdToSubIdSetMap.KeySet()){
                        tableRowHeaderWrapper resultWrapper = new tableRowHeaderWrapper();
                        list<tableRowSectionWrapper> subSectionWrapList = new list<tableRowSectionWrapper>();
                        resultWrapper.rowHeader = idToContentRecMap.get(headerId).get(labelfieldAPIName) != null ? (string)idToContentRecMap.get(headerId).get(labelfieldAPIName) : '';
                        resultWrapper.rowSpan = idToContentRecMap.get(headerId).get(ROWSPAN) != null ?  Integer.valueOf(idToContentRecMap.get(headerId).get(ROWSPAN)) : 0;
                        resultWrapper.sortOrder = idToContentRecMap.get(headerId).get(SORT_ORDER) != null ? Integer.valueOf(idToContentRecMap.get(headerId).get(SORT_ORDER)) : 0;
                        if(!headerIdToSubIdSetMap.get(headerId).isEmpty()){
                            for(string subId : headerIdToSubIdSetMap.get(headerId)){
                                tableRowSectionWrapper subSecWrap = new tableRowSectionWrapper();
                                subSecWrap.sortOrder = idToContentRecMap.get(subId).get(SORT_ORDER) != null ? Integer.valueOf(idToContentRecMap.get(subId).get(SORT_ORDER)) : 0;
                                Map<integer,List<string>> colHeaderIdtoContentMap = new Map<integer,List<string>>();
                                if(subHeaderToContentMap != null && !subHeaderToContentMap.keySet().isEmpty() && subHeaderToContentMap.get(subId)!= null){
                                    for(Core_MDF_Content_Configuration__c content: subHeaderToContentMap.get(subId)){
                                        list<string> contentLabelList = new List<string>(); 
                                        string contentLabel =content.get(labelfieldAPIName) != null ? (string)content.get(labelfieldAPIName) : '';
                                        if(string.isNotBlank(contentLabel)){
                                            contentLabelList = contentLabel.split(';\\|');
                                            
                                        }          
                                        if(contentLabelList.size() > 0) {
                                            for(integer index=0;index<3;index++){
                                                if(!colHeaderIdtoContentMap.containsKey(index)){//Sub Header
                                                    colHeaderIdtoContentMap.put(index, new List<string>());
                                                }
                                                if(contentLabelList.size() > index){
                                                    colHeaderIdtoContentMap.get(index).add(contentLabelList[index]);
                                                }   
                                                
                                            }
                                        }
                                        
                                    }
                                    subSecWrap.firstColContentList = colHeaderIdtoContentMap.values()[0];
                                    subSecWrap.secondColContentList = colHeaderIdtoContentMap.values()[1];
                                    subSecWrap.thirdColContentList = colHeaderIdtoContentMap.values()[2];
                                    
                                    
                                }
                                subSectionWrapList.add(subSecWrap);
                                
                            }
                            resultWrapper.tableSectionList = subSectionWrapList;
                            
                        }
                        
                        sectionWrapList.add(resultWrapper);
                    }          
                }
                
                
            }
        }catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return sectionWrapList;
    }

       
    
    //Start - Wrappers for resources page//
    public class sectionWrapper{
        @AuraEnabled public string contentHeader;
        @AuraEnabled public Integer sortOrder;
        @AuraEnabled public String style;
        @AuraEnabled public list<subSectionWrapper> subSectionList;
    }
    
    public class subSectionWrapper{
        @AuraEnabled public string contentSubHeader;
        @AuraEnabled public Integer sortOrder;
        @AuraEnabled public String style;
        @AuraEnabled public list<contentLineItemWrapper> lineItemWrapList;
    }
    
    public class contentLineItemWrapper{
        @AuraEnabled public String contentLabel; 
        @AuraEnabled public String contentUrl;    
        @AuraEnabled public String contentHelpText;  
        @AuraEnabled public Boolean isIconRequired;  
        @AuraEnabled public String iconUrl;             
        @AuraEnabled public Integer sortOrder; 
        @AuraEnabled public String style;       
    }
    //end - Wrappers for resources page//
    
    
    //Start - Wrappers for branding page//
     public class tableRowHeaderWrapper{
        @AuraEnabled public string rowHeader;
        @AuraEnabled public Integer sortOrder;
         @AuraEnabled public Integer rowSpan;
        @AuraEnabled public list<tableRowSectionWrapper> tableSectionList;
    }
    
    public class tableRowSectionWrapper{
        @AuraEnabled public Integer sortOrder;
        @AuraEnabled public List<string> firstColContentList;
        @AuraEnabled public List<string> secondColContentList;
        @AuraEnabled public List<string> thirdColContentList;
    }
    
   
    //end - Wrappers for branding page //
   
    
    //Wrapper Class for Output Details
    public class ContentWrapperObj{
        @AuraEnabled public String contentLabel;  //Holds value of label to be displayed on community 
        @AuraEnabled public String contentUrl;    //Holds value of URL to be displayed on community
        @AuraEnabled public String contentHelpText; //Holds Value of description on hoverover of icon & label on community 
        @AuraEnabled public Boolean isIconRequired;  //Holds Value of boolean value of isIcon required on community
        @AuraEnabled public String iconUrl;          //Holds value of static resource url of icon on community
        

    }
    
    
}