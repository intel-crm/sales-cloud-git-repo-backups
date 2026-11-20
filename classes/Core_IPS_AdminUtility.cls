/****************************************************************************************************
*Class Name:  Core_IPS_AdminUtility
*Description:  Utility Class for Admin Context
*Modification Log :
* Developer                   Date                        Description
* ----------------------------------------------------------------------------       
* Yogesh                      12/18/2017                  Modified - US72415
* Aayushi                    1/03/2019                    modified- US253172
****************************************************************************************************/

Public with sharing class Core_IPS_AdminUtility
{  
    
    //Added By Yogesh Sharma
    public  static void  DeleteEnvDetails(List<Core_IPS_Response__c> LstEnvironmentDetail)
    {
        /*US1038641 - 06/23/2021 - Yamini - CRUD Delete Check for security vulnerability --*/
        // Venrublity Fix - Refering query to service class
        // delete LstEnvironmentDetail;
        Core_IPS_QueryService.deleteRecords((List<SObject>) LstEnvironmentDetail);
        
    } 
    
    public  static void  DeleteEnvDetails(List<Core_IPS_Environment_Details__c> LstEnvironmentDetail)
    {
        /*US1038641 - 06/23/2021 - Yamini - CRUD Delete Check for security vulnerability --*/
        if (Core_IPS_Environment_Details__c.sObjectType.getDescribe().isDeletable()) {
            // Venrublity Fix - Refering query to service class
            // delete LstEnvironmentDetail;
            LstEnvironmentDetail = (List<Core_IPS_Environment_Details__c>) Core_IPS_QueryService.deleteRecords((List<SObject>) LstEnvironmentDetail);
        }
        
    } 
    
    public static void insertLineItems(List<Core_IPS_Map_Par_Line_Item__c> lineItems){  
        // Venrublity Fix - Refering query to service class
        // insert lineItems;
        lineItems = (List<Core_IPS_Map_Par_Line_Item__c>) Core_IPS_QueryService.insertRecords((List<SObject>) lineItems);  
    }
    
    public static void insertProdAccessAccJOs(List<Core_IPS_MAP_Account__c> coreMapAccToInsert){
        // Venrublity Fix - Refering query to service class
        // insert coreMapAccToInsert;
        coreMapAccToInsert = (List<Core_IPS_MAP_Account__c>) Core_IPS_QueryService.insertRecords((List<SObject>) coreMapAccToInsert);
    }
    
    public static void insertProdAccessProdJOs(List<Core_IPS_MAP_Product__c> coreMapPrdToInsert){
        // Venrublity Fix - Refering query to service class
        // insert coreMapPrdToInsert;
        coreMapPrdToInsert = (List<Core_IPS_MAP_Product__c>) Core_IPS_QueryService.insertRecords((List<SObject>) coreMapPrdToInsert);
    }
    
    public static void insertGECList(List<Core_IPS_GEC_Details__c> GECList){
        // Venrublity Fix - Refering query to service class
        // insert GECList;
        GECList = (List<Core_IPS_GEC_Details__c>) Core_IPS_QueryService.insertRecords((List<SObject>) GECList);     
    } 
    
    //Addded By Yogesh Sharma
    public static void insertEnvDetailsToCreate(List<Core_IPS_Response__c> insertEnvDetails){
        for (Core_IPS_Response__c v : insertEnvDetails){
        System.debug('DDDGGG 49 : insertEnvDetails' + v);
        }
        // Venrublity Fix - Refering query to service class
        // insert insertEnvDetails;
        //Niyaz added as part of vulnerability    
        insertEnvDetails = (List<Core_IPS_Response__c>) Core_IPS_QueryService.insertRecords((List<SObject>) insertEnvDetails); 
        
    }
     
    
    public static void upsertEnvDetailsToCreate(List<Core_IPS_Response__c> insertEnvDetails,string caseId, boolean deleteExsitingResponses ){
        
        List<Core_IPS_Response__c> lstExistingCoreResponse = Core_IPS_Questions_Utility.getEnvDetailCoreResponse(caseId);
        if(lstExistingCoreResponse!=null && lstExistingCoreResponse.size()>0) {
            Core_IPS_AdminUtility.DeleteEnvDetails(lstExistingCoreResponse);
        }
        
        
        insertEnvDetailsToCreate(insertEnvDetails);
    }
    
    
    public static void insertEnvDetailsToCreate(List<Core_IPS_Environment_Details__c> insertEnvDetails){
        // Venrublity Fix - Refering query to service class
        // insert insertEnvDetails;
        insertEnvDetails = (List<Core_IPS_Environment_Details__c>) Core_IPS_QueryService.insertRecords((List<SObject>) insertEnvDetails);     
    }
    
    //Added by Ashutosh - US103890 - to insert new interested parties
    /*Start -- Tushar -- 12/05/2026 --- CRUD Added as part of vulnerability fix. */
    public static void insertInterestedParties(List<Core_IPS_Case_Interested_Party__c> interestedParties){
        try {
            // Venrublity Fix - Refering query to service class
            // Database.insert(interestedParties, AccessLevel.USER_MODE);
            interestedParties = (List<Core_IPS_Case_Interested_Party__c>) Core_IPS_QueryService.insertRecords((List<SObject>) interestedParties);
        } catch (DmlException e) {
            // Log or handle the exception as needed
            throw e;
        }
    } 
    /*END -- Tushar -- 12/05/2026 --- CRUD Added as part of vulnerability fix. */
    //Added by Aayushi - US253172 - to update Contact
    public static void updateContact(Contact cont){
        try{
            // Venrublity Fix - Refering query to service class
            // update cont;
            List<SObject> contList = Core_IPS_QueryService.updateRecords(new List<SObject>{ cont });
            if(!contList.isEmpty()){
                cont = (Contact) contList[0];
            }
        }
        catch(Exception e){ 
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'Contact', 'Core_IPS_AdminUtility');
        }
        
    } 
    
    public static String partnerType;
    public static Boolean partnerUser = Label.Core_Partner_Profile_Id.contains(String.valueOf(userInfo.getProfileId().substring(0, 15))); 
    public static boolean externalUser = Network.getNetWorkid()!= null? true:false;
    public static Boolean partnerAgentUser  =  Label.Core_IPS_Agent_Partner_Profile_id.contains(String.valueOf(userInfo.getProfileId().substring(0, 15))); 
    public static String partnerProf  = System.Label.Core_IPS_Partner_Profile_Id;
    public static string selectedRadioButton;  
    
    
    @AuraEnabled
    public static List<Id> saveComment(String newcaseJSON ){
        list<id> newCommentId = new list<id>();
        CaseWrapper caseWrapperObj = (CaseWrapper) JSON.deserialize(newcaseJSON, CaseWrapper.class);
        case newCase = new case();
        if( caseWrapperObj.closedPending !=''&& caseWrapperObj.closedPending !=null){
            newCase.Core_IPS_Date_Time_Close_Pending__c = date.valueOf(caseWrapperObj.closedPending); 
        }
        if(caseWrapperObj.caseComment!=''&& caseWrapperObj.caseComment!=null){
            newCase.Core_IPS_Comment__c = caseWrapperObj.caseComment;
        }
        if(caseWrapperObj.casesubststus!=''&& caseWrapperObj.casesubststus!=null){
            newCase.Core_Sub_Status__c = caseWrapperObj.casesubststus;
        }
        if(caseWrapperObj.caseid!=''&& caseWrapperObj.caseid!=null){
            newCase.id = caseWrapperObj.caseid;
        }
        caseWrapperObj.selectedRadioButton = (getPartnerType()!=null && getPartnerType()!='') ? getPartnerType() : caseWrapperObj.selectedRadioButton;
        Case cs = new Case();
        if(newCase != null && newcase.Core_Sub_Status__c != Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Close_Pending_SubStatus') && newCase.Core_IPS_Date_Time_Close_Pending__c != null
           && caseWrapperObj.selectedRadioButton == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c && (System.Label.Core_IPS_Agent_Profile_Ids.Contains(String.valueOf(userInfo.getprofileId()).substring(0, 15)) 
                                                                                                                     || System.Label.Core_IPS_DataOps.contains(String.valueOf(userInfo.getprofileId()).substring(0, 15)))) {
                                                                                                                         if(Schema.sObjectType.Case.fields.Core_IPS_Date_Time_Close_Pending__c.isUpdateable()){
                                                                                                                             cs.Core_IPS_Date_Time_Close_Pending__c = null;
                                                                                                                         }
                                                                                                                         cs.Id = newCase.Id;
                                                                                                                     }
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
        Core_IPS_Case_Attachments__c newAttachment = new Core_IPS_Case_Attachments__c();              
        if(partnerType =='Partner'){               
            caseWrapperObj.selectedRadioButton = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;     
        } 
        if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case__c.isCreateable()) {//TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
        	newComment.Core_IPS_Case__c = newCase.id; 
        }
        if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Rich_Comment__c.isCreateable()) {
            newComment.Core_IPS_Rich_Comment__c = newCase.Core_IPS_Comment__c;     
        }
        if( caseWrapperObj.selectedRadioButton!=null ){         
            if(partnerUser){
                newComment.Core_IPS_Case_Comment_Type__c = caseWrapperObj.selectedRadioButton;   
                
            } else if(!(externalUser) || (partnerAgentUser)){   
                newComment.Core_IPS_Case_Comment_Type__c = caseWrapperObj.selectedRadioButton; 
                
            }
            else {
                newComment.Core_IPS_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
            }
            if(newComment.Core_IPS_Comment_Attachment_Id__c!=null){
                if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Comment_Author_Type__c.isCreateable()) { //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
                	newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userInfo.getprofileId(), newAttachment.Core_FileUploadedBy__c);
                }
            }
            else if(newComment.Core_IPS_Comment_Attachment_Id__c==null){
                if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Comment_Author_Type__c.isCreateable()) { //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
                	newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userInfo.getprofileId(), userinfo.getuserid());
                 }
              }
            try{
                if(newComment!=null){       
                    // Venrublity Fix - Refering query to service class
                    // insert newComment;
                    List<SObject> newCommentList = Core_IPS_QueryService.insertRecords(new List<SObject>{ newComment });
                    if(!newCommentList.isEmpty()){
                        newComment = (Core_IPS_Case_Comments__c) newCommentList[0];
                    }
                    newCommentId.add(newComment.id);
                    if(cs.Id != null){  
                        // Venrublity Fix - Refering query to service class
                        // update cs;
                        List<SObject> csList = Core_IPS_QueryService.updateRecords(new List<SObject>{ cs });
                        if(!csList.isEmpty()){
                            cs = (Case) csList[0];
                        }
                    }
                    return newCommentId;
                }
            }
            catch(Exception e){
                return null;
            }
        } 
        return newCommentId;
    }
    public class CaseWrapper{
        public String casesubststus{get;set;}
        public String caseComment{get;set;}
        public String closedPending{get;set;}
        public String caseid{get;set;}
        public String selectedRadioButton{get;set;}
    }
    public static String getPartnerType(){
        if(partnerProf.contains(String.valueOf(userinfo.getProfileId()).substring(0,15))){                      
            String authrPartnerType= Core_Utility.getPartnerUserType(userinfo.getuserid());           
            if(authrPartnerType != null){
                if(authrPartnerType.split(';').size()>0) {               
                    partnerType = authrPartnerType.split(';')[0];  
                }               
            }    
            if(partnerType !=null && String.isNotBlank(partnerType)){                
                if(partnerType == 'Partner - DFAE'){
                    selectedRadioButton = Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;                  
                }
                else if(partnerType == 'Partner'){
                    selectedRadioButton = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
                }
            }
        }
        return selectedRadioButton;
    }
    
    public static String getAuthr(String loggedUserId,String userid){
        String authroTyp='';
        
        if(Label.Core_IPS_External_Customer_Profile_Ids.contains(loggedUserId.substring(0,15))){
            return authroTyp=Core_IPS_Labels__c.getValues('Customer').value__c;         
        } 
        else if(label.Core_IPS_DataOps.contains(loggedUserId.substring(0,15))){           
            String dataOpsAuthrType = '';                     
            dataOpsAuthrType = Core_Utility.isSupOrgAdmPermUser(Userid.substring(0,15));         
            if(dataOpsAuthrType !=null && String.isNotBlank(dataOpsAuthrType )){           
                return authroTyp = dataOpsAuthrType ; }                               
        }    
        else if(Label.Core_IPS_SalesRep_ProfileIds.contains(loggedUserId.substring(0,15))){
            return authroTyp=Core_IPS_Labels__c.getValues('FAE').value__c;
        }
        else if(Label.Core_IPS_Agent_Profiles.contains(loggedUserId.substring(0,15) )){
            return authroTyp=Core_IPS_Labels__c.getValues('Agent').value__c;
        }
        
        else if(Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(userInfo.getUserId()) == true){ //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
            return authroTyp=Core_IPS_Labels__c.getValues('Data Migration').value__c;
        }
        else if(Label.Core_Integration_Profile_Id.contains(loggedUserId.substring(0,15))){
            return authroTyp=Core_IPS_Labels__c.getValues('Backend Integration').value__c;
        }
        else if(Label.Core_IPS_Agent_Partner_Profile_id.contains(loggedUserId.substring(0,15))){
            return authroTyp=Core_IPS_Labels__c.getValues('Partner - Agent').value__c;
        }        
        else if(Label.Core_Partner_Profile_Id.contains(loggedUserId.substring(0,15))){
            
            String partnerAuthrType = '';
            String partnerType1;                      
            partnerAuthrType  = Core_Utility.getPartnerUserType(Userid.substring(0,15));
            
            if(partnerAuthrType!=null){
                if(partnerAuthrType.split(';').size()>0){
                    partnerType1 = partnerAuthrType.split(';')[0];
                }
            }
            if(partnerType1 !=null && String.isNotBlank(partnerType1 )){
                return authroTyp= partnerType1 ;
            }else{
                return authroTyp=Core_IPS_Labels__c.getValues('Partner').value__c;
            }
        } 
        return null;        
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Product2> getProductVariants(String prodId) {
        
        String productId;
        if(prodId != null){
            
            productId = prodId;
        } else {
            productId = '';
        }
        
        List<Asset> assetList = new List<Asset>();
        List<Core_Flat_Product_Hierarchy__c> prodHierarchyList = new List<Core_Flat_Product_Hierarchy__c>();
        Set<String> ids = new Set<String>();
        List<Product2> productList = new List<Product2>();
        try{
            if(prodId != null || prodId != ''){
                List<sObject> listprod = new List<sObject>();
//Syed Vulnerability fix-- query refering to the service class
                assetList = (List<Asset>) Core_IPS_QueryService.queryRecords(
                    'select id, Name, Core_Product_Organization__c, core_supported_product__c, core_supported_product__r.Core_IPS_Is_Show_Variant__c, Core_IPS_Project__c, Core_Product_EPM_ID__c from asset where id = :productId',
                    new Map<String, Object>{ 'productId' => productId }
                );
                if(!assetList.isEmpty() || assetList.size() > 0){
                    if(assetList[0].core_supported_product__r.Core_IPS_Is_Show_Variant__c== true){
                        if (Schema.sObjectType.Core_Flat_Product_Hierarchy__c.isAccessible()) {
                           //Syed Vulnerability fix-- query refering to the service class
                            String hierarchyFilter = '%' + assetList[0].Core_Product_EPM_ID__c + '%';
                            prodHierarchyList = (List<Core_Flat_Product_Hierarchy__c>) Core_IPS_QueryService.queryRecords(
                                'select id, Core_EPM_Hierarchy_Name__c, Core_L1_EPM_ID__c, Core_L1_EPM_Name__c, Core_L2_EPM_ID__c, Core_L2_EPM_Name__c, Core_Unique_ID__c from Core_Flat_Product_Hierarchy__c where Core_Unique_ID__c LIKE :hierarchyFilter',
                                new Map<String, Object>{ 'hierarchyFilter' => hierarchyFilter }
                            );
                        }
                        if(!prodHierarchyList.isEmpty() && prodHierarchyList.size()>0){
                            List<String> recorddata = new List<String>();
                            for(Core_Flat_Product_Hierarchy__c fph :prodHierarchyList){
                                String data=fph.Core_Unique_ID__c;
                                recorddata=data.split(';');
                                for(integer i=0;i<recorddata.size();i++){
                                    if(recorddata[i]==assetList[0].Core_Product_EPM_ID__c){
                                        if(System.label.Core_IPS_MAG_Support_Org.Contains((assetList[0].Core_Product_Organization__c+'').substring(0,15))){
                                            if(i>0 && i==1){
                                                ids.add(recorddata.get(i-1));
                                            }else if(i>0 && i==2){
                                                ids.add(recorddata.get(i-2));
                                            }else if(i>0 && i==3){
                                                ids.add(recorddata.get(i-1));
                                            }
                                        } else {
                                            if(i>0){
                                                ids.add(recorddata.get(i-1));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        ids.remove(assetList[0].Core_Product_EPM_ID__c);
                        String strIPS = 'IPS';
                        if(ids!=null && ids.size()>0){
                            
                            productList = [SELECT Id, Name FROM Product2 WHERE Core_Product_Org__c = :strIPS  and Core_Product_Name_EPM_ID__c IN  :Ids order by Name];
                        }
                    }
                }
            }
        } catch(Exception e){
        }
        if(!productlist.isEmpty()){
            return productlist;
        }
        return null;
    }
    public static Case createCase(Case caseDetails){
//Syed Vulnerability fix-- query refering to the service class
         List<SObject> caseDetailsList = Core_IPS_QueryService.upsertRecords(new List<SObject>{ caseDetails });
                if(!caseDetailsList.isEmpty()){
                    caseDetails = (Case) caseDetailsList[0];
                }
        return caseDetails;
    }
    
}