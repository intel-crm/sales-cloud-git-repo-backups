/***************************************************************************************************
* Apex Class Name : Core_IPS_CaseEditWrapper
* Test Class Name : Core_IPS_CaseCreateLWCControllerTest
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prasad                    			              Created
****************************************************************************************************/

public with sharing class Core_IPS_CaseEditWrapper {
    
@AuraEnabled public boolean isEditable= false;
@AuraEnabled public boolean isAgent= false;
@AuraEnabled public boolean isPrivateProjectCase = false;
@AuraEnabled public boolean showGECFields = false ;
@AuraEnabled public boolean editCloseCasePermission;
@AuraEnabled public boolean isClosed = false;
@AuraEnabled public boolean blnShowVariant = false ;
@AuraEnabled public boolean blnShowVariant_NAC  = false ;
@AuraEnabled public boolean displayProject= false;
@AuraEnabled public boolean displaySelfAssigned= false; 
@AuraEnabled public boolean displayPSO = false;
//@AuraEnabled public string  caseTypeSelected;
@AuraEnabled public boolean DisplayPriorityReason= false;
@AuraEnabled public boolean displayPlatform = false;
@AuraEnabled public string selectedProductId ='';
@AuraEnabled public case cs;
@auraEnabled public core_ips_project__c project = new core_ips_project__c ();
@auraEnabled public contact contact;
@auraEnabled public asset asset;
@auraEnabled public string PSOQuery = '';
@auraEnabled public string PSOCountQuery ='';
@auraEnabled public USer PSO;


@AuraEnabled public List<Core_IPS_EnvironmentDetailQuestion> envDetails = new List<Core_IPS_EnvironmentDetailQuestion>(); 
@AuraEnabled public List<Core_IPS_EnvironmentDetailQuestion> subCatEnvDetails = new List<Core_IPS_EnvironmentDetailQuestion>(); 
@AuraEnabled public list<CustomSelectOptions> categoryOptions = new list<CustomSelectOptions>();
@AuraEnabled public list<CustomSelectOptions> subCategoryOptions = new list<CustomSelectOptions>();
@AuraEnabled public List<SelectOption> variants{get;set;} // Added by sumukh for US69871
@AuraEnabled public List<SelectOption> variants_NAC{get;set;} // Added by sumukh for US107484
list<SelectOption> platformOptions = new list<SelectOption>();
@AuraEnabled public List<CustomSelectOptions> lstPSA = new List<CustomSelectOptions>();

 @AuraEnabled public List<Core_IPS_CaseCreateHelper.DynamicField> fields;
 @AuraEnabled public List<Core_IPS_CaseCreateHelper.DynamicField> subCatFields;


public Core_IPS_CaseEditWrapper(String caseId){
    Core_IPS_CaseCreateHelper helper = new Core_IPS_CaseCreateHelper();
	if(string.isBlank(caseId)){
		return;
	}
    /* this has been migrated to standard functionality
	if( Test.isRunningTest()  ){
		isEditable = true;
	}else {
		isEditable = [SELECT HasEditAccess,RecordId FROM UserRecordAccess WHERE UserId =:userinfo.getuserId() AND RecordId = :caseId].HasEditAccess;
	}*/
		// set isAnget flag
	//isAgent = ??
	//need to pass agent - below dynamically - currently passing it hardcode
	isAgent = Core_IPS_Helper_Utility.isIPSCustomerUser(); //Added by Ganapati
	User currentuser;
	//String currentPageHeader = ApexPages.currentPage().getHeaders().get('Host');
	String currentPage = URL.getSalesforceBaseUrl().toExternalForm(); 
	if(currentPage.contains('premiersupport')){
		currentUser = [SELECT Id, Name, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
		if(currentUser.Profile.Name == 'IPS Agent-Partner'){
			isAgent = true;
		}
		else{
			isAgent = false;
		}
		
	}	
	cs = Core_IPS_CaseUtility.getCase_DynamiCSOQL(caseId,isAgent);
    if (cs != null){
	if(cs.core_ips_project_case__c != null){
		project = new core_ips_project__c (name = cs.core_ips_project_case__r.Name, id = cs.core_ips_project_case__c);
		
	}
	
	if(cs.ContactId != null){  
		
		contact = new contact (FirstName = cs.Contact.FirstName, LastName = cs.Contact.LastName, id = cs.ContactId);
		//contact = new contact ( Name = cs.Contact.Name, id = cs.ContactId);
		
	}
	if(cs.assetId != null){
		asset = new asset (name = cs.product.name, id = cs.assetId);		
	}
	//start added by Aayushi for US217499
	//what is private Project? = UI logic need to understand
    if(cs.Core_IPS_Private_Project__c){
		isPrivateProjectCase=true;   
    }//end
	if(cs.Recordtype.DeveloperName=='IPS_GEC_ReadOnly' ){
	  showGECFields = true;
	}
    if(cs.Recordtype.DeveloperName=='IPS_Closed_Case'){
	  editCloseCasePermission = helper.checkcloseCaseEditPermission();
	}
	//added by sugandha for UserStory US83594 Iteration 6
	if(!String.isBlank(cs.Status) && cs.Status == 'Closed') {
	  isClosed = True;
	}
	//end
    if(cs <> null && cs.Core_IPS_Supported_Product__c <> null 
     // && categorySelected <> null && categorySelected <> ''
     ){    
		categoryOptions=new list<CustomSelectOptions>();
		categoryOptions=helper.getCategoryOptions(cs.Core_IPS_Supported_Product__c);           
	}
	if(cs <> null && cs.Core_Case_Issue_Sub_Category__c!=null){
	   //subCategorySelected=cs.Core_Case_Issue_Sub_Category__c;
	   //subCategoryOptions=new list<SelectOption>();
	   subCategoryOptions=helper.getsubCategoryOptions(cs.Core_Case_Issue_Sub_Category__c);
	}
    if(cs <> null && cs.Core_IPS_Partner_Sup_Owner__c!=null){
		this.PSO = new user(id=cs.Core_IPS_Partner_Sup_Owner__c, firstname=cs.Core_IPS_Partner_Sup_Owner__r.name, 
                            lastname=cs.Core_IPS_Partner_Sup_Owner__r.lastname);
    }    
	lstPSA =  DisplayPSAPSO(null, null, null, cs);
	
     // Added by sumukh for US69871	 
	if(cs.assetId!=null){
		blnShowVariant = true;
        //displayProductVariant();
       // variants = Product_Variant_Utility.displayProductVariant(cs.assetId);
    }
    List<Id> idList = new List<Id>();
	List<Id> assetIdList = new List<Id>();
    assetIdList.add(cs.assetId);
   platformOptions = helper.getplatformOptions(assetIdList);
    //Ashutosh_Us106566- Now we may have both asset id and supp product id on case so modifying the condition statement
	//if(cs <> null && cs.Core_IPS_Supported_Product__c <> null && cs.assetId == null){ 
	if(cs <> null && ((cs.Core_IPS_Supported_Product__c != null && cs.AssetId != null && cs.RecordType.DeveloperName == 'Core_IPS_Case_Create_Self_Assigned')|| (cs.Core_IPS_Supported_Product__c <> null && cs.assetId == null))){
			
		string selectedSAProductId = cs.Core_IPS_Supported_Product__c;                
		idList.add(selectedSAProductId);
		platformOptions = helper.getplatformOptions(idList);
		
		displayProject=false;                                                                               
		//LookupChange(); 
		if(cs.productId <> null && cs.product.name!=null) {
			String selectedSAProduct = cs.product.name;
		}
		//selectedSAProduct = supProd.core_product__r.name;                                       
		displaySelfAssigned = true;
		//List<Id> idList = new List<Id>();
		//caseTypeSelected='selfAssigned';
		selectedProductId =null; //added for DE27016
	}
    if(platformOptions.size()>1) {  
        displayPlatform=true;
    }    
	if(cs <> null && cs.Core_Severity__c == 'Critical'){
		DisplayPriorityReason = true;
	}
	// Added by sumukh for US107484   
              
    // asset = Plain 
    // product = NAC
   if(cs <> null && cs.Core_IPS_Supported_Product__c <> null && cs.assetId == null){      
		blnShowVariant_NAC = true;
       // variants_NAC = Product_Variant_Utility.displayProductVariant_NAC(cs.Core_IPS_Supported_Product__c);
	} // End By Sumukh for US107484 
		
    envDetails=helper.getEnvironmentDetailsOperationList(cs.Core_IPS_Supported_Product__c,null,isAgent);
	System.debug('hk 171----> '+envDetails);
	subCatEnvDetails = helper.getEnvironmentDetailsOperationList(null,cs.Core_Case_Issue_Sub_Category__c,isAgent);
	System.debug('hk 173----> '+subCatEnvDetails); 
    helper.setCurrentEnvironmentDetails(envDetails,''+cs.Id);
	helper.setCurrentEnvironmentDetails(subCatEnvDetails,''+cs.Id);
	fields = helper.getDynmicFields(envDetails);
	subCatFields = helper.getDynmicFields(subCatEnvDetails);
	if(cs.Core_IPS_Partner_Sup_Owner__c != null){
		list<String> queries = helper.getLookupPartnerOwner(cs.Core_IPS_Project_Case__c,  cs.ContactId);
		if(queries.size()==2){
       		 PSOQuery =  queries[0];
			PSOCountQuery = queries[1];
        }    
	}	
    }	
}                     
/***************************************************************************************************
Method Name:  DisplayPSAPSO
Method Type: Action Method 
Version     : 1.0 
Created Date: 16-03-2018
Function    : This method displays PSA and PSO based on Project and Contact selection.
Input Parameters: None
Output Parameters: None 
Used in     : Case Edit Screen
Modification Log :
               
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                   16/03/2018                 Created(UserStory US85567 Iteration 8)
****************************************************************************************************/ 
Public List<CustomSelectOptions>  DisplayPSAPSO(string selectedProjId, string selectedContactId, string selectedPSOId, case cs ){
	//set of all users assigned to  IPS FAE Partner Permission set     
    Set<Id> userIds = new Set<Id>();
    List<CustomSelectOptions> lstPSA = new List<CustomSelectOptions>();
    List<Core_IPS_Project_Member__c> projMem=null;
    for(PermissionSetAssignment uId: [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :System.Label.Core_IPS_Partner_DFAE_Permission_Set AND Assignee.ProfileId = :System.Label.Core_IPS_Partner_Profile_Id]){
		userIds.add(uId.AssigneeId);
        }
	//string selectedProjId = cs.Core_IPS_Project_Case__c; // this is being executed for edit case
	//string selectedContactId = cs.ContactId;
	//Senario 1:Project Based Cases - When editing the Partner Supported Account field, the picklist will only show accounts associated to project on the case      
	if((selectedProjId <> '' && selectedProjId != null) || cs.Core_IPS_Project_Case__c != null){
		String projtId = '';
		if(selectedProjId == null){
			projtId = cs.Core_IPS_Project_Case__c;
		}
		else{
			projtId = selectedProjId;
		}
		//List of all Active project members whose profile is Agent Partner profile or FAE Partner permission set
        //FLS Check Added - Yasasvi
        if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){
            projMem =[SELECT id 
                      FROM Core_IPS_Project_Member__c
                      WHERE (Core_User__c IN :userIds OR
                             Core_User__r.ProfileId = :system.Label.Core_IPS_Agent_Partner_Profile_id) AND
                      Core_IPS_Project__c =: projtId AND
                      Core_Status__c = 'Active']; 
        }
        //Render PSO PSA only if there are atleast a project member in above list                                    
        if(projMem != null && !projMem.isEmpty()){
            displayPSO = true;
		}
		//Query PSA only if there a PSO available under selected Project
		if(displayPSO == true){
			//List of Partner Support Account
			lstPSA = new List<CustomSelectOptions>();
			lstPSA.add(new CustomSelectOptions('','--None--'));
			//List of all active Accounts under selected project
			//FLS Check Added - Yasasvi
            if(account.SObjectType.getDescribe().isAccessible()){        
                List<Account> lstAcc = [SELECT id,Name FROM account
                                        WHERE Id IN (SELECT Core_Account__c FROM Core_IPS_Account__c 
                                                     WHERE Core_IPS_Project__c =:projtId AND 
                                                     Core_Status__c = 'Active')];
                for(Account acc : lstAcc){
                    lstPSA.add(new CustomSelectOptions(acc.Name, acc.id));
                } 
            }
        }
	}
	//Senario 2: When editing the Partner Supported Account field, the picklist should display all Accounts associated with all projects in which the PSO is a member.
	else if((selectedContactId != '' && SelectedContactId != null) || cs.AccountId <> null){
		String ConId = '';
		if(selectedContactId == null )
			ConId= cs.ContactId;
		else
			ConId= selectedContactId;
		//AccountId of Contact Case 
		Id AcctId;     
        //FLS Read fix applied - Gangadhar 19-10-2022
        if (Schema.sObjectType.Contact.isAccessible()){
        for(Contact c: [SELECT AccountId FROM Contact WHERE Id =: ConId and Core_IPS_Active__c = True]){
            AcctId = c.AccountId;
        }
        }

		//List of all active user under Account of the case
		if(AcctId != null){
			List<User> lstAcctUser= [SELECT id FROM User WHERE isActive=True AND 
									(Id IN :userIds OR ProfileId = :system.Label.Core_IPS_Agent_Partner_Profile_id) AND 
									Contact.AccountId =: AcctId];
			
			//Render PSO PSA if there is atleast one user in above list 
			if(lstAcctUser != null && !lstAcctUser.isEmpty()){
				displayPSO = true;
			}
        }
		//Query for PSA only if there is a eligible PSO available under Account 
		if(displayPSO == true){
			//list of Partner Support Account
			lstPSA = new List<CustomSelectOptions>();
			lstPSA.add(new CustomSelectOptions('','--None--'));
			String psoId = '';
			if(selectedPSOId == null)
				psoId = cs.Core_IPS_Partner_Sup_Owner__c;
			else
				psoId = selectedPSOId;
			if(selectedPSOId != null && selectedPSOId != ''){ 
				//set of project ids where PSO is a member
				set<Id> allProjIds = new set<Id>(); 
                //FLS Check Added - Yasasvi
                    if(Core_IPS_Project__c.SObjectType.getDescribe().isAccessible()){
                        for(Core_IPS_Project__c project: [SELECT id FROM Core_IPS_Project__c WHERE id IN (SELECT Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_User__c = :selectedPSOId AND Core_Status__c = 'Active')]){
                            allProjIds.add(project.Id);
                        } 
                    }
				//List of all Active Accounts which are part of above project list
				//FLS Check Added - Yasasvi
                if(Account.SObjectType.getDescribe().isAccessible()){
                    List<Account> lstAcc = [SELECT id,Name FROM account
                                            WHERE id IN (SELECT Core_Account__c FROM Core_IPS_Account__c 
                                                         WHERE Core_IPS_Project__c IN :allProjIds AND Core_Status__c = 'Active')];
                    for(Account acc : lstAcc){
                        lstPSA.add(new CustomSelectOptions(acc.id,acc.Name));
                    }
                }  
            }                
        }
    }
	return lstPSA;
}
	

}