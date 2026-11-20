/****************************************************************************************************************************************
 * Class Name: Core_IPS_addEDQToProduct_LEX
 * Test Class Name: Core_IPS_addEDQToProduct_LEX_Test
 * Description: This class is used for Internal LEX(Support ORG) in 4 places 1.Supported Product Detail Page(Add Environment Details Button),
 * 2.Supported Product Detail Page(Add Case Categories Button), 3.Case Sub Category Detail Page(Add Environment Details Button), 
 * 4.Case Category Detail Page(Add Sub Categories Button)
 * Created By: Sai Krishna 
 * Created Date: 01/07/2022 
 ******************************************************************************************************************************************/
public with sharing class Core_IPS_addEDQToProduct_LEX {
    
    public static List<EnvironmentVarSel> envDetails;
    public string objectApi;
    public static id currentLoggedInUser; 
    public static Core_IPS_Supported_product__c SupportedProductRecord;
    public static Core_IPS_Product_Issue_Category__c CaseCategoryRecord;
    
    
    
     /*****************************************************************************************************************************************
     * Method Name: getEnvironmentVariables_SupProd
     * Description: This method will Fetch  all Environment Detail Questions for Supported Product which are avilable to add on Environment Detail Operations Record
     * No Of Queries: 2
     * Input Values: Supported Product ID, Limitsize, offset, fetchType for lazy Loading
     * Output Values: Returns the List of all Environment Detail Questions which are available on Supported Product 
     * Created Date: 01/07/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<EnvironmentVarSel> getEnvironmentVariables_SupProd( String recordId, Integer limitSize, Integer offset , String fetchType){
            List<Core_IPS_Question__c> masterEnvList;
        	List<Core_IPS_Supported_product__c> SupportedProductRecordList = new List<Core_IPS_Supported_product__c>();   // US-0049380 UnhandledExp_EDQs       
         String query;
            if(Core_IPS_Supported_product__c.SObjectType.getDescribe().isAccessible()){   
                SupportedProductRecordList = [Select id,Core_Product_Organization__c, Core_Product_Organization__r.OwnerId, Core_EOIS__c, (select id, Core_Agent_Only__c,Core_IPS_Question__c,Core_Required__c,Core_Supported_Product__c,Core_Type__c,Core_Status__c from Environment_Detail_Operationals__r where (Core_Status__c !=: Core_IPS_Labels__c.getValues('CoreStatus_Inactive').value__c and Core_Supported_Product__c=: recordId)) from Core_IPS_Supported_product__c where id =: recordId];
            }
        if(SupportedProductRecordList != null && SupportedProductRecordList.size()>0){  // US-0049380 UnhandledExp_EDQs
          SupportedProductRecord = SupportedProductRecordList[0]; 
            set<id> existingIds = new set<id>();
            for(Core_IPS_Assigned_Environment_Variables__c env : SupportedProductRecord.Environment_Detail_Operationals__r){      
               existingIds.add(env.Core_IPS_Question__c);  
            }
            
                
            if(Core_IPS_Question__c.SObjectType.getDescribe().isAccessible()){
                String status = Core_IPS_Labels__c.getValues('CoreStatus_Inactive').value__c;
                String SpOrg = SupportedProductRecord.Core_Product_Organization__c;
                if(fetchType == 'Load Data' && offset != null)
        			{
            			query = 'select id,name,Core_IPS_Question__c,Core_IPS_Reporting_Name__c,Core_IPS_Parent_Question__r.Core_IPS_Question__c,Core_IPS_Required__c,Core_IPS_Product_Organization__c from Core_IPS_Question__c where (id not in :existingIds and Core_IPS_Product_Organization__c =:SpOrg and Core_IPS_Status__c !=:status)  ORDER BY name LIMIT :limitSize OFFSET: offset';
                    }
                else if(fetchType == 'All Data'){
                	query = 'select id,name,Core_IPS_Question__c,Core_IPS_Reporting_Name__c,Core_IPS_Parent_Question__r.Core_IPS_Question__c,Core_IPS_Required__c,Core_IPS_Product_Organization__c from Core_IPS_Question__c where (id not in :existingIds and Core_IPS_Product_Organization__c =:SpOrg and Core_IPS_Status__c !=:status)  ORDER BY name';
                }
            } 
            masterEnvList = Database.Query(query);
            envDetails = new List<EnvironmentVarSel>();
            if(masterEnvList != Null){
                    for(Core_IPS_Question__c env: masterEnvList){
                       EnvironmentVarSel  envSel = new EnvironmentVarSel();
                        
                       	envSel.Name = env.Name; 
                        envSel.required=false;
                        envSel.agentOnly=false;
                        envSel.Id = env.Id;
                        envSel.Core_IPS_Question = env.Core_IPS_Question__c;
                        envSel.ParentQuestion = env.Core_IPS_Parent_Question__r.Core_IPS_Question__c;
                        
                        envDetails.add(envSel);
                    }  // US-0049380 UnhandledExp_EDQs
            }
        }
        return envDetails;
    }
    
    
    
     /*****************************************************************************************************************************************
     * Method Name: getEnvironmentVariables_CaseCat
     * Description: This method will Fetch  all Environment Detail Questions for Case Sub Category which are avilable to add on Environment Detail Operations Record
     * No Of Queries: 2
     * Input Values: Case Sub Category ID, Limitsize, offset, fetchType for lazy Loading
     * Output Values: Returns the List of all Environment Detail Questions which are available on Case Sub Category 
     * Created Date: 01/07/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/

    
    
    @AuraEnabled(cacheable=true)
    public static List<EnvironmentVarSel> getEnvironmentVariables_CaseCat( String recordId, Integer limitSize, Integer offset , String fetchType){
        String status = Core_IPS_Labels__c.getValues('CoreStatus_Inactive').value__c;
        String query='';
        String CaseCatOrg = '';
        if(Core_IPS_Product_Issue_Category__c.SObjectType.getDescribe().isAccessible()){
                CaseCategoryRecord = [Select id,Name,Core_Issue_Sub_Category_Name__c,Core_Status__c,Core_Product_Issue_Category__r.Core_Supported_Product__r.Core_Product_Organization__c, Core_Product_Issue_Category__r.Core_Supported_Product__r.Core_Product_Organization__r.OwnerID, Core_Product_Issue_Category__c, ( select id, Core_Agent_Only__c,Core_IPS_Question__c,Core_Required__c,Core_Supported_Product__c,Core_Type__c,Core_Status__c from Environment_Detail_Operationals__r where Core_Product_Issue_Sub_Category__c =: recordId) from Core_IPS_Product_Issue_Category__c where (id =: recordId)];
                CaseCatOrg = CaseCategoryRecord.Core_Product_Issue_Category__r.Core_Supported_Product__r.Core_Product_Organization__c;
            }        
            set<id> existingIds = new set<id>();
                for(Core_IPS_Assigned_Environment_Variables__c env:CaseCategoryRecord.Environment_Detail_Operationals__r){
                    existingIds.add(env.Core_IPS_Question__c);    
                }
                List<Core_IPS_Question__c> masterEnvList;
                        if(Core_IPS_Question__c.SObjectType.getDescribe().isAccessible()){
                            if(fetchType == 'Load Data' && offset != null){
                                query='select id,name,Core_IPS_Question__c,Core_IPS_Parent_Question__r.Core_IPS_Question__c from Core_IPS_Question__c where (id not in :existingIds and Core_IPS_Product_Organization__c =:CaseCatOrg  and Core_IPS_Status__c !=: status) ORDER BY name LIMIT :limitSize OFFSET: offset ';
                            }
                            else if(fetchType == 'All Data'){
                                query = 'select id,name,Core_IPS_Question__c,Core_IPS_Parent_Question__r.Core_IPS_Question__c from Core_IPS_Question__c where (id not in :existingIds and Core_IPS_Product_Organization__c =:CaseCatOrg  and Core_IPS_Status__c !=: status) ORDER BY name';
                            } 
                        	masterEnvList = Database.Query(query);
                        }                    
                envDetails = new List<EnvironmentVarSel>();
                if(masterEnvList != NULL){
                            for(Core_IPS_Question__c env: masterEnvList){
                                    EnvironmentVarSel  envSel = new EnvironmentVarSel();
                                    envSel.Name = env.Name; 
                                	envSel.required=false;
                                    envSel.agentOnly=false;
                                    envSel.Id = env.Id;
                                    envSel.Core_IPS_Question = env.Core_IPS_Question__c;
                                    envSel.ParentQuestion = env.Core_IPS_Parent_Question__r.Core_IPS_Question__c;
                                    envDetails.add(envSel);
                            }   
                }
        return envDetails;
    }
    
    
     /*****************************************************************************************************************************************
     * Method Name: checkCaseSubCatEDQRules
     * Description: This method will check all Business Rules on Case Sub Category. 
     * This method is used to restrict the (Add Environment Details) functionality on Case Sub Category Detail Page for some profile users with some conditions
     * No Of Queries: 2
     * Input Values: Case Sub Category ID
     * Output Values: Returns success if current Logged in user meets the criteria to add Environment Details, if not then returns the message based on criteria
     * Created Date: 01/07/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/

    
    
    @AuraEnabled 
    public static String checkCaseSubCatEDQRules(String recordId){
      Core_IPS_Product_Issue_Category__c  CaseCategoryRecord;
        if(recordId !=null){
            CaseCategoryRecord = [Select id,Name,Core_Issue_Sub_Category_Name__c,Core_Status__c,Core_Product_Issue_Category__r.Core_Supported_Product__r.Core_Product_Organization__c, Core_Product_Issue_Category__r.Core_Supported_Product__r.Core_Product_Organization__r.OwnerID, Core_Product_Issue_Category__c, ( select id, Core_Agent_Only__c,Core_IPS_Question__c,Core_Required__c,Core_Supported_Product__c,Core_Type__c,Core_Status__c from Environment_Detail_Operationals__r where Core_Product_Issue_Sub_Category__c =: recordId) from Core_IPS_Product_Issue_Category__c where (id =: recordId)];
        }
       
      currentLoggedInUser = UserInfo.getUserid();  
        if(CaseCategoryRecord != null){
            if(CaseCategoryRecord.Core_Product_Issue_Category__c != null){
                if(CaseCategoryRecord.Core_Product_Issue_Category__r.Core_Supported_Product__c  != null){
                    Set<id> setOfUserId = new Set<id> ();
                        SetOfUserId = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(CaseCategoryRecord.Core_Product_Issue_Category__r.Core_Supported_Product__r.Core_Product_Organization__r.OwnerID);
                        List<User> lstUser = [select profile.name from User where id=:UserInfo.getUserid()];
                        SetupEntityAccess[] checkAccess = [SELECT Id FROM SetupEntityAccess WHERE SetupEntityId IN (SELECT Id FROM ApexPage WHERE Name = 'Core_IPS_addEnvironmentDetailsToSubCat') AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()) LIMIT 1];
                        if(checkAccess.size()<=0){
                             return 'InsufficientAccess';
                        }
                        if((System.Label.Core_IPS_Button_Override_ITAdmins).contains(lstUser[0].profile.name) == False)
                        {
                            if(!SetOfUserId.contains(currentLoggedInUser)){
                                // Current Logged In user not authorized to access the page.
                              return  Core_IPS_Error_Code__c.getValues('I105').Core_Error_Message__c;
                                
                            }
                            
                                                            
                        }
                        if(CaseCategoryRecord.Core_Status__c != 'Active'){
                            return Core_IPS_Error_Code__c.getValues('I113').Core_Error_Message__c;
                        }

                        List<EnvironmentVarSel> masterEnvList =   getEnvironmentVariables_CaseCat(recordId,0,0,'All Data');
                    	if(masterEnvList.isEmpty()){
                            return Core_IPS_Error_Code__c.getValues('I106').Core_Error_Message__c;
                           
                        }
                }
                else{ 
                        // Case Category Record not associated with Supported Product           
                        return Core_IPS_Error_Code__c.getValues('I109').Core_Error_Message__c;    
                    }
            }
            else{
                    // Case Sub Category Record not associated with Case Category Record    
                   return  Core_IPS_Error_Code__c.getValues('I110').Core_Error_Message__c; 
                     
                }
            return 'Success';
        }
        return Core_IPS_Error_Code__c.getValues('G108').Core_Error_Message__c;
        
    }
    
    
     /*****************************************************************************************************************************************
     * Method Name: checkSPEDQRules
     * Description: This method will check all Business Rules on Case Sub Category. 
     * This method is used to restrict the (Add Environment Details) functionality on Supported Product Detail Page for some profile users with some conditions
     * No Of Queries: 2
     * Input Values: Supported Product ID
     * Output Values: Returns success if current Logged in user meets the criteria to add Environment Details, if not then returns the message based on criteria
     * Created Date: 01/07/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/

    
    
    @AuraEnabled(cacheable=true)
    public static String checkSPEDQRules(String recordId){
        
             Core_IPS_Supported_product__c SupportedProductRecord;
             List<Core_IPS_Supported_product__c> SupportedProductRecordList = new List<Core_IPS_Supported_product__c>();  // US-0049380 UnhandledExp_EDQs
             if(Core_IPS_Supported_product__c.SObjectType.getDescribe().isAccessible()){   
                SupportedProductRecordList = [Select id,Core_Product_Organization__c, Core_Product_Organization__r.OwnerId, Core_EOIS__c, (select id, Core_Agent_Only__c,Core_IPS_Question__c,Core_Required__c,Core_Supported_Product__c,Core_Type__c,Core_Status__c from Environment_Detail_Operationals__r where (Core_Status__c !=: Core_IPS_Labels__c.getValues('CoreStatus_Inactive').value__c and Core_Supported_Product__c=: recordId)) from Core_IPS_Supported_product__c where id =: recordId];
            }
          if(SupportedProductRecordList != null && SupportedProductRecordList.size()>0){  // US-0049380 UnhandledExp_EDQs
          SupportedProductRecord = SupportedProductRecordList[0]; 
                             
            if(SupportedProductRecord != null){
            Set<id> setOfUserId = new Set<id> ();
            currentLoggedInUser = UserInfo.getUserid();
                SetOfUserId = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(SupportedProductRecord.Core_Product_Organization__r.OwnerId);
                List<User> lstUser = [select profile.name from User where id=:UserInfo.getUserid()];
                if((System.Label.Core_IPS_Button_Override_ITAdmins).contains(lstUser[0].profile.name) == False)
                {
                    if(!SetOfUserId.contains(currentLoggedInUser)){
                        // Current Logged In user not authorized to access the page.
                        return  Core_IPS_Error_Code__c.getValues('I105').Core_Error_Message__c; 
                       
                    }    
                }
                 if(SupportedProductRecord.Core_EOIS__c == true){
                    // Core_EOIS__c Error Message from Custom Setting. Cannot add as the Supported Product is EOL'ed
                    return Core_IPS_Error_Code__c.getValues('I107').Core_Error_Message__c;
                     
                }
                List<EnvironmentVarSel> edqList =   getEnvironmentVariables_SupProd(recordId,0,0,'All Data');
                if(edqList.isEmpty()){
                  return   Core_IPS_Error_Code__c.getValues('I106').Core_Error_Message__c;
                    
                }
            else{
                return 'Success';
            }
        }

        
          }   // US-0049380 UnhandledExp_EDQs
        return null;
    }
    
    
    /*****************************************************************************************************************************************
     * Method Name: checkSPCaseCatRules
     * Description: This method will check all Business Rules on Case Sub Category. 
     * This method is used to restrict the (Add Case Categories) functionality on Supported Product Detail Page for some profile users with some conditions
     * No Of Queries: 2
     * Input Values: Supported Product ID
     * Output Values: Returns success if current Logged in user meets the criteria to add Case Categories, if not then returns the message based on criteria
     * Created Date: 01/07/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/

    
    
    
    @AuraEnabled(cacheable=true)
    public static String checkSPCaseCatRules(String recordId){
        Core_IPS_Supported_product__c SupportedProductRecord;
             if(Core_IPS_Supported_product__c.SObjectType.getDescribe().isAccessible() && recordId!=null){   
                SupportedProductRecord = [Select id,Core_Product_Organization__c, Core_Product_Organization__r.OwnerId, Core_EOIS__c, (select id, Core_Agent_Only__c,Core_IPS_Question__c,Core_Required__c,Core_Supported_Product__c,Core_Type__c,Core_Status__c from Environment_Detail_Operationals__r where (Core_Status__c !=: Core_IPS_Labels__c.getValues('CoreStatus_Inactive').value__c and Core_Supported_Product__c=: recordId)) from Core_IPS_Supported_product__c where id =: recordId];
            }
        currentLoggedInUser = UserInfo.getUserid();
        if(SupportedProductRecord != null){
            	List<Core_IPS_Master_Issue_Category__c> casecatlist = getCategories(recordId,0,0,'All Data');
                Set<id> setOfUserId = new Set<id> ();
                setOfUserId = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(SupportedProductRecord.Core_Product_Organization__r.OwnerId);
                if(!SetOfUserId.contains(currentLoggedInUser)){
                    // Current Logged In user not authorized to access the page.
                    return Core_IPS_Error_Code__c.getValues('I105').Core_Error_Message__c;
                    
                }
                else if(SupportedProductRecord.Core_EOIS__c == true){
                    // Core_EOIS__c Error Message from Custom Setting. Cannot add as the Supported Product is EOL'ed
                    return Core_IPS_Error_Code__c.getValues('I107').Core_Error_Message__c;
                    
                }
                else if(casecatlist.isEmpty()){
                    return Core_IPS_Error_Code__c.getValues('I106').Core_Error_Message__c;
                   
                }
            	else{
                	return 'Success';
            	}
            
            }

        return null;
    }
    
    
    /*****************************************************************************************************************************************
     * Method Name: addEnvironmentVariables
     * Description: This method creates Environment Detail Operations records fo Supported Product OR Case Sub Category. 
     * No Of Queries: 0
     * Input Values: List of Environment Detail Questions which need to be created on SP or CaseSubCategory, SP ID or CaseSubCategory ID
     * Output Values: Returns true if environment detail operations records are created on SP or CaseSubCategory, returns false if record creation fails 
     * Created Date: 01/07/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/

    
    
    @AuraEnabled
    public static String  addEnvironmentVariables(List<EnvironmentVarSel> SpenvDetails, String sprecId, String caseCatRecId){
        List<Core_IPS_Assigned_Environment_Variables__c> envTempList = new List<Core_IPS_Assigned_Environment_Variables__c>();
        for(EnvironmentVarSel env:SpenvDetails){
            
                Core_IPS_Assigned_Environment_Variables__c aEnv = new Core_IPS_Assigned_Environment_Variables__c();
                        aEnv.Core_Required__c= env.required;
                        aEnv.Core_Agent_Only__c= env.agentOnly;
                        aEnv.Core_Status__c = Core_IPS_Labels__c.getValues('CoreStatus_Active').value__c;
                        if(sprecId != null){
                            aEnv.Core_Supported_Product__c= sprecId;
                         	aEnv.Core_Type__c= Core_IPS_Labels__c.getValues('CoreType_Product').value__c;
                        }
                        else{
                            aEnv.Core_Product_Issue_Sub_Category__c= caseCatRecId;
                    		aEnv.Core_Type__c = Core_IPS_Labels__c.getValues('CoreType_Issue_Sub_Category').value__c;
                        }
                        
                   aEnv.Core_IPS_Question__c= env.id;
                envTempList.add(aEnv);
            }
        
        try{
            insert envTempList;
            return 'true';
        }
        catch(Exception e){
            return e.getMessage();
        } 
    }
    
    
    
     /*****************************************************************************************************************************************
     * Method Name: getCategories
     * Description: This method will Fetch  all Case Categories for Suported Product which are available to add on Case Category Record
     * No Of Queries: 2
     * Input Values: SP ID, Limitsize, offset, fetchType for lazy Loading
     * Output Values: Returns the List of all Case Categories which are available on Case Category 
     * Created Date: 05/08/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/

	@AuraEnabled
    public static List<Core_IPS_Master_Issue_Category__c> getCategories(String recordId, Integer limitsize, Integer offset, String fetchtype){
        set<id> existingIds = new set<id>();
        String query='';
        String coreType = 'Case Category';
        List<Core_IPS_Master_Issue_Category__c> catlist;
        if(Core_IPS_Supported_product__c.SObjectType.getDescribe().isAccessible()){
            // Hassan Khan created a "List<Core_IPS_Supported_product__c> supportedProdList" to fix (List has no rows for assignment to Sobject) Exception Handling issue.		
            // SupportedProductRecord = [Select id,Core_Product_Organization__c, Core_Product_Organization__r.OwnerId, Core_EOIS__c, (select id, Core_Issue_Category_Name__c from Product_Issue_Categories__r where Core_Supported_Product__c =: recordId) from Core_IPS_Supported_product__c where id =: recordId ];
            List<Core_IPS_Supported_product__c> supportedProdList = [Select id,Core_Product_Organization__c, Core_Product_Organization__r.OwnerId, Core_EOIS__c, (select id, Core_Issue_Category_Name__c from Product_Issue_Categories__r where Core_Supported_Product__c =: recordId) from Core_IPS_Supported_product__c where id =: recordId];
            if (!supportedProdList.isEmpty()){
                SupportedProductRecord = supportedProdList[0];
            }
        }
        for(Core_IPS_Product_Issue_Category__c icRec:SupportedProductRecord.Product_Issue_Categories__r){
           existingIds.add(icRec.Core_Issue_Category_Name__c);
        }
        if(fetchtype=='Load Data' && offset != null ){
            query = 'select id,name,Core_Status__c from Core_IPS_Master_Issue_Category__c where id not in: existingIds and Core_type__c =:coreType  ORDER BY name LIMIT :limitsize OFFSET: offset';
        	
        }
        else if(fetchtype=='All Data'){
             query = 'select id,name,Core_Status__c from Core_IPS_Master_Issue_Category__c where id not in: existingIds and Core_type__c =:coreType  ORDER BY name';
        	
        }
        
        catlist = Database.Query(query);
        return catlist;

    }    
    
    
    
     /*****************************************************************************************************************************************
     * Method Name: addCategories
     * Description: This method will add list of Case Categories for Suported Product which are available to add on Supported Product Record
     * No Of Queries: 2
     * Input Values: Master Category List, SP ID
     * Output Values: Returns true if list of categories gets inserted, Else returns exception 
     * Created Date: 05/08/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/

    
    
    @AuraEnabled
    public static String addCategories(String recordId,List<Core_IPS_Master_Issue_Category__c> catList){
        List<Core_IPS_Product_Issue_Category__c> isCatList = new List<Core_IPS_Product_Issue_Category__c>();
        Id CaseCatObjRecordTypeId = schema.sobjecttype.Core_IPS_Product_Issue_Category__c.getrecordtypeinfosbyname().get(Core_IPS_Labels__c.getValues('CaseCategory').value__c).getRecordTypeId();
		if(CaseCatObjRecordTypeId != null){
            for(Core_IPS_Master_Issue_Category__c isc:catList){
                Core_IPS_Product_Issue_Category__c pic = new Core_IPS_Product_Issue_Category__c();
                        pic.Core_Issue_Category_Name__c= isc.Id;
                        pic.Core_Supported_Product__c= recordId;
                        pic.recordTypeId=CaseCatObjRecordTypeId; 
                        pic.Core_Status__c = Core_IPS_Labels__c.getValues('CoreStatus_Active').value__c;
                        //pic.Name = isc.masterIssueCat.Name;
                        isCatList.add(pic);
            }
        }
        try{
            insert isCatList;
            return 'true';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
    
    
    
    
    
    
    
     /*****************************************************************************************************************************************
     * Method Name: getSubCategories
     * Description: This method will Fetch  all Sub categories for Case Category which are available to add on Case Category Record
     * No Of Queries: 2
     * Input Values: Case  Category ID, Limitsize, offset, fetchType for lazy Loading
     * Output Values: Returns the List of all Case Subcategories which are available on Case Category 
     * Created Date: 01/07/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/

    
    @AuraEnabled
    public static List<Core_IPS_Master_Issue_Category__c> getSubCategories(String recordID, Integer limitsize, Integer offset, String fetchType){
       
        set<id> existingIds = new set<id>();
        String query='';
        String coreType = 'Case Subcategory';
       String Name1 =''; 
        List<Core_IPS_Master_Issue_Category__c> subcatlist;
        if(Core_IPS_Product_Issue_Category__c.SObjectType.getDescribe().isAccessible()){
            CaseCategoryRecord = [select id,name,Core_Issue_Category_Name__r.Name,Core_Status__c,Core_Supported_Product__c, Core_Supported_Product__r.Core_Product_Organization__r.OwnerId, Core_Supported_Product__r.Core_EOIS__c, (select id, Core_Issue_Sub_Category_Name__c from Product_Issue_Sub_Categories__r where Core_Product_Issue_Category__c =: recordID) from Core_IPS_Product_Issue_Category__c where id =: recordID];
       		Name1 = CaseCategoryRecord.Core_Issue_Category_Name__r.Name;
        }
        for(Core_IPS_Product_Issue_Category__c icRec : CaseCategoryRecord.Product_Issue_Sub_Categories__r){
                existingIds.add(icRec.Core_Issue_Sub_Category_Name__c);
        }
        if(fetchTYpe=='Load Data' && offset != null ){
            query = 'select id,Name,Core_Status__c from Core_IPS_Master_Issue_Category__c where id not in :existingIds and Core_type__c=:coreType and Core_Master_Issue_Category__r.Name=:Name1 ORDER BY Name LIMIT :limitSize OFFSET: offset';
        	
        }
        else if(fetchTYpe=='All Data'){
             query = 'select id,Name,Core_Status__c from Core_IPS_Master_Issue_Category__c where id not in :existingIds and Core_type__c=:coreType and Core_Master_Issue_Category__r.Name=:Name1 ORDER BY Name';
        	
        }
        
        subcatlist = Database.Query(query);
        return subcatlist;
    }
    
    
    /*****************************************************************************************************************************************
     * Method Name: checkCaseSubCatRules
     * Description: This method will check all Business Rules on Case Category. 
     * This method is used to restrict the (Add Sub Categories) functionality on Case Category Detail Page for some profile users with some conditions
     * No Of Queries: 2
     * Input Values: Case Category Record ID
     * Output Values: Returns success if current Logged in user meets the criteria to add Sub Categories , If not then returns the message based on criteria
     * Created Date: 01/07/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/

    
    
    @AuraEnabled
    public static String checkCaseSubCatRules(String recordId){
        
        Core_IPS_Product_Issue_Category__c CaseCategoryRecord;
        currentLoggedInUser = UserInfo.getUserid();
        if(Core_IPS_Product_Issue_Category__c.SObjectType.getDescribe().isAccessible() && recordId!=null){
            CaseCategoryRecord = [select id,name,Core_Issue_Category_Name__r.Name,Core_Status__c,Core_Supported_Product__c, Core_Supported_Product__r.Core_Product_Organization__r.OwnerId, Core_Supported_Product__r.Core_EOIS__c, (select id, Core_Issue_Sub_Category_Name__c from Product_Issue_Sub_Categories__r where Core_Product_Issue_Category__c =: recordId) from Core_IPS_Product_Issue_Category__c where id =: recordId];
        }
        if(CaseCategoryRecord != null){
            if(CaseCategoryRecord.Core_Supported_Product__c != null){
                Set<id> setOfUserId = new Set<id> ();
                    setOfUserId = Core_IPS_Helper_Utility.GetSetOfUsersbyQueueID(CaseCategoryRecord.Core_Supported_Product__r.Core_Product_Organization__r.OwnerId);
                    
                	if(CaseCategoryRecord.Core_Status__c != 'Active'){
                    	return Core_IPS_Error_Code__c.getValues('I112').Core_Error_Message__c; 
                	}
                	if(!SetOfUserId.contains(currentLoggedInUser)){
                        // Current Logged In user not authorized to access the page.
                        return  Core_IPS_Error_Code__c.getValues('I105').Core_Error_Message__c;
                        
                    }
                    if(CaseCategoryRecord.Core_Supported_Product__r.Core_EOIS__c == true){
                        // Core_EOIS__c Error Message from Custom Setting. Cannot add as the Supported Product is EOL'ed
                        return Core_IPS_Error_Code__c.getValues('I107').Core_Error_Message__c;
                        
                    }
                	List<Core_IPS_Master_Issue_Category__c> subCat = getSubCategories(recordId,0,0,'All Data');
                    if(subCat.isEmpty()){
                        return  Core_IPS_Error_Code__c.getValues('I106').Core_Error_Message__c;
                        
                    }
            }
            else{
                return Core_IPS_Error_Code__c.getValues('I109').Core_Error_Message__c;
            }
        }
        else{
            return Core_IPS_Error_Code__c.getValues('I109').Core_Error_Message__c;
        }
        return 'Success';
    }
    
    
    
    /*****************************************************************************************************************************************
     * Method Name: addSubCategories
     * Description: This method will add list of Sub Categories for Case Category which are available to add on Case Category Record
     * No Of Queries: 2
     * Input Values: Master Sub Category List, Case Category ID
     * Output Values: Returns true if list of categories gets inserted, Else returns exception 
     * Created Date: 14/07/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/

    
    @AuraEnabled
    public static String addSubCategories(String recordId,List<Core_IPS_Master_Issue_Category__c> subcatList){
        List<Core_IPS_Product_Issue_Category__c> isSubCatList = new List<Core_IPS_Product_Issue_Category__c>();
        Id CaseCatObjRecordTypeId = schema.sobjecttype.Core_IPS_Product_Issue_Category__c.getrecordtypeinfosbyname().get(Core_IPS_Labels__c.getValues('CaseSubCategory').value__c).getRecordTypeId();
		if(CaseCatObjRecordTypeId != null){
            for(Core_IPS_Master_Issue_Category__c isc:subcatList){
                Core_IPS_Product_Issue_Category__c pic = new Core_IPS_Product_Issue_Category__c();
                        pic.Core_Issue_Sub_Category_Name__c= isc.Id;
                        pic.Core_Product_Issue_Category__c= recordId;
                        pic.recordTypeId=CaseCatObjRecordTypeId; 
                        pic.Core_Status__c = Core_IPS_Labels__c.getValues('CoreStatus_Active').value__c;
                        //pic.Name = isc.masterIssueCat.Name;
                        isSubCatList.add(pic);
            }
        }
        try{
            insert isSubCatList;
            return 'true';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
    
    
	/***************************************************************************************************
    Wrapper Class Name: EnvironmentVarSel
    Version     : 1.0 
    Created Date: 1 July 2022
    Function / Description    : This wrapper class is used for constructing components for "core_IPS_ProductAddEnvDetails_Lex" LWC component
    Used in     : "core_IPS_ProductAddEnvDetails_Lex" LWC For Internal Lex.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sai Krishna       		1/07/2022                 Created
    ****************************************************************************************************/
    
    public class EnvironmentVarSel{
       
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String Core_IPS_Question{get;set;}
        @AuraEnabled
        public String ParentQuestion{get;set;}
        @AuraEnabled
        public boolean agentOnly{get;set;}
        @AuraEnabled
        public boolean required{get;set;}
        
    }
    
}