/****************************************************************************************************************************************
 * Class Name: Core_IPS_AddProductsEnvDetailMaster_LEX
 * Test Class Name: Core_IPS_AddProducts_EDM_LEX_Test
 * Description: This class is used for Add to Products Button in Environment Detail Master Object
 * Created By: Manisha Sajwan
 * Created Date: 29/08/2022 
 ******************************************************************************************************************************************/

public with Sharing class Core_IPS_AddProductsEnvDetailMaster_LEX {

    public string objectApi;
    public static id currentLoggedInUser; 
    public static Core_IPS_Supported_product__c SupportedProductRecord;
    public static Core_IPS_Environment_Variables__c EnvVariableRecord;
    public static List<ProductsSel> supProductList;
    
    /***************************************************************************************************
    Method Name  : getSupportedProducts
    Method Type  : helper method
    Version      : 1.0 
    Created Date : 29/08/2022 
    Function     : Fetch and Display the "Supported Product" records which are available to add to the Env. Detail Master record.
    Input Parameters : None
    Output Parameters: None
    Description : Fetch and Display the "Supported Product" records which are available to add to the Env. Detail Master record.
    Used in     : This method invoked by Core_IPS_AddProductsEnvDetailMaster_LEX.js file.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Manisha Sajwan            28/07/2022                 Created
    ****************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<ProductsSel> getSupportedProducts(String recordId, Integer limitSize, Integer offset ){
      String query; 
      EnvVariableRecord = [select id, name, Core_Status__c, Core_Product_Organization__c, Core_Product_Organization__r.ownerId, 
                            (select id,Core_Supported_Product__c, Core_supported_product__r.name, Core_Required__c, Core_Agent_Only__c, Core_Status__c 
                                from Environment_Detail_Operationals__r 
                                 where Core_Environment_Variable__c =: recordId AND Core_Supported_Product__c != null) 
                                  from Core_IPS_Environment_Variables__c where id =: recordId];
        
      System.debug('--EnvVariableRecord--' +EnvVariableRecord);   
        
      Set<Id> existingIds = new Set<Id>(); 
        
      for(Core_IPS_Assigned_Environment_Variables__c envT: EnvVariableRecord.Environment_Detail_Operationals__r){
            existingIds.add(envT.Core_Supported_Product__c);
        }
        
      supProductList = new List<ProductsSel>();
        
      List<Core_IPS_Supported_Product__c> supportedproductObj  = [ SELECT Id,Name,Core_Supported_Product_Name__c FROM Core_IPS_Supported_Product__c 
                                                                      WHERE Core_Product_Organization__c =: EnvVariableRecord.Core_Product_Organization__c 
                                                                         AND Id NOT IN: existingIds AND Core_EOIS__c = FALSE 
                                                                           ORDER BY Core_Supported_Product_Name__c
                                                                             LIMIT :limitSize OFFSET :offset];
                
        
       System.debug('--supportedproductObj--' +supportedproductObj); 
        for(Core_IPS_Supported_Product__c sp: supportedproductObj){
                                     
            ProductsSel prodSel = new ProductsSel();
            prodSel.Name = sp.Core_Supported_Product_Name__c;
            prodSel.Id = sp.Id;
            prodSel.prod= sp;
            prodSel.required = false;
            prodSel.agentOnly = false; 
            supProductList.add(prodSel);
          }
        
        System.debug('--supProductList--' +supProductList);
        System.debug('--supProductList--' +supProductList.size());
        return supProductList;
    }
    
    /***************************************************************************************************
    Method Name: addToProducts 
    Created Date: 28/07/2022
    Description : This method creates the "Environmental Detail Operational" (child) records for "Environmental Detail Master" (Parent) Record. Upon record creation, redirects to the "Environmental Detail Master Detail" record.
    Used in     : This method invoked by "Add to Products" command button from LWC.
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods : 0
    Number of DML Statements : 1 upsert statement
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Manisha Sajwan            29/08/2022                 Created
    ****************************************************************************************************/
    
    @AuraEnabled
    public static boolean addToProducts(List<ProductsSel> supportedProductDetails, String recordId){
        System.debug('---supportedProductDetails---'+supportedProductDetails);
        //System.debug('---EnvVariableRecord.id---'+EnvVariableRecord.Id);
        System.debug('---recordId---'+recordId);
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
                      aEnv.Core_Environment_Variable__c = recordId;
                    }
                    System.debug('---aEnv1---'+aEnv);
                    envTempList.add(aEnv);
                    System.debug('---envTempList1---'+envTempList); 
                //}   
             }  
              upsert envTempList;
              return true;
            }         
        catch(Exception e){
            System.debug('Exception occured:'+e);
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
        System.debug('---supProductList check Business rules---'+supProductList);
        System.debug('---supProductList check Business rules---'+supProductList.size());
      currentLoggedInUser = UserInfo.getUserid();
        System.debug(' currentLoggedInUser:'+currentLoggedInUser);
        if(EnvVariableRecord != null){
                Set<Id> setOfUserId = new Set<Id> ();
                SetOfUserId = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(EnvVariableRecord.Core_Product_Organization__r.OwnerId);
                System.debug(' SetOfUserId:'+SetOfUserId);
                List<User> lstUser = [SELECT Profile.Name FROM User WHERE Id=:UserInfo.getUserid()];
                if((System.Label.Core_IPS_Button_Override_ITAdmins).contains(lstUser[0].profile.Name) == False)
                { 
                    // Current Logged In user not authorized to access the page.
                    if(!SetOfUserId.contains(currentLoggedInUser)){  
                        return Core_IPS_Error_Code__c.getValues('I105').Core_Error_Message__c; 
                    }    
                }
                //Question is inactive
                else if(EnvVariableRecord.Core_Status__c == Core_IPS_Labels__c.getValues('CoreStatus_Inactive').value__c){
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
    * Manisha sajwan          29/08/2022                 Created
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