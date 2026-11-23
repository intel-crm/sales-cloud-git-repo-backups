/****************************************************************************************************************************************
 * Class Name: Core_IPS_Add_To_Products_LEX
 * Test Class Name: Core_IPS_Add_To_Products_LEX_Test
 * Description: This class is used for Add to Products Button in Environment Detail Question
 * Created By: Manisha Sajwan
 * Created Date: 28/07/2022 
 ******************************************************************************************************************************************/
public with sharing class Core_IPS_Add_To_Products_LEX {

    public string objectApi;
    public static id currentLoggedInUser; 
    public static Core_IPS_Supported_product__c SupportedProductRecord;
    public static Core_IPS_Question__c EnvVariableRecord;
    public static List<ProductsSel> supProductList;
    
/***************************************************************************************************
    Method Name  : getSupportedProducts
    Method Type  : helper method
    Version      : 1.0 
    Created Date : 28/07/2022 
    Function     : Fetch and Display the "Supported Product" records which are available to add to the Env. Detail Question record.
    Input Parameters : None
    Output Parameters: None
    Description : Fetch and Display the "Supported Product" records which are available to add to the Env. Detail Question record.
    Used in     : This method invoked by Core_IPS_Add_To_Products.js file.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Manisha Sajwan            28/07/2022                 Created
    ****************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<ProductsSel> getSupportedProducts(String recordId, Integer limitSize, Integer offset ){
      String query;
      List<Core_IPS_Supported_Product__c> supportedproductObj;
      List<Core_IPS_Question__c> EnvVariableRecordList = new List<Core_IPS_Question__c>(); // US-0049380 UnhandledExp_EDQs
      if(Core_IPS_Question__c.SObjectType.getDescribe().isAccessible()){
      EnvVariableRecordList = [SELECT Id, Name, Core_IPS_Question__c, Core_IPS_Status__c, Core_IPS_Product_Organization__c, Core_IPS_Product_Organization__r.ownerId, 
                             (SELECT Id,Core_Supported_Product__c, Core_supported_product__r.name, Core_Required__c, Core_Agent_Only__c, Core_Status__c 
                                FROM Environment_Details_Operational__r WHERE Core_IPS_Question__c =: recordId AND Core_Supported_Product__c != NULL) 
                                  FROM Core_IPS_Question__c 
                                      WHERE Id =: recordId];
      }
      if(EnvVariableRecordList != null && EnvVariableRecordList.size()>0){ // US-0049380 UnhandledExp_EDQs
          EnvVariableRecord = EnvVariableRecordList[0];          
      Set<Id> existingIds = new Set<Id>(); 
        
      for(Core_IPS_Assigned_Environment_Variables__c envT: EnvVariableRecord.Environment_Details_Operational__r){
            existingIds.add(envT.Core_Supported_Product__c);
        }
        
      supProductList = new List<ProductsSel>();
       if(Core_IPS_Supported_Product__c.SObjectType.getDescribe().isAccessible()){
       		supportedproductObj  = [ SELECT Id,Name,Core_Supported_Product_Name__c 
                                                                       FROM Core_IPS_Supported_Product__c
                                                                         WHERE Core_Product_Organization__c =: EnvVariableRecord.Core_IPS_Product_Organization__c 
                                                                           AND Id NOT in: existingIds AND Core_EOIS__c = FALSE 
                                                                             ORDER BY Core_Supported_Product_Name__c
                                                                               LIMIT :limitSize OFFSET :offset ];
       }
         
        for(Core_IPS_Supported_Product__c sp: supportedproductObj){
                                     
            ProductsSel prodSel = new ProductsSel();
            prodSel.Name = sp.Core_Supported_Product_Name__c;
            prodSel.Id = sp.Id;
            prodSel.prod= sp;
            prodSel.required = false;
            prodSel.agentOnly = false; 
            supProductList.add(prodSel);
          }
        }  // US-0049380 UnhandledExp_EDQs  
        return supProductList;
    }
   
    /***************************************************************************************************
    Method Name: addToProducts 
    Created Date: 28/07/2022
    Description : This method creates the "Environmental Detail Operational" (child) records for "Environmental Detail Question " (Parent) Record. Upon record creation, redirects to the "Environmental Detail Master Detail" record.
    Used in     : This method invoked by "Add to Products" command button from LWC.
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 0
    Number of DML Statements : 1 upsert statement
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Manisha Sajwan            28/07/2022                 Created
    ****************************************************************************************************/
    
    @AuraEnabled
    public static boolean addToProducts(List<ProductsSel> supportedProductDetails, String recordId){
        try{
            List<Core_IPS_Assigned_Environment_Variables__c> envTempList = new List<Core_IPS_Assigned_Environment_Variables__c>();
            for(ProductsSel prodSel : supportedProductDetails){
                Core_IPS_Assigned_Environment_Variables__c aEnv = new Core_IPS_Assigned_Environment_Variables__c();
                //if(prodSel.Id != null && prodSel.prod.Id != null){
                    aEnv.Core_Required__c = prodSel.required;
                    aEnv.Core_Agent_Only__c = prodSel.agentOnly;
                    aEnv.Core_Supported_Product__c = prodSel.prod.Id;
                    aEnv.Core_Status__c = Core_IPS_Labels__c.getValues('CoreStatus_Active').value__c;
                    aEnv.Core_Type__c = Core_IPS_Labels__c.getValues('CoreType_Product').value__c; 
                    if(recordId != null){
                      aEnv.Core_IPS_Question__c = recordId;
                    }
                    
                    envTempList.add(aEnv);
                    
                //}   
             }  
              upsert envTempList;
              return true;
            }         
        catch(Exception e){
            return false;
       }
    }
    
     /*****************************************************************************************************************************************
     * Method Name: checkBusinessRules
     * Description: This method validates the below scenarios for Environmental Detail Master Record:  
                    Current Logged In user not authorized to access the page (Add to Product)
                    If Env. Detail Master record status if Inactive. Error displayed.
                    if (Supported Product) records to display in the UI is empty 
     * No Of Queries: 2
     * Input Values: Environment Question ID
     * Output Values: Returns success if current Logged in user meets the criteria to add products, if not then returns the message based on criteria
     * Modification Log :
     * Developer                   Date                   Description
     * ----------------------------------------------------------------------------                 
     * Manisha Sajwan            28/07/2022               Created
     ****************************************************************************************************/
 
    @AuraEnabled(cacheable=true)
    public static String checkBusinessRules(String recordId){
      List<ProductsSel> supProductList = getSupportedProducts(recordId,15,0);
        currentLoggedInUser = UserInfo.getUserid();
        if(EnvVariableRecord != null){
                Set<Id> setOfUserId = new Set<Id> ();
                SetOfUserId = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(EnvVariableRecord.Core_IPS_Product_Organization__r.OwnerId);
                List<User> lstUser = [SELECT Profile.Name FROM User WHERE Id=:UserInfo.getUserid()];
                SetupEntityAccess[] checkAccess = [SELECT Id FROM SetupEntityAccess WHERE SetupEntityId IN (SELECT Id FROM ApexPage WHERE Name = 'Core_IPS_addEnvToProducts') AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()) LIMIT 1];
                if(checkAccess.size()<=0){
                  return 'InsufficientAccess';
                }
                if((System.Label.Core_IPS_Button_Override_ITAdmins).contains(lstUser[0].profile.Name) == False)
                { 
                    // Current Logged In user not authorized to access the page.
                    if(!SetOfUserId.contains(currentLoggedInUser)){  
                        return Core_IPS_Error_Code__c.getValues('I105').Core_Error_Message__c; 
                    }    
                }
                //Question is inactive
                else if(EnvVariableRecord.Core_IPS_Status__c == Core_IPS_Labels__c.getValues('CoreStatus_Inactive').value__c){
                    return Core_IPS_Error_Code__c.getValues('I108').Core_Error_Message__c;
                }
                //No Records to Display
                else if(supProductList.isEmpty()){ 
                    return Core_IPS_Error_Code__c.getValues('I106').Core_Error_Message__c;
                }
                else{
                   return 'Success';
                }
            }        
        return null;
     }    
        
    /***************************************************************************************************
    Wrapper Class Name: ProductsSel
    Created Date: 28/07/2022
    Description : This wrapper class is used for constructing components for "Core_IPS_Add_To_Products" LWC.
    Used in     : "Core_IPS_Add_To_Products" LWC 
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Manisha sajwan          28/07/2022                 Created
    ****************************************************************************************************/
    public class ProductsSel{
        
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public Core_IPS_Supported_Product__c prod{get;set;}
        @AuraEnabled
        public boolean agentOnly{get;set;}
        @AuraEnabled
        public boolean required{get;set;}
    }
}